`timescale 1ns/1ps

module sobel_edge_tb;

    parameter IMG_W  = 640;
    parameter IMG_H  = 480;
    parameter PIX_W  = 8;
    parameter ADDR_W = 32;
    parameter CLK_PERIOD = 10;
	 
    reg clk,rst,start;
    wire [ADDR_W-1:0] in_addr;
    reg  [PIX_W-1:0]  in_pixel;
    wire              out_valid;
    wire [ADDR_W-1:0] out_addr;
    wire [PIX_W-1:0]  out_pixel;
    reg [PIX_W-1:0] input_mem  [0:IMG_W*IMG_H-1];
    reg [PIX_W-1:0] output_mem [0:IMG_W*IMG_H-1];
	 
    integer i;
    integer fd;


    sobel_edge #(
        .IMG_W (IMG_W),
        .IMG_H (IMG_H),
        .PIX_W (PIX_W),
        .ADDR_W(ADDR_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .in_addr(in_addr),
        .in_pixel(in_pixel),
        .out_valid(out_valid),
        .out_addr (out_addr),
        .out_pixel(out_pixel));
		  
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
	 
    initial begin
        $display("Loading input image...");
        $readmemh("E:/sobel_verilog/input_2_image_hex.txt", input_mem); // input_image.txt must contain ONE decimal pixel per line (0–255)
        $display("Image load attempted (check transcript for warnings)");
    end
	 
    always @(*) begin
        in_pixel = input_mem[in_addr];
    end
	 
    always @(posedge clk) begin
        if (out_valid) begin
            output_mem[out_addr] <= out_pixel;
        end
    end

    initial begin
        rst   = 1;
        start = 0;
        for (i = 0; i < IMG_W*IMG_H; i = i + 1)
            output_mem[i] = 8'd0;
        #(CLK_PERIOD * 5);
        rst = 0;
        #(CLK_PERIOD);
        start = 1;
        #(CLK_PERIOD * IMG_W * IMG_H);
        start = 0;
        #(CLK_PERIOD * 200);
        fd = $fopen("E:/sobel_verilog/sobel_output_4.pgm", "w");
		  
        if (fd == 0) begin
            $display("ERROR: Could not open output file");
            $finish;
        end
		  
        $fdisplay(fd, "P2");
        $fdisplay(fd, "%0d %0d", IMG_W, IMG_H);
        $fdisplay(fd, "255");
		  
        for (i = 0; i < IMG_W*IMG_H; i = i + 1) begin
            if (^output_mem[i] === 1'bX)
                $fdisplay(fd, "0");
            else
                $fdisplay(fd, "%0d", output_mem[i]);
        end
		  
        $fclose(fd);
        $display("DONE: Sobel output written to E:/sobel_verilog/sobel_output_4.pgm");
        $finish;
    end
	 
    initial begin
        #(CLK_PERIOD * IMG_W * IMG_H * 2);
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule
