/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


`include "../struct.sv"

/*
  dcache1_ram read during write behaviour: write first
  introduce write port slicing for the goldium edition. 
*/
module dcache1_ram(
  clk,
  rst,
  read_nClkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen,
  write_ben
  );
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;
  localparam DATA_WIDTH=77;
  
  input clk;
  input rst;
  input [3:0] read_nClkEn;
  input [3:0] [ADDR_WIDTH-1:0] read_addr;
  output [3:0] [DATA_WIDTH-1:0] read_data;
  input [`wport-1:0][ADDR_WIDTH-1:0] write_addr;
  input [`wport-1:0][DATA_WIDTH-1:0] write_data;
  input [`wport-1:0] write_wen;
  input [`wport-1:0][8:0] write_ben;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [3:0][ADDR_WIDTH-1:0] read_addr_reg;
  
  integer wpl;

  always @* begin
    for(rr=0;rr<4;rr=rr+1) begin
        read_data[rr]=read_nClkEn ? 'z : ram[read_addr_reg[rr]];
    end
  end
  always @(negedge clk)
    begin
      if (rst) read_addr_reg<={4*ADDR_WIDTH{1'b0}};
      else if (!read_nClkEn) read_addr_reg<=read_addr; 
      read_nClkEn_reg<=read_nClkEn;
      for (wpl=0;wpl<60;wpl=wpl+1) begin
          if (write_wen[wpl] & write_ben[wpl][0]) ram[write_addr[wpl]][8:0]<=write_data[8:0]; 
          if (write_wen[wpl] & write_ben[wpl][1]) ram[write_addr[wpl]][17:9]<=write_data[17:9];
          if (write_wen[wpl] & write_ben[wpl][2]) ram[write_addr[wpl]][26:18]<=write_data[26:18]; 
          if (write_wen[wpl] & write_ben[wpl][3]) ram[write_addr[wpl]][35:27]<=write_data[35:27]; 
          if (write_wen[wpl] & write_ben[wpl][4]) ram[write_addr[wpl]][44:36]<=write_data[44:36]; 
          if (write_wen[wpl] & write_ben[wpl][5]) ram[write_addr[wpl]][53:45]<=write_data[53:45]; 
          if (write_wen[wpl] & write_ben[wpl][6]) ram[write_addr[wpl]][62:54]<=write_data[62:54]; 
          if (write_wen[wpl] & write_ben[wpl][7]) ram[write_addr[wpl]][71:63]<=write_data[71:63]; 
          if (write_wen[wpl] & write_ben[wpl][8]) ram[write_addr[wpl]][76:72]<=write_data[76:72]; 
      end
    end

endmodule


module dcache1_bank(
  clk,
  rst,
  read_addrE0, read_hitE0, 
  read_addrO0, read_hitO0, 
  read_bankEn0,read_odd0,
  read_data,
  read_data_in,
  read_err,
  read_err_in,
  write_addrE0, write_hitE0,
  write_addrO0, write_hitO0,
  write_bankEn0, 
  write_begin0,write_end0,
  write_bBen0,write_enBen0,
  write_data,
  ins_hit,
  init
  );
  localparam ADDR_WIDTH=6;
  localparam DATA_WIDTH=`dcache1_data_width;
  parameter INDEX=0;
  parameter [0:0] TOP=0;
  input clk;
  input rst;
  input [3:0][ADDR_WIDTH-1:0] read_addrE0;
  input [3:0] read_hitE0; //+1 cycle
  input [3:0] [ADDR_WIDTH-1:0] read_addrO0;
  input [3:0] read_hitO0; //+1 cycle
  input [3:0] read_bankEn0;
  input [3:0] read_odd0;
  output [3:0][1:0][76:0] read_data;
  input [3:0][1:0][76:0][DATA_WIDTH-1:0] read_data_in;
  output read_err;
  input read_err_in;

  input [`wport-1:0][ADDR_WIDTH-1:0] write_addrE0;
  input [`wport-1:0]write_hitE0; //+1 cycle
  input [`wport-1:0][ADDR_WIDTH-1:0] write_addrO0;
  input [`wport-1:0]write_hitO0; //+1 cycle
  input [`wport-1:0]write_bankEn0;
  input [`wport-1:0][4:0] write_begin0;
  input [`wport-1:0][4:0] write_end0;
  input [`wport-1:0][3:0] write_bBen0;
  input [`wport-1:0][3:0] write_enBen0;
  input [3:0][`wport-1:0][DATA_WIDTH-1:0] write_data;
  input ins_hit;
  input init;
  
  wire [3:0][1:0][ADDR_WIDTH-1:0] read_addr;
  wire [3:0][1:0][DATA_WIDTH-1:0] read_data_ram;
  wire [3:0]enE,enO;
  wire [3:0]onE,onO;
  wire [3:0][1:0][DATA_WIDTH-1:0] read_dataP;

  reg [3:0] read_bankEn0_reg;

  reg [3:0] read_odd0_reg;

  
  
  assign enE=read_hitE0 & read_bankEn0_reg | read_hitE1 & read_bankEn1_reg | read_hitE2 & read_bankEn2_reg | read_hitE3 & read_bankEn3_reg;
  assign enO=read_hitO0 & read_bankEn0_reg | read_hitO1 & read_bankEn1_reg | read_hitO2 & read_bankEn2_reg | read_hitO3 & read_bankEn3_reg;


 
  generate
    for(p=0;p<4;p=p+1) begin
        assign write_ben[p]=(write_bankEn0[p] && write_begin0==INDEX && ~init) ? write_bBen0[p] : 4'bz;
        assign write_ben[p]=(write_bankEn0[p] && write_end0[p]==INDEX && ~init) ?   write_enBen0[p] : 4'bz;
        assign write_ben[p]=((write_bankEn0[p] && write_begin0[p]!=INDEX && write_end0[p]!=INDEX) || init) ? 4'b1111 : 4'bz;
        assign write_ben[p]=(~write_bankEn0[p] && ~init) ? 4'b0 : 4'bz;
    end
  endgenerate
  assign bank_hit=enE | enO;

  assign error[0]=^read_data_ram[0][8:0]|^read_data_ram[0][17:9]|^read_data_ram[0][26:18]|^read_data_ram[0][35:27];
  assign error[1]=^read_data_ram[1][8:0]|^read_data_ram[1][17:9]|^read_data_ram[1][26:18]|^read_data_ram[1][35:27];

  wire read_errX;

  always @* begin
    for(k=0;k<60;k=k+1) begin
        write_data0[k]=write_data[write_begin0[k]][k];
    end
    for(k=0;k<4;k=k+1) begin
        none_bankEn[k]=read_addr0[k][9:3]!=read_begin0[k] && read_addr0[k][9:3]!=read_end0[k];
    end
  end
  
  dcache1_ram ramE_mod(
  .clk(clk),
  .rst(rst),
  .read_nClkEn(none_bankEn),
  .read_addr(read_addrE0),
  .read_data(read_data_ram),
  .write_addr(write_addrE),
  .write_data(write_data0),
  .write_wen((write_bankEn && write_hitE0|write_hitE1)|init|(ins_hit&~read_odd0_reg)),
  .write_ben(write_ben)
  );

  dcache1_ram ramO_mod(
  .clk(clk),
  .rst(rst),
  .read_nClkEn(none_bankEn),
  .read_addr(read_addrO0),
  .read_data(read_data_ram),
  .write_addr(write_addrO),
  .write_data(write_data0),
  .write_wen((write_bankEn && write_hitO0|write_hitO1)|init|(ins_hit&read_odd0_reg)),
  .write_ben(write_ben)
  );
  


  generate
    for(xx=0;xx<4;xx=xx+1) begin
        assign read_data[xx][0]=(read_addr0[xx][9:3]==read_begin0[xx]) ? ram_read_data[xx] : 'z;
        assign read_data[xx][1]=(read_addr0[xx][9:3]==read_end0[xx]) ? ram_read_data[xx] : 'z;
    end
    if (~TOP) begin
        assign read_errX=(enE & ~ins_hit) ? error[0] : 'z;
        assign read_errX=(enO & ~ins_hit) ? error[1] : 'z;
        assign read_errX=(~bank_hit | ins_hit) ? 1'b0 : 'z;
  
        assign read_err=~(read_errX|read_err_in);  
    end else begin

        assign read_errX=(enE & ~ins_hit) ? ~error[0] : 'z;
        assign read_errX=(enO & ~ins_hit) ? ~error[1] : 'z;
        assign read_errX=(~bank_hit | ins_hit) ? 1'B1 : 'z;
  
        assign read_err=~(read_errX&read_err_in);  
    end
  endgenerate
  always @(posedge clk)
    begin
      if (rst)
        begin
          read_bankEn0_reg<=4'b0;
          read_odd0_reg<=4'b0;
        end
      else
        begin
          read_bankEn0_reg<=read_bankEn0;
          read_odd0_reg<=read_odd0;
        end
    end
  
endmodule


//dcache1_way compiled into a hard macro (1 for odd, 1 for even).
//DO NOT delete the inverted IO from the hard macro block
//use 1 x2 layer horizontal
module dcache1_way(
  clk,
  rst,
  read_addrE0, read_addrO0, read_bank0, read_clkEn0, read_hit0, 
    read_odd0, read_split0, read_pbit0, read_pbit0_in, read0_err,
  read_bankNoRead,
  read_invalidate,
  read_bankHit,
  read_data,
  read_data_in,
  read_err,
  read_err_in,
  read_begin0,read_low0,
  read_hitEi,read_hitOi,
  write_addrE0,
  write_addrO0,
  write_bank0,
  write_begin0,write_end0,
  write_bBen0,write_enBen0,
  write_clkEn0,
  write_hit0,
  write_hitCl0,
  write_dupl0,
  write_split0,
  write_pbit0,write_d128_0,
  write_odd0,
  write0_err,
  write_insert,
  write_insertExclusive,
  write_insertDirty,
  write_data,
  write_dataPTR,
  err_tag,
  recent_in,
  recent_out,
  insert_rand,
  insert_hit,
  wb_addr,
  wb_valid,
  puke_addr,
  puke_en
  );
  localparam ADDR_WIDTH=37;
  localparam DATA_WIDTH=`dcache1_data_width;
  localparam TAG_WIDTH=`dc1Tag_width;
  localparam BANK_COUNT=16;
  localparam LINE_WIDTH=DATA_WIDTH*BANK_COUNT;
  localparam RAM_ADDR_WIDTH=`dcache1_addr_width;
  parameter [2:0] INDEX=0;
  
  input clk;
  input rst;
  
  input [3:0][ADDR_WIDTH-2:0] read_addrE0;
  input [3:0][ADDR_WIDTH-2:0] read_addrO0;
  input [3:0][BANK_COUNT-1:0] read_bank0;
  input [3:0]read_clkEn0;
  output [3:0][1:0] read_hit0;
  input [3:0]read_odd0;
  input [3:0]read_split0;
  output [3:0][1:0] read_pbit0;
  input [3:0][1:0] read_pbit0_in;
  output [3:0] read0_err;
  

  input [BANK_COUNT-1:0] read_bankNoRead;//bits are 1 if other bank reads are 0
  
  input read_invalidate; 

  output [BANK_COUNT-1:0] read_bankHit;
  
  output [3:0][1:0][76:0] read_data;
  input [3:0][1:0][76:0] read_data_in;
  output [3:0] read_err;
  input [3:0] read_err_in;
 
  input [3:0][4:0] read_begin0;


  input [3:0][1:0] read_low0;

  inout [7:0] read_hitEi;
  inout [7:0] read_hitOi;

  input [`wport-1:0][ADDR_WIDTH-2:0] write_addrE0;
  input [`wport-1:0][ADDR_WIDTH-2:0] write_addrO0;
  input [`wport-1:0][BANK_COUNT-1:0] write_bank0;
  input [`wport-1:0][4:0] write_begin0;
  input [`wport-1:0][4:0] write_end0;
  input [`wport-1:0][3:0] write_bBen0;
  input [`wport-1:0][3:0] write_enBen0;
  input [`wport-1:0]write_clkEn0;
  input [`wport-1:0]write_hit0;
  input [`wport-1:0][1:0] write_pbit0;
  input [`wport-1:0]write_d128_0;
  output [`wport-1:0][1:0] write_hitCl0;
  output [`wport-1:0][1:0] write_dupl0;
  input [`wport-1:0]write_split0;
  input [`wport-1:0]write_odd0;
  output [`wport-1:0] write0_err;
  
  input write_insert_early;
  input [36:0] write_addr;
  input write_insert;    
  input write_insertExclusive;
  input write_insertDirty;
  input [3:0][`wport-1:0][35:0] write_data;
  input [15:0] write_dataPTR;
  


  
  output [5:0] err_tag;
  
  input recent_in;
  output recent_out;
  input [5:0] insert_rand;

  output insert_hit;
 
  output [ADDR_WIDTH-1:0] wb_addr;
  output wb_valid;  
  input [5:0][6:0] puke_addr;
  input [5:0] puke_en;
  
  wire [3:0] recent;
  
  wire [5:0] ins_hit;
  wire [5:0] errH;
  wire [5:0] errL;
  wire dirtyE,dirtyO;
  
  reg [`wport-1:0][4:0] write_begin0_reg;
  reg [`wport-1:0][4:0] write_end0_reg;
  reg [`wport-1:0][3:0] write_bBen0_reg;
  reg [`wport-1:0][3:0] write_enBen0_reg;

  wire [3:0] read_hitEL;
  wire [3:0] read_hitOL;
  wire [3:0] read_hitEH;
  wire [3:0] read_hitOH;
  wire [3:0] read_hitE;
  wire [3:0] read_hitO;

  wire [1:0] write_hitEL;
  wire [1:0] write_hitOL;
  wire [1:0] write_hitEH;
  wire [1:0] write_hitOH;

