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




module rrf(
  clk,
  rst,
  read_clkEn,
  read0_addr,read0_data,read0_oe,
  read1_addr,read1_data,read1_oe,
  write0_addr,write0_data,write0_wen,
  read_thread,
  write_thread
  );
  
  parameter DATA_WIDTH=`alu_width;
  parameter EXTRA=0;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=32+16*EXTRA;
  
  input clk;
  input rst;
  input read_clkEn;
  
  input [9:0][ADDR_WIDTH-1:0] read0_addr;
  output pwire [9:0][DATA_WIDTH-1:0] read0_data;
  input [9:0] read0_oe;
  input [10:0][ADDR_WIDTH-1:0] read1_addr;
  output pwire [10:0][DATA_WIDTH-1:0] read1_data;
  input [10:0]read1_oe;

  
  input [9:0][ADDR_WIDTH-1:0] write0_addr;
  input [9:0][DATA_WIDTH-1:0] write0_data;
  input [9:0]                 write0_wen;
  
  input read_thread;
  input write_thread;

  reg [9:0][ADDR_WIDTH-1:0] read0_addr_reg;
  reg [10:0][ADDR_WIDTH-1:0] read1_addr_reg;
  
  reg read_thread_reg;

  integer xnp;

  reg [9:0]read0_oe_reg;
  reg [10:0]read1_oe_reg;
  reg [DATA_WIDTH-1:0] ram[ADDR_COUNT-1:0];
  
  always @(posedge clk)
    begin
          for(xnp=0;xn<10;xnp=xnp+1) begin
              if (write0_wen[xnp]) ram[write0_addr[xnp]]<=write0_data[xnp];
          end
	  if (rst)
	    begin
		  read0_addr_reg<={10*ADDR_WIDTH{1'B0}};
		  read1_addr_reg<={11*ADDR_WIDTH{1'B0}};

		  read_thread_reg<=1'b0;
		  
		  read0_oe_reg<=10'b1111111111;
		  read1_oe_reg<=10'b1111111111;
		end
	  else if (read_clkEn)
	    begin
		  read0_addr_reg<=read0_addr;
		  read1_addr_reg<=read1_addr;

		  read_thread_reg<=read_thread;
		  
		  read0_oe_reg<=read0_oe;
		  read1_oe_reg<=read1_oe;
		end
	end

  generate
    genvar x1;
    for(x1=0;x1<11;x1=x1+1) begin
        if (x1!=10) assign read0_data[x1]=read0_oe_reg[x1] ? ram[read0_addr_reg[x1]] : 'z;
        assign read1_data[x1]=read1_oe_reg[x1] ? ram[read1_addr_reg[x1]] : 'z;
    end
  endgenerate	

  
endmodule



