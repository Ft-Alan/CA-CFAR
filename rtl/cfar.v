`timescale 1ns / 1ps
module cfar(
    input clk,
    input rst,
    input [19:0] power_s,
    output reg detection
);
    
    reg [19:0] shift_reg[0:27];
    reg [24:0] window_sum;
    reg [24:0] guard_sum;
    reg [24:0] running_sum;
    reg [24:0] running_sum_d;
    
    localparam [15:0] ALPHA = 16'd18595;
    localparam [5:0]  N_CUT = 6'd12;
    
    reg [42:0] rhs_full;
    reg [26:0] lhs_d;
    reg [26:0] lhs;
    reg [26:0] lhs_dd;
    reg [26:0] lhs_ddd;   // extra delay stage
    reg [30:0] rhs;
    
    integer k;
    
    wire [24:0] window_sum_next = window_sum + power_s - shift_reg[27];
    wire [24:0] guard_sum_next  = guard_sum  + shift_reg[7] - shift_reg[22];
    
    
    always @(posedge clk) begin
        if (rst) begin
            window_sum  <= 0;
            guard_sum   <= 0;
            running_sum <= 0;
            running_sum_d <= 0;
            detection   <= 0;
            lhs_d       <= 0;
            lhs         <= 0;
            lhs_dd      <= 0;
            lhs_ddd     <= 0;
            rhs         <= 0;
            rhs_full    <= 0;
            for (k=0; k<28; k=k+1)
                shift_reg[k] <= 0;
        end
        else begin
            // shift register
            shift_reg[0] <= power_s;
            for (k=1; k<28; k=k+1)
                shift_reg[k] <= shift_reg[k-1];
            
            // stage 1
            window_sum  <= window_sum_next;
            guard_sum   <= guard_sum_next;
            
            // stage 2
            running_sum   <= window_sum_next - guard_sum_next;
            lhs_d         <= N_CUT * shift_reg[14];

            // stage 3
            running_sum_d <= running_sum;
            lhs           <= lhs_d;
            rhs_full      <= ALPHA * running_sum_d;

            // stage 4
            lhs_dd <= lhs;
            rhs    <= rhs_full[42:12];

            // stage 5
            detection <= (lhs_dd > rhs);
        end
    end

endmodule
