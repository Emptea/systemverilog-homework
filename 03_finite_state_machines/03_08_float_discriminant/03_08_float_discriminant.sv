//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input clk,
    input rst,

    input              arg_vld,
    input [FLEN - 1:0] a,
    input [FLEN - 1:0] b,
    input [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic busy
);

  // Task:
  // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
  // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
  // That is, res = b^2 - 4ac == b*b - 4*a*c
  //
  // Note:
  // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
  //
  // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
  // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

  logic [FLEN - 1:0] b_sq, ac, four_ac;
  logic down_valid_b_sq, down_valid_ac, down_valid_four_ac;
  logic busy_b_sq, busy_ac, busy_sub, busy_four_ac;
  logic err_b_sq, err_ac, err_sub, err_four_ac;
  real four = 4.0;

  f_mult i_b_sq (
      .clk(clk),
      .rst(rst),
      .a(b),
      .b(b),
      .up_valid(arg_vld),
      .res(b_sq),
      .down_valid(down_valid_b_sq),
      .busy(busy_b_sq),
      .error(err_b_sq)
  );

  f_mult i_ac (
      .clk(clk),
      .rst(rst),
      .a(a),
      .b(c),
      .up_valid(arg_vld),
      .res(ac),
      .down_valid(down_valid_ac),
      .busy(busy_ac),
      .error(err_ac)
  );

  f_mult i_four_ac (
      .clk(clk),
      .rst(rst),
      .a(four),
      .b(ac),
      .up_valid(arg_vld),
      .res(four_ac),
      .down_valid(down_valid_four_ac),
      .busy(busy_four_ac),
      .error(err_four_ac)
  );

  f_sub i_discr (
      .clk(clk),
      .rst(rst),
      .a(b_sq),
      .b(four_ac),
      .up_valid(arg_vld),
      .res(res),
      .down_valid(res_vld),
      .busy(busy_sub),
      .error(err_sub)
  );

  assign busy = busy_ac | busy_b_sq | busy_sub;
  assign err  = err_ac | err_b_sq | err_sub;

endmodule
