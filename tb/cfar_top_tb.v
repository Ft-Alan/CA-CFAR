`timescale 1ns / 1ps

module cfar_top_tb;
    parameter N = 8192;
    
    reg clk;
    reg rst;
    
    reg signed [17:0] x1_r_mem[0:N-1];
    reg signed [17:0] x1_i_mem[0:N-1];
    reg signed [17:0] x2_r_mem[0:N-1];
    reg signed [17:0] x2_i_mem[0:N-1];
    reg signed [17:0] x3_r_mem[0:N-1];
    reg signed [17:0] x3_i_mem[0:N-1];
    reg signed [17:0] x4_r_mem[0:N-1];
    reg signed [17:0] x4_i_mem[0:N-1];
    
    wire [15:0] led_detection;  
    
    reg target_mask[0:N-1];
    
    // removed led_active port
    cfar_top DUT(
        .clk           (clk),
        .rst           (rst),
        .led_detection (led_detection)
    );
    
    // clock
    initial clk = 0;
    always #5 clk = ~clk;
    
    // reset
    initial begin
        rst = 1;
        #50;
        rst = 0;
    end
    
    // load memory files
    initial begin
        $readmemb("ant1_r.mem", x1_r_mem);
        $readmemb("ant1_i.mem", x1_i_mem);
        $readmemb("ant2_r.mem", x2_r_mem);
        $readmemb("ant2_i.mem", x2_i_mem);
        $readmemb("ant3_r.mem", x3_r_mem);
        $readmemb("ant3_i.mem", x3_i_mem);
        $readmemb("ant4_r.mem", x4_r_mem);
        $readmemb("ant4_i.mem", x4_i_mem);
    end
    
    // target mask
    integer b;
    initial begin
        for (b=0; b<N; b=b+1)
            target_mask[b] = 0;
        for (b=200; b<=N-200; b=b+500) begin
            target_mask[b]   = 1;
            target_mask[b+1] = 1;
            target_mask[b+2] = 1;
            target_mask[b+3] = 1;
        end
    end
    
    // i tracks BRAM address counter inside DUT instead of feeding samples
    wire [15:0] i;
    assign i = DUT.addr;
    
    // detection counting
    integer total_targets;
    integer detected_targets;
    integer sample_idx;
    
    initial begin
        total_targets    = 0;
        detected_targets = 0;
    end
    
    always @(posedge clk) begin
        if (i > 42 && i <= N) begin
            sample_idx = i - 28;
            if (sample_idx >= 0 && sample_idx < N) begin
                if (target_mask[sample_idx]) begin
                    total_targets = total_targets + 1;
                    if (DUT.u_cfar.detection)
                        detected_targets = detected_targets + 1;
                end
            end
        end
    end

    // final result
    real Pd;
    initial begin
        #(N * 10 + 500);
        Pd = real(detected_targets) / real(total_targets);
        $display("----------------------------------");
        $display("Total targets  : %0d", total_targets);
        $display("Detected       : %0d", detected_targets);
        $display("Pd             : %f", Pd);
        $display("Final LED count: %0d", led_detection[14:0]); 
        $display("----------------------------------");
        $finish;
    end

endmodule
