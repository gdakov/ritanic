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

//main modules in file: rat

module ratV_buf(
  clk,
  rst,
  read_clkEn,
  //from here addr is retirement register
  read0_addr,read0_data,read0_retired,read0_fun,read0_dom,
  read1_addr,read1_data,read1_retired,read1_fun,read1_dom,
  read2_addr,read2_data,read2_retired,read2_fun,read2_dom,
  read3_addr,read3_data,read3_retired,read3_fun,read3_dom,
  read4_addr,read4_data,read4_retired,read4_fun,read4_dom,
  read5_addr,read5_data,read5_retired,read5_fun,read5_dom,
  read6_addr,read6_data,read6_retired,read6_fun,read6_dom,
  read7_addr,read7_data,read7_retired,read7_fun,read7_dom,
  read8_addr,read8_data,read8_retired,read8_fun,read8_dom,

  writeNew0_addr,writeNew0_data,writeNew0_fun,writeNew0_dom,writeNew0_wen,
  writeNew1_addr,writeNew1_data,writeNew1_fun,writeNew1_dom,writeNew1_wen,
  writeNew2_addr,writeNew2_data,writeNew2_fun,writeNew2_dom,writeNew2_wen,
  writeNew3_addr,writeNew3_data,writeNew3_fun,writeNew3_dom,writeNew3_wen,
  writeNew4_addr,writeNew4_data,writeNew4_fun,writeNew4_dom,writeNew4_wen,
  writeNew5_addr,writeNew5_data,writeNew5_fun,writeNew5_dom,writeNew5_wen,
  writeNew6_addr,writeNew6_data,writeNew6_fun,writeNew6_dom,writeNew6_wen,
  writeNew7_addr,writeNew7_data,writeNew7_fun,writeNew7_dom,writeNew7_wen,
  writeNew8_addr,writeNew8_data,writeNew8_fun,writeNew8_dom,writeNew8_wen,
//from here addr is free register
  writeRet0_addr,writeRet0_wen,
  writeRet1_addr,writeRet1_wen,
  writeRet2_addr,writeRet2_wen,
  writeRet3_addr,writeRet3_wen,
  writeRet4_addr,writeRet4_wen,
  writeRet5_addr,writeRet5_wen,
  writeRet6_addr,writeRet6_wen,
  writeRet7_addr,writeRet7_wen,
  writeRet8_addr,writeRet8_wen,
  writeRet0_paddr,writeRet0_dom,writeRet0_wenp,
  writeRet1_paddr,writeRet1_dom,writeRet1_wenp,
  writeRet2_paddr,writeRet2_dom,writeRet2_wenp,
  writeRet3_paddr,writeRet3_dom,writeRet3_wenp,
  writeRet4_paddr,writeRet4_dom,writeRet4_wenp,
  writeRet5_paddr,writeRet5_dom,writeRet5_wenp,
  writeRet6_paddr,writeRet6_dom,writeRet6_wenp,
  writeRet7_paddr,writeRet7_dom,writeRet7_wenp,
  writeRet8_paddr,writeRet8_dom,writeRet8_wenp,
  retireAll,retireAll_thread,
  read_thread,write_thread,ret_thread
  );

