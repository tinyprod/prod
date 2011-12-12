#include "AM.h"

/**
 * Allows setting and reading a node's netmask - which address bits represent the AM group.
 */
interface NetMask {
	async command void setNetMask(am_netmask_t mask);
	async command am_netmask_t netMask();
}
