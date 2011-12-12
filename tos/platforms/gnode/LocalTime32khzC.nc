#include "Timer.h"

configuration LocalTime32khzC {
	provides interface LocalTime<T32khz>;
}

implementation {
	components Counter32khz32C;
	components new CounterToLocalTimeC(T32khz);

	LocalTime = CounterToLocalTimeC;
	CounterToLocalTimeC.Counter -> Counter32khz32C;
}
