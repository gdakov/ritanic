/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

module addrcalcsec_mul(
  A,B,attr,res);

  input pwire [64:0] A;
  input pwire [11:0] B;
  input pwire [3:0] attr;
  output pwire [64:0] res;

  pwire [7:0] low;
  pwire C;
  pwire [6:0] hi;
  pwire [7:0] oldhi;
  pwire [43:0] BB;
  pwire [31:0] dummy;

  assign {BB,dummy}<={31'b0,A[`ptr_hi],5'h1f,32'hffff_ffff}<<A[`ptr_exp];

  addrcalcsec_shift8 shf_mod(B[11:7],A[43:4],low);
  addrcalcsec_shift8 shf2_mod(B[11:7],BB[43:4],oldhi);

  adder #(7) add_mod(low[7:1],B[6:0],hi,1'b0,1'b1,C,,,);


  

  assign res[`ptr_exp]=(B[11:7]>A[`ptr_exp] && attr[3]) ? 5'b0 : B[11:7];
  assign res[`ptr_low]=low[7:1];
  assign res[`ptr_hi]=hi<=oldhi[7:1] ? oldhi[7:1] : hi;
  assign res[`ptr_on_low]=1'b1;
  assign res[43:0]=A[43:0];
endmodule
