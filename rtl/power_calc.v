module power_calc(
    input clk,
    
    input signed [17:0] beam_r,
    input signed [17:0] beam_i,
    
    output reg [19:0] power
    );
    
    (* multstyle = "dsp" *) reg [35:0] real_sq;
    (* multstyle = "dsp" *) reg [35:0] imag_sq;
    
    reg [36:0] power_full;
    
    always @(posedge clk) begin

        real_sq     <= beam_r * beam_r;
        imag_sq     <= beam_i * beam_i;

        power_full  <= real_sq + imag_sq;

        power       <= power_full[31:12];  // keep 20 bits with 12 fractional

    end
endmodule
