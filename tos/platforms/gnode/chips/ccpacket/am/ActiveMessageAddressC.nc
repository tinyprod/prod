/**
 * Component that stores the node's active message address and group ID.
 * The L-node provides its own because our AM address includes the AM group bits.
 * It also provides an additional NetMask interface.
 */
module ActiveMessageAddressC	{
	provides {
		interface ActiveMessageAddress;
		interface NetMask;
	}
}

implementation {
	
	// this is set to TOS_NODE_ID by tos-set-symbols, so we'll add the group bits on demand
	am_addr_t addr = DEFINED_TOS_AM_ADDRESS;
	am_addr_t group = DEFINED_TOS_AM_GROUP;
	am_addr_t netmask = DEFINED_AM_NETWORK_MASK;
	
	async command am_addr_t ActiveMessageAddress.amAddress() {
		atomic return group | addr;
	}
	
	async command void ActiveMessageAddress.setAddress(am_group_t myGroup, am_addr_t myAddr) {
		atomic {
			addr = myAddr;
			group = myGroup;
		}
		
		signal ActiveMessageAddress.changed();
	}
	
	async command am_group_t ActiveMessageAddress.amGroup() {
		atomic return group;
	}
	
	async command void NetMask.setNetMask(am_netmask_t myNetmask) {
		atomic netmask = myNetmask;
		signal ActiveMessageAddress.changed();
	}
	
	async command am_netmask_t NetMask.netMask() {
		atomic return netmask;
	}

	default async event void ActiveMessageAddress.changed() {}
	
}
