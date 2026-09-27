Synthesisable synchronous FIFO module designed for FPGA implementation using Vivado.

**Generics**: DATA_WIDTH (16), FIFO_DEPTH (16).

**Inputs**: `clk`, `rst` (synchronous active-high reset), `wr_en` (write enable), `rd_en` (read enable), `data_in` (DATA_WIDTH-1 downto 0).

**Outputs**: `data_out` (DATA_WIDTH-1 downto 0), `fifo_full`, `fifo_empty`.
