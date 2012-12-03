import binascii
import types
import struct
import sys

default_config_hexstr = '2E2E2947D391FF0445000A060022B13BC8931322F834073F10166C0340918000F05610EF2D251F0000590000813509C000000000000000000000'

class Rf1aConfig (object):

    PowerUpConfig_hexstr = '292e2e07d391ff044500000f001ec4ec8c220222f847073000766c034091876bf85610a90a200d0000597f3f88310bC600000000000000000000'
    F_XOSC = 26 * 1000000

    _BurstFields = [
        'iocfg2',             # 0x00 IOCFG2   - GDO2 output pin configuration  
        'iocfg1',             # 0x01 IOCFG1   - GDO1 output pin configuration  
        'iocfg0',             # 0x02 IOCFG0   - GDO0 output pin configuration  
        'fifothr',            # 0x03 FIFOTHR  - RX FIFO and TX FIFO thresholds 
        'sync1',              # 0x04 SYNC1    - Sync word, high byte 
        'sync0',              # 0x05 SYNC0    - Sync word, low byte 
        'pktlen',             # 0x06 PKTLEN   - Packet length 
        'pktctrl1',           # 0x07 PKTCTRL1 - Packet automation control 
        'pktctrl0',           # 0x08 PKTCTRL0 - Packet automation control 
        'addr',               # 0x09 ADDR     - Device address 
        'channr',             # 0x0A CHANNR   - Channel number 
        'fsctrl1',            # 0x0B FSCTRL1  - Frequency synthesizer control 
        'fsctrl0',            # 0x0C FSCTRL0  - Frequency synthesizer control 
        'freq2',              # 0x0D FREQ2    - Frequency control word, high byte 
        'freq1',              # 0x0E FREQ1    - Frequency control word, middle byte 
        'freq0',              # 0x0F FREQ0    - Frequency control word, low byte 
        'mdmcfg4',            # 0x10 MDMCFG4  - Modem configuration 
        'mdmcfg3',            # 0x11 MDMCFG3  - Modem configuration 
        'mdmcfg2',            # 0x12 MDMCFG2  - Modem configuration 
        'mdmcfg1',            # 0x13 MDMCFG1  - Modem configuration 
        'mdmcfg0',            # 0x14 MDMCFG0  - Modem configuration 
        'deviatn',            # 0x15 DEVIATN  - Modem deviation setting 
        'mcsm2',              # 0x16 MCSM2    - Main Radio Control State Machine configuration 
        'mcsm1',              # 0x17 MCSM1    - Main Radio Control State Machine configuration 
        'mcsm0',              # 0x18 MCSM0    - Main Radio Control State Machine configuration 
        'foccfg',             # 0x19 FOCCFG   - Frequency Offset Compensation configuration 
        'bscfg',              # 0x1A BSCFG    - Bit Synchronization configuration 
        'agcctrl2',           # 0x1B AGCCTRL2 - AGC control 
        'agcctrl1',           # 0x1C AGCCTRL1 - AGC control 
        'agcctrl0',           # 0x1D AGCCTRL0 - AGC control 
        'worevt1',            # 0x1E WOREVT1  - High byte Event0 timeout 
        'worevt0',            # 0x1F WOREVT0  - Low byte Event0 timeout 
        'worctrl',            # 0x20 WORCTRL  - Wake On Radio control 
        'frend1',             # 0x21 FREND1   - Front end RX configuration 
        'frend0',             # 0x22 FREND0   - Front end TX configuration 
        'fscal3',             # 0x23 FSCAL3   - Frequency synthesizer calibration 
        'fscal2',             # 0x24 FSCAL2   - Frequency synthesizer calibration 
        'fscal1',             # 0x25 FSCAL1   - Frequency synthesizer calibration 
        'fscal0',             # 0x26 FSCAL0   - Frequency synthesizer calibration 
        '_rcctrl1',           # RESERVED 0x27 RCCTRL1  - RC oscillator configuration 
        '_rcctrl0',           # RESERVED 0x28 RCCTRL0  - RC oscillator configuration 
        'fstest',             # 0x29 FSTEST   - Frequency synthesizer calibration control 
        'ptest',              # NOWRITE 0x2A PTEST    - Production test 
        'agctest',            # NOWRITE 0x2B AGCTEST  - AGC test 
        'test2',              # 0x2C TEST2    - Various test settings 
        'test1',              # 0x2D TEST1    - Various test settings 
        'test0',              # 0x2E TEST0    - Various test settings 
        ]
    _AuxFields = [
        'partnum',            # 0x30 PARTNUM  - Part number
        'version',            # 0x31 VERSION  - Current version number
        '_padding',
        # Status values provided only by Rf1aPhysical.readConfiguration,
        # never written.  It's not clear which of these are useful; the
        # ones I currently think aren't work the ROM are left disabled for
        # now.
        #'freqest',            # 0x32 FREQEST  - Frequency offset estimate
        #'lqi',                # 0x33 LQI      - Demodulator eestimate for link quality
        #'rssi',               # 0x34 RSSI     - Received signal strength indication
        #'marcstate',          # 0x35 MARCSTATE - Control state machine state
        #'wortime1',           # 0x36 WORTIME1  - High byte of WOR timer
        #'wortime0',           # 0x37 WORTIME0  - Low byte of WOR timer
        #'pktstatus',          # 0x38 PKTSTATUS - Current GDOx status and packet status
        #'vco_vc_dac',         # 0x39 VCO_VC_DAC - Current setting from PLL calibration module
        ]
    _Fields = _BurstFields + [ 'patable%u' % (_i,) for _i in xrange(8) ] + _AuxFields
    _StructLayout = '%dB8B%dB' % (len(_BurstFields), len(_AuxFields))
    _Length = struct.calcsize(_StructLayout)

    def __init__ (self, value):
        if isinstance(value, types.StringTypes):
            if 2 * self._Length == len(value):
                value = binascii.unhexlify(value)
            self.__data = list(struct.unpack(self._StructLayout, value))

    def __str__ (self):
        return "\n".join([ "%s = 0x%02x" % _v for _v in zip(self._Fields, self.__data) ])

    def _setField (self, field, value):
        idx = self._Fields.index(field)
        self.__data[idx] = value

    def _getField (self, field):
        return self.__data[self._Fields.index(field)]

    def pack (self):
        return struct.pack(self._StructLayout, *self.__data)

    def hexlify (self):
        return binascii.hexlify(self.pack()).upper()

    @classmethod
    def Extract (cls, data):
        return (cls(data[:cls._Length]), data[cls._Length:])

    _SmartRFStudio_map = { 'iocfg0d' : 'iocfg0' }
    @classmethod
    def FromSmartRFStudio_h (cls, filepath):
        TAG = 'SMARTRF_SETTING_'
        cfg = cls(cls.PowerUpConfig_hexstr)
        for line in file(filepath).readlines():
            if 0 > line.find(TAG):
                continue
            (_, var, val) = line.split()
            if not var.startswith(TAG):
                continue
            var = var[len(TAG):].lower()
            var = cls._SmartRFStudio_map.get(var, var)
            cfg._setField(var, int(val, 0))
        return cfg

for f in Rf1aConfig._Fields:
    setattr(Rf1aConfig, f, property(lambda _s,_f=f: _s._getField(_f)))

fn1 = sys.argv[1]
fn2 = sys.argv[2]

sfn1 = fn1.split('_')
sfn2 = fn2.split('_')

nfn1 = []
nfn2 = []
while sfn1 and sfn2:
    f1 = sfn1.pop(0)
    f2 = sfn2.pop(0)
    if f1 == f2:
        nfn1.append('*')
        nfn2.append('*')
    else:
        nfn1.append(f1)
        nfn2.append(f2)
dfn1 = '_'.join(nfn1)
dfn2 = '_'.join(nfn2)

cfg1 = Rf1aConfig.FromSmartRFStudio_h(sys.argv[1])
cfg2 = Rf1aConfig.FromSmartRFStudio_h(sys.argv[2])

print 'Field: %s %s' % (dfn1, dfn2)
for fn in Rf1aConfig._Fields:
    v1 = cfg1._getField(fn)
    v2 = cfg2._getField(fn)
    if v1 != v2:
        print '%-15s: %02x %02x' % (fn.upper(), v1, v2)
    
