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

module in_flip_rt(
  clk,rst,in_en,pause,d_in,d_out,dout_en,do_);
  localparam CNT=4;
  parameter WIDTH=32;
  
  input clk;
  input rst;
  input in_en;
  output pause;
  input [WIDTH-1:0] d_in;
  output [WIDTH-1:0] d_out;
  input dout_en;
  output do_;

  reg [CNT-1:0] free;
  reg [WIDTH-1:0] data[CNT-1:0];
  reg [CNT-1:0] den;
  reg [CNT-1:0] den_reg;
  reg [CNT-1:0] den_reg2;
 // reg [CNT-1:0] den_reg3;
  wire [CNT-1:0] first;
  wire has;
  wire [CNT-1:0] firstN;
  wire hasN;
  reg [CNT-1:0] firstN_reg;
  reg hasN_reg;
  reg [CNT-1:0] firstN_reg2;
  reg hasN_reg2;
  wire [4:0] cntFree_or_less;
//  reg [CNT-1:0] firstN_reg3;
//  reg hasN_reg3;
  integer t;

  bit_find_first_bit #(CNT) first_mod(free,first,has);
  bit_find_first_bit #(CNT) firstN_mod(~free,firstN,hasN);
  popcnt5_or_less cpop_mod({1'b0,free},cntFree_or_less);
  generate
    genvar k;
    for(k=0;k<CNT;k=k+1) begin
	assign d_out=firstN_reg2[k] ? data[k] : 'z;
    end
  endgenerate

  assign d_out=hasN_reg2 ? 'z : d_in;
  assign do_=dout_en && in_en|hasN;
  assign pause=~dout_en && ~cntFree_or_less[1];

  always @(posedge clk) begin
      if (rst) begin
	  for(t=0;t<CNT;t=t+1) begin
	      den[t]<=1'b0;
	      data[t]<={WIDTH{1'b0}};
	      free[t]<=1'b1;
	      den_reg[t]<=1'b0;
	      den_reg2[t]<=1'b0;
	   //   den_reg3[t]<=1'b0;
	      firstN_reg[t]<=1'b0;
	      firstN_reg2[t]<=1'b0;
	   //   firstN_reg3[t]<=1'b0;
	  end
	  hasN_reg<=1'b0;
	  hasN_reg2<=1'b0;
	//  hasN_reg3<=1'b0;
      end else begin
	  for(t=0;t<CNT;t=t+1) begin
		  den[t]<=1'b0;
	      if (in_en && ~dout_en|hasN && first[t]) begin
		  den[t]<=1'b1;
		  free[t]<=1'b0;
	      end
	      if (dout_en && hasN && firstN[t]) begin
		  free[t]<=1'b1;
	      end
	      den_reg[t]<=den[t];
	      den_reg2[t]<=den_reg[t];
	 //     den_reg3[t]<=den_reg3[t];
	      if (den_reg[t]) data[t]<=d_in;
	      firstN_reg<=firstN;
	      firstN_reg2<=firstN_reg;
	    //  firstN_reg3<=firstN_reg2;
	      hasN_reg<=hasN;
	      hasN_reg2<=hasN_reg;
	      //hasN_reg3<=hasN_reg2;
	  end
      end
  end
endmodule
