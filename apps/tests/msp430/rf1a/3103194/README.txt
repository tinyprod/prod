Reproducer for bug 3103194

make surf install
make surf reinstall,2 bsl,/dev/mote/1

If the bug is still present, the LEDs on one of the boards will stop
blinking (due to deadlock) at some point.  You decide how long you want to
wait.  Prior to the fix, deadlock would generally occur within 30 seconds.

Submitter's description of problem:

Hi,

I have encountered some problems using the Rf1a stack. The issue occur
(randomly) when trying to send messages, with the symptom that the send
attempt gets stuck in a loop at line 708 in HplMsp430Rf1aP.nc:

 /* Delay until we're sure the RSSI measurement is valid.
  * Trick: clearChannel says RSSI is below threshold; CCA_MODE
  * set XX allows carrierSense to check that it's above
  * threshold.  When one of those signals is asserted, RSSI is
  * valid. */
 call Rf1aIf.writeRegister(MCSM1, 0x10 | (0x0f & mcsm1)); // <-- stuck here!
   while (! ((IFG_clearChannel | IFG_carrierSense | IFG_rxFifoAboveThreshold) & call Rf1aIf.getIn())) {
     ; // busywait
  }

mcsm1 is 51 (0x33) and RF1AIN is constantly 16 (0x10).

I experimented with forcing 'with_cca' to FALSE but that caused it to
get stuck elsewhere or otherwise fail instead.

Any ideas to what's going on here, and how to fix it?

The apparent bug is fairly easy to reproduce (usually takes only a
couple of seconds) in a high contention scenario using a pair of EM430
boards. A simple test case is attached. I used the default
smartrf_RF1A.h configuration. The test simply sends a lot of messages
and blink the LEDs upon receive and successful sends -- when the LEDs
stop blinking it's stuck.

I'm using the latest sources from the git repository, with the latest
mspgcc4 version.

/Staffan
