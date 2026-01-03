// Code your testbench here
`timescale 1ns/1ps

// -------------------------
// Includes (plain-port models)
// -------------------------
`include "cpu_pkg.sv"
`include "imem_model.sv"
`include "dmem_model.sv"
`include "monitor_scoreboard.sv"

module tb;

  
  // DUMP VCD/////
  initial begin
  $dumpfile("dump.vcd");   // name of VCD file
  $dumpvars(0, tb);        // dump everything under tb
  end
  // -------------------------
  // Clock
  // -------------------------
  logic rst;/// Async reset 
  logic start;
  logic clk;
 initial begin
  clk = 1'b0;
  #50;                 // wait 50ns before starting the clock
  forever #5 clk = ~clk;  // 10ns period clock
 end

  // -------------------------
  // IMEM wires (DUT <-> imem_model)
  // -------------------------
  logic                      imem_en;
  logic [INST_ADDR_WIDTH-1:0] imem_addr;   // word address
  logic [INST_DATA_WIDTH-1:0] imem_data;   // instruction into CPU

  // -------------------------
  // DMEM wires (DUT <-> dmem_model) : 2-port
  // -------------------------
  logic        dmem_wen;
  logic [MEM_ADDR_WIDTH-1:0] dmem_waddr;
  logic [MEM_DATA_WIDTH-1:0] dmem_wdata;

  logic        dmem_ren;
  logic [MEM_ADDR_WIDTH-1:0] dmem_raddr;
  logic [MEM_DATA_WIDTH-1:0] dmem_rdata;

  // -------------------------
  // RF monitor wires (DUT -> monitor)
  // -------------------------
  logic [3:0]  rf_wr_addr;
  logic [31:0] rf_wr_data;
  logic        rf_wr_en;

  // -------------------------
  // DUT
  // -------------------------
  CPU_Top dut (
    .clk        (clk),
    .rst        (rst),
    .start		(start),
    // IMEM
    .imem_en    (imem_en),
    .imem_addr  (imem_addr),
    .imem_data  (imem_data),

    // DMEM 2-port
    .dmem_waddr (dmem_waddr),
    .dmem_wdata (dmem_wdata),
    .dmem_wen   (dmem_wen),

    .dmem_raddr (dmem_raddr),
    .dmem_rdata (dmem_rdata),
    .dmem_ren   (dmem_ren),

    // RF monitor
    .rf_wr_addr (rf_wr_addr),
    .rf_wr_data (rf_wr_data),
    .rf_wr_en   (rf_wr_en)
  );

  // -------------------------
  // IMEM model
  // -------------------------
  imem_model #(.DATA_WIDTH(INST_DATA_WIDTH), .ADDR_WIDTH(INST_ADDR_WIDTH)) imem (
    .clk        (clk),
    .rst        (rst),
    .imem_en    (imem_en),
    .imem_addr  (imem_addr),
    .imem_instr (imem_data)
  );

  // -------------------------
  // DMEM model
  // -------------------------
  dmem_model #(
    .ADDR_W (MEM_ADDR_WIDTH),
    .DATA_W (MEM_DATA_WIDTH)
  ) dmem (
    .clk        (clk),

    .dmem_wen   (dmem_wen),
    .dmem_waddr (dmem_waddr),
    .dmem_wdata (dmem_wdata),

    .dmem_ren   (dmem_ren),
    .dmem_raddr (dmem_raddr),
    .dmem_rdata (dmem_rdata)
  );

  // -------------------------
  // Monitor / scoreboard (nicer DMEM read alignment)
  // -------------------------
  monitor_scoreboard #(
    .INST_ADDR_W (INST_ADDR_WIDTH),
    .INST_DATA_W (INST_DATA_WIDTH),
    .DMEM_ADDR_W (MEM_ADDR_WIDTH),
    .DMEM_DATA_W (MEM_DATA_WIDTH)
  ) mon (
    .clk        (clk),
    .rst(rst),

    .imem_en    (imem_en),
    .imem_addr  (imem_addr),
    .imem_instr (imem_data),

    .dmem_wen   (dmem_wen),
    .dmem_waddr (dmem_waddr),
    .dmem_wdata (dmem_wdata),

    .dmem_ren   (dmem_ren),
    .dmem_raddr (dmem_raddr),
    .dmem_rdata (dmem_rdata),

    .rf_wr_addr (rf_wr_addr),
    .rf_wr_data (rf_wr_data),
    .rf_wr_en   (rf_wr_en)
  );

  // -------------------------
  // Program load + run
  // -------------------------
    task automatic load_program_from_file(string filename);
      $display("Loading program from %s", filename);
      $readmemh(filename, imem.mem, 0 , 10); // OK because mem is declared in imem_model // The 10 will limit the read to 11 instrcutions
       // Sanity check
      $display("IMEM[0] = 0x%08h", imem.mem[0]);
      $display("IMEM[1] = 0x%08h", imem.mem[1]);
      $display("IMEM[2] = 0x%08h", imem.mem[2]);
    endtask


  // Reset + program load (asynchronous reset)
   task automatic run_cycles(int n);
      for (int i = 0; i < n; i++) @(posedge clk);
    endtask

  // Reset + program load + start enable
 initial begin : reset_load_start
    rst   = 1'b0;   // assert async reset
    start = 1'b0;
    // load program while in reset
    load_program_from_file("program.hex");

    // keep reset asserted for some time (true async)
    #45;
    rst <= 1'b1;
    #50
    start = 1'b1;

  end


  // Test sequence (start after reset deassert)
  initial begin : test_sequence
    logic [31:0] result;
    #50
    run_cycles(20);

    result = dmem.read_word(0);
    $display("Result at dmem[0] = 0x%08h", result);

    $display("TEST DONE");
    #40;
    $finish;
  end
endmodule
