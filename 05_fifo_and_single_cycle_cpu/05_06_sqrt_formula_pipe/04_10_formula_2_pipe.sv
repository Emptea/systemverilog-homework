//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe #(
    parameter n_pipe_stages = 16,
    parameter width = 32
) (
    input clk,
    input rst,

    input        arg_vld,
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,

    output        res_vld,
    output [31:0] res
);

  // Task:
  //
  // Implement a pipelined module formula_2_pipe that computes the result
  // of the formula defined in the file formula_2_fn.svh.
  //
  // The requirements:
  //
  // 1. The module formula_2_pipe has to be pipelined.
  //
  // It should be able to accept a new set of arguments a, b and c
  // arriving at every clock cycle.
  //
  // It also should be able to produce a new result every clock cycle
  // with a fixed latency after accepting the arguments.
  //
  // 2. Your solution should instantiate exactly 3 instances
  // of a pipelined isqrt module, which computes the integer square root.
  //
  // 3. Your solution should save dynamic power by properly connecting
  // the valid bits.
  //
  // You can read the discussion of this problem
  // in the article by Yuri Panchul published in
  // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
  // You can download this issue from https://fpga-systems.ru/fsm#state_0

  logic abc_isvld, bc_sqrt_isvld, c_sqrt_isvld, sum_isvld, vld_out;
  logic [31:0] abc_sqrt, bc_sqrt, c_sqrt, sum, valid_sum, res_out;

  //  C path logic
  isqrt i_isqrt_c (
      .clk  (clk),
      .rst  (rst),
      .x_vld(arg_vld),
      .x    (c),
      .y_vld(c_sqrt_isvld),
      .y    (c_sqrt)
  );

  // B path logic
  logic arg_vld_b, arg_vld_c_sqrt;
  logic [31:0] data_b;
  logic [31:0] bc_in, bc_sum;

  shift_register_with_valid #(
      .width(width),
      .depth(n_pipe_stages)
  ) i_shift_register_with_valid_for_b (
      .clk     (clk),
      .rst     (rst),
      .in_vld  (arg_vld),
      .in_data (b),
      .out_vld (arg_vld_b),
      .out_data(data_b)
  );

  assign bc_sum = data_b + c_sqrt;
  always_ff @(posedge clk) if (c_sqrt_isvld) bc_in <= bc_sum;
  always_ff @(posedge clk) arg_vld_c_sqrt <= c_sqrt_isvld;

  isqrt i_isqrt_bc (
      .clk  (clk),
      .rst  (rst),
      .x_vld(arg_vld_c_sqrt),
      .x    (bc_in),
      .y_vld(bc_sqrt_isvld),
      .y    (bc_sqrt)
  );

  // A path logic
  logic arg_vld_a, arg_vld_bc_sqrt;
  logic [31:0] data_a;
  logic [31:0] abc_in, abc_sum;

  shift_register_with_valid #(
      .width(width),
      .depth(2 * n_pipe_stages + 1)
  ) i_shift_register_with_valid_for_a (
      .clk     (clk),
      .rst     (rst),
      .in_vld  (arg_vld),
      .in_data (a),
      .out_vld (arg_vld_a),
      .out_data(data_a)
  );
  assign abc_sum = data_a + bc_sqrt;
  always_ff @(posedge clk) if (bc_sqrt_isvld) abc_in <= abc_sum;
  always_ff @(posedge clk) arg_vld_bc_sqrt <= bc_sqrt_isvld;

  isqrt i_isqrt_abc (
      .clk  (clk),
      .rst  (rst),
      .x_vld(arg_vld_bc_sqrt),
      .x    (abc_in),
      .y_vld(res_vld),
      .y    (res)
  );

endmodule
