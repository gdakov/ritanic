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
  
module fun_lsq(
  clk,
  rst,
`if goldium_edition==1
  clkX0,
  clkX1,
`endif
  except,
  bus_holds_addrcalc_reg2,miss_holds_addrcalc_reg2,miss_pause_addrcalc_reg2,insert_isData_reg2,
  pause_addrcalc,WDoRsPause,
  lsq_index,
  rsStall,
  rsDoStall,
  p0_adata,p0_LSQ,p0_en,p0_rsEn,p0_smpc,p0_lsfwd,p0_skip,
  p1_adata,p1_LSQ,p1_en,p1_rsEn,p1_smpc,p1_lsfwd,p1_skip,
  p2_adata,p2_LSQ,p2_en,p2_rsEn,p2_smpc,p2_lsfwd,p2_skip,
  p3_adata,p3_LSQ,p3_en,p3_rsEn,p3_smpc,p3_lsfwd,p3_skip,
  p4_adata,p4_LSQ,p4_en,
  p5_adata,p5_LSQ,p5_en,
  FU0Hit,FU0Data,
  FU1Hit,FU1Data,
  FU2Hit,FU2Data,
  FU3Hit,FU3Data,
  st_stall,
  st0_adata,st0_en,st0_bank1,st0_bgn_ben,st0_end_ben,st0_data,st0_dataX,st0_pbit,
  st1_adata,st1_en,st1_bank1,st1_bgn_ben,st1_end_ben,st1_data,st1_dataX,st1_pbit,
  wb0_adata,wb0_LSQ,wb0_en,wb0_ret,wb0_data,wb0_dataX,wb0_brdbanks,wb0_brdbanks2,wb0_pbit,
  wb1_adata,wb1_LSQ,wb1_en,wb1_ret,wb1_data,wb1_dataX,wb1_brdbanks,wb1_brdbanks2,wb1_pbit,
  mem_II_upper,
  mem_II_upper2,
  has_store,
  mem_II_upper_in,
  mem_II_bits_fine,
  mem_II_bits_ldconfl,
  mem_II_bits_waitconfl,
  mem_II_bits_except,
  mem_II_bits_ret,
  mem_II_exbitsx6,
  mem_II_stall,
  mem_II_stall2,
  doStall_rs,stall_cntrl, 
  doStall_alloc,doStall_cntrl,
  doStall_WQ,stall_WQ,
  doRetire_d,
  xbreak,
  has_xbreak,
  ldq_new_mask_reg,bundle_in_reg2,II_upper,LSQ_shr_data,
  WQS0_reg,WQR0_reg,
  WQS1_reg,WQR1_reg,
  WQS2_reg,WQR2_reg,
  lsw_wq0,lsw_wdata0,lsw_wdataX0,lsw_pdata0,lsw_rs_en0,
  lsw_wq1,lsw_wdata1,lsw_wdataX1,lsw_pdata1,lsw_rs_en1,
  mOpY4_II,mOpY4_hit,
  mOpY5_II,mOpY5_hit,
  lsi0_reg,lsi1_reg,lsi2_reg,
  MSI_exp_addr,MSI_en,
  doStall_STQ,
  doStall_LDQ,
  doStall_LSQ ,
  jtag_en,
  jtag_data
  );
/*vxerilator hier_block*/

  input pwire clk;
  input pwire rst;
`if goldium_edition==1
  input pwire clkX0;
  input pwire clkX1;
`else
  pwire clkX0=1'b1;
  pwire clkX1=1'b0;
