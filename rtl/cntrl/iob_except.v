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


module iob_except_ram(
  clk,
  rst,
  read_burst,
  read_addr,
  read_data,
  
  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen,
  write4_addr,write4_data,write4_wen,
  write5_addr,write5_data,write5_wen,
  write6_addr,write6_data,write6_wen,
  write7_addr,write7_data,write7_wen,
  write8_addr,write8_data,write8_wen,
  write9_addr,write9_data,write9_wen
  );
  
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;
  parameter DATA_WIDTH=`except_width; 
//  localparam UNIT=`except_width;

  input clk;
  input rst;
  
  input read_burst;
  input [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  
  input [ADDR_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;

  input [ADDR_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;

  input [ADDR_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input write2_wen;

  input [ADDR_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input write3_wen;

  input [ADDR_WIDTH-1:0] write4_addr;
  input [DATA_WIDTH-1:0] write4_data;
  input write4_wen;

  input [ADDR_WIDTH-1:0] write5_addr;
  input [DATA_WIDTH-1:0] write5_data;
  input write5_wen;

  input [ADDR_WIDTH-1:0] write6_addr;
  input [DATA_WIDTH-1:0] write6_data;
  input write6_wen;

  input [ADDR_WIDTH-1:0] write7_addr;
  input [DATA_WIDTH-1:0] write7_data;
  input write7_wen;

  input [ADDR_WIDTH-1:0] write8_addr;
  input [DATA_WIDTH-1:0] write8_data;
  input write8_wen;

  input [ADDR_WIDTH-1:0] write9_addr;
  input [DATA_WIDTH-1:0] write9_data;
  input write9_wen;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];

  reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];
  
  always @(posedge clk)
    begin
      if (write0_wen) ram[write0_addr]<=write0_data;
      if (write1_wen) ram[write1_addr]<=write1_data;
      if (write2_wen) ram[write2_addr]<=write2_data;
      if (write3_wen) ram[write3_addr]<=write3_data;
      if (write4_wen) ram[write4_addr]<=write4_data;
      if (write5_wen) ram[write5_addr]<=write5_data;
      if (write6_wen) ram[write6_addr]<=write6_data;
      if (write7_wen) ram[write7_addr]<=write7_data;
      if (write8_wen) ram[write8_addr]<=write8_data;
      if (write9_wen) ram[write9_addr]<=write9_data;
      
      if (read_burst) read_addr_reg<=read_addr;
    end    
endmodule


module iob_except(
  clk,
  rst,
  read_step,
  read_addr,
  read_data0,
  read_data1,
  read_data2,
  read_data3,
  read_data4,
  read_data5,
  read_data6,
  read_data7,
  read_data8,
  read_data9,
  
  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen,
  write4_addr,write4_data,write4_wen,
  write5_addr,write5_data,write5_wen,
  write6_addr,write6_data,write6_wen,
  write7_addr,write7_data,write7_wen,
  write8_addr,write8_data,write8_wen,
  writeInit_addr,writeInit_wen,
  writeInit_data0,
  writeInit_data1,
  writeInit_data2,
  writeInit_data3,
  writeInit_data4,
  writeInit_data5,
  writeInit_data6,
  writeInit_data7,
  writeInit_data8,
  writeInit_data9
  );
  
  localparam ADDR_WIDTH=10;
  localparam ADDR_COUNT=48;
  parameter DATA_WIDTH=`except_width; 
  localparam UNIT=DATA_WIDTH;

  input clk;
  input rst;
  
  input read_step;
  input [5:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data0;
  output pwire [DATA_WIDTH-1:0] read_data1;
  output pwire [DATA_WIDTH-1:0] read_data2;
  output pwire [DATA_WIDTH-1:0] read_data3;
  output pwire [DATA_WIDTH-1:0] read_data4;
  output pwire [DATA_WIDTH-1:0] read_data5;
  output pwire [DATA_WIDTH-1:0] read_data6;
  output pwire [DATA_WIDTH-1:0] read_data7;
  output pwire [DATA_WIDTH-1:0] read_data8;
  output pwire [DATA_WIDTH-1:0] read_data9;
  
  input [ADDR_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;

  input [ADDR_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;

  input [ADDR_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input write2_wen;

  input [ADDR_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input write3_wen;

  input [ADDR_WIDTH-1:0] write4_addr;
  input [DATA_WIDTH-1:0] write4_data;
  input write4_wen;

  input [ADDR_WIDTH-1:0] write5_addr;
  input [DATA_WIDTH-1:0] write5_data;
  input write5_wen;

  input [ADDR_WIDTH-1:0] write6_addr;
  input [DATA_WIDTH-1:0] write6_data;
  input write6_wen;

  input [ADDR_WIDTH-1:0] write7_addr;
  input [DATA_WIDTH-1:0] write7_data;
  input write7_wen;

  input [ADDR_WIDTH-1:0] write8_addr;
  input [DATA_WIDTH-1:0] write8_data;
  input write8_wen;



  input [5:0] writeInit_addr;
  input writeInit_wen;
  input [DATA_WIDTH-1:0] writeInit_data0;
  input [DATA_WIDTH-1:0] writeInit_data1;
  input [DATA_WIDTH-1:0] writeInit_data2;
  input [DATA_WIDTH-1:0] writeInit_data3;
  input [DATA_WIDTH-1:0] writeInit_data4;
  input [DATA_WIDTH-1:0] writeInit_data5;
  input [DATA_WIDTH-1:0] writeInit_data6;
  input [DATA_WIDTH-1:0] writeInit_data7;
  input [DATA_WIDTH-1:0] writeInit_data8;
  input [DATA_WIDTH-1:0] writeInit_data9;
 
  pwire [DATA_WIDTH-1:0] writeInit_data[9:0];
  pwire [DATA_WIDTH-1:0] read_data[9:0];

  generate
    genvar k;
    for(k=0;k<=9;k=k+1) begin : rams_gen
        iob_except_ram #(DATA_WIDTH) ram_mod(
        clk,
        rst,
        
        read_step,
        read_addr,
        read_data[k],
  
        write0_addr[9:4],write0_data,write0_wen && write0_addr[3:0]==k,
        write1_addr[9:4],write1_data,write1_wen && write1_addr[3:0]==k,
        write2_addr[9:4],write2_data,write2_wen && write2_addr[3:0]==k,
        write3_addr[9:4],write3_data,write3_wen && write3_addr[3:0]==k,
        write4_addr[9:4],write4_data,write4_wen && write4_addr[3:0]==k,
        write5_addr[9:4],write5_data,write5_wen && write5_addr[3:0]==k,
        write6_addr[9:4],write6_data,write6_wen && write6_addr[3:0]==k,
        write7_addr[9:4],write7_data,write7_wen && write7_addr[3:0]==k,
        write8_addr[9:4],write8_data,write8_wen && write8_addr[3:0]==k,
        writeInit_addr,writeInit_data[k],writeInit_wen
        );
    end
  endgenerate
  
  assign writeInit_data[0]=writeInit_data0;
  assign writeInit_data[1]=writeInit_data1;
  assign writeInit_data[2]=writeInit_data2;
  assign writeInit_data[3]=writeInit_data3;
  assign writeInit_data[4]=writeInit_data4;
  assign writeInit_data[5]=writeInit_data5;
  assign writeInit_data[6]=writeInit_data6;
  assign writeInit_data[7]=writeInit_data7;
  assign writeInit_data[8]=writeInit_data8;
  assign writeInit_data[9]=writeInit_data9;

  assign read_data0=read_data[0];
  assign read_data1=read_data[1];
  assign read_data2=read_data[2];
  assign read_data3=read_data[3];
  assign read_data4=read_data[4];
  assign read_data5=read_data[5];
  assign read_data6=read_data[6];
  assign read_data7=read_data[7];
  assign read_data8=read_data[8];
  assign read_data9=read_data[9];

endmodule
