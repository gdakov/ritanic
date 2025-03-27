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


//read-during-write behaviour: write first
module tbuf_ram0(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  parameter DATA_WIDTH=29;
  parameter ADDR_WIDTH=9;
  parameter ADDR_COUNT=512;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
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
      if (write_wen) ram[write_addr]<=write_data;
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
    end

endmodule

module tbuf_ram1(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen,
  write_cond
  );

  parameter [15:0] init_lfsr=16'hf134;
  parameter DATA_WIDTH=63;
  parameter ADDR_WIDTH=9;
  parameter ADDR_COUNT=512;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;
  input pwire write_cond;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;
  pwire [ADDR_WIDTH-1:0] write_addr_save;
  pwire [DATA_WIDTH-1:0] write_data_save;
  pwire save;
  pwire [5:0] data_rand;
  pwire match;
  
  assign read_data=save && pwh#(32)::cmpEQ(read_addr_reg,write_addr_save) ? write_data_save : ram[read_addr_reg];

  LFSR_16_6 #(init_lfsr) rand_mod(clk,rst,data_rand);

  assign match=!write_cond || data_rand[1] || pwh#(2)::cmpEQ(data_rand[1:0],2'b0);

  always @(posedge clk)
    begin
      if (write_wen && match) ram[write_addr]<=write_data;
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen) begin
        write_addr_save<=write_addr;
        write_data_save<=write_data;
        save<=1'b1;
      end else if (read_clkEn) begin
        save<=1'b0;
      end
    end

endmodule

