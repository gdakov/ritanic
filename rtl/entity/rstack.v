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

module ret_stack_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=67;
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


module ret_stack(
  clk,
  rst,
  except,
  except_thread,
  read_clkEn,
  thread,
  read_data,
  write_data,
  write_lnk,
  write_trace,
  write_wen
  );

  localparam DATA_WIDTH=67;
  localparam ADDR_WIDTH=4;
  localparam ADDR_COUNT=16;

  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire except_thread;
  input pwire read_clkEn;
  input pwire thread;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire [4:0] write_lnk;
  input pwire write_trace;
  input pwire write_wen;

  pwire [ADDR_WIDTH-1:0] read_addr[1:0];
  pwire [ADDR_WIDTH-1:0] write_addr[1:0];
  pwire [ADDR_WIDTH-1:0] write_addr_reg;
  pwire [1:0][ADDR_WIDTH-1:0] read_addr_inc;
  pwire [1:0][ADDR_WIDTH-1:0] write_addr_inc;
  pwire [1:0][ADDR_WIDTH-1:0] read_addr_dec;
  pwire [1:0][ADDR_WIDTH-1:0] write_addr_dec;
  pwire [DATA_WIDTH-1:0] write_data_new;
  pwire [DATA_WIDTH-1:0] read_data_ram;

  pwire write_wen_reg;
  pwire thread_reg;
  pwire write_trace_reg;
  pwire [DATA_WIDTH-1:0] write_data_reg;
  pwire [4:0] write_link_reg;
  
  ret_stack_ram ram_mod(
  clk,
  rst,
  read_clkEn,
  {thread,read_addr[thread]},
  read_data_ram,
  {thread_reg,write_addr_reg},
  write_data_new,
  write_wen_reg
  );
  
  adder #(43) wrtdat_mod(write_data_reg[46:4],43'b0,write_data_new[46:4],write_link_reg[4],1'b1,,,,);
  assign write_data_new[66:47]=write_data_reg[66:47];
  
  adder_inc #(ADDR_WIDTH) rdInc0_mod(read_addr[0],read_addr_inc[0],1'b1,);
  adder_inc #(ADDR_WIDTH) rdInc1_mod(read_addr[1],read_addr_inc[1],1'b1,);
  adder_inc #(ADDR_WIDTH) wrInc0_mod(write_addr[0],write_addr_inc[0],1'b1,);
  adder_inc #(ADDR_WIDTH) wrInc1_mod(write_addr[1],write_addr_inc[1],1'b1,);

  adder #(ADDR_WIDTH) rdDec0_mod(read_addr[0],{ADDR_WIDTH{1'B1}},read_addr_dec[0],1'b0,1'b1,,,,);
  adder #(ADDR_WIDTH) rdDec1_mod(read_addr[1],{ADDR_WIDTH{1'B1}},read_addr_dec[1],1'b0,1'b1,,,,);
  adder #(ADDR_WIDTH) wrDec0_mod(write_addr[0],{ADDR_WIDTH{1'B1}},write_addr_dec[0],1'b0,1'b1,,,,);
  adder #(ADDR_WIDTH) wrDec1_mod(write_addr[1],{ADDR_WIDTH{1'B1}},write_addr_dec[1],1'b0,1'b1,,,,);
  
  assign write_data_new[3:0]=write_link_reg[3:0];
  
  assign read_data=write_wen_reg ? write_data_new : read_data_ram;
  
  always @(posedge clk) begin
      if (rst) begin
          read_addr[0]<=4'hf;
          read_addr[1]<=4'hf;
          write_addr[0]<=4'b0;
          write_addr[1]<=4'b0;
          write_addr_reg<=4'b0;
          thread_reg<=1'b0;
          write_data_reg<=67'b0;
          write_wen_reg<=1'b0;
          write_trace_reg<=1'b0;
          write_link_reg<=5'b0;
      end else if (except) begin
          read_addr[except_thread]<=4'hf;
          write_addr[except_thread]<=4'b0;
          write_addr_reg<=4'b0;
          thread_reg<=thread;
          write_data_reg<=67'b0;
          write_wen_reg<=1'b0;
          write_trace_reg<=1'b0;
          write_link_reg<=5'b0;
      end else begin
          if (read_clkEn) begin
              read_addr[thread]<=read_addr_dec[thread];
              write_addr[thread]<=write_addr_dec[thread];
          end else if (write_wen) begin
              read_addr[thread]<=read_addr_inc[thread];
              write_addr[thread]<=write_addr_inc[thread];
              write_addr_reg<=write_addr[thread];
          end
          thread_reg<=thread;
          write_data_reg<=write_data;
          write_wen_reg<=write_wen;
          write_trace_reg<=write_trace;
          write_link_reg<=write_lnk;
      end
  end
endmodule

