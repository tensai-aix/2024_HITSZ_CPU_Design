`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 08:41:44
// Design Name: 
// Module Name: ALU
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

module ALU(
     input wire[31:0] rD1,
     input wire[31:0] rD2,
     input wire[31:0] imm,
     input wire alub_sel,
     input wire alua_sel,
     input wire[3:0] alu_op,
     input wire[31:0] pc,
     output wire[31:0] alu_c,
     output wire alu_f
    );
    
reg[31:0] result;
reg f;

assign alu_c=result;
assign alu_f=f;
wire[31:0] dataA=alua_sel ? pc:rD1;
wire[31:0] dataB=alub_sel ? imm:rD2;
wire[31:0] sub_num=dataA-dataB;
wire cmp = (dataA[31] == dataB[31]) ? sub_num[31] : alu_op[2] ? dataB[31] : dataA[31];
wire cnp = (dataA[31] == dataB[31]) ? sub_num[31] : alu_op[0] ? dataB[31] : dataA[31];

always @(*) begin
    case(alu_op)
        4'b0000 : result=dataA + dataB;
        4'b0001 : result=dataA - dataB;
        4'b0010 : result=dataA & dataB;
        4'b0011 : result=dataA | dataB;
        4'b0100 : result=dataA ^ dataB;
        4'b0101 : result=dataA << dataB[4:0];
        4'b0110 : result=dataA >> dataB[4:0];
        4'b0111 : result=($signed(dataA)) >>> dataB[4:0];
        4'b1000 : f=(dataA==dataB) ? 1:0;
        4'b1001 : f=(dataA!=dataB) ? 1:0;
        4'b1010 : f=(sub_num[31]==1) ? 1:0;
        4'b1011 : f=(sub_num[31]==0) ? 1:0;
        4'b1100 : f=~cmp;
        4'b1101 : f=cmp;
        4'b1110 : result=cnp;
        4'b1111 : result=cnp;
        default : result=0;
    endcase
end
    
endmodule