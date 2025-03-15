module put_in_order #(
    parameter width    = 16,
    n_inputs = 4
) (
    input clk,
    input rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                   down_vld,
    output [width   - 1 : 0] down_data
);

  // Task:
  //
  // Implement a module that accepts many outputs of the computational blocks
  // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
  // are coming from an array of non-pipelined computational blocks.
  // These external computational blocks have a variable latency.
  //
  // The order of incoming "up_vlds" is not determent, and the task is to
  // output "down_vld" and corresponding data in a round-robin manner,
  // one after another, in order.
  //
  // Comment:
  // The idea of the block is kinda similar to the "parallel_to_serial" block
  // from Homework 2, but here block should also preserve the output order.

  logic [n_inputs - 1 : 0]                   requests;
  logic [n_inputs - 1 : 0][width    - 1 : 0] data;
  logic                                      vld_out;
  logic [ width   - 1 : 0]                   data_out;

  always_ff @(posedge clk) begin
    for (int i = 0; i < n_inputs; i++) begin
      if (up_vlds[i]) begin
        requests[i] <= up_vlds[i];
        data[i] <= up_data[i];
      end
    end
  end

  always_ff @(posedge clk) begin
    for (int i = 0; i < n_inputs; i++) begin
      if (up_vlds[i]) requests[i] <= up_vlds[i];
    end
  end

  logic [$clog2(n_inputs)-1:0] cnt;
  always_ff @(posedge clk) begin
    if (rst) cnt <= '0;
    else if (requests[cnt]) begin
      requests[cnt] <= '0;
      data_out <= data[cnt];
      vld_out <= '1;
      cnt <= cnt + 1;
    end else vld_out <= '0;
  end

  assign down_data = data_out;
  assign down_vld = vld_out;



endmodule
