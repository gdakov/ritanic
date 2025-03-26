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

module bob_ram0(
  clk,
  read_clkEn,
  read_addr, read_data,
  write_addr, write_data, write_wen
  );
  
  parameter ADDR_WIDTH=`bob_addr_width;
  parameter DATA_WIDTH=`bob_width/4+1;
  parameter ADDR_COUNT=`bob_count;
  
  input clk;
  
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
      if (write_wen) ram[write_addr]<=write_data;
      if (read_clkEn) read_addr_reg<=read_addr;
    end
    
endmodule
module bob_ram(
  clk,
  read_clkEn,
  read_addr, read_data,
  write_addr, write_data, write_wen
  );
  
  parameter ADDR_WIDTH=`bob_addr_width;
  parameter DATA_WIDTH=`bob_width;
  parameter ADDR_COUNT=`bob_count;

  input clk;
  
  input read_clkEn;
  input [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  
  input [ADDR_WIDTH-1:0] write_addr;
  input [DATA_WIDTH-1:0] write_data;
  input write_wen;
  pwire dummyW0,dummyW1,dummyW2,dummyW3;
  //verilator lint_off WIDTH
  bob_ram0 ram0(
  clk,
  read_clkEn,
  read_addr, {dummyW0,read_data[DATA_WIDTH/4-1:0]},
  write_addr, {1'b0,write_data[DATA_WIDTH/4-1:0]}, 
  write_wen
  );
  bob_ram0 ram1(
  clk,
  read_clkEn,
  read_addr, {dummyW1,read_data[DATA_WIDTH/2-1:DATA_WIDTH/4]},
  write_addr, {1'b0,write_data[DATA_WIDTH/2-1:DATA_WIDTH/4]}, 
  write_wen
  );
  bob_ram0 ram2(
  clk,
  read_clkEn,
  read_addr, {dummyW2,read_data[DATA_WIDTH*3/4-1:DATA_WIDTH/2]},
  write_addr, {1'b0,write_data[DATA_WIDTH*3/4-1:DATA_WIDTH/2]}, 
  write_wen
  );
  bob_ram0 ram3S(
  clk,
  read_clkEn,
  read_addr, {read_data[DATA_WIDTH-1:DATA_WIDTH*3/4]},
  write_addr, {write_data[DATA_WIDTH-1:DATA_WIDTH*3/4]}, 
  write_wen
  );
  //verilator lint_on WIDTH
endmodule  

module bob_addr(
  clk,
  rst,
  except,
  new_en,
  new_addr,
  stall,
  doStall,
  hasRetire,
  doRetire,
  retire_addr
  );
  
  input clk;
  input rst;
  input except;
  input new_en;
  output pwire reg [5:0] new_addr;
  input stall;
  output pwire doStall;
  output pwire reg hasRetire;
  input doRetire;
  output pwire reg [5:0] retire_addr;

  reg [5:0] retire_addr0;
  pwire [5:0] retire0_inc;
  reg [5:0] cnt;
  pwire [5:0] cnt_inc;
  pwire [5:0] cnt_dec;
  pwire [5:0] new_addr_d;
  reg except_reg;
  adder_inc #(6) add1_mod(retire_addr0,retire0_inc,1'b1,);
  adder_inc #(6) add2_mod(cnt,cnt_inc,1'b1,);
  adder_inc #(6) add3_mod(new_addr,new_addr_d,new_addr!=6'd62,);

  assign new_addr_d=new_addr==6'd62 ? 6'd0 : 6'bz;

  adder #(6) add4_mod(cnt,6'h3f,cnt_dec,1'b0,1'b1,,,,);

  assign doStall=cnt==6'd62;
  
  always @(*) begin
      if (rst) begin
	  retire_addr=6'd0;
      end else if (except) begin
          retire_addr=new_addr;
      end else begin
	  retire_addr=retire_addr0;
	  if (doRetire && retire_addr0!=6'd62) retire_addr=retire0_inc;
	  if (doRetire && retire_addr0==6'd62) retire_addr=6'b0;
      end
      hasRetire=cnt!=6'd0;
  end

  always @(posedge clk) begin
      if (rst) begin
	  retire_addr0<=6'd0;
	  cnt<=6'd0;
	  new_addr<=6'd0;
      end else if (except) begin
          retire_addr0<=new_addr;
	  cnt<=6'd0;
      end else begin
	  if (new_en && !stall && !doStall) new_addr<=new_addr_d;
	  if (new_en && !stall && !doStall && !doRetire) cnt<=cnt_inc;
	  if (!new_en | stall | doStall && doRetire) cnt<=cnt_dec;
	  if (doRetire && retire_addr0!=6'd62) retire_addr0<=retire0_inc;
	  if (doRetire && retire_addr0==6'd62) retire_addr0<=6'b0;
      end
  end

endmodule
