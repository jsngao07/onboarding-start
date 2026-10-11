## How it works

This project implements a SPI peripheral that receives commands from COPI, SCLK, and nCS inputs. I used 3-stage FF chain to synchronize SCLK and nCS, and 2-stage chain for COPI, with the internal clock to reduce the risk of metastability. It detects rising edges of SCLK to sample incoming bits into 16-bit shift register. When nCS rises, it validates the 16-bit command by checking the bit count, R/W bit, and address range. If valid, the address determines which of the five 8-bit output registers is updated, controlling outputs and PWM settings.

## How to test

This project uses Cocotb tests.

## External hardware
No external hardware was used.
