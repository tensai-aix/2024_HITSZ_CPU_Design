`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/09 16:32:02
// Design Name: 
// Module Name: NPC
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

module NPC(
    input wire[31:0] pc,
    input wire[31:0] offset,
    input wire[31:0] rs_imm,
    input wire br,
    input wire[1:0] op,
    output reg[31:0] npc,
    output wire[31:0] pc4
    );
    
assign pc4=pc+4;

always @(*) begin
        case (op)
            2'b00:   npc=pc+4;
            2'b01:   npc=rs_imm;//jalr
            2'b10:   if(br==1) npc=pc+offset-8;//branch
                     else npc=pc+4;
            2'b11:   npc=pc+offset-8;//jal
            default: npc = 32'b0;
        endcase
end
    
endmodule
