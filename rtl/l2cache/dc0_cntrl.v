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

module pfoff_buf(clk,rst,write_en,write_addr,read_en,read_addr,free_en,free,purged,chk_addr,chk_en);
  input pwire clk;
  input pwire rst;
  input pwire write_en;
  input pwire [36:0] write_addr;
  input pwire read_en;
  output pwire [36:0] read_addr;
  input pwire free_en;
  output pwire free;
  output pwire purged;
  input pwire [36:0] chk_addr;
  output pwire chk_en;

  pwire [36:0] addr;

  assign read_data=read_en ? addr : 37'bz;

  assign chk_en=pwh#(32)::cmpEQ(chk_addr,addr) && !free;

  always @(posedge clk) begin
    if (rst) begin
      addr<=0;
      free<=1'b1;
      purged<=1'b1;
    end else begin
      if (read_en) purged<=1'b1;
      if (free_en) begin
          free<=1'b1;
      end else if (write_en) begin
          free<=1'b0;
          addr<=1'b0;
          purged<=1'b0;
      end
    end
  end
endmodule

module pfoff(clk,rst,purge_can,purge_en,purge_addr,read_addr,read_chk,write_en,write_addr);
  parameter WIDTH=7;//20 for data?
  input pwire clk;
  input pwire rst;
  output purge_can;
  input pwire purge_en;
  output pwire [36:0] purge_addr;
  input pwire [36:0] read_addr;
  output pwire read_chk;
  input pwire write_en;
  input pwire [36:0] write_addr;

  pwire [WIDTH-1:0] write_pos;
  pwire [WIDTH-1:0] read_pos;

  generate
    genvar b;
    for(b=0;b<WIDTH;b=b+1) begin
        pfoff_buf buf_mod(clk,rst,{WIDTH{write_en}}&write_pos,write_addr,{WIDTH{purge_en}}&read_pos,purge_addr,1'b0,free,purged,read_addr,chk_en0);
    end
  endgenerate
  assign purge_can=|purge;
  assign read_chk=|chk_en0;
  bit_find_first_bit #(WIDTH) find_mod(~purged & ~free,read_pos,);

  always @(posedge clk) begin
    if (rst) begin
        write_pos<=1;
    end else begin
        if (write_en) write_pos<={write_pos[WIDTH-2:0],write_pos[WIDTH-1]};
    end
  end
endmodule
//verilator lint_off WIDTH
//dcache1_ram read during write behaviour: write first
module dc0_cntrl_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=5;
  localparam DATA_WIDTH=`mOpC_width+2+16;
  localparam ADDR_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

//dcache1_ram read during write behaviour: write first
module dc0_cntrlD_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=5;
  localparam DATA_WIDTH=128+16;
  localparam ADDR_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

//dcache1_ram read during write behaviour: write first
module dc0_cntrlC_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=3;
  localparam DATA_WIDTH=37+5;
  localparam ADDR_COUNT=8;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

//dcache1_ram read during write behaviour: write first
module dc0_cntrlC2w_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr0,
  write_addr1,
  write_data0,
  write_wen0
  write_data1,
  write_wen1
  );
  localparam ADDR_WIDTH=3;
  localparam DATA_WIDTH=37+5;
  localparam ADDR_COUNT=8;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr; 
      if (write_wen0) ram[write_addr0]<=write_data0;
      if (write_wen1) ram[write_addr1]<=write_data1;
    end

endmodule


//dcache1_ram read during write behaviour: write first
module dc0_cntrlC1_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=5;
  localparam DATA_WIDTH=37+5+1+1+13;
  localparam ADDR_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule


//dcache1_ram read during write behaviour: write first
module dc0_cntrlM_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=5;
  localparam DATA_WIDTH=37+5+1+1+13;
  localparam ADDR_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module dc0_cntrlM1_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=5;
  localparam DATA_WIDTH=37+1+1;
  localparam ADDR_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

//dcache1_ram read during write behaviour: write first
module dc0_cntrlMiC2_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=5;
  localparam DATA_WIDTH=37+5;
  localparam ADDR_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module dc0_cntrl(
  clk,
  rst,
  doSkip,
  read_addr,
  read_en,
  read_req,
  read_dupl,
  read_want_excl,
  read_io,
  read_sz,
  read_bank0,
  read_low,
  Cread_addr,
  Cread_en,
  Cread_req,
  write0_clkEn,
  write_addrE0, 
  write_addrO0,
  write_bankEn0, 
  write_begin0,write_end0,
  write_bBen0,write_enBen0,
  write_odd0,write_split0,
  write_data0,
  write_pbit0,write_d128_0,
  write1_clkEn,
  write_addrE1,
  write_addrO1, 
  write_bankEn1,
  write_begin1,write_end1,
  write_bBen1,write_enBen1,
  write_odd1,write_split1,
  write_data1,
  write_pbit1,write_d128_1,
//  writeI0_clkEn,
  writeI_addrE0, writeI_hitE0,
  writeI_addrO0, writeI_hitO0,
  writeI_bankEn0, 
  writeI_begin0,writeI_end0,
  writeI_bBen0,writeI_enBen0,
  writeI_odd0,writeI_split0,
  writeI_data0,
  writeI_pbit0,writeI_d128_0,
//  writeI1_clkEn,
  writeI_addrE1, writeI_hitE1,
  writeI_addrO1, writeI_hitO1,
  writeI_bankEn1,
  writeI_begin1,writeI_end1,
  writeI_bBen1,writeI_enBen1,
  writeI_odd1,writeI_split1,
  writeI_data1,
  writeI_pbit1,writeI_d128_1,
  writeI_exp,
  readI_en,readI_en2,readI_odd,readI_req,readI_code,readI_dupl,
  readI_want_excl,readI_io,readI_dataIO,readI_ins_A,readI_ins_B,
  miss_en,miss_addr,miss_req,miss_dupl,miss_want_excl, 
  rbus_signals,rbus_src_req,rbus_dst_req,rbus_address,rbus_can,rbus_want,rbus_bank0,rbus_sz,rbus_low,
  rbusAN_signals,rbusAN_src_req,rbusAN_dst_req,rbusAN_data64
  );
  parameter [4:0] ID=0;
  localparam STALL_CNT=12;
  localparam ADDR_WIDTH=36;
  input pwire clk;
  input pwire rst;
  output pwire doSkip;
  input pwire [36:0] read_addr;
  input pwire read_en;
  input pwire [4:0] read_req;
  input pwire read_dupl;
  input pwire read_want_excl;
  input pwire read_io;
  input pwire [4:0] read_sz;
  input pwire [4:0] read_bank0;
  input pwire [1:0] read_low;
  input pwire [36:0] Cread_addr;
  input pwire Cread_en;
  input pwire [4:0] Cread_req;
  input pwire [1:0] write0_clkEn;
  input pwire [ADDR_WIDTH-1:0] write_addrE0;
  input pwire [ADDR_WIDTH-1:0] write_addrO0;
  input pwire [31:0] write_bankEn0;
  input pwire [4:0] write_begin0;
  input pwire [4:0] write_end0;
  input pwire [3:0] write_bBen0;
  input pwire [3:0] write_enBen0;
  input pwire write_odd0,write_split0;
  input pwire [159:0] write_data0;
  input pwire [1:0] write_pbit0;
  input pwire write_d128_0;
  input pwire [1:0] write1_clkEn;
  input pwire [ADDR_WIDTH-1:0] write_addrE1;
  input pwire [ADDR_WIDTH-1:0] write_addrO1;
  input pwire [31:0] write_bankEn1;
  input pwire [4:0] write_begin1;
  input pwire [4:0] write_end1;
  input pwire [3:0] write_bBen1;
  input pwire [3:0] write_enBen1;
  input pwire write_odd1,write_split1;
  input pwire [159:0] write_data1;
  input pwire [1:0] write_pbit1;
  input pwire write_d128_1;
  output pwire [ADDR_WIDTH-1:0] writeI_addrE0;
  output pwire writeI_hitE0; //+1 cycle
  output pwire [ADDR_WIDTH-1:0] writeI_addrO0;
  output pwire writeI_hitO0; //+1 cycle
  output pwire [31:0] writeI_bankEn0;
  output pwire [4:0] writeI_begin0;
  output pwire [4:0] writeI_end0;
  output pwire [3:0] writeI_bBen0;
  output pwire [3:0] writeI_enBen0;
  output pwire writeI_odd0,writeI_split0;
  output pwire [159:0] writeI_data0;
  output pwire [1:0] writeI_pbit0;
  output pwire writeI_d128_0;
  output pwire [ADDR_WIDTH-1:0] writeI_addrE1;
  output pwire writeI_hitE1; //+1 cycle
  output pwire [ADDR_WIDTH-1:0] writeI_addrO1;
  output pwire writeI_hitO1; //+1 cycle
  output pwire [31:0] writeI_bankEn1;
  output pwire [4:0] writeI_begin1;
  output pwire [4:0] writeI_end1;
  output pwire [3:0] writeI_bBen1;
  output pwire [3:0] writeI_enBen1;
  output pwire writeI_odd1,writeI_split1;
  output pwire [159:0] writeI_data1;
  output pwire [1:0] writeI_pbit1;
  output pwire writeI_d128_1;
  output pwire writeI_exp;
  output pwire readI_en,readI_en2,readI_odd;
  output pwire [4:0] readI_req;
  output pwire readI_code;
  output pwire readI_dupl;
  output pwire readI_want_excl;
  output pwire readI_io;
  output pwire [64:0] readI_dataIO;
  output pwire readI_ins_A,readI_ins_B;
  input pwire miss_en;
  input pwire [36:0] miss_addr;
  input pwire [4:0] miss_req;
  input pwire miss_dupl;
  input pwire miss_want_excl;
  output pwire [`rbus_width-1:0] rbus_signals;
  output pwire [9:0] rbus_src_req;
  output pwire [9:0] rbus_dst_req;
  output pwire [36:0] rbus_address;
  input pwire rbus_can;
  output pwire rbus_want;
  output pwire [4:0] rbus_bank0;
  output pwire [4:0] rbus_sz;
  output pwire [1:0] rbus_low;
  input pwire [`rbusAN_width-1:0] rbusAN_signals;
  input pwire [9:0] rbusAN_src_req;
  input pwire [9:0] rbusAN_dst_req;
  input pwire [64:0] rbusAN_data64;
//  output pwire rbusAN_en_out;

  pwire [36:0] rbusAN_addr_out;
  pwire [`mOpC_width-1:0] write_mop[1:0];
  pwire [`mOpC_width-1:0] read_mop[1:0];
  pwire read_clkEn;
  pwire [4:0] cnt;
  pwire [4:0] read_addr0;
  pwire [4:0] write_addr;
  pwire [4:0] cnt_plus;
  pwire [4:0] cnt_minus;
  pwire [4:0] read_addr0_d;
  pwire [4:0] write_addr_d;
  pwire read_clkEnC;
  pwire [3:0] cntC;
  pwire [2:0] read_addrC;
  pwire [2:0] write_addrC;
  pwire [3:0] cntC_plus;
  pwire [3:0] cntC_minus;
  pwire [2:0] read_addrC_d;
  pwire [2:0] write_addrC_d;
  pwire read_clkEnM;
  pwire [4:0] cntM;
  pwire [4:0] read_addrM;
  pwire [4:0] write_addrM;
  pwire [4:0] cntM_plus;
  pwire [4:0] cntM_minus;
  pwire [4:0] read_addrM_d;
  pwire [4:0] write_addrM_d;
  pwire [64:0] rbusAN_data64_reg;

  pwire [159:0] read_data0;
  pwire [159:0] read_data1;
  pwire [1:0] read_hit[1:0];

  pwire read_clkEnC1;
  pwire [4:0] cntC1;
  pwire [4:0] read_addrC1;
  pwire [4:0] write_addrC1;
  pwire [4:0] cntC1_plus;
  pwire [4:0] cntC1_minus;
  pwire [4:0] read_addrC1_d;
  pwire [4:0] write_addrC1_d;

  pwire read_clkEnC2;
  pwire readI_en2_reg;
  pwire [4:0] cntC2;
  pwire [4:0] read_addrC2;
  pwire [4:0] write_addrC2;
  pwire [4:0] cntC2_plus;
  pwire [4:0] cntC2_minus;
  pwire [4:0] read_addrC2_d;
  pwire [4:0] write_addrC2_d;
  pwire read_clkEn_reg;

  pwire [`rbusAN_width-1:0] rbusAN_signals_reg;
  pwire [9:0] rbusAN_src_req_reg;
  pwire [9:0] rbusAN_dst_req_reg;

  pwire [36:0] read_addr1;
  pwire [4:0] read_req1;
  pwire read_dupl1;
  pwire read_want_excl1;
  pwire read_io1;
  pwire [4:0] read_sz1;
  pwire [4:0] read_bank01;
  pwire [1:0] read_low1;
  pwire read_io1_reg;
  pwire [4:0] read_sz1_reg;
  pwire [4:0] read_bank01_reg;
  pwire [1:0] read_low1_reg;
  pwire read_io1_reg2;
  pwire [4:0] read_sz1_reg2;
  pwire [4:0] read_bank01_reg2;
  pwire [1:0] read_low1_reg2;
  pwire read_io1_reg3;
  pwire [4:0] read_sz1_reg3;
  pwire [4:0] read_bank01_reg3;
  pwire [1:0] read_low1_reg3;
  pwire read_io1_reg4;
  pwire [4:0] read_sz1_reg4;
  pwire [4:0] read_bank01_reg4;
  pwire [1:0] read_low1_reg4;
  pwire [36:0] read_addr_C;
  pwire [4:0] read_reqC;
  pwire [36:0] read_addr_C2;
  pwire [4:0] read_req_C2;
  pwire read_io_C2;
  pwire [64:0] read_data_C2;
  pwire [36:0] missR_addr;
  pwire [4:0] missR_req;
  pwire missR_io;
  pwire [4:0] missR_sz;
  pwire [4:0] missR_bank0;
  pwire [1:0] missR_low;
  pwire missR_dupl;
  pwire missR_want_excl;
  pwire read_clkEnM1;
  pwire dupl_M1;
  pwire write_wen;
  pwire wen_C2;
