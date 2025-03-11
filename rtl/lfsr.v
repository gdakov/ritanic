/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

`include "struct.v"

module LFSR16_6(
 clk,
 rst,
 OUT
 );
  parameter [15:0] INIT=16'hbeef;
  input clk;
  input rst;
  output reg [5:0] OUT;

  wire [5:0] OUT_a;
  reg [15:0] IN;
  
  generate
      genvar k;
      for(k=0;k<6;k=k+1) begin
          assign OUT_a[5-k]=^{IN[15-k],IN[13-k],IN[12-k],IN[10-k]}; 
      end
  endgenerate
  
  always @(negedge clk) begin
      if (rst) OUT<=6'b010110;
      else OUT<=OUT_a;
      if (rst) IN<=INIT;
      else IN<={IN[9:0],OUT_a};
  end
endmodule


module LFSR16_1(
 clk,
 rst,
 OUT
 );
  parameter [15:0] INITVAL=16'he45b;
  input clk;
  input rst;
  output reg OUT;
  

  wire OUT_a;
  reg [15:0] IN;
  
  assign OUT_a=^{IN[15],IN[13],IN[12],IN[10]}; 
  
  always @(posedge clk) begin
      if (rst) OUT<=1'b0;
      else OUT<=OUT_a;
      if (rst) IN<=INITVAL;
      else IN<={IN[14:0],OUT_a};
  end
endmodule

module LFSR16_1_16(
 clk,
 rst,
 OUT,
 OUT2
 );
  parameter [15:0] INITVAL=16'he45b;
  input clk;
  input rst;
  output reg OUT;
  output [15:0] OUT2;
  

  wire OUT_a;
  reg [15:0] IN;
  
  assign OUT_a=^{IN[15],IN[13],IN[12],IN[10]}; 
  assign OUT2=IN;
  
  always @(posedge clk) begin
      if (rst) OUT<=1'b0;
      else OUT<=OUT_a;
      if (rst) IN<=INITVAL;
      else IN<={IN[14:0],OUT_a};
  end
endmodule

