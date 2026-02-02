`timescale 1ns/1ps
`default_nettype none
module sobel_edge #(
    parameter PIX_W   = 8,
    parameter IMG_W   = 640,
    parameter IMG_H   = 480,
    parameter ADDR_W  = 32
)(
    input wire clk,rst,start,
    output wire [ADDR_W-1:0] in_addr,   // Input image interface
    input wire [PIX_W-1:0]  in_pixel,
    output wire out_valid,              // Output image interface
    output wire [ADDR_W-1:0] out_addr,
    output wire [PIX_W-1:0]  out_pixel
);

    wire in_valid;                      // Internal signals for address generator window generator and sobel calculation
    wire [$clog2(IMG_H)-1:0] in_row;
    wire [$clog2(IMG_W)-1:0] in_col;
    wire [PIX_W-1:0] p1,p2,p3,p4,p5,p6,p7,p8,p9;
    wire sobel_valid_raw;

    sobel_input_addr_generator #(       // Input address generator
        .IMG_W (IMG_W),
        .IMG_H (IMG_H),
        .ADDR_W(ADDR_W)
    ) u_in (
        .clk(clk),
        .rst(rst),
        .enable(start),
        .pixel_valid(in_valid),
        .pixel_addr(in_addr),
        .row(in_row),
        .col(in_col));

    reg [$clog2(IMG_H)-1:0] row_d1,row_d2,row_d3,row_d4;     // Row / Column pipeline (4 cycles)
    reg [$clog2(IMG_W)-1:0] col_d1,col_d2,col_d3,col_d4;

    always @(posedge clk) begin
        if (rst) begin
            row_d1<=0; row_d2<=0; row_d3<=0; row_d4<=0;
            col_d1<=0; col_d2<=0; col_d3<=0; col_d4<=0;
        end else begin
            row_d1<=in_row;
            row_d2<=row_d1;
            row_d3<=row_d2;
            row_d4<=row_d3;
            col_d1<=in_col;
            col_d2<=col_d1;
            col_d3<=col_d2;
            col_d4<=col_d3;
        end
    end

    sobel_window_generator #(   // Sobel window generator
        .PIX_W (PIX_W),
        .IMG_W (IMG_W)
    ) u_win (
        .clk(clk),
        .rst(rst),
        .pixel_valid(in_valid),
        .pixel_in(in_pixel),
        .p1(p1),.p2(p2),.p3(p3),
        .p4(p4),.p5(p5),.p6(p6),
        .p7(p7),.p8(p8),.p9(p9));

    wire win_valid;             // Window validation
    assign win_valid =(row_d4 >= 2) && (col_d4 >= 2) && (row_d4 < IMG_H-1) && (col_d4 < IMG_W-1);

    sobel_calculation #(        // Sobel compute
        .PIX_W(PIX_W)
    ) u_sobel (
        .clk(clk),
        .rst(rst),
        .win_valid(win_valid),
        .p1(p1),.p2(p2),.p3(p3),
        .p4(p4),.p5(p5),.p6(p6),
        .p7(p7),.p8(p8),.p9(p9),
        .sobel_valid(sobel_valid_raw),
        .edge_pixel (out_pixel),
        .grad_mag());

    reg v1,v2,v3,v4;             // Align valid with address
    always @(posedge clk) begin
        if (rst) begin
            v1<=0; v2<=0; v3<=0; v4<=0;
        end else begin
            v1<=sobel_valid_raw;
            v2<=v1;
            v3<=v2;
            v4<=v3;
        end
    end
   
    sobel_output_addr_generator #( // Output address generator
        .IMG_W (IMG_W),
        .IMG_H (IMG_H),
        .ADDR_W(ADDR_W)
    ) u_out (
        .clk(clk),
        .rst(rst),
        .sobel_valid(v4),
        .in_row(row_d4),
        .in_col(col_d4),
        .out_valid(out_valid),
        .out_addr(out_addr));

endmodule

`default_nettype wire







