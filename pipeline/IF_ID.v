`include "defines.vh"
module IF_ID(
  input wire clk,
  input wire rst,
  input wire[31:0] IF_inst,
  input wire[31:0] IF_pc4,
  input wire data_hazard,
  input wire control_hazard,  
  input wire[31:0] IF_pc,
  output reg[31:0] ID_inst,
  output reg[31:0] ID_pc4,
  output reg[31:0] ID_pc
);


always @(posedge clk or posedge rst) begin
  if(rst) ID_inst<=0;
  else if(control_hazard) ID_inst<=0;
  else if(data_hazard) ID_inst<=ID_inst;
  else ID_inst<=IF_inst;
end

always @(posedge clk or posedge rst) begin
  if(rst) ID_pc4<=0;
  else if(control_hazard) ID_pc4<=0;
  else if(data_hazard) ID_pc4<=ID_pc4;
  else ID_pc4<=IF_pc4;
end

always @(posedge clk or posedge rst) begin
  if(rst) ID_pc<=0;
  else if(control_hazard) ID_pc<=0;
  else if(data_hazard) ID_pc<=ID_pc;
  else ID_pc<=IF_pc;
end

endmodule