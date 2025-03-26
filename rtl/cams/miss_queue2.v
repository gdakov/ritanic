/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


`include "../struct.v"


//read-during-write behaviour: write first
module missQ_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=2+2*`mOp1_width;
  localparam ADDR_WIDTH=5;
  localparam ADDR_COUNT=32;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

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

//read-during-write behaviour: write first
module missQ_data_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=2*128;
  localparam ADDR_WIDTH=5;
  localparam ADDR_COUNT=32;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

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

module missQ_datax_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=2*128+16+10+4;
  localparam ADDR_WIDTH=5;
  localparam ADDR_COUNT=32;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

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

//compile missQ to hard macro without deleting the redundant data outputs
//take into consideration the spacing of the bits in the LSQ unit

//verilator lint_off PINMISSING
//verilator lint_off WIDTH
module missQ(
  clk,
  rst,
  except,
  excpt_thread,
//  read_clkEn,
//  last_inserted,
  insert_isData,
  insBus_req,
  insBus_addr,
  doSkip,
  do_bus_hold,
//  do_unlock,
  nowfl,
  miss0,
  mOp0_en,
  mOp0_thread,
  mOp0_addrEven,
  mOp0_addrOdd,
  mOp0_sz,
  mOp0_st,
  mOp0_banks,
  mOp0_bank0,
  mOp0_odd,
  mOp0_addr_low,
  mOp0_split,
  mOp0_register,
  mOp0_ctype,
  mOp0_clHit,
  mOp0_LSQ,
  mOp0_II,
  mOp0_WQ,
  mOp0_lsflag,
  mOp0_en_o,
  mOp0_thread_o,
  mOp0_addrEven_o,
  mOp0_addrOdd_o,
  mOp0_sz_o,
  mOp0_st_o,
  mOp0_banks_o,
  mOp0_bank0_o,
  mOp0_odd_o,
  mOp0_addr_low_o,
  mOp0_split_o,
  mOp0_register_o,
  mOp0_ctype_o,
  mOp0_LSQ_o,
  mOp0_II_o,
  mOp0_WQ_o,
  mOp0_lsflag_o,
  mOp0_lsfwd_o,
  miss1,
  mOp1_en,
  mOp1_thread,
  mOp1_addrEven,
  mOp1_addrOdd,
  mOp1_sz,
  mOp1_st,
  mOp1_banks,
  mOp1_bank0,
  mOp1_odd,
  mOp1_addr_low,
  mOp1_split,
  mOp1_register,
  mOp1_ctype,
  mOp1_clHit,
  mOp1_LSQ,
  mOp1_II,
  mOp1_WQ,
  mOp1_lsflag,
  mOp1_en_o,
  mOp1_thread_o,
  mOp1_addrEven_o,
  mOp1_addrOdd_o,
  mOp1_sz_o,
  mOp1_st_o,
  mOp1_banks_o,
  mOp1_bank0_o,
  mOp1_odd_o,
  mOp1_addr_low_o,
  mOp1_split_o,
  mOp1_register_o,
  mOp1_ctype_o,
  mOp1_LSQ_o,
  mOp1_II_o,
  mOp1_WQ_o,
  mOp1_lsflag_o,
  mOp1_lsfwd_o,
  miss2,
  mOp2_en,
  mOp2_thread,
  mOp2_addrEven,
  mOp2_addrOdd,
  mOp2_sz,
  mOp2_st,
  mOp2_banks,
  mOp2_bank0,
  mOp2_odd,
  mOp2_addr_low,
  mOp2_split,
  mOp2_register,
  mOp2_ctype,
  mOp2_clHit,
  mOp2_LSQ,
  mOp2_II,
  mOp2_WQ,
  mOp2_lsflag,//s
  mOp2_en_no,
  mOp2_thread_no,
  mOp2_addrEven_no,
  mOp2_addrOdd_no,
  mOp2_sz_no,
  mOp2_st_no,
  mOp2_banks_no,
  mOp2_bank0_no,
  mOp2_odd_no,
  mOp2_addr_low_no,
  mOp2_split_no,
  mOp2_register_no,
  mOp2_ctype_no,
  mOp2_LSQ_no,
  mOp2_II_no,
  mOp2_WQ_no,
  mOp2_lsflag_no,
  mOp2_lsfwd_no,
  mOp2_data_o,
  mOp2_pbit_o,
  mOp2_brdread_o,
  miss3,
  mOp3_en,
  mOp3_thread,
  mOp3_addrEven,
  mOp3_addrOdd,
  mOp3_sz,
  mOp3_st,
  mOp3_banks,
  mOp3_bank0,
  mOp3_odd,
  mOp3_addr_low,
  mOp3_split,
  mOp3_register,
  mOp3_clHit,
  mOp3_LSQ,
  mOp3_II,
  mOp3_WQ,
  mOp3_lsflag,
  mOp3_lsfwd,
  mOp3_data,
  mOp3_pbit,
  mOp3_ctype,
  mOp3_brdbanks,
  mOp3_en_no,
  mOp3_thread_no,
  mOp3_addrEven_no,
  mOp3_addrOdd_no,
  mOp3_sz_no,
  mOp3_st_no,
  mOp3_banks_no,
  mOp3_bank0_no,
  mOp3_odd_no,
  mOp3_addr_low_no,
  mOp3_split_no,
  mOp3_register_no,
  mOp3_LSQ_no,
  mOp3_II_no,
  mOp3_WQ_no,
  mOp3_lsflag_no,
  mOp3_lsfwd_no,
  mOp3_data_no,
  mOp3_pbit_no,
  mOp3_ctype_no,
  mOp3_brdbanks_no,
  miss4,
  mOp4_en,
  mOp4_dupl,//write to a non-exclusive cl
  //mOp4_thread,
  mOp4_addrEven,
  mOp4_addrOdd,
  mOp4_sz,
  mOp4_first,
  mOp4_banks,
  mOp4_bank0,
  mOp4_bank1,
  mOp4_bgn_b,
  mOp4_end_b,
  mOp4_odd,
  mOp4_addr_low,
  mOp4_split,
  mOp4_clHit,
  mOp4_data,
  mOp4_pbit,
  mOp4_ctype,
  mOp4_II,
  mOp4_en_no,
 // mOp4_dupl_no,//write to a non-exclusive cl
  //mOp4_thread,
  mOp4_addrEven_no,
  mOp4_addrOdd_no,
  mOp4_sz_no,
//  mOp4_first_no,
  mOp4_banks_no,
  mOp4_bank0_no,
  mOp4_bank1_no,
  mOp4_bgn_b_no,
  mOp4_end_b_no,
  mOp4_odd_no,
  mOp4_addr_low_no,
  mOp4_split_no,
  mOp4_data_no,
  mOp4_dataN_no,
  mOp4_pbit_no,
  mOp4_ctype_no,
  mOp4_II_no,
  miss5,
  mOp5_en,
  mOp5_dupl,
 // mOp5_thread,
  mOp5_addrEven,
  mOp5_addrOdd,
  mOp5_sz,
  mOp5_first,
  mOp5_banks,
  mOp5_bank0,
  mOp5_bank1,
  mOp5_bgn_b,
  mOp5_end_b,
  mOp5_odd,
  mOp5_addr_low,
  mOp5_split,
  mOp5_clHit,
  mOp5_data,
  mOp5_pbit,
  mOp5_ctype,
  mOp5_II,
  mOp5_en_no,
//  mOp5_dupl_no,
 // mOp5_thread,
  mOp5_addrEven_no,
  mOp5_addrOdd_no,
  mOp5_sz_no,
//  mOp5_first_no,
  mOp5_banks_no,
  mOp5_bank0_no,
  mOp5_bank1_no,
  mOp5_bgn_b_no,
  mOp5_end_b_no,
  mOp5_odd_no,
  mOp5_addr_low_no,
  mOp5_split_no,
  mOp5_data_no,
  mOp5_dataN_no,
  mOp5_pbit_no,
  mOp5_ctype_no,
  mOp5_II_no,

  mOp_noBanks,
  mOp_noBanks_o,//
  mOp_write_clear,
  mOpR_en,
  mOpR_addr,
  mOpR_sz,
  mOpR_req,
  mOpR_st,
  mOpR_bank0,
  mOpR_io,//
  mOpR_odd,
  mOpR_addr_low,
  mOpR_split,
  mOpR_dupl,
  rdwr_match2,
  alt_bus_hold,
  alt_bus_addr,
  alt_bus_hold_reg3
  );

  localparam DEPTH=32;
  localparam ADDR_WIDTH=5;
  localparam DATA_WIDTH=2+2*`mOp1_width;
  localparam MOP_WIDTH=`mOp1_width;
  localparam STALL_COUNT=20;//up to 26
  localparam VADDR_WIDTH=64;
  localparam PADDR_WIDTH=44;
  localparam OPERATION_WIDTH=`operation_width;
  localparam TLB_DWIDTH=`dmlbData_width;
  localparam INDEX_WIDTH=7;
  localparam BANK_COUNT=32;
  localparam REG_WIDTH=9;
  localparam DDATA_WIDTH=2*128;
  localparam DXDATA_WIDTH=2*128+16+10+4;
  localparam THREE=0;

  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire excpt_thread;
  input pwire insert_isData;
  input pwire [4:0] insBus_req;
  output pwire [36:0] insBus_addr;
  pwire read_clkEn;
  pwire last_inserted;
  output pwire reg doSkip;
  output pwire do_bus_hold;
  reg do_unlock;
  output pwire nowfl;
  
  input pwire miss0;
  input pwire mOp0_en;
  input pwire mOp0_thread;
  input pwire [PADDR_WIDTH-1:8] mOp0_addrEven;
  input pwire [PADDR_WIDTH-1:8] mOp0_addrOdd;
  input pwire [4:0] mOp0_sz;
  input pwire mOp0_st;
  input pwire [BANK_COUNT-1:0] mOp0_banks;
  input pwire [4:0] mOp0_bank0;
  input pwire mOp0_odd;
  input pwire [1:0] mOp0_addr_low;
  input pwire mOp0_split;
  input pwire [REG_WIDTH-1:0] mOp0_register;
  input pwire [1:0] mOp0_ctype;
  input pwire [1:0] mOp0_clHit;
  input pwire [8:0] mOp0_LSQ;
  input pwire [9:0] mOp0_II;
  input pwire [5:0] mOp0_WQ;
  input pwire mOp0_lsflag;
  output pwire mOp0_en_o;
  output pwire mOp0_thread_o;
  output pwire [PADDR_WIDTH-1:8] mOp0_addrEven_o;
  output pwire [PADDR_WIDTH-1:8] mOp0_addrOdd_o;
  output pwire [4:0] mOp0_sz_o;
  output pwire mOp0_st_o;
  output pwire [BANK_COUNT-1:0] mOp0_banks_o;
  output pwire [4:0] mOp0_bank0_o;
  output pwire mOp0_odd_o;
  output pwire [1:0] mOp0_addr_low_o;
  output pwire mOp0_split_o;
  output pwire [REG_WIDTH-1:0] mOp0_register_o;
  output pwire [1:0] mOp0_ctype_o;
  output pwire [8:0] mOp0_LSQ_o;
  output pwire [9:0] mOp0_II_o;
  output pwire [5:0] mOp0_WQ_o;
  output pwire mOp0_lsflag_o;
  output pwire mOp0_lsfwd_o;


  input pwire miss1;
  input pwire mOp1_en;
  input pwire mOp1_thread;
  input pwire [PADDR_WIDTH-1:8] mOp1_addrEven;
  input pwire [PADDR_WIDTH-1:8] mOp1_addrOdd;
  input pwire [4:0] mOp1_sz;
  input pwire mOp1_st;
  input pwire [BANK_COUNT-1:0] mOp1_banks;
  input pwire [4:0] mOp1_bank0;
  input pwire mOp1_odd;
  input pwire [1:0] mOp1_addr_low;
  input pwire mOp1_split;
  input pwire [REG_WIDTH-1:0] mOp1_register;
  input pwire [1:0] mOp1_ctype;
  input pwire [1:0] mOp1_clHit;
  input pwire [8:0] mOp1_LSQ;
  input pwire [9:0] mOp1_II;
  input pwire [5:0] mOp1_WQ;
  input pwire mOp1_lsflag;
  output pwire mOp1_en_o;
  output pwire mOp1_thread_o;
  output pwire [PADDR_WIDTH-1:8] mOp1_addrEven_o;
  output pwire [PADDR_WIDTH-1:8] mOp1_addrOdd_o;
  output pwire [4:0] mOp1_sz_o;
  output pwire mOp1_st_o;
  output pwire [BANK_COUNT-1:0] mOp1_banks_o;
  output pwire [4:0] mOp1_bank0_o;
  output pwire mOp1_odd_o;
  output pwire [1:0] mOp1_addr_low_o;
  output pwire mOp1_split_o;
  output pwire [REG_WIDTH-1:0] mOp1_register_o;
  output pwire [1:0] mOp1_ctype_o;
  output pwire [8:0] mOp1_LSQ_o;
  output pwire [9:0] mOp1_II_o;
  output pwire [5:0] mOp1_WQ_o;
  output pwire mOp1_lsflag_o;
  output pwire mOp1_lsfwd_o;


  input pwire miss2;
  input pwire mOp2_en;
  input pwire mOp2_thread;
  input pwire [PADDR_WIDTH-1:8] mOp2_addrEven;
  input pwire [PADDR_WIDTH-1:8] mOp2_addrOdd;
  input pwire [4:0] mOp2_sz;
  input pwire mOp2_st;
  input pwire [BANK_COUNT-1:0] mOp2_banks;
  input pwire [4:0] mOp2_bank0;
  input pwire mOp2_odd;
  input pwire [1:0] mOp2_addr_low;
  input pwire mOp2_split;
  input pwire [REG_WIDTH-1:0] mOp2_register;
  input pwire [1:0] mOp2_ctype;
  input pwire [1:0] mOp2_clHit;
  input pwire [8:0] mOp2_LSQ;
  input pwire [9:0] mOp2_II;
  input pwire [5:0] mOp2_WQ;
  input pwire mOp2_lsflag;
  output pwire mOp2_en_no;
  output pwire mOp2_thread_no;
  output pwire [PADDR_WIDTH-1:8] mOp2_addrEven_no;
  output pwire [PADDR_WIDTH-1:8] mOp2_addrOdd_no;
  output pwire [4:0] mOp2_sz_no;
  output pwire mOp2_st_no;
  output pwire [BANK_COUNT-1:0] mOp2_banks_no;
  output pwire [4:0] mOp2_bank0_no;
  output pwire mOp2_odd_no;
  output pwire [1:0] mOp2_addr_low_no;
  output pwire mOp2_split_no;
  output pwire [REG_WIDTH-1:0] mOp2_register_no;
  output pwire [1:0] mOp2_ctype_no;
  output pwire [8:0] mOp2_LSQ_no;
  output pwire [9:0] mOp2_II_no;
  output pwire [5:0] mOp2_WQ_no;
  output pwire mOp2_lsflag_no;
  output pwire mOp2_lsfwd_no;
  output pwire [135:0] mOp2_data_o;
  output pwire [1:0] mOp2_pbit_o;
  output pwire [4:0] mOp2_brdread_o;


  input pwire miss3;
  input pwire mOp3_en;
  input pwire mOp3_thread;
  input pwire [PADDR_WIDTH-1:8] mOp3_addrEven;
  input pwire [PADDR_WIDTH-1:8] mOp3_addrOdd;
  input pwire [4:0] mOp3_sz;
  input pwire mOp3_st;
  input pwire [BANK_COUNT-1:0] mOp3_banks;
  input pwire [4:0] mOp3_bank0;
  input pwire mOp3_odd;
  input pwire [1:0] mOp3_addr_low;
  input pwire mOp3_split;
  input pwire [REG_WIDTH-1:0] mOp3_register;
  input pwire [1:0] mOp3_clHit;
  input pwire [8:0] mOp3_LSQ;
  input pwire [9:0] mOp3_II;
  input pwire [5:0] mOp3_WQ;
  input pwire mOp3_lsflag;
  input pwire mOp3_lsfwd;
  input pwire [135:0] mOp3_data;
  input pwire [1:0] mOp3_pbit;
  input pwire [1:0] mOp3_ctype;
  input pwire [4:0] mOp3_brdbanks;
  output pwire mOp3_en_no;
  output pwire mOp3_thread_no;
  output pwire [PADDR_WIDTH-1:8] mOp3_addrEven_no;
  output pwire [PADDR_WIDTH-1:8] mOp3_addrOdd_no;
  output pwire [4:0] mOp3_sz_no;
  output pwire mOp3_st_no;
  output pwire [BANK_COUNT-1:0] mOp3_banks_no;
  output pwire [4:0] mOp3_bank0_no;
  output pwire mOp3_odd_no;
  output pwire [1:0] mOp3_addr_low_no;
  output pwire mOp3_split_no;
  output pwire [REG_WIDTH-1:0] mOp3_register_no;
  output pwire [8:0] mOp3_LSQ_no;
  output pwire [9:0] mOp3_II_no;
  output pwire [5:0] mOp3_WQ_no;
  output pwire mOp3_lsflag_no;
  output pwire mOp3_lsfwd_no;
  output pwire [135:0] mOp3_data_no;
  output pwire [1:0] mOp3_pbit_no;
  output pwire [1:0] mOp3_ctype_no;
  output pwire [4:0] mOp3_brdbanks_no;

  input pwire miss4;
  input pwire mOp4_en;
  input pwire [1:0] mOp4_dupl;
 // inout mOp4_thread;
  input pwire [PADDR_WIDTH-1:8] mOp4_addrEven;
  input pwire [PADDR_WIDTH-1:8] mOp4_addrOdd;
  input pwire [4:0] mOp4_sz;
  input pwire mOp4_first;
  input pwire [BANK_COUNT-1:0] mOp4_banks;
  input pwire [4:0] mOp4_bank0;
  input pwire [4:0] mOp4_bank1;
  input pwire [3:0] mOp4_bgn_b;
  input pwire [3:0] mOp4_end_b;
  input pwire mOp4_odd;
  input pwire [1:0] mOp4_addr_low;
  input pwire mOp4_split;
  input pwire [1:0] mOp4_clHit;
  input pwire [159:0] mOp4_data;
  input pwire [1:0] mOp4_pbit;
  input pwire [1:0] mOp4_ctype;
  input pwire [9:0] mOp4_II;
  output pwire mOp4_en_no;
  //output [1:0] mOp4_dupl_no;
 // inout mOp4_thread;
  output pwire [PADDR_WIDTH-1:8] mOp4_addrEven_no;
  output pwire [PADDR_WIDTH-1:8] mOp4_addrOdd_no;
  output pwire [4:0] mOp4_sz_no;
  //output mOp4_first_no;
  output pwire [BANK_COUNT-1:0] mOp4_banks_no;
  output pwire [4:0] mOp4_bank0_no;
  output pwire [4:0] mOp4_bank1_no;
  output pwire [3:0] mOp4_bgn_b_no;
  output pwire [3:0] mOp4_end_b_no;
  output pwire mOp4_odd_no;
  output pwire [1:0] mOp4_addr_low_no;
  output pwire mOp4_split_no;
