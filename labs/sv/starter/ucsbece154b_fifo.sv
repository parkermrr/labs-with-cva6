/*
 * File: ucsbece154b_fifo.sv
 * Description: Starter file for fifo.
 */

module ucsbece154b_fifo #(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned NR_ENTRIES = 4
) (
    input   logic                   clk,
    input   logic                   rst,

    output  logic [DATA_WIDTH-1:0]  data_o,
    input   logic                   pop_i,

    input   logic [DATA_WIDTH-1:0]  data_i,
    input   logic                   push_i,

    output  logic                   full_o,
    output  logic                   valid_o
);

logic [DATA_WIDTH - 1:0] RAM [0: NR_ENTRIES - 1];
logic [3:0] head_d, head_q, tail_d, tail_q;
logic [3:0] numEntries_d, numEntries_q;
logic write_allowed;

assign full_o = (numEntries_q == NR_ENTRIES);
assign valid_o = (numEntries_q =! 0);
assign data_o = valid_o ? RAM[head_q] : '0;

always_comb begin
    head_d = head_q;
    tail_d = tail_q;
    numEntries_d = numEntries_q;
    write_allowed = 0b'1;

    if (pop_i && valid_o) begin
        head_d = (head_d == NR_ENTRIES - 1) ? '0 : head_d + 1;
        numEntries_d--;
    end
    if (push_i && !full_o) begin
        tail_d = (tail_d == NR_ENTRIES - 1) ? '0 : tail_d + 1;
        write_allowed = 1b'1;
    end
end

always_ff @ (posedge clk) begin
    if (rst) begin
        head_q <= '0;
        tail_q <= '0;
        numEntries_q <= '0;
    end else
        head_q <= head_d;
        tail_q <= tail_d;
        numEntries_q <= numEntries_d;
        if (write_allowed) begin
            RAM[tail_q] <= data_i;
        end
    end
end

endmodule
