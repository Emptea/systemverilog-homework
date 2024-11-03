//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel #(
    parameter width = 8
) (
    input clk,
    input rst,

    input serial_valid,
    input serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
  // Task:
  // Implement a module that converts serial data to the parallel multibit value.
  //
  // The module should accept one-bit values with valid interface in a serial manner.
  // After accumulating 'width' bits, the module should assert the parallel_valid
  // output and set the data.
  //
  // Note:
  // Check the waveform diagram in the README for better understanding.

  logic [$clog2(width) - 1:0] idx;
  logic [width-1:0] buff;
  logic vld;

  always_ff @(posedge clk) begin
    if (rst) {idx, buff} <= {'0, '0};
    else if (serial_valid) {idx, buff[idx]} <= {idx + 1'b1, serial_data};
  end

  always_ff @(posedge clk) begin
    if (rst | vld) vld <= '0;
    else if (serial_valid & (idx == width - 1)) vld <= '1;
  end

  assign parallel_valid = vld;
  always_comb begin
    if (vld) parallel_data = buff;
  end

endmodule
