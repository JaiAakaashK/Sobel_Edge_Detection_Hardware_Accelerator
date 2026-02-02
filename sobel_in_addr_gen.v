module sobel_input_addr_generator #(
    parameter IMG_W = 5,
    parameter IMG_H = 5,
    parameter ADDR_W = 8
)(
    input wire clk,rst,enable,
    output reg pixel_valid,
    output reg [ADDR_W-1:0] pixel_addr,
    output reg [$clog2(IMG_H)-1:0] row,
    output reg [$clog2(IMG_W)-1:0] col
);
    reg done;
	 
    always @(posedge clk) begin
        if (rst) begin
            row<= 0; 
				col<= 0;
            pixel_addr<= 0;
            pixel_valid<= 0;
            done<= 0;
        end
        else if (enable && !done) begin
            pixel_valid<= 1'b1;
            pixel_addr<= row * IMG_W + col;  // Input Address calculation

            if (col==IMG_W-1) begin
                col<= 0;
                if (row == IMG_H-1)
                    done<= 1'b1;     
                else
                    row<= row + 1;   // Row increment
            end else begin
                col<= col + 1;       // Column increment
            end
        end
        else begin
            pixel_valid<= 1'b0;
        end
    end
endmodule