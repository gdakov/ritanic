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
`include "../operations.sv"
module fu_alu(
  clk,
  clkREF,
  clkREF2,
  rst,
  except,
  u1_A,u1_B,u1_S,u1_op,u1_ret,u1_rten,u1_clkEn,
    u1_A_fufwd,u1_A_fuufwd,u1_B_fufwd,u1_B_fuufwd,
    u1_S_fufwd,u1_S_fuufwd,u1_const,
  u2_A,u2_B,u2_S,u2_op,u2_ret,u2_rten,u2_clkEn,
    u2_A_fufwd,u2_A_fuufwd,u2_B_fufwd,u2_B_fuufwd,
    u2_S_fufwd,u2_S_fuufwd,
  u3_A,u3_B,u3_S,u3_op,u3_ret,u3_rten,u3_clkEn,
    u3_A_fufwd,u3_A_fuufwd,u3_B_fufwd,u3_B_fuufwd,
    u3_S_fufwd,u3_S_fuufwd,u3_const,
  u4_A,u4_B,u4_S,u4_op,u4_ret,u4_rten,u4_clkEn,
    u4_A_fufwd,u4_A_fuufwd,u4_B_fufwd,u4_B_fuufwd,
    u4_S_fufwd,u4_S_fuufwd,
  u5_A,u5_B,u5_S,u5_nDataAlt,u5_op,u5_ret,u5_rten,u5_clkEn,
    u5_A_fufwd,u5_A_fuufwd,u5_B_fufwd,u5_B_fuufwd,
    u5_S_fufwd,u5_S_fuufwd,u5_const,
  u6_A,u6_B,u6_S,u6_op,u6_ret,u6_rten,u6_clkEn,
    u6_A_fufwd,u6_A_fuufwd,u6_B_fufwd,u6_B_fuufwd,
    u6_S_fufwd,u6_S_fuufwd,u6_attr,
  FU0, FU1,  FU2,  FU3,
  FU4, FU5,  FU6,  FU7,
  FU8, FU9,
  FUS1,  FUS2,  FUS3,
  FUS4, FUS5,  FUS6,  FUS7,
  FUS8,FUS9,
  fxFRT_alten_reg,
  fcvtout,
  DataAlt,
  FUCVTIN,
  jxcross,allah,
  msrss_addr,
  msrss_data,
  msrss_en
  );
/*verilator hier_block*/

  input pwire clk;
  input pwire clkREF;
  input pwire clkREF2;
  input pwire rst;
  input pwire except;

  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u1_A;
  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u1_B;
  input pwire [5:0]           u1_S;
  input pwire [17:0]          u1_op;
  output pwire [8:0]          u1_ret;
  output pwire                u1_rten;
  input pwire                 u1_clkEn;
  input pwire [3:0]           u1_A_fufwd;
  input pwire [3:0]           u1_A_fuufwd;
  input pwire [3:0]           u1_B_fufwd;
  input pwire [3:0]           u1_B_fuufwd;
  input pwire [3:0]           u1_S_fufwd;
  input pwire [3:0]           u1_S_fuufwd;
  (* bus=WB bus_spacing=10 bus_off=33 *)input pwire [32:0]		u1_const;

  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u2_A;
  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u2_B;
  input pwire [5:0]           u2_S;
  input pwire [17:0]          u2_op;
  output pwire [8:0]          u2_ret;
  output pwire                u2_rten;
  input pwire                 u2_clkEn;
  input pwire [3:0]           u2_A_fufwd;
  input pwire [3:0]           u2_A_fuufwd;
  input pwire [3:0]           u2_B_fufwd;
  input pwire [3:0]           u2_B_fuufwd;
  input pwire [3:0]           u2_S_fufwd;
  input pwire [3:0]           u2_S_fuufwd;

  (* bus=WB bus_spacing=10 *) input pwire [64:0]          u3_A;
  (* bus=WB bus_spacing=10 *) input pwire [64:0]          u3_B;
  input pwire [5:0]           u3_S;
  input pwire [17:0]          u3_op;
  output pwire [8:0]          u3_ret;
  output pwire                u3_rten;
  input pwire                 u3_clkEn;
  input pwire [3:0]           u3_A_fufwd;
  input pwire [3:0]           u3_A_fuufwd;
  input pwire [3:0]           u3_B_fufwd;
  input pwire [3:0]           u3_B_fuufwd;
  input pwire [3:0]           u3_S_fufwd;
  input pwire [3:0]           u3_S_fuufwd;
  (* bus=WB bus_spacing=10 *)input pwire [32:0]		u3_const;

  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u4_A;
  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u4_B;
  input pwire [5:0]           u4_S;
  input pwire [17:0]          u4_op;
  output pwire [8:0]          u4_ret;
  output pwire                u4_rten;
  input pwire                 u4_clkEn;
  input pwire [3:0]           u4_A_fufwd;
  input pwire [3:0]           u4_A_fuufwd;
  input pwire [3:0]           u4_B_fufwd;
  input pwire [3:0]           u4_B_fuufwd;
  input pwire [3:0]           u4_S_fufwd;
  input pwire [3:0]           u4_S_fuufwd;

  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u5_A;
  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u5_B;
  input pwire [5:0]           u5_S;
  input pwire                 u5_nDataAlt;
  input pwire [17:0]          u5_op;
  output pwire [8:0]          u5_ret;
  output pwire                u5_rten;
  input pwire                 u5_clkEn;
  input pwire [3:0]           u5_A_fufwd;
  input pwire [3:0]           u5_A_fuufwd;
  input pwire [3:0]           u5_B_fufwd;
  input pwire [3:0]           u5_B_fuufwd;
  input pwire [3:0]           u5_S_fufwd;
  input pwire [3:0]           u5_S_fuufwd;
  (* bus=WB bus_spacing=10 *)input pwire [32:0]          u5_const;

  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u6_A;
  (* bus=WB bus_spacing=10 *)input pwire [64:0]          u6_B;
  input pwire [5:0]           u6_S;
  input pwire [17:0]          u6_op;
  output pwire [8:0]          u6_ret;
  output pwire                u6_rten;
  input pwire                 u6_clkEn;
  input pwire [3:0]           u6_A_fufwd;
  input pwire [3:0]           u6_A_fuufwd;
  input pwire [3:0]           u6_B_fufwd;
  input pwire [3:0]           u6_B_fuufwd;
  input pwire [3:0]           u6_S_fufwd;
  input pwire [3:0]           u6_S_fuufwd;
  input pwire [3:0]		u6_attr;

  (* register equiload  bus=WB bus_spacing=10  *) input pwire [64:0] FU0;
  (* register equiload  bus=WB bus_spacing=10  *) input pwire [64:0] FU1;
  (* register equiload  bus=WB bus_spacing=10  *) input pwire [64:0] FU2;
  (* register equiload  bus=WB bus_spacing=10  *) input pwire [64:0] FU3;
  (* register equiload  bus=WB bus_spacing=10  *) output pwire [64:0] FU4;
  (* register equiload  bus=WB bus_spacing=10  *) output pwire [64:0] FU5;
  (* register equiload  bus=WB bus_spacing=10  *) output pwire [64:0] FU6;
  (* register equiload  bus=WB bus_spacing=10  *) output pwire [64:0] FU7;
  (* register equiload  bus=WB bus_spacing=10  *) output pwire [64:0] FU8;
  (* register equiload  bus=WB bus_spacing=10  *) output pwire [64:0] FU9;

  (* register equiload *) input pwire [5:0] FUS1;
  (* register equiload *) input pwire [5:0] FUS2;
  (* register equiload *) input pwire [5:0] FUS3;
  (* register equiload *) input pwire [5:0] FUS4;
  (* register equiload *) input pwire [5:0] FUS5;
  (* register equiload *) input pwire [5:0] FUS6;
  (* register equiload *) input pwire [5:0] FUS7;
  (* register equiload *) input pwire [5:0] FUS8;
  (* register equiload *) input pwire [5:0] FUS9;

  input pwire fxFRT_alten_reg;

  output pwire [83:0] fcvtout;
  output pwire [1:0] DataAlt;
  input pwire [64:0] FUCVTIN;
  input pwire [15:0] msrss_addr;
  input pwire [64:0] msrss_data;
  input pwire msrss_en;
  input pwire [64:0] jxcross;
  inout [64:0] allah;

  reg [1:0] nDataAlt;

  reg [1:0] nDataAlt_reg;
  reg u5_nDataAlt_reg;
  reg [64:0] FU0_reg;
  reg [64:0] FU1_reg;
  reg [64:0] FU2_reg;
  reg [64:0] FU3_reg;
  reg [64:0] FU4_reg;
  reg [64:0] FU5_reg;
  reg [64:0] FU6_reg;
  reg [64:0] FU7_reg;
  reg [64:0] FU8_reg;
  reg [64:0] FU9_reg;
  
  reg [5:0] FUS1_reg;
  reg [5:0] FUS2_reg;
  reg [5:0] FUS3_reg;
  reg [5:0] FUS4_reg;
  reg [5:0] FUS5_reg;
  reg [5:0] FUS6_reg;
  reg [5:0] FUS7_reg;
  reg [5:0] FUS8_reg;
  reg [5:0] FUS9_reg;
  
  reg [3:0]           u1_S_fufwd_reg;
  reg [3:0]           u1_S_fuufwd_reg;
  reg [3:0]           u2_S_fufwd_reg;
  reg [3:0]           u2_S_fuufwd_reg;
  reg [3:0]           u3_S_fufwd_reg;
  reg [3:0]           u3_S_fuufwd_reg;
  reg [3:0]           u4_S_fufwd_reg;
  reg [3:0]           u4_S_fuufwd_reg;
  reg [3:0]           u5_S_fufwd_reg;
  reg [3:0]           u5_S_fuufwd_reg;
  reg [3:0]           u6_S_fufwd_reg;
  reg [3:0]           u6_S_fuufwd_reg;

  reg [32:0] u1_const_reg;
  reg [32:0] u2_const_reg;
  reg [32:0] u3_const_reg;

  reg [3:0] u6_attr;

  reg [3:0] u1_sh_reg;
  reg [1:0] u1_sh2_reg;
  reg [3:0] u3_sh_reg;
  reg [1:0] u3_sh2_reg;
  reg [3:0] u5_sh_reg;
  reg [1:0] u5_sh2_reg;

  reg u1_eaen_reg;
  reg u3_eaen_reg;
  reg u5_eaen_reg;


  pwire [2:0][64:0] uu_A1;
  pwire [2:0][64:0] uu_B1;
  pwire [2:0][64:0] uu_A2;
  pwire [2:0][64:0] uu_B2;
  pwire [2:0][64:0] uu_A3;
  pwire [2:0][64:0] uu_B3;
  pwire [2:0][64:0] uu_A4;
  pwire [2:0][64:0] uu_B4;
  pwire [2:0][64:0] uu_A5;
  pwire [2:0][64:0] uu_B5;
  pwire [2:0][64:0] uu_A6;
  pwire [2:0][64:0] uu_B6;
  pwire [2:0][64:0] uu_A6m;
  pwire [2:0][64:0] uu_B6m;

  pwire [5:0] uu_S1;
  pwire [5:0] uu_S2;
  pwire [5:0] uu_S3;
  pwire [5:0] uu_S4;
  pwire [5:0] uu_S5;
  pwire [5:0] uu_S6;

  pwire [81:0] FUCVT2_0;
  pwire [1:0] FUTYPE_0;
  pwire [64:0] FUMUL;
  pwire [5:0] MULFL;
  reg [64:0] FUMUL_reg;
  reg [5:0] MULFL_reg;

  reg [3:0] u2_sz;
  reg       u2_arith;
  reg       u2_dir;
  reg [3:0] u4_sz;
  reg       u4_arith;
  reg       u4_dir;
  reg [3:0] u6_sz;
  reg       u6_arith;
  reg       u6_dir;
  
  reg fxFRT_alten_reg2;
  reg fxFRT_alten_reg3;

  reg [17:0] u1_op_reg;
  reg [17:0] u2_op_reg;
  reg [17:0] u3_op_reg;
  reg [17:0] u4_op_reg;
  reg [17:0] u5_op_reg;
  reg [17:0] u6_op_reg;
  reg [12:0] u6_op_reg2;
  reg [12:0] u6_op_reg3;
  reg [12:0] u6_op_reg4;

  reg [5:0] u1_isSub_reg;
  reg [5:0] u2_isSub_reg;
  reg [5:0] u3_isSub_reg;
  reg [5:0] u4_isSub_reg;
  reg [5:0] u5_isSub_reg;
  reg [5:0] u6_isSub_reg;

  reg u1_clkEn_reg;
  reg u2_clkEn_reg;
  reg u3_clkEn_reg;
  reg u4_clkEn_reg;
  reg u5_clkEn_reg;
  reg u6_clkEn_reg;

  reg u1_error_reg;
  reg u2_error_reg;
  reg u3_error_reg;
  reg u4_error_reg;
  reg u5_error_reg;
  reg u6_error_reg;

  pwire u1_error=^u1_A || ^u1_B;
  pwire u2_error=^u2_A || ^u2_B;
  pwire u3_error=^u3_A || ^u3_B;
  pwire u4_error=^u4_A || ^u4_B;
  pwire u5_error=^u5_A || ^u5_B;
  pwire u6_error=^u6_A || ^u6_B;

  reg [8:0] u6_ret_reg;
  reg [8:0] u6_ret_reg2;
  reg [8:0] u6_ret_reg3;

  pwire [1:0][63:0] mflags;

  msrss_watch #(`csr_mflags,64'h0) mflags_mod(clk,rst,msrss_addr,msrss_data[63:0],msrss_en,mflags);

  rs_write_forward_ALU #(0,66) u1_A_fwd(
  clk,rst,
  !(u1_op[7:3]==5'b0 || u1_op[7:1]==7'd30) || ~clkREF,
  (u1_op[7:3]==5'b0 || u1_op[7:1]==7'd30 || u1_op[7:3]==3 || u1_op[7:2]==5) || ~clkREF,
  !(u1_op[7:3]==3 || u1_op[7:2]==5 || u1_op[7:0]==`op_cax) || ~clkREF,  
  (u1_op[7:0]==`op_add64 || u1_op[7:0]==`op_sub64) && u1_op[8],
  u1_A,uu_A1,
  u1_A_fufwd,u1_A_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  rs_write_forward_ALU #(1,66) u1_B_fwd(
  clk,rst,
  !(u1_op[7:3]==5'b0 || u1_op[7:1]==7'd30) || ~clkREF2,
  (u1_op[7:3]==5'b0 || u1_op[7:1]==7'd30 || u1_op[7:3]==3 || u1_op[7:2]==5 || u1_op[11]) || ~clkREF2,
  !(u1_op[7:3]==3 || u1_op[7:2]==5 || u1_op[11] || u1_op[7:0]==`op_cax) || ~clkREF2,  
  (u1_op[7:0]==`op_add64 || u1_op[7:0]==`op_sub64) && u1_op[8],
  u1_B,uu_B1,
  u1_B_fufwd,u1_B_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  
  rs_write_forward_ALU #(0,66) u2_A_fwd(
  clk,rst,
  !(u2_op[7:3]==5'b0 || u2_op[7:1]==7'd30) || ~clkREF,
  (u2_op[7:3]==5'b0 || u2_op[7:1]==7'd30 || u2_op[7:3]==3 || u2_op[7:2]==5 || u2_op[11]) || ~clkREF,
  !(u2_op[7:3]==3 || u2_op[7:2]==5 || u2_op[11]) || ~clkREF,  
  (u2_op[7:0]==`op_add64 || u2_op[7:0]==`op_sub64) && u2_op[8],
  u2_A,uu_A2,
  u2_A_fufwd,u2_A_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  rs_write_forward_ALU #(1,66) u2_B_fwd(
  clk,rst,
  !(u2_op[7:3]==5'b0 || u2_op[7:1]==7'd30) || ~clkREF2,
  (u2_op[7:3]==5'b0 || u2_op[7:1]==7'd30 || u2_op[7:3]==3 || u2_op[7:2]==5 || u2_op[11]) || ~clkREF2,
  !(u2_op[7:3]==3 || u2_op[7:2]==5 || u2_op[11]) || ~clkREF2,  
  (u2_op[7:0]==`op_add64 || u2_op[7:0]==`op_sub64) && u2_op[8],
  u2_B,uu_B2,
  u2_B_fufwd,u2_B_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  
  rs_write_forward_ALU #(0,66) u3_A_fwd(
  clk,rst,
  !(u3_op[7:3]==5'b0 || u3_op[7:1]==7'd30) || ~clkREF,
  (u3_op[7:3]==5'b0 || u3_op[7:1]==7'd30 || u3_op[7:3]==3 || u3_op[7:2]==5 || u3_op[11]) || ~clkREF,
  !(u3_op[7:3]==3 || u3_op[7:2]==5 || u3_op[11] || u3_op[7:0]==`op_cax) || ~clkREF,  
  (u3_op[7:0]==`op_add64 || u3_op[7:0]==`op_sub64) && u3_op[8],
  u3_A,uu_A3,
  u3_A_fufwd,u3_A_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  rs_write_forward_ALU #(1,66) u3_B_fwd(
  clk,rst,
  !(u3_op[7:3]==5'b0 || u3_op[7:1]==7'd30) || ~clkREF2,
  (u3_op[7:3]==5'b0 || u3_op[7:1]==7'd30 || u3_op[7:3]==3 || u3_op[7:2]==5 || u3_op[11]) || ~clkREF2,
  !(u3_op[7:3]==3 || u3_op[7:2]==5 || u3_op[11] || u3_op[7:0]==`op_cax) || ~clkREF2,  
  (u3_op[7:0]==`op_add64 || u3_op[7:0]==`op_sub64) && u3_op[8],
  u3_B,uu_B3,
  u3_B_fufwd,u3_B_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  
  rs_write_forward_ALU #(0,66) u4_A_fwd(
  clk,rst,
  !(u4_op[7:3]==5'b0 || u4_op[7:1]==7'd30) || ~clkREF,
  (u4_op[7:3]==5'b0 || u4_op[7:1]==7'd30 || u4_op[7:3]==3 || u4_op[7:2]==5 || u4_op[11]) || ~clkREF,
  !(u4_op[7:3]==3 || u4_op[7:2]==5 || u4_op[11]) || ~clkREF,  
  (u4_op[7:0]==`op_add64 || u4_op[7:0]==`op_sub64) && u4_op[8],
  u4_A,uu_A4,
  u4_A_fufwd,u4_A_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  rs_write_forward_ALU #(1,66) u4_B_fwd(
  clk,rst,
  !(u4_op[7:3]==5'b0 || u4_op[7:1]==7'd30) || ~clkREF2,
  (u4_op[7:3]==5'b0 || u4_op[7:1]==7'd30 || u4_op[7:3]==3 || u4_op[7:2]==5 || u4_op[11]) || ~clkREF2,
  !(u4_op[7:3]==3 || u4_op[7:2]==5 || u4_op[11]) || ~clkREF2,  
  (u4_op[7:0]==`op_add64 || u4_op[7:0]==`op_sub64) && u4_op[8],
  u4_B,uu_B4,
  u4_B_fufwd,u4_B_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  
  rs_write_forward_ALU #(0,66) u5_A_fwd(
  clk,rst,
  !(u5_op[7:3]==5'b0 || u5_op[7:1]==7'd30) || ~clkREF,
  (u5_op[7:3]==5'b0 || u5_op[7:1]==7'd30 || u5_op[7:3]==3 || u5_op[7:2]==5 || u5_op[11]) || ~clkREF,
  !(u5_op[7:3]==3 || u5_op[7:2]==5 || u5_op[11] || u5_op[7:0]==`op_cax) || ~clkREF,  
  (u5_op[7:0]==`op_add64 || u5_op[7:0]==`op_sub64) && u5_op[8],
  u5_A,uu_A5,
  u5_A_fufwd,u5_A_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  rs_write_forward_ALU #(1,66) u5_B_fwd(
  clk,rst,
  !(u5_op[7:3]==5'b0 || u5_op[7:1]==7'd30) || ~clkREF2,
  (u5_op[7:3]==5'b0 || u5_op[7:1]==7'd30 || u5_op[7:3]==3 || u5_op[7:2]==5 || u5_op[11]) || ~clkREF2,
  !(u5_op[7:3]==3 || u5_op[7:2]==5 || u5_op[11] || u5_op[7:0]==`op_cax) || ~clkREF2,  
  (u5_op[7:0]==`op_add64 || u5_op[7:0]==`op_sub64) && u5_op[8],
  u5_B,uu_B5,
  u5_B_fufwd,u5_B_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  
  rs_write_forward_ALU #(0,66) u6_A_fwd(
  clk,rst,
  !(u6_op[7:3]==5'b0 || u6_op[7:1]==7'd30) || ~clkREF,
  (u6_op[7:3]==5'b0 || u6_op[7:1]==7'd30 || u6_op[7:3]==3 || u6_op[7:2]==5 || u6_op[11]) || ~clkREF,
  !(u6_op[7:3]==3 || u6_op[7:2]==5 || u6_op[11]) || ~clkREF,  
  (u6_op[7:0]==`op_add64 || u6_op[7:0]==`op_sub64) && u6_op[8],
  u6_A,uu_A6,
  u6_A_fufwd,u6_A_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  rs_write_forward_ALU #(1,66) u6_B_fwd(
  clk,rst,
  !(u6_op[7:3]==5'b0 || u6_op[7:1]==7'd30) || ~clkREF2,
  (u6_op[7:3]==5'b0 || u6_op[7:1]==7'd30 || u6_op[7:3]==3 || u6_op[7:2]==5 || u6_op[11]) || ~clkREF2,
  !(u6_op[7:3]==3 || u6_op[7:2]==5 || u6_op[11]) || ~clkREF2,  
  (u6_op[7:0]==`op_add64 || u6_op[7:0]==`op_sub64) && u6_op[8],
  u6_B,uu_B6,
  u6_B_fufwd,u6_B_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );

  rs_write_forward_ALU #(0,66) u6_Am_fwd(
  clk,rst,
  !(u6_op[7:3]==5'b0 || u6_op[7:1]==7'd30) || ~clkREF,
  (u6_op[7:3]==5'b0 || u6_op[7:1]==7'd30 || u6_op[7:3]==3 || u6_op[7:2]==5 || u6_op[11]) || ~clkREF,
  !(u6_op[11]) || ~clkREF,  
  (u6_op[7:0]==`op_add64 || u6_op[7:0]==`op_sub64) && u6_op[8],
  u6_A,uu_A6m,
  u6_A_fufwd,u6_A_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  rs_write_forward_ALU #(1,66) u6_B_fwd(
  clk,rst,
  !(u6_op[7:3]==5'b0 || u6_op[7:1]==7'd30) || ~clkREF1,
  (u6_op[7:3]==5'b0 || u6_op[7:1]==7'd30 || u6_op[7:3]==3 || u6_op[7:2]==5 || u6_op[11]) || ~clkREF2,
  !(u6_op[11]) || ~clkREF2,  
  (u6_op[7:0]==`op_add64 || u6_op[7:0]==`op_sub64) && u6_op[8],
  u6_B,uu_B6m,
  u6_B_fufwd,u6_B_fuufwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  rs_writeiS_forward #(6) u1_S_fwd(
  clk,rst,
  0,
  u1_S,uu_S1,
  u1_S_fufwd_reg,u1_S_fuufwd_reg,
  FUS1,FUS1_reg,
  FUS2,FUS2_reg,
  FUS3,FUS3_reg,
  6'b0,6'b0,
  FUS4,FUS4_reg,
  FUS5,FUS5_reg,
  FUS6,FUS6_reg,
  FUS7,FUS7_reg,
  FUS8,FUS8_reg,
  FUS9,FUS9_reg
  );

  rs_writeiS_forward #(6) u2_S_fwd(
  clk,rst,
  0,
  u2_S,uu_S2,
  u2_S_fufwd_reg,u2_S_fuufwd_reg,
  FUS1,FUS1_reg,
  FUS2,FUS2_reg,
  FUS3,FUS3_reg,
  6'b0,6'b0,
  FUS4,FUS4_reg,
  FUS5,FUS5_reg,
  FUS6,FUS6_reg,
  FUS7,FUS7_reg,
  FUS8,FUS8_reg,
  FUS9,FUS9_reg
  );


  rs_writeiS_forward #(6) u3_S_fwd(
  clk,rst,
  0,
  u3_S,uu_S3,
  u3_S_fufwd_reg,u3_S_fuufwd_reg,
  FUS1,FUS1_reg,
  FUS2,FUS2_reg,
  FUS3,FUS3_reg,
  6'b0,6'b0,
  FUS4,FUS4_reg,
  FUS5,FUS5_reg,
  FUS6,FUS6_reg,
  FUS7,FUS7_reg,
  FUS8,FUS8_reg,
  FUS9,FUS9_reg
  );


  rs_writeiS_forward #(6) u4_S_fwd(
  clk,rst,
  0,
  u4_S,uu_S4,
  u4_S_fufwd_reg,u4_S_fuufwd_reg,
  FUS1,FUS1_reg,
  FUS2,FUS2_reg,
  FUS3,FUS3_reg,
  6'b0,6'b0,
  FUS4,FUS4_reg,
  FUS5,FUS5_reg,
  FUS6,FUS6_reg,
  FUS7,FUS7_reg,
  FUS8,FUS8_reg,
  FUS9,FUS9_reg
  );


  rs_writeiS_forward #(6) u5_S_fwd(
  clk,rst,
  0,
  u5_S,uu_S5,
  u5_S_fufwd_reg,u5_S_fuufwd_reg,
  FUS1,FUS1_reg,
  FUS2,FUS2_reg,
  FUS3,FUS3_reg,
  6'b0,6'b0,
  FUS4,FUS4_reg,
  FUS5,FUS5_reg,
  FUS6,FUS6_reg,
  FUS7,FUS7_reg,
  FUS8,FUS8_reg,
  FUS9,FUS9_reg
  );


  rs_writeiS_forward #(6) u6_S_fwd(
  clk,rst,
  0,
  u6_S,uu_S6,
  u6_S_fufwd_reg,u6_S_fuufwd_reg,
  FUS1,FUS1_reg,
  FUS2,FUS2_reg,
  FUS3,FUS3_reg,
  6'b0,6'b0,
  FUS4,FUS4_reg,
  FUS5,FUS5_reg,
  FUS6,FUS6_reg,
  FUS7,FUS7_reg,
  FUS8,FUS8_reg,
  FUS9,FUS9_reg
  );


  pwire p0_sec_in;
  pwire p1_sec_in;
  pwire p2_sec_in;

  alu alu0(clk,rst,except,1'b0,1'b0,u1_op_reg[12:0],u1_op_reg[17:13],u1_isSub_reg,u1_clkEn_reg,1'b1,
    u1_ret,u1_rten,uu_A1,uu_B1,uu_S1,FU4,p0_sec_in,u1_error_reg,{2'b11,~u1_isSub_reg[1]});
  alu #(1'b0)  alu1(clk,rst,except,1'b0,1'b0,u2_op_reg[12:0],u2_op_reg[17:13],u2_isSub_reg,,u2_clkEn_reg,1'b1,
    u2_ret,u2_rten,uu_A2,uu_B2,uu_S2,FU7,1'b1,u2_error_reg,u2_rmode_reg);
  
  alu alu2(clk,rst,except,1'b0,1'b0,u3_op_reg[12:0],u3_op_reg[17:13],u3_isSub_reg,,u3_clkEn_reg,1'b1,
    u3_ret,u3_rten,uu_A3,uu_B3,uu_S3,FU5,p1_sec_in,u3_error_reg,{2'b11,~u3_isSub_reg[1]});
  alu #(1'b0)  alu3(clk,rst,except,1'b0,1'b0,u4_op_reg[12:0],u4_op_reg[17:13],u4_isSub_reg,,u4_clkEn_reg,1'b1,
    u4_ret,u4_rten,uu_A4,uu_B4,uu_S4,FU8,1'b1,u4_error_reg,u4_rmode_reg);
  
  alu alu4(clk,rst,except,1'b0,1'b0,u5_op_reg[12:0],u5_op_reg[17:13],u5_isSub_reg,,u5_clkEn_reg,u5_nDataAlt&&(&nDataAlt),
    u5_ret,u5_rten,uu_A5,uu_B5,uu_S5,FU6,p2_sec_in,u5_error_reg,{2'b11,~u5_isSub_reg[1]});
  alu #(1'b0)  alu5(clk,rst,except,1'b0,1'b0,u6_op_reg[12:0],u6_op_reg[17:13],u6_isSub_reg,u6_clkEn_reg,1'b1,
    u6_ret,u6_rten,uu_A6,uu_B6,uu_S6,FU9,1'b1,u6_error_reg,u6_rmode_reg);

 alu_shift sh1_alu(
  clk,
  rst,
  except,
  1'b0,
  u1_op_reg[12:0],u1_op_reg[17:13],
  u1_sz,{1'b0,u1_sz[3],1'b1,1'b0},u1_arith,u1_dir,
  u1_clkEn_reg,
  1'b1,
  u1_ret,
  uu_S1,
  uu_A1[2],
  uu_B1[2],
  FU6,
  u1_error_reg,
  u1_rmode_reg
  );

  alu_shift sh2_alu(
  clk,
  rst,
  except,
  1'b0,
  u2_op_reg[12:0],u2_op_reg[17:13],
  u2_sz,{1'b0,u2_sz[3],1'b1,1'b0},u2_arith,u2_dir,
  u2_clkEn_reg,
  1'b1,
  u2_ret,
  uu_S2,
  uu_A2[2],
  uu_B2[2],
  FU7,
  u2_error_reg,
  u2_rmode_reg
  );
  alu_shift sh3_alu(
  clk,
  rst,
  except,
  1'b0,
  u3_op_reg[12:0],u3_op_reg[17:13],
  u3_sz,{1'b0,u3_sz[3],1'b1,1'b0},u3_arith,u3_dir,
  u3_clkEn_reg,
  1'b1,
  u3_ret,
  uu_S3,
  uu_A3[2],
  uu_B3[2],
  FU7,
  u3_error_reg,
  u3_rmode_reg
  );

  alu_shift sh4_alu(
  clk,
  rst,
  except,
  1'b0,
  u4_op_reg[12:0],u4_op_reg[17:13],
  u4_sz,{1'b0,u4_sz[3],1'b1,1'b0},u4_arith,u4_dir,
  u4_clkEn_reg,
  1'b1,
  u4_ret,
  uu_S4,
  uu_A4[2],
  uu_B4[2],
  FU8,
  u4_error_reg,
  u4_rmode_reg
  );
alu_shift sh5_alu(
  clk,
  rst,
  except,
  1'b0,
  u5_op_reg[12:0],u5_op_reg[17:13],
  u5_sz,{1'b0,u5_sz[3],1'b1,1'b0},u5_arith,u5_dir,
  u5_clkEn_reg,
  1'b1,
  u5_ret,
  uu_S5,
  uu_A5[2],
  uu_B5[2],
  FU8,
  u5_error_reg,
  u5_rmode_reg//u4_rmode_reg
  );
  alu_shift sh6_alu(
  clk,
  rst,
  except,
  1'b0,
  u6_op_reg[12:0],u6_op_reg[17:13],
  u6_sz,{1'b0,u6_sz[3],1'b1,1'b0},u6_arith,u6_dir,
  u6_clkEn_reg,
  1'b1,
  u6_ret,
  uu_S6,
  uu_A6[2],
  uu_B6[2],
  FU9,
  u6_error_reg,
  u6_rmode_reg//u4_rmode_reg
  );
  
  ifconv_mod g2fp_mod(
  .clk(clk),
  .rst(rst),
  .clkEn(~(|fxFRT_alten_reg3)),
  .A(uu_B6[63:0]),
  .en(u6_op_reg[11] && u6_clkEn_reg && ((u6_op_reg[7:0]==`op_cvtD) ||
    (u6_op_reg[7:0]==`op_cvtE) || (u6_op_reg[7:0]==`op_cvtS))),
  .toDBL(u6_op_reg[7:0]!=`op_cvtE && u6_op_reg[7:0]!=`op_cvtS),
  .toEXT(u6_op_reg[7:0]==`op_cvtE),
  .toSNG(u6_op_reg[7:0]==`op_cvtS),
  .isS(u6_op_reg[10]),
  .res(FUCVT2_0),
  .rtyp(FUTYPE_0),
  .alt(DataAlt[1])
  );

  assign fcvtout={FUCVT2_0[81:66],FUTYPE_0,FUCVT2_0[65:0]};
  
  
  assign FU6=(~&nDataAlt) ? FUMUL1_reg : 65'bz;
  assign FU6=(~u5_nDataAlt) ? {1'b0,FUCVTIN1} : 65'bz;
  assign FU7=(~&nDataAlt) ? FUMUL2_reg : 65'bz;
  assign FU7=(~u5_nDataAlt) ? {1'b0,FUCVTIN2} : 65'bz;
  assign FU8=(~&nDataAlt) ? FUMUL3_reg : 65'bz;
  assign FU8=(~u5_nDataAlt) ? {1'b0,FUCVTIN3} : 65'bz;

 
  
  assign u5_ret=(~u5_nDataAlt_reg|(~nDataAlt_reg[1])) ? {6'b0,1'b0,2'd2} : 
    9'bz; 
  assign u5_ret=u5_nDataAlt_reg&~nDataAlt_reg[0] ? {MULFL_reg,~u6_op_reg4[12],
    2'd2} : 9'bz; 
  assign u5_rten=(~u5_nDataAlt_reg|(~&nDataAlt_reg)) ? 1'b1 : 
    1'bz; 
  
  reg [2:2][64:0] u6_A6m_reg;
  reg [2:2][64:0] u6_B6m_reg;
 
  imul imul_mod(
  .clk(clk),
  .rst(rst),
  .clkEn(~(|fxFRT_alten_reg3)),
  .op_prev(u6_op[12:0]),
  .alt_jxcross(),
  .jxcross(H ? jxcross : uu_B6m_reg[2]),
  .rmode(u6_rmode_reg),
  .en(u6_clkEn_reg && u6_op_reg[11] && (u6_op_reg[7:0]==1 || u6_op_reg[7:0]
    ==2 || u6_op_reg[7:0]==3 || u6_op_reg[7:0]==9 || u6_op_reg[7:0]==10 ||
    u6_op_reg[7:0]==11 || u6_op_reg[7:0]==5 || u6_op_reg[7:0]==7)),  
  .R(uu_A6m[2]),.C(uu_B6m[2]),
  .attr(u6_attr_reg),
  .alt(DataAlt[0]),
  .Res(FUMUL),
  .flg(MULFL)
 );
  imul imul2_mod(
  .clk(clk),
  .rst(rst),
  .clkEn(~(|fxFRT_alten2_reg3)),
  .op_prev(u5_op[12:0]),
  .alt_jxcross(),
  .jxcross(H ? jxcross2 : uu_B5m_reg[2]),
  .rmode(u5_rmode_reg),
  .en(u5_clkEn_reg && u5_op_reg[11] && (u5_op_reg[7:0]==1 || u5_op_reg[7:0]
    ==2 || u5_op_reg[7:0]==3 || u5_op_reg[7:0]==9 || u5_op_reg[7:0]==10 ||
    u5_op_reg[7:0]==11 || u5_op_reg[7:0]==5 || u5_op_reg[7:0]==7)),  
  .R(uu_A5m[2]),.C(uu_B5m[2]),
  .attr(u5_attr_reg),
  .alt(DataAlt2[0]),
  .Res(FUMUL2),
  .flg(MULFL2)
 );
imul_gatheronly imul3_mod(
  .clk(clk),
  .rst(rst),
  .clkEn(~(|fxFRT3_alten_reg3)),
  .op_prev(u4_op[12:0]),
  .alt_jxcross(),
  .jxcross(H ? jxcross3 : uu_B4m_reg[2]),
  .rmode(u4_rmode_reg),
  .en(u4_clkEn_reg && u4_op_reg[11] && (u4_op_reg[7:0]==1 || u4_op_reg[7:0]
    ==2 || u4_op_reg[7:0]==3 || u4_op_reg[7:0]==9 || u4_op_reg[7:0]==10 ||
    u4_op_reg[7:0]==11 || u4_op_reg[7:0]==5 || u4_op_reg[7:0]==7)),  
  .R(uu_A4m[2]),.C(uu_B4m[2]),
  .attr(u4_attr_reg),
  .alt(DataAlt3[0]),
  .Res(FUMUL3),
  .flg(MULFL3)
 );
   
 assign allah=uu_A6m_reg[2];

  always @(posedge clk) begin

      u6_attr_reg<=u6_attr;

      uu_A6M_reg[2]<=uu_A6M[2];
      uu_B6m_reg[2]<=uu_B6m[2];

      FUMUL_reg<=FUMUL;
      MULFL_reg<=MULFL;

      FU0_reg<=FU0;
      FU1_reg<=FU1;
      FU2_reg<=FU2;
      FU3_reg<=FU3;
      FU4_reg<=FU4;
      FU5_reg<=FU5;
      FU6_reg<=FU6;
      FU7_reg<=FU7;
      FU8_reg<=FU8;
      FU9_reg<=FU9;
      
      FUS1_reg<=FUS1;
      FUS2_reg<=FUS2;
      FUS3_reg<=FUS3;
      FUS4_reg<=FUS4;
      FUS5_reg<=FUS5;
      FUS6_reg<=FUS6;
      FUS7_reg<=FUS7;
      FUS8_reg<=FUS8;
      FUS9_reg<=FUS9;

      u1_clkEn_reg<=u1_clkEn;
      u2_clkEn_reg<=u2_clkEn;
      u3_clkEn_reg<=u3_clkEn;
      u4_clkEn_reg<=u4_clkEn;
      u5_clkEn_reg<=u5_clkEn;
      u6_clkEn_reg<=u6_clkEn;

      u1_error_reg<=u1_error;
      u2_error_reg<=u2_error;
      u3_error_reg<=u3_error;
      u4_error_reg<=u4_error;
      u5_error_reg<=u5_error;
      u6_error_reg<=u6_error;

      u1_op_reg<=u1_op;
      u2_op_reg<=u2_op;
      u3_op_reg<=u3_op;
      u4_op_reg<=u4_op;
      u5_op_reg<=u5_op;
      u6_op_reg<=u6_op;
      u6_op_reg2<=u6_op_reg[12:0];
      u6_op_reg3<=u6_op_reg2;
      u6_op_reg4<=u6_op_reg3;

      u1_S_fufwd_reg<= u1_S_fufwd;
      u1_S_fuufwd_reg<=u1_S_fuufwd;
      u2_S_fufwd_reg<= u2_S_fufwd;
      u2_S_fuufwd_reg<=u2_S_fuufwd;
      u3_S_fufwd_reg<= u3_S_fufwd;
      u3_S_fuufwd_reg<=u3_S_fuufwd;
      u4_S_fufwd_reg<= u4_S_fufwd;
      u4_S_fuufwd_reg<=u4_S_fuufwd;
      u5_S_fufwd_reg<= u5_S_fufwd;
      u5_S_fuufwd_reg<=u5_S_fuufwd;
      u6_S_fufwd_reg<= u6_S_fufwd;
      u6_S_fuufwd_reg<=u6_S_fuufwd;
      
      u1_const_reg<=u1_const;
      u3_const_reg<=u3_const;
      u5_const_reg<=u5_const;
      
      u1_sh_reg<=1'b1<<u1_op[9:8];
      u1_sh2_reg<=u1_op[9:8];
      u3_sh_reg<=1'b1<<u3_op[9:8];
      u3_sh2_reg<=u3_op[9:8];
      u5_sh_reg<=1'b1<<u5_op[9:8];
      u5_sh2_reg<=u5_op[9:8];

      u1_eaen_reg<=u1_op[7:0]==`op_cax;
      u3_eaen_reg<=u3_op[7:0]==`op_cax;
      u5_eaen_reg<=u5_op[7:0]==`op_cax;

      if(u2_op==`op_shl64 || u2_op==`op_shr64 || u2_op==`op_sar64)
          u2_sz<=4'b1000; else u2_sz<=4'b0100;
      if(u4_op==`op_shl64 || u4_op==`op_shr64 || u4_op==`op_sar64)
          u4_sz<=4'b1000; else u4_sz<=4'b0100;
      if(u6_op==`op_shl64 || u6_op==`op_shr64 || u6_op==`op_sar64)
          u6_sz<=4'b1000; else u6_sz<=4'b0100;
      u2_arith<=u2_op==`op_sar64 || u2_op==`op_sar32;
      u4_arith<=u4_op==`op_sar64 || u4_op==`op_sar32;
      u6_arith<=u6_op==`op_sar64 || u6_op==`op_sar32;
      u2_dir<=u2_op!=`op_shl64 && u2_op!=`op_shl32;
      u4_dir<=u4_op!=`op_shl64 && u4_op!=`op_shl32;
      u6_dir<=u6_op!=`op_shl64 && u6_op!=`op_shl32;
      fxFRT_alten_reg2<=fxFRT_alten_reg;
      fxFRT_alten_reg3<=fxFRT_alten_reg2;
      u6_ret_reg<=u6_ret;
      u6_ret_reg2<=u6_ret_reg;
      u6_ret_reg3<=u6_ret_reg2;
      nDataAlt<=~DataAlt;
      nDataAlt_reg<=nDataAlt;
      u5_nDataAlt_reg<=u5_nDataAlt;
      if (u1_op[7:1]==30) begin
	  u1_isSub_reg[0]=u1_op[0] && ~u1_op[8];
	  u1_isSub_reg[1]=~u1_op[0] && ~u1_op[8];
	  u1_isSub_reg[2]=u1_op[8];
	  u1_isSub_reg[3]=u1_op[9] && ~u1_op[10];
	  u1_isSub_reg[4]=~u1_op[9] && ~u1_op[10];
	  u1_isSub_reg[5]=u1_op[10];
      end else begin
	  u1_isSub_reg[0]=u1_op[7:0]!=`op_sub64 && u1_op[7:0]!=`op_sub32  && u1_op[7:0]!=`op_cmp16 && u1_op[7:0]!=`op_cmp8;
	  u1_isSub_reg[1]=u1_op[7:0]==`op_sub64 || u1_op[7:0]==`op_sub32  || u1_op[7:0]==`op_cmp16 || u1_op[7:0]==`op_cmp8;
	  u1_isSub_reg[2]=1'b0;
	  u1_isSub_reg[5:3]=3'd1;
      end
      if (u2_op[7:1]==30) begin
	  u2_isSub_reg[0]=u2_op[0] && ~u2_op[8];
	  u2_isSub_reg[1]=~u2_op[0] && ~u2_op[8];
	  u2_isSub_reg[2]=u2_op[8];
	  u2_isSub_reg[3]=u2_op[9] && ~u2_op[10];
	  u2_isSub_reg[4]=~u2_op[9] && ~u2_op[10];
	  u2_isSub_reg[5]=u2_op[10];
      end else begin
	  u2_isSub_reg[0]=u2_op[7:0]!=`op_sub64 && u2_op[7:0]!=`op_sub32 && u2_op[7:0]!=`op_cmp16 && u2_op[7:0]!=`op_cmp8;
	  u2_isSub_reg[1]=u2_op[7:0]==`op_sub64 || u2_op[7:0]==`op_sub32  || u2_op[7:0]==`op_cmp16 || u2_op[7:0]==`op_cmp8;
	  u2_isSub_reg[2]=1'b0;
	  u2_isSub_reg[5:3]=3'd1;
      end
      if (u3_op[7:1]==30) begin
	  u3_isSub_reg[0]=u3_op[0] && ~u3_op[8];
	  u3_isSub_reg[1]=~u3_op[0] && ~u3_op[8];
	  u3_isSub_reg[2]=u3_op[8];
	  u3_isSub_reg[3]=u3_op[9] && ~u3_op[10];
	  u3_isSub_reg[4]=~u3_op[9] && ~u3_op[10];
	  u3_isSub_reg[5]=u3_op[10];
      end else begin
	  u3_isSub_reg[0]=u3_op[7:0]!=`op_sub64 && u3_op[7:0]!=`op_sub32 && u3_op[7:0]!=`op_cmp16 && u3_op[7:0]!=`op_cmp8;
	  u3_isSub_reg[1]=u3_op[7:0]==`op_sub64 || u3_op[7:0]==`op_sub32 || u3_op[7:0]==`op_cmp16 || u3_op[7:0]==`op_cmp8;
	  u3_isSub_reg[2]=1'b0;
	  u3_isSub_reg[5:3]=3'd1;
      end
      if (u4_op[7:1]==30) begin
	  u4_isSub_reg[0]=u4_op[0] && ~u4_op[8];
	  u4_isSub_reg[1]=~u4_op[0] && ~u4_op[8];
	  u4_isSub_reg[2]=u4_op[8];
	  u4_isSub_reg[3]=u4_op[9] && ~u4_op[10];
	  u4_isSub_reg[4]=~u4_op[9] && ~u4_op[10];
	  u4_isSub_reg[5]=u4_op[10];
      end else begin
	  u4_isSub_reg[0]=u4_op[7:0]!=`op_sub64 && u4_op[7:0]!=`op_sub32 && u4_op[7:0]!=`op_cmp16 && u4_op[7:0]!=`op_cmp8;
	  u4_isSub_reg[1]=u4_op[7:0]==`op_sub64 || u4_op[7:0]==`op_sub32  || u4_op[7:0]==`op_cmp16 || u4_op[7:0]==`op_cmp8;
	  u4_isSub_reg[2]=1'b0;
	  u4_isSub_reg[5:3]=3'd1;
      end
      if (u5_op[7:1]==30) begin
	  u5_isSub_reg[0]=u5_op[0] && ~u5_op[8];
	  u5_isSub_reg[1]=~u5_op[0] && ~u5_op[8];
	  u5_isSub_reg[2]=u5_op[8];
	  u5_isSub_reg[3]=u5_op[9] && ~u5_op[10];
	  u5_isSub_reg[4]=~u5_op[9] && ~u5_op[10];
	  u5_isSub_reg[5]=u5_op[10];
      end else begin
	  u5_isSub_reg[0]=u5_op[7:0]!=`op_sub64 && u5_op[7:0]!=`op_sub32 && u5_op[7:0]!=`op_cmp16 && u5_op[7:0]!=`op_cmp8;
	  u5_isSub_reg[1]=u5_op[7:0]==`op_sub64 || u5_op[7:0]==`op_sub32 || u5_op[7:0]==`op_cmp16 || u5_op[7:0]==`op_cmp8;
	  u5_isSub_reg[2]=1'b0;
	  u5_isSub_reg[5:3]=3'd1;
      end
      if (u6_op[7:1]==30) begin
	  u6_isSub_reg[0]=u6_op[0] && ~u6_op[8];
	  u6_isSub_reg[1]=~u6_op[0] && ~u6_op[8];
	  u6_isSub_reg[2]=u6_op[8];
	  u6_isSub_reg[3]=u6_op[9] && ~u6_op[10];
	  u6_isSub_reg[4]=~u6_op[9] && ~u6_op[10];
	  u6_isSub_reg[5]=u6_op[10];
      end else begin
	  u6_isSub_reg[0]=u6_op[7:0]!=`op_sub64 && u6_op[7:0]!=`op_sub32 && u6_op[7:0]!=`op_cmp16 && u6_op[7:0]!=`op_cmp8;
	  u6_isSub_reg[1]=u6_op[7:0]==`op_sub64 || u6_op[7:0]==`op_sub32  || u6_op[7:0]==`op_cmp16 || u6_op[7:0]==`op_cmp8;
	  u6_isSub_reg[2]=1'b0;
	  u6_isSub_reg[5:3]=3'd1;
      end
      u2_rmode_reg<=u2_op[20:18]^{2'b0,u2_isSub_reg[1]};
      u4_rmode_reg<=u4_op[20:18]^{2'b0,u4_isSub_reg[1]};
      u5_rmode_reg<=u6_op[20:18]^{2'b0,u6_isSub_reg[1]};
  end
endmodule