`endif
  input pwire except;
  input pwire bus_holds_addrcalc_reg2,miss_holds_addrcalc_reg2,miss_pause_addrcalc_reg2,insert_isData_reg2;
  input pwire pause_addrcalc;
  output pwire [1:0] WDoRsPause;
  output pwire [5:0] lsq_index;
  input pwire rsStall;
  output pwire [3:0] rsDoStall;
  input pwire [`lsaddr_width-1:0] p0_adata;
  input pwire [8:0]               p0_LSQ;
  input pwire                     p0_en;
  input pwire                     p0_rsEn;
  input pwire                     p0_smpc;
  input pwire                     p0_lsfwd;
  input pwire                     p0_skip;
  input pwire [`lsaddr_width-1:0] p1_adata;
  input pwire [8:0]               p1_LSQ;
  input pwire                     p1_en;
  input pwire                     p1_rsEn;
  input pwire                     p1_smpc;
  input pwire                     p1_lsfwd;
  input pwire                     p1_skip;
  input pwire [`lsaddr_width-1:0] p2_adata;
  input pwire [8:0]               p2_LSQ;
  input pwire                     p2_en;
  input pwire                     p2_rsEn;
  input pwire                     p2_smpc;
  input pwire                     p2_lsfwd;
  input pwire                     p2_skip;
  input pwire [`lsaddr_width-1:0] p3_adata;
  input pwire [8:0]               p3_LSQ;
  input pwire                     p3_en;
  input pwire                     p3_rsEn;
  input pwire                     p3_smpc;
  input pwire                     p3_lsfwd;
  input pwire                     p3_skip;
  input pwire [`lsaddr_width-1:0] p4_adata;
  input pwire [8:0]               p4_LSQ;
  input pwire                     p4_en;
  input pwire [`lsaddr_width-1:0] p5_adata;
  input pwire [8:0]               p5_LSQ;
  input pwire                     p5_en;
  input pwire FU0Hit,FU1Hit,FU2Hit,FU3Hit;
  input pwire [135:0] FU0Data;
  input pwire [135:0] FU1Data;
  input pwire [135:0] FU2Data;
  input pwire [135:0] FU3Data;
  input pwire st_stall;
  output pwire [`lsaddr_width-1:0] st0_adata;
  output pwire                     st0_en;
  output pwire [4:0]               st0_bank1;
  output pwire [3:0]               st0_bgn_ben;
  output pwire [3:0]               st0_end_ben;
  output pwire [127:0]             st0_data;
  output pwire [127:0]              st0_dataX;
  output pwire [1:0]               st0_pbit;
  output pwire [`lsaddr_width-1:0] st1_adata;
  output pwire                     st1_en;
  output pwire [4:0]               st1_bank1;
  output pwire [3:0]               st1_bgn_ben;
  output pwire [3:0]               st1_end_ben;
  output pwire [127:0]             st1_data;
  output pwire [127:0]             st1_dataX;
  output pwire [1:0]               st1_pbit;
  output pwire [`lsaddr_width-1:0] wb0_adata;
  output pwire [8:0]               wb0_LSQ;
  output pwire                     wb0_en;
  output pwire [12:0]              wb0_ret;
  output pwire [127+8:0]           wb0_data;
  output pwire [127:0]             wb0_dataX;
  output pwire [16:0]               wb0_brdbanks;
  output pwire [16:0]               wb0_brdbanks2;
  output pwire [1:0]               wb0_pbit;
  output pwire [`lsaddr_width-1:0] wb1_adata;
  output pwire [8:0]               wb1_LSQ;
  output pwire                     wb1_en;
  output pwire [12:0]              wb1_ret;
  output pwire [127+8:0]           wb1_data;
  output pwire [127:0]             wb1_dataX;
  output pwire [16:0]               wb1_brdbanks;
  output pwire [16:0]               wb1_brdbanks2;
  output pwire [1:0]               wb1_pbit;
  
  output pwire [5:0]   mem_II_upper;
  output pwire [5:0]   mem_II_upper2;
  output pwire has_store;
  input pwire  [5:0]   mem_II_upper_in;
  output pwire [9:0]   mem_II_bits_fine;
  output pwire [9:0]   mem_II_bits_ldconfl;
  output pwire [9:0]   mem_II_bits_waitconfl;
  output pwire [9:0]   mem_II_bits_except;
  output pwire [9:0]   mem_II_bits_ret;
  output pwire [39:0]  mem_II_exbitsx6;
  output pwire         mem_II_stall;
  output pwire         mem_II_stall2;
  input pwire [3:0] doStall_rs;
  output pwire stall_cntrl;  
  input pwire doStall_alloc;
  input pwire doStall_cntrl;
  input pwire doStall_WQ;
  output pwire stall_WQ;
  pwire stall;
  input pwire doRetire_d;
  input pwire [9:0] xbreak;
  input pwire has_xbreak;
  input pwire [5:0] ldq_new_mask_reg;
  input pwire bundle_in_reg2;
  input pwire [5:0] II_upper;
  input pwire [`lsqshare_width-1:0] LSQ_shr_data;
  input pwire [5:0] WQS0_reg;
  input pwire [5:0] WQR0_reg;
  input pwire [5:0] WQS1_reg;
  input pwire [5:0] WQR1_reg;
  input pwire [5:0] WQS2_reg;
  input pwire [5:0] WQR2_reg;
  input pwire [5:0]     lsw_wq0;
  input pwire [127+8:0] lsw_wdata0;
  input pwire [127:0]   lsw_wdataX0;
  input pwire [1:0]     lsw_pdata0;
  input pwire [3:0]     lsw_rs_en0;
  input pwire [5:0]     lsw_wq1;
  input pwire [127+8:0] lsw_wdata1;
  input pwire [127:0]   lsw_wdataX1;
  input pwire [1:0]     lsw_pdata1;
  input pwire [3:0]     lsw_rs_en1;
  input pwire [9:0] mOpY4_II;
  input pwire       mOpY4_hit;
  input pwire [9:0] mOpY5_II;
  input pwire       mOpY5_hit;
  input pwire [2:0] lsi0_reg;
  input pwire [2:0] lsi1_reg;
  input pwire [2:0] lsi2_reg;
  input pwire [36:0] MSI_exp_addr;
  input pwire MSI_en;
  output pwire doStall_STQ;
  output pwire doStall_LDQ;
  output pwire doStall_LSQ;
  output pwire jtag_en;
  output pwire [8:0] jtag_data;

  assign jtag_en=p6_dummy_en;
  assign jtag_data=p6_dummy_LSQ[13:5];
 
  pwire stall_STQ;
  pwire aStall_STQ;
  pwire aDoStall_STQ;
  pwire [`lsqshare_width-1:0] LSQ_shr_dataA;
  pwire [`lsaddr_width-1:0] LSQ_dataA0;
  pwire [`lsaddr_width-1:0] LSQ_dataA1;
  pwire [`lsaddr_width-1:0] LSQ_dataA2;
  pwire [`lsaddr_width-1:0] LSQ_dataA3;
  pwire [`lsaddr_width-1:0] LSQ_dataA4;
  pwire [`lsaddr_width-1:0] LSQ_dataA5;
  pwire [5:0] LSQ_enA/*verilator public*/;
  pwire LSQ_rdy_A;
  pwire LSQ_rdy_AP/*verilator public*/;
  pwire [5:0] STQ_ldconfl;
  pwire [3:0] PSTQ_match;
  pwire [`lsaddr_width-1:0] PSTQ_data[2:0];
  pwire [2:0] PSTQ_en;
  pwire [5:0] PSTQ_data_shr;
  pwire [`lsqshare_width-1:0] retM_data_shr;
  pwire [`lsqshare_width-1:0] retM_data_shr_reg; 

  pwire p6_dummy_en;
  pwire [13:0] p6_dummy_LSQ;

  pwire [`lsaddr_width-1:0]   stqd_mOpA;
  pwire [`lsaddr_width-1:0]   stqd_mOpB;
  pwire [`lsfxdata_width-1:0] stqd_xdataA0;
  pwire [`lsfxdata_width-1:0] stqd_xdataA1;
  pwire [`lsfxdata_width-1:0] stqd_xdataB0;
  pwire [`lsfxdata_width-1:0] stqd_xdataB1;
  pwire [7:0]                 stqd_addrA0;
  pwire [7:0]                 stqd_addrA1;
  pwire [7:0]                 stqd_addrB0;
  pwire [7:0]                 stqd_addrB1;
  pwire [127+8:0]             stqd_dataA0;
  pwire [127+8:0]             stqd_dataB0;
  pwire [127+8:0]             stqd_dataA1;
  pwire [127+8:0]             stqd_dataB1;
  pwire [1:0]                 stqd_pbitA0;
  pwire [1:0]                 stqd_pbitB0;
  pwire [1:0]                 stqd_pbitA1;
  pwire [1:0]                 stqd_pbitB1;
  pwire                       stqd_rdyA0;
  pwire                       stqd_rdyA1;
  pwire                       stqd_rdyB0;
  pwire                       stqd_rdyB1;
  pwire [1:0][127+8:0]               dc_wdataP;
  reg  [127+8:0]               dc_wdataP_reg[1:0];
  pwire [1:0][1:0]                   dc_pdataP;
  reg  [1:0]                   dc_pdataP_reg[1:0];
  pwire [1:0] sdata_rdy;
  pwire [5:0] retM_II_in;
  pwire [5:0] retM_II;
  reg st_stall_reg;

  pwire [3*32-1:0] new_conflictx;
  pwire [3*32-1:0] new_conflicty;
