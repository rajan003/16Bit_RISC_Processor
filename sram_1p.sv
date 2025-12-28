// Single-port SRAM (sync read, full-word write, no reset)
// 1-cycle read latency: addr sampled in cycle N -> rdata valid at cycle N+1
module sram_1p #(
  parameter int ADDR_W = 10,   // depth = 2^ADDR_W words
  parameter int DATA_W = 32
)(
  input  logic                 clk,
  input  logic                 en,      // memory enable
  input  logic                 we,      // write enable (1=write, 0=read)
  input  logic [ADDR_W-1:0]    addr,
  input  logic [DATA_W-1:0]    wdata,
  output logic [DATA_W-1:0]    rdata
);

  localparam int DEPTH = 1 << ADDR_W;

  logic [DATA_W-1:0] mem   [0:DEPTH-1];
  logic [ADDR_W-1:0] addr_q;

  // Latch address for synchronous read
  always_ff @(posedge clk) begin
    if (en) begin
      addr_q <= addr;
    end
  end

  // Write (full word)
  always_ff @(posedge clk) begin
    if (en && we) begin
      mem[addr] <= wdata;
    end
  end

  // Read (1-cycle latency)
  always_ff @(posedge clk) begin
    if (en && !we) begin
      rdata <= mem[addr_q];
    end
  end

endmodule
