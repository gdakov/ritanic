/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/



module stq_buf_L(
  clk,
  rst,
  stallA,
  excpt,
  wrt0_en, wrt0_odd, wrt0_bytes, wrt0_subBNK, wrt0_subBNK2, 
  wrt1_en, wrt1_odd, wrt1_bytes, wrt1_subBNK, wrt1_subBNK2, 
  chk0_en, chk0_addrEO, chk0_odd, chk0_bytes, chk0_subBNK, chk0_subBNK2, chk0_match, chk0_partial,
  chk1_en, chk1_addrEO, chk1_odd, chk1_bytes, chk1_subBNK, chk1_subBNK2, chk1_match, chk1_partial,
  chk2_en, chk2_addrEO, chk2_odd, chk2_bytes, chk2_subBNK, chk2_subBNK2, chk2_match, chk2_partial,
  chk3_en, chk3_addrEO, chk3_odd, chk3_bytes, chk3_subBNK, chk3_subBNK2, chk3_match, chk3_partial,
  chk4_en, chk4_addrEO, chk4_odd, chk4_bytes, chk4_subBNK, chk4_subBNK2, chk4_match, chk4_partial,
  chk5_en, chk5_addrEO, chk5_odd, chk5_bytes, chk5_subBNK, chk5_subBNK2, chk5_match, chk5_partial,
  upd0_en, 
  upd1_en, 
  free_en,free,upd,passe,passe_en);
  localparam WIDTH=2;
  input pwire clk;
  input pwire rst;
  input pwire stallA;
  input pwire excpt;
  
  input pwire wrt0_en;
  input pwire [3:0] wrt0_odd;
  input pwire [3:0] wrt0_bytes;
  input pwire wrt0_subBNK;
  input pwire wrt0_subBNK2;

  input pwire wrt1_en;
  input pwire [3:0] wrt1_odd;
  input pwire [3:0] wrt1_bytes;
  input pwire wrt1_subBNK;
  input pwire wrt1_subBNK2;

  input pwire chk0_en;
  input pwire [WIDTH-1:0] chk0_addrEO;
  input pwire [3:0] chk0_odd;
  input pwire [3:0] chk0_bytes;
  input pwire chk0_subBNK;
  input pwire chk0_subBNK2;
  output pwire chk0_match;
  output pwire chk0_partial;

  input pwire chk1_en;
  input pwire [WIDTH-1:0] chk1_addrEO;
  input pwire [3:0] chk1_odd;
  input pwire [3:0] chk1_bytes;
  input pwire chk1_subBNK;
  input pwire chk1_subBNK2;
  output pwire chk1_match;
  output pwire chk1_partial;

  input pwire chk2_en;
  input pwire [WIDTH-1:0] chk2_addrEO;
  input pwire [3:0] chk2_odd;
  input pwire [3:0] chk2_bytes;
  input pwire chk2_subBNK;
  input pwire chk2_subBNK2;
  output pwire chk2_match;
  output pwire chk2_partial;

  input pwire chk3_en;
  input pwire [WIDTH-1:0] chk3_addrEO;
  input pwire [3:0] chk3_odd;
  input pwire [3:0] chk3_bytes;
  input pwire chk3_subBNK;
  input pwire chk3_subBNK2;
  output pwire chk3_match;
  output pwire chk3_partial;

  input pwire chk4_en;
  input pwire [WIDTH-1:0] chk4_addrEO;
  input pwire [3:0] chk4_odd;
  input pwire [3:0] chk4_bytes;
  input pwire chk4_subBNK;
  input pwire chk4_subBNK2;
  output pwire chk4_match;
  output pwire chk4_partial;

  input pwire chk5_en;
  input pwire [WIDTH-1:0] chk5_addrEO;
  input pwire [3:0] chk5_odd;
  input pwire [3:0] chk5_bytes;
  input pwire chk5_subBNK;
  input pwire chk5_subBNK2;
  output pwire chk5_match;
  output pwire chk5_partial;

  input pwire upd0_en;
  input pwire upd1_en;

  input pwire free_en;
  output pwire free;
  output pwire upd;
  output pwire passe;
  input pwire passe_en;
  
//  pwire [WIDTH-1:0] addrEO;
  pwire [3:0] bytes;
  pwire subBNK;
  pwire subBNK2;
  pwire [3:0] odd;
