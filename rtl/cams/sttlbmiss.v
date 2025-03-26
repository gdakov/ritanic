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
module wtmiss_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=1+`mOp2_width;
  localparam ADDR_WIDTH=2;
  localparam ADDR_COUNT=4;

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
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module wtmiss(
  clk,
  rst,
  except,
  except_thread,
  read_clkEn,
  doSkip,
  miss0,
  mOp0_en,
  mOp0_thread,
  mOp0_addrMain,
  mOp0_type,
  mOp0_sz,
  mOp0_banks,
  mOp0_bank0,
  mOp0_odd,
  mOp0_addr_low,
  mOp0_split,
  mOp0_LSQ,
  mOp0_II,
  mOp0_WQ,
  mOp0_attr,
  mOp0_lsflag,
  mOp0_en_o,
  mOp0_thread_o,
 // mOp0_addrMain_o,
  mOp0_type_o,
  mOp0_sz_o,
  mOp0_banks_o,
  mOp0_bank0_o,
  mOp0_odd_o,
  mOp0_addr_low_o,
  mOp0_split_o,
  mOp0_LSQ_o,
  mOp0_II_o,
  mOp0_WQ_o,
  mOp0_lsflag_o,
  miss1,
  mOp1_en,
  mOp1_thread,
  mOp1_addrMain,
  mOp1_type,
  mOp1_sz,
  mOp1_banks,
  mOp1_bank0,
  mOp1_odd,
  mOp1_addr_low,
  mOp1_split,
  mOp1_LSQ,
  mOp1_II,
  mOp1_WQ,
  mOp1_attr,
  mOp1_lsflag,
  mOp1_en_o,
  mOp1_thread_o,
 // mOp1_addrMain_o,
  mOp1_type_o,
  mOp1_sz_o,
  mOp1_banks_o,
  mOp1_bank0_o,
  mOp1_odd_o,
  mOp1_addr_low_o,
  mOp1_split_o,
  mOp1_LSQ_o,
  mOp1_II_o,
  mOp1_WQ_o,
  mOp1_lsflag_o,
  mEx0_addr,
  mEx0_sz,
  mEx0_attr,
  mEx0_en,
  mEx1_addr,
  mEx1_sz,
  mEx1_attr,
  mEx1_en,
  mlbreq_en,
  mlbreq_addr,
  mlbreq_attr,
  mlbreq_ack
  );

//  localparam DEPTH=16;
  localparam ADDR_WIDTH=2;
  localparam DATA_WIDTH=1+`mOp2_width;
  localparam MOP_WIDTH=`mOp2_width;
//  localparam STALL_COUNT=13;
  localparam VADDR_WIDTH=44;
  localparam PADDR_WIDTH=44;
  localparam OPERATION_WIDTH=`operation_width;
  localparam TLB_DWIDTH=`dmlbData_width;
  localparam BANK_COUNT=32;
  localparam REG_WIDTH=`reg_addr_width;
  localparam WQ_WIDTH=6;
  localparam TLB_IP_WIDTH=52;
 
  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire except_thread;
  input pwire read_clkEn;
  output pwire doSkip;

  input pwire miss0;
  input pwire mOp0_en;
  input pwire mOp0_thread;
  input pwire [VADDR_WIDTH-1:0] mOp0_addrMain;
  input pwire [1:0] mOp0_type;
  input pwire [4:0] mOp0_sz;
  input pwire [BANK_COUNT-1:0] mOp0_banks;
  input pwire [4:0] mOp0_bank0;
  input pwire mOp0_odd;
  input pwire [1:0] mOp0_addr_low;
  input pwire mOp0_split;
  input pwire [8:0] mOp0_LSQ;
  input pwire [9:0] mOp0_II;
  input pwire [5:0] mOp0_WQ;
  input pwire [3:0] mOp0_attr;
  input pwire mOp0_lsflag;

  output pwire mOp0_en_o;
  output pwire mOp0_thread_o;
  //input [VADDR_WIDTH-1:0] mOp0_addrMain_o;
  output pwire [1:0] mOp0_type_o;
  output pwire [4:0] mOp0_sz_o;
  output pwire [BANK_COUNT-1:0] mOp0_banks_o;
  output pwire [4:0] mOp0_bank0_o;
  output pwire mOp0_odd_o;
  output pwire [1:0] mOp0_addr_low_o;
  output pwire mOp0_split_o;
  output pwire [8:0] mOp0_LSQ_o;
  output pwire [9:0] mOp0_II_o;
  output pwire [5:0] mOp0_WQ_o;
  output pwire mOp0_lsflag_o;

  input pwire miss1;
  input pwire mOp1_en;
  input pwire mOp1_thread;
  input pwire [VADDR_WIDTH-1:0] mOp1_addrMain;
  input pwire [1:0] mOp1_type;
  input pwire [4:0] mOp1_sz;
  input pwire [BANK_COUNT-1:0] mOp1_banks;
  input pwire [4:0] mOp1_bank0;
  input pwire mOp1_odd;
  input pwire [1:0] mOp1_addr_low;
  input pwire mOp1_split;
  input pwire [8:0] mOp1_LSQ;
  input pwire [9:0] mOp1_II;
  input pwire [5:0] mOp1_WQ;
  input pwire [3:0] mOp1_attr;
  input pwire mOp1_lsflag;
  
  output pwire mOp1_en_o;
  output pwire mOp1_thread_o;
  output pwire [4:0] mOp1_sz_o;
  output pwire [BANK_COUNT-1:0] mOp1_banks_o;
  output pwire [1:0] mOp1_type_o;
  output pwire [4:0] mOp1_bank0_o;
  output pwire mOp1_odd_o;
  output pwire [1:0] mOp1_addr_low_o;
  output pwire mOp1_split_o;
  output pwire [8:0] mOp1_LSQ_o;
  output pwire [9:0] mOp1_II_o;
  output pwire [5:0] mOp1_WQ_o;
  output pwire mOp1_lsflag_o;
  
  output pwire [VADDR_WIDTH-1:0] mEx0_addr;
  output pwire [4:0] mEx0_sz;
  output pwire [3:0] mEx0_attr;
  output pwire mEx0_en;
  output pwire [VADDR_WIDTH-1:0] mEx1_addr;
  output pwire [4:0] mEx1_sz;
  output pwire [3:0] mEx1_attr;
  output pwire mEx1_en;
  output pwire mlbreq_en;
  output pwire [VADDR_WIDTH-15:0] mlbreq_addr;
  output pwire [3:0] mlbreq_attr;
  input pwire mlbreq_ack;

  pwire [VADDR_WIDTH-1:0] RaddrMain[1:0];
  pwire enOut,last_out,enOutNull;
  pwire [2:0] cnt;
  pwire [2:0] cnt_reg;
  pwire [3:0] stepW;
  pwire [2:0] cnt_plus;
  pwire [2:0] cnt_minus;
  pwire  [1:0] read_addr;
  pwire [1:0] read_addr_d;
  pwire  [1:0] write_addr;
  pwire [1:0] write_addr_d;
  pwire doSkip_reg,doSkip_reg2,doSkip_reg3;

  pwire [MOP_WIDTH-1:0] read_mop[1:0];
  pwire [MOP_WIDTH-1:0] read_mop_reg[1:0];
  pwire [MOP_WIDTH-1:0] write_mop[1:0];
  pwire [1:0] rdmiss;
  pwire [1:0] rdmiss_reg;
  pwire [1:0] rdm_done;
  pwire [1:0] rdm_xdone;
  pwire [1:0] pause;//can add bit 2 for pause until l2 mlb can respond
  pwire [1:0] pause_reg;
  pwire missP;
  pwire missQ;
  pwire enOut_reg;
  integer k;
  pwire [3:0] thr[1:0];
  pwire [3:0] invalid[1:0];
  pwire [3:0] invalid_reg[1:0];
  pwire inIt;
  pwire [1:0] inIt_cnt;
  pwire [1:0] inIt_cnt_d;
  pwire [1:0] read_addr_reg;
  pwire [3:0] mOp0_attr_o;
  pwire [3:0] mOp1_attr_o;

  wtmiss_ram ramA_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(enOut&&pause==0),
  .read_addr(read_addr_d),
  .read_data({rdmiss[0],read_mop[0]}),
  .write_addr(inIt ? inIt_cnt : write_addr),
  .write_data({miss0,write_mop[0]}&{DATA_WIDTH{~inIt}}),
  .write_wen((miss0|miss1)|inIt)
  );
  wtmiss_ram ramB_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(enOut&&pause==0),
  .read_addr(read_addr_d),
  .read_data({rdmiss[1],read_mop[1]}),
  .write_addr(inIt ? inIt_cnt : write_addr),
  .write_data({miss1,write_mop[1]}&{DATA_WIDTH{~inIt}}),
  .write_wen((miss0|miss1)|inIt)
  );

 
  adder_inc #(3) cntAdd_mod(cnt,cnt_plus,1'b1,);
  adder #(3) cntSub_mod(cnt,3'b111,cnt_minus,1'b0,1'b1,,,,);
  adder_inc #(2) rdAdd_mod(read_addr,read_addr_d,1'b1,);
  adder_inc #(2) wrAdd_mod(write_addr,write_addr_d,1'b1,);
  adder_inc #(2) inAdd_mod(inIt_cnt,inIt_cnt_d,1'b1,);
 
  assign mOp0_thread_o=(enOut_reg|enOutNull) ?   read_mop_reg[0][`mOp2_thread] : mOp0_thread;
  assign mOp0_sz_o=(enOut_reg|enOutNull) ?       read_mop_reg[0][`mOp2_sz] : mOp0_sz;
  assign mOp0_attr_o=(enOut_reg|enOutNull) ?       read_mop_reg[0][`mOp2_attr] : mOp0_attr;
  assign mOp0_odd_o=(enOut_reg|enOutNull) ?      read_mop_reg[0][`mOp2_odd] : mOp0_odd;
  assign mOp0_addr_low_o=(enOut_reg|enOutNull) ? read_mop_reg[0][`mOp2_addr_low] : mOp0_addr_low;
  //assign mOp0_st=(enOut_reg|enOutNull) ?       read_mop_reg[0][`mOp2_st] : 1'bz;
  assign mOp0_banks_o=(enOut_reg|enOutNull) ?    read_mop_reg[0][`mOp2_banks] : mOp0_banks;
  assign mOp0_bank0_o=(enOut_reg|enOutNull) ?    read_mop_reg[0][`mOp2_bank0] : mOp0_bank0;
  //assign mOp0_bank1=(enOut_reg|enOutNull) ?    read_mop_reg[0][`mOp_bank1] : 5'bz;
  assign mOp0_split_o=(enOut_reg|enOutNull) ?    read_mop_reg[0][`mOp2_split] : mOp0_split;
  assign mOp0_LSQ_o=(enOut_reg|enOutNull) ?      read_mop_reg[0][`mOp2_LSQ] : mOp0_LSQ;
  assign mOp0_type_o=(enOut_reg|enOutNull) ?     read_mop_reg[0][`mOp2_type] : mOp0_type;
  assign mOp0_II_o=(enOut_reg|enOutNull) ?       read_mop_reg[0][`mOp2_II] : mOp0_II;
  assign mOp0_WQ_o=(enOut_reg|enOutNull) ?       read_mop_reg[0][`mOp2_WQ] : mOp0_WQ;
  assign mOp0_lsflag_o=(enOut_reg|enOutNull) ?   read_mop_reg[0][`mOp2_lsflag] : mOp0_lsflag;
  assign mOp0_en_o=enOut_reg ?   rdmiss_reg[0] & ~invalid[0][read_addr_reg] && 
	 pause_reg==0 && ~except: 1'bz;
  assign mOp0_en_o=enOutNull ?   1'b0 : 1'bz;
  assign mOp0_en_o=~enOut_reg & ~enOutNull ? mOp0_en : 1'bz;
  assign mEx0_addr=RaddrMain[0];
  assign mEx0_en=enOut & (pause==0) & rdmiss[0] & ~invalid[0][read_addr] & ~except;
 
  assign mOp1_thread_o=(enOut_reg|enOutNull) ?   read_mop_reg[1][`mOp2_thread] : mOp1_thread;
  assign mOp1_sz_o=(enOut_reg|enOutNull) ?       read_mop_reg[1][`mOp2_sz] : mOp1_sz;
  assign mOp1_attr_o=(enOut_reg|enOutNull) ?       read_mop_reg[1][`mOp2_attr] : mOp1_attr;
  assign mOp1_odd_o=(enOut_reg|enOutNull) ?      read_mop_reg[1][`mOp2_odd] : mOp1_odd;
  assign mOp1_addr_low_o=(enOut_reg|enOutNull) ? read_mop_reg[1][`mOp2_addr_low] : mOp1_addr_low;
 // assign mOp1_st=(enOut_reg|enOutNull) ?       read_mop_reg[1][`mOp_st] : 1'bz;
  assign mOp1_banks_o=(enOut_reg|enOutNull) ?    read_mop_reg[1][`mOp2_banks] : mOp1_banks;
  assign mOp1_bank0_o=(enOut_reg|enOutNull) ?    read_mop_reg[1][`mOp2_bank0] : mOp1_bank0;
