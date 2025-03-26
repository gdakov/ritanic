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

module fadds(
  clk,
  rst,
  A,
  B,
  pook_inX,
  pook,
  pook_op_bit,
  isSub,
  isRSub,
  fpcsr,
  raise,
  rmode,
  en,
  copyA,
  logic_en,
  logic_sel,
  res
  );
  localparam ROUND_TRUNC=0;
  localparam ROUND_ROUND=1;
  localparam ROUND_EVEN =2;
  localparam ROUND_PLUS =3;
  localparam ROUND_MINUS=4;
  localparam ROUND_UP   =5;
  localparam ROUND_DOWN =6;

  input clk;
  input rst;
  input [32:0] A;
  input [32:0] B;
  input pook_inX;
  output pook;
  input pook_op_bit;
  input isSub;
  input isRSub;
  input [31:0] fpcsr;
  output pwire [10:0] raise;
  input [2:0] rmode;
  input en;
  input copyA;
  input logic_en;
  input [1:0] logic_sel;
  output pwire [32:0] res;
//need to set bit 53 to one if isDBL; not yet done
//need to clear/set bits 63-54 if isDBL and corresponging conditions
//if no isDBL, set one op low bits to 0, other to one depening on rounding
//width

  pwire [32:0] res_X;

  assign res=res_X;

  pwire sxor;
  reg sxor_reg;
  pwire a_more;
  pwire [23:0] opA;
  pwire [23:0] opB;
  pwire moreAD,moreAE;
  pwire [8:0] expdiffA;
  pwire [8:0] expdiffB;
  pwire [8:0] expdiff;
  reg  [8:0] expdiff_reg;
  pwire [23:0] opBs1;
  pwire [23:0] opBs;
  reg [23:0] opBs1_reg;
  reg [23:0] opA_reg;
