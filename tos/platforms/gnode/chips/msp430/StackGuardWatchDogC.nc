configuration StackGuardWatchDogC {
	provides {
		interface Init;
	}
}

implementation {
	
	components MainC, StackGuardWatchDogP, new TimerMilliC();

	Init = StackGuardWatchDogP;
	StackGuardWatchDogP.Boot -> MainC;
	StackGuardWatchDogP.Timer -> TimerMilliC;
	
}
