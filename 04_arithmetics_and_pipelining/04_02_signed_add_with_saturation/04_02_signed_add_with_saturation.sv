//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add (
    input  [3:0] a,
    b,
    output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation (
    input  [3:0] a,
    b,
    output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.
  logic [3:0] sum_inner, sum_satur;
  assign sum_inner = a + b;

  logic high_cond, low_cond;
  assign high_cond = !a[3] & !b[3] & sum_inner[3];
  assign low_cond  = a[3] & b[3] & !sum_inner[3];

  always_comb begin
    if (high_cond) sum_satur = 'b0111;
    else if (low_cond) sum_satur = 'b1000;
    else sum_satur = sum_inner;
  end

  assign sum = sum_satur;


endmodule
