/*
 * Copyright (c) 2010 People Power Co.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 *
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

generic module BareRf1aP (unsigned int BUFFER_SIZE) {
  provides {
    interface BareTxRx;
    interface BareMetadata;
    interface SplitControl;
  }
  uses {
    interface Resource;
    interface Rf1aPhysical;
    interface Rf1aPhysicalMetadata;
  }
} implementation {

  /** Indicate that this component has taken ownership of the radio.
   * When false, all Rf1aPhysical events are ignored.
   */
  bool active__;

  /** Space into which the outgoing message is copied, so the caller
   * can proceed while the data is being transmitted.
   */
  uint8_t txBuffer_[BUFFER_SIZE];

  /** The ultimate result of a successfully initiated
   * Rf1aPhysical.send operation.
   */
  error_t txResult__;

  /** True iff the txBuffer_ holds data that is actively being
   * transmitted.
   */
  bool txActive;

  /** Space into which incoming messages may be copied.  When this
   * component owns the radio, this buffer is provided as a single-use
   * receive buffer.  Upon receipt of a message, a task fires to
   * verify message integrity and if all is well to signal the
   * connected component.  The buffer is re-installed after these
   * steps have completed.
   */
  uint8_t rxBuffer_[BUFFER_SIZE];

  /** Metadata associated with the most recently received packet */
  rf1a_metadata_t metadata_;

  /** The reception status provided by Rf1aPhysical.receiveDone */
  error_t rxResult__;

  /** The number of octets in the rxBuffer_ */
  uint8_t rxLength__;

  command void* BareTxRx.transmitBuffer () { return txBuffer_; }

  command unsigned int BareTxRx.transmitBufferLength () { return sizeof(txBuffer_); }

  task void signalSplitControlStartDone_task () { signal SplitControl.startDone(SUCCESS); }
  task void signalSplitControlStopDone_task () { signal SplitControl.stopDone(SUCCESS); }

  command error_t SplitControl.start () {
    error_t rc;

    atomic {
      if (active__) {
        return EBUSY;
      }
    }
    rc = call Resource.immediateRequest();
    if (SUCCESS == rc) {
      rc = call Rf1aPhysical.setReceiveBuffer(rxBuffer_, sizeof(rxBuffer_), TRUE);
    }
    if (SUCCESS == rc) {
      atomic active__ = TRUE;
      post signalSplitControlStartDone_task();
    }
    return rc;
  }

  command error_t SplitControl.stop () {
    error_t rc;

    atomic {
      if (! active__) {
        return EOFF;
      }
      active__ = FALSE;
    }
    call Rf1aPhysical.setReceiveBuffer(0, 0, FALSE);
    rc = call Resource.release();
    if (SUCCESS == rc) {
      post signalSplitControlStopDone_task();
    }
    return rc;
  }

  task void sendDone_task () {
    error_t rc;
    atomic rc = txResult__;
    txActive = FALSE;
    signal BareTxRx.sendDone(rc);
  }

  async event void Rf1aPhysical.sendDone (int result) {
    atomic {
      /* Ignore irrelevant events */
      if (! active__) {
        return;
      }
      /* Save result for task processing */
      txResult__ = result;
    }
    post sendDone_task();
  }

  command error_t BareTxRx.send (const void* data,
                                 unsigned int length) {
    error_t rc;
    uint8_t* tbp = txBuffer_;

    /* Ensure we're allowed to use the radio */
    atomic {
      if (! active__) {
        return EOFF;
      }
    }

    /* Ensure we're not already using the radio */
    if (txActive) {
      return EBUSY;
    }

    /* Ensure we have room for the data */
    if (length > sizeof(txBuffer_)) {
      return EINVAL;
    }

    /* Copy the data into the transmit buffer (if it's not already
     * there), and append the CRC */
    if ((0 != data) && (tbp != data)) {
      memcpy(tbp, data, length);
    }
    tbp += length;

    rc = call Rf1aPhysical.send(txBuffer_, tbp - txBuffer_);
    if (SUCCESS == rc) {
      txActive = TRUE;
    }
    return rc;
  }

  command int BareMetadata.rssi () { return call Rf1aPhysicalMetadata.rssi(&metadata_); }
  command int BareMetadata.lqi () { return call Rf1aPhysicalMetadata.lqi(&metadata_); }

  task void receiveDone_task () {
    error_t rc;
    uint8_t len;
    bool ok;

    /* Extract the results from the Rf1aPhysical event */
    atomic {
      rc = rxResult__;
      len = rxLength__;
    }

    /* Must have successfully received a message, and radio-level CRC passed */
    ok = (SUCCESS == rc) && call Rf1aPhysicalMetadata.crcPassed(&metadata_);

    /* Only signal reception if all checks passed */
    if (ok) {
      signal BareTxRx.receive(rxBuffer_, len);
    }
    call Rf1aPhysical.setReceiveBuffer(rxBuffer_, sizeof(rxBuffer_), TRUE);
  }

  default event void BareTxRx.sendDone (error_t rc) { }

  default event void BareTxRx.receive (const void* data,
                                       unsigned int length) { }

  event void Resource.granted () { }

  async event void Rf1aPhysical.receiveDone (uint8_t* buffer,
                                             unsigned int count,
                                             int result) {
    atomic {
      /* Ignore irrelevant events */
      if (! active__) {
        return;
      }
      /* Cache results for task */
      rxResult__ = result;
      rxLength__ = count;
    }
    call Rf1aPhysicalMetadata.store(&metadata_);
    post receiveDone_task();
  }

  /* Ignore irrelevant Rf1aPhysical events */

  async event void Rf1aPhysical.receiveStarted (unsigned int length) { }
  async event void Rf1aPhysical.receiveBufferFilled (uint8_t* buffer,
                                                     unsigned int count) { }
  async event void Rf1aPhysical.frameStarted () { }
  async event void Rf1aPhysical.clearChannel () { }
  async event void Rf1aPhysical.carrierSense () { }
  async event void Rf1aPhysical.released () { }
}
