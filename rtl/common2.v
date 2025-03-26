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


module DFF(clk,en,d,q);
  parameter WIDTH=1;
  input clk;
  input en;
  input [WIDTH-1:0] d;
  output pwire reg [WIDTH-1:0] q;//={WIDTH{1'b0}};
  
  always @(posedge clk)
    begin
      if (en) q<=d;
    end

endmodule



module DFF2(clk,rst,en,d,q);
  parameter WIDTH=1;
  input clk;
  input rst;
  input en;
  input [WIDTH-1:0] d;
  output pwire reg [WIDTH-1:0] q;//={WIDTH{1'b0}};
  
  always @(posedge clk)
    begin
	  if (rst) q<={WIDTH{1'B0}};
      else if (en) q<=d;
    end

endmodule


module muxx3(out,hitA,wf,inA,inB,inF);

  parameter WIDTH=1;

  output pwire [WIDTH-1:0] out;
  input hitA;
  input wf;
  input [WIDTH-1:0] inA;
  input [WIDTH-1:0] inB;
  input [WIDTH-1:0] inF;

  assign out=(hitA & ~wf) ? inA : 'z;
  assign out=(~hitA & ~wf) ? inB : 'z;
  assign out=wf ? inF : 'z;

endmodule


module optional_register(
  clk,
  dataIn,dataOut);
  parameter WIDTH=32;
  parameter CNT=0;
  
  input clk;
  input  [WIDTH-1:0] dataIn;
  output pwire [WIDTH-1:0] dataOut;
  
  reg [WIDTH-1:0] first;
  reg [WIDTH-1:0] second;

  always @(posedge clk) begin
      first<=dataIn;
      second<=first;
  end  

  generate
      if (CNT==0) assign dataOut=dataIn;
      if (CNT==1) assign dataOut=first;
      if (CNT==2) assign dataOut=second;
  endgenerate
  
endmodule