//  wire [3:0] read_clkEn={read_clkEn3,read_clkEn2,read_clkEn1,read_clkEn0};
//  wire [3:0] read_odd={read_odd3,read_odd2,read_odd1,read_odd0};
//  wire [3:0] read_split={read_split3,read_split2,read_split1,read_split0};
  
//  wire [ADDR_WIDTH-2:0] read_addrE[3:0];
//  wire [ADDR_WIDTH-2:0] read_addrO[3:0];
 

  reg [3:0][4:0] read_begin0_reg;
  reg [3:0][1:0] read_low0_reg;
  
  reg [3:0] read_odd0_reg;
  reg [3:0] read_split0_reg;
  reg [`wport-1:0] write_odd0_reg;
  reg [`wport-1:0] write_split0_reg;
  reg write_insert_reg;
  
  reg read_invalidate_reg;
  
  wire [`wport-1:0] write_reqE0,write_reqO0;
  
  reg [`wport-1:0] write_clkEn0_reg;
  reg [`wport-1:0] write_clkEn0_reg2;

  reg [`wport-1:0][ADDR_WIDTH-2:0] write_addrE0_reg;
  reg [`wport-1:0][ADDR_WIDTH-2:0] write_addrO0_reg;
  reg [3:0][ADDR_WIDTH-2:0] read_addrE0_reg;
  reg [3:0][ADDR_WIDTH-2:0] read_addrO0_reg;
  reg [3:0]read_clkEn0_reg;
  wire [`wport-1:0][1:0] write_hitO;
  wire [`wport-1:0][1:0] write_hitE;
  reg ins_hit_reg;
 
  wire [1:0] write_dupl[1:0][`wport-1:0];
  
  wire [3:0][1:0] read_pbit0P;
  
  wire [3:0][1:0] read0_pbitP;
 
  reg init;
  reg init_dirty;
  reg [5:0] initCount;
  wire [5:0] initCount_d;
  generate
    genvar b,r,w;
    for (b=0;b<BANK_COUNT;b=b+1) begin : banks

       if (b<8) begin : banks_low
/* verilator lint_off WIDTH */
          dcache1_bank #(b,INDEX[0]) bank_mod(
          clk,
          rst,
          read_addrE0[3:0][6:0], read_hitEL[3:0][0],
          read_addrO0[3:0][6:0], read_hitOL[3:0][0],
          read_bank0[3:0][b],read_odd0,
          read_bankNoRead[b],
          read_bankHit[b],
          read_data,
          read_data_in,
          write_addrE0_reg[6:0], write_hitEL[`wport-1:0][0] && write_hit0,
          write_addrO0_reg[6:0], write_hitOL[`wport-1:0][0] && write_hit0,
          write_bank0[b], 
          write_begin0_reg,write_end0_reg,
          write_bBen0_reg,write_enBen0_reg,
          write_data,
          ins_hit[0],
          init
          );
/* verilator lint_on WIDTH */
       end else begin : banks_hi
/* verilator lint_off WIDTH */
          dcache1_bank #(b,INDEX[0]) bank_mod(
          clk,
          rst,
          read_addrE0[3:0][6:0], read_hitEH[3:0][0],
          read_addrO0[3:0][6:0], read_hitOH[3:0][0],
          read_bank0[3:0][b],~read_odd0,
          read_bankNoRead[b],
          read_bankHit[b],
          read_data[DATA_WIDTH*b+:DATA_WIDTH],
          read_data_in[DATA_WIDTH*b+:DATA_WIDTH],
          write_addrE0_reg[6:0], write_hitEH[`wport-1:0][0] && write_hit0,
          write_addrO0_reg[6:0], write_hitOH[`wport-1:0][0] && write_hit0,
          write_bank0[b], 
          write_begin0_reg,write_end0_reg,
          write_bBen0_reg,write_enBen0_reg,
          write_data,
          ins_hit[0],
          init
          );
