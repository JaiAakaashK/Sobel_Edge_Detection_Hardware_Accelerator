module sobel_window_generator #(
    parameter PIX_W = 8,
    parameter IMG_W = 640
)(
    input wire clk,rst,pixel_valid,
    input wire [PIX_W-1:0] pixel_in,
    output reg [PIX_W-1:0] p1,p2,p3,
    output reg [PIX_W-1:0] p4,p5,p6,
    output reg [PIX_W-1:0] p7,p8,p9
);

    reg [PIX_W-1:0] line0 [0:IMG_W-1]; // Line buffer 1
    reg [PIX_W-1:0] line1 [0:IMG_W-1]; // Line buffer 2
    reg [PIX_W-1:0] line2 [0:IMG_W-1]; // Line buffer 3
    reg [$clog2(IMG_W)-1:0] col;
	 
    reg [PIX_W-1:0] r0_0,r0_1,r0_2;    // Shift registers for 3 rows
    reg [PIX_W-1:0] r1_0,r1_1,r1_2;
    reg [PIX_W-1:0] r2_0,r2_1,r2_2;
	 
    wire [PIX_W-1:0] v0 = line2[col];
    wire [PIX_W-1:0] v1 = line1[col];
    wire [PIX_W-1:0] v2 = line0[col];

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            col <= 0;
            for (i=0;i<IMG_W;i=i+1) begin
                line0[i]<=0;
                line1[i]<=0;
                line2[i]<=0;
            end
            r0_0<=0; r0_1<=0; r0_2<=0;
            r1_0<=0; r1_1<=0; r1_2<=0;
            r2_0<=0; r2_1<=0; r2_2<=0;
        end
        else if (pixel_valid) begin
		  
            line2[col]<=line1[col];             // Vertical shift
            line1[col]<=line0[col];
            line0[col]<=pixel_in;
				
            r0_0<=r0_1; r0_1<=r0_2; r0_2<=v0;   // Horizontal shift
            r1_0<=r1_1; r1_1<=r1_2; r1_2<=v1;
            r2_0<=r2_1; r2_1<=r2_2; r2_2<=v2;

            
            col<=(col == IMG_W-1) ? 0:col + 1;  // Column increment
        end
    end

    always @(*) begin
        p1=r0_0; p2=r0_1; p3=r0_2;              // Window mapping
        p4=r1_0; p5=r1_1; p6=r1_2;
        p7=r2_0; p8=r2_1; p9=r2_2;
    end

endmodule