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

module regfile_get_gazump0(
  clk,rst,
  read_clkEn,
  read_addr,
  read_constEn,
  read_oe,
  match_w,
  write0_addr_reg,write0_wen_reg,
  write1_addr_reg,write1_wen_reg,
  write2_addr_reg,write2_wen_reg,
  write3_addr_reg,write3_wen_reg,
  write4_addr_reg,write4_wen_reg,
  write5_addr_reg,write5_wen_reg,
  write6_addr_reg,write6_wen_reg,
  write7_addr_reg,write7_wen_reg,
  write8_addr_reg,write8_wen_reg,
  write9_addr_reg,write9_wen_reg
  );
  parameter DATA_WIDTH=`alu_width;
  localparam ADDR_WIDTH=`reg_addr_width;

  input clk;
  input rst;

  input read_clkEn;
  
  input [ADDR_WIDTH-1:0] read_addr;

  input read_constEn;
  input read_oe;
  
  output [10:0] match_w;
  
  input [ADDR_WIDTH-1:0] write0_addr_reg;
  input write0_wen_reg;

  input [ADDR_WIDTH-1:0] write1_addr_reg;
  input write1_wen_reg;

  input [ADDR_WIDTH-1:0] write2_addr_reg;
  input write2_wen_reg;

  input [ADDR_WIDTH-1:0] write3_addr_reg;
  input write3_wen_reg;

  input [ADDR_WIDTH-1:0] write4_addr_reg;
  input write4_wen_reg;

  input [ADDR_WIDTH-1:0] write5_addr_reg;
  input write5_wen_reg;

  input [ADDR_WIDTH-1:0] write6_addr_reg;
  input write6_wen_reg;

  input [ADDR_WIDTH-1:0] write7_addr_reg;
  input write7_wen_reg;

  input [ADDR_WIDTH-1:0] write8_addr_reg;
  input write8_wen_reg;

  input [ADDR_WIDTH-1:0] write9_addr_reg;
  input write9_wen_reg;



  
  wire match_r0;
  wire match_r1;
  wire match_r2;
  wire match_r3;
  wire match_r4;
  wire match_r5;
  wire match_r6;
  wire match_r7;
  wire match_r8;
  wire match_r9;

  wire match;

  reg read_constEn_reg;

  reg read_oe_reg;
  reg [ADDR_WIDTH-1:0] read_addr_reg;


  
  assign match_w[0]=read_addr_reg==write0_addr_reg && write0_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[1]=read_addr_reg==write1_addr_reg && write1_wen_reg &&
     ~read_constEn_reg  && read_oe_reg;
  assign match_w[2]=read_addr_reg==write2_addr_reg && write2_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[3]=read_addr_reg==write3_addr_reg && write3_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[4]=read_addr_reg==write4_addr_reg && write4_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[5]=read_addr_reg==write5_addr_reg && write5_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[6]=read_addr_reg==write6_addr_reg && write6_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[7]=read_addr_reg==write7_addr_reg && write7_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[8]=read_addr_reg==write8_addr_reg && write8_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[9]=read_addr_reg==write9_addr_reg && write9_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  
  assign match_w[10]=~(|{match_w[0],match_w[1],match_w[2],match_w[3],match_w[4],match_w[5],
    match_w[6],match_w[7],match_w[8],match_w[9]});


  always @(posedge clk)
    begin
      if (rst)
        begin
          read_constEn_reg<=1'b0;
          read_oe_reg<=1'b0;
	  read_addr_reg<={ADDR_WIDTH{1'B0}};
        end
      else 
        begin 
          if (read_clkEn)
            begin
              read_constEn_reg<=read_constEn;
              read_oe_reg<=read_oe;
     	      read_addr_reg<=read_addr;
            end
        end
    end
endmodule


module regfile_get_gazump(
  clk,rst,
  read_clkEn,
  
  read0_addr,read0_constEn,read0_oe,read0_match,
  read1_addr,read1_constEn,read1_oe,read1_match,
  read2_addr,read2_constEn,read2_oe,read2_match,
  read3_addr,read3_constEn,read3_oe,read3_match,
  read4_addr,read4_constEn,read4_oe,read4_match,
  read5_addr,read5_constEn,read5_oe,read5_match,
  read6_addr,read6_constEn,read6_oe,read6_match,
  read7_addr,read7_constEn,read7_oe,read7_match,
  read8_addr,read8_constEn,read8_oe,read8_match,

  write0_addr_reg,write0_wen_reg,
  write1_addr_reg,write1_wen_reg,
  write2_addr_reg,write2_wen_reg,
  write3_addr_reg,write3_wen_reg,
  write4_addr_reg,write4_wen_reg,
  write5_addr_reg,write5_wen_reg,
  write6_addr_reg,write6_wen_reg,
  write7_addr_reg,write7_wen_reg,
  write8_addr_reg,write8_wen_reg,
  write9_addr_reg,write9_wen_reg
  );
  localparam ADDR_WIDTH=`reg_addr_width;
  input clk,rst,read_clkEn;
/*verilator hier_block*/ 
  
  input [ADDR_WIDTH-1:0] read0_addr;
  input read0_constEn;
  input read0_oe;
  output [10:0] read0_match;
  input [ADDR_WIDTH-1:0] read1_addr;
  input read1_constEn;
  input read1_oe;
  output [10:0] read1_match;
  input [ADDR_WIDTH-1:0] read2_addr;
  input read2_constEn;
  input read2_oe;
  output [10:0] read2_match;
  input [ADDR_WIDTH-1:0] read3_addr;
  input read3_constEn;
  input read3_oe;
  output [10:0] read3_match;
  input [ADDR_WIDTH-1:0] read4_addr;
  input read4_constEn;
  input read4_oe;
  output [10:0] read4_match;
  input [ADDR_WIDTH-1:0] read5_addr;
  input read5_constEn;
  input read5_oe;
  output [10:0] read5_match;
  input [ADDR_WIDTH-1:0] read6_addr;
  input read6_constEn;
  input read6_oe;
  output [10:0] read6_match;
  input [ADDR_WIDTH-1:0] read7_addr;
  input read7_constEn;
  input read7_oe;
  output [10:0] read7_match;
  input [ADDR_WIDTH-1:0] read8_addr;
  input read8_constEn;
  input read8_oe;
  output [10:0] read8_match;

  input [ADDR_WIDTH-1:0] write0_addr_reg;
  input write0_wen_reg;
  input [ADDR_WIDTH-1:0] write1_addr_reg;
  input write1_wen_reg;
  input [ADDR_WIDTH-1:0] write2_addr_reg;
  input write2_wen_reg;
  input [ADDR_WIDTH-1:0] write3_addr_reg;
  input write3_wen_reg;
  input [ADDR_WIDTH-1:0] write4_addr_reg;
  input write4_wen_reg;
  input [ADDR_WIDTH-1:0] write5_addr_reg;
  input write5_wen_reg;
  input [ADDR_WIDTH-1:0] write6_addr_reg;
  input write6_wen_reg;
  input [ADDR_WIDTH-1:0] write7_addr_reg;
  input write7_wen_reg;
  input [ADDR_WIDTH-1:0] write8_addr_reg;
  input write8_wen_reg;
  input [ADDR_WIDTH-1:0] write9_addr_reg;
  input write9_wen_reg;

  wire [ADDR_WIDTH-1:0] read_addr[8:0];
  wire [8:0] read_constEn;
  wire [10:0] read_match[8:0];
  wire [8:0] read_oe;

  assign read_addr[0]=read0_addr;
  assign read_addr[1]=read1_addr;
  assign read_addr[2]=read2_addr;
  assign read_addr[3]=read3_addr;
  assign read_addr[4]=read4_addr;
  assign read_addr[5]=read5_addr;
  assign read_addr[6]=read6_addr;
  assign read_addr[7]=read7_addr;
  assign read_addr[8]=read8_addr;

  assign read_oe[0]=read0_oe;
  assign read_oe[1]=read1_oe;
  assign read_oe[2]=read2_oe;
  assign read_oe[3]=read3_oe;
  assign read_oe[4]=read4_oe;
  assign read_oe[5]=read5_oe;
  assign read_oe[6]=read6_oe;
  assign read_oe[7]=read7_oe;
  assign read_oe[8]=read8_oe;
  
  assign read_constEn[0]=read0_constEn;
  assign read_constEn[1]=read1_constEn;
  assign read_constEn[2]=read2_constEn;
  assign read_constEn[3]=read3_constEn;
  assign read_constEn[4]=read4_constEn;
  assign read_constEn[5]=read5_constEn;
  assign read_constEn[6]=read6_constEn;
  assign read_constEn[7]=read7_constEn;
  assign read_constEn[8]=read8_constEn;

  assign read0_match=read_match[0];
  assign read1_match=read_match[1];
  assign read2_match=read_match[2];
  assign read3_match=read_match[3];
  assign read4_match=read_match[4];
  assign read5_match=read_match[5];
  assign read6_match=read_match[6];
  assign read7_match=read_match[7];
  assign read8_match=read_match[8];
  
  generate
    genvar k;
    for(k=0;k<9;k=k+1) begin : teh_gen
        regfile_get_gazump0 gz_mod(
        clk,rst,
        read_clkEn,
        read_addr[k],
        read_constEn[k],
        read_oe[k],
        read_match[k],
        write0_addr_reg,write0_wen_reg,
        write1_addr_reg,write1_wen_reg,
        write2_addr_reg,write2_wen_reg,
        write3_addr_reg,write3_wen_reg,
        write4_addr_reg,write4_wen_reg,
        write5_addr_reg,write5_wen_reg,
        write6_addr_reg,write6_wen_reg,
        write7_addr_reg,write7_wen_reg,
        write8_addr_reg,write8_wen_reg,
        write9_addr_reg,write9_wen_reg
        );
    end
  endgenerate 
  
endmodule

