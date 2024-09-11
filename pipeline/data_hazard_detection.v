`include "defines.vh"
module data_hazard_detection(
  input wire[4:0] ID_rR1,
  input wire[4:0] ID_rR2,
  input wire[1:0] ID_rf_re, 
  input wire[31:0] ID_rD1,
  input wire[31:0] ID_rD2,

  input wire[4:0] EX_wR,
  input wire EX_rf_we,
  input wire[1:0] EX_rf_wsel,
  input wire[31:0] EX_pc4,
  input wire[31:0] EX_ext,
  input wire[31:0] EX_alu_c,

  input wire[4:0] MEM_wR,
  input wire MEM_rf_we,
  input wire[1:0] MEM_rf_wsel,
  input wire[31:0] MEM_pc4,
  input wire[31:0] MEM_ext,
  input wire[31:0] MEM_alu_c,
  input wire[31:0] MEM_rd,

  input wire[4:0] WB_wR,
  input wire WB_rf_we,
  input wire[1:0] WB_rf_wsel,
  input wire[31:0] WB_pc4,
  input wire[31:0] WB_ext,
  input wire[31:0] WB_alu_c,
  input wire[31:0] WB_rd,

  output reg[31:0] new_rD1,
  output reg[31:0] new_rD2,
  output wire data_hazard   //if only we counter with load-use, it will be 1,stop pipeline
);


//three data hazards
//A,ID and EX
wire rR1_a = (ID_rR1 == EX_wR) & EX_rf_we &  ID_rf_re[0] & (ID_rR1 != 5'b0);
wire rR2_a = (ID_rR2 == EX_wR) & EX_rf_we &  ID_rf_re[1] & (ID_rR2 != 5'b0);
//B,ID and MEM
wire rR1_b = (ID_rR1 == MEM_wR) & MEM_rf_we &  ID_rf_re[0] & (ID_rR1 != 5'b0);
wire rR2_b = (ID_rR2 == MEM_wR) & MEM_rf_we &  ID_rf_re[1] & (ID_rR2 != 5'b0);
//C,ID and WB
wire rR1_c = (ID_rR1 == WB_wR) & WB_rf_we &  ID_rf_re[0] & (ID_rR1 != 5'b0);
wire rR2_c = (ID_rR2 == WB_wR) & WB_rf_we &  ID_rf_re[1] & (ID_rR2 != 5'b0);

assign data_hazard = (rR1_a && EX_rf_wsel == 2'b01) || (rR2_a && EX_rf_wsel == 2'b01);

always @(*) begin
  if(rR1_a) begin
    case(EX_rf_wsel)
      2'b10: new_rD1=EX_pc4;
      2'b11: new_rD1=EX_ext;
      2'b00: new_rD1=EX_alu_c;
      default: new_rD1=EX_alu_c;
    endcase
  end
  else if(rR1_b) begin
    case(MEM_rf_wsel)
    2'b10: new_rD1=MEM_pc4;
    2'b11: new_rD1=MEM_ext;
    2'b00: new_rD1=MEM_alu_c;
    2'b01: new_rD1=MEM_rd;
    default: new_rD1=MEM_alu_c;
    endcase
  end
  else if(rR1_c) begin
    case(WB_rf_wsel)
    2'b10: new_rD1=WB_pc4;
    2'b11: new_rD1=WB_ext;
    2'b00: new_rD1=WB_alu_c;
    2'b01: new_rD1=WB_rd;
    default: new_rD1=WB_alu_c;
    endcase
  end
  else new_rD1=ID_rD1;
end

always @(*) begin
  if(rR2_a) begin
    case(EX_rf_wsel)
      2'b10: new_rD2=EX_pc4;
      2'b11: new_rD2=EX_ext;
      2'b00: new_rD2=EX_alu_c;
      default: new_rD2=EX_alu_c;
    endcase
  end
  else if(rR2_b) begin
    case(MEM_rf_wsel)
    2'b10: new_rD2=MEM_pc4;
    2'b11: new_rD2=MEM_ext;
    2'b00: new_rD2=MEM_alu_c;
    2'b01: new_rD2=MEM_rd;
    default: new_rD2=MEM_alu_c;
    endcase
  end
  else if(rR2_c) begin
    case(WB_rf_wsel)
    2'b10: new_rD2=WB_pc4;
    2'b11: new_rD2=WB_ext;
    2'b00: new_rD2=WB_alu_c;
    2'b01: new_rD2=WB_rd;
    default: new_rD2=WB_alu_c;
    endcase
  end
  else new_rD2=ID_rD2;
end

endmodule