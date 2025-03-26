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

module fun_fpuH(
  clk,
  rst,
  fpcsr,
  u1_A,u1_B,u1_Bx,u1_Bxo,u1_en,u1_op,
  u1_fufwd_A,u1_fuufwd_A,u1_fufwd_B,u1_fuufwd_B,
  u1_ret,u1_ret_en,u1_XADD,u1_FX,u1_flag,
  u3_A,u3_B,u3_Bx,u3_Bxo,u3_en,u3_op,
  u3_fufwd_A,u3_fuufwd_A,u3_fufwd_B,u3_fuufwd_B,
  u3_ret,u3_ret_en,u3_XADD,u3_FX,u3_flag,
  u5_A,u5_B,u5_Bx,u5_Bxo,u5_en,u5_op,
  u5_fufwd_A,u5_fuufwd_A,u5_fufwd_B,u5_fuufwd_B,
  u5_ret,u5_ret_en,u5_XADD,u5_FX,u5_flag,
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF9,
  FUF4XY,FUF5XY,FUF6XY,
  xtra0,xtra1,xtra2,
  x2tra0,x2tra1,x2tra2,
  ALTDATA0,ALTDATA1,
  ALT_INP,
  FUS_alu0,FUS_alu1,
  FUS_alu2,FUS_alu3,
  FUS_alu4,FUS_alu5,
  ex_alu0,ex_alu1,
  ex_alu2,ex_alu3,
  ex_alu4,ex_alu5,
  fxFADD0_raise_s,
  fxFCADD1_raise_s,
  fxFADD2_raise_s,
  fxFCADD3_raise_s,
  fxFADD4_raise_s,
  fxFCADD5_raise_s,
  FOOSH0_in,  FOOSH0_out,
  FOOSH1_in,  FOOSH1_out,
  FOOSH2_in,  FOOSH2_out,
  HI_dataS,HI_dataT
  );
  localparam [0:0] H=1'b1;
  localparam SIMD_WIDTH=70; //half width
  parameter HIGH=0;
  input pwire clk;
  input pwire rst;
  input pwire [31:0] fpcsr;
  input pwire [67:0] u1_A;
  input pwire [67:0] u1_B;
  output pwire [67:0] u1_Bxo;
  input pwire [67:0] u1_Bx;
  input pwire [3:0] u1_en;
  input pwire [20:0] u1_op;
  input pwire [3:0] u1_fufwd_A;
  input pwire [3:0] u1_fuufwd_A;
  input pwire [3:0] u1_fufwd_B;
  input pwire [3:0] u1_fuufwd_B;
  output pwire [13:0] u1_ret;
  output pwire u1_ret_en;
  input pwire u1_XADD;
  input pwire u1_FX;
  input pwire [5:0] u1_flag;

  input pwire [67:0] u3_A;
  input pwire [67:0] u3_B;
  output pwire [67:0] u3_Bxo;
  input pwire [67:0] u3_Bx;
  input pwire [3:0] u3_en;
  input pwire [20:0] u3_op;
  input pwire [3:0] u3_fufwd_A;
  input pwire [3:0] u3_fuufwd_A;
  input pwire [3:0] u3_fufwd_B;
  input pwire [3:0] u3_fuufwd_B;
  output pwire [13:0] u3_ret;
  output pwire u3_ret_en;
  input pwire u3_XADD;
  input pwire u3_FX;
  input pwire [5:0] u3_flag;

  input pwire [67:0] u5_A;
  input pwire [67:0] u5_B;
  output pwire [67:0] u5_Bxo;
  input pwire [67:0] u5_Bx;
  input pwire [3:0] u5_en;
  input pwire [20:0] u5_op;
  input pwire [3:0] u5_fufwd_A;
  input pwire [3:0] u5_fuufwd_A;
  input pwire [3:0] u5_fufwd_B;
  input pwire [3:0] u5_fuufwd_B;
  output pwire [13:0] u5_ret;
  output pwire u5_ret_en;
  input pwire u5_XADD;
  input pwire u5_FX;
  input pwire [5:0] u5_flag;


  (* register equiload *) input pwire [67:0] FUF0;
  (* register equiload *) input pwire [67:0] FUF1;
  (* register equiload *) input pwire [67:0] FUF2;
  (* register equiload *) input pwire [67:0] FUF3;
  (* register equiload *) inout pwire [67:0] FUF4;
  (* register equiload *) inout pwire [67:0] FUF5;
  (* register equiload *) inout pwire [67:0] FUF6;
  (* register equiload *) inout pwire [67:0] FUF7;
  (* register equiload *) inout pwire [67:0] FUF8;
  (* register equiload *) inout pwire [67:0] FUF9;
  (* register equiload *) inout pwire [67:0] FUF4XY;
  (* register equiload *) inout pwire [67:0] FUF5XY;
  (* register equiload *) inout pwire [67:0] FUF6XY;

  output pwire [67:0] xtra0;
  output pwire [67:0] xtra1;
  output pwire [67:0] xtra2;

  input pwire [67:0] x2tra0;
  input pwire [67:0] x2tra1;
  input pwire [67:0] x2tra2;

  input pwire [1:0] ALT_INP;
  input pwire [67:0] ALTDATA0;
  input pwire [67:0] ALTDATA1;

  input pwire [5:0] FUS_alu0;
  input pwire [5:0] FUS_alu1;
  input pwire [5:0] FUS_alu2;
  input pwire [5:0] FUS_alu3;
  input pwire [5:0] FUS_alu4;
  input pwire [5:0] FUS_alu5;
  input pwire [2:0] ex_alu0;
  input pwire [2:0] ex_alu1;
  input pwire [2:0] ex_alu2;
  input pwire [2:0] ex_alu3;
  input pwire [2:0] ex_alu4;
  input pwire [2:0] ex_alu5;
  input pwire [10:0] fxFADD0_raise_s;
  input pwire [10:0] fxFCADD1_raise_s;
  input pwire [10:0] fxFADD2_raise_s;
  input pwire [10:0] fxFCADD3_raise_s;
  input pwire [10:0] fxFADD4_raise_s;
  input pwire [10:0] fxFCADD5_raise_s;
  (* register equiload *) input pwire [5:0]  FOOSH0_in;
  (* register equiload *) output pwire [5:0] FOOSH0_out;
  (* register equiload *) input pwire [5:0]  FOOSH1_in;
  (* register equiload *) output pwire [5:0] FOOSH1_out;
  (* register equiload *) input pwire [5:0]  FOOSH2_in;
  (* register equiload *) output pwire [5:0] FOOSH2_out;
  input pwire [67:0] HI_dataS;
  output pwire [67:0] HI_dataT;


  fun_fpu #(0,1,HIGH) fpu0_mod(
  clk,
  rst,
  fpcsr,
  u1_A,u1_B,u1_Bx,u1_Bxo,u1_en,u1_op,
  u1_fufwd_A,u1_fuufwd_A,u1_fufwd_B,u1_fuufwd_B,
  u1_ret,u1_ret_en,u1_XADD,{u5_FX,u3_FX,u1_FX},u1_flag,
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF9,
  FUF4XY,FUF5XY,FUF6XY,
  xtra0,x2tra0,
  70'b0,70'b0,
  2'b0,
  FUS_alu0,FUS_alu1,
  ex_alu0,ex_alu1,
  fxFADD0_raise_s,
  fxFCADD1_raise_s,
  FOOSH0_in,
  FOOSH0_out,,
  );

  fun_fpu #(1,1,HIGH) fpu1_mod(
  clk,
  rst,
  fpcsr,
  u3_A,u3_B,u3_Bx,u3_Bxo,u3_en,u3_op,
  u3_fufwd_A,u3_fuufwd_A,u3_fufwd_B,u3_fuufwd_B,
  u3_ret,u3_ret_en,u3_XADD,{u5_FX,u3_FX,u1_FX},u3_flag,
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF9,
  FUF4XY,FUF5XY,FUF6XY,
  xtra1,x2tra1,
  70'b0,70'b0,
  2'b0,
  FUS_alu2,FUS_alu3,
  ex_alu2,ex_alu3,
  fxFADD2_raise_s,
  fxFCADD3_raise_s,
  FOOSH1_in,
  FOOSH1_out,,
  );

  fun_fpu #(2,1,HIGH) fpu2_mod(
  clk,
  rst,
  fpcsr,
  u5_A,u5_B,u5_Bx,u5_Bxo,u5_en,u5_op,
  u5_fufwd_A,u5_fuufwd_A,u5_fufwd_B,u5_fuufwd_B,
  u5_ret,u5_ret_en,u5_XADD,{u5_FX,u3_FX,u1_FX},u5_flag,
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF9,
  FUF4XY,FUF5XY,FUF6XY,
  xtra2,x2tra2,
  ALTDATA0,ALTDATA1,
  ALT_INP,
  FUS_alu4,FUS_alu5,
  ex_alu4,ex_alu5,
  fxFADD4_raise_s,
  fxFCADD5_raise_s,
  FOOSH2_in,
  FOOSH2_out,HI_dataS,HI_dataT
  );

endmodule
