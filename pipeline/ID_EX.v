module ID_EX(
  input wire clk,
  input wire rst,

  input wire[1:0] ID_npc_op,
  input wire[2:0] ID_ram_wdata_op,
  input wire[2:0] ID_ram_rdata_op,
  input wire[3:0] ID_alu_op,
  input wire ID_alub_sel,
  input wire ID_alua_sel,
  input wire ID_rf_we,
  input wire[1:0] ID_rf_wsel,
  input wire[4:0] ID_wR,
  input wire[31:0] ID_pc4,
  input wire[31:0] ID_pc,
  input wire[31:0] ID_rD1,
  input wire[31:0] ID_rD2,
  input wire[31:0] ID_ext,
  input wire[1:0] ID_rf_re,

  output reg[1:0] EX_npc_op,
  output reg[2:0] EX_ram_wdata_op,
  output reg[2:0] EX_ram_rdata_op,
  output reg[3:0] EX_alu_op,
  output reg EX_alub_sel,
  output reg EX_alua_sel,
  output reg EX_rf_we,
  output reg[1:0] EX_rf_wsel,
  output reg[4:0] EX_wR,
  output reg[31:0] EX_pc4,
  output reg[31:0] EX_pc,
  output reg[31:0] EX_rD1,
  output reg[31:0] EX_rD2,
  output reg[31:0] EX_ext,
  output reg[1:0] EX_rf_re,

  input wire control_hazard,//two hazard have the same flush
  input wire data_hazard
);

always @(posedge clk or posedge rst) begin
  if(rst) EX_npc_op<=0;
  else if(control_hazard | data_hazard) EX_npc_op<=0;
  else EX_npc_op <= ID_npc_op;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_ram_wdata_op<=0;
  else if(control_hazard | data_hazard) EX_ram_wdata_op<=0;
  else EX_ram_wdata_op <= ID_ram_wdata_op;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_ram_rdata_op<=0;
  else if(control_hazard | data_hazard) EX_ram_rdata_op<=0;
  else EX_ram_rdata_op <= ID_ram_rdata_op;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_alu_op<=0;
  else if(control_hazard | data_hazard) EX_alu_op<=0;
  else EX_alu_op <= ID_alu_op;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_alub_sel<=0;
  else if(control_hazard | data_hazard) EX_alub_sel<=0;
  else EX_alub_sel <= ID_alub_sel;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_alua_sel<=0;
  else if(control_hazard | data_hazard) EX_alua_sel<=0;
  else EX_alua_sel <= ID_alua_sel;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_rf_we<=0;
  else if(control_hazard | data_hazard) EX_rf_we<=0;
  else EX_rf_we <= ID_rf_we;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_rf_re<=0;
  else if(control_hazard | data_hazard) EX_rf_re<=0;
  else EX_rf_re <= ID_rf_re;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_rf_wsel<=0;
  else if(control_hazard | data_hazard) EX_rf_wsel<=0;
  else EX_rf_wsel <= ID_rf_wsel;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_wR<=0;
  else if(control_hazard | data_hazard) EX_wR<=0;
  else EX_wR <= ID_wR;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_pc4<=0;
  else if(control_hazard | data_hazard) EX_pc4<=0;
  else EX_pc4 <= ID_pc4;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_pc<=0;
  else if(control_hazard | data_hazard) EX_pc<=0;
  else EX_pc <= ID_pc;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_rD1<=0;
  else if(control_hazard | data_hazard) EX_rD1<=0;
  else EX_rD1 <= ID_rD1;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_rD2<=0;
  else if(control_hazard | data_hazard) EX_rD2<=0;
  else EX_rD2 <= ID_rD2;
end

always @(posedge clk or posedge rst) begin
  if(rst) EX_ext<=0;
  else if(control_hazard | data_hazard) EX_ext<=0;
  else EX_ext <= ID_ext;
end

endmodule