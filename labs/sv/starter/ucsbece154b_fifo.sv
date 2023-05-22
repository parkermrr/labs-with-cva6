/*
 * File: ucsbece154b_fifo.sv
 * Description: Starter file for fifo.
 */

module ucsbece154b_fifo #(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned NR_ENTRIES = 4
) (
    input   logic                   clk_i,
    input   logic                   rst_i,

    output  logic [DATA_WIDTH-1:0]  data_o,
    input   logic                   pop_i,

    input   logic [DATA_WIDTH-1:0]  data_i,
    input   logic                   push_i,

    output  logic                   full_o,
    output  logic                   valid_o
);

logic [DATA_WIDTH - 1:0] RAM [0: NR_ENTRIES - 1];
integer head;
integer tail;
integer numEntries;

assign full_o = numEntries == NR_ENTRIES ? 1 : 0;
assign valid_o = numEntries == 0 ? 0 : 1;

always_ff @ (posedge clk_i) begin
    if (pop_i && valid_o) begin
        data_o <= RAM[head];
        head <= (head + 1) % NR_ENTRIES;
        numEntries--;
    end
    if (push_i && !full_o) begin
        RAM[tail] <= data_i;
        tail <= (tail + 1) % NR_ENTRIES;
        numEntries++;
    end
end

endmodule