//override index with physical register number
  parameter INDEX=0;
  localparam RAT_ADDR_WIDTH=3;
  localparam ROB_ADDR_WIDTH=`reg_addr_width;
  localparam FN_WIDTH=10;
  localparam PADDR_WIDTH=6;

  input pwire clk;
  input pwire rst;

  input pwire read_clkEn;

  input pwire [RAT_ADDR_WIDTH-1:0] read0_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read0_data;
  output pwire read0_retired;
  output pwire [FN_WIDTH-1:0] read0_fun;
  output pwire [1:0] read0_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read1_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read1_data;
  output pwire read1_retired;
  output pwire [FN_WIDTH-1:0] read1_fun;
  output pwire [1:0] read1_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read2_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read2_data;
  output pwire read2_retired;
  output pwire [FN_WIDTH-1:0] read2_fun;
  output pwire [1:0] read2_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read3_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read3_data;
  output pwire read3_retired;
  output pwire [FN_WIDTH-1:0] read3_fun;
  output pwire [1:0] read3_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read4_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read4_data;
  output pwire read4_retired;
  output pwire [FN_WIDTH-1:0] read4_fun;
  output pwire [1:0] read4_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read5_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read5_data;
  output pwire read5_retired;
  output pwire [FN_WIDTH-1:0] read5_fun;
  output pwire [1:0] read5_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read6_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read6_data;
  output pwire read6_retired;
  output pwire [FN_WIDTH-1:0] read6_fun;
  output pwire [1:0] read6_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read7_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read7_data;
  output pwire read7_retired;
  output pwire [FN_WIDTH-1:0] read7_fun;
  output pwire [1:0] read7_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read8_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read8_data;
  output pwire read8_retired;
  output pwire [FN_WIDTH-1:0] read8_fun;
  output pwire [1:0] read8_dom;

  input pwire [RAT_ADDR_WIDTH-1:0] writeNew0_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew0_data;
  input pwire [FN_WIDTH-1:0] writeNew0_fun;
  input pwire [1:0] writeNew0_dom;
  input pwire writeNew0_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew1_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew1_data;
  input pwire [FN_WIDTH-1:0] writeNew1_fun;
  input pwire [1:0] writeNew1_dom;
  input pwire writeNew1_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew2_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew2_data;
  input pwire [FN_WIDTH-1:0] writeNew2_fun;
  input pwire [1:0] writeNew2_dom;
  input pwire writeNew2_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew3_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew3_data;
  input pwire [FN_WIDTH-1:0] writeNew3_fun;
  input pwire [1:0] writeNew3_dom;
  input pwire writeNew3_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew4_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew4_data;
  input pwire [FN_WIDTH-1:0] writeNew4_fun;
  input pwire [1:0] writeNew4_dom;
  input pwire writeNew4_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew5_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew5_data;
  input pwire [FN_WIDTH-1:0] writeNew5_fun;
  input pwire [1:0] writeNew5_dom;
  input pwire writeNew5_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew6_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew6_data;
  input pwire [FN_WIDTH-1:0] writeNew6_fun;
  input pwire [1:0] writeNew6_dom;
  input pwire writeNew6_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew7_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew7_data;
  input pwire [FN_WIDTH-1:0] writeNew7_fun;
  input pwire [1:0] writeNew7_dom;
  input pwire writeNew7_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew8_addr;
  input pwire [ROB_ADDR_WIDTH-1:0] writeNew8_data;
  input pwire [FN_WIDTH-1:0] writeNew8_fun;
  input pwire [1:0] writeNew8_dom;
  input pwire writeNew8_wen;

  input pwire [ROB_ADDR_WIDTH-1:0] writeRet0_addr;
  input pwire writeRet0_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet1_addr;
  input pwire writeRet1_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet2_addr;
  input pwire writeRet2_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet3_addr;
  input pwire writeRet3_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet4_addr;
  input pwire writeRet4_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet5_addr;
  input pwire writeRet5_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet6_addr;
  input pwire writeRet6_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet7_addr;
  input pwire writeRet7_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet8_addr;
  input pwire writeRet8_wen;

  input pwire [PADDR_WIDTH-1:0] writeRet0_paddr;
  input pwire [1:0] writeRet0_dom;
  input pwire writeRet0_wenp;
  input pwire [PADDR_WIDTH-1:0] writeRet1_paddr;
  input pwire [1:0] writeRet1_dom;
  input pwire writeRet1_wenp;
  input pwire [PADDR_WIDTH-1:0] writeRet2_paddr;
  input pwire [1:0] writeRet2_dom;
  input pwire writeRet2_wenp;
  input pwire [PADDR_WIDTH-1:0] writeRet3_paddr;
  input pwire [1:0] writeRet3_dom;
  input pwire writeRet3_wenp;
  input pwire [PADDR_WIDTH-1:0] writeRet4_paddr;
  input pwire [1:0] writeRet4_dom;
  input pwire writeRet4_wenp;
  input pwire [PADDR_WIDTH-1:0] writeRet5_paddr;
  input pwire [1:0] writeRet5_dom;
  input pwire writeRet5_wenp;
  input pwire [PADDR_WIDTH-1:0] writeRet6_paddr;
  input pwire [1:0] writeRet6_dom;
  input pwire writeRet6_wenp;
  input pwire [PADDR_WIDTH-1:0] writeRet7_paddr;
  input pwire [1:0] writeRet7_dom;
  input pwire writeRet7_wenp;
  input pwire [PADDR_WIDTH-1:0] writeRet8_paddr;
  input pwire [1:0] writeRet8_dom;
  input pwire writeRet8_wenp;

  input pwire retireAll;
  input pwire retireAll_thread;
  
  input pwire read_thread;
  input pwire write_thread;
  input pwire ret_thread;
  
  pwire [ROB_ADDR_WIDTH-1:0] robAddr;
  pwire retired;
  pwire [FN_WIDTH-1:0] funit;
  pwire [1:0] dom;
  pwire [1:0] domp;

  pwire [ROB_ADDR_WIDTH-1:0] robAddr_rd;
  pwire retired_rd;
  pwire [FN_WIDTH-1:0] funit_rd;
  pwire [1:0] dom_rd;
  
  pwire match_new0;  
  pwire match_new1;  
  pwire match_new2;  
  pwire match_new3;  
  pwire match_new4;  
  pwire match_new5;
  pwire match_new6;
  pwire match_new7;
  pwire match_new8;

  pwire match_new;

  pwire match_retA0;  
  pwire match_retA1;  
  pwire match_retA2;  
  pwire match_retA3;  
  pwire match_retA4;  
  pwire match_retA5;
  pwire match_retA6;
  pwire match_retA7;
  pwire match_retA8;

  pwire match_ret0;  
  pwire match_ret1;  
  pwire match_ret2;  
  pwire match_ret3;  
  pwire match_ret4;  
  pwire match_ret5;
  pwire match_ret6;
  pwire match_ret7;
  pwire match_ret8;

  pwire match_ret;

  pwire match_retp0;  
  pwire match_retp1;  
  pwire match_retp2;  
  pwire match_retp3;  
  pwire match_retp4;  
  pwire match_retp5;
  pwire match_retp6;
  pwire match_retp7;
  pwire match_retp8;

  pwire match_retp;

  pwire [ROB_ADDR_WIDTH-1:0] robAddr_d;
  pwire [ROB_ADDR_WIDTH-1:0] robAddr_ret;

  pwire [FN_WIDTH-1:0] funit_d;
  
  pwire [1:0] dom_d;
  pwire [1:0] domp_d;
  
  pwire retired_d;

  pwire match_rd0;
  pwire match_rd1;
  pwire match_rd2;
  pwire match_rd3;
  pwire match_rd4;
  pwire match_rd5;
  pwire match_rd6;
  pwire match_rd7;
  pwire match_rd8;
  
  assign match_new0=(pwh#(32)::cmpEQ(writeNew0_addr,INDEX)) & writeNew0_wen;    
  assign match_new1=(pwh#(32)::cmpEQ(writeNew1_addr,INDEX)) & writeNew1_wen;    
  assign match_new2=(pwh#(32)::cmpEQ(writeNew2_addr,INDEX)) & writeNew2_wen;    
  assign match_new3=(pwh#(32)::cmpEQ(writeNew3_addr,INDEX)) & writeNew3_wen;    
  assign match_new4=(pwh#(32)::cmpEQ(writeNew4_addr,INDEX)) & writeNew4_wen;    
  assign match_new5=(pwh#(32)::cmpEQ(writeNew5_addr,INDEX)) & writeNew5_wen;    
  assign match_new6=(pwh#(32)::cmpEQ(writeNew6_addr,INDEX)) & writeNew6_wen;    
  assign match_new7=(pwh#(32)::cmpEQ(writeNew7_addr,INDEX)) & writeNew7_wen;    
  assign match_new8=(pwh#(32)::cmpEQ(writeNew8_addr,INDEX)) & writeNew8_wen;    

  assign match_new=|{match_new0,match_new1,match_new2,match_new3,match_new4,match_new5
    ,match_new6,match_new7,match_new8};

  assign match_ret0=(~pwh#(32)::cmpEQ(writeRet0_addr,robAddr_ret)) & writeRet0_wen;    
  assign match_ret1=(~pwh#(32)::cmpEQ(writeRet1_addr,robAddr_ret)) & writeRet1_wen;    
  assign match_ret2=(~pwh#(32)::cmpEQ(writeRet2_addr,robAddr_ret)) & writeRet2_wen;    
  assign match_ret3=(~pwh#(32)::cmpEQ(writeRet3_addr,robAddr_ret)) & writeRet3_wen;    
  assign match_ret4=(~pwh#(32)::cmpEQ(writeRet4_addr,robAddr_ret)) & writeRet4_wen;    
  assign match_ret5=(~pwh#(32)::cmpEQ(writeRet5_addr,robAddr_ret)) & writeRet5_wen;    
  assign match_ret6=(~pwh#(32)::cmpEQ(writeRet6_addr,robAddr_ret)) & writeRet6_wen;    
  assign match_ret7=(~pwh#(32)::cmpEQ(writeRet7_addr,robAddr_ret)) & writeRet7_wen;    
  assign match_ret8=(~pwh#(32)::cmpEQ(writeRet8_addr,robAddr_ret)) & writeRet8_wen;
  

  assign match_ret=|{match_ret0,match_ret1,match_ret2,match_ret3,
    match_ret4,match_ret5,match_ret6,match_ret7,match_ret8};

	
  assign match_rd0=pwh#(32)::cmpEQ(read0_addr,INDEX);
  assign match_rd1=pwh#(32)::cmpEQ(read1_addr,INDEX);
  assign match_rd2=pwh#(32)::cmpEQ(read2_addr,INDEX);
  assign match_rd3=pwh#(32)::cmpEQ(read3_addr,INDEX);
  assign match_rd4=pwh#(32)::cmpEQ(read4_addr,INDEX);
  assign match_rd5=pwh#(32)::cmpEQ(read5_addr,INDEX);
  assign match_rd6=pwh#(32)::cmpEQ(read6_addr,INDEX);
  assign match_rd7=pwh#(32)::cmpEQ(read7_addr,INDEX);
  assign match_rd8=pwh#(32)::cmpEQ(read8_addr,INDEX);

  assign match_retp0=pwh#(32)::cmpEQ(writeRet0_paddr,INDEX) && writeRet0_wenp;    
  assign match_retp1=pwh#(32)::cmpEQ(writeRet1_paddr,INDEX) && writeRet1_wenp;    
  assign match_retp2=pwh#(32)::cmpEQ(writeRet2_paddr,INDEX) && writeRet2_wenp;    
  assign match_retp3=pwh#(32)::cmpEQ(writeRet3_paddr,INDEX) && writeRet3_wenp;    
  assign match_retp4=pwh#(32)::cmpEQ(writeRet4_paddr,INDEX) && writeRet4_wenp;    
  assign match_retp5=pwh#(32)::cmpEQ(writeRet5_paddr,INDEX) && writeRet5_wenp;    
  assign match_retp6=pwh#(32)::cmpEQ(writeRet6_paddr,INDEX) && writeRet6_wenp;    
  assign match_retp7=pwh#(32)::cmpEQ(writeRet7_paddr,INDEX) && writeRet7_wenp;    
  assign match_retp8=pwh#(32)::cmpEQ(writeRet8_paddr,INDEX) && writeRet8_wenp;    

  assign match_retp=|{match_retp0,match_retp1,match_retp2,match_retp3,
    match_retp4,match_retp5,match_retp6,match_retp7,match_retp8};

    
  assign robAddr_d=(match_new0 & ~rst) ? ~writeNew0_data : 'z;
  assign robAddr_d=(match_new1 & ~rst) ? ~writeNew1_data : 'z;
  assign robAddr_d=(match_new2 & ~rst) ? ~writeNew2_data : 'z;
  assign robAddr_d=(match_new3 & ~rst) ? ~writeNew3_data : 'z;
  assign robAddr_d=(match_new4 & ~rst) ? ~writeNew4_data : 'z;
  assign robAddr_d=(match_new5 & ~rst) ? ~writeNew5_data : 'z;
  assign robAddr_d=(match_new6 & ~rst) ? ~writeNew6_data : 'z;
  assign robAddr_d=(match_new7 & ~rst) ? ~writeNew7_data : 'z;
  assign robAddr_d=(match_new8 & ~rst) ? ~writeNew8_data : 'z;

  assign robAddr_d=(rst | ~match_new) ? {ROB_ADDR_WIDTH{1'b1}} : 'z;

  assign retired_d=~(match_ret & ~ret_thread & ~(match_new & read_clkEn) || rst || retireAll & ~retireAll_thread); 

  assign funit_d=(match_new0 & ~rst) ? ~writeNew0_fun : 'z;
  assign funit_d=(match_new1 & ~rst) ? ~writeNew1_fun : 'z;
  assign funit_d=(match_new2 & ~rst) ? ~writeNew2_fun : 'z;
  assign funit_d=(match_new3 & ~rst) ? ~writeNew3_fun : 'z;
  assign funit_d=(match_new4 & ~rst) ? ~writeNew4_fun : 'z;
  assign funit_d=(match_new5 & ~rst) ? ~writeNew5_fun : 'z;
  assign funit_d=(match_new6 & ~rst) ? ~writeNew6_fun : 'z;
  assign funit_d=(match_new7 & ~rst) ? ~writeNew7_fun : 'z;
  assign funit_d=(match_new8 & ~rst) ? ~writeNew8_fun : 'z;

  assign funit_d=(rst | ~match_new) ? 10'b0111111111 : 'z;

  assign dom_d=(match_new0 & ~rst) ? ~writeNew0_dom : 2'bz;
  assign dom_d=(match_new1 & ~rst) ? ~writeNew1_dom : 2'bz;
  assign dom_d=(match_new2 & ~rst) ? ~writeNew2_dom : 2'bz;
  assign dom_d=(match_new3 & ~rst) ? ~writeNew3_dom : 2'bz;
  assign dom_d=(match_new4 & ~rst) ? ~writeNew4_dom : 2'bz;
  assign dom_d=(match_new5 & ~rst) ? ~writeNew5_dom : 2'bz;
  assign dom_d=(match_new6 & ~rst) ? ~writeNew6_dom : 2'bz;
  assign dom_d=(match_new7 & ~rst) ? ~writeNew7_dom : 2'bz;
  assign dom_d=(match_new8 & ~rst) ? ~writeNew8_dom : 2'bz;

  assign dom_d=(rst | ~match_new) ? 2'b11 : 2'bz;
  
  assign domp_d=(match_retp0 && ~rst) ? ~writeRet0_dom : 2'bz;
  assign domp_d=(match_retp1 && ~rst) ? ~writeRet1_dom : 2'bz;
  assign domp_d=(match_retp2 && ~rst) ? ~writeRet2_dom : 2'bz;
  assign domp_d=(match_retp3 && ~rst) ? ~writeRet3_dom : 2'bz;
  assign domp_d=(match_retp4 && ~rst) ? ~writeRet4_dom : 2'bz;
  assign domp_d=(match_retp5 && ~rst) ? ~writeRet5_dom : 2'bz;
  assign domp_d=(match_retp6 && ~rst) ? ~writeRet6_dom : 2'bz;
  assign domp_d=(match_retp7 && ~rst) ? ~writeRet7_dom : 2'bz;
  assign domp_d=(match_retp8 && ~rst) ? ~writeRet8_dom : 2'bz;
  
  assign domp_d=(!match_retp || rst ) ? 2'b00 : 2'bz;

  assign read0_data=match_rd0 ? ~robAddr_rd : 'z;  
  assign read1_data=match_rd1 ? ~robAddr_rd : 'z;  
  assign read2_data=match_rd2 ? ~robAddr_rd : 'z;  
  assign read3_data=match_rd3 ? ~robAddr_rd : 'z;  
  assign read4_data=match_rd4 ? ~robAddr_rd : 'z;  
  assign read5_data=match_rd5 ? ~robAddr_rd : 'z;  
  assign read6_data=match_rd6 ? ~robAddr_rd : 'z;  
  assign read7_data=match_rd7 ? ~robAddr_rd : 'z;  
  assign read8_data=match_rd8 ? ~robAddr_rd : 'z;  

  assign read0_fun=match_rd0 ? ~funit_rd : 'z;  
  assign read1_fun=match_rd1 ? ~funit_rd : 'z;  
  assign read2_fun=match_rd2 ? ~funit_rd : 'z;  
  assign read3_fun=match_rd3 ? ~funit_rd : 'z;  
  assign read4_fun=match_rd4 ? ~funit_rd : 'z;  
  assign read5_fun=match_rd5 ? ~funit_rd : 'z;  
  assign read6_fun=match_rd6 ? ~funit_rd : 'z;  
  assign read7_fun=match_rd7 ? ~funit_rd : 'z;  
  assign read8_fun=match_rd8 ? ~funit_rd : 'z;  

  assign read0_dom=match_rd0 ? ~dom_rd : 'z;  
  assign read1_dom=match_rd1 ? ~dom_rd : 'z;  
  assign read2_dom=match_rd2 ? ~dom_rd : 'z;  
  assign read3_dom=match_rd3 ? ~dom_rd : 'z;  
  assign read4_dom=match_rd4 ? ~dom_rd : 'z;  
  assign read5_dom=match_rd5 ? ~dom_rd : 'z;  
  assign read6_dom=match_rd6 ? ~dom_rd : 'z;  
  assign read7_dom=match_rd7 ? ~dom_rd : 'z;  
  assign read8_dom=match_rd8 ? ~dom_rd : 'z;  

  assign read0_retired=match_rd0 ? ~retired_rd : 1'bz;  
  assign read1_retired=match_rd1 ? ~retired_rd : 1'bz;  
  assign read2_retired=match_rd2 ? ~retired_rd : 1'bz;  
  assign read3_retired=match_rd3 ? ~retired_rd : 1'bz;  
  assign read4_retired=match_rd4 ? ~retired_rd : 1'bz;  
  assign read5_retired=match_rd5 ? ~retired_rd : 1'bz;  
  assign read6_retired=match_rd6 ? ~retired_rd : 1'bz;  
  assign read7_retired=match_rd7 ? ~retired_rd : 1'bz;  
  assign read8_retired=match_rd8 ? ~retired_rd : 1'bz;
  
  assign robAddr_rd=robAddr;  
  assign funit_rd=funit;  
  assign retired_rd=retired;  
  assign dom_rd=dom;
  assign robAddr_ret=robAddr;

  always @(posedge clk)
    begin
      if (rst) begin
          robAddr<=9'h1ff;
          funit<=10'b0111111111;
          dom<=2'b11;
          domp<=2'b0;
      end else begin
          if (~write_thread & match_new) robAddr<=robAddr_d;
          if (~write_thread & match_new) funit<=funit_d;
          if (retireAll & ~retireAll_thread) dom<=domp;
          else if (~write_thread & match_new) dom<=dom_d;
          if (~ret_thread & match_retp) domp<=domp_d;
      end
      if (match_ret & ~ret_thread || match_new & ~write_thread 
	    || retireAll & ~retireAll_thread || rst) retired<=retired_d;
    end   
endmodule




module ratV_dep(
  addr,
  data,
  retired,
  funit,
  domain,
  isDep,
  clkREF12,
  rs0i0_index,rs0i1_index,rs0i2_index,
  rs1i0_index,rs1i1_index,rs1i2_index,
  rs2i0_index,rs2i1_index,rs2i2_index,
  newR0,newR1,newR2,newR3,newR4,newR5,newR6,newR7,newR8,
  newU0,newU1,newU2,newU3,newU4,newU5,newU6,newU7,newU8,
  newD0,newD1,newD2,newD3,newD4,newD5,newD6,newD7,newD8
  );


  localparam RAT_ADDR_WIDTH=6;
  localparam ROB_ADDR_WIDTH=`reg_addr_width;
  localparam FN_WIDTH=10;

  input pwire [RAT_ADDR_WIDTH-1:0] addr;
  output pwire [ROB_ADDR_WIDTH-1:0] data;
  output pwire retired;
  output pwire [FN_WIDTH-1:0] funit;
  output pwire [1:0] domain;
  output pwire isDep;
  input pwire clkREF12;
  
  input pwire [3:0] rs0i0_index;
  input pwire [3:0] rs0i1_index;
  input pwire [3:0] rs0i2_index;
  input pwire [3:0] rs1i0_index;
  input pwire [3:0] rs1i1_index;
  input pwire [3:0] rs1i2_index;
  input pwire [3:0] rs2i0_index;
  input pwire [3:0] rs2i1_index;
  input pwire [3:0] rs2i2_index;

  input pwire [ROB_ADDR_WIDTH-1:0] newR0;
  input pwire [ROB_ADDR_WIDTH-1:0] newR1;
  input pwire [ROB_ADDR_WIDTH-1:0] newR2;
  input pwire [ROB_ADDR_WIDTH-1:0] newR3;
  input pwire [ROB_ADDR_WIDTH-1:0] newR4;
  input pwire [ROB_ADDR_WIDTH-1:0] newR5;
  input pwire [ROB_ADDR_WIDTH-1:0] newR6;
  input pwire [ROB_ADDR_WIDTH-1:0] newR7;
  input pwire [ROB_ADDR_WIDTH-1:0] newR8;

  input pwire [FN_WIDTH-1:0] newU0;
  input pwire [FN_WIDTH-1:0] newU1;
  input pwire [FN_WIDTH-1:0] newU2;
  input pwire [FN_WIDTH-1:0] newU3;
  input pwire [FN_WIDTH-1:0] newU4;
  input pwire [FN_WIDTH-1:0] newU5;
  input pwire [FN_WIDTH-1:0] newU6;
  input pwire [FN_WIDTH-1:0] newU7;
  input pwire [FN_WIDTH-1:0] newU8;

  input pwire [1:0] newD0;
  input pwire [1:0] newD1;
  input pwire [1:0] newD2;
  input pwire [1:0] newD3;
  input pwire [1:0] newD4;
  input pwire [1:0] newD5;
  input pwire [1:0] newD6;
  input pwire [1:0] newD7;
  input pwire [1:0] newD8;


  assign data=(addr=={2'b11,rs0i0_index})& clkREF12 ? newR0 : 'z;
  assign data=(addr=={2'b11,rs0i1_index})& clkREF12 ? newR1 : 'z;
  assign data=(addr=={2'b11,rs0i2_index})& clkREF12 ? newR2 : 'z;
  assign data=(addr=={2'b11,rs1i0_index})& clkREF12 ? newR3 : 'z;
  assign data=(addr=={2'b11,rs1i1_index})& clkREF12 ? newR4 : 'z;
  assign data=(addr=={2'b11,rs1i2_index})& clkREF12 ? newR5 : 'z;
  assign data=(addr=={2'b11,rs2i0_index})& clkREF12 ? newR6 : 'z;
  assign data=(addr=={2'b11,rs2i1_index})& clkREF12 ? newR7 : 'z;
  assign data=(addr=={2'b11,rs2i2_index})& clkREF12 ? newR8 : 'z;

  assign retired=(pwh#(2)::cmpEQ(addr[5:4],2'b11))& clkREF12  ? 1'b0 : 1'bz;
  assign isDep=pwh#(2)::cmpEQ(addr[5:4],2'b11) && clkREF12 ? 1'b1 : 1'bz ;

  assign funit=(addr=={2'b11,rs0i0_index})& clkREF12 ? newU0 : 'z;
  assign funit=(addr=={2'b11,rs0i1_index})& clkREF12 ? newU1 : 'z;
  assign funit=(addr=={2'b11,rs0i2_index})& clkREF12 ? newU2 : 'z;
  assign funit=(addr=={2'b11,rs1i0_index})& clkREF12 ? newU3 : 'z;
  assign funit=(addr=={2'b11,rs1i1_index})& clkREF12 ? newU4 : 'z;
  assign funit=(addr=={2'b11,rs1i2_index})& clkREF12 ? newU5 : 'z;
  assign funit=(addr=={2'b11,rs2i0_index})& clkREF12 ? newU6 : 'z;
  assign funit=(addr=={2'b11,rs2i1_index})& clkREF12 ? newU7 : 'z;
  assign funit=(addr=={2'b11,rs2i2_index})& clkREF12 ? newU8 : 'z;

  assign domain=(addr=={2'b11,rs0i0_index})& clkREF12 ? newD0 : 2'bz;
  assign domain=(addr=={2'b11,rs0i1_index})& clkREF12 ? newD1 : 2'bz;
  assign domain=(addr=={2'b11,rs0i2_index})& clkREF12 ? newD2 : 2'bz;
  assign domain=(addr=={2'b11,rs1i0_index})& clkREF12 ? newD3 : 2'bz;
  assign domain=(addr=={2'b11,rs1i1_index})& clkREF12 ? newD4 : 2'bz;
  assign domain=(addr=={2'b11,rs1i2_index})& clkREF12 ? newD5 : 2'bz;
  assign domain=(addr=={2'b11,rs2i0_index})& clkREF12 ? newD6 : 2'bz;
  assign domain=(addr=={2'b11,rs2i1_index})& clkREF12 ? newD7 : 2'bz;
  assign domain=(addr=={2'b11,rs2i2_index})& clkREF12 ? newD8 : 2'bz;
  
endmodule





module ratV(
  clk,
  clkREF12,
  rst,
  read_clkEn,
  newR0,newR1,newR2,newR3,newR4,newR5,newR6,newR7,newR8,
  newU0,newU1,newU2,newU3,newU4,newU5,newU6,newU7,newU8,
  newD0,newD1,newD2,newD3,newD4,newD5,newD6,newD7,newD8,
  //from here addr is retirement register
  read0_addr,read0_data,read0_retired,read0_isDep,read0_fun,read0_dom,
  read1_addr,read1_data,read1_retired,read1_isDep,read1_fun,read1_dom,
  read2_addr,read2_data,read2_retired,read2_isDep,read2_fun,read2_dom,
  read3_addr,read3_data,read3_retired,read3_isDep,read3_fun,read3_dom,
  read4_addr,read4_data,read4_retired,read4_isDep,read4_fun,read4_dom,
  read5_addr,read5_data,read5_retired,read5_isDep,read5_fun,read5_dom,
  read6_addr,read6_data,read6_retired,read6_isDep,read6_fun,read6_dom,
  read7_addr,read7_data,read7_retired,read7_isDep,read7_fun,read7_dom,
  read8_addr,read8_data,read8_retired,read8_isDep,read8_fun,read8_dom,

  writeNew0_addr,writeNew0_wen,
  writeNew1_addr,writeNew1_wen,
  writeNew2_addr,writeNew2_wen,
  writeNew3_addr,writeNew3_wen,
  writeNew4_addr,writeNew4_wen,
  writeNew5_addr,writeNew5_wen,
  writeNew6_addr,writeNew6_wen,
  writeNew7_addr,writeNew7_wen,
  writeNew8_addr,writeNew8_wen,
//from here addr is free register
  writeRet0_addr,writeRet0_paddr,writeRet0_dom,writeRet0_wen,
  writeRet1_addr,writeRet1_paddr,writeRet1_dom,writeRet1_wen,
  writeRet2_addr,writeRet2_paddr,writeRet2_dom,writeRet2_wen,
  writeRet3_addr,writeRet3_paddr,writeRet3_dom,writeRet3_wen,
  writeRet4_addr,writeRet4_paddr,writeRet4_dom,writeRet4_wen,
  writeRet5_addr,writeRet5_paddr,writeRet5_dom,writeRet5_wen,
  writeRet6_addr,writeRet6_paddr,writeRet6_dom,writeRet6_wen,
  writeRet7_addr,writeRet7_paddr,writeRet7_dom,writeRet7_wen,
  writeRet8_addr,writeRet8_paddr,writeRet8_dom,writeRet8_wen,
  retireAll,retireAll_thread,

  rs0i0_index,rs0i1_index,rs0i2_index,
  rs1i0_index,rs1i1_index,rs1i2_index,
  rs2i0_index,rs2i1_index,rs2i2_index,
  read_thread,ret_thread
  );

  localparam RAT_ADDR_WIDTH=6;
  localparam ROB_ADDR_WIDTH=`reg_addr_width;
//  localparam BUF_COUNT=`rat_count;
  localparam FN_WIDTH=10;
  parameter [0:0] EXTRA=1'b0;

  input pwire clk;
  input pwire clkREF12;
  input pwire rst;
  input pwire read_clkEn;

  input pwire [ROB_ADDR_WIDTH-1:0] newR0;
  input pwire [ROB_ADDR_WIDTH-1:0] newR1;
  input pwire [ROB_ADDR_WIDTH-1:0] newR2;
  input pwire [ROB_ADDR_WIDTH-1:0] newR3;
  input pwire [ROB_ADDR_WIDTH-1:0] newR4;
  input pwire [ROB_ADDR_WIDTH-1:0] newR5;
  input pwire [ROB_ADDR_WIDTH-1:0] newR6;
  input pwire [ROB_ADDR_WIDTH-1:0] newR7;
  input pwire [ROB_ADDR_WIDTH-1:0] newR8;

  input pwire [FN_WIDTH-1:0] newU0;
  input pwire [FN_WIDTH-1:0] newU1;
  input pwire [FN_WIDTH-1:0] newU2;
  input pwire [FN_WIDTH-1:0] newU3;
  input pwire [FN_WIDTH-1:0] newU4;
  input pwire [FN_WIDTH-1:0] newU5;
  input pwire [FN_WIDTH-1:0] newU6;
  input pwire [FN_WIDTH-1:0] newU7;
  input pwire [FN_WIDTH-1:0] newU8;

  input pwire [1:0] newD0;
  input pwire [1:0] newD1;
  input pwire [1:0] newD2;
  input pwire [1:0] newD3;
  input pwire [1:0] newD4;
  input pwire [1:0] newD5;
  input pwire [1:0] newD6;
  input pwire [1:0] newD7;
  input pwire [1:0] newD8;

  input pwire [RAT_ADDR_WIDTH-1:0] read0_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read0_data;
  output pwire read0_retired;
  output pwire read0_isDep;
  output pwire [FN_WIDTH-1:0] read0_fun;
  output pwire [1:0] read0_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read1_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read1_data;
  output pwire read1_retired;
  output pwire read1_isDep;
  output pwire [FN_WIDTH-1:0] read1_fun;
  output pwire [1:0] read1_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read2_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read2_data;
  output pwire read2_retired;
  output pwire read2_isDep;
  output pwire [FN_WIDTH-1:0] read2_fun;
  output pwire [1:0] read2_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read3_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read3_data;
  output pwire read3_retired;
  output pwire read3_isDep;
  output pwire [FN_WIDTH-1:0] read3_fun;
  output pwire [1:0] read3_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read4_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read4_data;
  output pwire read4_retired;
  output pwire read4_isDep;
  output pwire [FN_WIDTH-1:0] read4_fun;
  output pwire [1:0] read4_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read5_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read5_data;
  output pwire read5_retired;
  output pwire read5_isDep;
  output pwire [FN_WIDTH-1:0] read5_fun;
  output pwire [1:0] read5_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read6_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read6_data;
  output pwire read6_retired;
  output pwire read6_isDep;
  output pwire [FN_WIDTH-1:0] read6_fun;
  output pwire [1:0] read6_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read7_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read7_data;
  output pwire read7_retired;
  output pwire read7_isDep;
  output pwire [FN_WIDTH-1:0] read7_fun;
  output pwire [1:0] read7_dom;
  input pwire [RAT_ADDR_WIDTH-1:0] read8_addr;
  output pwire [ROB_ADDR_WIDTH-1:0] read8_data;
  output pwire read8_retired;
  output pwire read8_isDep;
  output pwire [FN_WIDTH-1:0] read8_fun;
  output pwire [1:0] read8_dom;

  input pwire [RAT_ADDR_WIDTH-1:0] writeNew0_addr;
  input pwire writeNew0_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew1_addr;
  input pwire writeNew1_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew2_addr;
  input pwire writeNew2_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew3_addr;
  input pwire writeNew3_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew4_addr;
  input pwire writeNew4_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew5_addr;
  input pwire writeNew5_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew6_addr;
  input pwire writeNew6_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew7_addr;
  input pwire writeNew7_wen;
  input pwire [RAT_ADDR_WIDTH-1:0] writeNew8_addr;
  input pwire writeNew8_wen;

  input pwire [ROB_ADDR_WIDTH-1:0] writeRet0_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet0_paddr;
  input pwire [1:0] writeRet0_dom;
  input pwire writeRet0_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet1_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet1_paddr;
  input pwire [1:0] writeRet1_dom;
  input pwire writeRet1_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet2_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet2_paddr;
  input pwire [1:0] writeRet2_dom;
  input pwire writeRet2_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet3_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet3_paddr;
  input pwire [1:0] writeRet3_dom;
  input pwire writeRet3_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet4_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet4_paddr;
  input pwire [1:0] writeRet4_dom;
  input pwire writeRet4_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet5_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet5_paddr;
  input pwire [1:0] writeRet5_dom;
  input pwire writeRet5_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet6_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet6_paddr;
  input pwire [1:0] writeRet6_dom;
  input pwire writeRet6_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet7_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet7_paddr;
  input pwire [1:0] writeRet7_dom;
  input pwire writeRet7_wen;
  input pwire [ROB_ADDR_WIDTH-1:0] writeRet8_addr;
  input pwire [RAT_ADDR_WIDTH-1:0] writeRet8_paddr;
  input pwire [1:0] writeRet8_dom;
  input pwire writeRet8_wen;

  input pwire retireAll;
  input pwire retireAll_thread;

  input pwire [3:0] rs0i0_index;
  input pwire [3:0] rs0i1_index;
  input pwire [3:0] rs0i2_index;
  input pwire [3:0] rs1i0_index;
  input pwire [3:0] rs1i1_index;
  input pwire [3:0] rs1i2_index;
  input pwire [3:0] rs2i0_index;
  input pwire [3:0] rs2i1_index;
  input pwire [3:0] rs2i2_index;
  input pwire read_thread;
  input pwire ret_thread;

  pwire [RAT_ADDR_WIDTH-1:0] read_addr_reg[8:0];



  genvar i,k,l;


  pwire [8:0][ROB_ADDR_WIDTH-1:0] read_data;
  pwire [8:0]read_retired;
  pwire [8:0]read_isDep;
  pwire [8:0][FN_WIDTH-1:0] read_fun;
  pwire [8:0][1:0] read_dom;

  pwire read_thread_reg;
  
  assign read0_data=read_data[0];
  assign read1_data=read_data[1];
  assign read2_data=read_data[2];
  assign read3_data=read_data[3];
  assign read4_data=read_data[4];
  assign read5_data=read_data[5];
  assign read6_data=read_data[6];
  assign read7_data=read_data[7];
  assign read8_data=read_data[8];

  assign read0_retired=read_retired[0];
  assign read1_retired=read_retired[1];
  assign read2_retired=read_retired[2];
  assign read3_retired=read_retired[3];
  assign read4_retired=read_retired[4];
  assign read5_retired=read_retired[5];
  assign read6_retired=read_retired[6];
  assign read7_retired=read_retired[7];
  assign read8_retired=read_retired[8];

  assign read0_isDep=read_isDep[0];
  assign read1_isDep=read_isDep[1];
  assign read2_isDep=read_isDep[2];
  assign read3_isDep=read_isDep[3];
  assign read4_isDep=read_isDep[4];
  assign read5_isDep=read_isDep[5];
  assign read6_isDep=read_isDep[6];
  assign read7_isDep=read_isDep[7];
  assign read8_isDep=read_isDep[8];

  assign read0_fun=read_fun[0];
  assign read1_fun=read_fun[1];
  assign read2_fun=read_fun[2];
  assign read3_fun=read_fun[3];
  assign read4_fun=read_fun[4];
  assign read5_fun=read_fun[5];
  assign read6_fun=read_fun[6];
  assign read7_fun=read_fun[7];
  assign read8_fun=read_fun[8];

  assign read0_dom=read_dom[0];
  assign read1_dom=read_dom[1];
  assign read2_dom=read_dom[2];
  assign read3_dom=read_dom[3];
  assign read4_dom=read_dom[4];
  assign read5_dom=read_dom[5];
  assign read6_dom=read_dom[6];
  assign read7_dom=read_dom[7];
  assign read8_dom=read_dom[8];

  generate
    for (l=0;l<5;l=l+1) begin : tile_gen
        pwire [8:0] [ROB_ADDR_WIDTH-1:0] read_dataA;
        pwire [8:0] read_retiredA;
        pwire [8:0][FN_WIDTH-1:0] read_funA;
        pwire [8:0][1:0] read_domA;
    for (i=0;i<8;i=i+1) begin : buffers
        ratV_buf #(i) buf_mod(
          clk,
          rst,
          read_clkEn,

          read_addr_reg[0][2:0],read_dataA[0],read_retiredA[0],read_funA[0],read_domA[0],
          read_addr_reg[1][2:0],read_dataA[1],read_retiredA[1],read_funA[1],read_domA[1],
          read_addr_reg[2][2:0],read_dataA[2],read_retiredA[2],read_funA[2],read_domA[2],
          read_addr_reg[3][2:0],read_dataA[3],read_retiredA[3],read_funA[3],read_domA[3],
          read_addr_reg[4][2:0],read_dataA[4],read_retiredA[4],read_funA[4],read_domA[4],
          read_addr_reg[5][2:0],read_dataA[5],read_retiredA[5],read_funA[5],read_domA[5],
          read_addr_reg[6][2:0],read_dataA[6],read_retiredA[6],read_funA[6],read_domA[6],
          read_addr_reg[7][2:0],read_dataA[7],read_retiredA[7],read_funA[7],read_domA[7],
          read_addr_reg[8][2:0],read_dataA[8],read_retiredA[8],read_funA[8],read_domA[8],

          writeNew0_addr[2:0],newR0,newU0,newD0,writeNew0_wen && writeNew0_addr[4:3]==l && read_clkEn,
          writeNew1_addr[2:0],newR1,newU1,newD1,writeNew1_wen && writeNew1_addr[4:3]==l && read_clkEn,
          writeNew2_addr[2:0],newR2,newU2,newD2,writeNew2_wen && writeNew2_addr[4:3]==l && read_clkEn,
          writeNew3_addr[2:0],newR3,newU3,newD3,writeNew3_wen && writeNew3_addr[4:3]==l && read_clkEn,
          writeNew4_addr[2:0],newR4,newU4,newD4,writeNew4_wen && writeNew4_addr[4:3]==l && read_clkEn,
          writeNew5_addr[2:0],newR5,newU5,newD5,writeNew5_wen && writeNew5_addr[4:3]==l && read_clkEn,
          writeNew6_addr[2:0],newR6,newU6,newD6,writeNew6_wen && writeNew6_addr[4:3]==l && read_clkEn,
          writeNew7_addr[2:0],newR7,newU7,newD7,writeNew7_wen && writeNew7_addr[4:3]==l && read_clkEn,
          writeNew8_addr[2:0],newR8,newU8,newD8,writeNew8_wen && writeNew8_addr[4:3]==l && read_clkEn,

          writeRet0_addr,writeRet0_wen,
          writeRet1_addr,writeRet1_wen,
          writeRet2_addr,writeRet2_wen,
          writeRet3_addr,writeRet3_wen,
          writeRet4_addr,writeRet4_wen,
          writeRet5_addr,writeRet5_wen,
          writeRet6_addr,writeRet6_wen,
          writeRet7_addr,writeRet7_wen,
          writeRet8_addr,writeRet8_wen,
          writeRet0_paddr,writeRet0_dom,writeRet0_wen,
          writeRet1_paddr,writeRet1_dom,writeRet1_wen,
          writeRet2_paddr,writeRet2_dom,writeRet2_wen,
          writeRet3_paddr,writeRet3_dom,writeRet3_wen,
          writeRet4_paddr,writeRet4_dom,writeRet4_wen,
          writeRet5_paddr,writeRet5_dom,writeRet5_wen,
          writeRet6_paddr,writeRet6_dom,writeRet6_wen,
          writeRet7_paddr,writeRet7_dom,writeRet7_wen,
          writeRet8_paddr,writeRet8_dom,writeRet8_wen,
          retireAll,retireAll_thread,
	  read_thread_reg,
	  read_thread_reg,
	  ret_thread
        );
    end
        assign read_data[0]=(read_addr_reg[0][5:3]==l)& clkREF12  ? read_dataA[0] : 'z;
        assign read_data[1]=(read_addr_reg[1][5:3]==l) & clkREF12 ? read_dataA[1] : 'z;
        assign read_data[2]=(read_addr_reg[2][5:3]==l) & clkREF12 ? read_dataA[2] : 'z;
        assign read_data[3]=(read_addr_reg[3][5:3]==l) & clkREF12 ? read_dataA[3] : 'z;
        assign read_data[4]=(read_addr_reg[4][5:3]==l) & clkREF12 ? read_dataA[4] : 'z;
        assign read_data[5]=(read_addr_reg[5][5:3]==l) & clkREF12 ? read_dataA[5] : 'z;
        assign read_data[6]=(read_addr_reg[6][5:3]==l) & clkREF12 ? read_dataA[6] : 'z;
        assign read_data[7]=(read_addr_reg[7][5:3]==l) & clkREF12 ? read_dataA[7] : 'z;
        assign read_data[8]=(read_addr_reg[8][5:3]==l) & clkREF12 ? read_dataA[8] : 'z;

        assign read_retired[0]=(read_addr_reg[0][5:3]==l) & clkREF12 ? read_retiredA[0] : 1'BZ;
        assign read_retired[1]=(read_addr_reg[1][5:3]==l) & clkREF12 ? read_retiredA[1] : 1'BZ;
        assign read_retired[2]=(read_addr_reg[2][5:3]==l) & clkREF12 ? read_retiredA[2] : 1'BZ;
        assign read_retired[3]=(read_addr_reg[3][5:3]==l) & clkREF12 ? read_retiredA[3] : 1'BZ;
        assign read_retired[4]=(read_addr_reg[4][5:3]==l) & clkREF12 ? read_retiredA[4] : 1'BZ;
        assign read_retired[5]=(read_addr_reg[5][5:3]==l) & clkREF12 ? read_retiredA[5] : 1'BZ;
        assign read_retired[6]=(read_addr_reg[6][5:3]==l) & clkREF12 ? read_retiredA[6] : 1'BZ;
        assign read_retired[7]=(read_addr_reg[7][5:3]==l) & clkREF12 ? read_retiredA[7] : 1'BZ;
        assign read_retired[8]=(read_addr_reg[8][5:3]==l) & clkREF12 ? read_retiredA[8] : 1'BZ;

        assign read_fun[0]=(read_addr_reg[0][5:3]==l) & clkREF12 ? read_funA[0] : 'z;
        assign read_fun[1]=(read_addr_reg[1][5:3]==l) & clkREF12 ? read_funA[1] : 'z;
        assign read_fun[2]=(read_addr_reg[2][5:3]==l) & clkREF12 ? read_funA[2] : 'z;
        assign read_fun[3]=(read_addr_reg[3][5:3]==l) & clkREF12 ? read_funA[3] : 'z;
        assign read_fun[4]=(read_addr_reg[4][5:3]==l) & clkREF12 ? read_funA[4] : 'z;
        assign read_fun[5]=(read_addr_reg[5][5:3]==l)& clkREF12  ? read_funA[5] : 'z;
        assign read_fun[6]=(read_addr_reg[6][5:3]==l)& clkREF12  ? read_funA[6] : 'z;
        assign read_fun[7]=(read_addr_reg[7][5:3]==l)& clkREF12  ? read_funA[7] : 'z;
        assign read_fun[8]=(read_addr_reg[8][5:3]==l)& clkREF12  ? read_funA[8] : 'z;

        assign read_dom[0]=(read_addr_reg[0][5:3]==l) & clkREF12 ? read_domA[0] : 'z;
        assign read_dom[1]=(read_addr_reg[1][5:3]==l) & clkREF12 ? read_domA[1] : 'z;
        assign read_dom[2]=(read_addr_reg[2][5:3]==l) & clkREF12 ? read_domA[2] : 'z;
        assign read_dom[3]=(read_addr_reg[3][5:3]==l) & clkREF12 ? read_domA[3] : 'z;
        assign read_dom[4]=(read_addr_reg[4][5:3]==l) & clkREF12 ? read_domA[4] : 'z;
        assign read_dom[5]=(read_addr_reg[5][5:3]==l) & clkREF12 ? read_domA[5] : 'z;
        assign read_dom[6]=(read_addr_reg[6][5:3]==l)& clkREF12  ? read_domA[6] : 'z;
        assign read_dom[7]=(read_addr_reg[7][5:3]==l)& clkREF12  ? read_domA[7] : 'z;
        assign read_dom[8]=(read_addr_reg[8][5:3]==l)& clkREF12  ? read_domA[8] : 'z;
        
    end
    for (k=0;k<=8;k=k+1)
      begin : deps
        ratV_dep dep_mod(
          read_addr_reg[k],
          read_data[k],
          read_retired[k],
          read_fun[k],
          read_dom[k],
          read_isDep[k],
          clkREF12,
          rs0i0_index,rs0i1_index,rs0i2_index,
          rs1i0_index,rs1i1_index,rs1i2_index,
          rs2i0_index,rs2i1_index,rs2i2_index,
          newR0,newR1,newR2,newR3,newR4,newR5,newR6,newR7,newR8,
          newU0,newU1,newU2,newU3,newU4,newU5,newU6,newU7,newU8,
          newD0,newD1,newD2,newD3,newD4,newD5,newD6,newD7,newD8
          );
      end

  endgenerate



  always @(posedge clk)
    begin
      if (rst)
        begin
          read_addr_reg[0]<={RAT_ADDR_WIDTH{1'b0}};
          read_addr_reg[1]<={RAT_ADDR_WIDTH{1'b0}};
          read_addr_reg[2]<={RAT_ADDR_WIDTH{1'b0}};
          read_addr_reg[3]<={RAT_ADDR_WIDTH{1'b0}};
          read_addr_reg[4]<={RAT_ADDR_WIDTH{1'b0}};
          read_addr_reg[5]<={RAT_ADDR_WIDTH{1'b0}};
          read_addr_reg[6]<={RAT_ADDR_WIDTH{1'b0}};
          read_addr_reg[7]<={RAT_ADDR_WIDTH{1'b0}};
          read_addr_reg[8]<={RAT_ADDR_WIDTH{1'b0}};
		  
	  read_thread_reg<=1'b0;
        end
      else if (read_clkEn)
        begin
          read_addr_reg[0]<=read0_addr;
          read_addr_reg[1]<=read1_addr;
          read_addr_reg[2]<=read2_addr;
          read_addr_reg[3]<=read3_addr;
          read_addr_reg[4]<=read4_addr;
          read_addr_reg[5]<=read5_addr;
          read_addr_reg[6]<=read6_addr;
          read_addr_reg[7]<=read7_addr;
          read_addr_reg[8]<=read8_addr;
		  
	  read_thread_reg<=read_thread;
        end
    end //always

endmodule


