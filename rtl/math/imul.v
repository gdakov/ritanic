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

module imul(
  clk,
  rst,
  clkEn,
  op_prev,
  rmode,
  en,
  R,C,
  attr,
  alt,
  alt_jxcross,
  Res,
  jxcross_in,
  flg
 );

  input pwire clk;
  input pwire rst;
  input pwire clkEn;
  input pwire [12:0] op_prev;
  input pwire [2:0] rmode;
  input pwire en;
  input pwire [64:0] R;
  input pwire [64:0] C;
  input pwire [3:0] attr;
  output pwire [64:0] Res;
  output pwire reg alt;
  output pwire reg alt_jxcross;
  output pwire [5:0] flg;
  input pwire [64:0] jxcross_in;

  reg and1,is_sig,sig,sm_sig,upper,short;
  reg sig_reg,sig_reg2;
  reg sm_sig_reg,sm_sig_reg2;
  reg upper_reg,upper_reg2,short_reg,short_reg2;
  reg upper_reg3,short_reg3;
  reg upper_reg4,short_reg4;
  reg en_reg,en_reg2,en_reg3,clkEn_reg;
  reg and1_reg,and1_reg2,and1_reg3,and1_reg4;
  reg is_sec,is_sec_reg,is_sec_reg2;
  reg is_sec_reg3;
  reg is_swp_reg,is_swp_reg2;
  reg is_swp_reg3;
  reg [1:0] is_swp;
  reg [64:0] sec_res_reg;
  reg [64:0] sec_res_reg2;
  reg [64:0] swp_res_reg;
  reg [64:0] swp_res_reg2;

  reg ptr_reg,ptr_reg2;
  pwire [64:0] swp_res;
  pwire [64:0] sec_res;
  pwire [127:0] A_out;
  pwire [127:0] B_out;
  reg [127:0] A_out_reg;
  reg [127:0] B_out_reg;
  pwire [64:0] dummy;
  pwire [64:0] dummy2;
  reg [64:0] Res_reg;
  reg [64:0] dummy2_reg;
  reg [64:0] dummy_reg;
  //reg [7:0] dummy8_reg;
  pwire resz;
  pwire resp;
  pwire [31:0] resx;
  reg [31:0] resx_reg;
  pwire [64:0] sec_res;
  //wire [64:0] resB;
  //reg bnd,bnd_reg,bnd_reg2,bnd_reg3;

  reg do16_reg;
  reg do16;
  reg do16_reg2;

  //assign alt=~(clkEn && en_reg2);
  assign resz=~|Res_reg;
  assign resp=~^Res_reg[7:0];

  assign flg=and1_reg2 && ~upper_reg2 ? {|dummy2_reg,~(&dummy2_reg&Res_reg[63]
    || ~|dummy2_reg&~Res_reg[63]),1'b0,Res_reg[63],resz,resp} : 6'bz; 
  assign flg=and1_reg2 && upper_reg2 ? {|Res_reg,~(&Res_reg&dummy_reg[63]
    || ~|Res_reg&~dummy_reg[63]),1'b0,Res_reg[63],resz&~|dummy_reg,~^dummy_reg[7:0]} : 6'bz; 
  assign flg=~and1_reg2 && ~short_reg2 ? {|Res_reg[63:32],~(&Res_reg[63:31]||
   ~|Res_reg[63:31]),1'b0,Res_reg[63],resz,resp} : 6'bz;
  assign flg=~and1_reg2 && short_reg2 ? {|resx_reg,~(&resx_reg&Res_reg[31] ||
    ~|resx_reg&~Res_reg[31]),1'b0,Res_reg[31],resz,resp} : 6'bz;


  pwire [64:0] Cix;

  assign Cix=and1 & !sm_sig ? C>>32 : C;

  icompr cmp_mod(clk,clkEn,R[63:0],{is_sig ? {32{Cix[31]}} :32'b0,Cix[31:0]},A_out,B_out,1'b1,is_sig|(and1&!sm_sig),sig|(and1&!sm_sig),sm_sig);
  adderoM #(64) add_mod(A_out_reg[63:0],B_out_reg[63:0],Res0[63:0], 1'b0,~is_sec_reg&~alt_jxcross_reg,short_reg&~alt_jxcross_reg,,,,);
  adder #(16) add16A_mod(A_out_reg[15:0],B_out_reg[15:0],Res[15:0],1'b0,do16_reg2,,,,);
  adder #(16) add16B_mod(A_out_reg[15:0],B_out_reg[15:0],Res16[15:0],1'b0,1'b1,,,,);

  assign Res[63:0]=and1_reg & !sm_sig_Reg ? Res0[63:0]<<32 : Res0[63:0];
  assign Res[64]=Res0[64];

  assign Res0[63:16]=do16_reg & ~alt_jxcross_reg ? {{48{Res16[15]}}} : 48'bz;
  assign Res0=alt_jxcross_reg ? jxcross : 65'bz;

  assign Res0[64]=~alt_jxcross_reg & ~ is_sec_reg & ~ is_swp_reg ? 1'b0 : 1'bz;

  assign Res0[64:0]=is_sec_reg & ~alt_jxcross_reg ? {ptr_reg,sec_res_reg} : {1'b0,64'bz};
  assign Res0[64:0]=is_swp_reg & ~alt_jxcross_reg ? {1'b0,swp_res_reg} : 65'bz;
  assign swp_res=is_swp[0] ? {32'b0,R[7:0],R[15:8],R[23:16],R[31:24]}: 
	  {R[7:0],R[15:8],R[23:16],R[31:24],R[39:32],R[47:40],R[55:48],R[63:56]};

  addrcalcsec_mul msec(R[63:0],C[11:0],attr,sec_res);

  pwire [64:0] dec_res;
  reg is_dec,is_dec_reg;
  reg is_mlb;

  foreign_imul dec_mod(
  clk,
  rst,
  clkEn_reg && is_dec,
  clkEn_reg && is_tbl,
  R,
  C,
  dec_res);

  
  always @(posedge clk) begin
    clkEn_reg<=clkEn;
    if (clkEn) begin
      and1<=1'b1;
      is_sig<=1'b1;
      sig<=1'b1;
      sm_sig<=1'b1;
      upper<=1'b0;
      short<=1'b0;
      is_sec<=1'b0;
      is_dec<=1'b0;
      is_tbl<=1'b0;
      do16<=1'b0;
 //     bnd<=1'b0;
      case({4'b1000,op_prev[7:0]})
      `op_lmul64: begin
          is_sig<=1'b0;
	  sig<=1'b0;
	  sm_sig<=1'b0;
	  upper<=1'b1;
      end
      `op_mul64: begin
          is_sig<=1'b0;
	  sig<=1'b0;
	  sm_sig<=1'b0;
	  //upper<=1'b1;
      end
      `op_mul32_64: begin
          and1<=1'b0;
	  is_sig<=1'b0;
	  sig<=1'b0;
	  sm_sig<=1'b0;
      end
      `op_imul32_64: begin
          and1<=1'b0;
	  //is_sig<=1'b0;
	  sig<=1'b0;
	  //sm_sig<=1'b0;
      end
      `op_mul32: begin
          and1<=1'b0;
	  is_sig<=1'b0;
	  sig<=1'b0;
	  sm_sig<=1'b0;
	  short<=1'b1;
      end
      `op_imul32: begin
          and1<=1'b0;
	  sig<=1'b0;
	  short<=1'b0;
          do16<=1'b1;
      end
      `op_imul64: begin
	  sm_sig<=1'b0;
          do16<=1'b1;
      end
      `op_limul64: begin
	  sm_sig<=1'b0;
	  upper<=1'b1;
      end
      `op_sec64: begin
	  is_sec<=1'b1;
      end
      `op_dec: begin
          is_dec<=op_prev[8];
          is_tbl<=~op_prev[8];
          is_sec<=1'b1;
      end
      `op_swp32: begin
	  is_swp<=2'b1;
      end
      `op_swp64: begin
	  is_swp<=2'b10;
      end
      endcase
      A_out_reg<=A_out ^ {sig_reg2,63'b0,sm_sig_reg2,63'b0};
      B_out_reg<=B_out;
      en_reg<=en;
      en_reg2<=en_reg;
      do16_reg<=do16;
      do16_reg2<=do16_reg;
      alt<=en;
      alt_jxcros<=en && rmode[0];
      alt_jxcros_reg<=alt_jxcross;
      alt_jxcros_reg2<=alt_jxcross_reg;
      is_sec_reg<=is_sec;
      is_sec_reg2<=is_sec_reg;
      is_swp_reg<=|is_swp;
      is_swp_reg2<=is_swp_reg;
      upper_reg<=upper;
      upper_reg2<=upper_reg;
      short_reg<=short;
      short_reg2<=short_reg;
      sig_reg<=sig;
      sm_sig_reg<=sm_sig;
      and1_reg<=and1;
      and1_reg2<=and1_reg;
      sec_res_reg<=is_dec_reg ? dec_res : sec_res;
      swp_res_reg<=swp_res;
      ptr_reg<=R[64];
    end
    Res_reg<=Res[63:0];
    dummy2_reg<=dummy2;
    dummy_reg<=dummy;
    //dummy8_reg<=dummy[7:0];
    resx_reg<=resx;
    upper_reg3<=upper_reg2;
    short_reg3<=short_reg2;
    and1_reg3<=and1_reg2;
  end
endmodule

