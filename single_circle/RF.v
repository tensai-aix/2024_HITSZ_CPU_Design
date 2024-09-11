`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/09 18:58:29
// Design Name: 
// Module Name: RF
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "defines.vh"

module RF(
    input wire clk,
    input wire[4:0] rR1,
    input wire[4:0] rR2,
    input wire[4:0] wR,
    input wire we,
    input wire[31:0] pc4,
    input wire[31:0] ext,
    input wire[31:0] alu_c,
    input wire[31:0] rd,
    input wire[1:0] rf_wsel,
    output reg[31:0] wD,
    output wire[31:0] rD1,
    output wire[31:0] rD2
    );
    
    reg[31:0] rf[31:0];
    
    //¶Á
    assign rD1=(rR1==5'b0)? 32'b0:rf[rR1];
    assign rD2=(rR2==5'b0)? 32'b0:rf[rR2];
    
//Ñ¡ÔñwD    
always @(*) begin
    case(rf_wsel)
        2'b00: wD=alu_c;
        2'b01: wD=rd;
        2'b10: wD=pc4;
        2'b11: wD=ext;
        default: wD=pc4;
  endcase
end
   
//Ð´   
always @(posedge clk) begin
    if(we&&(wR != 5'b0)) rf[wR]<=wD;
end
    
endmodule
