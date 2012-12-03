#include <stdio.h>
#include <Rf1aConfigure.h>
#include <Rf1aRadioPower.h>

module TestP {
  uses interface Boot;
  uses {
    interface HplMsp430Rf1aIf as Rf1aIf;
    interface Rf1aPhysicalIntrospect;
    interface Rf1aRadioPower;
    interface Resource;
  }
#include <unittest/module_spec.h>
} implementation {
#include <unittest/module_impl.h>

  enum {
    DEFAULT_TX_POWER = SMARTRF_SETTING_PATABLE0,
    PATABLE_LEN = 8,
  };

  const rf1a_patable_t _patables[] = {
    RF1A_TX_PATABLE_SETTINGS_INIT
  };
  const int8_t _pa_levels[] = RF1A_TX_PATABLE_LEVELS_INIT;

  void resetPATABLE ()
  {
    uint8_t patable[PATABLE_LEN];
    memset(&patable, 0, sizeof(patable));
    patable[0] = DEFAULT_TX_POWER;
    call Rf1aIf.writeBurstRegister(PATABLE, patable, sizeof(patable));
  }

  bool checkPATABLEIsReset ()
  {
    uint8_t patable[PATABLE_LEN];
    int i;
    
    memset(patable, 255, sizeof(patable));
    call Rf1aIf.readBurstRegister(PATABLE, patable, sizeof(patable));
    if (DEFAULT_TX_POWER != patable[0]) {
      return FALSE;
    }
    for (i = 1; i < PATABLE_LEN; ++i) {
      if (0 != patable[i]) {
        return FALSE;
      }
    }
    return TRUE;
  }

  void testDefaultPower ()
  {
    ASSERT_EQUAL(DEFAULT_TX_POWER, call Rf1aRadioPower.getTxPower_reg());
    ASSERT_TRUE(checkPATABLEIsReset());
    ASSERT_EQUAL(0, RF1A_MIN_TX_POWER_INDEX);
    ASSERT_EQUAL(7, RF1A_MAX_TX_POWER_INDEX);
  }

  void testBurstWrite ()
  {
    const rf1a_patable_t* tp = _patables;
    uint8_t patable[PATABLE_LEN];

    ASSERT_TRUE(checkPATABLEIsReset());
    ASSERT_EQUAL(315, tp->freq_MHz);
    ASSERT_EQUAL(PATABLE_LEN, sizeof(tp->patable));
    call Rf1aIf.writeBurstRegister(PATABLE, tp->patable, sizeof(tp->patable));
    ASSERT_TRUE(! checkPATABLEIsReset());
    call Rf1aIf.readBurstRegister(PATABLE, patable, sizeof(patable));
    ASSERT_TRUE(0 == memcmp(patable, tp->patable, sizeof(patable)));
    resetPATABLE();
  }

  void testSingleReadWrite ()
  {
    const rf1a_patable_t* tp = _patables;
    uint8_t patable[PATABLE_LEN];
    int i;

    ASSERT_TRUE(checkPATABLEIsReset());
    ASSERT_EQUAL(315, tp->freq_MHz);
    for (i = 0; i < PATABLE_LEN; ++i) {
      call Rf1aIf.writeRegister(PATABLE, tp->patable[i]);
    }
    ASSERT_TRUE(! checkPATABLEIsReset());
    call Rf1aIf.readBurstRegister(PATABLE, patable, sizeof(patable));
    ASSERT_TRUE(0 == memcmp(patable, tp->patable, sizeof(patable)));
    for (i = 0; i < PATABLE_LEN; ++i) {
      patable[i] = call Rf1aIf.readRegister(PATABLE);
    }
    ASSERT_TRUE(0 == memcmp(patable, tp->patable, sizeof(patable)));
    resetPATABLE();
  }

  void testSetTxPowerReg ()
  {
    const rf1a_patable_t* tp = _patables + sizeof(_patables)/sizeof(*_patables) - 1;
    uint8_t max_power;
    ASSERT_TRUE(checkPATABLEIsReset());
    ASSERT_EQUAL(915, tp->freq_MHz);
    max_power = tp->patable[RF1A_MAX_TX_POWER_INDEX];
    ASSERT_EQUAL(0xc0, max_power);
    ASSERT_EQUAL(DEFAULT_TX_POWER, call Rf1aRadioPower.getTxPower_reg());
    call Rf1aRadioPower.setTxPower_reg(max_power);
    ASSERT_EQUAL(max_power, call Rf1aRadioPower.getTxPower_reg());
    ASSERT_TRUE((max_power == DEFAULT_TX_POWER) || (! checkPATABLEIsReset()));
    resetPATABLE();
  }

  void testSetTxPowerIdx ()
  {
    const rf1a_patable_t* tp = _patables + sizeof(_patables)/sizeof(*_patables) - 1;
    uint8_t idx;
    int rv;

    ASSERT_TRUE(checkPATABLEIsReset());

    rv = call Rf1aRadioPower.setTxPower_idx(RF1A_MIN_TX_POWER_INDEX);
    ASSERT_EQUAL(_pa_levels[RF1A_MIN_TX_POWER_INDEX], rv);
    rv = call Rf1aRadioPower.setTxPower_idx(RF1A_MAX_TX_POWER_INDEX);
    ASSERT_EQUAL(_pa_levels[RF1A_MAX_TX_POWER_INDEX], rv);
    rv = call Rf1aRadioPower.setTxPower_idx(RF1A_MAX_TX_POWER_INDEX + 1);
    ASSERT_EQUAL(INT_MAX, rv);

    idx = (RF1A_MAX_TX_POWER_INDEX + RF1A_MIN_TX_POWER_INDEX) / 2;    
    ASSERT_EQUAL(3, idx);
    ASSERT_EQUAL(-10, _pa_levels[idx]);
    rv = call Rf1aRadioPower.setTxPower_idx(idx);
    ASSERT_EQUAL(_pa_levels[idx], rv);
    ASSERT_EQUAL(tp->patable[idx], call Rf1aRadioPower.getTxPower_reg());

    resetPATABLE();
  }

  void testSetTxPowerDbm ()
  {
    const rf1a_patable_t* tp = _patables + sizeof(_patables)/sizeof(*_patables) - 1;
    int idx;
    int dbm;
    int rv;

    ASSERT_TRUE(checkPATABLEIsReset());
    dbm = _pa_levels[0] - 1;
    rv = call Rf1aRadioPower.setTxPower_dBm(dbm);
    ASSERT_EQUAL(_pa_levels[0], rv);
    ASSERT_EQUAL(tp->patable[0], call Rf1aRadioPower.getTxPower_reg());

    dbm = (_pa_levels[2] + _pa_levels[3]) / 2;
    ASSERT_EQUAL(-12, dbm);
    idx = 3;
    rv = call Rf1aRadioPower.setTxPower_dBm(dbm);
    ASSERT_EQUAL(_pa_levels[idx], rv);
    ASSERT_EQUAL(tp->patable[idx], call Rf1aRadioPower.getTxPower_reg());

    dbm -= 1;
    ASSERT_EQUAL(-13, dbm);
    idx = 2;
    rv = call Rf1aRadioPower.setTxPower_dBm(dbm);
    ASSERT_EQUAL(_pa_levels[idx], rv);
    ASSERT_EQUAL(tp->patable[idx], call Rf1aRadioPower.getTxPower_reg());

    dbm = 7;
    idx = 6;
    ASSERT_EQUAL(_pa_levels[idx], dbm);
    rv = call Rf1aRadioPower.setTxPower_dBm(dbm);
    ASSERT_EQUAL(_pa_levels[idx], rv);
    ASSERT_EQUAL(tp->patable[idx], call Rf1aRadioPower.getTxPower_reg());

    dbm = 50;
    idx = 7;
    rv = call Rf1aRadioPower.setTxPower_dBm(dbm);
    ASSERT_EQUAL(_pa_levels[idx], rv);
    ASSERT_EQUAL(tp->patable[idx], call Rf1aRadioPower.getTxPower_reg());

    resetPATABLE();
  }

  void testRxAttenuationDbm ()
  {
    int rv;
    
    ASSERT_EQUAL(0, call Rf1aRadioPower.getRxAttenuation_dBm());
    rv = call Rf1aRadioPower.setRxAttenuation_dBm(2);
    ASSERT_EQUAL(0, rv);
    ASSERT_EQUAL(0, call Rf1aRadioPower.getRxAttenuation_dBm());

    rv = call Rf1aRadioPower.setRxAttenuation_dBm(3);
    ASSERT_EQUAL(6, rv);
    ASSERT_EQUAL(6, call Rf1aRadioPower.getRxAttenuation_dBm());

    rv = call Rf1aRadioPower.setRxAttenuation_dBm(6);
    ASSERT_EQUAL(6, rv);
    ASSERT_EQUAL(6, call Rf1aRadioPower.getRxAttenuation_dBm());

    rv = call Rf1aRadioPower.setRxAttenuation_dBm(8);
    ASSERT_EQUAL(6, rv);
    ASSERT_EQUAL(6, call Rf1aRadioPower.getRxAttenuation_dBm());

    rv = call Rf1aRadioPower.setRxAttenuation_dBm(14);
    ASSERT_EQUAL(12, rv);
    ASSERT_EQUAL(12, call Rf1aRadioPower.getRxAttenuation_dBm());

    rv = call Rf1aRadioPower.setRxAttenuation_dBm(20);
    ASSERT_EQUAL(18, rv);
    ASSERT_EQUAL(18, call Rf1aRadioPower.getRxAttenuation_dBm());

    rv = call Rf1aRadioPower.setRxAttenuation_dBm(50);
    ASSERT_EQUAL(18, rv);
    ASSERT_EQUAL(18, call Rf1aRadioPower.getRxAttenuation_dBm());

    // Ha-ha---yeah, nice try.  Physics don't work that way.
    rv = call Rf1aRadioPower.setRxAttenuation_dBm(-10);
    ASSERT_EQUAL(0, rv);
    ASSERT_EQUAL(0, call Rf1aRadioPower.getRxAttenuation_dBm());
  }
  
  event void Boot.booted () {
    error_t rc = call Resource.immediateRequest();
    ASSERT_EQUAL(SUCCESS, rc);
    testDefaultPower();
    testBurstWrite();
    testSingleReadWrite();
    testSetTxPowerReg();
    testSetTxPowerIdx();
    testSetTxPowerDbm();
    testRxAttenuationDbm();
    ALL_TESTS_PASSED();
  }

  event void Resource.granted () { }

}
