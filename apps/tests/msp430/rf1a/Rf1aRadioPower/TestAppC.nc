configuration TestAppC {
} implementation {
  components TestP;
  components MainC;

  TestP.Boot -> MainC;
  
  components new Rf1aPhysicalC();
  TestP.Resource -> Rf1aPhysicalC;
  TestP.Rf1aIf -> Rf1aPhysicalC;
  // TestP.Rf1aPhysical -> Rf1aPhysicalC;
  // TestP.Rf1aPhysicalMetadata -> Rf1aPhysicalC;

  components new Rf1aPhysicalIntrospectC();
  Rf1aPhysicalIntrospectC.Rf1aIf -> Rf1aPhysicalC;
  TestP.Rf1aPhysicalIntrospect -> Rf1aPhysicalIntrospectC;

  components new Rf1aRadioPowerC();
  Rf1aRadioPowerC.Rf1aIf -> Rf1aPhysicalC;
  Rf1aRadioPowerC.Rf1aPhysicalIntrospect -> Rf1aPhysicalIntrospectC;
  TestP.Rf1aRadioPower -> Rf1aRadioPowerC;

#include <unittest/config_impl.h>
}
