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



module mreq_ram(
  clk,
  rst,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=44-7;
  localparam ADDR_WIDTH=4;
  localparam ADDR_COUNT=16;
  
  input clk;
  input rst;
  input [ADDR_WIDTH-1:0] read_addr;
  output [DATA_WIDTH-1:0] read_data;
  input [ADDR_WIDTH-1:0] write_addr;
  input [DATA_WIDTH-1:0] write_data;
  input write_wen;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  
  assign read_data=ram[read_addr];

  always @(posedge clk)
    begin
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule


module mreq(
  clk,
  rst,
  nextReq,
  reqSend,
  reqAddr,
  insReq,
  insAddr,
  insEn,
  insEn_data,
  insEn_code
  );
  localparam PHYS_WIDTH=44;
  parameter [4:0] BUS_ID=0;
  
  input clk;
  input rst;
  input [3:0] nextReq;
  input reqSend;
  input [PHYS_WIDTH-8:0] reqAddr;
  input [9:0] insReq;
  output [PHYS_WIDTH-8:0] insAddr;
  input insEn;
  output insEn_data;
  output insEn_code;

  reg [15:0] free;

  integer m;
  
  
  assign insEn_data=insEn && BUS_ID==insReq[9:5] && ~insReq[4];
  assign insEn_code=insEn && BUS_ID==insReq[9:5] && insReq[4];
  
  mreq_ram ram_mod(
  .clk(clk),
  .rst(rst),
  .read_addr(insReq[3:0]),
  .read_data(insAddr),
  .write_addr(nextReq),
  .write_data(reqAddr),
  .write_wen(reqSend)
  );

  
endmodule
