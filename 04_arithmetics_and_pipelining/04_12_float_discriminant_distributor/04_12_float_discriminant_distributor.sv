module float_discriminant_distributor #(
    n_pipe_stages = 4
) (
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
  //
  // Implement a module that will calculate the discriminant based
  // on the triplet of input number a, b, c. The module must be pipelined.
  // It should be able to accept a new triple of arguments on each clock cycle
  // and also, after some time, provide the result on each clock cycle.
  // The idea of the task is similar to the task 04_11. The main difference is
  // in the underlying module 03_08 instead of formula modules.
  //
  // Note 1:
  // Reuse your file "03_08_float_discriminant.sv" from the Homework 03.
  //
  // Note 2:
  // Latency of the module "float_discriminant" should be clarified from the waveform.

  // COUNTER
  logic [$clog2(n_pipe_stages)-1:0] cnt;

  always_ff @(posedge clk) begin
    if (rst) cnt <= '0;
    else if (arg_vld) cnt <= cnt + 1;
  end

  // LOGIC FOR IN
  logic [FLEN - 1:0] data_a[n_pipe_stages];
  logic [FLEN - 1:0] data_b[n_pipe_stages];
  logic [FLEN - 1:0] data_c[n_pipe_stages];
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
  logic [FLEN - 1:0] data_res[n_pipe_stages];
  logic [FLEN - 1:0] res_out;
  logic [n_pipe_stages -1 : 0] res_vld_for_each_module;
  logic [n_pipe_stages -1 : 0] res_negative_for_each_module;
  logic [n_pipe_stages -1 : 0] err_for_each_module;
  logic [n_pipe_stages -1 : 0] busy_for_each_module;


  always_comb begin
    for (int j = 0; j < n_pipe_stages; j++) begin
      if (res_vld_for_each_module == (1 << j)) begin
        res_out = data_res[j];
      end
    end
  end
  assign res_vld = |res_vld_for_each_module;
  assign res_negative = |res_negative_for_each_module;
  assign err = |err_for_each_module;
  assign busy = |busy_for_each_module;
  assign res = res_out;

  generate
    for (i = 0; i < n_pipe_stages; i++) begin

      float_discriminant fd (
          .clk(clk),
          .rst(rst),

          .arg_vld(arg_vld_for_each_module[i]),
          .a(data_a[i]),
          .b(data_b[i]),
          .c(data_c[i]),

          .res_vld(res_vld_for_each_module[i]),
          .res(data_res[i]),
          .res_negative(res_negative_for_each_module[i]),
          .err(err_for_each_module[i]),

          .busy(busy_for_each_module[i])
      );
    end
  endgenerate
endmodule