//  output pwire [1:0] mOp4_clHit_no;
  output pwire [159:0] mOp4_data_no;
  output pwire [159:0] mOp4_dataN_no;
  output pwire [1:0] mOp4_pbit_no;
  output pwire [1:0] mOp4_ctype_no;
  output pwire [9:0] mOp4_II_no;

  input pwire miss5;
  input pwire mOp5_en;
  input pwire [1:0] mOp5_dupl;
//  inout mOp5_thread;
  input pwire [PADDR_WIDTH-1:8] mOp5_addrEven;
  input pwire [PADDR_WIDTH-1:8] mOp5_addrOdd;
  input pwire [4:0] mOp5_sz;
  input pwire mOp5_first;
  input pwire [BANK_COUNT-1:0] mOp5_banks;
  input pwire [4:0] mOp5_bank0;
  input pwire [4:0] mOp5_bank1;
  input pwire [3:0] mOp5_bgn_b;
  input pwire [3:0] mOp5_end_b;
  input pwire mOp5_odd;
  input pwire [1:0] mOp5_addr_low;
  input pwire mOp5_split;
  input pwire [1:0] mOp5_clHit;
  input pwire [159:0] mOp5_data;
  input pwire [1:0] mOp5_pbit;
  input pwire [1:0] mOp5_ctype;
  input pwire [9:0] mOp5_II;
  output pwire mOp5_en_no;
 // output pwire [1:0] mOp5_dupl_no;
//  inout mOp5_thread;
  output pwire [PADDR_WIDTH-1:8] mOp5_addrEven_no;
  output pwire [PADDR_WIDTH-1:8] mOp5_addrOdd_no;
  output pwire [4:0] mOp5_sz_no;
  //output mOp5_first_no;
  output pwire [BANK_COUNT-1:0] mOp5_banks_no;
  output pwire [4:0] mOp5_bank0_no;
  output pwire [4:0] mOp5_bank1_no;
  output pwire [3:0] mOp5_bgn_b_no;
  output pwire [3:0] mOp5_end_b_no;
  output pwire mOp5_odd_no;
  output pwire [1:0] mOp5_addr_low_no;
  output pwire mOp5_split_no;
  //output [1:0] mOp5_clHit_no;
  output pwire [159:0] mOp5_data_no;
  output pwire [159:0] mOp5_dataN_no;
  output pwire [1:0] mOp5_pbit_no;
  output pwire [1:0] mOp5_ctype_no;
  output pwire [9:0] mOp5_II_no;
  
  input pwire [31:0] mOp_noBanks;
  output pwire [31:0] mOp_noBanks_o;
  output pwire mOp_write_clear;

  output pwire mOpR_en;
  output pwire [PADDR_WIDTH-1:7] mOpR_addr;
  output pwire [4:0] mOpR_sz;
  output pwire [3:0] mOpR_req;
  output pwire mOpR_st;
  output pwire [4:0] mOpR_bank0;
  output pwire mOpR_odd;
  output pwire [1:0] mOpR_addr_low;
  output pwire mOpR_split;
  output pwire mOpR_dupl;
  output pwire mOpR_io;
  output pwire rdwr_match2;
  input pwire alt_bus_hold;
  input pwire [36:0] alt_bus_addr;
  input pwire alt_bus_hold_reg3;
  pwire [5:0] curConfl;
//  pwire [5:0] write_confl;
  pwire [5:0] read_confl;
  pwire [5:0] sel;  
  pwire conflFound;
  pwire doStep;
  
  reg [ADDR_WIDTH-1:0] read_addr;
  pwire [ADDR_WIDTH-1:0] read_addr_d;
 // reg [ADDR_WIDTH-1:0] read_addr_old;
  reg [ADDR_WIDTH-1:0] read_addr_begin;
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  reg [ADDR_WIDTH-1:0] write_addr_end;
  reg [ADDR_WIDTH-1:0] write_addr_end2;
 // pwire [ADDR_WIDTH-1:0] write_addr_end_d;
  reg [ADDR_WIDTH-1:0] write_addr;
  pwire [ADDR_WIDTH-1:0] write_addr_d;
  reg [ADDR_WIDTH:0] count;
  pwire [ADDR_WIDTH:0] count_d;
  reg [ADDR_WIDTH:0] countF;
  pwire [ADDR_WIDTH:0] countF_d;
  pwire wen;
  pwire [4:0] write_addr_dec;

  reg insert_isData_reg;
  reg [4:0] insBus_req_reg;
  reg [36:0] insBus_addr_reg;
  reg insert_isData_reg2;
  reg [4:0] insBus_req_reg2;
  reg [36:0] insBus_addr_reg2;

  pwire [MOP_WIDTH-1:0] write_mop[5:0];
  pwire [DATA_WIDTH-1:0] write_dataA;
  pwire [DATA_WIDTH-1:0] write_dataB;
  pwire [DATA_WIDTH-1:0] write_dataC;
  pwire [MOP_WIDTH-1:0] read_mop[5:0];
  pwire [DATA_WIDTH-1:0] read_dataA;
  pwire [DATA_WIDTH-1:0] read_dataB;
  pwire [DATA_WIDTH-1:0] read_dataC;
  pwire [DDATA_WIDTH-1:0] read_ddata;
  pwire [DDATA_WIDTH-1:0] write_ddata;
  pwire [DXDATA_WIDTH-1:0] read_dxdata;
  pwire [DXDATA_WIDTH-1:0] write_dxdata;
  
  
  reg [5:0] confl_mask;

  reg mOp0_thread_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp0_addrEven_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp0_addrOdd_reg[3:1];
  reg [4:0] mOp0_sz_reg[3:1];
  reg mOp0_st_reg[3:1];
  reg [BANK_COUNT-1:0] mOp0_banks_reg[3:1];
  reg [4:0] mOp0_bank0_reg[3:1];
  reg [4:0] mOp0_bank1_reg[3:1];
  reg mOp0_odd_reg[3:1];
  reg [1:0] mOp0_addr_low_reg[3:1];
  reg mOp0_split_reg[3:1];
  reg [REG_WIDTH-1:0] mOp0_register_reg[3:1];
  reg [8:0] mOp0_LSQ_reg[3:1];
  reg [9:0] mOp0_II_reg[3:1];
  reg [5:0] mOp0_WQ_reg[3:1];
  reg [1:0] mOp0_ctype_reg[3:1];
  reg mOp0_lsflag_reg[3:1];
  reg mOp0_lsfwd_reg[3:1];

  reg mOp1_thread_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp1_addrEven_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp1_addrOdd_reg[3:1];
  reg [4:0] mOp1_sz_reg[3:1];
  reg mOp1_st_reg[3:1];
  reg [BANK_COUNT-1:0] mOp1_banks_reg[3:1];
  reg [4:0] mOp1_bank0_reg[3:1];
  reg [4:0] mOp1_bank1_reg[3:1];
  reg mOp1_odd_reg[3:1];
  reg [1:0] mOp1_addr_low_reg[3:1];
  reg mOp1_split_reg[3:1];
  reg [REG_WIDTH-1:0] mOp1_register_reg[3:1];
  reg [8:0] mOp1_LSQ_reg[3:1];
  reg [9:0] mOp1_II_reg[3:1];
  reg [5:0] mOp1_WQ_reg[3:1];
  reg [1:0] mOp1_ctype_reg[3:1];
  reg mOp1_lsflag_reg[3:1];
  reg mOp1_lsfwd_reg[3:1];

  reg mOp2_thread_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp2_addrEven_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp2_addrOdd_reg[3:1];
  reg [4:0] mOp2_sz_reg[3:1];
  reg mOp2_st_reg[3:1];
  reg [BANK_COUNT-1:0] mOp2_banks_reg[3:1];
  reg [4:0] mOp2_bank0_reg[3:1];
  reg [4:0] mOp2_bank1_reg[3:1];
  reg mOp2_odd_reg[3:1];
  reg [1:0] mOp2_addr_low_reg[3:1];
  reg mOp2_split_reg[3:1];
  reg [REG_WIDTH-1:0] mOp2_register_reg[3:1];
  reg [8:0] mOp2_LSQ_reg[3:1];
  reg [9:0] mOp2_II_reg[3:1];
  reg [5:0] mOp2_WQ_reg[3:1];
  reg [1:0] mOp2_ctype_reg[3:1];
  reg mOp2_lsflag_reg[3:1];
  reg [127+8:0] mOp2_data_reg[3:1];
  reg [4:0] mOp2_brdread_reg[3:1];
  reg [1:0] mOp2_pbit_reg[3:1];
  reg mOp2_lsfwd_reg[3:1];

  reg mOp3_thread_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp3_addrEven_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp3_addrOdd_reg[3:1];
  reg [4:0] mOp3_sz_reg[3:1];
  reg mOp3_st_reg[3:1];
  reg [BANK_COUNT-1:0] mOp3_banks_reg[3:1];
  reg [4:0] mOp3_bank0_reg[3:1];
  reg [4:0] mOp3_bank1_reg[3:1];
  reg mOp3_odd_reg[3:1];
  reg [1:0] mOp3_addr_low_reg[3:1];
  reg mOp3_split_reg[3:1];
  reg [REG_WIDTH-1:0] mOp3_register_reg[3:1];
  reg [8:0] mOp3_LSQ_reg[3:1];
  reg [9:0] mOp3_II_reg[3:1];
  reg [5:0] mOp3_WQ_reg[3:1];
  reg mOp3_lsflag_reg[3:1];
  reg mOp3_lsfwd_reg[3:1];
  reg [127:0] mOp3_data_reg[3:1];
  reg [3:0] mOp3_brdbanks_reg[3:1];
  reg [1:0] mOp3_pbit_reg[3:1];
  reg [1:0] mOp3_ctype_reg[3:1];

