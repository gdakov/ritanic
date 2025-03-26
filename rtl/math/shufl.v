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


module fperm(
  clk,
  rst,
  en,
  copyA,
//  copyB,
  swpSngl,
  dupSngl,
  is_sqrt,
  is_div,
  tbl_read,
  tbl_write,
  xtra,
  A,B,
  res);
  parameter C=1'b0;
  input pwire clk;
  input pwire rst;
  input pwire en;
  input pwire copyA;
  input pwire swpSngl;
  input pwire dupSngl;
  input pwire is_sqrt;
  input pwire is_div;
  input pwire tbl_read;
  input pwire tbl_write;
  input pwire [2:0] xtra;
  input pwire [67:0] A;
  input pwire [67:0] B;
  output pwire [67:0] res;

  localparam [11:0] BIAS_D=12'd2047;
  localparam [8:0] BIAS_S=9'd255;

  pwire [67:0] resX;
  pwire [67:0] resY;
  pwire [67:0] res0;
  reg [67:0] res0_reg;
  reg [67:0] res0_reg2;
  reg [67:0] res0_reg3;
  reg en_reg,en_reg2,en_reg3;

  pwire [11:0] exp_D;
  pwire [8:0] exp_X1;
  pwire [8:0] exp_X;

  pwire [11:0] df;
  pwire df_has;
  pwire [8:0] dsf0;
  pwire dsf0_has;
  pwire [8:0] dsf1;
  pwire dsf1_has;
  pwire [11:0] valDF;
  pwire [11:0] expDF;
  pwire [8:0] valDSF0;
  pwire [8:0] expDSF0;
  pwire [8:0] valDSF1;
  pwire [8:0] expDSF1;

  bit_find_last_bit #(12) dblF({B[63],B[65],B[62:53]},df,df_has);
  bit_find_last_bit #(9) snglF0({B[63],B[65],B[62:56]},dsf0,dsf0_has);
  bit_find_last_bit #(9) snglF1({B[30],B[32],B[29:23]},dsf1,dsf1_has);

  generate
    if (!C) begin
        assign res=en_reg? res0_reg : 68'bz;
    end else begin
        assign res=en_reg2? res0 : 68'bz;
        tblD tbl_mod(
        clk,
        rst,
        A,
        B,
        xtra,
        tbl_read,
        tbl_write,
        resY);
    end
    genvar k;
    for(k=0;k<12;k=k+1) begin : shf
        assign valDF=df[k] ? {B[63],B[65],B[62:53]}<<(11-k) : 12'bz;
        assign expDF=df[k] ? k-BIAS_D : 12'bz;
        if (k<9) begin
            assign valDSF0=dsf0[k] ? {B[63],B[65],B[62:56]}<<(8-k) : 9'bz;
            assign expDSF0=dsf0[k] ? k-BIAS_S : 9'bz;
            assign valDSF1=dsf1[k] ? {B[30],B[32],B[29:23]}<<(8-k) : 9'bz;
            assign expDSF1=dsf1[k] ? k-BIAS_S : 9'bz;
        end
    end
  endgenerate
  assign valDF=df_has[k] ? 12'bz : 12'b0;
  assign expDF=df_has ? 12'bz : 0;
  assign valDSF0=dsf0_has[k] ? 9'bz : 9'b0;
  assign expDSF0=dsf0_has ? 9'bz : 9'b0;
  assign valDSF1=dsf1_has[k] ? 9'bz : 9'b0;
  assign expDSF1=dsf1_has ? 9'bz : 9'b0;
  
  adder #(12) add_dbla(BIAS_D<<1,~{B[63],B[65],B[62:53]},exp_D,1'b1,is_sqrt,,,,);
  adder #(12) add_dblb(BIAS_D<<1,~{1'b0,B[63],B[65],B[62:54]},exp_D,1'b1,~is_sqrt,,,,);
  adder #(9) add_snga(BIAS_S<<1,~{B[63],B[65],B[62:56]},exp_X,1'b1,is_sqrt,,,,);
  adder #(9) add_sngb(BIAS_S<<1,~{1'b0,B[63],B[65],B[62:57]},exp_X,1'b1,~is_sqrt,,,,);
  adder #(9) add_sngc(BIAS_S<<1,~{B[30],B[32],B[29:23]},exp_X1,1'b1,is_sqrt,,,,);
  adder #(9) add_sngd(BIAS_S<<1,~{1'b0,B[30],B[32],B[29:24]},exp_X1,1'b1,~is_sqrt,,,,);

  assign resY=A[67:66]==`ptype_dbl && ~tbl_read && ~(is_sqrt&is_div) ? {B[67:66],exp_D[10],B[63],exp_D[11],exp_D[9:0],53'b0} : 68'bz;
  assign resY=A[67:66]!=`ptype_dbl && ~tbl_read && ~(is_sqrt&is_div) ? {B[67:66],exp_X[7],B[63],exp_X[8],exp_X[6:0],23'b0,
    exp_X1[7],B[31],exp_X1[8],exp_X1[6:0],23'b0} : 68'bz;
  assign resY=A[67:66]==`ptype_dbl && ~tbl_read && (is_sqrt&is_div) ? {B[67:66],expDF[10],1'b0,expDF[11],expDF[9:0],valDF,41'b0} : 68'bz;
  assign resY=A[67:66]!=`ptype_dbl && ~tbl_read && (is_sqrt&is_div) ? {B[67:66],expDSF0[7],1'b0,expDSF0[8],expDSF0[6:0],valDSF0,14'b0,
    expDSF1[7],1'b0,expDSF[8],expDSF1[6:0],valDSF1,14'b0} : 68'bz;

  assign resX=(copyA & ~swpSngl) ? A : 68'bz;
  assign resX=(~copyA & ~swpSngl) ? B : 68'bz;
  assign resX=(copyA & swpSngl) ? {A[67:66],A[32:0],A[65:33]} : 68'bz;
  assign resX=(~copyA & swpSngl) ? {B[67:66],B[32:0],B[65:33]} : 68'bz;
  assign res0=dupSngl ?{resX[67:66],resX[32:0],resX[32:0]} : is_sqrt|is_div ? resY : resX; 
  `ifndef swapedge
  always @(negedge clk) begin
  `else
  always @(posedge clk) begin
  `endif
    res0_reg<=res0;
    res0_reg2<=res0_reg;
    res0_reg3<=res0_reg2;
    if (rst) en_reg<=1'b0; else en_reg<=en;
    if (rst) en_reg2<=1'b0; else en_reg2<=en_reg;
    if (rst) en_reg3<=1'b0; else en_reg3<=en_reg2;
  end

endmodule
