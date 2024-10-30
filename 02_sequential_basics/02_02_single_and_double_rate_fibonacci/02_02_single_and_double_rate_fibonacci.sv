//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module fibonacci (
    input               clk,
    input               rst,
    output logic [15:0] num
);

  logic [15:0] num2;

  always_ff @(posedge clk)
    if (rst) {num, num2} <= {16'd1, 16'd1};
    else {num, num2} <= {num2, num + num2};

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module fibonacci_2 (
    input               clk,
    input               rst,
    output logic [15:0] num,
    output logic [15:0] num2
);

  // Task:
  // Implement a module that generates two fibonacci numbers per cycle
  logic [15:0] prev_num1, prev_num2;

  always_ff @(posedge clk)
    if (rst) {prev_num2, prev_num1, num, num2} <= {16'd0, 16'd0, 16'd1, 16'd1};
    else {prev_num2, prev_num1, num, num2} <= {num, num + prev_num1, num + num2, num + num2 + num2};


endmodule
