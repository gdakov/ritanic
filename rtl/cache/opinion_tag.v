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


module ccTag_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=`cc1Tag_width;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;

  input clk;
  input rst;
  input [`wport-1:0]read_clkEn;
  input [`wport-1:0][ADDR_WIDTH-1:0] read_addr;
  output [`wport-1:0][DATA_WIDTH-1:0] read_data;
  input [ADDR_WIDTH-1:0] write_addr;
  input [DATA_WIDTH-1:0] write_data;
  input write_wen;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  always @* begin
      for(p2=0;p2<60;p2=p2+1) read_data[p]=ram[read_addr_reg[p]];
  end

  always @(negedge clk)
    begin
      for(p=0;p<60;p=p+1) begin
          if (rst) read_addr_reg[p]<={ADDR_WIDTH{1'b0}};
         else if (read_clkEn[p]) read_addr_reg[p]<=read_addr[p];
      end
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module ccTag_lram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=3;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;

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

  always @(negedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule



module ccTag(
  clk,
  rst,
  read_clkEn,
  read_phys_addr,
  read_hit,
  read_err,
  write_phys_addr,
  write_wen,
  invalidate,
  hitNRU,hitNRU_in,
  hitNRU_reg,
  write_hit,
  write_expun_addr,
  write_exp_en,
  EI,
  init
  );

  parameter [1:0] INDEX=0;
  parameter [0:0] EXT=1'b0;
  localparam DATA_WIDTH=`cc1Tag_width;
  localparam ADDR_WIDTH=7;
  localparam ADDR_COUNT=128;
  localparam PHYS_BITS=44;
  localparam VIRT_BITS=64;

  input clk;
  input rst;
  input [`wport-1:0] read_clkEn;
  input [`wport-1:0] [PHYS_BITS-8:0] read_phys_addr;
  output [`wport-1:0] read_hit;
  output [`wport-1:0] read_err;
  
  input [PHYS_BITS-8:0] write_phys_addr;
  input write_wen;
  input invalidate;
  
  
  output [2:0] hitNRU;
  input [2:0] hitNRU_in;
  input [2:0] hitNRU_reg;
  output write_hit;
  output [36:0] write_expun_addr;
  output write_exp_en;
  inout [7:0] EI;
  input init;

  wire [`wport-1:0][PHYS_BITS-8:0] tag_paddr;
  wire [`wport-1:0]tag_valid;


  wire [`wport-1:0][DATA_WIDTH-1:0] read_data;
  wire [`wport-1:0][DATA_WIDTH-1:0] readW_data;
  wire [`wport-1:0][DATA_WIDTH-1:0] read_dataW;

  wire [DATA_WIDTH-1:0] write_data_way;
  wire [DATA_WIDTH-1:0] write_data_new;
  
  reg [`wport-1:0] read_clkEn_reg;
  reg [`wport-1:0] read_clkEn_reg2;

  reg [`wport-1:0] read_hit_reg;

  reg [`wport-1:0] [PHYS_BITS-8:0] read_phys_addr_reg;
  reg [PHYS_BITS-8:0] write_phys_addr_reg;
  reg [`wport-1:0] [PHYS_BITS-8:0] read_phys_addr_reg2;
 

  wire [2:0] read_NRUr;
  wire [2:0] read_NRUw;
  wire [2:0] write_NRU;

  wire [5:0] POOG;

  
  reg write_wen_reg;

  reg [2:0] read_NRUr_reg;
  
  reg invalidate_reg;
  reg init_reg,init_reg2;
  
  always @ * begin
      for(p=0;p<60;p=p+1) begin
          tag_paddr[p]=read_data[p][`cc1Tag_paddr];
          tag_valid[p]=read_data[p][`cc1Tag_valid];
          read_err[p]=^read_data[p];
          read_hit[p]=tag_valid[p] && tag_paddr[p]==read_phys_addr_reg[p] && ~init && read_clkEn_reg[p];
          read_phys_addr0[p]=read_phys_addr[p][5:0];
      end
  end

  
  assign write_data_way=(invalidate_reg | init_reg) ? {DATA_WIDTH{1'B0}} : write_data_new;
  
  assign write_data_new[`cc1Tag_valid]=1'b1;
  assign write_data_new[`cc1Tag_paddr]=write_phys_addr_reg;
  assign write_data_new[`cc1Tag_parity]=^write_data_new[DATA_WIDTH-2:0];

  assign write_expun_addr=read_dataW[59][`cc1Tag_paddr] & {37{write_hit}};
  assign write_exp_en=write_hit && read_dataW[59][`cc1Tag_valid ];

  generate
    if (INDEX[0]) begin
        assign hitNRU=~(~({3{read_hit_reg[59]}} & read_NRUr_reg) & hitNRU_in); 
    end else begin
        assign hitNRU=~(({3{read_hit_reg[59]}} & read_NRUr_reg) | hitNRU_in); 
    end
  endgenerate

  LFSR16_6 #(16'hfead) pp_mod(clk,rst,POOG);

  assign EI[index]=write_wen && read_dataW[59][`cc1Tag_paddr]==write_phys_addr_reg && read_dataW[59][`cc1Tag_valid];

  assign write_hit=(write_wen_reg && read_NRUw==POOG[2:0]) && ~|EI;

  ccTag_ram ram_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_phys_addr0),
  .read_data(read_data),
  .write_addr(write_phys_addr_reg[5:0]),
  .write_data(write_data_way),
  .write_wen(write_hit|init_reg)
  );

  ccTag_ram ramW_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(write_phys_addr[6:0]),
  .read_data(read_dataW),
  .write_addr(write_phys_addr_reg[5:0]),
  .write_data(write_data_way),
  .write_wen(write_hit|init_reg)
  );

  ccTag_lram lram0_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_phys_addr[6:0]),
  .read_data(read_NRUr),
  .write_addr(read_phys_addr_reg2[59][5:0]),
  .write_data(write_NRU),
  .write_wen(EXT ? init_reg2 : read_clkEn_reg2[59]|init_reg2)
  );

  ccTag_lram lram1_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(write_wen),
  .read_addr(write_phys_addr[5:0]),
  .read_data(read_NRUw),
  .write_addr(read_phys_addr_reg2[59][5:0]),
  .write_data(write_NRU),
  .write_wen(EXT ? init_reg2 : read_clkEn_reg2[59]|init_reg2)
  );

  lru_single #(3,INDEX) NRU_mod(
  .lru(read_NRUr_reg),
  .newLRU(write_NRU),
  .LRU_hit(hitNRU_reg),
  .init(init_reg2),
  .en(read_clkEn_reg2)
  );

  
  always @(negedge clk)
  begin
      if (rst) read_clkEn_reg<=1'b0;
      else read_clkEn_reg<=read_clkEn;
      if (rst) read_clkEn_reg2<=1'b0;
      else read_clkEn_reg2<=read_clkEn_reg;
      if (rst) begin
          read_phys_addr_reg<=0;
          write_phys_addr_reg<=0;
          write_wen_reg<=0;
          read_NRUr_reg<=3'b0;
          invalidate_reg<=1'b0;
          read_phys_addr_reg2<=0;
          init_reg<=1'b0;
          init_reg2<=1'b0;
	  read_hit_reg<=0;
      end
      else begin
          read_phys_addr_reg<=read_phys_addr;
          write_phys_addr_reg<=write_phys_addr;
          write_wen_reg<=write_wen;
          read_NRUr_reg<=read_NRUr;
          invalidate_reg<=invalidate;
          read_phys_addr_reg2<=read_phys_addr_reg;
          init_reg<=init;
          init_reg2<=init_reg;
	  read_hit_reg<=read_hit;
      end
      if (write_wen_reg) $display("whit ",write_data_way," lruw ",read_NRUw);
     // if (read_clkEn_reg) $display("rhit ",read_phys_addr_reg," ",read_hit);
  end
  
endmodule

