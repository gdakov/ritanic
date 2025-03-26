/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/



module stq_buf_A(
  clk,
  rst,
  stallA,
  excpt,
  wrt0_en, wrt0_addrE, wrt0_addrO, 
  wrt1_en, wrt1_addrE, wrt1_addrO, 
  chk0_en, chk0_addrEO, chk0_addrE, chk0_addrO,
  chk1_en, chk1_addrEO, chk1_addrE, chk1_addrO,
  chk2_en, chk2_addrEO, chk2_addrE, chk2_addrO,
  chk3_en, chk3_addrEO, chk3_addrE, chk3_addrO,
  chk4_en, chk4_addrEO, chk4_addrE, chk4_addrO,
  chk5_en, chk5_addrEO, chk5_addrE, chk5_addrO,
  upd0_en, 
  upd1_en, 
  free_en,free,upd,passe,passe_en);
  localparam WIDTH=36;
  input pwire clk;
  input pwire rst;
  input pwire stallA;
  input pwire excpt;
  
  input pwire wrt0_en;
  input pwire [WIDTH-1:0] wrt0_addrE;
  input pwire [WIDTH-1:0] wrt0_addrO;

  input pwire wrt1_en;
  input pwire [WIDTH-1:0] wrt1_addrE;
  input pwire [WIDTH-1:0] wrt1_addrO;

  input pwire chk0_en;
  output pwire [1:0] chk0_addrEO;
  input pwire [WIDTH-1:0] chk0_addrE;
  input pwire [WIDTH-1:0] chk0_addrO;

  input pwire chk1_en;
  output pwire [1:0] chk1_addrEO;
  input pwire [WIDTH-1:0] chk1_addrE;
  input pwire [WIDTH-1:0] chk1_addrO;
  
  input pwire chk2_en;
  output pwire [1:0] chk2_addrEO;
  input pwire [WIDTH-1:0] chk2_addrE;
  input pwire [WIDTH-1:0] chk2_addrO;
  
  input pwire chk3_en;
  output pwire [1:0] chk3_addrEO;
  input pwire [WIDTH-1:0] chk3_addrE;
  input pwire [WIDTH-1:0] chk3_addrO;
  
  input pwire chk4_en;
  output pwire [1:0] chk4_addrEO;
  input pwire [WIDTH-1:0] chk4_addrE;
  input pwire [WIDTH-1:0] chk4_addrO;
  
  input pwire chk5_en;
  output pwire [1:0] chk5_addrEO;
  input pwire [WIDTH-1:0] chk5_addrE;
  input pwire [WIDTH-1:0] chk5_addrO;


  input pwire upd0_en;
  input pwire upd1_en;

  input pwire free_en;
  output pwire reg free;
  output pwire reg upd;
  output pwire reg passe;
  input pwire passe_en;
  
  reg [WIDTH-1:0] addrE;
  reg [WIDTH-1:0] addrO;
//  reg upd;
  
  assign chk0_addrEO[0]=chk0_addrE==addrE && ~free && ~passe;
  assign chk1_addrEO[0]=chk1_addrE==addrE && ~free && ~passe;
  assign chk2_addrEO[0]=chk2_addrE==addrE && ~free && ~passe;
  assign chk3_addrEO[0]=chk3_addrE==addrE && ~free && ~passe;
  assign chk4_addrEO[0]=chk4_addrE==addrE && ~free && ~passe;
  assign chk5_addrEO[0]=chk5_addrE==addrE && ~free && ~passe;

  assign chk0_addrEO[1]=chk0_addrO==addrO && ~free && ~passe;
  assign chk1_addrEO[1]=chk1_addrO==addrO && ~free && ~passe;
  assign chk2_addrEO[1]=chk2_addrO==addrO && ~free && ~passe;
  assign chk3_addrEO[1]=chk3_addrO==addrO && ~free && ~passe;
  assign chk4_addrEO[1]=chk4_addrO==addrO && ~free && ~passe;
  assign chk5_addrEO[1]=chk5_addrO==addrO && ~free && ~passe;

  always @(posedge clk) begin
      if (rst) begin
          addrE<=0;
          addrO<=0;
          free<=1'b1;
          upd<=1'b1;
          passe<=1'b0;
      end else begin
          if (wrt0_en) begin
              addrE<=wrt0_addrE;
              addrO<=wrt0_addrO;
              free<=1'b0;
              //upd<=1'b0;
              passe<=1'b0;
          end
          if (wrt1_en) begin
              addrE<=wrt1_addrE;
              addrO<=wrt1_addrO;
              free<=1'b0;
              //upd<=1'b0;
              passe<=1'b0;
          end
          if (upd0_en|upd1_en) begin
              upd<=1'b1;
          end
          if (passe_en) begin
              passe<=1'b1;
              upd<=1'b0;
          end
          if (free_en) begin 
              free<=1'b1;
              passe<=1'b0;
              addrE<=36'bz;
              addrO<=36'bz;
          end
          if (excpt&free&passe) begin
              passe<=1'b0;
          end
      end
  end
