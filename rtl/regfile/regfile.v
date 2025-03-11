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
//WARNING: data output needs to be updated even if no clkEn; clkEn is only for the addresses.
module regfile_ram(
  clk,
  rst,
  retire_clkEn,

  read_non_stall,

  read0_addr,read0_data,read0_clkEn,
  read1_addr,read1_data,read1_clkEn,

  retireRead_addr,retireRead_data,

  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen
  );

  parameter DATA_WIDTH=`alu_width;
  localparam ADDR_WIDTH=4;
  localparam ADDR_COUNT=16;
  
  input clk;
  input rst;
  input retire_clkEn;

  input read_non_stall;

  input [9:0][ADDR_WIDTH-1:0] read0_addr;
  (* read_port *) output [9:0][DATA_WIDTH-1:0] read0_data;
  input [9:0] read0_clkEn;
  
  input [10:0] [ADDR_WIDTH-1:0] read1_addr;
  (* read_port *) output [10:0] [DATA_WIDTH-1:0] read1_data;
  input [10:0]read1_clkEn;


  input [ADDR_WIDTH-1:0] retireRead_addr;
  (* read_port *) output [DATA_WIDTH-1:0] retireRead_data;


  input [ADDR_WIDTH-1:0] write0_addr;
  (* write_port *) input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;

  input [ADDR_WIDTH-1:0] write1_addr;
  (* write_port *) input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;

  input [ADDR_WIDTH-1:0] write2_addr;
  (* write_port *) input [DATA_WIDTH-1:0] write2_data;
  input write2_wen;

  input [ADDR_WIDTH-1:0] write3_addr;
  (* write_port *) input [DATA_WIDTH-1:0] write3_data;
  input write3_wen;
  

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];

  reg [9:0] [ADDR_WIDTH-1:0] read0_addr_reg;
  reg [9:0] [ADDR_WIDTH-1:0] read1_addr_reg;

  reg [9:0]read0_clkEn_reg;
  reg [9:0] read1_clkEn_reg;

  reg [ADDR_WIDTH-1:0] retireRead_addr_reg;

  generate
    genvar rp;
    for(rx=0;rx<11;rx=rx+1) begin
        if (rx!=10) assign read0_data[rx]=read0_clkEn_reg[rx] ? ram[read0_addr_reg[rx]] : 'z; 
        assign read1_data[rx]=read1_clkEn_reg[rx] ? ram[read1_addr_reg[rx]] : 'z;
  endgenerate

  assign retireRead_data=ram[retireRead_addr_reg][DATA_WIDTH-1:0];

  always @(posedge clk)
    begin
      if (rst)
        begin
          read0_addr_reg<={10*ADDR_WIDTH{1'b0}};
          read1_addr_reg<={11*ADDR_WIDTH{1'b0}};
          read0_clkEn_reg<=10'b0;
          read1_clkEn_reg<=11'b0;
          retireRead_addr_reg<={ADDR_WIDTH{1'b0}};
        end
      else
      begin
        if (read_non_stall) begin
            read0_addr_reg<=read0_addr;
            read1_addr_reg<=read1_addr;
            read0_clkEn_reg<=read0_clkEn;
            read1_clkEn_reg<=read1_clkEn;
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

module regfile_ram_placeholder(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_data,
  read1_addr,read1_data,

  read0_constEn,
  read1_constEn,

  retireRead_addr,retireRead_data,

  write0_addr,write0_data,write0_wen,
  write1_addr,write1_data,write1_wen,
  write2_addr,write2_data,write2_wen,
  write3_addr,write3_data,write3_wen
  );

  localparam ADDR_WIDTH=`reg_addr_width;
  parameter [3:0] INDEX=4'd15; //this is to be overriden to match tile index; range 0-8
  parameter DATA_WIDTH=`alu_width;
  
  input clk;
  input rst;
  input read_clkEn;
  input retire_clkEn;


  input [9:0][ADDR_WIDTH-1:0] read0_addr;
  (* register equiload *) output [9:0] [DATA_WIDTH-1:0] read0_data;
  
  input [10:0] [ADDR_WIDTH-1:0] read1_addr;
  (* register equiload *) output [10:0] [DATA_WIDTH-1:0] read1_data;


  input [9:0] read0_constEn;
  input [10:0] read1_constEn;
  
  input [ADDR_WIDTH-1:0] retireRead_addr;
  output [DATA_WIDTH-1:0] retireRead_data;

  input [ADDR_WIDTH-1:0] write0_addr;
  input [DATA_WIDTH-1:0] write0_data;
  input write0_wen;

  input [ADDR_WIDTH-1:0] write1_addr;
  input [DATA_WIDTH-1:0] write1_data;
  input write1_wen;

  input [ADDR_WIDTH-1:0] write2_addr;
  input [DATA_WIDTH-1:0] write2_data;
  input write2_wen;

  input [ADDR_WIDTH-1:0] write3_addr;
  input [DATA_WIDTH-1:0] write3_data;
  input write3_wen;

  reg [9:0][ADDR_WIDTH-1:0] read0_addr_reg;
  reg [10:0][ADDR_WIDTH-1:0] read1_addr_reg;

  reg [ADDR_WIDTH-1:0] retireRead_addr_reg;


  wire [9:0][DATA_WIDTH-1:0] ram_read0A_data;
  wire [10:0][DATA_WIDTH-1:0] ram_read1A_data;

  wire [9:0][DATA_WIDTH-1:0] ram_read0B_data;
  wire [10:0][DATA_WIDTH-1:0] ram_read1B_data;

  wire ram_write0A_wen;
  wire ram_write1A_wen;
  wire ram_write2A_wen;
  wire ram_write3A_wen;

  wire ram_write0B_wen;
  wire ram_write1B_wen;
  wire ram_write2B_wen;
  wire ram_write3B_wen;

  wire [9:0] read0_clkEn;
  wire [10:0] read1_clkEn;


  reg [9:0] read0A_en;
  reg [10:0] read1A_en;

  reg [9:0] read0B_en;
  reg [10:0] read1B_en;

  reg retA_en;
  wire [DATA_WIDTH-1:0] retireReadA_data;
  wire [DATA_WIDTH-1:0] retireReadB_data;

  always @* begin
    for(p=0;p <11;p=p+1) begin
        if (p!=10) read0_addr85[p]=read0_addr[p][8:5];
        read1_addr85[p]=read1_addr[p][8:5];
        if (p!=10) read0_addr4[p]=read0_addr[p][4];
        read1_addr4[p]=read1_addr[p][4];
        if (p!=10) read0_clkEn[p]=(read0_addr[p][3:0]==INDEX);
        read1_clkEn[p]=(read1_addr[p][3:0]==INDEX);
    end
  end
  regfile_ram #(DATA_WIDTH) ramA_mod(
  clk,
  rst,
  retire_clkEn,
  read_clkEn,
  read0_addr85,ram_read0A_data,read0_clkEn & ~read0_addr4,
  read1_addr85,ram_read1A_data,read1_clkEn & ~read1_addr4,

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
  read0_addr85,ram_read0B_data,read0_clkEn & read0_addr4,
  read1_addr85,ram_read1B_data,read1_clkEn & read1_addr4,

  retireRead_addr[8:5],retireReadB_data,

  write0_addr[8:5],write0_data,ram_write0B_wen,
  write1_addr[8:5],write1_data,ram_write1B_wen,
  write2_addr[8:5],write2_data,ram_write2B_wen,
  write3_addr[8:5],write3_data,ram_write3B_wen
  );
  generate
    genvar t;
    for(t=0;t<11;t=t+1) begin
        if (t!=10) assign read0_data[t]=read0A_en[t] ? ram_read0A_data[t] : 'z;
        assign read1_data[t]=read1A_en[t] ? ram_read1A_data[t] : 'z;

        if (t!=10) assign read0_data[t]=read0B_en[t] ? ram_read0B_data[t] : 'z;
        assign read1_data[t]=read1B_en[t] ? ram_read1B_data[t] : 'z;
    end
  end
  assign retireRead_data=retA_en ? retireReadA_data : retireReadB_data;
  
  assign ram_write0A_wen=write0_wen && write0_addr[3:0]==INDEX && ~write0_addr[4];
  assign ram_write1A_wen=write1_wen && write1_addr[3:0]==INDEX && ~write1_addr[4];
  assign ram_write2A_wen=write2_wen && write2_addr[3:0]==INDEX && ~write2_addr[4];
  assign ram_write3A_wen=write3_wen && write3_addr[3:0]==INDEX && ~write3_addr[4];

  assign ram_write0B_wen=write0_wen && write0_addr[3:0]==INDEX && write0_addr[4];
  assign ram_write1B_wen=write1_wen && write1_addr[3:0]==INDEX && write1_addr[4];
  assign ram_write2B_wen=write2_wen && write2_addr[3:0]==INDEX && write2_addr[4];
  assign ram_write3B_wen=write3_wen && write3_addr[3:0]==INDEX && write3_addr[4];

  always @(posedge clk)
    begin
      if (rst)
        begin
          read0A_en<=10'b0;
          read1A_en<=11'b0;

          read0B_en<=10'b0;
          read1B_en<=11'b0;

        end
      else
        if (read_clkEn) begin
          for(x=0;x<10;x=x+1) begin
              read0A_en[x]<=read0_addr[x][3:0]==INDEX && ~read0_constEn[x] && ~read0_addr4[x];
              read1A_en[x]<=read1_addr[x][3:0]==INDEX && ~read1_constEn[x] && ~read1_addr4[x];

              read0B_en[x]<=read0_addr[x][3:0]==INDEX && ~read0_constEn[x] && read0_addr4[x];
              read1B_en[x]<=read1_addr[x][3:0]==INDEX && ~read1_constEn[x] && read1_addr4[x];
          end
        end
      if (rst) begin
          retA_en<=1'b0;
      end else if (retire_clkEn) begin
          retA_en<=~retireRead_addr[4];
      end
    end
endmodule

//compile regfile_ram_block to hard macro without deleting
//the redundant inputs including 2 horizontal x2 wire layers
//fore read{0-9}_data and read{0-9}_dataN.
module regfile_ram_block(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_data,
  read1_addr,read1_data,

  read0_constEn,
  read1_constEn,

  read0_const,
  read1_const,

  retireRead0_addr,retireRead0_data,

  write0_addr,write0_data,write0_wen
  );

  parameter DATA_WIDTH=`alu_width;
  localparam ADDR_WIDTH=`reg_addr_width;
  
  input clk;
  input rst;
  input read_clkEn;
  input retire_clkEn;


  input [9:0][ADDR_WIDTH-1:0] read0_addr;
  (* register equiload *) output [9:0][DATA_WIDTH-1:0] read0_data;
  
  input [9:0][ADDR_WIDTH-1:0] read1_addr;
  (* register equiload *) output [9:0][DATA_WIDTH-1:0] read1_data;



  input [9:0] read0_constEn;
  input [10:0] read1_constEn;
  
  input [9:0] [DATA_WIDTH-1:0] read0_const;
  input [10:0] [DATA_WIDTH-1:0] read1_const;

  input [9:0] [ADDR_WIDTH-1:0] retireRead0_addr;
  output [9:0] [DATA_WIDTH-1:0] retireRead0_data;


  input [9:0][ADDR_WIDTH-1:0] write0_addr;
  input [9:0][DATA_WIDTH-1:0] write0_data;
  input [9:0] write0_wen;

 

  wire [ADDR_WIDTH-1:0] write0_addr_ram[2:0];
  wire [DATA_WIDTH-1:0] write0_data_ram[2:0];
  wire write0_wen_ram[2:0];
  
  wire [ADDR_WIDTH-1:0] write1_addr_ram[2:0];
  wire [DATA_WIDTH-1:0] write1_data_ram[2:0];
  wire write1_wen_ram[2:0];
  
  wire [ADDR_WIDTH-1:0] write2_addr_ram[2:0];
  wire [DATA_WIDTH-1:0] write2_data_ram[2:0];
  wire write2_wen_ram[2:0];

  wire [ADDR_WIDTH-1:0] retireRead_addr[8:0];
  wire [DATA_WIDTH-1:0] retireRead_data[8:0];


  wire [ADDR_WIDTH-5:0] initRegCount_next;
  
  reg [ADDR_WIDTH-1:0] initRegCount;
  reg doInit;

  wire [4:0] newAddr [8:0];
  wire [8:0] newEn;

  reg [9:0][DATA_WIDTH-1:0] read0_const_reg;
  reg [10:0][DATA_WIDTH-1:0] read1_const_reg;
  
  reg [9:0][ADDR_WIDTH-1:0]  read0_addr_reg;
  reg [10:0][ADDR_WIDTH-1:0]  read1_addr_reg;

  reg [9:0] read0_constEn_reg;
  reg [10:0] read1_constEn_reg;
  
  genvar x;

  
  assign write0_addr_ram[0]=doInit ? initRegCount : write0_addr[0];
  assign write0_data_ram[0]=doInit ? {DATA_WIDTH{1'b0}} : write0_data[0];
  assign write0_wen_ram[0]=write0_wen[0] | doInit;

  assign write0_addr_ram[1]=doInit ? initRegCount : write0_addr[1];
  assign write0_data_ram[1]=doInit ? {DATA_WIDTH{1'b0}} : write0_data[1];
  assign write0_wen_ram[1]=write0_wen[1] | doInit;
  
  assign write0_addr_ram[2]=doInit ? initRegCount : write0_addr[2];
  assign write0_data_ram[2]=doInit ? {DATA_WIDTH{1'b0}} : write0_data[2];
  assign write0_wen_ram[2]=write0_wen[2] | doInit;

  assign write1_addr_ram[0]=write0_addr[4];
  assign write1_data_ram[0]=write0_data[4];
  assign write1_wen_ram[0]=write0_wen[4];

  assign write2_addr_ram[0]=write0_addr[7];
  assign write2_data_ram[0]=write0_data[7];
  assign write2_wen_ram[0]=write0_wen[7];

  assign write1_addr_ram[1]=write0_addr[5];
  assign write1_data_ram[1]=write0_data[5];
  assign write1_wen_ram[1]=write0_wen[5];

  assign write2_addr_ram[1]=write0_addr[8];
  assign write2_data_ram[1]=write0_data[8];
  assign write2_wen_ram[1]=write0_wen[8];
  
  assign write1_addr_ram[2]=write0_addr[6];
  assign write1_data_ram[2]=write0_data[6];
  assign write1_wen_ram[2]=write0_wen[6];

  assign write2_addr_ram[2]=write0_addr[9];
  assign write2_data_ram[2]=write0_data[9];
  assign write2_wen_ram[2]=write0_wen[9];

  generate   
    genvar t;
    for(t=0;t<11;t=t+1) begin
        if (t!=10) assign read0_data[t]= read0_constEn_reg[t] ? read0_const_reg[t] : 'z;
        assign read1_data[t]= read1_constEn_reg[t] ? read1_const_reg[t] : 'z;
    end
  endgenerate
  adder_inc #(ADDR_WIDTH-4) initInc_mod(initRegCount[ADDR_WIDTH-1:4],initRegCount_next,1'b1,);

  generate
    for(x=0;x<=9;x=x+1)
	  begin : rams
		
        regfile_ram_placeholder #(x/3*4+x%3,DATA_WIDTH) ram_mod(
          clk,
	 // clkX,
          rst,
          read_clkEn,
          retire_clkEn,

          read0_addr,read0_data,
          read1_addr,read1_data,

          read0_constEn,
          read1_constEn,

          retireRead_addr[x],retireRead_data[x],

          write0_addr_ram[x%4],write0_data_ram[x%4],write0_wen_ram[x%4],
          write1_addr_ram[x%4],write1_data_ram[x%4],write1_wen_ram[x%4],
          write2_addr_ram[x%4],write2_data_ram[x%4],write2_wen_ram[x%4],
          write0_addr[3],write0_data[3],write0_wen[3]
        );
      end
  endgenerate

  always @(posedge clk)
    begin
      if (rst)
        begin
          doInit<=1'b1;
          initRegCount<={ADDR_WIDTH{1'b0}};
		  read0_const_reg<={10*DATA_WIDTH{1'B0}};
		  read1_const_reg<={11*DATA_WIDTH{1'B0}};
		  read0_constEn_reg<=10'b0;
		  read1_constEn_reg<=11'b0;
        end
      else
        begin
          if (doInit)
            case(initRegCount[3:0])
              0: initRegCount[3:0]<=4'd1;
              1: initRegCount[3:0]<=4'd2;
              2: initRegCount[3:0]<=4'd4;
              4: initRegCount[3:0]<=4'd5;
              5: initRegCount[3:0]<=4'd6;
              6: initRegCount[3:0]<=4'd7;
              8: initRegCount[3:0]<=4'd9;
              9: initRegCount[3:0]<=4'd10;
              10: initRegCount[3:0]<=4'd12;
              12: initRegCount<={initRegCount_next,4'd0};          
            endcase
          if ((initRegCount[ADDR_WIDTH-1:4]==(31)) & (initRegCount[3:0]==4'd12))
            doInit<=1'b0; 
		  if (read_clkEn)
		    begin
			  read0_const_reg<=read0_const;
			  read1_const_reg<=read1_const;
			  
			  read0_constEn_reg<=read0_constEn;
			  read1_constEn_reg<=read1_constEn;
			end
        end
	if (rst) begin
            read0_addr_reg<='0;
            read1_addr_reg<='0;
	end else if (read_clkEn) begin
            read0_addr_reg<=read0_addr;
            read1_addr_reg<=read1_addr;
	end
    end
  
endmodule


//module to create correct write-first behaviour
//shared with flags registers by overriding data parameter
module regfile_zero_cycle_write(
  clk,rst,
  read_clkEn,
  read_data_ram,read_data_new,read_addr,
  read_constEn,read_oe,
  match_w,
  write0_addr_reg,write0_wen_reg,
  write0_addr_reg2,write0_wen_reg2,
  write0_data_reg
  );
  parameter DATA_WIDTH=`alu_width;
  localparam ADDR_WIDTH=`reg_addr_width;

  input clk;
  input rst;

  input read_clkEn;
  
  input [DATA_WIDTH-1:0] read_data_ram;
  output [DATA_WIDTH-1:0] read_data_new;
  input [ADDR_WIDTH-1:0] read_addr;

  input read_constEn;
  input read_oe;
  
  output [10:0] match_w;
  
  input [9:0][ADDR_WIDTH-1:0] write0_addr_reg;
  input [9:0]write0_wen_reg;


  input [9:0][ADDR_WIDTH-1:0] write0_addr_reg2;
  input [9:0]write0_wen_reg2;


  input [9:0][DATA_WIDTH-1:0] write0_data_reg;
  
  wire [9:0]match_r0;

  wire match;

  reg read_constEn_reg;

  reg read_oe_reg;
  reg [ADDR_WIDTH-1:0] read_addr_reg;


  assign match=|match_r0;
  
  generate
    genvar t;
    for(t=0;t<10;t=t+1) begin

        assign read_data_new=(match_r0[t] & read_oe_reg[t]) ? write0_data_reg[t] : 'z;

        assign read_data_new=(match | ~read_oe_reg) ? 'z : read_data_ram;
  
        assign match_w[t]=read_addr_reg==write0_addr_reg[t] && write0_wen_reg[t] &&
          ~read_constEn_reg && read_oe_reg;
  
       assign match_w[10]=~(|match_w[9:0]);

       assign match_r0[t]=read_addr_reg==write0_addr_reg2[t] && write0_wen_reg2[t] &&
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
              read_oe_reg<=read_oe;
     	      read_addr_reg<=read_addr;
            end
        end
    end
endmodule


module regfile(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,read0_addr_rrf,read0_data,read0_oe,read0_match,
  read1_addr,read1_addr_rrf,read1_data,read1_oe,read1_match,

  read0_constEn,
  read1_constEn,

  read0_const,
  read1_const,

  write0_addr_rrf,write0_wen_rrf,

  retireRead0_addr,

  write0_addr_reg,write0_data_reg,write0_wen_reg
  );
  parameter DATA_WIDTH=`alu_width;
  localparam ADDR_WIDTH=`reg_addr_width;
  
  input clk;
  input rst;
  input read_clkEn;
  input retire_clkEn;


  input [9:0][ADDR_WIDTH-1:0] read0_addr;
  input [9:0][5:0] read0_addr_rrf;
  (* register equiload *) output [9:0][DATA_WIDTH-1:0] read0_data;
  input [9:0]read0_oe;
  output [9:0][10:0] read0_match;

  input [10:0][ADDR_WIDTH-1:0] read1_addr;
  input [10:0][5:0] read1_addr_rrf;
  (* register equiload *) output [10:0][DATA_WIDTH-1:0] read1_data;
  input [10:0] read1_oe;
  output [10:0] [10:0] read1_match;


  input [9:0] read0_constEn;
  input [10:0] read1_constEn;

  input [9:0] [DATA_WIDTH-1:0] read0_const;
  input [10:0] [DATA_WIDTH-1:0] read1_const;


  input [9:0][5:0] write0_addr_rrf;
  input [9:0]      write0_wen_rrf;  
  input [9:0][5:0] write1_addr_rrf;
  input [9:0]      write1_wen_rrf;  

  input [9:0][8:0] retireRead0_addr;

  input [9:0][ADDR_WIDTH-1:0] write0_addr_reg;
  input [9:0][DATA_WIDTH-1:0] write0_data_reg;
  input [9:0]write0_wen_reg;


  wire [9:0][DATA_WIDTH-1:0] ram_read_data0;
  wire [10:0][DATA_WIDTH-1:0] ram_read_data1;
  wire [9:0][DATA_WIDTH-1:0] retireRead_datax;


  wire read_constEn[9:0];
  wire read_oe[9:0];

  reg [9:0][ADDR_WIDTH-1:0] write0_addr_reg2;
  reg [9:0]write0_wen_reg2;

  
  genvar b;

  
  regfile_ram_block #(DATA_WIDTH) ram_mod(
  clk,
  rst,
  read_clkEn,
  retire_clkEn,

  read0_addr,ram_read_data0,
  read1_addr,ram_read_data1,

  read0_constEn,
  read1_constEn,

  read0_const,
  read1_const,

  retireRead0_addr,ram_retireRead_data0,
  retireRead1_addr,ram_retireRead_data1,

  write0_addr_reg2,write0_data_reg,write0_wen_reg2
 );

  rrf #(DATA_WIDTH) rrf_m(
  clk,
  rst,
  read_clkEn,
  read0_addr_rrf,read0_data,~read0_oe,
  read1_addr_rrf,read1_data,~read1_oe,
  write_addr_rrf0,reatireRead_datax0,write_wen_rrf0,
  write_addr_rrf1,reatireRead_datax1,write_wen_rrf1,
  read_thread,
  write_thread
  );



  assign write_addr_rrf0=write0_addr_rrf;
  assign write_addr_rrf1=write1_addr_rrf;

  assign write_wen_rrf0=write0_wen_rrf;
  assign write_wen_rrf1=write1_wen_rrf;
  

  generate for(b=0;b<=10;b=b+1)
    begin
      if (b!=10) regfile_zero_cycle_write #(DATA_WIDTH) zcw_mod(
      clk,rst,
      read_clkEn,
      ram_read_data0[b],read0_data[b],read0_addr[b],

      read0_constEn[b],read0_oe[b], read0_match[b],
      
      write0_addr_reg,write0_wen_reg,
      write0_addr_reg2,write0_wen_reg2,
      write0_data_reg
      );
      

      regfile_zero_cycle_write #(DATA_WIDTH) zcw2_mod(
      clk,rst,
      read_clkEn,
      ram_read_data1[b],read1_data[b],read1_addr[b],

      read1_constEn[b],read1_oe[b], read1_match[b],
      
      write0_addr_reg,write0_wen_reg,
      write0_addr_reg2,write0_wen_reg2,
      write0_data_reg
      );
      

      if (b!=10) regfile_zero_cycle_write #(DATA_WIDTH) zcwiR_mod(
      clk,rst,
      read_clkEn,
      ram_retireRead_data0[b],retireRead0_data[b],retireRead0_addr[b],

      1'b0,1'b1,,
      
      write0_addr_reg,write0_wen_reg,
      write0_addr_reg2,write0_wen_reg2,
      write0_data_reg
      );

      regfile_zero_cycle_write #(DATA_WIDTH) zcwiR_mod(
      clk,rst,
      read_clkEn,
      ram_retireRead_data1[b],retireRead1_data[b],retireRead1_addr[b],

      1'b0,1'b1,,
      
      write0_addr_reg,write0_wen_reg,
      write0_addr_reg2,write0_wen_reg2,
      write0_data_reg
      );

    end
  endgenerate

  always @(posedge clk) begin
      if (rst) begin
          write0_addr_reg2<={10*ADDR_WIDTH{1'B0}};
          
          
          write0_wen_reg2<=10'b0;
      end else begin
          for(x11=0;x11<10;x11=x11+1) begin
              if (write0_wen_reg[x11]) write0_addr_reg2[x11]<=write0_addr_reg[x11];
          end
          
          
          write0_wen_reg2<=write0_wen_reg;
      end
  end
endmodule





