`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 10:49:16
// Design Name: 
// Module Name: LEDs
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


module LEDs(
    input wire rst,
    input wire[31:0] data,
    input wire data_en,
    output reg[23:0] led
    );
    
    reg[31:0] data_1;
    
always @(*) begin
  if(rst) begin
    led=0;
    data_1=0;
  end
  else led=data_1[23:0];
  if(!rst&&data_en) data_1=data;
end
    
endmodule