endmodule
module stq_buf_A_array(
  clk,
  rst,
  stallA,
  excpt,
  wrt0_en, wrt0_addrE, wrt0_addrO, 
  wrt1_en, wrt1_addrE, wrt1_addrO, 
  chk0_en, chk0_addrEO, chk0_addrE, chk0_addrO,
  chk1_en, chk1_addrEO, chk1_addrE, chk1_addrO,
  chk2_en, chk2_addrEO, chk2_addrE, chk2_addrO,
  chk3_en, chk3_addrEO, chk3_addrE, chk3_addrO,
  chk4_en, chk4_addrEO, chk4_addrE, chk4_addrO,
  chk5_en, chk5_addrEO, chk5_addrE, chk5_addrO,
  upd0_en, 
  upd1_en, 
  free_en,free,upd,passe,passe_en);
  localparam WIDTH=36;
  localparam BUF_COUNT=64;
  input pwire clk;
  input pwire rst;
  input pwire stallA;
  input pwire excpt;
  
  input pwire [BUF_COUNT-1:0] wrt0_en;
  input pwire [WIDTH-1:0] wrt0_addrE;
  input pwire [WIDTH-1:0] wrt0_addrO;

  input pwire [BUF_COUNT-1:0] wrt1_en;
  input pwire [WIDTH-1:0] wrt1_addrE;
  input pwire [WIDTH-1:0] wrt1_addrO;

  input pwire chk0_en;
  output pwire [BUF_COUNT-1:0] [1:0] chk0_addrEO;
  input pwire [WIDTH-1:0] chk0_addrE;
  input pwire [WIDTH-1:0] chk0_addrO;

  input pwire chk1_en;
  output pwire [BUF_COUNT-1:0] [1:0] chk1_addrEO;
  input pwire [WIDTH-1:0] chk1_addrE;
  input pwire [WIDTH-1:0] chk1_addrO;
  
  input pwire chk2_en;
  output pwire [BUF_COUNT-1:0] [1:0] chk2_addrEO;
  input pwire [WIDTH-1:0] chk2_addrE;
  input pwire [WIDTH-1:0] chk2_addrO;
  
  input pwire chk3_en;
  output pwire [BUF_COUNT-1:0] [1:0] chk3_addrEO;
  input pwire [WIDTH-1:0] chk3_addrE;
  input pwire [WIDTH-1:0] chk3_addrO;
  
  input pwire chk4_en;
  output pwire [BUF_COUNT-1:0] [1:0] chk4_addrEO;
  input pwire [WIDTH-1:0] chk4_addrE;
  input pwire [WIDTH-1:0] chk4_addrO;
  
  input pwire chk5_en;
  output pwire [BUF_COUNT-1:0] [1:0] chk5_addrEO;
  input pwire [WIDTH-1:0] chk5_addrE;
  input pwire [WIDTH-1:0] chk5_addrO;


  input pwire [BUF_COUNT-1:0] upd0_en;
  input pwire [BUF_COUNT-1:0] upd1_en;

  input pwire [BUF_COUNT-1:0] free_en;
  output pwire [BUF_COUNT-1:0]  free;
  output pwire [BUF_COUNT-1:0]  upd;
  output pwire [BUF_COUNT-1:0]  passe;
  input pwire [BUF_COUNT-1:0]  passe_en;
  
  generate
      genvar t;
      for(t=0;t<BUF_COUNT;t=t+1) begin :  buf_gen
          stq_buf_A buf_mod(
          clk,
          rst,
          stallA,
          excpt,
          wrt0_en[t], wrt0_addrE, wrt0_addrO, 
          wrt1_en[t], wrt1_addrE, wrt1_addrO, 
          chk0_en, chk0_addrEO[t], chk0_addrE, chk0_addrO,
          chk1_en, chk1_addrEO[t], chk1_addrE, chk1_addrO,
          chk2_en, chk2_addrEO[t], chk2_addrE, chk2_addrO,
          chk3_en, chk3_addrEO[t], chk3_addrE, chk3_addrO,
          chk4_en, chk4_addrEO[t], chk4_addrE, chk4_addrO,
          chk5_en, chk5_addrEO[t], chk5_addrE, chk5_addrO,
          upd0_en[t], 
          upd1_en[t], 
          free_en[t],free[t],upd[t],passe[t],passe_en[t]);
      end
  endgenerate
endmodule
