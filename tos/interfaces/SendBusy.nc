
interface SendBusy {
  /**
   * Check whether send queue entry is in use
   *
   * @return TRUE If client is active.
   *         FALSE Otherwise.
   */
  command bool busy();
}
