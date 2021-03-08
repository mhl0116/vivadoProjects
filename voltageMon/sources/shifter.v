module shift_reg (clock, reset, load, sel, data, shiftreg);
input clock;
input reset;
input load;
input [1:0] sel;
input [4:0] data;
output [4:0] shiftreg;
reg [4:0] shiftreg;

always @ (posedge clock)
begin
  if (reset)
      shiftreg = 0;
  else if (load)
      shiftreg = data;
  else 
    case (sel)
      2'b00 : shiftreg = shiftreg;
      2'b01 : shiftreg = shiftreg << 1;
      2'b10 : shiftreg = shiftreg >> 1;
      default : shiftreg = shiftreg;
    endcase
end

endmodule