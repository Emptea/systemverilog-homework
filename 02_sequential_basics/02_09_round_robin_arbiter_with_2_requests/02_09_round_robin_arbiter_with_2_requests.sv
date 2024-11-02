//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests (
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
  // Task:
  // Implement a "arbiter" module that accepts up to two requests
  // and grants one of them to operate in a round-robin manner.
  //
  // The module should maintain an internal register
  // to keep track of which requester is next in line for a grant.
  //
  // Note:
  // Check the waveform diagram in the README for better understanding.
  //
  // Example:
  // requests -> 01 00 10 11 11 00 11 00 11 11
  // grants   -> 01 00 10 01 10 00 01 00 10 01
  typedef enum bit [1:0] {
    none = 2'b00,
    first = 2'b01,
    second = 2'b10
  } state_e;
  state_e prev_state, state;

  always_ff @(posedge clk or posedge rst)
    if (rst) {prev_state, state} <= {none, none};
    else prev_state <= state;

  always_comb begin
    state = prev_state;
    case (prev_state)
      none:
      if (requests[0]) begin
        state = first;
      end else if (requests[1]) begin
        state = second;
      end
      first:  if (requests[1]) state = second;
      second: if (requests[0]) state = first;
    endcase
  end

  assign grants = requests & state;


endmodule
