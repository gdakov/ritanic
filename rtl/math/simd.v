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
`include "../intop.v"



module simd_non_socialiste(
  clk,
  rst,
  en,
  operation,
  A,
  B,
  res
  );
  input pwire clk;
  input pwire rst;
  input pwire en;
  input pwire [12:0] operation;
  input pwire [67:0] A;
  input pwire [67:0] B;
  output pwire [67:0] res;
  
  pwire [67:0] res_X;
  assign res=res_X;

  reg out8,out16,out32,out64,outL;
  pwire [4:1][63:0] resD;
  reg  [4:1][63:0] resD_reg;
  reg is_sign,is_sat,is_min,is_max,is_sub,is_simpl,is_subcmp,is_cmp;
  reg [3:0] jump_type;
  reg[63:0] A_reg;
  reg[63:0] B_reg;
  reg [64:0] resL;
  reg [12:0] operation_reg;
  reg shSH_reg;
  pwire shSH;
  reg [64:0] resSH_reg;
  pwire [64:0] resSH;
  reg en_reg;
  reg en_reg2;
  pwire [64:0] resh;

  assign resh=out32&~outL ? resD_reg[3] : 64'bz;
  assign resh=out64&outL ? resD_reg[4] : 64'bz;
  assign resh=outL ? resL : 64'bz;
  

  assign res_X=en_reg2 ? {2'd`ptype_int,1'b0,resh[63:32],1'b0,resh[31:0]} : 68'bz;
  generate
      genvar d;
      for(d=0;d<16;d=d+1) begin
          if (d<8) begin
              sub_sat #(8) 
add32_mod(A_reg[d*8+:8],B_reg[d*8+:8],resD[3][d*8+:8],is_sign,is_sat,is_min,is_max,
	        is_sub,is_simpl,is_subcmp,is_cmp,jump_type);
              pwire signed [7:0] A_op;
              pwire signed [7:0] B_op;
              pwire signed [15:0] C_op;
              assign C_op=A_op*B_op;
              assign A_op=A_reg[d*8+:8];
              assign B_op=B_reg[d*8+:8];
              assign resD[1][d*8+:8]=C_op[11:4];
          end
          if (d<16) begin
              mul_sat #(4) 
add64_mod(A_reg[d*4+:4],B_reg[d*4+:4],resD[4][d*4+:4],is_sign,is_sat,is_min,is_max,
	        is_sub,is_simpl,is_subcmp,is_cmp,jump_type);
              pwire signed [3:0] A_op;
              pwire signed [3:0] B_op;
              pwire signed [7:0] C_op;
              assign C_op=A_op*B_op;
              assign A_op=A_reg[d*4+:4];
              assign B_op=B_reg[d*4+:4];
              assign resD[1][d*8+:8]=C_op[5:2];
          end
      end
  endgenerate
  `ifndef swapedge
  always @(negedge clk) begin
  `else
  always @(posedge clk) begin
  `endif
      A_reg<={A[64:33],A[31:0]};
      B_reg<={B[64:33],B[31:0]};
      is_sign<=operation[5:0]==`simd_paddsats ||operation[5:0]==`simd_psubsats||operation[5:0]==`simd_pmins||
        operation[5:0]==`simd_pmaxs;
      is_sat<=operation[5:0]==`simd_paddsats || operation[5:0]==`simd_psubsats ||operation[5:0]==`simd_paddsat||
        operation[5:0]==`simd_psubsat;
      is_min<=operation[5:0]==`simd_pmins || operation[5:0]==`simd_pmin;
      is_max<=operation[5:0]==`simd_pmaxs || operation[5:0]==`simd_pmax;
      is_sub<=operation[5:0]==`simd_psubsats ||operation[5:0]==`simd_psubsat|| operation[5:0]==`simd_psub;
      is_simpl<=operation[5:0]==`simd_psub || operation[5:0]==`simd_padd;
      is_subcmp=operation[5:0]==`simd_psub || operation[5:0]==`simd_cmp || operation[5:0]==`simd_psubsats ||
        operation[5:0]==`simd_psubsat || operation[5:0]==`simd_pmins ||operation[5:0]==`simd_pmaxs||operation[5:0]
	==`simd_pmin||operation[5:0]==`simd_pmax;
      is_cmp<=operation[5:0]==`simd_cmp;
      jump_type<={operation[12],operation[9:8],1'b0};
      resD_reg[1]<=resD[1];
      resD_reg[2]<=resD[2];
      resD_reg[3]<=operation_reg[7] ? resD[1] : resD[3];
      resD_reg[4]<=operation_reg[7] ? resD[2] : resD[4];
      operation_reg<=operation;
      out8<=1'b0;
      out16<=1'b0;
      out32<=operation_reg[6];
      out64<=~operation_reg[6];
      outL<=1'b1;
      shSH_reg<=1'b0;
      resSH_reg<='0;
      if (rst) begin
	  en_reg<=1'b0;
	  en_reg2<=1'b0;
      end else begin
          en_reg<=en;
          en_reg2<=en_reg;
      end
      case(operation_reg[7:0])
      `simd_pand: resL<=A_reg & B_reg;
      `simd_por: resL<=A_reg | B_reg;
      `simd_pxor: resL<=A_reg ^ B_reg;
      `simd_pnand: resL<=A_reg & ~B_reg;
      `simd_pnor: resL<=~(A_reg | B_reg);
      `simd_pnxor: resL<=A_reg ~^ B_reg;
      `simd_pmov,8'hff: resL<=B_reg;
      `simd_pnot:resL<=~B_reg;
      default: outL<=1'b0;
      endcase
  end
endmodule


