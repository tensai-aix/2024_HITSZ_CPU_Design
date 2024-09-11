`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/10 14:51:43
// Design Name: 
// Module Name: SEXT
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

module SEXT(
    input wire[3:0] op,
    input wire[31:0] din,
    output reg[31:0] ext
    );
    
    wire sign=din[31];
    
always @(*) begin
    case (op)
        3'b000:  ext=32'b0;
        3'b001:  ext={{20{sign}},{din[31:20]}};
        3'b010:  ext={{27{1'b0}},{din[24:20]}};
        3'b011:  ext={{20{sign}},{din[31:25]},{din[11:7]}};
        3'b100:  ext={{19{sign}},{din[31]},{din[7]},{din[30:25]},{din[11:8]},{1'b0}};
        3'b101:  ext={{din[31:12]},{12{1'b0}}};
        3'b110:  ext={{11{sign}},{din[31]},{din[19:12]},{din[20]},{din[30:21]},{1'b0}};
        default: ext=32'b0;
        endcase
end
    
endmodule
