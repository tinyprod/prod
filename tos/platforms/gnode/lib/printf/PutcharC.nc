/**
 * Provides a putchar() function for printf().
 */
 module PutcharC {
	 provides interface Putchar;
}

implementation {

	int putchar(int c) @C() @spontaneous() {
		signal Putchar.putchar((uint8_t) c);
		return 0;
	}

}
