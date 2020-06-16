`include "params.v"

module dut (
  input enable,
  input [`NUMADDR-1:0] soc_addr,
  input vdd,
  `ifdef USE_WREAL
  input real vddc,
  `else
  input vddc,
  `endif
  input vddf,

  output [31:0] port_a,
  output [15:0] port_b
);

  `ifdef USE_WREAL
  wire real vdd;
  wreal vddf;
  `endif

  wire logic sv_wire_logic;
  wire logic [3:0] sv_wire_logic_bus;
  logic sv_logic;
  logic [2:0] sv_logic_bus; 

  always @(*) begin
    // To expose a bug extracting pins when wreal support was added
  end
endmodule
