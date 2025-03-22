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




module alu_shift(
  clk,
  rst,
  except,
  except_thread,
  operation,
  cond,
  sz,bit_en,arith,dir,
  dataEn,
  nDataAlt,
  retData,
  valS,
  val1,
  val2,
  valRes,
  error,
  rmode
  );

  parameter REG_WIDTH=`reg_addr_width;
  parameter OPERATION_WIDTH=`operation_width;
  parameter EXCEPT_WIDTH=9;
  
  input clk;
  input rst;
  input except;
  input except_thread;
  input [OPERATION_WIDTH-1:0] operation;
  input [4:0] cond;
  input [3:0] sz;
  input [3:0] bit_en;
  input arith;
  input dir;
  input dataEn;//1=coming data from rs
  input nDataAlt;//0=feeding data through multiclk unit
  output wire [EXCEPT_WIDTH-1:0] retData;
  input [5:0] valS;
  input [2:0][65:0] val1;
  input [2:0][65:0] val2;
  output [65:0] valRes;
  input error;
  input [2:0] rmode;
  
  wire is_shift;
  wire [64:0] en;
  wire is_8H;
  wire doJmp;
  wire [64:0] valres0;
  wire [7:0] valres1;  
  reg is_shift_reg;
  reg [3:0] coutL_reg;
  reg coutR_reg;
  reg [64:0] valres0_reg;
  reg dir_reg;
  wire coutR;
  wire [3:0] coutL;
  wire [5:0] flags_COASZP;
  reg [3:0] sz_reg;

  wire [64:0] valX;

  assign valX[31:0]=val2[11] ? val1[31:0] : 32'b0;
  assign valX[63:32]=32'b0;
 
  assign is_shift=(operation[7:2]==6'd5 || operation[7:2]==6'd6 || operation[7:2]==6'd7) && nDataAlt && ~operation[11];
  
  shlr #(64) main_shift_right_mod(
  bit_en,
  {4'h8},
  dir|val2[12],
  arith|val2[13],
  val1[2][63:0],
  val2[2][5:0],
  valres0,
  coutR,
  coutL
  );
  
  except_jump_cmp jcmp_mod (valS,{1'b0,cond[3:0]},doJmp);

  generate
    genvar k;
    for(k=0;k<63;k=k+1) begin
        assign valRes[k]=is_shift & ~(cond[4]&~doJmp) & en[k] ? valres0[k] : 1'bz;
        assign valRes[k]=is_shift & ~(cond[4]&~doJmp) & ~en[k] ? valX[k] : 1'bz;
    end
  endgenerate
  assign valRes[64]=is_shift ? 1'b0 : 1'bz;
  assign valRes[65]=is_shift ? ^valRes[64:0] : 1'bz;

  assign en[63:32]={arith,{31{sz[3]}};
  assign en[31:24]=(val2[31:24]&{8{rmode==3'b100}})|{8{rmode==3'b0}};
  assign en[23:16]=(val2[23:16]&{8{rmode==3'b100 || rmode==3'b010}})|{8{rmode==3'b0}};
  assign en[15:8]=(val2[31:24]&{8{rmode==3'b10 || rmode==3'b1}})|{8{rmode==3'b0}};
  assign en[7:0]=(val2[23:16]&{8{rmode==3'b1}})|{8{rmode==3'b0}};

  assign retData[`except_flags]=is_shift_reg ? flags_COASZP : 6'bz;

  assign flags_COASZP=error ? 6'bz : { dir_reg ? coutR_reg : ((coutL_reg&sz_reg)!=0),1'b0,1'b0,
	  sz_reg[3] ? valres0_reg[63] : valres0_reg[31],~(|valres0_reg[31:0])&&
          (~sz_reg[3]||~(|valres0_reg[63:32])),1'b0};
`ifndef aluneg
  always @(posedge clk) begin
`else
  always @(negedge clk) begin
`endif
      is_shift_reg<=is_shift;
      coutL_reg<=coutL;
      coutR_reg<=coutR;
      valres0_reg<=valres0;
      dir_reg<=dir;
      sz_reg<=sz;
  end
endmodule





