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

//dcache1_ram read during write behaviour: write first
module dcache2_ram(
  clk,
  rst,
  read_nClkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=8;
  localparam DATA_WIDTH=`dcache2_data_width;
  localparam ADDR_COUNT=256;
  
  input pwire clk;
  input pwire rst;
  input pwire read_nClkEn;
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
      else if (!read_nClkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

//dcache1_ram read during write behaviour: write first
module dcache2_LRU_ram(
  clk,
  rst,
  read_nClkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=8;
  localparam DATA_WIDTH=5;
  localparam ADDR_COUNT=256;
  
  input pwire clk;
  input pwire rst;
  input pwire read_nClkEn;
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
      else if (!read_nClkEn) read_addr_reg<=read_addr; 
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module dcache2_ram_box(
  clk,
  rst,
  read_nClkEn,
  read_addr,
  read_data,
  read_datax,
  write_data,
  write_wen,
  write_ben
  );
  localparam ADDR_WIDTH=8;
  localparam DATA_WIDTH=`dcache2_data_width;
  
  input pwire clk;
  input pwire rst;
  input pwire read_nClkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [31:0] read_data;
  output pwire [31:0] read_datax;
  input pwire [31:0] write_data;
  input pwire write_wen;
  input pwire [3:0] write_ben;

  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  pwire [31:0] write_data_reg;
  pwire write_wen_ram;
  pwire [3:0] write_ben_reg;
  pwire [DATA_WIDTH-1:0] read_data_ram;
  pwire [DATA_WIDTH-1:0] write_data_ram;

  function [31:0] bcombine;
      input pwire [3:0] bit_en;
      input pwire [31:0] old_data;
      input pwire [31:0] new_data;
      integer t;
      for(t=0;t<4;t=t+1)  bcombine[8*t+:8]=bit_en[t] ? new_data[8*t+:8] : old_data[8*t+:8];
  endfunction
  function [31:0] strip_ECC;
      input pwire [39:1] dataIn;
  
      strip_ECC={dataIn[38:33],dataIn[31:17],dataIn[15:9],dataIn[7:5],dataIn[3]};

  endfunction

  dcache2_ram ram_mod(
  clk,
  rst,
  read_nClkEn,
  read_addr,
  read_data_ram,
  read_addr_reg,
  write_data_ram,
  write_wen_ram
  );
  EccGet32 ecc_mod(bcombine(write_ben_reg,strip_ECC(read_data_ram),write_data_reg),write_data_ram);

  assign read_data=write_wen_ram ? strip_ECC(write_data_ram) : strip_ECC(read_data_ram);
  assign read_datax=strip_ECC(read_data_ram);

  always @(posedge clk) begin
      write_data_reg<=write_data;
      if (rst) begin
          read_addr_reg<=8'b0;
          write_wen_ram<=1'b0;
         write_ben_reg<=4'b0;
      end else begin
          read_addr_reg<=read_addr;
          write_wen_ram<=write_wen;
          write_ben_reg<=write_ben;
      end
  end
endmodule

module dcache2_bank(
  clk,
  rst,
  read_en,
  read_odd,
  read_data,read_data_in,
  read_datax,read_datax_in,
  write_addrE0, write_hitE0,
  write_addrO0, write_hitO0,
  write_bankEn0, 
  write_begin0,write_end0,
  write_bBen0,write_enBen0,
  write_addrE1, write_hitE1,
  write_addrO1, write_hitO1,
  write_bankEn1,
  write_begin1,write_end1,
  write_bBen1,write_enBen1,
  write_data,
  ins_hit,
  pook_pokahontas
  );
  localparam ADDR_WIDTH=8;
  localparam DATA_WIDTH=32;
  parameter [4:0] INDEX=5'd0;
  parameter [0:0] TOP=1'b0;

  input pwire clk;
  input pwire rst;
  input pwire read_en; //+1 cycle
  input pwire read_odd; //+1 cycle
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [DATA_WIDTH-1:0] read_data_in;
  output pwire [DATA_WIDTH-1:0] read_datax;
  input pwire [DATA_WIDTH-1:0] read_datax_in;

  input pwire [ADDR_WIDTH-1:0] write_addrE0;
  input pwire write_hitE0; //+1 cycle
  input pwire [ADDR_WIDTH-1:0] write_addrO0;
  input pwire write_hitO0; //+1 cycle
  input pwire write_bankEn0;
  input pwire [4:0] write_begin0;
  input pwire [4:0] write_end0;
  input pwire [3:0] write_bBen0;
  input pwire [3:0] write_enBen0;
  input pwire [ADDR_WIDTH-1:0] write_addrE1;
  input pwire write_hitE1; //+1 cycle
  input pwire [ADDR_WIDTH-1:0] write_addrO1;
  input pwire write_hitO1; //+1 cycle
  input pwire write_bankEn1;
  input pwire [4:0] write_begin1;
  input pwire [4:0] write_end1;
  input pwire [3:0] write_bBen1;
  input pwire [3:0] write_enBen1;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire ins_hit;
  input pwire pook_pokahontas;
  
 // pwire [ADDR_WIDTH-1:0] read_addr[1:0];
  pwire [DATA_WIDTH-1:0] read_data_ram[1:0];
  pwire [DATA_WIDTH-1:0] read_datax_ram[1:0];
  pwire enE,enO;
  pwire onE,onO;
  pwire [DATA_WIDTH-1:0] read_dataP;
  pwire [DATA_WIDTH-1:0] read_dataxP;

  pwire [ADDR_WIDTH-1:0] write_addrO;
  pwire [ADDR_WIDTH-1:0] write_addrE;
  pwire write_bankEn;
  pwire [3:0] write_ben;
  
  pwire read_en_reg;
  pwire read_odd_reg;
  pwire ins_hit_reg;

  assign read_dataP=(read_en_reg|ins_hit_reg && ~read_odd_reg) ? read_data_ram[0] : 'z;
  assign read_dataP=(read_en_reg|ins_hit_reg && read_odd_reg) ? read_data_ram[1] : 'z;
  assign read_dataP=(~(read_en_reg|ins_hit_reg)) ? {DATA_WIDTH{1'B0}} : 'z;  

  assign read_dataxP=(read_en_reg|ins_hit_reg && ~read_odd_reg) ? read_datax_ram[0] : 'z;
  assign read_dataxP=(read_en_reg|ins_hit_reg && read_odd_reg) ? read_datax_ram[1] : 'z;
  assign read_dataxP=(~(read_en_reg|ins_hit_reg)) ? {DATA_WIDTH{1'B0}} : 'z;  

  generate
    if (~TOP) begin
        assign read_data=~(read_dataP|read_data_in);
        assign read_datax=~(read_dataxP|read_datax_in);
    end else begin
	assign read_data=~(~read_dataP&read_data_in);
	assign read_datax=~(~read_dataxP&read_datax_in);
    end
  endgenerate
  assign write_addrE=write_bankEn0 ? write_addrE0 : write_addrE1;
  assign write_addrO=write_bankEn0 ? write_addrO0 : write_addrO1;
  assign write_bankEn=write_bankEn0 | write_bankEn1;
 
  assign write_ben=(write_bankEn0 && pwh#(32)::cmpEQ(write_begin0,INDEX)) ? write_bBen0 : 4'bz;
  assign write_ben=(write_bankEn0 && pwh#(32)::cmpEQ(write_end0,INDEX)) ?   write_enBen0 : 4'bz;
  assign write_ben=((write_bankEn0 && write_begin0!=INDEX && write_end0!=INDEX)) ? 4'b1111 : 4'bz;
  assign write_ben=(write_bankEn1 && pwh#(32)::cmpEQ(write_begin1,INDEX)) ? write_bBen1 : 4'bz;
  assign write_ben=(write_bankEn1 && pwh#(32)::cmpEQ(write_end1,INDEX)) ?   write_enBen1 : 4'bz;
  assign write_ben=(write_bankEn1 && write_begin1!=INDEX && write_end1!=INDEX) ? 4'b1111 : 4'bz;
  assign write_ben=(~write_bankEn1 && ~write_bankEn0) ? 4'b0 : 4'bz;
  
  
  dcache2_ram_box ramE_mod(
  .clk(clk),
  .rst(rst),
  .read_nClkEn(~read_en),
  .read_addr(write_addrE),//read/write addr
  .read_data(read_data_ram[0]),
  .read_datax(read_datax_ram[0]),
  .write_data(write_data|{{DATA_WIDTH{pook_pokahontas}}&read_data_ram[0]}),
  .write_wen((write_bankEn && write_hitE0|write_hitE1)|(ins_hit|pook_pokahontas&&~read_odd)),
  .write_ben(write_ben|{4{pook_pokahontas}})
  );

  dcache2_ram_box ramO_mod(
  .clk(clk),
  .rst(rst),
  .read_nClkEn(~read_en),
  .read_addr(write_addrO),//read/write addr
  .read_data(read_data_ram[1]),
  .read_datax(read_datax_ram[1]),
  .write_data(write_data|{{DATA_WIDTH{pook_pokahontas}}&read_data_ram[1]}),
  .write_wen((write_bankEn && write_hitO0|write_hitO1)|(ins_hit|pook_pokahontas&&read_odd)),
  .write_ben(write_ben|{4{pook_pokahontas}})
  );
  
  
  always @(posedge clk)
    begin
      if (rst)
        begin
            read_odd_reg<=1'b0;
            read_en_reg<=1'b0;
            ins_hit_reg<=1'b0;
        end
      else
        begin
            read_odd_reg<=read_odd;
            read_en_reg<=read_en;
            ins_hit_reg<=ins_hit;
        end
    end
  
endmodule

//dcache1_ram read during write behaviour: write first
module dcache2_xbit_ram(
  clk,
  rst,
  read_nClkEn,
  read0_addr,
  read0_data,
  read1_addr,
  read1_data,
  write0_addr,
  write0_data,
  write0_wen,
  write1_addr,
  write1_data,
  write1_wen
  );
  localparam ADDR_WIDTH=8-1;
  localparam DATA_WIDTH=`dcache2_data_width;
  localparam ADDR_COUNT=256/2;
  
  input pwire clk;
  input pwire rst;
  input pwire read_nClkEn;
  input pwire [ADDR_WIDTH-1:0]  read0_addr;
  output pwire [DATA_WIDTH-1:0] read0_data;
  input pwire [ADDR_WIDTH-1:0]  read1_addr;
  output pwire [DATA_WIDTH-1:0] read1_data;
  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire [DATA_WIDTH-1:0] write1_data;
  input pwire                  write1_wen;
  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire                  write0_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read0_addr_reg;
  pwire [ADDR_WIDTH-1:0] read1_addr_reg;
  
  assign read0_data=ram[read0_addr_reg];
  assign read1_data=ram[read1_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read0_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (!read_nClkEn) read0_addr_reg<=read0_addr; 
      if (rst) read1_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (!read_nClkEn) read1_addr_reg<=read1_addr; 
      if (write0_wen) ram[write0_addr]<=write0_data;
      if (write1_wen) ram[write1_addr]<=write1_data;
    end

endmodule

module dcache2_xbit_ram_box(
  clk,
  rst,
  read_nClkEn,
  read0_addr,
  read0_data,
  read0_datax,
  write0_data,
  write0_wen,
  write0_ben,
  read1_addr,
  write1_data,
  write1_wen,
  write1_ben
  );
  localparam ADDR_WIDTH=8-1;
  localparam DATA_WIDTH=`dcache2_data_width;
  
  input pwire clk;
  input pwire rst;
  input pwire read_nClkEn;
  input pwire [ADDR_WIDTH-1:0] read0_addr;
  output pwire [31:0] read0_data;
  output pwire [31:0] read0_datax;
  input pwire [31:0] write0_data;
  input pwire write0_wen;
  input pwire [31:0] write0_ben;
  input pwire [ADDR_WIDTH-1:0] read1_addr;
  input pwire [31:0] write1_data;
  input pwire write1_wen;
  input pwire [31:0] write1_ben;

  pwire [ADDR_WIDTH-1:0]  read0_addr_reg;
  pwire [31:0]            write0_data_reg;
  pwire                   write0_wen_ram;
  pwire [31:0]             write0_ben_reg;
  pwire [DATA_WIDTH-1:0] read0_data_ram;
  pwire [DATA_WIDTH-1:0] write0_data_ram;
  pwire [ADDR_WIDTH-1:0]  read1_addr_reg;
  pwire [31:0]            write1_data_reg;
  pwire                   write1_wen_ram;
  pwire [31:0]             write1_ben_reg;
  pwire [DATA_WIDTH-1:0] read1_data_ram;
  pwire [DATA_WIDTH-1:0] write1_data_ram;

  function [31:0] bcombine;
      input pwire [31:0] bit_en;
      input pwire [31:0] old_data;
      input pwire [31:0] new_data;
      integer t;
      for(t=0;t<32;t=t+1)  bcombine[t]=bit_en[t] ? new_data[t] : old_data[t];
  endfunction
  function [31:0] strip_ECC;
      input pwire [39:1] dataIn;
  
      strip_ECC={dataIn[38:33],dataIn[31:17],dataIn[15:9],dataIn[7:5],dataIn[3]};

  endfunction

  dcache2_xbit_ram ram_mod(
  clk,
  rst,
  read_nClkEn,
  read0_addr,
  read0_data_ram,
  read1_addr,
  read1_data_ram,
  read0_addr_reg,
  write0_data_ram,
  write0_wen_ram,
  read1_addr_reg,
  write1_data_ram,
  write1_wen_ram
  );
  EccGet32 eccA_mod(bcombine(write0_ben_reg,strip_ECC(read0_data_ram),write0_data_reg),write0_data_ram);
  EccGet32 eccB_mod(bcombine(write1_ben_reg,strip_ECC(read1_data_ram),write1_data_reg),write1_data_ram);

  assign read0_data=write0_wen_ram ? strip_ECC(write0_data_ram) : strip_ECC(read0_data_ram);
  assign read0_datax=strip_ECC(read0_data_ram);

  always @(posedge clk) begin
      write0_data_reg<=write0_data;
      write1_data_reg<=write1_data;
      if (rst) begin
          read0_addr_reg<=7'b0;
          write0_wen_ram<=1'b0;
          write0_ben_reg<=32'b0;
          read1_addr_reg<=7'b0;
          write1_wen_ram<=1'b0;
          write1_ben_reg<=32'b0;
      end else begin
          read0_addr_reg<=read0_addr;
          write0_wen_ram<=write0_wen;
          write0_ben_reg<=write0_ben;
          read1_addr_reg<=read1_addr;
          write1_wen_ram<=write1_wen;
          write1_ben_reg<=write1_ben;
      end
  end
endmodule

module dcache2_bitx_bank(
  clk,
  rst,
  read_en,
  read_odd,
  read_data,read_data_in,
  read_datax,read_datax_in,
  write_addrE0, write_hitE0,
  write_addrO0, write_hitO0,
  write_odd0,write_d128_0,
  write_begin0,write_data0,
  write_addrE1, write_hitE1,
  write_addrO1, write_hitO1,
  write_begin1,write_data1,
  write_odd1,write_d128_1,
  write_data,
  ins_hit
  );
  localparam ADDR_WIDTH=8;
  localparam DATA_WIDTH=16;
  parameter [4:0] INDEX=5'd0;
  parameter [0:0] TOP=1'b0;

  input pwire clk;
  input pwire rst;
  input pwire read_en; //+1 cycle
  input pwire read_odd; //+1 cycle
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [DATA_WIDTH-1:0] read_data_in;
  output pwire [DATA_WIDTH-1:0] read_datax;
  input pwire [DATA_WIDTH-1:0] read_datax_in;

  input pwire [ADDR_WIDTH-1:0] write_addrE0;
  input pwire write_hitE0; //+1 cycle
  input pwire [ADDR_WIDTH-1:0] write_addrO0;
  input pwire write_hitO0; //+1 cycle
  input pwire write_odd0;
  input pwire write_d128_0;
  input pwire [4:0] write_begin0;
  input pwire [1:0] write_data0;
  input pwire [ADDR_WIDTH-1:0] write_addrE1;
  input pwire write_hitE1; //+1 cycle
  input pwire [ADDR_WIDTH-1:0] write_addrO1;
  input pwire write_hitO1; //+1 cycle
  input pwire write_odd1;
  input pwire write_d128_1;
  input pwire [4:0] write_begin1;
  input pwire [1:0] write_data1;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire ins_hit;
  
 // pwire [ADDR_WIDTH-1:0] read_addr[1:0];
  pwire [31:0] read_data_ram[1:0];
  pwire [31:0] read_datax_ram[1:0];
  pwire enE,enO;
  pwire onE,onO;
  pwire [15:0] read_dataP;
  pwire [15:0] read_dataxP;

  pwire  [31:0] write_ben0x[1:0];
  pwire  [31:0] write_ben1x[1:0];
  pwire  [31:0] write_ben_ins;
  
  pwire [ADDR_WIDTH-1:0] write_addrE0_reg;
  
  pwire read_en_reg;
  pwire read_odd_reg;
  pwire ins_hit_reg;

  assign read_dataP=(read_en_reg|ins_hit_reg && ~write_addrE0_reg[7]  && ~read_odd_reg) ? read_data_ram[0][15:0] : 'z;
  assign read_dataP=(read_en_reg|ins_hit_reg && ~write_addrE0_reg[7] && read_odd_reg) ? read_data_ram[1][15:0] : 'z;
  assign read_dataP=(read_en_reg|ins_hit_reg && write_addrE0_reg[7]  && ~read_odd_reg) ? read_data_ram[0][31:16] : 'z;
  assign read_dataP=(read_en_reg|ins_hit_reg && write_addrE0_reg[7] && read_odd_reg) ? read_data_ram[1][31:16] : 'z;
  assign read_dataP=(~(read_en_reg|ins_hit_reg)) ? {DATA_WIDTH{1'B0}} : 'z;  

  assign read_dataxP=(read_en_reg|ins_hit_reg && ~write_addrE0_reg[7] && ~read_odd_reg) ? read_datax_ram[0][15:0] : 'z;
  assign read_dataxP=(read_en_reg|ins_hit_reg && ~write_addrE0_reg[7] && read_odd_reg) ? read_datax_ram[1][15:0] : 'z;
  assign read_dataxP=(read_en_reg|ins_hit_reg && write_addrE0_reg[7] && ~read_odd_reg) ? read_datax_ram[0][31:16] : 'z;
  assign read_dataxP=(read_en_reg|ins_hit_reg && write_addrE0_reg[7] && read_odd_reg) ? read_datax_ram[1][31:16] : 'z;
  assign read_dataxP=(~(read_en_reg|ins_hit_reg)) ? {DATA_WIDTH{1'B0}} : 'z;  

  generate
    if (~TOP) begin
        assign read_data=~(read_dataP|read_data_in);
        assign read_datax=~(read_dataxP|read_datax_in);
    end else begin
	assign read_data=~(~read_dataP&read_data_in);
	assign read_datax=~(~read_dataxP&read_datax_in);
    end
  endgenerate

  always @* begin 
      write_ben0x[write_odd0]=32'd1<<{write_odd0 ? write_addrO0[7] : write_addrE0[7],write_begin0[4:1]};
      write_ben1x[write_odd1]=32'd1<<{write_odd1 ? write_addrO1[7] : write_addrE1[7],write_begin1[4:1]};
      write_ben0x[~write_odd0]=0;
      write_ben1x[~write_odd1]=0;
      write_ben_ins=write_addrE0_reg[7] ? 32'hffff0000 : 32'h0000ffff;  
      if (write_d128_0) begin
          if (write_begin0[4:1]!=4'hf) write_ben0x[write_odd0]=write_ben0x[write_odd0]| (
	      32'd2<<{write_odd0 ? write_addrO0[7] : write_addrE0[7],write_begin0[4:1]});
          else write_ben0x[~write_odd0]=32'd1<<{~write_odd0 ? write_addrO0[7] : write_addrE0[7],4'b0};
      end
      if (write_d128_1) begin
          if (write_begin1[4:1]!=4'hf) write_ben1x[write_odd1]=write_ben1x[write_odd1] | ( 
	      32'd2<<{write_odd1 ? write_addrO1[7] : write_addrE1[7],write_begin1[4:1]});
          else write_ben1x[~write_odd1]=32'd1<<{write_odd1 ? write_addrO1[7] : write_addrE1[7],4'b0};
      end
  end
  dcache2_xbit_ram_box ramE_mod(
  .clk(clk),
  .rst(rst),
  .read_nClkEn(~read_en),
  .read0_addr(write_addrE0[6:0]),//read/write addr
  .read0_data(read_data_ram[0]),
  .read0_datax(read_datax_ram[0]),
  .write0_data(ins_hit ? {write_data,write_data} : write_begin0[1] ? {16{{write_data0[0],write_data0[1]}}} : {16{write_data0}}),
  .write0_wen((write_hitE0)|(ins_hit&~read_odd)),
  .write0_ben(ins_hit ? write_ben_ins : write_ben0x[0]),
  .read1_addr(write_addrE1[6:0]),//read/write addr
  .write1_data(ins_hit ? {write_data,write_data} : write_begin1[1] ? {16{{write_data1[0],write_data1[1]}}} : {16{write_data1}}),
  .write1_wen((write_hitE1)|(ins_hit&~read_odd)),
  .write1_ben(ins_hit ? write_ben_ins : write_ben1x[0])
  );

  dcache2_xbit_ram_box ramO_mod(
  .clk(clk),
  .rst(rst),
  .read_nClkEn(~read_en),
  .read0_addr(write_addrO0[6:0]),//read/write addr
  .read0_data(read_data_ram[1]),
  .read0_datax(read_datax_ram[1]),
  .write0_data(ins_hit ? {write_data,write_data} : write_begin0[1] ? {16{{write_data0[0],write_data0[1]}}} : {16{write_data0}}),
  .write0_wen((write_hitO0)|(ins_hit&read_odd)),
  .write0_ben(ins_hit ? write_ben_ins : write_ben0x[1]),
  .read1_addr(write_addrO1[6:0]),//read/write addr
  .write1_data(ins_hit ? {write_data,write_data} : write_begin1[1] ? {16{{write_data1[0],write_data1[1]}}} : {16{write_data1}}),
  .write1_wen((write_hitO1)|(ins_hit&read_odd)),
  .write1_ben(ins_hit ? write_ben_ins : write_ben1x[1])
  );

  
  always @(posedge clk)
    begin
      if (rst)
        begin
            read_odd_reg<=1'b0;
            read_en_reg<=1'b0;
            ins_hit_reg<=1'b0;
	    write_addrE0_reg<=0;
        end
      else
        begin
            read_odd_reg<=read_odd;
            read_en_reg<=read_en;
            ins_hit_reg<=ins_hit;
	    write_addrE0_reg<=write_addrE0;
        end
    end
  
endmodule


module dcache2_way(
  clk,
  rst,
  read_en,read_odd,
  read_data,read_data_in,
  read_dataX,read_dataX_in,
  read_dataPTR,read_dataPTR_in,
  read_dataPTRx,read_dataPTRx_in,
  read_hit,read_inL1, // 1 cycle before data
  write0_clkEn,
  write_addrE0, write_hitE0,
  write_addrO0, write_hitO0,
  write_bankEn0,write_pbit0, 
  write_begin0,write_end0,
  write_bBen0,write_enBen0,
  write_odd0,write_split0,
  write_d128_0,
  write1_clkEn,
  write_addrE1, write_hitE1,
  write_addrO1, write_hitO1,
  write_bankEn1,write_pbit1,
  write_begin1,write_end1,
  write_bBen1,write_enBen1,
  write_odd1,write_split1,
  write_d128_1,
  write_data,
  write_dataPTR,
  ins_hit,
  insert,
  insert_excl,insert_dirty,insert_dupl,insert_pook,
  LRU_hit, read_LRU, read_dir, read_excl, read_expAddr,
  read_LRU_in, read_dir_in, read_excl_in, read_expAddr_in,
  expAddr_en,
  expun_cc_addr,
  expun_cc_en,
  expun_dc_addr,
  expun_dc_en
// init
  );
  localparam ADDR_WIDTH=36;
  localparam DATA_WIDTH=32;
  parameter [4:0] ID=0;
  parameter [1:0] BIG_ID=0;

  input pwire clk;
  input pwire rst;
  input pwire read_en; 
  input pwire read_odd;
  output pwire [32*DATA_WIDTH-1:0] read_data;
  input pwire [32*DATA_WIDTH-1:0] read_data_in;
  output pwire [32*DATA_WIDTH-1:0] read_dataX;
  input pwire [32*DATA_WIDTH-1:0] read_dataX_in;
  output pwire [15:0] read_dataPTR;
  input pwire [15:0] read_dataPTR_in;
  output pwire [15:0] read_dataPTRx;
  input pwire [15:0] read_dataPTRx_in;
  output pwire read_hit; //1 cycle before data
  output pwire read_inL1;

  input pwire write0_clkEn;
  input pwire [ADDR_WIDTH-1:0] write_addrE0;
  input pwire write_hitE0; //+1 cycle
  input pwire [ADDR_WIDTH-1:0] write_addrO0;
  input pwire write_hitO0; //+1 cycle
  input pwire [31:0] write_bankEn0;
  input pwire [4:0] write_begin0;
  input pwire [4:0] write_end0;
  input pwire [3:0] write_bBen0;
  input pwire [3:0] write_enBen0;
  input pwire [1:0] write_pbit0;
  input pwire write_d128_0;
  input pwire write_odd0,write_split0;
  input pwire write1_clkEn;
  input pwire [ADDR_WIDTH-1:0] write_addrE1;
  input pwire write_hitE1; //+1 cycle
  input pwire [ADDR_WIDTH-1:0] write_addrO1;
  input pwire write_hitO1; //+1 cycle
  input pwire [31:0] write_bankEn1;
  input pwire [4:0] write_begin1;
  input pwire [4:0] write_end1;
  input pwire [3:0] write_bBen1;
  input pwire [3:0] write_enBen1;
  input pwire [1:0] write_pbit1;
  input pwire write_d128_1;
  input pwire write_odd1,write_split1;
  input pwire [32*DATA_WIDTH-1:0] write_data;
  input pwire [15:0] write_dataPTR;
  output pwire ins_hit;
  input pwire insert;
  input pwire insert_excl;
  input pwire insert_dirty;
  input pwire insert_dupl;
  input pwire insert_pook;
  input pwire [4:0] LRU_hit;
  output pwire [4:0] read_LRU;
  output pwire [1:0] read_dir;
  output pwire [1:0] read_excl;
  output pwire [36:0] read_expAddr;
//  input pwire init;
  input pwire [4:0] read_LRU_in;
  input pwire [1:0] read_dir_in;
  input pwire [1:0] read_excl_in;
  input pwire [36:0] read_expAddr_in;
  input pwire expAddr_en;
  input pwire [36:0] expun_cc_addr;
  input pwire expun_cc_en;
  input pwire [36:0] expun_dc_addr;
  input pwire expun_dc_en;

  pwire write0_hitE;
  pwire write0_hitO;
  pwire write1_hitE;
  pwire write1_hitO;
  pwire write0_hitE_reg;
  pwire write0_hitO_reg;
  pwire write1_hitE_reg;
  pwire write1_hitO_reg;
  pwire write0_hitEL;
  pwire write0_hitOL;
  pwire write0_hitEH;
  pwire write0_hitOH;
  pwire write1_hitEL;
  pwire write1_hitOL;
  pwire write1_hitEH;
  pwire write1_hitOH;
  pwire read_en_reg,read_en_reg2,read_en_reg3,read_en_reg4,read_en_reg5;
  pwire insert_reg,insert_reg2,insert_reg3,insert_reg4,insert_reg5;
  pwire read_odd_reg,read_odd_reg2,read_odd_reg3,read_odd_reg4,read_odd_reg5;
  pwire init,init_reg,init_reg2;
  pwire [7:0] initCount;
  pwire [7:0] initCount_next;
  
  pwire [4:0] read_LRUE;
  pwire [4:0] read_LRUO;
  pwire [4:0] read_LRUx;
  pwire [4:0] new_LRU;
  pwire [4:0] read_LRUx_reg;
  pwire [4:0] read_LRUx_reg2;
  
  pwire write0_clkEn_reg;
  pwire write1_clkEn_reg;
  pwire [ADDR_WIDTH-1:0] write_addrE0_reg;
  pwire write_hitE0_reg; 
  pwire [ADDR_WIDTH-1:0] write_addrO0_reg;
  pwire write_hitO0_reg;
  pwire [31:0] write_bankEn0_reg;
  pwire [4:0] write_begin0_reg;
  pwire [4:0] write_end0_reg;
  pwire [3:0] write_bBen0_reg;
  pwire [3:0] write_enBen0_reg;
  pwire [ADDR_WIDTH-1:0] write_addrE1_reg;
  pwire write_hitE1_reg;
  pwire [ADDR_WIDTH-1:0] write_addrO1_reg;
  pwire write_hitO1_reg;
  pwire [31:0] write_bankEn1_reg;
  pwire [4:0] write_begin1_reg;
  pwire [4:0] write_end1_reg;
  pwire [3:0] write_bBen1_reg;
  pwire [3:0] write_enBen1_reg;
  pwire write_odd0_reg;
  pwire write_odd1_reg;
  pwire [1:0] write_pbit0_reg;
  pwire [1:0] write_pbit1_reg;
  pwire write_d128_0_reg;
  pwire write_d128_1_reg;

  pwire write0_clkEn_reg2;
  pwire write1_clkEn_reg2;
  pwire [ADDR_WIDTH-1:0] write_addrE0_reg2;
  pwire write_hitE0_reg2; 
  pwire [ADDR_WIDTH-1:0] write_addrO0_reg2;
  pwire write_hitO0_reg2;
  pwire [31:0] write_bankEn0_reg2;
  pwire [4:0] write_begin0_reg2;
  pwire [4:0] write_end0_reg2;
  pwire [3:0] write_bBen0_reg2;
  pwire [3:0] write_enBen0_reg2;
  pwire [ADDR_WIDTH-1:0] write_addrE1_reg2;
  pwire write_hitE1_reg2;
  pwire [ADDR_WIDTH-1:0] write_addrO1_reg2;
  pwire write_hitO1_reg2;
  pwire [31:0] write_bankEn1_reg2;
  pwire [4:0] write_begin1_reg2;
  pwire [4:0] write_end1_reg2;
  pwire [3:0] write_bBen1_reg2;
  pwire [3:0] write_enBen1_reg2;
  pwire write_odd0_reg2;
  pwire write_odd1_reg2;
  pwire [1:0] write_pbit0_reg2;
  pwire [1:0] write_pbit1_reg2;
  pwire write_d128_0_reg2;
  pwire write_d128_1_reg2;

  pwire [7:0] write_addrE0_reg3;
  pwire [7:0] write_addrO0_reg3;
  pwire [7:0] write_addrE0_reg4;
  pwire [7:0] write_addrO0_reg4;
  pwire [7:0] write_addrE0_reg5;
  pwire [7:0] write_addrO0_reg5;
  
  pwire [1:0] dirtyE;
  pwire [1:0] dirtyO;
  pwire [1:0] exclE;
  pwire [1:0] exclO;
  pwire [35:0] expAddrE;
  pwire [35:0] expAddrO;
  pwire [1:0] read_dirx;
  pwire [1:0] read_exclx;
  pwire [36:0] read_expAddrx;
  pwire [1:0] read_dirx_reg;
  pwire [1:0] read_exclx_reg;
  pwire [36:0] read_expAddrx_reg;

  pwire expun_imm;
  pwire [1:0] dirtyE_reg;
  pwire [1:0] dirtyO_reg;
  pwire [1:0] exclE_reg;
  pwire [1:0] exclO_reg;
  pwire [35:0] expAddrE_reg;
  pwire [35:0] expAddrO_reg;
  pwire [1:0] dirtyE_reg2;
  pwire [1:0] dirtyO_reg2;
  pwire [1:0] exclE_reg2;
  pwire [1:0] exclO_reg2;
  pwire [35:0] expAddrE_reg2;
  pwire [35:0] expAddrO_reg2;
 
  pwire [7:0] expun_dc_addr_reg;
  pwire [7:0] expun_cc_addr_reg;

  pwire insert_pook_reg;
  pwire insert_pook_reg2;

  pwire read_enL,read_enH;
  pwire write0_hitEL_reg;
  pwire write0_hitOL_reg;
  pwire write0_hitEH_reg;
  pwire write0_hitOH_reg;
  pwire write1_hitEL_reg;
  pwire write1_hitOL_reg;
  pwire write1_hitEH_reg;
  pwire write1_hitOH_reg;
  pwire write0_hitEL_reg2;
  pwire write0_hitOL_reg2;
  pwire write0_hitEH_reg2;
  pwire write0_hitOH_reg2;
  pwire write1_hitEL_reg2;
  pwire write1_hitOL_reg2;
  pwire write1_hitEH_reg2;
  pwire write1_hitOH_reg2;
  pwire write0_hitEL_reg3;
  pwire write0_hitOL_reg3;
  pwire write0_hitEH_reg3;
  pwire write0_hitOH_reg3;
  pwire write1_hitEL_reg3;
  pwire write1_hitOL_reg3;
  pwire write1_hitEH_reg3;
  pwire write1_hitOH_reg3;
 
  pwire read_hit_reg;
  pwire ins_hit_reg;
  pwire ins_hit_reg2;
 
  pwire [15:0] expun_dataE;
  pwire [15:0] expun_dataO;

  pwire expun_dc_hitE,expun_dc_hitO;
  pwire expun_cc_hitE,expun_cc_hitO;

  pwire [4:0] read_LRUP;
  pwire [1:0] read_dirP;
  pwire [1:0] read_exclP;
  pwire [36:0] read_expAddrP;
  
  dcache2_tag tagW0_mod(
  .clk(clk),
  .rst(rst),
  .req_wrtEn(write_hitO0|write_hitE0 && ~read_en),
  .req_en(write_hitO0|write_hitE0|read_en),
  .req_addrE(write_addrE0),
  .req_addrO(write_addrO0),
  .req_odd(write_odd0),
  .req_waddrE(write_addrE0),
  .req_waddrO(write_addrO0),
  .req_wodd(write_odd0),
  .req_split(write_split0),
  .req_hitE(write0_hitE),.req_hitO(write0_hitO),
  .req_shitE(),.req_shitO(),
  .req_exclE(exclE[0]),.req_exclO(exclO[0]),
  .req_dir_ins_E(dirtyE[0]),.req_dir_ins_O(dirtyO[0]),
  .req_hitEL(write0_hitEL),.req_hitOL(write0_hitOL),
  .req_hitEH(write0_hitEH),.req_hitOH(write0_hitOH),
  .req_LRUe(read_LRUE),.req_LRUo(read_LRUO),
  .write_wen(insert|expAddr_en),
  .write_dupl(insert_dupl),
  .write_hit(ins_hit),
  .write_exp(expAddr_en),
  .write_excl(insert_excl),.write_dir_ins(insert_dirty),
  .expun_addrE(expAddrE),.expun_addrO(expAddrO),
  .init(init),.initCount(initCount)
  );
  
  dcache2_tag tagW1_mod(
  .clk(clk),
  .rst(rst),
  .req_wrtEn(write_hitO0|write_hitE0 && ~read_en),
  .req_en(write_hitO0|write_hitE0|read_en),
  .req_addrE(write_addrE1),
  .req_addrO(write_addrO1),
  .req_odd(write_odd1),
  .req_waddrE(write_addrE1),
  .req_waddrO(write_addrO1),
  .req_wodd(write_odd0),
  .req_split(write_split1),
  .req_hitE(write1_hitE),.req_hitO(write1_hitO),
  .req_shitE(),.req_shitO(),
  .req_exclE(exclE[1]),.req_exclO(exclO[1]),
  .req_dir_ins_E(dirtyE[1]),.req_dir_ins_O(dirtyO[1]),
  .req_hitEL(write1_hitEL),.req_hitOL(write1_hitOL),
  .req_hitEH(write1_hitEH),.req_hitOH(write1_hitOH),
  .req_LRUe(read_LRUE),.req_LRUo(read_LRUO),
  .write_wen(insert|expAddr_en),
  .write_dupl(insert_dupl),
  .write_hit(ins_hit),
  .write_exp(expAddr_en),
  .write_excl(insert_excl),.write_dir_ins(insert_dirty),
  .expun_addrE(),.expun_addrO(),
  .init(init),.initCount(initCount)
  );
  
  dcache2_tag #(1)  tagEW0_mod(
  .clk(clk),
  .rst(rst),
  .req_wrtEn(write_hitO0|write_hitE0 && ~read_en),
  .req_en(write_hitO0|write_hitE0|read_en),
  .req_addrE(expun_cc_addr[36:1]),
  .req_addrO(expun_cc_addr[36:1]),
  .req_odd(expun_cc_addr[0]),
  .req_waddrE(write_addrE0),
  .req_waddrO(write_addrO0),
  .req_wodd(write_odd0),
  .req_split(1'b0),
  .req_hitE(write0_hitE),.req_hitO(write0_hitO),
  .req_shitE(expun_cc_hitE),.req_shitO(expun_cc_hitO),
  .req_exclE(),.req_exclO(),
  .req_dir_ins_E(dirtyE[0]),.req_dir_ins_O(dirtyO[0]),
  .req_hitEL(write0_hitEL),.req_hitOL(write0_hitOL),
  .req_hitEH(write0_hitEH),.req_hitOH(write0_hitOH),
  .req_LRUe(read_LRUE),.req_LRUo(read_LRUO),
  .write_wen(insert|expAddr_en),
  .write_dupl(insert_dupl),
  .write_hit(ins_hit),
  .write_exp(expAddr_en),
  .write_excl(insert_excl),.write_dir_ins(insert_dirty),
  .expun_addrE(),.expun_addrO(),
  .init(init),.initCount(initCount)
  );
  
  dcache2_tag #(1) tagEW1_mod(
  .clk(clk),
  .rst(rst),
  .req_wrtEn(write_hitO0|write_hitE0 && ~read_en),
  .req_en(write_hitO0|write_hitE0|read_en),
  .req_addrE(expun_dc_addr[36:1]),
  .req_addrO(expun_dc_addr[36:1]),
  .req_odd(expun_dc_addr[0]),
  .req_waddrE(write_addrE0),
  .req_waddrO(write_addrO0),
  .req_wodd(write_odd0),
  .req_split(1'b0),
  .req_hitE(write0_hitE),.req_hitO(write0_hitO),
  .req_shitE(expun_dc_hitE),.req_shitO(expun_dc_hitO),
  .req_exclE(exclE[1]),.req_exclO(exclO[1]),
  .req_dir_ins_E(dirtyE[1]),.req_dir_ins_O(dirtyO[1]),
  .req_hitEL(write1_hitEL),.req_hitOL(write1_hitOL),
  .req_hitEH(write1_hitEH),.req_hitOH(write1_hitOH),
  .req_LRUe(read_LRUE),.req_LRUo(read_LRUO),
  .write_wen(insert|expAddr_en),
  .write_dupl(insert_dupl),
  .write_hit(ins_hit),
  .write_exp(expAddr_en),
  .write_excl(insert_excl),.write_dir_ins(insert_dirty),
  .expun_addrE(),.expun_addrO(),
  .init(init),.initCount(initCount)
  );
  
  dc2_thag_ram present_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_en),
  .read_addr({write_addrE0[2:0],write_odd0}),
  .read_data(expun_dataE),
  .write0_addr(expun_cc_addr_reg[3:0]),
  .write0_data(16'b0),
  .write0_wen(expun_cc_hitE|expun_cc_hitO),
  .write0_bitEn(16'b1<<expun_cc_addr_reg[7:5]),
  .write1_addr(expun_dc_addr_reg[3:0]),
  .write1_data(16'b0),
  .write1_wen(expun_dc_hitE|expun_cc_hitO),
  .write1_bitEn(16'b1<<expun_dc_addr_reg[7:4]),
  .write2_addr({write_addrE0_reg[2:0],write_odd0_reg}),
  .write2_data(16'hffff),
  .write2_wen(ins_hit),
  .write2_bitEn(16'b1<<write_addrE0_reg[6:3])
  );
  
//  assign ins_hit=pwh#(32)::cmpEQ(rand_reg,ID) && rand_en_reg2 && insert_reg;
  dcache2_LRU_ram LRUe_mod(
  .clk(clk),
  .rst(rst),
  .read_nClkEn(~read_en),
  .read_addr(write_addrE0[7:0]),
  .read_data(read_LRUE),
  .write_addr(init ? initCount : write_addrE0_reg5[7:0]),
  .write_data(new_LRU),
  .write_wen(insert_reg5 & ~read_odd_reg5 || init || read_en_reg5 & ~read_odd_reg5)
  );
 
  dcache2_LRU_ram LRUo_mod(
  .clk(clk),
  .rst(rst),
  .read_nClkEn(~read_en),
  .read_addr(write_addrO0[7:0]),
  .read_data(read_LRUO),
  .write_addr(init ? initCount : write_addrO0_reg5[7:0]),
  .write_data(new_LRU),
  .write_wen(insert_reg5 & read_odd_reg5 || init || read_en_reg5 & read_odd_reg5)
  );

  generate
    if (~ID[0]) begin
	assign read_LRU=~(read_LRUP | read_LRU_in);
	assign read_dir=~(read_dirP | read_dir_in);
	assign read_excl=~(read_exclP | read_excl_in);
	assign read_expAddr=~(read_expAddrP | read_expAddr_in);
    end else begin
	assign read_LRU=~(~read_LRUP & read_LRU_in);
	assign read_dir=~(~read_dirP & read_dir_in);
	assign read_excl=~(~read_exclP & read_excl_in);
	assign read_expAddr=~(~read_expAddrP & read_expAddr_in);
    end
  endgenerate

  assign expun_imm=expun_dataE[write_addrE0[6:3]]; 

  assign read_LRUx=write_odd0_reg ? read_LRUO : read_LRUE;
  assign read_dirx=dirtyO | dirtyE;
  assign read_exclx=exclO | exclE;
  assign read_expAddrx=write_odd0_reg ? {expAddrO,1'b1} : {expAddrE,1'b0};

  assign read_LRUP={5{read_hit_reg}} & read_LRUx_reg;
  assign read_dirP={2{read_hit_reg}} & read_dirx_reg;
  assign read_exclP={2{read_hit_reg}} & read_exclx_reg;
  assign read_expAddrP={37{read_hit_reg}} & read_expAddrx_reg;

  lru_single #(5,{3'b0,BIG_ID}*5'h9+ID) lru_mod(
  .lru(read_LRUx_reg2),
  .newLRU(new_LRU),
  .LRU_hit(LRU_hit),
  .init(init),
  .en(~insert_reg5)
  );


  assign read_enL=read_en_reg2 & (write0_hitE_reg & ~read_odd_reg2 || write0_hitO_reg & read_odd_reg2);
  assign read_enH=read_en_reg2 & (write0_hitE_reg & ~read_odd_reg2 || write0_hitO_reg & read_odd_reg2);
  assign read_hit=insert_reg2 ? ins_hit_reg : read_enL;

  adder_inc #(8) initAdd_mod(initCount,initCount_next,1'b1,);
  dcache2_bitx_bank pbit_mod(
  .clk(clk),
  .rst(rst),
  .read_en(read_enL|read_enH|ins_hit_reg),
  .read_odd(read_odd_reg2),
  .read_data(read_dataPTR),.read_data_in(read_dataPTR_in),
  .read_datax(read_dataPTRx),.read_datax_in(read_dataPTRx_in),
  .write_addrE0(write_addrE0_reg2[7:0]), .write_hitE0(write0_hitEL_reg3),
  .write_addrO0(write_addrO0_reg2[7:0]), .write_hitO0(write0_hitOL_reg3),
  .write_begin0(write_begin0_reg2),.write_data0(write_pbit0_reg2),
  .write_d128_0(write_d128_0_reg2),.write_odd0(write_odd0_reg2),
  .write_addrE1(write_addrE1_reg2[7:0]), .write_hitE1(write1_hitEL_reg3),
  .write_addrO1(write_addrO1_reg2[7:0]), .write_hitO1(write1_hitOL_reg3),
  .write_begin1(write_begin1_reg2),.write_data1(write_pbit1_reg2),
  .write_d128_1(write_d128_1_reg2),.write_odd1(write_odd1_reg2),
  .write_data(write_dataPTR),
  .ins_hit(ins_hit_reg)
  );
  generate
      genvar b;
      for(b=0;b<16;b=b+1) begin : bank_gen
          dcache2_bank #(b[4:0],ID[0]) bankL_mod(
          .clk(clk),
          .rst(rst),
          .read_en(read_enL|ins_hit_reg),
          .read_odd(read_odd_reg2),
          .read_data(read_data[DATA_WIDTH*b+:DATA_WIDTH]),
          .read_data_in(read_data_in[DATA_WIDTH*b+:DATA_WIDTH]),
          .read_datax(read_dataX[DATA_WIDTH*b+:DATA_WIDTH]),
          .read_datax_in(read_dataX_in[DATA_WIDTH*b+:DATA_WIDTH]),
          .write_addrE0(write_addrE0_reg2[7:0]), .write_hitE0(write0_hitEL_reg3),
          .write_addrO0(write_addrO0_reg2[7:0]), .write_hitO0(write0_hitOL_reg3),
          .write_bankEn0(write_bankEn0_reg2[b] && write0_clkEn_reg2|ins_hit_reg), 
          .write_begin0(write_begin0_reg2),.write_end0(write_end0_reg2),
          .write_bBen0(write_bBen0_reg2),.write_enBen0(write_enBen0_reg2),
          .write_addrE1(write_addrE1_reg2[7:0]), .write_hitE1(write1_hitEL_reg3),
          .write_addrO1(write_addrO1_reg2[7:0]), .write_hitO1(write1_hitOL_reg3),
          .write_bankEn1(write_bankEn1_reg2[b] && write1_clkEn_reg2), 
          .write_begin1(write_begin1_reg2),.write_end1(write_end1_reg2),
          .write_bBen1(write_bBen1_reg2),.write_enBen1(write_enBen1_reg2),
          .write_data(write_data[DATA_WIDTH*b+:DATA_WIDTH]),
          .ins_hit(ins_hit_reg),
          .pook_pokahontas(insert_pook_reg2)
          );
          dcache2_bank #(b[4:0]+5'd16,ID[0]) bankH_mod(
          .clk(clk),
          .rst(rst),
          .read_en(read_enH|ins_hit_reg),
          .read_odd(read_odd_reg2),
          .read_data(read_data[DATA_WIDTH*(b+16)+:DATA_WIDTH]),
          .read_data_in(read_data_in[DATA_WIDTH*(b+16)+:DATA_WIDTH]),
          .read_datax(read_dataX[DATA_WIDTH*(b+16)+:DATA_WIDTH]),
          .read_datax_in(read_dataX_in[DATA_WIDTH*(b+16)+:DATA_WIDTH]),
          .write_addrE0(write_addrE0_reg2[7:0]), .write_hitE0(write0_hitEH_reg3),
          .write_addrO0(write_addrO0_reg2[7:0]), .write_hitO0(write0_hitOH_reg3),
          .write_bankEn0(write_bankEn0_reg2[b+16] && write0_clkEn_reg2|ins_hit_reg), 
          .write_begin0(write_begin0_reg2),.write_end0(write_end0_reg2),
          .write_bBen0(write_bBen0_reg2),.write_enBen0(write_enBen0_reg2),
          .write_addrE1(write_addrE1_reg2[7:0]), .write_hitE1(write1_hitEH_reg3),
          .write_addrO1(write_addrO1_reg2[7:0]), .write_hitO1(write1_hitOH_reg3),
          .write_bankEn1(write_bankEn1_reg2[b+16] && write1_clkEn_reg2), 
          .write_begin1(write_begin1_reg2),.write_end1(write_end1_reg2),
          .write_bBen1(write_bBen1_reg2),.write_enBen1(write_enBen1_reg2),
          .write_data(write_data[DATA_WIDTH*(b+16)+:DATA_WIDTH]),
          .ins_hit(ins_hit_reg),
          .pook_pokahontas(insert_pook_reg2)
          );
      end
  endgenerate

  always @(posedge clk) begin
      if (rst) begin
          write0_hitEL_reg<=1'b0;
          write0_hitOL_reg<=1'b0;
          write1_hitEL_reg<=1'b0;
          write1_hitOL_reg<=1'b0;
          write0_hitEH_reg<=1'b0;
          write0_hitOH_reg<=1'b0;
          write1_hitEH_reg<=1'b0;
          write1_hitOH_reg<=1'b0;
          write0_hitEL_reg2<=1'b0;
          write0_hitOL_reg2<=1'b0;
          write1_hitEL_reg2<=1'b0;
          write1_hitOL_reg2<=1'b0;
          write0_hitEH_reg2<=1'b0;
          write0_hitOH_reg2<=1'b0;
          write1_hitEH_reg2<=1'b0;
          write1_hitOH_reg2<=1'b0;
          write0_hitEL_reg3<=1'b0;
          write0_hitOL_reg3<=1'b0;
          write1_hitEL_reg3<=1'b0;
          write1_hitOL_reg3<=1'b0;
          write0_hitEH_reg3<=1'b0;
          write0_hitOH_reg3<=1'b0;
          write1_hitEH_reg3<=1'b0;
          write1_hitOH_reg3<=1'b0;
	  write_odd0_reg<=1'b0;
	  write_odd1_reg<=1'b0;
	  write_odd0_reg2<=1'b0;
	  write_odd1_reg2<=1'b0;
          read_odd_reg<=1'b0;
          read_en_reg<=1'b0;
          read_odd_reg2<=1'b0;
          read_en_reg2<=1'b0;
          read_odd_reg3<=1'b0;
          read_en_reg3<=1'b0;
          read_odd_reg4<=1'b0;
          read_en_reg4<=1'b0;
          read_odd_reg5<=1'b0;
          read_en_reg5<=1'b0;
	  write_pbit0_reg<=2'b0;
	  write_pbit1_reg<=2'b0;
	  write_pbit0_reg2<=2'b0;
	  write_pbit1_reg2<=2'b0;
	  write_d128_0_reg<=1'b0;
	  write_d128_1_reg<=1'b0;
	  write_d128_0_reg2<=1'b0;
	  write_d128_1_reg2<=1'b0;
          insert_reg<=1'b0;
          insert_reg2<=1'b0;
          insert_reg3<=1'b0;
          insert_reg4<=1'b0;
          insert_reg5<=1'b0;
          read_LRUx_reg<=5'b0;
          read_LRUx_reg2<=5'b0;
          dirtyE_reg<=2'b0;
          dirtyO_reg<=2'b0;
          dirtyE_reg2<=2'b0;
          dirtyO_reg2<=2'b0;
          exclE_reg<=2'b0;
          exclO_reg<=2'b0;
          exclE_reg2<=2'b0;
          exclO_reg2<=2'b0;
          read_dirx_reg<=2'b0;
          read_exclx_reg<=2'b0;
          read_expAddrx_reg<=37'b0;
          read_hit_reg<=1'b0;
          ins_hit_reg<=1'b0;
          ins_hit_reg2<=1'b0;
	  write0_clkEn_reg<=1'b0;
	  write1_clkEn_reg<=1'b0;
	  write0_clkEn_reg2<=1'b0;
	  write1_clkEn_reg2<=1'b0;
	  write0_hitE_reg<=1'b0;
	  write0_hitO_reg<=1'b0;
	  read_inL1<=1'b0;
          insert_pook_reg<=1'b0;
          insert_pook_reg2<=1'b0;
	  expun_cc_addr_reg<=8'b0;
	  expun_dc_addr_reg<=8'b0;
      end else begin
          write0_hitEL_reg<=write0_hitEL;
          write0_hitOL_reg<=write0_hitOL;
          write1_hitEL_reg<=write1_hitEL;
          write1_hitOL_reg<=write1_hitOL;
          write0_hitEH_reg<=write0_hitEH;
          write0_hitOH_reg<=write0_hitOH;
          write1_hitEH_reg<=write1_hitEH;
          write1_hitOH_reg<=write1_hitOH;
          write0_hitEL_reg2<=write0_hitEL_reg;
          write0_hitOL_reg2<=write0_hitOL_reg;
          write1_hitEL_reg2<=write1_hitEL_reg;
          write1_hitOL_reg2<=write1_hitOL_reg;
          write0_hitEH_reg2<=write0_hitEH_reg;
          write0_hitOH_reg2<=write0_hitOH_reg;
          write1_hitEH_reg2<=write1_hitEH_reg;
          write1_hitOH_reg2<=write1_hitOH_reg;
          write0_hitEL_reg3<=write0_hitEL_reg2;
          write0_hitOL_reg3<=write0_hitOL_reg2;
          write1_hitEL_reg3<=write1_hitEL_reg2;
          write1_hitOL_reg3<=write1_hitOL_reg2;
          write0_hitEH_reg3<=write0_hitEH_reg2;
          write0_hitOH_reg3<=write0_hitOH_reg2;
          write1_hitEH_reg3<=write1_hitEH_reg2;
          write1_hitOH_reg3<=write1_hitOH_reg2;
	  write_odd0_reg<=write_odd0;
	  write_odd1_reg<=write_odd1;
	  write_odd0_reg2<=write_odd0_reg;
	  write_odd1_reg2<=write_odd1_reg;
          read_odd_reg<=read_odd;
          read_en_reg<=read_en;
          read_odd_reg2<=read_odd_reg;
          read_en_reg2<=read_en_reg;
          read_odd_reg3<=read_odd_reg2;
          read_en_reg3<=read_en_reg2;
          read_odd_reg4<=read_odd_reg2;
          read_en_reg4<=read_en_reg3;
          read_odd_reg5<=read_odd_reg2;
          read_en_reg5<=read_en_reg4;
	  write_pbit0_reg<=write_pbit0;
	  write_pbit1_reg<=write_pbit1;
	  write_pbit0_reg2<=write_pbit0_reg;
	  write_pbit1_reg2<=write_pbit1_reg;
	  write_d128_0_reg<=write_d128_0;
	  write_d128_1_reg<=write_d128_1;
	  write_d128_0_reg2<=write_d128_0_reg;
	  write_d128_1_reg2<=write_d128_1_reg;
          insert_reg<=insert;
          insert_reg2<=insert_reg;
          insert_reg3<=insert_reg2;
          insert_reg4<=insert_reg3;
          insert_reg5<=insert_reg4;
          read_LRUx_reg<=read_LRUx;
          read_LRUx_reg2<=read_LRUx_reg;
          dirtyE_reg<=dirtyE;
          dirtyO_reg<=dirtyO;
          dirtyE_reg2<=dirtyE_reg;
          dirtyO_reg2<=dirtyO_reg;
          exclE_reg<=exclE;
          exclO_reg<=exclO;
          exclE_reg2<=exclE_reg;
          exclO_reg2<=exclO_reg;
          read_dirx_reg<=read_dirx;
          read_exclx_reg<=read_exclx;
          read_expAddrx_reg<=read_expAddrx;
          read_hit_reg<=read_hit;
          ins_hit_reg<=ins_hit;
          ins_hit_reg2<=ins_hit_reg;
	  write0_clkEn_reg<=write0_clkEn;
	  write1_clkEn_reg<=write1_clkEn;
	  write0_clkEn_reg2<=write0_clkEn_reg;
	  write1_clkEn_reg2<=write1_clkEn_reg;
	  write0_hitE_reg<=write0_hitE;
	  write0_hitO_reg<=write0_hitO;
	  read_inL1<=expun_imm&read_en_reg&ins_hit;
          insert_pook_reg<=insert_pook;
          insert_pook_reg2<=insert_pook_reg;
	  expun_cc_addr_reg<=expun_cc_addr[7:0];
	  expun_dc_addr_reg<=expun_dc_addr[7:0];
      end
      if (rst) begin
          write_addrE0_reg<=36'b0;
          write_addrO0_reg<=36'b0;
          write_bankEn0_reg<=32'b0;
          write_begin0_reg<=5'b0;
          write_end0_reg<=5'b0;
          write_bBen0_reg<=4'b0;
          write_enBen0_reg<=4'b0;
          write_addrE1_reg<=36'b0;
          write_addrO1_reg<=36'b0;
          write_bankEn1_reg<=32'b0;
          write_begin1_reg<=5'b0;
          write_end1_reg<=5'b0;
          write_bBen1_reg<=4'b0;
          write_enBen1_reg<=4'b0;
          write_addrE0_reg2<=36'b0;
          write_addrO0_reg2<=36'b0;
          write_bankEn0_reg2<=32'b0;
          write_begin0_reg2<=5'b0;
          write_end0_reg2<=5'b0;
          write_bBen0_reg2<=4'b0;
          write_enBen0_reg2<=4'b0;
          write_addrE1_reg2<=36'b0;
          write_addrO1_reg2<=36'b0;
          write_bankEn1_reg2<=32'b0;
          write_begin1_reg2<=5'b0;
          write_end1_reg2<=5'b0;
          write_bBen1_reg2<=4'b0;
          write_enBen1_reg2<=4'b0;
          write_addrE0_reg3<=8'b0;
          write_addrO0_reg3<=8'b0;
          write_addrE0_reg4<=8'b0;
          write_addrO0_reg4<=8'b0;
          write_addrE0_reg5<=8'b0;
          write_addrO0_reg5<=8'b0;
      end else begin
          write_addrE0_reg<=write_addrE0;
          write_addrO0_reg<=write_addrO0;
          write_bankEn0_reg<=write_bankEn0;
          write_begin0_reg<=write_begin0;
          write_end0_reg<=write_end0;
          write_bBen0_reg<=write_bBen0;
          write_enBen0_reg<=write_enBen0;

          write_addrE1_reg<=write_addrE1;
          write_addrO1_reg<=write_addrO1;
          write_bankEn1_reg<=write_bankEn1;
          write_begin1_reg<=write_begin1;
          write_end1_reg<=write_end1;
          write_bBen1_reg<=write_bBen1;
          write_enBen1_reg<=write_enBen1;
          if (write0_hitE|write0_hitO|ins_hit) begin
              if (write0_hitE|ins_hit) write_addrE0_reg2<=write_addrE0_reg;
              if (write0_hitO|ins_hit) write_addrO0_reg2<=write_addrO0_reg;
              write_bankEn0_reg2<=write_bankEn0_reg;
              write_begin0_reg2<=write_begin0_reg;
              write_end0_reg2<=write_end0_reg;
              write_bBen0_reg2<=write_bBen0_reg;
              write_enBen0_reg2<=write_enBen0_reg;
          end
          if (write1_hitE|write1_hitO|ins_hit) begin
              if (write1_hitE|ins_hit) write_addrE1_reg2<=write_addrE1_reg;
              if (write1_hitO|ins_hit) write_addrO1_reg2<=write_addrO1_reg;
              write_bankEn1_reg2<=write_bankEn1_reg;
              write_begin1_reg2<=write_begin1_reg;
              write_end1_reg2<=write_end1_reg;
              write_bBen1_reg2<=write_bBen1_reg;
              write_enBen1_reg2<=write_enBen1_reg;
          end
          write_addrE0_reg3<=write_addrE0_reg2[7:0];
          write_addrO0_reg3<=write_addrO0_reg2[7:0];
          write_addrE0_reg4<=write_addrE0_reg3;
          write_addrO0_reg4<=write_addrO0_reg3;
          write_addrE0_reg5<=write_addrE0_reg4;
          write_addrO0_reg5<=write_addrO0_reg4;
      end
      if (rst) begin
          init<=1'b1;
          initCount<=8'd0;
      end else if (init) begin
          initCount<=initCount_next;
          if (pwh#(8)::cmpEQ(initCount,8'hff)) init<=1'b0;
      end
      init_reg<=init;
      init_reg2<=init_reg;
  end

endmodule


module dcache2_block(
  clk,
  rst,
  read_en,read_odd,
  read_data,read_dataX,
  read_dataPTR,read_dataPTRx,
  write0_clkEn,write0_passthrough,
  write_addrE0, write_hitE0,
  write_addrO0, write_hitO0,
  write_bankEn0,write_pbit0, 
  write_begin0,write_end0,
  write_bBen0,write_enBen0,
  write_odd0,write_split0,
  write_data0,
  write_d128_0,
  write1_clkEn,write1_passthrough,
  write_addrE1, write_hitE1,
  write_addrO1, write_hitO1,
  write_bankEn1,write_pbit1,
  write_begin1,write_end1,
  write_bBen1,write_enBen1,
  write_odd1,write_split1,
  write_data1,
  write_d128_1,
  busIns_data,
  busIns_dataPTR,
  insBus_A,
  insBus_B,
//  ins_hit,
  insert,
  insert_excl,insert_dirty,insert_dupl,insert_pook,
  LRU_hit,read_LRU,hit_any,immoral_some,read_dir,read_excl,read_expAddrOut,
  read_expAddr_en,
  expun_cc_addr,
  expun_cc_en,
  expun_dc_addr,
  expun_dc_en
// init
  );
  localparam ADDR_WIDTH=36;
  localparam DATA_WIDTH=32;
  parameter [1:0] ID=0;
/*verilator hier_block*/ 

  input pwire clk;
  input pwire rst;
  input pwire read_en; 
  input pwire read_odd;
  output pwire [32*DATA_WIDTH-1:0] read_data;
  output pwire [32*DATA_WIDTH-1:0] read_dataX;
  output pwire [15:0] read_dataPTR;
  output pwire [15:0] read_dataPTRx;

  input pwire write0_passthrough;
  input pwire write1_passthrough;

  input pwire write0_clkEn;
  input pwire [ADDR_WIDTH-1:0] write_addrE0;
  input pwire write_hitE0; 
  input pwire [ADDR_WIDTH-1:0] write_addrO0;
  input pwire write_hitO0; 
  input pwire [31:0] write_bankEn0;
  input pwire [4:0] write_begin0;
  input pwire [4:0] write_end0;
  input pwire [3:0] write_bBen0;
  input pwire [3:0] write_enBen0;
  input pwire [1:0] write_pbit0;
  input pwire       write_d128_0;
  input pwire write_odd0,write_split0;
  input pwire [159:0] write_data0;
  input pwire write1_clkEn;
  input pwire [ADDR_WIDTH-1:0] write_addrE1;
  input pwire write_hitE1; 
  input pwire [ADDR_WIDTH-1:0] write_addrO1;
  input pwire write_hitO1; 
  input pwire [31:0] write_bankEn1;
  input pwire [4:0] write_begin1;
  input pwire [4:0] write_end1;
  input pwire [3:0] write_bBen1;
  input pwire [3:0] write_enBen1;
  input pwire [1:0] write_pbit1;
  input pwire       write_d128_1;
  input pwire write_odd1,write_split1;
  input pwire [159:0] write_data1;
  input pwire [511:0] busIns_data;
  input pwire [7:0] busIns_dataPTR;
  input pwire insBus_A,insBus_B;
//  output pwire ins_hit;
  input pwire insert;
  input pwire insert_excl;
  input pwire insert_dirty;
  input pwire insert_dupl;
  input pwire insert_pook;
  input pwire [4:0] LRU_hit;
  output pwire [4:0] read_LRU;
  output pwire hit_any;
  output pwire immoral_some;
  output pwire read_dir;
  output pwire read_excl;
  output pwire [36:0] read_expAddrOut;
  input pwire read_expAddr_en;
  input pwire [36:0] expun_cc_addr;
  input pwire expun_cc_en;
  input pwire [36:0] expun_dc_addr;
  input pwire expun_dc_en;

  pwire [8:0] read_hit_way;
  pwire [8:0] read_hit_way_reg;
  pwire [8:0] read_imm_way;
  pwire [8:0] read_imm_way_reg;
  pwire read_hit_any;
  pwire read_en_reg,read_en_reg2,read_en_reg3;
  pwire [4:0] write_begin0_reg;
  pwire [4:0] write_begin1_reg;
  pwire [31:0] write_bankEn0_reg;
  pwire [31:0] write_bankEn1_reg;
  pwire write0_clkEn_reg,write1_clkEn_reg;
  pwire [1023:0] write_data;
  pwire [1023:0] write_data_reg;
  pwire [7+1:0] ins_hit;
  pwire [159:0] write_data0_reg;
  pwire [159:0] write_data1_reg;
  pwire [511:0] busIns_data_reg;
  pwire insBus_A_reg,insBus_B_reg;
  pwire [8:0] ins_hit_reg;
  pwire ins_hit_reg2;
  pwire read_immoral_some;
//  pwire ins_hit_reg3;
  pwire [7:0] write_dataPTR_reg;
  pwire [15:0] write_dataPTR_reg2;
  generate
      genvar k,b,q;
      for(k=0;k<(10+(ID!=0)+1);k=k+1) begin : ways_gen
          pwire [1:0] read_dirP;
          pwire [1:0] read_exclP;
          pwire [36:0] read_expAddrP;
          pwire [32*DATA_WIDTH-1:0] read_dataP;
          pwire [32*DATA_WIDTH-1:0] read_dataxP;
          pwire [15:0] read_dataPtrP;
          pwire [15:0] read_dataPtrxP;
          pwire [4:0] read_LRUp;

          if (k) dcache2_way #(k-1,ID)  way_mod(
          clk,
          rst,
          read_en,
          read_odd,
          ways_gen[k].read_dataP,
          ways_gen[k-1].read_dataP,
          ways_gen[k].read_dataxP,
          ways_gen[k-1].read_dataxP,
          ways_gen[k].read_dataPtrP,
          ways_gen[k-1].read_dataPtrP,
          ways_gen[k].read_dataPtrxP,
          ways_gen[k-1].read_dataPtrxP,
          read_hit_way[k],
	  read_imm_way[k],
          write0_clkEn,
          write_addrE0, write_hitE0,
          write_addrO0, write_hitO0,
          write_bankEn0,write_pbit0, 
          write_begin0,write_end0,
          write_bBen0,write_enBen0,
          write_odd0,write_split0,
	  write_d128_0,
          write1_clkEn,
          write_addrE1, write_hitE1,
          write_addrO1, write_hitO1,
          write_bankEn1,write_pbit1,
          write_begin1,write_end1,
          write_bBen1,write_enBen1,
          write_odd1,write_split1,
	  write_d128_1,
          write_data_reg,
          write_dataPTR_reg2,
          ins_hit[k],
          insert,
          insert_excl,insert_dirty,insert_dupl,insert_pook,
          LRU_hit,
	  ways_gen[k].read_LRUp,ways_gen[k].read_dirP,ways_gen[k].read_exclP,ways_gen[k].read_expAddrP,
	  ways_gen[k-1].read_LRUp,ways_gen[k-1].read_dirP,ways_gen[k-1].read_exclP,ways_gen[k-1].read_expAddrP,
          read_expAddr_en,
          expun_cc_addr,
          expun_cc_en,
          expun_dc_addr,
          expun_dc_en
          );
      end
      for(b=0;b<32;b=b+1) begin : bank_gen
          pwire [4:0] wr0;
          pwire [4:0] wr1;
          for(q=0;q<5;q=q+1) begin : wroff_gen
              assign wr0[q]=((b-q)&5'h1f)==write_begin0_reg && write0_clkEn_reg && write_bankEn0_reg[b];
              assign wr1[q]=((b-q)&5'h1f)==write_begin1_reg && write1_clkEn_reg && write_bankEn1_reg[b];
              assign write_data[b*32+:32]=wr0[q] ? write_data0_reg[q*32+:32] : 32'BZ;
              assign write_data[b*32+:32]=wr1[q] ? write_data1_reg[q*32+:32] : 32'BZ;
          end
          assign  write_data[b*32+:32]=(|{wr0,wr1}) ? 32'BZ : 
            busIns_data_reg[(b%16)*32+:32];
     end
  endgenerate

  assign read_dataP[0]={1024{write0_clkEn_reg2|write1_clkEn_reg2}}&
          {write0_clkEn&write0_passthrough, write_addrE0, write_hitE0, write_addrO0, write_hitO0,
          write_bankEn0,write_pbit0, write_begin0,write_end0, write_bBen0,write_enBen0, write_odd0,write_split0, write_d128_0,
          write1_clkEn&write1_passthrough, write_addrE1, write_hitE1, write_addrO1, write_hitO1,
          write_bankEn1,write_pbit1, write_begin1,write_end1, write_bBen1,write_enBen1,write_odd1,write_split1,  write_d128_1,
          '0};

  assign ways_gen[0].read_dataP[511:0]=512'b0;
  assign ways_gen[0].read_dataP[1023:512]=512'b0;
  assign ways_gen[0].read_dataxP[511:0]=512'b0;
  assign ways_gen[0].read_dataxP[1023:512]=512'b0;
  assign ways_gen[0].read_LRUp={ID,3'b0};
  assign ways_gen[0].read_dirP=2'b0;
  assign ways_gen[0].read_exclP=2'b0;
  assign ways_gen[0].read_expAddrP=37'b0;
  assign read_hit_any=|read_hit_way_reg;
  assign read_immoral_some=|read_imm_way_reg;

  always @(posedge clk) begin
      if (rst) begin
          write_data0_reg<=160'b0;
          write_data1_reg<=160'b0;
          write_data_reg<=1024'b0;
	  write_dataPTR_reg<=8'b0;
	  write_dataPTR_reg2<=16'b0;
          busIns_data_reg<=512'b0;
          insBus_A_reg<=1'b0;
          insBus_B_reg<=1'b0;
          write_begin0_reg<=5'd0;
          write_begin1_reg<=5'd0;
          write0_clkEn_reg<=1'b0;
          write1_clkEn_reg<=1'b0;
          write_bankEn0_reg<=32'b0;
          write_bankEn1_reg<=32'b0;
          
        //  read_hit_any<=1'b0;
          read_data<=1024'b0;
          read_dataX<=1024'b0;
          read_LRU<=5'h0;
          read_en_reg<=1'b0;
          read_en_reg2<=1'b0;
          read_en_reg3<=1'b0;
          ins_hit_reg<=9'b0;
          ins_hit_reg2<=1'b0;
  //        ins_hit_reg3<=1'b0;
          read_hit_way_reg<=9'b0;
          hit_any<=1'b0;
          immoral_some<=1'b0;
          read_dir<=1'b0;
          read_excl<=1'b0;
          read_expAddrOut<=37'b0;
          read_imm_way_reg<=9'b0;
      end else begin
          write_data0_reg<=write_data0;
          write_data1_reg<=write_data1;
          if (~insBus_B_reg) write_data_reg[511:0]<=write_data[511:0];
          if (~insBus_A_reg) write_data_reg[1023:512]<=write_data[1023:512];
          if (~insBus_B_reg) write_dataPTR_reg2[7:0]<=write_dataPTR_reg;
          if (~insBus_A_reg) write_dataPTR_reg2[15:8]<=write_dataPTR_reg;
	  write_dataPTR_reg<=busIns_dataPTR;
          busIns_data_reg<=busIns_data;
          insBus_A_reg<=insBus_A;
          insBus_B_reg<=insBus_B;
          write_begin0_reg<=write_begin0;
          write_begin1_reg<=write_begin1;
 //         write0_clkEn_reg<=write0_clkEn;
 //         write1_clkEn_reg<=write1_clkEn;
          write_bankEn0_reg<=write_bankEn0;
          write_bankEn1_reg<=write_bankEn1;
          
        //  read_hit_any<=(|read_hit_way) && ~ins_hit_reg;
          read_data<=~read_dataP[10+(ID!=0)];
          read_dataX<=~read_dataxP[10+(ID!=0)];
          read_LRU<=~read_LRUp[10+(ID!=0)];
          read_en_reg<=read_en;
          read_en_reg2<=read_en_reg;
          read_en_reg3<=read_en_reg2;
          ins_hit_reg<=ins_hit;
          ins_hit_reg2<=|ins_hit_reg;
    //      ins_hit_reg3<=ins_hit_reg2;
          read_hit_way_reg<=read_hit_way;
          read_imm_way_reg<=read_imm_way;
          hit_any<=(|read_hit_way_reg);
          immoral_some<=(|read_imm_way_reg);
          read_dir<=~read_dirP[10+(ID!=0)][0];
          read_excl<=~read_exclP[10+(ID!=0)][0];
          read_expAddrOut<=~read_expAddrP[10+(ID!=0)];
      end
  end
endmodule