//  reg mOp4_thread_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp4_addrEven_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp4_addrOdd_reg[3:1];
  reg [4:0] mOp4_sz_reg[3:1];
  reg mOp4_first_reg[3:1];
  reg [4:0] mOp4_bank0_reg[3:1];
  reg [4:0] mOp4_bank1_reg[3:1];
  reg mOp4_odd_reg[3:1];
  reg [1:0] mOp4_addr_low_reg[3:1];
  reg mOp4_split_reg[3:1];
  reg [159:0] mOp4_data_reg[3:1];
  reg [9:0] mOp4_II_reg[3:1];
  reg [3:0] mOp4_bgn_b_reg[3:1];
  reg [3:0] mOp4_end_b_reg[3:1];
  reg [1:0] mOp4_pbit_reg[3:1];
  reg [1:0] mOp4_ctype_reg[3:1];

//  reg mOp5_thread_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp5_addrEven_reg[3:1];
  reg [PADDR_WIDTH-1:8] mOp5_addrOdd_reg[3:1];
  reg [4:0] mOp5_sz_reg[3:1];
  reg mOp5_first_reg[3:1];
  reg [4:0] mOp5_bank0_reg[3:1];
  reg [4:0] mOp5_bank1_reg[3:1];
  reg mOp5_odd_reg[3:1];
  reg [1:0] mOp5_addr_low_reg[3:1];
  reg mOp5_split_reg[3:1];
  reg [159:0] mOp5_data_reg[3:1];
  reg [9:0] mOp5_II_reg[3:1];
  reg [3:0] mOp5_bgn_b_reg[3:1];
  reg [3:0] mOp5_end_b_reg[3:1];
  reg [1:0] mOp5_pbit_reg[3:1];
  reg [1:0] mOp5_ctype_reg[3:1];

  reg [31:0] bank4;
  reg [31:0] bank5;
  reg [2:0] sz4;
  reg [2:0] sz5;
  
  reg begin_flush;
  reg begin_flush_reg;
  reg begin_flush_reg2;
  reg begin_flush_reg3;
  reg begin_flush_reg4;
  reg now_flushing;
  pwire flush_end;
  reg sticky_begin;

  reg last_inserted_reg;
  reg last_inserted_reg2;
  reg last_inserted_reg3;
  reg last_inserted_reg4;
  
  pwire [31:0] rdbanks[3:0];
  
  reg locked;
  
 // reg now_flooshing;
  
  pwire rdwr_match,rdwr_match2;

  pwire doSkip_d;
 
  reg stepOver4,stepOver42;
  reg stepOver5,stepOver52;
 
  genvar k;
  integer r,q;
  
  reg init;
  reg [4:0] initCount;
  pwire [4:0] initCount_next;
  
  pwire [5:0] read_thread; 
  pwire [5:0] thrinhibitconfl;
  reg [5:0] thrreginh[3:1];

  reg [31:0] validR;//note validR is different from miss_queue.sv; it means 1 for not cleared by except (block read replays if 0)
  
  pwire [4:0] dummy5;
  pwire [1:0] mOp4_dupl_dummy;
  pwire [1:0] mOp5_dupl_dummy;

  assign read_clkEn=1'b1;
  assign write_dataA={miss1&~thrreginh[3][1],miss0&~thrreginh[3][0],write_mop[1],write_mop[0]}&{DATA_WIDTH{~init}};
  assign write_dataB={miss3&~thrreginh[3][3],miss2&~thrreginh[3][2],write_mop[3],write_mop[2]}&{DATA_WIDTH{~init}};
  assign write_dataC={miss5&~thrreginh[3][5],miss4&~thrreginh[3][4],write_mop[5],write_mop[4]}&{DATA_WIDTH{~init}};
  assign write_ddata={mOp5_data_reg[3][159:32],mOp4_data_reg[3][159:32]}&{DDATA_WIDTH{~init}};
  assign write_dxdata={mOp3_pbit_reg[3],mOp3_data_reg[3],mOp3_brdbanks_reg[3],mOp2_pbit_reg[3],mOp2_data_reg[3],mOp2_brdread_reg[3]}
    &{DXDATA_WIDTH{~init}};
  
  assign wen=(miss0&~thrreginh[3][0]||miss1&~thrreginh[3][1]||miss2&~thrreginh[3][2]||
      miss3&~thrreginh[3][3]||miss4&~thrreginh[3][4]||miss5&~thrreginh[3][5])&~alt_bus_hold_reg3;
  assign read_addr_d=~doStep & ~begin_flush & ~rst ? read_addr : 5'bz; 
  assign read_addr_d=begin_flush &~rst ? read_addr_begin : 5'bz;
  assign write_addr_d=~wen & ~rst ? write_addr : 5'bz; 
  assign count_d=~wen & (~now_flushing|alt_bus_hold) &~rst ? count : 6'bz;
  assign count_d=wen & now_flushing & ~alt_bus_hold &~rst ? count : 6'bz;
  
  assign read_addr_d=rst ? 5'b0:5'bz;
  assign write_addr_d=rst ? 5'b0:5'bz;
  assign count_d=rst ? 6'b0 : 6'bz;
  
  assign {read_confl[1:0],read_mop[1],read_mop[0]}=read_dataA;
  assign {read_confl[3:2],read_mop[3],read_mop[2]}=read_dataB;
  assign {read_confl[5:4],read_mop[5],read_mop[4]}=read_dataC;

  assign do_bus_hold=now_flushing||begin_flush||last_inserted_reg4;
  
  assign mOp_noBanks_o=now_flushing&~alt_bus_hold ? 
    ~(rdbanks[0]|rdbanks[1]|rdbanks[2]|rdbanks[3]) : 32'bz;
  assign mOp_noBanks_o=alt_bus_hold ? 32'hffffffff : 32'bz;
  assign mOp_noBanks_o=~now_flushing&~alt_bus_hold ? mOp_noBanks : 32'bz;
 
  assign read_thread={2'b0,read_mop[3][`mOp1_thr],read_mop[2][`mOp1_thr],read_mop[1][`mOp1_thr],read_mop[0][`mOp1_thr]};

  assign thrinhibitconfl={2'b0,{4{validR[read_addr]==1'b0}}}; 
 
  assign nowfl=now_flushing;

  assign mOp0_thread_o=now_flushing  ?   read_mop[0][`mOp1_thr] : 1'bz;
  assign mOp0_thread_o=~now_flushing  ? mOp0_thread : 1'bz;
  assign mOp0_addrEven_o=now_flushing  ? read_mop[0][`mOp1_addrEven] : 36'bz; 
  assign mOp0_addrEven_o=~now_flushing & ~alt_bus_hold  ? mOp0_addrEven : 36'bz;
  assign mOp0_addrEven_o=alt_bus_hold  ? alt_bus_addr[36:1] : 36'bz;
  assign mOp0_addrOdd_o=now_flushing  ? read_mop[0][`mOp1_addrOdd] : 36'bz; 
  assign mOp0_addrOdd_o=~now_flushing & ~alt_bus_hold  ? mOp0_addrOdd : 36'bz;
  assign mOp0_addrOdd_o=alt_bus_hold  ? alt_bus_addr[36:1] : 36'bz;
  assign mOp0_sz_o=now_flushing  ?       read_mop[0][`mOp1_sz] : 5'bz; 
  assign mOp0_sz_o=~now_flushing  ? mOp0_sz : 5'bz; 
  assign mOp0_st_o=now_flushing  ?       read_mop[0][`mOp1_st] : 1'bz; 
  assign mOp0_st_o=~now_flushing  ? mOp0_st : 1'bz; 
  assign mOp0_split_o=now_flushing  ?    read_mop[0][`mOp1_split] : 1'bz; 
  assign mOp0_split_o=~now_flushing  ? mOp0_split : 1'bz; 
  assign mOp0_addr_low_o=now_flushing  ? read_mop[0][`mOp1_low] : 2'bz;
  assign mOp0_addr_low_o=~now_flushing  ? mOp0_addr_low : 2'bz; 
  assign mOp0_odd_o=now_flushing  ? read_mop[0][`mOp1_odd] : 1'bz; 
  assign mOp0_odd_o=~now_flushing & ~alt_bus_hold  ? mOp0_odd : 1'bz;
  assign mOp0_odd_o=alt_bus_hold ? alt_bus_addr[0] : 1'bz;
  assign mOp0_banks_o=now_flushing  ?    rdbanks[0] : 32'bz;
  assign mOp0_banks_o=alt_bus_hold  ? 32'b0 : 32'bz;
  assign mOp0_banks_o=~now_flushing & ~alt_bus_hold  ? mOp0_banks : 32'bz;
  assign mOp0_bank0_o=now_flushing  ?    read_mop[0][`mOp1_bank0] : 5'bz; 
  assign mOp0_bank0_o=~now_flushing  ? mOp0_bank0 : 5'bz; 
  assign mOp0_register_o=now_flushing  ? read_mop[0][`mOp1_regNo] : 9'bz;
  assign mOp0_register_o=alt_bus_hold  ? 9'h1ef : 9'bz;
  assign mOp0_register_o=~alt_bus_hold & ~now_flushing  ? mOp0_register : 9'bz;
  assign mOp0_ctype_o=now_flushing  ? read_mop[0][`mOp1_type] : 2'bz;
  assign mOp0_ctype_o=alt_bus_hold  ? 2'b0 : 2'bz;
  assign mOp0_ctype_o=~alt_bus_hold & ~now_flushing  ? mOp0_ctype : 2'bz;
  assign mOp0_en_o=now_flushing  ?       read_confl[0]&~thrinhibitconfl[0]  : 1'bz;
  assign mOp0_en_o=alt_bus_hold  ? 1'b1 : 1'bz;
  assign mOp0_en_o=~now_flushing & ~alt_bus_hold  ? mOp0_en : 1'bz;
  assign mOp0_LSQ_o=now_flushing  ?      read_mop[0][`mOp1_LSQ] : 9'bz; 
  assign mOp0_LSQ_o=~now_flushing  ? mOp0_LSQ : 9'bz; 
  assign mOp0_II_o=now_flushing  ?       read_mop[0][`mOp1_II] : 10'bz; 
  assign mOp0_II_o=~now_flushing  ? mOp0_II : 10'bz; 
  assign mOp0_WQ_o=now_flushing  ?       read_mop[0][`mOp1_WQ] : 6'bz; 
  assign mOp0_WQ_o=~now_flushing  ? mOp0_WQ : 6'bz; 
  assign mOp0_lsflag_o=now_flushing  ?   read_mop[0][`mOp1_lsf] : 1'bz; 
  assign mOp0_lsflag_o=~now_flushing  ? mOp0_lsflag : 1'bz; 

  assign mOp1_thread_o=now_flushing  ?   read_mop[1][`mOp1_thr] : 1'bz;
  assign mOp1_thread_o=~now_flushing  ? mOp1_thread : 1'bz;
  assign mOp1_addrEven_o=now_flushing  ? read_mop[1][`mOp1_addrEven] : 36'bz; 
  assign mOp1_addrEven_o=~now_flushing & ~alt_bus_hold  ? mOp1_addrEven : 36'bz;
  assign mOp1_addrEven_o=alt_bus_hold  ? alt_bus_addr[36:1] : 36'bz;
  assign mOp1_addrOdd_o=now_flushing  ? read_mop[1][`mOp1_addrOdd] : 36'bz; 
  assign mOp1_addrOdd_o=~now_flushing & ~alt_bus_hold  ? mOp1_addrOdd : 36'bz;
  assign mOp1_addrOdd_o=alt_bus_hold  ? alt_bus_addr[36:1] : 36'bz;
  assign mOp1_sz_o=now_flushing  ?       read_mop[1][`mOp1_sz] : 5'bz; 
  assign mOp1_sz_o=~now_flushing  ? mOp1_sz : 5'bz; 
  assign mOp1_st_o=now_flushing  ?       read_mop[1][`mOp1_st] : 1'bz; 
  assign mOp1_st_o=~now_flushing  ? mOp1_st : 1'bz; 
  assign mOp1_split_o=now_flushing  ?    read_mop[1][`mOp1_split] : 1'bz; 
  assign mOp1_split_o=~now_flushing  ? mOp1_split : 1'bz; 
  assign mOp1_addr_low_o=now_flushing  ? read_mop[1][`mOp1_low] : 2'bz;
  assign mOp1_addr_low_o=~now_flushing  ? mOp1_addr_low : 2'bz; 
  assign mOp1_odd_o=now_flushing  ? read_mop[1][`mOp1_odd] : 1'bz; 
  assign mOp1_odd_o=~now_flushing & ~alt_bus_hold  ? mOp1_odd : 1'bz;
  assign mOp1_odd_o=alt_bus_hold ? alt_bus_addr[0] : 1'bz;
  assign mOp1_banks_o=now_flushing  ?    rdbanks[1] : 32'bz;
  assign mOp1_banks_o=alt_bus_hold  ? 32'b0 : 32'bz;
  assign mOp1_banks_o=~now_flushing & ~alt_bus_hold  ? mOp1_banks : 32'bz;
  assign mOp1_bank0_o=now_flushing  ?    read_mop[1][`mOp1_bank0] : 5'bz; 
  assign mOp1_bank0_o=~now_flushing  ? mOp1_bank0 : 5'bz; 
  assign mOp1_register_o=now_flushing  ? read_mop[1][`mOp1_regNo] : 9'bz;
  assign mOp1_register_o=alt_bus_hold  ? 9'h1ef : 9'bz;
  assign mOp1_register_o=~alt_bus_hold & ~now_flushing  ? mOp1_register : 9'bz;
  assign mOp1_ctype_o=now_flushing  ? read_mop[1][`mOp1_type] : 2'bz;
  assign mOp1_ctype_o=alt_bus_hold  ? 2'b0 : 2'bz;
  assign mOp1_ctype_o=~alt_bus_hold & ~now_flushing  ? mOp1_ctype : 2'bz;
  assign mOp1_en_o=now_flushing  ?       read_confl[1]&~thrinhibitconfl[1]  : 1'bz;
  assign mOp1_en_o=alt_bus_hold  ? 1'b1 : 1'bz;
  assign mOp1_en_o=~now_flushing & ~alt_bus_hold  ? mOp1_en : 1'bz;
  assign mOp1_LSQ_o=now_flushing  ?      read_mop[1][`mOp1_LSQ] : 9'bz; 
  assign mOp1_LSQ_o=~now_flushing  ? mOp1_LSQ : 9'bz; 
  assign mOp1_II_o=now_flushing  ?       read_mop[1][`mOp1_II] : 10'bz; 
  assign mOp1_II_o=~now_flushing  ? mOp1_II : 10'bz; 
  assign mOp1_WQ_o=now_flushing  ?       read_mop[1][`mOp1_WQ] : 6'bz; 
  assign mOp1_WQ_o=~now_flushing  ? mOp1_WQ : 6'bz; 
  assign mOp1_lsflag_o=now_flushing  ?   read_mop[1][`mOp1_lsf] : 1'bz; 
  assign mOp1_lsflag_o=~now_flushing  ? mOp1_lsflag : 1'bz; 

  assign mOp2_thread_no=now_flushing  ?   read_mop[2][`mOp1_thr] : 1'bz;
  assign mOp2_thread_no=~now_flushing  ? mOp2_thread : 1'bz;
  assign mOp2_addrEven_no=now_flushing  ? read_mop[2][`mOp1_addrEven] : 36'bz; 
  assign mOp2_addrEven_no=~now_flushing & ~alt_bus_hold  ? mOp2_addrEven : 36'bz;
  assign mOp2_addrEven_no=alt_bus_hold  ? alt_bus_addr[36:1] : 36'bz;
  assign mOp2_addrOdd_no=now_flushing  ? read_mop[2][`mOp1_addrOdd] : 36'bz; 
  assign mOp2_addrOdd_no=~now_flushing & ~alt_bus_hold  ? mOp2_addrOdd : 36'bz;
  assign mOp2_addrOdd_no=alt_bus_hold  ? alt_bus_addr[36:1] : 36'bz;
  assign mOp2_sz_no=now_flushing  ?       read_mop[2][`mOp1_sz] : 5'bz; 
  assign mOp2_sz_no=~now_flushing  ? mOp2_sz : 5'bz; 
  assign mOp2_st_no=now_flushing  ?       read_mop[2][`mOp1_st] : 1'bz; 
  assign mOp2_st_no=~now_flushing  ? mOp2_st : 1'bz; 
  assign mOp2_split_no=now_flushing  ?    read_mop[2][`mOp1_split] : 1'bz; 
  assign mOp2_split_no=~now_flushing  ? mOp2_split : 1'bz; 
  assign mOp2_addr_low_no=now_flushing  ? read_mop[2][`mOp1_low] : 2'bz;
  assign mOp2_addr_low_no=~now_flushing  ? mOp2_addr_low : 2'bz; 
  assign mOp2_odd_no=now_flushing  ? read_mop[2][`mOp1_odd] : 1'bz; 
  assign mOp2_odd_no=~now_flushing & ~alt_bus_hold  ? mOp2_odd : 1'bz;
  assign mOp2_odd_no=alt_bus_hold ? alt_bus_addr[0] : 1'bz;
  assign mOp2_banks_no=now_flushing  ?    rdbanks[2] : 32'bz;
  assign mOp2_banks_no=alt_bus_hold  ? 32'b0 : 32'bz;
  assign mOp2_banks_no=~now_flushing & ~alt_bus_hold  ? mOp2_banks : 32'bz;
  assign mOp2_bank0_no=now_flushing  ?    read_mop[2][`mOp1_bank0] : 5'bz; 
  assign mOp2_bank0_no=~now_flushing  ? mOp2_bank0 : 5'bz; 
  assign mOp2_register_no=now_flushing  ? read_mop[2][`mOp1_regNo] : 9'bz;
  assign mOp2_register_no=alt_bus_hold  ? 9'h1ef : 9'bz;
  assign mOp2_register_no=~alt_bus_hold & ~now_flushing  ? mOp2_register : 9'bz;
  assign mOp2_ctype_no=now_flushing  ? read_mop[2][`mOp1_type] : 2'bz;
  assign mOp2_ctype_no=alt_bus_hold  ? 2'b0 : 2'bz;
  assign mOp2_ctype_no=~alt_bus_hold & ~now_flushing  ? mOp2_ctype : 2'bz;
  assign mOp2_en_no=now_flushing  ?       read_confl[2]&~thrinhibitconfl[2]  : 1'bz;
  assign mOp2_en_no=alt_bus_hold  ? 1'b1 : 1'bz;
  assign mOp2_en_no=~now_flushing & ~alt_bus_hold  ? mOp2_en : 1'bz;
  assign mOp2_LSQ_no=now_flushing  ?      read_mop[2][`mOp1_LSQ] : 9'bz; 
  assign mOp2_LSQ_no=~now_flushing  ? mOp2_LSQ : 9'bz; 
  assign mOp2_II_no=now_flushing  ?       read_mop[2][`mOp1_II] : 10'bz; 
  assign mOp2_II_no=~now_flushing  ? mOp2_II : 10'bz; 
  assign mOp2_WQ_no=now_flushing  ?       read_mop[2][`mOp1_WQ] : 6'bz; 
  assign mOp2_WQ_no=~now_flushing  ? mOp2_WQ : 6'bz; 
  assign mOp2_lsflag_no=now_flushing  ?   read_mop[2][`mOp1_lsf] : 1'bz; 
  assign mOp2_lsflag_no=~now_flushing  ? mOp2_lsflag : 1'bz; 




  assign mOp3_thread_no=now_flushing  ?   read_mop[3][`mOp1_thr] : 1'bz;
  assign mOp3_thread_no=~now_flushing  ? mOp3_thread : 1'bz;
  assign mOp3_addrEven_no=now_flushing  ? read_mop[3][`mOp1_addrEven] : 36'bz; 
  assign mOp3_addrEven_no=~now_flushing & ~alt_bus_hold  ? mOp3_addrEven : 36'bz;
  assign mOp3_addrEven_no=alt_bus_hold  ? alt_bus_addr[36:1] : 36'bz;
  assign mOp3_addrOdd_no=now_flushing  ? read_mop[3][`mOp1_addrOdd] : 36'bz; 
  assign mOp3_addrOdd_no=~now_flushing & ~alt_bus_hold  ? mOp3_addrOdd : 36'bz;
  assign mOp3_addrOdd_no=alt_bus_hold  ? alt_bus_addr[36:1] : 36'bz;
  assign mOp3_sz_no=now_flushing  ?       read_mop[3][`mOp1_sz] : 5'bz; 
  assign mOp3_sz_no=~now_flushing  ? mOp3_sz : 5'bz; 
  assign mOp3_st_no=now_flushing  ?       read_mop[3][`mOp1_st] : 1'bz; 
  assign mOp3_st_no=~now_flushing  ? mOp3_st : 1'bz; 
  assign mOp3_split_no=now_flushing  ?    read_mop[3][`mOp1_split] : 1'bz; 
  assign mOp3_split_no=~now_flushing  ? mOp3_split : 1'bz; 
  assign mOp3_addr_low_no=now_flushing  ? read_mop[3][`mOp1_low] : 2'bz;
  assign mOp3_addr_low_no=~now_flushing  ? mOp3_addr_low : 2'bz; 
  assign mOp3_odd_no=now_flushing  ? read_mop[3][`mOp1_odd] : 1'bz; 
  assign mOp3_odd_no=~now_flushing & ~alt_bus_hold  ? mOp3_odd : 1'bz;
  assign mOp3_odd_no=alt_bus_hold ? alt_bus_addr[THREE] : 1'bz;
  assign mOp3_banks_no=now_flushing  ?    rdbanks[3] : 32'bz;
  assign mOp3_banks_no=alt_bus_hold  ? 32'b0 : 32'bz;
  assign mOp3_banks_no=~now_flushing & ~alt_bus_hold  ? mOp3_banks : 32'bz;
  assign mOp3_bank0_no=now_flushing  ?    read_mop[3][`mOp1_bank0] : 5'bz; 
  assign mOp3_bank0_no=~now_flushing  ? mOp3_bank0 : 5'bz; 
  assign mOp3_register_no=now_flushing  ? read_mop[3][`mOp1_regNo] : 9'bz;
  assign mOp3_register_no=alt_bus_hold  ? 9'h1ef : 9'bz;
  assign mOp3_register_no=~alt_bus_hold & ~now_flushing  ? mOp3_register : 9'bz;
  assign mOp3_ctype_no=now_flushing  ? read_mop[3][`mOp1_type] : 2'bz;
  assign mOp3_ctype_no=alt_bus_hold  ? 2'b0 : 2'bz;
  assign mOp3_ctype_no=~alt_bus_hold & ~now_flushing  ? mOp3_ctype : 2'bz;
  assign mOp3_en_no=now_flushing  ?       read_confl[3]&~thrinhibitconfl[3]  : 1'bz;
  assign mOp3_en_no=alt_bus_hold  ? 1'b1 : 1'bz;
  assign mOp3_en_no=~now_flushing & ~alt_bus_hold  ? mOp3_en : 1'bz;
  assign mOp3_LSQ_no=now_flushing  ?      read_mop[3][`mOp1_LSQ] : 9'bz; 
  assign mOp3_LSQ_no=~now_flushing  ? mOp3_LSQ : 9'bz; 
  assign mOp3_II_no=now_flushing  ?       read_mop[3][`mOp1_II] : 10'bz; 
  assign mOp3_II_no=~now_flushing  ? mOp3_II : 10'bz; 
  assign mOp3_WQ_no=now_flushing  ?       read_mop[3][`mOp1_WQ] : 6'bz; 
  assign mOp3_WQ_no=~now_flushing  ? mOp3_WQ : 6'bz; 
  assign mOp3_lsflag_no=now_flushing  ?   read_mop[3][`mOp1_lsf] : 1'bz; 
  assign mOp3_lsflag_no=~now_flushing  ? mOp3_lsflag : 1'bz; 


