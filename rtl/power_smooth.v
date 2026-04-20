module power_smooth(
    input clk,
    input rst,
    input [19:0] power,
    output reg [19:0] power_s
    );
    
    reg [19:0] d1, d2, d3, d4;
    reg [23:0] sum;
    
    always @(posedge clk) begin
        if (rst) begin
            d1  <= 0; d2        <= 0;
            d3  <= 0; d4        <= 0;
            sum <= 0; power_s   <= 0;
            
        end else begin
            d4      <= d3;
            d3      <= d2;
            d2      <= d1;
            d1      <= power;
            sum     <= sum - d4 + power;
            power_s <= sum >> 2;
            
        end
    end
endmodule
