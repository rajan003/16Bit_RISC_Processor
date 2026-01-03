module sram_2p #(
  parameter ADDR_W = 6,
  parameter DATA_W = 32,
  parameter DEPTH  = 64
)(
  // Write port
  input  logic                 wclk,
  input  logic                 wen,
  input  logic [ADDR_W-1:0]     waddr,
  input  logic [DATA_W-1:0]     wdata,

  // Read port
  input  logic                 rclk,
  input  logic                 ren,
  input  logic [ADDR_W-1:0]     raddr,
  output logic [DATA_W-1:0]     rdata
);

  logic [DATA_W-1:0] mem [0:DEPTH-1];

  // Write logic  /// 1 cycle delay in Write
  always_ff @(posedge wclk) begin
    if (wen)
      mem[waddr] <= wdata;
  end

// Read logic with write-through bypass
// When write and read hit the same address at the same time, do you want:
//---	1.	Read old data
//---	2.	Read new data (write-through)--- This is Implemented
//---	3.	X / undefined
/// 1 cycle delay in Read
  always_ff @(posedge rclk) begin
    if (ren) begin
      if (wen && (waddr == raddr))   ///// Read And write at Same address
        rdata <= wdata;       // write-through
      else
        rdata <= mem[raddr];
    end
  end

endmodule
