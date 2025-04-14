//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe_using_fifos #(
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
  // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
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
  // 3. Your solution should use FIFOs instead of shift registers
  // which were used in 04_10_formula_2_pipe.sv.
  //
  // You can read the discussion of this problem
  // in the article by Yuri Panchul published in
  // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
  // You can download this issue from https://fpga-systems.ru/fsm

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
  logic arg_vld_c_sqrt;
  logic [31:0] data_b;
  logic [31:0] bc_in, bc_sum;

  wire b_fifo_push;
  wire b_fifo_pop;
  wire b_fifo_empty;
  wire b_fifo_full;

  flip_flop_fifo_with_counter #(
      .width(width),
      .depth(n_pipe_stages)
  ) fifo_b (
      .clk       (clk),
      .rst       (rst),
      .push      (b_fifo_push),
      .pop       (b_fifo_pop),
      .write_data(b),
      .read_data (data_b),
      .empty     (b_fifo_empty),
      .full      (b_fifo_full)
  );
  assign b_ready           = ~b_fifo_full;
  assign b_valid = ~b_fifo_empty;

  assign b_fifo_push       = arg_vld & b_ready;
  assign b_fifo_pop        = b_valid & c_sqrt_isvld;
  assign b_fifo_write_data = b;

  assign bc_sum            = data_b + c_sqrt;
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
  logic arg_vld_bc_sqrt;
  logic [31:0] data_a;
  logic [31:0] abc_in, abc_sum;

  wire a_fifo_push;
  wire a_fifo_pop;
  wire a_fifo_empty;
  wire a_fifo_full;

  flip_flop_fifo_with_counter #(
      .width(width),
      .depth(n_pipe_stages)
  ) fifo_a (
      .clk       (clk),
      .rst       (rst),
      .push      (a_fifo_push),
      .pop       (a_fifo_pop),
      .write_data(a),
      .read_data (data_a),
      .empty     (a_fifo_empty),
      .full      (a_fifo_full)
  );
  assign a_ready           = ~a_fifo_full;
  assign a_valid = ~a_fifo_empty;

  assign a_fifo_push       = arg_vld & a_ready;
  assign a_fifo_pop        = a_valid & bc_sqrt_isvld;
  assign a_fifo_write_data = a;
  
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
