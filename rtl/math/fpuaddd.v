/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


`include "../fpoperations.sv"
`include "../struct.sv"

module fadd(
  clk,
  rst,
  A,
  A_alt,
  B,
  pook_inX,
  pook_op_bit,
  isDBL,
  isSub,//inclusive of isRSub
  isRSub,
  fpcsr,
  raise,
  rmode,
  en,
  copyA,
  logic_en,
  logic_sel,
  res,
  res_hi
  );
  localparam ROUND_TRUNC=0;
  localparam ROUND_ROUND=1;
  localparam ROUND_EVEN =2;
  localparam ROUND_PLUS =3;
  localparam ROUND_MINUS=4;
  localparam ROUND_UP   =5;
  localparam ROUND_DOWN =6;

  input pwire clk;
  input pwire rst;
  input pwire [80:0] A;
  input pwire [64:0] A_alt;
  input pwire [80:0] B;
  input pwire pook_inX;
  input pwire pook_op_bit;
  input pwire isDBL;
  input pwire isSub;
  input pwire isRSub;
  input pwire [31:0] fpcsr;
  output pwire [10:0] raise;
  input pwire [2:0] rmode;
  input pwire en;
  input pwire copyA;
  input pwire logic_en;
  input pwire [1:0] logic_sel;
  output pwire [67:0] res;
  output pwire [15:0] res_hi;
//need to set bit 53 to one if isDBL; not yet done
//need to clear/set bits 63-54 if isDBL and corresponging conditions
//if no isDBL, set one op low bits to 0, other to one depening on rounding
//width
  pwire [67:0] res_X;
  pwire [15:0] res_X_hi;

  pwire [51:0] mskS;
  pwire [51:0] mskSC;
  pwire [51:0] mskSL;

  pwire pook_excpt;
  
  assign pook_excpt=pook_op_bit && isDBL ? ~|opB[52:0] : ~|opB[62:0];

  assign res=res_X;
  assign res_hi=res_X_hi;

  function [64:0] fracxfrm0;
      input pwire [64:0] op;
      input pwire dbl;
      
      begin
	  fracxfrm0[10:0]=op[10:0];
	  fracxfrm0[39:11]=op[39:11];
	  fracxfrm0[51:40]=op[51:40];
	  fracxfrm0[52]=op[52]|dbl;
	  fracxfrm0[63:53]=op[63:53]&{11{~dbl}};
      end
  endfunction

  function [64:0] fracxfrm1;
      input pwire [64:0] op;
      input pwire dbl;
      
      begin
	  fracxfrm1[10:0]=op[10:0];
	  fracxfrm1[39:11]=op[39:11];
	  fracxfrm1[51:40]=op[51:40];
	  fracxfrm1[52]=op[52]|dbl;
	  fracxfrm1[63:53]=op[63:53]&{11{~dbl}};
      end
  endfunction

  pwire sxor;
  reg sxor_reg;
  pwire a_more;
  pwire [64:0] opA;
  pwire [64:0] opB;
  pwire moreAD,moreAE;
  pwire [15:0] expdiffA;
  pwire [15:0] expdiffB;
  pwire [15:0] expdiff;
  reg  [15:0] expdiff_reg;
  pwire [64:0] opBs1;
  pwire [64:0] opBs;
  reg [64:0] opBs1_reg;
  reg [64:0] opA_reg;
