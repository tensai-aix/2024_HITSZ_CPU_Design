`timescale 1ns / 1ps

`include "defines.vh"

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
    //DRAM
    assign Bus_addr=alu_c;  //DRAM_addr will be alu_c[15:2],you can see it in the Soc part
    
    reg[3:0] tmp;
    reg[31:0] tmp2;
    always@(*) begin
        case(rdata_op)
            3'b001:begin //sb
                tmp2={4{rD2[7:0]}};
                case(Bus_addr[1:0])
                    2'b00:tmp=4'b0001;
                    2'b01:tmp=4'b0010;
                    2'b10:tmp=4'b0100;
                    2'b11:tmp=4'b1000;
                endcase
            end
            3'b010:begin //sh
                tmp2={2{rD2[15:0]}};
                case(Bus_addr[1])
                    1'b0:tmp=4'b0011;
                    1'b1:tmp=4'b1100;
                endcase
            end
            3'b011: begin //sw
                tmp2=rD2;
                tmp=4'b1111; 
            end
            default: tmp=4'b0000;
        endcase
    end
    assign Bus_we=tmp;
    assign Bus_wdata=tmp2;

    reg[31:0] Rd;
    always@(*) begin
        case(wdata_op)
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
  .pc(pc)
);

NPC U_NPC(
  .op(npc_op),
  .br(alu_f),
  .offset(ext),
  .rs_imm(alu_c),
  .pc(pc),
  .pc4(pc4),
  .npc(npc)
);

SEXT U_SEXT(
  .din(inst),
  .op(sext_op),
  .ext(ext)
);

RF U_RF(
  .clk(cpu_clk),
  .rR1(inst[19:15]),
  .rR2(inst[24:20]),
  .wR(inst[11:7]),
  .we(rf_we),
  .rf_wsel(rf_wsel),
  .pc4(pc4), //from npc
  .ext(ext), //from sext
  .alu_c(alu_c), //from alu
  .rd(rd),  //from dram
  .rD1(rD1),
  .rD2(rD2),
  .wD(wD) //only for debug
);

ALU U_ALU(
  .rD1(rD1),
  .rD2(rD2),
  .imm(ext),
  .alub_sel(alub_sel),
  .alua_sel(alua_sel),
  .alu_op(alu_op),
  .alu_c(alu_c),
  .alu_f(alu_f),
  .pc(pc)
);

Controller U_Controller(
  .inst(inst),
  .npc_op(npc_op),
  .rf_we(rf_we),
  .rf_wsel(rf_wsel),
  .sext_op(sext_op),
  .alub_sel(alub_sel),
  .alu_op(alu_op),
  .alua_sel(alua_sel),
  .wdata_op(wdata_op),
  .rdata_op(rdata_op)
);

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = /* TODO */1;
    assign debug_wb_pc        = /* TODO */(debug_wb_have_inst) ? pc:32'b0;
    assign debug_wb_ena       = /* TODO */(debug_wb_have_inst && rf_we) ? 1'b1:1'b0;
    assign debug_wb_reg       = /* TODO */(debug_wb_ena) ? inst[11:7]:5'b0;
    assign debug_wb_value     = /* TODO */(debug_wb_ena) ? wD:32'b0;
`endif

endmodule