module tbuf_ram2(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  parameter DATA_WIDTH=`btb_width-29-4*63;
  parameter ADDR_WIDTH=9;
  parameter ADDR_COUNT=512;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
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
      if (write_wen) ram[write_addr]<=write_data;
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
    end

endmodule

module tbuf_ram_block(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen,
  ioen,
  indiren
  );

  parameter DATA_WIDTH=`btb_width;
  parameter ADDR_WIDTH=9;
  parameter ADDR_COUNT=512;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;
  input pwire [3:0] ioen;
  input pwire [3:0] indiren;

  tbuf_ram0 ram0_mod(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data[28:0],
  write_addr,
  write_data[28:0],
  write_wen&&pwh#(32)::cmpEQ(ioen,15)
  );

  tbuf_ram1 ram10_mod(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data[`btb_tgt_IP0],
  write_addr,
  write_data[`btb_tgt_IP0],
  write_wen&ioen[0],indiren[0]
  );
  tbuf_ram1 ram11_mod(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data[`btb_tgt_IP1],
  write_addr,
  write_data[`btb_tgt_IP1],
  write_wen&ioen[1],indiren[1]
  );
  tbuf_ram1 ram12_mod(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data[`btb_tgt_IP2],
  write_addr,
  write_data[`btb_tgt_IP2],
  write_wen&ioen[2],indiren[2]
  );
  tbuf_ram1 ram13_mod(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data[`btb_tgt_IP3],
  write_addr,
  write_data[`btb_tgt_IP3],
  write_wen&ioen[3],indiren[3]
  );
  
  tbuf_ram2 ram2_mod(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data[DATA_WIDTH-1:29+4*63],
  write_addr,
  {1'b0,write_data[DATA_WIDTH-1:29+4*63]},
  write_wen&&pwh#(32)::cmpEQ(ioen,15)
  );
endmodule

//read-during-write behaviour: write first;
module tbufExtra_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  parameter DATA_WIDTH=`btbExtra_width;
  parameter ADDR_WIDTH=9;
  parameter ADDR_COUNT=512;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] read_addr_reg;

  integer i;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (write_wen) ram[write_addr]<=write_data;
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
    end

endmodule


module freq_update(freq,new_freq);

  input pwire [6:0] freq;
  output pwire [6:0] new_freq;
  
  adder_inc #(7) ifreq_mod(freq,new_freq,freq!=7'h7f,);
  assign new_freq=(pwh#(7)::cmpEQ(freq,7'h7f)) ? 7'h7f : 7'bz;  
endmodule

module sc_update(sc,taken,new_sc);

  input pwire [1:0] sc;
  input pwire taken;
  output pwire [1:0] new_sc;
  
  assign new_sc[1]=sc[0]==taken;
  assign new_sc[0]=sc[1] ? sc[0] : taken;
  
endmodule

module tbuf_way(
  clk,
  rst,
  read_clkEn,
  mStall,
  except_reg,
  except_indir_reg,
  nextIP,
  read_hit,read_hit_other,
  read_LRU_hit,
  read_write_fwd,
  has0,has1,has2,has3,
  sc0,sc1,sc2,sc3,
  jmp_mask0,jmp_mask1,jmp_mask2,jmp_mask3,jmp_mask,jmp_mask_in,taken,
  tbuf_pred,
  cond,
  indir,
  link0,lnpos0,ljpos0,
  link1,lnpos1,ljpos1,
  link2,lnpos2,ljpos2,
  link3,lnpos3,ljpos3,
  way,way_hit,
  tgt0I,tgt1I,tgt2I,tgt3I,
  tgt0O,tgt1O,tgt2O,tgt3O,
  off0,off1,off2,off3,
  attr0I,attr1I,attr2I,attr3I,
  attr0O,attr1O,attr2O,attr3O,
  write_off0,write_off1,write_off2,write_off3,
  write_cond,
  write_indir,
  write_link0,write_lnpos0,write_init0,
  write_link1,write_lnpos1,write_init1,
  write_link2,write_lnpos2,write_init2,
  write_link3,write_lnpos3,write_init3,
  write_way,
  write_wen,
  write_insert,
  update_addr0,update_addr1,
  update_en, update_taken,
  update_use, update_dis,
  scupd_taken,scupd_en,scupd_addr
  );
  
  localparam IP_WIDTH=64;
  localparam TGTIP_WIDTH=64;
  localparam HIST_WIDTH=8;
  localparam DATA_WIDTH=`btb_width;
  localparam EXTRA_WIDTH=`btbExtra_width;
  parameter [0:0] WAY=0;
  parameter [0:0] HALF=0;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire mStall;
  input pwire except_reg;
  input pwire except_indir_reg;
  input pwire [IP_WIDTH-1:1] nextIP;
  output pwire read_hit;
  input pwire read_hit_other;
  input pwire read_LRU_hit;
  input pwire read_write_fwd;
  output pwire has0,has1,has2,has3;
  output pwire [1:0] sc0;
  output pwire [1:0] sc1;
  output pwire [1:0] sc2;
  output pwire [1:0] sc3;
  output pwire [3:0] jmp_mask0;
  output pwire [3:0] jmp_mask1;
  output pwire [3:0] jmp_mask2;
  output pwire [3:0] jmp_mask3;
  output pwire [3:0] jmp_mask;
  input pwire [3:0]  jmp_mask_in;
  input pwire [3:0] taken;
  output pwire [3:0] tbuf_pred;
  output pwire [3:0] cond;
  output pwire [3:0] indir;
  output pwire [4:0] link0;
  output pwire [4:0] lnpos0;
  output pwire [4:0] ljpos0;
  output pwire [4:0] link1;
  output pwire [4:0] lnpos1;
  output pwire [4:0] ljpos1;
  output pwire [4:0] link2;
  output pwire [4:0] lnpos2;
  output pwire [4:0] ljpos2;
  output pwire [4:0] link3;
  output pwire [4:0] lnpos3;
  output pwire [4:0] ljpos3;
  output pwire way;
  output pwire way_hit;
  
  input pwire [TGTIP_WIDTH-1:1] tgt0I;
  input pwire [TGTIP_WIDTH-1:1] tgt1I;
  input pwire [TGTIP_WIDTH-1:1] tgt2I;
  input pwire [TGTIP_WIDTH-1:1] tgt3I;
  output pwire [TGTIP_WIDTH-1:1] tgt0O;
  output pwire [TGTIP_WIDTH-1:1] tgt1O;
  output pwire [TGTIP_WIDTH-1:1] tgt2O;
  output pwire [TGTIP_WIDTH-1:1] tgt3O;

  output pwire [3:0] off0;
  output pwire [3:0] off1;
  output pwire [3:0] off2;
  output pwire [3:0] off3;
  
  input pwire [3:0] attr0I;
  input pwire [3:0] attr1I;
  input pwire [3:0] attr2I;
  input pwire [3:0] attr3I;

  output pwire [3:0] attr0O;
  output pwire [3:0] attr1O;
  output pwire [3:0] attr2O;
  output pwire [3:0] attr3O;

  input pwire [3:0] write_off0;
  input pwire [3:0] write_off1;
  input pwire [3:0] write_off2;
  input pwire [3:0] write_off3;
  input pwire [3:0] write_init0;
  input pwire [3:0] write_init1;
  input pwire [3:0] write_init2;
  input pwire [3:0] write_init3;
  input pwire [3:0] write_cond;
  input pwire [3:0] write_indir;
  input pwire [4:0] write_link0;
  input pwire [4:0] write_lnpos0;
  input pwire [4:0] write_link1;
  input pwire [4:0] write_lnpos1;
  input pwire [4:0] write_link2;
  input pwire [4:0] write_lnpos2;
  input pwire [4:0] write_link3;
  input pwire [4:0] write_lnpos3;
  input pwire write_way;
  input pwire write_wen;
  input pwire write_insert;  
  input pwire [12:0] update_addr0;
  input pwire [12:0] update_addr1;
  input pwire update_en;
  input pwire [1:0] update_taken;
  input pwire [1:0] update_use;
  input pwire [1:0] update_dis;
  input pwire scupd_taken;
  input pwire scupd_en;
  input pwire [12:0] scupd_addr;

  pwire scupd_hit;
  
  pwire [1:0] scupd_sc0;
  pwire [1:0] scupd_sc1;
  pwire [1:0] scupd_sc2;
  pwire [1:0] scupd_sc3;

  pwire [1:0] sc0P;
  pwire [1:0] sc1P;
  pwire [1:0] sc2P;
  pwire [1:0] sc3P;
  
  pwire [9:0] IP_wbits;
  pwire  [9:0] IP_wbits_reg;
  pwire upd_eq0;
  pwire upd_eq1;
  
  pwire upd_eq01;
  
  pwire upd_id0;
  pwire upd_id1;
  pwire upd_idS;
  
  pwire [9:0] update_addr;
  pwire [9:0] update_addr_new;
  

  pwire [1:0] upd_j0;
  pwire [1:0] upd_j1;
  pwire [1:0] upd_j2;
  pwire [1:0] upd_j3;

  pwire [1:0] upd_j0_reg;
  pwire [1:0] upd_j1_reg;
  pwire [1:0] upd_j2_reg;
  pwire [1:0] upd_j3_reg;

  pwire [3:0] upd_taken;
  pwire [3:0] upd_taken_reg;
  pwire [3:0] sve_taken;
  
  pwire [6:0] upd_freq0;
  pwire [6:0] upd_freq1;
  pwire [6:0] upd_freq2;
  pwire [6:0] upd_freq3;

  pwire [6:0] updW_freq0;
  pwire [6:0] updW_freq1;
  pwire [6:0] updW_freq2;
  pwire [6:0] updW_freq3;

  pwire [6:0] updS_freq0;
  pwire [6:0] updS_freq1;
  pwire [6:0] updS_freq2;
  pwire [6:0] updS_freq3;
  
  pwire [1:0] upd_sc0;
  pwire [1:0] upd_sc1;
  pwire [1:0] upd_sc2;
  pwire [1:0] upd_sc3;

  pwire [1:0] updW_sc0;
  pwire [1:0] updW_sc1;
  pwire [1:0] updW_sc2;
  pwire [1:0] updW_sc3;

  pwire [1:0] updS_sc0;
  pwire [1:0] updS_sc1;
  pwire [1:0] updS_sc2;
  pwire [1:0] updS_sc3;

  pwire read_valid;
  pwire [28:0] read_src;
  pwire [62:0] read_tgt0;
  pwire [62:0] read_tgt1;
  pwire [62:0] read_tgt2;
  pwire [62:0] read_tgt3;
  pwire [2:0]  read_attr0;
  pwire [2:0]  read_attr1;
  pwire [2:0]  read_attr2;
  pwire [2:0]  read_attr3;
  pwire [3:0] read_off0;
  pwire [3:0] read_off1;
  pwire [3:0] read_off2;
  pwire [3:0] read_off3;
  pwire [3:0] read_jmask0;
  pwire [3:0] read_jmask1;
  pwire [3:0] read_jmask2;
  pwire [3:0] read_jmask3;
  pwire read_second;
  pwire [3:0] read_mask;
  pwire IP_match;
  pwire read_LRU;
  pwire [4:0] read_link0;
  pwire [4:0] read_lnpos0;
  pwire [4:0] read_link1;
  pwire [4:0] read_lnpos1;
  pwire [4:0] read_link2;
  pwire [4:0] read_lnpos2;
  pwire [4:0] read_link3;
  pwire [4:0] read_lnpos3;

  pwire [6:0] read_freq0;
  pwire [6:0] read_freq1;
  pwire [6:0] read_freq2;
  pwire [6:0] read_freq3;
  
  pwire j0_after;
  pwire j1_after;
  pwire j2_after;
  pwire j3_after;

  pwire [IP_WIDTH-1:1] nextIP_reg;
  
  pwire [DATA_WIDTH-1:0] btb_data;
  pwire  [DATA_WIDTH-1:0] btb_data_reg;
  pwire [DATA_WIDTH-1:0] write_data;
  pwire [DATA_WIDTH-1:0] write_dataW;
  pwire [DATA_WIDTH-1:0] write_dataW_reg;
  pwire [DATA_WIDTH-2:0] write_dataJ;
  
  pwire ram_wen;
  
  pwire [EXTRA_WIDTH-1:0] extra_data;
  pwire [EXTRA_WIDTH-1:0] extra_dataU;
  pwire [EXTRA_WIDTH-1:0] extra_update;
  pwire [EXTRA_WIDTH-1:0] extra_insert;
  pwire [EXTRA_WIDTH-1:0] extra_dataW;
  
  pwire [3:0] read_cond;
  pwire [3:0] read_indir;
  
  pwire do_save;
  pwire do_saven[2:0];
  //0=save 0
  //1=save 1
  //2=save 1 as second
  pwire has_saved,has_saved_reg;
  pwire [1:0] saved_tk;
  pwire [12:0] saved_addr0; 
  pwire [1:0] saved_addr1;
  pwire [1:0] saved_use;  
  pwire [1:0] sve_j0; 
  pwire [1:0] sve_j1; 
  pwire [1:0] sve_j2; 
  pwire [1:0] sve_j3; 

  pwire [9:0] write_addr;

  pwire init;
  pwire [8:0] init_count;
  pwire [8:0] init_next;

  pwire [12:0] update_addr0_reg;
  pwire [12:0] update_addr1_reg;
  pwire update_en_reg,update_en_reg2;
  pwire [1:0] update_taken_reg;
  pwire [1:0] update_use_reg;
 
  pwire [4:1] readx_jln0; 
  pwire [4:1] readx_jln1; 
  pwire [4:1] readx_jln2; 
  pwire [4:1] readx_jln3; 
  pwire [4:0] readx_fjln0; 
  pwire [4:0] readx_fjln1; 
  pwire [4:0] readx_fjln2; 
  pwire [4:0] readx_fjln3; 
  pwire [4:0] readx_fjlnx0; 
  pwire [4:0] readx_fjlnx1; 
  pwire [4:0] readx_fjlnx2; 
  pwire [4:0] readx_fjlnx3; 
  pwire [4:1] writex_jln0; 
  pwire [4:1] writex_jln1; 
  pwire [4:1] writex_jln2; 
  pwire [4:1] writex_jln3; 
  pwire [4:0] writex_fjln0; 
  pwire [4:0] writex_fjln1; 
  pwire [4:0] writex_fjln2; 
  pwire [4:0] writex_fjln3; 
  pwire [4:0] writex_fjlnx0; 
  pwire [4:0] writex_fjlnx1; 
  pwire [4:0] writex_fjlnx2; 
  pwire [4:0] writex_fjlnx3; 
  
  pwire write_LRU;
  pwire [9:0] update_addr_reg;

  pwire write_wen_reg;
  pwire write_insert_reg;
//  pwire write_wen_reg2;
//  pwire write_insert_reg2;
  pwire [3:0] taken_reg;
  pwire read_clkEn_reg;
  pwire write_LRU_reg;

  pwire lnoff0;
  pwire oen;
  pwire oenn;
  pwire j0_afterW,j1_afterW,j2_afterW,j3_afterW;
  
  pwire [3:0] write_off0_rex;
  pwire [3:0] write_off1_rex;
  pwire [3:0] write_off2_rex;
  pwire [3:0] write_off3_rex;
  pwire [3:0] write_cond_rex;
  pwire [3:0] write_indir_rex;
  pwire [4:0] write_link0_rex;
  pwire [4:0] write_lnpos0_rex;
  pwire [4:0] write_ljpos0_rex;
  pwire [4:0] write_link1_rex;
  pwire [4:0] write_lnpos1_rex;
  pwire [4:0] write_ljpos1_rex;
  pwire [4:0] write_link2_rex;
  pwire [4:0] write_lnpos2_rex;
  pwire [4:0] write_ljpos2_rex;
  pwire [4:0] write_link3_rex;
  pwire [4:0] write_lnpos3_rex;
  pwire [4:0] write_ljpos3_rex;
  pwire write_way_rex;
  
  pwire read_clkEn_reg2;
  
  
  assign oen=nextIP_reg[14]==HALF && ~read_write_fwd;
  assign scupd_hit=scupd_addr[0]==WAY && scupd_addr[10:1]==IP_wbits && scupd_en;
  
  assign IP_wbits=nextIP_reg[14:5];
  
  assign sc0P=(scupd_hit && scupd_addr[12:11]==2'd0) ? scupd_sc0 : extra_data[`btbExtra_satCount0];
  assign sc1P=(scupd_hit && scupd_addr[12:11]==2'd1) ? scupd_sc1 : extra_data[`btbExtra_satCount1];
  assign sc2P=(scupd_hit && scupd_addr[12:11]==2'd2) ? scupd_sc2 : extra_data[`btbExtra_satCount2];
  assign sc3P=(scupd_hit && scupd_addr[12:11]==2'd3) ? scupd_sc3 : extra_data[`btbExtra_satCount3];
    
  assign do_save=upd_eq0 & update_use_reg[0] & upd_eq1 & update_use_reg[1]
    & ~upd_eq01 || (upd_eq0 & update_use_reg[0] || upd_eq1 & update_use_reg[1])
    & has_saved;
    
  assign do_saven[0]=has_saved & upd_eq0 & update_use_reg[0];
  assign do_saven[1]=upd_eq0 & update_use_reg[0] & upd_eq1 & update_use_reg[1]
    & ~upd_eq01 & ~has_saved || has_saved & ~(update_use_reg[0] & upd_eq0) &
    update_use_reg[1] & upd_eq1;
  assign do_saven[2]=upd_eq0 & update_use_reg[0] & upd_eq1 & update_use_reg[1]
    & upd_eq01 & has_saved;
     
  assign upd_eq0=update_addr0_reg[0] == WAY;
  assign upd_eq1=update_addr1_reg[0] == WAY;
  
  assign upd_eq01=update_addr0_reg[10:0]==update_addr1_reg[10:0];
  
  assign upd_id0=upd_eq0 & update_use_reg[0] & ~has_saved;
  assign upd_id1=upd_eq1 && ~upd_id0 | upd_eq01 
    && update_use_reg[1] && ~has_saved;
  assign upd_idS=has_saved;
  
  assign upd_j0[0]=~has_saved && update_use_reg[0] && update_addr0_reg[12:11]==2'd0 && ~update_dis[0];
  assign upd_j0[1]=~has_saved && update_use_reg[1] && update_addr1_reg[12:11]==2'd0 && ~update_dis[1];

  assign upd_j1[0]=~has_saved && update_use_reg[0] && update_addr0_reg[12:11]==2'd1 && ~update_dis[0];
  assign upd_j1[1]=~has_saved && update_use_reg[1] && update_addr1_reg[12:11]==2'd1 && ~update_dis[1];

  assign upd_j2[0]=~has_saved && update_use_reg[0] && update_addr0_reg[12:11]==2'd2 && ~update_dis[0];
  assign upd_j2[1]=~has_saved && update_use_reg[1] && update_addr1_reg[12:11]==2'd2 && ~update_dis[1];

  assign upd_j3[0]=~has_saved && update_use_reg[0] && update_addr0_reg[12:11]==2'd3 && ~update_dis[0];
  assign upd_j3[1]=~has_saved && update_use_reg[1] && update_addr1_reg[12:11]==2'd3 && ~update_dis[1];

  assign update_addr_new=( upd_id0 & ~init) ? update_addr0_reg[10:1] : 10'bz;
  assign update_addr_new=( upd_id1 & ~init) ? update_addr1_reg[10:1] : 10'bz;
  assign update_addr_new=( upd_idS & ~init) ? saved_addr0[10:1] : 10'bz;
  assign update_addr_new=( ~upd_id0 && ~upd_id1 &&~upd_idS && ~init )
    ? 10'b0 : 10'bz;
  assign update_addr_new= init ? {1'b0,init_count} : 10'bz;
  
  assign update_addr=update_addr_new;
  
  assign upd_taken[0]=|(upd_j0 & update_taken_reg);
  assign upd_taken[1]=|(upd_j1 & update_taken_reg);
  assign upd_taken[2]=|(upd_j2 & update_taken_reg);
  assign upd_taken[3]=|(upd_j3 & update_taken_reg);
    
  assign upd_freq0=extra_dataU[`btbExtra_freq0];
  assign upd_freq1=extra_dataU[`btbExtra_freq1];
  assign upd_freq2=extra_dataU[`btbExtra_freq2];
  assign upd_freq3=extra_dataU[`btbExtra_freq3];

  assign upd_sc0=extra_dataU[`btbExtra_satCount0];
  assign upd_sc1=extra_dataU[`btbExtra_satCount1];
  assign upd_sc2=extra_dataU[`btbExtra_satCount2];
  assign upd_sc3=extra_dataU[`btbExtra_satCount3];

  assign read_freq0=extra_data[`btbExtra_freq0];
  assign read_freq1=extra_data[`btbExtra_freq1];
  assign read_freq2=extra_data[`btbExtra_freq2];
  assign read_freq3=extra_data[`btbExtra_freq3];
  
  
  assign extra_update[`btbExtra_freq0]=|upd_j0_reg ? updW_freq0 : 7'bz; 
  assign extra_update[`btbExtra_freq1]=|upd_j1_reg ? updW_freq1 : 7'bz; 
  assign extra_update[`btbExtra_freq2]=|upd_j2_reg ? updW_freq2 : 7'bz; 
  assign extra_update[`btbExtra_freq3]=|upd_j3_reg ? updW_freq3 : 7'bz; 

  assign extra_update[`btbExtra_freq0]=|sve_j0 ? updS_freq0 : 7'bz; 
  assign extra_update[`btbExtra_freq1]=|sve_j1 ? updS_freq1 : 7'bz; 
  assign extra_update[`btbExtra_freq2]=|sve_j2 ? updS_freq2 : 7'bz; 
  assign extra_update[`btbExtra_freq3]=|sve_j3 ? updS_freq3 : 7'bz; 

  assign extra_update[`btbExtra_freq0]=(!|upd_j0_reg && !|sve_j0) ? upd_freq0 : 7'bz; 
  assign extra_update[`btbExtra_freq1]=(!|upd_j1_reg && !|sve_j1) ? upd_freq1 : 7'bz; 
  assign extra_update[`btbExtra_freq2]=(!|upd_j2_reg && !|sve_j2) ? upd_freq2 : 7'bz; 
  assign extra_update[`btbExtra_freq3]=(!|upd_j3 && !|sve_j3) ? upd_freq3 : 7'bz; 

  assign extra_update[`btbExtra_satCount0]=|upd_j0_reg ? updW_sc0 : 2'bz; 
  assign extra_update[`btbExtra_satCount1]=|upd_j1_reg ? updW_sc1 : 2'bz; 
  assign extra_update[`btbExtra_satCount0]=|upd_j2_reg ? updW_sc2 : 2'bz; 
  assign extra_update[`btbExtra_satCount0]=|upd_j3_reg ? updW_sc3 : 2'bz; 

  assign extra_update[`btbExtra_satCount0]=|sve_j0 ? updS_sc0 : 2'bz; 
  assign extra_update[`btbExtra_satCount1]=|sve_j1 ? updS_sc1 : 2'bz; 
  assign extra_update[`btbExtra_satCount0]=|sve_j2 ? updS_sc2 : 2'bz; 
  assign extra_update[`btbExtra_satCount0]=|sve_j3 ? updS_sc3 : 2'bz; 

  assign extra_update[`btbExtra_satCount0]=(!|upd_j0_reg && !|sve_j0) ? upd_sc0 : 2'bz; 
  assign extra_update[`btbExtra_satCount1]=(!|upd_j1_reg && !|sve_j1) ? upd_sc1 : 2'bz; 
  assign extra_update[`btbExtra_satCount2]=(!|upd_j2_reg && !|sve_j2) ? upd_sc2 : 2'bz; 
  assign extra_update[`btbExtra_satCount3]=(!|upd_j3_reg && !|sve_j3) ? upd_sc3 : 2'bz; 

  assign extra_dataW=(write_insert|init) ? extra_insert : extra_update; 
//  assign write_data=init ? {DATA_WIDTH{1'B0}} : write_dataW;

  assign extra_insert[`btbExtra_freq0]=7'b0; 
  assign extra_insert[`btbExtra_freq1]=7'b0; 
  assign extra_insert[`btbExtra_freq2]=7'b0; 
  assign extra_insert[`btbExtra_freq3]=7'b0; 

  assign extra_insert[`btbExtra_satCount0]={2{~write_cond[0]}}|write_init0; 
  assign extra_insert[`btbExtra_satCount1]={2{~write_cond[1]}}|write_init1; 
  assign extra_insert[`btbExtra_satCount2]={2{~write_cond[2]}}|write_init2; 
  assign extra_insert[`btbExtra_satCount3]={2{~write_cond[3]}}|write_init3; 

  assign read_src=btb_data[`btb_src_IP];
  assign read_tgt0=btb_data[`btb_tgt_IP1];
  assign read_tgt1=btb_data[`btb_tgt_IP1];
  assign read_tgt2=btb_data[`btb_tgt_IP2];
  assign read_tgt3=btb_data[`btb_tgt_IP3];
  assign read_attr0=btb_data[`btb_attr0];
  assign read_attr1=btb_data[`btb_attr1];
  assign read_attr2=btb_data[`btb_attr2];
  assign read_attr3=btb_data[`btb_attr3];
  assign read_valid=btb_data[`btb_valid];
  assign read_off0=btb_data[`btb_off0];
  assign read_off1=btb_data[`btb_off1];
  assign read_off2=btb_data[`btb_off2];
  assign read_off3=btb_data[`btb_off3];
  assign read_cond=btb_data[`btb_cond];
  assign read_indir=btb_data[`btb_indir];
  assign read_link0=btb_data[`btb_link0];
  assign read_lnpos0=btb_data[`btb_lnkoff0];
  assign read_link1=btb_data[`btb_link1];
  assign read_lnpos1=btb_data[`btb_lnkoff1];
  assign read_link2=btb_data[`btb_link2];
  assign read_lnpos2=btb_data[`btb_lnkoff2];
  assign read_link3=btb_data[`btb_link3];
  assign read_lnpos3=btb_data[`btb_lnkoff3];
  assign read_LRU=btb_data[`btb_LRU];
  assign read_jmask0=btb_data[`btb_tgt_jmask0];
  assign read_jmask1=btb_data[`btb_tgt_jmask1];
  assign read_jmask2=btb_data[`btb_tgt_jmask2];
  assign read_jmask3=btb_data[`btb_tgt_jmask3];
  
  assign write_dataW[`btb_tgt_IP0]=tgt0I;
  assign write_dataW[`btb_tgt_IP1]=tgt1I;
  assign write_dataW[`btb_tgt_IP2]=tgt2I;
  assign write_dataW[`btb_tgt_IP3]=tgt3I;
  assign write_dataW[`btb_attr0]={attr0I[3],attr0I[1:0]};
  assign write_dataW[`btb_attr1]={attr1I[3],attr1I[1:0]};
  assign write_dataW[`btb_attr2]={attr2I[3],attr2I[1:0]};
  assign write_dataW[`btb_attr3]={attr3I[3],attr3I[1:0]};
  assign write_dataW[`btb_src_IP]=nextIP_reg[43:15];
  assign write_dataW[`btb_off0]=write_off0_rex;
  assign write_dataW[`btb_off1]=write_off1_rex;
  assign write_dataW[`btb_off2]=write_off2_rex;
  assign write_dataW[`btb_off3]=write_off3_rex;
  assign write_dataW[`btb_valid]=1'b1;
  assign write_dataW[`btb_cond]=write_cond_rex;
  assign write_dataW[`btb_indir]=write_indir_rex;
  assign write_dataW[`btb_link0]=write_link0_rex;
  assign write_dataW[`btb_lnkoff0]=write_lnpos0_rex;
  assign write_dataW[`btb_link1]=write_link1_rex;
  assign write_dataW[`btb_lnkoff1]=write_lnpos1_rex;
  assign write_dataW[`btb_link2]=write_link2_rex;
  assign write_dataW[`btb_lnkoff2]=write_lnpos2_rex;
  assign write_dataW[`btb_link3]=write_link3_rex;
  assign write_dataW[`btb_lnkoff3]=write_lnpos3_rex;
  assign write_dataW[`btb_LRU]=write_LRU;
  assign write_dataW[`btb_tgt_jmask0]=4'b0;//should be 4'hf, but now zero for testing
  assign write_dataW[`btb_tgt_jmask1]=4'b0;
  assign write_dataW[`btb_tgt_jmask2]=4'b0;
  assign write_dataW[`btb_tgt_jmask3]=4'b0;
  
  assign IP_match=pwh#(32)::cmpEQ(read_src,nextIP_reg[43:15]);
  assign read_hit=IP_match && read_valid && ~init && pwh#(1)::cmpEQ(HALF,nextIP_reg[14]);
  
  assign way_hit=oen ? read_LRU : 1'bz;
  
  assign tgt0O=(oen) ? read_tgt0 : {TGTIP_WIDTH-1{1'BZ}};
  assign tgt1O=(oen) ? read_tgt1 : {TGTIP_WIDTH-1{1'BZ}};
  assign tgt2O=(oen) ? read_tgt2 : {TGTIP_WIDTH-1{1'BZ}};
  assign tgt3O=(oen) ? read_tgt3 : {TGTIP_WIDTH-1{1'BZ}};

  assign attr0O=(oen) ? {read_attr0[2],1'b0,read_attr0[1:0]} : 4'bz;
  assign attr1O=(oen) ? {read_attr1[2],1'b0,read_attr1[1:0]} : 4'bz;
  assign attr2O=(oen) ? {read_attr2[2],1'b0,read_attr2[1:0]} : 4'bz;
  assign attr3O=(oen) ? {read_attr3[2],1'b0,read_attr3[1:0]} : 4'bz;
  
  assign way=oen ? WAY : 1'bz;
  
  assign has0=oen ? read_off0!=4'hf : 1'bz;
  assign has1=oen ? read_off1!=4'hf : 1'bz;
  assign has2=oen ? read_off2!=4'hf : 1'bz;
  assign has3=oen ? read_off3!=4'hf : 1'bz;

  assign off0=oen ? read_off0 : 4'bz;
  assign off1=oen ? read_off1 : 4'bz;
  assign off2=oen ? read_off2 : 4'bz;
  assign off3=oen ? read_off3 : 4'bz;

  assign tbuf_pred[0]=oen ? ~read_freq0[6] | ~read_cond[0] : 1'bz;
  assign tbuf_pred[1]=oen ? ~read_freq1[6] | ~read_cond[1] : 1'bz;
  assign tbuf_pred[2]=oen ? ~read_freq2[6] | ~read_cond[2] : 1'bz;
  assign tbuf_pred[3]=oen ? ~read_freq3[6] | ~read_cond[3] : 1'bz;

  assign jmp_mask0=oen ? read_jmask0 : 4'bz;
  assign jmp_mask1=oen ? read_jmask1 : 4'bz;
  assign jmp_mask2=oen ? read_jmask2 : 4'bz;
  assign jmp_mask3=oen ? read_jmask3 : 4'bz;

  assign cond=oen ? read_cond : 4'bz;
  
  assign indir=oen ? read_indir : 4'bz;
  assign link0=oen ? read_link0 : 5'bz;
  assign lnpos0=oen ? read_lnpos0 : 5'bz;
  assign link1=oen ? read_link1 : 5'bz;
  assign lnpos1=oen ? read_lnpos1 : 5'bz;
  assign link2=oen ? read_link2 : 5'bz;
  assign lnpos2=oen ? read_lnpos2 : 5'bz;
  assign link3=oen ? read_link3 : 5'bz;
  assign lnpos3=oen ? read_lnpos3 : 5'bz;
  
  assign ljpos3=oen ? readx_fjln3 : 5'bz;
  assign ljpos2=oen ? readx_fjln2 : 5'bz;
  assign ljpos1=oen ? readx_fjln1 : 5'bz;
 
  assign ljpos0=oen ? readx_fjln0 : 5'bz;
  
  assign ljpos3=read_write_fwd ? writex_fjln3 : 5'bz;
  assign ljpos2=read_write_fwd ? writex_fjln2 : 5'bz;
  assign ljpos1=read_write_fwd ? writex_fjln1 : 5'bz;
 
  assign ljpos0=read_write_fwd ? writex_fjln0 : 5'bz;


  get_carry #(4) cmpJL00_mod(read_off0,~read_lnpos0[3:0],1'b1,readx_jln0[1]); 
  get_carry #(4) cmpJL01_mod(read_off1,~read_lnpos0[3:0],1'b1,readx_jln0[2]); 
  get_carry #(4) cmpJL02_mod(read_off2,~read_lnpos0[3:0],1'b1,readx_jln0[3]); 
  get_carry #(4) cmpJL03_mod(read_off3,~read_lnpos0[3:0],1'b1,readx_jln0[4]);

  get_carry #(4) cmpJL10_mod(read_off0,~read_lnpos1[3:0],1'b1,readx_jln1[1]); 
  get_carry #(4) cmpJL11_mod(read_off1,~read_lnpos1[3:0],1'b1,readx_jln1[2]); 
  get_carry #(4) cmpJL12_mod(read_off2,~read_lnpos1[3:0],1'b1,readx_jln1[3]); 
  get_carry #(4) cmpJL13_mod(read_off3,~read_lnpos1[3:0],1'b1,readx_jln1[4]);

  get_carry #(4) cmpJL20_mod(read_off0,~read_lnpos2[3:0],1'b1,readx_jln2[1]); 
  get_carry #(4) cmpJL21_mod(read_off1,~read_lnpos2[3:0],1'b1,readx_jln2[2]); 
  get_carry #(4) cmpJL22_mod(read_off2,~read_lnpos2[3:0],1'b1,readx_jln2[3]); 
  get_carry #(4) cmpJL23_mod(read_off3,~read_lnpos2[3:0],1'b1,readx_jln2[4]);

  get_carry #(4) cmpJL30_mod(read_off0,~read_lnpos3[3:0],1'b1,readx_jln3[1]); 
  get_carry #(4) cmpJL31_mod(read_off1,~read_lnpos3[3:0],1'b1,readx_jln3[2]); 
  get_carry #(4) cmpJL32_mod(read_off2,~read_lnpos3[3:0],1'b1,readx_jln3[3]); 
  get_carry #(4) cmpJL33_mod(read_off3,~read_lnpos3[3:0],1'b1,readx_jln3[4]);

  bit_find_last_bit #(4) fnd0_mod(~readx_jln0,readx_fjlnx0[4:1],readx_fjlnx0[0]);
  assign readx_fjln0={readx_fjlnx0[4:1],~readx_fjlnx0[0]};

  bit_find_last_bit #(4) fnd1_mod(~readx_jln1,readx_fjlnx1[4:1],readx_fjlnx1[0]);
  assign readx_fjln1={readx_fjlnx1[4:1],~readx_fjlnx1[0]};

  bit_find_last_bit #(4) fnd2_mod(~readx_jln2,readx_fjlnx2[4:1],readx_fjlnx2[0]);
  assign readx_fjln2={readx_fjlnx2[4:1],~readx_fjlnx2[0]};

  bit_find_last_bit #(4) fnd3_mod(~readx_jln3,readx_fjlnx3[4:1],readx_fjlnx3[0]);
  assign readx_fjln3={readx_fjlnx3[4:1],~readx_fjlnx3[0]};

  get_carry #(4) wcmpJL00_mod(write_off0_rex,~write_lnpos0_rex[3:0],1'b1,writex_jln0[1]); 
  get_carry #(4) wcmpJL01_mod(write_off1_rex,~write_lnpos0_rex[3:0],1'b1,writex_jln0[2]); 
  get_carry #(4) wcmpJL02_mod(write_off2_rex,~write_lnpos0_rex[3:0],1'b1,writex_jln0[3]); 
  get_carry #(4) wcmpJL03_mod(write_off3_rex,~write_lnpos0_rex[3:0],1'b1,writex_jln0[4]);

  get_carry #(4) wcmpJL10_mod(write_off0_rex,~write_lnpos1_rex[3:0],1'b1,writex_jln1[1]); 
  get_carry #(4) wcmpJL11_mod(write_off1_rex,~write_lnpos1_rex[3:0],1'b1,writex_jln1[2]); 
  get_carry #(4) wcmpJL12_mod(write_off2_rex,~write_lnpos1_rex[3:0],1'b1,writex_jln1[3]); 
  get_carry #(4) wcmpJL13_mod(write_off3_rex,~write_lnpos1_rex[3:0],1'b1,writex_jln1[4]);

  get_carry #(4) wcmpJL20_mod(write_off0_rex,~write_lnpos2_rex[3:0],1'b1,writex_jln2[1]); 
  get_carry #(4) wcmpJL21_mod(write_off1_rex,~write_lnpos2_rex[3:0],1'b1,writex_jln2[2]); 
  get_carry #(4) wcmpJL22_mod(write_off2_rex,~write_lnpos2_rex[3:0],1'b1,writex_jln2[3]); 
  get_carry #(4) wcmpJL23_mod(write_off3_rex,~write_lnpos2_rex[3:0],1'b1,writex_jln2[4]);

  get_carry #(4) wcmpJL30_mod(write_off0_rex,~write_lnpos3_rex[3:0],1'b1,writex_jln3[1]); 
  get_carry #(4) wcmpJL31_mod(write_off1_rex,~write_lnpos3_rex[3:0],1'b1,writex_jln3[2]); 
  get_carry #(4) wcmpJL32_mod(write_off2_rex,~write_lnpos3_rex[3:0],1'b1,writex_jln3[3]); 
  get_carry #(4) wcmpJL33_mod(write_off3_rex,~write_lnpos3_rex[3:0],1'b1,writex_jln3[4]);

  bit_find_last_bit #(4) wfnd0_mod(~writex_jln0,writex_fjlnx0[4:1],writex_fjlnx0[0]);
  assign writex_fjln0={writex_fjlnx0[4:1],~writex_fjlnx0[0]};

  bit_find_last_bit #(4) wfnd1_mod(~writex_jln1,writex_fjlnx1[4:1],writex_fjlnx1[0]);
  assign writex_fjln1={writex_fjlnx1[4:1],~writex_fjlnx1[0]};

  bit_find_last_bit #(4) wfnd2_mod(~writex_jln2,writex_fjlnx2[4:1],writex_fjlnx2[0]);
  assign writex_fjln2={writex_fjlnx2[4:1],~writex_fjlnx2[0]};

  bit_find_last_bit #(4) wfnd3_mod(~writex_jln3,writex_fjlnx3[4:1],writex_fjlnx3[0]);
  assign writex_fjln3={writex_fjlnx3[4:1],~writex_fjlnx3[0]};

  assign jmp_mask[0]=oen ? j0_after && read_off0!=4'hf : 1'bz;
  assign jmp_mask[1]=oen ? j1_after && read_off1!=4'hf : 1'bz;
  assign jmp_mask[2]=oen ? j2_after && read_off2!=4'hf : 1'bz;
  assign jmp_mask[3]=oen ? j3_after && read_off3!=4'hf : 1'bz;
  
  assign sc0=oen ? sc0P | {1'b0,~read_cond[0]} : 2'bz;
  assign sc1=oen ? sc1P | {1'b0,~read_cond[1]} : 2'bz;
  assign sc2=oen ? sc2P | {1'b0,~read_cond[2]} : 2'bz;
  assign sc3=oen ? sc3P | {1'b0,~read_cond[3]} : 2'bz;

//  assign read_LRU_hit=read_hit ? read_LRU : 1'bz;
  //

  assign way=(read_write_fwd & HALF) ? WAY : 1'bz;
  
  assign has0=(read_write_fwd & HALF) ? write_off0_rex!=4'hf : 1'bz;
  assign has1=(read_write_fwd & HALF) ? write_off1_rex!=4'hf : 1'bz;
  assign has2=(read_write_fwd & HALF) ? write_off2_rex!=4'hf : 1'bz;
  assign has3=(read_write_fwd & HALF) ? write_off3_rex!=4'hf : 1'bz;

  assign off0=(read_write_fwd & HALF) ? write_off0_rex : 4'bz;
  assign off1=(read_write_fwd & HALF) ? write_off1_rex : 4'bz;
  assign off2=(read_write_fwd & HALF) ? write_off2_rex : 4'bz;
  assign off3=(read_write_fwd & HALF) ? write_off3_rex : 4'bz;

  assign tbuf_pred[0]=(read_write_fwd & HALF) ? 1'b1 : 1'bz;
  assign tbuf_pred[1]=(read_write_fwd & HALF) ? 1'b1 : 1'bz;
  assign tbuf_pred[2]=(read_write_fwd & HALF) ? 1'b1 : 1'bz;
  assign tbuf_pred[3]=(read_write_fwd & HALF) ? 1'b1 : 1'bz;

  assign cond=(read_write_fwd & HALF) ? write_cond_rex : 4'bz;
  
  assign indir=(read_write_fwd & HALF) ? write_indir_rex : 4'bz;
  assign link0=(read_write_fwd & HALF) ? write_link0_rex : 5'bz;
  assign lnpos0=(read_write_fwd & HALF) ? write_lnpos0_rex : 5'bz;
  assign link1=(read_write_fwd & HALF) ? write_link1_rex : 5'bz;
  assign lnpos1=(read_write_fwd & HALF) ? write_lnpos1_rex : 5'bz;
  assign link2=(read_write_fwd & HALF) ? write_link2_rex : 5'bz;
  assign lnpos2=(read_write_fwd & HALF) ? write_lnpos2_rex : 5'bz;
  assign link3=(read_write_fwd & HALF) ? write_link3_rex : 5'bz;
  assign lnpos3=(read_write_fwd & HALF) ? write_lnpos3_rex : 5'bz;
 
  assign jmp_mask[0]=(read_write_fwd & HALF) ? j0_afterW && write_off0_rex!=4'hf : 1'bz;
  assign jmp_mask[1]=(read_write_fwd & HALF) ? j1_afterW && write_off1_rex!=4'hf : 1'bz;
  assign jmp_mask[2]=(read_write_fwd & HALF) ? j2_afterW && write_off2_rex!=4'hf : 1'bz;
  assign jmp_mask[3]=(read_write_fwd & HALF) ? j3_afterW && write_off3_rex!=4'hf : 1'bz;
  
  assign sc0=(read_write_fwd & HALF) ? {2{write_cond_rex[0]}} : 2'bz;
  assign sc1=(read_write_fwd & HALF) ? {2{write_cond_rex[1]}} : 2'bz;
  assign sc2=(read_write_fwd & HALF) ? {2{write_cond_rex[2]}} : 2'bz;
  assign sc3=(read_write_fwd & HALF) ? {2{write_cond_rex[3]}} : 2'bz;

//  assign read_LRU_hit=read_hit ? read_LRU : 1'bz;
  
  assign ram_wen=write_wen & read_hit || write_insert & (pwh#(32)::cmpEQ(write_way,WAY)) || 
    (mStall && ~write_wen && ~write_insert && taken_reg!=0 && ~except_reg) || except_reg & except_indir_reg & 
    (update_taken_reg[0] ? update_addr0_reg[0]==WAY : update_addr1_reg[0]==WAY && update_taken_reg[1]);

  assign write_data=(write_insert|write_wen && ~init) ? write_dataW : 'z;
  assign write_data=(~write_insert & ~write_wen & ~init) ? {write_LRU_reg,write_dataJ} : 'z;
  assign write_data=init ? {WAY,{DATA_WIDTH-1{1'B0}}} : 'z;

//up to here.
//dataJ includes taken and computed jmask.
  assign sve_j0[0]=has_saved && saved_addr0[12:11]==2'd0 && saved_use[0];    
  assign sve_j0[1]=has_saved && pwh#(2)::cmpEQ(saved_addr1,2'd0) && saved_use[1];    

  assign sve_j1[0]=has_saved && saved_addr0[12:11]==2'd1 && saved_use[0];    
  assign sve_j1[1]=has_saved && pwh#(2)::cmpEQ(saved_addr1,2'd1) && saved_use[1];    

  assign sve_j2[0]=has_saved && saved_addr0[12:11]==2'd2 && saved_use[0];    
  assign sve_j2[1]=has_saved && pwh#(2)::cmpEQ(saved_addr1,2'd2) && saved_use[1];    

  assign sve_j3[0]=has_saved && saved_addr0[12:11]==2'd3 && saved_use[0];    
  assign sve_j3[1]=has_saved && pwh#(2)::cmpEQ(saved_addr1,2'd3) && saved_use[1];    

  assign sve_taken[0]=|(sve_j0 & saved_tk);
  assign sve_taken[1]=|(sve_j1 & saved_tk);
  assign sve_taken[2]=|(sve_j2 & saved_tk);
  assign sve_taken[3]=|(sve_j3 & saved_tk);

  assign write_addr=(~init  & ~mStall) ? IP_wbits : 10'bz;
  assign write_addr=init ? {1'b0,init_count} : 10'bz;
  assign write_addr=(mStall & ~init) ? IP_wbits_reg : 10'bz;
  
  always @* begin
      ioen=15;
      write_dataJ=btb_data_reg[`btb_width-2:0];
       //verilator lint_off CASEINCOMPLETE
      case({except_reg,taken_reg})
      5'b1: write_dataJ[`btb_tgt_jmask0]=jmp_mask_in;
      5'b10: write_dataJ[`btb_tgt_jmask1]=jmp_mask_in;
      5'b100: write_dataJ[`btb_tgt_jmask2]=jmp_mask_in;
      5'b1000: write_dataJ[`btb_tgt_jmask3]=jmp_mask_in;
      default: begin
          case(update_taken_reg[0] ? update_addr0_reg[12:11] : update_addr1_reg[12:11])
          2'd0: begin write_dataJ[`btb_tgt_IP0]=nextIP_reg[63:1]; ioen=1; end
          2'd1: begin write_dataJ[`btb_tgt_IP1]=nextIP_reg[63:1]; ioen=2; end
          2'd2: begin write_dataJ[`btb_tgt_IP2]=nextIP_reg[63:1]; ioen=4; end
          2'd3: begin write_dataJ[`btb_tgt_IP3]=nextIP_reg[63:1]; ioen=8; end
          endcase
      end
      endcase
       //verilator lint_on CASEINCOMPLETE
  end
  reg[3:0]ioen;
  tbuf_ram_block tbuf_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(nextIP[13:5]),
  .read_data(btb_data),
  .write_addr(except_indir_reg ? update_addr_reg[8:0] : write_addr[8:0]),
  .write_data(write_data),
  .write_wen((ram_wen&&write_addr[9]==HALF)|init),
  .ioen(ioen),
  .indiren({4{except_indir_reg}}&ioen)
  );
  
  tbufExtra_ram ex0_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(read_clkEn),
  .read_addr(nextIP[13:5]),
  .read_data(extra_data),
  .write_addr(write_insert ? IP_wbits[8:0] : update_addr_reg[8:0]),
  .write_data(extra_dataW),
  .write_wen(((update_en_reg2|has_saved_reg&&update_addr_reg[9]==HALF)|
    (write_insert&&pwh#(32)::cmpEQ(write_way,WAY)&&IP_wbits[9]==HALF))||init)
  );

  tbufExtra_ram ex1_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(update_en_reg | has_saved),
  .read_addr(update_addr[8:0]),
  .read_data(extra_dataU),
  .write_addr(write_insert ? IP_wbits[8:0] : update_addr_reg[8:0]),
  .write_data(extra_dataW),
  .write_wen(((update_en_reg2|has_saved_reg&&update_addr_reg[9]==HALF)|
      (write_insert&&pwh#(32)::cmpEQ(write_way,WAY)&&IP_wbits[9]==HALF))||init)
  );

  freq_update fq0_mod(upd_freq0,updW_freq0);
  freq_update fq1_mod(upd_freq1,updW_freq1);
  freq_update fq2_mod(upd_freq2,updW_freq2);
  freq_update fq3_mod(upd_freq3,updW_freq3);


  sc_update sc0_mod(upd_sc0,upd_taken_reg[0],updW_sc0);
  sc_update sc1_mod(upd_sc1,upd_taken_reg[1],updW_sc1);
  sc_update sc2_mod(upd_sc2,upd_taken_reg[2],updW_sc2);
  sc_update sc3_mod(upd_sc3,upd_taken_reg[3],updW_sc3);


  freq_update fqS0_mod(upd_freq0,updS_freq0);
  freq_update fqS1_mod(upd_freq1,updS_freq1);
  freq_update fqS2_mod(upd_freq2,updS_freq2);
  freq_update fqS3_mod(upd_freq3,updS_freq3);


  sc_update scS0_mod(upd_sc0,sve_taken[0],updS_sc0);
  sc_update scS1_mod(upd_sc1,sve_taken[1],updS_sc1);
  sc_update scS2_mod(upd_sc2,sve_taken[2],updS_sc2);
  sc_update scS3_mod(upd_sc3,sve_taken[3],updS_sc3);

  sc_update wbsc0_mod(extra_data[`btbExtra_satCount0],scupd_taken,scupd_sc0);
  sc_update wbsc1_mod(extra_data[`btbExtra_satCount1],scupd_taken,scupd_sc1);
  sc_update wbsc2_mod(extra_data[`btbExtra_satCount2],scupd_taken,scupd_sc2);
  sc_update wbsc3_mod(extra_data[`btbExtra_satCount3],scupd_taken,scupd_sc3);
    
    
  get_carry #(4) cj0_mod(~nextIP_reg[4:1],read_off0,1'b1,j0_after); 
  get_carry #(4) cj1_mod(~nextIP_reg[4:1],read_off1,1'b1,j1_after); 
  get_carry #(4) cj2_mod(~nextIP_reg[4:1],read_off2,1'b1,j2_after); 
  get_carry #(4) cj3_mod(~nextIP_reg[4:1],read_off3,1'b1,j3_after); 

  get_carry #(4) cj0W_mod(~nextIP_reg[4:1],write_off0_rex,1'b1,j0_afterW); 
  get_carry #(4) cj1W_mod(~nextIP_reg[4:1],write_off1_rex,1'b1,j1_afterW); 
  get_carry #(4) cj2W_mod(~nextIP_reg[4:1],write_off2_rex,1'b1,j2_afterW); 
  get_carry #(4) cj3W_mod(~nextIP_reg[4:1],write_off3_rex,1'b1,j3_afterW); 
 
  
  lru_single #(1,WAY) lru_mod(read_LRU,write_LRU,read_LRU_hit,init,read_hit|read_hit_other);
  
  adder_inc #(9) initAdd_mod(init_count,init_next,1'b1,);

  always @(posedge clk)
  begin
      if (rst) begin
          nextIP_reg<={IP_WIDTH-1{1'B0}};
      end else if (read_clkEn) begin
          nextIP_reg<=nextIP;
      end
      if (rst) begin
        has_saved<=1'b0;
        saved_tk<=2'b0;
        saved_use<=2'b0;
        saved_addr0<=13'b0;
        saved_addr1<=2'b0;
      end else begin
//        has_saved<=do_save;
        saved_use<=2'b0;
        saved_tk<=2'b0;
        if (do_saven[0]) begin
          saved_tk[0]<=update_taken_reg[0];
          saved_addr0<=update_addr0_reg;
          saved_use[0]<=1'b1;
          has_saved<=~update_dis[0];
        end
        if (do_saven[1]) begin
          saved_tk[1]<=update_taken_reg[1];
          saved_addr0<=update_addr1_reg;
          saved_use[1]<=1'b1;
          has_saved<=~update_dis[1];
        end
        if (do_saven[2]) begin
          saved_tk[1]<=update_taken_reg[1];
          saved_addr1<=update_addr1_reg[12:11];
          saved_use[1]<=1'b1;
          has_saved<=~update_dis[1];
        end
      end
      if (rst) begin
          update_addr0_reg<=13'b0;
          update_addr1_reg<=13'b0;
          update_en_reg<=1'b0;
          update_taken_reg<=2'b0;
          update_use_reg<=2'b0;
          upd_j0_reg<=2'b0;
          upd_j1_reg<=2'b0;
          upd_j2_reg<=2'b0;
          upd_j3_reg<=2'b0;
          upd_taken_reg<=4'b0;
          update_addr_reg<=10'b0;
          update_en_reg2<=1'b0;
          has_saved_reg<=1'b0;
      end else begin
          update_addr0_reg<=update_addr0;
          update_addr1_reg<=update_addr1;
          update_en_reg<=update_en;
          update_taken_reg<=update_taken;
          update_use_reg<=update_use;
          upd_j0_reg<=upd_j0;
          upd_j1_reg<=upd_j1;
          upd_j2_reg<=upd_j2;
          upd_j3_reg<=upd_j3;
          upd_taken_reg<=upd_taken;
          update_addr_reg<=update_addr;
          update_en_reg2<=update_en_reg;
          has_saved_reg<=has_saved;
      end
      if (rst) begin
          init<=1'b1;
          init_count<=9'd0;
      end else if (init) begin
          if (pwh#(9)::cmpEQ(init_count,9'h1ff)) init<=1'b0;
          init_count<=init_next;
      end
      if (rst) begin
          read_clkEn_reg<=1'b0;
          write_wen_reg<=1'b0;
        //  write_wen_reg2<=1'b0;
          write_insert_reg<=1'b0;
        //  write_insert_reg2<=1'b0;
          write_dataW_reg<={DATA_WIDTH{1'B0}};
          btb_data_reg<={DATA_WIDTH{1'B0}};
      //    write_dataW_reg2<={DATA_WIDTH{1'B0}};
          taken_reg<=4'b0;
          write_LRU_reg<=1'b0;
          write_off0_rex<=4'b0;
          write_off1_rex<=4'b0;
          write_off2_rex<=4'b0;
          write_off3_rex<=4'b0;
          write_cond_rex<=4'b0;
          write_indir_rex<=4'b0;
          write_link0_rex<=5'b0;
          write_lnpos0_rex<=5'b0;
          write_link1_rex<=5'b0;
          write_lnpos1_rex<=5'b0;
          write_link2_rex<=5'b0;
          write_lnpos2_rex<=5'b0;
          write_link3_rex<=5'b0;
          write_lnpos3_rex<=5'b0;
          write_way_rex<=1'b0;
          IP_wbits_reg<=10'b0;
      //    read_clkEn_reg2<=1'b0;
      end else begin
          read_clkEn_reg<=read_clkEn;
          write_wen_reg<=write_wen;
//          write_wen_reg2<=write_wen_reg;
          write_insert_reg<=write_insert;
         // write_insert_reg2<=write_insert_reg;
          if (read_clkEn) write_dataW_reg<=write_dataW;
          if (read_clkEn) btb_data_reg<=btb_data;
        //  write_dataW_reg2<=write_dataW_reg;
          if (read_clkEn) taken_reg<=taken;
          write_LRU_reg<=write_LRU;
          if (read_clkEn) begin
              write_off0_rex<=write_off0;
              write_off1_rex<=write_off1;
              write_off2_rex<=write_off2;
              write_off3_rex<=write_off3;
              write_cond_rex<=write_cond;
              write_indir_rex<=write_indir;
              write_link0_rex<=write_link0;
              write_lnpos0_rex<=write_lnpos0;
              write_link1_rex<=write_link1;
              write_lnpos1_rex<=write_lnpos1;
              write_link2_rex<=write_link2;
              write_lnpos2_rex<=write_lnpos2;
              write_link3_rex<=write_link3;
              write_lnpos3_rex<=write_lnpos3;
              write_way_rex<=write_way;
        //      read_clkEn_reg2<=read_clkEn;
          end
          IP_wbits_reg<=IP_wbits;
      end
  end
  
endmodule


module tbuf_way_2(
  clk,
  rst,
  read_clkEn,
  mStall,
  except_reg,
  except_indir_reg,
  nextIP,
  read_hit,
  read_hit_other,
  read_LRU_hit,
  read_write_fwd,
  has0,has1,has2,has3,
  sc0,sc1,sc2,sc3,
  jmp_mask0,jmp_mask1,jmp_mask2,jmp_mask3,jmp_mask,jmp_mask_in,taken,
  tbuf_pred,
  cond,
  indir,
  link0,lnpos0,ljpos0,
  link1,lnpos1,ljpos1,
  link2,lnpos2,ljpos2,
  link3,lnpos3,ljpos3,
  way,way_hit,
  tgt0I,tgt1I,tgt2I,tgt3I,
  tgt0O,tgt1O,tgt2O,tgt3O,
  off0,off1,off2,off3,
  attr0I,attr1I,attr2I,attr3I,
  attr0O,attr1O,attr2O,attr3O,
  write_off0,write_off1,write_off2,write_off3,
  write_cond,
  write_indir,
  write_link0,write_lnpos0,write_init0,
  write_link1,write_lnpos1,write_init1,
  write_link2,write_lnpos2,write_init2,
  write_link3,write_lnpos3,write_init3,
  write_way,
  write_wen,
  write_insert,
  update_addr0,update_addr1,
  update_en, update_taken,
  update_use, update_dis,
  scupd_taken,scupd_en,scupd_addr
  );
  localparam IP_WIDTH=64;
  localparam TGTIP_WIDTH=64;
  localparam HIST_WIDTH=8;
  localparam DATA_WIDTH=`btb_width;
  localparam EXTRA_WIDTH=`btbExtra_width;
  parameter [0:0] WAY=0;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire mStall;
  input pwire except_reg;
  input pwire except_indir_reg;
  input pwire [IP_WIDTH-1:1] nextIP;
  output pwire read_hit;
  input pwire read_hit_other;
  input pwire read_LRU_hit;
  input pwire read_write_fwd;
  output pwire has0,has1,has2,has3;
  output pwire [1:0] sc0;
  output pwire [1:0] sc1;
  output pwire [1:0] sc2;
  output pwire [1:0] sc3;
  output pwire [3:0] jmp_mask0;
  output pwire [3:0] jmp_mask1;
  output pwire [3:0] jmp_mask2;
  output pwire [3:0] jmp_mask3;
  output pwire [3:0] jmp_mask;
  input pwire [3:0]  jmp_mask_in;
  input pwire [3:0] taken;
  output pwire [3:0] tbuf_pred;
  output pwire [3:0] cond;
  output pwire [3:0] indir;
  output pwire [4:0] link0;
  output pwire [4:0] lnpos0;
  output pwire [4:0] ljpos0;
  output pwire [4:0] link1;
  output pwire [4:0] lnpos1;
  output pwire [4:0] ljpos1;
  output pwire [4:0] link2;
  output pwire [4:0] lnpos2;
  output pwire [4:0] ljpos2;
  output pwire [4:0] link3;
  output pwire [4:0] lnpos3;
  output pwire [4:0] ljpos3;
  output pwire way;
  output pwire way_hit;
  input pwire [TGTIP_WIDTH-1:1] tgt0I;
  input pwire [TGTIP_WIDTH-1:1] tgt1I;
  input pwire [TGTIP_WIDTH-1:1] tgt2I;
  input pwire [TGTIP_WIDTH-1:1] tgt3I;
  output pwire [TGTIP_WIDTH-1:1] tgt0O;
  output pwire [TGTIP_WIDTH-1:1] tgt1O;
  output pwire [TGTIP_WIDTH-1:1] tgt2O;
  output pwire [TGTIP_WIDTH-1:1] tgt3O;
  output pwire [3:0] off0;
  output pwire [3:0] off1;
  output pwire [3:0] off2;
  output pwire [3:0] off3;
  input pwire [3:0] attr0I;
  input pwire [3:0] attr1I;
  input pwire [3:0] attr2I;
  input pwire [3:0] attr3I;
  output pwire [3:0] attr0O;
  output pwire [3:0] attr1O;
  output pwire [3:0] attr2O;
  output pwire [3:0] attr3O;
  input pwire [3:0] write_off0;
  input pwire [3:0] write_off1;
  input pwire [3:0] write_off2;
  input pwire [3:0] write_off3;
  input pwire [3:0] write_init0;
  input pwire [3:0] write_init1;
  input pwire [3:0] write_init2;
  input pwire [3:0] write_init3;
  input pwire [3:0] write_cond;
  input pwire [3:0] write_indir;
  input pwire [4:0] write_link0;
  input pwire [4:0] write_lnpos0;
  input pwire [4:0] write_link1;
  input pwire [4:0] write_lnpos1;
  input pwire [4:0] write_link2;
  input pwire [4:0] write_lnpos2;
  input pwire [4:0] write_link3;
  input pwire [4:0] write_lnpos3;
  input pwire write_way;
  input pwire write_wen;
  input pwire write_insert;  
  input pwire [12:0] update_addr0;
  input pwire [12:0] update_addr1;
  input pwire update_en;
  input pwire [1:0] update_taken;
  input pwire [1:0] update_use;
  input pwire [1:0] update_dis;
  input pwire scupd_taken;
  input pwire scupd_en;
  input pwire [12:0] scupd_addr;
  
  pwire read_hit0;
  pwire read_hit1;
  
  pwire write_way_reg,write_insert_reg,write_wen_reg;
  
  assign read_hit=read_hit0 | read_hit1 | (read_write_fwd && pwh#(32)::cmpEQ(write_way_reg,WAY)) ;
  assign way_hit=read_write_fwd ? pwh#(32)::cmpEQ(write_way_reg,WAY) : 1'bz;


    tbuf_way #(WAY,1'b0) way0(
    clk,
    rst,
    read_clkEn|write_wen|write_insert,
    mStall,
    except_reg,
    except_indir_reg,
    nextIP,
    read_hit0,
    read_hit_other,
    read_LRU_hit,
    read_write_fwd,
    has0,has1,has2,has3,
    sc0,sc1,sc2,sc3,
    jmp_mask0,jmp_mask1,jmp_mask2,jmp_mask3,jmp_mask,jmp_mask_in,taken,
    tbuf_pred,
    cond,
    indir,
    link0,lnpos0,ljpos0,
    link1,lnpos1,ljpos1,
    link2,lnpos2,ljpos2,
    link3,lnpos3,ljpos3,
    way,way_hit,
    tgt0I,tgt1I,tgt2I,tgt3I,
    tgt0O,tgt1O,tgt2O,tgt3O,
    off0,off1,off2,off3,
    attr0I,attr1I,attr2I,attr3I,
    attr0O,attr1O,attr2O,attr3O,
    write_off0,write_off1,write_off2,write_off3,
    write_cond,
    write_indir,
    write_link0,write_lnpos0,write_init0,
    write_link1,write_lnpos1,write_init1,
    write_link2,write_lnpos2,write_init2,
    write_link3,write_lnpos3,write_init3,
    write_way_reg,
    write_wen_reg,
    write_insert_reg,
    update_addr0,update_addr1,
    update_en, update_taken,
    update_use, update_dis,
    scupd_taken,scupd_en,scupd_addr
    );
      tbuf_way #(WAY,1'b1) way1(
      clk,
      rst,
      read_clkEn|write_wen|write_insert,
      mStall,
      except_reg,
      except_indir_reg,
      nextIP,
      read_hit1,read_hit_other,
      read_LRU_hit,
      read_write_fwd,
      has0,has1,has2,has3,
      sc0,sc1,sc2,sc3,
      jmp_mask0,jmp_mask1,jmp_mask2,jmp_mask3,jmp_mask,jmp_mask_in,taken,
      tbuf_pred,
      cond,
      indir,
      link0,lnpos0,ljpos0,
      link1,lnpos1,ljpos1,
      link2,lnpos2,ljpos2,
      link3,lnpos3,ljpos3,
      way,way_hit,
      tgt0I,tgt1I,tgt2I,tgt3I,
      tgt0O,tgt1O,tgt2O,tgt3O,
      off0,off1,off2,off3,
      attr0I,attr1I,attr2I,attr3I,
      attr0O,attr1O,attr2O,attr3O,
      write_off0,write_off1,write_off2,write_off3,
      write_cond,
      write_indir,
      write_link0,write_lnpos0,write_init0,
      write_link1,write_lnpos1,write_init1,
      write_link2,write_lnpos2,write_init2,
      write_link3,write_lnpos3,write_init3,
      write_way_reg,
      write_wen_reg,
      write_insert_reg,
      update_addr0,update_addr1,
      update_en, update_taken,
      update_use, update_dis,
      scupd_taken,scupd_en,scupd_addr
      );
  always @(posedge clk) begin
      if (rst) begin
          write_way_reg<=1'b0;
          write_insert_reg<=1'b0;
          write_wen_reg<=1'b0;
      end else begin
          write_way_reg<=write_way;
          write_insert_reg<=write_insert;
          write_wen_reg<=write_wen;
      end
  end
endmodule

module tbuf(
  clk,
  rst,
  except,
  except_thread,
  except_due_jump,
  except_jmask,
  except_jmask_en,
  except_indir,
  mismatch_stall,
  uxcept,
  read_clkEn,
  nextIP,
  read_hit,
  taken,
  has0,has1,has2,has3,
  sc0A,sc1A,sc2A,sc3A,
  sc0B,sc1B,sc2B,sc3B,
  jump_mask,chk_maskA,chk_maskB,
  jump0_jmask,jump1_jmask,jump2_jmask,jump3_jmask,
  tbuf_predA,tbuf_predB,
  cond,
  indir,
  link0,lnpos0,ljpos0,
  link1,lnpos1,ljpos1,
  link2,lnpos2,ljpos2,
  link3,lnpos3,ljpos3,
  way,
  off0,off1,off2,off3,
  attr0I,attr1I,attr2I,attr3I,
  attr0O,attr1O,attr2O,attr3O,
  tgt0I,tgt1I,tgt2I,tgt3I,
  tgt0O,tgt1O,tgt2O,tgt3O,
  write_off0,write_off1,write_off2,write_off3,
  write_cond,
  write_indir,
  write_link0,write_lnpos0,write_init0,
  write_link1,write_lnpos1,write_init1,
  write_link2,write_lnpos2,write_init2,
  write_link3,write_lnpos3,write_init3,
  write_way,
  write_thread,
  write_wen,
  write_insert,
  write_can,
  write_read_fwd,write_read_lowIP,
  update_addr0,update_addr1,
  update_en, update_taken,
  update_use
  );
  
  localparam IP_WIDTH=64;
  localparam TGTIP_WIDTH=64;
  localparam HIST_WIDTH=8;
  localparam DATA_WIDTH=`btb_width;
  localparam EXTRA_WIDTH=`btbExtra_width;
  
  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire except_thread;
  input pwire except_due_jump;
  input pwire [3:0] except_jmask;
  input pwire except_jmask_en;
  input pwire except_indir;
  input pwire mismatch_stall;
  input pwire uxcept;
  input pwire read_clkEn;
  input pwire [IP_WIDTH-1:1] nextIP;
  output pwire read_hit;
  input pwire [3:0] taken;
  output pwire has0,has1,has2,has3;
  output pwire [1:0] sc0A;
  output pwire [1:0] sc1A;
  output pwire [1:0] sc2A;
  output pwire [1:0] sc3A;
  output pwire [1:0] sc0B;
  output pwire [1:0] sc1B;
  output pwire [1:0] sc2B;
  output pwire [1:0] sc3B;
  output pwire [3:0] jump_mask;
  output pwire [3:0] chk_maskA;
  output pwire [3:0] chk_maskB;
  output pwire [3:0] jump0_jmask;
  output pwire [3:0] jump1_jmask;
  output pwire [3:0] jump2_jmask;
  output pwire [3:0] jump3_jmask;
  output pwire [3:0] tbuf_predA;
  output pwire [3:0] tbuf_predB;
  output pwire [3:0] cond;
  output pwire [3:0] indir;
  output pwire [4:0] link0;
  output pwire [4:0] lnpos0;
  output pwire [4:0] ljpos0;
  output pwire [4:0] link1;
  output pwire [4:0] lnpos1;
  output pwire [4:0] ljpos1;
  output pwire [4:0] link2;
  output pwire [4:0] lnpos2;
  output pwire [4:0] ljpos2;
  output pwire [4:0] link3;
  output pwire [4:0] lnpos3;
  output pwire [4:0] ljpos3;
  output pwire way;
  output pwire [3:0] off0;
  output pwire [3:0] off1;
  output pwire [3:0] off2;
  output pwire [3:0] off3;
  input pwire [3:0] attr0I;
  input pwire [3:0] attr1I;
  input pwire [3:0] attr2I;
  input pwire [3:0] attr3I;
  output pwire [3:0] attr0O;
  output pwire [3:0] attr1O;
  output pwire [3:0] attr2O;
  output pwire [3:0] attr3O;
  input pwire [TGTIP_WIDTH-1:1] tgt0I;
  input pwire [TGTIP_WIDTH-1:1] tgt1I;
  input pwire [TGTIP_WIDTH-1:1] tgt2I;
  input pwire [TGTIP_WIDTH-1:1] tgt3I;
  output pwire [TGTIP_WIDTH-1:1] tgt0O;
  output pwire [TGTIP_WIDTH-1:1] tgt1O;
  output pwire [TGTIP_WIDTH-1:1] tgt2O;
  output pwire [TGTIP_WIDTH-1:1] tgt3O;
  input pwire [3:0] write_off0;
  input pwire [3:0] write_off1;
  input pwire [3:0] write_off2;
  input pwire [3:0] write_off3;
  input pwire [3:0] write_init0;
  input pwire [3:0] write_init1;
  input pwire [3:0] write_init2;
  input pwire [3:0] write_init3;
  input pwire [3:0] write_cond;
  input pwire [3:0] write_indir;
  input pwire [4:0] write_link0;
  input pwire [4:0] write_lnpos0;
  input pwire [4:0] write_link1;
  input pwire [4:0] write_lnpos1;
  input pwire [4:0] write_link2;
  input pwire [4:0] write_lnpos2;
  input pwire [4:0] write_link3;
  input pwire [4:0] write_lnpos3;
  input pwire write_way;
  input pwire write_thread;
  input pwire write_wen;
  input pwire write_insert;  
  output pwire write_can;
  input pwire write_read_fwd;
  input pwire [3:0] write_read_lowIP;
  input pwire [12:0] update_addr0;
  input pwire [12:0] update_addr1;
  input pwire update_en;
  input pwire [1:0] update_taken;
  input pwire [1:0] update_use;

  pwire [1:0] read_hit_way;
  pwire read_LRU_hit;
  
  pwire has0A,has1A,has2A,has3A;
  pwire has0B,has1B,has2B,has3B;
 
  pwire [1:0] sc0A;
  pwire [1:0] sc1A;
  pwire [1:0] sc2A;
  pwire [1:0] sc3A;

  pwire [1:0] sc0B;
  pwire [1:0] sc1B;
  pwire [1:0] sc2B;
  pwire [1:0] sc3B;
  
 // pwire [3:0] jump_maskA;
//  pwire [3:0] jump_maskB;
 // pwire [3:0] jump_maskFW;
  pwire [3:0] jmp_mask0A;
  pwire [3:0] jmp_mask0B;
  pwire [3:0] jmp_mask1A;
  pwire [3:0] jmp_mask1B;
  pwire [3:0] jmp_mask2A;
  pwire [3:0] jmp_mask2B;
  pwire [3:0] jmp_mask3A;
  pwire [3:0] jmp_mask3B;
  pwire [3:0] jump_mask0;
  pwire [3:0] jump_mask1;
  pwire [3:0] jump_mask2;
  pwire [3:0] jump_mask3;
  pwire [3:0] jump_mask0_reg;
  pwire [3:0] jump_mask1_reg;
  pwire [3:0] jump_mask2_reg;
  pwire [3:0] jump_mask3_reg;

  pwire [3:0] tbuf_predA;
  pwire [3:0] tbuf_predB;
  
  pwire [3:0] condA;
  pwire [3:0] condB;
  
  pwire wayA;
  pwire wayB;
  pwire [7:0] way_hit_way;
    
  pwire [3:0] indirA;
  pwire [3:0] indirB;

  pwire [3:0] off0A;
  pwire [3:0] off0B;
  pwire [3:0] off1A;
  pwire [3:0] off1B;
  pwire [3:0] off2A;
  pwire [3:0] off2B;
  pwire [3:0] off3A;
  pwire [3:0] off3B;
  
  pwire [4:0] linkA0;
  pwire [4:0] linkB0;
  pwire [4:0]  lnposA0;
  pwire [4:0]  lnposB0;
  pwire [4:0]  ljposA0;
  pwire [4:0]  ljposB0;
  pwire [4:0] linkA1;
  pwire [4:0] linkB1;
  pwire [4:0]  lnposA1;
  pwire [4:0]  lnposB1;
  pwire [4:0]  ljposA1;
  pwire [4:0]  ljposB1;
   
  pwire [4:0] linkA2;
  pwire [4:0] linkB2;
  pwire [4:0]  lnposA2;
  pwire [4:0]  lnposB2;
  pwire [4:0]  ljposA2;
  pwire [4:0]  ljposB2;
   
  pwire [4:0] linkA3;
  pwire [4:0] linkB3;
  pwire [4:0]  lnposA3;
  pwire [4:0]  lnposB3;
  pwire [4:0]  ljposA3;
  pwire [4:0]  ljposB3;
   
   
  pwire [TGTIP_WIDTH-2:0] tgt0A;
  pwire [TGTIP_WIDTH-2:0] tgt1A;
  pwire [TGTIP_WIDTH-2:0] tgt2A;
  pwire [TGTIP_WIDTH-2:0] tgt3A;

  pwire [TGTIP_WIDTH-2:0] tgt0B;
  pwire [TGTIP_WIDTH-2:0] tgt1B;
  pwire [TGTIP_WIDTH-2:0] tgt2B;
  pwire [TGTIP_WIDTH-2:0] tgt3B;

  pwire [3:0] attr0A;
  pwire [3:0] attr1A;
  pwire [3:0] attr2A;
  pwire [3:0] attr3A;
  pwire [3:0] attr0B;
  pwire [3:0] attr1B;
  pwire [3:0] attr2B;
  pwire [3:0] attr3B;
  
 // pwire [2:0] read_LRU_hit;

  pwire [3:0] write_off0_reg;
  pwire [3:0] write_off1_reg;
  pwire [3:0] write_off2_reg;
  pwire [3:0] write_off3_reg;
  pwire [3:0] write_cond_reg;
  pwire [3:0] write_indir_reg;
  pwire [4:0] write_link0_reg;
  pwire [4:0] write_lnpos0_reg;
  pwire [4:0] write_link1_reg;
  pwire [4:0] write_lnpos1_reg;
  pwire [4:0] write_link2_reg;
  pwire [4:0] write_lnpos2_reg;
  pwire [4:0] write_link3_reg;
  pwire [4:0] write_lnpos3_reg;
  pwire write_way_reg;
  pwire write_thread_reg;
  pwire write_wen_reg;
  pwire write_insert_reg;  

  pwire [3:0] taken_reg;
  pwire uxcept_reg;
  
  pwire [TGTIP_WIDTH-1:1] tgt0I_reg;
  pwire [TGTIP_WIDTH-1:1] tgt1I_reg;
  pwire [TGTIP_WIDTH-1:1] tgt2I_reg;
  pwire [TGTIP_WIDTH-1:1] tgt3I_reg;

  pwire [3:0] attr0I_reg;
  pwire [3:0] attr1I_reg;
  pwire [3:0] attr2I_reg;
  pwire [3:0] attr3I_reg;

  pwire [12:0] update_addr0_reg;
  pwire [12:0] update_addr1_reg;
  pwire update_en_reg;
  pwire [1:0] update_taken_reg;
  pwire [1:0] update_use_reg;
  pwire [1:0] update_dis;
  pwire [12:0] update_addr0_REG;
  pwire [12:0] update_addr1_REG;
  pwire [1:0] update_taken_REG;
  pwire [1:0] update_use_REG;
  pwire [3:0] chk_mask;  
  pwire j0_after,j1_after,j2_after,j3_after;
  pwire readA_LRU,readB_LRU,read_hit_A,read_hit_B;
  pwire [IP_WIDTH-1:1] nextIP_reg;
  
  pwire scupd_taken;
  pwire  scupd_en,scupd_en_reg;
  pwire [12:0] scupd_addr;
  pwire except_reg;
  pwire except_indir_reg;
  pwire except_jmask_en_reg;
  pwire [3:0] except_jmask_reg;

  tbufcam bufcam_mod(
  .clk(clk),
  .rst(rst),
  .except(except),
  .except_thread(except_thread),
  .new_addr({nextIP_reg[12:5]^nextIP_reg[20:13],2'b0,write_way_reg}),
  .new_thread(write_thread_reg),
  .new_en(write_insert_reg),
  .chk_addr0(update_addr0_reg[10:0]),
  .chk_match0(update_dis[0]),
  .chk_addr1(update_addr1_reg[10:0]),
  .chk_match1(update_dis[1]),
  .free(write_can)
  );
  
   
  
  tbuf_way_2 #(0) wayA_mod(
  clk,
  rst,
  read_clkEn|uxcept,
  mismatch_stall&~uxcept,
  except_reg,
  except_indir_reg,
  nextIP,
  read_hit_way[0],
  read_hit_way[1],
  read_LRU_hit,
  write_read_fwd,
  has0A,has1A,has2A,has3A,
  sc0A,sc1A,sc2A,sc3A,
  jmp_mask0A,jmp_mask1A,jmp_mask2A,jmp_mask3A,chk_maskA,chk_maskA,taken,
  tbuf_predA,
  condA,
  indirA,
  linkA0,lnposA0,ljposA0,
  linkA1,lnposA1,ljposA1,
  linkA2,lnposA2,ljposA2,
  linkA3,lnposA3,ljposA3,
  /*way*/,readA_LRU,
  tgt0I_reg,tgt1I_reg,tgt2I_reg,tgt3I_reg,
  tgt0A,tgt1A,tgt2A,tgt3A,
  off0A,off1A,off2A,off3A,
  attr0I_reg,attr1I_reg,attr2I_reg,attr3I_reg,
  attr0A,attr1A,attr2A,attr3A,
  write_off0,write_off1,write_off2,write_off3,
  write_cond,
  write_indir,
  write_link0,write_lnpos0,write_init0,
  write_link1,write_lnpos1,write_init1,
  write_link2,write_lnpos2,write_init2,
  write_link3,write_lnpos3,write_init3,
  write_way,
  write_wen,
  write_insert,
  update_addr0,update_addr1,
  update_en, update_taken,
  update_use, update_dis,
  scupd_taken,scupd_en,scupd_addr
  );
  
  tbuf_way_2 #(1) wayB_mod(
  clk,
  rst,
  read_clkEn|uxcept,
  mismatch_stall&~uxcept,
  except_reg,
  except_indir_reg,
  nextIP,
  read_hit_way[1],
  read_hit_way[0],
  read_LRU_hit,
  write_read_fwd,
  has0B,has1B,has2B,has3B,
  sc0B,sc1B,sc2B,sc3B,
  jmp_mask0B,jmp_mask1B,jmp_mask2B,jmp_mask3B,chk_maskB,chk_maskB,taken,
  tbuf_predB,
  condB,
  indirB,
  linkB0,lnposB0,ljposB0,
  linkB1,lnposB1,ljposB1,
  linkB2,lnposB2,ljposB2,
  linkB3,lnposB3,ljposB3,
  /*way*/,readB_LRU,
  tgt0I_reg,tgt1I_reg,tgt2I_reg,tgt3I_reg,
  tgt0B,tgt1B,tgt2B,tgt3B,
  off0B,off1B,off2B,off3B,
  attr0I_reg,attr1I_reg,attr2I_reg,attr3I_reg,
  attr0B,attr1B,attr2B,attr3B,
  write_off0,write_off1,write_off2,write_off3,
  write_cond,
  write_indir,
  write_link0,write_lnpos0,write_init0,
  write_link1,write_lnpos1,write_init1,
  write_link2,write_lnpos2,write_init2,
  write_link3,write_lnpos3,write_init3,
  write_way,
  write_wen,
  write_insert,
  update_addr0,update_addr1,
  update_en, update_taken,
  update_use, update_dis,
  scupd_taken,scupd_en,scupd_addr
  );
  

  assign has0=read_hit_A ? has0A : has0B&read_hit_B;
  assign has1=read_hit_A ? has1A : has1B&read_hit_B;
  assign has2=read_hit_A ? has2A : has2B&read_hit_B;
  assign has3=read_hit_A ? has3A : has3B&read_hit_B;
  assign off0=read_hit_A ? off0A : off0B|{4{~read_hit_B}};
  assign off1=read_hit_A ? off1A : off1B|{4{~read_hit_B}};
  assign off2=read_hit_A ? off2A : off2B|{4{~read_hit_B}};
  assign off3=read_hit_A ? off3A : off3B|{4{~read_hit_B}};
  assign cond=read_hit_A ? condA : condB;
  assign indir=read_hit_A ? indirA : indirB;
  assign link0= read_hit_A ? linkA0 :  linkB0&{5{read_hit_B}};
  assign lnpos0=read_hit_A ? lnposA0 : lnposB0|{5{~read_hit_B}};
  assign ljpos0=read_hit_A ? ljposA0 : ljposB0|{5{~read_hit_B}};
  assign link1= read_hit_A ? linkA1 :  linkB1&{5{read_hit_B}};
  assign lnpos1=read_hit_A ? lnposA1 : lnposB1|{5{~read_hit_B}};
  assign ljpos1=read_hit_A ? ljposA1 : ljposB1|{5{~read_hit_B}};
  assign link2= read_hit_A ? linkA2 :  linkB2&{5{read_hit_B}};
  assign lnpos2=read_hit_A ? lnposA2 : lnposB2|{5{~read_hit_B}};
  assign ljpos2=read_hit_A ? ljposA2 : ljposB2|{5{~read_hit_B}};
  assign link3= read_hit_A ? linkA3 :  linkB3&{5{read_hit_B}};
  assign lnpos3=read_hit_A ? lnposA3 : lnposB3|{5{~read_hit_B}};
  assign ljpos3=read_hit_A ? ljposA3 : ljposB3|{5{~read_hit_B}};
  assign read_LRU_hit=read_hit_A ? readA_LRU : readB_LRU;

  assign read_hit_A=read_hit_way[0];
  assign read_hit_B=read_hit_way[1];
  assign read_hit=|read_hit_way;
 
  assign way=|read_hit_way ? read_hit_B : readB_LRU; 

  assign tgt0O=read_hit_A ? tgt0A : tgt0B;
  assign tgt1O=read_hit_A ? tgt1A : tgt1B;
  assign tgt2O=read_hit_A ? tgt2A : tgt2B;
  assign tgt3O=read_hit_A ? tgt3A : tgt3B;
  
  assign attr0O=read_hit_A ? attr0A : attr0B;
  assign attr1O=read_hit_A ? attr1A : attr1B;
  assign attr2O=read_hit_A ? attr2A : attr2B;
  assign attr3O=read_hit_A ? attr3A : attr3B;
  
  assign scupd_taken=update_use_REG[1] ? update_taken_REG[1] : update_taken_REG[0];
  assign scupd_addr=update_use_REG[1] ? update_addr1_REG : update_addr0_REG;
  
  assign read_LRU_hit=read_hit_A ? readA_LRU : readB_LRU;

  assign jump_mask0=read_hit_A ? jmp_mask0A : jmp_mask0B;
  assign jump_mask1=read_hit_A ? jmp_mask1A : jmp_mask1B;
  assign jump_mask2=read_hit_A ? jmp_mask2A : jmp_mask2B;
  assign jump_mask3=read_hit_A ? jmp_mask3A : jmp_mask3B;
 
  assign jump0_jmask=jump_mask0; 
  assign jump1_jmask=jump_mask1; 
  assign jump2_jmask=jump_mask2; 
  assign jump3_jmask=jump_mask3;
 
  assign jump_mask=(taken_reg[0] && ~except_jmask_en_reg) ? jump_mask0_reg : 4'bz;
  assign jump_mask=(pwh#(2)::cmpEQ(taken_reg[1:0],2'b10) && ~except_jmask_en_reg) ? jump_mask1_reg : 4'bz;
  assign jump_mask=(pwh#(3)::cmpEQ(taken_reg[2:0],3'b100) && ~except_jmask_en_reg) ? jump_mask2_reg : 4'bz;
  assign jump_mask=(pwh#(4)::cmpEQ(taken_reg,4'b1000) && ~except_jmask_en_reg) ? jump_mask3_reg : 4'bz;
  assign jump_mask=(pwh#(4)::cmpEQ(taken_reg,4'b0) && ~except_jmask_en_reg) ? 4'hf : 4'bz;
  assign jump_mask=(except_jmask_en_reg) ? except_jmask_reg : 4'bz;

  assign chk_mask=read_hit_A ? chk_maskA : chk_maskB;


  always @(posedge clk)
  begin
      if (rst) begin
       /*   write_off0_reg<=4'b0;
          write_off1_reg<=4'b0;
          write_off2_reg<=4'b0;
          write_off3_reg<=4'b0;
          write_cond_reg<=4'b0;
          write_wen_reg<=1'b0;
          write_insert_reg<=1'b0;
          write_link_reg<=5'b0;
          write_indir_reg<=4'b0;
          write_lnpos_reg<=2'b0;
          write_lnoff_reg<=4'b0;
          write_lnoff_in_reg<=1'b0;
          write_way_reg<=3'b0;
          write_thread_reg<=1'b0;*/
          
          tgt0I_reg<={TGTIP_WIDTH-1{1'B0}};
          tgt1I_reg<={TGTIP_WIDTH-1{1'B0}};
          tgt2I_reg<={TGTIP_WIDTH-1{1'B0}};
          tgt3I_reg<={TGTIP_WIDTH-1{1'B0}};
          
          attr0I_reg<=4'B0;
          attr1I_reg<=4'B0;
          attr2I_reg<=4'B0;
          attr3I_reg<=4'B0;
          
          update_addr0_reg<=13'b0;
          update_addr1_reg<=13'b0;
          update_en_reg<=1'b0;
          update_taken_reg<=2'b0;
          update_use_reg<=2'b0;

          update_addr0_REG<=13'b0;
          update_addr1_REG<=13'b0;
          update_taken_REG<=2'b0;
          update_use_REG<=2'b0;
          
          nextIP_reg<={IP_WIDTH-1{1'B0}};
          scupd_en<=1'b0;
          scupd_en_reg<=1'b0;
          jump_mask0_reg<=4'b0;          
          jump_mask1_reg<=4'b0;          
          jump_mask2_reg<=4'b0;          
          jump_mask3_reg<=4'b0; 
          taken_reg<=4'b0;
          except_reg<=1'b0;
          except_indir_reg<=1'b0;
          except_jmask_en_reg<=1'b0;
          except_jmask_reg<=4'hf;         
      end else begin
          if (write_wen|write_insert) begin
           /*   write_off0_reg<=write_off0;
              write_off1_reg<=write_off1;
              write_off2_reg<=write_off2;
              write_off3_reg<=write_off3;
              write_cond_reg<=write_cond;
              write_link_reg<=write_link;
              write_indir_reg<=write_indir;
              write_lnpos_reg<=write_lnpos;
              write_lnoff_reg<=write_lnoff;
              write_lnoff_in_reg<=write_lnoff_in;
              write_way_reg<=write_way;
              write_thread_reg<=write_thread;*/
              
              tgt0I_reg<=tgt0I;
              tgt1I_reg<=tgt1I;
              tgt2I_reg<=tgt2I;
              tgt3I_reg<=tgt3I;
              attr0I_reg<=attr0I;
              attr1I_reg<=attr1I;
              attr2I_reg<=attr2I;
              attr3I_reg<=attr3I;
          end
          
          if (uxcept_reg) begin
              taken_reg<=4'b1;
              jump_mask0_reg<=chk_mask;
          end else if (read_clkEn) begin 
              jump_mask0_reg<=jump_mask0;
              jump_mask1_reg<=jump_mask1;
              jump_mask2_reg<=jump_mask2;
              jump_mask3_reg<=jump_mask3;
              taken_reg<=taken;
          end else if (mismatch_stall) begin
              if (taken_reg[0]) jump_mask0_reg<=chk_mask;
              else if (taken_reg[1]) jump_mask1_reg<=chk_mask;
              else if (taken_reg[2]) jump_mask2_reg<=chk_mask;
              else if (taken_reg[3]) jump_mask3_reg<=chk_mask;
          end
          
          
          write_wen_reg<=write_wen;
          write_insert_reg<=write_insert;
          
          update_addr0_reg<=update_addr0;
          update_addr1_reg<=update_addr1;
          update_en_reg<=update_en;
          update_taken_reg<=update_taken;
          update_use_reg<=update_use;
          if (update_en) begin
              update_addr0_REG<=update_addr0;
              update_addr1_REG<=update_addr1;
              update_taken_REG<=update_taken;
              update_use_REG<=update_use;
          end
          
          nextIP_reg<=nextIP;
          scupd_en<=except_due_jump & except;
          scupd_en_reg<=scupd_en;
          except_reg<=except;
          except_indir_reg<=except_indir;
          except_jmask_en_reg<=except_jmask_en;
          except_jmask_reg<=except_jmask;
      end
      if (rst) uxcept_reg<=1'b0;
      else uxcept_reg<=uxcept;
  end
  
endmodule