//  reg [64:0] opB_reg;
  pwire [64:0] partM0;
  pwire [64:0] partM1;
  pwire [64:0] partMs0;
  pwire [64:0] partMs1;
  pwire [64:0] resS1;
  pwire [64:0] resSR1;
  reg [64:0] resS1_reg;
  reg [64:0] resSR1_reg;
  pwire resS_rnbit;
  pwire res_rnbit,res_tail,res_andtail;
  pwire res_rnbitC,res_tailC,res_andtailC;
  pwire res_rnbitL,res_tailL,res_andtailL;
  pwire expoor;//completely off-precision shift!
  reg expoor_reg; 
  pwire alt_en;
  pwire A_s,B_s,A_s1,B_s1;
  reg A_s1_reg;
  pwire renor_simple,renor_round;
  pwire main_simple,main_round;
  pwire main_simpleL,main_roundL,main_subroundL;
  pwire main_simpleC,main_roundC,main_simpleRC;
  pwire Smain_simple,Smain_round;
  pwire Smain_simpleC,Smain_roundC,Smain_simpleRC;
  pwire Smain_simpleL,Smain_roundL,Smain_subroundL;
  pwire [64:0] renorS;
  pwire [15:0] renorE;
  pwire [64:0] renorSR;
  pwire [15:0] renorER;
  pwire [7:0] andtailBs1;
  pwire [7:0] andtailBs;
  pwire [7:0] andtailBs1_c;
  pwire [7:0] andtailBs_c;
  pwire [7:0] andtailBs1_L;
  pwire [7:0] andtailBs_L;
  pwire [7:0] tailBs1;
  pwire [7:0] tailBs;
  pwire [7:0] tailBs1_c;
  pwire [7:0] tailBs_c;
  pwire [7:0] tailBs1_L;
  pwire [7:0] tailBs_L;
  reg andtailBs1_reg;
  reg andtailBs1_c_reg;
  reg andtailBs1_L_reg;
  reg tailBs1_reg;
  reg tailBs1_c_reg;
  reg tailBs1_L_reg;
  reg isDBL_reg;
  pwire [64:0] resM1;
  pwire [64:0] resMR1;
  pwire [64:0] resM2;
  pwire [64:0] resMR2;
  pwire cout64_M1_ns,cout64_MR1_ns,cout53_M1_ns,cout53_MR1_ns;
  pwire cout64_M2_ns,cout64_MR2_ns,cout53_M2_ns,cout53_MR2_ns;
  pwire cout64_SZ1,cout64_SZR1,cout53_SZ1,cout53_SZR1;
  pwire cout64_Sz1,cout64_SzR1,cout53_Sz1,cout53_SzR1;
  pwire cout64_S1,cout64_SR1,cout53_S1,cout53_SR1;
  pwire [64:0] par1Off_A;
  pwire [64:0] par1Off_B;
  pwire [64:0] part_A;
  pwire [64:0] part_B;
  pwire [64:0] partt_A;
  pwire [64:0] partt_B;
  reg [7:0] expdiffeq;
  pwire [9:0] xop1;
  reg [9:0] xop1_reg;
  reg isrnd_zero,isrnd_even,isrnd_plus;
  pwire [64:0] resX;
  pwire [80:0] resY;
  pwire main_lo,main_ulo,Smain_lo,Smain_ulo;
  pwire [15:0] opA_exp;
  pwire [15:0] opA_exp_inc;
  pwire [15:0] opA_exp_dec;
  reg [15:0] opA_exp_reg;
  pwire altpath;
  reg altpath_reg;
  pwire rndpath;
  reg rndpath_reg;
  reg opB_reg;
  pwire [15:0] A_exp;
  pwire [15:0] B_exp;
  pwire A_zero,A_infty,A_nan;
  pwire B_zero,B_infty,B_nan;
  pwire spec_snan,spec_qnan,spec_pinf,spec_ninf,spec_A,spec_B;
  reg spec_snan_reg,spec_qnan_reg,spec_pinf_reg,spec_ninf_reg,spec_A_reg,spec_B_reg;
  pwire [3:0] spec_logic;
  reg [3:0] spec_logic_reg;
  reg spec_any;
  pwire [80:0] res_spec;
  reg [80:0] A_reg;
  reg [80:0] B_reg;
  pwire A_s2;
  reg en_reg;
  pwire [15:0] emsk=isDBL ? 16'h87ff : 16'hffff;
  integer m;

  pwire renor_any,exp_dec_non_denor_IEEE_0,exp_dec_non_denor_IEEE_1,exp_dec_non_denor,exp_inc_oor_IEEE,exp_inc_oor,
	  exp_dec_non_denor_IEEE;
  pwire [15:0] exp_min_IEEE;
  pwire [15:0] exp_max_IEEE;
  pwire [15:0] exp_min_kludge;
  pwire [15:0] exp_max;
  reg exp_inc_oor_reg,exp_inc_oor_IEEE_reg,exp_dec_non_denor_reg,exp_dec_non_denor_IEEE_reg;
  pwire [3:0] xpon;
  pwire [3:0] X_xpon;
  pwire [3:0] Y_xpon;
  pwire invExcpt;
  pwire pook;

  assign pook=B_zero;

  assign pook_in=pook_inX && expdiff==0 && ~sxor && pook_inX;

  assign A_exp=(~isDBL) ? {A[80],A[64],A[78:65]} : {A[62],A[64],{4{~A[64]}},A[61:52]};
  assign B_exp=(~isDBL) ? {B[80],B[64],B[78:65]} : {B[62],B[64],{4{~B[64]}},B[61:52]};

  assign A_zero=(A_exp&emsk)==16'b0;
  assign A_infty=(A_exp|~emsk)==16'hfffe;
  assign A_nan=(A_exp|~emsk)==16'hffff;
  
  assign B_zero=(B_exp&emsk)==16'b0;
  assign B_infty=(B_exp|~emsk)==16'hfffe;
  assign B_nan=(B_exp|~emsk)==16'hffff;

  assign invExcpt=fpcsr[`csrfpu_inv_excpt];

  assign spec_snan=A_nan & ~B_infty & invExcpt & ~copyA || B_nan & ~A_infty & invExcpt & ~copyA || A_infty & B_infty & sxor & invExcpt & ~copyA;  
  assign spec_qnan=A_nan & ~B_infty & ~invExcpt & ~copyA || B_nan & ~A_infty & ~invExcpt & ~copyA || A_infty & B_infty & sxor & ~invExcpt & ~copyA;
  assign spec_pinf=(A_infty && ~A_s && ~B_infty|~B_s && ~copyA) || (B_infty && ~B_s && ~A_infty|~A_s && ~copyA);   
  assign spec_ninf=(A_infty && A_s && ~B_infty|B_s && ~copyA) || (B_infty && B_s && ~A_infty|A_s && ~copyA);
  assign spec_A=(B_zero && ~A_zero|~A_s|B_s && ~A_nan && ~A_infty)||copyA;
  assign spec_B=(A_zero && ~B_zero|(~B_s&A_s) && ~B_nan && ~B_infty)&&~copyA;
  assign spec_logic[0]=logic_en && logic_sel==2'd0 && ~copyA;
  assign spec_logic[1]=logic_en && logic_sel==2'd1 && ~copyA;
  assign spec_logic[2]=logic_en && logic_sel==2'd2 && ~copyA;
  assign spec_logic[3]=logic_en && logic_sel==2'd3 && ~copyA;
 
 
  assign opA=a_more ?  fracxfrm1(A[63:0],isDBL) : 64'bz;
  assign opB=(sxor & a_more) ?  ~fracxfrm1(B[63:0],isDBL) : 64'bz;
  assign opA=(~a_more) ?  fracxfrm1(B[63:0],isDBL) : 64'bz;
  assign opB=(sxor & ~a_more) ?  ~fracxfrm1(A[63:0],isDBL) : 64'bz;
  assign opB=(~sxor & a_more) ?  fracxfrm0(B[63:0],isDBL) : 64'bz;
  assign opB=(~sxor & ~a_more) ?  fracxfrm0(A[63:0],isDBL) : 64'bz;
  
  assign opA_exp=(a_more & ~isDBL) ? {A[80],A[64],A[78:65]} : 16'bz;
  assign opA_exp=(a_more & isDBL) ? {A[80],A[64],{4{~A[64]}},A[62:52]} : 16'bz;
  assign opA_exp=(~a_more & ~isDBL) ? {B[80],B[64],B[78:65]} : 16'bz;
  assign opA_exp=(~a_more & isDBL) ? {B[80],B[64],{4{~B[64]}},B[62:52]} : 16'bz;
  
  assign expdiff=a_more ? expdiffA : expdiffB;
  
//  assign Bx=is_alt ? B_alt : B;

  assign opBs1=expoor ? {64{sxor_reg}} : 64'bz;
  assign opBs=expoor_reg ? {64{sxor_reg}} : 64'bz;
  assign res_rnbit=expoor_reg ? xop1_reg[1]^(res_andtail&sxor_reg) : 1'bz;
//  assign res_rnbitC=expoor_reg ?  : 1'bz;
  assign res_rnbitL=expoor_reg ? xop1_reg[0]^(res_andtailL&sxor_reg) : 1'bz;
  assign xop1[1:0]=(expoor && expdiff[15:1]!=15'h20) ? {2{sxor}} : 2'bz;
  
  assign a_more=isDBL ? moreAD : moreAE;

  assign sxor=isDBL ? A[63]^B[63]^isSub : A[79]^B[79]^isSub;
  assign A_s=isDBL ? A[63]^(isRSub) : A[79]^(isRSub);
  assign B_s=isDBL ? B[63]^(isSub&~isRSub) : B[79]^(isSub&~isRSub);
  assign A_s1=a_more ? A_s : B_s;
  assign B_s1=a_more ? B_s : A_s;
  assign A_s2=(a_more & ~(expdiffA==0 && alt_en && sxor)) ? A_s : B_s;

  assign alt_en=isDBL ? ~cout53_SZ1 : ~cout64_SZ1;

  assign resS_rnbit=(expdiffA!=0) ? ~opB[0] : 1'b0;
  assign altpath=(expdiffA==0 || expdiffA==1 || expdiffB==1) && sxor;
  assign rndpath=(expdiffA==1 || expdiffB==1) && sxor;
 
  assign res_X[67:66]=en_reg ? `ptype_dbl : 2'bz;

  assign res_X[64:0]=(renor_simple & ~isDBL_reg & ~spec_any & en_reg) ? {renorS[63:32],B_zero,renorS[31:0]} : 65'bz;
  assign res_X[52:0]=(renor_simple & isDBL_reg & ~spec_any & en_reg) ? {renorS[62:43],B_zero,renorS[42:11]} : 53'bz;
  assign {res_X[65],res_X_hi[14:0]}=(renor_simple & ~isDBL_reg & ~spec_any & en_reg) ? renorE : 16'bz;
  assign {res_X[65],res_X[63:53]}=(renor_simple & isDBL_reg & ~spec_any & en_reg) ? {renorE[15],renorE[10:0]} : 12'bz;
  
  assign res_X[64:0]=(renor_round & ~isDBL_reg & ~spec_any & en_reg) ? {renorSR[63:32],B_zero,renorSR[31:0]} : 65'bz;
  assign res_X[52:0]=(renor_round & isDBL_reg & ~spec_any & en_reg) ? {renorSR[62:43],B_zero,renorSR[42:11]} : 53'bz;
  assign {res_X[65],res_X_hi[14:0]}=(renor_round & ~isDBL_reg & en_reg & ~spec_any) ? renorER : 16'bz;
  assign {res_X[65],res_X[63:53]}=(renor_round & isDBL_reg & en_reg & ~spec_any) ? {renorER[11],renorER[10:0]} : 12'bz;

  assign res_X_hi[15]=(renor_simple & ~isDBL_reg & en_reg & ~spec_any) ? A_s1_reg : 1'bz;
  assign res_X[15]=(renor_round & ~isDBL_reg & en_reg & ~spec_any) ? A_s1_reg : 1'bz;
  assign res_X[64]=(renor_simple & isDBL_reg & en_reg & ~spec_any) ? A_s1_reg : 1'bz;
  assign res_X[64]=(renor_round & isDBL_reg & en_reg & ~spec_any) ? A_s1_reg : 1'bz;
  

  assign {res_X[65],res_X_hi,res_X[64:0]}=(~renor_simple && ~renor_round && ~isDBL_reg && ~spec_any && en_reg) ? {resY[80:32],pook,resY[31:0]} : 82'bz;
  assign res_X[65:0]=(~renor_simple && ~renor_round &&  isDBL_reg && ~spec_any && en_reg) ? {resX[64:32],pook,resX[31:0]} : 66'bz;

  assign {res_X[65],res_X[64:0]}=(spec_any & en_reg) ? {res_spec[80],res_spec[63:32],1'b0,res_spec[31:0]} : 66'bz;  
  assign res_X_hi[14:0]=(spec_any & ~isDBL_reg & en_reg) ? {res_spec[78:64]} : 15'bz;  
  assign res_X_hi[15]=(spec_any & ~isDBL_reg & en_reg) ? {res_spec[79]} : 1'bz;  

  assign res_spec=spec_A_reg ? A_reg : 81'bz;
  assign res_spec=spec_B_reg ? B_reg : 81'bz;
  assign res_spec=(spec_snan_reg & ~isDBL_reg) ? {17'h1ffff,64'b1} : 81'bz;
  assign res_spec=(spec_qnan_reg & ~isDBL_reg) ? {17'h1ffff,64'h8000000000000001} : 81'bz;
  assign res_spec=(spec_pinf_reg & ~isDBL_reg) ? {17'h1effe,64'b0} : 81'bz;
  assign res_spec=(spec_ninf_reg & ~isDBL_reg) ? {17'h1fffe,64'b0} : 81'bz;
  assign res_spec=(spec_snan_reg & isDBL_reg) ? {17'h1ffff,64'hfff0000000000001} : 81'bz;
  assign res_spec=(spec_qnan_reg & isDBL_reg) ? {17'h1ffff,64'hfff8000000000001} : 81'bz;
  assign res_spec=(spec_pinf_reg & isDBL_reg) ? {17'h1efff,64'h7fe0000000000000} : 81'bz;
  assign res_spec=(spec_ninf_reg & isDBL_reg) ? {17'h1ffff,64'hffe0000000000000} : 81'bz;
  assign res_spec=spec_logic_reg[0] ? {A_reg[80:65]&B_reg[80:65],A_reg[64]|B_reg[64],A_reg[63:0]&B_reg[63:0]} : 81'bz;
  assign res_spec=spec_logic_reg[1] ? {A_reg[80:65]|B_reg[80:65],A_reg[64]&B_reg[64],A_reg[63:0]|B_reg[63:0]} : 81'bz;
  assign res_spec=spec_logic_reg[2] ? {A_reg[80:65]^B_reg[80:65],A_reg[64]^B_reg[64],A_reg[63:0]^B_reg[63:0]} : 81'bz;
  assign res_spec=spec_logic_reg[3] ? {A_reg[80:65]&~B_reg[80:65],A_reg[64]|~B_reg[64],A_reg[63:0]&~B_reg[63:0]} : 81'bz;
  assign res_spec=spec_any ?  81'bz :  81'b0;

  assign renor_round=rndpath_reg && !(opB_reg || isrnd_zero ||(isrnd_even && resSR1_reg[0])) &&
  (isDBL_reg ? resS1_reg[52] : resS1_reg[63]);
  
  assign renor_simple=altpath_reg && ~renor_round;
  
  assign expoor=expdiff[15:6]!=10'b0 ;//&& expdiff!=16'h40; 

  assign resY[79]=A_s1_reg;
  assign resX[63]=A_s1_reg;
    
  get_carry #(16) cmp1_mod(opA_exp,~exp_max,1'b1,exp_inc_oor);
  get_carry #(16) cmp2_mod(opA_exp,~exp_max_IEEE,1'b1,exp_inc_oor_IEEE);
  get_carry #(16) cmp3_mod(opA_exp,~exp_min_IEEE,1'b1,exp_dec_non_denor_IEEE_0);
  get_carry #(16) cmp4_mod(opA_exp,~exp_min_kludge,1'b1,exp_dec_non_denor_IEEE_1);
  assign exp_dec_non_denor=opA_exp[15:1]!=0;
  assign exp_dec_non_denor_IEEE=altpath ? exp_dec_non_denor_IEEE_1 : exp_dec_non_denor_IEEE_0;

  assign exp_max=isDBL ? 16'hffd : 16'hfffd;
  assign exp_max_IEEE=isDBL ? 16'hbfe : 16'hbffe;
  assign exp_min_IEEE=isDBL ? 16'h401 : 16'h4001;
  assign exp_min_kludge=isDBL ? 16'h436 : 16'h4021;

  assign raise[`csrfpu_inv_excpt]=spec_snan_reg;
  assign raise[`csrfpu_under_excpt]=A_s1_reg & exp_inc_oor_reg & xpon[1] & ~spec_any;
  assign raise[`csrfpu_over_excpt]=~A_s1_reg & exp_inc_oor_reg & xpon[1] & ~spec_any;
  assign raise[`csrfpu_under_ieee_excpt]=A_s1_reg & exp_inc_oor_IEEE_reg & xpon[1] & ~spec_any;
  assign raise[`csrfpu_over_ieee_excpt]=~A_s1_reg & exp_inc_oor_IEEE_reg & xpon[1] & ~spec_any;
  assign raise[`csrfpu_denor_excpt]=~exp_dec_non_denor_reg & xpon[0] & ~spec_any;
  assign raise[`csrfpu_denor_ieee_excpt]=~exp_dec_non_denor_IEEE_reg & xpon[0] & ~spec_any;
  assign raise[`csrfpu_inexact_excpt]=!|xpon[3:2]; 
  assign raise[`csrfpu_inexact_ieee_excpt]=!|xpon[3:2]; 
  assign raise[`csrfpu_denor_consume_excpt]=1'b0;
  assign raise[`csrfpu_denor_produce_excpt]=1'b0;

  assign X_xpon=Smain_simple ? {res_rnbit,res_tail,2'b00} : 4'bz;
  assign X_xpon=Smain_round ? {res_rnbit,res_tail,2'b00} : 4'bz;
  assign X_xpon=Smain_simpleC ? {res_rnbitC,res_tailC,2'b10} : 4'bz;
  assign X_xpon=Smain_roundC ? {res_rnbitC,res_tailC,2'b10} : 4'bz;
  assign X_xpon=Smain_simpleRC ? {res_rnbit,res_tail,2'b10} : 4'bz;
  assign X_xpon=Smain_simpleL ? {res_rnbitL,res_tailL,2'b01} : 4'bz;
  assign X_xpon=Smain_roundL ? {res_rnbitL,res_tailL,2'b00} : 4'bz;
  
  assign Y_xpon=main_simple ? {res_rnbit,res_tail,2'b00} : 4'bz;
  assign Y_xpon=main_round ? {res_rnbit,res_tail,2'b00} : 4'bz;
  assign Y_xpon=main_simpleC ? {res_rnbitC,res_tailC,2'b10} : 4'bz;
  assign Y_xpon=main_roundC ? {res_rnbitC,res_tailC,2'b10} : 4'bz;
  assign Y_xpon=main_simpleRC ? {res_rnbit,res_tail,2'b10} : 4'bz;
  assign Y_xpon=main_simpleL ? {res_rnbitL,res_tailL,2'b01} : 4'bz;
  assign Y_xpon=main_roundL ? {res_rnbitL,res_tailL,2'b00} : 4'bz;
 
  assign xpon=isDBL_reg & ~renor_simple & ~renor_any  ? X_xpon : 4'bz;
  assign xpon=~isDBL_reg & ~renor_simple & ~renor_any  ? X_xpon : 4'bz;
  assign xpon=renor_simple | renor_round ? {renor_round,3'b001} : 4'bz;
   
  assign resX[51:0]=Smain_simple ? resM1[51:0]&mskS : 52'bz;
  assign resX[51:0]=Smain_round ? resMR1[51:0]&mskS : 52'bz;
  assign resX[51:0]=Smain_simpleC ? resM1[52:1]&mskSC : 52'bz;
  assign resX[51:0]=Smain_roundC ? resM2[52:1]&mskSC : 52'bz;
  assign resX[51:0]=Smain_simpleRC ? resMR1[52:1]&mskSC : 52'bz;
  assign resX[51:0]=Smain_simpleL ? {resM1[50:0],res_rnbit^Smain_subroundL}&mskSL : 52'bz;
  assign resX[51:0]=Smain_roundL ? {resMR1[50:0],1'b0}&mskSL : 52'bz;

  assign mskS=52'hfffffffffffff<<({opA_exp_reg[15],opA_exp_reg[10:0]}-12'h401);
  assign mskSC=52'hfffffffffffff<<({opA_exp_reg[15],opA_exp_reg[10:0]}-12'h400);
  assign mskSL=52'hfffffffffffff<<({opA_exp_reg[15],opA_exp_reg[10:0]}-12'h402);

  assign {resX[62],resX[64],resX[61:52]}=Smain_simple ? {opA_exp_reg[15],opA_exp_reg[10:0]} : 12'bz;
  assign {resX[62],resX[64],resX[61:52]}=Smain_round ? {opA_exp_reg[15],opA_exp_reg[10:0]} : 12'bz;
  assign {resX[62],resX[64],resX[61:52]}=Smain_simpleC ? {opA_exp_inc[15],opA_exp_inc[10:0]} : 12'bz;
  assign {resX[62],resX[64],resX[61:52]}=Smain_roundC ? {opA_exp_inc[15],opA_exp_inc[10:0]} : 12'bz;
  assign {resX[62],resX[64],resX[61:52]}=Smain_simpleRC ? {opA_exp_inc[15],opA_exp_inc[10:0]} : 12'bz;
  assign {resX[62],resX[64],resX[61:52]}=Smain_simpleL ? {opA_exp_dec[15],opA_exp_dec[10:0]} : 12'bz;
  assign {resX[62],resX[64],resX[61:52]}=Smain_roundL ? {opA_exp_dec[15],opA_exp_dec[10:0]} : 12'bz;
  
  assign {resY[80],resY[64],resY[78:65]}=main_simple ? opA_exp_reg : 16'bz;
  assign {resY[80],resY[64],resY[78:65]}=main_round ? opA_exp_reg : 16'bz;
  assign {resY[80],resY[64],resY[78:65]}=main_simpleC ? opA_exp_inc : 16'bz;
  assign {resY[80],resY[64],resY[78:65]}=main_roundC ? opA_exp_inc : 16'bz;
  assign {resY[80],resY[64],resY[78:65]}=main_simpleRC ? opA_exp_inc : 16'bz;
  assign {resY[80],resY[64],resY[78:65]}=main_simpleL ? opA_exp_dec : 16'bz;
  assign {resY[80],resY[64],resY[78:65]}=main_roundL ? opA_exp_dec : 16'bz;
   
  assign resY[63:0]=main_simple ? resM1[63:0] : 64'bz;
  assign resY[63:0]=main_round ? resMR1[63:0] : 64'bz;
  assign resY[63:0]=main_simpleC ? {1'b1,resM1[63:1]} : 64'bz;
  assign resY[63:0]=main_roundC ? {1'b1,resM2[63:1]} : 64'bz;
  assign resY[63:0]=main_simpleRC ? {1'b1,resMR1[63:1]} : 64'bz;
  assign resY[63:0]=main_simpleL ? {resM1[62:0],res_rnbit^main_subroundL} : 64'bz;
  assign resY[63:0]=main_roundL ? {resMR1[62:0],1'b0} : 64'bz;

  
  assign main_lo=~resM1[63] && ~(cout64_M1_ns^partM1[64]^sxor_reg);
  assign main_ulo=main_lo && resMR1[63];
  assign Smain_lo=~resM1[52] && ~(resM1[53]);
  assign Smain_ulo=Smain_lo && resMR1[52];
  
  assign main_simple=~main_lo && (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])) && 
    ~(cout64_M1_ns^partM1[64]^sxor_reg);
  assign main_round=(~main_lo && !(~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero ||(isrnd_even && ~res_tail&&resMR1[0])) && ~(cout64_MR1_ns^partM1[64]^sxor_reg)) ||
    (main_ulo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)));
  assign main_roundC=~main_lo && !(~res_rnbitC & ~(res_tailC & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailC&&resM2[1])) && (cout64_M1_ns^partM1[64]^sxor_reg) &&
   (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0]));
  assign main_simpleC=~main_lo && ((~res_rnbitC & ~(res_tailC & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailC&&resM2[1]) || pook_in ) && (cout64_M1_ns^partM1[64]^sxor_reg) &&
    (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])));
  assign main_simpleRC=~main_lo && (!(~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])) && (cout64_MR1_ns^partM1[64]^sxor_reg));
  assign main_simpleL=main_lo && ((~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) || ~res_rnbit);
  assign main_roundL=main_lo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) && ~main_ulo && res_rnbit;
  assign main_subroundL=main_lo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) && ~main_ulo;//|~res_rnbitL;
  
  assign Smain_simple=~Smain_lo && (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])) && ~(resM1[53]&~sxor_reg);
  assign Smain_round=(~Smain_lo && !(~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])) && ~(resMR1[53]&~sxor_reg)) ||
    (Smain_ulo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)
    ) );
  assign Smain_roundC=~Smain_lo && !(~res_rnbitC & ~(res_tailC & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailC&&resM2[1])) && (resM1[53]&~sxor_reg) &&
   (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&resMR1[0]));
  assign Smain_simpleC=~Smain_lo && ((~res_rnbitC & ~(res_tailC & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailC&&resM2[1])) && (resM1[53]&~sxor_reg) &&
    (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0]))); 
  assign Smain_simpleRC=~Smain_lo && (!(~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])) && (resMR1[53]&~sxor_reg));
  assign Smain_simpleL=Smain_lo && ((~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) ||
    ~res_rnbit);
  assign Smain_roundL=Smain_lo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) && ~Smain_ulo &&
   res_rnbit;
  assign Smain_subroundL=Smain_lo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) && ~Smain_ulo;//|~res_rnbitL;
  
  assign res_rnbitC=resM1[0];
  assign xop1[9:2]=opBs1[7:0];
  assign res_tail=sxor_reg ? ~res_andtail|pook_inX : |{tailBs,tailBs1_reg,pook_inX};
  assign res_tailC=sxor_reg ? ~res_andtailC|pook_inX : |{tailBs_c,tailBs1_c_reg,pook_inX};
  assign res_tailL=sxor_reg ? ~res_andtailL|pook_inX : |{tailBs_L,tailBs1_L_reg,pook_inX};
  assign res_andtail=&{andtailBs,andtailBs1_reg};
  assign res_andtailC=&{andtailBs_c,andtailBs1_c_reg};
  assign res_andtailL=&{andtailBs_L,andtailBs1_L_reg};

  
  generate
      genvar k;
      for(k=0;k<8;k=k+1) begin
          if (k!=0) assign {opBs1,xop1[1:0]}=(expdiff[5:3]==k && ~expoor) ? {{k*8{sxor}},opB[63:k*8-2]} : 66'bz;
          else begin
              assign opBs1=(expdiff[5:3]==k && ~expoor) ? {{k*8{sxor}},opB[63:k*8]} : 64'bz;
              assign xop1[1:0]=(expdiff[5:3]==3'b0 && ~expoor) ? 2'b0 : 2'bz;
              assign xop1[1:0]=(expdiff==16'h40) ? opB[63:62] : 2'bz;
              assign xop1[1:0]=(expdiff==16'h41) ? {sxor,opB[63]} : 2'bz;
          end
          if (k<8) begin 
              pwire e_more,e_eq,e_eq2;
              get_carry #(4) cmp8_mod(~(k[3:0]+4'b1),expdiff[6:3],1'b1,e_more);
              assign e_eq=expdiff[5:3]==(k+1) && expdiff[2:0]==3'b0;
              assign e_eq2=expdiff[5:3]==(k+1) && expdiff[2:1]==2'b0;
              assign tailBs1[k]=e_more|expoor && (|{opB[k*8+:7],opB[k*8+7]&~e_eq});
              assign tailBs1_c[k]=e_more|expoor && |opB[k*8+:8];
              assign tailBs1_L[k]=e_more|expoor && (|{opB[k*8+:6],opB[k*8+6+:2]&~{e_eq2,e_eq}});
              assign andtailBs1[k]=~e_more&~expoor || (&{opB[k*8+:7],opB[k*8+7]|e_eq});
              assign andtailBs1_c[k]=~e_more&~expoor || &opB[k*8+:8];
              assign andtailBs1_L[k]=~e_more&~expoor || (&{opB[k*8+:6],opB[k*8+6+:2]|{e_eq2,e_eq}});
             // assign rnbit_s1[k]=e_eq;
          end
          
          //wire [7:0] expdiffeq;
          //assign expdiffeq[k]=expdiff[2:0]==k[2:0];
	      assign opBs=expdiffeq[k] ? {{k{sxor_reg}},opBs1_reg[63:k]} : 64'bz;
	      assign res_rnbit=expdiffeq[k] ? xop1_reg[k+1]^(res_andtail&sxor_reg) : 1'bz;
	      assign res_rnbitL=expdiffeq[k] ? xop1_reg[k]^(res_andtailL&sxor_reg) : 1'bz;
	   //   assign res_rnbitC=expdiffeq[k] ? xop1_reg[k+1] : 1'bz;
          if (k<8) begin 
              pwire e_more,e_eq,e_eq2;
              get_carry #(4) cmp8_mod(~(k[3:0]+4'b1),{1'b0,expdiff_reg[2:0]},1'b1,e_more);
              assign e_eq=expdiff_reg[2:0]==(k+1);
              assign e_eq2=expdiff_reg[2:0]==(k+2);
              assign tailBs[k]=e_more & opBs1_reg[k] & ~e_eq;
              assign tailBs_c[k]=e_more & opBs1_reg[k];
              assign tailBs_L[k]=e_more & opBs1_reg[k] & ~e_eq & ~e_eq2;
              assign andtailBs[k]=~e_more | opBs1_reg[k] | e_eq;
              assign andtailBs_c[k]=~e_more | opBs1_reg[k];
              assign andtailBs_L[k]=~e_more | opBs1_reg[k] | e_eq | e_eq2;
           //   assign rnbit_s[k]=e_eq;
          end
      end

  endgenerate

//  adder2c #(64) fracCmp(fracxfrmA(A[63:0],isDBL,isSingle,isSngDbl),fracxfrmB(~Bx,isDBL,isSingle,isSngDbl),
//      ,,1'b1,1'b1,1'b1,1'b1,moreAFE,,moreAFD,);
  fpuadd_renor renor_mod(
  .A(isDBL_reg ? {resS1_reg[52:0],~opB_reg&&expdiff_reg!=0,10'b0} : resS1_reg),
  .exp(opA_exp_reg),.Ax(~opB_reg&&expdiff_reg!=0&&~isDBL_reg),
  .A_out(renorS),.exp_out(renorE)
  );

  fpuadd_renor renorR_mod(
  .A(isDBL_reg ? {resSR1_reg[52:0],~opB_reg&&expdiff_reg!=0,10'b0} : resSR1_reg),
  .exp(opA_exp_reg),.Ax(~opB_reg&&expdiff_reg!=0&&~isDBL_reg),
  .A_out(renorSR),.exp_out(renorER)
  );

  adder_CSA #(64) mainCSA(opA_reg,opBs,{63'b0,sxor_reg&res_andtail&~res_rnbit},partM0,partM1);
  adder_CSA #(64) mainCSAs(opA_reg,opBs,{62'b0,1'b1,sxor_reg&res_andtail&~res_rnbit},partMs0,partMs1);
  
  adder2c #(64) mainAddNoShift(partM0[63:0],partM1[63:0],resM1,resMR1,1'b0,1'b1,1'b1,1'b1,
    cout64_M1_ns,cout64_MR1_ns,cout53_M1_ns,cout53_MR1_ns);
  adder2c #(64) mainAddShift(partMs0[63:0],partMs1[63:0],resM2,resMR2,1'b0,1'b1,1'b1,1'b1,
    cout64_M2_ns,cout64_MR2_ns,cout53_M2_ns,cout53_MR2_ns);
  
  adder_CSA #(64) suppCSAOneOff (opA,{1'b1,opB[63:1]},{63'b0,opB[0]}, par1Off_A,par1Off_B);
  adder_CSA #(64) suppCSAxx (~opA,~opB,64'b1, part_A,part_B);
  adder_CSA #(64) suppCSAx (opA,opB,64'b1,partt_A,partt_B);
  
  adder2c #(64) suppAddZeroOff(partt_A[63:0],partt_B[63:0],
      resS1,resSR1,1'b0,1'b1,expdiffA==0 && ~alt_en,expdiffA==0&& ~alt_en,cout64_SZ1,cout64_SZR1,cout53_SZ1,cout53_SZR1);
  adder2c #(64) suppAddZeroOffz(part_A[63:0],part_B[63:0],
      resS1,resSR1,1'b0,1'b1,expdiffA==0 && alt_en,expdiffA==0 && alt_en,cout64_Sz1,cout64_SzR1,cout53_Sz1,cout53_SzR1);
  adder2c #(64) suppAddOneOff (par1Off_A[63:0],par1Off_B[63:0],resS1,resSR1,
      1'b0,1'b1,expdiffA!=0,expdiffA!=0,cout64_S1,cout64_SR1,cout53_S1,cout53_SR1);

  adder #(16) expAE_mod({A[64],A[79:65]},~{B[64],B[79:65]},expdiffA,1'b1,~isDBL,moreAE,,,);
  adder #(16) expBE_mod(~{A[64],A[79:65]},{B[64],B[79:65]},expdiffB,1'b1,~isDBL,,,,);
  
  adder #(16) expAD_mod({4'b0,A[64],A[62:52]},~{4'b0,B[80],B[64],B[62:53]},expdiffA,1'b1,isDBL,moreAD,,,);
  adder #(16) expBD_mod(~{4'b0,A[64],A[62:52]},{4'b0,B[80],A[64],B[62:53]},expdiffB,1'b1,isDBL,,,,);
  
  adder_inc #(16) aExpInc(opA_exp_reg,opA_exp_inc,1'b1,);
  adder #(16) aExpDec(opA_exp_reg,16'hffff,opA_exp_dec,1'b0,1'b1,,,,);
  //verilator lint_off COMBDLY 
  always @(*) begin
      if (rst) begin
          expdiffeq<=8'b1;
          opA_exp_reg<=16'b0;
          sxor_reg<=1'b0;
          expdiff_reg<=16'b0;
          expoor_reg<=1'b0;
          opBs1_reg<=64'b0;
          opA_reg<=64'b0;
          resS1_reg<=64'b0;
          resSR1_reg<=64'b0;
          xop1_reg<=10'b0;
          andtailBs1_reg<=1'b0;
          andtailBs1_c_reg<=1'b0;
          andtailBs1_L_reg<=1'b0;
          tailBs1_reg<=1'b0;
          tailBs1_c_reg<=1'b0;
          tailBs1_L_reg<=1'b0;
          isrnd_zero<=1'b1;
          isrnd_even<=1'b0;
	  isrnd_plus<=1'b0;
          isDBL_reg<=1'b1;
          altpath_reg<=1'b0;
          rndpath_reg<=rndpath;
          A_s1_reg<=1'b0;
          opB_reg<=1'b0;
          spec_snan_reg<=1'b0;
	  spec_qnan_reg<=1'b0;
	  spec_pinf_reg<=1'b0;
	  spec_ninf_reg<=1'b0;
	  spec_A_reg<=1'b0;
	  spec_B_reg<=1'b0;
	  spec_any<=1'b0;
	  A_reg<=81'b0;
	  B_reg<=81'b0;
	  en_reg<=1'b1;
          exp_inc_oor_reg<=1'b0;
	  exp_inc_oor_IEEE_reg<=1'b0;
	  exp_dec_non_denor_reg<=1'b0;
	  exp_dec_non_denor_IEEE_reg<=1'b0;
      end else begin
	  for (m=0;m<8;m=m+1) expdiffeq[m]<=expdiff[2:0]==m[2:0] && ~expoor;
          sxor_reg<=sxor;
          expdiff_reg<=expdiff;
          opA_exp_reg<=opA_exp;
          expoor_reg<=expoor;
          opBs1_reg<=opBs1;
          opA_reg<=opA;
          resS1_reg<=resS1;
          resSR1_reg<=resSR1;
          xop1_reg<=xop1;
          andtailBs1_reg<=&andtailBs1;
          andtailBs1_c_reg<=&andtailBs1_c;
          andtailBs1_L_reg<=&andtailBs1_L;
          tailBs1_reg<=|tailBs1;
          tailBs1_c_reg<=|tailBs1_c;
          tailBs1_L_reg<=|tailBs1_L;
          case(rmode)
            ROUND_TRUNC: begin isrnd_even<=1'b0; isrnd_zero<=1'b1; isrnd_plus<=1'b0; end
            ROUND_ROUND: begin isrnd_even<=1'b0; isrnd_zero<=1'b0; isrnd_plus<=1'b0; end
            ROUND_EVEN : begin isrnd_even<=1'b1; isrnd_zero<=1'b0; isrnd_plus<=1'b0; end
            ROUND_PLUS : begin isrnd_even<=1'b0; isrnd_zero<=A_s2; isrnd_plus<=1'b0; end
            ROUND_MINUS: begin isrnd_even<=1'b0; isrnd_zero<=~A_s2; isrnd_plus<=1'b0; end
            ROUND_UP   : begin isrnd_even<=1'b0; isrnd_zero<=A_s2; isrnd_plus<=~A_s2; end
            ROUND_DOWN : begin isrnd_even<=1'b0; isrnd_zero<=~A_s2; isrnd_plus<=A_s2; end
          endcase
          isDBL_reg<=isDBL;
          altpath_reg<=altpath;
          rndpath_reg<=rndpath;
          A_s1_reg<=(expdiffA==0 && sxor && alt_en) ? B_s1 : A_s1;
          opB_reg<=opB[0];
          spec_snan_reg<=spec_snan;
	  spec_qnan_reg<=spec_qnan;
	  spec_pinf_reg<=spec_pinf;
	  spec_ninf_reg<=spec_ninf;
	  spec_A_reg<=spec_A;
	  spec_B_reg<=spec_B;
          spec_any<=|{spec_snan,spec_qnan,spec_pinf,spec_ninf,spec_A,spec_B,spec_logic};
	  spec_logic_reg<=spec_logic;
          A_reg<=copyA ? {A_alt[64],16'b0,A_alt[63:0]} : A;
          B_reg<=B;
	  en_reg<=en;
          exp_inc_oor_reg<=exp_inc_oor;
	  exp_inc_oor_IEEE_reg<=exp_inc_oor_IEEE;
	  exp_dec_non_denor_reg<=exp_dec_non_denor;
	  exp_dec_non_denor_IEEE_reg<=exp_dec_non_denor_IEEE;
      end
  end
  //verilator lint_on COMBDLY
endmodule


module fpuadd_renor(
  A,exp,Ax,
  A_out,exp_out
  );

  input pwire [64:0] A;
  input pwire [15:0] exp;
  input pwire Ax;
  output pwire [64:0] A_out;
  output pwire [15:0] exp_out;

  pwire [64:0] A_first;
  pwire [7:0] A_first8;
  pwire A_has,A_has8;
  pwire [64:0] A_medE;
  pwire [64:0] A_outE;
  pwire [2:0] xadde1_c;
  pwire [2:0] xadde1_nc;
  pwire xaddeCO_c;
  pwire xaddeCO_nc;
  pwire [7:0][12:0] adde8_c;
  pwire [7:0][12:0] adde8_nc;
  pwire [7:0][2:0] adde1_c;
  pwire [7:0][2:0] adde1_nc;
  pwire [7:0] addeCO_nc;
  pwire [7:0] addeCO_c;
  pwire [15:0] exp_outE;
  pwire [7:0] A_firstE;

  bit_find_last_bit #(64) first_mod(A,A_first,A_has);
  bit_find_last_bit #(8) first8_mod({|A[63:56],|A[55:48],|A[47:40],|A[39:32],
      |A[31:24],|A[23:16],|A[15:8],|A[7:0]},A_first8,A_has8);

  generate
      genvar t,p;
      for (t=0;t<8;t=t+1) begin
	  if ((7-t)>0) assign A_medE=A_first8[t] ? {A[63-8*(7-t):0],Ax,{8*(7-t)-1{1'b0}}} : 64'bz;
	  else assign A_medE=A_first8[t] ? A : 64'bz;
	  assign A_firstE=A_first8 [t] ? A_first[8*t+:8] : 8'bz;
	  
      if ((7-t)>1) assign A_outE=A_firstE[t] ? {A_medE[63-(7-t):0],Ax,{(7-t)-1{1'b0}}} : 64'bz;
      else if ((7-t)==1) assign A_outE=A_firstE[t] ? {A_medE[63-(7-t):0],Ax} : 64'bz;
	  else assign A_outE=A_firstE[t] ? A_medE : 64'bz;

          adder2c #(13) upperAdd_mod(exp[15:3],~t[12:0],adde8_nc[t],adde8_c[t],1'b0,1'b1,1'b1,1'b1,,,,);
          adder2c #(3)  lowerAdd_mod(exp[2:0],~t[2:0],adde1_nc[t],adde1_c[t],1'b0,1'b1,1'b1,1'b1,
            addeCO_nc[t],addeCO_c[t],,);
          
          assign xadde1_nc=A_firstE[t] ? adde1_nc[7-t] : 3'bz;
          assign xadde1_c=A_firstE[t] ? adde1_c[7-t] : 3'bz;
          assign xaddeCO_nc=A_firstE[t] ? addeCO_nc[7-t] : 1'bz;
          assign xaddeCO_c=A_firstE[t] ? addeCO_c[7-t] : 1'bz;
        
          assign exp_outE=(A_first8[7-t] & xaddeCO_c) ?  {adde8_c[t],xadde1_c} : 16'bz;
          assign exp_outE=(A_first8[7-t] & ~xaddeCO_c) ?  {adde8_nc[t],xadde1_c} : 16'bz;
      end
          assign xadde1_nc=A_has ?  3'bz : 3'b0;
          assign xadde1_c=A_has ? 3'bz : 3'b0;
          assign xaddeCO_nc=A_has ? 1'bz : 1'b0;
          assign xaddeCO_c=A_has ? 1'bz : 1'b0;
  endgenerate

/*  assign xadde1_nc[t]=A_has ?  3'bz : 3'b0;
  assign xadde1_c[t]=A_has ? 3'bz : 3'b0;
  assign xaddeCO_nc[t]=A_has ? 1'bz : 1'b0;
  assign xaddeCO_c[t]=A_has ? 1'bz : 1'b0;*/
  assign exp_outE=A_has ?  16'bz : 16'b0;
  assign A_outE=A_has ? 64'bz : {Ax,63'b0};
  assign A_medE=A_has ? 64'bz : 64'b0;
  assign A_firstE=A_has ? 8'bz : 8'b0;
  assign A_out=A_outE;
  assign exp_out=(A_has | Ax) ? exp_outE : 16'b0;
endmodule


