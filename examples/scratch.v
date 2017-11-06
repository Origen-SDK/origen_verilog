/* A multi line
 * comment
 */

// A single comment

`ifdef PICORV32_V
`error "picosoc.v must be read before picorv32.v!"
`endif

`define PICORV32_REGS picosoc_regs
`define BLAH
`undef BLAH

module picosoc (

);

endmodule