//  assign mOp1_bank1=(enOut_reg|enOutNull) ?    read_mop_reg[1][`mOp_bank1] : 5'bz;
  assign mOp1_split_o=(enOut_reg|enOutNull) ?    read_mop_reg[1][`mOp2_split] : mOp1_split;
  assign mOp1_LSQ_o=(enOut_reg|enOutNull) ?      read_mop_reg[1][`mOp2_LSQ] : mOp1_LSQ;
  assign mOp1_type_o=(enOut_reg|enOutNull) ?     read_mop_reg[1][`mOp2_type] : mOp1_type;
  assign mOp1_II_o=(enOut_reg|enOutNull) ?       read_mop_reg[1][`mOp2_II] : mOp1_II;
  assign mOp1_WQ_o=(enOut_reg|enOutNull) ?       read_mop_reg[1][`mOp2_WQ] : mOp1_WQ;
  assign mOp1_lsflag_o=(enOut_reg|enOutNull) ?   read_mop_reg[1][`mOp2_lsflag] : mOp1_lsflag;
  assign mOp1_en_o=enOut_reg ?   rdmiss_reg[1] & ~invalid[0][read_addr_reg] &&
	 pause_reg==0 && ~except : 1'bz;
  assign mOp1_en_o=enOutNull ?   1'b0 : 1'bz;
  assign mOp1_en_o=~enOut_reg & ~enOutNull ? mOp1_en : 1'bz;
  assign mEx1_addr=RaddrMain[1];
  assign mEx1_en=enOut & (pause==0) & rdmiss[1] & ~invalid[0][read_addr] & ~except;
 
  assign RaddrMain[0]=read_mop[0][`mOp2_addrMain]; 
  assign RaddrMain[1]=read_mop[1][`mOp2_addrMain]; 
  assign mEx0_sz=read_mop[0][`mOp2_sz];
  assign mEx1_sz=read_mop[1][`mOp2_sz];//CA
  assign mEx0_attr=read_mop[0][`mOp2_attr];
  assign mEx1_attr=read_mop[1][`mOp2_attr];
  
  assign write_mop[0][`mOp2_addrMain]=mOp0_addrMain;
//  assign write_mop[0][`mOp_reg]=     9'b0_o;//mOp0_regNo;
  assign write_mop[0][`mOp2_sz]=      mOp0_sz_o;
  assign write_mop[0][`mOp2_attr]=      mOp0_attr_o;
  assign write_mop[0][`mOp2_odd]=     mOp0_odd_o;
  assign write_mop[0][`mOp2_addr_low]=mOp0_addr_low_o;
