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

module normalizeD(
  clk,
  rst,
  A,
  isDBL,
  isEXT,
  en,
  clkEn,
  res
  );

  localparam [11:0] DEN_DBL=12'h400;
  localparam [15:0] DEN_EXT=16'h4000;
  input pwire clk;
  input pwire rst;
  input pwire [81:0] A;
  input pwire isDBL;
  input pwire isEXT;
  input pwire en;
  input pwire clkEn;
  output pwire [81:0] res;

  pwire [15:0] expA;
  pwire [15:0] denor_from;
  pwire [15:0] offset;
  pwire [15:0] offset_reg;

  assign expA=isDBL ? {A[65],{4{~A[65]}},A[63:53]} : {A[65],A[80:66]};
  assign denor_from=isDBL ? {DEN_DBL[11],{4{~DEN_DBL[11]}},DEN_DBL[10:0]} : DEN_EXT;

  adder #(16) offAdd_mod(denor_from,~expA,offset,1'b1,1'b1);

  generate
    genvar t;
    for(t=0;t<8;t=t+1) begin
	get_carry #(3) cmpUP_mod(offset_reg[5:3],~t[2:0],1'b1,coUP[t]);
	get_carry #(3) cmpDN_mod(offset_reg[2:0],~t[2:0],1'b1,coDN[t]);
	assign eqUP[t]=t==offset_reg[5:3];
	assign the_mask[8*t+:8]=~eqUP[t] & coUP[t] ? 8'b0 : 8'bz;
	assign the_mask[8*t+:8]=eqUP[t] ? submask : 8'bz;
	assign the_mask[8*t+:8]=~coUP[t] ? 8'hff : 8'bz;
	assign submask[t]=coDN[t];
    end
  endgenerate
endmodule
