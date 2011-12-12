/**
 * Reboots the node by tripping the watchdog timer.
 */ 
module RebootC {
	provides interface Reboot;
}

implementation {
	
	async command void Reboot.reboot() {
		atomic WDTCTL = 0;
	}
}
