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
`include "../msrss_no.sv"
module addrcalc_r(
  clk,
  rst,
  except,
  doStall,
  bus_hold,
  pause_miss,
  rsStall,
  mOp0_en,
  mOp0_thread,
  mOp0_lsflag,
  mOp0_addrMain,
  mOp0_addrEven,
  mOp0_addrOdd,
  mOp0_lsfwd,
  mOp0_type,
  mOp0_odd,
  mOp0_addr_low,
  mOp0_bread,
  mOp0_data,
  mOp0_pbit,
  mOp0_sz,
  mOp0_invmlb,
  mOp0_st,
  mOp0_split,
  mOp0_bank0,
  mOp0_regNo,
  mOp0_LSQ,
  mOp0_II,
  mOp0_WQ,
  mOp0_attr,
  mOp0_error,
  reqmlb_en,
  reqmlb_addr,
  reqmlb_attr,
  reqmlb_ack,
  reqC_addr,
  reqC_attr,
  reqC_mlbEn,
  busC_mlb_data,
  busC_mlb_en,
  msrss_no,msrss_en,msrss_thread,msrss_data,
  pageFault,pageFaultX,
  faultCode,
  faultNo,
  mOp_addrEven,
  mOp_addrOdd,
  mOp_sz,
  mOp_st,
  mOp_en,
  mOp_rsEn,
  mOp_ioEn,
 // mOp_thread,
  mOp_lsflag,
  mOp_banks,
  mOp_bank0,
  mOp_odd,
  mOp_addr_low,
  mOp_split,
  mOp_regNo,
  mOp_LSQ,
  mOp_II,
  mOp_WQ,
  mOp_lsfwd,
  mOp_type,
  mOp_bread,
  mOp_data,
  mOp_pbit,
  mOp_mlb_miss,
  mOp_skip_LDQ,
  FU3Hit,
  FU3reg,
  FU3Data,
  extern_feed,
  writeTlb_IP,
  writeTlb_wen,
  writeTlb_force_way,
  writeTlb_force_way_en,
  writeTlb_data0,
  writeTlb_data1,
  writeTlb_data2,
  mlb_clkEn,
  cout_secq,
  addrTlb,
  sproc,
  mlb_data0,
  mlb_data1,
  mlb_hit,
  mlb_way 
  );
  
  localparam VADDR_WIDTH=64;
  localparam BANK_COUNT=32;
  localparam PADDR_WIDTH=44;
  localparam TLB_IP_WIDTH=52;
  localparam TLB_DATA_WIDTH=`dmlbData_width;

  input pwire clk;
  input pwire rst;
  input pwire except;
  output pwire doStall;
  input pwire bus_hold;
  input pwire pause_miss;
  input pwire rsStall;
  input pwire mOp0_en;
  input pwire mOp0_thread;
  input pwire mOp0_lsflag;
  input pwire [43:0] mOp0_addrMain;
  input pwire [PADDR_WIDTH-9:0] mOp0_addrEven;
  input pwire [PADDR_WIDTH-9:0] mOp0_addrOdd;
  input pwire mOp0_lsfwd;
  input pwire [2:0] mOp0_type;
  input pwire mOp0_odd;
  input pwire [1:0] mOp0_addr_low;
  input pwire [3+1:0] mOp0_bread;
  input pwire [127+8:0] mOp0_data;
  input pwire [1:0] mOp0_pbit;
  input pwire [4:0] mOp0_sz;
  input pwire mOp0_invmlb;
  input pwire mOp0_st;
  input pwire mOp0_split;
  input pwire [4:0] mOp0_bank0;
  input pwire [8:0] mOp0_regNo;
  input pwire [8:0] mOp0_LSQ;
  input pwire [9:0] mOp0_II;
  input pwire [5:0] mOp0_WQ;
  input pwire [3:0] mOp0_attr;
  input pwire mOp0_error;
  input pwire reqmlb_en;
  input pwire [29:0] reqmlb_addr;
  input pwire [3:0] reqmlb_attr;
  output pwire reqmlb_ack;
  input pwire [30:0] reqC_addr;
  input pwire [3:0] reqC_attr;
  input pwire reqC_mlbEn;
  output pwire [`cmlbData_width-1:0] busC_mlb_data;
  output pwire busC_mlb_en;
  input pwire [15:0] msrss_no;
  input pwire msrss_en;
  input pwire msrss_thread;
  input pwire [64:0] msrss_data;

  output pageFault;
  output pageFaultX;
  output pwire [7:0] faultCode;
  output pwire [8:0] faultNo;
  output pwire [PADDR_WIDTH-1:8] mOp_addrEven;
  output pwire [PADDR_WIDTH-1:8] mOp_addrOdd;
  output pwire [4:0] mOp_sz;
  output pwire mOp_st;
  output pwire mOp_en;
  output pwire mOp_rsEn;
  output pwire mOp_ioEn;
//  output pwire mOp_thread;
  output pwire mOp_lsflag;
  output pwire [BANK_COUNT-1:0] mOp_banks;
  output pwire [4:0] mOp_bank0;
  output pwire mOp_odd;
  output pwire [1:0] mOp_addr_low;
  output pwire mOp_split;
  output pwire [8:0] mOp_regNo;
  output pwire [8:0] mOp_LSQ;
  output pwire [9:0] mOp_II;
  output pwire [5:0] mOp_WQ;
  output pwire mOp_lsfwd;
  output pwire [2:0] mOp_type;
  output pwire [3+1:0] mOp_bread;
  output pwire [127+8:0] mOp_data;
  output pwire [1:0] mOp_pbit;
  output pwire mOp_mlb_miss;
  output pwire mOp_skip_LDQ;
  input pwire FU3Hit;
  input pwire [8:0] FU3reg;
  input pwire [127+8:0] FU3Data;
  input pwire extern_feed;
  output pwire [2:0] [TLB_IP_WIDTH-2:0] writeTlb_IP;
  output pwire [2:0] writeTlb_wen;
  output pwire [2:0] [2:0] writeTlb_force_way;
  output pwire [2:0]  writeTlb_force_way_en;
  output pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data0;
  output pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data1;
  output pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data2;
  output pwire mlb_clkEn;
  output pwire cout_secq;
  output pwire  [TLB_IP_WIDTH-1:0] addrTlb;
  output pwire [23:0] sproc;
  input pwire [TLB_DATA_WIDTH-1:0] mlb_data0;
  input pwire [TLB_DATA_WIDTH-1:0] mlb_data1;
  input pwire mlb_hit;
  input pwire [2:0] mlb_way;

  pwire [2:0]new_en;
  pwire [2:0] new_can;
  pwire [2:0] new_can_reg;
  pwire [2:0] new_can_reg2;
  pwire [2:0] [47:0] new_addr;
  pwire [2:0] [3:0] new_attr;
  pwire [2:0] new_indir;
  pwire [2:0] new_inv;
  pwire [2:0] new_permReq;

  pwire mlb_clkEn;

  pwire [2:0] writeTlb_wenC0;
  pwire [2:0] writeTlb_wenHC0;
  pwire [2:0] writeTlb_low0;
  pwire [2:0] writeTlb_low0_reg;
  pwire [2:0] writeTlb_wenC0_reg;
  pwire [2:0] writeTlb_wenHC0_reg;

  pwire writeTlb_low;

  pwire [2:0] [TLB_IP_WIDTH-2:0] writeTlb_IP0;
  pwire [2:0] writeTlb_wen0;
  pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data00;
  pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data10;
  pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data20;

  pwire [2:0] [TLB_IP_WIDTH-2:0] writeTlb_IP0_reg;
  pwire [2:0] writeTlb_wen0_reg;
  pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data00_reg;
  pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data10_reg;
  pwire [2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data20_reg;

  pwire mOp0_en_reg;
  pwire mOp0_thread_reg;
  pwire mOp0_lsflag_reg;
  pwire [43:0] mOp0_addrMain_reg;
  pwire [VADDR_WIDTH:0] addrMain_mlb;
  pwire [VADDR_WIDTH:0] addrSupp_mlb;
  pwire [VADDR_WIDTH:0] addrSupp2_mlb;
  pwire [3:0] addrMain_attr;
  pwire [3:0] addrSupp_attr;
  pwire [3:0] addrSupp2_attr;
//  pwire [VADDR_WIDTH-1:0] addrMain_mlb_reg;
  pwire mlb_save;
  pwire mlb_save2;
  pwire mlb_is_code;
  pwire [4:0] mOp0_sz_reg;
  pwire mOp0_invmlb_reg;
  pwire mOp0_st_reg;
  pwire mOp0_split_reg;
  pwire [4:0] mOp0_bank0_reg;
 // pwire [4:0] mOp0_bank1_reg;
  pwire [8:0] mOp0_regNo_reg;
  pwire [8:0] mOp0_LSQ_reg;
  pwire [9:0] mOp0_II_reg;
  pwire [5:0] mOp0_WQ_reg;
  pwire [3:0] mOp0_attr_reg;
  pwire [PADDR_WIDTH-9:0] mOp0_addrEven_reg;
  pwire [PADDR_WIDTH-9:0] mOp0_addrOdd_reg;
  pwire mOp0_lsfwd_reg;
  pwire [2:0] mOp0_type_reg;
  pwire mOp0_odd_reg;
  pwire [1:0] mOp0_addr_low_reg;
  pwire [3+1:0] mOp0_bread_reg;
  pwire [127+1+7:0] mOp0_data_reg;
  pwire [1:0] mOp0_pbit_reg;
  pwire error_reg;

  pwire [29:0] addrInPage;
  pwire [29:0] addrOffPage;
  pwire reqmlb_en_reg,mlb_hit_reg,reqmlb_en_reg2;
//  pwire [VADDR_WIDTH-14:0] reqmlb_addr_reg;
  pwire mlb_clkEn_reg;

  pwire [TLB_DATA_WIDTH-1:0] mlb_data;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data_next;
  pwire mlb_hit;
  
  pwire [14:0] addrMain;
  pwire [13:0] addrNext;

  pwire [2:0] opsize;
  pwire hasBankNext=1'b0;
 
  pwire [2:0] mlb_way;
  pwire  [2:0] mlb_way_reg;
  pwire mlb_is_inv,mlb_is_inv_reg,mlb_is_inv_reg2;

  pwire [4:0] bank0;
  pwire [31:0] banks0;
  pwire stepOver;
  pwire stepOver2;
  
  pwire pause_miss_reg;
  pwire pause_miss_reg2;
  
  pwire page_carry;
  
  pwire req_bus,req_can;
  pwire mlb_proceed;

  pwire reqmlb_next;
  pwire mlb_save_reg;
  pwire req_can_reg; 
  pwire mlb_in_flight;//misnomer

  pwire [23:0] proc;
  pwire [23:0] sproc;
  pwire [1:0][23:0] pproc;
  pwire [1:0][23:0] vproc;
  pwire [1:0][63:0] mflags;

  pwire [1:0] fault_mlb;
  pwire [1:0] fault_mlb_next;
  //wire [4:0] lastSz;
  pwire [1:0] pageFault_t;
  pwire [1:0] pageFault_t_reg; 
  pwire fault_cann;
  pwire fault_cann_reg;
  pwire mOp_en_reg;
  pwire bus_hold_reg;

  integer i;

  pwire new_miss;

  assign new_en[0]=reqmlb_en;
  assign new_en[1]=reqC_mlbEn;
  assign new_en[2]=new_miss;
  assign new_addr[0]={reqmlb_addr,14'b0};
  assign new_addr[1]={reqC_addr,13'b0};
  assign new_addr[2]=mOp0_addrMain_reg;
  assign new_attr[0]=reqmlb_attr;
  assign new_attr[1]=reqC_attr;
  assign new_attr[2]=mOp0_attr_reg;
 
  pwire mop_ack;

  assign reqmlb_ack=new_can[0] & ~new_can_reg[0]; 
  assign busC_mlb_en=new_can[1] & ~new_can_reg[1]; 
  assign mop_ack=new_can[2] & ~new_can_reg[2]; 

  assign writeTlb_IP[0]=reqmlb_ack ? writeTlb_IP0_reg[0] : writeTlb_IP0_reg[2];
  assign writeTlb_IP[1]=busC_mlb_en ? writeTlb_IP0_reg[1] : writeTlb_IP0_reg[2];
  assign writeTlb_IP[2]=reqmlb_ack ? writeTlb_IP0_reg[0] : writeTlb_IP0_reg[2];
  assign writeTlb_data0[0]=reqmlb_ack ? writeTlb_data00_reg[0] : writeTlb_data00_reg[2];
  assign writeTlb_data0[1]=busC_mlb_en ? writeTlb_data00_reg[1] : writeTlb_data00_reg[2];
  assign writeTlb_data0[2]=reqmlb_ack ? writeTlb_data00_reg[0] : writeTlb_data00_reg[2];
  assign writeTlb_data1[0]=reqmlb_ack ? writeTlb_data10_reg[0] : writeTlb_data10_reg[2];
  assign writeTlb_data1[1]=busC_mlb_en ? writeTlb_data10_reg[1] : writeTlb_data10_reg[2];
  assign writeTlb_data1[2]=reqmlb_ack ? writeTlb_data10_reg[0] : writeTlb_data10_reg[2];
  assign writeTlb_data2[0]=reqmlb_ack ? writeTlb_data20_reg[0] : writeTlb_data20_reg[2];
  assign writeTlb_data2[1]=busC_mlb_en ? writeTlb_data20_reg[1] : writeTlb_data20_reg[2];
  assign writeTlb_data2[2]=reqmlb_ack ? writeTlb_data20_reg[0] : writeTlb_data20_reg[2];
  assign writeTlb_low=busC_mlb_en ? writeTlb_low0_reg[1] : writeTlb_low0_reg[2];
 
  assign mOp_addrEven[13:8]=(~mOp0_lsfwd_reg & ~req_bus & addrMain[7]) ? addrNext[13:8] : 6'bz;
  assign mOp_addrEven[13:8]=(~mOp0_lsfwd_reg & ~req_bus & ~addrMain[7]) ? addrMain[13:8] : 6'bz;
  assign mOp_addrEven=(mOp0_lsfwd_reg & ~req_bus) ? mOp0_addrEven_reg : 36'bz;
  assign mOp_addrOdd[13:8]=(~mOp0_lsfwd_reg & ~req_bus & ~addrMain[7]) ? addrNext[13:8] : 6'bz;
  assign mOp_addrOdd[13:8]=(~mOp0_lsfwd_reg & ~req_bus & addrMain[7]) ? addrMain[13:8] : 6'bz;
  assign mOp_addrEven[13:8]=fault_mlb ? mOp0_addrMain_reg[5+8:8] : 6'bz;
  assign mOp_addrOdd=(mOp0_lsfwd_reg & ~req_bus) ? mOp0_addrOdd_reg : 36'bz;
  assign addrNext[6:0]=addrMain[6:0];
  assign addrMain[13:0]=mOp0_addrMain_reg[13:0];
  assign mOp_addr_low=(~mOp0_lsfwd_reg & ~req_bus) ? addrMain[1:0] : 2'bz;
  assign mOp_addr_low=(mOp0_lsfwd_reg & ~req_bus) ? mOp0_addr_low_reg : 2'bz;
  assign mOp_odd=(~mOp0_lsfwd_reg & ~req_bus) ? addrMain[7] : 1'bz;
  assign mOp_odd=(mOp0_lsfwd_reg & ~req_bus) ? mOp0_odd_reg : 1'bz;
  assign mOp_banks=(~req_bus & mOp0_en_reg & (mlb_hit|mOp0_lsfwd_reg)) ? banks0 : 32'bz;
  assign mOp_banks=(~req_bus & ~(mOp0_en_reg & (mlb_hit|mOp0_lsfwd_reg))) ? 32'b0 : 32'bz;
  assign mOp_bank0=(~req_bus) ? mOp0_bank0_reg : 5'bz;
  assign mOp_split=(~req_bus) ? mOp0_split_reg : 1'bz;
  assign mOp_sz=(~req_bus) ? mOp0_sz_reg : 5'bz;
  assign mOp_st=(~req_bus) ? mOp0_st_reg : 1'bz;
  assign mOp_regNo=(~req_bus) ? mOp0_regNo_reg : 9'bz;
  assign mOp_LSQ=(~req_bus) ? mOp0_LSQ_reg : 9'bz;
  assign mOp_II=(~req_bus) ? mOp0_II_reg : 10'bz;
  assign mOp_WQ=(~req_bus) ? mOp0_WQ_reg : 6'bz;
//  assign mOp_thread=(~req_bus) ? mOp0_thread_reg : 1'bz;
  assign mOp_lsflag=(~req_bus) ? mOp0_lsflag_reg : 1'bz;
  assign mOp_lsfwd=(~req_bus) ? mOp0_lsfwd_reg : 1'b0;
  assign mOp_type=(~req_bus) ? mOp0_type_reg : 3'b000;
  assign mOp_bread=(~req_bus) ? mOp0_bread_reg|{5{~mOp0_lsfwd_reg}} : 5'b1111;
  assign mOp_data=(~req_bus) ? mOp0_data_reg : 136'b0;
  assign mOp_pbit=(~req_bus) ? mOp0_pbit_reg : 2'b0;
 
  assign mOp_en=(~req_bus) ? mOp0_en_reg & (mlb_hit|mOp0_lsfwd_reg|mlb_is_inv) & ~req_bus & ~except &
    ~pause_miss_reg2 & ~mlb_proceed & ~bus_hold & (mOp0_type_reg[1:0]!=2'b10) : 1'bz; 
  assign mOp_ioEn=(~req_bus) ? mOp0_en_reg & (mlb_hit|mOp0_lsfwd_reg) & ~req_bus & ~except &
    ~pause_miss_reg2 & ~mlb_proceed & ~bus_hold & (mOp0_type_reg[1]) : 1'b0; 

  assign doStall=mOp0_en_reg & ~(mlb_hit|mOp0_lsfwd_reg|mlb_is_inv) || bus_hold || pause_miss_reg2 || mlb_proceed ||
  reqmlb_en || reqC_mlbEn || req_bus;
//& ~reqmlb_en & ~reqC_mlbEn & ~pause_miss &
//         ~(~mlb_hit & ~mOp0_lsfwd_reg & mOp0_en_reg & mlb_clkEn)
  assign mOp_mlb_miss=mOp0_en_reg & ~(mlb_hit|mOp0_lsfwd_reg);
  
  assign mlb_clkEn=mOp0_en_reg | reqmlb_en_reg;

  assign mOp_skip_LDQ=~mlb_data[`dmlbData_wp] && ~mlb_data_next[`dmlbData_wp]|~page_carry;

  assign mlb_data=mlb_data0;
  assign mlb_data_next=mlb_data1;

  assign na=|(mlb_data[`dmlbData_na]&(4'b1<<addrMain[13:12])) || |(mlb_data[`dmlbData_na]&(1'b1<<(addrMain[13:12]+2'd1))) & addrNext[12] & mOp_split_X;
  assign na_next= |(mlb_data_next[`dmlbData_na]&(1'b1<<(addrMain[13:12]+2'd1))) & addrNext[12] & mOp_split_X;

  assign mOp_addrEven[43:14]=(~mOp0_lsfwd_reg & ~req_bus && ~page_carry | ~addrMain[8]) && ~fault_mlb ? 
    mlb_data[`dmlbData_phys] : 30'bz;
  assign mOp_addrEven[43:14]=(~mOp0_lsfwd_reg & ~req_bus && page_carry && addrMain[8]) && ~fault_mlb ?
    mlb_data_next[`dmlbData_phys] : 30'bz;
  assign mOp_addrEven[43:14]=fault_mlb ? mOp0_addrMain_reg[35+8:6+8] : 30'bz;
  assign mOp_addrOdd[43:14]=(~mOp0_lsfwd_reg & ~req_bus && ~page_carry | addrMain[8]) && ~fault_mlb ? 
    mlb_data[`dmlbData_phys] : 30'bz;
  assign mOp_addrOdd[43:14]=(~mOp0_lsfwd_reg & ~req_bus && page_carry && ~addrMain[8]) && ~fault_mlb ?
    mlb_data_next[`dmlbData_phys] : 30'bz;
  assign mOp_addrOdd[43:14]=fault_mlb ? {27'b0,mOp0_addrMain_reg[7:6]} : 30'bz;
  
  assign pageFault_t=(page_carry) ? (fault_mlb | ({2{mOp_split}} & fault_mlb_next)) & {2{mlb_hit}} : fault_mlb & {2{mlb_hit}};
  assign pageFault= fault_cann_reg | error_reg && mOp_en_reg && ~bus_hold_reg;
  assign pageFaultX=(pageFault_t_reg!=0)&~ fault_cann_reg &~ error_reg && mOp_en_reg && ~bus_hold_reg;
  assign fault_cann=1'b0;
  assign faultNo=fault_cann_reg | (pageFault_t_reg!=0) | error_reg && ~bus_hold_reg ? {error_reg ? 6'd63 : 6'd11,1'b0,2'd1} :
    {6'd0,1'b0,2'd2};

  assign faultCode={3'b0,fault_cann_reg,pageFault_t_reg[1],is_stack_reg,is_kstack_reg,mOp0_addrMain_reg[2],mOp0_attr_reg[`attr_sec]};

  assign is_kstack=~mOp0_addrMain_reg[43] & ~mflags[mOp0_thread_reg][`mflags_priv+1] || &mOp0_addrMain_reg[43:41]; //it is not all stack but we must disallow stealing global map pointers
  assign is_stack=~mOp0_addrMain_reg[43] & &mOp0_addrMain_reg[42:40]; //reserved area for subsystem and /or stack

  assign fault_tlb={mflags[`mflags_priv+1] & tlb_data[`dmlbData_user] , ~tlb_data[`dmlbData_na]};
  assign fault_tlb_next={mflags[`mflags_priv+1] & tlb_data_next[`dmlbData_user],  ~tlb_data_next[`dmlbData_na]};

  assign addrTlb=addrMain_mlb;

  assign mOp_rsEn=mOp0_en_reg & mlb_hit & ~pause_miss_reg2 & ~bus_hold & ~mlb_proceed & ~mOp0_lsfwd_reg & ~(pwh#(2)::cmpEQ(mOp0_type_reg[1:0],2'b10)); 
//dummy page walker
  assign reqmlb_ack=mlb_proceed & req_can & reqmlb_next;

  assign addrInPage=addrMain_mlb[43:15];

  assign busC_mlb_data[`cmlbData_phys]=writeTlb_low[1] ? writeTlb_data1[1][`dmlbData_phys] : writeTlb_data0[1][`dmlbData_phys];
  assign busC_mlb_data[`cmlbData_user]=writeTlb_low[1] ? writeTlb_data1[1][`dmlbData_user] : writeTlb_data0[1][`dmlbData_user];
  assign busC_mlb_data[`cmlbData_ne]=writeTlb_low[1] ? writeTlb_data1[1][`dmlbData_ne] : writeTlb_data0[1][`dmlbData_ne];
  assign busC_mlb_data[`cmlbData_na]=writeTlb_low[1] ? writeTlb_data1[1][`dmlbData_na] : writeTlb_data0[1][`dmlbData_na];
  assign busC_mlb_data[`cmlbData_global]=writeTlb_low[1] ? writeTlb_data1[1][`dmlbData_glo] : writeTlb_data0[1][`dmlbData_glo];

//  assign busC_mlb_en=writeTlb_wenC[1] | writeTlb_wenHC[1];

  assign new_miss=~mlb_hit & mlb_clkEn & ~mOp0_lsfwd_reg & 
            ~reqC_mlbEn & mOp0_en_reg & ~mlb_proceed & ~(mOp0_invmlb_reg &
            mlb_is_inv_reg) || mlb_hit & mlb_clkEn & ~mOp0_lsfwd_reg &
            ~reqC_mlbEn & mOp0_en_reg & ~mlb_proceed & mOp0_invmlb_reg &
            ~mlb_is_inv_reg;
  assign writeTlb_force_way[2]=mlb_way_reg;
  assign writeTlb_force_way_en[2]=writeTlb_wen && mlb_is_inv;
  assign writeTlb_force_way[1]=mlb_way_reg;
  assign writeTlb_force_way_en[1]=writeTlb_wen && mlb_is_inv;
  assign writeTlb_force_way[0]=mlb_way_reg;
  assign writeTlb_force_way_en[0]=writeTlb_wen && mlb_is_inv;

  adder_inc #(7) addNext_mod(addrMain[13:7],addrNext[13:7],1'b1,page_carry);

  assign new_inv[0]=1'b0;
  assign new_inv[1]=1'b0;
  assign new_inv[2]=mlb_is_inv;

  assign new_permReq[0]=1'b0;
  assign new_permReq[1]=1'b1;
  assign new_permReq[2]=1'b0;

  pager pgr_mod(
  .clk(clk),
  .rst(rst),
  .except(except),
  .bus_hold(bus_hold),
  .req_bus(req_bus),
  .new_en(new_en),
  .new_can(req_can),
  .new_addr(new_addr),
  .new_attr(new_attr),
  .new_indir(1'b0),
  .new_inv(new_inv),
  .new_permReq(new_permReq),
  .msrss_no(msrss_no),
  .msrss_thread(msrss_thread),
  .msrss_en(msrss_en),
  .msrss_data(msrss_data),
  .mOp_register(mOp_regNo),
  .mOp_LSQ(mOp_LSQ),
  .mOp_II(mOp_II),
  .mOp_WQ(mOp_WQ),
  .mOp_addrEven(mOp_addrEven),
  .mOp_addrOdd(mOp_addrOdd),
//  .mOp_addrMain(mOp_addrMain),
  .mOp_sz(mOp_sz),
  .mOp_st(mOp_st),
  .mOp_en(mOp_en),
//  .mOp_thread(mOp_thread),
  .mOp_lsflag(mOp_lsflag),
  .mOp_banks(mOp_banks),
//  .mOp_rsBanks(mOp_rsBanks),
  .mOp_bank0(mOp_bank0),
  .mOp_odd(mOp_odd),
  .mOp_addr_low(mOp_addr_low),
  .mOp_split(mOp_split),
  .FUHit(FU3Hit),
  .FUreg(FU3reg),
  .data_in(FU3Data[127:0]),
  .writeTlb_IP(writeTlb_IP0),
  .writeTlb_low(writeTlb_low0),
  .writeTlb_wen(writeTlb_wen0),
  .writeTlb_wen_c(writeTlb_wenC0),
  .writeTlb_wenH_c(writeTlb_wenHC0),
  .writeTlb_data0(writeTlb_data00),
  .writeTlb_data1(writeTlb_data10),
  .writeTlb_data2(writeTlb_data20)
  //add code invlpg io
  );
  
    always @*
    begin
      stepOver=|mOp0_addrMain_reg[1:0];
      stepOver2=&mOp0_addrMain_reg[1:0];
      bank0=mOp0_bank0_reg;
      /* verilator lint_off WIDTH */
      for (i=0;i<32;i=i+1)
        begin
          banks0[i]=pwh#(32)::cmpEQ(bank0,i) || 
          ((pwh#(32)::cmpEQ(opsize,6 )|| pwh#(32)::cmpEQ(opsize,3 )|| opsize[2] || (stepOver && pwh#(32)::cmpEQ(opsize,2)) || 
            (stepOver2 && pwh#(32)::cmpEQ(opsize,1))) && bank0==((i-1)&5'h1f)) ||
          (((pwh#(32)::cmpEQ(opsize,3 )&& stepOver) || opsize[2] || pwh#(32)::cmpEQ(opsize,6)) && bank0==((i-2)&5'h1f)) || 
          (((pwh#(32)::cmpEQ(opsize,4 )&& stepOver2) || pwh#(32)::cmpEQ(opsize,5 )|| pwh#(32)::cmpEQ(opsize,6)) && bank0==((i-3)&5'h1f)) ||
          (((pwh#(32)::cmpEQ(opsize,5 )&& stepOver) || pwh#(32)::cmpEQ(opsize,6)) && bank0==((i-4)&5'h1f)) || (pwh#(32)::cmpEQ(opsize,7 )&& bank0[4:3]=={i[4:3],3'b0});
        end
    end
      /* verilator lint_on WIDTH */
  always @* begin
      case(mOp0_sz_reg)
         5'd16: opsize=0;
         5'd17: opsize=1;
         5'd18: opsize=2;
         5'd19: opsize=3;
         5'h3:  opsize=4; //long double
         5'h0,5'h1,5'h2:  opsize=5; //int, double, single 128 bit (u)
         5'hc,5'hd,5'he:  opsize=7; //int, double, single 128 bit (a)
         5'h4,5'h5,5'h6:  opsize=2; //singleE,single,singleD
         5'h8,5'h9,5'ha:  opsize=3; //doubleE, double, singlePairD
	 //7,11=64 bit
	 5'hf: opsize=6; //160 bit fill/spill
	 default: opsize=3;
      endcase
  end

  always @(posedge clk) begin
      writeTlb_IP0_reg<=writeTlb_IP0;
      writeTlb_low0_reg<=writeTlb_low0;
      writeTlb_wen0_reg<=writeTlb_wen0;
      writeTlb_wenC0_reg<=writeTlb_wenC0;
      writeTlb_wenHC0_reg<=writeTlb_wenHC0;
      writeTlb_data00_reg<=writeTlb_data00_reg;
      writeTlb_data10_reg<=writeTlb_data10_reg;
      writeTlb_data20_reg<=writeTlb_data20_reg;

      if (rst) begin
          mOp0_en_reg<=1'b0;
          mOp0_thread_reg<=1'b0;
          mOp0_lsflag_reg<=1'b0;
          mOp0_addrMain_reg<=44'b0;
          mOp0_sz_reg<=5'b0;
          mOp0_invmlb_reg<=1'b0;
          mOp0_st_reg<=1'b0;
          mOp0_split_reg<=1'b0;
          mOp0_bank0_reg<=5'b0;
          mOp0_regNo_reg<=9'b0;
	  mOp0_LSQ_reg<=9'b0;
	  mOp0_II_reg<=10'b0;
	  mOp0_WQ_reg<=6'b0;
	  mOp0_attr_reg<=4'b0;
          error_reg<=1'b0;
          mOp0_addrEven_reg<=36'b0;
          mOp0_addrOdd_reg<=36'b0;
          mOp0_lsfwd_reg<=1'b0;
          mOp0_odd_reg<=1'b0;
          mOp0_addr_low_reg<=2'b0;
          mOp0_bread_reg<={1'b0,4'b0};
          mOp0_data_reg<={8'b0,128'b0};
          mOp0_pbit_reg<={2'b0};
          addrMain_tlb<=65'b0;
          is_kstack_reg<=0;
          is_stack_reg<=0;
      end else if (except) begin
          mOp0_en_reg<=1'b0;
          error_reg<=1'b0;
          is_kstack_reg<=0;
          is_stack_reg<=0;
      end else if (~doStall&&!rsStall) begin
          mOp0_en_reg<=mOp0_en & ~(except);
          if (mOp0_en & ~|req_bus || extern_feed & |req_bus & (pwh#(2)::cmpEQ(mOp0_type_reg[1:0],2'b10)) || |req_bus & (pwh#(2)::cmpEQ(mOp0_type_reg,2'b11))) begin
              mOp0_thread_reg<=mOp0_thread;
              mOp0_lsflag_reg<=mOp0_lsflag;
              mOp0_addrMain_reg<=mOp0_addrMain;
              addrMain_mlb<={proc[20:0],mOp0_addrMain};
              mOp0_sz_reg<=mOp0_sz;
              mOp0_st_reg<=mOp0_st;
              mOp0_invmlb_reg<=mOp0_invmlb & mOp0_sz[0];
              mOp0_split_reg<=mOp0_split;
              mOp0_bank0_reg<=mOp0_bank0;
              mOp0_regNo_reg<=mOp0_regNo;
	      mOp0_LSQ_reg<=mOp0_LSQ;
	      mOp0_II_reg<=mOp0_II;
	      mOp0_WQ_reg<=mOp0_WQ;
	      mOp0_attr_reg<=mOp0_attr;
              error_reg<=mOp0_error;
              mOp0_addrEven_reg<=mOp0_addrEven;
              mOp0_addrOdd_reg<=mOp0_addrOdd;
              mOp0_lsfwd_reg<=mOp0_lsfwd;
              mOp0_odd_reg<=mOp0_odd;
              mOp0_addr_low_reg<=mOp0_addr_low;
              mOp0_bread_reg<=mOp0_bread;
              mOp0_data_reg<=mOp0_data;
              mOp0_pbit_reg<=mOp0_pbit;
	      if (~mOp0_attr[`attr_vm]) begin
		  proc<=pproc;
		  sproc<=0;
	      end
	      if (mOp0_attr[`attr_vm]) begin
		  proc<=vproc;
		  sproc<=pproc^1;
	      end
	      mflags[`mflags_priv]<={mOp0_attr[`attr_um],mOp0_attr[`attr_sec]};//muha-srankk
              is_kstack_reg<=is_kstack &!|req_bus;
              is_stack_reg<=is_stack &!|req_bus;
          end else if (!rsStall) begin
	      if (mOp_en && !|req_bus) mOp0_en_reg<=1'b0;
          end
      end 
      if (rst) begin
          new_can_reg<=3'b111;
          new_can_reg2<=3'b111;
          writeTlb_IP0_reg<=0;
          writeTlb_data00_reg<=0;
          writeTlb_data10_reg<=0;
          writeTlb_data20_reg<=0;
          writeTlb_low0_reg<=0;
      end else begin
          new_can_reg<=new_can;
          new_can_reg2<=new_can_reg;
          writeTlb_IP0_reg<=writeTlb_IP0;
          writeTlb_data00_reg<=writeTlb_data00;
          writeTlb_data10_reg<=writeTlb_data10;
          writeTlb_data20_reg<=writeTlb_data20;
          writeTlb_low0_reg<=writeTlb_low0;
      end
     
      if (rst) begin
          pause_miss_reg<=1'b0;
          pause_miss_reg2<=1'b0;
      end else begin
          pause_miss_reg<=pause_miss;
          pause_miss_reg2<=pause_miss_reg;
      end
          if (rst) begin
              pproc[0]<=24'b0;
              vproc[0]<=24'b0;
	      mflags[0]<=64'b0;
              pproc[1]<=24'b0;
              vproc[1]<=24'b0;
	      mflags[1]<=64'b0;
          end else if (msrss_en) begin
              case(msrss_no[14:0])
           `csr_page: begin pproc[msrss_no[15]]<=msrss_data[63:40]; end
           `csr_vmpage: vproc[msrss_no[15]]<=msrss_data[63:40];
           `csr_mflags: mflags[msrss_no[15]]<=msrss_data;
              endcase
	 end
      if (rst) mlb_way_reg<=3'd0;
      else if (mlb_clkEn) mlb_way_reg<=mlb_way;
      mlb_save_reg<=mlb_save;
      req_can_reg<=req_can; 
      if (rst) begin
         // cmplxAddr_reg<=64'b0;
          pageFault_t_reg<=2'b0;
          fault_cann_reg<=1'b0;
      end else if (!rsStall) begin
         // cmplxAddr_reg<=cmplxAddr;
          pageFault_t_reg<=pageFault_t;
          fault_cann_reg<=fault_cann;
      end
  end
    always @* begin
	if (~mOp0_attr_reg[`attr_vm]) begin
	    proc=pproc[mOp0_thread_reg];
	    sproc=0;
	end
	if (mOp0_attr_reg[`attr_vm]) begin
	    proc=vproc[mOp0_thread_reg];
	    sproc=pproc[mOp0_thread_reg]^1;
	end
    end   
endmodule

