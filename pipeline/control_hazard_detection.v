`include "defines.vh"
module control_hazard_detection(
  input wire[1:0] EX_npc_op,
  input wire alu_f,
  output reg control_hazard
);

always @(*) begin
  if(EX_npc_op == 2'b01 || EX_npc_op == 2'b11) control_hazard = 1'b1;
  else if(EX_npc_op == 2'b10 && alu_f == 1) control_hazard = 1'b1;
  else control_hazard = 1'b0;
end

endmodule