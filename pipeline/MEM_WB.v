`include "defines.vh"
module MEM_WB(
  input wire clk,
  input wire rst,
  
  input wire MEM_rf_we,
  input wire[1:0] MEM_rf_wsel,
  input wire[4:0] MEM_wR,
  input wire[31:0] MEM_pc4,
  input wire[31:0] MEM_alu_c,
  input wire[31:0] MEM_rd,
  input wire[31:0] MEM_ext,

  output reg WB_rf_we,
  output reg[1:0] WB_rf_wsel,
  output reg[4:0] WB_wR,
  output reg[31:0] WB_pc4,
  output reg[31:0] WB_alu_c,
  output reg[31:0] WB_rd,
  output reg[31:0] WB_ext
);

always @(posedge clk or posedge rst) begin
  if(rst) WB_rf_we <= 0;
  else WB_rf_we <= MEM_rf_we;
end

always @(posedge clk or posedge rst) begin
  if(rst) WB_rf_wsel <= 0;
  else WB_rf_wsel <= MEM_rf_wsel;
end

always @(posedge clk or posedge rst) begin
  if(rst) WB_wR <= 0;
  else WB_wR <= MEM_wR;
end

always @(posedge clk or posedge rst) begin
  if(rst) WB_pc4 <= 0;
  else WB_pc4 <= MEM_pc4;
end

always @(posedge clk or posedge rst) begin
  if(rst) WB_alu_c <= 0;
  else WB_alu_c <= MEM_alu_c;
end

always @(posedge clk or posedge rst) begin
  if(rst) WB_rd <= 0;
  else WB_rd <= MEM_rd;
end

always @(posedge clk or posedge rst) begin
  if(rst) WB_ext <= 0;
  else WB_ext <= MEM_ext;
end

endmodule