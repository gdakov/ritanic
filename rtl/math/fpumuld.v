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
`include "../fpoperations.sv"

module fpucadd(clk,rst,A,A_alt,B,pook_in,and1,or1,copyA,en,rmode,res,res_hi,xtra,isDBL,fpcsr,raise,is_rndD,is_rndS);
  localparam [15:0] BIAS=16'h7fff;
  localparam ROUND_TRUNC=0;
  localparam ROUND_ROUND=1;
  localparam ROUND_EVEN =2;
  localparam ROUND_PLUS =3;
  localparam ROUND_MINUS=4;
  localparam ROUND_UP   =5;
  localparam ROUND_DOWN =6;
  parameter [0:0] H=0;//"high" nibble

  input pwire clk;
  input pwire rst;
  input pwire [80:0] A;
  input pwire [64:0] A_alt;
  input pwire [80:0] B;
  input pwire pook_in;
  input pwire and1;
  input pwire or1;
  input pwire copyA;
  input pwire en;
  input pwire [2:0] rmode;
  output pwire [67:0] res;
  output pwire [15:0] res_hi;
  inout [67:0] xtra;
  input pwire isDBL;
  input pwire [31:0] fpcsr;
  output pwire [10:0] raise;
  input pwire is_rndD;
  input pwire is_rndS; 
  
  //reg [80:0] A_reg;
 // reg [80:0] B_reg;
  pwire [127:0] part0;
  pwire [127:0] part1;

  pwire [15:0] expA;
  pwire [15:0] expB;
  pwire [16:0] exp_exp;
  pwire [16:0] exp_exp1;
  pwire [16:0] expart0;
  pwire [16:0] expart1;
  reg isDBL_reg;
  reg isDBL_reg3;
  reg en_reg,en_reg2;
  pwire sgn;
  reg sgn_reg,sgn_reg2;
  reg [16:0] exp_max;
  reg [16:0] exp_max_IEEE;
  reg [16:0] exp_denor;
  reg [16:0] exp_denor_IEEE;
  reg [16:0] exp_exp_reg;
  reg [16:0] exp_exp1_reg;
  pwire [16:0] exp_exp_d;
  pwire [16:0] exp_exp1_d;
  reg [16:0] exp_exp_reg2;
  reg [16:0] exp_exp1_reg2;
  pwire exp_oor,exp1_oor,exp_oor_IEEE,exp1_oor_IEEE;
  pwire exp_non_denor_IEEE,exp1_non_denor_IEEE;
  reg exp_oor_reg,exp1_oor_reg,exp_oor_IEEE_reg,exp1_oor_IEEE_reg;
  reg exp_non_denor_IEEE_reg,exp1_non_denor_IEEE_reg;

  reg [127:0] prod_reg;
  pwire DBL_rnbit0,DBL_tail0,DBL_rnflip0;
  pwire DBL_rnbitX,DBL_tailX,DBL_rnflipX;
  pwire DBL_rnbit1,DBL_tail1;
  pwire EXT_rnbit0,EXT_tail0,EXT_rnflip0;
  pwire EXT_rnbitX,EXT_tailX,EXT_rnflipX;
  pwire EXT_rnbitY,EXT_tailY,EXT_rnflipY;
  pwire EXT_rnbit1,EXT_tail1;
  pwire DBL_rnd0,DBL_rnd1,DBL_rndX;
  pwire EXT_rnd0,EXT_rnd1,EXT_rndX,EXT_rndY;
  reg [62:-1] rndbit_ext;
  reg [51:-1] rndbit_dbl;
  //wire [62:-1] rndbit_ext={62'b0,prod_reg[127],~prod_reg[127]};
  //wire [51:-1] rndbit_dbl={51'b0,prod_reg[105],~prod_reg[105]};
  reg [62:-1] enbit_ext;
  reg [51:-1] enbit_dbl;
  reg [31:0] fpcsr_reg;
  reg [80:0] A_reg;
  reg [80:0] A_reg2;
  pwire [4:0] expon;
 // reg [1:0] expon_reg;

  pwire A_h; 
  pwire B_h; 

  pwire A_zero,A_infty,A_nan;
  
  pwire B_zero,B_infty,B_nan;

  pwire [52:0] mskS;

  pwire spec_zero,spec_infty,spec_nan,spec_snan,spec_qnan,spec_A;
  reg spec_zero_reg,spec_infty_reg,spec_snan_reg,spec_qnan_reg,spec_A_reg;
  reg spec_zero_reg2,spec_infty_reg2,spec_snan_reg2,spec_qnan_reg2,spec_A_reg2;
  reg spec_any;
  pwire [80:0] res_spec;
  reg isrnd_zero,isrnd_plus,isrnd_even;
  pwire [127:0] prod;
  reg is_rndD_reg;
  reg is_rndS_reg; 
  reg is_rounder,is_rounderD,is_rounderS; 
  pwire dummy1_1;
  pwire dummy1_2;
  pwire dummy1_3;
  pwire dummy1_4;
  pwire [15:0] emsk=isDBL ? 16'h87ff : 16'hffff;
//  reg or1,and1;

  fpucadd_compress compr_mod(clk,A[63:0],B[63:0],part0,part1,or1,and1);
  adder #(128) prodAdd_mod(part0,part1,prod,1'b0,1'b1,,,,);

  adder2oi #(53) resAddD_mod(enbit_dbl,prod_reg[104:52]&mskS[51:0],rndbit_dbl&mskS[-1],{res[52:33],res[31:0],dummy1_3},{dummy1_4,res[52:33],res[31:0]},1'b0,
      prod_reg[105] & DBL_rnd1 & isDBL_reg & ~spec_any & en_reg ||
      ~prod_reg[105] & DBL_rnd0 & DBL_rnflip0 & isDBL_reg & ~spec_any & en_reg,
      ~prod_reg[105] & DBL_rnd0 & ~DBL_rnflip0 & isDBL_reg & ~spec_any & en_reg,,,,);

  generate
    if (!H) begin : LOW_PREC2
        fpuadd_renor renorR_mod(
        .A({prod_reg[52:0],11'b0}),
        .exp(exp_exp1_adj_reg),.Ax(1'b0),
        .A_out(xtra_mantissa),.exp_out(xtra_exp)
        );

        assign xtra[53:0]={xtra_mantissa[62:42],1'b0,xtra_mantissa[41:10]};
        assign xtra[65:54]={xtra_exp[15],sgn_reg,xtra_exp[10:0]};
        assign xtra[67:66]=`ptype_dbl;
    end
  endgenerate
  
  adder_CSA #(16) extAdd_mod(expA,expB,-BIAS,expart0,expart1);
  adder2c #(17) expAdd2_mod(expart0,expart1,exp_exp,exp_exp1,1'b0,1'b1,1'b1,1'b1,,,,);

  adder_CSA #(16) extAdd_mod(expA,expB,-BIAS-53,expartX0,expartX1);
  adder2c #(17) expAdd2_mod(expartX0,expartX1,exp_exp_adj,exp_exp1_adj,1'b0,1'b1,1'b1,1'b1,,,,);

  get_carry #(17) cmp0_mod(exp_max,~(exp_exp^17'h10000),1'b1,exp_oor);
  get_carry #(17) cmp1_mod(exp_max,~(exp_exp1^17'h10000),1'b1,exp1_oor);
  get_carry #(17) cmp2_mod(exp_max_IEEE,~(exp_exp^17'h10000),1'b1,exp_oor_IEEE);
  get_carry #(17) cmp3_mod(exp_max_IEEE,~(exp_exp1^17'h10000),1'b1,exp1_oor_IEEE);
  get_carry #(17) cmp4_mod(~exp_denor_IEEE,(exp_exp^17'h10000),1'b1,exp_non_denor_IEEE);
  get_carry #(17) cmp5_mod(~exp_denor_IEEE,(exp_exp1^17'h10000),1'b1,exp_non_denor_IEEE);


  assign mskS=53'h1fffffffffffff<<(exp_exp_reg-exp_denor_IEEE+1);

  assign exp_exp_d=exp_oor & ~fpcsr[`csrfpu_clip_IEEE] ? exp_max : 17'b0;
  assign exp_exp_d=exp_oor_IEEE & fpcsr[`csrfpu_clip_IEEE] ? exp_max_IEEE : 17'bz;
  assign exp_exp_d=~exp_non_denor_IEEE & fpcsr[`csrfpu_daz] || ~exp_exp[16] ? 17'b0 : 17'bz;
  assign exp_exp_d=~(exp_oor & ~fpcsr[`csrfpu_clip_IEEE]) & 
    ~(exp_oor_IEEE & fpcsr[`csrfpu_clip_IEEE]) & 
    ~(~exp_non_denor_IEEE & fpcsr[`csrfpu_daz] || ~exp_exp[16]) ? (exp_exp^17'h10000) : 17'bz;
  
  assign exp_exp1_d=exp1_oor & ~fpcsr[`csrfpu_clip_IEEE] ? exp_max : 17'b0;
  assign exp_exp1_d=exp1_oor_IEEE & fpcsr[`csrfpu_clip_IEEE] ? exp_max_IEEE : 17'bz;
  assign exp_exp1_d=~exp1_non_denor_IEEE & fpcsr[`csrfpu_daz] || ~exp_exp1[16] ? 17'b0 : 17'bz;
  assign exp_exp1_d=~(exp1_oor & ~fpcsr[`csrfpu_clip_IEEE]) & 
    ~(exp1_oor_IEEE & fpcsr[`csrfpu_clip_IEEE]) & 
    ~(~exp1_non_denor_IEEE & fpcsr[`csrfpu_daz] || ~exp_exp1[16]) ? (exp_exp1^17'h10000) : 17'bz;

  assign exp_exp1_adj_d=exp1_oor & ~fpcsr[`csrfpu_clip_IEEE] ? exp_max : 17'b0;
  assign exp_exp1_adj_d=exp1_oor_IEEE & fpcsr[`csrfpu_clip_IEEE] ? exp_max_IEEE : 17'bz;
  assign exp_exp1_adj_d=~exp1_non_denor_IEEE & fpcsr[`csrfpu_daz] || ~exp_exp1[16] ? 17'b0 : 17'bz;
  assign exp_exp1_adj_d=~(exp1_oor & ~fpcsr[`csrfpu_clip_IEEE]) & 
    ~(exp1_oor_IEEE & fpcsr[`csrfpu_clip_IEEE]) & 
    ~(~exp1_non_denor_IEEE & fpcsr[`csrfpu_daz] || ~exp_exp1[16]) ? (exp_exp1_adj^17'h10000) : 17'bz;

  assign {res[63:33],res[31:0]}=(prod_reg[127] & ~isDBL_reg & ~EXT_rnd1 & ~spec_any & en_reg) ? prod_reg[126:64]:63'bz;
  assign {res[63:33],res[31:0]}=(~prod_reg[127] & ~isDBL_reg & ~EXT_rnd0 & ~spec_any & en_reg) ? prod_reg[125:63]:63'bz;
  assign {res[52:33],res[31:0]}=(prod_reg[105] & isDBL_reg & ~DBL_rnd1 & ~spec_any & en_reg) ? prod_reg[104:53]:52'bz;
  assign {res[52:33],res[31:0]}=(~prod_reg[105] & isDBL_reg & ~DBL_rnd0 & ~spec_any & en_reg) ? prod_reg[103:52]:52'bz;
   
  assign {res_hi[15],res[65],res_hi[14:0],res[64]}=(prod_reg[127] & ~isDBL_reg & ~spec_any & en_reg) ? {exp_exp1_reg[15],sgn_reg,exp_exp1_reg[14:0],1'b1} : 18'bz;
  assign {res_hi[15],res[65],res_hi[14:0],res[64]}=(~prod_reg[127] & ~isDBL_reg & ~spec_any & en_reg) ? {exp_exp_reg[15],sgn_reg,exp_exp_reg[14:0],1'b1} : 18'bz;
  assign {res[64],res[65],res[63:53]}=(prod_reg[105] & isDBL_reg & ~spec_any & en_reg) ? {exp_exp1_reg[15],sgn_reg,exp_exp1_reg[10:0]} : 13'bz;
  assign {res[64],res[65],res[63:53]}=(~prod_reg[105] & isDBL_reg & ~spec_any & en_reg) ? {exp_exp_reg[15],sgn_reg,exp_exp_reg[10:0]} : 13'bz;
  
  assign expon=(prod_reg[127] & ~isDBL_reg & ~spec_any) ? 
    {~EXT_rnbit1 & ~ EXT_tail1,exp_exp1_reg[16],exp1_non_denor_IEEE_reg,exp1_oor_IEEE_reg,exp1_oor_reg} : 5'bz;
  assign expon=(~prod_reg[127] & ~isDBL_reg & ~spec_any) ? 
    {~EXT_rnbit0 & ~ EXT_tail0,exp_exp_reg[16],exp_non_denor_IEEE_reg,exp_oor_IEEE_reg,exp_oor_reg} : 5'bz;
  assign expon=(prod_reg[105] & isDBL_reg & ~spec_any) ?
    {~DBL_rnbit1 & ~ DBL_tail1,exp_exp1_reg[16],exp1_non_denor_IEEE_reg,exp1_oor_IEEE_reg,exp1_oor_reg} : 5'bz;
  assign expon=(~prod_reg[105] & isDBL_reg & ~spec_any) ? 
    {~DBL_rnbit0 & ~ DBL_tail0,exp_exp_reg[16],exp_non_denor_IEEE_reg,exp_oor_IEEE_reg,exp_oor_reg} : 5'bz;
  assign expon=spec_any ? 5'd4 : 5'bz; 

  assign {res[65],res[64:33],res[31:0]}=(spec_any & en_reg) ? {res_spec[80],res_spec[63:0]} : 65'bz;
  assign res_hi[14:0]=(spec_any & ~isDBL_reg & en_reg) ? res_spec[78:64] : 15'bz;
  assign res_hi[15]=(spec_any & ~isDBL_reg & en_reg) ? res_spec[79] : 1'bz;
  
  assign res[67:66]=en_reg ? `ptype_dbl : 2'bz;
  assign res[32]=en_reg ? 1'b0 : 1'bz;

  assign DBL_rnbit0=prod_reg[51];
  assign DBL_tail0=|prod_reg[50:0];
  assign DBL_rnflip0=&prod_reg[103:52];
  assign DBL_rnbit1=prod_reg[52];
  assign DBL_tail1=DBL_tail0|DBL_rnbit0;
  assign DBL_rnbitX=prod_reg[80];
  assign DBL_tailX=|prod_reg[79:52];
  assign DBL_rnflipX=&prod_reg[103:81];

  assign DBL_rnd0=(~is_rounder && ~isrnd_zero && (DBL_rnbit0 & ~(isrnd_even & ~DBL_tail0 & prod_reg[52]) 
    || (isrnd_plus && DBL_rnbit0 | DBL_tail0))) | DBL_rndX;  
  assign DBL_rnd1=~isrnd_zero && (DBL_rnbit1 & ~(isrnd_even & ~DBL_tail1 & prod_reg[53]) 
    || (isrnd_plus && DBL_rnbit1 | DBL_tail1));  
  assign DBL_rndX=is_rounder && ~isrnd_zero && (DBL_rnbitX & ~(isrnd_even & ~DBL_tailX & prod_reg[52]) 
    || (isrnd_plus && DBL_rnbitX | DBL_tailX));  

  assign EXT_rnbit0=prod_reg[62];
  assign EXT_tail0=|prod_reg[61:51]|DBL_tail0;
  assign EXT_rnflip0=&prod_reg[125:63];
  assign EXT_rnbit1=prod_reg[63];
  assign EXT_tail1=|prod_reg[62:51]|DBL_tail0;
  assign EXT_rnbitX=prod_reg[73];
  assign EXT_tailX=|prod_reg[72:63];
  assign EXT_rnflipX=&prod_reg[125:74];
  assign EXT_rnbitY=prod_reg[102];
  assign EXT_tailY=|prod_reg[103:63];
  assign EXT_rnflipY=&prod_reg[125:103];
  
  assign EXT_rnd0=(~is_rounder && ~isrnd_zero && (EXT_rnbit0 & ~(isrnd_even & ~EXT_tail0 & prod_reg[63]) 
    || (isrnd_plus && EXT_rnbit0 | EXT_tail0))) | EXT_rndX | EXT_rndY;  
  assign EXT_rnd1=~isrnd_zero && (EXT_rnbit1 & ~(isrnd_even & ~EXT_tail1 & prod_reg[64]) 
    || (isrnd_plus && EXT_rnbit1 | EXT_tail1)); 
  assign EXT_rndX=is_rounderD && ~isrnd_zero && (EXT_rnbitX & ~(isrnd_even & ~EXT_tailX & prod_reg[63]) 
    || (isrnd_plus && EXT_rnbitX | EXT_tailX));  
  assign EXT_rndY=is_rounderS && ~isrnd_zero && (EXT_rnbitY & ~(isrnd_even & ~EXT_tailY & prod_reg[63]) 
    || (isrnd_plus && EXT_rnbitY | EXT_tailY));  
  
    //begin exp/sgn  
  assign expA=isDBL ? {A[62],A[64],{4{~A[62]}},A[61:52]} : {A[80],A[64],A[78:65]};  
  assign expB=isDBL ? {B[62],B[64],{4{~B[62]}},B[61:52]} : {B[80],B[64],B[78:65]};
  
  assign A_zero=(expA&emsk)==16'b0;
  assign A_infty=(expA|~emsk)==16'hfffe;
  assign A_nan=(expA|~emsk)==16'hffff;
  
  assign B_zero=(expB&emsk)==16'b0;
  assign B_infty=(expB|~emsk)==16'hfffe;
  assign B_nan=(expB|~emsk)==16'hffff;

  assign spec_zero=A_zero&~B_infty&~copyA||B_zero&~A_infty&~copyA;
  assign spec_infty=A_infty&~B_zero&~copyA||B_infty&~A_zero&~copyA;
  assign spec_nan=(A_infty & B_zero|| B_infty & A_zero || 
      A_nan&~B_infty&~B_zero || B_nan&~A_infty&~A_zero) &~copyA;
  assign spec_A=copyA;
  assign spec_snan=fpcsr[`csrfpu_inv_excpt]&spec_nan;
  assign spec_qnan=~fpcsr[`csrfpu_inv_excpt]&spec_nan;

  assign sgn=isDBL ? A[63]^B[63] : A[79]^B[79];
  
  assign res_spec=spec_A_reg ? A_reg : 81'bz;
  assign res_spec=(spec_snan_reg & ~isDBL_reg) ? {17'h1ffff,64'b1} : 81'bz;
  assign res_spec=(spec_qnan_reg & ~isDBL_reg) ? {17'h1ffff,64'h8000000000000001} : 81'bz;
  assign res_spec=(spec_infty_reg & ~isDBL_reg) ? {1'b1,sgn_reg,15'h7ffe,64'b0} : 81'bz;
  assign res_spec=(spec_snan_reg & isDBL_reg) ? {17'h1ffff,64'hfff0000000000001} : 81'bz;
  assign res_spec=(spec_qnan_reg & isDBL_reg) ? {17'h1ffff,64'hfff8000000000001} : 81'bz;
  assign res_spec=(spec_infty_reg & isDBL_reg) ? {17'h1efff,sgn_reg,63'h7fe0000000000000} : 81'bz;
  assign res_spec=spec_any ?  81'bz :  81'b0;

  assign raise[`csrfpu_inv_excpt]=spec_snan_reg;
  assign raise[`csrfpu_under_excpt]=sgn_reg && expon[0];
  assign raise[`csrfpu_under_ieee_excpt]=sgn_reg && expon[1];
  assign raise[`csrfpu_over_excpt]=~sgn_reg && expon[0];
  assign raise[`csrfpu_over_ieee_excpt]=~sgn_reg && expon[1];
  assign raise[`csrfpu_denor_ieee_excpt]=~expon[2] | expon[3];
  assign raise[`csrfpu_denor_excpt]=expon[3];
  assign raise[`csrfpu_inexact_excpt]=expon[4] | expon[3];
  assign raise[`csrfpu_inexact_ieee_excpt]=expon[4] | expon[3] | ~expon[2];
  assign raise[`csrfpu_denor_consume_excpt]=1'b0;//only for logic op
  assign raise[`csrfpu_denor_produce_excpt]=1'b0;// ==//==

  always @(*) begin
      if (~is_rndD_reg & ~is_rndS_reg) begin
	  rndbit_ext={62'b0,prod_reg[127],~prod_reg[127]};
          rndbit_dbl={51'b0,prod_reg[105],~prod_reg[105]};
	  enbit_ext=64'hffff_ffff_ffff_ffff;
	  enbit_dbl=53'h1f_ffff_ffff_ffff;
      end else if (is_rndD_reg) begin
	  rndbit_ext={52'b0,1'b1,11'b0};
          rndbit_dbl={51'b0,prod_reg[105],~prod_reg[105]};
	  enbit_ext=64'hffff_ffff_ffff_0000;
	  enbit_dbl=53'h1f_ffff_ffff_ffff;
      end else begin
	  rndbit_ext={23'b0,1'b1,40'b0};
	  rndbit_dbl={23'b0,1'b1,29'b0};
	  enbit_ext=64'hffff_ff00_0000_0000;
	  enbit_dbl=53'h1f_ffff_e000_0000;
      end
      spec_any=spec_zero_reg|spec_infty_reg|spec_snan_reg|spec_qnan_reg|spec_A_reg;
      prod_reg=prod;
  end
`ifndef swapedge
  always @(negedge clk)
`else
  always @(posedge clk)
`endif
  begin
 //     if (res!=res) $display("res z muld");
      isDBL_reg<=isDBL;
      isDBL_reg<=isDBL_reg;
  //    isDBL_reg<=isDBL_reg;
      en_reg<=en;
      en_reg<=en_reg;
 //     en_reg3<=en_reg;
      is_rndD_reg<=is_rndD;
      is_rndS_reg<=is_rndS; 
      is_rndD_reg<=is_rndD_reg;
      is_rndS_reg<=is_rndS_reg;
      is_rounder<=is_rndD_reg|is_rndS_reg; 
      is_rounderD<=is_rndD_reg; 
      is_rounderS<=is_rndS_reg; 
//      exp_exp_reg<=exp_exp^17'h10000;
//      exp_exp1_reg<=exp_exp1^17'h10000;
      exp_exp_reg<=exp_exp_d;
      exp_exp1_reg<=exp_exp1_d;
      exp_exp1_adj_reg<=exp_exp1_adj_d;
 //     exp_exp_reg3<=exp_exp_reg;
 //     exp_exp1_reg3<=exp_exp1_reg;
      exp_max<=isDBL ? 17'hffe : 17'hfffe;
      exp_max_IEEE<=isDBL ? 17'hbff : 17'hbfff;
      exp_denor_IEEE<=isDBL ? 17'h401 : 17'h4001;
      fpcsr_reg<=fpcsr;
      sgn_reg<=sgn;
      sgn_reg<=sgn_reg;
  //    sgn_reg3<=sgn_reg;
      spec_zero_reg<=spec_zero;
      spec_infty_reg<=spec_infty;
      spec_snan_reg<=spec_snan;
      spec_qnan_reg<=spec_qnan;
      spec_A_reg<=spec_A;
      exp_oor_reg<=exp_oor;
      exp1_oor_reg<=exp1_oor;
      exp_oor_IEEE_reg<=exp_oor_IEEE;
      exp1_oor_IEEE_reg<=exp1_oor_IEEE;
      exp_non_denor_IEEE_reg<=exp_non_denor_IEEE;
      exp1_non_denor_IEEE_reg<=exp1_non_denor_IEEE;
      A_reg<=copyA ? {A_alt[64],16'b0,A_alt[63:0]} : A;
      case(rmode)
        ROUND_TRUNC: begin isrnd_even<=1'b0; isrnd_zero<=1'b1; isrnd_plus<=1'b0; end
        ROUND_ROUND: begin isrnd_even<=1'b0; isrnd_zero<=1'b0; isrnd_plus<=1'b0; end
        ROUND_EVEN : begin isrnd_even<=1'b1; isrnd_zero<=1'b0; isrnd_plus<=1'b0; end
        ROUND_PLUS : begin isrnd_even<=1'b0; isrnd_zero<=sgn_reg; isrnd_plus<=1'b0; end
        ROUND_MINUS: begin isrnd_even<=1'b0; isrnd_zero<=~sgn_reg; isrnd_plus<=1'b0; end
        ROUND_UP   : begin isrnd_even<=1'b0; isrnd_zero<=sgn_reg; isrnd_plus<=~sgn_reg; end
        ROUND_DOWN : begin isrnd_even<=1'b0; isrnd_zero<=~sgn_reg; isrnd_plus<=sgn_reg; end
      endcase
  end

endmodule


