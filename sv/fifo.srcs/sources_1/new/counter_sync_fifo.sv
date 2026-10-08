module sync_fifo #(
    parameter int DATA_WIDTH = 16,
    parameter int FIFO_DEPTH = 16
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

localparam int PTR_WIDTH = (FIFO_DEPTH > 1) ? $clog2(FIFO_DEPTH) : 1;   // 0 to FIFO_DEPTH-1
localparam int CNT_WIDTH = $clog2(FIFO_DEPTH + 1);                      // 0 to FIFO_DEPTH

logic [DATA_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];

// pointers
logic [PTR_WIDTH-1:0] wr_pointer = '0;
logic [PTR_WIDTH-1:0] rd_pointer = '0;

logic [CNT_WIDTH-1:0] counter = '0;

logic write_accepted;
logic read_accepted;


assign write_accepted = (wr_en == 1'b1) && (counter < CNT_WIDTH'(FIFO_DEPTH));   //check if write_enable is high and fifo is not full
assign read_accepted  = (rd_en == 1'b1) && (counter > '0);                       //check if read_enable is high and fifo is not empty


always_ff @(posedge clk) begin
    if (rst == 1'b1) begin
        data_out   <= '0;
        wr_pointer <= '0;
        rd_pointer <= '0;
        counter    <= '0;
    end 
    
    else begin

        //----------------------- write ------------------------------------------------------------
        if (write_accepted) begin
            fifo_mem[wr_pointer] <= data_in;                        //store data at current write pointer position

            if (wr_pointer == FIFO_DEPTH - 1)                       //reset pointer if reached max depth
                wr_pointer <= '0;
            else
                wr_pointer <= wr_pointer + 1'b1;                    //shift write pointer by one place if max depth not reached
        end

        //----------------------- read -------------------------------------------------------------
        if (read_accepted) begin
            data_out <= fifo_mem[rd_pointer];                       //output data at current read pointer position

            if (rd_pointer == FIFO_DEPTH - 1)                       //reset pointer if reached max depth
                rd_pointer <= '0;
            else
                rd_pointer <= rd_pointer + 1'b1;                    //shift read pointer by one place if max depth not reached
        end

        //----------------------- counter logic ----------------------------------------------------
        if (write_accepted && !read_accepted)
            counter <= counter + 1'b1;                              //write adds an element so increase counter
        else if (read_accepted && !write_accepted)
            counter <= counter - 1'b1;                              //read removes an element so decrease counter
    end
end


assign fifo_empty = (counter == '0);                                //high while counter is 0 (fifo is empty)
assign fifo_full = (counter == FIFO_DEPTH);                         //high while counter is max depth (fifo is full)

endmodule