/* verilator lint_on WIDTH */
       end
    end
        dcache1_tag #(INDEX) tagRA_mod(
        .clk(clk),
        .rst(rst),
        .read_clkEn(write_insert_early),
        .read_en(write_insert_early),
        .read_addrOdd(insert_addr[36:1]),.read_addrEven(insert_addr[36:1]),
        .read_odd(insert_addr[0]), .read_split(1'b0), .read_invl(1'b0), 
        .read_hitL_odd(read_hitOLi),.read_hitL_even(read_hitELi),
        .read_hitH_odd(read_hitOHi),.read_hitH_even(read_hitEHi),
        .read_hit_odd(read_hitOi[INDEX]),.read_hit_even(read_hitEi[INDEX]),
        .read_exclOut0(),.read_exclOut1(),//.read_excl(),
        .errH(errHi),.errL(errLi),
        .write_exclusive(write_insertExclusive),
        .write_rand(insert_rand),
        .write_recent_out(),
        .write_recent_in(recent_in),
        .write_wen(write_insert),
        .write_hit(ins_hit[r]),
        .wb_addr(),
        .wb_valid(),
        .puke_en(puke_en),.puke_addr(puke_addr)
        );  

    for (r=0;r<4;r=r+1) begin : tagR_gen
        if (r>0)
        dcache1_tag #(INDEX) tagR_mod(
        .clk(clk),
        .rst(rst),
        .read_clkEn(read_clkEn0[r] | write_insert),
        .read_en(read_clkEn0[r]),
        .read_addrOdd(read_addrO0[r]),.read_addrEven(read_addrE0[r]),
        .read_odd(read_odd0[r]), .read_split(read_split0[r]), .read_invl(read_invalidate0),
        .read_hitL_odd(read_hitOL[r]),.read_hitL_even(read_hitEL[r]),
        .read_hitH_odd(read_hitOH[r]),.read_hitH_even(read_hitEH[r]),
        .read_hit_odd(read_hitO[r]),.read_hit_even(read_hitE[r]),
        .read_exclOut0(),.read_exclOut1(),//.read_excl(),
        .errH(errH[r]),.errL(errL[r]),
        .write_exclusive(write_insertExclusive),
        .write_rand(insert_rand),
        .write_recent_out(recent[r]),
        .write_recent_in(recent_in),
        .write_wen(write_insert),
        .write_hit(ins_hit[r]),
        .wb_addr(),
        .wb_valid(),
        .puke_en(puke_en),.puke_addr(puke_addr)
        );  
        else 
        dcache1_tag #(INDEX) tagR_mod(
        .clk(clk),
        .rst(rst),
        .read_clkEn(read_clkEn0[r] | write_insert),
        .read_en(read_clkEn0[r]),
        .read_addrOdd(read_addrO0[r]),.read_addrEven(read_addrE0[r]),
        .read_odd(read_odd0[r]), .read_split(read_split0[r]), .read_invl(read_invalidate),
        .read_hitL_odd(read_hitOL[r]),.read_hitL_even(read_hitEL[r]),
        .read_hitH_odd(read_hitOH[r]),.read_hitH_even(read_hitEH[r]),
        .read_hit_odd(read_hitO[r]),.read_hit_even(read_hitE[r]),
        .read_exclOut0(),.read_exclOut1(),//.read_excl(),
        .errH(errH[r]),.errL(errL[r]),
        .write_exclusive(write_insertExclusive),
        .write_rand(insert_rand),
        .write_recent_out(recent[r]),
        .write_recent_in(recent_in),
        .write_wen(write_insert&~|read_hitOi&~|read_hitEi),
        .write_hit(ins_hit[r]),
        .wb_addr(wb_addr),
        .wb_valid(wb_valid),
        .puke_en(puke_en),.puke_addr(puke_addr)
        );  
    end

    for (w=0;w<`wport;w=w+1) begin : tagW_gen
        dcache1_tag #(INDEX) tagW_mod(
        .clk(clk),
        .rst(rst),
        .read_clkEn(write_clkEn0[w] | write_insert),
        .read_en(write_clkEn0[w]),
        .read_addrOdd(write_addrO0[w]),.read_addrEven(write_addrE0[w]),
        .read_odd(write_odd0[w]), .read_split(write_split0[w]), .read_invl(read_invalidate0),
        .read_exclOut0(write_dupl0[w][0]),.read_exclOut1(write_dupl0[w][1]), 
        .read_hitL_odd(write_hitOL[w]),.read_hitL_even(write_hitEL[w]),
        .read_hitH_odd(write_hitOH[w]),.read_hitH_even(write_hitEH[w]),
        .read_hit_odd(write_hitO[w]),.read_hit_even(write_hitE[w]),
        //.read_excl(),
        .errH(errH[w+4]),.errL(errL[w+4]),
        .write_exclusive(write_insertExclusive),
        .write_rand(insert_rand),
        .write_recent_out(),
        .write_recent_in(recent_in),
        .write_wen(write_insert),
        .write_hit(ins_hit[w+4]),
        .wb_addr(),
        .wb_valid(),
        .puke_en(puke_en),.puke_addr(puke_addr)
        ); 
        
    end
  endgenerate
  

  adder_inc #(6) initAdd_mod(initCount,initCount_d,1'b1,);


  assign err_tag=errH|errL;  

  assign read0_err=errH[3:0]|errL[3:0];
  assign write0_err=errH[4+:`wport]|errL[4+:`wport];


  assign write_dupl0=~write_dupl & {write_hitO,write_hitE};

  assign write_hitCl0[`wport-1:0][0]=write_hitE[`wport-1:0][0] & write_reqE0;
  assign write_hitCl0[`wport-1:0][1]=write_hitO[`wport-1:0][0] & write_reqO0;
  
  assign write_reqE0=(~write_odd0_reg | write_split0_reg) & write_clkEn0_reg;
  assign write_reqO0=(write_odd0_reg | write_split0_reg) & write_clkEn0_reg;
  
  assign insert_hit=ins_hit[0];
  
  assign recent_out=|recent[2:0];
  
  
  always @(negedge clk) begin
      if (rst) begin
          read_odd0_reg<=1'b0;
          read_begin0_reg<=5'b0;
          read_low0_reg<=2'b0;
          write_odd0_reg<=1'b0;
          read_split0_reg<=1'b0;
          write_split0_reg<=1'b0;
          write_insert_reg<=1'b0;
          read_invalidate_reg<=1'b0;
          write_clkEn0_reg<=1'b0;
          write_addrE0_reg<=36'b0;
          write_addrO0_reg<=36'b0;
          read_addrE0_reg<=36'b0;
          read_addrO0_reg<=36'b0;
          read_clkEn0_reg<=1'b0;
          write_begin0_reg<=5'b0;
          write_end0_reg<=5'b0;
          write_bBen0_reg<=4'b0;
          write_enBen0_reg<=4'b0;
          ins_hit_reg<=1'b0;
      end else begin
          if (read_clkEn0) read_odd0_reg<=read_odd0;
          if (read_clkEn0) read_begin0_reg<=read_begin0;
          if (read_clkEn0) read_low0_reg<=read_low0;
          if (write_clkEn0) write_odd0_reg<=write_odd0;
          if (read_clkEn0) read_split0_reg<=read_split0;
          if (write_clkEn0) write_split0_reg<=write_split0;
          write_insert_reg<=write_insert;
          read_invalidate_reg<=read_invalidate;
          write_clkEn0_reg<=write_clkEn0;
          for(p=0;p<60;p=p+1) begin
              write_addrE0_reg[p]<=write_addrE0[p][6:0];
              write_addrO0_reg[p]<=write_addrO0[p][6:0];
              write_begin0_reg[p]<=write_begin0[p][4:1];
              write_end0_reg[p]<=write_end0[p][4:1];
          end
          read_addrE0_reg<=read_addrE0;
          read_addrO0_reg<=read_addrO0;
          read_clkEn0_reg<=read_clkEn0;
          write_begin0_reg<=write_begin0;
          write_end0_reg<=write_end0;
          write_bBen0_reg<=write_bBen0;
          write_enBen0_reg<=write_enBen0;
          ins_hit_reg<=ins_hit[0];
      end
      if (rst) begin
          init<=1'b1;
          init_dirty<=1'b1;
          initCount<=6'b0;
      end else if (init) begin
          initCount<=initCount_d;
          if (initCount==6'd63) init<=1'b0;
          if (initCount==6'hf) init_dirty<=1'b0;
      end
  end
    
endmodule


//module dcache1 compiled to hard-macro with extra 1 x2 layer vertical
//in addition to the dcache1_way horizontal x2 wire
//duplicated read_data?? outputs per instruction domain.
//outputs at same per bit distances as in LSU/ALU domains and the same spacing in
//between
//do not delete the inverted io

module dcache1(
  clk,
  rst,
  read_addrE0, read_addrO0, read_bank0, read_clkEn0, read_hit0, read_hitCl0, 
    read_odd0, read_split0, read_dataA0, read_dataX0, read_pbit0,
    read_beginA0, read_low0, read_sz0,
  read_bankNoRead,
  read_invalidate,
  write_addrE0,
  write_addrO0,
  write_bank0,
  write_clkEn0,
  write_hit0,
  write_hitCl0,
  write_dupl0,
  write_split0,
  write_odd0,
  write_begin0,
  write_end0,
  write_bgnBen0,
  write_endBen0,
  write_data0,
  write_dataM0,
  write_pbit0,
  write_d128_0,
  write_clear,
  insert_en,
  insert_from_ram,
  insert_exclusive,
  insert_dirty,
//  wb_en,
//  busWb_data,
  busIns_data,
  busIns_dataPTR,
  insbus_A,insbus_B,
  expun_addr,expun_en,
  msrss_en,msrss_addr,msrss_data
  );
  localparam ADDR_WIDTH=37;
  localparam DATA_WIDTH=`dcache1_data_width;
  localparam TAG_WIDTH=`dc1Tag_width;
  localparam BANK_COUNT=32;
  localparam LINE_WIDTH=DATA_WIDTH*BANK_COUNT;
  localparam RAM_ADDR_WIDTH=`dcache1_addr_width;
  localparam WLINE_WIDTH=1024;
/*verilator hier_block*/
  
  input clk;
  input rst;
  
  input [3:0][ADDR_WIDTH-2:0] read_addrE0;
  input [3:0][ADDR_WIDTH-2:0] read_addrO0;
  input [3:0][BANK_COUNT-1:0] read_bank0;
  input [3:0]read_clkEn0;
  output reg [3:0] read_hit0;
  output reg [3:0] [1:0] read_hitCl0;
  input [3:0]read_odd0;
  input [3:0]read_split0;
  output [3:0][127+8:0] read_dataA0;
  output [3:0][1:0] read_pbit0;
  input [3:0][4:0] read_beginA0;
  input [3:0][1:0] read_low0;
  input [3:0][4:0] read_sz0;

  input  [3:0]  read_pf3;

  
  input [BANK_COUNT-1:0] read_bankNoRead;
  
  input read_invalidate; 

  input [`wport-1:0][ADDR_WIDTH-2:0] write_addrE0;
  input [`wport-1:0][ADDR_WIDTH-2:0] write_addrO0;
  input [`wport-1:0][BANK_COUNT-1:0] write_bank0;
  input [`wport-1:0]write_clkEn0;
  output reg [`wport-1:0]write_hit0;
  output reg [`wport-1:0][1:0] write_hitCl0;
  output reg [`wport-1:0][1:0] write_dupl0;
  input [`wport-1:0]write_split0;
  input [`wport-1:0]write_odd0;
  input [`wport-1:0][4:0] write_begin0;
  input [`wport-1:0][4:0] write_end0;
  input [`wport-1:0][3:0] write_bgnBen0;
  input [`wport-1:0][3:0] write_endBen0;
  input [`wport-1:0][5*32-1:0] write_data0;
  input [`wport-1:0][5*32-1:0] write_dataM0;
  input [`wport-1:0][1:0] write_pbit0;
  input [`wport-1:0]write_d128_0;
  input write_clear;
  
  input insert_en;    
  input insert_from_ram;
  input insert_exclusive;
  input insert_dirty;
  input [511:0] busIns_data;
  input [7:0] busIns_dataPTR;
  input insbus_A,insbus_B;
  output [ADDR_WIDTH-1:0] expun_addr;
  output expun_en;
  input msrss_en;
  input [15:0] msrss_addr;
  input [64:0] msrss_data;
  //embedded segment register
  reg [64:0] emsr;

  wire [1023:0] write_data;
  wire [1023:0] write_dataM;
//  wire [LINE_WIDTH-1:0] read_data;
  reg read3_pf;
  reg read3_pf_reg;
  reg [135:0] pwndata[3:0];

  wire [LINE_WIDTH-1:0] read_dataP;
  reg [LINE_WIDTH-1:0] read_dataP_reg;
  reg [LINE_WIDTH-1:0] read_dataP_reg2;
  wire [BANK_COUNT*32-1:0] read_data_strip;
  wire [1:0] read_pbit0P[8:0];
  wire [1:0] read_pbit1P[8:0];
  wire [1:0] read_pbit2P[8:0];
  wire [1:0] read_pbit3P[8:0];
  
  reg [1:0] read_pbit0P_reg;
  reg [1:0] read_pbit0P_reg2;
  reg [1:0] read_pbit1P_reg;
  reg [1:0] read_pbit1P_reg2;
  reg [1:0] read_pbit2P_reg;
  reg [1:0] read_pbit2P_reg2;
  reg [1:0] read_pbit3P_reg;
  reg [1:0] read_pbit3P_reg2;

  wire [5:0][6:0] puke_addr;
  wire [5:0] puke_en;
  wire [5:0] err_tag[7:0];
  wire rderr1;
  wire rderr2;
  wire [3:0][15:0] rxerr0;
  wire [3:0][15:0] rxerr1;
  wire [3:0][15:0] rxerr2;
  wire [3:0][15:0] rxerr3;
  wire [3:0][15:0] rxerr4;
  wire [3:0][15:0] rxerr5;
  wire [3:0][15:0] rxerr6;
  wire [3:0][15:0] rxerr7;
  wire [3:0][15:0] rxerr7B;
  wire [3:0][15:0] rxerr;
  wire recent_in;
  wire [7:0] recent_out;

  wire [5:0] insert_rand;
  
  wire [BANK_COUNT-1:0] read_bankHit_way[7:0];
  wire [BANK_COUNT-1:0] bank_hit;

  wire [7:0] insert_hit_way;
  
  wire [1:0] read_hit0_way[7:0];
  wire [1:0] read_hit1_way[7:0];
  wire [1:0] read_hit2_way[7:0];
  wire [1:0] read_hit3_way[7:0];
  
  wire [1:0] read_hitCl0Q;
  wire [1:0] read_hitCl1Q;
  wire [1:0] read_hitCl2Q;
  wire [1:0] read_hitCl3Q;

  wire [1:0] read_hitCl0P;
  wire [1:0] read_hitCl1P;
  wire [1:0] read_hitCl2P;
  wire [1:0] read_hitCl3P;

  reg [1:0] read_hitCl0P_reg;
  reg [1:0] read_hitCl1P_reg;
  reg [1:0] read_hitCl2P_reg;
  reg [1:0] read_hitCl3P_reg;

  wire read_hit0P;
  wire read_hit1P;
  wire read_hit2P;
  wire read_hit3P;

  reg read_hit0P_reg;
  reg read_hit1P_reg;
  reg read_hit2P_reg;
  reg read_hit3P_reg;

  wire [1:0] write_hit0_way[7:0];
  wire [1:0] write_hit1_way[7:0];

  wire write_hit0P;
  wire write_hit1P;

  reg write_hit0P_reg;
  reg write_hit1P_reg;

  wire [1:0] write_hitCl0P;
  wire [1:0] write_hitCl1P;

  reg [1:0] write_hitCl0P_reg;
  reg [1:0] write_hitCl1P_reg;
  
  wire [1:0] write_dupl0_way[7:0];
  wire [1:0] write_dupl1_way[7:0];

  wire [1:0] write_dupl0P;
  wire [1:0] write_dupl1P;
  reg [1:0] write_dupl0P_reg;
  reg [1:0] write_dupl1P_reg;
  
  reg rdreqE0,rdreqO0;
  reg rdreqE1,rdreqO1;
  reg rdreqE2,rdreqO2;
  reg rdreqE3,rdreqO3;

  reg wrreqE0,wrreqO0;
  reg wrreqE1,wrreqO1;

  reg [ADDR_WIDTH-2:0] read_addrE0_reg;
  reg [ADDR_WIDTH-2:0] read_addrO0_reg;
  reg [BANK_COUNT-1:0] read_bank0_reg;
  reg read_clkEn0_reg;
  reg read_odd0_reg;
  reg read_split0_reg;

  reg [ADDR_WIDTH-2:0] read_addrE1_reg;
  reg [ADDR_WIDTH-2:0] read_addrO1_reg;
  reg [BANK_COUNT-1:0] read_bank1_reg;
  reg read_clkEn1_reg;
  reg read_odd1_reg;
  reg read_split1_reg;
  
  reg [ADDR_WIDTH-2:0] read_addrE2_reg;
  reg [ADDR_WIDTH-2:0] read_addrO2_reg;
  reg [BANK_COUNT-1:0] read_bank2_reg;
  reg [3:0][BANK_COUNT-1:0] read_bank;
  reg read_clkEn2_reg;
  reg read_odd2_reg;
  reg read_split2_reg;

  reg [ADDR_WIDTH-2:0] read_addrE3_reg;
  reg [ADDR_WIDTH-2:0] read_addrO3_reg;
  reg [BANK_COUNT-1:0] read_bank3_reg;
  reg read_clkEn3_reg;
  reg read_odd3_reg;
  reg read_split3_reg;
 
  reg [3:0] read_odd;
  reg [3:0] read_odd_reg;
  reg [3:0] read_split;
  reg [3:0] read_split_reg;
 
  reg [BANK_COUNT-1:0] read_bankNoRead_reg;//bits are 1 if other bank reads are 0
  
  reg read_invalidate_reg; 
  reg read_invalidate_reg2;
  
  reg [ADDR_WIDTH-2:0] write_addrE0_reg;
  reg [ADDR_WIDTH-2:0] write_addrO0_reg;
  reg [BANK_COUNT-1:0] write_bank0_reg;
  reg [4:0] write_begin0_reg;
  reg [4:0] write_end0_reg;
  reg [3:0] write_bgnBen0_reg;
  reg [3:0] write_endBen0_reg;
  reg write_clkEn0_reg;
  reg write_split0_reg;
  reg [1:0] write_pbit0_reg;
  reg write_d128_0_reg;
  reg write_odd0_reg;
  reg [ADDR_WIDTH-2:0] write_addrE1_reg;
  reg [ADDR_WIDTH-2:0] write_addrO1_reg;
  reg [BANK_COUNT-1:0] write_bank1_reg;
  reg write_clkEn1_reg;
  reg write_split1_reg;
  reg [1:0] write_pbit1_reg;
  reg write_d128_1_reg;
  reg write_odd1_reg;
  reg [4:0] write_begin1_reg;
  reg [4:0] write_end1_reg;
  reg [3:0] write_bgnBen1_reg;
  reg [3:0] write_endBen1_reg;
  
  reg insert_en_reg;    
  reg insert_exclusive_reg;
  reg insert_dirty_reg;
  reg [1023:0] write_data_reg;
  reg [1023:0] write_dataM_reg;
  reg insert_exclusive_reg2;
  reg insert_dirty_reg2;
  reg [1023:0] write_data_reg2;
  reg [1023:0] write_dataM_reg2;
  wire [LINE_WIDTH-1:0] write_data_ecc;
  wire [LINE_WIDTH-1:0] write_dataM0_ecc;
  wire [LINE_WIDTH-1:0] write_dataM_ecc;
  reg [15:0] write_dataPTR_reg;
  reg [15:0] write_dataPTR_reg2;
  reg [BANK_COUNT-1:0] write_bank0_reg2;
  reg [BANK_COUNT-1:0] write_bank1_reg2;
  
  reg insert_en_reg2;

  wire [255:0] rxdata0[3:0];
  wire [255:0] rxdata1[3:0];
  wire [255:0] rxdata2[3:0];
  wire [255:0] rxdata3[3:0];
  wire [255:0] rxdata4[3:0];
  wire [255:0] rxdata5[3:0];
  wire [255:0] rxdata6[3:0];
  wire [255:0] rxdata7[3:0];
  wire [255:0] rxdata[3:0];
  wire [3:0][127+8:0] rddata1;
  wire [3:0][127:0] rddata2;
//  wire [4:0] rdcan[3:0];
  wire [3:0][127+8:0] read_dataA;
  reg [5:0] mskdata1[3:0];
  reg swpdata[3:0];
  reg [4:0] read_sz[3:0];
  reg [4:0] read_sz_reg[3:0];

  wire [7:0] write_back_way;
  wire [7:0] write_back2_way;
  
  wire write_back;
  wire write_back2;

  reg write_back_P;
  reg write_back2_P;

  reg [4:0] read_beginA[3:0];
  reg [4:0] read_beginA_reg[3:0];
  reg [4:0] read_beginA_reg2[3:0];
  
  reg [7:0] read_low;
  reg [7:0] read_low_reg;
  reg [7:0] read_low_reg2;
  
//  reg [LINE_WIDTH-1:0] wb_data;
 
  integer v;


  reg sticky_wen;
  reg write_clear_reg;
  reg write_clear_reg2;
  reg write_clkEn0_reg2;
  reg write_clkEn1_reg2;
 
  wire [7:0] read_errT0; 
  wire [7:0] read_errT1; 
  wire [7:0] read_errT2; 
  wire [7:0] read_errT3; 
  reg [7:0] read_errP_reg;
  reg [7:0] read_errP_reg2;
  reg read_clkEnAny;
//  reg wb_en_reg,wb_en_reg2,wb_en_reg3;
  wire [ADDR_WIDTH-1:0] wb_addr;
  reg [ADDR_WIDTH-1:0] wb_addr_reg;
  reg [ADDR_WIDTH-1:0] wb_addr_reg2;
  wire wb_enOut;
  reg wb_enOut_reg;
  reg wb_enOut_reg2;
  generate
      genvar w,b,p,q;
      for (w=0;w<9;w=w+1) begin : ways_gen
          wire [LINE_WIDTH-1:0] read_dataP;
          wire [7:0] read_errP;
          wire [1:0] read_pbit0P;
          wire [1:0] read_pbit1P;
          wire [1:0] read_pbit2P;
          wire [1:0] read_pbit3P;
          if (w) dcache1_way #(w-1) way_mod(
          clk,
          rst,
          read_addrE0, read_addrO0, read_bank0, read_clkEn0, read_hit0_way[w-1], 
            read_odd0, read_split0, ways_gen[w].read_pbit0P, ways_gen[w-1].read_pbit0P, read_errT0[w-1],
          read_addrE1, read_addrO1, read_bank1, read_clkEn1, read_hit1_way[w-1],   
            read_odd1, read_split1, ways_gen[w].read_pbit1P, ways_gen[w-1].read_pbit1P, read_errT1[w-1],
          read_addrE2, read_addrO2, read_bank2, read_clkEn2, read_hit2_way[w-1],   
            read_odd2, read_split2, ways_gen[w].read_pbit2P, ways_gen[w-1].read_pbit2P, read_errT2[w-1],
          read_addrE3, read_addrO3, read_bank3, read_clkEn3, read_hit3_way[w-1],   
            read_odd3, read_split3, ways_gen[w].read_pbit3P, ways_gen[w-1].read_pbit3P, read_errT3[w-1],
          read_bankNoRead,
          read_invalidate_reg,
          read_bankHit_way[w-1],
          ways_gen[w].read_dataP,
	  ways_gen[w-1].read_dataP,
          ways_gen[w].read_errP,
	  ways_gen[w-1].read_errP,
	  read_beginA0,read_low0,
	  read_beginA1,read_low1,
	  read_beginA2,read_low2,
	  read_beginA3,read_low3,
          write_addrE0_reg,
          write_addrO0_reg,
          write_bank0_reg2,
          write_begin0_reg,write_end0_reg,
          write_bgnBen0_reg,write_endBen0_reg,
          write_clkEn0_reg,
          write_hit0P&sticky_wen,
          write_hit0_way[w-1],
          write_dupl0_way[w-1],
          write_split0_reg,
          write_pbit0_reg,
          write_d128_0_reg,
          write_odd0_reg,
          write_errS0,
          write_addrE1_reg,
          write_addrO1_reg,
          write_bank1_reg2,
          write_begin1_reg,write_end1_reg,
          write_bgnBen1_reg,write_endBen1_reg,
          write_clkEn1_reg,
          write_hit1P&sticky_wen,
          write_hit1_way[w-1],
          write_dupl1_way[w-1],
          write_split1_reg,
          write_pbit1_reg,
          write_d128_1_reg,
          write_odd1_reg,
          write_errS1,
          insert_en_reg,
          insert_exclusive_reg2,
          insert_dirty_reg2,
          write_data_ecc,
          write_dataPTR_reg2,
          err_tag[w-1],
          recent_in,
          recent_out[w-1],
          insert_rand,
          insert_hit_way[w-1],
          wb_addr,wb_enOut,
          puke_addr,puke_en
          );
      end
      for (b=0;b<BANK_COUNT;b=b+1) begin
          dc1_strip_par strip_mod(read_dataP_reg2[b*DATA_WIDTH+:DATA_WIDTH],read_data_strip[b*32+:32]);
          dc1_get_par wrEcc_mod(write_data_reg2[b*32+:32],write_data_ecc[b*DATA_WIDTH+:DATA_WIDTH]); 
          dc1_get_par wrEcc2_mod(~write_dataM_reg2[b*32+:32],write_dataM0_ecc[b*DATA_WIDTH+:DATA_WIDTH]); 

	  assign write_dataM_ecc[b*DATA_WIDTH+:DATA_WIDTH]=~write_dataM0_ecc[b*DATA_WIDTH+:DATA_WIDTH];
          
          wire [4:0] wr0;
          wire [4:0] wr1;
          for(q=0;q<5;q=q+1) begin
              assign wr0[q]=((b-q)&5'h1f)==write_begin0 && write_clkEn0 && write_bank0[b];
              assign wr1[q]=((b-q)&5'h1f)==write_begin1 && write_clkEn1 && write_bank1[b];
              assign write_data[b*32+:32]=wr0[q] ? write_data0[q*32+:32] : 32'BZ;
              assign write_data[b*32+:32]=wr1[q] ? write_data1[q*32+:32] : 32'BZ;
              assign write_dataM[b*32+:32]=wr0[q] ? write_dataM0[q*32+:32] : 32'BZ;
              assign write_dataM[b*32+:32]=wr1[q] ? write_dataM1[q*32+:32] : 32'BZ;
          end
          assign  write_data[b*32+:32]=(|{wr0,wr1}) ? 32'BZ : 
            busIns_data[(b%16)*32+:32];
          assign  write_dataM[b*32+:32]=(|{wr0,wr1}) ? 32'BZ : 
            ~busIns_data[(b%16)*32+:32];
  /*        assign bank_hit[b]=read_bankHit_way[0][b] | read_bankHit_way[1][b] | read_bankHit_way[2][b] | 
            read_bankHit_way[3][b] | read_bankHit_way[4][b] | read_bankHit_way[5][b] |  
            read_bankHit_way[6][b] | read_bankHit_way[7][b]; */
          if (b<16) begin
              assign rddata1[0]=({read_beginA_reg[0][1:0],read_low_reg[1:0]}==b) ? rxdata[0][b*8+:136] : 136'BZ;
              assign rddata1[1]=({read_beginA_reg[1][1:0],read_low_reg[3:2]}==b) ? rxdata[1][b*8+:136] : 136'BZ;
              assign rddata1[2]=({read_beginA_reg[2][1:0],read_low_reg[5:4]}==b) ? rxdata[2][b*8+:136] : 136'BZ;
              assign rddata1[3]=({read_beginA_reg[3][1:0],read_low_reg[7:6]}==b) ? rxdata[3][b*8+:136] : 136'BZ;
              assign rderr1[0]=({read_beginA_reg[0][1:0],2'b0}==b) ? |rxerr[0][b+:4] : 1'BZ;
              assign rderr1[1]=({read_beginA_reg[1][1:0],2'b0}==b) ? |rxerr[1][b+:4] : 1'BZ;
              assign rderr1[2]=({read_beginA_reg[2][1:0],2'b0}==b) ? |rxerr[2][b+:4] : 1'BZ;
              assign rderr1[3]=({read_beginA_reg[3][1:0],2'b0}==b) ? |rxerr[3][b+:4] : 1'BZ;
              assign rderr2[0]=({read_beginA_reg[0][1:0],2'b0}==b) ? |rxerr7B[0][b+:4] : 1'BZ;
              assign rderr2[1]=({read_beginA_reg[1][1:0],2'b0}==b) ? |rxerr7B[1][b+:4] : 1'BZ;
              assign rderr2[2]=({read_beginA_reg[2][1:0],2'b0}==b) ? |rxerr7B[2][b+:4] : 1'BZ;
              assign rderr2[3]=({read_beginA_reg[3][1:0],2'b0}==b) ? |rxerr7B[3][b+:4] : 1'BZ;
          end
      end
      for (p=0;p<4;p=p+1) begin
              assign rddata2[p]=rxdata[p][255:128];
	      assign rxdata0[p]=read_data_strip[255:0]&{256{read_beginA_reg[p][4:2]==3'd0}};
              assign rxerr0[p]=read_errP_reg2[7:0]&read_banks[p][7:0]&{8{read_beginA_reg[p][4:2]==3'd0}};
	      assign rxdata1[p]=read_data_strip[128+255:128]&{256{read_beginA_reg[p][4:2]==3'd1}};
              assign rxerr1[p]=read_errP_reg2[11:4]&read_banks[p][11:4]&{8{read_beginA_reg[p][4:2]==3'd1}};
	      assign rxdata2[p]=read_data_strip[511:256]&{256{read_beginA_reg[p][4:2]==3'd2}};
              assign rxerr2[p]=read_errP_reg2[15:8]&read_banks[p][15:8]&{8{read_beginA_reg[p][4:2]==3'd2}};
	      assign rxdata3[p]=read_data_strip[128+511:128+256]&{256{read_beginA_reg[p][4:2]==3'd3}};
              assign rxerr3[p]=read_errP_reg2[19:12]&read_banks[p][19:12]&{8{read_beginA_reg[p][4:2]==3'd3}};
	      assign rxdata4[p]=read_data_strip[767:512]&{256{read_beginA_reg[p][4:2]==3'd4}};
              assign rxerr4[p]=read_errP_reg2[23:16]&read_banks[p][23:16]&{8{read_beginA_reg[p][4:2]==3'd4}};
	      assign rxdata5[p]=read_data_strip[767+128:128+512]&{256{read_beginA_reg[p][4:2]==3'd5}};
              assign rxerr5[p]=read_errP_reg2[27:20]&read_banks[p][27:20]&{8{read_beginA_reg[p][4:2]==3'd5}};
	      assign rxdata6[p]=read_data_strip[1023:768]&{256{read_beginA_reg[p][4:2]==3'd6}};
              assign rxerr6[p]=read_errP_reg2[31:24]&read_banks[p][31:24]&{8{read_beginA_reg[p][4:2]==3'd6}};
	      assign rxdata7[p]={read_data_strip[127:0],read_data_strip[1023:768+128]}&
		{256{read_beginA_reg[p][4:2]==3'd7}};
              assign rxerr7[p]={4'b0,read_errP_reg2[31:28]}&{read_banks[p][31:28]}&
                {8{read_beginA_reg[p][4:2]==3'd7}};
              assign rxerr7B[p]={read_errP_reg2[3:0],4'b0}&{read_banks[p][3:0],4'b0}&
                {8{read_beginA_reg[p][4:2]==3'd7}};
	      assign rxdata[p]=rxdata0[p]|rxdata1[p]|rxdata2[p]|rxdata3[p]|
		rxdata4[p]|rxdata5[p]|rxdata6[p]|rxdata7[p];
	      assign rxerr[p]=rxerr0[p]|rxerr1[p]|rxerr2[p]|rxerr3[p]|
		rxerr4[p]|rxerr5[p]|rxerr6[p]|rxerr7[p];
              assign read_dataA[p][135:128]=(swpdata[v] ? rdata1[p][135:128] : ~mskdata1[p][5] ? pwndata[p][135:128] : rddata1[p][135:128]);
              assign read_dataA[p][127:80]=(swpdata[v] ? rdata1[p][127:80] : ~mskdata1[p][4] ? pwndata[p][127:80] : rddata1[p][127:80]);
              assign read_dataA[p][79:64]=(swpdata[v] ? rdata1[p][79:64] : ~mskdata1[p][3] ? pwndata[p][79:64] : rddata1[p][79:64]);
              assign read_dataA[p][63:32]=(swpdata[v] ? {rdata1[p][7:0],rdata1[p][15:8],rdata1[p][23:16],rdata1[p][31:24]} : ~mskdata1[p][2] ? pwndata[p][63:32] : rddata1[p][63:32]);
              assign read_dataA[p][31:16]=(swpdata[v] ? {rdata1[p][39:32],rddata1[p][47:40]} : ~mskdata1[p][1] ? pwndata[p][31:16] : rddata1[p][31:16]);
              assign read_dataA[p][15:8]=(swpdata[v] ? rdata1[p][55:48] : ~mskdata1[p][0] ? pwndata[p][15:8] : rddata1[p][15:8]);
              assign read_dataA[p][7:0]=(swpdata[v] ? rdata1[p][63:56] : rddata1[p][7:0]);
              assign puke_addr[p]=read_odd_reg[p]|read_split_reg[p] && rderr1[p] ? read_addrO_reg[p][6:0] : read_addrE_reg[p][6:0];
              assign puke_en[p]=rderr1[p] | rderr2[p];
    end
  endgenerate
  assign puke_addr[4]=0;//write_odd[4] && write_errL_reg2[4] ? write_addrO[4][6:0] : read_addrE[4][6:0];
  assign puke_en[4]=0;//write_errL_reg2[4] | write_errH_reg2[4];
  assign puke_addr[5]=0;//write_odd[5] && write_errL_reg2[5] ? write_addrO[5][6:0] : read_addrE[5][6:0];
  assign puke_en[5]=0;//write_errL_reg2[5] | write_errH_reg2[5];

  LFSR16_6 rnd_mod(clk,rst,insert_rand);
  
  assign read_pbit0=read_pbit0P_reg2|{1'b0,|emsr && read_sz_reg[0]==5'd19};
  assign read_pbit1=read_pbit1P_reg2|{1'b0,|emsr && read_sz_reg[1]==5'd19};
  assign read_pbit2=read_pbit2P_reg2|{1'b0,|emsr && read_sz_reg[2]==5'd19};
  assign read_pbit3=read_pbit3P_reg2|{1'b0,read3_pf_reg} | {1'b0,|emsr && read_sz_reg[3]==5'd19};
  
  assign read_hitCl0Q=read_hit0_way[0] | read_hit0_way[1] | read_hit0_way[2] | 
    read_hit0_way[3] | read_hit0_way[4] | read_hit0_way[5] |  
    read_hit0_way[6] | read_hit0_way[7]; 
  assign read_hitCl1Q=read_hit1_way[0] | read_hit1_way[1] | read_hit1_way[2] | 
    read_hit1_way[3] | read_hit1_way[4] | read_hit1_way[5] |  
    read_hit1_way[6] | read_hit1_way[7]; 
  assign read_hitCl2Q=read_hit2_way[0] | read_hit2_way[1] | read_hit2_way[2] | 
    read_hit2_way[3] | read_hit2_way[4] | read_hit2_way[5] |  
    read_hit2_way[6] | read_hit2_way[7]; 
  assign read_hitCl3Q=read_hit3_way[0] | read_hit3_way[1] | read_hit3_way[2] | 
    read_hit3_way[3] | read_hit3_way[4] | read_hit3_way[5] |  
    read_hit3_way[6] | read_hit3_way[7];
    
  assign read_hitCl0P=read_hitCl0Q & {rdreqO0,rdreqE0};
  assign read_hitCl1P=read_hitCl1Q & {rdreqO1,rdreqE1};
  assign read_hitCl2P=read_hitCl2Q & {rdreqO2,rdreqE2};
  assign read_hitCl3P=read_hitCl3Q & {rdreqO3,rdreqE3};

  assign read_NdataA0=~read_dataA0;
  assign read_NdataA1=~read_dataA1;
  assign read_NdataA2=~read_dataA2;
  assign read_NdataA3=~read_dataA3;

  assign write_dupl0P=write_dupl0_way[0]|write_dupl0_way[1]|write_dupl0_way[2]|write_dupl0_way[3]|write_dupl0_way[4]|
    write_dupl0_way[5]|write_dupl0_way[6]|write_dupl0_way[7];
  assign write_dupl1P=write_dupl1_way[0]|write_dupl1_way[1]|write_dupl1_way[2]|write_dupl1_way[3]|write_dupl1_way[4]|
        write_dupl1_way[5]|write_dupl1_way[6]|write_dupl1_way[7];

  assign expun_addr=wb_addr_reg2;
  assign expun_en=wb_enOut_reg2;
  assign wb_addr=insert_hit_way!=0 ? 37'bz : 37'b0;
  assign wb_enOut=insert_hit_way!=0 ? 1'bz : 1'b0;
  
  assign write_hitCl0P=write_hit0_way[0] | write_hit0_way[1] | write_hit0_way[2] | 
    write_hit0_way[3] | write_hit0_way[4] | write_hit0_way[5] |  
    write_hit0_way[6] | write_hit0_way[7];
  assign write_hitCl1P=write_hit1_way[0] | write_hit1_way[1] | write_hit1_way[2] | 
    write_hit1_way[3] | write_hit1_way[4] | write_hit1_way[5] |  
    write_hit1_way[6] | write_hit1_way[7]; 
    
 assign write_hit0P=(write_hitCl0P[0] | ~wrreqE0 && write_hitCl0P[1] | ~wrreqO0 ) &&
   (wrreqE0|wrreqO0);
 assign write_hit1P=(write_hitCl1P[0] | ~wrreqE1 && write_hitCl1P[1] | ~wrreqO1 ) &&
   (wrreqE1|wrreqO1);
   
 assign write_back=|write_back_way;
 assign write_back2=|write_back2_way;
   
    
  assign recent_in=|recent_out;

  assign read_dataA0=read_dataA[0];
  assign read_dataA1=read_dataA[1];
  assign read_dataA2=read_dataA[2];
  assign read_dataA3=read_dataA[3];

  assign read_dataX0={128{read_sz_reg[0][4:1]==4'd6 || read_sz_reg[0]==5'd14}}&rddata2[0];
  assign read_dataX1={128{read_sz_reg[1][4:1]==4'd6 || read_sz_reg[1]==5'd14}}&rddata2[0];
  assign read_dataX2={128{read_sz_reg[2][4:1]==4'd6 || read_sz_reg[2]==5'd14}}&rddata2[0];
  assign read_dataX3={128{read_sz_reg[3][4:1]==4'd6 || read_sz_reg[3]==5'd14}}&rddata2[0];
 
  assign ways_gen[0].read_dataP={LINE_WIDTH{1'B0}}; 
  assign ways_gen[0].read_pbit0P=2'b0;
  assign ways_gen[0].read_pbit1P=2'b0;
  assign ways_gen[0].read_pbit2P=2'b0;
  assign ways_gen[0].read_pbit3P=2'b0;
  assign ways_gen[0].read_errP='0;
  assign read_hit0P=(|read_hitCl0Q[0] | ~rdreqE0) && (read_hitCl0Q[1] | ~rdreqO0) &&
    (rdreqE0 | rdreqO0) && ~insert_en_reg2 & ~rderr1[0] & ~rderr2[0];
  assign read_hit1P=(read_hitCl1Q[0] | ~rdreqE1) && (read_hitCl1Q[1] | ~rdreqO1) &&
    (rdreqE1 | rdreqO1) && ~insert_en_reg2 & ~rderr1[1] & ~rderr2[1];
  assign read_hit2P=(read_hitCl2Q[0] | ~rdreqE2) && (read_hitCl2Q[1] | ~rdreqO2) &&
    (rdreqE2 | rdreqO2) && ~insert_en_reg2 & ~rderr1[2] & ~rderr2[2];
  assign read_hit3P=(read_hitCl3Q[0] | ~rdreqE3) && (read_hitCl3Q[1] | ~rdreqO3) &&
    (rdreqE3 | rdreqO3) && ~insert_en_reg2 & ~rderr1[3] & ~rderr2[3];
    
  always @(posedge clk) begin
      if (rst)  begin
          read_invalidate_reg<=1'B0; 

          write_addrE0_reg<={ADDR_WIDTH-1{1'B0}};
          write_addrO0_reg<={ADDR_WIDTH-1{1'B0}};
          write_bank0_reg<={BANK_COUNT{1'B0}};
          write_clkEn0_reg<=1'B0;
          write_split0_reg<=1'B0;
          write_odd0_reg<=1'B0;
          write_begin0_reg<=5'b0;
          write_end0_reg<=5'b0;
          write_bgnBen0_reg<=4'b0;
          write_endBen0_reg<=4'b0; 
          write_pbit0_reg<=2'b0;
          write_d128_0_reg<=1'b0;

          write_addrE1_reg<={ADDR_WIDTH-1{1'B0}};
          write_addrO1_reg<={ADDR_WIDTH-1{1'B0}};
          write_bank1_reg<={BANK_COUNT{1'B0}};
          write_begin1_reg<=5'b0;
          write_end1_reg<=5'b0;
          write_bgnBen1_reg<=4'b0;
          write_endBen1_reg<=4'b0; 
          write_clkEn1_reg<=1'B0;
          write_split1_reg<=1'B0;
          write_odd1_reg<=1'B0;
          write_pbit1_reg<=2'b0;
          write_d128_1_reg<=1'b0;

          insert_en_reg<=1'b0;
          insert_exclusive_reg<=1'b0;
          insert_dirty_reg<=1'b0;

          read_hitCl0<=2'b0;
          read_hitCl1<=2'b0;
          read_hitCl2<=2'b0;
          read_hitCl3<=2'b0;
          read_hit0<=1'b0;
          read_hit1<=1'b0;
          read_hit2<=1'b0;
          read_hit3<=1'b0;

          write_hit0<=1'b0;
          write_hit1<=1'b0;
          write_hitCl0<=2'b0;
          write_hitCl1<=2'b0;
          write_dupl0<=2'b0;
          write_dupl1<=2'b0;

          read_clkEnAny<=1'b0;
          
          write_clear_reg<=1'b0;
          
          wb_addr_reg2<={ADDR_WIDTH{1'B0}};
          wb_enOut_reg2<=1'b0;

          read_low<=8'b0;
          read_low_reg<=8'b0;
          
          
          write_data_reg<=1024'B0;
          write_dataM_reg<=1024'B0;
          write_dataPTR_reg<=16'b0;
          read_dataP_reg2<={LINE_WIDTH{1'B0}};
          read_errP_reg2<=8'b0;
          read_pbit0P_reg2<=2'b0;
          read_pbit1P_reg2<=2'b0;
          read_pbit2P_reg2<=2'b0;
          read_pbit3P_reg2<=2'b0;

          read_bank0_reg<=32'b0;
          read_bank1_reg<=32'b0;
          read_bank2_reg<=32'b0;
          read_bank3_reg<=32'b0;

          read_odd<=4'b0;
          read_odd_reg<=4'b0;
          read_split<=4'b0;
          read_spliy_reg<=4'b0;
          
          for(v=0;v<4;v=v+1) begin
              mskdata1[v]<=6'b0;
              read_sz[v]<=5'b0;
              pwndata[v]<=136'b0;
              read_sz_reg[v]<=5'b0;
              read_beginA[v]<=5'b0;
              read_beginA_reg[v]<=5'b0;
              read_bank[v]<=32'b0;
          end
          read3_pf<=0;
          read3_pf_reg<=0;
          read3_addrMain<=0;
          emsr<=64'b0;        
      end else begin
          read_invalidate_reg<=read_invalidate; 

          write_addrE0_reg<=write_addrE0;
          write_addrO0_reg<=write_addrO0;
          write_bank0_reg<=write_bank0;
          write_clkEn0_reg<=write_clkEn0;
          write_split0_reg<=write_split0;
          write_odd0_reg<=write_odd0;
          write_begin0_reg<=write_begin0;
          write_end0_reg<=write_end0;
          write_bgnBen0_reg<=write_bgnBen0;
          write_endBen0_reg<=write_endBen0;
          write_pbit0_reg<=write_pbit0;
          write_d128_0_reg<=write_d128_0;

          write_addrE1_reg<=write_addrE1;
          write_addrO1_reg<=write_addrO1;
          write_bank1_reg<=write_bank1;
          write_begin1_reg<=write_begin1;
          write_end1_reg<=write_end1;
          write_bgnBen1_reg<=write_bgnBen1;
          write_endBen1_reg<=write_endBen1;
          write_clkEn1_reg<=write_clkEn1;
          write_split1_reg<=write_split1;
          write_odd1_reg<=write_odd1;
          write_pbit1_reg<=write_pbit1;
          write_d128_1_reg<=write_d128_1;

          insert_en_reg<=insert_en;    
          insert_exclusive_reg<=insert_exclusive;
          insert_dirty_reg<=insert_dirty;

          read_hitCl0<=read_hitCl0P_reg;
          read_hitCl1<=read_hitCl1P_reg;
          read_hitCl2<=read_hitCl2P_reg;
          read_hitCl3<=read_hitCl3P_reg;
          read_hit0<=read_hit0P_reg;
          read_hit1<=read_hit1P_reg;
          read_hit2<=read_hit2P_reg;
          read_hit3<=read_hit3P_reg;

          write_hit0<=write_hit0P_reg | &write_hitCl0P_reg;//bypass write cache miss if full miss occurs
          write_hit1<=write_hit1P_reg | &write_hitCl1P_reg;//bypass write cache miss if full miss occurs 
          write_hitCl0<=write_hitCl0P_reg;
          write_hitCl1<=write_hitCl1P_reg;
          write_dupl0<=write_dupl0P_reg;
          write_dupl1<=write_dupl1P_reg;

          read_clkEnAny<=|{read_clkEn0,read_clkEn1,read_clkEn2,read_clkEn3};
          
          read_odd<={read_odd3,read_odd2,read_odd1,read_odd0};
          read_split<={read_split3,read_split2,read_split1,read_split0};
          read_odd_reg<=read_odd;
          read_split_reg<=read_split;


          write_clear_reg<=write_clear;
          
          wb_addr_reg2<=wb_addr_reg;
          wb_enOut_reg2<=wb_enOut_reg;
          
          read_low<={read_low3,read_low2,read_low1,read_low0};
          read_low_reg<=read_low;
          
          
          if (~insbus_B) write_data_reg[WLINE_WIDTH/2-1:0]<=write_data[WLINE_WIDTH/2-1:0];
          if (~insbus_A) write_data_reg[WLINE_WIDTH-1:WLINE_WIDTH/2]<=write_data[WLINE_WIDTH-1:WLINE_WIDTH/2];
          
          if (~insbus_B) write_dataPTR_reg[7:0]<=busIns_dataPTR;
          if (~insbus_A) write_dataPTR_reg[15:8]<=busIns_dataPTR;
          
          if (~insbus_B) write_dataM_reg[WLINE_WIDTH/2-1:0]<=write_dataM[WLINE_WIDTH/2-1:0];
          if (~insbus_A) write_dataM_reg[WLINE_WIDTH-1:WLINE_WIDTH/2]<=write_dataM[WLINE_WIDTH-1:WLINE_WIDTH/2];
          
          if (read_clkEnAny) read_errP_reg2<=read_errP_reg;
	  if (read_clkEnAny) read_dataP_reg2<=read_dataP_reg;
          if (read_clkEnAny) read_pbit0P_reg2<=read_pbit0P_reg;
          if (read_clkEnAny) read_pbit1P_reg2<=read_pbit1P_reg;
          if (read_clkEnAny) read_pbit2P_reg2<=read_pbit2P_reg;
          if (read_clkEnAny) read_pbit3P_reg2<=read_pbit3P_reg;

          read_sz[0]<=read_sz0;
          read_sz[1]<=read_sz1;
          read_sz[2]<=read_sz2;
          read_sz[3]<=read_sz3;

          read3_pf<=read_pf3;
          read3_addrMain<={read_addrE3,read_addrO3[7:0]};
          
          read_beginA[0]<=read_beginA0;
          read_beginA[1]<=read_beginA1;
          read_beginA[2]<=read_beginA2;
          read_beginA[3]<=read_beginA3;

          read_bank0_reg<=read_bank0;
          read_bank1_reg<=read_bank1;
          read_bank2_reg<=read_bank2;
          read_bank3_reg<=read_bank3;

          read_bank[0]<=read_bank0_reg;
          read_bank[1]<=read_bank1_reg;
          read_bank[2]<=read_bank2_reg;
          read_bank[3]<=read_bank3_reg;
          
          for(v=0;v<4;v=v+1) begin
              read_sz_reg[v]<=read_sz[v];
              swpdata[v]<=1'b0;
       //verilator lint_off CASEINCOMPLETE

              case(read_sz[v])
         5'd16: mskdata1[v]<=6'b00000;
         5'd17: mskdata1[v]<=6'b00001;
         5'd18: mskdata1[v]<=6'b00011;
         5'd19: begin mskdata1[v]<=6'b00111; if (emsr!=64'b0) mskdata1[v]<={4'b000,emsr[0],1'b1}; pwndata[v][63:16]<=emsr[63:16]; end
         5'd23: begin mskdata1[v]<=6'b00111; swpdata[v]<=1'b1; end
         5'h3:  mskdata1[v]<=6'b01111; //long double
         5'h0,5'h1,5'h2:  mskdata1[v]<=6'b11111; //int, double, single 128 bit (u)
         5'hc,5'hd,5'he:  mskdata1[v]<=6'b11111; //int, double, single 128 bit (a)
         5'h4,5'h5,5'h6:  mskdata1[v]<=6'b00011; //singleE,single,singleD
         5'h8,5'h9,5'ha:  mskdata1[v]<=6'b00111; //doubleE, double, singlePairD
         5'hb,5'h7:  mskdata1[v]<=6'b00111; //singlePair,64 int(u), 64 int(a)
	 5'hf: mskdata1[v]<=6'b111111;
              endcase
       //verilator lint_on CASEINCOMPLETE
              read_beginA_reg[v]<=read_beginA[v];
              pwndata[v]<=0;
           if (read3_pf[v][0]) begin
               pwndata[v][55:0]<=read3_addrMain[v][43:0];
               pwndata[v][`ptr_low]<={read3_addrMain[v][`ptr_hi+5]-2'b3,read_sz[v]};
               pwndata[v][`ptr_on_low]=read3_pf[v][2]; //out of range bit
           end
           if (read3_pf[v][1]) begin
               pwndata[v][3][43:0]<=read3_addrMain[v][43:0];
               pwndata[v][3][63:48]<={15'h7fff,read3_pf[v][2]};//note: this signalling NaN shouldn't be produced by computation; also  includes out of bound indicator
               pwndata[v][3][47:43]<=read_sz[3];
           end
           read3_pf_reg[v]<=read3_pf[v];
           end
           if (msrss_en && msrss_addr[14:0]==`csr_embedded_mode) emsr<=msrss_data;
      end
  end
  
  always @(negedge clk) begin
      if (rst) begin
          write_bank0_reg2<=32'b0;
          write_bank1_reg2<=32'b0;
          write_data_reg2<={WLINE_WIDTH{1'B0}};
          write_dataM_reg2<={WLINE_WIDTH{1'B0}};
          write_dataPTR_reg2<=16'b0;
          insert_exclusive_reg2<=1'b0;
          insert_dirty_reg2<=1'b0;
          
          read_hitCl0P_reg<=2'b0;
          read_hitCl1P_reg<=2'b0;
          read_hitCl2P_reg<=2'b0;
          read_hitCl3P_reg<=2'b0;
          read_hit0P_reg<=1'b0;
          read_hit1P_reg<=1'b0;
          read_hit2P_reg<=1'b0;
          read_hit3P_reg<=1'b0;

          write_hit0P_reg<=1'b0;
          write_hit1P_reg<=1'b0;
          write_hitCl0P_reg<=2'b0;
          write_hitCl1P_reg<=2'b0;
          write_dupl0P_reg<=2'b0;
          write_dupl1P_reg<=2'b0;
          
          write_bank0_reg2<={BANK_COUNT{1'b0}};
          write_bank1_reg2<={BANK_COUNT{1'b0}};

          rdreqE0<=1'b0;
          rdreqO0<=1'b0;
          rdreqE1<=1'b0;
          rdreqO1<=1'b0;
          rdreqE2<=1'b0;
          rdreqO2<=1'b0;
          rdreqE3<=1'b0;
          rdreqO3<=1'b0;

          wrreqE0<=1'b0;
          wrreqO0<=1'b0;
          wrreqE1<=1'b0;
          wrreqO1<=1'b0;

          insert_exclusive_reg2<=1'b0;
          insert_dirty_reg2<=1'b0;
          
          read_invalidate_reg2<=1'b0;
          
          wb_addr_reg<={ADDR_WIDTH{1'B0}};
          wb_enOut_reg<=1'b0;

          sticky_wen<=1'b1;
          write_clear_reg2<=1'b0;
          write_clkEn0_reg2<=1'b0;
          write_clkEn1_reg2<=1'b0;
          
          insert_en_reg2<=1'b0;
          read_pbit0P_reg<=2'b0;
          read_pbit1P_reg<=2'b0;
          read_pbit2P_reg<=2'b0;
          read_pbit3P_reg<=2'b0;
          read_dataP_reg<={LINE_WIDTH{1'B0}};
          read_errP_reg<=8'b0;
          write_data_reg2<={WLINE_WIDTH{1'B0}};
          write_dataM_reg2<={WLINE_WIDTH{1'B0}};
      end else begin
          write_bank0_reg2<=write_bank0_reg;
          write_bank1_reg2<=write_bank1_reg;
          write_data_reg2<=write_data;
          write_dataPTR_reg2<=write_dataPTR_reg;
          insert_exclusive_reg2<=insert_exclusive_reg;
          insert_dirty_reg2<=insert_dirty;
          
          read_hitCl0P_reg<=read_hitCl0P;
          read_hitCl1P_reg<=read_hitCl1P;
          read_hitCl2P_reg<=read_hitCl2P;
          read_hitCl3P_reg<=read_hitCl3P;
          read_hit0P_reg<=read_hit0P;
          read_hit1P_reg<=read_hit1P;
          read_hit2P_reg<=read_hit2P;
          read_hit3P_reg<=read_hit3P;
          
          write_hit0P_reg<=write_hit0P & sticky_wen;
          write_hit1P_reg<=write_hit1P & sticky_wen & (write_hit0P|~write_clkEn0_reg2);
          write_hitCl0P_reg<=write_hitCl0P;
          write_hitCl1P_reg<=write_hitCl1P;
          write_dupl0P_reg<=write_dupl0P;
          write_dupl1P_reg<=write_dupl1P;

          write_bank0_reg2<=write_bank0_reg;
          write_bank1_reg2<=write_bank1_reg;
          
          insert_exclusive_reg2<=insert_exclusive_reg;
          insert_dirty_reg2<=insert_dirty_reg;
          
          read_invalidate_reg2<=read_invalidate_reg;//?? remove _reg 
          
          wb_addr_reg<=wb_addr;
          wb_enOut_reg<=wb_enOut;

          rdreqE0<=~read_odd0 | read_split0 && read_clkEn0;
          rdreqO0<=read_odd0 | read_split0 && read_clkEn0;
          rdreqE1<=~read_odd1 | read_split1 && read_clkEn1;
          rdreqO1<=read_odd1 | read_split1 && read_clkEn1;
          rdreqE2<=~read_odd2 | read_split2 && read_clkEn2;
          rdreqO2<=read_odd2 | read_split2 && read_clkEn2;
          rdreqE3<=~read_odd3 | read_split3 && read_clkEn3;
          rdreqO3<=read_odd3 | read_split3 && read_clkEn3;

          wrreqE0<=~write_odd0_reg | write_split0_reg && write_clkEn0_reg;
          wrreqO0<=write_odd0_reg | write_split0_reg && write_clkEn0_reg;
          wrreqE1<=~write_odd1_reg | write_split1_reg && write_clkEn1_reg;
          wrreqO1<=write_odd1_reg | write_split1_reg && write_clkEn1_reg;
          
          if (write_clear_reg2) sticky_wen<=1'b1;
          else if (write_clkEn0_reg2 & ~write_hit0P || write_clkEn1_reg2 & ~write_hit1P)
            sticky_wen<=1'b0;
          write_clear_reg2<=write_clear_reg;
          write_clkEn0_reg2<=write_clkEn0_reg;
          write_clkEn1_reg2<=write_clkEn1_reg;
          
          insert_en_reg2<=insert_en_reg;
          read_pbit0P_reg<=ways_gen[8].read_pbit0P;
          read_pbit1P_reg<=ways_gen[8].read_pbit1P;
          read_pbit2P_reg<=ways_gen[8].read_pbit2P;
          read_pbit3P_reg<=ways_gen[8].read_pbit3P;
          read_dataP_reg<=ways_gen[8].read_dataP;
          read_errP_reg<=ways_gen[8].read_errP;
          write_data_reg2<=write_data_reg;
          write_dataM_reg2<=write_dataM_reg;
      end
  end
endmodule


module dc1_strip_ECC(dataIn,dataOut);
  input [39:1] dataIn;
  output [31:0] dataOut;
  
  assign dataOut={dataIn[38:33],dataIn[31:17],dataIn[15:9],dataIn[7:5],dataIn[3]};
  
endmodule
