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
//disambiguate-align module for memory addresses; also feeds data to the memory retire unit
module lsq_req_ram(
  clk,
  rst,

  read_addr,read_data,read_clkEn,


  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen,
  write4_addr,write4_data,write4_wen,
  write5_addr,write5_data,write5_wen,
  write6_addr,write6_wen
  );

  parameter DATA_WIDTH=`lsaddr_width+1;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;
  
  input clk;
  input rst;


  input [ADDR_WIDTH-1:0] read_addr;
  output reg [DATA_WIDTH-1:0] read_data;
  input read_clkEn;
  


  input [ADDR_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;

  input [ADDR_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;

  input [ADDR_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input write2_wen;

  input [ADDR_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input write3_wen;
  
  input [ADDR_WIDTH-1:0] write4_addr;
  input [DATA_WIDTH-1:0] write4_data;
  input write4_wen;

  input [ADDR_WIDTH-1:0] write5_addr;
  input [DATA_WIDTH-1:0] write5_data;
  input write5_wen;

  input [ADDR_WIDTH-1:0] write6_addr;
  input write6_wen;


  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];

  reg [ADDR_WIDTH-1:0] read_addr_reg;

 // assign read_data=ram[read_addr_reg];


  always @(negedge clk)
    begin
      if (rst)
        begin
 //         read_addr_reg<={ADDR_WIDTH{1'b0}};
        end
      else
      begin
 //       if (read_clkEn)
 //           read_addr_reg<=read_addr;
      end
      
      if (rst) begin
	  read_data<=0;
      end else begin
	  read_data<=ram[read_addr];
      end

      if (write0_wen) ram[write0_addr]<=write0_data;
      if (write1_wen) ram[write1_addr]<=write1_data;
      if (write2_wen) ram[write2_addr]<=write2_data;
      if (write3_wen) ram[write3_addr]<=write3_data;
      if (write4_wen) ram[write4_addr]<=write4_data;
      if (write5_wen) ram[write5_addr]<=write5_data;
      if (write6_wen) ram[write6_addr]<='0;
      
    end      
    
endmodule

module lsq_req_block(
  clk,
  rst,

  read_clkEn,
  read_addr,
  read0_data,
  read1_data,
  read2_data,
  read3_data,
  read4_data,
  read5_data,


  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen,
  write4_addr,write4_data,write4_wen,
  write5_addr,write5_data,write5_wen,
  write6_addr,write6_wen
  );

  parameter DATA_WIDTH=`lsaddr_width+1;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;
  localparam ADDR2_WIDTH=9;
  
  input clk;
  input rst;

  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  
  output [DATA_WIDTH-1:0]  read0_data;
  output [DATA_WIDTH-1:0]  read1_data;
  output [DATA_WIDTH-1:0]  read2_data;
  output [DATA_WIDTH-1:0]  read3_data;
  output [DATA_WIDTH-1:0]  read4_data;
  output [DATA_WIDTH-1:0]  read5_data;
  

  input [ADDR2_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;

  input [ADDR2_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;

  input [ADDR2_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input write2_wen;

  input [ADDR2_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input write3_wen;
  
  input [ADDR2_WIDTH-1:0] write4_addr;
  input [DATA_WIDTH-1:0] write4_data;
  input write4_wen;

  input [ADDR2_WIDTH-1:0] write5_addr;
  input [DATA_WIDTH-1:0] write5_data;
  input write5_wen;

  input [ADDR_WIDTH-1:0] write6_addr;
  input write6_wen;

  wire [DATA_WIDTH-1:0]  read_data[5:0];
  
  
  assign read0_data=read_data[0];
  assign read1_data=read_data[1];
  assign read2_data=read_data[2];
  assign read3_data=read_data[3];
  assign read4_data=read_data[4];
  assign read5_data=read_data[5];

  
  generate
      genvar k;
      for(k=0;k<6;k=k+1) begin : rams_gen
          lsq_req_ram #(DATA_WIDTH) RAM_MOD(
          clk,
          rst,

          read_addr,read_data[k],read_clkEn,

          write0_addr[8:3],write0_data,write0_wen && write0_addr[2:0]==k,
          write1_addr[8:3],write1_data,write1_wen && write1_addr[2:0]==k,
          write2_addr[8:3],write2_data,write2_wen && write2_addr[2:0]==k,
          write3_addr[8:3],write3_data,write3_wen && write3_addr[2:0]==k,
          write4_addr[8:3],write4_data,write4_wen && write4_addr[2:0]==k,
          write5_addr[8:3],write5_data,write5_wen && write5_addr[2:0]==k,
          write6_addr,write6_wen
          );
      end
  endgenerate


endmodule


module lsq_ex_ram(
  clk,
  rst,

  read_addr,read_data,read_clkEn,


  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen,
  write4_addr,write4_data,write4_wen,
  write5_addr,write5_data,write5_wen,
  write6_addr,write6_wen
  );

  parameter DATA_WIDTH=`lsqxcept_width+1;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;
  
  input clk;
  input rst;


  input [ADDR_WIDTH-1:0] read_addr;
  output [DATA_WIDTH-1:0] read_data;
  input read_clkEn;
  


  input [ADDR_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;

  input [ADDR_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;

  input [ADDR_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input write2_wen;

  input [ADDR_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input write3_wen;
  
  input [ADDR_WIDTH-1:0] write4_addr;
  input [DATA_WIDTH-1:0] write4_data;
  input write4_wen;

  input [ADDR_WIDTH-1:0] write5_addr;
  input [DATA_WIDTH-1:0] write5_data;
  input write5_wen;

  input [ADDR_WIDTH-1:0] write6_addr;
  input write6_wen;


  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];

  reg [ADDR_WIDTH-1:0] read_addr_reg;

  assign read_data=ram[read_addr_reg];


  always @(posedge clk)
    begin
      if (rst)
        begin
          read_addr_reg<={ADDR_WIDTH{1'b0}};
        end
      else
      begin
        if (read_clkEn)
            read_addr_reg<=read_addr;
      end
      

      if (write0_wen) ram[write0_addr]<=write0_data;
      if (write1_wen) ram[write1_addr]<=write1_data;
      if (write2_wen) ram[write2_addr]<=write2_data;
      if (write3_wen) ram[write3_addr]<=write3_data;
      if (write4_wen) ram[write4_addr]<=write4_data;
      if (write5_wen) ram[write5_addr]<=write5_data;
      if (write6_wen) ram[write6_addr]<='0;
    end      
    
endmodule

module lsq_ex_block(
  clk,
  rst,

  read_clkEn,
  read_addr,
  read0_data,
  read1_data,
  read2_data,
  read3_data,
  read4_data,
  read5_data,


  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen,
  write4_addr,write4_data,write4_wen,
  write5_addr,write5_data,write5_wen,
  write6_addr,write6_wen
  );

  parameter DATA_WIDTH=`lsqxcept_width+1;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;
  localparam ADDR2_WIDTH=9;
  
  input clk;
  input rst;

  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  
  output [DATA_WIDTH-1:0]  read0_data;
  output [DATA_WIDTH-1:0]  read1_data;
  output [DATA_WIDTH-1:0]  read2_data;
  output [DATA_WIDTH-1:0]  read3_data;
  output [DATA_WIDTH-1:0]  read4_data;
  output [DATA_WIDTH-1:0]  read5_data;
  

  input [ADDR2_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;

  input [ADDR2_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;

  input [ADDR2_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input write2_wen;

  input [ADDR2_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input write3_wen;
  
  input [ADDR2_WIDTH-1:0] write4_addr;
  input [DATA_WIDTH-1:0] write4_data;
  input write4_wen;

  input [ADDR2_WIDTH-1:0] write5_addr;
  input [DATA_WIDTH-1:0] write5_data;
  input write5_wen;

  input [ADDR_WIDTH-1:0] write6_addr;
  input [DATA_WIDTH-1:0] write6_data;
  input write6_wen;

  wire [DATA_WIDTH-1:0]  read_data[5:0];
  
  
  assign read0_data=read_data[0];
  assign read1_data=read_data[1];
  assign read2_data=read_data[2];
  assign read3_data=read_data[3];
  assign read4_data=read_data[4];
  assign read5_data=read_data[5];

  
  generate
      genvar k;
      for(k=0;k<6;k=k+1) begin : rams_gen
          lsq_ex_ram #(DATA_WIDTH) RAM_MOD(
          clk,
          rst,

          read_addr,read_data[k],read_clkEn,

          write0_addr[8:3],write0_data,write0_wen && write0_addr[2:0]==k,
          write1_addr[8:3],write1_data,write1_wen && write1_addr[2:0]==k,
          write2_addr[8:3],write2_data,write2_wen && write2_addr[2:0]==k,
          write3_addr[8:3],write3_data,write3_wen && write3_addr[2:0]==k,
          write4_addr[8:3],write4_data,write4_wen && write4_addr[2:0]==k,
          write5_addr[8:3],write5_data,write5_wen && write5_addr[2:0]==k,
          write6_addr,write6_wen
          );
      end
  endgenerate


endmodule



module lsq_shared_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=`lsqshare_width;
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
  //reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr];

  always @(posedge clk)
    begin
      //if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      //else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module lsq_sharedB_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=`lsqshare_width;
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

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule



module lsq_pend_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr0,
  write_data0,
  write_wen0,
  write_addr1,
  write_wen1
  );

  localparam DATA_WIDTH=`lsqpend_width;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;

  input clk;
  input rst;
  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  output [DATA_WIDTH-1:0] read_data;
  input [ADDR_WIDTH-1:0] write_addr0;
  input [DATA_WIDTH-1:0] write_data0;
  input write_wen0;
  input [ADDR_WIDTH-1:0] write_addr1;
  input write_wen1;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen0) ram[write_addr0]<=write_data0;
      if (write_wen1) ram[write_addr1]<='0;
    end

endmodule

module lsq_req(
  clk,
  rst,
  
  stall,
  doStall,
  doRsPause,

  except,
  except_thread,

  aStall,
  readA_clkEn,
  readA_rdy,
  readA_rdyP,
  readA_thr,
  read0A_data,read0A_enOut,
  read1A_data,read1A_enOut,
  read2A_data,read2A_enOut,
  read3A_data,read3A_enOut,
  read4A_data,read4A_enOut,
  read5A_data,read5A_enOut,

  read0A_DATA,read0A_DATAU,read0A_dEn,
  read1A_DATA,read1A_DATAU,read1A_dEn,
  read2A_DATA,read2A_DATAU,read2A_dEn,
  read3A_DATA,read3A_DATAU,read3A_dEn,
  read4A_DATA,read4A_DATAU,read4A_dEn,
  read5A_DATA,read5A_DATAU,read5A_dEn,
  
  readA_conflIn_l,
  readA_conflInMSI,

  read_data_shr,
  write_thread_shr,
  write_data_shr,
  write_wen_shr,
  write_addr_shr,

  read0B_xdata,read0B_enOut,
  read1B_xdata,read1B_enOut,
  read2B_xdata,read2B_enOut,
  read3B_xdata,read3B_enOut,
  read4B_xdata,read4B_enOut,
  read5B_xdata,read5B_enOut,
  read_data_shrB,
  readB_ldconfl,readB_smpconfl,
  readB_rdy_en,readB_clkEn,

  //loads 0-3, xdata +2 clocks
  write0_addr,write0_data,write0_xdata,write0_thr,write0_wen,
  write1_addr,write1_data,write1_xdata,write1_thr,write1_wen,
  write2_addr,write2_data,write2_xdata,write2_thr,write2_wen,
  write3_addr,write3_data,write3_xdata,write3_thr,write3_wen,
  //stores 0-1
  write4_addr,write4_data,write4_xdata,write4_thr,write4_wen,
  write5_addr,write5_data,write5_xdata,write5_thr,write5_wen,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  FU0Data,FU1Data,FU2Data,FU3Data,
  FU0DataU,FU1DataU,FU2DataU,FU3DataU,
  smpc0,smpc1,smpc2,smpc3,
  rsEn0,rsEn1,rsEn2,rsEn3
  );

  localparam DATA_WIDTH=`lsaddr_width;
  localparam XDATA_WIDTH=`lsqxcept_width;
  localparam YDATA_WIDTH=`lsqpend_width;
  localparam SDATA_WIDTH=`lsqshare_width;
  localparam ADDR_WIDTH=5;
//  localparam ADDR1_COUNT=16;
  localparam ADDR2_WIDTH=9;
  localparam ADDR_COUNT=32;
  
  input clk;
  input rst;

  input stall;
  output doStall;
  output [1:0] doRsPause;

  input except;
  input except_thread;

  input aStall,readA_clkEn;
  output readA_rdy,readA_rdyP,readA_thr;
  
  output [DATA_WIDTH-1:0]  read0A_data;
  output read0A_enOut;
  output [DATA_WIDTH-1:0]  read1A_data;
  output read1A_enOut;
  output [DATA_WIDTH-1:0]  read2A_data;
  output read2A_enOut;
  output [DATA_WIDTH-1:0]  read3A_data;
  output read3A_enOut;
  output [DATA_WIDTH-1:0]  read4A_data;
  output read4A_enOut;
  output [DATA_WIDTH-1:0]  read5A_data;
  output read5A_enOut;

  output [135:0] read0A_DATA;
  output [127:0] read0A_DATAU;
  output [1:0]   read0A_dEn;
  output [135:0] read1A_DATA;
  output [127:0] read1A_DATAU;
  output [1:0]   read1A_dEn;
  output [135:0] read2A_DATA;
  output [127:0] read2A_DATAU;
  output [1:0]   read2A_dEn;
  output [135:0] read3A_DATA;
  output [127:0] read3A_DATAU;
  output [1:0]   read3A_dEn;
  output [135:0] read4A_DATA;
  output [127:0] read4A_DATAU;
  output [1:0]   read4A_dEn;
  output [135:0] read5A_DATA;
  output [127:0] read5A_DATAU;
  output [1:0]   read5A_dEn;

  input [5:0] readA_conflIn_l;
  input [5:0] readA_conflInMSI;

  output [SDATA_WIDTH-1:0] read_data_shr;
  input write_thread_shr;
  input  [SDATA_WIDTH-1:0] write_data_shr;
  input write_wen_shr;
  output reg [ADDR_WIDTH:0] write_addr_shr;

  output [XDATA_WIDTH-1:0]  read0B_xdata;
  output read0B_enOut;
  output [XDATA_WIDTH-1:0]  read1B_xdata;
  output read1B_enOut;
  output [XDATA_WIDTH-1:0]  read2B_xdata;
  output read2B_enOut;
  output [XDATA_WIDTH-1:0]  read3B_xdata;
  output read3B_enOut;
  output [XDATA_WIDTH-1:0]  read4B_xdata;
  output read4B_enOut;
  output [XDATA_WIDTH-1:0]  read5B_xdata;
  output read5B_enOut;
  output [SDATA_WIDTH-1:0] read_data_shrB;
  output [5:0] readB_ldconfl;
  output [5:0] readB_smpconfl;
  output readB_rdy_en;
  input readB_clkEn;

  input [ADDR2_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input [XDATA_WIDTH-3:0] write0_xdata;
  input write0_thr;
  input write0_wen;

  input [ADDR2_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input [XDATA_WIDTH-3:0] write1_xdata;
  input write1_thr;
  input write1_wen;

  input [ADDR2_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input [XDATA_WIDTH-3:0] write2_xdata;
  input write2_thr;
  input write2_wen;

  input [ADDR2_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input [XDATA_WIDTH-3:0] write3_xdata;
  input write3_thr;
  input write3_wen;
  
  input [ADDR2_WIDTH-1:0] write4_addr;
  input [DATA_WIDTH-1:0] write4_data;
  input [XDATA_WIDTH-3:0] write4_xdata;
  input write4_thr;
  input write4_wen;

  input [ADDR2_WIDTH-1:0] write5_addr;
  input [DATA_WIDTH-1:0] write5_data;
  input [XDATA_WIDTH-3:0] write5_xdata;
  input write5_thr;
  input write5_wen;
  
  input FU0Hit,FU1Hit,FU2Hit,FU3Hit;
  input [135:0] FU0Data;
  input [135:0] FU1Data;
  input [135:0] FU2Data;
  input [135:0] FU3Data;
  input smpc0,smpc1,smpc2,smpc3;
  input rsEn0,rsEn1,rsEn2,rsEn3;
  
  reg [2*ADDR_COUNT-1:0]  validA;
  reg [2*ADDR_COUNT-1:0] validB;
  reg [2*ADDR_COUNT-1:0]  validA_next;
  reg [2*ADDR_COUNT-1:0] validB_next;
  reg [2*ADDR_COUNT-1:0]  validA_reg;
  reg [2*ADDR_COUNT-1:0]  validA_next_reg;

  reg [2*ADDR_COUNT-1:0]  threadA;
  reg [2*ADDR_COUNT-1:0] threadB;
  reg [2*ADDR_COUNT-1:0]  threadA_next;
  reg [2*ADDR_COUNT-1:0] threadB_next;
 
  reg smpc0_reg,smpc1_reg,smpc2_reg,smpc3_reg;
  reg smpc0_reg2,smpc1_reg2,smpc2_reg2,smpc3_reg2;

  reg [ADDR_WIDTH:0] readA_addr;
  reg [ADDR_WIDTH:0] readB_addr;
  reg [ADDR_WIDTH:0] readA_addr_reg;
  wire [2*ADDR_COUNT-1:0] firstB;
  reg [2*ADDR_COUNT-1:0] curB;
  wire foundB;
  wire [2*ADDR_COUNT-1:0] firstBN;
  wire foundBN;
  wire [ADDR_WIDTH:0] readB_addr_d;
  reg onSameValidB;
  wire [2*ADDR_COUNT-1:0] firstA;
  reg [2*ADDR_COUNT-1:0] curA;
  wire foundA;
  wire [2*ADDR_COUNT-1:0] firstAN;
  wire foundAN;
  wire [ADDR_WIDTH:0] readA_addr_d;
  reg onSameValidA;
  
  wire [SDATA_WIDTH-1:0] read_data_shrB_ram;
  wire [SDATA_WIDTH-1:0] read_data_shr_ram;

  wire [2:0] write4_aux;
  wire [2:0] write5_aux;
  
  reg [ADDR2_WIDTH-1:0] write0_addr_reg;
  reg [ADDR2_WIDTH-1:0] write1_addr_reg;
  reg [ADDR2_WIDTH-1:0] write2_addr_reg;
  reg [ADDR2_WIDTH-1:0] write3_addr_reg;
  reg [ADDR2_WIDTH-1:0] write0_addr_reg2;
  reg [ADDR2_WIDTH-1:0] write1_addr_reg2;
  reg [ADDR2_WIDTH-1:0] write2_addr_reg2;
  reg [ADDR2_WIDTH-1:0] write3_addr_reg2;
  reg [XDATA_WIDTH-3:0] write0_xdata_reg;
  reg [XDATA_WIDTH-3:0] write1_xdata_reg;
  reg [XDATA_WIDTH-3:0] write2_xdata_reg;
  reg [XDATA_WIDTH-3:0] write3_xdata_reg;
  reg [XDATA_WIDTH-3:0] write0_xdata_reg2;
  reg [XDATA_WIDTH-3:0] write1_xdata_reg2;
  reg [XDATA_WIDTH-3:0] write2_xdata_reg2;
  reg [XDATA_WIDTH-3:0] write3_xdata_reg2;

  reg write0_thr_reg;
  reg write1_thr_reg;
  reg write2_thr_reg;
  reg write3_thr_reg;
  reg write0_thr_reg2;
  reg write1_thr_reg2;
  reg write2_thr_reg2;
  reg write3_thr_reg2;

  reg write0_wen_reg;
  reg write1_wen_reg;
  reg write2_wen_reg;
  reg write3_wen_reg;
  reg write0_wen_reg2;
  reg write1_wen_reg2;
  reg write2_wen_reg2;
  reg write3_wen_reg2;
  
  reg [ADDR2_WIDTH-1:0] write4_addr_REGA;
  reg [XDATA_WIDTH-3:0] write4_xdata_REGA;
  reg write4_wen_REGA;
  reg [2:0] write4_dly_REGA;
  reg [ADDR2_WIDTH-1:0] write4_addr_REGB;
  reg [XDATA_WIDTH-3:0] write4_xdata_REGB;
  reg write4_wen_REGB;
  reg [2:0] write4_dly_REGB;
  reg [ADDR2_WIDTH-1:0] write4_addr_REGC;
  reg [XDATA_WIDTH-3:0] write4_xdata_REGC;
  reg write4_wen_REGC;
  reg [2:0] write4_dly_REGC;
  reg [ADDR2_WIDTH-1:0] write4_addr_REGD;
  reg [XDATA_WIDTH-3:0] write4_xdata_REGD;
  reg write4_wen_REGD;
  reg [2:0] write4_dly_REGD;
  reg [ADDR2_WIDTH-1:0] write5_addr_REGA;
  reg [XDATA_WIDTH-3:0] write5_xdata_REGA;
  reg write5_wen_REGA;
  reg [2:0] write5_dly_REGA;
  reg [ADDR2_WIDTH-1:0] write5_addr_REGB;
  reg [XDATA_WIDTH-3:0] write5_xdata_REGB;
  reg write5_wen_REGB;
  reg [2:0] write5_dly_REGB;
  reg [ADDR2_WIDTH-1:0] write5_addr_REGC;
  reg [XDATA_WIDTH-3:0] write5_xdata_REGC;
  reg write5_wen_REGC;
  reg [2:0] write5_dly_REGC;
  reg [ADDR2_WIDTH-1:0] write5_addr_REGD;
  reg [XDATA_WIDTH-3:0] write5_xdata_REGD;
  reg write5_wen_REGD;
  reg [2:0] write5_dly_REGD;
  reg [ADDR2_WIDTH-1:0] write4_addr_REG2;
  reg [XDATA_WIDTH-3:0] write4_xdata_REG2;
  reg write4_wen_REG2;
  reg [2:0] write4_dly_REG2;
  reg [ADDR2_WIDTH-1:0] write5_addr_REG2;
  reg [XDATA_WIDTH-3:0] write5_xdata_REG2;
  reg write5_wen_REG2;
  reg [2:0] write5_dly_REG2;
  reg [ADDR2_WIDTH-1:0] write4_addr_REG3;
  reg [XDATA_WIDTH-3:0] write4_xdata_REG3;
  reg write4_wen_REG3;
  reg [2:0] write4_dly_REG3;
  reg [ADDR2_WIDTH-1:0] write5_addr_REG3;
  reg [XDATA_WIDTH-3:0] write5_xdata_REG3;
  reg write5_wen_REG3;
  reg [2:0] write5_dly_REG3;
  reg [ADDR2_WIDTH-1:0] write4_addr_REG4;
  reg [XDATA_WIDTH-3:0] write4_xdata_REG4;
  reg write4_wen_REG4;
  reg [2:0] write4_dly_REG4;
  reg [ADDR2_WIDTH-1:0] write5_addr_REG4;
  reg [XDATA_WIDTH-3:0] write5_xdata_REG4;
  reg write5_wen_REG4;
  reg [2:0] write5_dly_REG4;

  wire enableA;
  wire enableB;
  wire enableA0;
  wire enableB0;

  reg flipA;
  reg flipB;
  reg flipA_reg;
  reg flipA_REH;
  reg [5:0] readA_addr_REH;

  wire [5:0] readA_flip;
  wire [5:0] readA_enItem;
  reg [5:0] readA_enItem_reg;
  wire [5:0] readA_enItemP;
  reg [5:0] readA_enItemP_reg;
  wire [5:0] readA_st;
  reg [5:0] readA_st_reg;
  wire [5:0] readA_flag;
  reg [5:0] readA_flag_reg;
  wire [5:0] readA_pconfl;
  reg [5:0] readA_pconfl_reg;
  wire readA_clkEn0;
  reg readA_clkEn_reg,readA_clkEn0_reg;
  wire [5:0] readA_unal;
  reg  [5:0] readA_unal_reg;
  
  wire [5:0] readB_flip;
  wire [5:0] readB_enItem;
  wire [5:0] readB_ldconfl2;
  wire readB_rdy;
  reg readA_rdy_reg;

  wire [31:0] firstBx;
  wire [31:0] firstAx;
  wire        foundBx;
  wire        foundAx;
  wire [31:0] firstBx2;
  wire [31:0] firstAx2;
  wire        foundBx2;
  wire        foundAx2;
  
 // wire doStallB;
  wire readB_clkEn;

  wire [ADDR_WIDTH:0] write_addr_shr_next;

  wire [31:0] firstANt;
  wire [31:0] firstBNt;
  wire foundANt;
  wire foundBNt;
  wire foundANq;
  wire foundBNq;

  wire reenabA,reenabB;
/*  reg toflipA,toflipB;*/
  reg exceptA_fix;
  reg exceptB_fix;

  reg init;
  reg [5:0] initCount;
  wire [5:0] initCount_next;

  wire [YDATA_WIDTH-1:0] read_dataY;
  wire [YDATA_WIDTH-1:0] write_dataY;
   
  assign readA_rdyP=readA_clkEn0 && ~init;
   
  assign readA_thr=threadA[readA_addr];
 
  function [0:0] sz_unal; 
    input [4:0] sz;
    sz_unal=sz==5'd0 || sz==5'd1;
  endfunction

  function [5:0] up_to_first_zero;
    input [5:0] arg;
    begin
        up_to_first_zero[0]=arg[0];
        up_to_first_zero[1]=&arg[1:0];
        up_to_first_zero[2]=&arg[2:0];
        up_to_first_zero[3]=&arg[3:0];
        up_to_first_zero[4]=&arg[4:0];
        up_to_first_zero[5]=&arg[5:0];
    end
  endfunction
  assign enableA=(validA)!=0 || (validA_next)!=0;
  assign enableB=(curB&validB)!=0;
  assign enableA0=(curA&validA)!=0;

  assign reenabA=~enableA0&write_wen_shr&~stall&~doStall&~except;
  assign reenabB=~enableB&write_wen_shr&~stall&~doStall&~except;
  
//  assign onSameValidA=onSameValidA0 | toflipA;
//  assign onSameValidB=onSameValidB0 | toflipB;
  assign read_data_shrB=read_data_shrB_ram|{SDATA_WIDTH{init}};
  assign read_data_shr=read_data_shr_ram|{SDATA_WIDTH{init}};

  assign readA_flip[0]=read0A_data[`lsaddr_width];
  assign readA_flip[1]=read1A_data[`lsaddr_width];
  assign readA_flip[2]=read2A_data[`lsaddr_width];
  assign readA_flip[3]=read3A_data[`lsaddr_width];
  assign readA_flip[4]=read4A_data[`lsaddr_width];
  assign readA_flip[5]=read5A_data[`lsaddr_width];

  assign readB_flip[0]=read0B_xdata[`lsqxcept_width];
  assign readB_flip[1]=read1B_xdata[`lsqxcept_width];
  assign readB_flip[2]=read2B_xdata[`lsqxcept_width];
  assign readB_flip[3]=read3B_xdata[`lsqxcept_width];
  assign readB_flip[4]=read4B_xdata[`lsqxcept_width];
  assign readB_flip[5]=read5B_xdata[`lsqxcept_width];
  
  assign readA_enItem=read_data_shr[`lsqshare_used];
  assign readB_enItem=read_data_shrB[`lsqshare_usedB];
  
  assign readA_rdy=((readA_flip)&readA_enItem)==(readA_enItem) && enableA && ~init;
  assign readB_rdy=((readB_flip)&readB_enItem)==(readB_enItem) && enableB && ~init;
  
  assign readB_addr_d=(foundB|foundBN) ? 6'bz : write_addr_shr;
  assign readA_addr_d=(foundA|foundAN) ? 6'bz : write_addr_shr;
  
 
  assign readA_clkEn0=((readA_flip[0])&readA_enItem[0])==readA_enItem[0] && enableA;
 
  assign doStall=validA_reg[write_addr_shr] || validB[write_addr_shr[5:0]] ||
    validA_next_reg[write_addr_shr] || validB_next[write_addr_shr[5:0]];
  
  assign doRsPause[0]=write4_wen_REGA|write4_wen_REGB|write4_wen_REGC;
  assign doRsPause[1]=write5_wen_REGA|write5_wen_REGB|write5_wen_REGC;

  assign {
    read5B_enOut,
    read4B_enOut,
    read3B_enOut,
    read2B_enOut,
    read1B_enOut,
    read0B_enOut}=up_to_first_zero(read_dataY[`lsqpend_retire] & {6{~init&enableB&(read_dataY[`lsqpend_odd_rnd_partial])}} &
    ((readB_flip )|~readB_enItem|read_dataY[`lsqpend_pconfl])) & readB_enItem & ~read_dataY[`lsqpend_pconfl]; 
    
  assign readA_enItemP=up_to_first_zero((readA_flip )&readA_enItem&{6{enableA&~init}});
  assign {read5A_enOut,read4A_enOut,read3A_enOut,read2A_enOut,read1A_enOut,read0A_enOut}=readA_enItemP;

  assign write_dataY[`lsqpend_retire]=readA_enItemP_reg;
  assign write_dataY[`lsqpend_pconfl]=readA_pconfl_reg;
  assign write_dataY[`lsqpend_ldconfl]=readA_enItemP_reg & ~readA_st_reg & ~readA_flag_reg & ~readA_pconfl_reg & readA_conflIn_l;
  assign write_dataY[`lsqpend_smpconfl]=readA_enItemP_reg & ~readA_st_reg & ~readA_flag_reg & ~readA_pconfl_reg & readA_conflInMSI;

  assign write_dataY[`lsqpend_odd_round]=readA_rdy_reg;
  assign write_dataY[`lsqpend_odd_rnd_partial]=readA_clkEn0_reg;
     
  assign readB_rdy_en=readB_rdy && read_dataY[`lsqpend_odd_round];
  assign readB_ldconfl=read_dataY[`lsqpend_ldconfl];
  assign readB_smpconfl=read_dataY[`lsqpend_smpconfl]|{read5B_xdata[`lsqxcept_smpdep],
    read4B_xdata[`lsqxcept_smpdep],read3B_xdata[`lsqxcept_smpdep],
    read2B_xdata[`lsqxcept_smpdep],read1B_xdata[`lsqxcept_smpdep],
    read0B_xdata[`lsqxcept_smpdep]};

  assign write4_aux[2]=write4_addr[8:3]!=readA_addr && write4_addr[8:3]!=readA_addr_REH && enableA;
  assign write4_aux[1:0]={2{write4_addr[8:3]!=readA_addr && enableA}};
  assign write5_aux[2]=write5_addr[8:3]!=readA_addr && write5_addr[8:3]!=readA_addr_REH && enableA;
  assign write5_aux[1:0]={2{write5_addr[8:3]!=readA_addr && enableA}};

  assign readA_st={
    read5A_data[`lsaddr_st],
    read4A_data[`lsaddr_st],
    read3A_data[`lsaddr_st],
    read2A_data[`lsaddr_st],
    read1A_data[`lsaddr_st],
    read0A_data[`lsaddr_st]};
      
  assign readA_flag={
    read5A_data[`lsaddr_flag],
    read4A_data[`lsaddr_flag],
    read3A_data[`lsaddr_flag],
    read2A_data[`lsaddr_flag],
    read1A_data[`lsaddr_flag],
    read0A_data[`lsaddr_flag]};

  assign readA_pconfl={6'b0};

  assign readA_unal={
    read5A_data[`lsaddr_low]!=2'b00 || sz_unal(read5A_data[`lsaddr_sz]),
    read4A_data[`lsaddr_low]!=2'b00 || sz_unal(read4A_data[`lsaddr_sz]),
    read3A_data[`lsaddr_low]!=2'b00 || sz_unal(read3A_data[`lsaddr_sz]),
    read2A_data[`lsaddr_low]!=2'b00 || sz_unal(read2A_data[`lsaddr_sz]),
    read1A_data[`lsaddr_low]!=2'b00 || sz_unal(read1A_data[`lsaddr_sz]),
    read0A_data[`lsaddr_low]!=2'b00 || sz_unal(read0A_data[`lsaddr_sz])};
  
  generate
      genvar k;
      for(k=0;k<32;k=k+1) begin : addrB_gen
          assign readB_addr_d=(firstB[k] || firstB[k+32] || ~foundB & (firstBN[k]|firstBN[k+32])) ? {~firstB[k]&foundB||~firstBN[k]&~foundB,k[4:0]} : 6'bz;
          assign readA_addr_d=(firstA[k] || firstA[k+32] || ~foundA & (firstAN[k]|firstAN[k+32])) ? {~firstA[k]&foundA||~firstAN[k]&~foundA,k[4:0]} : 6'bz;
          //assign readA_addr_d=(firstA[k] || ~foundA & firstAN[k]) ? k : 5'bz;
      end
  endgenerate
  
  lsq_req_block toA_mod(
  clk,
  rst,

  readA_clkEn,
  readA_addr_d,
  read0A_data,
  read1A_data,
  read2A_data,
  read3A_data,
  read4A_data,
  read5A_data,


  init ? {initCount[5:0],3'd0} : write0_addr[8:0],{1'b1,write0_data}|{1'b0,{DATA_WIDTH{init}}},rsEn0 || init,
  init ? {initCount[5:0],3'd1} : write1_addr[8:0],{1'b1,write1_data}|{1'b0,{DATA_WIDTH{init}}},rsEn1 || init,
  init ? {initCount[5:0],3'd2} : write2_addr[8:0],{1'b1,write2_data}|{1'b0,{DATA_WIDTH{init}}},rsEn2 || init,
  init ? {initCount[5:0],3'd3} : write3_addr[8:0],{1'b1,write3_data}|{1'b0,{DATA_WIDTH{init}}},rsEn3 || init,
  init ? {initCount[5:0],3'd4} : write4_addr[8:0],{1'b1,write4_data}|{1'b0,{DATA_WIDTH{init}}},write4_wen ||init,
  init ? {initCount[5:0],3'd5} : write5_addr[8:0],{1'b1,write5_data}|{1'b0,{DATA_WIDTH{init}}},write5_wen ||init,
  write_addr_shr[5:0],write_wen_shr&~doStall&~stall&~init&~except
  );
  
  lsq_req_block #(137) toC_mod(
  clk,
  rst,

  readA_clkEn,
  readA_addr_d,
  read0A_DATA,
  read1A_DATA,
  read2A_DATA,
  read3A_DATA,
  read4A_DATA,
  read5A_DATA,


  init ? {initCount[5:0],3'd0} : write0_addr_reg2[8:0],{1'b1,FU0Data}|{1'b0,{136{init}}},write0_wen_reg2 & FU0Hit || init,
  init ? {initCount[5:0],3'd1} : write1_addr_reg2[8:0],{1'b1,FU1Data}|{1'b0,{136{init}}},write1_wen_reg2 & FU1Hit || init,
  init ? {initCount[5:0],3'd2} : write2_addr_reg2[8:0],{1'b1,FU2Data}|{1'b0,{136{init}}},write2_wen_reg2 & FU2Hit || init,
  init ? {initCount[5:0],3'd3} : write3_addr_reg2[8:0],{1'b1,FU3Data}|{1'b0,{136{init}}},write3_wen_reg2 & FU3Hit || init,
  {initCount[5:0],3'd4},{1'b0,{136{init}}},init,
  {initCount[5:0],3'd5},{1'b0,{136{init}}},init,
  write_addr_shr[5:0],write_wen_shr&~doStall&~stall&~init&~except
  );

  lsq_req_block #(129) toD_mod(
  clk,
  rst,

  readA_clkEn,
  readA_addr_d,
  read0A_DATAU,
  read1A_DATAU,
  read2A_DATAU,
  read3A_DATAU,
  read4A_DATAU,
  read5A_DATAU,


  init ? {initCount[5:0],3'd0} : write0_addr_reg2[8:0],{1'b1,FU0DataU]|{1'b0,{128{init}}},write0_wen_reg2 & FU0Hit || init,
  init ? {initCount[5:0],3'd1} : write1_addr_reg2[8:0],{1'b1,FU1DataU]|{1'b0,{128{init}}},write1_wen_reg2 & FU1Hit || init,
  init ? {initCount[5:0],3'd2} : write2_addr_reg2[8:0],{1'b1,FU2DataU}|{1'b0,{128{init}}},write2_wen_reg2 & FU2Hit || init,
  init ? {initCount[5:0],3'd3} : write3_addr_reg2[8:0],{1'b1,FU3DataU}|{1'b0,{128{init}}},write3_wen_reg2 & FU3Hit || init,
  {initCount[5:0],3'd4},{1'b0,{128{init}}},init,
  {initCount[5:0],3'd5},{1'b0,{128{init}}},init,
  write_addr_shr[5:0],write_wen_shr&~doStall&~stall&~init&~except
  );


  lsq_ex_block toB_mod(
  clk,
  rst,

  readB_clkEn | reenabB,
  readB_addr_d,
  read0B_xdata,
  read1B_xdata,
  read2B_xdata,
  read3B_xdata,
  read4B_xdata,
  read5B_xdata,


  init ? {initCount,3'd0} : write0_addr_reg2[8:0],{1'b1,write0_addr_reg2[8],smpc0_reg2,write0_xdata_reg2}|{1'b0,{XDATA_WIDTH{init}}},
      write0_wen_reg2 & FU0Hit || init,
  init ? {initCount,3'd1} : write1_addr_reg2[8:0],{1'b1,write1_addr_reg2[8],smpc1_reg2,write1_xdata_reg2}|{1'b0,{XDATA_WIDTH{init}}},
      write1_wen_reg2 & FU1Hit || init,
  init ? {initCount,3'd2} : write2_addr_reg2[8:0],{1'b1,write2_addr_reg2[8],smpc2_reg2,write2_xdata_reg2}|{1'b0,{XDATA_WIDTH{init}}},
      write2_wen_reg2 & FU2Hit || init,
  init ? {initCount,3'd3} : write3_addr_reg2[8:0],{1'b1,write3_addr_reg2[8],smpc3_reg2,write3_xdata_reg2}|{1'b0,{XDATA_WIDTH{init}}},
      write3_wen_reg2 & FU3Hit || init,
  init ? {initCount,3'd4} : write4_addr[8:0],{1'b1,write4_addr[8],1'b0,write4_xdata}|{1'b0,{XDATA_WIDTH{init}}},
      write4_wen || init,
  init ? {initCount,3'd5} : write5_addr[8:0],{1'b1,write5_addr[8],1'b0,write5_xdata}|{1'b0,{XDATA_WIDTH{init}}},
      write5_wen || init,
  write_addr_shr,write_wen_shr&~doStall&~stall&~init&~except
  );

  lsq_pend_ram pend_mod(
  clk,
  rst,
  readB_clkEn | reenabB,
  readB_addr_d,
  read_dataY,
  init ? initCount : readA_addr_reg,
  write_dataY|{YDATA_WIDTH{init}},
  readA_clkEn_reg||readA_clkEn0_reg||init,
  write_addr_shr,write_wen_shr&~doStall&~stall&~init&~except
  );
  
  lsq_shared_ram shrA_mod(
  clk,
  rst,
  readA_clkEn,
  readA_addr_d,
  read_data_shr_ram,
  init ? initCount[5:0] : write_addr_shr[5:0],
  write_data_shr|{SDATA_WIDTH{init}},
  write_wen_shr&~doStall&~stall&~except||init
  );

  lsq_sharedB_ram shrB_mod(
  clk,
  rst,
  readB_clkEn | reenabB,
  readB_addr_d,
  read_data_shrB_ram,
  init ? initCount : write_addr_shr,
  write_data_shr|{SDATA_WIDTH{init}},
  write_wen_shr&~doStall&~stall&~except||init
  );
  
  bit_find_first_bit #(ADDR_COUNT) lastB_mod(validB[31:0]&~curB[31:0],firstB[31:0],foundBx);
  bit_find_first_bit #(ADDR_COUNT) lastA_mod(validA[31:0],firstA[31:0],foundAx);
  bit_find_first_bit #(ADDR_COUNT) lastB2_mod(validB[63:32]&~curB[63:32],firstBx,foundBx2);
  bit_find_first_bit #(ADDR_COUNT) lastA2_mod(validA[63:32],firstAx[63:32],foundAx2);
  assign firstB[63:32]=firstBx&{32{~foundBx}};
  assign firstA[63:32]=firstAx&{32{~foundAx}};
  assign foundB=foundBx|foundBx2;
  assign foundA=foundAx|foundAx2;

  bit_find_first_bit #(ADDR_COUNT) lastBN_mod(validB_next[31:0],firstBN[31:0],foundBNq);
  bit_find_first_bit #(ADDR_COUNT) lastAN_mod(validA_next[31:0],firstAN[31:0],foundANq);
  bit_find_first_bit #(ADDR_COUNT) lastBN2_mod(validB_next[63:32],firstBNt,foundBNt);
  bit_find_first_bit #(ADDR_COUNT) lastAN2_mod(validA_next[63:32],firstANt,foundANt);
  assign firstBN[63:32]=firstBNt&{32{~foundBNq}};
  assign firstAN[63:32]=firstANt&{32{~foundANq}};
  assign foundBN=foundBNq|foundBNt;
  assign foundAN=foundANq|foundANt;

//  get_carry #(5) onNextCmpB_mod(write_addr_shr[4:0],~readB_addr,1'b1,onSameValidB0);
//  get_carry #(5) onNextCmpA_mod(write_addr_shr[4:0],~readA_addr,1'b1,onSameValidA0);
  
  adder_inc #(6) wrAdd_mod(write_addr_shr,write_addr_shr_next,1'b1,);

  adder_inc #(6) initAdd_mod(initCount,initCount_next,1'b1,);

  assign read0A_dEn[0]=(write0_addr_reg2=={readA_addr,3'd0} && write0_wen_reg2 && FU0Hit) ||
      (write1_addr_reg2=={readA_addr,3'd0} && write1_wen_reg2 && FU1Hit) || 
      (write2_addr_reg2=={readA_addr,3'd0} && write2_wen_reg2 && FU2Hit);
  assign read0A_dEn[1]=(write3_addr_reg2=={readA_addr,3'd0} && write3_wen_reg2 && FU3Hit);

  assign read1A_dEn[0]=(write0_addr_reg2=={readA_addr,3'd1} && write0_wen_reg2 && FU0Hit) ||
      (write1_addr_reg2=={readA_addr,3'd1} && write1_wen_reg2 && FU1Hit) || 
      (write2_addr_reg2=={readA_addr,3'd1} && write2_wen_reg2 && FU2Hit);
  assign read1A_dEn[1]=(write3_addr_reg2=={readA_addr,3'd1} && write3_wen_reg2 && FU3Hit);

  assign read2A_dEn[0]=(write0_addr_reg2=={readA_addr,3'd2} && write0_wen_reg2 && FU0Hit) ||
      (write1_addr_reg2=={readA_addr,3'd2} && write1_wen_reg2 && FU1Hit) || 
      (write2_addr_reg2=={readA_addr,3'd2} && write2_wen_reg2 && FU2Hit);
  assign read2A_dEn[1]=(write3_addr_reg2=={readA_addr,3'd2} && write3_wen_reg2 && FU3Hit);

  assign read3A_dEn[0]=(write0_addr_reg2=={readA_addr,3'd3} && write0_wen_reg2 && FU0Hit) ||
      (write1_addr_reg2=={readA_addr,3'd3} && write1_wen_reg2 && FU1Hit) || 
      (write2_addr_reg2=={readA_addr,3'd3} && write2_wen_reg2 && FU2Hit);
  assign read3A_dEn[1]=(write3_addr_reg2=={readA_addr,3'd3} && write3_wen_reg2 && FU3Hit);

  assign read4A_dEn[0]=(write0_addr_reg2=={readA_addr,3'd4} && write0_wen_reg2 && FU0Hit) ||
      (write1_addr_reg2=={readA_addr,3'd4} && write1_wen_reg2 && FU1Hit) || 
      (write2_addr_reg2=={readA_addr,3'd4} && write2_wen_reg2 && FU2Hit);
  assign read4A_dEn[1]=(write3_addr_reg2=={readA_addr,3'd4} && write3_wen_reg2 && FU3Hit);

  assign read5A_dEn[0]=(write0_addr_reg2=={readA_addr,3'd5} && write0_wen_reg2 && FU0Hit) ||
      (write1_addr_reg2=={readA_addr,3'd5} && write1_wen_reg2 && FU1Hit) || 
      (write2_addr_reg2=={readA_addr,3'd5} && write2_wen_reg2 && FU2Hit);
  assign read5A_dEn[1]=(write3_addr_reg2=={readA_addr,3'd5} && write3_wen_reg2 && FU3Hit);

  always @* begin
      flipA=readA_addr_d[5];
  end
  always @(posedge clk) begin
      if (rst) begin
          validA=64'b0;
          validA_next=64'b0;

          curA=64'b0;

	  threadA<=64'b0;
	  threadA_next<=64'b0;
	  readA_addr<=6'd0;
          exceptA_fix<=1'b0;
      end else begin
          
        //  if (readA_clkEn && toFlipA) begin flipA<=~flipA; toFlipA<=1'b0; end
        //  if (readB_clkEn && toFlipB) begin flipB<=~flipB; toFlipB<=1'b0; end

          
          if (foundA && readA_clkEn) begin
              validA[readA_addr_d]=1'b0;
            //  curA=firstA;
	    //  flipA<=readA_addr_d[5];
          end else if (readA_clkEn) begin //no new entries
              validA[readA_addr_d]=1'b0;
              //curA=64'b0;
	    //  flipA<=readA_addr_d[5];
              if (~onSameValidA) begin
                  validA=validA_next;
                  validA_next=64'b0;
                //  threadA<=threadA_next;
                //  flipA<=~flipA;
                  onSameValidA<=1'b1;
              end
          end
          
          if (write_wen_shr & ~doStall & ~stall & ~except) begin

              if (validA!=0 && write_addr_shr==6'd0) begin
                  onSameValidA<=1'b0;
              end

              if ((validA!=0 && write_addr_shr==6'd0)||~onSameValidA&~(readA_clkEn & ~foundA)) begin
                  validA_next[write_addr_shr]=1'b1;
              end else begin
                  validA[write_addr_shr]=1'b1;
              end
              
              threadA[write_addr_shr]<=write_thread_shr;

          end
	 //up to here 
         // exceptA_fix<=1'b0;
         // exceptB_fix<=1'b0;
	  if (except) begin
              validA=64'b0;
	      validA_next=64'b0;
              //flipA<=write_addr_shr[5];
              onSameValidA<=1'b1;
	  end
	  
	  if (readA_clkEn) readA_addr<=readA_addr_d;
      end
  end
  always @(posedge clk) begin
      if (&read0A_data && read0A_enOut) $display("SS0");
      if (&read1A_data && read1A_enOut) $display("SS1");
      if (&read2A_data && read2A_enOut) $display("SS2");
      if (&read3A_data && read3A_enOut) $display("SS3");
      if (&read4A_data && read4A_enOut) $display("SS4");
      if (&read5A_data && read5A_enOut) $display("SS5");

      if (~|read0A_data && read0A_enOut) $display("Sx0");
      if (~|read1A_data && read1A_enOut) $display("Sx1");
      if (~|read2A_data && read2A_enOut) $display("Sx2");
      if (~|read3A_data && read3A_enOut) $display("Sx3");
      if (~|read4A_data && read4A_enOut) $display("Sx4");
      if (~|read5A_data && read5A_enOut) $display("Sx5");

      smpc0_reg<=smpc0;
      smpc1_reg<=smpc1;
      smpc2_reg<=smpc2;
      smpc3_reg<=smpc3;
      smpc0_reg2<=smpc0_reg;
      smpc1_reg2<=smpc1_reg;
      smpc2_reg2<=smpc2_reg;
      smpc3_reg2<=smpc3_reg;
      if (rst) begin
	  write4_addr_REGA=0;
	  write5_addr_REGA=0;
	  write4_addr_REGB=0;
	  write5_addr_REGB=0;
	  write4_addr_REGC=0;
	  write5_addr_REGC=0;
	  write4_addr_REGD=0;
	  write5_addr_REGD=0;
	  write4_addr_REG2<=0;
	  write5_addr_REG2<=0;
	  write4_addr_REG3<=0;
	  write5_addr_REG3<=0;
	  write4_addr_REG4<=0;
	  write5_addr_REG4<=0;
	  write4_xdata_REGA=0;
	  write5_xdata_REGA=0;
	  write4_xdata_REGB=0;
	  write5_xdata_REGB=0;
	  write4_xdata_REGC=0;
	  write5_xdata_REGC=0;
	  write4_xdata_REGD=0;
	  write5_xdata_REGD=0;
	  write4_xdata_REG2<=0;
	  write5_xdata_REG2<=0;
	  write4_xdata_REG3<=0;
	  write5_xdata_REG3<=0;
	  write4_xdata_REG4<=0;
	  write5_xdata_REG4<=0;
	  write4_wen_REGA=0;
	  write5_wen_REGA=0;
	  write4_wen_REGB=0;
	  write5_wen_REGB=0;
	  write4_wen_REGC=0;
	  write5_wen_REGC=0;
	  write4_wen_REGD=0;
	  write5_wen_REGD=0;
	  write4_dly_REGA=0;
	  write5_dly_REGA=0;
	  write4_dly_REGB=0;
	  write5_dly_REGB=0;
	  write4_dly_REGC=0;
	  write5_dly_REGC=0;
	  write4_dly_REGD=0;
	  write5_dly_REGD=0;
	  write4_wen_REG2<=0;
	  write5_wen_REG2<=0;
	  write4_wen_REG3<=0;
	  write5_wen_REG3<=0;
	  write4_wen_REG4<=0;
	  write5_wen_REG4<=0;
      readA_addr_REH<=0;
      flipA_REH<=0;
      end else if (~~~aStall) begin
          if (write4_wen_REGD) begin 
	          write4_addr_REG2<=write4_addr_REGD;
	          write4_xdata_REG2<=write4_xdata_REGD;
        	  write4_wen_REG2<=write4_wen_REGD;
        	  write4_dly_REG2<={write4_dly_REGD[1:0],1'b1};
          end else if (write4_wen_REGC) begin 
	          write4_addr_REG2<=write4_addr_REGC;
	          write4_xdata_REG2<=write4_xdata_REGC;
        	  write4_wen_REG2<=write4_wen_REGC;
	          write4_wen_REGC=1'b0;
        	  write4_dly_REG2<={write4_dly_REGC[1:0],1'b1};
          end else if (write4_wen_REGB) begin 
	          write4_addr_REG2<=write4_addr_REGB;
	          write4_xdata_REG2<=write4_xdata_REGB;
        	  write4_wen_REG2<=write4_wen_REGB;
	          write4_wen_REGB=1'b0;
        	  write4_dly_REG2<={write4_dly_REGB[1:0],1'b1};
          end else if (write4_wen_REGA) begin 
	          write4_addr_REG2<=write4_addr_REGA;
	          write4_xdata_REG2<=write4_xdata_REGA;
        	  write4_wen_REG2<=write4_wen_REGA;
     	      write4_wen_REGA=1'b0;
        	  write4_dly_REG2<={write4_dly_REGA[1:0],1'b1};
          end else begin
	          write4_addr_REG2<=write4_addr;
	          write4_xdata_REG2<=write4_xdata;
        	  write4_wen_REG2<=write4_wen;
        	  write4_dly_REG2<=3'b1|write4_aux;
          end
          if (write5_wen_REGD) begin 
	          write5_addr_REG2<=write5_addr_REGD;
	          write5_xdata_REG2<=write5_xdata_REGD;
	          write5_wen_REG2<=write5_wen_REGD;
        	  write5_dly_REG2<={write5_dly_REGD[1:0],1'b1};
          end else if (write5_wen_REGC) begin 
	          write5_addr_REG2<=write5_addr_REGC;
	          write5_xdata_REG2<=write5_xdata_REGC;
	          write5_wen_REG2<=write5_wen_REGC;
           	  write5_wen_REGC=1'b0;
        	  write5_dly_REG2<={write5_dly_REGC[1:0],1'b1};
          end else if (write5_wen_REGB) begin 
	          write5_addr_REG2<=write5_addr_REGB;
	          write5_xdata_REG2<=write5_xdata_REGB;
	          write5_wen_REG2<=write5_wen_REGB;
           	  write5_wen_REGB=1'b0;
        	  write5_dly_REG2<={write5_dly_REGB[1:0],1'b1};
          end else if (write5_wen_REGA) begin 
	          write5_addr_REG2<=write5_addr_REGA;
	          write5_xdata_REG2<=write5_xdata_REGA;
	          write5_wen_REG2<=write5_wen_REGA;
    	      write5_wen_REGA=1'b0;
        	  write5_dly_REG2<={write5_dly_REGA[1:0],1'b1};
          end else begin
	          write5_addr_REG2<=write5_addr;
	          write5_xdata_REG2<=write5_xdata;
	          write5_wen_REG2<=write5_wen;
        	  write5_dly_REG2<=3'b1|write5_aux;
          end


	      write4_addr_REG3<=write4_addr_REG2;
	      write5_addr_REG3<=write5_addr_REG2;
	      write4_addr_REG4<=write4_addr_REG3;
	      write5_addr_REG4<=write5_addr_REG3;
	      write4_xdata_REG3<=write4_xdata_REG2;
	      write5_xdata_REG3<=write5_xdata_REG2;
	      write4_xdata_REG4<=write4_xdata_REG3;
	      write5_xdata_REG4<=write5_xdata_REG3;
      	  write4_dly_REG3<={write4_dly_REG2[1:0],1'b1};
      	  write5_dly_REG3<={write5_dly_REG2[1:0],1'b1};
      	  write4_dly_REG4<={write4_dly_REG3[1:0],1'b1};
      	  write5_dly_REG4<={write5_dly_REG3[1:0],1'b1};
	      write4_wen_REGD=1'b0;
	      write5_wen_REGD=1'b0;
	      write4_wen_REG3<=write4_wen_REG2;
	      write5_wen_REG3<=write5_wen_REG2;
	      write4_wen_REG4<=write4_wen_REG3;
	      write5_wen_REG4<=write5_wen_REG3;
	      if (write4_wen && doRsPause[0]) begin
    	      write4_addr_REGD=write4_addr_REGC;
	          write4_xdata_REGD=write4_xdata_REGC;
	          write4_wen_REGD=write4_wen_REGC;
    	      write4_addr_REGC=write4_addr_REGB;
	          write4_xdata_REGC=write4_xdata_REGB;
	          write4_wen_REGC=write4_wen_REGB;
    	      write4_addr_REGB=write4_addr_REGA;
	          write4_xdata_REGB=write4_xdata_REGA;
	          write4_wen_REGB=write4_wen_REGA;
    	      write4_addr_REGA=write4_addr;
	          write4_xdata_REGA=write4_xdata;
	          write4_wen_REGA=write4_wen;
              write4_dly_REGD={write4_dly_REGC[1:0],1'b1};
      //        write5_dly_REGD={write5_dly_REGC[1:0],1'b1};
              write4_dly_REGC={write4_dly_REGB[1:0],1'b1};
        //      write5_dly_REGC={write5_dly_REGB[1:0],1'b1};
              write4_dly_REGB={write4_dly_REGA[1:0],1'b1};
          //    write5_dly_REGB={write5_dly_REGA[1:0],1'b1};
              write4_dly_REGA=3'b1|write4_aux;
          end else if (write4_wen) begin
              write4_dly_REGD={write4_dly_REGD[1:0],1'b1};
              write4_dly_REGC={write4_dly_REGC[1:0],1'b1};
              write4_dly_REGB={write4_dly_REGB[1:0],1'b1};
              write4_dly_REGA={write4_dly_REGA[1:0],1'b1};
          end
	      if (write5_wen && doRsPause[1]) begin
    	      write5_addr_REGD=write5_addr_REGC;
	          write5_xdata_REGD=write5_xdata_REGC;
	          write5_wen_REGD=write5_wen_REGC;
    	      write5_addr_REGC=write5_addr_REGB;
	          write5_xdata_REGC=write5_xdata_REGB;
	          write5_wen_REGC=write5_wen_REGB;
    	      write5_addr_REGB=write5_addr_REGA;
	          write5_xdata_REGB=write5_xdata_REGA;
	          write5_wen_REGB=write5_wen_REGA;
	          write5_addr_REGA=write5_addr;
    	      write5_xdata_REGA=write5_xdata;
	          write5_wen_REGA=write5_wen;
//              write4_dly_REGD={write4_dly_REGC[1:0],1'b1};
              write5_dly_REGD={write5_dly_REGC[1:0],1'b1};
  //            write4_dly_REGC={write4_dly_REGB[1:0],1'b1};
              write5_dly_REGC={write5_dly_REGB[1:0],1'b1};
    //          write4_dly_REGB={write4_dly_REGA[1:0],1'b1};
              write5_dly_REGB={write5_dly_REGA[1:0],1'b1};
              write5_dly_REGA=3'b1|write5_aux;
          end else if (write5_wen) begin
              write5_dly_REGD={write5_dly_REGD[1:0],1'b1};
              write5_dly_REGC={write5_dly_REGC[1:0],1'b1};
              write5_dly_REGB={write5_dly_REGB[1:0],1'b1};
              write5_dly_REGA={write5_dly_REGA[1:0],1'b1};
          end
          readA_addr_REH<=readA_addr_d;
          flipA_REH<=flipA;
      end else begin
	      if (write4_wen) begin
    	      write4_addr_REGD=write4_addr_REGC;
	          write4_xdata_REGD=write4_xdata_REGC;
	          write4_wen_REGD=write4_wen_REGC;
	          write4_dly_REGD=write4_dly_REGC;
    	      write4_addr_REGC=write4_addr_REGB;
	          write4_xdata_REGC=write4_xdata_REGB;
	          write4_wen_REGC=write4_wen_REGB;
	          write4_dly_REGC=write4_dly_REGB;
    	      write4_addr_REGB=write4_addr_REGA;
	          write4_xdata_REGB=write4_xdata_REGA;
	          write4_wen_REGB=write4_wen_REGA;
	          write4_dly_REGB=write4_dly_REGA;
    	      write4_addr_REGA=write4_addr;
	          write4_xdata_REGA=write4_xdata;
	          write4_wen_REGA=write4_wen;
	          write4_dly_REGA=3'b0;
          end
	      if (write5_wen) begin
    	      write5_addr_REGD=write5_addr_REGC;
	          write5_xdata_REGD=write5_xdata_REGC;
	          write5_wen_REGD=write5_wen_REGC;
	          write5_dly_REGD=write5_dly_REGC;
    	      write5_addr_REGC=write5_addr_REGB;
	          write5_xdata_REGC=write5_xdata_REGB;
	          write5_wen_REGC=write5_wen_REGB;
	          write5_dly_REGC=write5_dly_REGB;
    	      write5_addr_REGB=write5_addr_REGA;
	          write5_xdata_REGB=write5_xdata_REGA;
	          write5_wen_REGB=write5_wen_REGA;
	          write5_dly_REGB=write5_dly_REGA;
	          write5_addr_REGA=write5_addr;
    	      write5_xdata_REGA=write5_xdata;
	          write5_wen_REGA=write5_wen;
	          write5_dly_REGA=3'b0;
          end
          if (write4_wen_REG4 && write4_dly_REG4[2]) begin
              write4_addr_REG3<=write4_addr_REG2;
	          write4_addr_REG4<=write4_addr_REG3;
	          write4_xdata_REG3<=write4_xdata_REG2;
	          write4_xdata_REG4<=write4_xdata_REG3;
      	      write4_dly_REG3<=write4_dly_REG2;
      	      write4_dly_REG4<=write4_dly_REG3;
	          write4_wen_REG2<=1'b0;
	          write4_wen_REG3<=write4_wen_REG2;
   	          write4_wen_REG4<=write4_wen_REG3;
          end
          if (write5_wen_REG4 && write5_dly_REG4[2]) begin
              write5_addr_REG3<=write5_addr_REG2;
	          write5_addr_REG4<=write5_addr_REG3;
	          write5_xdata_REG3<=write5_xdata_REG2;
	          write5_xdata_REG4<=write5_xdata_REG3;
      	      write5_dly_REG3<=write5_dly_REG2;
      	      write5_dly_REG4<=write5_dly_REG3;
	          write5_wen_REG2<=1'b0;
	          write5_wen_REG3<=write5_wen_REG2;
   	          write5_wen_REG4<=write5_wen_REG3;
          end
      end

      if (rst) begin
          validB=64'b0;
          validB_next=64'b0;
          validA_reg=64'b0;
          validA_next_reg=64'b0;

          curB=64'b0;

	  write0_addr_reg<={ADDR2_WIDTH{1'B0}};
	  write1_addr_reg<={ADDR2_WIDTH{1'B0}};
	  write2_addr_reg<={ADDR2_WIDTH{1'B0}};
	  write3_addr_reg<={ADDR2_WIDTH{1'B0}};
	  write0_addr_reg2<={ADDR2_WIDTH{1'B0}};
	  write1_addr_reg2<={ADDR2_WIDTH{1'B0}};
	  write2_addr_reg2<={ADDR2_WIDTH{1'B0}};
	  write3_addr_reg2<={ADDR2_WIDTH{1'B0}};
	  write0_xdata_reg<={XDATA_WIDTH-2{1'B0}};
	  write1_xdata_reg<={XDATA_WIDTH-2{1'B0}};
	  write2_xdata_reg<={XDATA_WIDTH-2{1'B0}};
	  write3_xdata_reg<={XDATA_WIDTH-2{1'B0}};
	  write0_xdata_reg2<={XDATA_WIDTH-2{1'B0}};
	  write1_xdata_reg2<={XDATA_WIDTH-2{1'B0}};
	  write2_xdata_reg2<={XDATA_WIDTH-2{1'B0}};
	  write3_xdata_reg2<={XDATA_WIDTH-2{1'B0}};
	  write0_thr_reg<=1'b0;
      write1_thr_reg<=1'b0;
      write2_thr_reg<=1'b0;
      write3_thr_reg<=1'b0;
      write0_thr_reg2<=1'b0;
      write1_thr_reg2<=1'b0;
      write2_thr_reg2<=1'b0;
      write3_thr_reg2<=1'b0;
	  write0_wen_reg<=1'b0;
	  write1_wen_reg<=1'b0;
	  write2_wen_reg<=1'b0;
	  write3_wen_reg<=1'b0;
	  write0_wen_reg2<=1'b0;
	  write1_wen_reg2<=1'b0;
	  write2_wen_reg2<=1'b0;
	  write3_wen_reg2<=1'b0;
	  //write0_xdata_reg<={XDATA_WIDTH{1'B0}};
	 // write1_xdata_reg<={XDATA_WIDTH{1'B0}};
	 // write2_xdata_reg<={XDATA_WIDTH{1'B0}};
	 // write3_xdata_reg<={XDATA_WIDTH{1'B0}};
	 // write0_xdata_reg2<={XDATA_WIDTH{1'B0}};
	 // write1_xdata_reg2<={XDATA_WIDTH{1'B0}};
	 // write2_xdata_reg2<={XDATA_WIDTH{1'B0}};
	 // write3_xdata_reg2<={XDATA_WIDTH{1'B0}};
	  flipA_reg<=1'b0;
	  readA_rdy_reg<=1'b0;
	  write_addr_shr<=6'd0;
	  threadB<=64'b0;
	  threadB_next<=64'b0;
	  readB_addr<=6'd0;
	  readA_addr_reg<=6'd0;
	  flipB<=1'b0;
          exceptB_fix<=1'b0;
	  readA_enItem_reg<=6'b0;
	  readA_enItemP_reg<=6'b0;
	  readA_st_reg<=6'b0;
	  readA_flag_reg<=6'b0;
	  readA_pconfl_reg<=6'b0;
	  readA_unal_reg<=6'b0;
	  readA_clkEn_reg<=1'b0;
          readA_clkEn0_reg<=1'b0;
      end else begin
          
        //  if (readA_clkEn && toFlipA) begin flipA<=~flipA; toFlipA<=1'b0; end
        //  if (readB_clkEn && toFlipB) begin flipB<=~flipB; toFlipB<=1'b0; end
          validA_reg=validA;
          validA_next_reg=validA_next;

          if (reenabB) begin validB=validB&~curB; curB=firstB;  exceptB_fix<=1'b0; onSameValidB<=1'b1; end 
          if (foundB && readB_clkEn) begin
              validB=validB & ~curB;
              curB=firstB;
	      flipB<=readB_addr_d[5];
          end else if (readB_clkEn) begin //no new entries
              validB=validB & ~curB;
	      flipB<=readB_addr_d[5];
              curB=64'b0;
              if (~onSameValidB) begin
                  validB=validB_next;
                  validB_next=64'b0;
                  //threadB<=threadB_next;
//                  flipB<=~flipB;
                  onSameValidB<=1'b1;
                  curB=firstBN;
              end
          end
          
          if (write_wen_shr & ~doStall & ~stall & ~except) begin

              if (validB!=0 && write_addr_shr==6'd0) begin
                  onSameValidB<=1'b0;
              end

              if ((validB!=0 && write_addr_shr==6'd0)||~onSameValidB&~reenabB&~(readB_clkEn & ~foundB)) begin
                  validB_next[write_addr_shr]=1'b1;
              end else begin
                  validB[write_addr_shr]=1'b1;
              end

              threadB[write_addr_shr]<=write_thread_shr;

              if (curB==0) curB[write_addr_shr[5:0]]=1'b1;


	      
	      if (!except) write_addr_shr<=write_addr_shr_next;
          end
	 //up to here 
         // exceptA_fix<=1'b0;
         // exceptB_fix<=1'b0;
	  if (except) begin
//	      toflipA<=1'b0;
//	      toflipB<=1'b0;
	      validB=64'b0;
	      validB_next=64'b0;
              curB=64'b0;
              exceptB_fix<=1'b0;
              flipB<=write_addr_shr[5];
              onSameValidB<=1'b1;
	  end
	  
	  if (readB_clkEn || reenabB) readB_addr<=readB_addr_d;
	  if (!aStall) readA_addr_reg<=readA_addr_d;

	  
	  write0_addr_reg<=write0_addr;
	  write1_addr_reg<=write1_addr;
	  write2_addr_reg<=write2_addr;
	  write3_addr_reg<=write3_addr;
	  write0_addr_reg2<=write0_addr_reg;
	  write1_addr_reg2<=write1_addr_reg;
	  write2_addr_reg2<=write2_addr_reg;
	  write3_addr_reg2<=write3_addr_reg;
	  write0_xdata_reg<=write0_xdata;
	  write1_xdata_reg<=write1_xdata;
	  write2_xdata_reg<=write2_xdata;
	  write3_xdata_reg<=write3_xdata;
	  write0_xdata_reg2<=write0_xdata_reg;
	  write1_xdata_reg2<=write1_xdata_reg;
	  write2_xdata_reg2<=write2_xdata_reg;
	  write3_xdata_reg2<=write3_xdata_reg;
	  write0_thr_reg<=write0_thr;
	  write1_thr_reg<=write1_thr;
	  write2_thr_reg<=write2_thr;
	  write3_thr_reg<=write3_thr;
	  write0_thr_reg2<=write0_thr_reg;
	  write1_thr_reg2<=write1_thr_reg;
	  write2_thr_reg2<=write2_thr_reg;
	  write3_thr_reg2<=write3_thr_reg;
	  write0_wen_reg<=write0_wen & ~(except && except_thread==write0_thr);
	  write1_wen_reg<=write1_wen & ~(except && except_thread==write1_thr);
	  write2_wen_reg<=write2_wen & ~(except && except_thread==write2_thr);
	  write3_wen_reg<=write3_wen & ~(except && except_thread==write3_thr);
	  write0_wen_reg2<=write0_wen_reg & ~(except && except_thread==write0_thr_reg);
	  write1_wen_reg2<=write1_wen_reg & ~(except && except_thread==write1_thr_reg);
	  write2_wen_reg2<=write2_wen_reg & ~(except && except_thread==write2_thr_reg);
	  write3_wen_reg2<=write3_wen_reg & ~(except && except_thread==write3_thr_reg);
	 // write0_xdata_reg<=write0_xdata;
	 // write1_xdata_reg<=write1_xdata;
	 // write2_xdata_reg<=write2_xdata;
	 // write3_xdata_reg<=write3_xdata;
	 // write0_xdata_reg2<=write0_xdata_reg;
         // write1_xdata_reg2<=write1_xdata_reg;
         // write2_xdata_reg2<=write2_xdata_reg;
         // write3_xdata_reg2<=write3_xdata_reg;
          if (readA_clkEn||readA_clkEn0&~aStall) begin
	      flipA_reg<=flipA;
	      readA_rdy_reg<=readA_rdy;
	      readA_enItem_reg<=readA_enItem;
	      readA_enItemP_reg<=readA_enItemP;
              readA_st_reg<=readA_st;
              readA_flag_reg<=readA_flag;
              readA_pconfl_reg<=readA_pconfl;
              readA_unal_reg<=readA_pconfl;
           end
           readA_clkEn_reg<=readA_clkEn;
           if (!aStall) readA_clkEn0_reg<=readA_clkEn0;
           else readA_clkEn0_reg<=1'b0;
      end
      if (rst) begin
	  init<=1'b1;
	  initCount<=6'd0;
      end else if (init) begin
	  initCount<=initCount_next;
	  if (initCount==6'h3f) init<=1'b0;
      end
  end  

endmodule