//  pwire [3*BUF_COUNT-1:0] p1_new_conflictAp;
//  pwire [3*BUF_COUNT-1:0] p1_new_conflictBp;
  pwire [3*32-1:0] new_conflictA;
  pwire [11:0] p1_new_conflictA_b;
  pwire [2:0] new_conflictA_has;
  pwire [3*32-1:0] new_conflictB;
  pwire [11:0] p1_new_conflictB_b;
  pwire [2:0] new_conflictB_has;
  pwire [`lsaddr_width-1:0] lstep1_owndataA;
  pwire [`lsaddr_width-1:0] lstep1_owndataB;
  pwire [3*32-1:0] new_conflict2_acc;
  pwire [32-1:0] p1_nChNextA0;
  pwire [32-1:0] p1_nChNextA1;
  pwire [32-1:0] p1_nChNextA2;
  pwire [4:0] p1_ins_addr0;
  pwire [`lsaddr_width-1:0] p1_pos_dataA0;
  pwire p1_pos_en0;
  pwire [4:0] p1_ins_addr1;
  pwire [`lsaddr_width-1:0] p1_pos_dataA1;
  pwire p1_pos_en1;
  pwire [4:0] p1_ins_addr2;
  pwire [`lsaddr_width-1:0] p1_pos_dataA2;
  pwire p1_pos_en2;

  pwire [135:0] dat0_LSQ;
  pwire [1:0]   chk0_LSQ;
  pwire [135:0] dat1_LSQ;
  pwire [1:0]   chk1_LSQ;
  pwire [135:0] dat2_LSQ;
  pwire [1:0]   chk2_LSQ;
  pwire [135:0] dat3_LSQ;
  pwire [1:0]   chk3_LSQ;
  pwire [135:0] dat4_LSQ;
  pwire [1:0]   chk4_LSQ;
  pwire [135:0] dat5_LSQ;
  pwire [1:0]   chk5_LSQ;

  pwire [5:0] wb0_chk;
  pwire [5:0] wb1_chk;
/*  pwire [9:0] wret_II0;
  pwire wret_en0;
  pwire [9:0] wret_II1;
  pwire wret_en1;
  */
  pwire [5:0] LDQ_mask;
  pwire new_en_reg2;
  pwire new_enP_reg2;
  pwire p1_peek_aStall;
  pwire [5:0] confl_first;
  pwire [5:0] confl_last;
  pwire [6:0] confl_cnt;
  pwire [95:0] m_mask;
  pwire [95:0] n_mask;

  pwire p1_inhibit;

  reg [`lsaddr_width-1:0] p0_adata_x;
  reg [`lsaddr_width-1:0] p1_adata_x;
  reg [`lsaddr_width-1:0] p2_adata_x;
  reg [`lsaddr_width-1:0] p3_adata_x;

  always @(*) begin
      p0_adata_x=p0_adata;
      p0_adata_x[`lsaddr_pconfl]=PSTQ_match[0];
      p1_adata_x=p1_adata;
      p1_adata_x[`lsaddr_pconfl]=PSTQ_match[1];
      p2_adata_x=p2_adata;
      p2_adata_x[`lsaddr_pconfl]=PSTQ_match[2];
      p3_adata_x=p3_adata;
      p3_adata_x[`lsaddr_pconfl]=PSTQ_match[3];
  end
  
  stq stq_mod(
  clk,
  rst,
  except,
  stall_STQ,
  doStall_STQ,
  aStall_STQ,
  aDoStall_STQ,
  wreq_stall| &wreq_en_reg[2:1],
  rsStall,
  rsDoStall,
  doRetire_d,
  {6'b0,xbreak},
  mem_II_upper_in,
  mem_II_upper2,
  LSQ_dataA0,LSQ_enA[0],chk0_LSQ,
  LSQ_dataA1,LSQ_enA[1],chk1_LSQ,
  LSQ_dataA2,LSQ_enA[2],chk2_LSQ,
  LSQ_dataA3,LSQ_enA[3],chk3_LSQ,
  LSQ_dataA4,LSQ_enA[4],chk4_LSQ,
  LSQ_dataA5,LSQ_enA[5],chk5_LSQ,  
  LSQ_rdy_A,
  LSQ_shr_dataA,
  p4_adata,p4_en,p4_LSQ,
  p5_adata,p5_en,p5_LSQ,
  p3_adata,p6_dummy_en, p6_dummy_LSQ,
  LDQ_ldconfl,LDQ_insconfl,LDQ_ldconflX,
  STQ_ldconfl,
  lsw_wq0,lsw_rs_en0[0],lsw_wdata0,lsw_wdataX0,lsw_pdata0,
  lsw_wq1,lsw_rs_en1[0],lsw_wdata1,lsw_wdataX1,lsw_pdata1,
  LSQ_shr_data[`lsqshare_wrt0]!=3'd7,
  LSQ_shr_data[`lsqshare_wrt1]!=3'd7,
  wb1_adata,wb1_LSQ,wb1_data,wb1_dataX,wb1_pbit,wb1_brdbanks,wb1_brdbanks2,wb1_en,wb1_chk,//wb1_way
  wb0_adata,wb0_LSQ,wb0_data,wb0_dataX,wb0_pbit,wb0_brdbanks,wb0_brdbanks2,wb0_en,wb0_chk,,
  wreq_en[0],wreq_data[0],dc_wdataP[0],dc_wdataPX[0],dc_pdataP[0],
  wreq_en[1],wreq_data[1],dc_wdataP[1],dc_wdataPX[1],dc_pdataP[1]
  );

  pwire aStall_LSQ;
  pwire stall_LDQ;
  pwire [5:0] LDQ_ldconfl;
  pwire [5:0] LDQ_insconfl;
  pwire [5:0] LDQ_ldconflX;
  pwire [`lsqxcept_width-2:0] ret_xdata[5:0];
  pwire [5:0] ret_xenab;
  pwire [5:0] ret_xldconfl;
  pwire [5:0] ret_xsmpconfl;
  pwire retB_en;
  pwire retB_clkEn;
  pwire mem_II_stall;
  pwire [1:0][`lsaddr_width-1:0] wreq_data;
  reg [`lsaddr_width-1:0] wreq_data_reg[1:0];
  pwire [1:0] wreq_en;
  reg [1:0] wreq_en_reg;
  pwire [3:0] wreq_bben[1:0];
  pwire [3:0] wreq_endben[1:0];
  pwire [4:0] wreq_dcEnd[1:0];
  pwire PSTQ_has_store;
  pwire [1:0] wreq_has;
  pwire stall_LSQ;
  pwire [5:0] LSQ_upper;
  pwire wreq_stall;

  assign PSTQ_has_store=PSTQ_data_shr!=6'h3f;

  assign wb0_data=wb0_chk[0] ? dat0_LSQ : 136'bz;
  assign wb0_data=wb0_chk[1] ? dat1_LSQ : 136'bz;
  assign wb0_data=wb0_chk[2] ? dat2_LSQ : 136'bz;
  assign wb0_data=wb0_chk[3] ? dat3_LSQ : 136'bz;
  assign wb0_data=wb0_chk[4] ? dat4_LSQ : 136'bz;
  assign wb0_data=wb0_chk[5] ? dat5_LSQ : 136'bz;
  assign wb0_data=|wb0_chk ? 136'bz : 136'b0;

  assign mem_II_stall=wreq_stall;
  assign mem_II_stall2=1'b0;

  assign wb1_data=wb1_chk[0] ? dat0_LSQ : 136'bz;
  assign wb1_data=wb1_chk[1] ? dat1_LSQ : 136'bz;
  assign wb1_data=wb1_chk[2] ? dat2_LSQ : 136'bz;
  assign wb1_data=wb1_chk[3] ? dat3_LSQ : 136'bz;
  assign wb1_data=wb1_chk[4] ? dat4_LSQ : 136'bz;
  assign wb1_data=wb1_chk[5] ? dat5_LSQ : 136'bz;
  assign wb1_data=|wb1_chk ? 136'bz : 136'b0;

