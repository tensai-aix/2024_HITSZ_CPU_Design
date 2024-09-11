`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 11:35:09
// Design Name: 
// Module Name: display
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


module display(
input wire clk,
input wire rst,
input wire[31:0]data,
input wire data_en,
output reg[7:0] led_en,
output reg[7:0] led
    );
    
reg[31:0] cnt;
reg[3:0] num;
reg[31:0] data_1;
parameter n0=8'b1_1000000,n1=8'b1_1111001,n2=8'b1_0100100,n3=8'b1_0110000,n4=8'b1_0011001,n5=8'b1_0010010,n6=8'b1_0000010,n7=8'b1_1111000,n8=8'b1_0000000,n9=8'b1_0011000,n10=8'b1_0001000,n11=8'b1_0000011,n12=8'b1_0100111,n13=8'b1_0100001,n14=8'b1_0000110,n15=8'b1_0001110;
    
always @ (posedge clk or posedge rst) begin//2ms“∆Œª
    if(rst)   cnt<=0;          
    else if(cnt==20_0000-1)cnt<=0;       
    else cnt<=cnt+1'd1;
end

    always @ (posedge clk or posedge rst) begin//“∆Œª
    if(rst)       led_en <= 8'b1111_1110;          
    else if(cnt==20_0000-1) led_en<={led_en[6:0], led_en[7]}; 
    else led_en<=led_en;
end

always @(posedge clk or posedge rst) begin
  if(rst) data_1<=0;
  else if(data_en) data_1<=data;
  else data_1<=data_1;
end

always @(led_en) begin
  case(led_en)
    8'b1111_1110:num=data_1[0]+data_1[1]*2+data_1[2]*4+data_1[3]*8;
    8'b1111_1101:num=data_1[4]+data_1[5]*2+data_1[6]*4+data_1[7]*8;
    8'b1111_1011:num=data_1[8]+data_1[9]*2+data_1[10]*4+data_1[11]*8;
    8'b1111_0111:num=data_1[12]+data_1[13]*2+data_1[14]*4+data_1[15]*8;
    8'b1110_1111:num=data_1[16]+data_1[17]*2+data_1[18]*4+data_1[19]*8;
    8'b1101_1111:num=data_1[20]+data_1[21]*2+data_1[22]*4+data_1[23]*8;
    8'b1011_1111:num=data_1[24]+data_1[25]*2+data_1[26]*4+data_1[27]*8;
    8'b0111_1111:num=data_1[28]+data_1[29]*2+data_1[30]*4+data_1[31]*8;
    default:num=4'd0;
  endcase
end
   
always @(*) begin
  case(num)
    4'd0:led=n0;
    4'd1:led=n1;
    4'd2:led=n2;
    4'd3:led=n3;
    4'd4:led=n4;
    4'd5:led=n5;
    4'd6:led=n6;
    4'd7:led=n7;
    4'd8:led=n8;
    4'd9:led=n9;
    4'd10:led=n10;
    4'd11:led=n11;
    4'd12:led=n12;
    4'd13:led=n13;
    4'd14:led=n14;
    4'd15:led=n15;
    default:led=n0;
  endcase
end
    
endmodule
