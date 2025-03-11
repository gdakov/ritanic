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


//dcache1_tag_ram read during write behaviour: write first
module dcache1_tag_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=`dcache1_addr_width-1;
  localparam ADDR_COUNT=`dcache1_addr_count/2;
  localparam DATA_WIDTH=`dc1Tag_width;
  
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

//dcache1_tag_ram read during write behaviour: write first
module dcache1_tagV_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write0_addr, write0_data,  write0_wen,
  write1_addr, write1_data,  write1_wen,
  write2_addr, write2_data,  write2_wen,
  write3_addr, write3_data,  write3_wen,
  write4_addr, write4_data,  write4_wen,
  write5_addr, write5_data,  write5_wen,
  write6_addr, write6_data,  write6_wen
  );
  localparam ADDR_WIDTH=`dcache1_addr_width-1;
  localparam ADDR_COUNT=`dcache1_addr_count/2;
  localparam DATA_WIDTH=1;
  
  input clk;
  input rst;
  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  output [DATA_WIDTH-1:0] read_data;
  input [ADDR_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input                  write0_wen;
  input [ADDR_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input                  write1_wen;
  input [ADDR_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input                  write2_wen;
  input [ADDR_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input                  write3_wen;
  input [ADDR_WIDTH-1:0] write4_addr;
  input [DATA_WIDTH-1:0] write4_data;
  input                  write4_wen;
  input [ADDR_WIDTH-1:0] write5_addr;
  input [DATA_WIDTH-1:0] write5_data;
  input                  write5_wen;
  input [ADDR_WIDTH-1:0] write6_addr;
  input [DATA_WIDTH-1:0] write6_data;
  input                  write6_wen;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(negedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write0_wen) ram[write0_addr]<=write0_data;
      if (write1_wen) ram[write1_addr]<=write1_data;
      if (write2_wen) ram[write2_addr]<=write2_data;
      if (write3_wen) ram[write3_addr]<=write3_data;
      if (write4_wen) ram[write4_addr]<=write4_data;
      if (write5_wen) ram[write5_addr]<=write5_data;
      if (write6_wen) ram[write7_addr]<=write6_data;
    end

endmodule


module dcache1_tag(
  clk,
  rst,
  read_clkEn,
  read_en,
  read_addrOdd,read_addrEven,read_odd, read_split, read_invl, 
  read_exclOut0,read_exclOut1,
  read_hitL_odd,read_hitL_even,read_hitH_odd,read_hitH_even,
  read_hit_odd, read_hit_even,
  errH,errL,
 // read_excl,
  write_exclusive,
  write_rand,
  write_recent_out,
  write_recent_in,
  write_wen,
  write_hit,
  wb_addr,
  wb_valid,
  puke_en,puke_addr
  );
  localparam PADDR_WIDTH=44;
  localparam DATA_WIDTH=`dc1Tag_width;
  parameter [2:0] INDEX=0;
  
  input clk;
  input rst;
  input read_clkEn;
  input read_en;
  input [PADDR_WIDTH-9:0] read_addrOdd;
  input [PADDR_WIDTH-9:0] read_addrEven;
  input read_odd;
  input read_split;
  input read_invl;
  output read_exclOut0;
  output read_exclOut1;
  output reg read_hitL_odd,read_hitL_even,read_hitH_odd,read_hitH_even;
  output read_hit_odd,read_hit_even;
 // output [1:0] read_excl;  
  output errH,errL;
  input write_exclusive;
  input [5:0] write_rand;
  output write_recent_out;
  input write_recent_in;
  input write_wen;
  output write_hit;
  output [PADDR_WIDTH-8:0] wb_addr;
  output wb_valid;
  input [5:0] puke_en;
  input [6:0] puke_addr;

  wire [PADDR_WIDTH-9:0] tagR0_IP;
  wire [PADDR_WIDTH-9:0] tagR1_IP;

  wire tagR0_valid,tagR1_valid;
  wire tagR0_exclusive,tagR1_exclusive;
  wire hit_odd;
  wire hit_even;
  
  wire [`dc1Tag_width-1:0] tagR0_data;
  wire [`dc1Tag_width-1:0] tagR1_data;
  wire [`dc1Tag_width-1:0] tag_write_data;
  wire [`dc1Tag_width-1:0] tag_same_data;
  
  reg [PADDR_WIDTH-9:0] read_addrOdd_reg;
  reg [PADDR_WIDTH-9:0] read_addrEven_reg;
  reg read_odd_reg;
  reg read_split_reg;
  reg write_wen_reg;
  
  reg init;
  reg [5:0] initCount;
  wire [5:0] initCount_d;
  wire recent;
  
  reg read_invl_reg;
  reg read_en_reg;
  
  wire write_hit1;
  wire write_hit2;
