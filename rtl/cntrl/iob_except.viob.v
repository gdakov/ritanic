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


module bob_except_ram(
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

  input pwire clk;
  input pwire rst;
  
  input pwire read_burst;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  
  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire write0_wen;

  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire [DATA_WIDTH-1:0] write1_data;
  input pwire write1_wen;

  input pwire [ADDR_WIDTH-1:0] write2_addr;
  input pwire [DATA_WIDTH-1:0] write2_data;
  input pwire write2_wen;

  input pwire [ADDR_WIDTH-1:0] write3_addr;
  input pwire [DATA_WIDTH-1:0] write3_data;
  input pwire write3_wen;

  input pwire [ADDR_WIDTH-1:0] write4_addr;
  input pwire [DATA_WIDTH-1:0] write4_data;
  input pwire write4_wen;

  input pwire [ADDR_WIDTH-1:0] write5_addr;
  input pwire [DATA_WIDTH-1:0] write5_data;
  input pwire write5_wen;

  input pwire [ADDR_WIDTH-1:0] write6_addr;
  input pwire [DATA_WIDTH-1:0] write6_data;
  input pwire write6_wen;

  input pwire [ADDR_WIDTH-1:0] write7_addr;
  input pwire [DATA_WIDTH-1:0] write7_data;
  input pwire write7_wen;

  input pwire [ADDR_WIDTH-1:0] write8_addr;
  input pwire [DATA_WIDTH-1:0] write8_data;
  input pwire write8_wen;

  input pwire [ADDR_WIDTH-1:0] write9_addr;
  input pwire [DATA_WIDTH-1:0] write9_data;
  input pwire write9_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];

  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
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


module bob_except(
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

  input pwire clk;
  input pwire rst;
  
  input pwire read_step;
  input pwire [5:0] read_addr;
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
  
  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire write0_wen;

  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire [DATA_WIDTH-1:0] write1_data;
  input pwire write1_wen;

  input pwire [ADDR_WIDTH-1:0] write2_addr;
  input pwire [DATA_WIDTH-1:0] write2_data;
  input pwire write2_wen;

  input pwire [ADDR_WIDTH-1:0] write3_addr;
  input pwire [DATA_WIDTH-1:0] write3_data;
  input pwire write3_wen;

  input pwire [ADDR_WIDTH-1:0] write4_addr;
  input pwire [DATA_WIDTH-1:0] write4_data;
  input pwire write4_wen;

  input pwire [ADDR_WIDTH-1:0] write5_addr;
  input pwire [DATA_WIDTH-1:0] write5_data;
  input pwire write5_wen;

  input pwire [ADDR_WIDTH-1:0] write6_addr;
  input pwire [DATA_WIDTH-1:0] write6_data;
  input pwire write6_wen;

  input pwire [ADDR_WIDTH-1:0] write7_addr;
  input pwire [DATA_WIDTH-1:0] write7_data;
  input pwire write7_wen;

  input pwire [ADDR_WIDTH-1:0] write8_addr;
  input pwire [DATA_WIDTH-1:0] write8_data;
  input pwire write8_wen;



  input pwire [5:0] writeInit_addr;
  input pwire writeInit_wen;
  input pwire [DATA_WIDTH-1:0] writeInit_data0;
  input pwire [DATA_WIDTH-1:0] writeInit_data1;
  input pwire [DATA_WIDTH-1:0] writeInit_data2;
  input pwire [DATA_WIDTH-1:0] writeInit_data3;
  input pwire [DATA_WIDTH-1:0] writeInit_data4;
  input pwire [DATA_WIDTH-1:0] writeInit_data5;
  input pwire [DATA_WIDTH-1:0] writeInit_data6;
  input pwire [DATA_WIDTH-1:0] writeInit_data7;
  input pwire [DATA_WIDTH-1:0] writeInit_data8;
  input pwire [DATA_WIDTH-1:0] writeInit_data9;
 
  pwire [DATA_WIDTH-1:0] writeInit_data[9:0];
  pwire [DATA_WIDTH-1:0] read_data[9:0];

  generate
    genvar k;
    for(k=0;k<=9;k=k+1) begin : rams_gen
        bob_except_ram #(DATA_WIDTH) ram_mod(
        clk,
        rst,
        
        read_step,
        read_addr,
        read_data[k],
  
        write0_addr[9:4],write0_data,write0_wen && pwh#(4)::cmpEQ(write0_addr[3:0],k),
        write1_addr[9:4],write1_data,write1_wen && pwh#(4)::cmpEQ(write1_addr[3:0],k),
        write2_addr[9:4],write2_data,write2_wen && pwh#(4)::cmpEQ(write2_addr[3:0],k),
        write3_addr[9:4],write3_data,write3_wen && pwh#(4)::cmpEQ(write3_addr[3:0],k),
        write4_addr[9:4],write4_data,write4_wen && pwh#(4)::cmpEQ(write4_addr[3:0],k),
        write5_addr[9:4],write5_data,write5_wen && pwh#(4)::cmpEQ(write5_addr[3:0],k),
        write6_addr[9:4],write6_data,write6_wen && pwh#(4)::cmpEQ(write6_addr[3:0],k),
        write7_addr[9:4],write7_data,write7_wen && pwh#(4)::cmpEQ(write7_addr[3:0],k),
        write8_addr[9:4],write8_data,write8_wen && pwh#(4)::cmpEQ(write8_addr[3:0],k),
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
