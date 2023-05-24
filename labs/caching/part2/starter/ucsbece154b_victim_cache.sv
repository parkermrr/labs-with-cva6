/*
 * File: ucsbece154b_victim_cache.sv
 * Description: Starter file for a victim cache.
 * Directions:
 *  The implementation should be a fully-associative cache with LRU replacement policy. It should
 *  have support for any positive integer cache size, meaning that the LRU algorithm will change a
 *  bit depending on the specified size. For a cache size of 1, there is no LRU logic necessary
 *  because only one way can be replaced. For a cache size of 2, there should be a single bit
 *  specifying which way was least recently accessed, and therefore which way should be replaced.
 *  For a cache size >2, there should be a doubly-linked-list (DLL) that orders each way from LRU
 *  to MRU; every read/write should bump the corresponding way to the MRU of the DLL, and every
 *  write should replace the LRU of the DLL.
 */

module ucsbece154b_victim_cache #(
    parameter int unsigned ADDR_WIDTH = 56,
    parameter int unsigned LINE_WIDTH = 128,
    parameter int unsigned NR_ENTRIES = 4
) (
    input   logic                   clk_i,
    input   logic                   rst_ni,
    input   logic                   flush_i,
    input   logic                   en_i,

    input   logic [ADDR_WIDTH-1:0]  raddr_i,
    output  logic [LINE_WIDTH-1:0]  rdata_o,
    output  logic                   hit_o,

    input   logic                   we_i,
    input   logic [ADDR_WIDTH-1:0]  waddr_i,
    input   logic [LINE_WIDTH-1:0]  wdata_i
);

localparam OFFSET_WIDTH = $clog2(LINE_WIDTH/8); // TODO (in terms of ADDR_WIDTH and LINE_WIDTH)
localparam TAG_SIZE = ADDR_WIDTH - OFFSET_WIDTH; // TODO (in terms of ADDR_WIDTH and LINE_WIDTH)

logic [TAG_SIZE-1:0] rtag, wtag;
assign rtag = raddr_i[OFFSET_WIDTH +: TAG_SIZE]; // "indexed part-select" operator
assign wtag = waddr_i[OFFSET_WIDTH +: TAG_SIZE];

integer i = 0;


/* verilator lint_off UNUSED */
wire unused = (|i)|(|raddr_i[OFFSET_WIDTH-1:0])|(|waddr_i[OFFSET_WIDTH-1:0]);
/* verilator lint_on UNUSED */




if (NR_ENTRIES==1) begin : one_register
// 1-way fully associative cache
// no LRU needed
//




struct packed {
    logic [LINE_WIDTH-1:0] data;
    logic [TAG_SIZE-1:0] tag;
    logic valid;
} MEM_d, MEM_q;

assign hit_o = en_i && MEM_q.valid && (rtag == MEM_q.tag); // TODO
assign rdata_o = MEM_q.data; // TODO

always_comb begin
    MEM_d = MEM_q;
    if (en_i && we_i) begin
        MEM_d.data = wdata_i; // TODO
        MEM_d.tag = wtag; // TODO
        MEM_d.valid = 1'b1; // TODO
    end
end
always_ff @(posedge clk_i) begin
    if (!rst_ni || flush_i || !en_i) begin
        MEM_q <= '0;
    end else begin
        MEM_q <= MEM_d;
    end
end




//
end else if (NR_ENTRIES==2) begin : lru_bit
// 2-way fully associative cache
// LRU is 1 bit to show which way should be replaced on a write
//

// cache memory
struct packed {
    logic [LINE_WIDTH-1:0] data;
    logic [TAG_SIZE-1:0] tag;
    logic valid;
} MEM_d[1:0], MEM_q[1:0];

// lru register
logic lru_d, lru_q;

always_comb begin
    // combinational nets
    rdata_o = 'x;
    hit_o = 1'b0;
    // registers
    lru_d = lru_q;
    MEM_d = MEM_q;

    // assign read port
    for (i = 0; i < 2; i++) begin
        if (en_i && MEM_q[i].valid && (rtag==MEM_q[i].tag)) begin
            hit_o = 1'b1; // TODO
            rdata_o = MEM_q[i].data; // TODO
            lru_d = i == 1 ? 0 : 1; // TODO
        end
    end
    // handle write port
    if (en_i && we_i) begin
        MEM_d[lru_d].data = wdata_i; // TODO
        MEM_d[lru_d].tag = wtag; // TODO
        MEM_d[lru_d].valid = 1'b1; // TODO
        lru_d = lru_d == 1 ? 0 : 1; // TODO
    end
end
always_ff @(posedge clk_i) begin
    if ((!rst_ni) || flush_i || (!en_i)) begin
        MEM_q[0].valid <= '0;
        MEM_q[1].valid <= '0;
        lru_q <= '0;
    end else begin
        MEM_q <= MEM_d;
        lru_q <= lru_d;
    end
end




//
end else begin : lru_linked_list
// n-way fully associative cache
// LRU implemented as linked list
//



//                  DLL Structure                   //
// MRU - ... - way.mru - way - way.lru - ... -  LRU //

typedef logic [$clog2(NR_ENTRIES)-1:0] way_index_t;

struct packed {
    logic [LINE_WIDTH-1:0] data;
    logic [TAG_SIZE-1:0] tag;
    way_index_t lru; // less recently used
    way_index_t mru; // more recently used
    logic valid;
} MEM_d[NR_ENTRIES-1:0], MEM_q[NR_ENTRIES-1:0];

// lru register
way_index_t lru_d, lru_q, mru_d, mru_q;

function void lru_bump(input way_index_t way);
    // function to move way to MRU while maintaining DLL structure
    if (way != lru_d) 
        MEM_d[MEM_d[way].mru].lru = MEM_d[way].lru;
    if (way != mru_d) 
        MEM_d[MEM_d[way].lru].mru = MEM_d[way].mru;
    if (way == lru_d) 
        lru_d = MEM_d[way].mru;
    MEM_d[way].lru = mru_d;
    MEM_d[mru_d].mru = way;
    mru_d = way;
endfunction

always_comb begin
    // combinational nets
    rdata_o = 'x;
    hit_o = 1'b0;
    // registers
    lru_d = lru_q;
    mru_d = mru_q;
    MEM_d = MEM_q;

    // assign read port
    for (i = 0; i < NR_ENTRIES; i++) begin
        if (en_i && MEM_d[i].valid && (rtag==MEM_d[i].tag)) begin
            hit_o = 1'b1; // TODO
            rdata_o = MEM_d[i].data; // TODO
            lru_bump(way_index_t'(i));
            break;
        end
    end
    // handle write port
    if (en_i && we_i) begin
        MEM_d[lru_d].data = wdata_i; // TODO
        MEM_d[lru_d].tag = wtag; // TODO
        MEM_d[lru_d].valid = 1'b1; // TODO
        lru_bump(lru_d);
    end
    // handle reset/flush/disable
    if (!rst_ni || flush_i || !en_i) begin
        for (i = 0; i < NR_ENTRIES; i++) begin
            MEM_d[i].valid = 1'b0;
            MEM_d[i].lru = way_index_t'(i-1);
            MEM_d[i].mru = way_index_t'(i+1);
        end
        lru_d = '0;
        mru_d = way_index_t'(NR_ENTRIES-1);
    end
end
always_ff @(posedge clk_i) begin
    MEM_q <= MEM_d;
    lru_q <= lru_d;
    mru_q <= mru_d;
end




//
end

endmodule
