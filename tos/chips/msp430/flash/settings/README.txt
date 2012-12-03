This library uses the flash driver on the MSP430 to store
configuration data.  Essentially, it lets you take your variables
scattered throughout your program that are normally kept in RAM, 
and make them non-volatile. 

On Init, it will send out a request to all users to log in.
At that time, the user SHOULD call back with a login command, 
passing in the address of the data in RAM you want to keep mirrored
on non-volatile memory, and the size of that data in RAM.  It can
be something as small as a byte, or as big as a struct.

Each component can store its variables with the store() command,
or load the variables with the load() command.  After login on boot,
each component's RAM is automatically refreshed with the last stored()
values before the reboot occurred.  

load() will return SUCCESS if the data loaded and its CRC was good and
your variable in RAM will be automatically updated with the value
from non-volatile memory.

