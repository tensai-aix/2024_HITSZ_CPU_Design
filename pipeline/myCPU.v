`timescale 1ns / 1ps


module myCPU (
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // Interface to IROM
`ifdef RUN_TRACE
    output wire [15:0]  inst_addr,
`else
    output wire [13:0]  inst_addr,
`endif
    input  wire [31:0]  inst,
    
    // Interface to Bridge
    output wire [31:0]  Bus_addr,
    input  wire [31:0]  Bus_rdata,
    output wire [3:0]   Bus_we,
    output wire [31:0]  Bus_wdata

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst,
    output wire [31:0]  debug_wb_pc,
    output              debug_wb_ena,
    output wire [ 4:0]  debug_wb_reg,
    output wire [31:0]  debug_wb_value
`endif
);

    // TODO:       ?  ?     CPU   
    //pc   
    wire[31:0] pc;
    //npc   
    wire[31:0] npc;
    wire[31:0] pc4;
    //sext   
    wire[31:0] ext;
    //DRAM   
    wire[31:0] rd;
    //IROM
    assign inst_addr = pc[15:2];
    //RF   
    wire[31:0] rD1;
    wire[31:0] rD2;
    wire[31:0] wD;
    //alu   
    wire[31:0] alu_c;
    wire alu_f;
    //cntroller   
    wire[1:0] npc_op;
    wire rf_we;
    wire[1:0] rf_wsel;
    wire[2:0] sext_op;
    wire alub_sel;
    wire[3:0] alu_op;
    wire alua_sel;
    wire[2:0] wdata_op;
    wire[2:0] rdata_op;
    wire[1:0] rf_re;
    //IF_ID  ˮ ߼Ĵ       ź 
    wire [31:0] ID_inst;
    wire [31:0] ID_pc4;
    wire [31:0] ID_pc;
    //ID_EX  ˮ ߼Ĵ       ź 
    wire[1:0] EX_npc_op;
    wire[2:0] EX_ram_wdata_op;
    wire[2:0] EX_ram_rdata_op;
    wire[3:0] EX_alu_op;
    wire EX_alub_sel;
    wire EX_alua_sel;
    wire EX_rf_we;
    wire[1:0] EX_rf_wsel;
    wire[4:0] EX_wR;
    wire[31:0] EX_pc4;
    wire[31:0] EX_rD1;
    wire[31:0] EX_rD2;
    wire[31:0] EX_ext;
    wire[31:0] EX_pc;
    wire[1:0] EX_rf_re;
    //EX_MEM  ˮ ߼Ĵ       ź 
    wire[2:0] MEM_ram_wdata_op;
    wire[2:0] MEM_ram_rdata_op;
    wire MEM_rf_we;
    wire[1:0] MEM_rf_wsel;
    wire[4:0] MEM_wR;
    wire[31:0] MEM_pc4;
    wire[31:0] MEM_alu_c;
    wire[31:0] MEM_rD2;
    wire[31:0] MEM_ext;
    //MEM_WB  ˮ ߼Ĵ       ź 
    wire WB_rf_we;
    wire[1:0] WB_rf_wsel;
    wire[4:0] WB_wR;
    wire[31:0] WB_pc4;
    wire[31:0] WB_alu_c;
    wire[31:0] WB_rd;
    wire[31:0] WB_ext;
    //    ð տ   ģ      ź 
    wire[31:0] new_rD1;
    wire[31:0] new_rD2;
    wire data_hazard;
    //    ë ߿   ģ      ź 
    wire control_hazard;
     //DRAM ź 
    assign Bus_addr=MEM_alu_c;  //DRAM_addr will be alu_c[15:2],you can see it in the Soc part  
    reg[3:0] tmp;
    reg[31:0] tmp2;
    always@(*) begin
        case(MEM_ram_rdata_op)
            3'b001:begin //sb
                tmp2={4{MEM_rD2[7:0]}};
                case(Bus_addr[1:0])
                    2'b00:tmp=4'b0001;
                    2'b01:tmp=4'b0010;
                    2'b10:tmp=4'b0100;
                    2'b11:tmp=4'b1000;
                endcase
            end
            3'b010:begin //sh
                tmp2={2{MEM_rD2[15:0]}};
                case(Bus_addr[1])
                    1'b0:tmp=4'b0011;
                    1'b1:tmp=4'b1100;
                endcase
            end
            3'b011: begin //sw
                tmp2=MEM_rD2;
                tmp=4'b1111; 
            end
            default: begin    
                tmp2=MEM_rD2;
                tmp=4'b0000;
            end
        endcase
    end
    assign Bus_we=tmp;
    assign Bus_wdata=tmp2;

    reg[31:0] Rd;
    always@(*) begin
        case(MEM_ram_wdata_op)
            3'b001:  //lb
                case(Bus_addr[1:0]) 
                    2'b00:Rd={{24{Bus_rdata[7]}},{Bus_rdata[7:0]}};
                    2'b01:Rd={{24{Bus_rdata[15]}},{Bus_rdata[15:8]}};
                    2'b10:Rd={{24{Bus_rdata[23]}},{Bus_rdata[23:16]}};
                    2'b11:Rd={{24{Bus_rdata[31]}},{Bus_rdata[31:24]}};
                endcase
            3'b010: //lh
                case(Bus_addr[1])
                    1'b0:Rd={{16{Bus_rdata[15]}},{Bus_rdata[15:0]}};
                    1'b1:Rd={{16{Bus_rdata[31]}},{Bus_rdata[31:16]}};
                endcase
            3'b011: Rd=Bus_rdata; //lw
            3'b100: //lbu
                case(Bus_addr[1:0]) 
                    2'b00:Rd={{24{1'b0}},{Bus_rdata[7:0]}};
                    2'b01:Rd={{24{1'b0}},{Bus_rdata[15:8]}};
                    2'b10:Rd={{24{1'b0}},{Bus_rdata[23:16]}};
                    2'b11:Rd={{24{1'b0}},{Bus_rdata[31:24]}};
                endcase
            3'b101: //lhu
                case(Bus_addr[1])
                    1'b0:Rd={{16{1'b0}},{Bus_rdata[15:0]}};
                    1'b1:Rd={{16{1'b0}},{Bus_rdata[31:16]}};
                endcase
            default:Rd=Bus_rdata;
        endcase
    end
    assign rd = Rd;

PC U_PC(
  .rst(cpu_rst),
  .clk(cpu_clk),
  .din(npc),
  .data_hazard(data_hazard),
  .control_hazard(control_hazard),
  .pc(pc)
);

NPC U_NPC(
  .op(EX_npc_op),
  .br(alu_f),
  .offset(EX_ext),
  .rs_imm(alu_c),
  .pc(pc),
  .pc4(pc4),
  .npc(npc)
);

SEXT U_SEXT(
  .din(ID_inst),
  .op(sext_op),
  .ext(ext)
);

RF U_RF(
  .clk(cpu_clk),
  .rR1(ID_inst[19:15]),
  .rR2(ID_inst[24:20]),
  .wR(WB_wR),
  .we(WB_rf_we),
  .rf_wsel(WB_rf_wsel),
  .pc4(WB_pc4), //from npc
  .ext(WB_ext), //from sext
  .alu_c(WB_alu_c), //from alu
  .rd(WB_rd),  //from dram
  .rD1(rD1),
  .rD2(rD2),
  .wD(wD) //only for debug
);

ALU U_ALU(
  .rD1(EX_rD1),
  .rD2(EX_rD2),
  .imm(EX_ext),
  .alub_sel(EX_alub_sel),
  .alua_sel(EX_alua_sel),
  .alu_op(EX_alu_op),
  .alu_c(alu_c),
  .alu_f(alu_f),
  .pc(EX_pc)
);

Controller U_Controller(
  .inst(ID_inst),
  .npc_op(npc_op),
  .rf_we(rf_we),
  .rf_wsel(rf_wsel),
  .sext_op(sext_op),
  .alub_sel(alub_sel),
  .alu_op(alu_op),
  .alua_sel(alua_sel),
  .wdata_op(wdata_op),
  .rdata_op(rdata_op),
  .rf_re(rf_re)
);

IF_ID U_IF_ID(
  .clk(cpu_clk),
  .rst(cpu_rst),
  .IF_inst(inst),
  .IF_pc(pc),
  .IF_pc4(pc4),
  .data_hazard(data_hazard),
  .control_hazard(control_hazard), 
  .ID_inst(ID_inst),
  .ID_pc4(ID_pc4),
  .ID_pc(ID_pc)
);

ID_EX U_ID_EX(
  .clk(cpu_clk),
  .rst(cpu_rst),
  .ID_npc_op(npc_op),
  .ID_ram_wdata_op(wdata_op),
  .ID_ram_rdata_op(rdata_op),
  .ID_alu_op(alu_op),
  .ID_alub_sel(alub_sel),
  .ID_alua_sel(alua_sel),
  .ID_rf_we(rf_we),
  .ID_rf_wsel(rf_wsel),
  .ID_wR(ID_inst[11:7]),
  .ID_pc4(ID_pc4),
  .ID_pc(ID_pc),
  .ID_rD1(new_rD1),
  .ID_rD2(new_rD2),
  .ID_ext(ext),
  .ID_rf_re(rf_re),
  .EX_npc_op(EX_npc_op),
  .EX_ram_wdata_op(EX_ram_wdata_op),
  .EX_ram_rdata_op(EX_ram_rdata_op),
  .EX_alu_op(EX_alu_op),
  .EX_alub_sel(EX_alub_sel),
  .EX_alua_sel(EX_alua_sel),
  .EX_rf_we(EX_rf_we),
  .EX_rf_wsel(EX_rf_wsel),
  .EX_wR(EX_wR),
  .EX_pc4(EX_pc4),
  .EX_pc(EX_pc),
  .EX_rD1(EX_rD1),
  .EX_rD2(EX_rD2),
  .EX_ext(EX_ext),
  .EX_rf_re(EX_rf_re),
  .control_hazard(control_hazard),
  .data_hazard(data_hazard)
);

EX_MEM U_EX_MEM(
  .clk(cpu_clk),
  .rst(cpu_rst),
  .EX_ram_wdata_op(EX_ram_wdata_op),
  .EX_ram_rdata_op(EX_ram_rdata_op),
  .EX_rf_we(EX_rf_we),
  .EX_rf_wsel(EX_rf_wsel),
  .EX_wR(EX_wR),
  .EX_pc4(EX_pc4),
  .EX_alu_c(alu_c),
  .EX_rD2(EX_rD2),
  .EX_ext(EX_ext),
  .MEM_ram_wdata_op(MEM_ram_wdata_op),
  .MEM_ram_rdata_op(MEM_ram_rdata_op),
  .MEM_rf_we(MEM_rf_we),
  .MEM_rf_wsel(MEM_rf_wsel),
  .MEM_wR(MEM_wR),
  .MEM_pc4(MEM_pc4),
  .MEM_alu_c(MEM_alu_c),
  .MEM_rD2(MEM_rD2),
  .MEM_ext(MEM_ext)
);

MEM_WB U_MEM_WB(
  .clk(cpu_clk),
  .rst(cpu_rst), 
  .MEM_rf_we(MEM_rf_we),
  .MEM_rf_wsel(MEM_rf_wsel),
  .MEM_wR(MEM_wR),
  .MEM_pc4(MEM_pc4),
  .MEM_alu_c(MEM_alu_c),
  .MEM_rd(rd),
  .MEM_ext(MEM_ext),
  .WB_rf_we(WB_rf_we),
  .WB_rf_wsel(WB_rf_wsel),
  .WB_wR(WB_wR),
  .WB_pc4(WB_pc4),
  .WB_alu_c(WB_alu_c),
  .WB_rd(WB_rd),
  .WB_ext(WB_ext)
);

data_hazard_detection U_datahazard_detection(
  .ID_rR1(ID_inst[19:15]),
  .ID_rR2(ID_inst[24:20]),
  .ID_rf_re(rf_re), 
  .ID_rD1(rD1),
  .ID_rD2(rD2),
  .EX_wR(EX_wR),
  .EX_rf_we(EX_rf_we),
  .EX_rf_wsel(EX_rf_wsel),
  .EX_pc4(EX_pc4),
  .EX_ext(EX_ext),
  .EX_alu_c(alu_c),
  .MEM_wR(MEM_wR),
  .MEM_rf_we(MEM_rf_we),
  .MEM_rf_wsel(MEM_rf_wsel),
  .MEM_pc4(MEM_pc4),
  .MEM_ext(MEM_ext),
  .MEM_alu_c(MEM_alu_c),
  .MEM_rd(rd),
  .WB_wR(WB_wR),
  .WB_rf_we(WB_rf_we),
  .WB_rf_wsel(WB_rf_wsel),
  .WB_pc4(WB_pc4),
  .WB_ext(WB_ext),
  .WB_alu_c(WB_alu_c),
  .WB_rd(WB_rd),
  .new_rD1(new_rD1),
  .new_rD2(new_rD2),
  .data_hazard(data_hazard)
);

control_hazard_detection U_control_hazard_detection(
  .EX_npc_op(EX_npc_op),
  .alu_f(alu_f),
  .control_hazard(control_hazard)
);

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = (WB_pc4 == 32'b0) ? 0 : 1; //if pc4 == 0,it must be nop
    assign debug_wb_pc        = (debug_wb_have_inst) ? (WB_pc4 - 4) : 32'b0;
    assign debug_wb_ena       = (debug_wb_have_inst && WB_rf_we) ? 1'b1 : 1'b0;
    assign debug_wb_reg       = (debug_wb_ena) ? WB_wR : 5'b0;
    assign debug_wb_value     = (debug_wb_ena) ? wD : 32'b0;  //wD is only for debug
`endif

endmodule