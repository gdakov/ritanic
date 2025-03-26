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


module ifconv_mod(
  clk,
  rst,
  en,
  clkEn,
  A,
  toDBL,
  toEXT,
  toSNG,
  isS,
  res,
  rtyp,
  alt
  );

  localparam [15:0] BIAS=16'h7fff;

  input pwire clk;
  input pwire rst;
  input pwire en;
  input pwire clkEn;
  input pwire [64:0] A;
  input pwire toDBL,toEXT,toSNG;
  input pwire isS;
  output pwire [81:0] res;
  output pwire [1:0] rtyp;
  output pwire reg alt;
  pwire [15:0] valE2;
  pwire [71:-8] medBits;
  pwire [64:0] endBits;
  reg [64:0] A_reg;
  reg [71:-8] medBits_reg;
//  reg [64:0] A_reg2;
  pwire sgn;
  reg sgn_reg;
  reg sgn_reg2;
  pwire [64:0] A_last;
  pwire A_has;
  pwire [8:-7] A_bank;
  reg A_has_reg;
  reg toDBL_reg,toEXT_reg,toSNG_reg;
  reg toDBL_reg2,toEXT_reg2,toSNG_reg2;
  reg en_reg;
  reg en_reg2;
  reg en_reg3;
  pwire [3:0] medbin;
  pwire [7:0] medb;
  reg [7:0] medb_reg;
  reg [3:0] medbin_reg;

  pwire [64:0] A_d;

  bit_find_last_bit #(64) upper_mod(A_reg,A_last,A_has);
  bit_find_last_bit #(8) ubank_mod({|A_reg[63:56],
  |A_reg[55:48],|A_reg[47:40],|A_reg[39:32],|A_reg[31:24],
  |A_reg[23:16],|A_reg[15:8],|A_reg[7:0]},A_bank[0:-7],);

  adder_inc #(64) negate_mod(~A,A_d,isS && A[63],);
  assign sgn=isS && A[63];
  assign A_d=sgn ? 64'bz : A;
  assign A_bank[8:1]=8'b0;

  assign res[81:0]=(toSNG_reg2) ? {16'b0,33'b0,valE2[6],sgn_reg2,valE2[15],valE2[6:0],endBits[62:40]} : 82'bz;
  assign res[81:0]=(toDBL_reg2) ? {16'b0,valE2[9],sgn_reg2,valE2[15],valE2[8:0],endBits[62:43],1'b0,endBits[42:11]} : 82'bz;
  assign res[81:0]=(toEXT_reg2) ? {valE2[15],sgn_reg2,valE2[13:0],valE2[14],endBits[63:32],1'b0,endBits[31:0]} : 82'bz;

  assign rtyp=(toSNG_reg2) ? `ptype_sngl : 2'bz;
  assign rtyp=(toDBL_reg2) ? `ptype_dbl : 2'bz;
  assign rtyp=(toEXT_reg2) ? `ptype_ext : 2'bz;

  assign medBits[-8+:8]=((A_bank&16'b0000000_1_1111111)!=0) ?  8'b0 : 8'bz;
  assign medBits[0+:8]= ((A_bank&16'b0000000_0_1111111)!=0) ?  8'b0 : 8'bz;
  assign medBits[8+:8]= ((A_bank&16'b1000000_0_0111111)!=0) ?  8'b0 : 8'bz;
  assign medBits[16+:8]=((A_bank&16'b1100000_0_0011111)!=0) ?  8'b0 : 8'bz;
  assign medBits[24+:8]=((A_bank&16'b1110000_0_0001111)!=0) ?  8'b0 : 8'bz;
  assign medBits[32+:8]=((A_bank&16'b1111000_0_0000111)!=0) ?  8'b0 : 8'bz;
  assign medBits[40+:8]=((A_bank&16'b1111100_0_0000011)!=0) ?  8'b0 : 8'bz;
  assign medBits[48+:8]=((A_bank&16'b1111110_0_0000001)!=0) ?  8'b0 : 8'bz;
  assign medBits[56+:8]=((A_bank&16'b1111111_0_0000000)!=0) ?  8'b0 : 8'bz;
  assign medBits[64+:8]=((A_bank&16'b1111111_1_0000000)!=0) ?  8'b0 : 8'bz;
  assign medBits=A_has ? 80'bz : 80'b0;
  assign medb=A_has ? 8'bz : 8'b0;
  assign medbin=A_has ? 4'bz : 4'b0;
  assign valE2=A_has_reg ? 16'bz : 16'b0;
  assign endBits=A_has_reg ? 64'bz:64'b0;

  generate
    genvar t,p;
    for(t=0;t<8;t=t+1) begin
        for(p=0;p<8;p=p+1) begin
            assign medBits[t*8+:8]=A_bank[p-t] ?
              A_reg[p*8+:8] : 8'bz;
	end
        assign medBits[8*8+:8]=A_bank[t-8] ?
              A_reg[t*8+:8] : 8'bz;
        assign medBits[-8+:8]=A_bank[t+1] ?
              A_reg[t*8+:8] : 8'bz;
        assign medb=A_bank[t-7] ?
              A_last[t*8+:8] : 8'bz;
       // if (t<=4)
       //     assign medb=A_bank[t+8-7] ?
        //          A_last[(t+8)*8+:8] : 8'bz;
        assign medbin=A_bank[t-7] ?
              t[3:0] : 4'bz;
        //if (t<=4)
        //    assign medbin=A_bank[t+8-7] ?
        //          t[3:0]+4'd8 : 4'bz;
        assign endBits=medb_reg[t] ? medBits_reg[t-7+:64] : 64'bz;
        
        adder #(16)  add_mod({{9{medbin_reg[3]}},medbin_reg,t[2:0]},BIAS,
        valE2,1'b0,medb_reg[t],,,,);
          
    end
  endgenerate

  always @(posedge clk) begin
    if (clkEn) begin
        A_reg<=A_d;
        //A_reg2<=A_reg;
        medb_reg<=medb;
        medBits_reg<=medBits;
        A_has_reg<=A_has;
        medbin_reg<=medbin;
	sgn_reg<=sgn;
	sgn_reg2<=sgn_reg;
        toDBL_reg<=toDBL;
	toEXT_reg<=toEXT;
	toSNG_reg<=toSNG;
        toDBL_reg2<=toDBL_reg;
	toEXT_reg2<=toEXT_reg;
	toSNG_reg2<=toSNG_reg;
        //SH1_reg<=SH1;
	en_reg<=en;
	en_reg2<=en_reg;
        en_reg3<=en_reg2;
	alt<=en;
    end
  end
endmodule 

