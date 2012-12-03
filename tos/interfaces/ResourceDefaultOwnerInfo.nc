
interface ResourceDefaultOwnerInfo {
  /**
   * Check whether a DefaultOwner has an active client.
   *
   * @return TRUE If client is active.
   *         FALSE Otherwise.
   */
  async command bool inUse();
}
