`include "test1.v" 
`define TEST

`ifdef TEST
`ifndef TEST1
// Should not see me
`else
// Should see me
`endif
`endif

`ifdef TEST
`ifdef TEST2
// Should not see me
`elsif TEST1
// Should see me
`else
// Should not see me
`endif
`endif
