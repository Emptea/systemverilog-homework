//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.
    enum logic [1:0] {
        STATE_IDLE = 2'b00,
        STATE_COMP_U0_U1 = 2'b01,
        STATE_COMP_U1_U2 = 2'b10,
        STATE_COMP_U0_U2 = 2'b11
    } state, next_state;

    logic [FLEN-1:0] u0,u1,u2;
    logic u0_less_or_equal_u1, u1_less_or_equal_u2 ,u0_less_or_equal_u2;

    always_comb
    begin
        if (valid_in) begin
        u0 = unsorted[0];
        u1 = unsorted[1];
        u2 = unsorted[2];
        end
    end

    // state logic
    always_comb
    begin
        next_state = state;

        case (state)
        STATE_IDLE : if(valid_in) next_state = STATE_COMP_U0_U1;
        STATE_COMP_U0_U1: if (!f_le_err) next_state = STATE_COMP_U1_U2;
        STATE_COMP_U1_U2: if (!f_le_err) next_state = STATE_COMP_U0_U2;
        STATE_COMP_U0_U2: if (!f_le_err) next_state = STATE_IDLE;
        endcase
    end

    always_ff @ (posedge clk)
        if (rst | f_le_err)
            state <= STATE_IDLE;
        else
            state <= next_state;

    // f_le logic
    always_comb
    begin
        case (state)
        STATE_IDLE : begin
            f_le_a = u0;
            f_le_b = u1;
            u0_less_or_equal_u1 = f_le_res;
        end
        STATE_COMP_U0_U1: begin
            f_le_a = u1;
            f_le_b = u2;
            u1_less_or_equal_u2 = f_le_res;
        end
        STATE_COMP_U1_U2: begin
            f_le_a = u0;
            f_le_b = u2;
            u0_less_or_equal_u2 = f_le_res;
        end
        endcase
    end

    // sort logic
    always_comb
    if (u0_less_or_equal_u1 & u1_less_or_equal_u2)
        sorted = unsorted;
    else if (u0_less_or_equal_u1 & !u1_less_or_equal_u2 & u0_less_or_equal_u2)
            {   sorted [0],   sorted [1], sorted[2] }
        = { u0, u2, u1};
    else if (u0_less_or_equal_u1 & !u1_less_or_equal_u2 & !u0_less_or_equal_u2)
            {   sorted [0],   sorted [1], sorted[2] }
        = { u2, u0, u1};
    else if (!u0_less_or_equal_u1 & u1_less_or_equal_u2 & !u0_less_or_equal_u2)
            {   sorted [0],   sorted [1], sorted[2] }
        = { u1, u2, u0};
    else if (!u0_less_or_equal_u1 & u1_less_or_equal_u2 & u0_less_or_equal_u2)
            {   sorted [0],   sorted [1], sorted[2] }
        = { u1, u0, unsorted[2]};
    else if (!u0_less_or_equal_u1 & !u1_less_or_equal_u2)
            {   sorted [0],   sorted [1], sorted[2] }
        = { u2, u1, u0};

    assign valid_out = (state == STATE_COMP_U0_U2) | (f_le_err);
    assign err = f_le_err;
    assign bust = (state != STATE_IDLE);



endmodule
