/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024, see additional restriction in copying.txt

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


`include "../struct.sv"

// main modules: regfilef
// the rest are parts of it


//please note that the compiler is likely to split the regifle into 3 identical blocks with less read ports e.g. 3 data / 
//[1 ram/9 wire] retire
module regfilef(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_addr_rrf,read0_data,read0_oe,read0_match,
  read1_addr,read1_addr_rrf,read1_data,read1_oe,read1_match,
  read2_addr,read2_addr_rrf,read2_data,read2_oe,read2_match,

  read0_constEn,
  read1_constEn,
  read2_constEn,

  read0_const,
  read1_const,
  read2_const,

  write0_addr_rrf,write0_wen_rrf,
  write1_addr_rrf,write1_wen_rrf,
  write2_addr_rrf,write2_wen_rrf,
  write3_addr_rrf,write3_wen_rrf,
  write4_addr_rrf,write4_wen_rrf,
  write5_addr_rrf,write5_wen_rrf,
  write6_addr_rrf,write6_wen_rrf,
  write7_addr_rrf,write7_wen_rrf,
  write8_addr_rrf,write8_wen_rrf,

  retireRead0_addr,
  retireRead1_addr,
  retireRead2_addr,
  retireRead3_addr,
  retireRead4_addr,
  retireRead5_addr,
  retireRead6_addr,
  retireRead7_addr,
  retireRead8_addr,

  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen,
  write4_addr,write4_data,write4_wen,
  write5_addr,write5_data,write5_wen,
  write6_addr,write6_data,write6_wen,
  write7_addr,write7_data,write7_wen,
  write8_addr,write8_data,write8_wen,
  write9_addr,write9_data,write9_wen
  );
  parameter DATA_WIDTH=`alu_width;
  parameter [1:0] RS=0;
  localparam ADDR_WIDTH=`reg_addr_width;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  input pwire [5:0] read0_addr_rrf;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read0_data;
  input pwire read0_oe;
  output pwire [10:0] read0_match;

  input pwire [ADDR_WIDTH-1:0] read1_addr;
  input pwire [5:0] read1_addr_rrf;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read1_data;
  input pwire read1_oe;
  output pwire [10:0] read1_match;

  input pwire [ADDR_WIDTH-1:0] read2_addr;
  input pwire [5:0] read2_addr_rrf;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read2_data;
  input pwire read2_oe;
  output pwire [10:0] read2_match;

  input pwire read0_constEn;
  input pwire read1_constEn;
  input pwire read2_constEn;

  input pwire [DATA_WIDTH-1:0] read0_const;
  input pwire [DATA_WIDTH-1:0] read1_const;
  input pwire [DATA_WIDTH-1:0] read2_const;


  input pwire [5:0] write0_addr_rrf;
  input pwire       write0_wen_rrf;  
  input pwire [5:0] write1_addr_rrf;
  input pwire       write1_wen_rrf;  
  input pwire [5:0] write2_addr_rrf;
  input pwire       write2_wen_rrf;  
  input pwire [5:0] write3_addr_rrf;
  input pwire       write3_wen_rrf;  
  input pwire [5:0] write4_addr_rrf;
  input pwire       write4_wen_rrf;  
  input pwire [5:0] write5_addr_rrf;
  input pwire       write5_wen_rrf;  
  input pwire [5:0] write6_addr_rrf;
  input pwire       write6_wen_rrf;  
  input pwire [5:0] write7_addr_rrf;
  input pwire       write7_wen_rrf;  
  input pwire [5:0] write8_addr_rrf;
  input pwire       write8_wen_rrf;  

  input pwire [8:0] retireRead0_addr;
  input pwire [8:0] retireRead1_addr;
  input pwire [8:0] retireRead2_addr;
  input pwire [8:0] retireRead3_addr;
  input pwire [8:0] retireRead4_addr;
  input pwire [8:0] retireRead5_addr;
  input pwire [8:0] retireRead6_addr;
  input pwire [8:0] retireRead7_addr;
  input pwire [8:0] retireRead8_addr;

  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire write0_wen;

  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire [DATA_WIDTH-1:0] write1_data;
  input pwire write1_wen;

  input pwire [ADDR_WIDTH-1:0] write2_addr;
  input pwire [DATA_WIDTH-1:0] write2_data;
  input pwire write2_wen;

  input pwire [ADDR_WIDTH-1:0] write3_addr;
  input pwire [DATA_WIDTH-1:0] write3_data;
  input pwire write3_wen;

  input pwire [ADDR_WIDTH-1:0] write4_addr;
  input pwire [DATA_WIDTH-1:0] write4_data;
  input pwire write4_wen;

  input pwire [ADDR_WIDTH-1:0] write5_addr;
  input pwire [DATA_WIDTH-1:0] write5_data;
  input pwire write5_wen;

  input pwire [ADDR_WIDTH-1:0] write6_addr;
  input pwire [DATA_WIDTH-1:0] write6_data;
  input pwire write6_wen;

  input pwire [ADDR_WIDTH-1:0] write7_addr;
  input pwire [DATA_WIDTH-1:0] write7_data;
  input pwire write7_wen;

  input pwire [ADDR_WIDTH-1:0] write8_addr;
  input pwire [DATA_WIDTH-1:0] write8_data;
  input pwire write8_wen;

  input pwire [ADDR_WIDTH-1:0] write9_addr;
  input pwire [DATA_WIDTH-1:0] write9_data;
  input pwire write9_wen;

  pwire [2:0][DATA_WIDTH-1:0] ram_read_data;
  pwire [2:0][DATA_WIDTH-1:0] read_data;
  pwire [2:0][ADDR_WIDTH-1:0] read_addr;
  pwire [8:0][DATA_WIDTH-1:0] ram_retireRead_data;
  pwire [8:0][DATA_WIDTH-1:0] retireRead_data;
  pwire [8:0][DATA_WIDTH-1:0] retireRead_datax;
  pwire [8:0][ADDR_WIDTH-1:0] retireRead_addr;


  pwire read_constEn[2:0];
  pwire read_oe[2:0];

  pwire [ADDR_WIDTH-1:0] write0_addr_reg2;
  pwire write0_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write1_addr_reg2;
  pwire write1_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write2_addr_reg2;
  pwire write2_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write3_addr_reg2;
  pwire write3_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write4_addr_reg2;
  pwire write4_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write5_addr_reg2;
  pwire write5_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write6_addr_reg2;
  pwire write6_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write7_addr_reg2;
  pwire write7_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write8_addr_reg2;
  pwire write8_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write9_addr_reg2;
  pwire write9_wen_reg2;

  pwire [ADDR_WIDTH-1:0] write0_addr_reg;
  pwire write0_wen_reg;

  pwire [ADDR_WIDTH-1:0] write1_addr_reg;
  pwire write1_wen_reg;

  pwire [ADDR_WIDTH-1:0] write2_addr_reg;
  pwire write2_wen_reg;

  pwire [ADDR_WIDTH-1:0] write3_addr_reg;
  pwire write3_wen_reg;

  pwire [ADDR_WIDTH-1:0] write4_addr_reg;
  pwire write4_wen_reg;

  pwire [ADDR_WIDTH-1:0] write5_addr_reg;
  pwire write5_wen_reg;

  pwire [ADDR_WIDTH-1:0] write6_addr_reg;
  pwire write6_wen_reg;

  pwire [ADDR_WIDTH-1:0] write7_addr_reg;
  pwire write7_wen_reg;

  pwire [ADDR_WIDTH-1:0] write8_addr_reg;
  pwire write8_wen_reg;

  pwire [ADDR_WIDTH-1:0] write9_addr_reg;
  pwire write9_wen_reg;

  pwire [DATA_WIDTH-1:0] write0_data_reg;
  pwire [DATA_WIDTH-1:0] write1_data_reg;
  pwire [DATA_WIDTH-1:0] write2_data_reg;
  pwire [DATA_WIDTH-1:0] write3_data_reg;
  pwire [DATA_WIDTH-1:0] write4_data_reg;
  pwire [DATA_WIDTH-1:0] write5_data_reg;
  pwire [DATA_WIDTH-1:0] write6_data_reg;
  pwire [DATA_WIDTH-1:0] write7_data_reg;
  pwire [DATA_WIDTH-1:0] write8_data_reg;
  pwire [DATA_WIDTH-1:0] write9_data_reg;
  pwire [8:0][5:0] write_addr_rrf;
  pwire [8:0]      write_wen_rrf;  
  pwire [8:0][5:0] write_addr_rrfx;
  pwire [8:0]      write_wen_rrfx;  
  
  pwire [10:0] read_match[2:0];
  
  genvar b;

  
  regfile_ram_block_f #(DATA_WIDTH,RS) ram_mod(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,ram_read_data[0],
  read1_addr,ram_read_data[1],
  read2_addr,ram_read_data[2],

  read0_constEn,
  read1_constEn,
  read2_constEn,

  read0_const,
  read1_const,
  read2_const,

  retireRead0_addr,ram_retireRead_data[0],
  retireRead1_addr,ram_retireRead_data[1],
  retireRead2_addr,ram_retireRead_data[2],
  retireRead3_addr,ram_retireRead_data[3],
  retireRead4_addr,ram_retireRead_data[4],
  retireRead5_addr,ram_retireRead_data[5],
  retireRead6_addr,ram_retireRead_data[6],
  retireRead7_addr,ram_retireRead_data[7],
  retireRead8_addr,ram_retireRead_data[8],

  write0_addr_reg2,write0_data_reg,write0_wen_reg2,
  write1_addr_reg2,write1_data_reg,write1_wen_reg2,
  write2_addr_reg2,write2_data_reg,write2_wen_reg2,
  write3_addr_reg2,write3_data_reg,write3_wen_reg2,

  write4_addr_reg2,write4_data_reg,write4_wen_reg2,
  write5_addr_reg2,write5_data_reg,write5_wen_reg2,
  write6_addr_reg2,write6_data_reg,write6_wen_reg2,
  write7_addr_reg2,write7_data_reg,write7_wen_reg2,
  write8_addr_reg2,write8_data_reg,write8_wen_reg2,
  write9_addr_reg2,write9_data_reg,write9_wen_reg2
 );

  rrf_f #(DATA_WIDTH) rrf_m(
  clk,
  rst,
  read_clkEn,
  read0_addr_rrf,read0_data,~read0_oe,
  read1_addr_rrf,read1_data,~read1_oe,
  read2_addr_rrf,read2_data,~read2_oe,
  write_addr_rrfx[0],reatireRead_datax[0],write_wen_rrfx[0],
  write_addr_rrfx[1],reatireRead_datax[1],write_wen_rrfx[1],
  write_addr_rrfx[2],reatireRead_datax[2],write_wen_rrfx[2],
  write_addr_rrfx[3],reatireRead_datax[3],write_wen_rrfx[3],
  write_addr_rrfx[4],reatireRead_datax[4],write_wen_rrfx[4],
  write_addr_rrfx[5],reatireRead_datax[5],write_wen_rrfx[5],
  write_addr_rrfx[6],reatireRead_datax[6],write_wen_rrfx[6],
  write_addr_rrfx[7],reatireRead_datax[7],write_wen_rrfx[7],
  write_addr_rrfx[8],reatireRead_datax[8],write_wen_rrfx[8],
  read_thread,
  write_thread
  );

  assign read0_data=read_data[0];
  assign read1_data=read_data[1];
  assign read2_data=read_data[2];

  assign read_addr[0]=read0_addr;
  assign read_addr[1]=read1_addr;
  assign read_addr[2]=read2_addr;

  assign read_constEn[0]=read0_constEn;
  assign read_constEn[1]=read1_constEn;
  assign read_constEn[2]=read2_constEn;

  assign read_oe[0]=read0_oe;
  assign read_oe[1]=read1_oe;
  assign read_oe[2]=read2_oe;
  
  assign read0_matchV=read_matchV[0];
  assign read1_matchV=read_matchV[1];
  assign read2_matchV=read_matchV[2];

  assign read0_matchF=read_matchF[0];
  assign read1_matchF=read_matchF[1];
  assign read2_matchF=read_matchF[2];
  
  assign write_addr_rrf[0]=write0_addr_rrf;
  assign write_addr_rrf[1]=write1_addr_rrf;
  assign write_addr_rrf[2]=write2_addr_rrf;
  assign write_addr_rrf[3]=write3_addr_rrf;
  assign write_addr_rrf[4]=write4_addr_rrf;
  assign write_addr_rrf[5]=write5_addr_rrf;
  assign write_addr_rrf[6]=write6_addr_rrf;
  assign write_addr_rrf[7]=write7_addr_rrf;
  assign write_addr_rrf[8]=write8_addr_rrf;

  assign write_wen_rrf[0]=write0_wen_rrf;
  assign write_wen_rrf[1]=write1_wen_rrf;
  assign write_wen_rrf[2]=write2_wen_rrf;
  assign write_wen_rrf[3]=write3_wen_rrf;
  assign write_wen_rrf[4]=write4_wen_rrf;
  assign write_wen_rrf[5]=write5_wen_rrf;
  assign write_wen_rrf[6]=write6_wen_rrf;
  assign write_wen_rrf[7]=write7_wen_rrf;
  assign write_wen_rrf[8]=write8_wen_rrf;

  assign retireRead_addr[0]=retireRead0_addr;
  assign retireRead_addr[1]=retireRead1_addr;
  assign retireRead_addr[2]=retireRead2_addr;
  assign retireRead_addr[3]=retireRead3_addr;
  assign retireRead_addr[4]=retireRead4_addr;
  assign retireRead_addr[5]=retireRead5_addr;
  assign retireRead_addr[6]=retireRead6_addr;
  assign retireRead_addr[7]=retireRead7_addr;
  assign retireRead_addr[8]=retireRead8_addr;

  generate for(b=0;b<=8;b=b+1)
    begin
      regfile_zero_cycle_write #(DATA_WIDTH) zcw_mod(
      clk,rst,
      read_clkEn,
      ram_read_data[b],read_dataX[b],read_addr[b],

      read_constEn[b],read_oe[b], read_matchV[b],
      
      write0_addr_reg,write0_wen_reg,
      write1_addr_reg,write1_wen_reg,
      write2_addr_reg,write2_wen_reg,
      write3_addr_reg,write3_wen_reg,
      write4_addr_reg,write4_wen_reg,
      write5_addr_reg,write5_wen_reg,
      write6_addr_reg,write6_wen_reg,
      write7_addr_reg,write7_wen_reg,
      write8_addr_reg,write8_wen_reg,
      write9_addr_reg,write9_wen_reg,
      write0_addr_reg2,write0_wen_reg2,
      write1_addr_reg2,write1_wen_reg2,
      write2_addr_reg2,write2_wen_reg2,
      write3_addr_reg2,write3_wen_reg2,
      write4_addr_reg2,write4_wen_reg2,
      write5_addr_reg2,write5_wen_reg2,
      write6_addr_reg2,write6_wen_reg2,
      write7_addr_reg2,write7_wen_reg2,
      write8_addr_reg2,write8_wen_reg2,
      write9_addr_reg2,write9_wen_reg2,
      write0_data_reg,
      write1_data_reg,
      write2_data_reg,
      write3_data_reg,
      write4_data_reg,
      write5_data_reg,
      write6_data_reg,
      write7_data_reg,
      write8_data_reg,
      write9_data_reg
      );

      regfile_zero_cycle_write #(DATA_WIDTH) zcwX_mod(
      clk,rst,
      read_clkEn,
      read_dataX[b],read_data[b],read_addr[b],

      read_constEn[b],read_oe[b], read_matchF[b],
      
      write0_addr,write0_wen,
      write1_addr,write1_wen,
      write2_addr,write2_wen,
      write3_addr,write3_wen,
      write4_addr,write4_wen,
      write5_addr,write5_wen,
      write6_addr,write6_wen,
      write7_addr,write7_wen,
      write8_addr,write8_wen,
      write9_addr,write9_wen,
      write0_addr_reg,write0_wen_reg,
      write1_addr_reg,write1_wen_reg,
      write2_addr_reg,write2_wen_reg,
      write3_addr_reg,write3_wen_reg,
      write4_addr_reg,write4_wen_reg,
      write5_addr_reg,write5_wen_reg,
      write6_addr_reg,write6_wen_reg,
      write7_addr_reg,write7_wen_reg,
      write8_addr_reg,write8_wen_reg,
      write9_addr_reg,write9_wen_reg,
      write0_data,
      write1_data,
      write2_data,
      write3_data,
      write4_data,
      write5_data,
      write6_data,
      write7_data,
      write8_data,
      write9_data
      );
      
      regfile_zero_cycle_write #(DATA_WIDTH) zcwiR_mod(
      clk,rst,
      read_clkEn,
      ram_retireRead_data[b],retireRead_data[b],retireRead_addr[b],

      1'b0,1'b1,,
      
      write0_addr_reg,write0_wen_reg,
      write1_addr_reg,write1_wen_reg,
      write2_addr_reg,write2_wen_reg,
      write3_addr_reg,write3_wen_reg,
      write4_addr_reg,write4_wen_reg,
      write5_addr_reg,write5_wen_reg,
      write6_addr_reg,write6_wen_reg,
      write7_addr_reg,write7_wen_reg,
      write8_addr_reg,write8_wen_reg,
      write9_addr_reg,write9_wen_reg,
      write0_addr_reg2,write0_wen_reg2,
      write1_addr_reg2,write1_wen_reg2,
      write2_addr_reg2,write2_wen_reg2,
      write3_addr_reg2,write3_wen_reg2,
      write4_addr_reg2,write4_wen_reg2,
      write5_addr_reg2,write5_wen_reg2,
      write6_addr_reg2,write6_wen_reg2,
      write7_addr_reg2,write7_wen_reg2,
      write8_addr_reg2,write8_wen_reg2,
      write9_addr_reg2,write9_wen_reg2,
      write0_data_reg,
      write1_data_reg,
      write2_data_reg,
      write3_data_reg,
      write4_data_reg,
      write5_data_reg,
      write6_data_reg,
      write7_data_reg,
      write8_data_reg,
      write9_data_reg
      );
      cmpx4 #(DATA_WIDTH) ret_mod(clk,clkREF,clkREF2,retireRead_data[b],retireRead_datax[b]);
      cmpx4 #(6) retAddr_mod(clk,clkREF,clkREF2,write_addr_rrf[b],write_addr_rrfx[b]);
      cmpx4 #(1) retEn_mod(clk,clkREF,clkREF2,write_wen_rrf[b],write_wen_rrfx[b]);
    end
  endgenerate

  always @(posedge clk) begin
      if (rst) begin
          write0_addr_reg2<={ADDR_WIDTH{1'B0}};
          write1_addr_reg2<={ADDR_WIDTH{1'B0}};
          write2_addr_reg2<={ADDR_WIDTH{1'B0}};
          write3_addr_reg2<={ADDR_WIDTH{1'B0}};
          write4_addr_reg2<={ADDR_WIDTH{1'B0}};
          write5_addr_reg2<={ADDR_WIDTH{1'B0}};
          write6_addr_reg2<={ADDR_WIDTH{1'B0}};
          write7_addr_reg2<={ADDR_WIDTH{1'B0}};
          write8_addr_reg2<={ADDR_WIDTH{1'B0}};
          write9_addr_reg2<={ADDR_WIDTH{1'B0}};
          
          
          write0_wen_reg2<=1'b0;
          write1_wen_reg2<=1'b0;
          write2_wen_reg2<=1'b0;
          write3_wen_reg2<=1'b0;
          write4_wen_reg2<=1'b0;
          write5_wen_reg2<=1'b0;
          write6_wen_reg2<=1'b0;
          write7_wen_reg2<=1'b0;
          write8_wen_reg2<=1'b0;
          write9_wen_reg2<=1'b0;

          write0_addr_reg<={ADDR_WIDTH{1'B0}};
          write1_addr_reg<={ADDR_WIDTH{1'B0}};
          write2_addr_reg<={ADDR_WIDTH{1'B0}};
          write3_addr_reg<={ADDR_WIDTH{1'B0}};
          write4_addr_reg<={ADDR_WIDTH{1'B0}};
          write5_addr_reg<={ADDR_WIDTH{1'B0}};
          write6_addr_reg<={ADDR_WIDTH{1'B0}};
          write7_addr_reg<={ADDR_WIDTH{1'B0}};
          write8_addr_reg<={ADDR_WIDTH{1'B0}};
          write9_addr_reg<={ADDR_WIDTH{1'B0}};
          
          write0_data_reg<={DATA_WIDTH{1'B0}};
          
          write0_wen_reg<=1'b0;
          write1_wen_reg<=1'b0;
          write2_wen_reg<=1'b0;
          write3_wen_reg<=1'b0;
          write4_wen_reg<=1'b0;
          write5_wen_reg<=1'b0;
          write6_wen_reg<=1'b0;
          write7_wen_reg<=1'b0;
          write8_wen_reg<=1'b0;
          write9_wen_reg<=1'b0;
      end else begin
          if (write0_wen_reg) write0_addr_reg2<=write0_addr_reg;
          if (write1_wen_reg) write1_addr_reg2<=write1_addr_reg;
          if (write2_wen_reg) write2_addr_reg2<=write2_addr_reg;
          if (write3_wen_reg) write3_addr_reg2<=write3_addr_reg;
          if (write4_wen_reg) write4_addr_reg2<=write4_addr_reg;
          if (write5_wen_reg) write5_addr_reg2<=write5_addr_reg;
          if (write6_wen_reg) write6_addr_reg2<=write6_addr_reg;
          if (write7_wen_reg) write7_addr_reg2<=write7_addr_reg;
          if (write8_wen_reg) write8_addr_reg2<=write8_addr_reg;
          if (write9_wen_reg) write9_addr_reg2<=write9_addr_reg;
          
          
          write0_wen_reg2<=write0_wen_reg;
          write1_wen_reg2<=write1_wen_reg;
          write2_wen_reg2<=write2_wen_reg;
          write3_wen_reg2<=write3_wen_reg;
          write4_wen_reg2<=write4_wen_reg;
          write5_wen_reg2<=write5_wen_reg;
          write6_wen_reg2<=write6_wen_reg;
          write7_wen_reg2<=write7_wen_reg;
          write8_wen_reg2<=write8_wen_reg;
          write9_wen_reg2<=write9_wen_reg;

          write0_addr_reg<=write0_addr;
          write0_data_reg<=write0_data;
          write0_wen_reg <=write0_wen;
          write1_addr_reg<=write1_addr;
          write1_data_reg<=write1_data;
          write1_wen_reg <=write1_wen;
          write2_addr_reg<=write2_addr;
          write2_data_reg<=write2_data;
          write2_wen_reg <=write2_wen;
          write3_addr_reg<=write3_addr;
          write3_data_reg<=write3_data;
          write3_wen_reg <=write3_wen;
          write4_addr_reg<=write4_addr;
          write4_data_reg<=write4_data;
          write4_wen_reg <=write4_wen;
          write5_addr_reg<=write5_addr;
          write5_data_reg<=write5_data;
          write5_wen_reg <=write5_wen;
          write6_addr_reg<=write6_addr;
          write6_data_reg<=write6_data;
          write6_wen_reg <=write6_wen;
          write7_addr_reg<=write7_addr;
          write7_data_reg<=write7_data;
          write7_wen_reg <=write7_wen;
          write8_addr_reg<=write8_addr;
          write8_data_reg<=write8_data;
          write8_wen_reg <=write8_wen;
          write9_addr_reg<=write9_addr;
          write9_data_reg<=write9_data;
          write9_wen_reg <=write9_wen;
      end
  end
endmodule





