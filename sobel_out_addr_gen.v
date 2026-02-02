module sobel_output_addr_generator #(
    parameter IMG_W = 5,
    parameter IMG_H = 5,
    parameter ADDR_W = 8
)(
    input wire clk,rst,sobel_valid,
    input wire [$clog2(IMG_H)-1:0] in_row,
    input wire [$clog2(IMG_W)-1:0] in_col,
    output reg out_valid,
    output reg [ADDR_W-1:0] out_addr
);

    always @(posedge clk) begin
        if (rst) begin
            out_valid<=0;
            out_addr<=0;
        end
        else if (sobel_valid && in_row>=2 && in_col>=2) begin
            out_valid<=1'b1;
            out_addr<=(in_row-1)*IMG_W + (in_col-1);   // Output Address calculation
        end
        else begin
            out_valid<=1'b0;
        end
    end
endmodule
