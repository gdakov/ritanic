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




module rrf_flag_buf(
  clk,
  rst,
  read0_data,
  write0_data,write0_wen,
  read_thread,
  write_thread
  );
  
  parameter INDEX=0;
  parameter DATA_WIDTH=6;
  
  input pwire clk;
  input pwire rst;
  
  output pwire [DATA_WIDTH-1:0] read0_data;

  
  input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire                  write0_wen;

  input pwire read_thread;
  input pwire write_thread;

  pwire [DATA_WIDTH-1:0] data0;
  pwire [DATA_WIDTH-1:0] data;
  pwire [DATA_WIDTH-1:0] wData;

  
  assign data=data0;
  
  assign read0_data=data;
  

  assign wData=write0_data;

  always @(posedge clk)
    begin
	  if (rst) begin data0<={DATA_WIDTH{1'B0}}; end
	  else 
	    begin
		  if (write0_wen) data0<=wData;
		end
    end	
	
endmodule


module rrf_flag(
  clk,
  rst,
  read_clkEn,
  read0_data,read0_oe,
  write0_data,write0_wen,
  read_thread,
  write_thread
  );
  
  parameter DATA_WIDTH=6;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  
  output pwire [DATA_WIDTH:0] read0_data;
  input pwire read0_oe;

  
  input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire                  write0_wen;
  
  input pwire read_thread;
  input pwire write_thread;

  pwire read_thread_reg;

  pwire [DATA_WIDTH-1:0] read_data_ram;


  pwire read0_oe_reg;

  
  assign read0_data=read0_oe_reg ? {1'b0,read_data_ram} : {DATA_WIDTH+1{1'BZ}};
  
  always @(posedge clk)
    begin
	  if (rst)
	    begin

		  read_thread_reg<=1'b0;
		  
		  read0_oe_reg<=1'b1;
		end
	  else if (read_clkEn)
	    begin

		  read_thread_reg<=read_thread;
		  
		  read0_oe_reg<=read0_oe;
		end
	end
	
        rrf_flag_buf buf_mod(
        clk,
        rst,
        read_data_ram,
        write0_data,write0_wen,
        read_thread_reg,
        write_thread
        );

endmodule



