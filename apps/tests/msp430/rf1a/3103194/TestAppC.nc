configuration TestAppC
{
}

implementation
{
    components MainC, ActiveMessageC, LedsC, TestC as App;
    components new AMSenderC(0) as AMSenderC;
    components new TimerMilliC() as Timer;

    App.Boot -> MainC;
    App.Leds -> LedsC;
    App.SplitControl -> ActiveMessageC;
    App.Timer -> Timer;
    App.AMSend -> AMSenderC;
    App.Receive -> ActiveMessageC.Receive[0];
}