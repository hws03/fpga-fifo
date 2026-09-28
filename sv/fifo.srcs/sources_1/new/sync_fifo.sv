module sync_fifo #(
    parameter DATA_WIDTH = 16,
    parameter FIFO_DEPTH = 16
) (
    input logic clk,
    input logic rst,
    input logic wr_en,
    input logic rd_en,
    input logic[DATA_WIDTH-1:0] data_in,
    
    output logic[DATA_WIDTH-1:0] data_out,
    output logic fifo_full,
    output logic fifo_empty   
);

localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);                            //number of bits required to represent FIFO_DEPTH

logic write_accepted, read_accepted;
logic[ADDR_WIDTH:0] wr_ptr, rd_ptr;
logic[ADDR_WIDTH:0] wr_ptr_next, rd_ptr_next;

typedef logic[DATA_WIDTH-1:0] mem_type[0:FIFO_DEPTH-1];
mem_type fifo_mem;



//combinational
assign write_accepted = wr_en && ~fifo_full;                           //if wr_en is high and fifo is not full, write is accepted
assign read_accepted = rd_en && ~fifo_empty;                           //if rd_en is high and fifo is not empty, read is accepted

assign wr_ptr_next = write_accepted ? wr_ptr + 1'b1 : wr_ptr;          //shift write pointer by 1 if write_accepted is high
assign rd_ptr_next = read_accepted ? rd_ptr + 1'b1 : rd_ptr;           //shift read pointer by 1 if read_accepted is high



//sequemtial: reset, pointers, full/empty
always_ff @(posedge clk) begin
    if (rst) begin
        wr_ptr <= '0;
        rd_ptr <= '0;
        fifo_full <= 0;
        fifo_empty <= 1;
    end
    else begin
        wr_ptr <= wr_ptr_next;
        rd_ptr <= rd_ptr_next;
        fifo_full <= (wr_ptr_next[ADDR_WIDTH-1:0] == rd_ptr_next[ADDR_WIDTH-1:0]) && (wr_ptr_next[ADDR_WIDTH] != rd_ptr_next[ADDR_WIDTH]);
        fifo_empty <= (wr_ptr_next == rd_ptr_next); 
    end
end


//sequemtial: write & read
always_ff @(posedge clk) begin
    if (write_accepted) begin
        fifo_mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
    end
    if (read_accepted) begin
        data_out <= fifo_mem[rd_ptr[ADDR_WIDTH-1:0]];
    end
end

endmodule
