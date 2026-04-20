module bram_sp #(
    parameter INIT_FILE = "",
    parameter DEPTH     = 8192,
    parameter WIDTH     = 18
)(
    input                         clk,
    input      [15:0]             addr,
    output reg signed [WIDTH-1:0] dout
);

    (* rom_style = "block" *)
    reg signed [WIDTH-1:0] mem [0:DEPTH-1];

    initial begin
        if (INIT_FILE != "")
            $readmemb(INIT_FILE, mem);
    end

    always @(posedge clk)
        dout <= mem[addr];

endmodule
