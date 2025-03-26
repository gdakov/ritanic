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

module dcache_dirty_ram(
  clk,
  rst,
  read_addr0,read_clkEn0, read_data0,
  
  write_addr0, write_wen0, write_bitEn0, write_data0,
  write_addr1, write_wen1, write_bitEn1, write_data1
  );
  localparam ADDR_WIDTH=3;
  localparam DATA_WIDTH=8;
  localparam ADDR_COUNT=8;

  input pwire clk;
  input pwire rst;
  input pwire [ADDR_WIDTH-1:0] read_addr0;
  input pwire read_clkEn0;
  output pwire [DATA_WIDTH-1:0] read_data0;

  input pwire [ADDR_WIDTH-1:0] write_addr0;
  input pwire write_wen0;
  input pwire [DATA_WIDTH-1:0] write_bitEn0;
  input pwire [DATA_WIDTH-1:0] write_data0;
  input pwire [ADDR_WIDTH-1:0] write_addr1;
  input pwire write_wen1;
  input pwire [DATA_WIDTH-1:0] write_bitEn1;
  input pwire [DATA_WIDTH-1:0] write_data1;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];

  reg [ADDR_WIDTH-1:0] read_addr0_reg;

  integer k;
  
  assign read_data0=ram[read_addr0_reg];
  
  always @(posedge clk) begin
      if (write_wen0) for (k=0;k<8;k=k+1) if (write_bitEn0[k]) ram[write_addr0][k]<=write_data0[k];
      if (write_wen1) for (k=0;k<8;k=k+1) if (write_bitEn1[k]) ram[write_addr1][k]<=write_data1[k];
      if (rst) begin
          read_addr0_reg<={ADDR_WIDTH{1'B0}};
      end else begin
          if (read_clkEn0) read_addr0_reg<=read_addr0;
      end
  end
endmodule
  
  
  
module dcache_dirty(
  clk,
  rst,
  read_addr0,read_clkEn0, read_dirty0,
  
  write_addr0, write_wen0, 
  write_addr1, write_wen1,
  insert,insert_dirty,
  init
  );
  localparam ADDR_WIDTH=6;
  localparam DATA_WIDTH=8;

  input pwire clk;
  input pwire rst;
  input pwire [ADDR_WIDTH-1:0] read_addr0;
  input pwire read_clkEn0;
  output pwire read_dirty0;
  input pwire [ADDR_WIDTH-1:0] write_addr0;
  input pwire write_wen0;
  input pwire [ADDR_WIDTH-1:0] write_addr1;
  input pwire write_wen1;
  input pwire insert;
  input pwire insert_dirty;
  input pwire init;

  pwire [DATA_WIDTH-1:0] read_data0;
  pwire [DATA_WIDTH-1:0] write_data0;
  pwire [DATA_WIDTH-1:0] write_data1;
  
  reg [5:3] read_addr0_reg;
  
  
  dcache_dirty_ram ram_mod(
  clk,
  rst,
  read_addr0[2:0],read_clkEn0, read_data0,
  
  write_addr0[2:0], write_wen0|init|insert, 
    write_data0|{DATA_WIDTH{init}}, write_data0|{DATA_WIDTH{init}},
  write_addr1[2:0], write_wen1, write_data1, write_data1
  );
  
  
  generate
      genvar k;
      for (k=0;k<4;k=k+1) begin
          assign read_dirty0=(read_addr0_reg[5:3]==k) ? read_data0[k] : 1'bz;
          
          assign write_data0[k]=write_addr0[5:3]==k && write_wen0 && (insert_dirty|~insert);
          assign write_data1[k]=write_addr1[5:3]==k && write_wen1;
      end
  endgenerate
  
  always @(negedge clk) begin
      if (rst) begin
          read_addr0_reg<=3'b0;
      end else begin
          if (read_clkEn0) read_addr0_reg<=read_addr0[5:3];
      end
  end

endmodule  

