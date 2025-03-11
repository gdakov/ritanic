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

//compile rs_write_forward to multiple hard macros with 1 horizontal x2 wire
//allign bit spacing with corresponding functional unit
//do not delete "redundant" inputs
module rs_write_forward_ALU(
  clk,rst,
  stall_addsub,stall_non_add,stall_shift,
  sxtEn,
  oldData,newData,
  fuFwd,fuuFwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  parameter [0:0] D=0;
  parameter DATA_WIDTH=`alu_width;
  input clk;
  input rst;
  input stall_addsub;
  input stall_non_add;
  input stall_shift;
  input sxtEn;
  
  input [DATA_WIDTH-1:0] oldData;
  output reg [2:0][DATA_WIDTH-1:0] newData;
  input [3:0] fuFwd;
  input [3:0] fuuFwd;
  
  (* register equiload *) input  [DATA_WIDTH-1:0] FU0;
  input [DATA_WIDTH-1:0] FU0_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU1;
  input [DATA_WIDTH-1:0] FU1_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU2;
  input [DATA_WIDTH-1:0] FU2_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU3;
  input [DATA_WIDTH-1:0] FU3_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU4;
  input [DATA_WIDTH-1:0] FU4_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU5;
  input [DATA_WIDTH-1:0] FU5_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU6;
  input [DATA_WIDTH-1:0] FU6_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU7;
  input [DATA_WIDTH-1:0] FU7_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU8;
  input [DATA_WIDTH-1:0] FU8_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU9;
  input [DATA_WIDTH-1:0] FU9_reg;
  
  wire [DATA_WIDTH-1:0] newData_d;
  wire [DATA_WIDTH-1:0] newDataFu_d;
  wire [DATA_WIDTH-1:0] newDataFuu_d;
  
  assign newDataFu_d=(fuFwd==4'd0) ? FU0 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd0) ? FU0_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd1) ? FU1 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd1) ? FU1_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd2) ? FU2 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd2) ? FU2_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd3) ? FU3 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd3) ? FU3_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd4) ? FU4 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd4) ? FU4_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd5) ? FU5 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd5) ? FU5_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd6) ? FU6 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd6) ? FU6_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd7) ? FU7 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd7) ? FU7_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd8) ? FU8 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd8) ? FU8_reg : 'z;  
  assign newDataFu_d=(fuFwd[3] && |fuFwd[2:0]) ? FU9 : 'z;  
  assign newDataFuu_d=(fuuFwd[3] && |fuuFwd[2:0]) ? FU9_reg : 'z;  


  assign newData_d[15:0]=({fuFwd,fuuFwd}==8'hff) ? oldData[15:0] : 'z;  
  assign newData_d[15:0]=(fuFwd!=4'hf) ? newDataFu_d[15:0] : 'z;  
  assign newData_d[15:0]=(fuuFwd!=4'hf) ? newDataFuu_d[15:0] : 'z;  
  assign newData_d[64]=({fuFwd,fuuFwd}==8'hff) ? oldData[64] : 1'BZ;  
  assign newData_d[64]=(fuFwd!=4'hf) ? newDataFu_d[64] : 1'BZ;  
  assign newData_d[64]=(fuuFwd!=4'hf) ? newDataFuu_d[64] : 1'BZ;  
  assign newData_d[63:16]=({fuFwd,fuuFwd}==8'hff && ~sxtEn) ? oldData[63:16] : 'z;  
  assign newData_d[63:16]=(fuFwd!=4'hf && ~sxtEn) ? newDataFu_d[63:16] : 'z;  
  assign newData_d[63:16]=(fuuFwd!=4'hf || sxtEn) ? (newDataFuu_d[63:16]|{48{D&sxtEn}})&{48{D|~sxtEn}} : 'z;  

  always @(posedge clk) 
  begin
      if (rst)                 newData[0]<={DATA_WIDTH{1'B0}};
      else if (~stall_addsub)  newData[0]<=newData_d[0];
      else                     newData[0]<=65'bz;
      if (rst)                 newData[1]<={DATA_WIDTH{1'B0}};
      else if (~stall_non_add) newData[1]<=newData_d[0];
      else                     newData[1]<=65'bz;
      if (rst)                 newData[2]<={DATA_WIDTH{1'B0}};
      else if (~stall_shift)   newData[2]<=newData_d[0];
      else                     newData[2]<=65'bz;
  end
endmodule


module rs_write_forward(
  clk,rst,
  stall,
  oldData,newData,
  fuFwd,fuuFwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  parameter DATA_WIDTH=`alu_width;
  input clk;
  input rst;
  input stall;
  
  input [DATA_WIDTH-1:0] oldData;
  output reg [DATA_WIDTH-1:0] newData;
  input [3:0] fuFwd;
  input [3:0] fuuFwd;
  
  (* register equiload *) input  [DATA_WIDTH-1:0] FU0;
  input [DATA_WIDTH-1:0] FU0_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU1;
  input [DATA_WIDTH-1:0] FU1_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU2;
  input [DATA_WIDTH-1:0] FU2_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU3;
  input [DATA_WIDTH-1:0] FU3_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU4;
  input [DATA_WIDTH-1:0] FU4_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU5;
  input [DATA_WIDTH-1:0] FU5_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU6;
  input [DATA_WIDTH-1:0] FU6_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU7;
  input [DATA_WIDTH-1:0] FU7_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU8;
  input [DATA_WIDTH-1:0] FU8_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU9;
  input [DATA_WIDTH-1:0] FU9_reg;
  
  wire [DATA_WIDTH-1:0] newData_d;
  wire [DATA_WIDTH-1:0] newDataFu_d;
  wire [DATA_WIDTH-1:0] newDataFuu_d;
  
  assign newDataFu_d=(fuFwd==4'd0) ? FU0 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd0) ? FU0_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd1) ? FU1 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd1) ? FU1_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd2) ? FU2 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd2) ? FU2_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd3) ? FU3 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd3) ? FU3_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd4) ? FU4 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd4) ? FU4_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd5) ? FU5 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd5) ? FU5_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd6) ? FU6 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd6) ? FU6_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd7) ? FU7 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd7) ? FU7_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd8) ? FU8 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd8) ? FU8_reg : 'z;  
  assign newDataFu_d=(fuFwd[3] && |fuFwd[2:0]) ? FU9 : 'z;  
  assign newDataFuu_d=(fuuFwd[3] && |fuuFwd[2:0]) ? FU9_reg : 'z;  


  assign newData_d=({fuFwd,fuuFwd}==8'hff) ? oldData : 'z;  
  assign newData_d=(fuFwd!=4'hf) ? newDataFu_d : 'z;  
  assign newData_d=(fuuFwd!=4'hf) ? newDataFuu_d : 'z;  

  always @(posedge clk) 
  begin
      if (rst) newData<={DATA_WIDTH{1'B0}};
      else if (~stall)
        newData<=newData_d;
  end
endmodule

module rs_write_forwardF(
  clk,rst,
  stall,
  oldData,newData,
  fuFwd,fuuFwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  parameter DATA_WIDTH=`alu_width;
  input clk;
  input rst;
  input stall;
  
  input [DATA_WIDTH-1:0] oldData;
  output reg [DATA_WIDTH-1:0] newData;
  input [3:0] fuFwd;
  input [3:0] fuuFwd;
  
  (* register equiload *) input [DATA_WIDTH-1:0] FU0;
  input [DATA_WIDTH-1:0] FU0_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU1;
  input [DATA_WIDTH-1:0] FU1_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU2;
  input [DATA_WIDTH-1:0] FU2_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU3;
  input [DATA_WIDTH-1:0] FU3_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU4;
  input [DATA_WIDTH-1:0] FU4_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU5;
  input [DATA_WIDTH-1:0] FU5_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU6;
  input [DATA_WIDTH-1:0] FU6_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU7;
  input [DATA_WIDTH-1:0] FU7_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU8;
  input [DATA_WIDTH-1:0] FU8_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU9;
  input [DATA_WIDTH-1:0] FU9_reg;
  
  wire [DATA_WIDTH-1:0] newData_d;
  wire [DATA_WIDTH-1:0] newDataFu_d;
  wire [DATA_WIDTH-1:0] newDataFuu_d;
  
  assign newDataFu_d=(fuFwd==4'd0) ? FU0 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd0) ? FU0_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd1) ? FU1 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd1) ? FU1_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd2) ? FU2 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd2) ? FU2_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd3) ? FU3 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd3) ? FU3_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd4) ? FU4 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd4) ? FU4_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd5) ? FU5 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd5) ? FU5_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd6) ? FU6 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd6) ? FU6_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd7) ? FU7 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd7) ? FU7_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd8) ? FU8 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd8) ? FU8_reg : 'z;  
  assign newDataFu_d=(fuFwd[3] && |fuFwd[2:0]) ? FU9 : 'z;  
  assign newDataFuu_d=(fuuFwd[3] && |fuuFwd[2:0]) ? FU9_reg : 'z;  


  assign newData_d=({fuFwd,fuuFwd}==8'hff) ? oldData : 'z;  
  assign newData_d=(fuFwd!=4'hf) ? newDataFu_d : 'z;  
  assign newData_d=(fuuFwd!=4'hf) ? newDataFuu_d : 'z;  

  always @(posedge clk) 
  begin
      if (rst) newData<={DATA_WIDTH{1'B0}};
      else if (~stall)
        newData<=newData_d;
  end
endmodule


module rs_write_forward_JALR(
  clk,rst,
  stall,
  oldData,newData,auxData,auxEn,
  fuFwd,fuuFwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  parameter DATA_WIDTH=`alu_width;
  input clk;
  input rst;
  input stall;
  
  input [DATA_WIDTH-1:0] oldData;
  output reg [DATA_WIDTH-1:0] newData;
  input [DATA_WIDTH-1:0] auxData;
  input auxEn;
  input [3:0] fuFwd;
  input [3:0] fuuFwd;
  
  (* register equiload *) input  [DATA_WIDTH-1:0] FU0;
  input [DATA_WIDTH-1:0] FU0_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU1;
  input [DATA_WIDTH-1:0] FU1_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU2;
  input [DATA_WIDTH-1:0] FU2_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU3;
  input [DATA_WIDTH-1:0] FU3_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU4;
  input [DATA_WIDTH-1:0] FU4_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU5;
  input [DATA_WIDTH-1:0] FU5_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU6;
  input [DATA_WIDTH-1:0] FU6_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU7;
  input [DATA_WIDTH-1:0] FU7_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU8;
  input [DATA_WIDTH-1:0] FU8_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU9;
  input [DATA_WIDTH-1:0] FU9_reg;

  wire [DATA_WIDTH-1:0] newData_d;
  wire [DATA_WIDTH-1:0] newDataFu_d;
  wire [DATA_WIDTH-1:0] newDataFuu_d;
  
  assign newDataFu_d=(fuFwd==4'd0) ? FU0 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd0 && ~auxEn) ? FU0_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd1) ? FU1 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd1 && ~auxEn) ? FU1_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd2) ? FU2 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd2 && ~auxEn) ? FU2_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd3) ? FU3 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd3 && ~auxEn) ? FU3_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd4) ? FU4 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd4 && ~auxEn) ? FU4_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd5) ? FU5 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd5 && ~auxEn) ? FU5_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd6) ? FU6 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd6 && ~auxEn) ? FU6_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd7) ? FU7 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd7 && ~auxEn) ? FU7_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd8) ? FU8 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd8) && ~auxEn ? FU8_reg : 'z;  
  assign newDataFu_d=(fuFwd[3] && |fuFwd[2:0]) ? FU9 : 'z;  
  assign newDataFuu_d=(fuuFwd[3] && |fuuFwd[2:0] && ~auxEn) ? FU9_reg : 'z;  
  assign newDataFuu_d=(auxEn) ? auxData : 'z;  


  assign newData_d=({fuFwd,fuuFwd}==8'hff) ? oldData : 'z;  
  assign newData_d=(fuFwd!=4'hf) ? newDataFu_d : 'z;  
  assign newData_d=(fuuFwd!=4'hf) ? newDataFuu_d : 'z;  

  always @(posedge clk) 
  begin
      if (rst) newData<={DATA_WIDTH{1'B0}};
      else if (~stall)
        newData<=newData_d;
  end
endmodule


module rs_writeiS_forward(
  clk,rst,
  stall,
  oldData,newData,
  fuFwd,fuuFwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  parameter DATA_WIDTH=6;
  input clk;
  input rst;
  input stall;
  
  input [DATA_WIDTH-1:0] oldData;
  output [DATA_WIDTH-1:0] newData;
  input [3:0] fuFwd;
  input [3:0] fuuFwd;
  
  input [DATA_WIDTH-1:0] FU0;
  input [DATA_WIDTH-1:0] FU0_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU1;
  input [DATA_WIDTH-1:0] FU1_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU2;
  input [DATA_WIDTH-1:0] FU2_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU3;
  input [DATA_WIDTH-1:0] FU3_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU4;
  input [DATA_WIDTH-1:0] FU4_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU5;
  input [DATA_WIDTH-1:0] FU5_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU6;
  input [DATA_WIDTH-1:0] FU6_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU7;
  input [DATA_WIDTH-1:0] FU7_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU8;
  input [DATA_WIDTH-1:0] FU8_reg;
  (* register equiload *) input  [DATA_WIDTH-1:0] FU9;
  input [DATA_WIDTH-1:0] FU9_reg;

  wire [DATA_WIDTH-1:0] newData_d;
  wire [DATA_WIDTH-1:0] newDataFu_d;
  wire [DATA_WIDTH-1:0] newDataFuu_d;
  reg [DATA_WIDTH-1:0] oldData_reg;
  
  assign newDataFu_d=(fuFwd==4'd0) ? FU0 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd0) ? FU0_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd1) ? FU1 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd1) ? FU1_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd2) ? FU2 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd2) ? FU2_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd3) ? FU3 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd3) ? FU3_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd4) ? FU4 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd4) ? FU4_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd5) ? FU5 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd5) ? FU5_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd6) ? FU6 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd6) ? FU6_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd7) ? FU7 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd7) ? FU7_reg : 'z;  
  assign newDataFu_d=(fuFwd==4'd8) ? FU8 : 'z;  
  assign newDataFuu_d=(fuuFwd==4'd8) ? FU8_reg : 'z;  
  assign newDataFu_d=(fuFwd[3] && |fuFwd[2:0]) ? FU9 : 'z;  
  assign newDataFuu_d=(fuuFwd[3] && |fuuFwd[2:0]) ? FU9_reg : 'z;  


  assign newData=({fuFwd,fuuFwd}==8'hff) ? oldData_reg : 'z;  
  assign newData=(fuFwd!=4'hf) ? newDataFu_d : 'z;  
  assign newData=(fuuFwd!=4'hf) ? newDataFuu_d : 'z;  

  always @(posedge clk) begin
	  oldData_reg<=oldData;
  end

endmodule




module rs_write_forward_save(
  clk,rst,
  oldData,newData,
  fuFwd,fuuFwd,
  save,en,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  parameter DATA_WIDTH=`alu_width;
  input clk;
  input rst;
  
  input [DATA_WIDTH-1:0] oldData;
  output [DATA_WIDTH-1:0] newData;
  input [3:0] fuFwd;
  input [3:0] fuuFwd;
  input save;
  input en;
  
  input [DATA_WIDTH-1:0] FU0;
  input [DATA_WIDTH-1:0] FU0_reg;
  input [DATA_WIDTH-1:0] FU1;
  input [DATA_WIDTH-1:0] FU1_reg;
  input [DATA_WIDTH-1:0] FU2;
  input [DATA_WIDTH-1:0] FU2_reg;
  input [DATA_WIDTH-1:0] FU3;
  input [DATA_WIDTH-1:0] FU3_reg;
  input [DATA_WIDTH-1:0] FU4;
  input [DATA_WIDTH-1:0] FU4_reg;
  input [DATA_WIDTH-1:0] FU5;
  input [DATA_WIDTH-1:0] FU5_reg;
  input [DATA_WIDTH-1:0] FU6;
  input [DATA_WIDTH-1:0] FU6_reg;
  input [DATA_WIDTH-1:0] FU7;
  input [DATA_WIDTH-1:0] FU7_reg;
  input [DATA_WIDTH-1:0] FU8;
  input [DATA_WIDTH-1:0] FU8_reg;
  input [DATA_WIDTH-1:0] FU9;
  input [DATA_WIDTH-1:0] FU9_reg;

  wire [DATA_WIDTH-1:0] oldDataX;
  wire [3:0] fuFwdX;
  wire [3:0] fuuFwdX;

  reg saved;

  reg [DATA_WIDTH-1:0] oldData_reg;
  reg [3:0] fuFwd_reg;
  reg [3:0] fuuFwd_reg;

  rs_write_forward_nxt fwd_mod(
  clk,rst,
  save,
  oldDataX,newData,
  fuFwdX,fuuFwdX,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  
  assign oldDataX=saved ? oldData_reg : oldData;
  assign fuFwdX=saved ? fuFwd_reg : fuFwd;
  assign fuuFwdX=saved ? fuuFwd_reg : fuuFwd;
  
  always @(posedge clk) begin
      if (rst) saved<=1'b0;
      else saved<=saved | save && en;
      oldData_reg<=oldData;
      fuFwd_reg<=fuuFwd;
      fuuFwd_reg<=4'hf;
  end
  
endmodule



module rs_save(
  clk,rst,
  oldData,newData,
  save,en
  );
  parameter DATA_WIDTH=`alu_width;
  input clk;
  input rst;
  
  input [DATA_WIDTH-1:0] oldData;
  output reg [DATA_WIDTH-1:0] newData;
  input save;
  input en;
  

  wire [DATA_WIDTH-1:0] oldDataX;

  reg saved;

  reg [DATA_WIDTH-1:0] oldData_reg;

 
  assign oldDataX=saved ? oldData_reg : oldData;
  
  always @(posedge clk) begin
      if (rst) saved<=1'b0;
      else saved<=saved | save && en;
      oldData_reg<=oldData;
      if (rst) newData<={DATA_WIDTH{1'B0}};
      else if (~save) newData<=oldDataX;
  end
  
endmodule



module rs_write_forward_nxt(
  clk,rst,
  stall,
  oldData,newData,
  fuFwd,fuuFwd,
  FU0,FU0_reg,
  FU1,FU1_reg,
  FU2,FU2_reg,
  FU3,FU3_reg,
  FU4,FU4_reg,
  FU5,FU5_reg,
  FU6,FU6_reg,
  FU7,FU7_reg,
  FU8,FU8_reg,
  FU9,FU9_reg
  );
  parameter DATA_WIDTH=`alu_width;
  input clk;
  input rst;
  input stall;
  
  input [DATA_WIDTH-1:0] oldData;
  output [DATA_WIDTH-1:0] newData;
  input [3:0] fuFwd;
  input [3:0] fuuFwd;
  
  input [DATA_WIDTH-1:0] FU0;
  input [DATA_WIDTH-1:0] FU0_reg;
  input [DATA_WIDTH-1:0] FU1;
  input [DATA_WIDTH-1:0] FU1_reg;
  input [DATA_WIDTH-1:0] FU2;
  input [DATA_WIDTH-1:0] FU2_reg;
  input [DATA_WIDTH-1:0] FU3;
  input [DATA_WIDTH-1:0] FU3_reg;
  input [DATA_WIDTH-1:0] FU4;
  input [DATA_WIDTH-1:0] FU4_reg;
  input [DATA_WIDTH-1:0] FU5;
  input [DATA_WIDTH-1:0] FU5_reg;
  input [DATA_WIDTH-1:0] FU6;
  input [DATA_WIDTH-1:0] FU6_reg;
  input [DATA_WIDTH-1:0] FU7;
  input [DATA_WIDTH-1:0] FU7_reg;
  input [DATA_WIDTH-1:0] FU8;
  input [DATA_WIDTH-1:0] FU8_reg;
  input [DATA_WIDTH-1:0] FU9;
  input [DATA_WIDTH-1:0] FU9_reg;

  reg  [DATA_WIDTH-1:0] oldData_reg;
  wire [DATA_WIDTH-1:0] newDataFu_d;
  wire [DATA_WIDTH-1:0] newDataFuu_d;
  reg [3:0] fuFwd_reg;
  reg [3:0] fuuFwd_reg;
  
  assign newDataFu_d=(fuFwd_reg==4'd0) ? FU0 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd0) ? FU0_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg==4'd1) ? FU1 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd1) ? FU1_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg==4'd2) ? FU2 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd2) ? FU2_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg==4'd3) ? FU3 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd3) ? FU3_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg==4'd4) ? FU4 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd4) ? FU4_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg==4'd5) ? FU5 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd5) ? FU5_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg==4'd6) ? FU6 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd6) ? FU6_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg==4'd7) ? FU7 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd7) ? FU7_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg==4'd8) ? FU8 : 'z;  
  assign newDataFuu_d=(fuuFwd_reg==4'd8) ? FU8_reg : 'z;  
  assign newDataFu_d=(fuFwd_reg[3] && fuFwd_reg[2:0]!=0) ? FU9 : 
    'z;  
  assign newDataFuu_d=(fuuFwd_reg[3] && fuuFwd_reg[2:0]!=0) ? FU9_reg : 
    'z;  


  assign newData=({fuFwd_reg,fuuFwd_reg}==8'hff) ? oldData_reg : 'z;  
  assign newData=(fuFwd_reg!=4'hf) ? newDataFu_d : 'z;  
  assign newData=(fuuFwd_reg!=4'hf) ? newDataFuu_d : 'z;  

  always @(posedge clk) begin 
      if (rst) oldData_reg<={DATA_WIDTH{1'B0}};
      else if (~stall)
        oldData_reg<=oldData;
      if (rst) begin
          fuFwd_reg<=4'hf;
          fuuFwd_reg<=4'hf;
      end else if (~stall) begin
          fuFwd_reg<=fuFwd;
          fuuFwd_reg<=fuuFwd;
      end
  end
endmodule


