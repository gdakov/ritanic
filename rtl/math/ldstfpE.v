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

module LDE2NativeE(
  A,An,
  en,
  res
  );
  input pwire [79:0] A;
  input pwire [79:0] An;
  input pwire en;
  output pwire [80:0] res;
  //assign except=A[78:64]==0 && A[63:0];//denormal
  assign res=(A[78:64]!=0 && A[78:64]!=15'hefff && en) ? {~A[78],A[79],A[78:64],1'b1,A[62:0]} : 81'bz;
  assign res=(A[78:64]==15'hefff && en) ? {A[78],A[79],A[78],A[77:65],A[62:0]!=63'b0,A[78],1'b1,A[62:0]} : 81'bz;
  assign res=(A[78:64]==0 && en) ? 81'b0 :  81'bz;//denormal loaded as zero for extended format
  
endmodule

module stNativeE2E(
  A,
  en,
  res
  );
  localparam [15:0] DEN=16'h4000;
  localparam [15:0] OVFL=16'hbfff;
  input pwire [80:0] A;
  input pwire en;
  output pwire [127:0] res;
 
  pwire is_den;
  pwire is_overflow;
  pwire [15:0] expA={A[79],A[64],A[77:64]};
  pwire is_unord=&expA;
  pwire [15:0] expOff;
  adder #(16) expAddD_mod(DEN,~expA,expOff,1'b1,1'b1,is_den,,,);
  adder #(16) expAddO_mod(expA,~OVFL,,1'b1,1'b1,is_overflow,,,);


  assign res=is_den & en ? 128'b0 : 128'bz;
  assign res=is_overflow & ~is_unord & en ? {48'b0,A[80],15'hefff,64'b0} : 128'bz;
  assign res=is_unord & en ? {48'b0,A[80],15'hefff,1'b1,A[62:0]} : 128'bz;
  assign res=~is_den & ~is_overflow & ~is_unord & en ? {48'b0,A[80],A[64],A[78:65],1'b1,A[62:0]} : 128'bz;
endmodule

