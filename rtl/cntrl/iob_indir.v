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


module BOBind_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  parameter ADDR_WIDTH=`bob_addr_width;
  parameter DATA_WIDTH=65;
  parameter ADDR_COUNT=`bob_count;

  input clk;
  input rst;
  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  output [DATA_WIDTH-1:0] read_data;
  input [ADDR_WIDTH-1:0] write_addr;
  input [DATA_WIDTH-1:0] write_data;
  input write_wen;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule


module BOBind_ready_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write0_addr,
  write0_data,
  write0_wen,
  write1_addr,
  write1_data,
  write1_wen
  );

  parameter ADDR_WIDTH=`bob_addr_width;
  parameter DATA_WIDTH=1;
  parameter ADDR_COUNT=`bob_count;

  input clk;
  input rst;
  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  output [DATA_WIDTH-1:0] read_data;
  input [ADDR_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;
  input [ADDR_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;
  
  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write0_wen) ram[write0_addr]<=write0_data;
      if (write1_wen) ram[write1_addr]<=write1_data;
    end

endmodule

module BOBind(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  read_ready,
  write_addr,
  write_data,
  write_wen,
  writeI_addr,
  writeI_ready,
  writeI_wen
  );

  parameter ADDR_WIDTH=`bob_addr_width;
  parameter DATA_WIDTH=65;
  parameter ADDR_COUNT=`bob_count;

  input clk;
  input rst;
  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  output [DATA_WIDTH-1:0] read_data;
  output read_ready;
  input [ADDR_WIDTH-1:0] write_addr;
  input [DATA_WIDTH-1:0] write_data;
  input write_wen;
  input [ADDR_WIDTH-1:0] writeI_addr;
  input writeI_ready;
  input writeI_wen;

  
  BOBind_ram ram_mod(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  BOBind_ready_ram rdy_mod(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_ready,
  write_addr,
  1'b1,
  write_wen,
  writeI_addr,
  writeI_ready,
  writeI_wen
  );

endmodule

