/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

`include "../struct.sv"

module cvt_FP_I_mod(
  clk,
  rst,
  en,
  clkEn,
  A,
  isDBL,isEXT,
  isSNG,
  is32b,
  verbatim,
  res,
  alt
);
  localparam [15:0] BIAS=16'h7fff;
  input clk;
  input rst;
  input en;
  input clkEn;
  input [81:0] A;
  input isDBL;
  input isEXT;
  input isSNG;
  input is32b;
  input verbatim;
  output [64:0] res;
  output alt;

  wire [15:0] shift;
  wire [64:0] bits;
  wire [64:0] bits2;
  wire [71:0] val_imm;
  reg [71:0] val_imm_reg;
  wire [64:0] val;
  reg [15:0] shift_reg;
  wire sign;
  reg sign_reg;
  reg is32b_reg;
  reg clkEn_reg;
  wire coUP,coNUP;
  reg coUP_reg,coNUP_reg;

  assign shift=isEXT ? {A[79],A[81],A[78:65]} : 16'bz;
  assign shift=isDBL ? {A[79],A[81],{4{~A[79]}},A[62:53]} : 16'bz;
  assign shift=isSNG ? {A[30],A[32],{7{~A[30]}},A[29:23]} : 16'bz;
  assign shift=verbatim ? BIAS+16'd63 : 16'bz;
  assign bits=isEXT ? {A[64:33],A[31:0]} : 64'bz;
  assign bits=isDBL ? {1'b1,A[52:33],A[31:0],11'b0} : 64'bz;
  assign bits=isSNG ? {1'b1,A[22:0],40'b0} : 64'bz;
  assign bits=verbatim ? {A[64:33],A[31:0]} : 64'bz;
  assign sign=isEXT ? A[80] : 1'bz;
  assign sign=isDBL ? A[64] : 1'bz;
  assign sign=isSNG ? A[31] : 1'bz;
  assign sign=verbatim ? 1'b0 : 1'bz;

  assign alt=~(clkEn & en);
  get_carry #(16) cmpShift_mod(shift,~(BIAS+16'd64),1'b1,coUP);
  get_carry #(16) cmpShift2_mod(BIAS-16'd63,~shift,1'b1,coNUP);

  adder_inc #(64) inv_mod(~bits,bits2,sign,);

  assign bits2=~sign ? bits : 64'bz;

  assign res[31:0]=coUP_reg ? 32'b0 : 32'bz;
  assign res=coNUP_reg ? {64{sign_reg}} : 64'bz;
  assign res[31:0]=(~coUP_reg&~coNUP_reg) ? val[31:0] : 32'bz;
  assign res[63:32]=coUP_reg|is32b_reg ? 32'b0 : 32'bz;
  assign res[63:32]=(~coUP_reg&~coNUP_reg&~is32b_reg) ? val[63:32] : 32'bz;

  generate
    genvar k;
    for(k=0;k<8;k=k+1) begin : shifter_gen
	    //verilator lint_off WIDTH
	assign val_imm=(shift[7:3]==k[4:0]) ? {{64{sign}},bits2}>>((7-k)*8) : 72'bz;
	assign val_imm=(shift[7:3]==(k[4:0]+5'd16)) ? {{8{sign}},bits2}<<(k*8+8) : 72'bz;
	assign val=(shift_reg[2:0]==k) ?
	       	{val_imm_reg,1'b0}>>(7-k) : 64'bz;
    end
        assign val=(shift_reg[7]) ? val_imm_reg>>7 : 64'bz;
	   //verilator lint_on WIDTH
  endgenerate

  `ifndef swapedge
  always @(posedge clk) begin
  `else
  always @(negedge clk) begin
  `endif
      clkEn_reg<=clkEn;
      if (clkEn_reg) begin
	  shift_reg<=shift;
	  sign_reg<=sign;
	  val_imm_reg<=val_imm;
	  coUP_reg<=coUP;
	  coNUP_reg<=coNUP;
	  is32b_reg<=is32b;
      end
  end
endmodule
 
