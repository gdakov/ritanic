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

// main modules: regfile
// the rest are parts of it


//regfile_ram read during write behaviour: write first; untiled memory
module regfileFl_ram(
  clk,
  rst,
  retire_clkEn,

  read0_addr,read0_data,read0_clkEn,

  retireRead_addr,retireRead_data,

  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_wen
  );

  localparam DATA_WIDTH=6;
  localparam ADDR_WIDTH=4;
  localparam ADDR_COUNT=16;
  
  input pwire clk;
  input pwire rst;
  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire [DATA_WIDTH:0] read0_data;
  input pwire read0_clkEn;


  input pwire [ADDR_WIDTH-1:0] retireRead_addr;
  output pwire [DATA_WIDTH-1:0] retireRead_data;


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
  input pwire write3_wen;

  pwire [DATA_WIDTH:0] ram [ADDR_COUNT-1:0];

  pwire [ADDR_WIDTH-1:0] read0_addr_reg;

  pwire [ADDR_WIDTH-1:0] retireRead_addr_reg;

  assign read0_data=ram[read0_addr_reg];

  assign retireRead_data=ram[retireRead_addr_reg][5:0];

  always @(posedge clk)
    begin
      if (rst)
        begin
          read0_addr_reg<={ADDR_WIDTH{1'b0}};
          retireRead_addr_reg<={ADDR_WIDTH{1'b0}};
        end
      else
      begin
        if (read0_clkEn)
            read0_addr_reg<=read0_addr;
      end
      
      if (retire_clkEn & ~rst)
        begin
          retireRead_addr_reg<=retireRead_addr;
        end

      if (write0_wen) ram[write0_addr]<={1'b0,write0_data};
      if (write1_wen) ram[write1_addr]<={1'b0,write1_data};
      if (write2_wen) ram[write2_addr]<={1'b0,write2_data};
      if (write3_wen) ram[write3_addr]<={DATA_WIDTH+1{1'B1}};
    end      
    
endmodule


module regfileFl_ram_placeholder(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_data,

  retireRead_addr,retireRead_data,

  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_wen
  );

  localparam DATA_WIDTH=6;
  localparam ADDR_WIDTH=`reg_addr_width;
  parameter [3:0] INDEX=4'd15; //this is to be overriden to match tile index
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire [DATA_WIDTH:0] read0_data;

  
  
  input pwire [ADDR_WIDTH-1:0] retireRead_addr;
  output pwire [DATA_WIDTH-1:0] retireRead_data;


  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire write0_wen;

  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire [DATA_WIDTH-1:0] write1_data;
  input pwire write1_wen;

  input pwire [ADDR_WIDTH-1:0] write2_addr;
  input pwire [DATA_WIDTH-1:0] write2_data;
  input pwire write2_wen;

  input pwire [4:0] write3_addr;
  input pwire write3_wen;




  pwire [DATA_WIDTH:0] ram_readA_data;
  pwire [DATA_WIDTH:0] ram_readB_data;

  pwire [DATA_WIDTH-1:0] retireReadA_data;
  pwire [DATA_WIDTH-1:0] retireReadB_data;

  pwire ram_write0_wen;
  pwire ram_write1_wen;
  pwire ram_write2_wen;

  pwire read0_clkEn;


  pwire readA_en,readB_en,retA_en,retB_en;
  
  regfileFl_ram ramA_mod(
  clk,
  rst,
  retire_clkEn & ~read0_addr[8],

  read0_addr[7:4],ram_readA_data,read0_clkEn & ~read0_addr[8],

  retireRead_addr[7:4],retireReadA_data,

  write0_addr[7:4],write0_data,ram_write0_wen && ~write0_addr[8],
  write1_addr[7:4],write1_data,ram_write1_wen && ~write1_addr[8],
  write2_addr[7:4],write2_data,ram_write2_wen && ~write2_addr[8],
  write3_addr[3:0],write3_wen && ~write3_addr[4]
  );

  regfileFl_ram ramB_mod(
  clk,
  rst,
  retire_clkEn & read0_addr[8],

  read0_addr[7:4],ram_readB_data,read0_clkEn & read0_addr[8],

  retireRead_addr[7:4],retireReadB_data,

  write0_addr[7:4],write0_data,ram_write0_wen && write0_addr[8],
  write1_addr[7:4],write1_data,ram_write1_wen && write1_addr[8],
  write2_addr[7:4],write2_data,ram_write2_wen && write2_addr[8],
  write3_addr[3:0],write3_wen && write3_addr[4]
  );

  assign read0_data=readA_en ? ram_readA_data : {1+DATA_WIDTH{1'bz}};
  assign read0_data=readB_en ? ram_readB_data : {1+DATA_WIDTH{1'bz}};

  assign retireRead_data=retA_en ? retireReadA_data : 'z;
  assign retireRead_data=retB_en ? retireReadB_data : 'z;

  assign ram_write0_wen=write0_wen & (write0_addr[3:0]==INDEX);
  assign ram_write1_wen=write1_wen & (write1_addr[3:0]==INDEX);
  assign ram_write2_wen=write2_wen & (write2_addr[3:0]==INDEX);
  
  assign read0_clkEn=(read0_addr[3:0]==INDEX) & read_clkEn;

  always @(posedge clk)
    begin
      if (rst)
        begin
          readA_en<=1'b0;
          readB_en<=1'b0;
        end
      else if (read_clkEn) 
	begin
          readA_en<=read0_addr[3:0]==INDEX && ~read0_addr[8];
          readB_en<=read0_addr[3:0]==INDEX && read0_addr[8];
        end
      if (rst) begin
          retA_en<=1'b0;
          retB_en<=1'b0;
      end else if (retire_clkEn) begin
          retA_en<=retireRead_addr[3:0]==INDEX && ~retireRead_addr[8];
          retB_en<=retireRead_addr[3:0]==INDEX && retireRead_addr[8];
      end
    end
endmodule


module regfileFl_ram_block(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_data,

  retireRead0_addr,retireRead0_data,

  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen,
  write4_addr,write4_data,write4_wen,
  write5_addr,write5_data,write5_wen,
  write6_addr,write6_data,write6_wen,
  write7_addr,write7_data,write7_wen,
  write8_addr,write8_data,write8_wen,
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

  localparam DATA_WIDTH=6;
  localparam ADDR_WIDTH=`reg_addr_width;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire [DATA_WIDTH:0] read0_data;


  input pwire [ADDR_WIDTH-1:0] retireRead0_addr;
  output pwire [DATA_WIDTH-1:0] retireRead0_data;


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
  
  pwire [4:0] newAddr [8:0];
  pwire [8:0] newEn;

  pwire [ADDR_WIDTH-1:0] write0_addr_ram[2:0];
  pwire [DATA_WIDTH-1:0] write0_data_ram[2:0];
  pwire write0_wen_ram[2:0];
  
  pwire [ADDR_WIDTH-1:0] write1_addr_ram[2:0];
  pwire [DATA_WIDTH-1:0] write1_data_ram[2:0];
  pwire write1_wen_ram[2:0];
  
  pwire [ADDR_WIDTH-1:0] write2_addr_ram[2:0];
  pwire [DATA_WIDTH-1:0] write2_data_ram[2:0];
  pwire write2_wen_ram[2:0];

  pwire [ADDR_WIDTH-5:0] initRegCount_next;
  
  pwire [ADDR_WIDTH-1:0] initRegCount;
  pwire doInit;

  genvar x;

  
  assign write0_addr_ram[0]=doInit ? initRegCount : write0_addr;
  assign write0_data_ram[0]=doInit ? {DATA_WIDTH{1'b0}} : write0_data;
  assign write0_wen_ram[0]=write0_wen | doInit;

  assign write0_addr_ram[1]=doInit ? initRegCount : write1_addr;
  assign write0_data_ram[1]=doInit ? {DATA_WIDTH{1'b0}} : write1_data;
  assign write0_wen_ram[1]=write1_wen | doInit;
  
  assign write0_addr_ram[2]=doInit ? initRegCount : write2_addr;
  assign write0_data_ram[2]=doInit ? {DATA_WIDTH{1'b0}} : write2_data;
  assign write0_wen_ram[2]=write2_wen | doInit;

  assign write1_addr_ram[0]=write3_addr;
  assign write1_data_ram[0]=write3_data;
  assign write1_wen_ram[0]=write3_wen;

  assign write1_addr_ram[1]=write4_addr;
  assign write1_data_ram[1]=write4_data;
  assign write1_wen_ram[1]=write4_wen;

  assign write1_addr_ram[2]=write5_addr;
  assign write1_data_ram[2]=write5_data;
  assign write1_wen_ram[2]=write5_wen;

  assign write2_addr_ram[0]=write6_addr;
  assign write2_data_ram[0]=write6_data;
  assign write2_wen_ram[0]=write6_wen;

  assign write2_addr_ram[1]=write7_addr;
  assign write2_data_ram[1]=write7_data;
  assign write2_wen_ram[1]=write7_wen;

  assign write2_addr_ram[2]=write8_addr;
  assign write2_data_ram[2]=write8_data;
  assign write2_wen_ram[2]=write8_wen;

//  assign initRegCount_next[3:0]=initRegCount[3:0];

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
        regfileFl_ram_placeholder #(x) ram_mod(
          clk,
          rst,
          read_clkEn,
          retire_clkEn,

          read0_addr,read0_data,

          retireRead0_addr,retireRead0_data,

          write0_addr_ram[x%3],write0_data_ram[x%3],write0_wen_ram[x%3],
          write1_addr_ram[x%3],write1_data_ram[x%3],write1_wen_ram[x%3],
          write2_addr_ram[x%3],write2_data_ram[x%3],write2_wen_ram[x%3],
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
          if ((initRegCount[ADDR_WIDTH-1:4]==5'd31) & (pwh#(4)::cmpEQ(initRegCount[3:0],4'd8)))
            doInit<=1'b0; 
        end
    end
  
endmodule





module regfileFl(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_data,read0_oe,read0_gazump,

  retireRead0_addr,retireRead0_data,

  write0_addr_reg,write0_data_reg,write0_wen_reg,
  write1_addr_reg,write1_data_reg,write1_wen_reg,
  write2_addr_reg,write2_data_reg,write2_wen_reg,
  write3_addr_reg,write3_data_reg,write3_wen_reg,
  write4_addr_reg,write4_data_reg,write4_wen_reg,
  write5_addr_reg,write5_data_reg,write5_wen_reg,
  write6_addr_reg,write6_data_reg,write6_wen_reg,
  write7_addr_reg,write7_data_reg,write7_wen_reg,
  write8_addr_reg,write8_data_reg,write8_wen_reg,
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
  localparam DATA_WIDTH=6;
  localparam ADDR_WIDTH=`reg_addr_width;
 
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire [DATA_WIDTH:0] read0_data;
  input pwire read0_oe;
  output pwire [10:0] read0_gazump;


  input pwire [ADDR_WIDTH-1:0] retireRead0_addr;
  output pwire [DATA_WIDTH-1:0] retireRead0_data;


  input pwire [ADDR_WIDTH-1:0] write0_addr_reg;
  input pwire [DATA_WIDTH-1:0] write0_data_reg;
  input pwire write0_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write1_addr_reg;
  input pwire [DATA_WIDTH-1:0] write1_data_reg;
  input pwire write1_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write2_addr_reg;
  input pwire [DATA_WIDTH-1:0] write2_data_reg;
  input pwire write2_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write3_addr_reg;
  input pwire [DATA_WIDTH-1:0] write3_data_reg;
  input pwire write3_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write4_addr_reg;
  input pwire [DATA_WIDTH-1:0] write4_data_reg;
  input pwire write4_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write5_addr_reg;
  input pwire [DATA_WIDTH-1:0] write5_data_reg;
  input pwire write5_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write6_addr_reg;
  input pwire [DATA_WIDTH-1:0] write6_data_reg;
  input pwire write6_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write7_addr_reg;
  input pwire [DATA_WIDTH-1:0] write7_data_reg;
  input pwire write7_wen_reg;

  input pwire [ADDR_WIDTH-1:0] write8_addr_reg;
  input pwire [DATA_WIDTH-1:0] write8_data_reg;
  input pwire write8_wen_reg;



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

  pwire [DATA_WIDTH:0] ram_read_data;

  
//  assign read0_data=read_data[0];

  regfileFl_ram_block ram_mod(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,ram_read_data,

  retireRead0_addr,retireRead0_data,

  write0_addr_reg2,write0_data_reg,write0_wen_reg2,
  write1_addr_reg2,write1_data_reg,write1_wen_reg2,
  write2_addr_reg2,write2_data_reg,write2_wen_reg2,
  write3_addr_reg2,write3_data_reg,write3_wen_reg2,
  write4_addr_reg2,write4_data_reg,write4_wen_reg2,
  write5_addr_reg2,write5_data_reg,write5_wen_reg2,

  write6_addr_reg2,write6_data_reg,write6_wen_reg2,
  write7_addr_reg2,write7_data_reg,write7_wen_reg2,
  write8_addr_reg2,write8_data_reg,write8_wen_reg2,
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

  regfile_zero_cycle_write #(DATA_WIDTH+1) zcw_mod(
  clk,rst,
  read_clkEn,
  ram_read_data,read0_data,read0_addr,
  1'b0,//constEn
  read0_oe,
  read0_gazump,
  
  write0_addr_reg,write0_wen_reg,
  write1_addr_reg,write1_wen_reg,
  write2_addr_reg,write2_wen_reg,
  write3_addr_reg,write3_wen_reg,
  write4_addr_reg,write4_wen_reg,
  write5_addr_reg,write5_wen_reg,
  write6_addr_reg,write6_wen_reg,
  write7_addr_reg,write7_wen_reg,
  write8_addr_reg,write8_wen_reg,
  9'h1ff,1'b0,
  write0_addr_reg2,write0_wen_reg2,
  write1_addr_reg2,write1_wen_reg2,
  write2_addr_reg2,write2_wen_reg2,
  write3_addr_reg2,write3_wen_reg2,
  write4_addr_reg2,write4_wen_reg2,
  write5_addr_reg2,write5_wen_reg2,
  write6_addr_reg2,write6_wen_reg2,
  write7_addr_reg2,write7_wen_reg2,
  write8_addr_reg2,write8_wen_reg2,
  9'h1ff,1'b0,
  {1'b0,write0_data_reg},
  {1'b0,write1_data_reg},
  {1'b0,write2_data_reg},
  {1'b0,write3_data_reg},
  {1'b0,write4_data_reg},
  {1'b0,write5_data_reg},
  {1'b0,write6_data_reg},
  {1'b0,write7_data_reg},
  {1'b0,write8_data_reg},
  7'b0
  );
  
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
      
      
          write0_wen_reg2<=1'b0;
          write1_wen_reg2<=1'b0;
          write2_wen_reg2<=1'b0;
          write3_wen_reg2<=1'b0;
          write4_wen_reg2<=1'b0;
          write5_wen_reg2<=1'b0;
          write6_wen_reg2<=1'b0;
          write7_wen_reg2<=1'b0;
          write8_wen_reg2<=1'b0;
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
      
      
          write0_wen_reg2<=write0_wen_reg;
          write1_wen_reg2<=write1_wen_reg;
          write2_wen_reg2<=write2_wen_reg;
          write3_wen_reg2<=write3_wen_reg;
          write4_wen_reg2<=write4_wen_reg;
          write5_wen_reg2<=write5_wen_reg;
          write6_wen_reg2<=write6_wen_reg;
          write7_wen_reg2<=write7_wen_reg;
          write8_wen_reg2<=write8_wen_reg;
      end
  end

endmodule



