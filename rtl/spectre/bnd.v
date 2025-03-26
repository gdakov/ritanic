/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

module bnd(
  input clk,
  input rst,
  input [64:0] A,
  input [64:0] B,
  output pwire reg [64:0] C
  );
  pwire [43:0] DB;
  pwire [43:0] DA;
  reg [43:0] DB_reg;
  reg [43:0] DA_reg;
  reg [43:0] DB_reg2;
  reg [43:0] A_reg;
  reg [43:0] A_reg2;
  pwire cout0;
  pwire [4:0] sh;
  reg [4:0] sh_reg;
  pwire [31:0] first;
  pwire has;

  adder #(44) sub0_mod(B[43:0],~A[43:0],DA,1'b1,B[64],cout0,,,);
  adder #(44) add0_mod(B[43:0],A[43:0],DB,1'b1,~B[64],,,,);
  assign DA=~B[64] ? B[43:0] : 44'bz;
  assign DB=B[64] ? B[43:0] : 44'bz;

  bit_find_last_bit #(32) ls_mod(DA_reg[43:12],first,has);
  generate
    genvar p;
    for(p=0;p<8;p=p+1) begin
        assign sh[2:0]=first[7-p]|first[15-p]|first[23-p]|first[31-p]|(p==0 &&
        ~has) ? p[2:0] : 3'bz;
    end
  endgenerate

  assign sh[4:3]=~|DA_reg[43-:24] ? 2'b0 : 2'bz;
  assign sh[4:3]=~|DA_reg[43-:16] ? 2'b1 : 2'bz;
  assign sh[4:3]=~|DA_reg[43-:8] ? 2'b10 : 2'bz;
  assign sh[4:3]=|DA_reg[43-:8] ? 2'b11 : 2'bz;

  addrcalcsec_shift8 shfB(sh_reg,DB_reg2[43:4],hi_rng);
  addrcalcsec_shift8 shfA(sh_reg,A_reg2[43:4],lo_rng);


  always @(posedge clk) begin
    sh_reg<=sh;
    DA_reg<=DA;
    DB_reg<=DB;
    DB_reg2<=DB;
    A_reg<=A[43:0];
    A_reg2<=A_reg;
    C[64]<=1'b1;
    C[`ptr_exp]<=sh_reg;
    C[`ptr_low]<=lo_rng;
    C[`ptr_hi]<=hi_rng;
    C[`ptr_on_low]<=1'b1;
    C[43:0]<=A_reg2;
  end
endmodule
