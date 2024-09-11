module EX_MEM(
  input wire clk,
  input wire rst,
  
  input wire[2:0] EX_ram_wdata_op,
  input wire[2:0] EX_ram_rdata_op,
  input wire[3:0] EX_rf_we,
  input wire[1:0] EX_rf_wsel,
  input wire[4:0] EX_wR,
  input wire[31:0] EX_pc4,
  input wire[31:0] EX_alu_c,
  input wire[31:0] EX_rD2,
  input wire[31:0] EX_ext,

  output reg[2:0] MEM_ram_wdata_op,
  output reg[2:0] MEM_ram_rdata_op,
  output reg MEM_rf_we,
  output reg[1:0] MEM_rf_wsel,
  output reg[4:0] MEM_wR,
  output reg[31:0] MEM_pc4,
  output reg[31:0] MEM_alu_c,
  output reg[31:0] MEM_rD2,
  output reg[31:0] MEM_ext
);

always @(posedge clk or posedge rst) begin
  if(rst) MEM_ram_wdata_op <= 0;
  else MEM_ram_wdata_op <= EX_ram_wdata_op;
end

always @(posedge clk or posedge rst) begin
  if(rst) MEM_ram_rdata_op <= 0;
  else MEM_ram_rdata_op <= EX_ram_rdata_op;
end

always @(posedge clk or posedge rst) begin
  if(rst) MEM_rf_we <= 0;
  else MEM_rf_we <= EX_rf_we;
end

always @(posedge clk or posedge rst) begin
  if(rst) MEM_rf_wsel <= 0;
  else MEM_rf_wsel <= EX_rf_wsel;
end

always @(posedge clk or posedge rst) begin
  if(rst) MEM_wR <= 0;
  else MEM_wR <= EX_wR;
end

always @(posedge clk or posedge rst) begin
  if(rst) MEM_pc4 <= 0;
  else MEM_pc4 <= EX_pc4;
end

always @(posedge clk or posedge rst) begin
  if(rst) MEM_alu_c <= 0;
  else MEM_alu_c <= EX_alu_c;
end

always @(posedge clk or posedge rst) begin
  if(rst) MEM_rD2 <= 0;
  else MEM_rD2 <= EX_rD2;
end

always @(posedge clk or posedge rst) begin
  if(rst) MEM_ext <= 0;
  else MEM_ext <= EX_ext;
end

endmodule