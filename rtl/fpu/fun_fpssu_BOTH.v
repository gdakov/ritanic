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

module fun_fpsu_BOTH(
  clk,
  rst,
  fpcsr,
  u1_A0,u1_B0,u1_A1,u1_B1,u1_en,u1_op,
  u1_fufwd_A,u1_fuufwd_A,u1_fufwd_B,u1_fuufwd_B,
  u1_ret,u1_ret_en,u1_XSUB,
  u3_A0,u3_B0,u3_A1,u3_B1,u3_en,u3_op,
  u3_fufwd_A,u3_fuufwd_A,u3_fufwd_B,u3_fuufwd_B,
  u3_ret,u3_ret_en,u3_XSUB,
  u5_A0,u5_B0,u5_A1,u5_B1,u5_en,u5_op,
  u5_fufwd_A,u5_fuufwd_A,u5_fufwd_B,u5_fuufwd_B,
  u5_ret,u5_ret_en,u5_XSUB,
  FUFH0,FUFH1,FUFH2,
  FUFH3,FUFH4,FUFH5,
  FUFH6,FUFH7,FUFH8,
  FUFH9,
  FUFXH4,FUFXH5,FUFXH6,
  FUFL0,FUFL1,FUFL2,
  FUFL3,FUFL4,FUFL5,
  FUFL6,FUFL7,FUFL8,
  FUFL9,
  FUFXL4,FUFXL5,FUFXL6,
  ALTDATAH0,ALTDATAH1,
  ALTDATAL0,ALTDATAL1,
  ALT_INP,
  FOOFL0,FOOFL1,FOOFL2,
  fork_in,fork_out
  );
  localparam [0:0] H=1'b1;
  localparam SIMD_WIDTH=70; //half width
