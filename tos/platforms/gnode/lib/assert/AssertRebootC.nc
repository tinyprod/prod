#include "AssertReboot.h"

/**
 * Handles failed assertions by rebooting the node.
 */
configuration AssertRebootC {}
	

implementation {
	
	components AssertRebootP, RebootC;

	AssertRebootP.Reboot -> RebootC;

}
