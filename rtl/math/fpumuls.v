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

module fpumuls(clk,rst,A,B,copyA,en,rmode,res,raise,fpcsr);
  localparam [8:0] BIAS=9'hff;
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
  input copyA;
  input en;
  input [2:0] rmode;
  output pwire [32:0] res;
  output pwire [10:0] raise;
  input [31:0] fpcsr;
  
  
  pwire [32:0] res_X;

  assign res=res_X;
  //reg [80:0] A_reg;
 // reg [80:0] B_reg;
  pwire [47:0] part0;
  pwire [47:0] part1;

  pwire [8:0] expA;
  pwire [8:0] expB;
  pwire [9:0] exp_exp;
  pwire [9:0] exp_exp1;
  pwire [9:0] expart0;
  pwire [9:0] expart1;
  pwire sgn;
  reg sgn_reg,sgn_reg2,sgn_reg3;
  reg [9:0] exp_max;
  reg [9:0] exp_max_IEEE;
  reg [9:0] exp_denor;
  reg [9:0] exp_denor_IEEE;
  reg [9:0] exp_exp_reg;
  reg [9:0] exp_exp1_reg;
  reg [9:0] exp_exp_reg2;
  reg [9:0] exp_exp1_reg2;
  reg [9:0] exp_exp_reg3;
  reg [9:0] exp_exp1_reg3;
  reg [47:0] prod_reg;
  pwire DBL_rnbit0,DBL_tail0,DBL_rnflip0;
  pwire DBL_rnbit1,DBL_tail1;
  pwire DBL_rnd0,DBL_rnd1;
  pwire [22:-1] rndbit_dbl={22'b0,prod_reg[47],~prod_reg[47]};
  pwire [9:0] exp_exp_d;
  pwire [9:0] exp_exp1_d;
  reg [31:0] fpcsr_reg;
  pwire [4:0] expon;
  pwire exp_oor,exp1_oor,exp_oor_IEEE,exp1_oor_IEEE;
  pwire exp_non_denor_IEEE,exp1_non_denor_IEEE;
  reg exp_oor_reg,exp1_oor_reg,exp_oor_IEEE_reg,exp1_oor_IEEE_reg;
  reg exp_non_denor_IEEE_reg,exp1_non_denor_IEEE_reg;
  reg exp_oor_reg2,exp1_oor_reg2,exp_oor_IEEE_reg2,exp1_oor_IEEE_reg2;
  reg exp_non_denor_IEEE_reg2,exp1_non_denor_IEEE_reg2;

  reg [32:0] A_reg;
  reg [32:0] A_reg2;
  reg [32:0] A_reg3;
  
  pwire A_h; 
  pwire B_h; 

  pwire A_zero,A_infty,A_nan;
  
  pwire B_zero,B_infty,B_nan;

  pwire spec_zero,spec_infty,spec_nan,spec_snan,spec_qnan,spec_A;
  reg spec_zero_reg,spec_infty_reg,spec_snan_reg,spec_qnan_reg,spec_A_reg;
  reg spec_zero_reg2,spec_infty_reg2,spec_snan_reg2,spec_qnan_reg2,spec_A_reg2;
  reg spec_zero_reg3,spec_infty_reg3,spec_snan_reg3,spec_qnan_reg3,spec_A_reg3;
  reg spec_any;
  pwire [32:0] res_spec;
  reg isrnd_zero,isrnd_plus,isrnd_even;
  pwire [47:0] prod;
  pwire dummy1_1;
  pwire dummy1_2;
  pwire dummy1_3;
  pwire dummy1_4;
  reg en_reg,en_reg2,en_reg3;
//  reg or1,and1;
 //tbd: enable bit 
`ifndef simulation
  fpucadd_compress_24 compr_mod(clk,{1'b1,A[22:0]},{1'b1,B[22:0]},
    part0,part1);
  adder #(48) prodAdd_mod(part0,part1,prod,1'b0,1'b1,,,,);
`else
  prod={1'b1,A[22:0]}*{1'b1,B[22:0]};
`endif

  adder2o #(24) resAddD_mod(prod_reg[46:23],rndbit_dbl,{res_X[22:0],dummy1_3},{dummy1_4,res_X[22:0]},1'b0,
      prod_reg[47] & DBL_rnd1 & en_reg2 & ~spec_any || ~prod_reg[47] & DBL_rnd0 & DBL_rnflip0 & en_reg2 & ~spec_any,
      ~prod_reg[47] & DBL_rnd0 & ~DBL_rnflip0 & en_reg2 & ~spec_any,,,,);

  adder_CSA #(9) extAdd_mod(expA,expB,-BIAS,expart0,expart1);
  adder2c #(10) expAdd2_mod(expart0,expart1,exp_exp,exp_exp1,1'b0,1'b1,1'b1,1'b1,,,,);

  get_carry #(10) cmp0_mod(exp_max,~exp_exp_reg,1'b1,exp_oor);
  get_carry #(10) cmp1_mod(exp_max,~exp_exp1_reg,1'b1,exp1_oor);
  get_carry #(10) cmp2_mod(exp_max_IEEE,~exp_exp_reg,1'b1,exp_oor_IEEE);
  get_carry #(10) cmp3_mod(exp_max_IEEE,~exp_exp1_reg,1'b1,exp1_oor_IEEE);
  get_carry #(10) cmp4_mod(~exp_denor_IEEE,exp_exp_reg,1'b1,exp_non_denor_IEEE);
  get_carry #(10) cmp5_mod(~exp_denor_IEEE,exp_exp1_reg,1'b1,exp_non_denor_IEEE);


  assign exp_exp_d=exp_oor & ~fpcsr_reg[`csrfpu_clip_IEEE] ? exp_max : 10'b0;
  assign exp_exp_d=exp_oor_IEEE & fpcsr_reg[`csrfpu_clip_IEEE] ? exp_max_IEEE : 10'bz;
  assign exp_exp_d=~exp_non_denor_IEEE & fpcsr_reg[`csrfpu_daz] || exp_exp_reg[9] ? 10'b0 : 10'bz;
  assign exp_exp_d=~(exp_oor & ~fpcsr_reg[`csrfpu_clip_IEEE]) & 
    ~(exp_oor_IEEE & fpcsr_reg[`csrfpu_clip_IEEE]) & 
    ~(~exp_non_denor_IEEE & fpcsr_reg[`csrfpu_daz] || exp_exp_reg[9]) ? exp_exp_reg : 10'bz;
  
  assign exp_exp1_d=exp1_oor & ~fpcsr_reg[`csrfpu_clip_IEEE] ? exp_max : 10'b0;
  assign exp_exp1_d=exp1_oor_IEEE & fpcsr_reg[`csrfpu_clip_IEEE] ? exp_max_IEEE : 10'bz;
  assign exp_exp1_d=~exp1_non_denor_IEEE & fpcsr_reg[`csrfpu_daz] || exp_exp1_reg[9] ? 10'b0 : 10'bz;
  assign exp_exp1_d=~(exp1_oor & ~fpcsr_reg[`csrfpu_clip_IEEE]) & 
    ~(exp1_oor_IEEE & fpcsr_reg[`csrfpu_clip_IEEE]) & 
    ~(~exp1_non_denor_IEEE & fpcsr_reg[`csrfpu_daz] || exp_exp1_reg[9]) ? exp_exp1_reg : 10'bz;


  assign res_X[22:0]=(prod_reg[47] & ~DBL_rnd1 & ~spec_any & en_reg2) ? prod_reg[46:24]:23'bz;
  assign res_X[22:0]=(~prod_reg[47] & ~DBL_rnd0 & ~spec_any & en_reg2) ? prod_reg[45:23]:23'bz;
   
  assign {res_X[30],res_X[31],res_X[32],res_X[29:23]}=(prod_reg[47] & ~spec_any & en_reg2) ? {exp_exp1_reg2[8],sgn_reg2,exp_exp1_reg2[7:0]} : 10'bz;
  assign {res_X[30],res_X[31],res_X[32],res_X[29:23]}=(~prod_reg[47] & ~spec_any & en_reg2) ? {exp_exp_reg2[8],sgn_reg2,exp_exp_reg2[7:0]} : 10'bz;

  assign expon=(prod_reg[47] & ~spec_any) ? 
    {~DBL_rnbit1 & ~ DBL_tail1,exp_exp1_reg2[9],exp1_non_denor_IEEE_reg2,exp1_oor_IEEE_reg2,exp1_oor_reg2} : 5'bz;
  assign expon=(~prod_reg[47] & ~spec_any) ? 
    {~DBL_rnbit0 & ~ DBL_tail0,exp_exp_reg2[9],exp_non_denor_IEEE_reg2,exp_oor_IEEE_reg2,exp_oor_reg2} : 5'bz;
  assign expon=spec_any ? 5'd4 : 5'bz; 
 
 
  assign res_X[31]=(~spec_any & en_reg2) ? sgn_reg2 : 1'bz;
  
  assign res_X[22:0]=(spec_any & en_reg2) ? res_spec[22:0] : 23'bz;
  assign res_X[32:23]=(spec_any & en_reg2) ? res_spec[32:23] : 10'bz;
  assign res_X[31]=(spec_any & en_reg2) ? res_spec[31] : 1'bz;

  assign DBL_rnbit0=prod_reg[22];
  assign DBL_tail0=|prod_reg[21:0];
  assign DBL_rnflip0=&prod_reg[45:23];
  assign DBL_rnbit1=prod_reg[23];
  assign DBL_tail1=DBL_tail0|DBL_rnbit0;

  assign DBL_rnd0=~isrnd_zero && (DBL_rnbit0 & ~(isrnd_even & ~DBL_tail0 & prod_reg[23]) 
    || (isrnd_plus && DBL_rnbit0 | DBL_tail0));  
  assign DBL_rnd1=~isrnd_zero && (DBL_rnbit1 & ~(isrnd_even & ~DBL_tail1 & prod_reg[24]) 
    || (isrnd_plus && DBL_rnbit1 | DBL_tail1));  

  
    //begin exp/sgn  
  assign expA={A[30],A[32],A[29:23]};  
  assign expB={B[30],B[32],B[29:23]};
  

  assign A_zero=expA==9'b0;
  assign A_infty=expA==9'h1fe;
  assign A_nan=expA==9'h1ff;
  
  assign B_zero=expB==9'b0;
  assign B_infty=expB==9'h1fe;
  assign B_nan=expB==9'h1ff;

  assign spec_zero=A_zero&~B_infty&~copyA||B_zero&~A_infty&~copyA;
  assign spec_infty=A_infty&~B_zero&~copyA||B_infty&~A_zero&~copyA;
  assign spec_nan=(A_infty & B_zero|| B_infty & A_zero || 
      A_nan&~B_infty&~B_zero || B_nan&~A_infty&~A_zero) &~copyA;
  assign spec_A=copyA;
  assign spec_snan=fpcsr[`csrfpu_inv_flag]&spec_nan;
  assign spec_qnan=~fpcsr[`csrfpu_inv_flag]&spec_nan;

  assign sgn=A[31]^B[31];
  
  assign res_spec=spec_A_reg2 ? A_reg2 : 33'bz;
  assign res_spec=spec_snan_reg2 ? {10'h3ff,23'b1} : 33'bz;
  assign res_spec=spec_qnan_reg2 ? {10'h3ff,23'h400001} : 33'bz;
  assign res_spec=spec_infty_reg2 ? {1'b1,sgn_reg2,8'hfe,23'b0} : 33'bz;
  assign res_spec=spec_any ?  33'bz :  33'b0;

  assign raise[`csrfpu_inv_excpt]=spec_snan_reg2;
  assign raise[`csrfpu_under_excpt]=sgn_reg2 && expon[0];
  assign raise[`csrfpu_under_ieee_excpt]=sgn_reg2 && expon[1];
  assign raise[`csrfpu_over_excpt]=~sgn_reg2 && expon[0];
  assign raise[`csrfpu_over_ieee_excpt]=~sgn_reg2 && expon[1];
  assign raise[`csrfpu_denor_ieee_excpt]=~expon[2] | expon[3];
  assign raise[`csrfpu_denor_excpt]=expon[3];
  assign raise[`csrfpu_inexact_excpt]=expon[4] | expon[3];
  assign raise[`csrfpu_inexact_ieee_excpt]=expon[4] | expon[3] | ~expon[2];
  assign raise[`csrfpu_denor_consume_excpt]=1'b0;//only for logic op
  assign raise[`csrfpu_denor_produce_excpt]=1'b0;// ==//==

  always @(*) begin
      spec_any=spec_zero_reg2|spec_infty_reg2|spec_snan_reg2|spec_qnan_reg2|spec_A;
      prod_reg=prod;
  end
  `ifndef swapedge
  always @(negedge clk)
  `else
  always @(posedge clk)
  `endif
  begin
  //    if (res_X!=res_X) $display("res z muls");
      exp_exp_reg<=exp_exp;
      exp_exp1_reg<=exp_exp1;
      exp_exp_reg2<=exp_exp_d;
      exp_exp1_reg2<=exp_exp1_d;
//      exp_exp_reg3<=exp_exp_reg2;
//      exp_exp1_reg3<=exp_exp1_reg2;
      exp_oor_reg<=exp_oor;
      exp1_oor_reg<=exp1_oor;
      exp_oor_IEEE_reg<=exp_oor_IEEE;
      exp1_oor_IEEE_reg<=exp1_oor_IEEE;
      exp_non_denor_IEEE_reg<=exp_non_denor_IEEE;
      exp1_non_denor_IEEE_reg<=exp1_non_denor_IEEE;
      exp_oor_reg2<=exp_oor_reg;
      exp1_oor_reg2<=exp1_oor_reg;
      exp_oor_IEEE_reg2<=exp_oor_IEEE_reg;
      exp1_oor_IEEE_reg2<=exp1_oor_IEEE_reg;
      exp_non_denor_IEEE_reg2<=exp_non_denor_IEEE_reg;
      exp1_non_denor_IEEE_reg2<=exp1_non_denor_IEEE_reg;
      sgn_reg<=sgn;
      sgn_reg2<=sgn_reg;
  //    sgn_reg3<=sgn_reg2;
      spec_zero_reg<=spec_zero;
      spec_infty_reg<=spec_infty;
      spec_snan_reg<=spec_snan;
      spec_qnan_reg<=spec_qnan;
      spec_A_reg<=spec_A;
      spec_zero_reg2<=spec_zero_reg;
      spec_infty_reg2<=spec_infty_reg;
      spec_snan_reg2<=spec_snan_reg;
      spec_qnan_reg2<=spec_qnan_reg;
      spec_A_reg2<=spec_A_reg;
  //    spec_zero_reg3<=spec_zero_reg2;
  //    spec_infty_reg3<=spec_infty_reg2;
  //    spec_snan_reg3<=spec_snan_reg2;
  //    spec_qnan_reg3<=spec_qnan_reg2;
  //    spec_A_reg3<=spec_A_reg2;
      exp_max<=10'h1fe;
      exp_max_IEEE<=10'h17f;
      exp_denor_IEEE<=10'h81;
      fpcsr_reg<=fpcsr;
      A_reg<=A;
      A_reg2<=A_reg;
 //     A_reg3<=A_reg2;
      en_reg<=en;
      en_reg2<=en_reg;
 //     en_reg3<=en_reg2;
      case(rmode)
        ROUND_TRUNC: begin isrnd_even<=1'b0; isrnd_zero<=1'b1; isrnd_plus<=1'b0; end
        ROUND_ROUND: begin isrnd_even<=1'b0; isrnd_zero<=1'b0; isrnd_plus<=1'b0; end
        ROUND_EVEN : begin isrnd_even<=1'b1; isrnd_zero<=1'b0; isrnd_plus<=1'b0; end
        ROUND_PLUS : begin isrnd_even<=1'b0; isrnd_zero<=sgn_reg2; isrnd_plus<=1'b0; end
        ROUND_MINUS: begin isrnd_even<=1'b0; isrnd_zero<=~sgn_reg2; isrnd_plus<=1'b0; end
        ROUND_UP   : begin isrnd_even<=1'b0; isrnd_zero<=sgn_reg2; isrnd_plus<=~sgn_reg2; end
        ROUND_DOWN : begin isrnd_even<=1'b0; isrnd_zero<=~sgn_reg2; isrnd_plus<=sgn_reg2; end
      endcase
  end

endmodule


