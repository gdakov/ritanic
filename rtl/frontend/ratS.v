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


module rat_flags_buf(
  clk,
  rst,
  read_clkEn,
//data is free register
  read0_data,read0_funit,read0_retired,

  writeNew1_data,writeNew1_funit,writeNew1_wen,
  writeNew2_data,writeNew2_funit,writeNew2_wen,
  writeNew4_data,writeNew4_funit,writeNew4_wen,
  writeNew5_data,writeNew5_funit,writeNew5_wen,
  writeNew7_data,writeNew7_funit,writeNew7_wen,
  writeNew8_data,writeNew8_funit,writeNew8_wen,
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
  retireAll,
  read_thread,write_thread,ret_thread
  );

//override index with physical register number
  parameter INDEX=0;
  localparam RAT_ADDR_WIDTH=`rat_addr_width;
  localparam ROB_ADDR_WIDTH=`reg_addr_width;
  localparam FN_WIDTH=10;

  input clk;
  input rst;

  input read_clkEn;

  output [ROB_ADDR_WIDTH-1:0] read0_data;
  output [FN_WIDTH-1:0] read0_funit;
  output read0_retired;

  input [ROB_ADDR_WIDTH-1:0] writeNew1_data;
  input [FN_WIDTH-1:0] writeNew1_funit;
  input writeNew1_wen;
  input [ROB_ADDR_WIDTH-1:0] writeNew2_data;
  input [FN_WIDTH-1:0] writeNew2_funit;
  input writeNew2_wen;
  input [ROB_ADDR_WIDTH-1:0] writeNew4_data;
  input [FN_WIDTH-1:0] writeNew4_funit;
  input writeNew4_wen;
  input [ROB_ADDR_WIDTH-1:0] writeNew5_data;
  input [FN_WIDTH-1:0] writeNew5_funit;
  input writeNew5_wen;
  input [ROB_ADDR_WIDTH-1:0] writeNew7_data;
  input [FN_WIDTH-1:0] writeNew7_funit;
  input writeNew7_wen;
  input [ROB_ADDR_WIDTH-1:0] writeNew8_data;
  input [FN_WIDTH-1:0] writeNew8_funit;
  input writeNew8_wen;

  input [ROB_ADDR_WIDTH-1:0] writeRet0_addr;
  input writeRet0_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet1_addr;
  input writeRet1_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet2_addr;
  input writeRet2_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet3_addr;
  input writeRet3_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet4_addr;
  input writeRet4_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet5_addr;
  input writeRet5_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet6_addr;
  input writeRet6_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet7_addr;
  input writeRet7_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet8_addr;
  input writeRet8_wen;

  input retireAll;
  
  input read_thread;
  input write_thread;
  input ret_thread;
  
  reg [ROB_ADDR_WIDTH-1:0] robAddr[1:0];
  reg retired[1:0];
  reg [FN_WIDTH-1:0] funit[1:0];
  
  wire match_new;

  wire match_ret0[1:0];  
  wire match_ret1[1:0];  
  wire match_ret2[1:0];  
  wire match_ret3[1:0];  
  wire match_ret4[1:0];  
  wire match_ret5[1:0];
  wire match_ret6[1:0];
  wire match_ret7[1:0];
  wire match_ret8[1:0];

  wire match_ret[1:0];

  wire [ROB_ADDR_WIDTH-1:0] robAddr_d;
  
  wire retired_d[1:0];

  wire [FN_WIDTH-1:0] funit_d;

  wire match_rd0;
  wire match_rd1;
  wire match_rd2;
  wire match_rd3;
  wire match_rd4;
  wire match_rd5;
  wire match_rd6;
  wire match_rd7;
  wire match_rd8;
  

  assign match_new=|{writeNew1_wen,writeNew2_wen,writeNew4_wen,writeNew5_wen
    ,writeNew7_wen,writeNew8_wen};

  assign match_ret0[0]=(writeRet0_addr==robAddr[0]) & writeRet0_wen;    
  assign match_ret1[0]=(writeRet1_addr==robAddr[0]) & writeRet1_wen;    
  assign match_ret2[0]=(writeRet2_addr==robAddr[0]) & writeRet2_wen;    
  assign match_ret3[0]=(writeRet3_addr==robAddr[0]) & writeRet3_wen;    
  assign match_ret4[0]=(writeRet4_addr==robAddr[0]) & writeRet4_wen;    
  assign match_ret5[0]=(writeRet5_addr==robAddr[0]) & writeRet5_wen;    
  assign match_ret6[0]=(writeRet6_addr==robAddr[0]) & writeRet6_wen;    
  assign match_ret7[0]=(writeRet7_addr==robAddr[0]) & writeRet7_wen;    
  assign match_ret8[0]=(writeRet5_addr==robAddr[0]) & writeRet8_wen;    

  assign match_ret[0]=|{match_ret0[0],match_ret1[0],match_ret2[0],match_ret3[0],
    match_ret4[0],match_ret5[0],match_ret6[0],match_ret7[0],match_ret8[0]};

  assign match_ret0[1]=(writeRet0_addr==robAddr[1]) & writeRet0_wen;    
  assign match_ret1[1]=(writeRet1_addr==robAddr[1]) & writeRet1_wen;    
  assign match_ret2[1]=(writeRet2_addr==robAddr[1]) & writeRet2_wen;    
  assign match_ret3[1]=(writeRet3_addr==robAddr[1]) & writeRet3_wen;    
  assign match_ret4[1]=(writeRet4_addr==robAddr[1]) & writeRet4_wen;    
  assign match_ret5[1]=(writeRet5_addr==robAddr[1]) & writeRet5_wen;    
  assign match_ret6[1]=(writeRet6_addr==robAddr[1]) & writeRet6_wen;    
  assign match_ret7[1]=(writeRet7_addr==robAddr[1]) & writeRet7_wen;    
  assign match_ret8[1]=(writeRet5_addr==robAddr[1]) & writeRet8_wen;    

  assign match_ret[1]=|{match_ret0[1],match_ret1[1],match_ret2[1],match_ret3[1],
    match_ret4[1],match_ret5[1],match_ret6[1],match_ret7[1],match_ret8[1]};
	

  assign robAddr_d=(writeNew1_wen & ~rst) ? writeNew1_data : 'z;
  assign robAddr_d=(writeNew2_wen & ~rst) ? writeNew2_data : 'z;
  assign robAddr_d=(writeNew4_wen & ~rst) ? writeNew4_data : 'z;
  assign robAddr_d=(writeNew5_wen & ~rst) ? writeNew5_data : 'z;
  assign robAddr_d=(writeNew7_wen & ~rst) ? writeNew7_data : 'z;
  assign robAddr_d=(writeNew8_wen & ~rst) ? writeNew8_data : 'z;

  assign robAddr_d=(rst | ~match_new) ? {ROB_ADDR_WIDTH{1'b0}} : 'z;

  assign retired_d[0]=match_ret[0] & ~(match_new & read_clkEn) || rst || retireAll; 
  assign retired_d[1]=match_ret[1] & ~(match_new & read_clkEn) || rst || retireAll; 

  assign funit_d=(writeNew1_wen & ~rst) ? writeNew1_funit : 'z;
  assign funit_d=(writeNew2_wen & ~rst) ? writeNew2_funit : 'z;
  assign funit_d=(writeNew4_wen & ~rst) ? writeNew4_funit : 'z;
  assign funit_d=(writeNew5_wen & ~rst) ? writeNew5_funit : 'z;
  assign funit_d=(writeNew7_wen & ~rst) ? writeNew7_funit : 'z;
  assign funit_d=(writeNew8_wen & ~rst) ? writeNew8_funit : 'z;

  assign funit_d=(rst | ~match_new) ? 10'b1001 : 'z;

  assign read0_data=robAddr[read_thread];  

  assign read0_retired=retired[read_thread];  

  assign read0_funit=funit[read_thread];
  
  always @(posedge clk)
    begin
      if (~write_thread & match_new || rst) robAddr[0]<=robAddr_d;
      if ( write_thread & match_new || rst) robAddr[1]<=robAddr_d;
      if (~write_thread & match_new || rst) funit[0]<=funit_d;
      if ( write_thread & match_new || rst) funit[1]<=funit_d;
      if (match_ret[0] & ~ret_thread || match_new & ~write_thread 
	    || retireAll & ~ret_thread || rst) retired[0]<=retired_d[0];
      if (match_ret[1] & ret_thread || match_new & write_thread 
	    || retireAll & ret_thread || rst) retired[1]<=retired_d[1];
    end   
endmodule




module rat_flags_dep(
  addr,
  data,
  retired,
  funit,
  rs0i0_index,rs0i1_index,rs0i2_index,
  rs1i0_index,rs1i1_index,rs1i2_index,
  rs2i0_index,rs2i1_index,rs2i2_index,
  newR0,newR1,newR2,newR3,newR4,newR5,newR6,newR7,newR8,
  newU0,newU1,newU2,newU3,newU4,newU5,newU6,newU7,newU8
  );


  localparam RAT_ADDR_WIDTH=4;
  localparam ROB_ADDR_WIDTH=`reg_addr_width;
  localparam FN_WIDTH=10;

  input [RAT_ADDR_WIDTH-1:0] addr;
  output [ROB_ADDR_WIDTH-1:0] data;
  output retired;
  output [FN_WIDTH-1:0] funit;
  
  input [3:0] rs0i0_index;
  input [3:0] rs0i1_index;
  input [3:0] rs0i2_index;
  input [3:0] rs1i0_index;
  input [3:0] rs1i1_index;
  input [3:0] rs1i2_index;
  input [3:0] rs2i0_index;
  input [3:0] rs2i1_index;
  input [3:0] rs2i2_index;

  input [ROB_ADDR_WIDTH-1:0] newR0;
  input [ROB_ADDR_WIDTH-1:0] newR1;
  input [ROB_ADDR_WIDTH-1:0] newR2;
  input [ROB_ADDR_WIDTH-1:0] newR3;
  input [ROB_ADDR_WIDTH-1:0] newR4;
  input [ROB_ADDR_WIDTH-1:0] newR5;
  input [ROB_ADDR_WIDTH-1:0] newR6;
  input [ROB_ADDR_WIDTH-1:0] newR7;
  input [ROB_ADDR_WIDTH-1:0] newR8;

  input [FN_WIDTH-1:0] newU0;
  input [FN_WIDTH-1:0] newU1;
  input [FN_WIDTH-1:0] newU2;
  input [FN_WIDTH-1:0] newU3;
  input [FN_WIDTH-1:0] newU4;
  input [FN_WIDTH-1:0] newU5;
  input [FN_WIDTH-1:0] newU6;
  input [FN_WIDTH-1:0] newU7;
  input [FN_WIDTH-1:0] newU8;


  assign data=(addr==rs0i0_index)? newR0 : 'z;
  assign data=(addr==rs0i1_index)? newR1 : 'z;
  assign data=(addr==rs0i2_index)? newR2 : 'z;
  assign data=(addr==rs1i0_index)? newR3 : 'z;
  assign data=(addr==rs1i1_index)? newR4 : 'z;
  assign data=(addr==rs1i2_index)? newR5 : 'z;
  assign data=(addr==rs2i0_index)? newR6 : 'z;
  assign data=(addr==rs2i1_index)? newR7 : 'z;
  assign data=(addr==rs2i2_index)? newR8 : 'z;

  assign funit=(addr==rs0i0_index)? newU0 : 'z;
  assign funit=(addr==rs0i1_index)? newU1 : 'z;
  assign funit=(addr==rs0i2_index)? newU2 : 'z;
  assign funit=(addr==rs1i0_index)? newU3 : 'z;
  assign funit=(addr==rs1i1_index)? newU4 : 'z;
  assign funit=(addr==rs1i2_index)? newU5 : 'z;
  assign funit=(addr==rs2i0_index)? newU6 : 'z;
  assign funit=(addr==rs2i1_index)? newU7 : 'z;
  assign funit=(addr==rs2i2_index)? newU8 : 'z;

  assign retired=(addr!=4'he && addr!=4'hd) ? 1'b0 : 1'bz;
endmodule



module rat_flags(
  clk,
  rst,
  read_clkEn,
  newR0,newR1,newR2,newR3,newR4,newR5,newR6,newR7,newR8,
  newU0,newU1,newU2,newU3,newU4,newU5,newU6,newU7,newU8,
  //from here addr is retirement register
  read1_addr,read1_data,read1_retired,read1_fun,
  read2_addr,read2_data,read2_retired,read2_fun,
  read4_addr,read4_data,read4_retired,read4_fun,
  read5_addr,read5_data,read5_retired,read5_fun,
  read7_addr,read7_data,read7_retired,read7_fun,
  read8_addr,read8_data,read8_retired,read8_fun,
  r_data, r_retired,r_fun,
  
  writeNew0_wen,
  writeNew1_wen,
  writeNew2_wen,
  writeNew3_wen,
  writeNew4_wen,
  writeNew5_wen,
  writeNew6_wen,
  writeNew7_wen,
  writeNew8_wen,
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
  retireAll,

  rs0i0_index,rs0i1_index,rs0i2_index,
  rs1i0_index,rs1i1_index,rs1i2_index,
  rs2i0_index,rs2i1_index,rs2i2_index,
  read_thread,ret_thread
  );

  parameter RAT_ADDR_WIDTH=4;
  parameter ROB_ADDR_WIDTH=`reg_addr_width;
  parameter FN_WIDTH=10;

  input clk;
  input rst;
  input read_clkEn;

  input [ROB_ADDR_WIDTH-1:0] newR0;
  input [ROB_ADDR_WIDTH-1:0] newR1;
  input [ROB_ADDR_WIDTH-1:0] newR2;
  input [ROB_ADDR_WIDTH-1:0] newR3;
  input [ROB_ADDR_WIDTH-1:0] newR4;
  input [ROB_ADDR_WIDTH-1:0] newR5;
  input [ROB_ADDR_WIDTH-1:0] newR6;
  input [ROB_ADDR_WIDTH-1:0] newR7;
  input [ROB_ADDR_WIDTH-1:0] newR8;

  input [FN_WIDTH-1:0] newU0;
  input [FN_WIDTH-1:0] newU1;
  input [FN_WIDTH-1:0] newU2;
  input [FN_WIDTH-1:0] newU3;
  input [FN_WIDTH-1:0] newU4;
  input [FN_WIDTH-1:0] newU5;
  input [FN_WIDTH-1:0] newU6;
  input [FN_WIDTH-1:0] newU7;
  input [FN_WIDTH-1:0] newU8;

  input [RAT_ADDR_WIDTH-1:0] read1_addr;
  output [ROB_ADDR_WIDTH-1:0] read1_data;
  output read1_retired;
  output [FN_WIDTH-1:0] read1_fun;
  input [RAT_ADDR_WIDTH-1:0] read2_addr;
  output [ROB_ADDR_WIDTH-1:0] read2_data;
  output read2_retired;
  output [FN_WIDTH-1:0] read2_fun;
  input [RAT_ADDR_WIDTH-1:0] read4_addr;
  output [ROB_ADDR_WIDTH-1:0] read4_data;
  output read4_retired;
  output [FN_WIDTH-1:0] read4_fun;
  input [RAT_ADDR_WIDTH-1:0] read5_addr;
  output [ROB_ADDR_WIDTH-1:0] read5_data;
  output read5_retired;
  output [FN_WIDTH-1:0] read5_fun;
  input [RAT_ADDR_WIDTH-1:0] read7_addr;
  output [ROB_ADDR_WIDTH-1:0] read7_data;
  output read7_retired;
  output [FN_WIDTH-1:0] read7_fun;
  input [RAT_ADDR_WIDTH-1:0] read8_addr;
  output [ROB_ADDR_WIDTH-1:0] read8_data;
  output read8_retired;
  output [FN_WIDTH-1:0] read8_fun;

  output [ROB_ADDR_WIDTH-1:0] r_data;
  output r_retired;
  output [FN_WIDTH-1:0] r_fun;


  input writeNew0_wen;
  input writeNew1_wen;
  input writeNew2_wen;
  input writeNew3_wen;
  input writeNew4_wen;
  input writeNew5_wen;
  input writeNew6_wen;
  input writeNew7_wen;
  input writeNew8_wen;

  input [ROB_ADDR_WIDTH-1:0] writeRet0_addr;
  input writeRet0_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet1_addr;
  input writeRet1_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet2_addr;
  input writeRet2_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet3_addr;
  input writeRet3_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet4_addr;
  input writeRet4_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet5_addr;
  input writeRet5_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet6_addr;
  input writeRet6_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet7_addr;
  input writeRet7_wen;
  input [ROB_ADDR_WIDTH-1:0] writeRet8_addr;
  input writeRet8_wen;

  input retireAll;

  input [3:0] rs0i0_index;
  input [3:0] rs0i1_index;
  input [3:0] rs0i2_index;
  input [3:0] rs1i0_index;
  input [3:0] rs1i1_index;
  input [3:0] rs1i2_index;
  input [3:0] rs2i0_index;
  input [3:0] rs2i1_index;
  input [3:0] rs2i2_index;
  input read_thread;
  input ret_thread;

  wire [ROB_ADDR_WIDTH-1:0] read_data_buf;
  wire read_retired_buf;
  wire [FN_WIDTH-1:0] read_fun_buf;

  wire [8:0][ROB_ADDR_WIDTH-1:0] read_data;
  wire [8:0]read_retired;
  wire [8:0][FN_WIDTH-1:0] read_fun;
  
  reg [RAT_ADDR_WIDTH-1:0] read_addr_reg[8:0];
  reg read_thread_reg;


  genvar k;


  

  rat_flags_buf buf_mod(
  clk,
  rst,
  read_clkEn,

  read_data_buf,read_fun_buf,read_retired_buf,

  newR1,newU1,writeNew1_wen,
  newR2,newU2,writeNew2_wen,
  newR4,newU4,writeNew4_wen,
  newR5,newU5,writeNew5_wen,
  newR7,newU7,writeNew7_wen,
  newR8,newU8,writeNew8_wen,

  writeRet0_addr,writeRet0_wen,
  writeRet1_addr,writeRet1_wen,
  writeRet2_addr,writeRet2_wen,
  writeRet3_addr,writeRet3_wen,
  writeRet4_addr,writeRet4_wen,
  writeRet5_addr,writeRet5_wen,
  writeRet6_addr,writeRet6_wen,
  writeRet7_addr,writeRet7_wen,
  writeRet8_addr,writeRet8_wen,
  retireAll,
  read_thread_reg,
  read_thread_reg,
  ret_thread
  );
  
  generate
    for (k=0;k<=8;k=k+1)begin : deps_gen
        if ((k%3)!=0)
        rat_flags_dep dep_mod(
        read_addr_reg[k],
        read_data[k],
        read_retired[k],
        read_fun[k],
        rs0i0_index,rs0i1_index,rs0i2_index,
        rs1i0_index,rs1i1_index,rs1i2_index,
        rs2i0_index,rs2i1_index,rs2i2_index,
        newR0,newR1,newR2,newR3,newR4,newR5,newR6,newR7,newR8,
        newU0,newU1,newU2,newU3,newU4,newU5,newU6,newU7,newU8
        );
        assign read_data[k]=(read_addr_reg[k]==4'he || read_addr_reg[k]==4'hd) ?
          read_data_buf : 'z;
        assign read_fun[k]=(read_addr_reg[k]==4'he || read_addr_reg[k]==4'hd) ?
          read_fun_buf : 'z;
        assign read_retired[k]=(read_addr_reg[k]==4'he) ? read_retired_buf : 1'BZ;
        assign read_retired[k]=(read_addr_reg[k]==4'hd) ? 1'b1 : 1'BZ;
    end

  endgenerate

  assign read1_data=read_data[1];
  assign read2_data=read_data[2];
  assign read4_data=read_data[4];
  assign read5_data=read_data[5];
  assign read7_data=read_data[7];
  assign read8_data=read_data[8];

  assign read1_fun=read_fun[1];
  assign read2_fun=read_fun[2];
  assign read4_fun=read_fun[4];
  assign read5_fun=read_fun[5];
  assign read7_fun=read_fun[7];
  assign read8_fun=read_fun[8];
  
  assign read1_retired=read_retired[1];
  assign read2_retired=read_retired[2];
  assign read4_retired=read_retired[4];
  assign read5_retired=read_retired[5];
  assign read7_retired=read_retired[7];
  assign read8_retired=read_retired[8];

  assign r_data=read_data_buf;
  assign r_fun=read_fun_buf;
  assign r_retired=read_retired_buf;

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
          read_addr_reg[1]<=read1_addr;
          read_addr_reg[2]<=read2_addr;
          read_addr_reg[4]<=read4_addr;
          read_addr_reg[5]<=read5_addr;
          read_addr_reg[7]<=read7_addr;
          read_addr_reg[8]<=read8_addr;
		  
	  read_thread_reg<=read_thread;
        end
    end //always

endmodule