/* verilator lint_off WIDTH */  
  dcache1_tag_ram tagR0_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_addrEven[6:0]),
  .read_data(tagR0_data),
  .write_addr(init ? initCount : read_addrEven_reg[5:0]),
  .write_data(write_hit ? tag_write_data&{DATA_WIDTH{~init}} : 
    tag_same_data&{DATA_WIDTH{~init}}),
  .write_wen(write_hit&~read_odd_reg || read_en_reg & (~read_odd_reg) ||init)
  );  

  dcache1_tag_ram tagR1_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_addrOdd[6:0]),
  .read_data(tagR1_data),
  .write_addr(init ? initCount : read_addrOdd_reg[5:0]),
  .write_data(write_hit ? tag_write_data&{DATA_WIDTH{~init}} : 
    tag_same_data&{DATA_WIDTH{~init}}),
  .write_wen(write_hit&read_odd_reg || read_en_reg & (read_odd_reg)||init)
  );  

  dcache1_tagV_ram tagR0v_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_addrEven[6:0]),
  .read_data(tagR0_valid),
  .write0_addr(init ? initCount : read_addrEven_reg[5:0]),
  .write0_data(write_hit ? tag_write_data[`dc1Tag_valid]&{1{~init}} : 
    tag_same_data[`dc1Tag_valid]&{1{~init}}),
  .write0_wen(write_hit&~read_odd_reg || read_en_reg & (~read_odd_reg) ||init),
  .write1_addr(puke_addr[0][5:0]),.write1_data(1'b0), .write1_wen(puke_en[0]&~puke_addr[0][6]),
  .write2_addr(puke_addr[1][5:0]),.write2_data(1'b0), .write2_wen(puke_en[1]&~puke_addr[1][6]),
  .write3_addr(puke_addr[2][5:0]),.write3_data(1'b0), .write3_wen(puke_en[2]&~puke_addr[2][6]),
  .write4_addr(puke_addr[3][5:0]),.write4_data(1'b0), .write4_wen(puke_en[3]&~puke_addr[3][6]),
  .write5_addr(puke_addr[4][5:0]),.write5_data(1'b0), .write5_wen(puke_en[4]&~puke_addr[4][6]),
  .write6_addr(puke_addr[5][5:0]),.write6_data(1'b0), .write6_wen(puke_en[5]&~puke_addr[5][6])
  );  

  dcache1_tagV_ram tagR1v_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_addrOdd[6:0]),
  .read_data(tagR1_valid),
  .write0_addr(init ? initCount : read_addrOdd_reg[5:0]),
  .write0_data(write_hit ? tag_write_data[`dc1Tag_valid]&{1{~init}} : 
    tag_same_data[`dc1Tag_valid]&{1{~init}}),
  .write0_wen(write_hit&read_odd_reg || read_en_reg & (read_odd_reg)||init),
  .write1_addr(puke_addr[0][5:0]),.write1_data(1'b0), .write1_wen(puke_en[0]&puke_addr[0][6]),
  .write2_addr(puke_addr[1][5:0]),.write2_data(1'b0), .write2_wen(puke_en[1]&puke_addr[1][6]),
  .write3_addr(puke_addr[2][5:0]),.write3_data(1'b0), .write3_wen(puke_en[2]&puke_addr[2][6]),
  .write4_addr(puke_addr[3][5:0]),.write4_data(1'b0), .write4_wen(puke_en[3]&puke_addr[3][6]),
  .write5_addr(puke_addr[4][5:0]),.write5_data(1'b0), .write5_wen(puke_en[4]&puke_addr[4][6]),
  .write6_addr(puke_addr[5][5:0]),.write6_data(1'b0), .write6_wen(puke_en[5]&puke_addr[5][6])
  );  
/* verilator lint_on WIDTH */

  adder_inc #(6) initAdd_mod(initCount,initCount_d,1'b1,);

  assign  tagR0_IP={tagR0_data[`dc1Tag_addr_43_14],read_addrEven_reg[5:0]};
  assign  tagR1_IP={tagR1_data[`dc1Tag_addr_43_14],read_addrOdd_reg[5:0]};
//  assign  tagR0_valid=tagR0_data[`dc1Tag_valid] & ~err_tag0;
//  assign  tagR1_valid=tagR1_data[`dc1Tag_valid] & ~err_tag1;
  assign  tagR0_exclusive=tagR0_data[`dc1Tag_exclusive] & ~err_tag0;
  assign  tagR1_exclusive=tagR1_data[`dc1Tag_exclusive] & ~err_tag1;

  assign  recent=read_odd_reg ? tagR1_data[`dc1Tag_recent] : tagR0_data[`dc1Tag_recent];
  assign  write_recent_out=write_rand[2:0]==INDEX && recent;
  
  assign err_tag0=^tagR0_data;
  assign err_tag1=^tagR1_data;
 
  assign read_exclOut0=tagR0_exclusive;
  assign read_exclOut1=tagR1_exclusive;
  
  assign hit_odd=tagR1_IP==read_addrOdd_reg && tagR1_valid && read_en_reg;
  assign hit_even=tagR0_IP==read_addrEven_reg && tagR0_valid && read_en_reg;

  assign tag_write_data[`dc1Tag_addr_43_14]=read_odd_reg ? read_addrOdd_reg[PADDR_WIDTH-9:6] : read_addrEven_reg[PADDR_WIDTH-9:6];
  assign tag_write_data[`dc1Tag_valid]=1'b1;
  assign tag_write_data[`dc1Tag_recent]=1'b0;
  assign tag_write_data[`dc1Tag_exclusive]=write_exclusive;
  assign tag_write_data[`dc1Tag_parity]=^tag_write_data[DATA_WIDTH-2:0];

  assign tag_same_data[`dc1Tag_addr_43_14]=read_odd_reg ? tagR1_IP[PADDR_WIDTH-9:6] : tagR0_IP[PADDR_WIDTH-9:6];
  assign tag_same_data[`dc1Tag_valid]=~read_invl_reg|(hit_odd|hit_even) && (read_odd_reg ? tagR1_valid : tagR0_valid);
  assign tag_same_data[`dc1Tag_recent]=hit_odd | hit_even;
  assign tag_same_data[`dc1Tag_exclusive]=read_odd_reg ? tagR1_exclusive : tagR0_exclusive;
  assign tag_same_data[`dc1Tag_parity]=^tag_same_data[DATA_WIDTH-2:0];
  
  assign write_hit=(write_recent_in) ? write_hit2 : write_hit1;
  assign write_hit1=write_rand[2:0]==INDEX && write_wen_reg; 
  assign write_hit2=write_rand[5:3]==INDEX && write_wen_reg; 
  
  assign errH=err_tag0;
  assign errL=err_tag1;
  
 // assign read_excl[0]=(read_hitH_odd  | read_hitL_odd) ? tagR1_exclusive : 1'bz; 
 // assign read_excl[1]=(read_hitH_even  | read_hitL_even) ? tagR0_exclusive : 1'bz; 
  
  assign read_hit_odd=hit_odd;
  assign read_hit_even=hit_even;

  always @* begin
      read_hitH_odd=read_odd_reg && hit_odd;
      read_hitH_even=~read_odd_reg && hit_even;
      read_hitL_odd=read_split_reg ? hit_odd&~read_odd_reg : read_hitH_odd;
      read_hitL_even=read_split_reg ? hit_even&read_odd_reg : read_hitH_even;
  end
  
  assign wb_addr=write_hit ? (
    read_odd_reg ? {tagR1_IP,1'b1} : {tagR0_IP,1'b1}) : {PADDR_WIDTH-7{1'bz}};
  assign wb_valid=write_hit ? (
    read_odd_reg ? tagR1_valid : tagR0_valid) : 1'bz;
  always @(negedge clk) begin
      if (rst) begin
          read_addrOdd_reg<=36'b0;
          read_addrEven_reg<=36'b0;
          read_odd_reg<=1'b0;
          read_en_reg<=1'b0;
          read_split_reg<=1'b0;
      end else if (read_clkEn) begin
          read_addrOdd_reg<=read_addrOdd;
          read_addrEven_reg<=read_addrEven;
          read_odd_reg<=read_odd;
          read_split_reg<=read_split;
          read_en_reg<=read_en;
      end else begin
          read_en_reg<=1'b0;
      end
      if (rst) begin
          read_invl_reg<=1'b0; 
          write_wen_reg<=1'b0;
      end else  begin
          read_invl_reg<=read_invl;
          write_wen_reg<=write_wen;
      end
      
      if (rst) begin
          init<=1'b1;
          initCount<=0;
      end else if (init) begin
          initCount<=initCount_d;
          if (initCount==6'd63) init<=1'b0;
      end
  end

endmodule

