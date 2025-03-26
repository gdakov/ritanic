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
`include "../msrss_no.sv"

module fun_fpuSL(
  clk,
  rst,
  fpcsr,
  u1_A,u1_B,u1_Bx,u1_Bxo,u1_en,u1_op,
  u1_fufwd_A,u1_fuufwd_A,u1_fufwd_B,u1_fuufwd_B,
  u1_ret,u1_ret_en,u1_XSUB,u1_FX,
  u3_A,u3_B,u3_Bx,u3_Bxo,u3_en,u3_op,
  u3_fufwd_A,u3_fuufwd_A,u3_fufwd_B,u3_fuufwd_B,
  u3_ret,u3_ret_en,u3_XSUB,u3_FX,
  u5_A,u5_B,u5_Bx,u5_Bxo,u5_en,u5_op,
  u5_fufwd_A,u5_fuufwd_A,u5_fufwd_B,u5_fuufwd_B,
  u5_ret,u5_ret_en,u5_XSUB,u5_FX,
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF9,
  FUF4X,FUF5X,FUF6X,
  xdataD,xdata2D,
  xdataB,xdata2B,
  xdataC,xdata2C,
  ALTDATA0,
  ALT_INP,
  FOOSL0_out,
  FOOSL1_out,
  FOOSL2_out,
  XI_dataS,XI_dataT
  );
  localparam [0:0] H=1'b0;
  localparam SIMD_WIDTH=70; //half width
  input pwire clk;
  input pwire rst;
  input pwire [31:0] fpcsr;
  input pwire [67:0] u1_A;
  input pwire [67:0] u1_B;
  input pwire [67:0] u1_Bx;
  output pwire [67:0] u1_Bxo;
  input pwire [3:0] u1_en;
  input pwire [20:0] u1_op;
  input pwire [3:0] u1_fufwd_A;
  input pwire [3:0] u1_fuufwd_A;
  input pwire [3:0] u1_fufwd_B;
  input pwire [3:0] u1_fuufwd_B;
  output pwire [13:0] u1_ret;
  output pwire u1_ret_en;
  input pwire u1_XSUB;
  input pwire u1_FX;

  input pwire [67:0] u3_A;
  input pwire [67:0] u3_B;
  input pwire [67:0] u3_Bx;
  output pwire [67:0] u3_Bxo;
  input pwire [3:0] u3_en;
  input pwire [20:0] u3_op;
  input pwire [3:0] u3_fufwd_A;
  input pwire [3:0] u3_fuufwd_A;
  input pwire [3:0] u3_fufwd_B;
  input pwire [3:0] u3_fuufwd_B;
  output pwire [13:0] u3_ret;
  output pwire u3_ret_en;
  input pwire u3_XSUB;
  input pwire u3_FX;
  
  input pwire [67:0] u5_A;
  input pwire [67:0] u5_B;
  input pwire [67:0] u5_Bx;
  output pwire [67:0] u5_Bxo;
  input pwire [3:0] u5_en;
  input pwire [20:0] u5_op;
  input pwire [3:0] u5_fufwd_A;
  input pwire [3:0] u5_fuufwd_A;
  input pwire [3:0] u5_fufwd_B;
  input pwire [3:0] u5_fuufwd_B;
  output pwire [13:0] u5_ret;
  output pwire u5_ret_en;
  input pwire u5_XSUB;
  input pwire u5_FX;
  

  (* register equiload *) input pwire [67:0] FUF0;
  (* register equiload *) input pwire [67:0] FUF1;
  (* register equiload *) input pwire [67:0] FUF2;
  (* register equiload *) input pwire [67:0] FUF3;
  (* register equiload *) output pwire [67:0] FUF4;
  (* register equiload *) output pwire [67:0] FUF5;
  (* register equiload *) output pwire [67:0] FUF6;
  (* register equiload *) output pwire [67:0] FUF7;
  (* register equiload *) output pwire [67:0] FUF8;
  (* register equiload *) output pwire [67:0] FUF9;
  (* register equiload *) output pwire [67:0] FUF4X;
  (* register equiload *) output pwire [67:0] FUF5X;
  (* register equiload *) output pwire [67:0] FUF6X;
  input pwire [67:0] xdataD;
  output pwire [67:0] xdata2D;
  input pwire [67:0] xdataB;
  output pwire [67:0] xdata2B;
  input pwire [67:0] xdataC;
  output pwire [67:0] xdata2C;

  input pwire [1:0] ALT_INP;
  input pwire [67:0] ALTDATA0;
  
 
  (* register equiload *) output pwire [5:0] FOOSL0_out;
  (* register equiload *) output pwire [5:0] FOOSL1_out;
  (* register equiload *) output pwire [5:0] FOOSL2_out;

  input pwire [67:0] XI_dataS;
  output pwire [67:0] XI_dataT;

  pwire [67:0] ALTDATA1;
  pwire [67:0] ALTDATA1_reg;
  pwire [67:0] ALTDATA1_reg2;
  pwire daltXA;
  pwire daltXB;
  pwire daltXA_reg;
  pwire daltXB_reg;
  pwire daltXA_reg2;
  pwire daltXB_reg2;

  pwire [20:0] u5_op_reg;
  pwire [3:0] u5_en_reg;
  pwire [20:0] u5_op_reg2;
  pwire [3:0] u5_en_reg2;

  fun_fpsu #(0,0) fpu0_mod(
  clk,
  rst,
  fpcsr,
  u1_A,u1_B,u1_Bx,u1_Bxo,u1_en,u1_op,
  u1_fufwd_A,u1_fuufwd_A,u1_fufwd_B,u1_fuufwd_B,
  u1_ret,u1_ret_en,u1_XSUB,{u5_FX,u3_FX,u1_FX},
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF4X,FUF5X,FUF6X,
  FUF9,
  xdataD,xdata2D,
  70'b0,70'b0,
  2'b0,
  FOOSL0_out,,
  );

  fun_fpsu #(1,0) fpu1_mod(
  clk,
  rst,
  fpcsr,
  u3_A,u3_B,u3_Bx,u3_Bxo,u3_en,u3_op,
  u3_fufwd_A,u3_fuufwd_A,u3_fufwd_B,u3_fuufwd_B,
  u3_ret,u3_ret_en,u3_XSUB,{u5_FX,u3_FX,u1_FX},
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF9,
  FUF4X,FUF5X,FUF6X,
  xdataB,xdata2B,
  70'b0,70'b0,
  2'b0,
  FOOSL1_out,,
  );

  fun_fpsu #(2,0) fpu2_mod(
  clk,
  rst,
  fpcsr,
  u5_A,u5_B,u5_Bx,u5_Bxo,u5_en,u5_op,
  u5_fufwd_A,u5_fuufwd_A,u5_fufwd_B,u5_fuufwd_B,
  u5_ret,u5_ret_en,u5_XSUB,{u5_FX,u3_FX,u1_FX},
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF9,
  FUF4X,FUF5X,FUF6X,
  xdataC,xdata2C,
  ALTDATA0,ALTDATA1_reg,
  {daltXA_reg|daltXB_reg,ALT_INP[0]},
  FOOSL2_out,
  XI_dataS,XI_dataT
  );

  pwire [69:0] FUCVT1A;
  pwire [69:0] FUCVT1B;

  cvt_FP_I_mod fp2i_mod(
  .clk(clk),
  .rst(rst),
  .en(u5_en_reg[3] && |u5_en_reg[3:2] 
  && (pwh#(8)::cmpEQ(u5_op_reg[7:0],`fop_pcvtD) || pwh#(8)::cmpEQ(u5_op_reg[7:0],`fop_pcvtS))),
  .clkEn(1'b1),
  .A((u5_op_reg2[7:0]!=`fop_pcvtD) ? {16'b0,XI_dataS[65:0]} : {XI_dataT[15+70:70],XI_dataT[65:0]}),
  .isDBL(pwh#(8)::cmpEQ(u5_op_reg[7:0],`fop_pcvtD)),
  .isEXT(1'b0),
  .isSNG(u5_op_reg[7:0]!=`fop_pcvtD),
  .verbatim(1'b0),
  .is32b(pwh#(8)::cmpEQ(u5_op_reg[7:0],`fop_pcvtS)),
  .res(FUCVT1A),
  .alt(daltXA)
  );

  cvt_FP_I_mod fp2is_mod(
  .clk(clk),
  .rst(rst),
  .en(u5_en_reg[3] && |u5_en_reg[3:2]  
  && (pwh#(8)::cmpEQ(u5_op_reg[7:0],`fop_pcvtS))),
  .clkEn(1'b1),
  .A({16'b0,33'b0,XI_dataS[65:33]}),
  .isDBL(1'b0),
  .isEXT(1'b0),
  .isSNG(1'b1),
  .verbatim(1'b0),
  .is32b(1'b1),
  .res(FUCVT1B),
  .alt(daltXB)
  );

  assign ALTDATA1=daltXB ? {FUCVT1A[67:66],FUCVT1B[32:0],FUCVT1A[32:0]} : 
      FUCVT1A;

  always @(posedge clk) begin
      ALTDATA1_reg<=ALTDATA1;
      ALTDATA1_reg2<=ALTDATA1_reg;
      daltXA_reg<=daltXA;
      daltXB_reg<=daltXB;
      daltXA_reg2<=daltXA_reg;
      daltXB_reg2<=daltXB_reg;
      u5_en_reg<=u5_en;
      u5_op_reg<=u5_op;
      u5_en_reg2<=u5_en_reg;
      u5_op_reg2<=u5_op_reg2;
  end
endmodule
