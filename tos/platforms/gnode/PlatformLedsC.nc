configuration PlatformLedsC {
	provides interface GeneralIO as Led0;
	provides interface GeneralIO as Led1;
	provides interface GeneralIO as Led2;
	uses interface Init;
}
implementation
{
	components GeneralIOC, PlatformP;

	Init = PlatformP.InitLevel[2];

	Led0 = GeneralIOC.GeneralIO[LED_GREEN];
	Led1 = GeneralIOC.GeneralIO[LED_YELLOW];
	Led2 = GeneralIOC.GeneralIO[LED_RED];

}
