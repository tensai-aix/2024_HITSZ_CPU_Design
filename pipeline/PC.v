`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/09 16:32:02
// Design Name: 
// Module Name: PC
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

module PC(
    input wire rst,
    input wire clk,
    input wire[31:0] din,
    input wire data_hazard,
    input wire control_hazard,
    output reg[31:0] pc
    );
    
always @(posedge clk or posedge rst) begin
  if(rst) begin
    `ifdef RUN_TRACE
      pc<=-4;
    `else
      pc<=0;
    `endif
  end
  else if(control_hazard) pc<= din;
  else if(data_hazard) pc<=pc;
  else pc <= din;
end
    
endmodule