/*verilator hier_block*/
  input pwire clk;
  input pwire rst;
  input pwire [31:0] fpcsr;
  (* bus=SIMDL bus_spacing=10 bus_off=0 *) input pwire [67:0] u1_A0;
  (* bus=SIMDL bus_spacing=10 bus_off=0 *) input pwire [67:0] u1_B0;
  (* bus=SIMDH bus_spacing=10 bus_off=0 *) input pwire [67:0]    u1_A1;
  (* bus=SIMDH bus_spacing=10 bus_off=0 *) input pwire [67:0]    u1_B1;
  input pwire [3:0] u1_en;
  input pwire [20:0] u1_op;
  input pwire [3:0] u1_fufwd_A;
  input pwire [3:0] u1_fuufwd_A;
  input pwire [3:0] u1_fufwd_B;
  input pwire [3:0] u1_fuufwd_B;
  output pwire [13:0] u1_ret;
  output pwire u1_ret_en;
  input pwire u1_XSUB;

  (* bus=SIMDL bus_spacing=10 bus_off=1 *) input pwire [67:0] u3_A0;
  (* bus=SIMDL bus_spacing=10 bus_off=1 *) input pwire [67:0] u3_B0;
  (* bus=SIMDH bus_spacing=10 bus_off=1 *) input pwire [67:0]    u3_A1;
  (* bus=SIMDH bus_spacing=10 bus_off=1 *) input pwire [67:0]    u3_B1;
  input pwire [3:0] u3_en;
  input pwire [20:0] u3_op;
  input pwire [3:0] u3_fufwd_A;
  input pwire [3:0] u3_fuufwd_A;
  input pwire [3:0] u3_fufwd_B;
  input pwire [3:0] u3_fuufwd_B;
  output pwire [13:0] u3_ret;
  output pwire u3_ret_en;
  input pwire u3_XSUB;

  (* bus=SIMDL bus_spacing=10 bus_off=2 *) input pwire [67:0] u5_A0;
  (* bus=SIMDL bus_spacing=10 bus_off=2 *) input pwire [67:0] u5_B0;
  (* bus=SIMDH bus_spacing=10 bus_off=2 *) input pwire [67:0]    u5_A1;
  (* bus=SIMDH bus_spacing=10 bus_off=2 *) input pwire [67:0]    u5_B1;
  input pwire [3:0] u5_en;
  input pwire [20:0] u5_op;
  input pwire [3:0] u5_fufwd_A;
  input pwire [3:0] u5_fuufwd_A;
  input pwire [3:0] u5_fufwd_B;
  input pwire [3:0] u5_fuufwd_B;
  output pwire [13:0] u5_ret;
  output pwire u5_ret_en;
  input pwire u5_XSUB;


  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) input pwire [67:0] FUFH0;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) input pwire [67:0] FUFH1;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) input pwire [67:0] FUFH2;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) input pwire [67:0] FUFH3;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFH4;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFH5;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFH6;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFH7;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFH8;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFH9;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFXH4;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFXH5;
  (* register equiload *) (* bus=SIMDH bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFXH6;
  
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) input pwire [67:0] FUFL0;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) input pwire [67:0] FUFL1;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) input pwire [67:0] FUFL2;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) input pwire [67:0] FUFL3;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFL4;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFL5;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFL6;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFL7;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFL8;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFL9;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFXL4;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFXL5;
  (* register equiload *) (* bus=SIMDL bus_spacing=10 bus_rpl=3 *) output pwire [67:0] FUFXL6;

  input pwire [1:0] ALT_INP;
  (* bus=SIMDL bus_spacing=10 *) input pwire [67:0] ALTDATAL0;
  (* bus=SIMDL bus_spacing=10 *) input pwire [67:0] ALTDATAL1;
  (* bus=SIMDH bus_spacing=10 *) input pwire [67:0] ALTDATAH0;
  (* bus=SIMDH bus_spacing=10 *) input pwire [67:0] ALTDATAH1;

  (* register equiload *) output pwire [5:0] FOOFL0;
  (* register equiload *) output pwire [5:0] FOOFL1;
  (* register equiload *) output pwire [5:0] FOOFL2;
  

  input pwire [135:0] fork_in;
  output pwire [135:0] fork_out;

  pwire [67:0] xtra0;
  pwire [67:0] x2tra0;  
  pwire [67:0] xtra1;
  pwire [67:0] x2tra1;  
  pwire [67:0] xtra2;
  pwire [67:0] x2tra2;  

  pwire [67:0] u1_Ax;
  pwire [67:0] u1_Bx;
  pwire [67:0] u2_Ax;
  pwire [67:0] u2_Bx;
  pwire [67:0] u3_Ax;
  pwire [67:0] u3_Bx;
  pwire [67:0] u4_Ax;
  pwire [67:0] u4_Bx;
  pwire [67:0] u5_Ax;
  pwire [67:0] u5_Bx;
  pwire [67:0] u6_Ax;
  pwire [67:0] u6_Bx;
  
  /*wire  [67:0] FUFH4X;
  pwire  [67:0] FUFH5X;
  pwire  [67:0] FUFH6X;
  pwire  [67:0] FUFH7X;
  pwire  [67:0] FUFH8X;
  pwire  [67:0] FUFH9X;

  assign FUFH4=FUFH4X;
  assign FUFH5=FUFH5X;
  assign FUFH6=FUFH6X;
  assign FUFH7=FUFH7X;
  assign FUFH8=FUFH8X;
  assign FUFH9=FUFH9X;

  pwire  [67:0] FUFL4X;
  pwire  [67:0] FUFL5X;
  pwire  [67:0] FUFL6X;
  pwire  [67:0] FUFL7X;
  pwire  [67:0] FUFL8X;
  pwire  [67:0] FUFL9X;

  assign FUFL4=FUFL4X;
  assign FUFL5=FUFL5X;
  assign FUFL6=FUFL6X;
  assign FUFL7=FUFL7X;
  assign FUFL8=FUFL8X;
  assign FUFL9=FUFL9X;
*/
  pwire [13:0] u1_retH;
  pwire u1_ret_enH;
  pwire [13:0] u2_retH;
  pwire u2_ret_enH;
  pwire [13:0] u3_retH;
  pwire u3_ret_enH;
  pwire [13:0] u4_retH;
  pwire u4_ret_enH;
  pwire [13:0] u5_retH;
  pwire u5_ret_enH;
  pwire [13:0] u6_retH;
  pwire u6_ret_enH;
  pwire [13:0] u1_retL;
  pwire u1_ret_enL;
  pwire [13:0] u2_retL;
  pwire u2_ret_enL;
  pwire [13:0] u3_retL;
  pwire u3_ret_enL;
  pwire [13:0] u4_retL;
  pwire u4_ret_enL;
  pwire [13:0] u5_retL;
  pwire u5_ret_enL;
  pwire [13:0] u6_retL;
  pwire u6_ret_enL;

  reg [20:0] u1_op_reg;
  reg [20:0] u3_op_reg;
  reg [20:0] u5_op_reg;
  reg [20:0] u1_op_reg2;
  reg [20:0] u3_op_reg2;
  reg [20:0] u5_op_reg2;
  reg [20:0] u1_op_reg3;
  reg [20:0] u3_op_reg3;
  reg [20:0] u5_op_reg3;


  assign u1_ret=u1_retL|u1_retH;
  assign u1_ret_en=u1_ret_enL| u1_ret_enH;
  assign u3_ret=u3_retL|u3_retH;
  assign u3_ret_en=u3_ret_enL| u3_ret_enH;
  assign u5_ret=u5_retL|u5_retH;
  assign u5_ret_en=u5_ret_enL| u5_ret_enH;
  
  reg u1_XADD_reg,u3_XADD_reg,u5_XADD_reg;
  reg u1_XADD_reg2,u3_XADD_reg2,u5_XADD_reg2;
  reg u1_XADD_reg3,u3_XADD_reg3,u5_XADD_reg3;

  fun_fpuSL hf_mod(
  clk,
  rst,
  fpcsr,
  u1_A1,u1_B1,u1_Ax,u1_Bx,u1_en,u1_op,
  u1_fufwd_A,u1_fuufwd_A,u1_fufwd_B,u1_fuufwd_B,
  u1_retH,u1_ret_enH,u1_XSUB,{~u5_XADD_reg3&u5_op_reg3[10],~u3_XADD_reg3&u3_op_reg3[10],~u1_XADD_reg3&u1_op_reg3[10]},
  u3_A1,u3_B1,u3_Ax,u3_Bx,u3_en,u3_op,
  u3_fufwd_A,u3_fuufwd_A,u3_fufwd_B,u3_fuufwd_B,
  u3_retH,u3_ret_enH,u3_XSUB,{~u5_XADD_reg3&u5_op_reg3[10],~u3_XADD_reg3&u3_op_reg3[10],~u1_XADD_reg3&u1_op_reg3[10]},
  u5_A1,u5_B1,u5_Ax,u5_Bx,u5_en,u5_op,
  u5_fufwd_A,u5_fuufwd_A,u5_fufwd_B,u5_fuufwd_B,
  u5_retH,u5_ret_enH,u5_XSUB,{~u5_XADD_reg3&u5_op_reg3[10],~u3_XADD_reg3&u3_op_reg3[10],~u1_XADD_reg3&u1_op_reg3[10]},
  FUFH0,FUFH1,FUFH2,
  FUFH3,FUFH4,FUFH5,
  FUFH6,FUFH7,FUFH8,
  FUFH9,
  FUFXH4,FUFXH5,FUFXH6,
  xtra0,xtra0,
  xtra1,xtra1,
  xtra2,xtra2,
  ALTDATAH0,ALTDATAH1,
  ALT_INP,,,fork_in[139:70],fork_out[139:70]
  );

  fun_fpuSL lfpc_mod(
  clk,
  rst,
  fpcsr,
  u1_A0,u1_B0,u1_Bx,u1_Ax,u1_en,u1_op,
  u1_fufwd_A,u1_fuufwd_A,u1_fufwd_B,u1_fuufwd_B,
  u1_retL,u1_ret_enL,u1_XSUB,{~u5_XADD_reg3&u5_op_reg3[10],~u3_XADD_reg3&u3_op_reg3[10],~u1_XADD_reg3&u1_op_reg3[10]},
  u3_A0,u3_B0,u3_Bx,u3_Ax,u3_en,u3_op,
  u3_fufwd_A,u3_fuufwd_A,u3_fufwd_B,u3_fuufwd_B,
  u3_retL,u3_ret_enL,u3_XSUB,{~u5_XADD_reg3&u5_op_reg3[10],~u3_XADD_reg3&u3_op_reg3[10],~u1_XADD_reg3&u1_op_reg3[10]},
  u5_A0,u5_B0,u5_Bx,u5_Ax,u5_en,u5_op,
  u5_fufwd_A,u5_fuufwd_A,u5_fufwd_B,u5_fuufwd_B,
  u5_retL,u5_ret_enL,u5_XSUB,{~u5_XADD_reg3&u5_op_reg3[10],~u3_XADD_reg3&u3_op_reg3[10],~u1_XADD_reg3&u1_op_reg3[10]},
  FUFL0,FUFL1,FUFL2,
  FUFL3,FUFL4,FUFL5,
  FUFL6,FUFL7,FUFL8,
  FUFL9,
  FUFXL4,FUFXL5,FUFXL6,
  x2tra0,x2tra0,
  x2tra1,x2tra1,
  x2tra2,x2tra2,
  ALTDATAL0,ALTDATAL1,
  ALT_INP,
  FOOFL0,FOOFL1,FOOFL2,
  fork_in[67:0],fork_out[67:0]
  );

  `ifndef swapedge
  always @(posedge clk) begin
  `else
  always @(negedge clk) begin
  `endif
      u1_op_reg<=u1_op;
      u3_op_reg<=u3_op;
      u5_op_reg<=u5_op;
      u1_XADD_reg<=u1_XSUB;
      u3_XADD_reg<=u3_XSUB;
      u5_XADD_reg<=u5_XSUB;
      u1_op_reg2<=u1_op_reg;
      u3_op_reg2<=u3_op_reg;
      u5_op_reg2<=u5_op_reg;
      u1_XADD_reg2<=u1_XADD_reg;
      u3_XADD_reg2<=u3_XADD_reg;
      u5_XADD_reg2<=u5_XADD_reg;
      u1_op_reg3<=u1_op_reg2;
      u3_op_reg3<=u3_op_reg2;
      u5_op_reg3<=u5_op_reg2;
      u1_XADD_reg3<=u1_XADD_reg3;
      u3_XADD_reg3<=u3_XADD_reg3;
      u5_XADD_reg3<=u5_XADD_reg3;
  end

endmodule