//  assign wb0_sdata=wreq_data[0];
//  assign wb1_sdata=wreq_data[1];

  ldq ldq_mod(
  .clk(clk),
  .rst(rst),
  .except(except),.except_thread(1'b0),
  .aStall(aStall_LSQ),
  .stall(stall_LDQ),.doStall(doStall_LDQ),
  .new0_data(p0_adata_x),.new0_rsEn(p0_rsEn&~p0_skip),
   .new0_isFlag(p0_adata_x[`lsaddr_flag]),.new0_thread(1'b0),
  .new1_data(p1_adata_x),.new1_rsEn(p1_rsEn&~p1_skip),
    .new1_isFlag(p1_adata_x[`lsaddr_flag]),.new1_thread(1'b0),
  .new2_data(p2_adata_x),.new2_rsEn(p2_rsEn&~p2_skip),
    .new2_isFlag(p2_adata_x[`lsaddr_flag]),.new2_thread(1'b0),
  .new3_data(p3_adata_x),.new3_rsEn(p3_rsEn&~p3_skip),
    .new3_isFlag(p3_adata_x[`lsaddr_flag]),.new3_thread(1'b0),
  .newI_mask(ldq_new_mask_reg),.newI_en(bundle_in_reg2),.newI_thr(1'b0),
  .chk0_dataA(LSQ_dataA0),.chk0_enA(LSQ_enA[0]),
  .chk1_dataA(LSQ_dataA1),.chk1_enA(LSQ_enA[1]),
  .chk2_dataA(LSQ_dataA2),.chk2_enA(LSQ_enA[2]),
  .chk3_dataA(LSQ_dataA3),.chk3_enA(LSQ_enA[3]),
  .chk4_dataA(LSQ_dataA4),.chk4_enA(LSQ_enA[4]),
  .chk5_dataA(LSQ_dataA5),.chk5_enA(LSQ_enA[5]),
  .chk_data_shr(LSQ_shr_dataA),
  .chk_en(LSQ_rdy_A),
  .chk_enP(LSQ_rdy_AP),
  .confl(LDQ_ldconfl),
  .confl_smp(LDQ_insconfl),
  .conflX(LDQ_ldconflX),
  .expun_addr(MSI_exp_addr),
  .expun_en(MSI_en)
  );


  lsq_req lsqReq_mod(
  .clk(clk),
  .rst(rst),

  .stall(stall_LSQ),
  .doStall(doStall_LSQ),
  .doRsPause(WDoRsPause),
  .except(except),
  .except_thread(1'b0),
  .aStall(aStall_LSQ),

  .readA_clkEn(LSQ_rdy_A&~aStall_LSQ),
  .readA_rdy(LSQ_rdy_A),
  .readA_rdyP(LSQ_rdy_AP),
  .read0A_data(LSQ_dataA0),.read0A_enOut(LSQ_enA[0]),
  .read1A_data(LSQ_dataA1),.read1A_enOut(LSQ_enA[1]),
  .read2A_data(LSQ_dataA2),.read2A_enOut(LSQ_enA[2]),
  .read3A_data(LSQ_dataA3),.read3A_enOut(LSQ_enA[3]),
  .read4A_data(LSQ_dataA4),.read4A_enOut(LSQ_enA[4]),
  .read5A_data(LSQ_dataA5),.read5A_enOut(LSQ_enA[5]),

  .read0A_DATA(dat0_LSQ),.read0A_dEn(chk0_LSQ),
  .read1A_DATA(dat1_LSQ),.read1A_dEn(chk1_LSQ),
  .read2A_DATA(dat2_LSQ),.read2A_dEn(chk2_LSQ),
  .read3A_DATA(dat3_LSQ),.read3A_dEn(chk3_LSQ),
  .read4A_DATA(dat4_LSQ),.read4A_dEn(chk4_LSQ),
  .read5A_DATA(dat5_LSQ),.read5A_dEn(chk5_LSQ),
  
  .readA_conflIn_l(LDQ_ldconfl|STQ_ldconfl),
  .readA_conflInMSI(LDQ_insconfl),
  //.readA_conflIn_s(STQ_confl), //purpose??

  .readA_thr(),

  .read_data_shr(LSQ_shr_dataA),
  .write_thread_shr(1'b0),
  .write_data_shr(LSQ_shr_data),
  .write_wen_shr((lsi0_reg!=3'd6 || lsi1_reg!=3'd6 || lsi2_reg!=3'd6) && bundle_in_reg2),
  .write_addr_shr(lsq_index),
//verilator lint_off WIDTH
  .read0B_xdata(ret_xdata[0]),.read0B_enOut(ret_xenab[0]),
  .read1B_xdata(ret_xdata[1]),.read1B_enOut(ret_xenab[1]),
  .read2B_xdata(ret_xdata[2]),.read2B_enOut(ret_xenab[2]),
  .read3B_xdata(ret_xdata[3]),.read3B_enOut(ret_xenab[3]),
  .read4B_xdata(ret_xdata[4]),.read4B_enOut(ret_xenab[4]),
  .read5B_xdata(ret_xdata[5]),.read5B_enOut(ret_xenab[5]),
//verilator lint_on WIDTH
  .read_data_shrB(retM_data_shr),
  .readB_ldconfl(ret_xldconfl),
  .readB_smpconfl(ret_xsmpconfl),
  .readB_rdy_en(retB_en),.readB_clkEn(retB_clkEn),
  //.write_thread,
  //loads 0-3, xdata +2 clocks
  .write0_addr(p0_LSQ),.write0_data(p0_adata_x),
    .write0_xdata({p0_adata_x[`lsaddr_II],p0_adata_x[`lsaddr_except],2'b0,p0_adata_x[`lsaddr_etype]}),
    .write0_thr(1'b0),.write0_wen(p0_en && ~p0_adata_x[`lsaddr_flag] & ~p0_lsfwd &(p0_adata[`lsaddr_reg_low]!=4'hf)),
  .write1_addr(p1_LSQ),.write1_data(p1_adata_x),
    .write1_xdata({p1_adata_x[`lsaddr_II],p1_adata_x[`lsaddr_except],2'b0,p1_adata_x[`lsaddr_etype]}),
    .write1_thr(1'b0),.write1_wen(p1_en && ~p1_adata_x[`lsaddr_flag] & ~p1_lsfwd &(p1_adata[`lsaddr_reg_low]!=4'hf)),
  .write2_addr(p2_LSQ),.write2_data(p2_adata_x),
    .write2_xdata({p2_adata_x[`lsaddr_II],p2_adata_x[`lsaddr_except],2'b0,p2_adata_x[`lsaddr_etype]}),
    .write2_thr(1'b0),.write2_wen(p2_en && ~p2_adata_x[`lsaddr_flag] & ~p2_lsfwd &(p2_adata[`lsaddr_reg_low]!=4'hf)),
  .write3_addr(p3_LSQ),.write3_data(p3_adata_x),
    .write3_xdata({p3_adata_x[`lsaddr_II],p3_adata_x[`lsaddr_except],2'b0,p3_adata_x[`lsaddr_etype]}),
    .write3_thr(1'b0),.write3_wen(p3_en && ~p3_adata_x[`lsaddr_flag] & ~p3_lsfwd &(p3_adata[`lsaddr_reg_low]!=4'hf)),
  //stores 0-1
  .write4_addr(p4_LSQ),.write4_data(p4_adata),.write4_xdata({p4_adata[`lsaddr_II],p4_adata[`lsaddr_except],2'b0,p4_adata[`lsaddr_etype]}),
  .write4_thr(1'b0),.write4_wen(p4_en),
  .write5_addr(p5_LSQ),.write5_data(p5_adata),.write5_xdata({p5_adata[`lsaddr_II],p5_adata[`lsaddr_except],2'b0,p5_adata[`lsaddr_etype]}),
  .write5_thr(1'b0),.write5_wen(p5_en),
  .FU0Hit(FU0Hit),.FU1Hit(FU1Hit),.FU2Hit(FU2Hit),.FU3Hit(FU3Hit),
  .FU0Data(FU0Data),.FU1Data(FU1Data),.FU2Data(FU2Data),.FU3Data(FU3Data),
  .smpc0(p0_smpc),.smpc1(p1_smpc),.smpc2(p2_smpc),.smpc3(p3_smpc),
  .rsEn0(p0_rsEn&&~p0_lsfwd),.rsEn1(p1_rsEn&&~p1_lsfwd),.rsEn2(p2_rsEn&&~p2_lsfwd),.rsEn3(p3_rsEn&&~p3_lsfwd)
  );  
  
  wrtdata_combine wcomb0_mod(.data(dc_wdataP_reg[0]),.dataN(dc_wdataPX_reg[0]),.pdata(dc_pdataP_reg[0]),.en(1'b1),
    .odata(st0_data),.odataN(st0_dataX),.opdata(st0_pbit),.low(wreq_data_reg[0][`lsaddr_low]),.sz(wreq_data_reg[0][`lsaddr_sz]));
  wrtdata_combine wcomb1_mod(.data(dc_wdataP_reg[1]),.dataN(dc_wdataPX_reg[1]),.pdata(dc_pdataP_reg[1]),.en(1'b1),
      .odata(st1_data),.odataN(st1_dataX),.opdata(st1_pbit),.low(wreq_data_reg[1][`lsaddr_low]),.sz(wreq_data_reg[1][`lsaddr_sz]));

  
  pwire [127+8:0]           wb1_dataA;
  pwire [127+8:0]           wb1_dataB;
  pwire [1:0]               wb1_pbitA;
  pwire [1:0]               wb1_pbitB;
  pwire [`lsfxdata_width-1:0] wb1_xdataA;
  pwire [`lsfxdata_width-1:0] wb1_xdataB;
  pwire [127+8:0]           wb0_dataA;
  pwire [127+8:0]           wb0_dataB;
  pwire [1:0]               wb0_pbitA;
  pwire [1:0]               wb0_pbitB;
  pwire [`lsfxdata_width-1:0] wb0_xdataA;
  pwire [`lsfxdata_width-1:0] wb0_xdataB;
  pwire [127+8:0]           sso_data;
  pwire [3:0]               sso_bnkread;

  
  lsq_decide_ret help_to_retire_mod(
  .clk(clk),
  .rst(rst),
  .bStall((mem_II_stall||mem_II_stall2)&&has_store),
  .dataB_ret_mask(ret_xenab),
  .dataB_ld_confl(ret_xldconfl),
  .dataB_wait_confl(ret_xsmpconfl),
  .dataB_excpt({ret_xdata[5][`lsqxcept_xcept],ret_xdata[4][`lsqxcept_xcept],
    ret_xdata[3][`lsqxcept_xcept],ret_xdata[2][`lsqxcept_xcept],
    ret_xdata[1][`lsqxcept_xcept],ret_xdata[0][`lsqxcept_xcept]}),
  .dataB_exbits({ret_xdata[5][3:0],ret_xdata[4][3:0],ret_xdata[3][3:0],
    ret_xdata[2][3:0],ret_xdata[1][3:0],ret_xdata[0][3:0]}),
  .dataB_thread(1'b0), 
  .dataB_II(retM_data_shr[`lsqshare_II]),
  .dataB_data_shr(retM_data_shr),
  .dataB_II0(ret_xdata[0][-6+`lsqxcept_II]),.dataB_II1(ret_xdata[1][-6+`lsqxcept_II]),
  .dataB_II2(ret_xdata[2][-6+`lsqxcept_II]),.dataB_II3(ret_xdata[3][-6+`lsqxcept_II]),
  .dataB_II4(ret_xdata[4][-6+`lsqxcept_II]),.dataB_II5(ret_xdata[5][-6+`lsqxcept_II]),
  .dataB_ready(retB_en),
  .dataB_enOut(retB_clkEn),
  .cntrl_II(mem_II_upper_in),
  .out_II(mem_II_upper),
  .retire_enOut(mem_II_bits_ret),  .retire_fine(mem_II_bits_fine), .retire_ldconfl(mem_II_bits_ldconfl), .retire_except(mem_II_bits_except),
  .retire_exbitsx6(mem_II_exbitsx6),.retire_waitconfl(mem_II_bits_waitconfl),
  .dataB_shr_out(retM_data_shr_reg),
  .doRetire(doRetire_d),
  .except(except),
  .except_thread(1'b0)
  );

  assign has_store=retM_data_shr[`lsqshare_wrt0]!=3'd7;



  get_ben_een getBen0_mod(
  .low(wreq_data_reg[0][`lsaddr_low]),
  .sz(wreq_data_reg[0][`lsaddr_sz]),
  .bgn0(wreq_data_reg[0][`lsaddr_bank0]),
  .end0(wreq_dcEnd[0]),
  .bgnBen(wreq_bben[0]),
  .endBen(wreq_endben[0])
  );
      
  get_ben_een getBen1_mod(
  .low(wreq_data_reg[1][`lsaddr_low]),
  .sz(wreq_data_reg[1][`lsaddr_sz]),
  .bgn0(wreq_data_reg[1][`lsaddr_bank0]),
  .end0(wreq_dcEnd[1]),
  .bgnBen(wreq_bben[1]),
  .endBen(wreq_endben[1])
  );
  
  assign stall_LSQ=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LDQ,doStall_STQ | doStall_WQ};
  assign stall_cntrl=|{doStall_rs[3:0],doStall_alloc,doStall_LSQ,doStall_LDQ,doStall_STQ | doStall_WQ};
  assign stall_LDQ=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LSQ,doStall_STQ | doStall_WQ};
  assign stall_STQ=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LSQ,doStall_LDQ | doStall_WQ};
  assign stall_WQ=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LSQ,doStall_LDQ,doStall_STQ};
  assign stall=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LSQ,doStall_LDQ,doStall_STQ | doStall_WQ};

  assign aStall_STQ=wreq_stall| &wreq_en_reg[2:1];
  assign aStall_LSQ=aDoStall_STQ|wreq_stall| &wreq_en_reg[2:1];


  assign wreq_stall=bus_holds_addrcalc_reg2|miss_holds_addrcalc_reg2|miss_pause_addrcalc_reg2|insert_isData_reg2;
      
  assign st0_adata=wreq_data_reg[0];
  assign st0_en=wreq_en_reg[0];
  assign st0_bank1=wreq_dcEnd[0];
  assign st0_bgn_ben=wreq_bben[0];
  assign st0_end_ben=wreq_endben[0];

  assign st1_adata=wreq_data_reg[1];
  assign st1_en=wreq_en_reg[1];
  assign st1_bank1=wreq_dcEnd[1];
  assign st1_bgn_ben=wreq_bben[1];
  assign st1_end_ben=wreq_endben[1];

  reg [`lsaddr_width-1:0] wrq_dta[3:0];
  reg [3:0] wrq_bgnb[3:0];
  reg [3:0] wrq_endb[3:0];

  function [1:0] get_xconf;
    input pwire [`lsaddr_width-1:0] A;
    input pwire [`lsaddr_width-1:0] B;
    input pwire [3:0] A_bgn_ben;
    input pwire [3:0] A_end_ben;
    input pwire [3:0] B_bgn_ben;
    input pwire [3:0] B_end_ben;
    integer b;
    reg [31:0] A_b;
    reg [31:0] B_b;
    reg [3:0] a;
    reg [3:0] b;
    begin
        A_b=A[`lsaddr_banks];
        B_b=B[`lsaddr_banks];
        get_xconfl=2'b0;
        for(b=0;b<32;b=b+1) begin
            if (A_b[b] && B_b[b]) begin
                get_xconf[0]=1'b1;
                a=4'hf;
                b=4'hf;
                if (b=A[`lsaddr_begin0]) a=A_bgn_ben;
                if (b=A[`lsaddr_end0])   a=A_end_ben;
                if (b=B[`lsaddr_begin0]) b=B_bgn_ben;
                if (b=B[`lsaddr_end0])   b=B_end_ben;
                if ((a&b)!=4'b0) get_xconfl[1]=1'b1; //or statement
            end
        end
    end
  endfunction

  assign wreq_xconfl[0]=clkX1 ? get_xconf(wrq_dta[0],wrq_dta[1],wrq_bgnb[0],wrq_endb[0],wrq_bgnb[1],wrq_endb[1])[1] : 1'bz;
  assign wreq_xconfl[0]=clkX0 ? 1'b0 : 1'bz;

  assign wreq_xconfl[1]=clkX1 ? get_xconf(wrq_dta[3],wrq_dta[4],wrq_bgnb[3],wrq_endb[3],wrq_bgnb[4],wrq_endb[4])[1] : 1'bz;
  assign wreq_xconfl[1]=clkX0 ? 1'b0 : 1'bz;

  assign wreq_confl[0]=clkX1 ? get_xconf(wrq_dta[0],wrq_dta[3],wrq_bgnb[0],wrq_endb[0],wrq_bgnb[3],wrq_endb[3])[0] : 1'bz;
  assign wreq_confl[0]=clkX0 ? get_xconf(wrq_dta[0],wrq_dta[4],wrq_bgnb[0],wrq_endb[0],wrq_bgnb[4],wrq_endb[4])[1] : 1'bz;
  assign wreq_confl[1]=clkX1 ? get_xconf(wrq_dta[1],wrq_dta[4],wrq_bgnb[1],wrq_endb[1],wrq_bgnb[4],wrq_endb[4])[0] : 1'bz;
  assign wreq_confl[1]=clkX0 ? get_xconf(wrq_dta[1],wrq_dta[3],wrq_bgnb[1],wrq_endb[1],wrq_bgnb[3],wrq_endb[3])[1] : 1'bz;

  always @* begin
      if (clkX0) wrq_dta[0]=wreq_data[0]; else wrq_dta[0]='z;
      if (clkX1) wrq_dta[1]=wreq_data[0]; else wrq_dta[1]='z;
      if (clkX0) wrq_dta[3]=wreq_data[1]; else wrq_dta[2]='z;
      if (clkX1) wrq_dta[4]=wreq_data[1]; else wrq_dta[3]='z;
      if (clkX0) wrq_bgnb[0]=wreq_bgn_ben[0]; else wrq_bgnb[0]='z;
      if (clkX1) wrq_bgnb[1]=wreq_bgn_ben[0]; else wrq_bgnb[1]='z;
      if (clkX0) wrq_bgnb[3]=wreq_bgn_ben[1]; else wrq_bgnb[2]='z;
      if (clkX1) wrq_bgnb[4]=wreq_bgn_ben[1]; else wrq_bgnb[3]='z;
      if (clkX0) wrq_endb[0]=wreq_end_ben[0]; else wrq_endb[0]='z;
      if (clkX1) wrq_endb[1]=wreq_end_ben[0]; else wrq_endb[1]='z;
      if (clkX0) wrq_endb[3]=wreq_end_ben[1]; else wrq_endb[2]='z;
      if (clkX1) wrq_endb[4]=wreq_end_ben[1]; else wrq_endb[3]='z;
  end

  always @(posedge clk) begin
    st_stall_reg<=st_stall;
    if (rst) begin
	wreq_en_reg<=2'b0;
	wreq_data_reg[0]<=0;
	wreq_data_reg[1]<=0;
	dc_wdataP_reg[0]<=0;
	dc_wdataP_reg[1]<=0;
	dc_pdataP_reg[0]<=0;
	dc_pdataP_reg[1]<=0;
    end else if (!wreq_stall && !wreq_confl && !wreq_en_reg[3:2]) begin
        wreq_en_reg<={2'b0,wreq_en&wreq_xconfl};
        wreq_data_reg[0]<=wreq_data[0];
        wreq_data_reg[1]<=wreq_data[1];
        dc_wdataP_reg[0]<=dc_wdataP[0];
        dc_wdataP_reg[1]<=dc_wdataP[1];
        dc_pdataP_reg[0]<=dc_pdataP[0];
        dc_pdataP_reg[1]<=dc_pdataP[1];
    end else if (!wreq_stall && !wreq_confl && !wreq_en_reg[3]) begin
        wreq_en_reg<={1'b0,wreq_en&wreq_xconfl,wreq_en_reg[2]};
        wreq_data_reg<={wreq_data[0],wreq_data[1],wreq_data[0],wreq_data_reg[2]};
        dc_wdataP_reg<={dc_wdataP[0],dc_wdataP[1],dc_wdataP[0],dc_wdataP_reg[2]};
        dc_pdataP_reg<={dc_pdataP[0],dc_pdataP[1],dc_pdataP[0],dc_pdataP_reg[2]};
    end else if (!wreq_stall && wreq_confl) begin
        wreq_en_reg<={wreq_en_reg[2]&~wreq_crossdep_vec,wreq_en[1]&wreq_xconfl[1],wreq_crossdep_vec,wreq_en[0]&wreq_xconfl[0]};
        wreq_data_reg<={wreq_data_reg[2],wreq_data[1],wreq_data_reg[2],wreq_data[0]};
        dc_wdataP_reg<={dc_wdataP_reg[2],dc_wdataP[1],dc_wdataP_reg[2],dc_wdataP[0]};
        dc_pdataP_reg<={dc_pdataP_reg[2],dc_pdataP[1],dc_pdataP_reg[2],dc_pdataP[0]};
    end else begin
        wreq_en_reg<=2'b0;
    end
  end

endmodule
