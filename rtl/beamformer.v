module beamformer(
    input clk,
    
    input signed [17:0] x1_r,
    input signed [17:0] x1_i,
    input signed [17:0] x2_r,
    input signed [17:0] x2_i,
    input signed [17:0] x3_r,
    input signed [17:0] x3_i,
    input signed [17:0] x4_r,
    input signed [17:0] x4_i,
    
    output reg signed [17:0] beam_r,
    output reg signed [17:0] beam_i
    );
    
    reg signed [19:0] sum_r, sum_i;
    
    always @(posedge clk) begin
        sum_r = $signed(x1_r) - $signed(x2_i) - $signed(x3_r) + $signed(x4_i);
        sum_i = $signed(x1_i) + $signed(x2_r) - $signed(x3_i) - $signed(x4_r);
        
        beam_r <= sum_r >>> 1;
        beam_i <= sum_i >>> 1;
    end

endmodule
