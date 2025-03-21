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


//read-during-write behaviour: write first
module instrQextra_ram(
  clk,
  rst,
  read_clkEn,
  read_addr0,read_data0,
  read_addr1,read_data1,
  write_addr0,write_data0,write_wen0,
  write_addr1,write_data1,write_wen1,
  write_addr2,write_data2,write_wen2,
  write_addr3,write_data3,write_wen3
  );

  localparam DATA_WIDTH=`instrQExtra_width;
  localparam ADDR_WIDTH=5;
  localparam ADDR_COUNT=32;

  input clk;
  input rst;
  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr0;
  output [DATA_WIDTH-1:0] read_data0;
  input [ADDR_WIDTH-1:0] read_addr1;
  output [DATA_WIDTH-1:0] read_data1;

  input [ADDR_WIDTH-1:0] write_addr0;
  input [DATA_WIDTH-1:0] write_data0;
  input write_wen0;
  input [ADDR_WIDTH-1:0] write_addr1;
  input [DATA_WIDTH-1:0] write_data1;
  input write_wen1;
  input [ADDR_WIDTH-1:0] write_addr2;
  input [DATA_WIDTH-1:0] write_data2;
  input write_wen2;
  input [ADDR_WIDTH-1:0] write_addr3;
  input [DATA_WIDTH-1:0] write_data3;
  input write_wen3;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [ADDR_WIDTH-1:0] read_addr0_reg;
  reg [ADDR_WIDTH-1:0] read_addr1_reg;
  
  assign read_data0=ram[read_addr0_reg];
  assign read_data1=ram[read_addr1_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr0_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr0_reg<=read_addr0;
      if (rst) read_addr1_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr1_reg<=read_addr1;
      if (write_wen0) ram[write_addr0]<=write_data0;
      if (write_wen1) ram[write_addr1]<=write_data1;
      if (write_wen2) ram[write_addr2]<=write_data2;
      if (write_wen3) ram[write_addr3]<=write_data3;
    end

endmodule


module iqe_inc_addr(
  addr,
  new_addr,
  inc,
  inc_en
  );
  input [3:0] addr;
  output [3:0] new_addr;
  input [4:0] inc;
  input inc_en;

  wire [4:0] inc2=(~inc_en) ? 5'd1 : inc;

  generate
    genvar v;
    for(v=0;v<=4;v=v+1) begin : adders_gen
        adder #(4) add_mod(addr,v[3:0],new_addr,1'b0,inc2[v],,,,);
    end
  endgenerate

endmodule

module iqe_up_down(
  inc,inc_en,
  dec,dec_en,
  count,count_new
  );
  input [4:0] inc;
  input inc_en;
  input [2:0] dec;
  input dec_en;
  input [4:0] count;
  output [4:0] count_new;
  
  wire  [4:-2] cnt;
  wire [4:0] inc2;
  wire [2:0] dec2;
  
  assign inc2=(~inc_en) ? 5'd1 : inc;
  assign dec2=(~dec_en) ? 3'd1 : dec;

  assign cnt[0]=inc2[0]&dec2[0]||inc2[1]&&dec2[1]||inc2[2]&dec2[2];
  assign cnt[1]=inc2[1]&dec2[0]||inc2[2]&&dec2[1]||inc2[3]&dec2[2];
  assign cnt[2]=inc2[2]&dec2[0]||inc2[3]&&dec2[1]||inc2[4]&dec2[2];
  assign cnt[3]=inc2[3]&dec2[0]||inc2[4]&&dec2[1];
  assign cnt[4]=inc2[4]&dec2[0];
  
  assign cnt[-1]=inc2[0]&dec2[1]||inc2[1]&dec2[2];
  assign cnt[-2]=inc2[0]&dec2[2];

  generate
    genvar p;
    for(p=-2;p<=4;p=p+1) begin : add_gen
        adder #(5) add_mod(count,p[4:0],count_new,1'b0,cnt[p],,,,);
    end
  endgenerate

endmodule

module instrQextra(
  clk,
  rst,
  except,
  except_thread,
  fStall,
  doFStall,
  stall,
  read_thread,
  read_cnt,
  read_data0,
  read_data1,
  write_wen,
  write_thread,
  write_cnt,
  write_start,
  write_data0,
  write_data1,
  write_data2,
  write_data3
  );
  localparam DATA_WIDTH=`instrQExtra_width;
  localparam ADDR_WIDTH=5;
  localparam ADDR_COUNT=32;

  input clk;
  input rst;
  input except;
  input except_thread;
  input fStall;
  output doFStall;
  input stall;
  input read_thread;
  input [2:0] read_cnt;
  output [DATA_WIDTH-1:0] read_data0;
  output [DATA_WIDTH-1:0] read_data1;
  input write_wen;
  input write_thread;
  input [4:0] write_cnt;
  input [4:0] write_start;
  input [DATA_WIDTH-1:0] write_data0;
  input [DATA_WIDTH-1:0] write_data1;
  input [DATA_WIDTH-1:0] write_data2;
  input [DATA_WIDTH-1:0] write_data3;

  reg [3:0] read_addr0[1:0];
  reg [3:0] read_addr1[1:0];
  reg [3:0] write_addr0[1:0];
  reg [3:0] write_addr1[1:0];
  reg [3:0] write_addr2[1:0];
  reg [3:0] write_addr3[1:0];
  
  wire [1:0][3:0] read_addr0_d;
  wire [1:0][3:0] read_addr1_d;
  wire [1:0][3:0] write_addr0_d;
  wire [1:0][3:0] write_addr1_d;
  wire [1:0][3:0] write_addr2_d;
  wire [1:0][3:0] write_addr3_d;
  
  wire [DATA_WIDTH-1:0] write_data0x;
  wire [DATA_WIDTH-1:0] write_data1x;
  wire [DATA_WIDTH-1:0] write_data2x;
  wire [DATA_WIDTH-1:0] write_data3x;

  reg [4:0] cnt[1:0];
  wire [1:0][4:0] cnt_d;

  assign write_data0x=write_start[0] ? write_data0 : 'z;
  assign write_data0x=write_start[1] ? write_data1 : 'z;
  assign write_data0x=write_start[2] ? write_data2 : 'z;
  assign write_data0x=|write_start[4:3] ? write_data3 : 'z;

  assign write_data1x=write_start[0] ? write_data1 : 'z;
  assign write_data1x=write_start[1] ? write_data2 : 'z;
  assign write_data1x=|write_start[4:2] ? write_data3 : 'z;
  
  assign write_data2x=write_start[0] ? write_data2 : 'z;
  assign write_data2x=|write_start[4:1] ? write_data3 : 'z;
  
  assign write_data3x=write_data3;

  
  get_carry #(5) cmp_mod(cnt[read_thread],~5'd13,1'b1,doFStall);

  iqe_inc_addr incR00_mod(read_addr0[0],read_addr0_d[0],{2'b0,read_cnt},~stall & ~read_thread);
  iqe_inc_addr incR01_mod(read_addr0[1],read_addr0_d[1],{2'b0,read_cnt},~stall &  read_thread);
  iqe_inc_addr incR10_mod(read_addr1[0],read_addr1_d[0],{2'b0,read_cnt},~stall & ~read_thread);
  iqe_inc_addr incR11_mod(read_addr1[1],read_addr1_d[1],{2'b0,read_cnt},~stall &  read_thread);
  
  iqe_inc_addr incW00_mod(write_addr0[0],write_addr0_d[0],
    write_cnt,~fStall & ~doFStall & write_wen & ~write_thread);
  iqe_inc_addr incW01_mod(write_addr0[1],write_addr0_d[1],
    write_cnt,~fStall & ~doFStall & write_wen &  write_thread);
  iqe_inc_addr incW10_mod(write_addr1[0],write_addr1_d[0],
    write_cnt,~fStall & ~doFStall & write_wen & ~write_thread);
  iqe_inc_addr incW11_mod(write_addr1[1],write_addr1_d[1],
    write_cnt,~fStall & ~doFStall & write_wen &  write_thread);
  iqe_inc_addr incW20_mod(write_addr2[0],write_addr2_d[0],
    write_cnt,~fStall & ~doFStall & write_wen & ~write_thread);
  iqe_inc_addr incW21_mod(write_addr2[1],write_addr2_d[1],
    write_cnt,~fStall & ~doFStall & write_wen &  write_thread);
  iqe_inc_addr incW30_mod(write_addr3[0],write_addr3_d[0],
    write_cnt,~fStall & ~doFStall & write_wen & ~write_thread);
  iqe_inc_addr incW31_mod(write_addr3[1],write_addr3_d[1],
    write_cnt,~fStall & ~doFStall & write_wen &  write_thread);

  instrQextra_ram ram_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~stall),
  .read_addr0({read_thread,read_addr0_d[read_thread]}),.read_data0(read_data0),
  .read_addr1({read_thread,read_addr1_d[read_thread]}),.read_data1(read_data1),
  .write_addr0({write_thread,write_addr0[write_thread]}),.write_data0(write_data0x),
    .write_wen0(write_wen && ~fStall && ~doFStall && |write_cnt[4:1]),
  .write_addr1({write_thread,write_addr1[write_thread]}),.write_data1(write_data1x),
    .write_wen1(write_wen && ~fStall && ~doFStall && |write_cnt[4:2]),
  .write_addr2({write_thread,write_addr2[write_thread]}),.write_data2(write_data2x),
    .write_wen2(write_wen && ~fStall && ~doFStall && |write_cnt[4:3]),
  .write_addr3({write_thread,write_addr3[write_thread]}),.write_data3(write_data3x),
    .write_wen3(write_wen && ~fStall && ~doFStall && write_cnt[4])
  );

  iqe_up_down cnt0_mod(
  .inc(write_cnt),.inc_en(write_wen && ~fStall && ~doFStall && ~write_thread),
  .dec(read_cnt),.dec_en(~stall && ~read_thread),
  .count(cnt[0]),.count_new(cnt_d[0])
  );

  iqe_up_down cnt1_mod(
  .inc(write_cnt),.inc_en(write_wen && ~fStall && ~doFStall &&  write_thread),
  .dec(read_cnt),.dec_en(~stall &&  read_thread),
  .count(cnt[1]),.count_new(cnt_d[1])
  );

  always @(posedge clk) begin
      if (rst) begin
	  cnt[0]<=5'd0;
	  read_addr0[0]<=4'd0;
	  read_addr1[0]<=4'd1;
	  write_addr0[0]<=4'd0;
	  write_addr1[0]<=4'd1;
	  write_addr2[0]<=4'd2;
	  write_addr3[0]<=4'd3;
	  
	  cnt[1]<=5'd0;
	  read_addr0[1]<=4'd0;
	  read_addr1[1]<=4'd1;
	  write_addr0[1]<=4'd0;
	  write_addr1[1]<=4'd1;
	  write_addr2[1]<=4'd2;
	  write_addr3[1]<=4'd3;

      end else if (except) begin
	  cnt[except_thread]<=5'd0;
	  read_addr0[except_thread]<=4'd0;
	  read_addr1[except_thread]<=4'd1;
	  write_addr0[except_thread]<=4'd0;
	  write_addr1[except_thread]<=4'd1;
	  write_addr2[except_thread]<=4'd2;
	  write_addr3[except_thread]<=4'd3;

      end else begin
	  cnt[0]<=cnt_d[0];
	  read_addr0[0]<=read_addr0_d[0];
	  read_addr1[0]<=read_addr1_d[0];
	  write_addr0[0]<=write_addr0_d[0];
	  write_addr1[0]<=write_addr1_d[0];
	  write_addr2[0]<=write_addr2_d[0];
	  write_addr3[0]<=write_addr3_d[0];
	  
	  cnt[1]<=cnt_d[1];
	  read_addr0[1]<=read_addr0_d[1];
	  read_addr1[1]<=read_addr1_d[1];
	  write_addr0[1]<=write_addr0_d[1];
	  write_addr1[1]<=write_addr1_d[1];
	  write_addr2[1]<=write_addr2_d[1];
	  write_addr3[1]<=write_addr3_d[1];
	 
      end
  end

endmodule