//  assign mOp4_thread=now_flushing ?   read_mop[4][`mOp1_thr] : 1'bz;
  assign mOp4_addrEven_no=now_flushing ? read_mop[4][`mOp1_addrEven] : 36'bz; 
  assign mOp4_addrEven_no=~now_flushing & ~alt_bus_hold ? mOp4_addrEven : 36'bz;
  assign mOp4_addrEven_no=alt_bus_hold ? alt_bus_addr[36:1] : 36'bz;
  assign mOp4_addrOdd_no=now_flushing ? read_mop[4][`mOp1_addrOdd] : 36'bz; 
  assign mOp4_addrOdd_no=~now_flushing & ~alt_bus_hold ? mOp4_addrOdd : 36'bz;
  assign mOp4_addrOdd_no=alt_bus_hold ? alt_bus_addr[36:1] : 36'bz;
  assign mOp4_sz_no=now_flushing ?       read_mop[4][`mOp1_sz] : mOp4_sz;
//  assign mOp4_first_o=now_flushing ?    read_mop[4][`mOp1_st] : mOp4_first;
  assign mOp4_split_no=now_flushing ?    read_mop[4][`mOp1_split] : mOp4_split;
  assign mOp4_odd_no=now_flushing ? read_mop[4][`mOp1_odd] : 1'bz; 
  assign mOp4_odd_no=~now_flushing & ~alt_bus_hold ? mOp4_odd : 1'bz;
  assign mOp4_odd_no=alt_bus_hold ? alt_bus_addr[0] : 1'bz;
  assign mOp4_addr_low_no=now_flushing ? read_mop[4][`mOp1_low] : mOp4_addr_low;
  assign mOp4_bank0_no=now_flushing ?    read_mop[4][`mOp1_bank0] : mOp4_bank0;
  assign mOp4_banks_no=now_flushing ?    bank4 : 32'bz;
  assign mOp4_banks_no=alt_bus_hold ? 32'hffff_ffff : 32'bz;
  assign mOp4_banks_no=~now_flushing & ~alt_bus_hold ? mOp4_banks : 32'bz;
  assign mOp4_data_no=now_flushing ? {read_ddata[127:0],read_mop[4][`mOp1_banks]} : mOp4_data;
  assign mOp4_dataN_no=now_flushing ? ~{read_ddata[127:0],read_mop[4][`mOp1_banks]} : ~mOp4_data;
  assign mOp4_ctype_no=now_flushing ? read_mop[4][`mOp1_type] : 2'bz;
  assign mOp4_ctype_no=alt_bus_hold ? 2'b0 : 2'bz;
  assign mOp4_ctype_no=~alt_bus_hold & ~now_flushing ? mOp4_ctype : 2'bz;
  assign mOp4_en_no=now_flushing ?       read_confl[4]&~thrinhibitconfl[4]  : 1'bz;
  assign mOp4_en_no=alt_bus_hold ? 1'b0 : 1'bz;
  assign mOp4_en_no=~now_flushing & ~alt_bus_hold ? mOp4_en : 1'bz;;
  assign {mOp4_pbit_no,mOp4_dupl_dummy,mOp4_bank1_no}=now_flushing ?    read_mop[4][`mOp1_LSQ] : {mOp4_pbit,2'b0,mOp4_bank1};
  assign mOp4_II_no=now_flushing ?       read_mop[4][`mOp1_II] : mOp4_II;
  assign {mOp4_bgn_b_no,mOp4_end_b_no}=now_flushing ? read_mop[4][`mOp1_WQ] : 8'bz;
  assign {mOp4_bgn_b_no,mOp4_end_b_no}=alt_bus_hold ? 8'hff : 8'bz;
  assign {mOp4_bgn_b_no,mOp4_end_b_no}=~now_flushing & ~alt_bus_hold ? {mOp4_bgn_b,mOp4_end_b} : 8'bz;

//  assign mOp5_thread=now_flushing ?   read_mop[5][`mOp1_thr] : 1'bz;
  assign mOp5_addrEven_no=now_flushing ? read_mop[5][`mOp1_addrEven] : 36'bz; 
  assign mOp5_addrEven_no=~now_flushing & ~alt_bus_hold ? mOp5_addrEven : 36'bz;
  assign mOp5_addrEven_no=alt_bus_hold ? alt_bus_addr[36:1] : 36'bz;
  assign mOp5_addrOdd_no=now_flushing ? read_mop[5][`mOp1_addrOdd] : 36'bz; 
  assign mOp5_addrOdd_no=~now_flushing & ~alt_bus_hold ? mOp5_addrOdd : 36'bz;
  assign mOp5_addrOdd_no=alt_bus_hold ? alt_bus_addr[36:1] : 36'bz;
  assign mOp5_sz_no=now_flushing ?       read_mop[5][`mOp1_sz] : mOp5_sz;
//  assign mOp5_first_o=now_flushing ?    read_mop[5][`mOp1_st] : mOp5_first;
  assign mOp5_split_no=now_flushing ?    read_mop[5][`mOp1_split] : mOp5_split;
  assign mOp5_odd_no=now_flushing ? read_mop[5][`mOp1_odd] : 1'bz; 
  assign mOp5_odd_no=~now_flushing & ~alt_bus_hold ? mOp5_odd : 1'bz;
  assign mOp5_odd_no=alt_bus_hold ? alt_bus_addr[0] : 1'bz;
  assign mOp5_addr_low_no=now_flushing ? read_mop[5][`mOp1_low] : mOp5_addr_low;
  assign mOp5_bank0_no=now_flushing ?    read_mop[5][`mOp1_bank0] : mOp5_bank0;
  assign mOp5_banks_no=now_flushing ?    bank5 : 32'bz;
  assign mOp5_banks_no=alt_bus_hold ? 32'b0 : 32'bz;
  assign mOp5_banks_no=~now_flushing & ~alt_bus_hold ? mOp5_banks : 32'bz;
  assign mOp5_data_no=now_flushing ? {read_ddata[255:128],read_mop[5][`mOp1_banks]} : mOp5_data;
  assign mOp5_dataN_no=now_flushing ? ~{read_ddata[255:128],read_mop[5][`mOp1_banks]} :~mOp5_data;
  assign mOp5_ctype_no=now_flushing ? read_mop[5][`mOp1_type] : 2'bz;
  assign mOp5_ctype_no=alt_bus_hold ? 2'b0 : 2'bz;
  assign mOp5_ctype_no=~alt_bus_hold & ~now_flushing ? mOp5_ctype : 2'bz;
  assign mOp5_en_no=now_flushing ?       read_confl[5]&~thrinhibitconfl[5]  : 1'bz;
  assign mOp5_en_no=alt_bus_hold ? 1'b0 : 1'bz;
  assign mOp5_en_no=~now_flushing & ~alt_bus_hold ? mOp5_en : 1'bz;;
  assign {mOp5_pbit_no,mOp5_dupl_dummy,mOp5_bank1_no}=now_flushing ?    read_mop[5][`mOp1_LSQ] : {mOp5_pbit,2'b0,mOp5_bank1};
  assign mOp5_II_no=now_flushing ?       read_mop[5][`mOp1_II] : mOp5_II;
  assign {mOp5_bgn_b_no,mOp5_end_b_no}=now_flushing ? read_mop[5][`mOp1_WQ] : 8'bz;
  assign {mOp5_bgn_b_no,mOp5_end_b_no}=alt_bus_hold ? 8'hff : 8'bz;
  assign {mOp5_bgn_b_no,mOp5_end_b_no}=~now_flushing & ~alt_bus_hold ? {mOp5_bgn_b,mOp5_end_b} : 8'bz;

  assign write_mop[0][`mOp1_thr]=     mOp0_thread_reg[3];
  assign write_mop[0][`mOp1_addrEven]=mOp0_addrEven_reg[3];
  assign write_mop[0][`mOp1_addrOdd]= mOp0_addrOdd_reg[3];
  assign write_mop[0][`mOp1_sz]=      mOp0_sz_reg[3];
  assign write_mop[0][`mOp1_st]=      1'b0;
  assign write_mop[0][`mOp1_split]=   mOp0_split_reg[3];
  assign write_mop[0][`mOp1_low]=     mOp0_addr_low_reg[3];
  assign write_mop[0][`mOp1_odd]=     mOp0_odd_reg[3];
  assign write_mop[0][`mOp1_banks]=   mOp0_banks_reg[3];
  assign write_mop[0][`mOp1_bank0]=   mOp0_bank0_reg[3];
  assign write_mop[0][`mOp1_clHit]=   mOp0_clHit;
  assign write_mop[0][`mOp1_regNo]=   mOp0_register_reg[3];
  assign write_mop[0][`mOp1_type]=    mOp0_ctype_reg[3];
  assign write_mop[0][`mOp1_LSQ]=     mOp0_LSQ_reg[3];
  assign write_mop[0][`mOp1_II]=      mOp0_II_reg[3];
  assign write_mop[0][`mOp1_WQ]=      mOp0_WQ_reg[3];
  assign write_mop[0][`mOp1_lsf]=     mOp0_lsflag_reg[3];
  assign write_mop[0][`mOp1_lsfwd]=   mOp0_lsfwd_reg[3];

  assign write_mop[1][`mOp1_thr]=     mOp1_thread_reg[3];
  assign write_mop[1][`mOp1_addrEven]=mOp1_addrEven_reg[3];
  assign write_mop[1][`mOp1_addrOdd]= mOp1_addrOdd_reg[3];
  assign write_mop[1][`mOp1_sz]=      mOp1_sz_reg[3];
  assign write_mop[1][`mOp1_st]=      1'b0;
  assign write_mop[1][`mOp1_split]=   mOp1_split_reg[3];
  assign write_mop[1][`mOp1_low]=     mOp1_addr_low_reg[3];
  assign write_mop[1][`mOp1_odd]=     mOp1_odd_reg[3];
  assign write_mop[1][`mOp1_banks]=   mOp1_banks_reg[3];
  assign write_mop[1][`mOp1_bank0]=   mOp1_bank0_reg[3];
  assign write_mop[1][`mOp1_clHit]=   mOp1_clHit;
  assign write_mop[1][`mOp1_regNo]=   mOp1_register_reg[3];
  assign write_mop[1][`mOp1_type]=    mOp1_ctype_reg[3];
  assign write_mop[1][`mOp1_LSQ]=     mOp1_LSQ_reg[3];
  assign write_mop[1][`mOp1_II]=      mOp1_II_reg[3];
  assign write_mop[1][`mOp1_WQ]=      mOp1_WQ_reg[3];
  assign write_mop[1][`mOp1_lsf]=     mOp1_lsflag_reg[3];
  assign write_mop[1][`mOp1_lsfwd]=   mOp1_lsfwd_reg[3];

  assign write_mop[2][`mOp1_thr]=     mOp2_thread_reg[3];
  assign write_mop[2][`mOp1_addrEven]=mOp2_addrEven_reg[3];
  assign write_mop[2][`mOp1_addrOdd]= mOp2_addrOdd_reg[3];
  assign write_mop[2][`mOp1_sz]=      mOp2_sz_reg[3];
  assign write_mop[2][`mOp1_st]=      1'b0;
  assign write_mop[2][`mOp1_split]=   mOp2_split_reg[3];
  assign write_mop[2][`mOp1_low]=     mOp2_addr_low_reg[3];
  assign write_mop[2][`mOp1_odd]=     mOp2_odd_reg[3];
  assign write_mop[2][`mOp1_banks]=   mOp2_banks_reg[3];
  assign write_mop[2][`mOp1_bank0]=   mOp2_bank0_reg[3];
  assign write_mop[2][`mOp1_clHit]=   mOp2_clHit;
  assign write_mop[2][`mOp1_regNo]=   mOp2_register_reg[3];
  assign write_mop[2][`mOp1_type]=    mOp2_ctype_reg[3];
  assign write_mop[2][`mOp1_LSQ]=     mOp2_LSQ_reg[3];
  assign write_mop[2][`mOp1_II]=      mOp2_II_reg[3];
  assign write_mop[2][`mOp1_WQ]=      mOp2_WQ_reg[3];
  assign write_mop[2][`mOp1_lsf]=     mOp2_lsflag_reg[3];
  assign write_mop[2][`mOp1_lsfwd]=   mOp2_lsfwd_reg[3];

  assign write_mop[3][`mOp1_thr]=     mOp3_thread_reg[3];
  assign write_mop[3][`mOp1_addrEven]=mOp3_addrEven_reg[3];
  assign write_mop[3][`mOp1_addrOdd]= mOp3_addrOdd_reg[3];
  assign write_mop[3][`mOp1_sz]=      mOp3_sz_reg[3];
  assign write_mop[3][`mOp1_st]=      1'b0;
  assign write_mop[3][`mOp1_split]=   mOp3_split_reg[3];
  assign write_mop[3][`mOp1_low]=     mOp3_addr_low_reg[3];
  assign write_mop[3][`mOp1_odd]=     mOp3_odd_reg[3];
  assign write_mop[3][`mOp1_banks]=   mOp3_banks_reg[3];
  assign write_mop[3][`mOp1_bank0]=   mOp3_bank0_reg[3];
  assign write_mop[3][`mOp1_clHit]=   mOp3_clHit;
  assign write_mop[3][`mOp1_regNo]=   mOp3_register_reg[3];
  assign write_mop[3][`mOp1_type]=    mOp3_ctype_reg[3];
  assign write_mop[3][`mOp1_LSQ]=     mOp3_LSQ_reg[3];
  assign write_mop[3][`mOp1_II]=      mOp3_II_reg[3];
  assign write_mop[3][`mOp1_WQ]=      mOp3_WQ_reg[3];
  assign write_mop[3][`mOp1_lsf]=     mOp3_lsflag_reg[3];
  assign write_mop[3][`mOp1_lsfwd]=   mOp3_lsfwd_reg[3];

  assign write_mop[4][`mOp1_thr]=     1'b0;
  assign write_mop[4][`mOp1_addrEven]=mOp4_addrEven_reg[3];
  assign write_mop[4][`mOp1_addrOdd]= mOp4_addrOdd_reg[3];
  assign write_mop[4][`mOp1_sz]=      mOp4_sz_reg[3];
  assign write_mop[4][`mOp1_st]=      1'b1;
  assign write_mop[4][`mOp1_split]=   mOp4_split_reg[3];
//  assign write_mop[4][`mOp1_low]=     2'b0;
  assign write_mop[4][`mOp1_odd]=     mOp4_odd_reg[3];
  assign write_mop[4][`mOp1_low]=     mOp4_addr_low_reg[3];
  assign write_mop[4][`mOp1_banks]=   mOp4_data_reg[3][31:0];
  assign write_mop[4][`mOp1_bank0]=   mOp4_bank0_reg[3];
  assign write_mop[4][`mOp1_type]=    mOp4_ctype_reg[3];
  assign write_mop[4][`mOp1_clHit]=   mOp4_clHit;
  assign write_mop[4][`mOp1_LSQ]=     {mOp4_pbit_reg[3],mOp4_dupl,mOp4_bank1_reg[3]};
  assign write_mop[4][`mOp1_II]=      mOp4_II_reg[3];
  assign write_mop[4][`mOp1_WQ]=      {mOp4_bgn_b_reg[3],mOp4_end_b_reg[3]};
  assign write_mop[4][`mOp1_lsfwd]=   1'b0;

  assign write_mop[5][`mOp1_thr]=     1'b0;
  assign write_mop[5][`mOp1_addrEven]=mOp5_addrEven_reg[3];
  assign write_mop[5][`mOp1_addrOdd]= mOp5_addrOdd_reg[3];
  assign write_mop[5][`mOp1_sz]=      mOp5_sz_reg[3];
  assign write_mop[5][`mOp1_st]=      1'b1;
  assign write_mop[5][`mOp1_split]=   mOp5_split_reg[3];
//  assign write_mop[5][`mOp1_low]=     2'b0;
  assign write_mop[5][`mOp1_odd]=     mOp5_odd_reg[3];
  assign write_mop[5][`mOp1_low]=     mOp5_addr_low_reg[3];
  assign write_mop[5][`mOp1_banks]=   mOp5_data_reg[3][31:0];
  assign write_mop[5][`mOp1_bank0]=   mOp5_bank0_reg[3];
  assign write_mop[5][`mOp1_type]=    mOp5_ctype_reg[3];
  assign write_mop[5][`mOp1_clHit]=   mOp5_clHit;
  assign write_mop[5][`mOp1_LSQ]=     {mOp5_pbit_reg[3],mOp5_dupl,mOp5_bank1_reg[3]};
  assign write_mop[5][`mOp1_II]=      mOp5_II_reg[3];
  assign write_mop[5][`mOp1_WQ]=      {mOp5_bgn_b_reg[3],mOp5_end_b_reg[3]};
  assign write_mop[5][`mOp1_lsfwd]=   1'b0;



 
  assign curConfl=read_confl&confl_mask;

  assign rdwr_match2=read_addr==write_addr_end;
  assign rdwr_match=countF==6'd1 && !alt_bus_hold;
  assign flush_end=rdwr_match && now_flushing;

  assign mOp_write_clear=begin_flush;
  
  generate
    for(k=0;k<4;k=k+1)  begin
        assign rdbanks[k]=read_mop[k][`mOp1_banks] & {32{read_confl[k]}};        
    end
  endgenerate
  
  adder_inc #(5) read_inc_mod(read_addr,read_addr_d,doStep &~begin_flush &~rst);
  adder_inc #(5) write_inc_mod(write_addr,write_addr_d,wen&~rst);
  adder_inc #(6) count_inc_mod(count,count_d,(~now_flushing|alt_bus_hold) & wen & ~rst);
  adder #(6) count_dec_mod(count,6'b111111,count_d,1'b0,now_flushing & ~alt_bus_hold & ~wen & ~rst);
  //adder #(4) wrEndAdd_mod(write_addr,4'hf,write_addr_end_d,1'b0,1'b1);
  adder #(6) coundF_dec_mod(countF,6'b111111,countF_d,1'b0,1'b1); 
  adder_inc #(5) initAdd_mod(initCount,initCount_next,1'b1);

  
  bit_find_first_bit #(6) findConfl_mod(curConfl,sel,conflFound);

  get_carry #(6) cmpSkip_mod(count,~STALL_COUNT[5:0],1'b1,doSkip_d);
  adder #(5) write_dec_mod(write_addr,5'h1f,write_addr_dec,1'b0,1'b1);
  

  missQ_ram ramA_mod(
  clk,
  rst,
  doStep|begin_flush,
  read_addr_d,
  read_dataA,
  init ? initCount : write_addr,
  write_dataA,
  wen|init
  );

  missQ_ram ramB_mod(
  clk,
  rst,
  doStep|begin_flush,
  read_addr_d,
  read_dataB,
  init ? initCount : write_addr,
  write_dataB,
  wen|init
  );

  missQ_ram ramC_mod(
  clk,
  rst,
  doStep|begin_flush,
  read_addr_d,
  read_dataC,
  init ? initCount : write_addr,
  write_dataC,
  wen|init
  );

  missQ_data_ram ramD_mod(
  clk,
  rst,
  doStep|begin_flush,
  read_addr_d,
  read_ddata,
  init ? initCount : write_addr,
  write_ddata,
  wen|init
  );
  
  missQ_datax_ram ramXD_mod(
  clk,
  rst,
  doStep|begin_flush,
  read_addr_d,
  read_dxdata,
  init ? initCount : write_addr,
  write_dxdata,
  wen|init
  );

  reg low_traffic;
  reg [4:0] traffic_chain;
  dmisscam ms_mod(
  clk,
  rst,
  {2{miss0}}&{~mOp0_clHit}&{mOp0_odd_reg[3]|mOp0_split_reg[3]|low_traffic,~mOp0_odd_reg[3]|mOp0_split_reg[3]|low_traffic},
  mOp0_addrEven_reg[3],mOp0_addrOdd_reg[3],mOp0_st_reg[3],2'b0,mOp0_sz_reg[3],
  mOp0_odd_reg[3],mOp0_ctype_reg[3]==2'b10,mOp0_split_reg[3],mOp0_bank0_reg[3],mOp0_addr_low_reg[3],
  {2{miss1}}&{~mOp1_clHit}&{mOp1_odd_reg[3]|mOp1_split_reg[3]|low_traffic,~mOp1_odd_reg[3]|mOp1_split_reg[3]|low_traffic},
  mOp1_addrEven_reg[3],mOp1_addrOdd_reg[3],mOp1_st_reg[3],2'b0,mOp1_sz_reg[3],
  mOp1_odd_reg[3],mOp1_ctype_reg[3]==2'b10,mOp1_split_reg[3],mOp1_bank0_reg[3],mOp1_addr_low_reg[3],
  {2{miss2}}&{~mOp2_clHit}&{mOp2_odd_reg[3]|mOp2_split_reg[3],~mOp2_odd_reg[3]|mOp2_split_reg[3]},
  mOp2_addrEven_reg[3],mOp2_addrOdd_reg[3],mOp2_st_reg[3],2'b0,mOp2_sz_reg[3],
  mOp2_odd_reg[3],mOp2_ctype_reg[3]==2'b10,mOp2_split_reg[3],mOp2_bank0_reg[3],mOp2_addr_low_reg[3],
  {2{miss3}}&{~mOp3_clHit}&{mOp3_odd_reg[3]|mOp3_split_reg[3]|low_traffic,~mOp3_odd_reg[3]|mOp3_split_reg[3]|low_traffic},
  mOp3_addrEven_reg[3],mOp3_addrOdd_reg[3],mOp3_st_reg[3],2'b0,mOp3_sz_reg[3],
  mOp3_odd_reg[3],mOp3_ctype_reg[3]==2'b10,mOp3_split_reg[3],mOp3_bank0_reg[3],mOp3_addr_low_reg[3],
  {2{miss4}}&{~mOp4_clHit}&{mOp4_odd_reg[3]|mOp4_split_reg[3]|low_traffic,~mOp4_odd_reg[3]|mOp4_split_reg[3]|low_traffic},
  mOp4_addrEven_reg[3],mOp4_addrOdd_reg[3],1'b1,mOp4_dupl,mOp4_sz_reg[3],
  mOp4_odd_reg[3],mOp4_ctype_reg[3]==2'b10,mOp4_split_reg[3],mOp4_bank0_reg[3],mOp4_addr_low_reg[3],
  {2{miss5}}&{~mOp5_clHit}&{mOp5_odd_reg[3]|mOp5_split_reg[3]|low_traffic,~mOp5_odd_reg[3]|mOp5_split_reg[3]|low_traffic},
  mOp5_addrEven_reg[3],mOp5_addrOdd_reg[3],1'b1,mOp5_dupl,mOp5_sz_reg[3],
  mOp5_odd_reg[3],mOp5_ctype_reg[3]==2'b10,mOp5_split_reg[3],mOp5_bank0_reg[3],mOp5_addr_low_reg[3],
  mOpR_en,mOpR_addr,mOpR_st,mOpR_req,mOpR_dupl,mOpR_sz,mOpR_odd,mOpR_io,mOpR_split,mOpR_bank0,mOpR_addr_low,
  insert_isData_reg2,
  insBus_req_reg2[4:0],
  insBus_addr_reg2,
  ,//has_free
  locked,
  last_inserted,
  begin_flush_reg4
  );

  assign doStep=now_flushing&~alt_bus_hold;
 
  always @* begin
      stepOver4=read_mop[4][`mOp1_low]!=2'd0;
      stepOver5=read_mop[5][`mOp1_low]!=2'd0;
      stepOver42=read_mop[4][`mOp1_low]==2'd3;
      stepOver52=read_mop[5][`mOp1_low]==2'd3;
  end
   
  always @* begin
      sz4=read_mop[4][`mOp1_sz]&4'hf;
      sz5=read_mop[5][`mOp1_sz]&4'hf;
  
      for(q=0;q<32;q=q+1) begin
          bank4[q]=read_mop[4][`mOp1_bank0]==q || 
          ((sz4==3 || sz4[2] || (stepOver4 && sz4==2) || 
            (stepOver42 && sz4==1)) && read_mop[4][`mOp1_bank0]==((q-1)&5'h1f)) ||
          (((sz4==3 && stepOver4) | sz4[2]) && read_mop[4][`mOp1_bank0]==((q-2)&5'h1f)) || 
          (((sz4==4 && stepOver42) || sz4==5) && read_mop[4][`mOp1_bank0]==((q-3)&5'h1f)) ||
          ((sz4==5 && stepOver4) && read_mop[4][`mOp1_bank0]==((q-4)&5'h1f)) ;
          bank5[q]=read_mop[5][`mOp1_bank0]==q || 
          ((sz5==3 || sz5[2] || (stepOver5 && sz5==2) || 
            (stepOver52 && sz5==1)) && read_mop[5][`mOp1_bank0]==((q-1)&5'h1f)) ||
          (((sz5==3 && stepOver5) | sz5[2]) && read_mop[5][`mOp1_bank0]==((q-2)&5'h1f)) || 
          (((sz5==5 && stepOver52) || sz5==5) && read_mop[5][`mOp1_bank0]==((q-3)&5'h1f)) ||
          ((sz5==5 && stepOver5) && read_mop[5][`mOp1_bank0]==((q-4)&5'h1f)) ;
      end
  end
  
  always @(posedge clk)
    begin
          if (rst) begin
              insert_isData_reg2<=0;
              insBus_req_reg2<=0;
              insBus_addr_reg2<=0;
              insert_isData_reg<=0;
              insBus_req_reg<=0;
              insBus_addr_reg<=0;
          end else begin
              insert_isData_reg2<=insert_isData_reg;
              insBus_req_reg2<=insBus_req_reg;
              insBus_addr_reg2<=insBus_addr_reg;
              insert_isData_reg<=insert_isData;
              insBus_req_reg<=insBus_req;
              insBus_addr_reg<=insBus_addr;
          end
 
	  if (rst) begin
	      confl_mask<=6'b111111;
	  end else if ((flush_end&~alt_bus_hold)|doStep) begin
	      confl_mask<=6'b111111;
	  end else begin
	      if (!count && wen && ~now_flushing) confl_mask<=6'h3f;
	      else if (count && read_clkEn && ~alt_bus_hold) confl_mask<=confl_mask&~sel;
	  end
	  if (!alt_bus_hold) read_addr<=read_addr_d;
	  write_addr<=write_addr_d;
	  count<=count_d;
	  if (rst) begin
	     read_addr_begin<=5'b0;
             sticky_begin<=1'b0;
	  end else if (wen && !count) begin
	      read_addr_begin<=write_addr;
              sticky_begin<=now_flushing;
	  end else if (now_flushing & wen & ~sticky_begin) begin
              read_addr_begin<=write_addr;
              sticky_begin<=1'b1;
          end else if (~now_flushing) begin
              sticky_begin<=1'b0;
          end

          if (rst) begin
              low_traffic=1'b1;
              traffic_chain=4'b0;              
          end else begin
              traffic_chain={traffic_chain[3:0],miss0|miss1|miss2|miss3|miss4|miss5};
              low_traffic=traffic_chain==5'b0;
          end
	  if (rst) begin
	     write_addr_end<=5'b0;
	     write_addr_end2<=5'b0;
	  end else if (wen && ~locked|do_unlock|(flush_end&&~alt_bus_hold)) begin
	      write_addr_end<=write_addr;
	      write_addr_end2<=write_addr_d;
	  end else if (do_unlock|(flush_end&&~alt_bus_hold) & ~wen) begin
	      write_addr_end<=write_addr_dec;
	      write_addr_end2<=write_addr_dec;
	  end

	  if (rst) begin
	      validR=32'b0;
	  end else if (wen|except) begin
	      if (wen) validR[write_addr]=1'b1;
	      if (except) validR=32'b0;
	  end
	  
          if (rst) doSkip<=1'b0;
	  else if (doSkip_d || last_inserted) doSkip<=1'b1;
	  else if ((flush_end&~alt_bus_hold)|~locked && ~doSkip_d) doSkip<=1'b0;
	  
	  if (rst) begin
              countF<=5'd0;
	      begin_flush<=1'b0;
	      begin_flush_reg<=1'b0;
	      begin_flush_reg2<=1'b0;
	      begin_flush_reg3<=1'b0;
	      begin_flush_reg4<=1'b0;
	      now_flushing<=1'b0;
	      last_inserted_reg<=1'b0;
	      last_inserted_reg2<=1'b0;
	      last_inserted_reg3<=1'b0;
	      last_inserted_reg4<=1'b0;
	      do_unlock<=1'b0;
	      read_addr_reg<={ADDR_WIDTH{1'B0}};
	  end else begin
	      begin_flush<=last_inserted_reg4;
              begin_flush_reg<=begin_flush;
              begin_flush_reg2<=begin_flush_reg;
              begin_flush_reg3<=begin_flush_reg2;
              begin_flush_reg4<=begin_flush_reg3;
              if (begin_flush) countF<=count_d;
              else if (now_flushing && ~alt_bus_hold) 
                  countF<=countF_d;
	      if (begin_flush) now_flushing<=1'b1;
	      else if (flush_end&&~alt_bus_hold) now_flushing<=1'b0;
	      last_inserted_reg<=last_inserted;
	      last_inserted_reg2<=last_inserted_reg;
	      last_inserted_reg3<=last_inserted_reg2;
	      last_inserted_reg4<=last_inserted_reg3;
	      do_unlock<=flush_end&&~alt_bus_hold;
	      read_addr_reg<=read_addr;
	  end
	  if (rst) locked<=1'b0;
	  else if (last_inserted) locked<=1'b1;
	  else if (do_unlock) locked<=1'b0;
	  
	  if (rst) begin
	      for(r=1;r<=3;r=r+1) begin
                  mOp0_thread_reg[r]<=1'b0; 
                  mOp0_addrEven_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp0_addrOdd_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp0_sz_reg[r]<=5'B0;
                  mOp0_st_reg[r]<=1'B0;
                  mOp0_banks_reg[r]<=32'B0;
                  mOp0_bank0_reg[r]<=5'B0;
                  mOp0_odd_reg[r]<=1'B0;
                  mOp0_addr_low_reg[r]<=2'B0;
                  mOp0_split_reg[r]<=1'B0;
                  mOp0_register_reg[r]<=9'b0;
                  mOp0_LSQ_reg[r]<=9'b0;
                  mOp0_II_reg[r]<=10'b0;
                  mOp0_WQ_reg[r]<=8'b0;
                  mOp0_lsflag_reg[r]<=1'b0;

                  mOp1_thread_reg[r]<=1'b0; 
                  mOp1_addrEven_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp1_addrOdd_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp1_sz_reg[r]<=5'B0;
                  mOp1_st_reg[r]<=1'B0;
                  mOp1_banks_reg[r]<=32'B0;
                  mOp1_bank0_reg[r]<=5'B0;
                  mOp1_odd_reg[r]<=1'B0;
                  mOp1_addr_low_reg[r]<=2'B0;
                  mOp1_split_reg[r]<=1'B0;
                  mOp1_register_reg[r]<=9'b0;
                  mOp1_LSQ_reg[r]<=9'b0;
                  mOp1_II_reg[r]<=10'b0;
                  mOp1_WQ_reg[r]<=8'b0;
                  mOp1_lsflag_reg[r]<=1'b0;
                  
                  mOp2_thread_reg[r]<=1'b0; 
                  mOp2_addrEven_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp2_addrOdd_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp2_sz_reg[r]<=5'B0;
                  mOp2_st_reg[r]<=1'B0;
                  mOp2_banks_reg[r]<=32'B0;
                  mOp2_bank0_reg[r]<=5'B0;
                  mOp2_odd_reg[r]<=1'B0;
                  mOp2_addr_low_reg[r]<=2'B0;
                  mOp2_split_reg[r]<=1'B0;
                  mOp2_register_reg[r]<=9'b0;
                  mOp2_LSQ_reg[r]<=9'b0;
                  mOp2_II_reg[r]<=10'b0;
                  mOp2_WQ_reg[r]<=8'b0;
                  mOp2_lsflag_reg[r]<=1'b0;
                  mOp2_data_reg[r]<={8'b0,128'b0};
                  mOp2_pbit_reg[r]<=2'b0;
                  mOp2_brdread_reg[r]<=5'b0;
                  
                  mOp3_thread_reg[r]<=1'b0; 
                  mOp3_addrEven_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp3_addrOdd_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp3_sz_reg[r]<=5'B0;
                  mOp3_st_reg[r]<=1'B0;
                  mOp3_banks_reg[r]<=32'B0;
                  mOp3_bank0_reg[r]<=5'B0;
                  mOp3_odd_reg[r]<=1'B0;
                  mOp3_addr_low_reg[r]<=2'B0;
                  mOp3_split_reg[r]<=1'B0;
                  mOp3_register_reg[r]<=9'b0;
                  mOp3_LSQ_reg[r]<=9'b0;
                  mOp3_II_reg[r]<=10'b0;
                  mOp3_WQ_reg[r]<=8'b0;
                  mOp3_lsflag_reg[r]<=1'b0;
                  mOp3_data_reg[r]<=128'b0;
		  mOp3_lsfwd_reg[r]<=1'b0;
		  mOp3_brdbanks_reg[r]<=4'b0;

                  mOp4_addrEven_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp4_addrOdd_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp4_sz_reg[r]<=5'B0;
                  mOp4_first_reg[r]<=1'B0;
                  mOp4_bank0_reg[r]<=5'B0;
                  mOp4_odd_reg[r]<=1'B0;
                  mOp4_addr_low_reg[r]<=2'B0;
                  mOp4_split_reg[r]<=1'B0;
                  mOp4_data_reg[r]<=160'b0;
                  mOp4_bank1_reg[r]<=9'b0;
                  mOp4_II_reg[r]<=10'b0;
                  mOp4_bgn_b_reg[r]<=4'b0;
                  mOp4_end_b_reg[r]<=4'b0;

                  mOp5_addrEven_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp5_addrOdd_reg[r]<={PADDR_WIDTH-8{1'B0}};
                  mOp5_sz_reg[r]<=5'B0;
                  mOp5_first_reg[r]<=1'B0;
                  mOp5_bank0_reg[r]<=5'B0;
                  mOp5_odd_reg[r]<=1'B0;
                  mOp5_addr_low_reg[r]<=2'B0;
                  mOp5_split_reg[r]<=1'B0;
                  mOp5_data_reg[r]<=160'b0;
                  mOp5_bank1_reg[r]<=9'b0;
                  mOp5_II_reg[r]<=10'b0;
                  mOp5_bgn_b_reg[r]<=4'b0;
                  mOp5_end_b_reg[r]<=4'b0;

                  thrreginh[r]<=6'b0;
	      end
	  end else begin
              thrreginh[1][0]<=mOp0_thread_o~^excpt_thread && except;
	      mOp0_thread_reg[1]<=mOp0_thread_o;
              mOp0_addrEven_reg[1]<=mOp0_addrEven_o;
              mOp0_addrOdd_reg[1]<=mOp0_addrOdd_o;
              mOp0_sz_reg[1]<=mOp0_sz_o;
              mOp0_st_reg[1]<=mOp0_st_o;
              mOp0_banks_reg[1]<=mOp0_banks_o;
              mOp0_bank0_reg[1]<=mOp0_bank0_o;
              mOp0_odd_reg[1]<=mOp0_odd_o;
              mOp0_addr_low_reg[1]<=mOp0_addr_low_o;
              mOp0_split_reg[1]<=mOp0_split_o;
              mOp0_register_reg[1]<=mOp0_register_o;
              mOp0_LSQ_reg[1]<=mOp0_LSQ_o;
              mOp0_II_reg[1]<=mOp0_II_o;
              mOp0_WQ_reg[1]<=mOp0_WQ_o;
              mOp0_ctype_reg[1]<=mOp0_ctype_o;
              mOp0_lsflag_reg[1]<=mOp0_lsflag_o;

              thrreginh[1][1]<=mOp1_thread_o~^excpt_thread && except;
	      mOp1_thread_reg[1]<=mOp1_thread_o;
              mOp1_addrEven_reg[1]<=mOp1_addrEven_o;
              mOp1_addrOdd_reg[1]<=mOp1_addrOdd_o;
              mOp1_sz_reg[1]<=mOp1_sz_o;
              mOp1_st_reg[1]<=mOp1_st_o;
              mOp1_banks_reg[1]<=mOp1_banks_o;
              mOp1_bank0_reg[1]<=mOp1_bank0_o;
              mOp1_odd_reg[1]<=mOp1_odd_o;
              mOp1_addr_low_reg[1]<=mOp1_addr_low_o;
              mOp1_split_reg[1]<=mOp1_split_o;
              mOp1_register_reg[1]<=mOp1_register_o;
              mOp1_LSQ_reg[1]<=mOp1_LSQ_o;
              mOp1_II_reg[1]<=mOp1_II_o;
              mOp1_WQ_reg[1]<=mOp1_WQ_o;
              mOp1_ctype_reg[1]<=mOp1_ctype_o;
              mOp1_lsflag_reg[1]<=mOp1_lsflag_o;

              thrreginh[1][2]<=mOp2_thread_no~^excpt_thread && except;
	      mOp2_thread_reg[1]<=mOp2_thread_no;
              mOp2_addrEven_reg[1]<=mOp2_addrEven_no;
              mOp2_addrOdd_reg[1]<=mOp2_addrOdd_no;
              mOp2_sz_reg[1]<=mOp2_sz_no;
              mOp2_st_reg[1]<=mOp2_st_no;
              mOp2_banks_reg[1]<=mOp2_banks_no;
              mOp2_bank0_reg[1]<=mOp2_bank0_no;
              mOp2_odd_reg[1]<=mOp2_odd_no;
              mOp2_addr_low_reg[1]<=mOp2_addr_low_no;
              mOp2_split_reg[1]<=mOp2_split_no;
              mOp2_register_reg[1]<=mOp2_register_no;
              mOp2_LSQ_reg[1]<=mOp2_LSQ_no;
              mOp2_II_reg[1]<=mOp2_II_no;
              mOp2_WQ_reg[1]<=mOp2_WQ_no;
              mOp2_ctype_reg[1]<=mOp2_ctype_no;
              mOp2_lsflag_reg[1]<=mOp2_lsflag_no;
              mOp2_data_reg[1]<=mOp2_data_o;
              mOp2_pbit_reg[1]<=mOp2_pbit_o;
              mOp2_brdread_reg[1]<=mOp2_brdread_o;
              
              thrreginh[1][3]<=mOp3_thread_no~^excpt_thread && except;
	      mOp3_thread_reg[1]<=mOp3_thread_no;
              mOp3_addrEven_reg[1]<=mOp3_addrEven_no;
              mOp3_addrOdd_reg[1]<=mOp3_addrOdd_no;
              mOp3_sz_reg[1]<=mOp3_sz_no;
              mOp3_st_reg[1]<=mOp3_st_no;
              mOp3_banks_reg[1]<=mOp3_banks_no;
              mOp3_bank0_reg[1]<=mOp3_bank0_no;
              mOp3_odd_reg[1]<=mOp3_odd_no;
              mOp3_addr_low_reg[1]<=mOp3_addr_low_no;
              mOp3_split_reg[1]<=mOp3_split_no;
              mOp3_register_reg[1]<=mOp3_register_no;
              mOp3_LSQ_reg[1]<=mOp3_LSQ_no;
              mOp3_II_reg[1]<=mOp3_II_no;
              mOp3_WQ_reg[1]<=mOp3_WQ_no;
              mOp3_lsflag_reg[1]<=mOp3_lsflag_no;
              mOp3_lsfwd_reg[1]<=mOp3_lsfwd_no;
              mOp3_data_reg[1]<=mOp3_data_no;
              mOp3_brdbanks_reg[1]<=mOp3_brdbanks_no;
              mOp3_pbit_reg[1]<=mOp3_pbit_no;
              mOp3_ctype_reg[1]<=mOp3_ctype_no;

              thrreginh[1][4]<=1'b0;
              mOp4_addrEven_reg[1]<=mOp4_addrEven_no;
              mOp4_addrOdd_reg[1]<=mOp4_addrOdd_no;
              mOp4_sz_reg[1]<=mOp4_sz_no;
          //    mOp4_first_reg[1]<=mOp4_first_no;
              mOp4_bank0_reg[1]<=mOp4_bank0_no;
              mOp4_odd_reg[1]<=mOp4_odd_no;
              mOp4_addr_low_reg[1]<=mOp4_addr_low_no;
              mOp4_split_reg[1]<=mOp4_split_no;
              mOp4_data_reg[1]<=mOp4_data_no;
              mOp4_bank1_reg[1]<=mOp4_bank1_no;
              mOp4_II_reg[1]<=mOp4_II_no;
              mOp4_bgn_b_reg[1]<=mOp4_bgn_b_no;
              mOp4_end_b_reg[1]<=mOp4_end_b_no;
              mOp4_pbit_reg[1]<=mOp4_pbit_no;
              mOp4_ctype_reg[1]<=mOp4_ctype_no;

              thrreginh[1][5]<=1'b0;
              mOp5_addrEven_reg[1]<=mOp5_addrEven_no;
              mOp5_addrOdd_reg[1]<=mOp5_addrOdd_no;
              mOp5_sz_reg[1]<=mOp5_sz_no;
            //  mOp5_first_reg[1]<=mOp5_first_no;
              mOp5_bank0_reg[1]<=mOp5_bank0_no;
              mOp5_odd_reg[1]<=mOp5_odd_no;
              mOp5_addr_low_reg[1]<=mOp5_addr_low_no;
              mOp5_split_reg[1]<=mOp5_split_no;
              mOp5_data_reg[1]<=mOp5_data_no;
              mOp5_bank1_reg[1]<=mOp5_bank1_no;
              mOp5_II_reg[1]<=mOp5_II_no;
              mOp5_bgn_b_reg[1]<=mOp5_bgn_b_no;
              mOp5_end_b_reg[1]<=mOp5_end_b_no;
              mOp5_pbit_reg[1]<=mOp5_pbit_no;
              mOp5_ctype_reg[1]<=mOp5_ctype_no;
              for(r=2;r<=3;r=r+1) begin
                  thrreginh[r][0]<=thrreginh[r-1][0] || (mOp0_thread_reg[r-1]~^excpt_thread && except);
	          mOp0_thread_reg[r]<=mOp0_thread_reg[r-1];
                  mOp0_addrEven_reg[r]<=mOp0_addrEven_reg[r-1];
                  mOp0_addrOdd_reg[r]<=mOp0_addrOdd_reg[r-1];
                  mOp0_sz_reg[r]<=mOp0_sz_reg[r-1];
                  mOp0_st_reg[r]<=mOp0_st_reg[r-1];
                  mOp0_banks_reg[r]<=mOp0_banks_reg[r-1];
                  mOp0_bank0_reg[r]<=mOp0_bank0_reg[r-1];
                  mOp0_odd_reg[r]<=mOp0_odd_reg[r-1];
                  mOp0_addr_low_reg[r]<=mOp0_addr_low_reg[r-1];
                  mOp0_split_reg[r]<=mOp0_split_reg[r-1];
                  mOp0_register_reg[r]<=mOp0_register_reg[r-1];
                  mOp0_LSQ_reg[r]<=mOp0_LSQ_reg[r-1];
                  mOp0_II_reg[r]<=mOp0_II_reg[r-1];
                  mOp0_WQ_reg[r]<=mOp0_WQ_reg[r-1];
                  mOp0_ctype_reg[r]<=mOp0_ctype_reg[r-1];
                  mOp0_lsflag_reg[r]<=mOp0_lsflag_reg[r-1];

                  thrreginh[r][1]<=thrreginh[r-1][1] || (mOp1_thread_reg[r-1]~^excpt_thread && except);
	          mOp1_thread_reg[r]<=mOp1_thread_reg[r-1];
                  mOp1_addrEven_reg[r]<=mOp1_addrEven_reg[r-1];
                  mOp1_addrOdd_reg[r]<=mOp1_addrOdd_reg[r-1];
                  mOp1_sz_reg[r]<=mOp1_sz_reg[r-1];
                  mOp1_st_reg[r]<=mOp1_st_reg[r-1];
                  mOp1_banks_reg[r]<=mOp1_banks_reg[r-1];
                  mOp1_bank0_reg[r]<=mOp1_bank0_reg[r-1];
                  mOp1_odd_reg[r]<=mOp1_odd_reg[r-1];
                  mOp1_addr_low_reg[r]<=mOp1_addr_low_reg[r-1];
                  mOp1_split_reg[r]<=mOp1_split_reg[r-1];
                  mOp1_register_reg[r]<=mOp1_register_reg[r-1];
                  mOp1_LSQ_reg[r]<=mOp1_LSQ_reg[r-1];
                  mOp1_II_reg[r]<=mOp1_II_reg[r-1];
                  mOp1_WQ_reg[r]<=mOp1_WQ_reg[r-1];
                  mOp1_ctype_reg[r]<=mOp1_ctype_reg[r-1];
                  mOp1_lsflag_reg[r]<=mOp1_lsflag_reg[r-1];

                  thrreginh[r][2]<=thrreginh[r-1][2] || (mOp2_thread_reg[r-1]~^excpt_thread && except);
	          mOp2_thread_reg[r]<=mOp2_thread_reg[r-1];
                  mOp2_addrEven_reg[r]<=mOp2_addrEven_reg[r-1];
                  mOp2_addrOdd_reg[r]<=mOp2_addrOdd_reg[r-1];
                  mOp2_sz_reg[r]<=mOp2_sz_reg[r-1];
                  mOp2_st_reg[r]<=mOp2_st_reg[r-1];
                  mOp2_banks_reg[r]<=mOp2_banks_reg[r-1];
                  mOp2_bank0_reg[r]<=mOp2_bank0_reg[r-1];
                  mOp2_odd_reg[r]<=mOp2_odd_reg[r-1];
                  mOp2_addr_low_reg[r]<=mOp2_addr_low_reg[r-1];
                  mOp2_split_reg[r]<=mOp2_split_reg[r-1];
                  mOp2_register_reg[r]<=mOp2_register_reg[r-1];
                  mOp2_LSQ_reg[r]<=mOp2_LSQ_reg[r-1];
                  mOp2_II_reg[r]<=mOp2_II_reg[r-1];
                  mOp2_WQ_reg[r]<=mOp2_WQ_reg[r-1];
                  mOp2_ctype_reg[r]<=mOp2_ctype_reg[r-1];
                  mOp2_lsflag_reg[r]<=mOp2_lsflag_reg[r-1];
                  mOp2_data_reg[r]<=mOp2_data_reg[r-1];
                  mOp2_pbit_reg[r]<=mOp2_pbit_reg[r-1];
                  mOp2_brdread_reg[r]<=mOp2_brdread_reg[r-1];
                  
                  thrreginh[r][3]<=thrreginh[r-1][3] || (mOp3_thread_reg[r-1]~^excpt_thread && except);
	          mOp3_thread_reg[r]<=mOp3_thread_reg[r-1];
                  mOp3_addrEven_reg[r]<=mOp3_addrEven_reg[r-1];
                  mOp3_addrOdd_reg[r]<=mOp3_addrOdd_reg[r-1];
                  mOp3_sz_reg[r]<=mOp3_sz_reg[r-1];
                  mOp3_st_reg[r]<=mOp3_st_reg[r-1];
                  mOp3_banks_reg[r]<=mOp3_banks_reg[r-1];
                  mOp3_bank0_reg[r]<=mOp3_bank0_reg[r-1];
                  mOp3_odd_reg[r]<=mOp3_odd_reg[r-1];
                  mOp3_addr_low_reg[r]<=mOp3_addr_low_reg[r-1];
                  mOp3_split_reg[r]<=mOp3_split_reg[r-1];
                  mOp3_register_reg[r]<=mOp3_register_reg[r-1];
                  mOp3_LSQ_reg[r]<=mOp3_LSQ_reg[r-1];
                  mOp3_II_reg[r]<=mOp3_II_reg[r-1];
                  mOp3_WQ_reg[r]<=mOp3_WQ_reg[r-1];
                  mOp3_lsflag_reg[r]<=mOp3_lsflag_reg[r-1];
                  mOp3_data_reg[r]<=mOp3_data_reg[r-1];
                  mOp3_lsfwd_reg[r]<=mOp3_lsfwd_reg[r-1];
                  mOp3_brdbanks_reg[r]<=mOp3_brdbanks_reg[r-1];
                  mOp3_pbit_reg[r]<=mOp3_pbit_reg[r-1];
                  mOp3_ctype_reg[r]<=mOp3_ctype_reg[r-1];

                 // thrreginh[r][4]<=thrreginh[r-1][4] || (mOp4_thread_reg[r-1]~^excpt_thread && except);
                  mOp4_addrEven_reg[r]<=mOp4_addrEven_reg[r-1];
                  mOp4_addrOdd_reg[r]<=mOp4_addrOdd_reg[r-1];
                  mOp4_sz_reg[r]<=mOp4_sz_reg[r-1];
                  mOp4_first_reg[r]<=mOp4_first_reg[r-1];
                  mOp4_bank0_reg[r]<=mOp4_bank0_reg[r-1];
                  mOp4_odd_reg[r]<=mOp4_odd_reg[r-1];
                  mOp4_addr_low_reg[r]<=mOp4_addr_low_reg[r-1];
                  mOp4_split_reg[r]<=mOp4_split_reg[r-1];
                  mOp4_data_reg[r]<=mOp4_data_reg[r-1];
                  mOp4_bank1_reg[r]<=mOp4_bank1_reg[r-1];
                  mOp4_II_reg[r]<=mOp4_II_reg[r-1];
                  mOp4_bgn_b_reg[r]<=mOp4_bgn_b_reg[r-1];
                  mOp4_end_b_reg[r]<=mOp4_end_b_reg[r-1];
                  mOp4_pbit_reg[r]<=mOp4_pbit_reg[r-1];
                  mOp4_ctype_reg[r]<=mOp4_ctype_reg[r-1];

                 // thrreginh[r][5]<=thrreginh[r-1][5] || (mOp5_thread_reg[r-1]~^excpt_thread && except);
                  mOp5_addrEven_reg[r]<=mOp5_addrEven_reg[r-1];
                  mOp5_addrOdd_reg[r]<=mOp5_addrOdd_reg[r-1];
                  mOp5_sz_reg[r]<=mOp5_sz_reg[r-1];
                  mOp5_first_reg[r]<=mOp5_first_reg[r-1];
                  mOp5_bank0_reg[r]<=mOp5_bank0_reg[r-1];
                  mOp5_odd_reg[r]<=mOp5_odd_reg[r-1];
                  mOp5_addr_low_reg[r]<=mOp5_addr_low_reg[r-1];
                  mOp5_split_reg[r]<=mOp5_split_reg[r-1];
                  mOp5_data_reg[r]<=mOp5_data_reg[r-1];
                  mOp5_bank1_reg[r]<=mOp5_bank1_reg[r-1];
                  mOp5_II_reg[r]<=mOp5_II_reg[r-1];
                  mOp5_bgn_b_reg[r]<=mOp5_bgn_b_reg[r-1];
                  mOp5_end_b_reg[r]<=mOp5_end_b_reg[r-1];
                  mOp5_pbit_reg[r]<=mOp5_pbit_reg[r-1];
                  mOp5_ctype_reg[r]<=mOp5_ctype_reg[r-1];
              end
          end
          if (rst) begin
              init<=1'b1;
              initCount<=5'd0;
          end else if (init) begin
              initCount<=initCount_next;
              if (initCount==5'h1f) init<=1'b0;
          end
    end
  
endmodule

//verilator lint_on WIDTH

//verilator lint_on PINMISSING

