module sobel_calculation #(
    parameter PIX_W = 8
)(
    input wire clk,rst,win_valid,
    input wire [PIX_W-1:0] p1,p2,p3,
    input wire [PIX_W-1:0] p4,p5,p6,
    input wire [PIX_W-1:0] p7,p8,p9,
    output reg sobel_valid,
    output reg [PIX_W-1:0] edge_pixel,
    output reg [PIX_W+3:0] grad_mag
);

    reg signed [PIX_W:0] sp1,sp2,sp3,sp4,sp6,sp7,sp8,sp9;
    reg signed [PIX_W+2:0] gx, gy;
    reg [PIX_W+2:0] abs_gx, abs_gy;
    reg [PIX_W+3:0] mag;

    always @(*) begin
        sp1={1'b0,p1}; sp2={1'b0,p2}; sp3={1'b0,p3};           // Converting unsigned pixel to signed pixel
        sp4={1'b0,p4}; sp6={1'b0,p6};
        sp7={1'b0,p7}; sp8={1'b0,p8}; sp9={1'b0,p9};

        gx = (sp3 + (sp6<<1) + sp9) - (sp1 + (sp4<<1) + sp7);  // Horizontal component
        gy = (sp1 + (sp2<<1) + sp3) - (sp7 + (sp8<<1) + sp9);  // Vertical component

        abs_gx = gx[PIX_W+2] ? -gx : gx;                       // Absolute value of Gx
        abs_gy = gy[PIX_W+2] ? -gy : gy;                       // Absolute value of Gy

        mag = abs_gx + abs_gy;                                 // Magnitude of sobel component
    end

    always @(posedge clk) begin
        if (rst) begin
            sobel_valid<=1'b0;
            edge_pixel<=8'd0;
            grad_mag<=0;
        end 
		  else begin
            sobel_valid<=win_valid;
            if (win_valid) begin
                grad_mag<=mag;
                
                if (mag >= 12'd255)        
                    edge_pixel<=8'hFF;
                else
                    edge_pixel<=mag[7:0];
            end
        end
    end

endmodule