//  pwire rst_reg;
  pwire miss_io;
  pwire [4:0] miss_sz;
  pwire [4:0] miss_bank0;
  pwire [1:0] miss_low;

  pwire read_M1_exp;
  
  pwire init;
  pwire [4:0] initCount;
  pwire [4:0] initCount_next;
  
  assign write_mop[0][`mOpC_addrEven]=write_addrE0;
  assign write_mop[0][`mOpC_addrOdd]=write_addrO0;
  assign write_mop[0][`mOpC_banks]=write_bankEn0;
  assign write_mop[0][`mOpC_begin]=write_begin0;
  assign write_mop[0][`mOpC_end]=write_end0;
  assign write_mop[0][`mOpC_bben]=write_bBen0;
  assign write_mop[0][`mOpC_endben]=write_enBen0;
  assign write_mop[0][`mOpC_odd]=write_odd0;
  assign write_mop[0][`mOpC_split]=write_split0;
  assign write_mop[0][`mOpC_req]=read_req[2:0];
  assign write_mop[0][`mOpC_pbit]=write_pbit0;
  assign write_mop[0][`mOpC_d128]=write_d128_0;
  
  assign write_mop[1][`mOpC_addrEven]=write_addrE1;
  assign write_mop[1][`mOpC_addrOdd]=write_addrO1;
  assign write_mop[1][`mOpC_banks]=write_bankEn1;
  assign write_mop[1][`mOpC_begin]=write_begin1;
  assign write_mop[1][`mOpC_end]=write_end1;
  assign write_mop[1][`mOpC_bben]=write_bBen1;
  assign write_mop[1][`mOpC_endben]=write_enBen1;
  assign write_mop[1][`mOpC_odd]=write_odd1;
  assign write_mop[1][`mOpC_split]=write_split1;
  assign write_mop[1][`mOpC_req]={1'b0,read_req[4:3]};
  assign write_mop[1][`mOpC_pbit]=write_pbit1;
  assign write_mop[1][`mOpC_d128]=write_d128_1;
  
  assign write_wen=write0_clkEn || write1_clkEn;
  assign read_clkEn=cnt && ~read_clkEnC && ~read_clkEnC2 && ~readI_en2_reg && 
    ~read_clkEnC1 && ~read_clkEnM1; //write
  assign read_clkEnC=~read_clkEnC2 && ~readI_en2_reg && ~read_clkEnC1 && ~read_clkEnM1 && cntC;  //read code
  assign read_clkEnM=rbus_can && rbus_want;
  assign rbus_want=cntM!=5'd0;
  assign read_clkEnC1=cntC1 && ~read_clkEnM1 && ~read_clkEnC2 && ~readI_en2_reg;  //read data
  assign read_clkEnC2=1'b0;
  assign read_clkEnM1=rbusAN_signals_reg[`rbusAN_used] && (rbusAN_signals_reg[`rbusAN_mem_reply] &&
    rbusAN_dst_req_reg[9:5]==ID)|rbusAN_signals_reg[`rbusAN_expun]; //cl insert
  assign read_M1_exp=rbusAN_signals_reg[`rbusAN_used] && rbusAN_signals_reg[`rbusAN_expun];
  assign writeI_addrE0=read_clkEnC1 ? read_addr1[36:1] : 36'bz;
  assign writeI_addrO0=read_clkEnC1 ? read_addr1[36:1] : 36'bz;
  assign writeI_bankEn0=(read_clkEnC2|read_clkEnC1|read_clkEnC|read_clkEnM1) ? 
    32'hffffffff : read_mop[0][`mOpC_banks];
  assign writeI_begin0=(read_clkEnC2|read_clkEnC1|read_clkEnC|read_clkEnM1) ? 5'd0 : read_mop[0][`mOpC_begin];
  assign writeI_end0=(read_clkEnC2|read_clkEnC1|read_clkEnC|read_clkEnM1) ? 5'd0 : read_mop[0][`mOpC_end];
  assign writeI_bBen0=(read_clkEnC2|read_clkEnC1|read_clkEnC|read_clkEnM1) ? 4'hf : read_mop[0][`mOpC_bben];
  assign writeI_enBen0=(read_clkEnC2|read_clkEnC1|read_clkEnC|read_clkEnM1) ? 4'hf : read_mop[0][`mOpC_endben];
  assign writeI_pbit0=(read_clkEnC2|read_clkEnC1|read_clkEnC|read_clkEnM1) ? 2'b0 : read_mop[0][`mOpC_pbit];
  assign writeI_d128_0=(read_clkEnC2|read_clkEnC1|read_clkEnC|read_clkEnM1) ? 1'b0 : read_mop[0][`mOpC_d128];
  assign writeI_odd0=read_clkEnC1 ? read_addr1[0] : 1'bz;
  assign writeI_split0=read_clkEnC1 ? 1'b0 : 1'bz;
  assign writeI_data0=read_data0;
  assign {writeI_hitO0,writeI_hitE0}=( read_clkEnC2|read_clkEnC1|read_clkEnC|read_clkEnM1) ?
    {writeI_odd0,~writeI_odd0} &{2{~read_clkEnM1}} : read_hit[0] & {2{read_clkEn}};

  assign writeI_addrE1=read_clkEnC1 ? read_addr1[36:1] : 36'bz;
  assign writeI_addrO1=read_clkEnC1 ? read_addr1[36:1] : 36'bz;
  assign writeI_bankEn1=(read_clkEnC1|read_clkEnC) ? 32'h0 : read_mop[1][`mOpC_banks];
  assign writeI_begin1=(read_clkEnC1|read_clkEnC) ? 5'd1 : read_mop[1][`mOpC_begin];
  assign writeI_end1=(read_clkEnC1|read_clkEnC) ? 5'd1 : read_mop[1][`mOpC_end];
  assign writeI_bBen1=(read_clkEnC1|read_clkEnC) ? 4'hf : read_mop[1][`mOpC_bben];
  assign writeI_enBen1=(read_clkEnC1|read_clkEnC) ? 4'hf : read_mop[1][`mOpC_endben];
  assign writeI_pbit1=(read_clkEnC1|read_clkEnC) ? 2'b0 : read_mop[1][`mOpC_pbit];
  assign writeI_d128_1=(read_clkEnC1|read_clkEnC) ? 1'b0 : read_mop[1][`mOpC_d128];
  assign writeI_odd1=read_clkEnC1 ? read_addr1[0] : 1'bz;
  assign writeI_split1=read_clkEnC1 ? 1'b0 : 1'bz;
  assign writeI_data1=read_data1;
  assign {writeI_hitO1,writeI_hitE1}=( read_clkEnC1|read_clkEnC|read_clkEnM1) ? 2'b0 : read_hit[1] & {2{read_clkEn}};

  assign writeI_addrE0=read_clkEn ? read_mop[0][`mOpC_addrEven] : 36'bz;
  assign writeI_addrO0=read_clkEn ? read_mop[0][`mOpC_addrOdd] : 36'bz;
  assign writeI_addrE1=read_clkEn ? read_mop[1][`mOpC_addrEven] : 36'bz;
  assign writeI_addrO1=read_clkEn ? read_mop[1][`mOpC_addrOdd] : 36'bz;
  assign writeI_odd0=read_clkEn ? read_mop[0][`mOpC_odd] : 1'bz;
  assign writeI_split0=read_clkEn ? read_mop[0][`mOpC_split] : 1'bz;
  assign writeI_odd1=read_clkEn ? read_mop[1][`mOpC_odd] : 1'bz;
  assign writeI_split1=read_clkEn ? read_mop[1][`mOpC_split] : 1'bz;


  assign writeI_addrE0=read_clkEnM1&~read_M1_exp ? rbusAN_addr_out[36:1] : 36'bz;
  assign writeI_addrO0=read_clkEnM1&~read_M1_exp ? rbusAN_addr_out[36:1] : 36'bz;
  assign writeI_addrE1=read_clkEnM1&~read_M1_exp ? rbusAN_addr_out[36:1] : 36'bz;
  assign writeI_addrO1=read_clkEnM1&~read_M1_exp ? rbusAN_addr_out[36:1] : 36'bz;
  assign writeI_odd0=read_clkEnM1&~read_M1_exp ? rbusAN_addr_out[0] : 1'bz;
  assign writeI_split0=read_clkEnM1&~read_M1_exp ? 1'b0 : 1'bz;
  assign writeI_odd1=read_clkEnM1&~read_M1_exp ? rbusAN_addr_out[0] : 1'bz;
  assign writeI_split1=read_clkEnM1&~read_M1_exp ? 1'b0 : 1'bz;
  
  assign writeI_addrE0=read_clkEnM1&read_M1_exp ? rbusAN_data64_reg[36:1] : 36'bz;
  assign writeI_addrO0=read_clkEnM1&read_M1_exp ? rbusAN_data64_reg[36:1] : 36'bz;
  assign writeI_addrE1=read_clkEnM1&read_M1_exp ? rbusAN_data64_reg[36:1] : 36'bz;
  assign writeI_addrO1=read_clkEnM1&read_M1_exp ? rbusAN_data64_reg[36:1] : 36'bz;
  assign writeI_odd0=read_clkEnM1&read_M1_exp ? rbusAN_data64_reg[0] : 1'bz;
  assign writeI_split0=read_clkEnM1&read_M1_exp ? 1'b0 : 1'bz;
  assign writeI_odd1=read_clkEnM1&read_M1_exp ? rbusAN_data64_reg[0] : 1'bz;
  assign writeI_split1=read_clkEnM1&read_M1_exp ? 1'b0 : 1'bz;
  
  
  assign writeI_addrE0=read_clkEnC2 ? read_addr_C2[36:1] : 36'bz;
  assign writeI_addrO0=read_clkEnC2 ? read_addr_C2[36:1] : 36'bz;
  assign writeI_addrE1=read_clkEnC2 ? read_addr_C2[36:1] : 36'bz;
  assign writeI_addrO1=read_clkEnC2 ? read_addr_C2[36:1] : 36'bz;
  assign writeI_odd0=read_clkEnC2 ? read_addr_C2[0] : 1'bz;
  assign writeI_split0=read_clkEnC2 ? 1'b0 : 1'bz;
  assign writeI_odd1=read_clkEnC2 ? read_addr_C2[0] : 1'bz;
  assign writeI_split1=read_clkEnC2 ? 1'b0 : 1'bz;
  
  assign writeI_addrE0=(read_clkEnC1|read_clkEnM1|read_clkEn|read_clkEnC2) ? 36'bz : read_addr_C[36:1];
  assign writeI_addrO0=(read_clkEnC1|read_clkEnM1|read_clkEn|read_clkEnC2) ? 36'bz : read_addr_C[36:1];
  assign writeI_addrE1=(read_clkEnC1|read_clkEnM1|read_clkEn|read_clkEnC2) ? 36'bz : read_addr_C[36:1];
  assign writeI_addrO1=(read_clkEnC1|read_clkEnM1|read_clkEn|read_clkEnC2) ? 36'bz : read_addr_C[36:1];
  assign writeI_odd0=(read_clkEnC1|read_clkEnM1|read_clkEn|read_clkEnC2) ? 1'bz : 1'b0;
  assign writeI_split0=(read_clkEnC1|read_clkEnM1|read_clkEn|read_clkEnC2) ? 1'bz : 1'b0;
  assign writeI_odd1=(read_clkEnC1|read_clkEnM1|read_clkEn|read_clkEnC2) ? 1'bz : 1'b0;
  assign writeI_split1=(read_clkEnC1|read_clkEnM1|read_clkEn|read_clkEnC2) ? 1'bz : 1'b0;
  
  assign readI_en=read_clkEnC2 | read_clkEnC1 | read_clkEnC | read_clkEnM1;
  assign readI_en2=read_clkEnC2 | read_clkEnC1 | read_clkEnC;
  assign readI_odd=read_clkEnC1 ? read_addr1[0] : 1'bz; 
  assign readI_odd=read_clkEnC ? read_addr_C[0] : 1'bz;
  assign readI_odd=read_clkEnC2 ? read_addr_C2[0] : 1'bz;
  assign readI_odd=(~read_clkEnC1 & ~read_clkEnC & ~read_clkEnC2) ? rbusAN_addr_out[0] : 1'bz; 
  assign readI_req=read_clkEnC1 ? read_req1 : 5'bz;
  assign readI_req=read_clkEnC ? read_reqC : 5'bz;
  assign readI_req=read_clkEnC2 ? read_req_C2 : 5'bz;
  assign readI_req=(~read_clkEnC1 & ~read_clkEnC & ~read_clkEnC2) ? rbusAN_dst_req_reg[4:0] : 5'bz;
  assign readI_code=read_clkEnC;
  assign readI_io=read_clkEnC2 && read_io_C2;
  assign readI_dataIO=read_data_C2;
  assign readI_ins_A=read_clkEnM1 && ~rbusAN_signals_reg[`rbusAN_second] && ~rbusAN_signals_reg[`rbusAN_iorpl] && 
	  ~rbusAN_signals_reg[`rbusAN_expun];
  assign readI_ins_B=read_clkEnM1 && rbusAN_signals_reg[`rbusAN_second] && ~rbusAN_signals_reg[`rbusAN_iorpl] && 
	  ~rbusAN_signals_reg[`rbusAN_expun];

  assign readI_dupl=read_clkEnC1 & read_dupl1 || read_clkEnM1 & dupl_M1;
  assign readI_want_excl=read_clkEnC1 & read_want_excl1;

  assign writeI_exp=read_clkEnM1 & rbusAN_signals_reg[`rbusAN_expun];

  assign miss_sz=read_sz1_reg4;
  assign miss_bank0=read_bank01_reg4;
  assign miss_low=read_low1_reg4;
  assign miss_io=read_clkEnC1 & read_io1_reg4;

  assign rbus_address=missR_addr;
  assign rbus_src_req={ID,missR_req};
  assign rbus_dst_req=10'h3ff;
  assign rbus_signals[`rbus_mreq]=~missR_io;
  assign rbus_signals[`rbus_ior]=missR_io;
  assign rbus_signals[`rbus_bcast]=1'b1;
  assign rbus_signals[`rbus_used]=read_clkEnM;
  assign rbus_signals[`rbus_second]=1'b0;
  assign rbus_signals[`rbus_want_excl]=missR_want_excl;
  assign rbus_signals[`rbus_code]=missR_req[4] && ~missR_req[3];
  assign rbus_signals[`rbus_creq]=1'b0;
  assign rbus_signals[`rbus_dupl]=missR_dupl;
  assign rbus_sz=missR_sz;
  assign rbus_bank0=missR_bank0;
  assign rbus_low=missR_low;

  adder_inc #(5) cntAdd_mod(cnt,cnt_plus,1'b1,);
  adder_inc #(4) wrtAdd_mod(write_addr,write_addr_d,write_addr!=5'd20,);  
  adder_inc #(4) readAdd_mod(read_addr0,read_addr0_d,read_addr0!=5'd20,);  
  adder #(5) cntSub_mod(cnt,5'h1f,cnt_minus,1'b0,1'b1,,,,);
  get_carry #(5) cmp_mod(cnt,~STALL_CNT[4:0],1'b1,doSkip);
  adder_inc #(4) cntCAdd_mod(cntC,cntC_plus,1'b1,);
  adder_inc #(3) wrtCAdd_mod(write_addrC,write_addrC_d,1'b1,);  
  adder_inc #(3) readCAdd_mod(read_addrC,read_addrC_d,1'b1,);  
  adder #(4) cntCSub_mod(cntC,4'hf,cntC_minus,1'b0,1'b1,,,,);
  adder_inc #(5) cntMAdd_mod(cntM,cntM_plus,1'b1,);
  adder_inc #(5) wrtMAdd_mod(write_addrM,write_addrM_d,write_addrM!=5'd27,);  
  adder_inc #(5) readMAdd_mod(read_addrM,read_addrM_d,read_addrM!=5'd27,);  
  adder #(5) cntMSub_mod(cntM,5'h1f,cntM_minus,1'b0,1'b1,,,,);
  adder_inc #(5) cntC1Add_mod(cntC1,cntC1_plus,1'b1,);
  adder_inc #(4) wrtC1Add_mod(write_addrC1,write_addrC1_d,write_addrC1!=5'd20,);  
  adder_inc #(4) readC1Add_mod(read_addrC1,read_addrC1_d,read_addrC1!=5'd20,);  
  adder #(5) cntC1Sub_mod(cntC1,5'h1f,cntC1_minus,1'b0,1'b1,,,,);
  adder_inc #(5) cntC2Add_mod(cntC2,cntC2_plus,1'b1,);
  adder_inc #(5) wrtC2Add_mod(write_addrC2,write_addrC2_d,write_addrC2!=5'd27,);  
  adder_inc #(5) readC2Add_mod(read_addrC2,read_addrC2_d,read_addrC2!=5'd27,);  
  adder #(5) cntC2Sub_mod(cntC2,5'h1f,cntC2_minus,1'b0,1'b1,,,,);
  
  adder_inc #(5) initAdd_mod(initCount,initCount_next,1'b1,);

  assign write_addrM_d=(pwh#(5)::cmpEQ(write_addrM,5'd27)) ? 5'd0 : 5'bz;
  assign read_addrM_d=(pwh#(5)::cmpEQ(read_addrM,5'd27)) ? 5'd0 : 5'bz;
  assign write_addrC2_d=(pwh#(5)::cmpEQ(write_addrC2,5'd27)) ? 5'd0 : 5'bz;
  assign read_addrC2_d=(pwh#(5)::cmpEQ(read_addrC2,5'd27)) ? 5'd0 : 5'bz;
  assign write_addrC1_d=(pwh#(5)::cmpEQ(write_addrC2,5'd20)) ? 5'd0 : 5'bz;
  assign read_addrC1_d=(pwh#(5)::cmpEQ(read_addrC2,5'd20)) ? 5'd0 : 5'bz;
  assign write_addr_d=(pwh#(5)::cmpEQ(write_addrC2,5'd20)) ? 5'd0 : 5'bz;
  assign read_addr_d=(pwh#(5)::cmpEQ(read_addrC2,5'd20)) ? 5'd0 : 5'bz;

  assign wen_C2=read_clkEnM1 && ~rbusAN_signals_reg[`rbusAN_second];
  
  dc0_cntrl_ram ram0_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_addr0_d),
  .read_data({read_mop[0],read_hit[0],read_data0[143:128]}),
  .write_addr(init ? initCount[3:0] : write_addr),
  .write_data(init ? 1'b0 : {write_mop[0],write0_clkEn,write_data0[143:128]}),
  .write_wen(write_wen|init)
  );
  dc0_cntrl_ram ram1_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_addr0_d),
  .read_data({read_mop[1],read_hit[1],read_data0[159:144]}),
  .write_addr(init ? initCount[3:0] : write_addr),
  .write_data(init ? 1'b0 : {write_mop[1],write1_clkEn,write_data0[159:144]}),
  .write_wen(write_wen|init)
  );
  dc0_cntrlD_ram ramB0_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_addr0_d),
  .read_data({read_data0[127:0],read_data1[143:128]}),
  .write_addr(init ? initCount[3:0] : write_addr),
  .write_data(init ? 1'b0 : {write_data0[127:0],write_data1[143:128]}),
  .write_wen(write_wen|init)
  );
  dc0_cntrlD_ram ramB1_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(read_addr0_d),
  .read_data({read_data1[127:0],read_data1[159:144]}),
  .write_addr(init ? initCount[3:0] : write_addr),
  .write_data(init ? 1'b0 : {write_data1[127:0],write_data1[159:144]}),
  .write_wen(write_wen|init)
  );
  dc0_cntrlC_ram ramC_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEnC),
  .read_addr(read_addrC_d),
  .read_data({read_addr_C,read_reqC}),
  .write_addr(init ? initCount[2:0] : write_addrC),
  .write_data(init ? 1'b0 : {Cread_addr,Cread_req}),
  .write_wen(Cread_en|init)
  );
  dc0_cntrlC1_ram ramC1_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEnC1),
  .read_addr(read_addrC1_d),
  .read_data({read_want_excl1,read_dupl1,read_addr1,read_req1,read_io1,read_sz1,read_bank01,read_low1}),
  .write_addr(init ? initCount[3:0] : write_addrC1),
  .write_data(init ? 1'b0 : {read_want_excl,read_dupl,read_addr,read_req,read_io,read_sz,read_bank0,read_low}),
  .write_wen(read_en|init)
  );
  
  dc0_cntrlM_ram ramM_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEnM),
  .read_addr(read_addrM_d),
  .read_data({missR_want_excl,missR_dupl,missR_addr,missR_req,missR_io,missR_sz,missR_bank0,missR_low}),
  .write_addr(init ? initCount : write_addrM),
  .write_data(init ? 1'b0 : {miss_want_excl,miss_dupl,miss_addr,miss_req,miss_io,miss_sz,miss_bank0,miss_low}),
  .write_wen(miss_en|init)
  );
  dc0_cntrlM1_ram ramM1_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(1'b1),
  .read_addr(rbusAN_dst_req[4:0]),
  .read_data({dupl_M1,rbusAN_addr_out}),
  .write_addr(init ? initCount : miss_req),
  .write_data(init ? 1'b0 : {miss_dupl,miss_addr}),
  .write_wen(miss_en|init)
  );
  always @(posedge clk) begin
      if (rst) begin
          cnt<=5'd0;
          write_addr<=5'd0;
          read_addr0<=5'b0;
          cntC<=4'd0;
          write_addrC<=3'd0;
          read_addrC<=3'b0;
          cntM<=5'd0;
          write_addrM<=5'd0;
          read_addrM<=5'b0;
          cntC1<=5'd0;
          write_addrC1<=5'd0;
          read_addrC1<=5'b0;
          cntC2<=5'd0;
          write_addrC2<=5'd0;
          read_addrC2<=5'b0;
        //  read_addr_reg<=37'b0;
        //  read_en_reg<=1'b0;
          rbusAN_signals_reg<=0;
          rbusAN_src_req_reg<=10'b0;
          rbusAN_dst_req_reg<=10'b0;
          readI_en2_reg<=1'b0;
	  read_clkEn_reg<=1'b0;
          read_io1_reg<=1'b0;
          read_sz1_reg<=5'b0;
          read_bank01_reg<=5'b0;
          read_low1_reg<=2'b0;
          read_io1_reg2<=1'b0;
          read_sz1_reg2<=5'b0;
          read_bank01_reg2<=5'b0;
          read_low1_reg2<=2'b0;
          read_io1_reg3<=1'b0;
          read_sz1_reg3<=5'b0;
          read_bank01_reg3<=5'b0;
          read_low1_reg3<=2'b0;
          read_io1_reg4<=1'b0;
          read_sz1_reg4<=5'b0;
          read_bank01_reg4<=5'b0;
          read_low1_reg4<=2'b0;
	  read_io_C2<=1'b0;
	  read_data_C2<=64'b0;
	  rbusAN_data64_reg<=64'b0;
      end else begin
          if (write_wen & ~read_clkEn) cnt<=cnt_plus;
          if (read_clkEn & ~write_wen) cnt<=cnt_minus;
          if (write_wen) write_addr<=write_addr_d;
          if (read_clkEn) read_addr0<=read_addr0_d;
          if (Cread_en & ~read_clkEnC) cntC<=cntC_plus;
          if (read_clkEnC & ~Cread_en) cntC<=cntC_minus;
          if (Cread_en) write_addrC<=write_addrC_d;
          if (read_clkEnC) read_addrC<=read_addrC_d;
          if (miss_en & ~read_clkEnM) cntM<=cntM_plus;
          if (read_clkEnM & ~miss_en) cntM<=cntM_minus;
          if (miss_en) write_addrM<=write_addrM_d;
          if (read_clkEnM) read_addrM<=read_addrM_d;
          if (read_en & ~read_clkEnC1) cntC1<=cntC1_plus;
          if (read_clkEnC1 & ~read_en) cntC1<=cntC1_minus;
          if (read_en) write_addrC1<=write_addrC1_d;
          if (read_clkEnC1) read_addrC1<=read_addrC1_d;
          if (wen_C2 & ~read_clkEnC2) cntC2<=cntC2_plus;
          if (read_clkEnC2 & ~wen_C2) cntC2<=cntC2_minus;
          if (wen_C2) write_addrC2<=write_addrC2_d;
          if (read_clkEnC2) read_addrC2<=read_addrC2_d;
      //    read_addr_reg<=read_addr;
      //    read_en_reg<=read_en;
          rbusAN_signals_reg<=rbusAN_signals;
          rbusAN_src_req_reg<=rbusAN_src_req;
          rbusAN_dst_req_reg<=rbusAN_dst_req;
          readI_en2_reg<=readI_en2;
	  read_clkEn_reg<=read_clkEn;
          read_io1_reg<=read_io1;
          read_sz1_reg<=read_sz1;
          read_bank01_reg<=read_bank01;
          read_low1_reg<=read_low1;
          read_io1_reg2<=read_io1_reg;
          read_sz1_reg2<=read_sz1_reg;
          read_bank01_reg2<=read_bank01_reg;
          read_low1_reg2<=read_low1_reg;
          read_io1_reg3<=read_io1_reg2;
          read_sz1_reg3<=read_sz1_reg2;
          read_bank01_reg3<=read_bank01_reg2;
          read_low1_reg3<=read_low1_reg2;
          read_io1_reg4<=read_io1_reg3;
          read_sz1_reg4<=read_sz1_reg3;
          read_bank01_reg4<=read_bank01_reg3;
          read_low1_reg4<=read_low1_reg3;
	  if (wen_C2) begin
	      read_io_C2<=rbusAN_signals_reg[`rbusAN_iorpl];
	      read_data_C2<=rbusAN_data64_reg[63:0];
	  end
	  rbusAN_data64_reg<=rbusAN_data64;
      end
      if (rst) begin
          init<=1'b1;
          initCount<=5'b0;
      end else if (init) begin
          initCount<=initCount_next;
          if (pwh#(5)::cmpEQ(initCount,5'd23)) init<=1'b0;
      end
  end
endmodule
//verilator lint_on WIDTH