//  assign write_mop[0][`mOp_st]=      1'b0_o;
  assign write_mop[0][`mOp2_split]=   mOp0_split_o;
  assign write_mop[0][`mOp2_banks]=   mOp0_banks_o;
  assign write_mop[0][`mOp2_bank0]=   mOp0_bank0_o;
//  assign write_mop[0][`mOp_bank1]=   5'b0;
  assign write_mop[0][`mOp2_LSQ]=     mOp0_LSQ_o;
  assign write_mop[0][`mOp2_type]=     mOp0_type_o;
  assign write_mop[0][`mOp2_II]=      mOp0_II_o;
  assign write_mop[0][`mOp2_WQ]=      mOp0_WQ_o;
  assign write_mop[0][`mOp2_thread]=  mOp0_thread_o;
  assign write_mop[0][`mOp2_lsflag]=  mOp0_lsflag_o;

  assign write_mop[1][`mOp2_addrMain]=mOp1_addrMain;
//  assign write_mop[1][`mOp_reg]=     9'b0;//mOp1_regNo;
  assign write_mop[1][`mOp2_sz]=      mOp1_sz_o;
  assign write_mop[1][`mOp2_attr]=      mOp1_attr_o;
  assign write_mop[1][`mOp2_odd]=     mOp1_odd_o;
  assign write_mop[1][`mOp2_addr_low]=mOp1_addr_low_o;
