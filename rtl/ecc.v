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
//verilator lint_off WIDTH
module hamingChk32(data,hasError,error);
  parameter WIDTH=38;
  input pwire [WIDTH-1:0] data;
  output pwire hasError;
  output pwire [5:0] error;
 
  assign error[0]=^(data & {(WIDTH+1)/2{2'B01}});
  assign error[1]=^(data & {(WIDTH+3)/4{4'B0110}});
  assign error[2]=^(data & {(WIDTH+7)/8{8'B01111000}});
  assign error[3]=^(data & {(WIDTH+15)/16{16'h7f80}});
  assign error[4]=^(data & {(WIDTH+31)/32{32'h7fff_8000}});
  assign error[5]=^(data & {(WIDTH+63)/64{64'h7fff_ffff_8000_0000}});
  
  assign hasError=|error;
  
endmodule


module eccChk32(data,hasError,hardError);
  parameter WIDTH=39;
  input pwire [WIDTH-1:0] data;
  output pwire hasError;
  output pwire hardError;

  pwire [5:0] ecc;
  
  assign hardError=~^data & hasError;

  hamingChk32 #(WIDTH-1) ham_mod(data[WIDTH-2:0],hasError,ecc);
  
endmodule


module hamingGet32(data,dataH);
  parameter WIDTH=32;
  input pwire [WIDTH-1:0] data;
  output pwire reg [WIDTH+5:0] dataH;
  
  reg [WIDTH-1:0] errbits[5:0];
 
  always @*
    begin
      errbits[0]={(WIDTH+1)/2{2'B01}};
      errbits[1]={(WIDTH+3)/4{4'B0110}};
      errbits[2]={(WIDTH+7)/8{8'B01111000}};
      errbits[3]={(WIDTH+15)/16{16'h7f80}};
      errbits[4]={(WIDTH+31)/32{32'h7fff_8000}};
      errbits[5]={(WIDTH+63)/64{64'h7fff_ffff_8000_0000}};
      errbits[0][0]=1'b0;
      errbits[1][1]=1'b0;
      errbits[2][3]=1'b0;
      errbits[3][7]=1'b0;
      errbits[4][15]=1'b0;
      errbits[5][31]=1'b0;
      
      dataH={data[WIDTH-1:26],1'b0,data[25:11],1'b0,data[10:4],1'b0,data[3:1],1'b0,data[0],2'b0};
      dataH[0]=^(data&errbits[0]);
      dataH[1]=^(data&errbits[1]);
      dataH[3]=^(data&errbits[2]);
      dataH[7]=^(data&errbits[3]);
      dataH[15]=^(data&errbits[4]);
      dataH[31]=^(data&errbits[5]);
    end
  
endmodule

module EccGet32(data,dataH);
  parameter WIDTH=32;
  input pwire [WIDTH-1:0] data;
  output pwire [WIDTH+6:0] dataH;
  hamingGet32 #(WIDTH) ham_mod(data,dataH[WIDTH+5:0]);
  assign dataH[WIDTH+6]=^dataH[WIDTH+5:0];

endmodule


module dc1_strip_par(in,out);
  input pwire [35:0] in;
  output pwire [31:0] out;
  
  assign out={in[34:27],in[25:18],in[16:9],in[7:0]};
endmodule

module dc1_get_par(in,out);
  input pwire [31:0] in;
  output pwire [35:0] out;

  assign out={^in[31:24],in[31:24],^in[23:16],in[23:16],^in[15:8],in[15:8],^in[7:0],in[7:0]};
endmodule
//verilator lint_on WIDTH

