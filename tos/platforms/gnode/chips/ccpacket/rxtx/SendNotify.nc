interface SendNotify {
	/**
	 * A message is about to be sent.
	 */
	event void sending(message_t* msg);
}