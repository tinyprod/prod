README for Dma
Author/Contact: Eric B. Decker <cire831@gmail.com>

Description:

This test module is used for simple testing of the DMA driver.
It should just work on the x1, x2, or x5 cpu families.

It sets up an initial 512 byte buffer that is filled with a
known value.   Cascading dma transactions are set up to 
copy that buffer (B0n) into 3 other buffers using the 3 dma
engines.  Dma0 copies B0 -> B1, Dma1 B1 -> B2, and Dma2
does B2 -> B3.   B3 is checked against B0 for correctness.

This is done for each of the different transfer modes.  The
code can be tweaked to do things in different orders and
with different combinations.