//  reg [64:0] opB_reg;
  pwire [24:0] partM0;
  pwire [24:0] partM1;
  pwire [24:0] partMs0;
  pwire [24:0] partMs1;
  pwire [23:0] resS1;
  pwire [23:0] resSR1;
  reg [23:0] resS1_reg;
  reg [23:0] resSR1_reg;
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
  pwire [23:0] renorS;
  pwire [8:0] renorE;
  pwire [23:0] renorSR;
  pwire [8:0] renorER;
  pwire [2:0] andtailBs1;
  pwire [7:0] andtailBs;
  pwire [2:0] andtailBs1_c;
  pwire [7:0] andtailBs_c;
  pwire [2:0] andtailBs1_L;
  pwire [7:0] andtailBs_L;
  pwire [2:0] tailBs1;
  pwire [7:0] tailBs;
  pwire [2:0] tailBs1_c;
  pwire [7:0] tailBs_c;
  pwire [2:0] tailBs1_L;
  pwire [7:0] tailBs_L;
  reg andtailBs1_reg;
  reg andtailBs1_c_reg;
  reg andtailBs1_L_reg;
  reg tailBs1_reg;
  reg tailBs1_c_reg;
  reg tailBs1_L_reg;
  reg isDBL_reg;
  pwire [23:0] resM1;
  pwire [23:0] resMR1;
  pwire [23:0] resM2;
  pwire [23:0] resMR2;
  pwire cout64_M1_ns,cout64_MR1_ns,cout53_M1_ns,cout53_MR1_ns;
  pwire cout64_M2_ns,cout64_MR2_ns,cout53_M2_ns,cout53_MR2_ns;
  pwire cout64_SZ1,cout64_SZR1,cout53_SZ1,cout53_SZR1;
  pwire cout64_Sz1,cout64_SzR1,cout53_Sz1,cout53_SzR1;
  pwire cout64_S1,cout64_SR1,cout53_S1,cout53_SR1;
  pwire [24:0] par1Off_A;
  pwire [24:0] par1Off_B;
  pwire [24:0] part_A;
  pwire [24:0] part_B;
  pwire [24:0] partt_A;
  pwire [24:0] partt_B;
  reg [7:0] expdiffeq;
  pwire [9:0] xop1;
  reg [9:0] xop1_reg;
  reg isrnd_zero,isrnd_even,isrnd_plus;
  pwire [32:0] resX;
  pwire main_lo,main_ulo,Smain_lo,Smain_ulo;
  pwire [8:0] opA_exp;
  pwire [8:0] opA_exp_inc;
  pwire [8:0] opA_exp_dec;
  reg [8:0] opA_exp_reg;
  pwire altpath;
  reg altpath_reg;
  pwire rndpath;
  reg rndpath_reg;
  reg opB_reg;
  pwire [8:0] A_exp;
  pwire [8:0] B_exp;
  pwire A_zero,A_infty,A_nan;
  pwire B_zero,B_infty,B_nan;
  pwire spec_snan,spec_qnan,spec_pinf,spec_ninf,spec_A,spec_B;
  reg spec_snan_reg,spec_qnan_reg,spec_pinf_reg,spec_ninf_reg,spec_A_reg,spec_B_reg;
  pwire [3:0] spec_logic;
  reg [3:0] spec_logic_reg;
  reg spec_any;
  pwire A_h,B_h;
  pwire [32:0] res_spec;
  reg [32:0] A_reg;
  reg [32:0] B_reg;
  pwire A_s2;
  reg en_reg;
  integer m;
  pwire renor_any,exp_dec_non_denor_IEEE_0,exp_dec_non_denor_IEEE_1,exp_dec_non_denor,exp_inc_oor_IEEE,exp_inc_oor,
	  exp_dec_non_denor_IEEE;
  pwire [8:0] exp_min_IEEE;
  pwire [8:0] exp_max_IEEE;
  pwire [8:0] exp_min_kludge;
  pwire [8:0] exp_max;
  reg exp_inc_oor_reg,exp_inc_oor_IEEE_reg,exp_dec_non_denor_reg,exp_dec_non_denor_IEEE_reg;
  pwire [3:0] xpon;
  pwire invExcpt;
  pwire pook;

  pwire pook_excpt;
  
  assign pook_excpt=pook_op_bit && ~|opB[23:0];

  assign pook=B_zero;

  assign pook_in=pook_inX && expdiff==0 && ~sxor && pook_inX;
 

  assign A_exp={A[30],A[32],A[29:23]};
  assign B_exp={B[30],B[32],B[29:23]};

  //assign A_h={|A[22:0]}; 
  //assign B_h={|B[22:0]}; 

  assign A_zero=A_exp==9'b0;
  assign A_infty=A_exp==9'h1fe;
  assign A_nan=A_exp==9'h1ff;
  
  assign B_zero=B_exp==9'b0;
  assign B_infty=B_exp==9'h1fe;
  assign B_nan=B_exp==9'h1ff;

  assign spec_snan=(A_nan & ~B_infty & invExcpt || B_nan & ~A_infty & invExcpt || A_infty & B_infty & sxor & invExcpt) &~copyA &~logic_en;  
  assign spec_qnan=(A_nan & ~B_infty & ~invExcpt || B_nan & ~A_infty & ~invExcpt || A_infty & B_infty & sxor & ~invExcpt) &~copyA&~logic_en;
  assign spec_pinf=((A_infty && ~A_s && ~B_infty|~B_s) || (B_infty && ~B_s && ~A_infty|~A_s)) &~copyA&~logic_en;   
  assign spec_ninf=((A_infty && A_s && ~B_infty|B_s) || (B_infty && B_s && ~A_infty|A_s))&~copyA&~logic_en;
  assign spec_A=(B_zero && ~A_zero|~A_s|B_s && ~A_nan && ~A_infty && ~logic_en)|copyA;
  assign spec_B=(A_zero && ~B_zero|(~B_s&A_s) && ~B_nan && ~B_infty)&~copyA & ~logic_en;
  assign spec_logic[0]=logic_en && logic_sel==2'd0 && ~copyA;
  assign spec_logic[1]=logic_en && logic_sel==2'd1 && ~copyA;
  assign spec_logic[2]=logic_en && logic_sel==2'd2 && ~copyA;
  assign spec_logic[3]=logic_en && logic_sel==2'd3 && ~copyA;
 
  assign opA=a_more ?  {1'b1,A[22:0]} : 24'bz;
  assign opB=(sxor & a_more) ?  ~{1'b1,B[22:0]} : 24'bz;
  assign opA=(~a_more) ?  {1'b1,B[22:0]} : 24'bz;
  assign opB=(sxor & ~a_more) ?  ~{1'b1,A[22:0]} : 24'bz;
  assign opB=(~sxor & a_more) ?  {1'b1,B[22:0]} : 24'bz;
  assign opB=(~sxor & ~a_more) ?  {1'b1,A[22:0]} : 24'bz;
  
  assign opA_exp=a_more ? {A[32],A[30:23]} : 9'bz;
  assign opA_exp=(~a_more) ? {B[32],B[30:23]} : 9'bz;
  
  assign expdiff=a_more ? expdiffA : expdiffB;
  
//  assign Bx=is_alt ? B_alt : B;

  assign opBs1=expoor ? {24{sxor_reg}} : 24'bz;
  assign opBs=expoor_reg ? {24{sxor_reg}} : 24'bz;
  assign res_rnbit=expoor_reg ? xop1_reg[1]^(res_andtail&sxor_reg) : 1'bz;
//  assign res_rnbitC=expoor_reg ?  : 1'bz;
  assign res_rnbitL=expoor_reg ? xop1_reg[0]^(res_andtailL&sxor_reg) : 1'bz;
  assign xop1[1:0]=(expoor && expdiff[8:1]!=8'd12) ? {2{sxor}} : 2'bz;
  
  assign a_more=moreAD;

  assign sxor=A[31]^B[31]^isSub;
  assign A_s=A[31]^(isRSub);
  assign B_s=B[31]^(isSub&~isRSub);
  assign A_s1=a_more ? A_s : B_s;
  assign B_s1=a_more ? B_s : A_s;
  assign A_s2=(a_more & ~(expdiffA==0 && alt_en && sxor)) ? A_s : B_s;

  assign alt_en=~cout64_SZ1;

  assign resS_rnbit=(expdiffA!=0) ? ~opB[0] : 1'b0;
  assign altpath=(expdiffA==0 || expdiffA==1 || expdiffB==1) && sxor;
  assign rndpath=(expdiffA==1 || expdiffB==1) && sxor;
  
  assign res_X[22:0]=(renor_simple & ~spec_any & en_reg) ? renorS[22:0] : 23'bz;
  assign {res_X[32],res_X[30:23]}=(renor_simple & ~spec_any & en_reg) ? renorE : 9'bz;
  
  assign res_X[22:0]=(renor_round & ~spec_any & en_reg) ? renorSR[22:0] : 23'bz;
  assign {res_X[32],res_X[30:23]}=(renor_round & en_reg & ~spec_any) ? renorER : 9'bz;

  assign res_X[31]=(renor_simple & en_reg & ~spec_any) ? A_s1_reg : 1'bz;
  assign res_X[31]=(renor_round & en_reg & ~spec_any) ? A_s1_reg : 1'bz;
  

  assign res_X=(~renor_simple && ~renor_round &&  isDBL_reg && ~spec_any && en_reg) ? resX : 33'bz;

  assign res_X=(spec_any & en_reg) ? res_spec[32:0] : 33'bz;  

  assign res_spec=spec_A_reg ? A_reg : 33'bz;
  assign res_spec=spec_B_reg ? B_reg : 33'bz;
  assign res_spec=spec_snan_reg ? {10'h3ff,23'b1} : 33'bz;
  assign res_spec=spec_qnan_reg ? {10'h3ff,23'h400001} : 33'bz;
  assign res_spec=spec_pinf_reg ? {10'h2fe,23'b0} : 33'bz;
  assign res_spec=spec_ninf_reg ? {10'h3fe,23'b0} : 33'bz;
  assign res_spec=spec_logic_reg[0] ? {A_reg[32]|B_reg[32],A_reg[31:0]&B_reg[31:0]} : 33'bz;
  assign res_spec=spec_logic_reg[1] ? {A_reg[32]&B_reg[32],A_reg[31:0]|B_reg[31:0]} : 33'bz;
  assign res_spec=spec_logic_reg[2] ? {A_reg[32]^B_reg[32],A_reg[31:0]^B_reg[31:0]} : 33'bz;
  assign res_spec=spec_logic_reg[3] ? {A_reg[32]|~B_reg[32],A_reg[31:0]&~B_reg[31:0]} : 33'bz;
  assign res_spec=spec_any ?  33'bz :  33'b0;

  assign renor_round=rndpath_reg && !(opB_reg || isrnd_zero ||(isrnd_even && resSR1_reg[0])) &&
  (resS1_reg[23]);
  
  assign renor_simple=altpath_reg && ~renor_round;
  
  assign expoor=expdiff[8:5]!=4'b0 || expdiff[8:3]==6'b000011;//&& expdiff!=16'h40; 

  assign resX[31]=A_s1_reg;
  
  get_carry #(9) cmp1_mod(opA_exp,~exp_max,1'b1,exp_inc_oor);
  get_carry #(9) cmp2_mod(opA_exp,~exp_max_IEEE,1'b1,exp_inc_oor_IEEE);
  get_carry #(9) cmp3_mod(opA_exp,~exp_min_IEEE,1'b1,exp_dec_non_denor_IEEE_0);
  get_carry #(9) cmp4_mod(opA_exp,~exp_min_kludge,1'b1,exp_dec_non_denor_IEEE_1);
  assign exp_dec_non_denor=opA_exp[8:1]!=0;
  assign exp_dec_non_denor_IEEE=altpath ? exp_dec_non_denor_IEEE_1 : exp_dec_non_denor_IEEE_0;

  assign exp_max=9'h1fd;
  assign exp_max_IEEE=9'h17e;
  assign exp_min_IEEE=9'h81;
  assign exp_min_kludge=9'h99;

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
  assign raise[`csrfpu_denor_produce_excpt]=pook_excpt;

  assign xpon=main_simple & ~renor_round & ~renor_simple ? {res_rnbit,res_tail,2'b00} : 4'bz;
  assign xpon=main_round & ~renor_round & ~renor_simple  ? {res_rnbit,res_tail,2'b00} : 4'bz;
  assign xpon=main_simpleC & ~renor_round & ~renor_simple  ? {res_rnbitC,res_tailC,2'b10} : 4'bz;
  assign xpon=main_roundC & ~renor_round & ~renor_simple  ? {res_rnbitC,res_tailC,2'b10} : 4'bz;
  assign xpon=main_simpleRC & ~renor_round & ~renor_simple  ? {res_rnbit,res_tail,2'b10} : 4'bz;
  assign xpon=main_simpleL & ~renor_round & ~renor_simple  ? {res_rnbitL,res_tailL,2'b01} : 4'bz;
  assign xpon=main_roundL & ~renor_round & ~renor_simple  ? {res_rnbitL,res_tailL,2'b00} : 4'bz;
  assign xpon=renor_round | renor_simple ? {renor_round, 3'b001} : 4'bz; 
    
  
  assign resX[22:0]=main_simple ? resM1[22:0] : 23'bz;
  assign resX[22:0]=main_round ? resMR1[22:0] : 23'bz;
  assign resX[22:0]=main_simpleC ? resM1[23:1] : 23'bz;
  assign resX[22:0]=main_roundC ? resM2[23:1] : 23'bz;
  assign resX[22:0]=main_simpleRC ? resMR1[23:1] : 23'bz;
  assign resX[22:0]=main_simpleL ? {resM1[21:0],res_rnbit^Smain_subroundL} : 23'bz;
  assign resX[22:0]=main_roundL ? {resMR1[21:0],1'b0} : 23'bz;
  
  assign {resX[30],resX[32],resX[29:23]}=main_simple ? {opA_exp_reg[8:0]} : 9'bz;
  assign {resX[30],resX[32],resX[29:23]}=main_round ? {opA_exp_reg[8:0]} : 9'bz;
  assign {resX[30],resX[32],resX[29:23]}=main_simpleC ? {opA_exp_inc[8:0]} : 9'bz;
  assign {resX[30],resX[32],resX[29:23]}=main_roundC ? {opA_exp_inc[8:0]} : 9'bz;
  assign {resX[30],resX[32],resX[29:23]}=main_simpleRC ? {opA_exp_inc[8:0]} : 9'bz;
  assign {resX[30],resX[32],resX[29:23]}=main_simpleL ? {opA_exp_dec[8:0]} : 9'bz;
  assign {resX[30],resX[32],resX[29:23]}=main_roundL ? {opA_exp_dec[8:0]} : 9'bz;
  
  assign main_lo=~resM1[23] && ~(cout64_M1_ns^partM1[24]^sxor_reg);
  assign main_ulo=main_lo && resMR1[23];
  
  assign main_simple=~main_lo && (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])) && 
    ~(cout64_M1_ns^partM1[24]^sxor_reg);
  assign main_round=(~main_lo && !(~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero ||(isrnd_even && ~res_tail&&resMR1[0])) && ~(cout64_MR1_ns^partM1[24]^sxor_reg)) ||
    (main_ulo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)));
  assign main_roundC=~main_lo && !(~res_rnbitC & ~(res_tailC & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailC&&resM2[1])) && (cout64_M1_ns^partM1[24]^sxor_reg) &&
   (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0]));
  assign main_simpleC=~main_lo && ((~res_rnbitC & ~(res_tailC & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailC&&resM2[1]) ) && (cout64_M1_ns^partM1[24]^sxor_reg) &&
    (~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])));
  assign main_simpleRC=~main_lo && (!(~res_rnbit & ~(res_tail & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tail&&resMR1[0])) && (cout64_MR1_ns^partM1[24]^sxor_reg));
  assign main_simpleL=main_lo && ((~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) || ~res_rnbit);
  assign main_roundL=main_lo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) && ~main_ulo && res_rnbit;
  assign main_subroundL=main_lo && !(~res_rnbitL & ~(res_tailL & isrnd_plus) || isrnd_zero || (isrnd_even && ~res_tailL&&~res_rnbit)) && ~main_ulo;//|~res_rnbitL;
  
  
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
          if (|k && k<3) assign {opBs1,xop1[1:0]}=(expdiff[5:3]==k && ~expoor) ? {{k*8{sxor}},opB[23:k*8-2]} : 26'bz;
          else if (!|k) begin
              assign opBs1=(expdiff[5:3]==k && ~expoor) ? {{k*8{sxor}},opB[23:k*8]} : 24'bz;
              assign xop1[1:0]=(expdiff[5:3]==3'b0 && ~expoor) ? 2'b0 : 2'bz;
              assign xop1[1:0]=(expdiff==9'h18) ? opB[23:22] : 2'bz;
              assign xop1[1:0]=(expdiff==9'h19) ? {sxor,opB[23]} : 2'bz;
          end
          if (k<3) begin 
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
	      assign opBs=expdiffeq[k] ? {{k{sxor_reg}},opBs1_reg[23:k]} : 24'bz;
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
  fpuadd_renorS renor_mod(
  .A(resS1_reg),
  .exp(opA_exp_reg),.Ax(~opB_reg&&expdiff_reg!=0),
  .A_out(renorS),.exp_out(renorE)
  );

  fpuadd_renorS renorR_mod(
  .A(resSR1_reg),
  .exp(opA_exp_reg),.Ax(~opB_reg&&expdiff_reg!=0),
  .A_out(renorSR),.exp_out(renorER)
  );

  adder_CSA #(24) mainCSA(opA_reg,opBs,{23'b0,sxor_reg&res_andtail&~res_rnbit},partM0,partM1);
  adder_CSA #(24) mainCSAs(opA_reg,opBs,{22'b0,1'b1,sxor_reg&res_andtail&~res_rnbit},partMs0,partMs1);
  
  adder2c #(24) mainAddNoShift(partM0[23:0],partM1[23:0],resM1,resMR1,1'b0,1'b1,1'b1,1'b1,
    cout64_M1_ns,cout64_MR1_ns,,);
  adder2c #(24) mainAddShift(partMs0[23:0],partMs1[23:0],resM2,resMR2,1'b0,1'b1,1'b1,1'b1,
    cout64_M2_ns,cout64_MR2_ns,,);
  
  adder_CSA #(24) suppCSAOneOff (opA,{1'b1,opB[23:1]},{23'b0,opB[0]}, par1Off_A,par1Off_B);
  adder_CSA #(24) suppCSAxx (~opA,~opB,24'b1, part_A,part_B);
  adder_CSA #(24) suppCSAx (opA,opB,24'b1,partt_A,partt_B);
  
  adder2c #(24) suppAddZeroOff(partt_A[23:0],partt_B[23:0],
      resS1,resSR1,1'b0,1'b1,expdiffA==0 && ~alt_en,expdiffA==0&& ~alt_en,cout64_SZ1,cout64_SZR1,,);
  adder2c #(24) suppAddZeroOffz(part_A[23:0],part_B[23:0],
      resS1,resSR1,1'b0,1'b1,expdiffA==0 && alt_en,expdiffA==0 && alt_en,cout64_Sz1,cout64_SzR1,,);
  adder2c #(24) suppAddOneOff (par1Off_A[23:0],par1Off_B[23:0],resS1,resSR1,
      1'b0,1'b1,expdiffA!=0,expdiffA!=0,cout64_S1,cout64_SR1,,);

  
  adder #(9) expAD_mod({A[32],A[30:23]},~{B[32],B[30:23]},expdiffA,1'b1,1'b1,moreAD,,,);
  adder #(9) expBD_mod(~{A[32],A[30:23]},{B[32],B[30:23]},expdiffB,1'b1,1'b1,,,,);
  
  adder_inc #(9) aExpInc(opA_exp_reg,opA_exp_inc,1'b1,);
  adder #(9) aExpDec(opA_exp_reg,9'h1ff,opA_exp_dec,1'b0,1'b1,,,,);
 //verilator lint_off COMBDLY 
  always @(*) begin
      if (rst) begin
          expdiffeq<=8'b1;
          opA_exp_reg<=9'b0;
          sxor_reg<=1'b0;
          expdiff_reg<=9'b0;
          expoor_reg<=1'b0;
          opBs1_reg<=24'b0;
          opA_reg<=24'b0;
          resS1_reg<=24'b0;
          resSR1_reg<=24'b0;
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
          //isDBL_reg<=1'b1;
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
	  spec_logic_reg<=4'b0;
	  spec_any<=1'b0;
	  A_reg<=33'b0;
	  B_reg<=33'b0;
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
        //  isDBL_reg<=isDBL;
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
          A_reg<=A;
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


module fpuadd_renorS(
  A,exp,Ax,
  A_out,exp_out
  );

  input [23:0] A;
  input [8:0] exp;
  input Ax;
  output pwire [23:0] A_out;
  output pwire [8:0] exp_out;

  pwire [23:0] A_first;
  pwire [2:0] A_first8;
  pwire A_has,A_has8;
  pwire [23:0] A_medE;
  pwire [23:0] A_outE;
  pwire [2:0] xadde1_c;
  pwire [2:0] xadde1_nc;
  pwire xaddeCO_c;
  pwire xaddeCO_nc;
  pwire [2:0][5:0] adde8_c;
  pwire [2:0][5:0] adde8_nc;
  pwire [7:0][2:0] adde1_c;
  pwire [7:0][2:0] adde1_nc;
  pwire [7:0] addeCO_nc;
  pwire [7:0] addeCO_c;
  pwire [8:0] exp_outE;
  pwire [7:0] A_firstE;//??

  bit_find_last_bit #(24) first_mod(A,A_first,A_has);
  bit_find_last_bit #(3) first8_mod({|A[23:16],|A[15:8],|A[7:0]},A_first8,A_has8);

  generate
      genvar t,p;
      for (t=0;t<8;t=t+1) begin
	  if (t<3) begin
	      if ((2-t)>0) assign A_medE=A_first8[t] ? {A[23-8*(2-t):0],Ax,{8*(2-t)-1{1'b0}}} : 24'bz;
	      else assign A_medE=A_first8[t] ? A : 24'bz;
	      assign A_firstE=A_first8 [t] ? A_first[8*t+:8] : 8'bz;
              adder2c #(6) upperAdd_mod(exp[8:3],~t[5:0],adde8_nc[t],adde8_c[t],1'b0,1'b1,1'b1,1'b1,,,,);
	  end
      if ((7-t)>1) assign A_outE=A_firstE[t] ? {A_medE[23-(7-t):0],Ax,{(7-t)-1{1'b0}}} : 24'bz;
      else if ((7-t)==1) assign A_outE=A_firstE[t] ? {A_medE[23-(7-t):0],Ax} : 24'bz;
          else assign A_outE=A_firstE[t] ? A_medE : 24'bz;

          adder2c #(3)  lowerAdd_mod(exp[2:0],~t[2:0],adde1_nc[t],adde1_c[t],1'b0,1'b1,1'b1,1'b1,
            addeCO_nc[t],addeCO_c[t],,);
          
          assign xadde1_nc=A_firstE[t] ? adde1_nc[7-t] : 3'bz;
          assign xadde1_c=A_firstE[t] ? adde1_c[7-t] : 3'bz;
          assign xaddeCO_nc=A_firstE[t] ? addeCO_nc[7-t] : 1'bz;
          assign xaddeCO_c=A_firstE[t] ? addeCO_c[7-t] : 1'bz;
        
	  if (t<3) begin
	      assign exp_outE=A_first8[2-t] & xaddeCO_c ?  {adde8_c[t],xadde1_c} : 9'bz;
              assign exp_outE=A_first8[2-t] & ~xaddeCO_c ?  {adde8_nc[t],xadde1_c} : 9'bz;
          end
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
  assign exp_outE=A_has ?  9'bz : 9'b0;
  assign A_outE=A_has ? 24'bz : {Ax,23'b0};
  assign A_medE=A_has ? 24'bz : 24'b0;
  assign A_firstE=A_has ? 8'bz : 8'b0;
  assign A_out=A_outE;
  assign exp_out=(A_has | Ax) ? exp_outE : 9'b0;
endmodule