//  pwire upd;
  pwire chk0_match0;
  pwire chk1_match0;
  pwire chk2_match0;
  pwire chk3_match0;
  pwire chk4_match0;
  pwire chk5_match0;
  
  assign chk0_match0=chk0_addrEO[chk0_odd[0]] && (chk0_subBNK2&subBNK2)!=0 && chk0_odd[0]==odd[0];
  assign chk1_match0=chk1_addrEO[chk1_odd[0]] && (chk1_subBNK2&subBNK2)!=0 && chk1_odd[0]==odd[0];
  assign chk2_match0=chk2_addrEO[chk2_odd[0]] && (chk2_subBNK2&subBNK2)!=0 && chk2_odd[0]==odd[0];
  assign chk3_match0=chk3_addrEO[chk3_odd[0]] && (chk3_subBNK2&subBNK2)!=0 && chk3_odd[0]==odd[0];
  assign chk4_match0=chk4_addrEO[chk4_odd[0]] && (chk4_subBNK2&subBNK2)!=0 && chk4_odd[0]==odd[0];
  assign chk5_match0=chk5_addrEO[chk5_odd[0]] && (chk5_subBNK2&subBNK2)!=0 && chk5_odd[0]==odd[0];
  
  assign chk0_match=chk0_match0 && chk0_en && ~free && ~passe && (chk0_bytes&~bytes)==0 && upd && pwh#(32)::cmpEQ(chk0_odd,odd) && (chk0_subBNK&subBNK)!=0;
  assign chk1_match=chk1_match0 && chk1_en && ~free && ~passe && (chk1_bytes&~bytes)==0 && upd && pwh#(32)::cmpEQ(chk1_odd,odd) && (chk1_subBNK&subBNK)!=0;
  assign chk2_match=chk2_match0 && chk2_en && ~free && ~passe && (chk2_bytes&~bytes)==0 && upd && pwh#(32)::cmpEQ(chk2_odd,odd) && (chk2_subBNK&subBNK)!=0;
  assign chk3_match=chk3_match0 && chk3_en && ~free && ~passe && (chk3_bytes&~bytes)==0 && upd && pwh#(32)::cmpEQ(chk3_odd,odd) && (chk3_subBNK&subBNK)!=0;
  assign chk4_match=chk4_match0 && chk4_en && ~free && ~passe && (chk4_bytes&~bytes)==0 && upd && pwh#(32)::cmpEQ(chk4_odd,odd) && (chk4_subBNK&subBNK)!=0;
  assign chk5_match=chk5_match0 && chk5_en && ~free && ~passe && (chk5_bytes&~bytes)==0 && upd && pwh#(32)::cmpEQ(chk5_odd,odd) && (chk5_subBNK&subBNK)!=0;

  assign chk0_partial=chk0_match0 && chk0_en && ~free && ~passe && ((chk0_bytes&~bytes)!=0 || ~upd);
  assign chk1_partial=chk1_match0 && chk1_en && ~free && ~passe && ((chk1_bytes&~bytes)!=0 || ~upd);
  assign chk2_partial=chk2_match0 && chk2_en && ~free && ~passe && ((chk2_bytes&~bytes)!=0 || ~upd);
  assign chk3_partial=chk3_match0 && chk3_en && ~free && ~passe && ((chk3_bytes&~bytes)!=0 || ~upd);
  assign chk4_partial=chk4_match0 && chk4_en && ~free && ~passe && ((chk4_bytes&~bytes)!=0 || ~upd);
  assign chk5_partial=chk5_match0 && chk5_en && ~free && ~passe && ((chk5_bytes&~bytes)!=0 || ~upd);

  always @(posedge clk) begin
      if (rst) begin
  //        addrEO<=0;
          bytes<=0;
          subBNK<=0;
          subBNK2<=0;
          free<=1'b1;
          upd<=1'b1;
          passe<=1'b0;
          odd<=4'b0;
      end else begin
          if (wrt0_en) begin
//              addrEO<=wrt0_addrEO;
              bytes<=wrt0_bytes;
              subBNK<=wrt0_subBNK;
              subBNK2<=wrt0_subBNK2;
              odd<=wrt0_odd;
              free<=1'b0;
              //upd<=1'b0;
              passe<=1'b0;
          end
          if (wrt1_en) begin
//              addrEO<=wrt1_addrEO;
              bytes<=wrt1_bytes;
              subBNK<=wrt1_subBNK;
              subBNK2<=wrt1_subBNK2;
              odd<=wrt1_odd;
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
          end
          if (excpt&free&passe) begin
              passe<=1'b0;
          end
      end
  end
endmodule

