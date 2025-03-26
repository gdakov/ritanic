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

module rbus(
  clk,
  rst,
  rbus_rdyIn,
  rbus_rdyOutA,rbus_rdyOutB,
  rbusIn0_signals,rbusIn0_src_req,rbusIn0_dst_req,rbusIn0_address,
  rbusIn1_signals,rbusIn1_src_req,rbusIn1_dst_req,rbusIn1_address,
  rbusPrev_signals,rbusPrev_src_req,rbusPrev_dst_req,rbusPrev_address,
  rbusOut_signals,rbusOut_src_req,rbusOut_dst_req,rbusOut_address,
  prev_out_can,next_in_can
  );
  parameter [4:0] IDA=0;
  parameter [4:0] IDB=IDA;
  input clk;
  input rst;
  output pwire rbus_rdyIn;
  input rbus_rdyOutA;
  input rbus_rdyOutB;
  input [`rbus_width-1:0] rbusIn0_signals;
  input [9:0] rbusIn0_src_req;
  input [9:0] rbusIn0_dst_req;
  input [36:0] rbusIn0_address;
  input [`rbus_width-1:0] rbusIn1_signals;
  input [9:0] rbusIn1_src_req;
  input [9:0] rbusIn1_dst_req;
  input [36:0] rbusIn1_address;
  input [`rbus_width-1:0] rbusPrev_signals;
  input [9:0] rbusPrev_src_req;
  input [9:0] rbusPrev_dst_req;
  input [36:0] rbusPrev_address;
  output pwire [`rbus_width-1:0] rbusOut_signals;
  output pwire [9:0] rbusOut_src_req;
  output pwire [9:0] rbusOut_dst_req;
  output pwire [36:0] rbusOut_address;
  output prev_out_can;
  input next_in_can;
  
  reg [`rbus_width-1:0] rbusPrev_signals_reg;
  reg [9:0] rbusPrev_src_req_reg;
  reg [9:0] rbusPrev_dst_req_reg;
  reg [36:0] rbusPrev_address_reg;
  reg [`rbus_width-1:0] rbusIn0_signals_reg;
  reg [9:0] rbusIn0_src_req_reg;
  reg [9:0] rbusIn0_dst_req_reg;
  reg [36:0] rbusIn0_address_reg;
  reg [`rbus_width-1:0] rbusIn1_signals_reg;
  reg [9:0] rbusIn1_src_req_reg;
  reg [9:0] rbusIn1_dst_req_reg;
  reg [36:0] rbusIn1_address_reg;
  reg [1:0] busy;

  assign rbus_rdyIn=~rbusPrev_signals[`rbus_second] && next_in_can && !(&busy);
  assign prev_out_can=(~rbus_rdyOutA&&~rbus_rdyOutB&&!(&busy))||
     ~rbusPrev_signals[`rbus_used];

  assign rbusOut_signals=busy[0] ? rbusIn0_signals_reg : {`rbus_width{1'bz}};
  assign rbusOut_src_req=busy[0] ? rbusIn0_src_req_reg : 10'bz;
  assign rbusOut_dst_req=busy[0] ? rbusIn0_dst_req_reg : 10'bz;
  assign rbusOut_address=busy[0] ? rbusIn0_address_reg : 37'bz;
  assign rbusOut_signals=(~busy[0] & busy[1]) ? rbusIn1_signals_reg : {`rbus_width{1'bz}};
  assign rbusOut_src_req=(~busy[0] & busy[1]) ? rbusIn1_src_req_reg : 10'bz;
  assign rbusOut_dst_req=(~busy[0] & busy[1]) ? rbusIn1_dst_req_reg : 10'bz;
  assign rbusOut_address=(~busy[0] & busy[1]) ? rbusIn1_address_reg : 37'bz;
  assign rbusOut_signals=(!busy) ? rbusPrev_signals_reg : {`rbus_width{1'bz}};
  assign rbusOut_src_req=(!busy) ? rbusPrev_src_req_reg : 10'bz;
  assign rbusOut_dst_req=(!busy) ? rbusPrev_dst_req_reg : 10'bz;
  assign rbusOut_address=(!busy) ? rbusPrev_address_reg : 37'bz;
  always @(posedge clk) begin
      if (rst) begin
      end else begin
          if (rbusPrev_signals[`rbus_used]) begin
              rbusPrev_signals_reg<=rbusPrev_signals;
              rbusPrev_src_req_reg<=rbusPrev_src_req;
              rbusPrev_dst_req_reg<=rbusPrev_dst_req;
              rbusPrev_address_reg<=rbusPrev_address;
              if (rbusPrev_src_req==IDA || rbusPrev_src_req==IDB) 
                rbusPrev_signals_reg[`rbus_used]<=1'b0;
          end
          if (rbus_rdyOutA && rbus_rdyIn) begin
              rbusIn0_signals_reg<=rbusIn0_signals;
              rbusIn0_src_req_reg<=rbusIn0_src_req;
              rbusIn0_dst_req_reg<=rbusIn0_dst_req;
              rbusIn0_address_reg<=rbusIn0_address;
              busy[0]<=1'b1;
          end else begin
              busy[0]<=1'b0; 
          end
          if (rbus_rdyOutB && rbus_rdyIn) begin
              rbusIn1_signals_reg<=rbusIn1_signals;
              rbusIn1_src_req_reg<=rbusIn1_src_req;
              rbusIn1_dst_req_reg<=rbusIn1_dst_req;
              rbusIn1_address_reg<=rbusIn1_address;
              busy[1]<=1'b1;
          end else begin
              if (~busy[0]) busy[1]<=1'b0;
          end
      end
  end
endmodule

module rbusD_ram(
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
  localparam DATA_WIDTH=`rbusM_width;
  localparam ADDR_COUNT=24;
  
  input clk;
  input rst;
  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
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


module rbusD(
  clk,
  rst,
  rbus_rdyIn,
  rbus_rdyOutA,rbus_rdyOutB,
  rbusIn0_signals,rbusIn0_src_req,rbusIn0_dst_req,rbusIn0_data,rbusIn0_addr,rbusIn0_doStall,
  rbusIn1_signals,rbusIn1_src_req,rbusIn1_dst_req,rbusIn1_data,rbusIn1_addr,rbusIn1_doStall,
  rbusPrev_signals,rbusPrev_src_req,rbusPrev_dst_req,rbusPrev_data,rbusPrev_addr,
  rbusOut_signals,rbusOut_src_req,rbusOut_dst_req,rbusOut_data,rbusOut_addr,
  prev_out_can,next_in_can
  );
  localparam [4:0] STALL_CNT=19;
  input clk;
  input rst;
  output pwire rbus_rdyIn;
  input rbus_rdyOutA;
  input rbus_rdyOutB;
  input [`rbus_width-1:0] rbusIn0_signals;
  input [9:0] rbusIn0_src_req;
  input [9:0] rbusIn0_dst_req;
  input [511:0] rbusIn0_data;
  input [36:0] rbusIn0_addr;
  output pwire rbusIn0_doStall;
  input [`rbus_width-1:0] rbusIn1_signals;
  input [9:0] rbusIn1_src_req;
  input [9:0] rbusIn1_dst_req;
  input [511:0] rbusIn1_data;
  input [36:0] rbusIn1_addr;
  output pwire rbusIn1_doStall;
  input [`rbus_width-1:0] rbusPrev_signals;
  input [9:0] rbusPrev_src_req;
  input [9:0] rbusPrev_dst_req;
  input [511:0] rbusPrev_data;
  input [36:0] rbusPrev_addr;
  output pwire [`rbus_width-1:0] rbusOut_signals;
  output pwire [9:0] rbusOut_src_req;
  output pwire [9:0] rbusOut_dst_req;
  output pwire [511:0] rbusOut_data;
  output pwire [36:0] rbusOut_addr;
  output prev_out_can;
  input next_in_can;
  
  reg [`rbus_width-1:0] rbusPrev_signals_reg;
  reg [9:0] rbusPrev_src_req_reg;
  reg [9:0] rbusPrev_dst_req_reg;
  reg [511:0] rbusPrev_data_reg;
  reg [`rbus_width-1:0] rbusIn0_signals_reg;
  reg [9:0] rbusIn0_src_req_reg;
  reg [9:0] rbusIn0_dst_req_reg;
  reg [511:0] rbusIn0_data_reg;
  reg [`rbus_width-1:0] rbusIn1_signals_reg;
  reg [9:0] rbusIn1_src_req_reg;
  reg [9:0] rbusIn1_dst_req_reg;
  reg [511:0] rbusIn1_data_reg;
  reg [1:0] busy;
  
  pwire read_clkEnA;
  reg [4:0] cntA;
  reg [4:0] read_addrA;
  reg [4:0] write_addrA;
  pwire [4:0] cntA_plus;
  pwire [4:0] cntA_minus;
  pwire [4:0] read_addrA_d;
  pwire [4:0] write_addrA_d;

  pwire read_clkEnB;
  reg [4:0] cntB;
  reg [4:0] read_addrB;
  reg [4:0] write_addrB;
  pwire [4:0] cntB_plus;
  pwire [4:0] cntB_minus;
  pwire [4:0] read_addrB_d;
  pwire [4:0] write_addrB_d;
  
  assign rbus_rdyIn=~rbusPrev_signals[`rbus_second] && next_in_can && !(&busy);
  assign prev_out_can=(~rbus_rdyOutA&&~rbus_rdyOutB&&!(&busy))||
     ~rbusPrev_signals[`rbus_used];
  rbusD_ram ram0_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEnA),
  .read_addr(read_addrA_d),
  .read_data(read_dataA),
  .write_addr(write_addrA),
  .write_data(write_dataA),
  .write_wen(write_wenA)
  );
  rbusD_ram ram1_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEnB),
  .read_addr(read_addrB_d),
  .read_data(read_dataB),
  .write_addr(write_addrB),
  .write_data(write_dataB),
  .write_wen(write_wenB)
  );
  adder_inc #(5) cntAAdd_mod(cntA,cntA_plus,1'b1,);
  adder_inc #(5) wrtAAdd_mod(write_addrA,write_addrA_d,write_addrA!=5'd23,);  
  adder_inc #(5) readAAdd_mod(read_addrA,read_addrA_d,read_addrA!=5'd23,);  
  adder #(5) cntASub_mod(cntA,5'h1f,cntA_minus,1'b0,1'b1,,,,);
  adder_inc #(5) cntBAdd_mod(cntB,cntB_plus,1'b1,);
  adder_inc #(5) wrtBAdd_mod(write_addrB,write_addrB_d,write_addrB!=5'd23,);  
  adder_inc #(5) readBAdd_mod(read_addrB,read_addrB_d,read_addrB!=5'd23,);  
  adder #(5) cntBSub_mod(cntB,5'h1f,cntB_minus,1'b0,1'b1,,,,);

  assign rbusOut_signals=busy[0] ? rbusIn0_signals_reg : {`rbus_width{1'bz}};
  assign rbusOut_src_req=busy[0] ? rbusIn0_src_req_reg : 10'bz;
  assign rbusOut_dst_req=busy[0] ? rbusIn0_dst_req_reg : 10'bz;
  assign rbusOut_data=busy[0] ? rbusIn0_data_reg : 512'bz;
  assign rbusOut_signals=(~busy[0] & busy[1]) ? rbusIn1_signals_reg : {`rbus_width{1'bz}};
  assign rbusOut_src_req=(~busy[0] & busy[1]) ? rbusIn1_src_req_reg : 10'bz;
  assign rbusOut_dst_req=(~busy[0] & busy[1]) ? rbusIn1_dst_req_reg : 10'bz;
  assign rbusOut_data=(~busy[0] & busy[1]) ? rbusIn1_data_reg : 512'bz;
  assign rbusOut_signals=(!busy) ? rbusPrev_signals_reg : {`rbus_width{1'bz}};
  assign rbusOut_src_req=(!busy) ? rbusPrev_src_req_reg : 10'bz;
  assign rbusOut_dst_req=(!busy) ? rbusPrev_dst_req_reg : 10'bz;
  assign rbusOut_data=(!busy) ? rbusPrev_data_reg : 512'bz;
  always @(posedge clk) begin
      if (rst) begin
      end else begin
          if (write_wenA & ~read_clkEnA) cntA<=cntA_plus;
          if (read_clkEnA & ~write_wenA) cntA<=cntA_minus;
          if (write_wenA) write_addrA<=write_addrA_d;
          if (read_clkEnA) read_addrA<=read_addrA_d;
          if (write_wenB & ~read_clkEnB) cntB<=cntB_plus;
          if (read_clkEnB & ~write_wenB) cntB<=cntB_minus;
          if (write_wenB) write_addrB<=write_addrB_d;
          if (read_clkEnB) read_addrB<=read_addrB_d;
          rbusPrev_signals_reg<=rbusPrev_signals;
          rbusPrev_src_req_reg<=rbusPrev_src_req;
          rbusPrev_dst_req_reg<=rbusPrev_dst_req;
          rbusPrev_data_reg<=rbusPrev_data;
          if (rbus_rdyOutA && rbus_rdyIn) begin
              rbusIn0_signals_reg<=rbusIn0_signals;
              rbusIn0_src_req_reg<=rbusIn0_src_req;
              rbusIn0_dst_req_reg<=rbusIn0_dst_req;
              rbusIn0_data_reg<=rbusIn0_data;
              busy[0]<=1'b1;
          end else begin
              busy[0]<=1'b0; 
          end
          if (rbus_rdyOutB && rbus_rdyIn) begin
              rbusIn1_signals_reg<=rbusIn1_signals;
              rbusIn1_src_req_reg<=rbusIn1_src_req;
              rbusIn1_dst_req_reg<=rbusIn1_dst_req;
              rbusIn1_data_reg<=rbusIn1_data;
              busy[1]<=1'b1;
          end else begin
              if (~busy[0]) busy[1]<=1'b0;
          end
      end
  end
endmodule


