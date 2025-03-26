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

// main modules: regfile
// the rest are parts of it


//regfile_ram read during write behaviour: write first; untiled memory
//WARNING: data output pwire needs to be updated even if no clkEn; clkEn is only for the addresses.
module reginfl_ram(
  clk,
  rst,
//  retire_clkEn,

  read0_addr,read0_data,read0_clkEn,
  read1_addr,read1_data,read1_clkEn,
  read2_addr,read2_data,read2_clkEn,
  read3_addr,read3_data,read3_clkEn,
  read4_addr,read4_data,read4_clkEn,
  read5_addr,read5_data,read5_clkEn,
  read6_addr,read6_data,read6_clkEn,
  read7_addr,read7_data,read7_clkEn,
  read8_addr,read8_data,read8_clkEn,


  write0_addr,write0_wen,
  write1_addr,write1_wen,
  write2_addr,write2_wen,
  write3_addr,write3_wen,
  write4_addr,write4_wen
  );

  localparam ADDR_WIDTH=5;
  localparam ADDR_COUNT=32;
  
  input pwire clk;
  input pwire rst;
//  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire read0_data;
  input pwire read0_clkEn;
  
  input pwire [ADDR_WIDTH-1:0] read1_addr;
  output pwire read1_data;
  input pwire read1_clkEn;

  input pwire [ADDR_WIDTH-1:0] read2_addr;
  output pwire read2_data;
  input pwire read2_clkEn;

  input pwire [ADDR_WIDTH-1:0] read3_addr;
  output pwire read3_data;
  input pwire read3_clkEn;

  input pwire [ADDR_WIDTH-1:0] read4_addr;
  output pwire read4_data;
  input pwire read4_clkEn;

  input pwire [ADDR_WIDTH-1:0] read5_addr;
  output pwire read5_data;
  input pwire read5_clkEn;

  input pwire [ADDR_WIDTH-1:0] read6_addr;
  output pwire read6_data;
  input pwire read6_clkEn;

  input pwire [ADDR_WIDTH-1:0] read7_addr;
  output pwire read7_data;
  input pwire read7_clkEn;

  input pwire [ADDR_WIDTH-1:0] read8_addr;
  output pwire read8_data;
  input pwire read8_clkEn;




  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire write0_wen;

  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire write1_wen;

  input pwire [ADDR_WIDTH-1:0] write2_addr;
  input pwire write2_wen;

  input pwire [ADDR_WIDTH-1:0] write3_addr;
  input pwire write3_wen;
  
  input pwire [ADDR_WIDTH-1:0] write4_addr;
  input pwire write4_wen;


  pwire [3:0] ram[7:0];

  pwire [ADDR_WIDTH-1:0] read0_addr_reg;
  pwire [ADDR_WIDTH-1:0] read1_addr_reg;
  pwire [ADDR_WIDTH-1:0] read2_addr_reg;
  pwire [ADDR_WIDTH-1:0] read3_addr_reg;
  pwire [ADDR_WIDTH-1:0] read4_addr_reg;
  pwire [ADDR_WIDTH-1:0] read5_addr_reg;
  pwire [ADDR_WIDTH-1:0] read6_addr_reg;
  pwire [ADDR_WIDTH-1:0] read7_addr_reg;
  pwire [ADDR_WIDTH-1:0] read8_addr_reg;


  assign read0_data=ram[read0_addr_reg[4:2]][read0_addr_reg[1:0]];
  assign read1_data=ram[read1_addr_reg[4:2]][read1_addr_reg[1:0]];
  assign read2_data=ram[read2_addr_reg[4:2]][read2_addr_reg[1:0]];
  assign read3_data=ram[read3_addr_reg[4:2]][read3_addr_reg[1:0]];
  assign read4_data=ram[read4_addr_reg[4:2]][read4_addr_reg[1:0]];
  assign read5_data=ram[read5_addr_reg[4:2]][read5_addr_reg[1:0]];
  assign read6_data=ram[read6_addr_reg[4:2]][read6_addr_reg[1:0]];
  assign read7_data=ram[read7_addr_reg[4:2]][read7_addr_reg[1:0]];
  assign read8_data=ram[read8_addr_reg[4:2]][read8_addr_reg[1:0]];



  always @(posedge clk)
    begin
      if (rst)
        begin
          read0_addr_reg<={ADDR_WIDTH{1'b0}};
          read1_addr_reg<={ADDR_WIDTH{1'b0}};
          read2_addr_reg<={ADDR_WIDTH{1'b0}};
          read3_addr_reg<={ADDR_WIDTH{1'b0}};
          read4_addr_reg<={ADDR_WIDTH{1'b0}};
          read5_addr_reg<={ADDR_WIDTH{1'b0}};
          read6_addr_reg<={ADDR_WIDTH{1'b0}};
          read7_addr_reg<={ADDR_WIDTH{1'b0}};
          read8_addr_reg<={ADDR_WIDTH{1'b0}};
        end
      else
      begin
        if (read0_clkEn)
            read0_addr_reg<=read0_addr;
        if (read1_clkEn)
            read1_addr_reg<=read1_addr;
        if (read2_clkEn)
            read2_addr_reg<=read2_addr;
        if (read3_clkEn)
            read3_addr_reg<=read3_addr;
        if (read4_clkEn)
            read4_addr_reg<=read4_addr;
        if (read5_clkEn)
            read5_addr_reg<=read5_addr;
        if (read6_clkEn)
            read6_addr_reg<=read6_addr;
        if (read7_clkEn)
            read7_addr_reg<=read7_addr;
        if (read8_clkEn)
            read8_addr_reg<=read8_addr;
      end
      

      if (write0_wen) ram[write0_addr[4:2]][write0_addr[1:0]]<=1'B0;
      if (write1_wen) ram[write1_addr[4:2]][write1_addr[1:0]]<=1'B0;
      if (write2_wen) ram[write2_addr[4:2]][write2_addr[1:0]]<=1'B0;
      if (write3_wen) ram[write3_addr[4:2]][write3_addr[1:0]]<=1'B0;
      if (write4_wen) ram[write4_addr[4:2]][write4_addr[1:0]]<=1'B1;
    end      
    
endmodule


module reginfl_ram_placeholder(
  clk,
  rst,
  read_clkEn,
//  retire_clkEn,

  read0_addr,read0_data,
  read1_addr,read1_data,
  read2_addr,read2_data,
  read3_addr,read3_data,
  read4_addr,read4_data,
  read5_addr,read5_data,
  read6_addr,read6_data,
  read7_addr,read7_data,
  read8_addr,read8_data,

  read0_constEn,
  read1_constEn,
  read2_constEn,
  read3_constEn,
  read4_constEn,
  read5_constEn,
  read6_constEn,
  read7_constEn,
  read8_constEn,


  write0_addr,write0_wen,
  write1_addr,write1_wen,
  write2_addr,write2_wen,
  write3_addr,write3_wen,
  write4_addr,write4_wen
  );

  localparam DATA_WIDTH=1;
  localparam ADDR_WIDTH=`reg_addr_width;
  parameter [3:0] INDEX=4'd15; //this is to be overriden to match tile index; range 0-8
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
 // input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire [DATA_WIDTH-1:0] read0_data;
  
  input pwire [ADDR_WIDTH-1:0] read1_addr;
  output pwire [DATA_WIDTH-1:0] read1_data;

  input pwire [ADDR_WIDTH-1:0] read2_addr;
  output pwire [DATA_WIDTH-1:0] read2_data;

  input pwire [ADDR_WIDTH-1:0] read3_addr;
  output pwire [DATA_WIDTH-1:0] read3_data;

  input pwire [ADDR_WIDTH-1:0] read4_addr;
  output pwire [DATA_WIDTH-1:0] read4_data;

  input pwire [ADDR_WIDTH-1:0] read5_addr;
  output pwire [DATA_WIDTH-1:0] read5_data;

  input pwire [ADDR_WIDTH-1:0] read6_addr;
  output pwire [DATA_WIDTH-1:0] read6_data;

  input pwire [ADDR_WIDTH-1:0] read7_addr;
  output pwire [DATA_WIDTH-1:0] read7_data;

  input pwire [ADDR_WIDTH-1:0] read8_addr;
  output pwire [DATA_WIDTH-1:0] read8_data;

  input pwire read0_constEn;
  input pwire read1_constEn;
  input pwire read2_constEn;
  input pwire read3_constEn;
  input pwire read4_constEn;
  input pwire read5_constEn;
  input pwire read6_constEn;
  input pwire read7_constEn;
  input pwire read8_constEn;
  

  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire write0_wen;

  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire write1_wen;

  input pwire [ADDR_WIDTH-1:0] write2_addr;
  input pwire write2_wen;

  input pwire [ADDR_WIDTH-1:0] write3_addr;
  input pwire write3_wen;

  input pwire [4:0] write4_addr;
  input pwire write4_wen;

  pwire [ADDR_WIDTH-1:0] read0_addr_reg;
  pwire [ADDR_WIDTH-1:0] read1_addr_reg;
  pwire [ADDR_WIDTH-1:0] read2_addr_reg;
  pwire [ADDR_WIDTH-1:0] read3_addr_reg;
  pwire [ADDR_WIDTH-1:0] read4_addr_reg;
  pwire [ADDR_WIDTH-1:0] read5_addr_reg;
  pwire [ADDR_WIDTH-1:0] read6_addr_reg;
  pwire [ADDR_WIDTH-1:0] read7_addr_reg;
  pwire [ADDR_WIDTH-1:0] read8_addr_reg;



  pwire [DATA_WIDTH-1:0] ram_read0_data;
  pwire [DATA_WIDTH-1:0] ram_read1_data;
  pwire [DATA_WIDTH-1:0] ram_read2_data;
  pwire [DATA_WIDTH-1:0] ram_read3_data;
  pwire [DATA_WIDTH-1:0] ram_read4_data;
  pwire [DATA_WIDTH-1:0] ram_read5_data;
  pwire [DATA_WIDTH-1:0] ram_read6_data;
  pwire [DATA_WIDTH-1:0] ram_read7_data;
  pwire [DATA_WIDTH-1:0] ram_read8_data;


  pwire ram_write0_wen;
  pwire ram_write1_wen;
  pwire ram_write2_wen;
  pwire ram_write3_wen;
  pwire ram_write4_wen;


  pwire read0_clkEn;
  pwire read1_clkEn;
  pwire read2_clkEn;
  pwire read3_clkEn;
  pwire read4_clkEn;
  pwire read5_clkEn;
  pwire read6_clkEn;
  pwire read7_clkEn;
  pwire read8_clkEn;


  pwire read0_en;
  pwire read1_en;
  pwire read2_en;
  pwire read3_en;
  pwire read4_en;
  pwire read5_en;
  pwire read6_en;
  pwire read7_en;
  pwire read8_en;



  reginfl_ram ram_mod(
  clk,
  rst,
 // retire_clkEn,

  read0_addr[8:4],ram_read0_data,read0_clkEn,
  read1_addr[8:4],ram_read1_data,read1_clkEn,
  read2_addr[8:4],ram_read2_data,read2_clkEn,
  read3_addr[8:4],ram_read3_data,read3_clkEn,
  read4_addr[8:4],ram_read4_data,read4_clkEn,
  read5_addr[8:4],ram_read5_data,read5_clkEn,
  read6_addr[8:4],ram_read6_data,read6_clkEn,
  read7_addr[8:4],ram_read7_data,read7_clkEn,
  read8_addr[8:4],ram_read8_data,read8_clkEn,


  write0_addr[8:4],ram_write0_wen,
  write1_addr[8:4],ram_write1_wen,
  write2_addr[8:4],ram_write2_wen,
  write3_addr[8:4],ram_write3_wen,
  write4_addr[4:0],ram_write4_wen
  );

  assign read0_data=read0_en ? ram_read0_data : 'z;
  assign read1_data=read1_en ? ram_read1_data : 'z;
  assign read2_data=read2_en ? ram_read2_data : 'z;
  assign read3_data=read3_en ? ram_read3_data : 'z;
  assign read4_data=read4_en ? ram_read4_data : 'z;
  assign read5_data=read5_en ? ram_read5_data : 'z;
  assign read6_data=read6_en ? ram_read6_data : 'z;
  assign read7_data=read7_en ? ram_read7_data : 'z;
  assign read8_data=read8_en ? ram_read8_data : 'z;

  
  assign ram_write0_wen=write0_wen && write0_addr[3:0]==INDEX;
  assign ram_write1_wen=write1_wen && write1_addr[3:0]==INDEX;
  assign ram_write2_wen=write2_wen && write2_addr[3:0]==INDEX;
  assign ram_write3_wen=write3_wen && write3_addr[3:0]==INDEX;
  assign ram_write4_wen=write4_wen;


  assign read0_clkEn=(read0_addr[3:0]==INDEX) & read_clkEn;
  assign read1_clkEn=(read1_addr[3:0]==INDEX) & read_clkEn;
  assign read2_clkEn=(read2_addr[3:0]==INDEX) & read_clkEn;
  assign read3_clkEn=(read3_addr[3:0]==INDEX) & read_clkEn;
  assign read4_clkEn=(read4_addr[3:0]==INDEX) & read_clkEn;
  assign read5_clkEn=(read5_addr[3:0]==INDEX) & read_clkEn;
  assign read6_clkEn=(read6_addr[3:0]==INDEX) & read_clkEn;
  assign read7_clkEn=(read7_addr[3:0]==INDEX) & read_clkEn;
  assign read8_clkEn=(read8_addr[3:0]==INDEX) & read_clkEn;

  always @(posedge clk)
    begin
      if (rst)
        begin
          read0_en<=1'b0;
          read1_en<=1'b0;
          read2_en<=1'b0;
          read3_en<=1'b0;
          read4_en<=1'b0;
          read5_en<=1'b0;
          read6_en<=1'b0;
          read7_en<=1'b0;
          read8_en<=1'b0;
        end
      else
        if (read_clkEn) begin
          read0_en<=read0_addr[3:0]==INDEX && ~read0_constEn;
          read1_en<=read1_addr[3:0]==INDEX && ~read1_constEn;
          read2_en<=read2_addr[3:0]==INDEX && ~read2_constEn;
          read3_en<=read3_addr[3:0]==INDEX && ~read3_constEn;
          read4_en<=read4_addr[3:0]==INDEX && ~read4_constEn;
          read5_en<=read5_addr[3:0]==INDEX && ~read5_constEn;
          read6_en<=read6_addr[3:0]==INDEX && ~read6_constEn;
          read7_en<=read7_addr[3:0]==INDEX && ~read7_constEn;
          read8_en<=read8_addr[3:0]==INDEX && ~read8_constEn;
        end
    end
endmodule


module reginfl_ram_block(
  clk,
//  clkX,
  rst,
  read_clkEn,
 // retire_clkEn,

  read0_addr,read0_data,
  read1_addr,read1_data,
  read2_addr,read2_data,
  read3_addr,read3_data,
  read4_addr,read4_data,
  read5_addr,read5_data,
  read6_addr,read6_data,
  read7_addr,read7_data,
  read8_addr,read8_data,

  read0_constEn,
  read1_constEn,
  read2_constEn,
  read3_constEn,
  read4_constEn,
  read5_constEn,
  read6_constEn,
  read7_constEn,
  read8_constEn,


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
  newAddr0,newEn0,
  newAddr1,newEn1,
  newAddr2,newEn2,
  newAddr3,newEn3,
  newAddr4,newEn4,
  newAddr5,newEn5,
  newAddr6,newEn6,
  newAddr7,newEn7,
  newAddr8,newEn8,
  doInit
  );

  localparam DATA_WIDTH=1;
  localparam ADDR_WIDTH=`reg_addr_width;
  
  input pwire clk;
 // input pwire clkX;
  input pwire rst;
  input pwire read_clkEn;
 // input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire [DATA_WIDTH-1:0] read0_data;
  
  input pwire [ADDR_WIDTH-1:0] read1_addr;
  output pwire [DATA_WIDTH-1:0] read1_data;

  input pwire [ADDR_WIDTH-1:0] read2_addr;
  output pwire [DATA_WIDTH-1:0] read2_data;

  input pwire [ADDR_WIDTH-1:0] read3_addr;
  output pwire [DATA_WIDTH-1:0] read3_data;

  input pwire [ADDR_WIDTH-1:0] read4_addr;
  output pwire [DATA_WIDTH-1:0] read4_data;

  input pwire [ADDR_WIDTH-1:0] read5_addr;
  output pwire [DATA_WIDTH-1:0] read5_data;

  input pwire [ADDR_WIDTH-1:0] read6_addr;
  output pwire [DATA_WIDTH-1:0] read6_data;

  input pwire [ADDR_WIDTH-1:0] read7_addr;
  output pwire [DATA_WIDTH-1:0] read7_data;

  input pwire [ADDR_WIDTH-1:0] read8_addr;
  output pwire [DATA_WIDTH-1:0] read8_data;


  input pwire read0_constEn;
  input pwire read1_constEn;
  input pwire read2_constEn;
  input pwire read3_constEn;
  input pwire read4_constEn;
  input pwire read5_constEn;
  input pwire read6_constEn;
  input pwire read7_constEn;
  input pwire read8_constEn;
  

  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire write0_wen;

  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire write1_wen;

  input pwire [ADDR_WIDTH-1:0] write2_addr;
  input pwire write2_wen;

  input pwire [ADDR_WIDTH-1:0] write3_addr;
  input pwire write3_wen;

  input pwire [ADDR_WIDTH-1:0] write4_addr;
  input pwire write4_wen;

  input pwire [ADDR_WIDTH-1:0] write5_addr;
  input pwire write5_wen;

  input pwire [ADDR_WIDTH-1:0] write6_addr;
  input pwire write6_wen;

  input pwire [ADDR_WIDTH-1:0] write7_addr;
  input pwire write7_wen;

  input pwire [ADDR_WIDTH-1:0] write8_addr;
  input pwire write8_wen;

  input pwire [ADDR_WIDTH-1:0] write9_addr;
  input pwire write9_wen;

  input pwire [4:0] newAddr0;
  input pwire newEn0;
  input pwire [4:0] newAddr1;
  input pwire newEn1;
  input pwire [4:0] newAddr2;
  input pwire newEn2;
  input pwire [4:0] newAddr3;
  input pwire newEn3;
  input pwire [4:0] newAddr4;
  input pwire newEn4;
  input pwire [4:0] newAddr5;
  input pwire newEn5;
  input pwire [4:0] newAddr6;
  input pwire newEn6;
  input pwire [4:0] newAddr7;
  input pwire newEn7;
  input pwire [4:0] newAddr8;
  input pwire newEn8;
   
  output pwire doInit;
 

  pwire [ADDR_WIDTH-1:0] write0_addr_ram[2:0];
  pwire write0_wen_ram[2:0];
  
  pwire [ADDR_WIDTH-1:0] write1_addr_ram[2:0];
  pwire write1_wen_ram[2:0];
  
  pwire [ADDR_WIDTH-1:0] write2_addr_ram[2:0];
  pwire write2_wen_ram[2:0];



  pwire [ADDR_WIDTH-5:0] initRegCount_next;
  
  pwire [ADDR_WIDTH-1:0] initRegCount;
  pwire doInit;

  pwire [4:0] newAddr [8:0];
  pwire [8:0] newEn;


  pwire read0_constEn_reg;
  pwire read1_constEn_reg;
  pwire read2_constEn_reg;
  pwire read3_constEn_reg;
  pwire read4_constEn_reg;
  pwire read5_constEn_reg;
  pwire read6_constEn_reg;
  pwire read7_constEn_reg;
  pwire read8_constEn_reg;
  
  genvar x;


  
  assign write0_addr_ram[0]=doInit ? initRegCount : write0_addr;
  assign write0_wen_ram[0]=write0_wen | doInit;

  assign write0_addr_ram[1]=doInit ? initRegCount : write1_addr;
  assign write0_wen_ram[1]=write1_wen | doInit;
  
  assign write0_addr_ram[2]=doInit ? initRegCount : write2_addr;
  assign write0_wen_ram[2]=write2_wen | doInit;

  assign write1_addr_ram[0]=write4_addr;
  assign write1_wen_ram[0]=write4_wen;

  assign write2_addr_ram[0]=write7_addr;
  assign write2_wen_ram[0]=write7_wen;

  assign write1_addr_ram[1]=write5_addr;
  assign write1_wen_ram[1]=write5_wen;

  assign write2_addr_ram[1]=write8_addr;
  assign write2_wen_ram[1]=write8_wen;
  
  assign write1_addr_ram[2]=write6_addr;
  assign write1_wen_ram[2]=write6_wen;

  assign write2_addr_ram[2]=write9_addr;
  assign write2_wen_ram[2]=write9_wen;
   
  
  assign read0_data=read0_constEn_reg ? 1'b0 : 'z;
  assign read1_data=read1_constEn_reg ? 1'b0 : 'z;
  assign read2_data=read2_constEn_reg ? 1'b0 : 'z;
  assign read3_data=read3_constEn_reg ? 1'b0 : 'z;
  assign read4_data=read4_constEn_reg ? 1'b0 : 'z;
  assign read5_data=read5_constEn_reg ? 1'b0 : 'z;
  assign read6_data=read6_constEn_reg ? 1'b0 : 'z;
  assign read7_data=read7_constEn_reg ? 1'b0 : 'z;
  assign read8_data=read8_constEn_reg ? 1'b0 : 'z;

  assign newAddr[0]=newAddr0;
  assign newAddr[1]=newAddr1;
  assign newAddr[2]=newAddr2;
  assign newAddr[3]=newAddr3;
  assign newAddr[4]=newAddr4;
  assign newAddr[5]=newAddr5;
  assign newAddr[6]=newAddr6;
  assign newAddr[7]=newAddr7;
  assign newAddr[8]=newAddr8;
  
  assign newEn[0]=newEn0;
  assign newEn[1]=newEn1;
  assign newEn[2]=newEn2;
  assign newEn[3]=newEn3;
  assign newEn[4]=newEn4;
  assign newEn[5]=newEn5;
  assign newEn[6]=newEn6;
  assign newEn[7]=newEn7;
  assign newEn[8]=newEn8;



  adder_inc #(ADDR_WIDTH-4) initInc_mod(initRegCount[ADDR_WIDTH-1:4],initRegCount_next,1'b1,);

  
  
  generate
    for(x=0;x<=8;x=x+1)
	  begin : rams
		
        reginfl_ram_placeholder #(x) ram_mod(
          clk,
   //       clkX,
          rst,
          read_clkEn,
 //         retire_clkEn,

          read0_addr,read0_data,
          read1_addr,read1_data,
          read2_addr,read2_data,
          read3_addr,read3_data,
          read4_addr,read4_data,
          read5_addr,read5_data,
          read6_addr,read6_data,
          read7_addr,read7_data,
          read8_addr,read8_data,

          read0_constEn,
          read1_constEn,
          read2_constEn,
          read3_constEn,
          read4_constEn,
          read5_constEn,
          read6_constEn,
          read7_constEn,
          read8_constEn,

          write0_addr_ram[x%3],write0_wen_ram[x%3],
          write1_addr_ram[x%3],write1_wen_ram[x%3],
          write2_addr_ram[x%3],write2_wen_ram[x%3],
          write3_addr,write3_wen,
	  newAddr[x],newEn[x]
        );
      end
  endgenerate

  always @(posedge clk)
    begin
      if (rst)
        begin
          doInit<=1'b1;
          initRegCount<={ADDR_WIDTH{1'b0}};
		  read0_constEn_reg<=1'b0;
		  read1_constEn_reg<=1'b0;
		  read2_constEn_reg<=1'b0;
		  read3_constEn_reg<=1'b0;
		  read4_constEn_reg<=1'b0;
		  read5_constEn_reg<=1'b0;
		  read6_constEn_reg<=1'b0;
		  read7_constEn_reg<=1'b0;
		  read8_constEn_reg<=1'b0;
        end
      else
        begin
          if (doInit)
            case(initRegCount[3:0])
              0: initRegCount[3:0]<=4'd1;
              1: initRegCount[3:0]<=4'd2;
              2: initRegCount[3:0]<=4'd3;
              3: initRegCount[3:0]<=4'd4;
              4: initRegCount[3:0]<=4'd5;
              5: initRegCount[3:0]<=4'd6;
              6: initRegCount[3:0]<=4'd7;
              7: initRegCount[3:0]<=4'd8;
              8: initRegCount<={initRegCount_next,4'd0};          
            endcase
          if ((initRegCount[ADDR_WIDTH-1:4]==(31)) & (pwh#(4)::cmpEQ(initRegCount[3:0],4'd8)))
            doInit<=1'b0; 
		  if (read_clkEn)
		    begin
			  
			  read0_constEn_reg<=read0_constEn;
			  read1_constEn_reg<=read1_constEn;
			  read2_constEn_reg<=read2_constEn;
			  read3_constEn_reg<=read3_constEn;
			  read4_constEn_reg<=read4_constEn;
			  read5_constEn_reg<=read5_constEn;
			  read6_constEn_reg<=read6_constEn;
			  read7_constEn_reg<=read7_constEn;
			  read8_constEn_reg<=read8_constEn;
			end
        end
    end
  
endmodule


//module to create correct write-first behaviour
//shared with flags registers by overriding data parameter
module reginfl_zero_cycle_write(
  clk,rst,
  read_clkEn,
  read_data_ram,read_data_new,read_addr,
  read_constEn,read_oe,
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
  init
  );
  localparam DATA_WIDTH=1;
  localparam ADDR_WIDTH=`reg_addr_width;
  parameter OE_IN=1'b0;
  
  input pwire clk;
  input pwire rst;

  input pwire read_clkEn;
  
  input pwire [DATA_WIDTH-1:0] read_data_ram;
  output pwire [DATA_WIDTH-1:0] read_data_new;
  input pwire [ADDR_WIDTH-1:0] read_addr;

  input pwire read_constEn;
  input pwire read_oe;
  
  
  input pwire [ADDR_WIDTH-1:0] write0_addr_reg;
  input pwire write0_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write1_addr_reg;
  input pwire write1_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write2_addr_reg;
  input pwire write2_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write3_addr_reg;
  input pwire write3_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write4_addr_reg;
  input pwire write4_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write5_addr_reg;
  input pwire write5_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write6_addr_reg;
  input pwire write6_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write7_addr_reg;
  input pwire write7_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write8_addr_reg;
  input pwire write8_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write9_addr_reg;
  input pwire write9_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write0_addr_reg2;
  input pwire write0_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write1_addr_reg2;
  input pwire write1_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write2_addr_reg2;
  input pwire write2_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write3_addr_reg2;
  input pwire write3_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write4_addr_reg2;
  input pwire write4_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write5_addr_reg2;
  input pwire write5_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write6_addr_reg2;
  input pwire write6_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write7_addr_reg2;
  input pwire write7_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write8_addr_reg2;
  input pwire write8_wen_reg2;

  input pwire [ADDR_WIDTH-1:0] write9_addr_reg2;
  input pwire write9_wen_reg2;

  input pwire init;

  
  
  pwire match_r0;
  pwire match_r1;
  pwire match_r2;
  pwire match_r3;
  pwire match_r4;
  pwire match_r5;
  pwire match_r6;
  pwire match_r7;
  pwire match_r8;
  pwire match_r9;

  pwire match;

  pwire read_constEn_reg;

  pwire read_oe_reg;
  pwire [ADDR_WIDTH-1:0] read_addr_reg;

  pwire [10:0] match_w;

  assign read_data_new=(init & OE_IN) ? 1'b0 : 1'bz;
  
  assign match=|{match_r0,match_r1,match_r2,match_r3,match_r4,match_r5,match_r6,match_r7,match_r8,match_r9};

  assign read_data_new=(match & read_oe_reg) ? 1'b0 : 1'bz;

  assign read_data_new=(match | ~read_oe_reg) ? 1'bz : read_data_ram & match_w[10] & ~read_constEn_reg;
  
  assign match_w[0]=pwh#(32)::cmpEQ(read_addr_reg,write0_addr_reg) && write0_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[1]=pwh#(32)::cmpEQ(read_addr_reg,write1_addr_reg) && write1_wen_reg &&
     ~read_constEn_reg  && read_oe_reg;
  assign match_w[2]=pwh#(32)::cmpEQ(read_addr_reg,write2_addr_reg) && write2_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[3]=pwh#(32)::cmpEQ(read_addr_reg,write3_addr_reg) && write3_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[4]=pwh#(32)::cmpEQ(read_addr_reg,write4_addr_reg) && write4_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[5]=pwh#(32)::cmpEQ(read_addr_reg,write5_addr_reg) && write5_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[6]=pwh#(32)::cmpEQ(read_addr_reg,write6_addr_reg) && write6_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[7]=pwh#(32)::cmpEQ(read_addr_reg,write7_addr_reg) && write7_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[8]=pwh#(32)::cmpEQ(read_addr_reg,write8_addr_reg) && write8_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  assign match_w[9]=pwh#(32)::cmpEQ(read_addr_reg,write9_addr_reg) && write9_wen_reg &&
     ~read_constEn_reg && read_oe_reg;
  
  assign match_w[10]=~(|{match_w[0],match_w[1],match_w[2],match_w[3],match_w[4],match_w[5],
    match_w[6],match_w[7],match_w[8],match_w[9]});

 assign match_r0=pwh#(32)::cmpEQ(read_addr_reg,write0_addr_reg2) && write0_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;
  assign match_r1=pwh#(32)::cmpEQ(read_addr_reg,write1_addr_reg2) && write1_wen_reg2 &&
     ~read_constEn_reg  && read_oe_reg;
  assign match_r2=pwh#(32)::cmpEQ(read_addr_reg,write2_addr_reg2) && write2_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;
  assign match_r3=pwh#(32)::cmpEQ(read_addr_reg,write3_addr_reg2) && write3_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;
  assign match_r4=pwh#(32)::cmpEQ(read_addr_reg,write4_addr_reg2) && write4_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;
  assign match_r5=pwh#(32)::cmpEQ(read_addr_reg,write5_addr_reg2) && write5_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;
  assign match_r6=pwh#(32)::cmpEQ(read_addr_reg,write6_addr_reg2) && write6_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;
  assign match_r7=pwh#(32)::cmpEQ(read_addr_reg,write7_addr_reg2) && write7_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;
  assign match_r8=pwh#(32)::cmpEQ(read_addr_reg,write8_addr_reg2) && write8_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;
  assign match_r9=pwh#(32)::cmpEQ(read_addr_reg,write9_addr_reg2) && write9_wen_reg2 &&
     ~read_constEn_reg && read_oe_reg;

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
              read_oe_reg<=read_oe & ~init;
     	      read_addr_reg<=read_addr;
            end
        end
    end
endmodule



module reginfl(
  clk,
  rst,
  read_clkEn,
//  retire_clkEn,

  read0_addr,read0_data,read0_oe,
  read1_addr,read1_data,read1_oe,
  read2_addr,read2_data,read2_oe,
  read3_addr,read3_data,read3_oe,
  read4_addr,read4_data,read4_oe,
  read5_addr,read5_data,read5_oe,
  read6_addr,read6_data,read6_oe,
  read7_addr,read7_data,read7_oe,
  read8_addr,read8_data,read8_oe,

  read0_constEn,
  read1_constEn,
  read2_constEn,
  read3_constEn,
  read4_constEn,
  read5_constEn,
  read6_constEn,
  read7_constEn,
  read8_constEn,


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
  newAddr0,newEn0,
  newAddr1,newEn1,
  newAddr2,newEn2,
  newAddr3,newEn3,
  newAddr4,newEn4,
  newAddr5,newEn5,
  newAddr6,newEn6,
  newAddr7,newEn7,
  newAddr8,newEn8
  );
  localparam DATA_WIDTH=1;
  localparam ADDR_WIDTH=`reg_addr_width;
  parameter OE_IN=1'b0;
 
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
//  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire [DATA_WIDTH-1:0] read0_data;
  input pwire read0_oe;

  input pwire [ADDR_WIDTH-1:0] read1_addr;
  output pwire [DATA_WIDTH-1:0] read1_data;
  input pwire read1_oe;

  input pwire [ADDR_WIDTH-1:0] read2_addr;
  output pwire [DATA_WIDTH-1:0] read2_data;
  input pwire read2_oe;

  input pwire [ADDR_WIDTH-1:0] read3_addr;
  output pwire [DATA_WIDTH-1:0] read3_data;
  input pwire read3_oe;

  input pwire [ADDR_WIDTH-1:0] read4_addr;
  output pwire [DATA_WIDTH-1:0] read4_data;
  input pwire read4_oe;

  input pwire [ADDR_WIDTH-1:0] read5_addr;
  output pwire [DATA_WIDTH-1:0] read5_data;
  input pwire read5_oe;

  input pwire [ADDR_WIDTH-1:0] read6_addr;
  output pwire [DATA_WIDTH-1:0] read6_data;
  input pwire read6_oe;

  input pwire [ADDR_WIDTH-1:0] read7_addr;
  output pwire [DATA_WIDTH-1:0] read7_data;
  input pwire read7_oe;

  input pwire [ADDR_WIDTH-1:0] read8_addr;
  output pwire [DATA_WIDTH-1:0] read8_data;
  input pwire read8_oe;

  input pwire read0_constEn;
  input pwire read1_constEn;
  input pwire read2_constEn;
  input pwire read3_constEn;
  input pwire read4_constEn;
  input pwire read5_constEn;
  input pwire read6_constEn;
  input pwire read7_constEn;
  input pwire read8_constEn;


  input pwire [ADDR_WIDTH-1:0] write0_addr_reg;
  input pwire write0_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write1_addr_reg;
  input pwire write1_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write2_addr_reg;
  input pwire write2_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write3_addr_reg;
  input pwire write3_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write4_addr_reg;
  input pwire write4_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write5_addr_reg;
  input pwire write5_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write6_addr_reg;
  input pwire write6_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write7_addr_reg;
  input pwire write7_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write8_addr_reg;
  input pwire write8_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write9_addr_reg;
  input pwire write9_wen_reg;

  input pwire [4:0] newAddr0;
  input pwire newEn0;
  input pwire [4:0] newAddr1;
  input pwire newEn1;
  input pwire [4:0] newAddr2;
  input pwire newEn2;
  input pwire [4:0] newAddr3;
  input pwire newEn3;
  input pwire [4:0] newAddr4;
  input pwire newEn4;
  input pwire [4:0] newAddr5;
  input pwire newEn5;
  input pwire [4:0] newAddr6;
  input pwire newEn6;
  input pwire [4:0] newAddr7;
  input pwire newEn7;
  input pwire [4:0] newAddr8;
  input pwire newEn8;

  pwire [8:0][DATA_WIDTH-1:0] ram_read_data;
  pwire [8:0][DATA_WIDTH-1:0] read_data;
  pwire [8:0][ADDR_WIDTH-1:0] read_addr;


  pwire read_constEn[8:0];
  pwire read_oe[8:0];

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
  
  pwire init;
  
  pwire [10:0] read_match[8:0];
  
  genvar b;

  
  reginfl_ram_block ram_mod(
  clk,
  rst,
  read_clkEn,
 // retire_clkEn,

  read0_addr,ram_read_data[0],
  read1_addr,ram_read_data[1],
  read2_addr,ram_read_data[2],
  read3_addr,ram_read_data[3],
  read4_addr,ram_read_data[4],
  read5_addr,ram_read_data[5],
  read6_addr,ram_read_data[6],
  read7_addr,ram_read_data[7],
  read8_addr,ram_read_data[8],

  read0_constEn,
  read1_constEn,
  read2_constEn,
  read3_constEn,
  read4_constEn,
  read5_constEn,
  read6_constEn,
  read7_constEn,
  read8_constEn,


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
  newAddr0,newEn0,
  newAddr1,newEn1,
  newAddr2,newEn2,
  newAddr3,newEn3,
  newAddr4,newEn4,
  newAddr5,newEn5,
  newAddr6,newEn6,
  newAddr7,newEn7,
  newAddr8,newEn8,
  init
 );

  assign read0_data=read_data[0];
  assign read1_data=read_data[1];
  assign read2_data=read_data[2];
  assign read3_data=read_data[3];
  assign read4_data=read_data[4];
  assign read5_data=read_data[5];
  assign read6_data=read_data[6];
  assign read7_data=read_data[7];
  assign read8_data=read_data[8];

  assign read_addr[0]=read0_addr;
  assign read_addr[1]=read1_addr;
  assign read_addr[2]=read2_addr;
  assign read_addr[3]=read3_addr;
  assign read_addr[4]=read4_addr;
  assign read_addr[5]=read5_addr;
  assign read_addr[6]=read6_addr;
  assign read_addr[7]=read7_addr;
  assign read_addr[8]=read8_addr;

  assign read_constEn[0]=read0_constEn;
  assign read_constEn[1]=read1_constEn;
  assign read_constEn[2]=read2_constEn;
  assign read_constEn[3]=read3_constEn;
  assign read_constEn[4]=read4_constEn;
  assign read_constEn[5]=read5_constEn;
  assign read_constEn[6]=read6_constEn;
  assign read_constEn[7]=read7_constEn;
  assign read_constEn[8]=read8_constEn;

  assign read_oe[0]=read0_oe;
  assign read_oe[1]=read1_oe;
  assign read_oe[2]=read2_oe;
  assign read_oe[3]=read3_oe;
  assign read_oe[4]=read4_oe;
  assign read_oe[5]=read5_oe;
  assign read_oe[6]=read6_oe;
  assign read_oe[7]=read7_oe;
  assign read_oe[8]=read8_oe;
  
  
  generate for(b=0;b<=8;b=b+1)
    begin
      reginfl_zero_cycle_write #(OE_IN) zcw_mod(
      clk,rst,
      read_clkEn,
      ram_read_data[b],read_data[b],read_addr[b],

      read_constEn[b],read_oe[b],
      
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
      init
      );
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
      end else begin
          write0_addr_reg2<=write0_addr_reg;
          write1_addr_reg2<=write1_addr_reg;
          write2_addr_reg2<=write2_addr_reg;
          write3_addr_reg2<=write3_addr_reg;
          write4_addr_reg2<=write4_addr_reg;
          write5_addr_reg2<=write5_addr_reg;
          write6_addr_reg2<=write6_addr_reg;
          write7_addr_reg2<=write7_addr_reg;
          write8_addr_reg2<=write8_addr_reg;
          write9_addr_reg2<=write9_addr_reg;
          
          
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
      end
  end
endmodule



