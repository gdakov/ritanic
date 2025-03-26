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
//WARNING: data output pwire needs to be updated even if no clkEn; clkEn is only for the addresses.
module regfile_ram_f(
  clk,
  rst,
  retire_clkEn,

  read_non_stall,

  read0_addr,read0_data,read0_clkEn,
  read1_addr,read1_data,read1_clkEn,
  read2_addr,read2_data,read2_clkEn,
  retireRead_addr,retireRead_data,

  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen
  );

  parameter DATA_WIDTH=`alu_width;
  localparam ADDR_WIDTH=4;
  localparam ADDR_COUNT=16;
  
  input pwire clk;
  input pwire rst;
  input pwire retire_clkEn;

  input pwire read_non_stall;

  input pwire [ADDR_WIDTH-1:0] read0_addr;
  (* read_port *) output pwire [DATA_WIDTH-1:0] read0_data;
  input pwire read0_clkEn;
  
  input pwire [ADDR_WIDTH-1:0] read1_addr;
  (* read_port *) output pwire [DATA_WIDTH-1:0] read1_data;
  input pwire read1_clkEn;

  input pwire [ADDR_WIDTH-1:0] read2_addr;
  (* read_port *) output pwire [DATA_WIDTH-1:0] read2_data;
  input pwire read2_clkEn;

  input pwire [ADDR_WIDTH-1:0] retireRead_addr;
  (* read_port *) output pwire [DATA_WIDTH-1:0] retireRead_data;

  input pwire [ADDR_WIDTH-1:0] write0_addr;
  (* write_port *) input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire write0_wen;

  input pwire [ADDR_WIDTH-1:0] write1_addr;
  (* write_port *) input pwire [DATA_WIDTH-1:0] write1_data;
  input pwire write1_wen;

  input pwire [ADDR_WIDTH-1:0] write2_addr;
  (* write_port *) input pwire [DATA_WIDTH-1:0] write2_data;
  input pwire write2_wen;

  input pwire [ADDR_WIDTH-1:0] write3_addr;
  (* write_port *) input pwire [DATA_WIDTH-1:0] write3_data;
  input pwire write3_wen;
  

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];

  pwire [ADDR_WIDTH-1:0] read0_addr_reg;
  pwire [ADDR_WIDTH-1:0] read1_addr_reg;
  pwire [ADDR_WIDTH-1:0] read2_addr_reg;

  pwire read0_clkEn_reg;
  pwire read1_clkEn_reg;
  pwire read2_clkEn_reg;

  pwire [ADDR_WIDTH-1:0] retireRead_addr_reg;

  assign read0_data=read0_clkEn_reg ? ram[read0_addr_reg] : 'z; 
  assign read1_data=read1_clkEn_reg ? ram[read1_addr_reg] : 'z;
  assign read2_data=read2_clkEn_reg ? ram[read2_addr_reg] : 'z;

  assign retireRead_data=ram[retireRead_addr_reg][DATA_WIDTH-1:0];

  always @(posedge clk)
    begin
      if (rst)
        begin
          read0_addr_reg<={ADDR_WIDTH{1'b0}};
          read1_addr_reg<={ADDR_WIDTH{1'b0}};
          read2_addr_reg<={ADDR_WIDTH{1'b0}};
          read0_clkEn_reg<=1'b0;
          read1_clkEn_reg<=1'b0;
          read2_clkEn_reg<=1'b0;
          retireRead_addr_reg<={ADDR_WIDTH{1'b0}};
        end
      else
      begin
        if (read_non_stall) begin
            read0_addr_reg<=read0_addr;
            read1_addr_reg<=read1_addr;
            read2_addr_reg<=read2_addr;
            read0_clkEn_reg<=read0_clkEn;
            read1_clkEn_reg<=read1_clkEn;
            read2_clkEn_reg<=read2_clkEn;
        end
      end
      if (retire_clkEn & ~rst)
        begin
          retireRead_addr_reg<=retireRead_addr;
        end
      if (write0_wen) ram[write0_addr]<=write0_data;
      if (write1_wen) ram[write1_addr]<=write1_data;
      if (write2_wen) ram[write2_addr]<=write2_data;
      if (write3_wen) ram[write3_addr]<=write3_data;
    end      
    
endmodule

module regfile_ram_placeholder_f(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_data,
  read1_addr,read1_data,
  read2_addr,read2_data,

  read0_constEn,
  read1_constEn,
  read2_constEn,

  retireRead_addr,retireRead_data,

  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen
  );

  localparam ADDR_WIDTH=`reg_addr_width;
  parameter [3:0] INDEX=4'd15; //this is to be overriden to match tile index; range 0-8
  parameter DATA_WIDTH=`alu_width;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read0_data;
  
  input pwire [ADDR_WIDTH-1:0] read1_addr;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read1_data;

  input pwire [ADDR_WIDTH-1:0] read2_addr;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read2_data;

  input pwire read0_constEn;
  input pwire read1_constEn;
  input pwire read2_constEn;
  
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
  input pwire [DATA_WIDTH-1:0] write3_data;
  input pwire write3_wen;

  pwire [ADDR_WIDTH-1:0] read0_addr_reg;
  pwire [ADDR_WIDTH-1:0] read1_addr_reg;
  pwire [ADDR_WIDTH-1:0] read2_addr_reg;

  pwire [ADDR_WIDTH-1:0] retireRead_addr_reg;


  pwire [DATA_WIDTH-1:0] ram_read0A_data;
  pwire [DATA_WIDTH-1:0] ram_read1A_data;
  pwire [DATA_WIDTH-1:0] ram_read2A_data;

  pwire [DATA_WIDTH-1:0] ram_read0B_data;
  pwire [DATA_WIDTH-1:0] ram_read1B_data;
  pwire [DATA_WIDTH-1:0] ram_read2B_data;

  pwire ram_write0A_wen;
  pwire ram_write1A_wen;
  pwire ram_write2A_wen;
  pwire ram_write3A_wen;

  pwire ram_write0B_wen;
  pwire ram_write1B_wen;
  pwire ram_write2B_wen;
  pwire ram_write3B_wen;

  pwire read0_clkEn;
  pwire read1_clkEn;
  pwire read2_clkEn;


  pwire read0A_en;
  pwire read1A_en;
  pwire read2A_en;

  pwire read0B_en;
  pwire read1B_en;
  pwire read2B_en;

  pwire retA_en;
  pwire [DATA_WIDTH-1:0] retireReadA_data;
  pwire [DATA_WIDTH-1:0] retireReadB_data;

  regfile_ram #(DATA_WIDTH) ramA_mod(
  clk,
  rst,
  retire_clkEn,
  read_clkEn,
  read0_addr[8:5],ram_read0A_data,read0_clkEn & ~read0_addr[4],
  read1_addr[8:5],ram_read1A_data,read1_clkEn & ~read1_addr[4],
  read2_addr[8:5],ram_read2A_data,read2_clkEn & ~read2_addr[4],

  retireRead_addr[8:5],retireReadA_data,

  write0_addr[8:5],write0_data,ram_write0A_wen,
  write1_addr[8:5],write1_data,ram_write1A_wen,
  write2_addr[8:5],write2_data,ram_write2A_wen,
  write3_addr[8:5],write3_data,ram_write3A_wen
  );

  regfile_ram #(DATA_WIDTH) ramB_mod(
  clk,
  rst,
  retire_clkEn,
  read_clkEn,
  read0_addr[8:5],ram_read0B_data,read0_clkEn & read0_addr[4],
  read1_addr[8:5],ram_read1B_data,read1_clkEn & read1_addr[4],
  read2_addr[8:5],ram_read2B_data,read2_clkEn & read2_addr[4],

  retireRead_addr[8:5],retireReadB_data,

  write0_addr[8:5],write0_data,ram_write0B_wen,
  write1_addr[8:5],write1_data,ram_write1B_wen,
  write2_addr[8:5],write2_data,ram_write2B_wen,
  write3_addr[8:5],write3_data,ram_write3B_wen
  );
  
  assign read0_data=read0A_en ? ram_read0A_data : 'z;
  assign read1_data=read1A_en ? ram_read1A_data : 'z;
  assign read2_data=read2A_en ? ram_read2A_data : 'z;

  assign read0_data=read0B_en ? ram_read0B_data : 'z;
  assign read1_data=read1B_en ? ram_read1B_data : 'z;
  assign read2_data=read2B_en ? ram_read2B_data : 'z;
  
  assign retireRead_data=retA_en ? retireReadA_data : retireReadB_data;
  
  assign ram_write0A_wen=write0_wen && write0_addr[3:0]==INDEX && ~write0_addr[4];
  assign ram_write1A_wen=write1_wen && write1_addr[3:0]==INDEX && ~write1_addr[4];
  assign ram_write2A_wen=write2_wen && write2_addr[3:0]==INDEX && ~write2_addr[4];
  assign ram_write3A_wen=write3_wen && write3_addr[3:0]==INDEX && ~write3_addr[4];

  assign ram_write0B_wen=write0_wen && write0_addr[3:0]==INDEX && write0_addr[4];
  assign ram_write1B_wen=write1_wen && write1_addr[3:0]==INDEX && write1_addr[4];
  assign ram_write2B_wen=write2_wen && write2_addr[3:0]==INDEX && write2_addr[4];
  assign ram_write3B_wen=write3_wen && write3_addr[3:0]==INDEX && write3_addr[4];

  assign read0_clkEn=(read0_addr[3:0]==INDEX);
  assign read1_clkEn=(read1_addr[3:0]==INDEX);
  assign read2_clkEn=(read2_addr[3:0]==INDEX);

  always @(posedge clk)
    begin
      if (rst)
        begin
          read0A_en<=1'b0;
          read1A_en<=1'b0;
          read2A_en<=1'b0;

          read0B_en<=1'b0;
          read1B_en<=1'b0;
          read2B_en<=1'b0;
        end
      else
        if (read_clkEn) begin
          read0A_en<=read0_addr[3:0]==INDEX && ~read0_constEn && ~read0_addr[4];
          read1A_en<=read1_addr[3:0]==INDEX && ~read1_constEn && ~read1_addr[4];
          read2A_en<=read2_addr[3:0]==INDEX && ~read2_constEn && ~read2_addr[4];

          read0B_en<=read0_addr[3:0]==INDEX && ~read0_constEn && read0_addr[4];
          read1B_en<=read1_addr[3:0]==INDEX && ~read1_constEn && read1_addr[4];
          read2B_en<=read2_addr[3:0]==INDEX && ~read2_constEn && read2_addr[4];
        end
      if (rst) begin
          retA_en<=1'b0;
      end else if (retire_clkEn) begin
          retA_en<=~retireRead_addr[4];
      end
    end
endmodule

//compile regfile_ram_block to hard macro without deleting
//the redundant inputs including 2 horizontal x2 pwire layers
//fore read{0-9}_data and read{0-9}_dataN.
module regfile_ram_block_f(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_data,
  read1_addr,read1_data,
  read2_addr,read2_data,

  read0_constEn,
  read1_constEn,
  read2_constEn,

  read0_const,
  read1_const,
  read2_const,

  retireRead0_addr,retireRead0_data,
  retireRead1_addr,retireRead1_data,
  retireRead2_addr,retireRead2_data,
  retireRead3_addr,retireRead3_data,
  retireRead4_addr,retireRead4_data,
  retireRead5_addr,retireRead5_data,
  retireRead6_addr,retireRead6_data,
  retireRead7_addr,retireRead7_data,
  retireRead8_addr,retireRead8_data,

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
  parameter rs=0;
  localparam ADDR_WIDTH=`reg_addr_width;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire retire_clkEn;


  input pwire [ADDR_WIDTH-1:0] read0_addr;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read0_data;
  
  input pwire [ADDR_WIDTH-1:0] read1_addr;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read1_data;

  input pwire [ADDR_WIDTH-1:0] read2_addr;
  (* register equiload *) output pwire [DATA_WIDTH-1:0] read2_data;


  input pwire read0_constEn;
  input pwire read1_constEn;
  input pwire read2_constEn;
  
  input pwire [DATA_WIDTH-1:0] read0_const;
  input pwire [DATA_WIDTH-1:0] read1_const;
  input pwire [DATA_WIDTH-1:0] read2_const;

  input pwire [ADDR_WIDTH-1:0] retireRead0_addr;
  output pwire [DATA_WIDTH-1:0] retireRead0_data;

  input pwire [ADDR_WIDTH-1:0] retireRead1_addr;
  output pwire [DATA_WIDTH-1:0] retireRead1_data;

  input pwire [ADDR_WIDTH-1:0] retireRead2_addr;
  output pwire [DATA_WIDTH-1:0] retireRead2_data;

  input pwire [ADDR_WIDTH-1:0] retireRead3_addr;
  output pwire [DATA_WIDTH-1:0] retireRead3_data;

  input pwire [ADDR_WIDTH-1:0] retireRead4_addr;
  output pwire [DATA_WIDTH-1:0] retireRead4_data;

  input pwire [ADDR_WIDTH-1:0] retireRead5_addr;
  output pwire [DATA_WIDTH-1:0] retireRead5_data;

  input pwire [ADDR_WIDTH-1:0] retireRead6_addr;
  output pwire [DATA_WIDTH-1:0] retireRead6_data;

  input pwire [ADDR_WIDTH-1:0] retireRead7_addr;
  output pwire [DATA_WIDTH-1:0] retireRead7_data;

  input pwire [ADDR_WIDTH-1:0] retireRead8_addr;
  output pwire [DATA_WIDTH-1:0] retireRead8_data;


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

 

  pwire [ADDR_WIDTH-1:0] write0_addr_ram[2:0];
  pwire [DATA_WIDTH-1:0] write0_data_ram[2:0];
  pwire write0_wen_ram[2:0];
  
  pwire [ADDR_WIDTH-1:0] write1_addr_ram[2:0];
  pwire [DATA_WIDTH-1:0] write1_data_ram[2:0];
  pwire write1_wen_ram[2:0];
  
  pwire [ADDR_WIDTH-1:0] write2_addr_ram[2:0];
  pwire [DATA_WIDTH-1:0] write2_data_ram[2:0];
  pwire write2_wen_ram[2:0];

  pwire [ADDR_WIDTH-1:0] retireRead_addr[8:0];
  pwire [DATA_WIDTH-1:0] retireRead_data[8:0];


  pwire [ADDR_WIDTH-5:0] initRegCount_next;
  
  pwire [ADDR_WIDTH-1:0] initRegCount;
  pwire doInit;

  pwire [4:0] newAddr [8:0];
  pwire [8:0] newEn;

  pwire [DATA_WIDTH-1:0] read0_const_reg;
  pwire [DATA_WIDTH-1:0] read1_const_reg;
  pwire [DATA_WIDTH-1:0] read2_const_reg;
  
  pwire [ADDR_WIDTH-1:0]  read0_addr_reg;
  pwire [ADDR_WIDTH-1:0]  read1_addr_reg;
  pwire [ADDR_WIDTH-1:0]  read2_addr_reg;

  pwire read0_constEn_reg;
  pwire read1_constEn_reg;
  pwire read2_constEn_reg;
  
  genvar x;

  assign retireRead_addr[0]=retireRead0_addr;
  assign retireRead_addr[1]=retireRead1_addr;
  assign retireRead_addr[2]=retireRead2_addr;
  assign retireRead_addr[3]=retireRead3_addr;
  assign retireRead_addr[4]=retireRead4_addr;
  assign retireRead_addr[5]=retireRead5_addr;
  assign retireRead_addr[6]=retireRead6_addr;
  assign retireRead_addr[7]=retireRead7_addr;
  assign retireRead_addr[8]=retireRead8_addr;

  assign retireRead0_data=retireRead_data[0];
  assign retireRead1_data=retireRead_data[1];
  assign retireRead2_data=retireRead_data[2];
  assign retireRead3_data=retireRead_data[3];
  assign retireRead4_data=retireRead_data[4];
  assign retireRead5_data=retireRead_data[5];
  assign retireRead6_data=retireRead_data[6];
  assign retireRead7_data=retireRead_data[7];
  assign retireRead8_data=retireRead_data[8];
  
  assign write0_addr_ram[0]=doInit ? initRegCount : write0_addr;
  assign write0_data_ram[0]=doInit ? {DATA_WIDTH{1'b0}} : write0_data;
  assign write0_wen_ram[0]=write0_wen | doInit;

  assign write0_addr_ram[1]=doInit ? initRegCount : write1_addr;
  assign write0_data_ram[1]=doInit ? {DATA_WIDTH{1'b0}} : write1_data;
  assign write0_wen_ram[1]=write1_wen | doInit;
  
  assign write0_addr_ram[2]=doInit ? initRegCount : write2_addr;
  assign write0_data_ram[2]=doInit ? {DATA_WIDTH{1'b0}} : write2_data;
  assign write0_wen_ram[2]=write2_wen | doInit;

  assign write1_addr_ram[0]=write4_addr;
  assign write1_data_ram[0]=write4_data;
  assign write1_wen_ram[0]=write4_wen;

  assign write2_addr_ram[0]=write7_addr;
  assign write2_data_ram[0]=write7_data;
  assign write2_wen_ram[0]=write7_wen;

  assign write1_addr_ram[1]=write5_addr;
  assign write1_data_ram[1]=write5_data;
  assign write1_wen_ram[1]=write5_wen;

  assign write2_addr_ram[1]=write8_addr;
  assign write2_data_ram[1]=write8_data;
  assign write2_wen_ram[1]=write8_wen;
  
  assign write1_addr_ram[2]=write6_addr;
  assign write1_data_ram[2]=write6_data;
  assign write1_wen_ram[2]=write6_wen;

  assign write2_addr_ram[2]=write9_addr;
  assign write2_data_ram[2]=write9_data;
  assign write2_wen_ram[2]=write9_wen;
   
  assign read0_data= read0_constEn_reg ? read0_const_reg : 'z;
  assign read1_data= read1_constEn_reg ? read1_const_reg : 'z;
  assign read2_data= read2_constEn_reg ? read2_const_reg : 'z;

  adder_inc #(ADDR_WIDTH-4) initInc_mod(initRegCount[ADDR_WIDTH-1:4],initRegCount_next,1'b1,);

  generate
    for(x=0;x<=8;x=x+1)
	  begin : rams
		
        regfile_ram_placeholder_f #((x%3)+3*rs,DATA_WIDTH) ram_mod(
          clk,
	 // clkX,
          rst,
          read_clkEn,
          retire_clkEn,

          read0_addr,read0_data,
          read1_addr,read1_data,
          read2_addr,read2_data,

          read0_constEn,
          read1_constEn,
          read2_constEn,
          read3_constEn,
          read4_constEn,
          read5_constEn,
          read6_constEn,
          read7_constEn,
          read8_constEn,

          retireRead_addr[x],retireRead_data[x],

          write0_addr_ram[x%3],write0_data_ram[x%3],write0_wen_ram[x%3],
          write1_addr_ram[x%3],write1_data_ram[x%3],write1_wen_ram[x%3],
          write2_addr_ram[x%3],write2_data_ram[x%3],write2_wen_ram[x%3],
          write3_addr,write3_data,write3_wen
        );
      end
  endgenerate

  always @(posedge clk)
    begin
      if (rst)
        begin
          doInit<=1'b1;
          initRegCount<={ADDR_WIDTH{1'b0}};
		  read0_const_reg<={DATA_WIDTH{1'B0}};
		  read1_const_reg<={DATA_WIDTH{1'B0}};
		  read2_const_reg<={DATA_WIDTH{1'B0}};
		  read0_constEn_reg<=1'b0;
		  read1_constEn_reg<=1'b0;
		  read2_constEn_reg<=1'b0;
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
          if ((initRegCount[ADDR_WIDTH-1:4]==(31)) & (initRegCount[3:0]==4'd8))
            doInit<=1'b0; 
		  if (read_clkEn)
		    begin
			  read0_const_reg<=read0_const;
			  read1_const_reg<=read1_const;
			  read2_const_reg<=read2_const;
			  
			  read0_constEn_reg<=read0_constEn;
			  read1_constEn_reg<=read1_constEn;
			  read2_constEn_reg<=read2_constEn;
			end
        end
	if (rst) begin
            read0_addr_reg<=9'b0;
            read1_addr_reg<=9'b0;
            read2_addr_reg<=9'b0;
	end else if (read_clkEn) begin
            read0_addr_reg<=read0_addr;
            read1_addr_reg<=read1_addr;
            read2_addr_reg<=read2_addr;
	end
    end
  
endmodule






