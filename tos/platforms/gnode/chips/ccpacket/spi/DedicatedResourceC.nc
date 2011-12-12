/**
 * Resource implementation that just tracks whether it is owned or not, for a single owner.
 */
module DedicatedResourceC {
	provides interface Resource;
}

implementation {
	
	bool owned;
	
	task void grant() {
		signal Resource.granted();
	}
	
	async command error_t Resource.request() {
		atomic {
			if (owned) return FAIL;
			owned = TRUE;
			post grant();
		}
		
		return SUCCESS;
	}
	
	async command error_t Resource.immediateRequest() {
		atomic {
			if (owned) return FAIL;
			owned = TRUE;
		}
		
		return SUCCESS;
	}
	
	async command error_t Resource.release() {
		error_t error;
		atomic {
			error = owned ? SUCCESS : FAIL;
			owned = FALSE;
		}
		
		return error;
	}
	
	async command bool Resource.isOwner() {
		atomic return owned;
	}
	
	default event void Resource.granted() {}
	
}