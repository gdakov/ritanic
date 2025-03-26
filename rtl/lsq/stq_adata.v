/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


module stq_adata(
  clk,
  rst,
  wrt0_en,wrt0_WQ,wrt0_adata,
  wrt1_en,wrt1_WQ,wrt1_adata,
  upd0_WQ,upd0_adata,
  upd1_WQ,upd1_adata);
  input pwire clk;
  input pwire rst;
  input pwire wrt0_en;
  input pwire [5:0] wrt0_WQ;
  input pwire [4:0] wrt0_adata;
  input pwire wrt1_en;
  input pwire [5:0] wrt1_WQ;
  input pwire [4:0] wrt1_adata;
  input pwire [5:0] upd0_WQ;
  output pwire [4:0] upd0_adata;
  input pwire [5:0] upd1_WQ;
  output pwire [4:0] upd1_adata;
  
  pwire [4:0] BGN[63:0];
  
  assign upd0_adata=BGN[upd0_WQ];
  assign upd1_adata=BGN[upd1_WQ];
  
  always @(posedge clk) begin
      if (wrt1_en) BGN[wrt1_WQ]<=wrt1_adata;
      if (wrt0_en) BGN[wrt0_WQ]<=wrt0_adata;
  end
endmodule