//  assign write_mop[1][`mOp_st]=      1'b0;
  assign write_mop[1][`mOp2_split]=   mOp1_split_o;
  assign write_mop[1][`mOp2_banks]=   mOp1_banks_o;
  assign write_mop[1][`mOp2_bank0]=   mOp1_bank0_o;
//  assign write_mop[1][`mOp_bank1]=   5'b0;
  assign write_mop[1][`mOp2_LSQ]=     mOp1_LSQ_o;
  assign write_mop[1][`mOp2_type]=     mOp1_type_o;
  assign write_mop[1][`mOp2_II]=      mOp1_II_o;
  assign write_mop[1][`mOp2_WQ]=      mOp1_WQ_o;
  assign write_mop[1][`mOp2_thread]=  mOp1_thread_o;
  assign write_mop[1][`mOp2_lsflag]=  mOp1_lsflag_o;

  assign enOut=stepW[2] && cnt!=0;
  assign last_out=stepW[3] && pwh#(3)::cmpEQ(cnt,3'd0);
  assign enOutNull=doSkip_reg2 & ~enOut_reg;

  assign pause[0]=enOut & rdmiss[0] & ~rdm_done[0];
  assign pause[1]=enOut & rdmiss[1] & ~rdm_done[1];

  assign mlbreq_addr=pause[0] ? RaddrMain[0][43:14] : RaddrMain[1][43:14];
  assign mlbreq_en=enOut && (pause[0] && ~rdm_xdone[0]) | (pwh#(2)::cmpEQ(pause,2'b10) & ~rdm_xdone[1]);
  assign mlbreq_attr=pause[0] ? read_mop[0][`mOp2_attr] : read_mop[1][`mOp2_attr];

  always @(posedge clk) begin

      pause_reg<=pause;
      invalid_reg[0]<=invalid[0];
      invalid_reg[1]<=invalid[1];
      read_addr_reg<=read_addr;

      if (rst) begin
          doSkip<=1'b0;
          stepW<=4'b0;
          write_addr<=2'b0;
          cnt<=3'b0;
          invalid[0]<=4'b0;
          invalid[1]<=4'b0;
          thr[0]<=4'b0;
          thr[1]<=4'b0;
          read_mop_reg[0]<={MOP_WIDTH{1'B0}};
          read_mop_reg[1]<={MOP_WIDTH{1'B0}};
          rdmiss_reg<=2'B0;
          rdm_done<=2'b0;
          rdm_xdone<=2'b0;
          missP<=1'b0;
          missQ<=1'b0;
          enOut_reg<=1'b0;
          cnt_reg<=3'b0;
      end else begin
          if (pause==0) cnt_reg<=cnt;
          if (pause==0) stepW<={stepW[2:0],miss0|miss1|doSkip};
          if (miss0|miss1&&(~enOut||pause!=0)) begin
              doSkip<=1'b1;
              cnt<=cnt_plus;
              write_addr<=write_addr_d;
             // missP<=1'b1;
              if (pause==0) enOut_reg<=enOut;
              if (pause!=0 && enOut) begin
                  if (pause[0]) begin
                      rdm_done[0]<=mlbreq_ack;
                      rdm_xdone[0]<=1'b1;
	          end else if (pause[1]) begin
                      rdm_done[1]<=mlbreq_ack;
                      rdm_xdone[1]<=1'b1;
                  end
	     
              end
          end else if (miss0|miss1&&enOut&&pause==0) begin
              doSkip<=1'b1;
              write_addr<=write_addr_d;
              rdm_done<=2'b0;
              rdm_xdone<=2'b0;
              missQ<=~last_out;
              //missP<=1'b1;
              enOut_reg<=1'b1;
          end else if ((pause==0) & enOut)begin
              if (last_out) cnt<=3'd0;
              if (last_out) stepW<=4'b0;
              if (last_out) doSkip<=1'b0;
              if (last_out) begin
                  if (missQ) begin
                     // missP<=1'b1;
                      missQ<=1'b0;
                  end else begin
                     // missP<=1'b0;
                  end
              end
              if (enOut) cnt<=cnt_minus;
              rdm_done<=2'b0;
              rdm_xdone<=2'b0;
              enOut_reg<=1'b1;
          end else if (pause!=0 && enOut) begin
	      if (pause[0]) begin
                  rdm_done[0]<=mlbreq_ack;
                  rdm_xdone[0]<=1'b1;
	      end else if (pause[1]) begin
                  rdm_done[1]<=mlbreq_ack;
                  rdm_xdone[1]<=1'b1;
              end
          end else begin
              if (pause==0) enOut_reg<=enOut;
	      else enOut_reg<=1'b0;
          end
          if (except) begin
              for(k=0;k<4;k=k+1) begin
                  if (pwh#(32)::cmpEQ(except_thread,thr)[0][k]) invalid[0][k]<=1'b1;
                  if (pwh#(32)::cmpEQ(except_thread,thr)[1][k]) invalid[1][k]<=1'b1;
		  if (miss0|miss1) begin
                      if (pwh#(32)::cmpEQ(except_thread,thr)[0][write_addr]) invalid[0][write_addr]<=1'b1;
                      if (pwh#(32)::cmpEQ(except_thread,thr)[1][write_addr]) invalid[1][write_addr]<=1'b1;
		  end
              end
              //if (({4{except_thread}}^thr[0]&~invalid[0]|{4{except_thread}}^thr[1]&~invalid[1])==4'b0)
              //  doSkip<=1'b0;
          end
          if (miss0|miss1 && ~enOut_reg && ~except) begin
              thr[0][write_addr]<=mOp0_thread;
              thr[1][write_addr]<=mOp1_thread;
              invalid[0][write_addr]<=except && pwh#(32)::cmpEQ(except_thread,mOp0_thread);
              invalid[1][write_addr]<=except && pwh#(32)::cmpEQ(except_thread,mOp1_thread);
          end
          read_mop_reg[0]<=read_mop[0];
          read_mop_reg[1]<=read_mop[1];
          rdmiss_reg<=rdmiss;
      end
      if (last_out) doSkip<=1'b0;
      if (rst) begin
          doSkip_reg<=1'b0;
          doSkip_reg2<=1'b0;
          doSkip_reg3<=1'b0;
      end else begin
          doSkip_reg<=doSkip;
          doSkip_reg2<=doSkip_reg;
          doSkip_reg3<=doSkip_reg2;
      end
      if (rst) begin
          read_addr<=2'b0;
      end else begin
          if (enOut&&pause==0) read_addr<=read_addr_d;
      end
      if (rst) begin
          inIt<=1'b1;
          inIt_cnt<=2'd0;
      end else if (inIt) begin
          case (inIt_cnt)
          2'd0: inIt_cnt<=2'd1;
          2'd1: inIt_cnt<=2'd2;
          2'd2: inIt_cnt<=2'd3;
          2'd3: inIt_cnt<=2'd0;
          endcase
          if (pwh#(2)::cmpEQ(inIt_cnt,2'd3)) inIt<=1'd0;
      end
  end
endmodule


