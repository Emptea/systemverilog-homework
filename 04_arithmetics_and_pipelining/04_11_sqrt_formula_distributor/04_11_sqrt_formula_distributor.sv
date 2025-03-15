module sqrt_formula_distributor #(
    parameter formula = 1,
    impl    = 1,
    n_pipe_stages = 64
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
  // Implement a module that will calculate formula 1 or formula 2
  // based on the parameter values. The module must be pipelined.
  // It should be able to accept new triple of arguments a, b, c arriving
  // at every clock cycle.
  //
  // The idea of the task is to implement hardware task distributor,
  // that will accept triplet of the arguments and assign the task
  // of the calculation formula 1 or formula 2 with these arguments
  // to the free FSM-based internal module.
  //
  // The first step to solve the task is to fill 03_04 and 03_05 files.
  //
  // Note 1:
  // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
  // or simply assumed to be equal 50 clock cycles.
  //
  // Note 2:
  // The task assumes idealized distributor (with 50 internal computational blocks),
  // because in practice engineers rarely use more than 10 modules at ones.
  // Usually people use 3-5 blocks and utilize stall in case of high load.
  //
  // Hint:
  // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
  // or "formula_2_top" modules to achieve desired performance.

  // COUNTER
  logic [$clog2(n_pipe_stages)-1:0] cnt;

  always_ff @(posedge clk) begin
    if (rst) cnt <= '0;
    else if (arg_vld) cnt <= cnt + 1;
  end

  // LOGIC FOR IN
  logic [31:0] data_a[n_pipe_stages];
  logic [31:0] data_b[n_pipe_stages];
  logic [31:0] data_c[n_pipe_stages];
  logic [n_pipe_stages -1 : 0] arg_vld_for_each_module;
  generate
    genvar i;
    for (i = 0; i < n_pipe_stages; i++) begin
      always_ff @(posedge clk) begin
        if (rst) arg_vld_for_each_module[i] <= '0;
        else if (cnt == i) arg_vld_for_each_module[i] <= arg_vld;
        else arg_vld_for_each_module[i] <= '0;


        if (arg_vld & (cnt == i)) begin
          data_a[i] <= a;
          data_b[i] <= b;
          data_c[i] <= c;
        end
      end
    end
  endgenerate

  // LOGIC FOR OUT
  logic [31:0] data_res[n_pipe_stages];
  logic [31:0] res_out;
  logic [n_pipe_stages -1 : 0] res_vld_for_each_module;

  always_comb begin
    for (int j = 0; j < n_pipe_stages; j++) begin
      if (res_vld_for_each_module == (1 << j)) begin
        res_out = data_res[j];
      end
    end
  end
  assign res_vld = |res_vld_for_each_module;
  assign res = res_out;

  // MODULE INSTANCES
  generate
    for (i = 0; i < n_pipe_stages; i++) begin
      if (formula == 1 & impl == 1) begin
        formula_1_impl_1_top f11 (
            .clk(clk),
            .rst(rst),
            .arg_vld(arg_vld_for_each_module[i]),
            .a(data_a[i]),
            .b(data_b[i]),
            .c(data_c[i]),
            .res_vld(res_vld_for_each_module[i]),
            .res(data_res[i])
        );
      end else if (formula == 1 & impl == 2) begin
        formula_1_impl_2_top f12 (
            .clk(clk),
            .rst(rst),
            .arg_vld(arg_vld_for_each_module[i]),
            .a(data_a[i]),
            .b(data_b[i]),
            .c(data_c[i]),
            .res_vld(res_vld_for_each_module[i]),
            .res(data_res[i])
        );

      end else if (formula == 2) begin
        formula_2_top f2 (
            .clk(clk),
            .rst(rst),
            .arg_vld(arg_vld_for_each_module[i]),
            .a(data_a[i]),
            .b(data_b[i]),
            .c(data_c[i]),
            .res_vld(res_vld_for_each_module[i]),
            .res(data_res[i])
        );
      end
    end
  endgenerate

endmodule
