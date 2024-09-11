`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 09:01:18
// Design Name: 
// Module Name: Controller
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

module Controller #(
  //    ָ     ͵ opcode
    localparam OP_R    = 7'b0110011,
    localparam OP_I    = 7'b0010011,
    localparam OP_LOAD = 7'b0000011,
    localparam OP_S    = 7'b0100011,
    localparam OP_B    = 7'b1100011,
    localparam OP_LUI  = 7'b0110111,
    localparam OP_AUIPC  = 7'b0010111,
    localparam OP_JAL  = 7'b1101111,
    localparam OP_JALR = 7'b1100111
)
(
    input wire[31:0] inst,
    output reg[2:0] sext_op,
    output reg[1:0] npc_op,
    output reg[3:0] alu_op,
    output reg alub_sel,
    output reg alua_sel,
    output reg rf_we,
    output reg[1:0] rf_wsel,
    output reg[2:0] wdata_op,
    output reg[2:0] rdata_op
    );
    
wire[6:0] opcode = inst[6:0];
wire[2:0] funct3 = inst[14:12];
wire[6:0] funct7 = inst[31:25];

always @(*) begin//sext_op
  case(opcode)
    OP_I:
      case(funct3)
        3'b001, 3'b101: sext_op=3'b010;
        default: sext_op=3'b001;
      endcase
    OP_LOAD, OP_JALR: sext_op=3'b001;
    OP_LUI,OP_AUIPC: sext_op=3'b101;
    OP_JAL: sext_op=3'b110;
    OP_B: sext_op=3'b100;
    OP_S: sext_op=3'b011;
    OP_R: sext_op=3'b000;
    default: sext_op=3'b000;
  endcase
end

always @(*) begin//npc_op
    case(opcode)
        OP_R, OP_I, OP_LOAD, OP_LUI, OP_S,OP_AUIPC: npc_op=2'b00;
        OP_JALR:                                    npc_op=2'b01;
        OP_B:                                       npc_op=2'b10;
        OP_JAL:                                     npc_op=2'b11;
        default:                                    npc_op=2'b00;
    endcase
end
  
always @ (*) begin//alu_op
    case (opcode)
        OP_R: begin
            case (funct3)
                3'b000 : alu_op=funct7[5] ? 4'b0001:4'b0000;
                3'b111 : alu_op=4'b0010;
                3'b110 : alu_op=4'b0011;
                3'b100 : alu_op=4'b0100;
                3'b001 : alu_op=4'b0101;
                3'b101 : alu_op=funct7[5] ? 4'b0111:4'b0110;
                3'b010 : alu_op=4'b1110;
                3'b011 : alu_op=4'b1111;
                default: alu_op=4'b0010;
            endcase
        end
        OP_I: begin
            case (funct3)
                3'b000 : alu_op=4'b0000;
                3'b111 : alu_op=4'b0010;
                3'b110 : alu_op=4'b0011;
                3'b100 : alu_op=4'b0100;
                3'b001 : alu_op=4'b0101;
                3'b101 : alu_op=funct7[5] ? 4'b0111:4'b0110;
                3'b010 : alu_op=4'b1110;
                3'b011 : alu_op=4'b1111;
                default: alu_op=4'b0010;
            endcase
        end
        OP_LOAD, OP_S, OP_JALR,OP_AUIPC:
            alu_op=4'b0000;
        OP_B:begin
            case(funct3)
              3'b000 : alu_op =4'b1000;
              3'b001 : alu_op =4'b1001;
              3'b100 : alu_op =4'b1010;
              3'b101 : alu_op =4'b1011;
              3'b111 : alu_op =4'b1100;
              3'b110 : alu_op =4'b1101;
              default: alu_op =4'b1000;
            endcase
        end
        default:
            alu_op=4'b0010;
    endcase
end
    
always @ (*) begin//alub_sel
    case (opcode)
        OP_I, OP_LOAD, OP_S, OP_JALR,OP_AUIPC:
            alub_sel = 1; //imm
        default:
            alub_sel = 0; //rs2
    endcase
end

always @ (*) begin//alua_sel
    case (opcode)
        OP_AUIPC:
            alua_sel = 1; //pc
        default:
            alua_sel = 0; //rs1
    endcase
end
    
always @(*) begin//rf_we
  if(opcode == OP_B || opcode == OP_S) rf_we = 0;
  else rf_we  = 1;
end
    
always @(*) begin//rf_wsel
  case(opcode)
    OP_R, OP_I,OP_AUIPC: rf_wsel=2'b00;
    OP_LOAD: rf_wsel=2'b01;
    OP_JALR, OP_JAL: rf_wsel=2'b10;
    OP_LUI: rf_wsel=2'b11;
    default: rf_wsel=2'b00;
  endcase
end

always @ (*) begin //wdata_op
    case (opcode)
        OP_LOAD:
            case(funct3)
              3'b000 : wdata_op =3'b001; //lb
              3'b001 : wdata_op =3'b010; //lh
              3'b010 : wdata_op =3'b011; //lw
              3'b100 : wdata_op =3'b100; //lbu
              3'b101 : wdata_op =3'b101; //lhu
            endcase
        default:
            wdata_op = 3'b011; //rs1
    endcase
end

always @ (*) begin //rdata_op
    case (opcode)
        OP_S:
            case(funct3)
              3'b000 : rdata_op =3'b001; //sb
              3'b001 : rdata_op =3'b010; //sh
              3'b010 : rdata_op =3'b011; //sw
            endcase
        default:
            rdata_op = 3'b000; //rs1
    endcase
end
    
endmodule
