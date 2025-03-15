//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe (
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
  // Implement a pipelined module formula_1_pipe that computes the result
  // of the formula defined in the file formula_1_fn.svh.
  //
  // The requirements:
  //
  // 1. The module formula_1_pipe has to be pipelined.
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
  logic a_isvld, b_isvld, c_isvld, sum_isvld, vld_out;
  logic [31:0] a_sqrt, b_sqrt, c_sqrt, sum, valid_sum, res_out;

  isqrt i_isqrt_a (
      .clk  (clk),
      .rst  (rst),
      .x_vld(arg_vld),
      .x    (a),
      .y_vld(a_isvld),
      .y    (a_sqrt)
  );

  isqrt i_isqrt_b (
      .clk  (clk),
      .rst  (rst),
      .x_vld(arg_vld),
      .x    (b),
      .y_vld(b_isvld),
      .y    (b_sqrt)
  );

  isqrt i_isqrt_c (
      .clk  (clk),
      .rst  (rst),
      .x_vld(arg_vld),
      .x    (c),
      .y_vld(c_isvld),
      .y    (c_sqrt)
  );

  assign sum = a_sqrt + b_sqrt + c_sqrt;
  assign sum_isvld = a_isvld & b_isvld & c_isvld;

  always_ff @(posedge clk) begin
    if (rst) vld_out <= '0;
    else vld_out <= sum_isvld;
  end

  always_ff @(posedge clk) begin
    if ((a_isvld == 1) & (b_isvld == 1) & (c_isvld == 1)) res_out<= sum;
    else if (rst) res_out<= '0;
  end

  assign res_vld = vld_out;
  assign res = res_out;

endmodule
