//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections
  wire or_out, and_out;
  mux mux_or(b,1'b1, a, or_out);
  mux mux_and (1'b0, a, b, and_out);
  mux mux_out(or_out, '0, and_out, o);

endmodule