module stq_buf_L_array(
  clk,
  rst,
  stallA,
  excpt,
  wrt0_en, wrt0_any, wrt0_WQ, wrt0_odd, wrt0_bytes, wrt0_subBNK, wrt0_subBNK2, 
  wrt1_en, wrt1_any, wrt1_WQ, wrt1_odd, wrt1_bytes, wrt1_subBNK, wrt1_subBNK2, 
  chk0_en, chk0_addrEO, chk0_odd, chk0_bytes, chk0_subBNK, chk0_subBNK2, chk0_match, chk0_partial, chk0_matchW, chk0_partialW, chk0_pre0, chk0_pre1,
  chk1_en, chk1_addrEO, chk1_odd, chk1_bytes, chk1_subBNK, chk1_subBNK2, chk1_match, chk1_partial, chk1_matchW, chk1_partialW, chk1_pre0, chk1_pre1,
  chk2_en, chk2_addrEO, chk2_odd, chk2_bytes, chk2_subBNK, chk2_subBNK2, chk2_match, chk2_partial, chk2_matchW, chk2_partialW, chk2_pre0, chk2_pre1,
  chk3_en, chk3_addrEO, chk3_odd, chk3_bytes, chk3_subBNK, chk3_subBNK2, chk3_match, chk3_partial, chk3_matchW, chk3_partialW, chk3_pre0, chk3_pre1,
  chk4_en, chk4_addrEO, chk4_odd, chk4_bytes, chk4_subBNK, chk4_subBNK2, chk4_match, chk4_partial, chk4_matchW, chk4_partialW, chk4_pre0, chk4_pre1,
  chk5_en, chk5_addrEO, chk5_odd, chk5_bytes, chk5_subBNK, chk5_subBNK2, chk5_match, chk5_partial, chk5_matchW, chk5_partialW, chk5_pre0, chk5_pre1,
  upd0_en, 
  upd1_en, 
  free_en,free,upd,passe,passe_en);
  localparam WIDTH=2;
  localparam BUF_COUNT=64;
  input pwire clk;
  input pwire rst;
  input pwire stallA;
  input pwire excpt;
  
  input pwire [BUF_COUNT-1:0] wrt0_en;
  input pwire wrt0_any;
  input pwire [3:0] wrt0_odd;
  input pwire [3:0] wrt0_bytes;
  input pwire wrt0_subBNK;
  input pwire wrt0_subBNK2;
  input pwire [5:0] wrt0_WQ;

  input pwire [BUF_COUNT-1:0] wrt1_en;
  input pwire wrt1_any;
  input pwire [3:0] wrt1_odd;
  input pwire [3:0] wrt1_bytes;
  input pwire wrt1_subBNK;
  input pwire wrt1_subBNK2;
  input pwire [5:0] wrt1_WQ;

  input pwire chk0_en;
  input pwire [BUF_COUNT-1:0][WIDTH-1:0] chk0_addrEO;
  input pwire [3:0] chk0_odd;
  input pwire [3:0] chk0_bytes;
  input pwire chk0_subBNK;
  input pwire chk0_subBNK2;
  output pwire [BUF_COUNT-1:0] chk0_match;
  output pwire [BUF_COUNT-1:0] chk0_partial;
  output pwire [1:0] chk0_matchW;
  output pwire [1:0] chk0_partialW;
  input pwire chk0_pre0;
  input pwire chk0_pre1;

  input pwire chk1_en;
  input pwire [BUF_COUNT-1:0][WIDTH-1:0] chk1_addrEO;
  input pwire [3:0] chk1_odd;
  input pwire [3:0] chk1_bytes;
  input pwire chk1_subBNK;
  input pwire chk1_subBNK2;
  output pwire [BUF_COUNT-1:0] chk1_match;
  output pwire [BUF_COUNT-1:0] chk1_partial;
  output pwire [1:0] chk1_matchW;
  output pwire [1:0] chk1_partialW;
  input pwire chk1_pre0;
  input pwire chk1_pre1;

  input pwire chk2_en;
  input pwire [BUF_COUNT-1:0][WIDTH-1:0] chk2_addrEO;
  input pwire [3:0] chk2_odd;
  input pwire [3:0] chk2_bytes;
  input pwire chk2_subBNK;
  input pwire chk2_subBNK2;
  output pwire [BUF_COUNT-1:0] chk2_match;
  output pwire [BUF_COUNT-1:0] chk2_partial;
  output pwire [1:0] chk2_matchW;
  output pwire [1:0] chk2_partialW;
  input pwire chk2_pre0;
  input pwire chk2_pre1;

  input pwire chk3_en;
  input pwire [BUF_COUNT-1:0][WIDTH-1:0] chk3_addrEO;
  input pwire [3:0] chk3_odd;
  input pwire [3:0] chk3_bytes;
  input pwire chk3_subBNK;
  input pwire chk3_subBNK2;
  output pwire [BUF_COUNT-1:0] chk3_match;
  output pwire [BUF_COUNT-1:0] chk3_partial;
  output pwire [1:0] chk3_matchW;
  output pwire [1:0] chk3_partialW;
  input pwire chk3_pre0;
  input pwire chk3_pre1;

  input pwire chk4_en;
  input pwire [BUF_COUNT-1:0][WIDTH-1:0] chk4_addrEO;
  input pwire [3:0] chk4_odd;
  input pwire [3:0] chk4_bytes;
  input pwire chk4_subBNK;
  input pwire chk4_subBNK2;
  output pwire [BUF_COUNT-1:0] chk4_match;
  output pwire [BUF_COUNT-1:0] chk4_partial;
  output pwire [1:0] chk4_matchW;
  output pwire [1:0] chk4_partialW;
  input pwire chk4_pre0;
  input pwire chk4_pre1;

  input pwire chk5_en;
  input pwire [BUF_COUNT-1:0][WIDTH-1:0] chk5_addrEO;
  input pwire [3:0] chk5_odd;
  input pwire [3:0] chk5_bytes;
  input pwire chk5_subBNK;
  input pwire chk5_subBNK2;
  output pwire [BUF_COUNT-1:0] chk5_match;
  output pwire [BUF_COUNT-1:0] chk5_partial;
  output pwire [1:0] chk5_matchW;
  output pwire [1:0] chk5_partialW;
  input pwire chk5_pre0;
  input pwire chk5_pre1;

  input pwire [BUF_COUNT-1:0] upd0_en;
  input pwire [BUF_COUNT-1:0] upd1_en;

  input pwire  [BUF_COUNT-1:0] free_en;
  output pwire [BUF_COUNT-1:0] free;
  output pwire [BUF_COUNT-1:0] upd;
  output pwire [BUF_COUNT-1:0] passe;
  input pwire  [BUF_COUNT-1:0] passe_en;
  
  pwire wrt0_match0;
  pwire wrt1_match0;
  pwire wrt0_match1;
  pwire wrt1_match1;
  pwire wrt0_match2;
  pwire wrt1_match2;
  pwire wrt0_match3;
  pwire wrt1_match3;
  pwire wrt0_match4;
  pwire wrt1_match4;
  pwire wrt0_match5;
  pwire wrt1_match5;
  generate
      genvar t;
      for(t=0;t<BUF_COUNT;t=t+1) begin : buf_gen
          stq_buf_L buf_mod(
          clk,
          rst,
          stallA,
          excpt,
          wrt0_en[t], wrt0_odd, wrt0_bytes, wrt0_subBNK, wrt0_subBNK2, 
          wrt1_en[t], wrt1_odd, wrt1_bytes, wrt1_subBNK, wrt1_subBNK2, 
          chk0_en, chk0_addrEO[t], chk0_odd, chk0_bytes, chk0_subBNK, chk0_subBNK2, chk0_match[t], chk0_partial[t],
          chk1_en, chk1_addrEO[t], chk1_odd, chk1_bytes, chk1_subBNK, chk1_subBNK2, chk1_match[t], chk1_partial[t],
          chk2_en, chk2_addrEO[t], chk2_odd, chk2_bytes, chk2_subBNK, chk2_subBNK2, chk2_match[t], chk2_partial[t],
          chk3_en, chk3_addrEO[t], chk3_odd, chk3_bytes, chk3_subBNK, chk3_subBNK2, chk3_match[t], chk3_partial[t],
          chk4_en, chk4_addrEO[t], chk4_odd, chk4_bytes, chk4_subBNK, chk4_subBNK2, chk4_match[t], chk4_partial[t],
          chk5_en, chk5_addrEO[t], chk5_odd, chk5_bytes, chk5_subBNK, chk5_subBNK2, chk5_match[t], chk5_partial[t],
          upd0_en[t], 
          upd1_en[t], 
          free_en[t],free[t],upd[t],passe[t],passe_en[t]);
      end
  endgenerate
  assign wrt0_match0=chk0_addrEO[wrt0_WQ][wrt0_odd[0]] && (wrt0_subBNK2&chk0_subBNK2)!=0 && wrt0_odd[0]==chk0_odd[0];
  assign wrt1_match0=chk0_addrEO[wrt1_WQ][wrt1_odd[0]] && (wrt1_subBNK2&chk0_subBNK2)!=0 && wrt1_odd[0]==chk0_odd[0];
  assign wrt0_match1=chk1_addrEO[wrt0_WQ][wrt0_odd[0]] && (wrt0_subBNK2&chk1_subBNK2)!=0 && wrt0_odd[0]==chk1_odd[0];
  assign wrt1_match1=chk1_addrEO[wrt1_WQ][wrt1_odd[0]] && (wrt1_subBNK2&chk1_subBNK2)!=0 && wrt1_odd[0]==chk1_odd[0];
  assign wrt0_match2=chk2_addrEO[wrt0_WQ][wrt0_odd[0]] && (wrt0_subBNK2&chk2_subBNK2)!=0 && wrt0_odd[0]==chk2_odd[0];
  assign wrt1_match2=chk2_addrEO[wrt1_WQ][wrt1_odd[0]] && (wrt1_subBNK2&chk2_subBNK2)!=0 && wrt1_odd[0]==chk2_odd[0];
  assign wrt0_match3=chk3_addrEO[wrt0_WQ][wrt0_odd[0]] && (wrt0_subBNK2&chk3_subBNK2)!=0 && wrt0_odd[0]==chk3_odd[0];
  assign wrt1_match3=chk3_addrEO[wrt1_WQ][wrt1_odd[0]] && (wrt1_subBNK2&chk3_subBNK2)!=0 && wrt1_odd[0]==chk3_odd[0];
  assign wrt0_match4=chk4_addrEO[wrt0_WQ][wrt0_odd[0]] && (wrt0_subBNK2&chk4_subBNK2)!=0 && wrt0_odd[0]==chk4_odd[0];
  assign wrt1_match4=chk4_addrEO[wrt1_WQ][wrt1_odd[0]] && (wrt1_subBNK2&chk4_subBNK2)!=0 && wrt1_odd[0]==chk4_odd[0];
  assign wrt0_match5=chk5_addrEO[wrt0_WQ][wrt0_odd[0]] && (wrt0_subBNK2&chk5_subBNK2)!=0 && wrt0_odd[0]==chk5_odd[0];
  assign wrt1_match5=chk5_addrEO[wrt1_WQ][wrt1_odd[0]] && (wrt1_subBNK2&chk5_subBNK2)!=0 && wrt1_odd[0]==chk5_odd[0];
  
  assign chk0_matchW[0]=wrt0_match0 && chk0_en && chk0_pre0 && wrt0_any &&(chk0_bytes&~wrt0_bytes)==0 && (upd&wrt0_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk0_odd,wrt0_odd) && (chk0_subBNK&wrt0_subBNK)!=0;
  assign chk1_matchW[0]=wrt0_match1 && chk1_en && chk1_pre0 && wrt0_any &&(chk1_bytes&~wrt0_bytes)==0 && (upd&wrt0_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk1_odd,wrt0_odd) && (chk1_subBNK&wrt0_subBNK)!=0;
  assign chk2_matchW[0]=wrt0_match2 && chk2_en && chk2_pre0 && wrt0_any &&(chk2_bytes&~wrt0_bytes)==0 && (upd&wrt0_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk2_odd,wrt0_odd) && (chk2_subBNK&wrt0_subBNK)!=0;
  assign chk3_matchW[0]=wrt0_match3 && chk3_en && chk3_pre0 && wrt0_any &&(chk3_bytes&~wrt0_bytes)==0 && (upd&wrt0_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk3_odd,wrt0_odd) && (chk3_subBNK&wrt0_subBNK)!=0;
  assign chk4_matchW[0]=wrt0_match4 && chk4_en && chk4_pre0 && wrt0_any &&(chk4_bytes&~wrt0_bytes)==0 && (upd&wrt0_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk4_odd,wrt0_odd) && (chk4_subBNK&wrt0_subBNK)!=0;
  assign chk5_matchW[0]=wrt0_match5 && chk5_en && chk5_pre0 && wrt0_any &&(chk5_bytes&~wrt0_bytes)==0 && (upd&wrt0_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk5_odd,wrt0_odd) && (chk5_subBNK&wrt0_subBNK)!=0;

  assign chk0_partialW[0]=wrt0_match0 && chk0_en && chk0_pre0 && wrt0_any && ((chk0_bytes&~wrt0_bytes)!=0 || (upd&wrt0_en)==64'b0);
  assign chk1_partialW[0]=wrt0_match1 && chk1_en && chk1_pre0 && wrt0_any && ((chk1_bytes&~wrt0_bytes)!=0 || (upd&wrt0_en)==64'b0);
  assign chk2_partialW[0]=wrt0_match2 && chk2_en && chk2_pre0 && wrt0_any && ((chk2_bytes&~wrt0_bytes)!=0 || (upd&wrt0_en)==64'b0);
  assign chk3_partialW[0]=wrt0_match3 && chk3_en && chk3_pre0 && wrt0_any && ((chk3_bytes&~wrt0_bytes)!=0 || (upd&wrt0_en)==64'b0);
  assign chk4_partialW[0]=wrt0_match4 && chk4_en && chk4_pre0 && wrt0_any && ((chk4_bytes&~wrt0_bytes)!=0 || (upd&wrt0_en)==64'b0);
  assign chk5_partialW[0]=wrt0_match5 && chk5_en && chk5_pre0 && wrt0_any && ((chk5_bytes&~wrt0_bytes)!=0 || (upd&wrt0_en)==64'b0);
  
  assign chk0_matchW[1]=wrt1_match0 && chk0_en && chk0_pre1 && wrt1_any &&(chk0_bytes&~wrt1_bytes)==0 && (upd&wrt1_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk0_odd,wrt1_odd) && (chk0_subBNK&wrt1_subBNK)!=0;
  assign chk1_matchW[1]=wrt1_match1 && chk1_en && chk1_pre1 && wrt1_any &&(chk1_bytes&~wrt1_bytes)==0 && (upd&wrt1_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk1_odd,wrt1_odd) && (chk1_subBNK&wrt1_subBNK)!=0;
  assign chk2_matchW[1]=wrt1_match2 && chk2_en && chk2_pre1 && wrt1_any &&(chk2_bytes&~wrt1_bytes)==0 && (upd&wrt1_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk2_odd,wrt1_odd) && (chk2_subBNK&wrt1_subBNK)!=0;
  assign chk3_matchW[1]=wrt1_match3 && chk3_en && chk3_pre1 && wrt1_any &&(chk3_bytes&~wrt1_bytes)==0 && (upd&wrt1_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk3_odd,wrt1_odd) && (chk3_subBNK&wrt1_subBNK)!=0;
  assign chk4_matchW[1]=wrt1_match4 && chk4_en && chk4_pre1 && wrt1_any &&(chk4_bytes&~wrt1_bytes)==0 && (upd&wrt1_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk4_odd,wrt1_odd) && (chk4_subBNK&wrt1_subBNK)!=0;
  assign chk5_matchW[1]=wrt1_match5 && chk5_en && chk5_pre1 && wrt1_any &&(chk5_bytes&~wrt1_bytes)==0 && (upd&wrt1_en)!=64'b0 &&
	  pwh#(32)::cmpEQ(chk5_odd,wrt1_odd) && (chk5_subBNK&wrt1_subBNK)!=0;

  assign chk0_partialW[1]=wrt1_match0 && chk0_en && chk0_pre1 && wrt1_any && ((chk0_bytes&~wrt1_bytes)!=0 || (upd&wrt1_en)==64'b0);
  assign chk1_partialW[1]=wrt1_match1 && chk1_en && chk1_pre1 && wrt1_any && ((chk1_bytes&~wrt1_bytes)!=0 || (upd&wrt1_en)==64'b0);
  assign chk2_partialW[1]=wrt1_match2 && chk2_en && chk2_pre1 && wrt1_any && ((chk2_bytes&~wrt1_bytes)!=0 || (upd&wrt1_en)==64'b0);
  assign chk3_partialW[1]=wrt1_match3 && chk3_en && chk3_pre1 && wrt1_any && ((chk3_bytes&~wrt1_bytes)!=0 || (upd&wrt1_en)==64'b0);
  assign chk4_partialW[1]=wrt1_match4 && chk4_en && chk4_pre1 && wrt1_any && ((chk4_bytes&~wrt1_bytes)!=0 || (upd&wrt1_en)==64'b0);
  assign chk5_partialW[1]=wrt1_match5 && chk5_en && chk5_pre1 && wrt1_any && ((chk5_bytes&~wrt1_bytes)!=0 || (upd&wrt1_en)==64'b0);
endmodule
