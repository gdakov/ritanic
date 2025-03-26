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
`include "../fpoperations.sv"

//warning: rs*_alloc means allocate rat entry, not register
//rs*_alt means use store rs

module backend(
  clk,
  clkREF,
  clkREF2,
  clkREF3,
  clkREF4,
  clkREF5,
  stall_clkREF,
  rst,
  doStall,
  do_rst_sched,

  thread,
  bundle_in,
  except,
  exceptIP,
  excpt_attr,
  excpt_due_jump,
  except_set_flag,
  excpt_ght,
  excpt_ght2,
  except_jmp_mask_en,
  except_jmp_mask,
  req_addr,
  req_mlbAttr,
  req_mlbEn,
  bus_mlb_data,
  bus_mlb_en,

  newAttr,

  MSI_exp_addr,
  MSI_exp_en,
  MSI_swap_want,
  MSI_swap_repl,

  dc_expun_addr,
  dc_expun_en,
  dc_expun_mkshared,

  rs0i0_rA,rs0i0_rA_use,rs0i0_rA_useF,rs0i0_rA_isV,rs0i0_rA_isAnyV,
  rs0i0_rB,rs0i0_rB_use,rs0i0_rB_useF,rs0i0_rB_isV,rs0i0_rB_isAnyV,rs0i0_useBConst,
  rs0i0_rT,rs0i0_rT_use,rs0i0_rT_useF,rs0i0_rT_isV, 
  rs0i0_port,
  rs0i0_operation,
  rs0i0_en,
  rs0i0_const,
  rs0i0_index,
  rs0i0_IPRel,
  rs0i0_afterTaken,
  rs0i0_alt,
  rs0i0_alloc,
  rs0i0_allocF,
  rs0i0_allocR,
  rs0i0_lsi,
  rs0i0_ldst_flg,
  rs0i0_enA,
  rs0i0_enB,

  rs0i1_rA,rs0i1_rA_use,rs0i1_rA_useF,rs0i1_rA_isV,rs0i1_rA_isAnyV,rs0i1_useAConst,
  rs0i1_rB,rs0i1_rB_use,rs0i1_rB_useF,rs0i1_rB_isV,rs0i1_rB_isAnyV,rs0i1_useBConst,
  rs0i1_rT,rs0i1_rT_use,rs0i1_rT_useF,rs0i1_rT_isV,
  rs0i1_port,
  rs0i1_operation,
  rs0i1_en,
  rs0i1_const,
  rs0i1_index,
  rs0i1_IPRel,
  rs0i1_afterTaken,
  rs0i1_alloc,
  rs0i1_allocF,
  rs0i1_allocR,
  rs0i1_flagDep,
  rs0i1_lastFl,
  rs0i1_lsi,
  rs0i1_ldst_flg,
  rs0i1_flag_wr,

  rs0i2_rA,rs0i2_rA_use,rs0i2_rA_useF,rs0i2_rA_isV,rs0i2_rA_isAnyV,rs0i2_useAConst,
  rs0i2_rB,rs0i2_rB_use,rs0i2_rB_useF,rs0i2_rB_isV,rs0i2_rB_isAnyV,rs0i2_useBConst,
  rs0i2_rT,rs0i2_rT_use,rs0i2_rT_useF,rs0i2_rT_isV,
  rs0i2_port,
  rs0i2_operation,
  rs0i2_en,
  rs0i2_const,
  rs0i2_index,
  rs0i2_IPRel,
  rs0i2_afterTaken,
  rs0i2_alloc,
  rs0i2_allocF,
  rs0i2_allocR,
  rs0i2_flagDep,
  rs0i2_lastFl,
  rs0i2_flag_wr,

  rs1i0_rA,rs1i0_rA_use,rs1i0_rA_useF,rs1i0_rA_isV,rs1i0_rA_isAnyV,
  rs1i0_rB,rs1i0_rB_use,rs1i0_rB_useF,rs1i0_rB_isV,rs1i0_rB_isAnyV,rs1i0_useBConst,
  rs1i0_rT,rs1i0_rT_use,rs1i0_rT_useF,rs1i0_rT_isV,
  rs1i0_port,
  rs1i0_operation,
  rs1i0_en,
  rs1i0_const,
  rs1i0_index,
  rs1i0_IPRel,
  rs1i0_afterTaken,
  rs1i0_alt,
  rs1i0_alloc,
  rs1i0_allocF,
  rs1i0_allocR,
  rs1i0_lsi,
  rs1i0_ldst_flg,
  rs1i0_enA,
  rs1i0_enB,

  rs1i1_rA,rs1i1_rA_use,rs1i1_rA_useF,rs1i1_rA_isV,rs1i1_rA_isAnyV,rs1i1_useAConst,
  rs1i1_rB,rs1i1_rB_use,rs1i1_rB_useF,rs1i1_rB_isV,rs1i1_rB_isAnyV,rs1i1_useBConst,
  rs1i1_rT,rs1i1_rT_use,rs1i1_rT_useF,rs1i1_rT_isV,
  rs1i1_port,
  rs1i1_operation,
  rs1i1_en,
  rs1i1_const,
  rs1i1_index,
  rs1i1_IPRel,
  rs1i1_afterTaken,
  rs1i1_alloc,
  rs1i1_allocF,
  rs1i1_allocR,
  rs1i1_flagDep,
  rs1i1_lastFl,
  rs1i1_lsi,
  rs1i1_ldst_flg,
  rs1i1_flag_wr,

  rs1i2_rA,rs1i2_rA_use,rs1i2_rA_useF,rs1i2_rA_isV,rs1i2_rA_isAnyV,rs1i2_useAConst,
  rs1i2_rB,rs1i2_rB_use,rs1i2_rB_useF,rs1i2_rB_isV,rs1i2_rB_isAnyV,rs1i2_useBConst,
  rs1i2_rT,rs1i2_rT_use,rs1i2_rT_useF,rs1i2_rT_isV,
  rs1i2_port,
  rs1i2_operation,
  rs1i2_en,
  rs1i2_const,
  rs1i2_index,
  rs1i2_IPRel,
  rs1i2_afterTaken,
  rs1i2_alloc,
  rs1i2_allocF,
  rs1i2_allocR,
  rs1i2_flagDep,
  rs1i2_lastFl,
  rs1i2_flag_wr,

  rs2i0_rA,rs2i0_rA_use,rs2i0_rA_useF,rs2i0_rA_isV,rs2i0_rA_isAnyV,
  rs2i0_rB,rs2i0_rB_use,rs2i0_rB_useF,rs2i0_rB_isV,rs2i0_rB_isAnyV,rs2i0_useBConst,
  rs2i0_rT,rs2i0_rT_use,rs2i0_rT_useF,rs2i0_rT_isV,
  rs2i0_port,
  rs2i0_operation,
  rs2i0_en,
  rs2i0_const,
  rs2i0_index,
  rs2i0_IPRel,
  rs2i0_afterTaken,
  rs2i0_alt,
  rs2i0_alloc,
  rs2i0_allocF,
  rs2i0_allocR,
  rs2i0_lsi,
  rs2i0_ldst_flg,
  rs2i0_enA,
  rs2i0_enB,

  rs2i1_rA,rs2i1_rA_use,rs2i1_rA_useF,rs2i1_rA_isV,rs2i1_rA_isAnyV,rs2i1_useAConst,
  rs2i1_rB,rs2i1_rB_use,rs2i1_rB_useF,rs2i1_rB_isV,rs2i1_rB_isAnyV,rs2i1_useBConst,
  rs2i1_rT,rs2i1_rT_use,rs2i1_rT_useF,rs2i1_rT_isV,
  rs2i1_port,
  rs2i1_operation,
  rs2i1_en,
  rs2i1_const,
  rs2i1_index,
  rs2i1_IPRel,
  rs2i1_afterTaken,
  rs2i1_alloc,
  rs2i1_allocF,
  rs2i1_allocR,
  rs2i1_flagDep,
  rs2i1_lastFl,
  rs2i1_lsi,
  rs2i1_ldst_flg,
  rs2i1_flag_wr,

  rs2i2_rA,rs2i2_rA_use,rs2i2_rA_useF,rs2i2_rA_isV,rs2i2_rA_isAnyV,rs2i2_useAConst,
  rs2i2_rB,rs2i2_rB_use,rs2i2_rB_useF,rs2i2_rB_isV,rs2i2_rB_isAnyV,rs2i2_useBConst,
  rs2i2_rT,rs2i2_rT_use,rs2i2_rT_useF,rs2i2_rT_isV,
  rs2i2_port,
  rs2i2_operation,
  rs2i2_en,
  rs2i2_const,
  rs2i2_index,
  rs2i2_IPRel,
  rs2i2_afterTaken,
  rs2i2_alloc,
  rs2i2_allocF,
  rs2i2_allocR,
  rs2i2_flagDep,
  rs2i2_lastFl,
  rs2i2_mul,
  rs2i2_flag_wr,
//end reordered small instructions
//begin instructions in program order
  instr0_rT, 
  instr0_en,
  instr0_wren, 
  instr0_IPOff,
  instr0_afterTaken,
  instr0_rT_useF,
  instr0_rT_isV,
  instr0_port,
  instr0_magic,
  instr0_last,
  instr0_aft_spc,
  instr0_err,
  
  instr1_rT,
  instr1_en,
  instr1_wren,
  instr1_IPOff,
  instr1_afterTaken,
  instr1_rT_useF,
  instr1_rT_isV,
  instr1_port,
  instr1_magic,
  instr1_last,
  instr1_aft_spc,
  instr1_err,
    
  instr2_rT,
  instr2_en,
  instr2_wren,
  instr2_IPOff,
  instr2_afterTaken,
  instr2_rT_useF,
  instr2_rT_isV,
  instr2_port,
  instr2_magic,
  instr2_last,
  instr2_aft_spc,
  instr2_err,
  
  instr3_rT,
  instr3_en,
  instr3_wren,
  instr3_IPOff,
  instr3_afterTaken,
  instr3_rT_useF,
  instr3_rT_isV,
  instr3_port,
  instr3_magic,
  instr3_last,
  instr3_aft_spc,
  instr3_err,
  
  instr4_rT,
  instr4_en,
  instr4_wren,
  instr4_IPOff,
  instr4_afterTaken,
  instr4_rT_useF,
  instr4_rT_isV,
  instr4_port,
  instr4_magic,
  instr4_last,
  instr4_aft_spc,
  instr4_err,
  
  instr5_rT,
  instr5_en,
  instr5_wren,
  instr5_IPOff,
  instr5_afterTaken,
  instr5_rT_useF,
  instr5_rT_isV,
  instr5_port,
  instr5_magic,
  instr5_last,
  instr5_aft_spc,
  instr5_err,

  instr6_rT,
  instr6_en,
  instr6_wren,
  instr6_IPOff,
  instr6_afterTaken,
  instr6_rT_useF,
  instr6_rT_isV,
  instr6_port,
  instr6_magic,
  instr6_last,
  instr6_aft_spc,
  instr6_err,

  instr7_rT,
  instr7_en,
  instr7_wren,
  instr7_IPOff,
  instr7_afterTaken,
  instr7_rT_useF,
  instr7_rT_isV,
  instr7_port,
  instr7_magic,
  instr7_last,
  instr7_aft_spc,
  instr7_err,

  instr8_rT,
  instr8_en,
  instr8_wren,
  instr8_IPOff,
  instr8_afterTaken,
  instr8_rT_useF,
  instr8_rT_isV,
  instr8_port,
  instr8_magic,
  instr8_last,
  instr8_aft_spc,
  instr8_err,

  instr9_rT,
  instr9_en,
  instr9_wren,
  instr9_IPOff,
  instr9_afterTaken,
  instr9_rT_useF,
  instr9_rT_isV,
  instr9_port,
  instr9_magic,
  instr9_last,
  instr9_aft_spc,
  instr9_err,

  jump0Type,jump0Pos,jump0Pred,jump0IP,jump0Mask,jump0Attr,jump0CLP,
  jump1Type,jump1Pos,jump1Pred,jump1IP,jump1Mask,jump1Attr,jump1CLP,
  jump0TbufWay,jump0JmpInd,jump0GHT,jump0GHT2,jump0Val,
  jump1TbufWay,jump1JmpInd,jump1GHT,jump1GHT2,jump1Val,
  jump0SC,jump0Miss,jump0TbufOnly,
  jump1SC,jump1Miss,jump1TbufOnly,
  instr_fsimd,
  baseIP,
  wrt0,wrt1,wrt2,

  jupd0_en,jupdt0_en,jupd0_ght_en,jupd0_ght2_en,jupd0_addr,jupd0_baddr,jupd0_sc,jupd0_tk,
  jupd1_en,jupdt1_en,jupd1_ght_en,jupd1_ght2_en,jupd1_addr,jupd1_baddr,jupd1_sc,jupd1_tk,
  
  msrss_no,msrss_en,msrss_data,
  
  insBus_en,
  insBus_io,
  insBus_req,
  insBus_dirty,
  insBus_exclusive,
  insBus_data,
  insBus_dataPTR,
  insBus_register,
  insBus_LSQ,
  reqBus_en,
  reqBus_addr,
  reqBus_req,
  reqBus_want_excl,
  reqBus_dupl,
  reqBus_io,
  reqBus_sz,
  reqBus_low,
  reqBus_bank0,
  reqBus_register,
  reqBus_LSQ,

  lsr_wr_ext_data, p_ext_LSQ, dc_ext_wrEn,
  lsr_wr_out_data, p_out_LSQ, dc_out_wrEn,

  pfxWQ,pfx_wdata,pfx_wdataU,pfx_pdata,pfx_dataEn,
  pfyWQ,pfy_wdata,pfy_wdataU,pfy_pdata,pfy_dataEn,//outputs

  bofh, pfy,

  piff_paff_A,
  piff_paff_B,
 // piff,

  wr0_hit,
  wr0_addrE,wr0_addrO,
  wr0_banks,
  wr0_begin,wr0_end,
  wr0_bgn_ben,wr0_end_ben,
  wr0_odd,wr0_split,
  wr0_data,
  wr0_pbit,wr0_d128,
  wr1_hit,
  wr1_addrE,wr1_addrO,
  wr1_banks,
  wr1_begin,wr1_end,
  wr1_bgn_ben,wr1_end_ben,
  wr1_odd,wr1_split,
  wr1_data,
  wr1_pbit,wr1_d128,
  wrStall
//  extBus_en,
//  extBus_addr,
//  extBus_req,
//  extBus_want_excl
//  wbBus_en,
//  wbBus_req
  );
  localparam DATA_WIDTH=66;//65 bit + 1 parity
  localparam OPERATION_WIDTH=`operation_width+5+3;
  localparam RRF_WIDTH=6;
  localparam IN_REG_WIDTH=6;
  localparam PORT_WIDTH=4;
  localparam REG_WIDTH=9;
  localparam IP_WIDTH=48;
  localparam PORT_LOAD=4'd1;
  localparam PORT_STORE=4'd2;
  localparam PORT_SHIFT=4'd3;
  localparam PORT_ALU=4'd4;
  localparam PORT_MUL=4'd5;
  localparam PORT_FADD=4'd6;
  localparam PORT_FMUL=4'd7;
  localparam PORT_FANY=4'd8;
  localparam PORT_VADD=4'd9;
  localparam PORT_VCMP=4'd10;
  localparam PORT_VANY=4'd11;
  localparam BUS_WIDTH=512;
  localparam REQ_WIDTH=10;
  localparam PADDR_WIDTH=44;
  localparam BANK_WIDTH=`dcache1_data_width;
  localparam FN_WIDTH=10;
  localparam SIMD_WIDTH=70;//half width. 68 data bits and 2 parity bits 
  localparam CONST_WIDTH=44;
  parameter [5:0] BUS_ID=5'd0;
  parameter [6:0] BUS_ID2=6'd0;
  
  input pwire clk;
  input pwire clkREF;
  input pwire clkREF2;
  input pwire clkREF3;
  input pwire clkREF4;
  input pwire clkREF5;
  input pwire stall_clkREF;
  input pwire rst;
  output pwire doStall;

  output pwire do_rst_sched;
  
  input pwire thread;
  input pwire bundle_in;

  output pwire except;
  output pwire [62:0] exceptIP;
  output pwire [3:0] excpt_attr;
  output pwire excpt_due_jump;
  output pwire [7:0] excpt_ght;
  output pwire [15:0] excpt_ght2;
  output pwire except_set_flag;
  output pwire except_jmp_mask_en;
  output pwire [3:0] except_jmp_mask;

  input pwire [30:0] req_addr; 
  input pwire [3:0] req_mlbAttr;
  input pwire req_mlbEn;
  output pwire [`cmlbData_width-1:0] bus_mlb_data;
  output pwire bus_mlb_en;

  input pwire [3:0] newAttr;
  
  input pwire [36:0] MSI_exp_addr;
  input pwire MSI_exp_en;
  input pwire MSI_swap_want;
  input pwire MSI_swap_repl;
  
  output pwire [36:0] dc_expun_addr;
  output pwire dc_expun_en;
  ouput dc_expun_mkshared;


  input pwire [IN_REG_WIDTH-1:0] rs0i0_rA;
  input pwire rs0i0_rA_use;
  input pwire rs0i0_rA_useF;
  input pwire rs0i0_rA_isV;
  input pwire rs0i0_rA_isAnyV;
  input pwire [IN_REG_WIDTH-1:0] rs0i0_rB;
  input pwire rs0i0_rB_use;
  input pwire rs0i0_rB_useF;
  input pwire rs0i0_rB_isV;
  input pwire rs0i0_rB_isAnyV;
  input pwire rs0i0_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs0i0_rT;
  input pwire rs0i0_rT_use;
  input pwire rs0i0_rT_useF;
  input pwire rs0i0_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs0i0_port;
  input pwire [OPERATION_WIDTH-1:0] rs0i0_operation;
  input pwire rs0i0_en;
  input pwire [DATA_WIDTH-1:0] rs0i0_const;
  input pwire [3:0] rs0i0_index;
  input pwire rs0i0_IPRel;
  input pwire rs0i0_afterTaken;
  input pwire rs0i0_alt;
  input pwire rs0i0_alloc;
  input pwire rs0i0_allocF;
  input pwire rs0i0_allocR;
  input pwire [5:0] rs0i0_lsi; 
  input pwire rs0i0_ldst_flg; 
  input pwire rs0i0_enA;
  input pwire rs0i0_enB; 
 
  input pwire [IN_REG_WIDTH-1:0] rs0i1_rA;
  input pwire rs0i1_rA_use;
  input pwire rs0i1_rA_useF;
  input pwire rs0i1_rA_isV;
  input pwire rs0i1_rA_isAnyV;
  input pwire rs0i1_useAConst;
  input pwire [IN_REG_WIDTH-1:0] rs0i1_rB;
  input pwire rs0i1_rB_use;
  input pwire rs0i1_rB_useF;
  input pwire rs0i1_rB_isV;
  input pwire rs0i1_rB_isAnyV;
  input pwire rs0i1_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs0i1_rT;
  input pwire rs0i1_rT_use;
  input pwire rs0i1_rT_useF;
  input pwire rs0i1_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs0i1_port;
  input pwire [OPERATION_WIDTH-1:0] rs0i1_operation;
  input pwire rs0i1_en;
  input pwire [DATA_WIDTH-1:0] rs0i1_const;
  input pwire [3:0] rs0i1_index;
  input pwire rs0i1_IPRel;
  input pwire rs0i1_afterTaken;
  input pwire rs0i1_alloc;
  input pwire rs0i1_allocF;
  input pwire rs0i1_allocR;
  input pwire [3:0] rs0i1_flagDep;
  input pwire rs0i1_lastFl;
  input pwire [5:0] rs0i1_lsi;  
  input pwire rs0i1_ldst_flg; 
  input pwire rs0i1_flag_wr;
  
  input pwire [IN_REG_WIDTH-1:0] rs0i2_rA;
  input pwire rs0i2_rA_use;
  input pwire rs0i2_rA_useF;
  input pwire rs0i2_rA_isV;
  input pwire rs0i2_rA_isAnyV;
  input pwire rs0i2_useAConst;
  input pwire [IN_REG_WIDTH-1:0] rs0i2_rB;
  input pwire rs0i2_rB_use;
  input pwire rs0i2_rB_useF;
  input pwire rs0i2_rB_isV;
  input pwire rs0i2_rB_isAnyV;
  input pwire rs0i2_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs0i2_rT;
  input pwire rs0i2_rT_use;
  input pwire rs0i2_rT_useF;
  input pwire rs0i2_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs0i2_port;
  input pwire [OPERATION_WIDTH-1:0] rs0i2_operation;
  input pwire rs0i2_en;
  input pwire [DATA_WIDTH-1:0] rs0i2_const;
  input pwire [3:0] rs0i2_index;
  input pwire rs0i2_IPRel;
  input pwire rs0i2_afterTaken;
  input pwire rs0i2_alloc;
  input pwire rs0i2_allocF;
  input pwire rs0i2_allocR;
  input pwire [3:0] rs0i2_flagDep;
  input pwire rs0i2_lastFl;
  input pwire rs0i2_flag_wr;
  
  input pwire [IN_REG_WIDTH-1:0] rs1i0_rA;
  input pwire rs1i0_rA_use;
  input pwire rs1i0_rA_useF;
  input pwire rs1i0_rA_isV;
  input pwire rs1i0_rA_isAnyV;
  input pwire [IN_REG_WIDTH-1:0] rs1i0_rB;
  input pwire rs1i0_rB_use;
  input pwire rs1i0_rB_useF;
  input pwire rs1i0_rB_isV;
  input pwire rs1i0_rB_isAnyV;
  input pwire rs1i0_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs1i0_rT;
  input pwire rs1i0_rT_use;
  input pwire rs1i0_rT_useF;
  input pwire rs1i0_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs1i0_port;
  input pwire [OPERATION_WIDTH-1:0] rs1i0_operation;
  input pwire rs1i0_en;
  input pwire [DATA_WIDTH-1:0] rs1i0_const;
  input pwire [3:0] rs1i0_index;
  input pwire rs1i0_IPRel;
  input pwire rs1i0_afterTaken;
  input pwire rs1i0_alt;
  input pwire rs1i0_alloc;
  input pwire rs1i0_allocF;
  input pwire rs1i0_allocR;
  input pwire [5:0] rs1i0_lsi;  
  input pwire rs1i0_ldst_flg; 
  input pwire rs1i0_enA;
  input pwire rs1i0_enB; 
  
  input pwire [IN_REG_WIDTH-1:0] rs1i1_rA;
  input pwire rs1i1_rA_use;
  input pwire rs1i1_rA_useF;
  input pwire rs1i1_rA_isV;
  input pwire rs1i1_rA_isAnyV;
  input pwire rs1i1_useAConst;
  input pwire [IN_REG_WIDTH-1:0] rs1i1_rB;
  input pwire rs1i1_rB_use;
  input pwire rs1i1_rB_useF;
  input pwire rs1i1_rB_isV;
  input pwire rs1i1_rB_isAnyV;
  input pwire rs1i1_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs1i1_rT;
  input pwire rs1i1_rT_use;
  input pwire rs1i1_rT_useF;
  input pwire rs1i1_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs1i1_port;
  input pwire [OPERATION_WIDTH-1:0] rs1i1_operation;
  input pwire rs1i1_en;
  input pwire [DATA_WIDTH-1:0] rs1i1_const;
  input pwire [3:0] rs1i1_index;
  input pwire rs1i1_IPRel;
  input pwire rs1i1_afterTaken;
  input pwire rs1i1_alloc;
  input pwire rs1i1_allocF;
  input pwire rs1i1_allocR;
  input pwire [3:0] rs1i1_flagDep;
  input pwire rs1i1_lastFl;
  input pwire [5:0] rs1i1_lsi;  
  input pwire rs1i1_ldst_flg; 
  input pwire rs1i1_flag_wr;

  input pwire [IN_REG_WIDTH-1:0] rs1i2_rA;
  input pwire rs1i2_rA_use;
  input pwire rs1i2_rA_useF;
  input pwire rs1i2_rA_isV;
  input pwire rs1i2_rA_isAnyV;
  input pwire rs1i2_useAConst;
  input pwire [IN_REG_WIDTH-1:0] rs1i2_rB;
  input pwire rs1i2_rB_use;
  input pwire rs1i2_rB_useF;
  input pwire rs1i2_rB_isV;
  input pwire rs1i2_rB_isAnyV;
  input pwire rs1i2_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs1i2_rT;
  input pwire rs1i2_rT_use;
  input pwire rs1i2_rT_useF;
  input pwire rs1i2_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs1i2_port;
  input pwire [OPERATION_WIDTH-1:0] rs1i2_operation;
  input pwire rs1i2_en;
  input pwire [DATA_WIDTH-1:0] rs1i2_const;
  input pwire [3:0] rs1i2_index;
  input pwire rs1i2_IPRel;
  input pwire rs1i2_afterTaken;
  input pwire rs1i2_alloc;
  input pwire rs1i2_allocF;
  input pwire rs1i2_allocR;
  input pwire [3:0] rs1i2_flagDep;
  input pwire rs1i2_lastFl;
  input pwire rs1i2_flag_wr;

  input pwire [IN_REG_WIDTH-1:0] rs2i0_rA;
  input pwire rs2i0_rA_use;
  input pwire rs2i0_rA_useF;
  input pwire rs2i0_rA_isV;
  input pwire rs2i0_rA_isAnyV;
  input pwire [IN_REG_WIDTH-1:0] rs2i0_rB;
  input pwire rs2i0_rB_use;
  input pwire rs2i0_rB_useF;
  input pwire rs2i0_rB_isV;
  input pwire rs2i0_rB_isAnyV;
  input pwire rs2i0_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs2i0_rT;
  input pwire rs2i0_rT_use;
  input pwire rs2i0_rT_useF;
  input pwire rs2i0_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs2i0_port;
  input pwire [OPERATION_WIDTH-1:0] rs2i0_operation;
  input pwire rs2i0_en;
  input pwire [DATA_WIDTH-1:0] rs2i0_const;
  input pwire [3:0] rs2i0_index;
  input pwire rs2i0_IPRel;
  input pwire rs2i0_afterTaken;
  input pwire rs2i0_alt;
  input pwire rs2i0_alloc;
  input pwire rs2i0_allocF;
  input pwire rs2i0_allocR;
  input pwire [5:0] rs2i0_lsi;  
  input pwire rs2i0_ldst_flg; 
  input pwire rs2i0_enA;
  input pwire rs2i0_enB; 
  
  input pwire [IN_REG_WIDTH-1:0] rs2i1_rA;
  input pwire rs2i1_rA_use;
  input pwire rs2i1_rA_useF;
  input pwire rs2i1_rA_isV;
  input pwire rs2i1_rA_isAnyV;
  input pwire rs2i1_useAConst;
  input pwire [IN_REG_WIDTH-1:0] rs2i1_rB;
  input pwire rs2i1_rB_use;
  input pwire rs2i1_rB_useF;
  input pwire rs2i1_rB_isV;
  input pwire rs2i1_rB_isAnyV;
  input pwire rs2i1_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs2i1_rT;
  input pwire rs2i1_rT_use;
  input pwire rs2i1_rT_useF;
  input pwire rs2i1_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs2i1_port;
  input pwire [OPERATION_WIDTH-1:0] rs2i1_operation;
  input pwire rs2i1_en;
  input pwire [DATA_WIDTH-1:0] rs2i1_const;
  input pwire [3:0] rs2i1_index;
  input pwire rs2i1_IPRel;
  input pwire rs2i1_afterTaken;
  input pwire rs2i1_alloc;
  input pwire rs2i1_allocF;
  input pwire rs2i1_allocR;
  input pwire [3:0] rs2i1_flagDep;
  input pwire rs2i1_lastFl;
  input pwire [5:0] rs2i1_lsi;  
  input pwire rs2i1_ldst_flg; 
  input pwire rs2i1_flag_wr;

  input pwire [IN_REG_WIDTH-1:0] rs2i2_rA;
  input pwire rs2i2_rA_use;
  input pwire rs2i2_rA_useF;
  input pwire rs2i2_rA_isV;
  input pwire rs2i2_rA_isAnyV;
  input pwire rs2i2_useAConst;
  input pwire [IN_REG_WIDTH-1:0] rs2i2_rB;
  input pwire rs2i2_rB_use;
  input pwire rs2i2_rB_useF;
  input pwire rs2i2_rB_isV;
  input pwire rs2i2_rB_isAnyV;
  input pwire rs2i2_useBConst;
  input pwire [IN_REG_WIDTH-1:0] rs2i2_rT;
  input pwire rs2i2_rT_use;
  input pwire rs2i2_rT_useF;
  input pwire rs2i2_rT_isV;
  input pwire [PORT_WIDTH-1:0] rs2i2_port;
  input pwire [OPERATION_WIDTH-1:0] rs2i2_operation;
  input pwire rs2i2_en;
  input pwire [DATA_WIDTH-1:0] rs2i2_const;
  input pwire [3:0] rs2i2_index;
  input pwire rs2i2_IPRel;
  input pwire rs2i2_afterTaken;
  input pwire rs2i2_alloc;
  input pwire rs2i2_allocF;
  input pwire rs2i2_allocR;
  input pwire [3:0] rs2i2_flagDep;
  input pwire rs2i2_lastFl;
  input pwire rs2i2_mul;
  input pwire rs2i2_flag_wr;
  
  input pwire [IN_REG_WIDTH-1:0] instr0_rT;
  input pwire instr0_en;
  input pwire instr0_wren;
  input pwire [8:0] instr0_IPOff;
  input pwire instr0_afterTaken;
  input pwire instr0_rT_useF;
  input pwire instr0_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr0_port;
  input pwire [3:0] instr0_magic;
  input pwire instr0_last;
  input pwire instr0_aft_spc;
  input pwire [1:0] instr0_err;
  input pwire [1:0] instr1_err;
  input pwire [1:0] instr2_err;
  input pwire [1:0] instr3_err;
  input pwire [1:0] instr4_err;
  input pwire [1:0] instr5_err;
  input pwire [1:0] instr6_err;
  input pwire [1:0] instr7_err;
  input pwire [1:0] instr8_err;
  
  input pwire [IN_REG_WIDTH-1:0] instr1_rT;
  input pwire instr1_en;
  input pwire instr1_wren;
  input pwire [8:0] instr1_IPOff;
  input pwire instr1_afterTaken;
  input pwire instr1_rT_useF;
  input pwire instr1_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr1_port;
  input pwire [3:0] instr1_magic;
  input pwire instr1_last;
  input pwire instr1_aft_spc;
  
  input pwire [IN_REG_WIDTH-1:0] instr2_rT;
  input pwire instr2_en;
  input pwire instr2_wren;
  input pwire [8:0] instr2_IPOff;
  input pwire instr2_afterTaken;
  input pwire instr2_rT_useF;
  input pwire instr2_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr2_port;
  input pwire [3:0] instr2_magic;
  input pwire instr2_last;
  input pwire instr2_aft_spc;
  
  input pwire [IN_REG_WIDTH-1:0] instr3_rT;
  input pwire instr3_en;
  input pwire instr3_wren;
  input pwire [8:0] instr3_IPOff;
  input pwire instr3_afterTaken;
  input pwire instr3_rT_useF;
  input pwire instr3_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr3_port;
  input pwire [3:0] instr3_magic;
  input pwire instr3_last;
  input pwire instr3_aft_spc;
  
  input pwire [IN_REG_WIDTH-1:0] instr4_rT;
  input pwire instr4_en;
  input pwire instr4_wren;
  input pwire [8:0] instr4_IPOff;
  input pwire instr4_afterTaken;
  input pwire instr4_rT_useF;
  input pwire instr4_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr4_port;
  input pwire [3:0] instr4_magic;
  input pwire instr4_last;
  input pwire instr4_aft_spc;
  
  input pwire [IN_REG_WIDTH-1:0] instr5_rT;
  input pwire instr5_en;
  input pwire instr5_wren;
  input pwire [8:0] instr5_IPOff;
  input pwire instr5_afterTaken;
  input pwire instr5_rT_useF;
  input pwire instr5_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr5_port;
  input pwire [3:0] instr5_magic;
  input pwire instr5_last;
  input pwire instr5_aft_spc;

  input pwire [IN_REG_WIDTH-1:0] instr6_rT;
  input pwire instr6_en;
  input pwire instr6_wren;
  input pwire [8:0] instr6_IPOff;
  input pwire instr6_afterTaken;
  input pwire instr6_rT_useF;
  input pwire instr6_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr6_port;
  input pwire [3:0] instr6_magic;
  input pwire instr6_last;
  input pwire instr6_aft_spc;

  input pwire [IN_REG_WIDTH-1:0] instr7_rT;
  input pwire instr7_en;
  input pwire instr7_wren;
  input pwire [8:0] instr7_IPOff;
  input pwire instr7_afterTaken;
  input pwire instr7_rT_useF;
  input pwire instr7_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr7_port;
  input pwire [3:0] instr7_magic;
  input pwire instr7_last;
  input pwire instr7_aft_spc;

  input pwire [IN_REG_WIDTH-1:0] instr8_rT;
  input pwire instr8_en;
  input pwire instr8_wren;
  input pwire [8:0] instr8_IPOff;
  input pwire instr8_afterTaken;
  input pwire instr8_rT_useF;
  input pwire instr8_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr8_port;
  input pwire [3:0] instr8_magic;
  input pwire instr8_last;
  input pwire instr8_aft_spc;

  input pwire [IN_REG_WIDTH-1:0] instr9_rT;
  input pwire instr9_en;
  input pwire instr9_wren;
  input pwire [8:0] instr9_IPOff;
  input pwire instr9_afterTaken;
  input pwire instr9_rT_useF;
  input pwire instr9_rT_isV;
  input pwire [PORT_WIDTH-1:0] instr9_port;
  input pwire [3:0] instr9_magic;
  input pwire instr9_last;
  input pwire instr9_aft_spc;
  
  input pwire [4:0] jump0Type;
  input pwire [3:0] jump0Pos;
  input pwire jump0Pred;
  input pwire [64:0] jump0IP;
  input pwire [3:0] jump0Mask;
  input pwire [3:0] jump0Attr;
  input pwire       jump0CLP;
  input pwire [4:0] jump1Type;
  input pwire [3:0] jump1Pos;
  input pwire jump1Pred;
  input pwire [64:0] jump1IP;
  input pwire [3:0] jump1Mask;
  input pwire [3:0] jump1Attr;
  input pwire       jump1CLP;
  input pwire jump0TbufWay;
  input pwire [1:0] jump0JmpInd;
  input pwire [7:0] jump0GHT;
  input pwire [15:0] jump0GHT2;
  input pwire        jump0Val;
  input pwire jump1TbufWay;
  input pwire [1:0] jump1JmpInd;
  input pwire [7:0] jump1GHT;
  input pwire [15:0] jump1GHT2;
  input pwire        jump1Val;
  input pwire [1:0] jump0SC;
  input pwire jump0Miss;
  input pwire jump0TbufOnly;
  input pwire [1:0] jump1SC;
  input pwire jump1Miss;
  input pwire jump1TbufOnly;
  input pwire [9:0] instr_fsimd;
  input pwire [62:0] baseIP;
  input pwire [5:0] wrt0;
  input pwire [5:0] wrt1;
  input pwire [5:0] wrt2;

  output pwire jupd0_en;
  output pwire jupdt0_en;
  output pwire jupd0_ght_en;
  output pwire jupd0_ght2_en;
  output pwire [15:0] jupd0_addr;
  output pwire [12:0] jupd0_baddr;
  output pwire [1:0] jupd0_sc;
  output pwire jupd0_tk;
  output pwire jupd1_en;
  output pwire jupdt1_en;
  output pwire jupd1_ght_en;
  output pwire jupd1_ght2_en;
  output pwire [15:0] jupd1_addr;
  output pwire [12:0] jupd1_baddr;
  output pwire [1:0] jupd1_sc;
  output pwire jupd1_tk;
  
  output pwire [15:0] msrss_no;
  output pwire msrss_en;
  output pwire [64:0] msrss_data;
  
  input pwire insBus_en;
  input pwire insBus_io;
  input pwire [REQ_WIDTH-1:0] insBus_req;
  input pwire insBus_dirty;
  input pwire insBus_exclusive;
  input pwire [BUS_WIDTH-1:0] insBus_data;
  input pwire [7:0] insBus_dataPTR;
  input pwire [8:0] insBus_register;
  input pwire [8:0] insBus_LSQ;

  output pwire reg reqBus_en;
  output pwire reg [43:7] reqBus_addr;
  output pwire reg [REQ_WIDTH-1:0] reqBus_req;
  output pwire reg reqBus_want_excl;
  output pwire reg reqBus_dupl;
  output pwire reg reqBus_io;
  output pwire reg [4:0] reqBus_sz;
  output pwire reg [1:0] reqBus_low;
  output pwire reg [4:0] reqBus_bank0;
  output pwire reg [8:0] reqBus_register;
  output pwire reg [8:9] reqBus_LSQ;

  input pwire [`lsaddr_width-1:0] lsr_wr_ext_data;
  input pwire [8:0] p_ext_LSQ;
  input pwire dc_ext_wrEn;
  output pwire reg [`lsaddr_width-1:0] lsr_wr_out_data;
  output pwire reg [8:0] p_out_LSQ;
  output pwire reg dc_out_wrEn;
  
  input pwire [7:0] pfxWQ;
  input pwire [135:0] pfx_wdata;
  input pwire [127:0] pfx_wdataU;
  input pwire [3:0] pfx_pdata;
  input pwire pfx_dataEn;
  output pwire reg [7:0] pfyWQ;
  output pwire reg [135:0] pfy_wdata;
  output pwire reg [127:0] pfy_wdataU;
  output pwire reg [3:0] pfy_pdata;
  output pwire reg pfy_dataEn;

  output pwire [64:0] bofh;
  input pwire [64:0] pfy;

  output pwire [8*SIMD_WIDTH-1:0] piff_paff_A;
  input pwire [8*SIMD_WIDTH-1:0] piff_paff_B;
  pwire piff;

  output pwire [1:0] wr0_hit;
  output pwire       wr0_iol;
  output pwire [35:0] wr0_addrE;
  output pwire [35:0] wr0_addrO;
  output pwire [31:0] wr0_banks;
  output pwire [4:0] wr0_begin;
  output pwire [4:0] wr0_end;
  output pwire [3:0] wr0_bgn_ben;
  output pwire [3:0] wr0_end_ben;
  output pwire wr0_odd,wr0_split;
  output pwire [159:0] wr0_data;
  output pwire [1:0] wr0_pbit;
  output pwire       wr0_d128;
  output pwire [1:0] wr1_hit;
  output pwire       wr1_iol;
  output pwire [35:0] wr1_addrE;
  output pwire [35:0] wr1_addrO;
  output pwire [31:0] wr1_banks;
  output pwire [4:0] wr1_begin;
  output pwire [4:0] wr1_end;
  output pwire [3:0] wr1_bgn_ben;
  output pwire [3:0] wr1_end_ben;
  output pwire [159:0] wr1_data;
  output pwire [1:0] wr1_pbit;
  output pwire       wr1_d128;
  output pwire wr1_odd,wr1_split;
  input pwire wrStall;
/*
  reg reqBus_en;
  reg [43:7] reqBus_addr;
  reg [REQ_WIDTH-1:0] reqBus_req;
  reg reqBus_want_excl;
*/
  pwire [67:0] XI_dataS;

  pwire p3_pfx;
  reg p3_pfx_reg;
  reg p3_pfx_reg2;

  pwire rsStall;
  pwire [3:0] rsDoStall;

  pwire do_rst_sched;

  reg [8:0] rs_xport;

  pwire [8:0] outXAM;
  reg [8:0] outXAM_reg;
  reg [8:0] outXAM_reg2;

  pwire p0_sec;
  pwire p1_sec;
  pwire p2_sec;
  reg p0_sec_reg,p0_sec_reg2;
  reg p1_sec_reg,p1_sec_reg2;
  reg p2_sec_reg,p2_sec_reg2;
  pwire [2:0] useBConstW;
  pwire [2:0] useAConstW;
  pwire [2:0] rs_rAW_use;
  pwire [2:0] rs_rAW_useF;
  pwire [2:0] rs_rBW_use;
  pwire [2:0] rs_rBW_useF;
  reg [2:0] rs_rAW_useF_reg;
  reg [2:0] rs_rBW_useF_reg;
  reg [2:0] rs_rAW_useF_reg2;
  reg [2:0] rs_rBW_useF_reg2;

  reg [3:0] newAttr_reg;
  reg [3:0] newAttr_reg2;
 
  pwire write_clear;

  reg insBus_io_reg;
  reg insBus_io_reg2;
  reg insBus_io_reg3;
  
  reg [36:0] MSI_exp_addr_reg;
  reg MSI_exp_en_reg;
  reg MSI_swap_want_reg;
  reg MSI_swap_repl_reg;
  reg MSI_exp_mkshared;

  reg [36:0] MSI_exp_addr_save[1:0];
  reg MSI_exp_en_save[1:0];
  reg MSI_swap_want_save[1:0];
  reg MSI_swap_repl_save[1:0];

  reg [36:0] MSI_lock[1:0];
  reg [13:0] MSI_lock_cnt[1:0];
  reg  MSI_locked[1:0];
  pwire [13:0] MSI_lock_cnt_inc[1:0];

  adder_inc #(14) MSI_inc0_mod(MSI_lock_cnt[0],MSI_lock_cnt_inc[0],1'b1,1'b1,,,,);
  adder_inc #(14) MSI_inc1_mod(MSI_lock_cnt[1],MSI_lock_cnt_inc[1],1'b1,1'b1,,,,);

  pwire [3:0] dc_thr=4'b0;

  pwire [5:0][13:0] fretA/*verilator public*/;
  pwire [5:0] fretA_en/* verilator public */;
  reg  [5:0][13:0] fretA_reg/*verilator public*/;
  pwire [5:0][13:0] fretB/*verilator public*/;
  pwire [5:0][13:0] fretX/*verilator public*/;
  pwire [5:0] fretB_en/* verilator public */;
  reg  [5:0][13:0] fretB_reg/*verilator public*/;
  pwire [5:0][13:0] fsretA/*verilator public*/;
  pwire [5:0][13:0] fsretB/*verilator public*/;

  pwire [5:0] FOOFL1;
  pwire [5:0] FOOFL2;
  pwire [5:0] FOOFL3;

  pwire [`lsaddr_width-1:0] st0_adata;
  pwire                     st0_en;
  reg                      st0_en_reg;
  reg                      st0_en_reg2;
  reg                      st0_en_reg3;
  reg [1:0]                st0_type_reg;
  reg [1:0]                st0_type_reg2;
  reg [1:0]                st0_type_reg3;
  pwire [4:0]               st0_bank1;
  pwire [3:0]               st0_bgn_ben;
  pwire [3:0]               st0_end_ben;
  reg [9:0]                st0_II_reg;
  reg [9:0]                st0_II_reg2;
  reg [9:0]                st0_II_reg3;
  pwire [159:0]             st0_data;
  pwire [1:0]               st0_pbit;
  pwire [`lsaddr_width-1:0] st1_adata;
  pwire                     st1_en;
  reg                      st1_en_reg;
  reg                      st1_en_reg2;
  reg                      st1_en_reg3;
  reg [1:0]                st1_type_reg;
  reg [1:0]                st1_type_reg2;
  reg [1:0]                st1_type_reg3;
  pwire [4:0]               st1_bank1;
  pwire [3:0]               st1_bgn_ben;
  pwire [3:0]               st1_end_ben;
  reg [9:0]                st1_II_reg;
  reg [9:0]                st1_II_reg2;
  reg [9:0]                st1_II_reg3;
  pwire [159:0]             st1_data;
  pwire [1:0]               st1_pbit;

  pwire [`lsaddr_width-1:0] lso_adata;
  pwire [8:0]               lso_LSQ;
  pwire                     lso_en;
  pwire [2:0]		   lso_way;
  reg                      lso_en_reg,lso2_en_reg;
  reg [2:0]		   lso_way_reg;
  pwire [12:0]              lso_ret;
  pwire [127+8:0]           lso_data;
  pwire [127+8:0]           lso_dataN;
  reg  [127+8:0]           lso_data_reg;
  reg  [127+8:0]           lso2_data_reg;
  reg  [127+8:0]           lso_dataN_reg;
  reg  [127+8:0]           lso2_dataN_reg;
  pwire [16:0]               lso_bnkread;
  pwire [16:0]               lso_bnkread2;
  pwire [1:0]               lso_pbit;
  pwire [`lsaddr_width-1:0] lso2_adata;
  pwire [8:0]               lso2_LSQ;
  pwire                     lso2_en;
  pwire [12:0]              lso2_ret;
  pwire [127+8:0]           lso2_data;
  pwire [127+8:0]           lso2_dataN;
  pwire [1:0]               lso2_pbit;
  pwire [16:0]               lso2_bnkread;
  pwire [16:0]               lso2_bnkread2;
  reg  [1:0]               lso_pbit_reg;
  reg  [1:0]               lso2_pbit_reg;
  
  pwire [2:0][IN_REG_WIDTH-1:0] rrfAW;
  pwire [2:0][IN_REG_WIDTH-1:0] rrfBW;
  pwire [2:0][REG_WIDTH-1:0] regAW;
  pwire [2:0][REG_WIDTH-1:0] regBW;
  pwire [2:0][REG_WIDTH-1:0] regAWF;
  pwire [2:0][REG_WIDTH-1:0] regBFW;
  pwire [2:0] retAW;
  pwire [2:0] retBW;
  pwire [2:0] retAWF;
  pwire [2:0] retBFW;
  reg [REG_WIDTH-1:0] regAW_reg[2:0];
  reg [REG_WIDTH-1:0] regBW_reg[2:0];
  reg [REG_WIDTH-1:0] regAWF_reg[2:0];
  reg [REG_WIDTH-1:0] regBFW_reg[2:0];
  reg [REG_WIDTH-1:0] regAWF_reg2[2:0];
  reg [REG_WIDTH-1:0] regBFW_reg2[2:0];
  reg [2:0] retAWF_reg;
  reg [2:0] retBFW_reg;
  reg [2:0] retAWF_reg2;
  reg [2:0] retBFW_reg2;
  reg [IN_REG_WIDTH-1:0] rrfAW_reg[2:0];
  reg [IN_REG_WIDTH-1:0] rrfBW_reg[2:0];
  reg [IN_REG_WIDTH-1:0] rrfAW_reg2[2:0];
  reg [IN_REG_WIDTH-1:0] rrfBW_reg2[2:0];
 
  pwire [2:0] isAWF;
  pwire [2:0] isBFW;
  reg [2:0] isAWF_reg;
  reg [2:0] isBFW_reg;
  pwire [2:0] isAWV;
  pwire [2:0] isBVW;
  reg [2:0] isAWV_reg;
  reg [2:0] isBVW_reg;

  pwire [8:0][REG_WIDTH-1:0] regA;
  pwire [8:0][REG_WIDTH-1:0] regB;
  pwire [8:0][REG_WIDTH-1:0] regAF;
  pwire [8:0][REG_WIDTH-1:0] regBF;
  pwire [8:0][REG_WIDTH-1:0] regS;
  reg [REG_WIDTH-1:0] regA_reg[8:0];
  reg [REG_WIDTH-1:0] regB_reg[8:0];
  reg [REG_WIDTH-1:0] regS_reg[8:0];
  reg [REG_WIDTH-1:0] regAF_reg[8:0];
  reg [REG_WIDTH-1:0] regBF_reg[8:0];
  reg [REG_WIDTH-1:0] regAF_reg2[8:0];
  reg [REG_WIDTH-1:0] regBF_reg2[8:0];
  pwire [2:0][REG_WIDTH-1:0] WregA;
  pwire [2:0][REG_WIDTH-1:0] WregB;
  pwire [8:0] retA;
  pwire [8:0] retB;
  pwire [8:0] retAF;
  pwire [8:0] retBF;
  pwire [8:0] retS;
  reg [8:0] retAF_reg;
  reg [8:0] retBF_reg;
  reg [8:0] retAF_reg2;
  reg [8:0] retBF_reg2;
  
  pwire stall_alloc;
  pwire doStall_alloc;
  pwire stall_alloc2;
  pwire doStall_alloc2;
  pwire [3:0] doStall_rs/*verilator public*/;
  pwire [3:0] stall_rs/*verilator public*/;
  pwire stall_LSQ;
  pwire doStall_LSQ;
  pwire stall_cntrl;
  pwire doStall_cntrl;
  pwire stall_LDQ;
  pwire doStall_LDQ;
  pwire stall_STQ;
  pwire doStall_STQ;
  pwire stall_WQ;
  pwire doStall_WQ;

  pwire [8:0][REG_WIDTH-1:0] newR;
  reg [REG_WIDTH-1:0] newR_reg[8:0];
  pwire [8:0][REG_WIDTH-1:0] newRF;
  reg [REG_WIDTH-1:0] newRF_reg[8:0];

  pwire [8:0][FN_WIDTH-1:0] newU;
  pwire [8:0][1:0] newD;

//  reg [REG_WIDTH-1:0] newU_reg[8:0];


  pwire [8:0][REG_WIDTH-1:0] clrR;
  pwire [8:0][REG_WIDTH-1:0] clrRS;
  pwire [8:0] clr;
  pwire [8:0] clrS;
  reg [REG_WIDTH-1:0] clrR_reg[8:0];
  reg [REG_WIDTH-1:0] clrRS_reg[8:0];
  reg [8:0] clr_reg;
  reg [8:0] clrS_reg;

  reg [IN_REG_WIDTH-1:0] rs0i0_rT_reg;
  reg [IN_REG_WIDTH-1:0] rs0i1_rT_reg;
  reg [IN_REG_WIDTH-1:0] rs0i2_rT_reg;
  reg [IN_REG_WIDTH-1:0] rs1i0_rT_reg;
  reg [IN_REG_WIDTH-1:0] rs1i1_rT_reg;
  reg [IN_REG_WIDTH-1:0] rs1i2_rT_reg;
  reg [IN_REG_WIDTH-1:0] rs2i0_rT_reg;
  reg [IN_REG_WIDTH-1:0] rs2i1_rT_reg;
  reg [IN_REG_WIDTH-1:0] rs2i2_rT_reg;

  reg [IN_REG_WIDTH-1:0] rs0i0_rA_reg;
  reg [IN_REG_WIDTH-1:0] rs0i1_rA_reg;
  reg [IN_REG_WIDTH-1:0] rs0i2_rA_reg;
  reg [IN_REG_WIDTH-1:0] rs1i0_rA_reg;
  reg [IN_REG_WIDTH-1:0] rs1i1_rA_reg;
  reg [IN_REG_WIDTH-1:0] rs1i2_rA_reg;
  reg [IN_REG_WIDTH-1:0] rs2i0_rA_reg;
  reg [IN_REG_WIDTH-1:0] rs2i1_rA_reg;
  reg [IN_REG_WIDTH-1:0] rs2i2_rA_reg;

  reg [IN_REG_WIDTH-1:0] rs0i0_rB_reg;
  reg [IN_REG_WIDTH-1:0] rs0i1_rB_reg;
  reg [IN_REG_WIDTH-1:0] rs0i2_rB_reg;
  reg [IN_REG_WIDTH-1:0] rs1i0_rB_reg;
  reg [IN_REG_WIDTH-1:0] rs1i1_rB_reg;
  reg [IN_REG_WIDTH-1:0] rs1i2_rB_reg;
  reg [IN_REG_WIDTH-1:0] rs2i0_rB_reg;
  reg [IN_REG_WIDTH-1:0] rs2i1_rB_reg;
  reg [IN_REG_WIDTH-1:0] rs2i2_rB_reg;
  
  reg [IN_REG_WIDTH-1:0] rs0i0_rA_reg2;
  reg [IN_REG_WIDTH-1:0] rs0i1_rA_reg2;
  reg [IN_REG_WIDTH-1:0] rs0i2_rA_reg2;
  reg [IN_REG_WIDTH-1:0] rs1i0_rA_reg2;
  reg [IN_REG_WIDTH-1:0] rs1i1_rA_reg2;
  reg [IN_REG_WIDTH-1:0] rs1i2_rA_reg2;
  reg [IN_REG_WIDTH-1:0] rs2i0_rA_reg2;
  reg [IN_REG_WIDTH-1:0] rs2i1_rA_reg2;
  reg [IN_REG_WIDTH-1:0] rs2i2_rA_reg2;

  reg [IN_REG_WIDTH-1:0] rs0i0_rB_reg2;
  reg [IN_REG_WIDTH-1:0] rs0i1_rB_reg2;
  reg [IN_REG_WIDTH-1:0] rs0i2_rB_reg2;
  reg [IN_REG_WIDTH-1:0] rs1i0_rB_reg2;
  reg [IN_REG_WIDTH-1:0] rs1i1_rB_reg2;
  reg [IN_REG_WIDTH-1:0] rs1i2_rB_reg2;
  reg [IN_REG_WIDTH-1:0] rs2i0_rB_reg2;
  reg [IN_REG_WIDTH-1:0] rs2i1_rB_reg2;
  reg [IN_REG_WIDTH-1:0] rs2i2_rB_reg2;
  
  reg [IN_REG_WIDTH-1:0] rs0i0_rA_reg3;
  reg [IN_REG_WIDTH-1:0] rs0i1_rA_reg3;
  reg [IN_REG_WIDTH-1:0] rs0i2_rA_reg3;
  reg [IN_REG_WIDTH-1:0] rs1i0_rA_reg3;
  reg [IN_REG_WIDTH-1:0] rs1i1_rA_reg3;
  reg [IN_REG_WIDTH-1:0] rs1i2_rA_reg3;
  reg [IN_REG_WIDTH-1:0] rs2i0_rA_reg3;
  reg [IN_REG_WIDTH-1:0] rs2i1_rA_reg3;
  reg [IN_REG_WIDTH-1:0] rs2i2_rA_reg3;

  reg [IN_REG_WIDTH-1:0] rs0i0_rB_reg3;
  reg [IN_REG_WIDTH-1:0] rs0i1_rB_reg3;
  reg [IN_REG_WIDTH-1:0] rs0i2_rB_reg3;
  reg [IN_REG_WIDTH-1:0] rs1i0_rB_reg3;
  reg [IN_REG_WIDTH-1:0] rs1i1_rB_reg3;
  reg [IN_REG_WIDTH-1:0] rs1i2_rB_reg3;
  reg [IN_REG_WIDTH-1:0] rs2i0_rB_reg3;
  reg [IN_REG_WIDTH-1:0] rs2i1_rB_reg3;
  reg [IN_REG_WIDTH-1:0] rs2i2_rB_reg3;
  
  reg rs0i0_alloc_reg;
  reg rs0i1_alloc_reg;
  reg rs0i2_alloc_reg;
  reg rs1i0_alloc_reg;
  reg rs1i1_alloc_reg;
  reg rs1i2_alloc_reg;
  reg rs2i0_alloc_reg;
  reg rs2i1_alloc_reg;
  reg rs2i2_alloc_reg;

  reg rs0i0_allocF_reg;
  reg rs0i1_allocF_reg;
  reg rs0i2_allocF_reg;
  reg rs1i0_allocF_reg;
  reg rs1i1_allocF_reg;
  reg rs1i2_allocF_reg;
  reg rs2i0_allocF_reg;
  reg rs2i1_allocF_reg;
  reg rs2i2_allocF_reg;

  reg rs0i0_allocR_reg;
  reg rs0i1_allocR_reg;
  reg rs0i2_allocR_reg;
  reg rs1i0_allocR_reg;
  reg rs1i1_allocR_reg;
  reg rs1i2_allocR_reg;
  reg rs2i0_allocR_reg;
  reg rs2i1_allocR_reg;
  reg rs2i2_allocR_reg;

  reg rs0i0_en_reg;
  reg rs0i1_en_reg;
  reg rs0i2_en_reg;
  reg rs1i0_en_reg;
  reg rs1i1_en_reg;
  reg rs1i2_en_reg;
  reg rs2i0_en_reg;
  reg rs2i1_en_reg;
  reg rs2i2_en_reg;
  
  reg rs0i0_useBConst_reg;
  reg rs0i1_useBConst_reg;
  reg rs0i2_useBConst_reg;
  reg rs1i0_useBConst_reg;
  reg rs1i1_useBConst_reg;
  reg rs1i2_useBConst_reg;
  reg rs2i0_useBConst_reg;
  reg rs2i1_useBConst_reg;
  reg rs2i2_useBConst_reg;
  
  reg [DATA_WIDTH-1:0] rs_const[8:0];
  reg [DATA_WIDTH-1:0] rs_const_reg[8:0];
  pwire [8:0][DATA_WIDTH-1:0] rs_const_new;
  reg [8:0] rs_IPRel;
  reg [8:0] rs_afterTK;

  reg rs_en[8:0];
  reg rs_en_reg[8:0]/*verilator public*/;
  reg [2:0] rs_enA;
  reg [2:0] rs_enB;
  reg [2:0] rs_enA_reg;
  reg [2:0] rs_enB_reg;
  reg [8:0] rs_ldst_flg;
  reg [8:0] rs_ldst_flg_reg;
  
  pwire [2:0] rs_enAW;
  pwire [2:0] rs_enBW;
  reg [2:0] rs_enAW_reg;
  reg [2:0] rs_enBW_reg;

  reg [3:0] rs0i0_index_reg;
  reg [3:0] rs0i1_index_reg;
  reg [3:0] rs0i2_index_reg;
  reg [3:0] rs1i0_index_reg;
  reg [3:0] rs1i1_index_reg;
  reg [3:0] rs1i2_index_reg;
  reg [3:0] rs2i0_index_reg;
  reg [3:0] rs2i1_index_reg;
  reg [3:0] rs2i2_index_reg;

  reg rs2i2_mul_reg;

  reg [3:0] rs0i1_flagDep_reg;
  reg [3:0] rs0i2_flagDep_reg;
  reg [3:0] rs1i1_flagDep_reg;
  reg [3:0] rs1i2_flagDep_reg;
  reg [3:0] rs2i1_flagDep_reg;
  reg [3:0] rs2i2_flagDep_reg;

  reg [3:0] rs0i1_flagDep_reg2;
  reg [3:0] rs0i2_flagDep_reg2;
  reg [3:0] rs1i1_flagDep_reg2;
  reg [3:0] rs1i2_flagDep_reg2;
  reg [3:0] rs2i1_flagDep_reg2;
  reg [3:0] rs2i2_flagDep_reg2;

  reg rs0i1_lastFl_reg;
  reg rs0i2_lastFl_reg;
  reg rs1i1_lastFl_reg;
  reg rs1i2_lastFl_reg;
  reg rs2i1_lastFl_reg;
  reg rs2i2_lastFl_reg;

  reg rs0i1_flag_wr_reg;
  reg rs0i2_flag_wr_reg;
  reg rs1i1_flag_wr_reg;
  reg rs1i2_flag_wr_reg;
  reg rs2i1_flag_wr_reg;
  reg rs2i2_flag_wr_reg;

  reg [OPERATION_WIDTH-1:0] rs_operation[8:0];
  reg [OPERATION_WIDTH-1:0] rs_operation_reg[8:0];
  reg [OPERATION_WIDTH-1:0] rs_operation_reg2[8:0];

  reg [3:0] rs_port[8:0];
  reg [3:0] rs_port_reg[8:0];
  reg [3:0] rs_port_sch[8:0]/* verilator public */;
  
  reg [3:0] rs_index[8:0];
  reg [3:0] rs_index_reg[8:0];
  
  reg [8:0] rs_rA_use;
  pwire [8:0] rs_rA_use_d;
  reg [8:0] rs_rB_use;

  reg [8:0] rs_rA_useF;
  pwire [8:0] rs_rA_useF_d;
  reg [8:0] rs_rB_useF;

  reg [8:0] rs_rA_useF_reg;
  reg [8:0] rs_rB_useF_reg;

  reg [8:0] rs_rA_useF_reg2;
  reg [8:0] rs_rB_useF_reg2;
  
  reg [8:0] rs_useBConst;
  reg [8:0] rs_useBConst_reg;
  reg [8:0] rs_useAConst;
  pwire [8:0] rs_useAConst_d;
  
  reg [5:0] rs_lsi[5:0];
  reg [2:0] rs_lsi_reg[5:0];

  reg [2:0] rs_alt;
  reg [2:0] rs_alt_reg/* verilator public */;

  reg [8:0] rs_rA_isV;
  reg [8:0] rs_rA_isAnyV;
  reg [8:0] rs_rB_isV;
  reg [8:0] rs_rB_isAnyV;
  reg [8:0] rs_rT_isV;
  reg [8:0] rs_rT_use;
  reg [8:0] rs_rT_useF;

  pwire [8:0] domErrA;
  pwire [8:0] domErrB;
 
  pwire [9:0] lsi_cnt;
  reg  [5:0] lsi_cnt_reg;
  pwire [5:0] lsi_bits;
 
  reg [IN_REG_WIDTH-1:0] instr_rT[9:0];
  reg [9:0] instr_en;
  reg [9:0] instr_wren;
  reg [8:0] instr_IPOff[9:0];
  reg [9:0] instr_afterTaken;
  reg [9:0] instr_rT_useF;
  reg [9:0] instr_rT_isV;
  reg [PORT_WIDTH-1:0] instr_port[9:0];
  reg [3:0] instr_magic[9:0];
  reg [9:0] instr_last;
  reg [9:0] instr_aft_spc;
  reg [1:0] instr_err[9:0];
  
  reg [4:0] jump0Type_reg;
  reg [3:0] jump0Pos_reg;
  reg jump0Pred_reg;
  reg [64:0] jump0IP_reg;
  reg [3:0] jump0Attr_reg;
  reg       jump0CLP_reg;
  reg [3:0] jump0Mask_reg;
  reg [4:0] jump1Type_reg;
  reg [3:0] jump1Pos_reg;
  reg jump1Pred_reg;
  reg [64:0] jump1IP_reg;
  reg [3:0] jump1Attr_reg;
  reg       jump1CLP_reg;
  reg [3:0] jump1Mask_reg;
  reg [9:0] instr_fsimd_reg;
  reg [62:0] baseIP_reg;
  reg [5:0] wrt0_reg;
  reg [5:0] wrt1_reg;
  reg [5:0] wrt2_reg;
  
  reg jump0TbufWay_reg;
  reg [1:0] jump0JmpInd_reg;
  reg [7:0] jump0GHT_reg;
  reg [15:0] jump0GHT2_reg;
  reg        jump0Val_reg;
  reg jump1TbufWay_reg;
  reg [1:0] jump1JmpInd_reg;
  reg [7:0] jump1GHT_reg;
  reg [15:0] jump1GHT2_reg;
  reg        jump1Val_reg;
  reg [1:0] jump0SC_reg;
  reg jump0Miss_reg;
  reg jump0TbufOnly_reg;
  reg [1:0] jump1SC_reg;
  reg jump1Miss_reg;
  reg jump1TbufOnly_reg;

  reg [IN_REG_WIDTH-1:0] instr_rT_reg[9:0];
  reg [9:0] instr_en_reg;
  reg [9:0] instr_wren_reg;
  reg [8:0] instr_IPOff_reg[9:0];
  reg [9:0] instr_afterTaken_reg;
  reg [9:0] instr_rT_useF_reg;
  reg [9:0] instr_rT_isV_reg;
  reg [PORT_WIDTH-1:0] instr_port_reg[9:0];
//  reg [3:0] instr_magic_reg[9:0];
  reg [9:0] instr_last_reg;
  reg [1:0] instr_err_reg[9:0];

  reg [2:0] instr_magicOff[9:0];
  reg [9:0] instr_gen;
  reg [9:0] instr_vec;
  reg [9:0] instr_aft_spc_reg;

  reg [4:0] jump0Type_reg2;
  reg [3:0] jump0Pos_reg2;
  reg jump0Pred_reg2;
  reg [64:0] jump0IP_reg2;
  reg [3:0] jump0Attr_reg2;
  reg       jump0CLP_reg2;
  reg [3:0] jump0Mask_reg2;
  reg [4:0] jump1Type_reg2;
  reg [3:0] jump1Pos_reg2;
  reg jump1Pred_reg2;
  reg [64:0] jump1IP_reg2;
  reg [3:0] jump1Attr_reg2;
  reg       jump1CLP_reg2;
  reg [3:0] jump1Mask_reg2;
  reg [9:0] instr_fsimd_reg2;
//  reg [46:0] baseIP_reg2;

  reg [15:0] jump0GHT2_reg2;
  reg        jump0Val_reg2;
  reg [15:0] jump1GHT2_reg2;
  reg        jump1Val_reg2;

  reg jump0TbufWay_reg2;
  reg [1:0] jump0JmpInd_reg2;
  reg [7:0] jump0GHT_reg2;
  reg jump1TbufWay_reg2;
  reg [1:0] jump1JmpInd_reg2;
  reg [7:0] jump1GHT_reg2;
  reg [1:0] jump0SC_reg2;
  reg jump0Miss_reg2;
  reg jump0TbufOnly_reg2;
  reg [1:0] jump1SC_reg2;
  reg jump1Miss_reg2;
  reg jump1TbufOnly_reg2;

  pwire [3:0] wrtII0;
  pwire [3:0] wrtII1;
  pwire [3:0] wrtII2;
  pwire [2:0] wrtO0;
  pwire [2:0] wrtO1;
  pwire [2:0] wrtO2;
  reg [3:0] wrtII0_reg;
  reg [3:0] wrtII1_reg;
  reg [3:0] wrtII2_reg;
  reg [2:0] wrtO0_reg;
  reg [2:0] wrtO1_reg;
  reg [2:0] wrtO2_reg;
//functional units
  pwire [9:0][DATA_WIDTH-1:0] FU;
  pwire [9:0][DATA_WIDTH-1:0] FU_N;
  pwire [9:0][REG_WIDTH-1:0] FUreg;
  pwire [9:0][REG_WIDTH-1:0] FUSreg;
  pwire [9:0]FUwen;
  reg FUwen0;
  reg FUwen1;
  reg FUwen2;
  reg FUwen3;
  pwire [DATA_WIDTH-1:0] FUMUL;
  pwire [DATA_WIDTH-1:0] FUCVT1;
  pwire [1:0] nDataAlt_alu;
  pwire [81:0] FUCVT2;
  reg  [81:0] FUCVT2_reg;
  reg  [81:0] FUCVT2_reg2;
  reg  [81:0] FUCVT2_reg3;
  reg  [81:0] FUCVT2_reg4;
  reg  [81:0] FUCVT2_reg5;
  reg  [81:0] FUCVT2_reg6;
  pwire [1:0] FUTYPE;
  reg  [1:0] FUTYPE_reg;
  reg  [1:0] FUTYPE_reg2;
  reg  [1:0] FUTYPE_reg3;
  reg  [1:0] FUTYPE_reg4;
  reg  [1:0] FUTYPE_reg5;
  reg  [1:0] FUTYPE_reg6;
  pwire [9:0][SIMD_WIDTH-1:0] FUVH;
  pwire [9:0][SIMD_WIDTH-1:0] FUVL;
  pwire [9:0][SIMD_WIDTH-1:0] FUFH;
  pwire [9:0][16+SIMD_WIDTH-1:0] FUFL;
  pwire [9:0][SIMD_WIDTH-1:0] FUVH_N;
  pwire [9:0][SIMD_WIDTH-1:0] FUVL_N;
  pwire [9:0][SIMD_WIDTH-1:0] FUFH_N;
  pwire [9:0][16+SIMD_WIDTH-1:0] FUFL_N;
  pwire [5:0][SIMD_WIDTH-1:0] FOOFH;
  pwire [5:0][16+SIMD_WIDTH-1:0] FOOFL;
  pwire [3:0][15:0] FUVLX_N;
  pwire [3:0][15:0] FUVLX;
  reg  [3:0][15:0] FUVLX_reg;

  pwire [5:0][DATA_WIDTH-1:0] FU_alu/*verilator public*/;
  pwire [5:0][5:0] FUS_alu/*verilator public*/;
  pwire [5:0][2:0] ex_alu/*verilator public*/;
  pwire [5:0] enS_alu/*verilator public*/;
  pwire [2:0][5:0] FUX_alu;
  pwire [2:0][2:0] exx_alu;
  reg [5:0] FUS_alu_reg[5:0];
  reg [2:0] ex_alu_reg[5:0];
  reg [5:0] enS_alu_reg;
  reg [5:0] FUS_alu_reg2[5:0];
  reg [2:0] ex_alu_reg2[5:0];
  reg [5:0] enS_alu_reg2;
  reg [5:0] FUS_alu_reg3[5:0];
  reg [2:0] ex_alu_reg3[5:0];
  reg [5:0] enS_alu_reg3;
  reg [5:0] FUS_alu_reg4[5:0];
  reg [2:0] ex_alu_reg4[5:0];
  reg [5:0] enS_alu_reg4;
  reg [5:0] FUS_alu_reg5[5:0];
  reg [2:0] ex_alu_reg5[5:0];
  reg [5:0] enS_alu_reg5;
  reg [5:0] FUS_alu_reg6[5:0];
  reg [2:0] ex_alu_reg6[5:0];
  reg [5:0] enS_alu_reg6;
  
  pwire [1:0] dalt;
/*  reg [5:0] FUX_alu_reg;
  reg [2:0] exx_alu_reg;
  reg [5:0] FUX_alu_reg2;
  reg [2:0] exx_alu_reg2;
  reg [5:0] FUX_alu_reg3;
  reg [2:0] exx_alu_reg3;
  reg [5:0] FUX_alu_reg4;
  reg [2:0] exx_alu_reg4;
  reg [5:0] FUX_alu_reg5;
  reg [2:0] exx_alu_reg5;
*/
  
//FLAGS FU*
  pwire [5:0] FUS1;
  pwire [5:0] FUS2;
  pwire [5:0] FUS3;
  pwire [5:0] FUS4;
  pwire [5:0] FUS5;
  pwire [5:0] FUS6;
  pwire [5:0] FUS7;
  pwire [5:0] FUS8;
  pwire [5:0] FUS9;

  
  pwire FU0Hit,FU1Hit,FU2Hit,FU3Hit;
  pwire FU0HitP/*verilator public*/,FU1HitP/*verilator public*/,FU2HitP/*verilator public*/,FU3HitP/* verilator public */;
  reg FU0Hit_reg/*verilator public*/,FU1Hit_reg/*verilator public*/,FU2Hit_reg/*verilator public*/,FU3Hit_reg/* verilator public */;
  reg FU0Hit_reg2/*verilator public*/,FU1Hit_reg2/*verilator public*/,FU2Hit_reg2/*verilator public*/,FU3Hit_reg2/* verilator public */;
//  pwire FU0HitP,FU1HitP,FU2HitP,FU3HitP;
  reg [3:0] fxLD_dbl;
  reg [3:0] fxLD_ext;
  reg [3:0] fxLD_dblext;
  reg [3:0] fxLD_sin;
  reg [3:0] fxLD_dbl_t;
  reg [3:0] fxLD_ext_t;
  reg [3:0] fxLD_sngl_t;
  reg [3:0] fxLD_spair_t;
  reg [3:0] fxLD_dbl_reg;
  reg [3:0] fxLD_ext_reg;
  reg [3:0] fxLD_dblext_reg;
  reg [3:0] fxLD_sin_reg;
  reg [3:0] fxLD_dbl_t_reg;
  reg [3:0] fxLD_ext_t_reg;
  reg [3:0] fxLD_sngl_t_reg;
  reg [3:0] fxLD_spair_t_reg;
  
  
  pwire [2:0][3:0] fxFRT_alten;
  pwire [3:0]      fxFRT_pause;
  reg [2:0][3:0] fxFRT_alten_reg;
  reg [2:0][3:0] fxFRT_alten_reg2;
  reg [2:0][3:0] fxFRT_alten_reg3;
  
  reg [DATA_WIDTH-1:0] FU_reg[9:0];
  reg [DATA_WIDTH-1:0] FU_reg2[9:0];

  reg [REG_WIDTH-1:0] FUreg_reg[9:0]/* verilator public */;
  reg [REG_WIDTH-1:0] FUSreg_reg[9:0];
  reg FUwen_reg[9:0]/* verilator public */;
  reg [REG_WIDTH-1:0] FUreg_reg2[9:0];
  reg [REG_WIDTH-1:0] FUSreg_reg2[9:0];
  reg FUwen_reg2[9:0];
  reg [REG_WIDTH-1:0] FUreg_reg3[9:0];
  reg [REG_WIDTH-1:0] FUSreg_reg3[9:0];
  reg FUwen_reg3[9:0];
  reg [REG_WIDTH-1:0] FUreg_reg4[9:0];
  reg [REG_WIDTH-1:0] FUSreg_reg4[9:0];
  reg FUwen_reg4[9:0];
  reg [REG_WIDTH-1:0] FUreg_reg5[9:0];
  reg [REG_WIDTH-1:0] FUSreg_reg5[9:0];
  reg FUwen_reg5[9:0];
  reg [REG_WIDTH-1:0] FUreg_reg6[9:0];
  reg FUwen_reg6[9:0];
  reg [REG_WIDTH-1:0] FUreg_reg7[9:0];
  reg FUwen_reg7[9:0];
  reg [SIMD_WIDTH-1:0] FUVH_reg[9:0];
  reg [16+SIMD_WIDTH-1:0] FUVL_reg[9:0];
  reg [SIMD_WIDTH-1:0] FUFH_reg[9:0];
  reg [16+SIMD_WIDTH-1:0] FUFL_reg[9:0];
  reg [SIMD_WIDTH-1:0] FUVH_reg2[9:0];
  reg [16+SIMD_WIDTH-1:0] FUVL_reg2[9:0];
  reg [SIMD_WIDTH-1:0] FUFH_reg2[9:0];
  reg [16+SIMD_WIDTH-1:0] FUFL_reg2[9:0];

  reg [5:0] FUS1_reg;
  reg [5:0] FUS2_reg;
  reg [5:0] FUS3_reg;
  reg [5:0] FUS4_reg;
  reg [5:0] FUS5_reg;
  reg [5:0] FUS6_reg;
  reg [5:0] FUS7_reg;
  reg [5:0] FUS8_reg;
  reg [5:0] FUS9_reg;


  pwire [8:0][DATA_WIDTH-1:0] dataA;
  pwire [8:0][DATA_WIDTH-1:0] dataB;
  pwire [8:0][DATA_WIDTH-1:0] dataNA;
  pwire [8:0][DATA_WIDTH-1:0] dataNB;
  pwire [2:0][DATA_WIDTH-1:0] WdataA;
  pwire [2:0][DATA_WIDTH-1:0] WdataB;
  pwire [8:0] inflA;
  pwire [8:0] inflB;
  pwire [2:0] WinflA;
  pwire [2:0] WinflB;
  pwire inflS;
  pwire [8:0] Sinfl;
  pwire [8:0][10:0] gazumpA;
  pwire [8:0][10:0] gazumpB;
  pwire [2:0][10:0] WgazumpA;
  pwire [2:0][10:0] WgazumpB;
  pwire [8:0][10:0] gazumpAG;
  pwire [8:0][10:0] gazumpBG;
  pwire [8:0][10:0] gazumpAV;
  pwire [8:0][10:0] gazumpBV;
  pwire [8:0][10:0] gazumpFA;
  pwire [8:0][10:0] gazumpFB;
  pwire [10:0] gazumpS;
  pwire [5:0] dataS;
  
  pwire [8:0] isAV;
  pwire [8:0] isBV;
  reg [8:0] isAV_reg;
  reg [8:0] isBV_reg;
  pwire [8:0] isAF;
  pwire [8:0] isBF;
  reg [8:0] isAF_reg;
  reg [8:0] isBF_reg;

  pwire [2:0][6:0] Wport;
  reg [6:0] Wport_reg[2:0];
  
  pwire [8:0][SIMD_WIDTH-1:0] dataAVH;
  pwire [8:0][SIMD_WIDTH-1:0] dataAVL;
  pwire [8:0][SIMD_WIDTH-1:0] dataAFH;
  pwire [8:0][16+SIMD_WIDTH-1:0] dataAFL;

  pwire [8:0][SIMD_WIDTH-1:0] dataBVH;
  pwire [8:0][SIMD_WIDTH-1:0] dataBVL;
  pwire [8:0][SIMD_WIDTH-1:0] dataBFH;
  pwire [8:0][16+SIMD_WIDTH-1:0] dataBFL;

  pwire [2:0][SIMD_WIDTH-1:0] WdataAVH;
  pwire [2:0][SIMD_WIDTH-1:0] WdataAVL;
  pwire [2:0][SIMD_WIDTH-1:0] WdataAFH;
  pwire [2:0][16+SIMD_WIDTH-1:0] WdataAFL;

  pwire [2:0][SIMD_WIDTH-1:0] WdataBVH;
  pwire [2:0][SIMD_WIDTH-1:0] WdataBVL;
  pwire [2:0][SIMD_WIDTH-1:0] WdataBFH;
  pwire [2:0][16+SIMD_WIDTH-1:0] WdataBFL;

  pwire [8:0][SIMD_WIDTH-1:0] dataNAVH;
  pwire [8:0][SIMD_WIDTH-1:0] dataNAVL;
  pwire [8:0][SIMD_WIDTH-1:0] dataNAFH;
  pwire [8:0][16+SIMD_WIDTH-1:0] dataNAFL;

  pwire [8:0][SIMD_WIDTH-1:0] dataNBVH;
  pwire [8:0][SIMD_WIDTH-1:0] dataNBVL;
  pwire [8:0][SIMD_WIDTH-1:0] dataNBFH;
  pwire [8:0][16+SIMD_WIDTH-1:0] dataNBFL;

  pwire [2:0][SIMD_WIDTH-1:0] WdataNAVH;
  pwire [2:0][SIMD_WIDTH-1:0] WdataNAVL;
  pwire [2:0][SIMD_WIDTH-1:0] WdataNAFH;
  pwire [2:0][16+SIMD_WIDTH-1:0] WdataNAFL;

  pwire [2:0][SIMD_WIDTH-1:0] WdataNBVH;
  pwire [2:0][SIMD_WIDTH-1:0] WdataNBVL;
  pwire [2:0][SIMD_WIDTH-1:0] WdataNBFH;
  pwire [2:0][16+SIMD_WIDTH-1:0] WdataNBFL;

  pwire [8:0][DATA_WIDTH-1:0] ret_dataA/*verilator public*/;
  pwire [8:0][DATA_WIDTH-1:0] ret_dataB;
  
  pwire [8:0][SIMD_WIDTH-1:0] ret_dataAVH;
  pwire [8:0][SIMD_WIDTH-1:0] ret_dataAVL;
  pwire [8:0][SIMD_WIDTH-1:0] ret_dataAFH;
  pwire [8:0][16+SIMD_WIDTH-1:0] ret_dataAFL;

  pwire [8:0][SIMD_WIDTH-1:0] ret_dataBVH;
  pwire [8:0][SIMD_WIDTH-1:0] ret_dataBVL;
  pwire [8:0][SIMD_WIDTH-1:0] ret_dataBFH;
  pwire [8:0][16+SIMD_WIDTH-1:0] ret_dataBFL;

  pwire [8:0] depA;
  pwire [8:0] depB;
  pwire [8:0] depAF;
  pwire [8:0] depBF;
  reg [8:0] depA_reg;
  reg [8:0] depB_reg;
  
  pwire [8:0][FN_WIDTH-1:0] funA;
  pwire [8:0][FN_WIDTH-1:0] funB;
  pwire [8:0][FN_WIDTH-1:0] funAF;
  pwire [8:0][FN_WIDTH-1:0] funBF;
  reg [FN_WIDTH-1:0] funA_reg[8:0];
  reg [FN_WIDTH-1:0] funB_reg[8:0];
  pwire [2:0][FN_WIDTH-1:0] WfunA;
  pwire [2:0][FN_WIDTH-1:0] WfunB;

  pwire [8:0][FN_WIDTH-1:0] funS;
  reg [FN_WIDTH-1:0] funS_reg[8:0];

  pwire [8:0][1:0] domA;
  pwire [8:0][1:0] domB;
 // pwire [8:0][1:0] domAF;
 // pwire [8:0][1:0] domBF;

  reg [1:0] domA_reg[8:0];
  reg [1:0] domB_reg[8:0];
  
  pwire [3:0] retcnt;
  pwire [8:0] retclr;

  pwire [16+67:0] ouDataBFL;
  pwire [16+67:0] ouDataAFL;
  pwire [67:0] utDataAFH;
  pwire [67:0] utDataBFH;
  pwire [67:0] ouDataBVL;
  pwire [67:0] ouDataAVL;
  pwire [67:0] utDataAVH;
  pwire [67:0] utDataBVH;
  pwire [8:0][DATA_WIDTH-1:0] outDataA;
  pwire [8:0][DATA_WIDTH-1:0] outDataB;
  pwire [5:0][SIMD_WIDTH-1:0] outDataAVH;
  pwire [5:0][SIMD_WIDTH-1:0] outDataBVH;
  pwire [5:0][SIMD_WIDTH-1:0] outDataAVL;
  pwire [5:0][SIMD_WIDTH-1:0] outDataBVL;
  pwire [5:0][SIMD_WIDTH-1:0] outDataAFH;
  pwire [5:0][SIMD_WIDTH-1:0] outDataBFH;
  pwire [5:0][16+SIMD_WIDTH-1:0] outDataAFL;
  pwire [5:0][16+SIMD_WIDTH-1:0] outDataBFL;
  pwire [8:0][DATA_WIDTH-1:0] outDataNA;
  pwire [8:0][DATA_WIDTH-1:0] outDataNB;
  pwire [5:0][SIMD_WIDTH-1:0] outDataNAVH;
  pwire [5:0][SIMD_WIDTH-1:0] outDataNBVH;
  pwire [5:0][SIMD_WIDTH-1:0] outDataNAVL;
  pwire [5:0][SIMD_WIDTH-1:0] outDataNBVL;
  pwire [5:0][SIMD_WIDTH-1:0] outDataNAFH;
  pwire [5:0][SIMD_WIDTH-1:0] outDataNBFH;
  pwire [5:0][16+SIMD_WIDTH-1:0] outDataNAFL;
  pwire [5:0][16+SIMD_WIDTH-1:0] outDataNBFL;
  pwire [8:0][43:0] outDataC;
  pwire [8:0][5:0] outDataS;
  pwire [8:0][REG_WIDTH-1:0] outReg;
  pwire [8:0][REG_WIDTH-1:0] outRegS;
  pwire [8:0][OPERATION_WIDTH-1:0] outOp;
  pwire [8:0][9:0] outII;
  pwire [8:0][3:0] outEn/* verilator public */;
  pwire [2:0][8:0] outLSQ;
  pwire [2:0][5:0] outWQ;
  pwire [8:0][3:0] fuFwdA;
  pwire [8:0][3:0] fuFwdB;
  pwire [8:0][3:0] fuFwdS;
  pwire [8:0][3:0] fuuFwdA;
  pwire [8:0][3:0] fuuFwdB;
  pwire [8:0][3:0] fuuFwdS;
  pwire [8:0] outThr;
  pwire [8:0][3:0] outAttr;
  pwire [2:0] outLSflag;
  pwire [2:0][3:0] fuFwdAH;
  pwire [2:0][3:0] fuFwdBH;
  pwire [2:0][3:0] fuuFwdAH;
  pwire [2:0][3:0] fuuFwdBH;
  
  pwire [2:0][3:0] outShiftSize;
 
  pwire [3:0]  outEnX;
  pwire [9:0]  outIIX;
  pwire [12:0] outOpX;
  pwire [8:0]  outRegX;
  pwire [8:0]  outRegSX;
  reg [3:0]  outEnX_reg;
  reg [9:0]  outIIX_reg;
  reg [17:0] outOpX_reg;
  reg [8:0]  outRegX_reg;
  reg [8:0]  outRegSX_reg;

  reg [5:5][SIMD_WIDTH-1:0] outDataAVH_reg;
  reg [5:5][SIMD_WIDTH-1:0] outDataBVH_reg;
  reg [5:5][SIMD_WIDTH-1:0] outDataAVL_reg;
  reg [5:5][SIMD_WIDTH-1:0] outDataBVL_reg;
  reg [5:5][SIMD_WIDTH-1:0] outDataAFH_reg;
  reg [5:5][SIMD_WIDTH-1:0] outDataBFH_reg;
  reg [5:5][16+SIMD_WIDTH-1:0] outDataAFL_reg;
  reg [5:5][16+SIMD_WIDTH-1:0] outDataBFL_reg;
  
  reg [3:0] fuFwdA_reg[8:0];
  reg [3:0] fuFwdB_reg[8:0];
  reg [3:0] fuFwdA_reg2[8:0];
  reg [3:0] fuFwdB_reg2[8:0];
  reg [3:0] fuuFwdA_reg[8:0];
  reg [3:0] fuuFwdB_reg[8:0];
  reg [3:0] fuuFwdA_reg2[8:0];
  reg [3:0] fuuFwdB_reg2[8:0];
  reg [3:0] fuFwdAH_reg[2:0];
  reg [3:0] fuFwdBH_reg[2:0];
  reg [3:0] fuuFwdAH_reg[2:0];
  reg [3:0] fuuFwdBH_reg[2:0];
  pwire [REG_WIDTH-1:0] regFl;
  pwire retFl;
//  pwire [FN_WIDTH-1:0] funFl;
  
  pwire [1:0][DATA_WIDTH-1:0] WoutDataA;
  pwire [1:0][DATA_WIDTH-1:0] WoutDataB;
  pwire [1:0][DATA_WIDTH-1:0] WoutDataNA;
  pwire [1:0][DATA_WIDTH-1:0] WoutDataNB;
  pwire [1:0][CONST_WIDTH-1:0] WoutDataC;
  pwire [1:0][OPERATION_WIDTH-6:0] WoutOp;
  pwire [1:0][9:0] WoutII;
  pwire [1:0][5:0] WoutWQ;
  pwire [1:0][3:0] WfuFwdA;
  pwire [1:0][3:0] WfuFwdB;
  pwire [1:0][3:0] WfuuFwdA;
  pwire [1:0][3:0] WfuuFwdB;
  pwire [1:0][8:0] WoutLSQ;
  pwire [1:0][3:0] WoutDataEn;
  pwire [1:0]WoutThread;
  pwire [1:0][3:0] WoutShiftSize;
  pwire [1:0]Waddrcalc_blockRS;
  reg Waddrcalc_blockRS_reg[1:0];
  pwire alu_jupdate=enS_alu[5];
  pwire [1:0] WoutLSflag;
  pwire [1:0][3:0] WoutAttr;
  
  
  pwire [1:0][DATA_WIDTH-1:0] WDoutData;
  pwire [1:0][DATA_WIDTH-1:0] WDoutDataN;
  pwire [1:0][OPERATION_WIDTH-6:0] WDoutOp;
  reg [1:0][OPERATION_WIDTH-6:0] WDoutOp_reg;
  reg [1:0][OPERATION_WIDTH-6:0] WDoutOp_reg2;
  reg [1:0][OPERATION_WIDTH-6:0] WDoutOp_reg3;
  pwire [1:0][9:0] WDoutII;
  pwire [1:0][3:0] WDoutFuFwd;
  pwire [1:0][3:0] WDoutFuuFwd;
  reg [3:0] WDoutFuFwd_reg[1:0];
  reg [3:0] WDoutFuuFwd_reg[1:0];
  reg [3:0] WDoutFuFwd_reg2[1:0];
  reg [3:0] WDoutFuuFwd_reg2[1:0];
  pwire [1:0][8:0] WDoutLSQ;
  pwire [1:0][3:0] WDoutDataEn;
  reg [3:0] WDoutDataEn_reg[1:0];
  reg [3:0] WDoutDataEn_reg2[1:0];
  pwire [1:0][5:0] WDoutWQ;
  pwire [1:0]WDoutThread;
  pwire [1:0][SIMD_WIDTH-1:0] WDoutDataVH;
  pwire [1:0][SIMD_WIDTH-1:0] WDoutDataVL;
  pwire [1:0][SIMD_WIDTH-1:0] WDoutDataFH;
  pwire [1:0][16+SIMD_WIDTH-1:0] WDoutDataFL;
  pwire [1:0][SIMD_WIDTH-1:0] WDoutDataNVH;
  pwire [1:0][SIMD_WIDTH-1:0] WDoutDataNVL;
  pwire [1:0][SIMD_WIDTH-1:0] WDoutDataNFH;
  pwire [1:0][16+SIMD_WIDTH-1:0] WDoutDataNFL;
  
  pwire [1:0][DATA_WIDTH-1:0] WDfxData;
  reg  [DATA_WIDTH-1:0] WDfxData_reg[1:0];
  reg  [DATA_WIDTH-1:0] WDfxData_reg2[1:0];
  reg  [DATA_WIDTH-1:0] WDfxData_reg3[1:0];
  pwire [1:0][SIMD_WIDTH-1:0] WDfxDataVH;
  pwire [1:0][SIMD_WIDTH-1:0] WDfxDataVL;
  pwire [1:0][SIMD_WIDTH-1:0] WDfxDataFH;
  pwire [1:0][16+SIMD_WIDTH-1:0] WDfxDataFL;
  pwire [1:0][OPERATION_WIDTH-1:0] WDfxOp;
  pwire [1:0][9:0] WDfxII;
  reg [9:0] WDfxII_reg[1:0];
  reg [9:0] WDfxII_reg2[1:0];
  reg [9:0] WDfxII_reg3[1:0];
  pwire [1:0][3:0] WDfxDataEn;
  reg  [3:0] WDfxDataEn_reg[1:0];
  reg  [3:0] WDfxDataEn_reg2[1:0];
  reg  [3:0] WDfxDataEn_reg3[1:0];
  reg  [3:0] WDfxDataEn_reg4[1:0];
  pwire [1:0][8:0] WDfxLSQ;
  pwire [1:0][5:0] WDfxWQ;
  reg  [5:0] WDfxWQ_reg[1:0];
  reg  [5:0] WDfxWQ_reg2[1:0];
  reg  [5:0] WDfxWQ_reg3[1:0];
  reg  [5:0] WDfxWQ_reg4[1:0];
  pwire [1:0] WDfxThr;
 
  pwire [1:0][135:0] lsw_wdataF0;
  pwire [1:0][135:0] lsw_wdataF1;
  pwire [1:0][135:0] lsw_wdataF;
  reg [135:0] lsw_wdataF_reg[1:0];
  pwire [1:0][135:0] lsw_wdataV;
  pwire [1:0][127:0] lsw_wdataV0;
  reg [135:0] lsw_wdataV_reg[1:0];
  pwire [1:0][135:0] lsw_wdata; 
  pwire [1:0][3:0] lsw_pdata;

  pwire pause_addrcalc;
  pwire miss_pause_addrcalc/* verilator public */;
  reg miss_pause_addrcalc_reg;
  reg miss_pause_addrcalc_reg2;
  pwire [2:0] addrcalc_blockRS;
  pwire miss_holds_addrcalc;
  reg miss_holds_addrcalc_reg;
  reg miss_holds_addrcalc_reg2;
 
  pwire [5:4][8:0] p_LSQ; 
  
  pwire [2:0][2:0] nDataAlt;
  reg [2:0][2:0] nDataAlt_reg;
  reg [2:0][2:0] nDataAlt_reg2;
  reg [2:0][2:0] nDataAlt_reg3;
  reg [2:0][2:0] nDataAlt_reg4;
  reg [2:0][2:0] nDataAlt_reg5;

  reg [REG_WIDTH-1:0] outReg_reg[8:0];
  reg [REG_WIDTH-1:0] outReg_reg2[8:0];
  reg [REG_WIDTH-1:0] outReg_reg3[8:0];
  reg [OPERATION_WIDTH-1:0] outOp_reg[8:0];
  reg [OPERATION_WIDTH-1:0] outOp_reg2[8:0];
  reg [OPERATION_WIDTH-1:0] outOp_reg3[8:0];
  reg [OPERATION_WIDTH-1:0] outOp_reg4[8:0];
  reg [OPERATION_WIDTH-1:0] outOp_reg5[8:0];
  reg [OPERATION_WIDTH-1:0] outOp_reg6[8:0];
  reg [OPERATION_WIDTH-1:0] outOp_reg7[8:0];
  reg [OPERATION_WIDTH-1:0] outOp_reg8[8:0];
  reg [9:0] outII_reg[8:0];
  reg [9:0] outII_reg2[8:0];
  reg [9:0] outII_reg3[8:0];
  reg [9:0] outII_reg4[8:0]/* verilator public */;
  reg [9:0] outII_reg5[8:0];
  reg [9:0] outII_reg6[8:0];
  reg [9:0] outII_reg7[8:0]/* verilator public */;
  reg [9:0] outII_reg8[8:0];
  reg [9:0] outII_reg9[8:0];
  reg [9:0] outII_reg10[8:0];
  reg [9:0] outII_reg11[8:0];
  reg [3:0] outEn_reg[8:0];
  reg [3:0] outEn_reg2[8:0];
  reg [3:0] outEn_reg3[8:0];
  reg [3:0] outEn_reg4[8:0];
  reg [3:0] outEn_reg5[8:0];
  reg [3:0] outEn_reg6[8:0];
  reg [3:0] outEn_reg7[8:0];
  reg [3:0] outEn_reg8[8:0];
  reg [8:0] outThr_reg;
  
  pwire thread_both=1'b0;
  reg thread_reg;
  reg thread_reg2;
  reg thread_reg3;
  reg bundle_in_reg;
  reg bundle_in_reg2;
  
  pwire [5:0] II_upper;
  
  reg bus_holds_addrcalc,bus_holds_addrcalc_reg,bus_holds_addrcalc_reg2;
  reg bus_holds_addrcalc_reg3,bus_holds_addrcalc_reg4,bus_holds_addrcalc_reg5;
  
  pwire [3:0] dc_rdEn/* verilator public */; 
  pwire [3:0] dc_rsEn; 
  pwire [3:0][127+8:0] dc_rdataA;
  pwire [3:0][127:0] dc_rdataA_X;
  pwire [3:0][127+8:0] dc_rdat;
  pwire [3:0][127:0] dc_rdat_X;
  pwire [3:0][1:0] dc_pdataA;
  pwire [3:0][1:0] dc_pdat;
  reg [3:0][1:0] dc_pdataA_reg;
  pwire [3:0][1:0] dc_rdHitCl;
//  pwire [3:0] dc_store;
  pwire [31:0] dc_bankNone;
  pwire [3:0][8:0] dc_LSQ;

  reg [127+8:0] dc_rdataA_reg[3:0];
  reg [127+8:0] dc_rdataA_reg2[3:0];
  reg [127:0] dc_rdataA_X_reg[3:0];
  reg [127:0] dc_rdataA_X_reg2[3:0];
  
  reg [3:0] dc_rdEn_reg; 
  reg [3:0] dc_rdEn_reg2; 
  reg [3:0] dc_rdEn_reg3;
  reg [3:0] dc_rsEn_reg; 
  reg [8:0] dc_LSQ_reg[3:0];

  reg [3:0][8:0] dc_rdReg_reg;

  pwire [1:0][PADDR_WIDTH-9:0] dc_wrAddrE;
  pwire [1:0][PADDR_WIDTH-9:0] dc_wrAddrO;
  pwire [1:0][31:0] dc_wrBanks;
  pwire [1:0] dc_wrEn; 
  reg [1:0] dc_wrEn_reg; 
  reg [1:0] dc_wrEn_reg2; 
  reg [1:0] dc_wrEn_reg3; 
  pwire [1:0] dc_odd_wr;
  pwire [1:0] dc_split_wr;
  pwire [1:0][5*32-1:0] dc_wdata;
  pwire [1:0][5*32-1:0] dc_wdata_N;
  pwire [1:0][4*32-1:0] dc_wdataP;
  reg [4*32-1:0] dc_wdataP_reg[1:0];
  pwire [1:0][4:0] dc_wrBegin;
  pwire [1:0][4:0] dc_size_wr;
  pwire [1:0][1:0] dc_wrHitCl;
  pwire [1:0][1:0] dc_wrDuplCl;
  pwire [1:0][1:0] dc_wspecdata;
  pwire [1:0][9:0] dc_II_wr;
  reg [9:0] dc_II_wr_reg[1:0];
  reg [9:0] dc_II_wr_reg2[1:0];
  reg [9:0] dc_II_wr_reg3[1:0];
  pwire [1:0] dc_wrHit;
  pwire [1:0][4:0] dc_wrEnd;
  pwire [1:0][3:0] dc_wrBGN_BNK;
  pwire [1:0][3:0] dc_wrEND_BNK;
  pwire [1:0][1:0] dc_wr_low;
  pwire [1:0][1:0] dc_wrTyp;
  pwire [1:0][4:0] dc_wrSZ;
  pwire [1:0][1:0] dc_pdata;

  pwire [5:0] p_repl;
  pwire [3:0] p_lsfwd;
  pwire [127+8:0]p2_data;
  pwire [1:0]    p2_pdata;
  pwire    [4:0] p2_brdbanks;
  pwire [127+8:0]p3_data;
  pwire [1:0]    p3_pdata;
  pwire    [4:0] p3_brdbanks;
  pwire [3:0][13:0] p_ret;
  reg [127+8:0]p2_data_reg;
  reg [127+8:0]p2_data_reg2;
  reg [127+8:0]p3_data_reg;
  reg [127+8:0]p3_data_reg2;
  reg [1:0]  p2_pdata_reg;
  reg [1:0]  p2_pdata_reg2;
  reg [1:0]  p3_pdata_reg;
  reg [1:0]  p3_pdata_reg2;
  reg [13:0] p2_ret_reg;
  reg [13:0] p2_ret_reg2;
  reg [13:0] p3_ret_reg;
  reg [13:0] p3_ret_reg2;
  reg [9:0] lsr2_II_reg;
  reg [9:0] lsr2_II_reg2;
  reg [9:0] lsr3_II_reg;
  reg [9:0] lsr3_II_reg2;
  reg [3:0] p_lsfwd_reg;
  reg [3:0] p_lsfwd_reg2;
  reg    [4:0] p2_brdbanks_reg;
  reg    [4:0] p2_brdbanks_reg2;
  reg    [4:0] p3_brdbanks_reg;
  reg    [4:0] p3_brdbanks_reg2;

  pwire [8:0] retfl_rF;
  pwire [5:0] retfl_data;
  pwire retfl_enG;
  reg [8:0] retfl_rF_reg;

  pwire wt_pause_addrcalc;
  reg wt_pause_addrcalc_reg;
  reg wt_pause_addrcalc_reg2;

  pwire [5:0][`lsaddr_width-1:0] lsr_wr_data;

  pwire [SIMD_WIDTH-1+16:0]    sqrDatFL;
  pwire [SIMD_WIDTH-1:0] sqrDatVL;
  pwire [3:0]               sqrDatEn;
  reg  [SIMD_WIDTH-1+16:0]    sqrDatFL_reg;
  reg  [SIMD_WIDTH-1:0] sqrDatVL_reg;
  reg                      sqrDatEn_reg;
//  pwire [3:0][47:0] wxdata;

  pwire [8:0][3:0] instr_ret;
  reg  [3:0] instr_ret_reg[8:0];
    
  pwire [5:0] tire0_rT/*verilator public*/;
  pwire [8:0] tire0_rF;
  pwire [8:0] tire0_rFl;
  pwire tire0_enG/*verilator public*/;
  pwire tire0_enV;
  pwire tire0_enF;
  pwire [5:0] tire1_rT/*verilator public*/;
  pwire [8:0] tire1_rF;
  pwire [8:0] tire1_rFl;
  pwire tire1_enG/*verilator public*/;
  pwire tire1_enV;
  pwire tire1_enF;
  pwire [5:0] tire2_rT/*verilator public*/;
  pwire [8:0] tire2_rF;
  pwire [8:0] tire2_rFl;
  pwire tire2_enG/*verilator public*/;
  pwire tire2_enV;
  pwire tire2_enF;
  pwire [5:0] tire3_rT/*verilator public*/;
  pwire [8:0] tire3_rF;
  pwire [8:0] tire3_rFl;
  pwire tire3_enG/*verilator public*/;
  pwire tire3_enV;
  pwire tire3_enF;
  pwire [5:0] tire4_rT/*verilator public*/;
  pwire [8:0] tire4_rF;
  pwire [8:0] tire4_rFl;
  pwire tire4_enG/*verilator public*/;
  pwire tire4_enV;
  pwire tire4_enF;
  pwire [5:0] tire5_rT/*verilator public*/;
  pwire [8:0] tire5_rF;
  pwire [8:0] tire5_rFl;
  pwire tire5_enG/*verilator public*/;
  pwire tire5_enV;
  pwire tire5_enF;
  pwire [5:0] tire6_rT/*verilator public*/;
  pwire [8:0] tire6_rF;
  pwire [8:0] tire6_rFl;
  pwire tire6_enG/*verilator public*/;
  pwire tire6_enV;
  pwire tire6_enF;
  pwire [5:0] tire7_rT/*verilator public*/;
  pwire [8:0] tire7_rF;
  pwire [8:0] tire7_rFl;
  pwire tire7_enG/*verilator public*/;
  pwire tire7_enV;
  pwire tire7_enF;
  pwire [5:0] tire8_rT/*verilator public*/;
  pwire [8:0] tire8_rF;
  pwire [8:0] tire8_rFl;
  pwire tire8_enG/*verilator public*/;
  pwire tire8_enV;
  pwire tire8_enF;

  reg [5:0] tire0_rT_reg;
  reg [8:0] tire0_rF_reg;
  reg [8:0] tire0_rFl_reg;
  reg tire0_enV_reg;
  reg tire0_enF_reg;
  reg [5:0] tire1_rT_reg;
  reg [8:0] tire1_rF_reg;
  reg [8:0] tire1_rFl_reg;
  reg tire1_enV_reg;
  reg tire1_enF_reg;
  reg [5:0] tire2_rT_reg;
  reg [8:0] tire2_rF_reg;
  reg [8:0] tire2_rFl_reg;
  reg tire2_enV_reg;
  reg tire2_enF_reg;
  reg [5:0] tire3_rT_reg;
  reg [8:0] tire3_rF_reg;
  reg [8:0] tire3_rFl_reg;
  reg tire3_enV_reg;
  reg tire3_enF_reg;
  reg [5:0] tire4_rT_reg;
  reg [8:0] tire4_rF_reg;
  reg [8:0] tire4_rFl_reg;
  reg tire4_enV_reg;
  reg tire4_enF_reg;
  reg [5:0] tire5_rT_reg;
  reg [8:0] tire5_rF_reg;
  reg [8:0] tire5_rFl_reg;
  reg tire5_enV_reg;
  reg tire5_enF_reg;
  reg [5:0] tire6_rT_reg;
  reg [8:0] tire6_rF_reg;
  reg [8:0] tire6_rFl_reg;
  reg tire6_enV_reg;
  reg tire6_enF_reg;
  reg [5:0] tire7_rT_reg;
  reg [8:0] tire7_rF_reg;
  reg [8:0] tire7_rFl_reg;
  reg tire7_enV_reg;
  reg tire7_enF_reg;
  reg [5:0] tire8_rT_reg;
  reg [8:0] tire8_rF_reg;
  reg [8:0] tire8_rFl_reg;
  reg tire8_enV_reg;
  reg tire8_enF_reg;

  reg [5:0] tire0_rT_reg2;
  reg [8:0] tire0_rF_reg2;
  reg tire0_enF_reg2;
  reg [5:0] tire1_rT_reg2;
  reg [8:0] tire1_rF_reg2;
  reg tire1_enF_reg2;
  reg [5:0] tire2_rT_reg2;
  reg [8:0] tire2_rF_reg2;
  reg tire2_enF_reg2;
  reg [5:0] tire3_rT_reg2;
  reg [8:0] tire3_rF_reg2;
  reg tire3_enF_reg2;
  reg [5:0] tire4_rT_reg2;
  reg [8:0] tire4_rF_reg2;
  reg tire4_enF_reg2;
  reg [5:0] tire5_rT_reg2;
  reg [8:0] tire5_rF_reg2;
  reg tire5_enF_reg2;
  reg [5:0] tire6_rT_reg2;
  reg [8:0] tire6_rF_reg2;
  reg tire6_enF_reg2;
  reg [5:0] tire7_rT_reg2;
  reg [8:0] tire7_rF_reg2;
  reg tire7_enF_reg2;
  reg [5:0] tire8_rT_reg2;
  reg [8:0] tire8_rF_reg2;
  reg tire8_enF_reg2;
  
  pwire insert_isCode;
  pwire insert_isData;
  reg insert_isData_reg;
  reg insert_isData_reg2;
  reg insert_isData_reg3/*verilator public*/;
  reg insert_isData_reg4;
  reg insert_isData_reg5;
  reg insert_isData_reg6;
  reg insert_isData_reg7;
  reg insert_isData_reg8;

  reg insBus_exclusive_reg;
  reg insBus_exclusive_reg2;
  reg insBus_exclusive_reg3;

  reg insBus_dirty_reg;
  reg insBus_dirty_reg2;
  reg insBus_dirty_reg3;
  
  reg [REQ_WIDTH-1:0] insBus_req_reg;
  
  pwire [36:0] insert_addr;
  reg [36:0] insert_addr_reg;
  reg [36:0] insert_addr_reg2;
  reg [36:0] insert_addr_reg3;

  reg [BUS_WIDTH-1:0] insBus_data_reg;
  reg [BUS_WIDTH-1:0] insBus_data_reg2;
 // pwire [8*BANK_WIDTH-1:0] insBus_data_ECC;
  reg [7:0] insBus_dataPTR_reg;
  reg [7:0] insBus_dataPTR_reg2;

  pwire [5:0] LSQ_upper;
  pwire [2:0] LSQ_lsqA;
  pwire [2:0] LSQ_lsqB;
  pwire [3:0] LSQ_indA;
  pwire [3:0] LSQ_indB;
  pwire [5:0] LSQ_wqA;
  pwire [5:0] LSQ_wqB;
  pwire [2:0] Wswp;
  pwire [OPERATION_WIDTH-6:0] WopA;
  pwire [OPERATION_WIDTH-6:0] WopB;
  reg [2:0] LSQ_lsqA_reg;
  reg [2:0] LSQ_lsqB_reg;
  reg [3:0] LSQ_indA_reg;
  reg [3:0] LSQ_indB_reg;
  reg [5:0] LSQ_wqA_reg;
  reg [5:0] LSQ_wqB_reg;
  reg [2:0] Wswp_reg;
  reg [OPERATION_WIDTH-6:0] WopA_reg;
  reg [OPERATION_WIDTH-6:0] WopB_reg;
  pwire LSQ_rdy_A;
  pwire [`lsaddr_width-1:0] LSQ_dataA0;
  pwire [`lsaddr_width-1:0] LSQ_dataA1;
  pwire [`lsaddr_width-1:0] LSQ_dataA2;
  pwire [`lsaddr_width-1:0] LSQ_dataA3;
  pwire [`lsaddr_width-1:0] LSQ_dataA4;
  pwire [`lsaddr_width-1:0] LSQ_dataA5;
  pwire [5:0] LSQ_enA;
  
  pwire [`lsqshare_width-1:0] LSQ_shr_data;
  pwire [`lsqshare_width-1:0] LSQ_shr_dataA;

  pwire [5:0] LDQ_ldconfl;
  pwire retB_en,retB_clkEn;
  pwire [5:0] ldq_new_mask;
  reg  [5:0] ldq_new_mask_reg;

  pwire STQ_confl_finish=1'b0;
  pwire [5:0] STQ_confl;
  pwire [1:0][3*32-1:0] STQ_confls;

  pwire bDoStall_rqSpit;
  pwire bDoStall_rqSpit0;
  
  pwire [2:0][5:0] WQR;
  pwire [2:0][5:0] WQS;
  reg [5:0] WQS_reg[2:0];
  reg [5:0] WQR_reg[2:0];
  
  pwire aStall_STQ;
  pwire aDoStall_STQ;
  pwire aStall_LSQ;
  
  pwire lStall_lsfw;
  pwire lDoStall_lsfw;
  pwire lStall_STQ;
  pwire lDoStall_STQ;
  pwire lStall;

  pwire [5:0] retM_II/*verilator public*/;
  pwire [5:0] retM_II0/*verilator public*/;
  pwire [5:0] retM_II1/*verilator public*/;
  pwire retM_has_store/*verilator public*/;
  pwire [9:0] retM_ret/*verilator public*/;
  pwire [9:0] retM_fine/*verilator public*/;
  pwire [9:0] retM_ldconfl/*verilator public*/;
  pwire [9:0] retM_waitconfl/*verilator public*/;
  pwire [9:0] retM_excpt/*verilator public*/;
 // pwire [39:0]retM_exbits;
  pwire retM_do_tire/*verilator public*/;
  pwire [`lsqshare_width-1:0] retM_data_shr/*verilator public*/;
  reg [`lsqshare_width-1:0] retM_data_shr_reg/*verilator public*/;
  //reg retM_ret_ret;
  pwire [9:0] retM_xbreak/*verilator public*/;
  pwire retM_stall/*verilator public*/;
  pwire retM_xbreak_has/*verilator public*/; 

  
  pwire [83:0] fpE_one={16'b0,2'd`ptype_ext,1'b1,65'h1_0000_0000_0000_0000};
  pwire [67:0] fpD_one={2'd`ptype_dbl,1'b0,1'b0,11'h400,53'b0};
  pwire [15:0] msrss_no;
  pwire msrss_en,msrss_thread;
  pwire [64:0] msrss_data;
 
  pwire [5:0][15:0] dummyFH;
  pwire [64:0] fpcsr;

  reg wrStall_reg;

  integer k,v,t,p,f,qq,k1;
 
  function [1:0] get_dom_C;
    input pwire V;
    input pwire F;
    case({V,F})
        2'b01: get_dom_C=2'b00;
        2'b11: get_dom_C=2'b10;
        2'b10: get_dom_C=2'b01;
        default: get_dom_C=2'b00;
    endcase

  endfunction

  function [3:0] get_byte_mod4;
      input pwire [1:0] addr_low;
      input pwire [4:0] sz;
      begin
          get_byte_mod4=4'b0;
          if (sz!=5'd16 && sz!=5'd17) get_byte_mod4=4'hf;
          else begin
              get_byte_mod4[addr_low]=1'b1;
              if (sz==5'd17) get_byte_mod4=get_byte_mod4|{get_byte_mod4[2:0],get_byte_mod4[3]};
          end
      end
  endfunction

  function [2:0] get_lsi;
      input pwire [5:0] in_lsi;
      case(in_lsi)
      6'b000001: get_lsi=0;
      6'b000010: get_lsi=1;
      6'b000100: get_lsi=2;
      6'b001000: get_lsi=3;
      6'b010000: get_lsi=4;
      6'b100000: get_lsi=5;
      6'h3f: get_lsi=6;
      default: get_lsi=7;
      endcase
  endfunction
  function [1:0] get_ptype; //from ptype
      input pwire [4:0] msz;  
      input pwire [1:0] orig;
      case(msz)
         5'h3,5'h4,5'h6:  get_ptype=`ptype_ext; 
	 5'h5,5'h7: get_ptype=`ptype_dbl; 
	 5'h8,5'hd: get_ptype=`ptype_sngl; 
	 //0 1 2, a b c = 128 bits,a/u 
	 //9=int 64 bit
	 //0xf=fill/spill
	 default: get_ptype=orig;
     endcase
  endfunction

  function [1:0] get_ptype2; //to ptype
      input pwire [4:0] msz;  
      input pwire [1:0] orig;
      case(msz)
         5'h3:  get_ptype2=`ptype_ext; //long double
	 5'h4,5'h5: get_ptype2=`ptype_dbl; //E2d d
	 5'h6,5'h7,5'h8,5'hd: get_ptype2=`ptype_sngl; //e2s d2s s2s spair/s
	 5'he: get_ptype2=`ptype_int; 
	 //0 1 2, a b c = 128 bits,a/u 
	 default: get_ptype2=orig;
     endcase
  endfunction

  function get_d128;
      input pwire [4:0] msz;
      get_d128=msz==5'h1 || msz==5'h2 || msz==5'h0 || msz==5'ha || msz==5'hc || msz==5'hB || msz==5'hf;
  endfunction

  function [0:0] is_rndE;
      input pwire [17:0] op;
      is_rndE=(op[7:0]==`fop_rndES || op[7:0]==`fop_rndED) & ~op[11];
  endfunction
  msrss_watch #(`csr_FPU,64'h20000) fpcsr_mod(clk,rst,msrss_no,msrss_data[63:0],msrss_en,fpcsr);

  rat ratA_mod(
    .clk(clk),
    .clkREF12(clkREF),
    .rst(rst),
    .read_clkEn(~doStall),
    .newR0(newR[0]),.newR1(newR[1]),.newR2(newR[2]),.newR3(newR[3]),
    .newR4(newR[4]),.newR5(newR[5]),.newR6(newR[6]),.newR7(newR[7]),.newR8(newR[8]),
    .newU0(newU[0]),.newU1(newU[1]),.newU2(newU[2]),.newU3(newU[3]),
    .newU4(newU[4]),.newU5(newU[5]),.newU6(newU[6]),.newU7(newU[7]),.newU8(newU[8]),
    //from here addr is tirement register
    .read0_addr(rs0i0_rA),.read0_data(regA[0]),.read0_tired(retA[0]),
      .read0_isDep(depA[0]),.read0_fun(funA[0]),
    .read1_addr(rs0i1_rA),.read1_data(regA[1]),.read1_tired(retA[1]),
      .read1_isDep(depA[1]),.read1_fun(funA[1]),
    .read2_addr(rs0i2_rA),.read2_data(regA[2]),.read2_tired(retA[2]),
      .read2_isDep(depA[2]),.read2_fun(funA[2]),
    .read3_addr(rs1i0_rA),.read3_data(regA[3]),.read3_tired(retA[3]),
      .read3_isDep(depA[3]),.read3_fun(funA[3]),
    .read4_addr(rs1i1_rA),.read4_data(regA[4]),.read4_tired(retA[4]),
      .read4_isDep(depA[4]),.read4_fun(funA[4]),
    .read5_addr(rs1i2_rA),.read5_data(regA[5]),.read5_tired(retA[5]),
      .read5_isDep(depA[5]),.read5_fun(funA[5]),
    .read6_addr(rs2i0_rA),.read6_data(regA[6]),.read6_tired(retA[6]),
      .read6_isDep(depA[6]),.read6_fun(funA[6]),
    .read7_addr(rs2i1_rA),.read7_data(regA[7]),.read7_tired(retA[7]),
      .read7_isDep(depA[7]),.read7_fun(funA[7]),
    .read8_addr(rs2i2_rA),.read8_data(regA[8]),.read8_tired(retA[8]),
      .read8_isDep(depA[8]),.read8_fun(funA[8]),
  
    .writeNew0_addr(rs0i0_rT_reg),.writeNew0_wen(rs0i0_alloc_reg),
    .writeNew1_addr(rs0i1_rT_reg),.writeNew1_wen(rs0i1_alloc_reg),
    .writeNew2_addr(rs0i2_rT_reg),.writeNew2_wen(rs0i2_alloc_reg),
    .writeNew3_addr(rs1i0_rT_reg),.writeNew3_wen(rs1i0_alloc_reg),
    .writeNew4_addr(rs1i1_rT_reg),.writeNew4_wen(rs1i1_alloc_reg),
    .writeNew5_addr(rs1i2_rT_reg),.writeNew5_wen(rs1i2_alloc_reg),
    .writeNew6_addr(rs2i0_rT_reg),.writeNew6_wen(rs2i0_alloc_reg),
    .writeNew7_addr(rs2i1_rT_reg),.writeNew7_wen(rs2i1_alloc_reg),
    .writeNew8_addr(rs2i2_rT_reg),.writeNew8_wen(rs2i2_alloc_reg),
  //from here addr is free register
    .writeRet0_addr(tire0_rF_reg),.writeRet0_wen(tire0_enG),
    .writeRet1_addr(tire1_rF_reg),.writeRet1_wen(tire1_enG),
    .writeRet2_addr(tire2_rF_reg),.writeRet2_wen(tire2_enG),
    .writeRet3_addr(tire3_rF_reg),.writeRet3_wen(tire3_enG),
    .writeRet4_addr(tire4_rF_reg),.writeRet4_wen(tire4_enG),
    .writeRet5_addr(tire5_rF_reg),.writeRet5_wen(tire5_enG),
    .writeRet6_addr(tire6_rF_reg),.writeRet6_wen(tire6_enG),
    .writeRet7_addr(tire7_rF_reg),.writeRet7_wen(tire7_enG),
    .writeRet8_addr(tire8_rF_reg),.writeRet8_wen(tire8_enG),
    .tireAll(except),.tireAll_thread(1'b0),
    
  
    .rs0i0_index(rs0i0_index_reg),.rs0i1_index(rs0i1_index_reg),.rs0i2_index(rs0i2_index_reg),
    .rs1i0_index(rs1i0_index_reg),.rs1i1_index(rs1i1_index_reg),.rs1i2_index(rs1i2_index_reg),
    .rs2i0_index(rs2i0_index_reg),.rs2i1_index(rs2i1_index_reg),.rs2i2_index(rs2i2_index_reg),
    .read_thread(thread),.ret_thread(1'b0)
    );
  rat ratB_mod(
    .clk(clk),
    .clkREF12(clkREF2),
    .rst(rst),
    .read_clkEn(~doStall),
    .newR0(newR[0]),.newR1(newR[1]),.newR2(newR[2]),.newR3(newR[3]),
    .newR4(newR[4]),.newR5(newR[5]),.newR6(newR[6]),.newR7(newR[7]),.newR8(newR[8]),
    .newU0(newU[0]),.newU1(newU[1]),.newU2(newU[2]),.newU3(newU[3]),
    .newU4(newU[4]),.newU5(newU[5]),.newU6(newU[6]),.newU7(newU[7]),.newU8(newU[8]),
    //from here addr is tirement register
    .read0_addr(rs0i0_rB),.read0_data(regB[0]),.read0_tired(retB[0]),
      .read0_isDep(depB[0]),.read0_fun(funB[0]),
    .read1_addr(rs0i1_rB),.read1_data(regB[1]),.read1_tired(retB[1]),
      .read1_isDep(depB[1]),.read1_fun(funB[1]),
    .read2_addr(rs0i2_rB),.read2_data(regB[2]),.read2_tired(retB[2]),
      .read2_isDep(depB[2]),.read2_fun(funB[2]),
    .read3_addr(rs1i0_rB),.read3_data(regB[3]),.read3_tired(retB[3]),
      .read3_isDep(depB[3]),.read3_fun(funB[3]),
    .read4_addr(rs1i1_rB),.read4_data(regB[4]),.read4_tired(retB[4]),
      .read4_isDep(depB[4]),.read4_fun(funB[4]),
    .read5_addr(rs1i2_rB),.read5_data(regB[5]),.read5_tired(retB[5]),
      .read5_isDep(depB[5]),.read5_fun(funB[5]),
    .read6_addr(rs2i0_rB),.read6_data(regB[6]),.read6_tired(retB[6]),
      .read6_isDep(depB[6]),.read6_fun(funB[6]),
    .read7_addr(rs2i1_rB),.read7_data(regB[7]),.read7_tired(retB[7]),
      .read7_isDep(depB[7]),.read7_fun(funB[7]),
    .read8_addr(rs2i2_rB),.read8_data(regB[8]),.read8_tired(retB[8]),
      .read8_isDep(depB[8]),.read8_fun(funB[8]),
  
    .writeNew0_addr(rs0i0_rT_reg),.writeNew0_wen(rs0i0_alloc_reg),
    .writeNew1_addr(rs0i1_rT_reg),.writeNew1_wen(rs0i1_alloc_reg),
    .writeNew2_addr(rs0i2_rT_reg),.writeNew2_wen(rs0i2_alloc_reg),
    .writeNew3_addr(rs1i0_rT_reg),.writeNew3_wen(rs1i0_alloc_reg),
    .writeNew4_addr(rs1i1_rT_reg),.writeNew4_wen(rs1i1_alloc_reg),
    .writeNew5_addr(rs1i2_rT_reg),.writeNew5_wen(rs1i2_alloc_reg),
    .writeNew6_addr(rs2i0_rT_reg),.writeNew6_wen(rs2i0_alloc_reg),
    .writeNew7_addr(rs2i1_rT_reg),.writeNew7_wen(rs2i1_alloc_reg),
    .writeNew8_addr(rs2i2_rT_reg),.writeNew8_wen(rs2i2_alloc_reg),
  //from here addr is free register
    .writeRet0_addr(tire0_rF_reg),.writeRet0_wen(tire0_enG),
    .writeRet1_addr(tire1_rF_reg),.writeRet1_wen(tire1_enG),
    .writeRet2_addr(tire2_rF_reg),.writeRet2_wen(tire2_enG),
    .writeRet3_addr(tire3_rF_reg),.writeRet3_wen(tire3_enG),
    .writeRet4_addr(tire4_rF_reg),.writeRet4_wen(tire4_enG),
    .writeRet5_addr(tire5_rF_reg),.writeRet5_wen(tire5_enG),
    .writeRet6_addr(tire6_rF_reg),.writeRet6_wen(tire6_enG),
    .writeRet7_addr(tire7_rF_reg),.writeRet7_wen(tire7_enG),
    .writeRet8_addr(tire8_rF_reg),.writeRet8_wen(tire8_enG),
    .tireAll(except),.tireAll_thread(1'b0),
  
    .rs0i0_index(rs0i0_index_reg),.rs0i1_index(rs0i1_index_reg),.rs0i2_index(rs0i2_index_reg),
    .rs1i0_index(rs1i0_index_reg),.rs1i1_index(rs1i1_index_reg),.rs1i2_index(rs1i2_index_reg),
    .rs2i0_index(rs2i0_index_reg),.rs2i1_index(rs2i1_index_reg),.rs2i2_index(rs2i2_index_reg),
    .read_thread(thread),.ret_thread(1'b0)
    );
  rat_flags rat_flags_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),
  .newR0(newRF[0]),.newR1(newRF[1]),.newR2(newRF[2]),.newR3(newRF[3]),
  .newR4(newRF[4]),.newR5(newRF[5]),.newR6(newRF[6]),.newR7(newRF[7]),.newR8(newRF[8]),
  .newU0(newU[0]),.newU1(newU[1]),.newU2(newU[2]),.newU3(newU[3]),
  .newU4(newU[4]),.newU5(newU[5]),.newU6(newU[6]),.newU7(newU[7]),.newU8(newU[8]),
  //from here addr is tirement register
  .read1_addr(rs0i1_flagDep),.read1_data(regS[1]),.read1_tired(retS[1]),.read1_fun(funS[1]),
  .read2_addr(rs0i2_flagDep),.read2_data(regS[2]),.read2_tired(retS[2]),.read2_fun(funS[2]),
  .read4_addr(rs1i1_flagDep),.read4_data(regS[4]),.read4_tired(retS[4]),.read4_fun(funS[4]),
  .read5_addr(rs1i2_flagDep),.read5_data(regS[5]),.read5_tired(retS[5]),.read5_fun(funS[5]),
  .read7_addr(rs2i1_flagDep),.read7_data(regS[7]),.read7_tired(retS[7]),.read7_fun(funS[7]),
  .read8_addr(rs2i2_flagDep),.read8_data(regS[8]),.read8_tired(retS[8]),.read8_fun(funS[8]),
  
  .r_data(regFl), .r_tired(retFl), .r_fun(),
  
  .writeNew0_wen(1'b0),
  .writeNew1_wen(rs0i1_lastFl_reg&~doStall),
  .writeNew2_wen(rs0i2_lastFl_reg&~doStall),
  .writeNew3_wen(1'b0),
  .writeNew4_wen(rs1i1_lastFl_reg&~doStall),
  .writeNew5_wen(rs1i2_lastFl_reg&~doStall),
  .writeNew6_wen(1'b0),
  .writeNew7_wen(rs2i1_lastFl_reg&~doStall),
  .writeNew8_wen(rs2i2_lastFl_reg&~doStall),
//from here addr is free register
  .writeRet0_addr(retfl_rF_reg),.writeRet0_wen(retfl_enG && retfl_rF_reg[3:0]==4'b0),
  .writeRet1_addr(retfl_rF_reg),.writeRet1_wen(retfl_enG && retfl_rF_reg[3:0]==4'd1),
  .writeRet2_addr(retfl_rF_reg),.writeRet2_wen(retfl_enG && retfl_rF_reg[3:0]==4'd2),
  .writeRet3_addr(retfl_rF_reg),.writeRet3_wen(retfl_enG && retfl_rF_reg[3:0]==4'd3),
  .writeRet4_addr(retfl_rF_reg),.writeRet4_wen(retfl_enG && retfl_rF_reg[3:0]==4'd4),
  .writeRet5_addr(retfl_rF_reg),.writeRet5_wen(retfl_enG && retfl_rF_reg[3:0]==4'd5),
  .writeRet6_addr(retfl_rF_reg),.writeRet6_wen(retfl_enG && retfl_rF_reg[3:0]==4'd6),
  .writeRet7_addr(retfl_rF_reg),.writeRet7_wen(retfl_enG && retfl_rF_reg[3:0]==4'd7),
  .writeRet8_addr(retfl_rF_reg),.writeRet8_wen(retfl_enG && retfl_rF_reg[3:0]==4'd8),
  .tireAll(except),

  .rs0i0_index(rs0i0_index_reg),.rs0i1_index(rs0i1_index_reg),.rs0i2_index(rs0i2_index_reg),
  .rs1i0_index(rs1i0_index_reg),.rs1i1_index(rs1i1_index_reg),.rs1i2_index(rs1i2_index_reg),
  .rs2i0_index(rs2i0_index_reg),.rs2i1_index(rs2i1_index_reg),.rs2i2_index(rs2i2_index_reg),
  .read_thread(thread),.ret_thread(1'b0)
  );  
  
  ratV ratAV_mod(
    .clk(clk),
    .clkREF12(clkREF),
    .rst(rst),
    .read_clkEn(~doStall),
    .newR0(newR[0]),.newR1(newR[1]),.newR2(newR[2]),.newR3(newR[3]),
    .newR4(newR[4]),.newR5(newR[5]),.newR6(newR[6]),.newR7(newR[7]),.newR8(newR[8]),
    .newU0(newU[0]),.newU1(newU[1]),.newU2(newU[2]),.newU3(newU[3]),
    .newU4(newU[4]),.newU5(newU[5]),.newU6(newU[6]),.newU7(newU[7]),.newU8(newU[8]),
    .newD0(newD[0]),.newD1(newD[1]),.newD2(newD[2]),.newD3(newD[3]),
    .newD4(newD[4]),.newD5(newD[5]),.newD6(newD[6]),.newD7(newD[7]),.newD8(newD[8]),
  //from here addr is tirement register
    .read0_addr(rs0i0_rA),.read0_data(regAF[0]),.read0_tired(retAF[0]),
      .read0_isDep(depAF[0]),.read0_fun(funAF[0]),.read0_dom(domA[0]),
    .read1_addr(rs0i1_rA),.read1_data(regAF[1]),.read1_tired(retAF[1]),
      .read1_isDep(depAF[1]),.read1_fun(funAF[1]),.read1_dom(domA[1]),
    .read2_addr(rs0i2_rA),.read2_data(regAF[2]),.read2_tired(retAF[2]),
      .read2_isDep(depAF[2]),.read2_fun(funAF[2]),.read2_dom(domA[2]),
    .read3_addr(rs1i0_rA),.read3_data(regAF[3]),.read3_tired(retAF[3]),
      .read3_isDep(depAF[3]),.read3_fun(funAF[3]),.read3_dom(domA[3]),
    .read4_addr(rs1i1_rA),.read4_data(regAF[4]),.read4_tired(retAF[4]),
      .read4_isDep(depAF[4]),.read4_fun(funAF[4]),.read4_dom(domA[4]),
    .read5_addr(rs1i2_rA),.read5_data(regAF[5]),.read5_tired(retAF[5]),
      .read5_isDep(depAF[5]),.read5_fun(funAF[5]),.read5_dom(domA[5]),
    .read6_addr(rs2i0_rA),.read6_data(regAF[6]),.read6_tired(retAF[6]),
      .read6_isDep(depAF[6]),.read6_fun(funAF[6]),.read6_dom(domA[6]),
    .read7_addr(rs2i1_rA),.read7_data(regAF[7]),.read7_tired(retAF[7]),
      .read7_isDep(depAF[7]),.read7_fun(funAF[7]),.read7_dom(domA[7]),
    .read8_addr(rs2i2_rA),.read8_data(regAF[8]),.read8_tired(retAF[8]),
      .read8_isDep(depAF[8]),.read8_fun(funAF[8]),.read8_dom(domA[8]),

    .writeNew0_addr(rs0i0_rT_reg),.writeNew0_wen(rs0i0_allocF_reg),
    .writeNew1_addr(rs0i1_rT_reg),.writeNew1_wen(rs0i1_allocF_reg),
    .writeNew2_addr(rs0i2_rT_reg),.writeNew2_wen(rs0i2_allocF_reg),
    .writeNew3_addr(rs1i0_rT_reg),.writeNew3_wen(rs1i0_allocF_reg),
    .writeNew4_addr(rs1i1_rT_reg),.writeNew4_wen(rs1i1_allocF_reg),
    .writeNew5_addr(rs1i2_rT_reg),.writeNew5_wen(rs1i2_allocF_reg),
    .writeNew6_addr(rs2i0_rT_reg),.writeNew6_wen(rs2i0_allocF_reg),
    .writeNew7_addr(rs2i1_rT_reg),.writeNew7_wen(rs2i1_allocF_reg),
    .writeNew8_addr(rs2i2_rT_reg),.writeNew8_wen(rs2i2_allocF_reg),
//from here addr is free register
    .writeRet0_addr(tire0_rF_reg),.writeRet0_paddr(tire0_rT),
       .writeRet0_dom(get_dom_C(tire0_enV,tire0_enF)),.writeRet0_wen(tire0_enV|tire0_enF),
    .writeRet1_addr(tire1_rF_reg),.writeRet1_paddr(tire1_rT),
       .writeRet1_dom(get_dom_C(tire1_enV,tire1_enF)),.writeRet1_wen(tire1_enV|tire1_enF),
    .writeRet2_addr(tire2_rF_reg),.writeRet2_paddr(tire2_rT),
       .writeRet2_dom(get_dom_C(tire2_enV,tire2_enF)),.writeRet2_wen(tire2_enV|tire2_enF),
    .writeRet3_addr(tire3_rF_reg),.writeRet3_paddr(tire3_rT),
       .writeRet3_dom(get_dom_C(tire3_enV,tire3_enF)),.writeRet3_wen(tire3_enV|tire3_enF),
    .writeRet4_addr(tire4_rF_reg),.writeRet4_paddr(tire4_rT),
       .writeRet4_dom(get_dom_C(tire4_enV,tire4_enF)),.writeRet4_wen(tire4_enV|tire4_enF),
    .writeRet5_addr(tire5_rF_reg),.writeRet5_paddr(tire5_rT),
       .writeRet5_dom(get_dom_C(tire5_enV,tire5_enF)),.writeRet5_wen(tire5_enV|tire5_enF),
    .writeRet6_addr(tire6_rF_reg),.writeRet6_paddr(tire6_rT),
       .writeRet6_dom(get_dom_C(tire6_enV,tire6_enF)),.writeRet6_wen(tire6_enV|tire6_enF),
    .writeRet7_addr(tire7_rF_reg),.writeRet7_paddr(tire7_rT),
       .writeRet7_dom(get_dom_C(tire7_enV,tire7_enF)),.writeRet7_wen(tire7_enV|tire7_enF),
    .writeRet8_addr(tire8_rF_reg),.writeRet8_paddr(tire8_rT),
       .writeRet8_dom(get_dom_C(tire8_enV,tire8_enF)),.writeRet8_wen(tire8_enV|tire8_enF),
    .tireAll(except),.tireAll_thread(1'b0),

    .rs0i0_index(rs0i0_index_reg),.rs0i1_index(rs0i1_index_reg),.rs0i2_index(rs0i2_index_reg),
    .rs1i0_index(rs1i0_index_reg),.rs1i1_index(rs1i1_index_reg),.rs1i2_index(rs1i2_index_reg),
    .rs2i0_index(rs2i0_index_reg),.rs2i1_index(rs2i1_index_reg),.rs2i2_index(rs2i2_index_reg),
    .read_thread(thread),.ret_thread(1'b0)
  );
  ratV ratBV_mod(
    .clk(clk),
    .clkREF12(clkREF2),
    .rst(rst),
    .read_clkEn(~doStall),
    .newR0(newR[0]),.newR1(newR[1]),.newR2(newR[2]),.newR3(newR[3]),
    .newR4(newR[4]),.newR5(newR[5]),.newR6(newR[6]),.newR7(newR[7]),.newR8(newR[8]),
    .newU0(newU[0]),.newU1(newU[1]),.newU2(newU[2]),.newU3(newU[3]),
    .newU4(newU[4]),.newU5(newU[5]),.newU6(newU[6]),.newU7(newU[7]),.newU8(newU[8]),
    .newD0(newD[0]),.newD1(newD[1]),.newD2(newD[2]),.newD3(newD[3]),
    .newD4(newD[4]),.newD5(newD[5]),.newD6(newD[6]),.newD7(newD[7]),.newD8(newD[8]),
  //from here addr is tirement register
    .read0_addr(rs0i0_rB),.read0_data(regBF[0]),.read0_tired(retBF[0]),
      .read0_isDep(depBF[0]),.read0_fun(funBF[0]),.read0_dom(domB[0]),
    .read1_addr(rs0i1_rB),.read1_data(regBF[1]),.read1_tired(retBF[1]),
      .read1_isDep(depBF[1]),.read1_fun(funBF[1]),.read1_dom(domB[1]),
    .read2_addr(rs0i2_rB),.read2_data(regBF[2]),.read2_tired(retBF[2]),
      .read2_isDep(depBF[2]),.read2_fun(funBF[2]),.read2_dom(domB[2]),
    .read3_addr(rs1i0_rB),.read3_data(regBF[3]),.read3_tired(retBF[3]),
      .read3_isDep(depBF[3]),.read3_fun(funBF[3]),.read3_dom(domB[3]),
    .read4_addr(rs1i1_rB),.read4_data(regBF[4]),.read4_tired(retBF[4]),
      .read4_isDep(depBF[4]),.read4_fun(funBF[4]),.read4_dom(domB[4]),
    .read5_addr(rs1i2_rB),.read5_data(regBF[5]),.read5_tired(retBF[5]),
      .read5_isDep(depBF[5]),.read5_fun(funBF[5]),.read5_dom(domB[5]),
    .read6_addr(rs2i0_rB),.read6_data(regBF[6]),.read6_tired(retBF[6]),
      .read6_isDep(depBF[6]),.read6_fun(funBF[6]),.read6_dom(domB[6]),
    .read7_addr(rs2i1_rB),.read7_data(regBF[7]),.read7_tired(retBF[7]),
      .read7_isDep(depBF[7]),.read7_fun(funBF[7]),.read7_dom(domB[7]),
    .read8_addr(rs2i2_rB),.read8_data(regBF[8]),.read8_tired(retBF[8]),
      .read8_isDep(depBF[8]),.read8_fun(funBF[8]),.read8_dom(domB[8]),

    .writeNew0_addr(rs0i0_rT_reg),.writeNew0_wen(rs0i0_allocF_reg),
    .writeNew1_addr(rs0i1_rT_reg),.writeNew1_wen(rs0i1_allocF_reg),
    .writeNew2_addr(rs0i2_rT_reg),.writeNew2_wen(rs0i2_allocF_reg),
    .writeNew3_addr(rs1i0_rT_reg),.writeNew3_wen(rs1i0_allocF_reg),
    .writeNew4_addr(rs1i1_rT_reg),.writeNew4_wen(rs1i1_allocF_reg),
    .writeNew5_addr(rs1i2_rT_reg),.writeNew5_wen(rs1i2_allocF_reg),
    .writeNew6_addr(rs2i0_rT_reg),.writeNew6_wen(rs2i0_allocF_reg),
    .writeNew7_addr(rs2i1_rT_reg),.writeNew7_wen(rs2i1_allocF_reg),
    .writeNew8_addr(rs2i2_rT_reg),.writeNew8_wen(rs2i2_allocF_reg),
//from here addr is free register
    .writeRet0_addr(tire0_rF_reg),.writeRet0_paddr(tire0_rT),
       .writeRet0_dom(get_dom_C(tire0_enV,tire0_enF)),.writeRet0_wen(tire0_enV|tire0_enF),
    .writeRet1_addr(tire1_rF_reg),.writeRet1_paddr(tire1_rT),
       .writeRet1_dom(get_dom_C(tire1_enV,tire1_enF)),.writeRet1_wen(tire1_enV|tire1_enF),
    .writeRet2_addr(tire2_rF_reg),.writeRet2_paddr(tire2_rT),
       .writeRet2_dom(get_dom_C(tire2_enV,tire2_enF)),.writeRet2_wen(tire2_enV|tire2_enF),
    .writeRet3_addr(tire3_rF_reg),.writeRet3_paddr(tire3_rT),
       .writeRet3_dom(get_dom_C(tire3_enV,tire3_enF)),.writeRet3_wen(tire3_enV|tire3_enF),
    .writeRet4_addr(tire4_rF_reg),.writeRet4_paddr(tire4_rT),
       .writeRet4_dom(get_dom_C(tire4_enV,tire4_enF)),.writeRet4_wen(tire4_enV|tire4_enF),
    .writeRet5_addr(tire5_rF_reg),.writeRet5_paddr(tire5_rT),
       .writeRet5_dom(get_dom_C(tire5_enV,tire5_enF)),.writeRet5_wen(tire5_enV|tire5_enF),
    .writeRet6_addr(tire6_rF_reg),.writeRet6_paddr(tire6_rT),
       .writeRet6_dom(get_dom_C(tire6_enV,tire6_enF)),.writeRet6_wen(tire6_enV|tire6_enF),
    .writeRet7_addr(tire7_rF_reg),.writeRet7_paddr(tire7_rT),
       .writeRet7_dom(get_dom_C(tire7_enV,tire7_enF)),.writeRet7_wen(tire7_enV|tire7_enF),
    .writeRet8_addr(tire8_rF_reg),.writeRet8_paddr(tire8_rT),
       .writeRet8_dom(get_dom_C(tire8_enV,tire8_enF)),.writeRet8_wen(tire8_enV|tire8_enF),
    .tireAll(except),.tireAll_thread(1'b0),

    .rs0i0_index(rs0i0_index_reg),.rs0i1_index(rs0i1_index_reg),.rs0i2_index(rs0i2_index_reg),
    .rs1i0_index(rs1i0_index_reg),.rs1i1_index(rs1i1_index_reg),.rs1i2_index(rs1i2_index_reg),
    .rs2i0_index(rs2i0_index_reg),.rs2i1_index(rs2i1_index_reg),.rs2i2_index(rs2i2_index_reg),
    .read_thread(thread),.ret_thread(1'b0)
  );
  reg_alloc allock_mod(
  .clk(clk),
  .rst(rst),
  .stall(stall_alloc),
  .doStall(doStall_alloc),
  .except(except),.ethread(1'b0),.eboth(1'b0),
  .thread(thread_reg),
  .ret_en(retclr),
  .ret_thread(1'b0),
  .ret_rno0(tire0_rF_reg[8:4]),.ret_rno1(tire1_rF_reg[8:4]),.ret_rno2(tire2_rF_reg[8:4]),
  .ret_rno3(tire3_rF_reg[8:4]),.ret_rno4(tire4_rF_reg[8:4]),.ret_rno5(tire5_rF_reg[8:4]),
  .ret_rno6(tire6_rF_reg[8:4]),.ret_rno7(tire7_rF_reg[8:4]),.ret_rno8(tire8_rF_reg[8:4]),
  .newR0(newR[0]),.newR1(newR[1]),.newR2(newR[2]),
  .newR3(newR[3]),.newR4(newR[4]),.newR5(newR[5]),
  .newR6(newR[6]),.newR7(newR[7]),.newR8(newR[8]),
  .rs0i0_en(rs0i0_allocR_reg),.rs1i0_en(rs1i0_allocR_reg),.rs2i0_en(rs2i0_allocR_reg),
  .rs0i1_en(rs0i1_allocR_reg),.rs1i1_en(rs1i1_allocR_reg),.rs2i1_en(rs2i1_allocR_reg),
  .rs0i2_en(rs0i2_allocR_reg),.rs1i2_en(rs1i2_allocR_reg),.rs2i2_en(rs2i2_allocR_reg)
  );
  
  reg_alloc allock2_mod(
  .clk(clk),
  .rst(rst),
  .stall(stall_alloc2),
  .doStall(doStall_alloc2),
  .except(except),.ethread(1'b0),.eboth(1'b0),
  .thread(thread_reg),
  .ret_en({9{retfl_enG}}&{retfl_rF[3:0]==8,retfl_rF[3:0]==7,retfl_rF[3:0]==6,retfl_rF[3:0]==5,retfl_rF[3:0]==4,retfl_rF[3:0]==3,
     retfl_rF[3:0]==2,retfl_rF[3:0]==1,retfl_rF[3:0]==0}),
  .ret_thread(1'b0),
  .ret_rno0(tire0_rFl_reg[8:4]),.ret_rno1(tire1_rFl_reg[8:4]),.ret_rno2(tire2_rFl_reg[8:4]),
  .ret_rno3(tire3_rFl_reg[8:4]),.ret_rno4(tire4_rFl_reg[8:4]),.ret_rno5(tire5_rFl_reg[8:4]),
  .ret_rno6(tire6_rFl_reg[8:4]),.ret_rno7(tire7_rFl_reg[8:4]),.ret_rno8(tire8_rFl_reg[8:4]),
  .newR0(newRF[0]),.newR1(newRF[1]),.newR2(newRF[2]),
  .newR3(newRF[3]),.newR4(newRF[4]),.newR5(newRF[5]),
  .newR6(newRF[6]),.newR7(newRF[7]),.newR8(newRF[8]),
  .rs0i0_en(1'b0),.rs1i0_en(1'b0),.rs2i0_en(1'b0),
  .rs0i1_en(rs0i1_flag_wr_reg),.rs1i1_en(rs1i1_flag_wr_reg),.rs2i1_en(rs2i1_flag_wr_reg),
  .rs0i2_en(rs0i2_flag_wr_reg),.rs1i2_en(rs1i2_flag_wr_reg),.rs2i2_en(rs2i2_flag_wr_reg)
  );
  
  
  get_funit funit_mod(
  .rs0i0_index(rs0i0_index_reg),.rs0i0_port(rs_port[0]),
  .rs0i1_index(rs0i1_index_reg),.rs0i1_port(rs_port[1]),
  .rs0i2_index(rs0i2_index_reg),.rs0i2_port(rs_port[2]),
  .rs1i0_index(rs1i0_index_reg),.rs1i0_port(rs_port[3]),
  .rs1i1_index(rs1i1_index_reg),.rs1i1_port(rs_port[4]),
  .rs1i2_index(rs1i2_index_reg),.rs1i2_port(rs_port[5]),
  .rs2i0_index(rs2i0_index_reg),.rs2i0_port(rs_port[6]),
  .rs2i1_index(rs2i1_index_reg),.rs2i1_port(rs_port[7]),
  .rs2i2_index(rs2i2_index_reg),.rs2i2_port(rs_port[8]),.mul(rs2i2_mul_reg),
  .funit0(newU[0]),.funit1(newU[1]),.funit2(newU[2]),
  .funit3(newU[3]),.funit4(newU[4]),.funit5(newU[5]),
  .funit6(newU[6]),.funit7(newU[7]),.funit8(newU[8])
  );
  
  regfile #(DATA_WIDTH) regA_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),

  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_addr(regA[0]),.read0_data(dataA[0]),
    .read0_oe(~retA[0]|~rs_rA_use[0]),.read0_match(gazumpAG[0]),
  .read1_addr(regA[1]),.read1_data(dataA[1]),
    .read1_oe(~retA[1]|~rs_rA_use[1]),.read1_match(gazumpAG[1]),
  .read2_addr(regA[2]),.read2_data(dataA[2]),
    .read2_oe(~retA[2]|~rs_rA_use[2]),.read2_match(gazumpAG[2]),
  .read3_addr(regA[3]),.read3_data(dataA[3]),
    .read3_oe(~retA[3]|~rs_rA_use[3]),.read3_match(gazumpAG[3]),
  .read4_addr(regA[4]),.read4_data(dataA[4]),
    .read4_oe(~retA[4]|~rs_rA_use[4]),.read4_match(gazumpAG[4]),
  .read5_addr(regA[5]),.read5_data(dataA[5]),
    .read5_oe(~retA[5]|~rs_rA_use[5]),.read5_match(gazumpAG[5]),
  .read6_addr(regA[6]),.read6_data(dataA[6]),
    .read6_oe(~retA[6]|~rs_rA_use[6]),.read6_match(gazumpAG[6]),
  .read7_addr(regA[7]),.read7_data(dataA[7]),
    .read7_oe(~retA[7]|~rs_rA_use[7]),.read7_match(gazumpAG[7]),
  .read8_addr(regA[8]),.read8_data(dataA[8]),
    .read8_oe(~retA[8]|~rs_rA_use[8]),.read8_match(gazumpAG[8]),

  .read0_addr_rrf(rs0i0_rA_reg),
  .read1_addr_rrf(rs0i1_rA_reg),
  .read2_addr_rrf(rs0i2_rA_reg),
  .read3_addr_rrf(rs1i0_rA_reg),
  .read4_addr_rrf(rs1i1_rA_reg),
  .read5_addr_rrf(rs1i2_rA_reg),
  .read6_addr_rrf(rs2i0_rA_reg),
  .read7_addr_rrf(rs2i1_rA_reg),
  .read8_addr_rrf(rs2i2_rA_reg),

  .read0_constEn(~rs_rA_use[0]),
  .read1_constEn(~rs_rA_use[1]),
  .read2_constEn(~rs_rA_use[2]),
  .read3_constEn(~rs_rA_use[3]),
  .read4_constEn(~rs_rA_use[4]),
  .read5_constEn(~rs_rA_use[5]),
  .read6_constEn(~rs_rA_use[6]),
  .read7_constEn(~rs_rA_use[7]),
  .read8_constEn(~rs_rA_use[8]),

  .read0_const(rs_const_new[0]&{65{rs_useAConst[0]}}),
  .read1_const(rs_const[1]&{65{rs_useAConst[1]}}),
  .read2_const(rs_const[2]&{65{rs_useAConst[2]}}),
  .read3_const(rs_const_new[3]&{65{rs_useAConst[3]}}),
  .read4_const(rs_const[4]&{65{rs_useAConst[4]}}),
  .read5_const(rs_const[5]&{65{rs_useAConst[5]}}),
  .read6_const(rs_const_new[6]&{65{rs_useAConst[6]}}),
  .read7_const(rs_const[7]&{65{rs_useAConst[7]}}),
  .read8_const(rs_const[8]&{65{rs_useAConst[8]}}),

  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enG),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enG),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enG),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enG),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enG),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enG),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enG),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enG),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enG),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg[0]),.write0_data_reg(FU_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_data_reg(FU_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_data_reg(FU_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_data_reg(FU_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg[4]),.write4_data_reg(FU_reg[4]),.write4_wen_reg(FUwen_reg[4]),
  .write5_addr_reg(FUreg_reg[5]),.write5_data_reg(FU_reg[5]),.write5_wen_reg(FUwen_reg[5]),
  .write6_addr_reg(FUreg_reg[6]),.write6_data_reg(FU_reg[6]),.write6_wen_reg(FUwen_reg[6]),
  .write7_addr_reg(FUreg_reg[7]),.write7_data_reg(FU_reg[7]),.write7_wen_reg(FUwen_reg[7]),
  .write8_addr_reg(FUreg_reg[8]),.write8_data_reg(FU_reg[8]),.write8_wen_reg(FUwen_reg[8]),
  .write9_addr_reg(FUreg_reg[9]),.write9_data_reg(FU_reg[9]),.write9_wen_reg(FUwen_reg[9])
  );


  regfile_get_gazump GzSimdA(
  .clk(clk),.rst(rst),
  .read_clkEn(~doStall),
  
  .read0_addr(regAF[0]),.read0_constEn(~rs_rA_useF[0]),.read0_oe(~retAF[0]|~rs_rA_useF[0]),.read0_match(gazumpAV[0]),
  .read1_addr(regAF[1]),.read1_constEn(~rs_rA_useF[1]),.read1_oe(~retAF[1]|~rs_rA_useF[1]),.read1_match(gazumpAV[1]),
  .read2_addr(regAF[2]),.read2_constEn(~rs_rA_useF[2]),.read2_oe(~retAF[2]|~rs_rA_useF[2]),.read2_match(gazumpAV[2]),
  .read3_addr(regAF[3]),.read3_constEn(~rs_rA_useF[3]),.read3_oe(~retAF[3]|~rs_rA_useF[3]),.read3_match(gazumpAV[3]),
  .read4_addr(regAF[4]),.read4_constEn(~rs_rA_useF[4]),.read4_oe(~retAF[4]|~rs_rA_useF[4]),.read4_match(gazumpAV[4]),
  .read5_addr(regAF[5]),.read5_constEn(~rs_rA_useF[5]),.read5_oe(~retAF[5]|~rs_rA_useF[5]),.read5_match(gazumpAV[5]),
  .read6_addr(regAF[6]),.read6_constEn(~rs_rA_useF[6]),.read6_oe(~retAF[6]|~rs_rA_useF[6]),.read6_match(gazumpAV[6]),
  .read7_addr(regAF[7]),.read7_constEn(~rs_rA_useF[7]),.read7_oe(~retAF[7]|~rs_rA_useF[7]),.read7_match(gazumpAV[7]),
  .read8_addr(regAF[8]),.read8_constEn(~rs_rA_useF[8]),.read8_oe(~retAF[8]|~rs_rA_useF[8]),.read8_match(gazumpAV[8]),

  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg2[4]),.write4_wen_reg(FUwen_reg2[4]),
  .write5_addr_reg(FUreg_reg2[5]),.write5_wen_reg(FUwen_reg2[5]),
  .write6_addr_reg(FUreg_reg2[6]),.write6_wen_reg(FUwen_reg2[6]),
  .write7_addr_reg(FUreg_reg2[7]),.write7_wen_reg(FUwen_reg2[7]),
  .write8_addr_reg(FUreg_reg2[8]),.write8_wen_reg(FUwen_reg2[8]),
  .write9_addr_reg(FUreg_reg2[9]),.write9_wen_reg(FUwen_reg2[9])
  );
  
  regfile_get_gazump GzFA(
  .clk(clk),.rst(rst),
  .read_clkEn(~doStall),
  
  .read0_addr(regAF[0]),.read0_constEn(~rs_rA_useF[0]),.read0_oe(~retAF[0]|~rs_rA_useF[0]),.read0_match(gazumpFA[0]),
  .read1_addr(regAF[1]),.read1_constEn(~rs_rA_useF[1]),.read1_oe(~retAF[1]|~rs_rA_useF[1]),.read1_match(gazumpFA[1]),
  .read2_addr(regAF[2]),.read2_constEn(~rs_rA_useF[2]),.read2_oe(~retAF[2]|~rs_rA_useF[2]),.read2_match(gazumpFA[2]),
  .read3_addr(regAF[3]),.read3_constEn(~rs_rA_useF[3]),.read3_oe(~retAF[3]|~rs_rA_useF[3]),.read3_match(gazumpFA[3]),
  .read4_addr(regAF[4]),.read4_constEn(~rs_rA_useF[4]),.read4_oe(~retAF[4]|~rs_rA_useF[4]),.read4_match(gazumpFA[4]),
  .read5_addr(regAF[5]),.read5_constEn(~rs_rA_useF[5]),.read5_oe(~retAF[5]|~rs_rA_useF[5]),.read5_match(gazumpFA[5]),
  .read6_addr(regAF[6]),.read6_constEn(~rs_rA_useF[6]),.read6_oe(~retAF[6]|~rs_rA_useF[6]),.read6_match(gazumpFA[6]),
  .read7_addr(regAF[7]),.read7_constEn(~rs_rA_useF[7]),.read7_oe(~retAF[7]|~rs_rA_useF[7]),.read7_match(gazumpFA[7]),
  .read8_addr(regAF[8]),.read8_constEn(~rs_rA_useF[8]),.read8_oe(~retAF[8]|~rs_rA_useF[8]),.read8_match(gazumpFA[8]),

  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg2[4]),.write4_wen_reg(FUwen_reg2[4]),
  .write5_addr_reg(FUreg_reg2[5]),.write5_wen_reg(FUwen_reg2[5]),
  .write6_addr_reg(FUreg_reg2[6]),.write6_wen_reg(FUwen_reg2[6]),
  .write7_addr_reg(FUreg_reg3[7]),.write7_wen_reg(FUwen_reg3[7]),
  .write8_addr_reg(FUreg_reg3[8]),.write8_wen_reg(FUwen_reg3[8]),
  .write9_addr_reg(FUreg_reg3[9]),.write9_wen_reg(FUwen_reg3[9])
  );
  

  reginfl #(1'b1) inflGVA_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),

  .read0_addr(regA[0]),.read0_data(inflA[0]),
    .read0_oe(~isAF[0] & ~isAV[0]),
  .read1_addr(regA[1]),.read1_data(inflA[1]),
    .read1_oe(~isAF[1] & ~isAV[1]),
  .read2_addr(regA[2]),.read2_data(inflA[2]),
    .read2_oe(~isAF[2] & ~isAV[2]),
  .read3_addr(regA[3]),.read3_data(inflA[3]),
    .read3_oe(~isAF[3] & ~isAV[3]),
  .read4_addr(regA[4]),.read4_data(inflA[4]),
    .read4_oe(~isAF[4] & ~isAV[4]),
  .read5_addr(regA[5]),.read5_data(inflA[5]),
    .read5_oe(~isAF[5] & ~isAV[5]),
  .read6_addr(regA[6]),.read6_data(inflA[6]),
    .read6_oe(~isAF[6] & ~isAV[6]),
  .read7_addr(regA[7]),.read7_data(inflA[7]),
    .read7_oe(~isAF[7] & ~isAV[7]),
  .read8_addr(regA[8]),.read8_data(inflA[8]),
    .read8_oe(~isAF[8] & ~isAV[8]),

  .read0_constEn(~rs_rA_use[0]&~rs_rA_useF[0]||rs_rA_use[0]&retA[0]||rs_rA_useF[0]&retAF[0]),
  .read1_constEn(~rs_rA_use[1]&~rs_rA_useF[1]||rs_rA_use[1]&retA[1]||rs_rA_useF[1]&retAF[1]),
  .read2_constEn(~rs_rA_use[2]&~rs_rA_useF[2]||rs_rA_use[2]&retA[2]||rs_rA_useF[2]&retAF[2]),
  .read3_constEn(~rs_rA_use[3]&~rs_rA_useF[3]||rs_rA_use[3]&retA[3]||rs_rA_useF[3]&retAF[3]),
  .read4_constEn(~rs_rA_use[4]&~rs_rA_useF[4]||rs_rA_use[4]&retA[4]||rs_rA_useF[4]&retAF[4]),
  .read5_constEn(~rs_rA_use[5]&~rs_rA_useF[5]||rs_rA_use[5]&retA[5]||rs_rA_useF[5]&retAF[5]),
  .read6_constEn(~rs_rA_use[6]&~rs_rA_useF[6]||rs_rA_use[6]&retA[6]||rs_rA_useF[6]&retAF[6]),
  .read7_constEn(~rs_rA_use[7]&~rs_rA_useF[7]||rs_rA_use[7]&retA[7]||rs_rA_useF[7]&retAF[7]),
  .read8_constEn(~rs_rA_use[8]&~rs_rA_useF[8]||rs_rA_use[8]&retA[8]||rs_rA_useF[8]&retAF[8]),


  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg[4]),.write4_wen_reg(FUwen_reg[4]),
  .write5_addr_reg(FUreg_reg[5]),.write5_wen_reg(FUwen_reg[5]),
  .write6_addr_reg(FUreg_reg[6]),.write6_wen_reg(FUwen_reg[6]),
  .write7_addr_reg(FUreg_reg[7]),.write7_wen_reg(FUwen_reg[7]),
  .write8_addr_reg(FUreg_reg[8]),.write8_wen_reg(FUwen_reg[8]),
  .write9_addr_reg(FUreg_reg[9]),.write9_wen_reg(FUwen_reg[9]),
  .newAddr0(clrR_reg[0][8:4]),.newEn0(clr_reg[0]),
  .newAddr1(clrR_reg[1][8:4]),.newEn1(clr_reg[1]),
  .newAddr2(clrR_reg[2][8:4]),.newEn2(clr_reg[2]),
  .newAddr3(clrR_reg[3][8:4]),.newEn3(clr_reg[3]),
  .newAddr4(clrR_reg[4][8:4]),.newEn4(clr_reg[4]),
  .newAddr5(clrR_reg[5][8:4]),.newEn5(clr_reg[5]),
  .newAddr6(clrR_reg[6][8:4]),.newEn6(clr_reg[6]),
  .newAddr7(clrR_reg[7][8:4]),.newEn7(clr_reg[7]),
  .newAddr8(clrR_reg[8][8:4]),.newEn8(clr_reg[8])
  );

  reginfl inflVA_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),

  .read0_addr(regAF[0]),.read0_data(inflA[0]),
    .read0_oe(isAV[0]),
  .read1_addr(regAF[1]),.read1_data(inflA[1]),
    .read1_oe(isAV[1]),
  .read2_addr(regAF[2]),.read2_data(inflA[2]),
    .read2_oe(isAV[2]),
  .read3_addr(regAF[3]),.read3_data(inflA[3]),
    .read3_oe(isAV[3]),
  .read4_addr(regAF[4]),.read4_data(inflA[4]),
    .read4_oe(isAV[4]),
  .read5_addr(regAF[5]),.read5_data(inflA[5]),
    .read5_oe(isAV[5]),
  .read6_addr(regAF[6]),.read6_data(inflA[6]),
    .read6_oe(isAV[6]),
  .read7_addr(regAF[7]),.read7_data(inflA[7]),
    .read7_oe(isAV[7]),
  .read8_addr(regAF[8]),.read8_data(inflA[8]),
    .read8_oe(isAV[8]),

  .read0_constEn(~rs_rA_useF[0]||retAF[0]),
  .read1_constEn(~rs_rA_useF[1]||retAF[1]),
  .read2_constEn(~rs_rA_useF[2]||retAF[2]),
  .read3_constEn(~rs_rA_useF[3]||retAF[3]),
  .read4_constEn(~rs_rA_useF[4]||retAF[4]),
  .read5_constEn(~rs_rA_useF[5]||retAF[5]),
  .read6_constEn(~rs_rA_useF[6]||retAF[6]),
  .read7_constEn(~rs_rA_useF[7]||retAF[7]),
  .read8_constEn(~rs_rA_useF[8]||retAF[8]),


  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg2[4]),.write4_wen_reg(FUwen_reg2[4]),
  .write5_addr_reg(FUreg_reg2[5]),.write5_wen_reg(FUwen_reg2[5]),
  .write6_addr_reg(FUreg_reg2[6]),.write6_wen_reg(FUwen_reg2[6]),
  .write7_addr_reg(FUreg_reg2[7]),.write7_wen_reg(FUwen_reg2[7]),
  .write8_addr_reg(FUreg_reg2[8]),.write8_wen_reg(FUwen_reg2[8]),
  .write9_addr_reg(FUreg_reg2[9]),.write9_wen_reg(FUwen_reg2[9]),
  .newAddr0(clrR_reg[0][8:4]),.newEn0(clr_reg[0]),
  .newAddr1(clrR_reg[1][8:4]),.newEn1(clr_reg[1]),
  .newAddr2(clrR_reg[2][8:4]),.newEn2(clr_reg[2]),
  .newAddr3(clrR_reg[3][8:4]),.newEn3(clr_reg[3]),
  .newAddr4(clrR_reg[4][8:4]),.newEn4(clr_reg[4]),
  .newAddr5(clrR_reg[5][8:4]),.newEn5(clr_reg[5]),
  .newAddr6(clrR_reg[6][8:4]),.newEn6(clr_reg[6]),
  .newAddr7(clrR_reg[7][8:4]),.newEn7(clr_reg[7]),
  .newAddr8(clrR_reg[8][8:4]),.newEn8(clr_reg[8])
  );

  reginfl inflFA_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),

  .read0_addr(regAF[0]),.read0_data(inflA[0]),
    .read0_oe(isAF[0]),
  .read1_addr(regAF[1]),.read1_data(inflA[1]),
    .read1_oe(isAF[1]),
  .read2_addr(regAF[2]),.read2_data(inflA[2]),
    .read2_oe(isAF[2]),
  .read3_addr(regAF[3]),.read3_data(inflA[3]),
    .read3_oe(isAF[3]),
  .read4_addr(regAF[4]),.read4_data(inflA[4]),
    .read4_oe(isAF[4]),
  .read5_addr(regAF[5]),.read5_data(inflA[5]),
    .read5_oe(isAF[5]),
  .read6_addr(regAF[6]),.read6_data(inflA[6]),
    .read6_oe(isAF[6]),
  .read7_addr(regAF[7]),.read7_data(inflA[7]),
    .read7_oe(isAF[7]),
  .read8_addr(regAF[8]),.read8_data(inflA[8]),
    .read8_oe(isAF[8]),

  .read0_constEn(~rs_rA_useF[0]||retAF[0]),
  .read1_constEn(~rs_rA_useF[1]||retAF[1]),
  .read2_constEn(~rs_rA_useF[2]||retAF[2]),
  .read3_constEn(~rs_rA_useF[3]||retAF[3]),
  .read4_constEn(~rs_rA_useF[4]||retAF[4]),
  .read5_constEn(~rs_rA_useF[5]||retAF[5]),
  .read6_constEn(~rs_rA_useF[6]||retAF[6]),
  .read7_constEn(~rs_rA_useF[7]||retAF[7]),
  .read8_constEn(~rs_rA_useF[8]||retAF[8]),


  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg2[4]),.write4_wen_reg(FUwen_reg2[4]),
  .write5_addr_reg(FUreg_reg2[5]),.write5_wen_reg(FUwen_reg2[5]),
  .write6_addr_reg(FUreg_reg2[6]),.write6_wen_reg(FUwen_reg2[6]),
  .write7_addr_reg(FUreg_reg3[7]),.write7_wen_reg(FUwen_reg3[7]),
  .write8_addr_reg(FUreg_reg3[8]),.write8_wen_reg(FUwen_reg3[8]),
  .write9_addr_reg(FUreg_reg3[9]),.write9_wen_reg(FUwen_reg3[9]),
  .newAddr0(clrR_reg[0][8:4]),.newEn0(clr_reg[0]),
  .newAddr1(clrR_reg[1][8:4]),.newEn1(clr_reg[1]),
  .newAddr2(clrR_reg[2][8:4]),.newEn2(clr_reg[2]),
  .newAddr3(clrR_reg[3][8:4]),.newEn3(clr_reg[3]),
  .newAddr4(clrR_reg[4][8:4]),.newEn4(clr_reg[4]),
  .newAddr5(clrR_reg[5][8:4]),.newEn5(clr_reg[5]),
  .newAddr6(clrR_reg[6][8:4]),.newEn6(clr_reg[6]),
  .newAddr7(clrR_reg[7][8:4]),.newEn7(clr_reg[7]),
  .newAddr8(clrR_reg[8][8:4]),.newEn8(clr_reg[8])
  );
  regfile #(DATA_WIDTH) regB_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_addr(regB[0]),.read0_data(dataB[0]),
    .read0_oe(~retB[0]|rs0i0_useBConst_reg|~rs_rB_use[0]),.read0_match(gazumpBG[0]),
  .read1_addr(regB[1]),.read1_data(dataB[1]),
    .read1_oe(~retB[1]|rs0i1_useBConst_reg|~rs_rB_use[1]),.read1_match(gazumpBG[1]),
  .read2_addr(regB[2]),.read2_data(dataB[2]),
    .read2_oe(~retB[2]|rs0i2_useBConst_reg|~rs_rB_use[2]),.read2_match(gazumpBG[2]),
  .read3_addr(regB[3]),.read3_data(dataB[3]),
    .read3_oe(~retB[3]|rs1i0_useBConst_reg|~rs_rB_use[3]),.read3_match(gazumpBG[3]),
  .read4_addr(regB[4]),.read4_data(dataB[4]),
    .read4_oe(~retB[4]|rs1i1_useBConst_reg|~rs_rB_use[4]),.read4_match(gazumpBG[4]),
  .read5_addr(regB[5]),.read5_data(dataB[5]),
    .read5_oe(~retB[5]|rs1i2_useBConst_reg|~rs_rB_use[5]),.read5_match(gazumpBG[5]),
  .read6_addr(regB[6]),.read6_data(dataB[6]),
    .read6_oe(~retB[6]|rs2i0_useBConst_reg|~rs_rB_use[6]),.read6_match(gazumpBG[6]),
  .read7_addr(regB[7]),.read7_data(dataB[7]),
    .read7_oe(~retB[7]|rs2i1_useBConst_reg|~rs_rB_use[7]),.read7_match(gazumpBG[7]),
  .read8_addr(regB[8]),.read8_data(dataB[8]),
    .read8_oe(~retB[8]|rs2i2_useBConst_reg|~rs_rB_use[8]),.read8_match(gazumpBG[8]),

  .read0_addr_rrf(rs0i0_rB_reg),
  .read1_addr_rrf(rs0i1_rB_reg),
  .read2_addr_rrf(rs0i2_rB_reg),
  .read3_addr_rrf(rs1i0_rB_reg),
  .read4_addr_rrf(rs1i1_rB_reg),
  .read5_addr_rrf(rs1i2_rB_reg),
  .read6_addr_rrf(rs2i0_rB_reg),
  .read7_addr_rrf(rs2i1_rB_reg),
  .read8_addr_rrf(rs2i2_rB_reg),


  .read0_constEn(rs0i0_useBConst_reg|~rs_rB_use[0]),
  .read1_constEn(rs0i1_useBConst_reg|~rs_rB_use[1]),
  .read2_constEn(rs0i2_useBConst_reg|~rs_rB_use[2]),
  .read3_constEn(rs1i0_useBConst_reg|~rs_rB_use[3]),
  .read4_constEn(rs1i1_useBConst_reg|~rs_rB_use[4]),
  .read5_constEn(rs1i2_useBConst_reg|~rs_rB_use[5]),
  .read6_constEn(rs2i0_useBConst_reg|~rs_rB_use[6]),
  .read7_constEn(rs2i1_useBConst_reg|~rs_rB_use[7]),
  .read8_constEn(rs2i2_useBConst_reg|~rs_rB_use[8]),

  .read0_const(rs_const_new[0]&{65{rs_useBConst[0]}}),
  .read1_const(rs_const_new[1]&{65{rs0i1_useBConst_reg}}),
  .read2_const(rs_const_new[2]),
  .read3_const(rs_const_new[3]&{65{rs_useBConst[3]}}),
  .read4_const(rs_const_new[4]&{65{rs1i1_useBConst_reg}}),
  .read5_const(rs_const_new[5]),
  .read6_const(rs_const_new[6]&{65{rs_useBConst[6]}}),
  .read7_const(rs_const_new[7]&{65{rs2i1_useBConst_reg}}),
  .read8_const(rs_const_new[8]),

  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enG),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enG),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enG),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enG),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enG),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enG),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enG),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enG),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enG),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg[0]),.write0_data_reg(FU_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_data_reg(FU_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_data_reg(FU_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_data_reg(FU_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg[4]),.write4_data_reg(FU_reg[4]),.write4_wen_reg(FUwen_reg[4]),
  .write5_addr_reg(FUreg_reg[5]),.write5_data_reg(FU_reg[5]),.write5_wen_reg(FUwen_reg[5]),
  .write6_addr_reg(FUreg_reg[6]),.write6_data_reg(FU_reg[6]),.write6_wen_reg(FUwen_reg[6]),
  .write7_addr_reg(FUreg_reg[7]),.write7_data_reg(FU_reg[7]),.write7_wen_reg(FUwen_reg[7]),
  .write8_addr_reg(FUreg_reg[8]),.write8_data_reg(FU_reg[8]),.write8_wen_reg(FUwen_reg[8]),
  .write9_addr_reg(FUreg_reg[9]),.write9_data_reg(FU_reg[9]),.write9_wen_reg(FUwen_reg[9])
  );


  regfile_get_gazump GzVB(
  .clk(clk),.rst(rst),
  .read_clkEn(~doStall),
  
  .read0_addr(regBF[0]),.read0_constEn(~rs_rB_useF[0]),.read0_oe(~retBFW[0]|~rs_rB_useF[0]),.read0_match(gazumpBV[0]),
  .read1_addr(regBF[1]),.read1_constEn(~rs_rB_useF[1]),.read1_oe(~retBF[1]|~rs_rB_useF[1]),.read1_match(gazumpBV[1]),
  .read2_addr(regBF[2]),.read2_constEn(~rs_rB_useF[2]),.read2_oe(~retBF[2]|~rs_rB_useF[2]),.read2_match(gazumpBV[2]),
  .read3_addr(regBF[3]),.read3_constEn(~rs_rB_useF[3]),.read3_oe(~retBF[3]|~rs_rB_useF[3]),.read3_match(gazumpBV[3]),
  .read4_addr(regBF[4]),.read4_constEn(~rs_rB_useF[4]),.read4_oe(~retBF[4]|~rs_rB_useF[4]),.read4_match(gazumpBV[4]),
  .read5_addr(regBF[5]),.read5_constEn(~rs_rB_useF[5]),.read5_oe(~retBF[5]|~rs_rB_useF[5]),.read5_match(gazumpBV[5]),
  .read6_addr(regBF[6]),.read6_constEn(~rs_rB_useF[6]),.read6_oe(~retBF[6]|~rs_rB_useF[6]),.read6_match(gazumpBV[6]),
  .read7_addr(regBF[7]),.read7_constEn(~rs_rB_useF[7]),.read7_oe(~retBF[7]|~rs_rB_useF[7]),.read7_match(gazumpBV[7]),
  .read8_addr(regBF[8]),.read8_constEn(~rs_rB_useF[8]),.read8_oe(~retBF[8]|~rs_rB_useF[8]),.read8_match(gazumpBV[8]),

  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg2[4]),.write4_wen_reg(FUwen_reg2[4]),
  .write5_addr_reg(FUreg_reg2[5]),.write5_wen_reg(FUwen_reg2[5]),
  .write6_addr_reg(FUreg_reg2[6]),.write6_wen_reg(FUwen_reg2[6]),
  .write7_addr_reg(FUreg_reg2[7]),.write7_wen_reg(FUwen_reg2[7]),
  .write8_addr_reg(FUreg_reg2[8]),.write8_wen_reg(FUwen_reg2[8]),
  .write9_addr_reg(FUreg_reg2[9]),.write9_wen_reg(FUwen_reg2[9])
  );

  regfile_get_gazump GzFB(
  .clk(clk),.rst(rst),
  .read_clkEn(~doStall),
  
  .read0_addr(regBF[0]),.read0_constEn(~rs_rB_useF[0]),.read0_oe(~retBF[0]|~rs_rB_useF[0]),.read0_match(gazumpFB[0]),
  .read1_addr(regBF[1]),.read1_constEn(~rs_rB_useF[1]),.read1_oe(~retBF[1]|~rs_rB_useF[1]),.read1_match(gazumpFB[1]),
  .read2_addr(regBF[2]),.read2_constEn(~rs_rB_useF[2]),.read2_oe(~retBF[2]|~rs_rB_useF[2]),.read2_match(gazumpFB[2]),
  .read3_addr(regBF[3]),.read3_constEn(~rs_rB_useF[3]),.read3_oe(~retBF[3]|~rs_rB_useF[3]),.read3_match(gazumpFB[3]),
  .read4_addr(regBF[4]),.read4_constEn(~rs_rB_useF[4]),.read4_oe(~retBF[4]|~rs_rB_useF[4]),.read4_match(gazumpFB[4]),
  .read5_addr(regBF[5]),.read5_constEn(~rs_rB_useF[5]),.read5_oe(~retBF[5]|~rs_rB_useF[5]),.read5_match(gazumpFB[5]),
  .read6_addr(regBF[6]),.read6_constEn(~rs_rB_useF[6]),.read6_oe(~retBF[6]|~rs_rB_useF[6]),.read6_match(gazumpFB[6]),
  .read7_addr(regBF[7]),.read7_constEn(~rs_rB_useF[7]),.read7_oe(~retBF[7]|~rs_rB_useF[7]),.read7_match(gazumpFB[7]),
  .read8_addr(regBF[8]),.read8_constEn(~rs_rB_useF[8]),.read8_oe(~retBF[8]|~rs_rB_useF[8]),.read8_match(gazumpFB[8]),

  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg2[4]),.write4_wen_reg(FUwen_reg2[4]),
  .write5_addr_reg(FUreg_reg2[5]),.write5_wen_reg(FUwen_reg2[5]),
  .write6_addr_reg(FUreg_reg2[6]),.write6_wen_reg(FUwen_reg2[6]),
  .write7_addr_reg(FUreg_reg3[7]),.write7_wen_reg(FUwen_reg3[7]),
  .write8_addr_reg(FUreg_reg3[8]),.write8_wen_reg(FUwen_reg3[8]),
  .write9_addr_reg(FUreg_reg3[9]),.write9_wen_reg(FUwen_reg3[9])
  );

  reginfl #(1'b1) reginflGVB_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),

  .read0_addr(regB[0]),.read0_data(inflB[0]),
    .read0_oe(~isBF[0] & ~isBV[0]),
  .read1_addr(regB[1]),.read1_data(inflB[1]),
    .read1_oe(~isBF[1] & ~isBV[1]),
  .read2_addr(regB[2]),.read2_data(inflB[2]),
    .read2_oe(~isBF[2] & ~isBV[2]),
  .read3_addr(regB[3]),.read3_data(inflB[3]),
    .read3_oe(~isBF[3] & ~isBV[3]),
  .read4_addr(regB[4]),.read4_data(inflB[4]),
    .read4_oe(~isBF[4] & ~isBV[4]),
  .read5_addr(regB[5]),.read5_data(inflB[5]),
    .read5_oe(~isBF[5] & ~isBV[5]),
  .read6_addr(regB[6]),.read6_data(inflB[6]),
    .read6_oe(~isBF[6] & ~isBV[6]),
  .read7_addr(regB[7]),.read7_data(inflB[7]),
    .read7_oe(~isBF[7] & ~isBV[7]),
  .read8_addr(regB[8]),.read8_data(inflB[8]),
    .read8_oe(~isBF[8] & ~isBV[8]),

  .read0_constEn(rs0i0_useBConst_reg||~rs_rB_use[0]&~rs_rB_useF[0]||rs_rB_use[0]&retB[0]||rs_rB_useF[0]&retBF[0]),
  .read1_constEn(rs0i1_useBConst_reg||~rs_rB_use[1]&~rs_rB_useF[1]||rs_rB_use[1]&retB[1]||rs_rB_useF[1]&retBF[1]),
  .read2_constEn(rs0i2_useBConst_reg||~rs_rB_use[2]&~rs_rB_useF[2]||rs_rB_use[2]&retB[2]||rs_rB_useF[2]&retBF[2]),
  .read3_constEn(rs1i0_useBConst_reg||~rs_rB_use[3]&~rs_rB_useF[3]||rs_rB_use[3]&retB[3]||rs_rB_useF[3]&retBF[3]),
  .read4_constEn(rs1i1_useBConst_reg||~rs_rB_use[4]&~rs_rB_useF[4]||rs_rB_use[4]&retB[4]||rs_rB_useF[4]&retBF[4]),
  .read5_constEn(rs1i2_useBConst_reg||~rs_rB_use[5]&~rs_rB_useF[5]||rs_rB_use[5]&retB[5]||rs_rB_useF[5]&retBF[5]),
  .read6_constEn(rs2i0_useBConst_reg||~rs_rB_use[6]&~rs_rB_useF[6]||rs_rB_use[6]&retB[6]||rs_rB_useF[6]&retBF[6]),
  .read7_constEn(rs2i1_useBConst_reg||~rs_rB_use[7]&~rs_rB_useF[7]||rs_rB_use[7]&retB[7]||rs_rB_useF[7]&retBF[7]),
  .read8_constEn(rs2i2_useBConst_reg||~rs_rB_use[8]&~rs_rB_useF[8]||rs_rB_use[8]&retB[8]||rs_rB_useF[8]&retBF[8]),

  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg[4]),.write4_wen_reg(FUwen_reg[4]),
  .write5_addr_reg(FUreg_reg[5]),.write5_wen_reg(FUwen_reg[5]),
  .write6_addr_reg(FUreg_reg[6]),.write6_wen_reg(FUwen_reg[6]),
  .write7_addr_reg(FUreg_reg[7]),.write7_wen_reg(FUwen_reg[7]),
  .write8_addr_reg(FUreg_reg[8]),.write8_wen_reg(FUwen_reg[8]),
  .write9_addr_reg(FUreg_reg[9]),.write9_wen_reg(FUwen_reg[9]),
  .newAddr0(clrR_reg[0][8:4]),.newEn0(clr_reg[0]),
  .newAddr1(clrR_reg[1][8:4]),.newEn1(clr_reg[1]),
  .newAddr2(clrR_reg[2][8:4]),.newEn2(clr_reg[2]),
  .newAddr3(clrR_reg[3][8:4]),.newEn3(clr_reg[3]),
  .newAddr4(clrR_reg[4][8:4]),.newEn4(clr_reg[4]),
  .newAddr5(clrR_reg[5][8:4]),.newEn5(clr_reg[5]),
  .newAddr6(clrR_reg[6][8:4]),.newEn6(clr_reg[6]),
  .newAddr7(clrR_reg[7][8:4]),.newEn7(clr_reg[7]),
  .newAddr8(clrR_reg[8][8:4]),.newEn8(clr_reg[8])
  );

  reginfl reginflVB_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),

  .read0_addr(regBF[0]),.read0_data(inflB[0]),
    .read0_oe(isBV[0]),
  .read1_addr(regBF[1]),.read1_data(inflB[1]),
    .read1_oe(isBV[1]),
  .read2_addr(regBF[2]),.read2_data(inflB[2]),
    .read2_oe(isBV[2]),
  .read3_addr(regBF[3]),.read3_data(inflB[3]),
    .read3_oe(isBV[3]),
  .read4_addr(regBF[4]),.read4_data(inflB[4]),
    .read4_oe(isBV[4]),
  .read5_addr(regBF[5]),.read5_data(inflB[5]),
    .read5_oe(isBV[5]),
  .read6_addr(regBF[6]),.read6_data(inflB[6]),
    .read6_oe(isBV[6]),
  .read7_addr(regBF[7]),.read7_data(inflB[7]),
    .read7_oe(isBV[7]),
  .read8_addr(regBF[8]),.read8_data(inflB[8]),
    .read8_oe(isBV[8]),

  .read0_constEn(~rs_rB_useF[0]||retBF[0]),
  .read1_constEn(~rs_rB_useF[1]||retBF[1]),
  .read2_constEn(~rs_rB_useF[2]||retBF[2]),
  .read3_constEn(~rs_rB_useF[3]||retBF[3]),
  .read4_constEn(~rs_rB_useF[4]||retBF[4]),
  .read5_constEn(~rs_rB_useF[5]||retBF[5]),
  .read6_constEn(~rs_rB_useF[6]||retBF[6]),
  .read7_constEn(~rs_rB_useF[7]||retBF[7]),
  .read8_constEn(~rs_rB_useF[8]||retBF[8]),

  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg2[4]),.write4_wen_reg(FUwen_reg2[4]),
  .write5_addr_reg(FUreg_reg2[5]),.write5_wen_reg(FUwen_reg2[5]),
  .write6_addr_reg(FUreg_reg2[6]),.write6_wen_reg(FUwen_reg2[6]),
  .write7_addr_reg(FUreg_reg2[7]),.write7_wen_reg(FUwen_reg2[7]),
  .write8_addr_reg(FUreg_reg2[8]),.write8_wen_reg(FUwen_reg2[8]),
  .write9_addr_reg(FUreg_reg2[9]),.write9_wen_reg(FUwen_reg2[9]),
  .newAddr0(clrR_reg[0][8:4]),.newEn0(clr_reg[0]),
  .newAddr1(clrR_reg[1][8:4]),.newEn1(clr_reg[1]),
  .newAddr2(clrR_reg[2][8:4]),.newEn2(clr_reg[2]),
  .newAddr3(clrR_reg[3][8:4]),.newEn3(clr_reg[3]),
  .newAddr4(clrR_reg[4][8:4]),.newEn4(clr_reg[4]),
  .newAddr5(clrR_reg[5][8:4]),.newEn5(clr_reg[5]),
  .newAddr6(clrR_reg[6][8:4]),.newEn6(clr_reg[6]),
  .newAddr7(clrR_reg[7][8:4]),.newEn7(clr_reg[7]),
  .newAddr8(clrR_reg[8][8:4]),.newEn8(clr_reg[8])
  );

  
  
  reginfl reginflFB_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),

  .read0_addr(regBF[0]),.read0_data(inflB[0]),
    .read0_oe(isBF[0]),
  .read1_addr(regBF[1]),.read1_data(inflB[1]),
    .read1_oe(isBF[1]),
  .read2_addr(regBF[2]),.read2_data(inflB[2]),
    .read2_oe(isBF[2]),
  .read3_addr(regBF[3]),.read3_data(inflB[3]),
    .read3_oe(isBF[3]),
  .read4_addr(regBF[4]),.read4_data(inflB[4]),
    .read4_oe(isBF[4]),
  .read5_addr(regBF[5]),.read5_data(inflB[5]),
    .read5_oe(isBF[5]),
  .read6_addr(regBF[6]),.read6_data(inflB[6]),
    .read6_oe(isBF[6]),
  .read7_addr(regBF[7]),.read7_data(inflB[7]),
    .read7_oe(isBF[7]),
  .read8_addr(regBF[8]),.read8_data(inflB[8]),
    .read8_oe(isBF[8]),

  .read0_constEn(~rs_rB_useF[0]||retBF[0]),
  .read1_constEn(~rs_rB_useF[1]||retBF[1]),
  .read2_constEn(~rs_rB_useF[2]||retBF[2]),
  .read3_constEn(~rs_rB_useF[3]||retBF[3]),
  .read4_constEn(~rs_rB_useF[4]||retBF[4]),
  .read5_constEn(~rs_rB_useF[5]||retBF[5]),
  .read6_constEn(~rs_rB_useF[6]||retBF[6]),
  .read7_constEn(~rs_rB_useF[7]||retBF[7]),
  .read8_constEn(~rs_rB_useF[8]||retBF[8]),

  .write0_addr_reg(FUreg_reg[0]),.write0_wen_reg(FUwen_reg[0] & FU0Hit),
  .write1_addr_reg(FUreg_reg[1]),.write1_wen_reg(FUwen_reg[1] & FU1Hit),
  .write2_addr_reg(FUreg_reg[2]),.write2_wen_reg(FUwen_reg[2] & FU2Hit),
  .write3_addr_reg(FUreg_reg[3]),.write3_wen_reg(FUwen_reg[3] & FU3Hit),
  .write4_addr_reg(FUreg_reg2[4]),.write4_wen_reg(FUwen_reg2[4]),
  .write5_addr_reg(FUreg_reg2[5]),.write5_wen_reg(FUwen_reg2[5]),
  .write6_addr_reg(FUreg_reg2[6]),.write6_wen_reg(FUwen_reg2[6]),
  .write7_addr_reg(FUreg_reg3[7]),.write7_wen_reg(FUwen_reg3[7]),
  .write8_addr_reg(FUreg_reg3[8]),.write8_wen_reg(FUwen_reg3[8]),
  .write9_addr_reg(FUreg_reg3[9]),.write9_wen_reg(FUwen_reg3[9]),
  .newAddr0(clrR_reg[0][8:4]),.newEn0(clr_reg[0]),
  .newAddr1(clrR_reg[1][8:4]),.newEn1(clr_reg[1]),
  .newAddr2(clrR_reg[2][8:4]),.newEn2(clr_reg[2]),
  .newAddr3(clrR_reg[3][8:4]),.newEn3(clr_reg[3]),
  .newAddr4(clrR_reg[4][8:4]),.newEn4(clr_reg[4]),
  .newAddr5(clrR_reg[5][8:4]),.newEn5(clr_reg[5]),
  .newAddr6(clrR_reg[6][8:4]),.newEn6(clr_reg[6]),
  .newAddr7(clrR_reg[7][8:4]),.newEn7(clr_reg[7]),
  .newAddr8(clrR_reg[8][8:4]),.newEn8(clr_reg[8])
  );
  
  get_clear_reg clr_mod(
  .newR0(newR[0]),.newR1(newR[1]),.newR2(newR[2]),
  .newR3(newR[3]),.newR4(newR[4]),.newR5(newR[5]),
  .newR6(newR[6]),.newR7(newR[7]),.newR8(newR[8]),
  .newRF0(newRF[0]),.newRF1(newRF[1]),.newRF2(newRF[2]),
  .newRF3(newRF[3]),.newRF4(newRF[4]),.newRF5(newRF[5]),
  .newRF6(newRF[6]),.newRF7(newRF[7]),.newRF8(newRF[8]),
  .alloc({
    rs2i2_allocR_reg,rs2i1_allocR_reg,rs2i0_allocR_reg,
    rs1i2_allocR_reg,rs1i1_allocR_reg,rs1i0_allocR_reg,
    rs0i2_allocR_reg,rs0i1_allocR_reg,rs0i0_allocR_reg}),
  .clr(clr),
  .allocS({
    rs2i2_lastFl_reg,rs2i1_lastFl_reg,1'b0,
    rs1i2_lastFl_reg,rs1i1_lastFl_reg,1'b0,
    rs0i2_lastFl_reg,rs0i1_lastFl_reg,1'b0}),
  .clrS(clrS),
  .clrR0(clrR[0]),.clrR1(clrR[1]),.clrR2(clrR[2]),
  .clrR3(clrR[3]),.clrR4(clrR[4]),.clrR5(clrR[5]),
  .clrR6(clrR[6]),.clrR7(clrR[7]),.clrR8(clrR[8]),
  .clrRS0(clrRS[0]),.clrRS1(clrRS[1]),.clrRS2(clrRS[2]),
  .clrRS3(clrRS[3]),.clrRS4(clrRS[4]),.clrRS5(clrRS[5]),
  .clrRS6(clrRS[6]),.clrRS7(clrRS[7]),.clrRS8(clrRS[8])
  );
  
  
  
  regfileFl regS_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_addr(regFl),.read0_data({inflS,dataS}),.read0_oe(~retFl),.read0_gazump(gazumpS),

  .tireRead0_addr(retfl_rF),.tireRead0_data(retfl_data),

  .write0_addr_reg(FUSreg_reg[4]),.write0_data_reg(FUS4),.write0_wen_reg(FUwen_reg[4] && ~outOp_reg[3*0+1][12] && outEn_reg[3*0+1][1]),
  .write1_addr_reg(FUSreg_reg[5]),.write1_data_reg(FUS5),.write1_wen_reg(FUwen_reg[5] && ~outOp_reg[3*1+1][12] && outEn_reg[3*1+1][1]),
  .write2_addr_reg(FUSreg_reg[6]),.write2_data_reg(FUS6),.write2_wen_reg(FUwen_reg[6] && ~outOp_reg[3*2+1][12] && outEn_reg[3*2+1][1]),
  .write3_addr_reg(FUSreg_reg[7]),.write3_data_reg(FUS7),.write3_wen_reg(FUwen_reg[7] && ~outOp_reg[3*0+2][12] && outEn_reg[3*0+2][1]),
  .write4_addr_reg(FUSreg_reg[8]),.write4_data_reg(FUS8),.write4_wen_reg(FUwen_reg[8] && ~outOp_reg[3*1+2][12] && outEn_reg[3*1+2][1]),
  .write5_addr_reg(FUSreg_reg[9]),.write5_data_reg(FUS9),.write5_wen_reg(FUwen_reg[9] && ~outOp_reg[3*2+2][12] && outEn_reg[3*2+2][1]),
  .write6_addr_reg(FUSreg_reg4[4]),.write6_data_reg(FUS1),.write6_wen_reg(FUwen_reg3[4] && fsret[0][2]),
  .write7_addr_reg(FUSreg_reg4[5]),.write7_data_reg(FUS2),.write7_wen_reg(FUwen_reg3[5] && fsret[2][2]),
  .write8_addr_reg(FUSreg_reg4[6]),.write8_data_reg(FUS3),.write8_wen_reg(FUwen_reg3[6] && fsret[4][2]),
  .newAddr0(clrRS_reg[0][8:4]),.newEn0(clrS_reg[0]),
  .newAddr1(clrRS_reg[1][8:4]),.newEn1(clrS_reg[1]),
  .newAddr2(clrRS_reg[2][8:4]),.newEn2(clrS_reg[2]),
  .newAddr3(clrRS_reg[3][8:4]),.newEn3(clrS_reg[3]),
  .newAddr4(clrRS_reg[4][8:4]),.newEn4(clrS_reg[4]),
  .newAddr5(clrRS_reg[5][8:4]),.newEn5(clrS_reg[5]),
  .newAddr6(clrRS_reg[6][8:4]),.newEn6(clrS_reg[6]),
  .newAddr7(clrRS_reg[7][8:4]),.newEn7(clrS_reg[7]),
  .newAddr8(clrRS_reg[8][8:4]),.newEn8(clrS_reg[8])
  );
  
  rrf_flag ffrS_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(~doStall),
  .read0_data({inflS,dataS}),.read0_oe(retFl),
  .write0_data(retfl_data),.write0_wen(retfl_enG),
  .read_thread(thread_reg),
  .write_thread(1'b0)
  );
  
  get_flag_infl flag_in_flight_mod(
  .rs0i1_flagDep(rs0i1_flagDep_reg2),
  .rs0i2_flagDep(rs0i2_flagDep_reg2),
  .rs1i1_flagDep(rs1i1_flagDep_reg2),
  .rs1i2_flagDep(rs1i2_flagDep_reg2),
  .rs2i1_flagDep(rs2i1_flagDep_reg2),
  .rs2i2_flagDep(rs2i2_flagDep_reg2),
  .srcFlight(inflS&&gazumpS[9:0]==10'b0),
  .infl(Sinfl)
  );
  
  
  generate
  
  genvar m,n,u;//,o
  for (m=0;m<3;m=m+1) begin : main_rs_gen
  regfilef #(SIMD_WIDTH,m[1:0]) regAVH_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_match(),.read1_match(),.read2_match(),
  .read3_match(),.read4_match(),.read5_match(),
  .read6_match(),.read7_match(),.read8_match(),
  .read0_addr(regAF_reg[3*m+0]),.read0_data(dataAVH[3*m+0]),
    .read0_oe(~retAF_reg[3*m+0]|~rs_rA_useF_reg[3*m+0]),
  .read1_addr(regAF_reg[3*m+1]),.read1_data(dataAVH[3*m+1]),
    .read1_oe(~retAF_reg[3*m+1]|~rs_rA_useF_reg[3*m+1]),
  .read2_addr(regAF_reg[3*m+2]),.read2_data(dataAVH[3*m+2]),
    .read2_oe(~retAF_reg[3*m+2]|~rs_rA_useF_reg[3*m+2]),

  .read0_addr_rrf(rs_rA_reg[3*m+0]),
  .read1_addr_rrf(rs_rA_reg[3*m+1]),
  .read2_addr_rrf(rs_rA_reg[3*m+2]),

  .read0_constEn(~rs_rA_useF_reg[3*m+0]),
  .read1_constEn(~rs_rA_useF_reg[3*m+1]),
  .read2_constEn(~rs_rA_useF_reg[3*m+2]),

  .read0_const({SIMD_WIDTH{1'B0}}),
  .read1_const({SIMD_WIDTH{1'B0}}),
  .read2_const({SIMD_WIDTH{1'B0}}),

  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enV),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enV),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enV),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enV),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enV),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enV),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enV),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enV),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enV),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg2[0]),.write0_data_reg(FUVH_reg[0]),.write0_wen_reg(FUwen_reg2[0] & FU0Hit_reg),
  .write1_addr_reg(FUreg_reg2[1]),.write1_data_reg(FUVH_reg[1]),.write1_wen_reg(FUwen_reg2[1] & FU1Hit_reg),
  .write2_addr_reg(FUreg_reg2[2]),.write2_data_reg(FUVH_reg[2]),.write2_wen_reg(FUwen_reg2[2] & FU2Hit_reg),
  .write3_addr_reg(FUreg_reg2[3]),.write3_data_reg(FUVH_reg[3]),.write3_wen_reg(FUwen_reg2[3] & FU3Hit_reg),
  .write4_addr_reg(FUreg_reg3[4]),.write4_data_reg(FUVH_reg[4]),.write4_wen_reg(FUwen_reg3[4]),
  .write5_addr_reg(FUreg_reg3[5]),.write5_data_reg(FUVH_reg[5]),.write5_wen_reg(FUwen_reg3[5]),
  .write6_addr_reg(FUreg_reg3[6]),.write6_data_reg(FUVH_reg[6]),.write6_wen_reg(FUwen_reg3[6]),
  .write7_addr_reg(FUreg_reg3[7]),.write7_data_reg(FUVH_reg[7]),.write7_wen_reg(FUwen_reg3[7]),
  .write8_addr_reg(FUreg_reg3[8]),.write8_data_reg(FUVH_reg[8]),.write8_wen_reg(FUwen_reg3[8]),
  .write9_addr_reg(FUreg_reg3[9]),.write9_data_reg(FUVH_reg[9]),.write9_wen_reg(FUwen_reg3[9])
  );

  regfilef #(16+SIMD_WIDTH,m[1:0]) regAVL_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_match(),.read1_match(),.read2_match(),
  .read3_match(),.read4_match(),.read5_match(),
  .read6_match(),.read7_match(),.read8_match(),
  .read0_addr(regAF_reg[3*m+0]),.read0_data(dataAVL[3*m+0]),
    .read0_oe(~retAF_reg[3*m+0]|~rs_rA_useF_reg[3*m+0]),
  .read1_addr(regAF_reg[3*m+1]),.read1_data(dataAVL[3*m+1]),
    .read1_oe(~retAF_reg[3*m+1]|~rs_rA_useF_reg[3*m+1]),
  .read2_addr(regAF_reg[3*m+2]),.read2_data(dataAVL[3*m+2]),
    .read2_oe(~retAF_reg[3*m+2]|~rs_rA_useF_reg[3*m+2]),

  .read0_addr_rrf(rs_rA_reg[3*m+0]),
  .read1_addr_rrf(rs_rA_reg[3*m+1]),
  .read2_addr_rrf(rs_rA_reg[3*m+2]),

  .read0_constEn(~rs_rA_useF_reg[3*m+0]),
  .read1_constEn(~rs_rA_useF_reg[3*m+1]),
  .read2_constEn(~rs_rA_useF_reg[3*m+2]),

  .read0_const({SIMD_WIDTH{1'B0}}),
  .read1_const({SIMD_WIDTH{1'B0}}),
  .read2_const({SIMD_WIDTH{1'B0}}),

  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enV),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enV),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enV),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enV),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enV),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enV),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enV),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enV),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enV),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg2[0]),.write0_data_reg(FUVL_reg[0]),.write0_wen_reg(FUwen_reg2[0] & FU0Hit_reg),
  .write1_addr_reg(FUreg_reg2[1]),.write1_data_reg(FUVL_reg[1]),.write1_wen_reg(FUwen_reg2[1] & FU1Hit_reg),
  .write2_addr_reg(FUreg_reg2[2]),.write2_data_reg(FUVL_reg[2]),.write2_wen_reg(FUwen_reg2[2] & FU2Hit_reg),
  .write3_addr_reg(FUreg_reg2[3]),.write3_data_reg(FUVL_reg[3]),.write3_wen_reg(FUwen_reg2[3] & FU3Hit_reg),
  .write4_addr_reg(FUreg_reg3[4]),.write4_data_reg(FUVL_reg[4]),.write4_wen_reg(FUwen_reg3[4]),
  .write5_addr_reg(FUreg_reg3[5]),.write5_data_reg(FUVL_reg[5]),.write5_wen_reg(FUwen_reg3[5]),
  .write6_addr_reg(FUreg_reg3[6]),.write6_data_reg(FUVL_reg[6]),.write6_wen_reg(FUwen_reg3[6]),
  .write7_addr_reg(FUreg_reg3[7]),.write7_data_reg(FUVL_reg[7]),.write7_wen_reg(FUwen_reg3[7]),
  .write8_addr_reg(FUreg_reg3[8]),.write8_data_reg(FUVL_reg[8]),.write8_wen_reg(FUwen_reg3[8]),
  .write9_addr_reg(FUreg_reg3[9]),.write9_data_reg(FUVL_reg[9]),.write9_wen_reg(FUwen_reg3[9])
  );

  regfilef #(SIMD_WIDTH,m[1:0]) regAFH_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_match(),.read1_match(),.read2_match(),
  .read0_addr(regAF_reg2[3*m+0]),.read0_data(dataAFH[3*m+0]),
    .read0_oe(~retAF_reg2[3*m+0]|~rs_rA_useF_reg2[3*m+0]),
  .read1_addr(regAF_reg2[3*m+1]),.read1_data(dataAFH[3*m+1]),
    .read1_oe(~retAF_reg2[3*m+1]|~rs_rA_useF_reg2[3*m+1]),
  .read2_addr(regAF_reg2[3*m+2]),.read2_data(dataAFH[3*m+2]),
    .read2_oe(~retAF_reg2[3*m+2]|~rs_rA_useF_reg2[3*m+2]),

  .read0_addr_rrf(rs_rA_reg2[3*m+0]),
  .read1_addr_rrf(rs_rA_reg2[3*m+1]),
  .read2_addr_rrf(rs_rA_reg2[3*m+2]),

  .read0_constEn(~rs_rA_useF_reg2[3*m+0]),
  .read1_constEn(~rs_rA_useF_reg2[3*m+1]),
  .read2_constEn(~rs_rA_useF_reg2[3*m+2]),

  .read0_const(is_rndE(rs_operation_reg2[3*m+0]) ? 70'b0 : {1'b1,^fpD_one,fpD_one}),
  .read1_const(is_rndE(rs_operation_reg2[3*m+1]) ? 70'b0 : {1'b1,^fpD_one,fpD_one}),
  .read2_const(is_rndE(rs_operation_reg2[3*m+2]) ? 70'b0 : {1'b1,^fpD_one,fpD_one}),

  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enF),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enF),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enF),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enF),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enF),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enF),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enF),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enF),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enF),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg3[0]),.write0_data_reg(FUFH_reg[0]),.write0_wen_reg(FUwen_reg3[0] & FU0Hit_reg2),
  .write1_addr_reg(FUreg_reg3[1]),.write1_data_reg(FUFH_reg[1]),.write1_wen_reg(FUwen_reg3[1] & FU1Hit_reg2),
  .write2_addr_reg(FUreg_reg3[2]),.write2_data_reg(FUFH_reg[2]),.write2_wen_reg(FUwen_reg3[2] & FU2Hit_reg2),
  .write3_addr_reg(FUreg_reg3[3]),.write3_data_reg(FUFH_reg[3]),.write3_wen_reg(FUwen_reg3[3] & FU3Hit_reg2),
  .write4_addr_reg(FUreg_reg4[4]),.write4_data_reg(FUFH_reg[4]),.write4_wen_reg(FUwen_reg4[4]),
  .write5_addr_reg(FUreg_reg4[5]),.write5_data_reg(FUFH_reg[5]),.write5_wen_reg(FUwen_reg4[5]),
  .write6_addr_reg(FUreg_reg4[6]),.write6_data_reg(FUFH_reg[6]),.write6_wen_reg(FUwen_reg4[6]),
  .write7_addr_reg(FUreg_reg5[7]),.write7_data_reg(FUFH_reg[7]),.write7_wen_reg(FUwen_reg5[7]),
  .write8_addr_reg(FUreg_reg5[8]),.write8_data_reg(FUFH_reg[8]),.write8_wen_reg(FUwen_reg5[8]),
  .write9_addr_reg(FUreg_reg5[9]),.write9_data_reg(FUFH_reg[9]),.write9_wen_reg(FUwen_reg5[9])
  );


  regfilef #(16+SIMD_WIDTH,m[1:0]) regAFL_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_match(),.read1_match(),.read2_match(),
  .read0_addr(regAF_reg2[3*m+0]),.read0_data(dataAFL[3*m+0]),
    .read0_oe(~retAF_reg2[3*m+0]|~rs_rA_useF_reg2[3*m+0]),
  .read1_addr(regAF_reg2[3*m+1]),.read1_data(dataAFL[3*m+1]),
    .read1_oe(~retAF_reg2[3*m+1]|~rs_rA_useF_reg2[3*m+1]),
  .read2_addr(regAF_reg2[3*m+2]),.read2_data(dataAFL[3*m+2]),
    .read2_oe(~retAF_reg2[3*m+2]|~rs_rA_useF_reg2[3*m+2]),

  .read0_constEn(~rs_rA_useF_reg2[3*m+0]),
  .read1_constEn(~rs_rA_useF_reg2[3*m+1]),
  .read2_constEn(~rs_rA_useF_reg2[3*m+2]),

  .read0_addr_rrf(rs_rA_reg2[3*m+0]),
  .read1_addr_rrf(rs_rA_reg2[3*m+1]),
  .read2_addr_rrf(rs_rA_reg2[3*m+2]),

  .read0_const(is_rndE(rs_operation_reg2[3*m+0]) ? {1'b1,^fpE_one,fpE_one} : {16'b0,1'b1,^fpD_one,fpD_one}),
  .read1_const(is_rndE(rs_operation_reg2[3*m+1]) ? {1'b1,^fpE_one,fpE_one} : {16'b0,1'b1,^fpD_one,fpD_one}),
  .read2_const(is_rndE(rs_operation_reg2[3*m+2]) ? {1'b1,^fpE_one,fpE_one} : {16'b0,1'b1,^fpD_one,fpD_one}),


  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enF),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enF),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enF),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enF),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enF),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enF),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enF),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enF),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enF),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg3[0]),.write0_data_reg(FUFL_reg[0]),.write0_wen_reg(FUwen_reg3[0] & FU0Hit_reg2),
  .write1_addr_reg(FUreg_reg3[1]),.write1_data_reg(FUFL_reg[1]),.write1_wen_reg(FUwen_reg3[1] & FU1Hit_reg2),
  .write2_addr_reg(FUreg_reg3[2]),.write2_data_reg(FUFL_reg[2]),.write2_wen_reg(FUwen_reg3[2] & FU2Hit_reg2),
  .write3_addr_reg(FUreg_reg3[3]),.write3_data_reg(FUFL_reg[3]),.write3_wen_reg(FUwen_reg3[3] & FU3Hit_reg2),
  .write4_addr_reg(FUreg_reg4[4]),.write4_data_reg(FUFL_reg[4]),.write4_wen_reg(FUwen_reg4[4]),
  .write5_addr_reg(FUreg_reg4[5]),.write5_data_reg(FUFL_reg[5]),.write5_wen_reg(FUwen_reg4[5]),
  .write6_addr_reg(FUreg_reg4[6]),.write6_data_reg(FUFL_reg[6]),.write6_wen_reg(FUwen_reg4[6]),
  .write7_addr_reg(FUreg_reg5[7]),.write7_data_reg(FUFL_reg[7]),.write7_wen_reg(FUwen_reg5[7]),
  .write8_addr_reg(FUreg_reg5[8]),.write8_data_reg(FUFL_reg[8]),.write8_wen_reg(FUwen_reg5[8]),
  .write9_addr_reg(FUreg_reg5[9]),.write9_data_reg(FUFL_reg[9]),.write9_wen_reg(FUwen_reg5[9])
  );

  regfilef #(SIMD_WIDTH,m[1:0]) regBVH_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_match(),.read1_match(),.read2_match(),
  .read0_addr(regBF_reg[3*m+0]),.read0_data(dataBVH[3*m+0]),
    .read0_oe(~retBF_reg[3*m+0]|~rs_rB_useF_reg[3*m+0]),
  .read1_addr(regBF_reg[3*m+1]),.read1_data(dataBVH[3*m+1]),
    .read1_oe(~retBF_reg[3*m+1]|~rs_rB_useF_reg[3*m+1]),
  .read2_addr(regBF_reg[3*m+2]),.read2_data(dataBVH[3*m+2]),
    .read2_oe(~retBF_reg[3*m+2]|~rs_rB_useF_reg[3*m+2]),

  .read0_constEn(~rs_rB_useF_reg[3*m+0]),
  .read1_constEn(~rs_rB_useF_reg[3*m+1]),
  .read2_constEn(~rs_rB_useF_reg[3*m+2]),

  .read0_addr_rrf(rs_rB_reg[3*m+0]),
  .read1_addr_rrf(rs_rB_reg[3*m+1]),
  .read2_addr_rrf(rs_rB_reg[3*m+2]),

  .read0_const({SIMD_WIDTH{1'B0}}),
  .read1_const({SIMD_WIDTH{1'B0}}),
  .read2_const({SIMD_WIDTH{1'B0}}),

  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enV),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enV),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enV),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enV),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enV),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enV),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enV),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enV),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enV),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg2[0]),.write0_data_reg(FUVH_reg[0]),.write0_wen_reg(FUwen_reg2[0] & FU0Hit_reg),
  .write1_addr_reg(FUreg_reg2[1]),.write1_data_reg(FUVH_reg[1]),.write1_wen_reg(FUwen_reg2[1] & FU1Hit_reg),
  .write2_addr_reg(FUreg_reg2[2]),.write2_data_reg(FUVH_reg[2]),.write2_wen_reg(FUwen_reg2[2] & FU2Hit_reg),
  .write3_addr_reg(FUreg_reg2[3]),.write3_data_reg(FUVH_reg[3]),.write3_wen_reg(FUwen_reg2[3] & FU3Hit_reg),
  .write4_addr_reg(FUreg_reg3[4]),.write4_data_reg(FUVH_reg[4]),.write4_wen_reg(FUwen_reg3[4]),
  .write5_addr_reg(FUreg_reg3[5]),.write5_data_reg(FUVH_reg[5]),.write5_wen_reg(FUwen_reg3[5]),
  .write6_addr_reg(FUreg_reg3[6]),.write6_data_reg(FUVH_reg[6]),.write6_wen_reg(FUwen_reg3[6]),
  .write7_addr_reg(FUreg_reg3[7]),.write7_data_reg(FUVH_reg[7]),.write7_wen_reg(FUwen_reg3[7]),
  .write8_addr_reg(FUreg_reg3[8]),.write8_data_reg(FUVH_reg[8]),.write8_wen_reg(FUwen_reg3[8]),
  .write9_addr_reg(FUreg_reg3[9]),.write9_data_reg(FUVH_reg[9]),.write9_wen_reg(FUwen_reg3[9])
  );

  regfilef #(16+SIMD_WIDTH,m[1:0]) regBVL_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_match(),.read1_match(),.read2_match(),
  .read0_addr(regBF_reg[3*m+0]),.read0_data(dataBVL[3*m+0]),
    .read0_oe(~retBF_reg[3*m+0]|~rs_rB_useF_reg[3*m+0]),
  .read1_addr(regBF_reg[3*m+1]),.read1_data(dataBVL[3*m+1]),
    .read1_oe(~retBF_reg[3*m+1]|~rs_rB_useF_reg[3*m+1]),
  .read2_addr(regBF_reg[3*m+2]),.read2_data(dataBVL[3*m+2]),
    .read2_oe(~retBF_reg[3*m+2]|~rs_rB_useF_reg[3*m+2]),

  .read0_constEn(~rs_rB_useF_reg[3*m+0]),
  .read1_constEn(~rs_rB_useF_reg[3*m+1]),
  .read2_constEn(~rs_rB_useF_reg[3*m+2]),

  .read0_addr_rrf(rs_rB_reg[3*m+0]),
  .read1_addr_rrf(rs_rB_reg[3*m+1]),
  .read2_addr_rrf(rs_rB_reg[3*m+2]),

  .read0_const({SIMD_WIDTH{1'B0}}),
  .read1_const({SIMD_WIDTH{1'B0}}),
  .read2_const({SIMD_WIDTH{1'B0}}),

  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enV),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enV),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enV),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enV),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enV),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enV),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enV),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enV),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enV),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg2[0]),.write0_data_reg(FUVL_reg[0]),.write0_wen_reg(FUwen_reg2[0] & FU0Hit_reg),
  .write1_addr_reg(FUreg_reg2[1]),.write1_data_reg(FUVL_reg[1]),.write1_wen_reg(FUwen_reg2[1] & FU1Hit_reg),
  .write2_addr_reg(FUreg_reg2[2]),.write2_data_reg(FUVL_reg[2]),.write2_wen_reg(FUwen_reg2[2] & FU2Hit_reg),
  .write3_addr_reg(FUreg_reg2[3]),.write3_data_reg(FUVL_reg[3]),.write3_wen_reg(FUwen_reg2[3] & FU3Hit_reg),
  .write4_addr_reg(FUreg_reg3[4]),.write4_data_reg(FUVL_reg[4]),.write4_wen_reg(FUwen_reg3[4]),
  .write5_addr_reg(FUreg_reg3[5]),.write5_data_reg(FUVL_reg[5]),.write5_wen_reg(FUwen_reg3[5]),
  .write6_addr_reg(FUreg_reg3[6]),.write6_data_reg(FUVL_reg[6]),.write6_wen_reg(FUwen_reg3[6]),
  .write7_addr_reg(FUreg_reg3[7]),.write7_data_reg(FUVL_reg[7]),.write7_wen_reg(FUwen_reg3[7]),
  .write8_addr_reg(FUreg_reg3[8]),.write8_data_reg(FUVL_reg[8]),.write8_wen_reg(FUwen_reg3[8]),
  .write9_addr_reg(FUreg_reg3[9]),.write9_data_reg(FUVL_reg[9]),.write9_wen_reg(FUwen_reg3[9])
  );
  regfilef #(SIMD_WIDTH,m[1:0]) regBFH_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_match(),.read1_match(),.read2_match(),
  .read0_addr(regBF_reg2[3*m+0]),.read0_data(dataBFH[3*m+0]),
    .read0_oe(~retBF_reg2[3*m+0]|~rs_rB_useF_reg2[3*m+0]),
  .read1_addr(regBF_reg2[3*m+1]),.read1_data(dataBFH[3*m+1]),
    .read1_oe(~retBF_reg2[3*m+1]|~rs_rB_useF_reg2[3*m+1]),
  .read2_addr(regBF_reg2[3*m+2]),.read2_data(dataBFH[3*m+2]),
    .read2_oe(~retBF_reg2[3*m+2]|~rs_rB_useF_reg2[3*m+2]),

  .read0_constEn(~rs_rB_useF_reg2[3*m+0]),
  .read1_constEn(~rs_rB_useF_reg2[3*m+1]),
  .read2_constEn(~rs_rB_useF_reg2[3*m+2]),

  .read0_const({SIMD_WIDTH{1'B0}}),
  .read1_const({SIMD_WIDTH{1'B0}}),
  .read2_const({SIMD_WIDTH{1'B0}}),

  .read0_addr_rrf(rs_rB_reg2[3*m+0]),
  .read1_addr_rrf(rs_rB_reg2[3*m+1]),
  .read2_addr_rrf(rs_rB_reg2[3*m+2]),


  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enF),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enF),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enF),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enF),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enF),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enF),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enF),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enF),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enF),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_reg(FUreg_reg3[0]),.write0_data_reg(FUFH_reg[0]),.write0_wen_reg(FUwen_reg3[0] & FU0Hit_reg2),
  .write1_addr_reg(FUreg_reg3[1]),.write1_data_reg(FUFH_reg[1]),.write1_wen_reg(FUwen_reg3[1] & FU1Hit_reg2),
  .write2_addr_reg(FUreg_reg3[2]),.write2_data_reg(FUFH_reg[2]),.write2_wen_reg(FUwen_reg3[2] & FU2Hit_reg2),
  .write3_addr_reg(FUreg_reg3[3]),.write3_data_reg(FUFH_reg[3]),.write3_wen_reg(FUwen_reg3[3] & FU3Hit_reg2),
  .write4_addr_reg(FUreg_reg4[4]),.write4_data_reg(FUFH_reg[4]),.write4_wen_reg(FUwen_reg4[4]),
  .write5_addr_reg(FUreg_reg4[5]),.write5_data_reg(FUFH_reg[5]),.write5_wen_reg(FUwen_reg4[5]),
  .write6_addr_reg(FUreg_reg4[6]),.write6_data_reg(FUFH_reg[6]),.write6_wen_reg(FUwen_reg4[6]),
  .write7_addr_reg(FUreg_reg5[7]),.write7_data_reg(FUFH_reg[7]),.write7_wen_reg(FUwen_reg5[7]),
  .write8_addr_reg(FUreg_reg5[8]),.write8_data_reg(FUFH_reg[8]),.write8_wen_reg(FUwen_reg5[8]),
  .write9_addr_reg(FUreg_reg5[9]),.write9_data_reg(FUFH_reg[9]),.write9_wen_reg(FUwen_reg5[9])
  );

  regfilef #(16+SIMD_WIDTH,m[1:0]) regBFL_mod(
  .clk(clk),
  .clkREF(clkREF),
  .clkREF2(clkREF2),
  .clkREF3(clkREF3),
  .clkREF4(clkREF4),
  .clkREF5(clkREF5),
  .rst(rst),
  .read_clkEn(~doStall),
  .tire_clkEn(1'b1),

  .read0_match(),.read1_match(),.read2_match(),
  .read0_addr(regBF_reg2[3*m+0]),.read0_data(dataBFL[3*m+0]),
    .read0_oe(~retBF_reg2[3*m+0]|~rs_rB_useF_reg2[3*m+0]),
  .read1_addr(regBF_reg2[3*m+1]),.read1_data(dataBFL[3*m+1]),
    .read1_oe(~retBF_reg2[3*m+1]|~rs_rB_useF_reg2[3*m+1]),
  .read2_addr(regBF_reg2[3*m+2]),.read2_data(dataBFL[3*m+2]),
    .read2_oe(~retBF_reg2[3*m+2]|~rs_rB_useF_reg2[3*m+2]),

  .read0_constEn(~rs_rB_useF_reg2[3*m+0]),
  .read1_constEn(~rs_rB_useF_reg2[3*m+1]),
  .read2_constEn(~rs_rB_useF_reg2[3*m+2]),

  .read0_const({16+SIMD_WIDTH{1'B0}}),
  .read1_const({16+SIMD_WIDTH{1'B0}}),
  .read2_const({16+SIMD_WIDTH{1'B0}}),

  .read0_addr_rrf(rs_rB_reg2[3*m+0]),
  .read1_addr_rrf(rs_rB_reg2[3*m+1]),
  .read2_addr_rrf(rs_rB_reg2[3*m+2]),


  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .write0_addr_rrf(tire0_rT),.write0_wen_rrf(tire0_enF),
  .write1_addr_rrf(tire1_rT),.write1_wen_rrf(tire1_enF),
  .write2_addr_rrf(tire2_rT),.write2_wen_rrf(tire2_enF),
  .write3_addr_rrf(tire3_rT),.write3_wen_rrf(tire3_enF),
  .write4_addr_rrf(tire4_rT),.write4_wen_rrf(tire4_enF),
  .write5_addr_rrf(tire5_rT),.write5_wen_rrf(tire5_enF),
  .write6_addr_rrf(tire6_rT),.write6_wen_rrf(tire6_enF),
  .write7_addr_rrf(tire7_rT),.write7_wen_rrf(tire7_enF),
  .write8_addr_rrf(tire8_rT),.write8_wen_rrf(tire8_enF),
  .tireRead0_addr(tire0_rF),
  .tireRead1_addr(tire1_rF),
  .tireRead2_addr(tire2_rF),
  .tireRead3_addr(tire3_rF),
  .tireRead4_addr(tire4_rF),
  .tireRead5_addr(tire5_rF),
  .tireRead6_addr(tire6_rF),
  .tireRead7_addr(tire7_rF),
  .tireRead8_addr(tire8_rF),

  .read0_addr_rrf(rs0i0_rB_reg3),
  .read1_addr_rrf(rs0i1_rB_reg3),
  .read2_addr_rrf(rs0i2_rB_reg3),
  .read3_addr_rrf(rs1i0_rB_reg3),
  .read4_addr_rrf(rs1i1_rB_reg3),
  .read5_addr_rrf(rs1i2_rB_reg3),
  .read6_addr_rrf(rs2i0_rB_reg3),
  .read7_addr_rrf(rs2i1_rB_reg3),
  .read8_addr_rrf(rs2i2_rB_reg3),


  .write0_addr_reg(FUreg_reg3[0]),.write0_data_reg(FUFL_reg[0]),.write0_wen_reg(FUwen_reg3[0] & FU0Hit_reg2),
  .write1_addr_reg(FUreg_reg3[1]),.write1_data_reg(FUFL_reg[1]),.write1_wen_reg(FUwen_reg3[1] & FU1Hit_reg2),
  .write2_addr_reg(FUreg_reg3[2]),.write2_data_reg(FUFL_reg[2]),.write2_wen_reg(FUwen_reg3[2] & FU2Hit_reg2),
  .write3_addr_reg(FUreg_reg3[3]),.write3_data_reg(FUFL_reg[3]),.write3_wen_reg(FUwen_reg3[3] & FU3Hit_reg2),
  .write4_addr_reg(FUreg_reg4[4]),.write4_data_reg(FUFL_reg[4]),.write4_wen_reg(FUwen_reg4[4]),
  .write5_addr_reg(FUreg_reg4[5]),.write5_data_reg(FUFL_reg[5]),.write5_wen_reg(FUwen_reg4[5]),
  .write6_addr_reg(FUreg_reg4[6]),.write6_data_reg(FUFL_reg[6]),.write6_wen_reg(FUwen_reg4[6]),
  .write7_addr_reg(FUreg_reg5[7]),.write7_data_reg(FUFL_reg[7]),.write7_wen_reg(FUwen_reg5[7]),
  .write8_addr_reg(FUreg_reg5[8]),.write8_data_reg(FUFL_reg[8]),.write8_wen_reg(FUwen_reg5[8]),
  .write9_addr_reg(FUreg_reg5[9]),.write9_data_reg(FUFL_reg[9]),.write9_wen_reg(FUwen_reg5[9])
  );

  rs rs0_mod(
  .clk(clk),
  .dataRst(rst|do_rst_sched),.nonDataRst(except|rst),.rst_thread(1'b0),
  .stall(stall_rs[m]),
  .doStall(doStall_rs[m]),
  .FU0Hit(FU0Hit),.FU1Hit(FU1Hit),.FU2Hit(FU2Hit),.FU3Hit(FU3Hit),
  .new_thread(thread_reg2),
// wires to store new values in a buffer
  .newDataA0(dataA[3*m+0]),.newDataB0(dataB[3*m+0]),
     .newDataC0(rs_const_reg[3*m+0][43:0]&{44{~rs_useBConst_reg[3*m+0]}}),
    .newRegA0(regA_reg[3*m+0]|{9{~inflA[3*m+0]&~depA_reg[3*m+0]}}),
    .newRegB0(regB_reg[3*m+0]|{9{~inflB[3*m+0]&~depB_reg[3*m+0]}}),
    .newANeeded0(inflA[3*m+0]|depA_reg[3*m+0]),.newBNeeded0(inflB[3*m+0]|depB_reg[3*m+0]),.newReg0(newR_reg[3*m+0]),
    .newOp0(rs_operation_reg[3*m+0]),.newPort0(rs_port_sch[3*m+0]),.newInstrIndex0({II_upper,rs_index_reg[3*m+0]}),.newLSQ0({LSQ_upper,rs_lsi_reg[m+0]}),
    .rsAlloc0(rs_en_reg[3*m+0]&~rs_alt_reg[m]),.newGazumpA0(gazumpA[3*m+0]),.newGazumpB0(gazumpB[3*m+0]),
    .newFunitA0(funA_reg[3*m+0]),.newFunitB0(funB_reg[3*m+0]),.newWQ0(WQR_reg[m]),.newLSFlag0(rs_ldst_flg_reg[2*m]),
    .newAttr0(newAttr_reg2),
  .newDataA1(dataA[3*m+1]),.newDataB1(dataB[3*m+1]),
     .newDataC1(rs_const_reg[3*m+1][43:0]&{44{~rs_useBConst_reg[3*m+1]}}),.newDataS1(dataS),
    .newRegA1(regA_reg[3*m+1]|{9{~inflA[3*m+1]&~depA_reg[3*m+1]}}),
    .newRegB1(regB_reg[3*m+1]|{9{~inflB[3*m+1]&~depB_reg[3*m+1]}}),
    .newRegS1(regS_reg[3*m+1]|{REG_WIDTH{~Sinfl[3*m+1]}}),
    .newANeeded1(inflA[3*m+1]|depA_reg[3*m+1]),.newBNeeded1(inflB[3*m+1]|depB_reg[3*m+1]),.newSNeeded1(Sinfl[3*m+1]),
    .newReg1(newR_reg[3*m+1]),.newRegSimd1(newRF_reg[3*m+1]),
    .newOp1(rs_operation_reg[3*m+1]),.newPort1(rs_port_sch[3*m+1]),.newInstrIndex1({II_upper,rs_index_reg[3*m+1]}),.newLSQ1({LSQ_upper,rs_lsi_reg[m+3]}),
    .rsAlloc1(rs_en_reg[3*m+1]),.newGazumpA1(gazumpA[3*m+1]),.newGazumpB1(gazumpB[3*m+1]),.newGazumpS1(gazumpS),
    .newFunitA1(funA_reg[3*m+1]),.newFunitB1(funB_reg[3*m+1]),.newFunitS1(funS_reg[3*m+1]),.newLSFlag1(rs_ldst_flg_reg[2*m+1]),
    .newAttr1(newAttr_reg2),.newXPort1(rs_xport[3*m+1]),
  .newDataA2(dataA[3*m+2]),.newDataB2(dataB[3*m+2]),
    .newDataC2(33'b0),.newDataS2(dataS),
    .newRegA2(regA_reg[3*m+2]|{9{~inflA[3*m+2]&~depA_reg[3*m+2]}}),
    .newRegB2(regB_reg[3*m+2]|{9{~inflB[3*m+2]&~depB_reg[3*m+2]}}),
    .newRegS2(regS_reg[3*m+2]|{REG_WIDTH{~Sinfl[3*m+2]}}),
    .newANeeded2(inflA[3*m+2]|depA_reg[3*m+2]),.newBNeeded2(inflB[3*m+2]|depB_reg[3*m+2]),.newSNeeded2(Sinfl[3*m+2]),.newReg2(newR_reg[3*m+2]),.newRegSimd2(newRF_reg[3*m+2]),
    .newOp2(rs_operation_reg[3*m+2]),.newPort2(rs_port_sch[3*m+2]),.newInstrIndex2({II_upper,rs_index_reg[3*m+2]}),
    .rsAlloc2(rs_en_reg[3*m+2]),.newGazumpA2(gazumpA[3*m+2]),.newGazumpB2(gazumpB[3*m+2]),.newGazumpS2(gazumpS),
    .newFunitA2(funA_reg[3*m+2]),.newFunitB2(funB_reg[3*m+2]),.newFunitS2(funS_reg[3*m+2]),
    .newAttr2(newAttr_reg2),.newXPort2(rs_xport[3*m+2]),
// wires to get values out of buffer
  .outDataA0(outDataA[3*m+0]),.outDataB0(outDataB[3*m+0]),
	  .outDataC0(outDataC[3*m+0]),.outReg0(outReg[3*m+0]),
    .outOp0(outOp[3*m+0]),.outInstrIndex0(outII[3*m+0]), .outFuFwdA0(fuFwdA[3*m+0]),.outFuFwdB0(fuFwdB[3*m+0]),
    .outFuuFwdA0(fuuFwdA[3*m+0]),.outFuuFwdB0(fuuFwdB[3*m+0]),.outLSQ0(outLSQ[m]),.outDataEn0(outEn[3*m+0]),
    .outThread0(outThr[3*m+0]),.outWQ0(outWQ[m]),.outLSFlag0(outLSflag[m]),
    .outAttr0(outAttr[3*m+0]),//addrcalc
  .outDataA1(outDataA[3*m+1]),.outDataB1(outDataB[3*m+1]),
    .outDataC1(outDataC[3*m+1]), 
    .outDataS1(outDataS[3*m+1]),.outReg1(outReg[3*m+1]),
    .outRegSimd1(outRegS[3*m+1]),.outOp1(outOp[3*m+1]),.outInstrIndex1(outII[3*m+1]),
    .outFuFwdA1(fuFwdA[3*m+1]),.outFuFwdB1(fuFwdB[3*m+1]),.outFuFwdS1(fuFwdS[3*m+1]),
    .outFuuFwdA1(fuuFwdA[3*m+1]),.outFuuFwdB1(fuuFwdB[3*m+1]),.outFuuFwdS1(fuuFwdS[3*m+1]),
    .outDataEn1(outEn[3*m+1]),
    .outThread1(outThr[3*m+1]),
    .outAttr1(outAttr[3*m+1]),//alu 1
    .outXPort1(outXAM[3*m+1]),
  .outDataA2(outDataA[3*m+2]),.outDataB2(outDataB[3*m+2]),
    .outDataS2(outDataS[3*m+2]),.outReg2(outReg[3*m+2]),
    .outRegSimd2(outRegS[3*m+2]),.outOp2(outOp[3*m+2]),.outInstrIndex2(outII[3*m+2]),.outFuFwdA2(fuFwdA[3*m+2]),
    .outFuFwdB2(fuFwdB[3*m+2]),.outFuFwdS2(fuFwdS[3*m+2]),.outFuuFwdA2(fuuFwdA[3*m+2]),
    .outFuuFwdB2(fuuFwdB[3*m+2]),.outFuuFwdS2(fuuFwdS[3*m+2]),.outDataEn2(outEn[3*m+2]),
    .outThread2(outThr[3*m+2]),
    .outAttr2(outAttr[3*m+2]),//alu 2
    .outXPort2(outXAM[3*m+2]),
// wires from functional units  
  .FU0(FU_reg[0]),.FUreg0(FUreg[0]),.FUwen0(FUwen[0]),
  .FU1(FU_reg[1]),.FUreg1(FUreg[1]),.FUwen1(FUwen[1]),
  .FU2(FU_reg[2]),.FUreg2(FUreg[2]),.FUwen2(FUwen[2]),
  .FU3(FU_reg[3]),.FUreg3(FUreg[3]),.FUwen3(FUwen[3]),
  .FU4(FU_reg[4]),.FUreg4(FUreg[4]),.FUwen4(FUwen[4]),
  .FU5(FU_reg[5]),.FUreg5(FUreg[5]),.FUwen5(FUwen[5]),
  .FU6(FU_reg[6]),.FUreg6(FUreg[6]),.FUwen6(FUwen[6]),
  .FU7(FU_reg[7]),.FUreg7(FUreg[7]),.FUwen7(FUwen[7]),
  .FU8(FU_reg[8]),.FUreg8(FUreg[8]),.FUwen8(FUwen[8]),
  .FU9(FU_reg[9]),.FUreg9(FUreg[9]),.FUwen9(FUwen[9]),
  
  .newDataVA1H(dataAVH[3*m+1]),.newDataVB1H(dataBVH[3*m+1]),
  .newDataVA1L(dataAVL[3*m+1]),.newDataVB1L(dataBVL[3*m+1]),
  .newDataFA1H(dataAFH[3*m+1]),.newDataFB1H(dataBFH[3*m+1]),
  .newDataFA1L(dataAFL[3*m+1]),.newDataFB1L(dataBFL[3*m+1]),
  .newDataVA2H(dataAVH[3*m+2]),.newDataVB2H(dataBVH[3*m+2]),
  .newDataVA2L(dataAVL[3*m+2]),.newDataVB2L(dataBVL[3*m+2]),
  .newDataFA2H(dataAFH[3*m+2]),.newDataFB2H(dataBFH[3*m+2]),
  .newDataFA2L(dataAFL[3*m+2]),.newDataFB2L(dataBFL[3*m+2]),

  .outDataVA1H(outDataAVH[2*m+0]),.outDataVB1H(outDataBVH[2*m+0]),
  .outDataVA1L(outDataAVL[2*m+0]),.outDataVB1L(outDataBVL[2*m+0]),
  .outDataFA1H(outDataAFH[2*m+0]),.outDataFB1H(outDataBFH[2*m+0]),
  .outDataFA1L(outDataAFL[2*m+0]),.outDataFB1L(outDataBFL[2*m+0]),
  .outDataVA2H(outDataAVH[2*m+1]),.outDataVB2H(outDataBVH[2*m+1]),
  .outDataVA2L(outDataAVL[2*m+1]),.outDataVB2L(outDataBVL[2*m+1]),
  .outDataFA2H(outDataAFH[2*m+1]),.outDataFB2H(outDataBFH[2*m+1]),
  .outDataFA2L(outDataAFL[2*m+1]),.outDataFB2L(outDataBFL[2*m+1]),

  .FUV0H(FUVH_reg[0]),.FUV0L(FUVL_reg[0]),.FUF0H(FUFH_reg[0]),.FUF0L(FUFL_reg[0]),
  .FUV1H(FUVH_reg[1]),.FUV1L(FUVL_reg[1]),.FUF1H(FUFH_reg[1]),.FUF1L(FUFL_reg[1]),
  .FUV2H(FUVH_reg[2]),.FUV2L(FUVL_reg[2]),.FUF2H(FUFH_reg[2]),.FUF2L(FUFL_reg[2]),
  .FUV3H(FUVH_reg[3]),.FUV3L(FUVL_reg[3]),.FUF3H(FUFH_reg[3]),.FUF3L(FUFL_reg[3]),
  .FUV4H(FUVH_reg[4]),.FUV4L(FUVL_reg[4]),.FUF4H(FUFH_reg[4]),.FUF4L(FUFL_reg[4]),
  .FUV5H(FUVH_reg[5]),.FUV5L(FUVL_reg[5]),.FUF5H(FUFH_reg[5]),.FUF5L(FUFL_reg[5]),
  .FUV6H(FUVH_reg[6]),.FUV6L(FUVL_reg[6]),.FUF6H(FUFH_reg[6]),.FUF6L(FUFL_reg[6]),
  .FUV7H(FUVH_reg[7]),.FUV7L(FUVL_reg[7]),.FUF7H(FUFH_reg[7]),.FUF7L(FUFL_reg[7]),
  .FUV8H(FUVH_reg[8]),.FUV8L(FUVL_reg[8]),.FUF8H(FUFH_reg[8]),.FUF8L(FUFL_reg[8]),
  .FUV9H(FUVH_reg[9]),.FUV9L(FUVL_reg[9]),.FUF9H(FUFH_reg[9]),.FUF9L(FUFL_reg[9]),

  .FUV4XH(FUVXH_reg[4]),.FUV4L(FUVXL_reg[4]),.FUF4H(FUVH_reg[4]),.FUF4L(FUVL_reg[4]),
  .FUV5XH(FUVXH_reg[5]),.FUV5L(FUVXL_reg[5]),.FUF5H(FUVH_reg[5]),.FUF5L(FUVL_reg[5]),
  .FUV6XH(FUVXH_reg[6]),.FUV6L(FUVXL_reg[6]),.FUF6H(FUVH_reg[6]),.FUF6L(FUVL_reg[6]),

  .FUS0(FUS1),.FUSreg0(outRegS_reg5[3*0+1]),.FUSwen0(1'b0),
  .FUS1(FUS2),.FUSreg1(outRegS_reg5[3*1+1]),.FUSwen1(1'b0),
  .FUS2(FUS3),.FUSreg2(outRegS_reg5[3*2+1]),.FUSwen2(1'b0),
  .FUS3(FUS4),.FUSreg3(outRegS[3*0+1]),.FUSwen3(outEn[3*0+1][1]&~outOp[3*0+1][12]),
  .FUS4(FUS5),.FUSreg4(outRegS[3*1+1]),.FUSwen4(outEn[3*1+1][1]&~outOp[3*1+1][12]),
  .FUS5(FUS6),.FUSreg5(outRegS[3*2+1]),.FUSwen5(outEn[3*2+1][1]&~outOp[3*2+1][12]),
  .FUS6(FUS7),.FUSreg6(outRegS[3*0+2]),.FUSwen6(outEn[3*0+2][1]&~outOp[3*0+2][12]),
  .FUS7(FUS8),.FUSreg7(outRegS[3*1+2]),.FUSwen7(outEn[3*1+2][1]&~outOp[3*1+2][12]),
  .FUS8(FUS9),.FUSreg8(outRegS[3*2+2]),.FUSwen8(outEn[3*2+2][1]&~outOp[3*2+2][12]),
// 1 if buffer is free  
  .pause0(miss_holds_addrcalc|pause_addrcalc|miss_pause_addrcalc/*|bus_holds_addrcalc*/|bus_holds_addrcalc_reg|insBus_io|rsDoStall[m]),
  .foundAlt1(~(&nDataAlt[m])|(|fxFRT_alten[m])),.foundAlt2(fxFRT_pause[m])
  );
  
 



  
//  rs_save #(1) saveAlt1_mod(
//  .clk(clk),.rst(rst),
//  .oldData(outOp[8][11]&&outOp[8][7:3]==4'hf),.newData(fxAlt1),
//  .save(1'b0),.en(outEn[8][0])
//  );

  
 

//  assign FOOS[m]=gxFADD_hi[m] ? FOOSH[m] : FOOSL[m];


  assign WfunA[m]=Wswp_reg[m] ? funB_reg[3*m] : funA_reg[3*m];
  assign WfunB[m]=Wswp_reg[m] ? funA_reg[3*m] : funB_reg[3*m];
  
  
  assign WinflA[m]=inflA[3*m]|depA_reg[3*m];
  assign WinflB[m]=inflB[3*m]|depB_reg[3*m];
  
  assign WregA[m]=regAW_reg[m]|{9{~inflA[3*m]&~depA_reg[3*m]}};
  assign WregB[m]=regBW_reg[m]|{9{~inflB[3*m]&~depB_reg[3*m]}};

  assign regAW[m]=Wswp[m] ? regB[3*m] : regA[3*m];
  assign regBW[m]=Wswp[m] ? regA[3*m] : regB[3*m];
  assign regAWF[m]=Wswp[m] ? regBF[3*m] : regAF[3*m];
  assign regBFW[m]=Wswp[m] ? regAF[3*m] : regBF[3*m];
  assign retAW[m]=Wswp[m] ? retB[3*m] : retA[3*m];
  assign retBW[m]=Wswp[m] ? retA[3*m] : retB[3*m];
  assign retAWF[m]=Wswp[m] ? retBF[3*m] : retAF[3*m];
  assign retBFW[m]=Wswp[m] ? retAF[3*m] : retBF[3*m];
  assign isBFW[m]=Wswp[m] ? isAF[3*m] : isBF[3*m];
  assign isAWF[m]=(~Wswp[m]) ? isAF[3*m] : isBF[3*m];
  assign isBVW[m]=Wswp[m] ? isAV[3*m] : isBV[3*m];
  assign isAWV[m]=(~Wswp[m]) ? isAV[3*m] : isBV[3*m];
  assign rs_rAW_use[m]=(~Wswp[m]) ? rs_rA_use[3*m] : rs_rB_use[3*m];
  assign rs_rBW_use[m]=Wswp[m] ? rs_rA_use[3*m] : rs_rB_use[3*m];
  assign rs_rAW_useF[m]=(~Wswp[m]) ? rs_rA_useF[3*m] : rs_rB_useF[3*m];
  assign rs_rBW_useF[m]=Wswp[m] ? rs_rA_useF[3*m] : rs_rB_useF[3*m];
  assign useBConstW[m]=~Wswp[m] & rs_useBConst[3*m];
  assign useAConstW[m]=Wswp[m] & rs_useBConst[3*m];
  assign rs_enAW[m]=(~Wswp[m]) ? rs_enA[m] : rs_enB[m];
  assign rs_enBW[m]=Wswp[m] ? rs_enA[m] : rs_enB[m];

  assign rs_const_new[3*m]=~rs_IPRel[3*m] ? {^rs_const[3*m],rs_const[3*m]} : 65'bz;
  assign rs_const_new[3*m]=rs_IPRel[3*m] & ~ rs_afterTK[3*m] ? {^{1'b1,baseIP_reg,1'b0},{1'b1,baseIP_reg,1'b0}} : 65'bz;
  assign rs_const_new[3*m]=rs_IPRel[3*m] & rs_afterTK[3*m] & jump0Pred_reg ? {^{1'b1,jump0IP_reg},{1'b1,jump0IP_reg}} : 65'bz;
  assign rs_const_new[3*m]=rs_IPRel[3*m] & rs_afterTK[3*m] & ~jump0Pred_reg ? {^{1'b1,jump1IP_reg},{1'b1,jump1IP_reg}} : 65'bz;
  assign rs_const_new[3*m+1]=~rs_IPRel[3*m+1] ? rs_const[3*m+1] : 65'bz;
  assign rs_const_new[3*m+1]=rs_IPRel[3*m+1] & ~ rs_afterTK[3*m+1] ? {^{1'b1,baseIP_reg,1'b0},{1'b1,baseIP_reg,1'b0}} : 65'bz;
  assign rs_const_new[3*m+1]=rs_IPRel[3*m+1] & rs_afterTK[3*m+1] & jump0Pred_reg ? {^{1'b1,jump0IP_reg},{1'b1,jump0IP_reg}} : 65'bz;
  assign rs_const_new[3*m+1]=rs_IPRel[3*m+1] & rs_afterTK[3*m+1] & ~jump0Pred_reg ? {^{1'b1,jump1IP_reg},{1'b1,jump1IP_reg}} : 65'bz;
  assign rs_const_new[3*m+2]=rs_const[3*m+2];

  end
 
  pwire [3:0][15:0] FUFLD_dummy;
  pwire [3:0][15:0] FUFLD_dummy1;
  pwire [3:0][15:0] FUFLD_dummy2;
  pwire [3:0][15+33:0] FUVLD_dummy;
  pwire [3:0][15+33:0] FUVLD_dummy1;
  pwire [3:0][15:0] FUFLD_dummy_N;
  pwire [3:0][15:0] FUFLD_dummy1_N;
  pwire [3:0][15:0] FUFLD_dummy2_N;
  pwire [3:0][15+33:0] FUVLD_dummy_N;
  pwire [3:0][15+33:0] FUVLD_dummy1_N;


  for(n=0;n<4;n=n+1) begin

 //   assign wxdata[n]={get_last_bank(dc_size_reg3[n],dc_rdataA[n]),dc_rdataA[n][23:0]};

      ldD2nativeD lddbl_hi_mod(dc_rdataA_regn[n][127:64],fxLD_dbl_regn[n],fxLD_dbl_t_regn[n],1'b0,
	      {FUFLD_dummy[n],FUVH[n][65:33],FUVH[n][31:0]});
      LDE2NativeE ldedbl_mod({dc_rdataA_regn[n][79:0]},fxLD_ext_regn[n],
	      {FUVL[n][15+70:68],FUVL[n][65:33],FUVL[n][31:0]});
      assign FUVH[n][32]=fxLD_dblext_regn[n] ? 1'b0 : 1'bz;
      ldD2nativeD lddbl_lo_mod(dc_rdataA_regn[n][63:0],fxLD_dbl_regn[n],fxLD_dbl_t_regn[n],fxLD_ext_t_regn[n],
	      {FUVL[n][15+70:68],FUVL[n][65:33],FUVL[n][31:0]});
      assign FUVL[n][32]=fxLD_dblext_regn[n] ? 1'b0 : 1'bz;
      ldS2nativeS ldsngl_ll(dc_rdataA_reg[n][31:0],fxLD_sin_reg[n],fxLD_sngl_t_reg[n],fxLD_dbl_t_reg[n],fxLD_ext_t_reg[n],
	      {FUVLX[n][15:0],FUVL[n][65:0]});
      ldS2nativeS ldsngl_lh(dc_rdataA_reg[n][63:32],fxLD_sin_reg[n],fxLD_sngl_t_reg[n],1'b0,1'b0,
	      {FUVLD_dummy[n],FUVL[n][65:33]});
      ldS2nativeS ldsngl_hl(dc_rdataA_reg[n][95:64],fxLD_sin_reg[n],fxLD_sngl_t_reg[n],fxLD_dbl_t_reg[n] && ~fxLD_spair_t_reg[n],1'b0,
	      {FUFLD_dummy1[n],FUVH[n][65:0]});
      ldS2nativeS ldsngl_hh(dc_rdataA_reg[n][127:96],fxLD_sin_reg[n],fxLD_sngl_t_reg[n],1'b0,1'b0,
	      {FUVLD_dummy1[n],FUVH[n][65:33]});
      ldS2nativeS ldsngl_hl2(dc_rdataA_reg[n][63:32],fxLD_sin_reg[n],1'b0,fxLD_dbl_t_reg[n] && fxLD_spair_t_reg[n],1'b0,
	      {FUFLD_dummy2[n],FUVH[n][65:0]});
      assign FUVH[n][65:0]=(fxLD_ext_t_regn[n]) ? 66'b0 : 66'bz;
      assign FUVH[n][67:66]=fxLD_ext_t_regn[n] ? `ptype_ext : 2'bz;
      assign FUVH[n][67:66]=fxLD_dbl_t_regn[n] ? `ptype_dbl : 2'bz;
      assign FUVH[n][67:66]=fxLD_sngl_t_regn[n] ? `ptype_sngl : 2'bz;
      
      assign FUVL[n][67:66]=FUVH[n][67:66];

      assign {FUVL[n][15+70:68],FUVL[n][65:0]} =fxLD_ext_t_regn[n] & fxLD_sin_regn[n] ? {FUVLX_n[n][15:0],FUVL_n[n][65:0]} : 82'bz;
      assign {FUVL[n][15+70:68],FUVL[n][65:0]} =fxLD_dbl_t_regn[n] & fxLD_sin_regn[n] ? {16'b0,FUVL_n[n][65:0]} : 82'bz;
      assign {FUVH[n][65:0]} =fxLD_dbl_t_regn[n] & fxLD_sin_regn[n] ? {FUVH_n[n][65:0]} : 66'bz;
       
      assign FUVL[n][65:0]=fxLD_sngl_t[n] | fxLD_dbl_t[n] ? 66'bz : {dc_pdataA_reg[n][0],dc_rdataA_reg[n][63:32],1'b0,
	      dc_rdataA_reg[n][31:0]}; 
      assign FUVH[n][65:0]=fxLD_sngl_t[n] | fxLD_dbl_t[n] ? 66'bz : {dc_pdataA_reg[n][1],dc_rdataA_reg[n][127:96],1'b0,
	      dc_rdataA_reg[n][95:64]}; 
      assign FUVL[n][67:66]=fxLD_sngl_t[n] ? `ptype_sngl : `ptype_int;
      assign FUVH[n][67:66]=fxLD_sngl_t[n] ? `ptype_sngl : `ptype_int;

      ldD2nativeD Glddbl_hi_mod(dc_rdataA_X_reg2_n[n][127:64],fxLD_dbl_reg2_n[n],fxLD_dbl_t_reg2_n[n],1'b0,
	      {FUFLD2_dummy[n],FUFH[n][65:33],FUFH[n][31:0]});
      LDE2NativeE Gldedbl_mod({dc_rdataA_X_reg2_n[n][79:0]},fxLD_ext_reg2_n[n],
	      {FUFL[n][15+70:68],FUFL[n][65:33],FUFL[n][31:0]});
      assign FUFH[n][32]=fxLD_dblext_reg2_n[n] ? 1'b0 : 1'bz;
      ldD2nativeD Glddbl_lo_mod(dc_rdataA_X_reg2_n[n][63:0],fxLD_dbl_reg2_n[n],fxLD_dbl_t_reg2_n[n],fxLD_ext_t_reg2_n[n],
	      {FUFL[n][15+70:68],FUFL[n][65:33],FUFL[n][31:0]});
      assign FUFL[n][32]=fxLD_dblext_reg2_n[n] ? 1'b0 : 1'bz;
      ldS2nativeS ldsngl_ll(dc_rdataA_X_reg2[n][31:0],fxLD_sin_reg2[n],fxLD_sngl_t_reg2[n],fxLD_dbl_t_reg2[n],fxLD_ext_t_reg2[n],
	      {FUVLX2[n][15:0],FUVXL[n][65:0]});
      ldS2nativeS ldsngl_lh(dc_rdataA_X_reg2[n][63:32],fxLD_sin_reg2[n],fxLD_sngl_t_reg2[n],1'b0,1'b0,
	      {FUVLD2_dummy[n],FUVXL[n][65:33]});
      ldS2nativeS ldsngl_hl(dc_rdataA_X_reg2[n][95:64],fxLD_sin_reg2[n],fxLD_sngl_t_reg2[n],fxLD_dbl_t_reg2[n] &&
               ~fxLD_spair_t_reg2[n],1'b0,    {FUFLD2_dummy1[n],FUVXH[n][65:0]});
      ldS2nativeS ldsngl_hh(dc_rdataA_X_reg2[n][127:96],fxLD_sin_reg2[n],fxLD_sngl_t_reg2[n],1'b0,1'b0,
	      {FUVLD2_dummy1[n],FUVXH[n][65:33]});
      ldS2nativeS ldsngl_hl2(dc_rdataA_X_reg2[n][63:32],fxLD_sin_reg2[n],1'b0,fxLD_dbl_t_reg2[n] && fxLD_spair_t_reg2[n],1'b0,
	      {FUFLD2_dummy2[n],FUVXH[n][65:0]});
      assign FUFH[n][65:0]=(fxLD_ext_t_reg2_n[n]) ? 66'b0 : 66'bz; 
      assign FUFH[n][67:66]=fxLD_ext_t_reg2_n[n] ? `ptype_ext : 2'bz;
      assign FUFH[n][67:66]=fxLD_dbl_t_reg2_n[n] ? `ptype_dbl : 2'bz;
      assign FUFH[n][67:66]=fxLD_sngl_t_reg2_n[n] ? `ptype_sngl : 2'bz;
      
      assign FUFL[n][67:66]=FUFH[n][67:66];

      assign {FUFL[n][15+70:68],FUFL[n][65:0]} =fxLD_ext_t_reg2_n[n] & fxLD_sin_reg2_n[n] ?
            {FUVLX2_n[n][15:0],FUVXL_n[n][65:0]} : 82'bz;
      assign {FUFL[n][15+70:68],FUFL[n][65:0]} =fxLD_dbl_t_reg2_n[n] & fxLD_sin_reg2_n[n] ? {16'b0,FUVXL_n[n][65:0]} : 82'bz;
      assign {FUFH[n][65:0]} =fxLD_dbl_t_reg2_n[n] & fxLD_sin_reg2_n[n] ? {FUVXH_n[n][65:0]} : 66'bz;
       
      assign FUVXL[n][65:0]=fxLD_sngl_t_reg2[n] | fxLD_dbl_t_reg2[n] ? 66'bz : {1'b0,dc_rdataA_X_reg2[n][63:32],1'b0,
	      dc_rdataA_X_reg2[n][31:0]}; 
      assign FUVXH[n][65:0]=fxLD_sngl_t_reg2[n] | fxLD_dbl_t_reg2[n] ? 66'bz : {1'b0,dc_rdataA_X_reg2[n][127:96],1'b0,
	      dc_rdataA_X_reg2[n][95:64]}; 
      assign FUVXL[n][67:66]=fxLD_sngl_t_reg2[n] ? `ptype_sngl : `ptype_int;
      assign FUVXH[n][67:66]=fxLD_sngl_t_reg2[n] ? `ptype_sngl : `ptype_int;

      if (n<2) begin : Wfwd

          assign lsw_wdata[n]=|WDfxDataEn_reg3[n][3:2] ? lsw_wdataF[n] : {64'b0,8'b0,WDfxData_reg3[n][63:0]};
          assign lsw_pdata[n]=|WDfxDataEn_reg3[n][2] ? {lsw_wdataF[n][132],lsw_wdataF[n][128]} : 2'bz;
	  assign lsw_pdata[n]=|WDfxDataEn_reg3[n][3:2] ? 2'bz : {1'b0,WDfxData_reg3[n][64]};
	  assign lsw_pdata[n]=|WDfxDataEn_reg3[n][3] ? 2'b0 : 2'bz;
          assign lsw_wdataF[n]=WDfxDataEn_reg2[n][2] ? lsw_wdataV_reg[n] : {WDfxDataFH_n[n][67:66],WDfxDataFH_n[n][65],
                  WDfxDataFH_n[n][32],
                  WDfxDataFL_n[n][67:66],WDfxDataFL_n[n][65],WDfxDataFL_n[n][32],
		  lsw_wdataF0[n][127:0]};
	  assign lsw_wdataV[n]=(get_ptype2(WDoutOp_reg2[n][5:1],WDfxDataVL[n][67:66])==`ptype_sngl) ?
		  {WDfxDataVH[n][67:66],WDfxDataVH[n][65],WDfxDataVH[n][32],
                  WDfxDataVL[n][67:66],WDfxDataVL[n][65],WDfxDataVL[n][32],lsw_wdataV0[n][127:0]} : 
		  {WDfxDataVH[n][67:66],WDfxDataVH[n][65],WDfxDataVH[n][32],
		  WDfxDataVL[n][67:66],WDfxDataVL[n][65],WDfxDataVL[n][32],
		  WDfxDataVH[n][64:33],WDfxDataVH[n][31:0],WDfxDataVL[n][64:33],WDfxDataVL[n][31:0]};
	  assign lsw_wdataF0[n][127:32]=(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])==`ptype_sngl) ?
		  96'b0 : 96'bz;
	  assign lsw_wdataF0[n][127:0]=(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])==`ptype_int) ?
		  {WDfxDataFH_n[n][64:33],WDfxDataFH_n[n][31:0],WDfxDataFL_n[n][64:33],WDfxDataFL_n[n][31:0]} : 128'bz;

	  stNativeD2D stconvHD_mod(.A({16'b0,WDfxDataFH_n[n][65:33],WDfxDataFH_n[n][31:0]}),
                  .en(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataFH_n[n][67:66])==`ptype_dbl), 
                  .from_ext(1'b0),
                  .from_dbl(1'b1),
		  .res(lsw_wdataF0[n][127:64]));
          stNativeE2E stconvED(.A({WDfxDataFL_n[n][70+15:68],WDfxDataFL_n[n][65:33],WDfxDataFL_n[n][31:0]}),
                  .en(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])==`ptype_ext),
		  .res(lsw_wdataF0[n][127:0]));
	  stNativeD2D stconvLD_mod(.A({WDfxDataFL_n[n][70+15:68],WDfxDataFL_n[n][65:33],WDfxDataFL_n[n][31:0]}),
                  .en(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])==`ptype_dbl),
                  .from_ext(get_ptype(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])==`ptype_ext),
                  .from_dbl(get_ptype(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])!=`ptype_ext),
		  .res(lsw_wdataF0[n][63:0]));
	  stNativeS2S stconvEDS_mod(.A({WDfxDataFL_n[n][70+15:68],WDfxDataFH_n[n][65:33],WDfxDataFH_n[n][32:0]}),
                  .en(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])==`ptype_sngl),
                  .from_ext(get_ptype(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])==`ptype_ext),
                  .from_dbl(get_ptype(WDoutOp_reg3[n][5:1],WDfxDataFL_n[n][67:66])==`ptype_dbl),
                  .from_sngl(1'b0),
		  .res(lsw_wdataF0[n][31:0]));
	  stNativeS2S stconvLLD_mod(.A({49'b0,WDfxDataVL[n][32:0]}),
                  .en(1'b1),
                  .from_ext(1'b0),
                  .from_dbl(1'b0),
                  .from_sngl(1'b1),
		  .res(lsw_wdataV0[n][31:0]));
	  stNativeS2S stconvLHD_mod(.A({49'b0,WDfxDataVL[n][65:33]}),
                  .en(1'b1),
                  .from_ext(1'b0),
                  .from_dbl(1'b0),
                  .from_sngl(1'b1),
		  .res(lsw_wdataV0[n][63:32]));
	  stNativeS2S stconvHLD_mod(.A({49'b0,WDfxDataVH[n][32:0]}),
                  .en(1'b1),
                  .from_ext(1'b0),
                  .from_dbl(1'b0),
                  .from_sngl(1'b1),
		  .res(lsw_wdataV0[n][95:64]));
	  stNativeS2S stconvHHD_mod(.A({49'b0,WDfxDataVH[n][65:33]}),
                  .en(1'b1),
                  .from_ext(1'b0),
                  .from_dbl(1'b0),
                  .from_sngl(1'b1),
		  .res(lsw_wdataV0[n][127:96]));

          assign lsw_wdataU[n]=|WDfxDataEn_reg3[n][3:2] ? lsw_wdataFU[n] : {64'b0,8'b0,WDfxData_reg3[n][63:0]};
          assign lsw_pdataU[n]=|WDfxDataEn_reg3[n][2] ? {lsw_wdataFU[n][132],lsw_wdataFU[n][128]} : 2'bz;
	  assign lsw_pdataU[n]=|WDfxDataEn_reg3[n][3:2] ? 2'bz : {1'b0,WDfxData_reg3[n][64]};
	  assign lsw_pdataU[n]=|WDfxDataEn_reg3[n][3] ? 2'b0 : 2'bz;
          assign lsw_wdataFU[n]=WDfxDataEn_reg3[n][2] ? lsw_wdataVU_reg[n] : {WDfxDataVH_n[n][67:66],WDfxDataVH_n[n][65],
                  WDfxDataVH_n[n][32],
                  WDfxDataVL_n[n][67:66],WDfxDataVL_n[n][65],WDfxDataVL_n[n][32],
		  lsw_wdataFU0[n][127:0]};
	  assign lsw_wdataVU[n]=(get_ptype2(WDoutOp_reg2[n][5:1],WDfxDataVXL[n][67:66])==`ptype_sngl) ?
		  {WDfxDataVXH[n][67:66],WDfxDataVXH[n][65],WDfxDataVXH[n][32],
                  WDfxDataVXL[n][67:66],WDfxDataVXL[n][65],WDfxDataVXL[n][32],lsw_wdataVU0[n][127:0]} : 
		  {WDfxDataVXH[n][67:66],WDfxDataVXH[n][65],WDfxDataVXH[n][32],
		  WDfxDataVXL[n][67:66],WDfxDataVXL[n][65],WDfxDataVXL[n][32],
		  WDfxDataVXH[n][64:33],WDfxDataVXH[n][31:0],WDfxDataVXL[n][64:33],WDfxDataVXL[n][31:0]};
	  assign lsw_wdataFU0[n][127:32]=(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])==`ptype_sngl) ?
		  96'b0 : 96'bz;
	  assign lsw_wdataFU0[n][127:0]=(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])==`ptype_int) ?
		  {WDfxDataVH_n[n][64:33],WDfxDataVH_n[n][31:0],WDfxDataVL_n[n][64:33],WDfxDataVL_n[n][31:0]} : 128'bz;

	  stNativeD2D stconvHD_mod(.A({16'b0,WDfxDataVH_n[n][65:33],WDfxDataVH_n[n][31:0]}),
                  .en(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataVH_n[n][67:66])==`ptype_dbl),
                  .from_ext(1'b0),
                  .from_dbl(1'b1),
		  .res(lsw_wdataFU0[n][127:64]));
          stNativeE2E stconvED(.A({WDfxDataVL_n[n][70+15:68],WDfxDataVL_n[n][65:33],WDfxDataVL_n[n][31:0]}),
                  .en(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])==`ptype_ext),
		  .res(lsw_wdataFU0[n][127:0]));
	  stNativeD2D stconvLD_mod(.A({WDfxDataVL_n[n][70+15:68],WDfxDataVL_n[n][65:33],WDfxDataVL_n[n][31:0]}),
                  .en(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])==`ptype_dbl),
                  .from_ext(get_ptype(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])==`ptype_ext),
                  .from_dbl(get_ptype(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])!=`ptype_ext),
		  .res(lsw_wdataFU0[n][63:0]));
	  stNativeS2S stconvEDS_mod(.A({WDfxDataVL_n[n][70+15:68],WDfxDataVH_n[n][65:33],WDfxDataVH_n[n][32:0]}),
                  .en(get_ptype2(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])==`ptype_sngl),
                  .from_ext(get_ptype(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])==`ptype_ext),
                  .from_dbl(get_ptype(WDoutOp_reg3[n][5:1],WDfxDataVL_n[n][67:66])==`ptype_dbl),
                  .from_sngl(1'b0),
		  .res(lsw_wdataFU0[n][31:0]));
	  stNativeS2S stconvLLD_mod(.A({49'b0,WDfxDataVXL[n][32:0]}),
                  .en(1'b1),
                  .from_ext(1'b0),
                  .from_dbl(1'b0),
                  .from_sngl(1'b1),
		  .res(lsw_wdataVU0[n][31:0]));
	  stNativeS2S stconvLHD_mod(.A({49'b0,WDfxDataVXL[n][65:33]}),
                  .en(1'b1),
                  .from_ext(1'b0),
                  .from_dbl(1'b0),
                  .from_sngl(1'b1),
		  .res(lsw_wdataVU0[n][63:32]));
	  stNativeS2S stconvHLD_mod(.A({49'b0,WDfxDataVXH[n][32:0]}),
                  .en(1'b1),
                  .from_ext(1'b0),
                  .from_dbl(1'b0),
                  .from_sngl(1'b1),
		  .res(lsw_wdataVU0[n][95:64]));
	  stNativeS2S stconvHHD_mod(.A({49'b0,WDfxDataVXH[n][65:33]}),
                  .en(1'b1),
                  .from_ext(1'b0),
                  .from_dbl(1'b0),
                  .from_sngl(1'b1),
		  .res(lsw_wdataVU0[n][127:96]));
       
          rs_write_forward #(DATA_WIDTH) fwdDA_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutData[n]),
          .newData(WDfxData[n]),
          .fuFwd(WDoutFuFwd[n]),.fuuFwd(WDoutFuuFwd[n]),
          .stall(~WDoutDataEn[n][1]),
          .FU0(FU[0]),.FU0_reg(FU_reg[0]),
          .FU1(FU[1]),.FU1_reg(FU_reg[1]),
          .FU2(FU[2]),.FU2_reg(FU_reg[2]),
          .FU3(FU[3]),.FU3_reg(FU_reg[3]),
          .FU4(FU[4]),.FU4_reg(FU_reg[4]),
          .FU5(FU[5]),.FU5_reg(FU_reg[5]),
          .FU6(FU[6]),.FU6_reg(FU_reg[6]),
          .FU7(FU[7]),.FU7_reg(FU_reg[7]),
          .FU8(FU[8]),.FU8_reg(FU_reg[8]),
          .FU9(FU[9]),.FU9_reg(FU_reg[9])
          );

          rs_write_forward #(SIMD_WIDTH) fwdDAVH_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutDataVH[n]),
          .newData(WDfxDataVH[n]),
          .fuFwd(WDoutFuFwd_reg[n]),.fuuFwd(WDoutFuuFwd_reg[n]),
          .stall(~WDoutDataEn_reg[n][2]),
          .FU0(FUVH[0]),.FU0_reg(FUVH_reg[0]),
          .FU1(FUVH[1]),.FU1_reg(FUVH_reg[1]),
          .FU2(FUVH[2]),.FU2_reg(FUVH_reg[2]),
          .FU3(FUVH[3]),.FU3_reg(FUVH_reg[3]),
          .FU4(FUVH[4]),.FU4_reg(FUVH_reg[4]),
          .FU5(FUVH[5]),.FU5_reg(FUVH_reg[5]),
          .FU6(FUVH[6]),.FU6_reg(FUVH_reg[6]),
          .FU7(FUVH[7]),.FU7_reg(FUVH_reg[7]),
          .FU8(FUVH[8]),.FU8_reg(FUVH_reg[8]),
          .FU9(FUVH[9]),.FU9_reg(FUVH_reg[9])
          );
        
          rs_write_forward #(SIMD_WIDTH) fwdDBVL_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutDataVL[n]),
          .newData(WDfxDataVL[n]),
          .fuFwd(WDoutFuFwd_reg[n]),.fuuFwd(WDoutFuuFwd_reg[n]),
          .stall(~WDoutDataEn_reg[n][2]),
          .FU0(FUVL[0]),.FU0_reg(FUVL_reg[0]),
          .FU1(FUVL[1]),.FU1_reg(FUVL_reg[1]),
          .FU2(FUVL[2]),.FU2_reg(FUVL_reg[2]),
          .FU3(FUVL[3]),.FU3_reg(FUVL_reg[3]),
          .FU4(FUVL[4]),.FU4_reg(FUVL_reg[4]),
          .FU5(FUVL[5]),.FU5_reg(FUVL_reg[5]),
          .FU6(FUVL[6]),.FU6_reg(FUVL_reg[6]),
          .FU7(FUVL[7]),.FU7_reg(FUVL_reg[7]),
          .FU8(FUVL[8]),.FU8_reg(FUVL_reg[8]),
          .FU9(FUVL[9]),.FU9_reg(FUVL_reg[9])
          );
        
          rs_write_forward #(SIMD_WIDTH) fwdDAVxH_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutDataVXH[n]),
          .newData(WDfxDataVXH[n]),
          .fuFwd(WDoutFuFwd_reg2[n]),.fuuFwd(WDoutFuuFwd_reg2[n]),
          .stall(~WDoutDataEn_reg2[n][2]),
          .FU0(FUVXH[0]),.FU0_reg(FUVXH_reg[0]),
          .FU1(FUVXH[1]),.FU1_reg(FUVXH_reg[1]),
          .FU2(FUVXH[2]),.FU2_reg(FUVXH_reg[2]),
          .FU3(FUVXH[3]),.FU3_reg(FUVXH_reg[3]),
          .FU4(FUVXH[4]),.FU4_reg(FUVXH_reg[4]),
          .FU5(FUVXH[5]),.FU5_reg(FUVXH_reg[5]),
          .FU6(FUVXH[6]),.FU6_reg(FUVXH_reg[6]),
          .FU7(FUVXH[7]),.FU7_reg(FUVXH_reg[7]),
          .FU8(FUVXH[8]),.FU8_reg(FUVXH_reg[8]),
          .FU9(FUVXH[9]),.FU9_reg(FUVXH_reg[9])
          );
        
          rs_write_forward #(SIMD_WIDTH) fwdDBVYL_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutDataVXL[n]),
          .newData(WDfxDataVXL[n]),
          .fuFwd(WDoutFuFwd_reg2[n]),.fuuFwd(WDoutFuuFwd_reg2[n]),
          .stall(~WDoutDataEn_reg2[n][2]),
          .FU0(FUVXL[0]),.FU0_reg(FUVXL_reg[0]),
          .FU1(FUVXL[1]),.FU1_reg(FUVXL_reg[1]),
          .FU2(FUVXL[2]),.FU2_reg(FUVXL_reg[2]),
          .FU3(FUVXL[3]),.FU3_reg(FUVXL_reg[3]),
          .FU4(FUVXL[4]),.FU4_reg(FUVXL_reg[4]),
          .FU5(FUVXL[5]),.FU5_reg(FUVXL_reg[5]),
          .FU6(FUVXL[6]),.FU6_reg(FUVXL_reg[6]),
          .FU7(FUVXL[7]),.FU7_reg(FUVXL_reg[7]),
          .FU8(FUVXL[8]),.FU8_reg(FUVXL_reg[8]),
          .FU9(FUVXL[9]),.FU9_reg(FUVXL_reg[9])
          );
        
          rs_write_forward #(SIMD_WIDTH) fwdDAFH_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutDataFH[n]),
          .newData(WDfxDataFH[n]),
          .fuFwd(WDoutFuFwd_reg[n]),.fuuFwd(WDoutFuuFwd_reg[n]),
          .stall(~WDoutDataEn_reg[n][3]),
          .FU0(FUVH[0]),.FU0_reg(FUVH_reg[0]),
          .FU1(FUVH[1]),.FU1_reg(FUVH_reg[1]),
          .FU2(FUVH[2]),.FU2_reg(FUVH_reg[2]),
          .FU3(FUVH[3]),.FU3_reg(FUVH_reg[3]),
          .FU4(FUVH[4]),.FU4_reg(FUVH_reg[4]),
          .FU5(FUVH[5]),.FU5_reg(FUVH_reg[5]),
          .FU6(FUVH[6]),.FU6_reg(FUVH_reg[6]),
          .FU7(FUVH[7]),.FU7_reg(FUVH_reg[7]),
          .FU8(FUVH[8]),.FU8_reg(FUVH_reg[8]),
          .FU9(FUVH[9]),.FU9_reg(FUVH_reg[9])
          );
        
          rs_write_forward #(16+SIMD_WIDTH) fwdDBFL_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutDataFL[n]),
          .newData(WDfxDataFL[n]),
          .fuFwd(WDoutFuFwd_reg[n]),.fuuFwd(WDoutFuuFwd_reg[n]),
          .stall(~WDoutDataEn_reg[n][3]),
          .FU0(FUVL[0]),.FU0_reg(FUVL_reg[0]),
          .FU1(FUVL[1]),.FU1_reg(FUVL_reg[1]),
          .FU2(FUVL[2]),.FU2_reg(FUVL_reg[2]),
          .FU3(FUVL[3]),.FU3_reg(FUVL_reg[3]),
          .FU4(FUVL[4]),.FU4_reg(FUVL_reg[4]),
          .FU5(FUVL[5]),.FU5_reg(FUVL_reg[5]),
          .FU6(FUVL[6]),.FU6_reg(FUVL_reg[6]),
          .FU7(FUVL[7]),.FU7_reg(FUVL_reg[7]),
          .FU8(FUVL[8]),.FU8_reg(FUVL_reg[8]),
          .FU9(FUVL[9]),.FU9_reg(FUVL_reg[9])
          );
          
          rs_write_forward #(SIMD_WIDTH) fwdDAFSH_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutDataVH[n]),
          .newData(WDfxDataVH[n]),
          .fuFwd(WDoutFuFwd_reg2[n]),.fuuFwd(WDoutFuuFwd_reg2[n]),
          .stall(~WDoutDataEn_reg2[n][3]),
          .FU0(FUFH[0]),.FU0_reg(FUFH_reg[0]),
          .FU1(FUFH[1]),.FU1_reg(FUFH_reg[1]),
          .FU2(FUFH[2]),.FU2_reg(FUFH_reg[2]),
          .FU3(FUFH[3]),.FU3_reg(FUFH_reg[3]),
          .FU4(FUFH[4]),.FU4_reg(FUFH_reg[4]),
          .FU5(FUFH[5]),.FU5_reg(FUFH_reg[5]),
          .FU6(FUFH[6]),.FU6_reg(FUFH_reg[6]),
          .FU7(FUFH[7]),.FU7_reg(FUFH_reg[7]),
          .FU8(FUFH[8]),.FU8_reg(FUFH_reg[8]),
          .FU9(FUFH[9]),.FU9_reg(FUFH_reg[9])
          );
        
          rs_write_forward #(16+SIMD_WIDTH) fwdDBFSL_mod(
          .clk(clk),
          .rst(rst),
          .oldData(WDoutDataVL[n]),
          .newData(WDfxDataVL[n]),
          .fuFwd(WDoutFuFwd_reg2[n]),.fuuFwd(WDoutFuuFwd_reg2[n]),
          .stall(~WDoutDataEn_reg2[n][3]),
          .FU0(FUFL[0]),.FU0_reg(FUFL_reg[0]),
          .FU1(FUFL[1]),.FU1_reg(FUFL_reg[1]),
          .FU2(FUFL[2]),.FU2_reg(FUFL_reg[2]),
          .FU3(FUFL[3]),.FU3_reg(FUFL_reg[3]),
          .FU4(FUFL[4]),.FU4_reg(FUFL_reg[4]),
          .FU5(FUFL[5]),.FU5_reg(FUFL_reg[5]),
          .FU6(FUFL[6]),.FU6_reg(FUFL_reg[6]),
          .FU7(FUFL[7]),.FU7_reg(FUFL_reg[7]),
          .FU8(FUFL[8]),.FU8_reg(FUFL_reg[8]),
          .FU9(FUFL[9]),.FU9_reg(FUFL_reg[9])
          );
          

          rs_save #(4) DdataEn_mod(
          .clk(clk),.rst(rst),
          .oldData(WDoutDataEn[n]),.newData(WDfxDataEn[n]),
          .save(1'b0),.en(WDoutDataEn[n][0])
          );

      end

  end
  
//  for(o=0;o<8;o=o+1) begin : busECC_mod
//      EccGet32 #(32) busECC_mod(insBus_data_reg2[o*32+:32],insBus_data_ECC[o*BANK_WIDTH+:BANK_WIDTH]);
//  end
  
  for(u=0;u<9;u=u+1) begin : infl_gen
      assign newD[u]={rs_port[u]==PORT_LOAD,rs_rT_isV[u]};
      assign domErrA[u]=~((rs_rA_isV[u]~^domA[u][0]) || rs_rA_isAnyV[u] || domA[u][1]) && rs_rA_useF[u];
      assign domErrB[u]=~((rs_rB_isV[u]~^domB[u][0]) || rs_rB_isAnyV[u] || domB[u][1]) && rs_rB_useF[u];
      
      if ((u%3)!=0) begin
          assign gazumpA[u]=isAF_reg[u] ? gazumpFA[u] : 11'bz;
          assign gazumpA[u]=isAV_reg[u] ? gazumpAV[u] : 11'bz;
          assign gazumpA[u]=(~isAV_reg[u] & ~isAF_reg[u]) ? gazumpAG[u] : 11'bz;
          assign gazumpB[u]=isBF_reg[u] ? gazumpFB[u] : 11'bz;
          assign gazumpB[u]=isBV_reg[u] ? gazumpBV[u] : 11'bz;
          assign gazumpB[u]=(~isBV_reg[u] & ~isBF_reg[u]) ? gazumpBG[u] : 11'bz;
     end else begin
          assign gazumpA[u]=isAWF_reg[u/3] ? gazumpFA[u] : 11'bz;
          assign gazumpA[u]=isAWV_reg[u/3] ? gazumpAV[u] : 11'bz;
          assign gazumpA[u]=(~isAWV_reg[u/3] & ~isAWF_reg[u/3]) ? gazumpAG[u] : 11'bz;
          assign gazumpB[u]=isBFW_reg[u/3] ? gazumpFB[u] : 11'bz;
          assign gazumpB[u]=isBVW_reg[u/3] ? gazumpBV[u] : 11'bz;
          assign gazumpB[u]=(~isBVW_reg[u/3] & ~isBFW_reg[u/3]) ? gazumpBG[u] : 11'bz;
     end
      assign isAF[u]=rs_rA_useF[u] && (~rs_rA_isV[u] || (rs_rA_isAnyV[u] && domA[u]==2'b00));
      assign isBF[u]=rs_rB_useF[u] && (~rs_rB_isV[u] || (rs_rB_isAnyV[u] && domB[u]==2'b00));
      //warning: error might occur in "any" dom{A|B}.
      assign isAV[u]=rs_rA_useF[u] && (rs_rA_isV[u] || (rs_rA_isAnyV[u] && domA[u]==2'b01));
      assign isBV[u]=rs_rB_useF[u] && (rs_rB_isV[u] || (rs_rB_isAnyV[u] && domB[u]==2'b01));
  end
  
  endgenerate
  
  assign rsStall=miss_holds_addrcalc|pause_addrcalc|miss_pause_addrcalc|bus_holds_addrcalc|bus_holds_addrcalc_reg|insBus_io; 
  assign fret_en[1]=0;
  assign fret   [1]=0;
  assign fret_en[3]=0;
  assign fret   [3]=0;
  assign fret_en[5]=0;
  assign fret   [5]=0;


  assign rs_useAConst_d=clkREF ? {rs2i2_useAConst,rs2i1_useAConst,1'b0,
            rs1i2_useAConst,rs1i1_useAConst,1'b0,
            rs0i2_useAConst,rs0i1_useAConst,1'b0} : 9'bz;
`ifndef simulation
  assign rs_useAConst_d=clkREF2 ? {rs2i2_useBConst,rs2i1_useBConst,rs2i0_useBConst,
            rs1i2_useBConst,rs1i1_useBConst,rs1i0_useBConst,
            rs0i2_useBConst,rs0i1_useBConst,rs0i0_useBConst} : 9'bz;
`endif
  assign rs_rA_use_d=clkREF ? {rs2i2_rA_use,rs2i1_rA_use,rs2i0_rA_use,
              rs1i2_rA_use,rs1i1_rA_use,rs1i0_rA_use,
              rs0i2_rA_use,rs0i1_rA_use,rs0i0_rA_use} : 9'bz;
`ifndef simulation
  assign rs_rA_use_d=clkREF2 ? {rs2i2_rB_use,rs2i1_rB_use,rs2i0_rB_use,
              rs1i2_rB_use,rs1i1_rB_use,rs1i0_rB_use,
              rs0i2_rB_use,rs0i1_rB_use,rs0i0_rB_use} : 9'bz;
`endif
  assign rs_rA_useF_d=clkREF ? {rs2i2_rA_useF,rs2i1_rA_useF,rs2i0_rA_useF,
              rs1i2_rA_useF,rs1i1_rA_useF,rs1i0_rA_useF,
              rs0i2_rA_useF,rs0i1_rA_useF,rs0i0_rA_useF} : 9'bz;
`ifndef simulation
  assign rs_rA_useF_d=clkREF2 ? {rs2i2_rB_useF,rs2i1_rB_useF,rs2i0_rB_useF,
              rs1i2_rB_useF,rs1i1_rB_useF,rs1i0_rB_useF,
              rs0i2_rB_useF,rs0i1_rB_useF,rs0i0_rB_useF} : 9'bz;
`endif

  assign rrfAW[0]=Wswp[0] ? rs0i0_rB_reg : rs0i0_rA_reg;
  assign rrfAW[1]=Wswp[1] ? rs1i0_rB_reg : rs1i0_rA_reg;
  assign rrfAW[2]=Wswp[2] ? rs2i0_rB_reg : rs2i0_rA_reg;
  assign rrfBW[0]=(~Wswp[0]) ? rs0i0_rB_reg : rs0i0_rA_reg;
  assign rrfBW[1]=(~Wswp[1]) ? rs1i0_rB_reg : rs1i0_rA_reg;
  assign rrfBW[2]=(~Wswp[2]) ? rs2i0_rB_reg : rs2i0_rA_reg;
`ifdef simulation      
  fu_alu alu_ALIGNED(
  .clk(clk),
  .rst(rst),
  .except(except),
  .msrss_addr(msrss_no),
  .msrss_data(msrss_data),
  .msrss_en(msrss_en),
  .jxcross(pfy),
  .allah(bofh),
  .u1_A(outDataA[0+1]),.u1_B(outDataB[0+1]),.u1_S(outDataS[0+1]),.u1_op(outOp[0+1]),
  .u1_ret({FUS_alu[0],ex_alu[0]}),.u1_rten(enS_alu[0]),.u1_clkEn(outEn[0+1][0]&outEn[0+1][1]),
    .u1_A_fufwd(fuFwdA[0+1]),.u1_A_fuufwd(fuuFwdA[0+1]),
    .u1_B_fufwd(fuFwdB[0+1]),.u1_B_fuufwd(fuuFwdB[0+1]),
    .u1_S_fufwd(fuFwdS[0+1]),.u1_S_fuufwd(fuuFwdS[0+1]),
    .u1_const(outDataC[3*0+1]),
  .u2_A(outDataA[0+2]),.u2_B(outDataB[0+2]),.u2_S(outDataS[0+2]),.u2_op(outOp[0+2]),
  .u2_ret({FUS_alu[1],ex_alu[1]}),.u2_rten(enS_alu[1]),.u2_clkEn(outEn[0+2][0]&outEn[0+2][1]),
    .u2_A_fufwd(fuFwdA[0+2]),.u2_A_fuufwd(fuuFwdA[0+2]),
    .u2_B_fufwd(fuFwdB[0+2]),.u2_B_fuufwd(fuuFwdB[0+2]),
    .u2_S_fufwd(fuFwdS[0+2]),.u2_S_fuufwd(fuuFwdS[0+2]),
  .u3_A(outDataA[3+1]),.u3_B(outDataB[3+1]),.u3_S(outDataS[3+1]),.u3_op(outOp[3+1]),
  .u3_ret({FUS_alu[2],ex_alu[2]}),.u3_rten(enS_alu[2]),.u3_clkEn(outEn[3+1][0]&outEn[3+1][1]),
    .u3_A_fufwd(fuFwdA[3+1]),.u3_A_fuufwd(fuuFwdA[3+1]),
    .u3_B_fufwd(fuFwdB[3+1]),.u3_B_fuufwd(fuuFwdB[3+1]),
    .u3_S_fufwd(fuFwdS[3+1]),.u3_S_fuufwd(fuuFwdS[3+1]),
    .u3_const(outDataC[3*1+1]),
  .u4_A(outDataA[3+2]),.u4_B(outDataB[3+2]),.u4_S(outDataS[3+2]),.u4_op(outOp[3+2]),
  .u4_ret({FUS_alu[3],ex_alu[3]}),.u4_rten(enS_alu[3]),.u4_clkEn(outEn[3+2][0]&outEn[3+2][1]),
    .u4_A_fufwd(fuFwdA[3+2]),.u4_A_fuufwd(fuuFwdA[3+2]),
    .u4_B_fufwd(fuFwdB[3+2]),.u4_B_fuufwd(fuuFwdB[3+2]),
    .u4_S_fufwd(fuFwdS[3+2]),.u4_S_fuufwd(fuuFwdS[3+2]),
  .u5_A(outDataA[6+1]),.u5_B(outDataB[6+1]),.u5_S(outDataS[6+1]),.u5_nDataAlt(nDataAlt_reg[2][1]),.u5_op(outOp[6+1]),
  .u5_ret({FUS_alu[4],ex_alu[4]}),.u5_rten(enS_alu[4]),.u5_clkEn(outEn[6+1][0]&outEn[6+1][1]),
    .u5_A_fufwd(fuFwdA[6+1]),.u5_A_fuufwd(fuuFwdA[6+1]),
    .u5_B_fufwd(fuFwdB[6+1]),.u5_B_fuufwd(fuuFwdB[6+1]),
    .u5_S_fufwd(fuFwdS[6+1]),.u5_S_fuufwd(fuuFwdS[6+1]),
    .u5_const(outDataC[3*2+1]),
  .u6_A(outDataA[6+2]),.u6_B(outDataB[6+2]),.u6_S(outDataS[6+2]),.u6_op(outOp[6+2]),
  .u6_ret({FUS_alu[5],ex_alu[5]}),.u6_rten(enS_alu[5]),.u6_clkEn(outEn[6+2][0]&outEn[6+2][1]),
    .u6_A_fufwd(fuFwdA[6+2]),.u6_A_fuufwd(fuuFwdA[6+2]),
    .u6_B_fufwd(fuFwdB[6+2]),.u6_B_fuufwd(fuuFwdB[6+2]),
    .u6_S_fufwd(fuFwdS[6+2]),.u6_S_fuufwd(fuuFwdS[6+2]),
    .u6_attr(outAttr[6+2]),
  .FU0(FU[0]), .FU1(FU[1]),  .FU2(FU[2]),  .FU3(FU[3]),
  .FU4(FU[4]), .FU5(FU[5]),  .FU6(FU[6]),  .FU7(FU[7]),
  .FU8(FU[8]), .FU9(FU[9]),
  .FUS1(FUS1),  .FUS2(FUS2),  .FUS3(FUS3),
  .FUS4(FUS4), .FUS5(FUS5),  .FUS6(FUS6),  .FUS7(FUS7),
  .FUS8(FUS8),.FUS9(FUS9),
  .fxFRT_alten_reg(|fxFRT_alten_reg[2]),
  .fcvtout({FUTYPE,FUCVT2}), //might need less than 6 regs due to internal regs
  .DataAlt(dalt),
  .FUCVTIN(FUCVT1[63:0])
  ); 
`else
  fu_alu alu_ALIGNED(
  .clk(clk),
  .rst(rst),
  .except(except),
  .msrss_addr(msrss_no),
  .msrss_data(msrss_data),
  .msrss_en(msrss_en),
  .jxcross(pfy),
  .allah(bofh),
  .u1_A(outDataA[0+1]),.u1_B(outDataA[0+1]),.u1_S(outDataS[0+1]),.u1_op(outOp[0+1]),
  .u1_ret({FUS_alu[0],ex_alu[0]}),.u1_rten(enS_alu[0]),.u1_clkEn(outEn[0+1][0]&outEn[0+1][1]),
    .u1_A_fufwd(fuFwdA[0+1]),.u1_A_fuufwd(fuuFwdA[0+1]),
    .u1_B_fufwd(fuFwdA[0+1]),.u1_B_fuufwd(fuuFwdA[0+1]),
    .u1_S_fufwd(fuFwdS[0+1]),.u1_S_fuufwd(fuuFwdS[0+1]),
  .u2_A(outDataA[0+2]),.u2_B(outDataA[0+2]),.u2_S(outDataS[0+2]),.u2_op(outOp[0+2]),
  .u2_ret({FUS_alu[1],ex_alu[1]}),.u2_rten(enS_alu[1]),.u2_clkEn(outEn[0+2][0]&outEn[0+2][1]),
    .u2_A_fufwd(fuFwdA[0+2]),.u2_A_fuufwd(fuuFwdA[0+2]),
    .u2_B_fufwd(fuFwdA[0+2]),.u2_B_fuufwd(fuuFwdA[0+2]),
    .u2_S_fufwd(fuFwdS[0+2]),.u2_S_fuufwd(fuuFwdS[0+2]),
  .u3_A(outDataA[3+1]),.u3_B(outDataA[3+1]),.u3_S(outDataS[3+1]),.u3_op(outOp[3+1]),
  .u3_ret({FUS_alu[2],ex_alu[2]}),.u3_rten(enS_alu[2]),.u3_clkEn(outEn[3+1][0]&outEn[3+1][1]),
    .u3_A_fufwd(fuFwdA[3+1]),.u3_A_fuufwd(fuuFwdA[3+1]),
    .u3_B_fufwd(fuFwdA[3+1]),.u3_B_fuufwd(fuuFwdA[3+1]),
    .u3_S_fufwd(fuFwdS[3+1]),.u3_S_fuufwd(fuuFwdS[3+1]),
  .u4_A(outDataA[3+2]),.u4_B(outDataA[3+2]),.u4_S(outDataS[3+2]),.u4_op(outOp[3+2]),
  .u4_ret({FUS_alu[3],ex_alu[3]}),.u4_rten(enS_alu[3]),.u4_clkEn(outEn[3+2][0]&outEn[3+2][1]),
    .u4_A_fufwd(fuFwdA[3+2]),.u4_A_fuufwd(fuuFwdA[3+2]),
    .u4_B_fufwd(fuFwdA[3+2]),.u4_B_fuufwd(fuuFwdA[3+2]),
    .u4_S_fufwd(fuFwdS[3+2]),.u4_S_fuufwd(fuuFwdS[3+2]),
  .u5_A(outDataA[6+1]),.u5_B(outDataA[6+1]),.u5_S(outDataS[6+1]),.u5_nDataAlt(nDataAlt_reg[2][1]),.u5_op(outOp[6+1]),
  .u5_ret({FUS_alu[4],ex_alu[4]}),.u5_rten(enS_alu[4]),.u5_clkEn(outEn[6+1][0]&outEn[6+1][1]),
    .u5_A_fufwd(fuFwdA[6+1]),.u5_A_fuufwd(fuuFwdA[6+1]),
    .u5_B_fufwd(fuFwdA[6+1]),.u5_B_fuufwd(fuuFwdA[6+1]),
    .u5_S_fufwd(fuFwdS[6+1]),.u5_S_fuufwd(fuuFwdS[6+1]),
  .u6_A(outDataA[6+2]),.u6_B(outDataA[6+2]),.u6_S(outDataS[6+2]),.u6_op(outOp[6+2]),
  .u6_ret({FUS_alu[5],ex_alu[5]}),.u6_rten(enS_alu[5]),.u6_clkEn(outEn[6+2][0]&outEn[6+2][1]),
    .u6_A_fufwd(fuFwdA[6+2]),.u6_A_fuufwd(fuuFwdA[6+2]),
    .u6_B_fufwd(fuFwdA[6+2]),.u6_B_fuufwd(fuuFwdA[6+2]),
    .u6_S_fufwd(fuFwdS[6+2]),.u6_S_fuufwd(fuuFwdS[6+2]),
    .u6_attr(outAttr[6+2]),
  .FU0(FU[0]), .FU1(FU[1]),  .FU2(FU[2]),  .FU3(FU[3]),
  .FU4(FU[4]), .FU5(FU[5]),  .FU6(FU[6]),  .FU7(FU[7]),
  .FU8(FU[8]), .FU9(FU[9]),
  .FUS1(FUS1),  .FUS2(FUS2),  .FUS3(FUS3),
  .FUS4(FUS4), .FUS5(FUS5),  .FUS6(FUS6),  .FUS7(FUS7),
  .FUS8(FUS8),.FUS9(FUS9),
  .fxFRT_alten_reg(|fxFRT_alten_reg[2]),
  .fcvtout({FUTYPE,FUCVT2}), //might need less than 6 regs due to internal regs
  .DataAlt(dalt),
  .FUCVTIN(FUCVT1[63:0])
  );
`endif

  assign nDataAlt[2][2]=~dalt[1];
  assign nDataAlt[2][0]=~dalt[0];
  assign nDataAlt[0]=3'b111;
  assign nDataAlt[1]=3'b111;

  assign insert_isData=insBus_req[9:5]==BUS_ID && !insBus_req[4] && insBus_en;

  addrcalc_block #(BUS_ID) addrcalc_aligned(
  .clk(clk), .rst(rst|do_sched_rst),
  .clkREF(clkREF),.clkREF2(clkREF2),
  .except(except),
  .excpt_gate(),
  .excpt_in_vm(),
  .excpt_in_km(),
  .rsStall(rsDoStall),//input
  .pause_addrcalc(pause_addrcalc),
  .miss_holds_addrcalc(miss_holds_addrcalc),
  .miss_pause_addrcalc(miss_pause_addrcalc),
  .wt_pause_addrcalc(wt_pause_addrcalc),
  .mOp_write_clear(write_clear),
  .u1_base(outDataB[0]),.u1_index(outDataA[0]),.u1_const(outDataC[0][43:0]),
  .u1_base_fufwd(fuFwdB[0]),.u1_base_fuufwd(fuuFwdB[0]),
  .u1_index_fufwd(fuFwdA[0]),.u1_index_fuufwd(fuuFwdA[0]),
  .u1_op(outOp[0][12:0]),.u1_reg(outReg[0]),
  .u1_LSQ_no(outLSQ[0]),.u1_II_no(outII[0]),.u1_WQ_no(outWQ[0]),
  .u1_lsflag(outLSflag[0]),.u1_clkEn(outEn[0][0]),
  .u1_attr(outAttr[0]),.u1_thread(outThr[0]),
  .u2_base(outDataB[3]),.u2_index(outDataA[3]),.u2_const(outDataC[3][43:0]),
  .u2_base_fufwd(fuFwdB[3]),.u2_base_fuufwd(fuuFwdB[3]),
  .u2_index_fufwd(fuFwdA[3]),.u2_index_fuufwd(fuuFwdA[3]),
  .u2_op(outOp[3][12:0]),.u2_reg(outReg[3]),
  .u2_LSQ_no(outLSQ[1]),.u2_II_no(outII[3]),.u2_WQ_no(outWQ[1]),
  .u2_lsflag(outLSflag[1]),.u2_clkEn(outEn[3][0]),
  .u2_attr(outAttr[3]),.u2_thread(outThr[3]),
  .u3_base(outDataB[6]),.u3_index(outDataA[6]),.u3_const(outDataC[6][43:0]),
  .u3_base_fufwd(fuFwdB[6]),.u3_base_fuufwd(fuuFwdB[6]),
  .u3_index_fufwd(fuFwdA[6]),.u3_index_fuufwd(fuuFwdA[6]),
  .u3_op(outOp[6][12:0]),.u3_reg(outReg[6]),
  .u3_LSQ_no(outLSQ[2]),.u3_II_no(outII[6]),.u3_WQ_no(outWQ[2]),
  .u3_lsflag(outLSflag[2]),.u3_clkEn(outEn[6][0]),
  .u3_attr(outAttr[6]),.u3_thread(outThr[6]),
  .u4_base(WoutDataB[0]),.u4_index(WoutDataA[0]),.u4_const(WoutDataC[0]),
  .u4_base_fufwd(WfuFwdB[0]),.u4_base_fuufwd(WfuuFwdB[0]),
  .u4_index_fufwd(WfuFwdA[0]),.u4_index_fuufwd(WfuuFwdA[0]),
  .u4_op(WoutOp[0]),.u4_reg(9'b0),
  .u4_LSQ_no(WoutLSQ[0]),.u4_II_no(WoutII[0]),.u4_WQ_no(WoutWQ[0]),
  .u4_lsflag(WoutLSflag[0]),.u4_clkEn(WoutDataEn[0][0]),
  .u4_attr(WoutAttr[0]),.u4_thread(WoutThread[0]),
  .u5_base(WoutDataB[1]),.u5_index(WoutDataA[1]),.u5_const(WoutDataC[1]),
  .u5_base_fufwd(WfuFwdB[1]),.u5_base_fuufwd(WfuuFwdB[1]),
  .u5_index_fufwd(WfuFwdA[1]),.u5_index_fuufwd(WfuuFwdA[1]),
  .u5_op(WoutOp[1]),.u5_reg(9'b0),
  .u5_LSQ_no(WoutLSQ[1]),.u5_II_no(WoutII[1]),.u5_WQ_no(WoutWQ[1]),
  .u5_lsflag(WoutLSflag[1]),.u5_clkEn(WoutDataEn[1][0]),
  .u5_attr(WoutAttr[1]),.u5_thread(WoutThread[1]),
  .mOp0_clHit(dc_rdHitCl[0]),.mOp1_clHit(dc_rdHitCl[1]),.mOp2_clHit(dc_rdHitCl[2]),.mOp3_clHit(dc_rdHitCl[3]),
  .miss4(st0_en_reg3 && !dc_wrHit[0] && st0_type_reg3!=2'b10),
  .mOpY4_en(st0_en),
  .mOpY4_hit(dc_wrHit[0]),
  .mOpY4_dupl(dc_wrDuplCl[0]),//write to a non-exclusive cl
  //mOp4_thread,
  .mOpY4_addrEven(st0_adata[`lsaddr_addrE]),
  .mOpY4_addrOdd(st0_adata[`lsaddr_addrO]),
  .mOpY4_sz(st0_adata[`lsaddr_sz]),
  .mOpY4_first(1'b0),
  .mOpY4_banks(st0_adata[`lsaddr_banks]),//?? st0_banks?
  .mOpY4_bank0(st0_adata[`lsaddr_bank0]),
  .mOpY4_bank1(st0_bank1),
  .mOpY4_bgn_b(st0_bgn_ben),
  .mOpY4_end_b(st0_end_ben),
  .mOpY4_odd(st0_adata[`lsaddr_odd]),
  .mOpY4_addr_low(st0_adata[`lsaddr_low]),
  .mOpY4_split(st0_adata[`lsaddr_split]),
  .mOpY4_clHit(dc_wrHitCl[0]),
  .mOpY4_data(st0_data),
  .mOpY4_pbit(st0_pbit),
  .mOpY4_type(st0_adata[`lsaddr_mtype]),
  .mOpY4_II(st0_adata[`lsaddr_II]),
  .mOpY4_en_o(dc_wrEn[0]),
  .mOpY4_addrEven_o(dc_wrAddrE[0]),
  .mOpY4_addrOdd_o(dc_wrAddrO[0]),
  .mOpY4_sz_o(dc_wrSZ[0]),
  .mOpY4_first_o(write_clear),
  .mOpY4_banks_o(dc_wrBanks[0]),
  .mOpY4_bank0_o(dc_wrBegin[0]),
  .mOpY4_bank1_o(dc_wrEnd[0]),
  .mOpY4_bgn_b_o(dc_wrBGN_BNK[0]),
  .mOpY4_end_b_o(dc_wrEND_BNK[0]),
  .mOpY4_odd_o(dc_odd_wr[0]),
  .mOpY4_addr_low_o(),
  .mOpY4_split_o(dc_split_wr[0]),
//  mOpY4_clHit_o,
  .mOpY4_data_o(dc_wdata[0]),
  .mOpY4_dataN_o(dc_wdata_N[0]),
  .mOpY4_pbit_o(dc_pdata[0]),
  .mOpY4_type_o(),
  .mOpY4_II_o(),
  .miss5(st1_en_reg3 && !dc_wrHit[1] && st1_type_reg3!=2'b10),
  .mOpY5_en(st1_en),
  .mOpY5_hit(dc_wrHit[1]),
  .mOpY5_dupl(dc_wrDuplCl[1]),//write to a non-exclusive cl
  //mOp4_thread,
  .mOpY5_addrEven(st0_adata[`lsaddr_addrE]),
  .mOpY5_addrOdd(st0_adata[`lsaddr_addrO]),
  .mOpY5_sz(st0_adata[`lsaddr_sz]),
  .mOpY5_first(1'b0),
  .mOpY5_banks(st1_adata[`lsaddr_banks]),//?? st1_banks?
  .mOpY5_bank0(st1_adata[`lsaddr_bank0]),
  .mOpY5_bank1(st1_bank1),
  .mOpY5_bgn_b(st1_bgn_ben),
  .mOpY5_end_b(st1_end_ben),
  .mOpY5_odd(st1_adata[`lsaddr_odd]),
  .mOpY5_addr_low(st1_adata[`lsaddr_low]),
  .mOpY5_split(st1_adata[`lsaddr_split]),
  .mOpY5_clHit(dc_wrHitCl[1]),
  .mOpY5_data(st1_data),
  .mOpY5_pbit(st1_pbit),
  .mOpY5_type(st1_adata[`lsaddr_mtype]),
  .mOpY5_II(st1_adata[`lsaddr_II]),
  .mOpY5_en_o(dc_wrEn[1]),
  .mOpY5_addrEven_o(dc_wrAddrE[1]),
  .mOpY5_addrOdd_o(dc_wrAddrO[1]),
  .mOpY5_sz_o(),
  .mOpY5_first_o(),
  .mOpY5_banks_o(dc_wrBanks[1]),
  .mOpY5_bank0_o(dc_wrBegin[1]),
  .mOpY5_bank1_o(dc_wrEnd[1]),
  .mOpY5_bgn_b_o(dc_wrBGN_BNK[1]),
  .mOpY5_end_b_o(dc_wrEND_BNK[1]),
  .mOpY5_odd_o(dc_odd_wr[1]),
  .mOpY5_addr_low_o(),
  .mOpY5_split_o(dc_split_wr[1]),
//  mOpY5_clHit_o,
  .mOpY5_data_o(dc_wdata[1]),
  .mOpY5_dataN_o(dc_wdata_N[1]),
  .mOpY5_pbit_o(dc_pdata[1]),
  .mOpY5_type_o(),
  .mOpY5_II_o(),
  .p0_adata(lsr_wr_data[0]),.p0_banks(),.p0_LSQ(dc_LSQ[0]),
    .p0_en(dc_rdEn[0]),.p0_rsEn(dc_rsEn[0]),.p0_secq(p0_sec),.p0_ret(p_ret[0]),.p0_repl(p_repl[0]),.p0_lsfwd(p_lsfwd[0]),
  .p1_adata(lsr_wr_data[1]),.p1_banks(),.p1_LSQ(dc_LSQ[1]),
    .p1_en(dc_rdEn[1]),.p1_rsEn(dc_rsEn[1]),.p1_secq(p1_sec),.p1_ret(p_ret[1]),.p1_repl(p_repl[1]),.p1_lsfwd(p_lsfwd[1]),
  .p2_adata(lsr_wr_data[2]),.p2_banks(),.p2_LSQ(dc_LSQ[2]),
    .p2_en(dc_rdEn[2]),.p2_rsEn(dc_rsEn[2]),.p2_secq(p2_sec),.p2_ret(p_ret[2]),.p2_repl(p_repl[2]),.p2_lsfwd(p_lsfwd[2]),
    .p2_data(p2_data),.p2_brdbanks(p2_brdbanks),.p2_pbit(p2_pdata),
  .p3_adata(lsr_wr_data[3]),.p3_banks(),.p3_LSQ(dc_LSQ[3]),.p3_pbit(p3_pdata),.p3_pfx(p3_pfx),
    .p3_en(dc_rdEn[3]),.p3_rsEn(dc_rsEn[3]),.p3_ioEn(),.p3_io_ack(insBus_io_reg3),.p3_ret(p_ret[3]),.p3_data(p3_data),.p3_brdbanks(p3_brdbanks),.p3_repl(p_repl[3]),.p3_lsfwd(p_lsfwd[3]),
  .p4_adata(lsr_wr_data[4]),.p4_LSQ(p_LSQ[4]),.p4_en(dc_wrEn[0]),.p4_secq(),.p4_ret(),
  .p5_adata(lsr_wr_data[5]),.p5_LSQ(p_LSQ[5]),.p5_en(dc_wrEn[1]),.p5_secq(),.p5_ret(),
  .p_bankNone(dc_bankNone),
  .FU0Hit(FU0Hit),.FU1Hit(FU1Hit),.FU2Hit(FU2Hit),.FU3Hit(FU3Hit),
  .FU0(FU[0]),.FU1(FU[1]),.FU2(FU[2]),.FU3(FU[3]),.FU4(FU[4]),.FU5(FU[5]),.FU6(FU[6]),.FU7(FU[7]),.FU8(FU[8]),.FU9(FU[9]),
  .FUreg3_reg(FUreg_reg5[3]),.dc_rdataA(dc_rdataA[3]),//is it really reg5?
  .msi_exp_addr(MSI_exp_addr_reg),.msi_en(MSI_exp_en_reg),.msi_out_clear(),//msi_out_clear=can do msi en; todo - make replace last buffer rather than wait + redu
  .msrss_en(msrss_en),.msrss_addr(msrss_no),.msrss_data(msrss_data[63:0]),
  .req_addr(req_addr),.req_mlbAttr(req_mlbAttr),.req_mlbEn(req_mlbEn),
  .bus_mlb_data(bus_mlb_data),.bus_mlb_en(bus_mlb_en),
  .reqBus_en(reqBus_en),
  .reqBus_addr(reqBus_addr[43:7]),
  .reqBus_req(reqBus_req),
  .reqBus_want_excl(reqBus_want_excl),
  .reqBus_dupl(reqBus_dupl),
  .reqBus_io(reqBus_io),
  .reqBus_sz(reqBus_sz),
  .reqBus_low(reqBus_low),
  .reqBus_bank0(reqBus_bank0),
  .reqBus_register(reqBus_register),
  .reqBus_LSQ(reqBus_LSQ),
  .insert_isData(insert_isData),
  .insBus_req(insBus_req),
  .insBus_register(insBus_register),
  .insBus_LSQ(insBus_LSQ),
  .wr0_hit(wr0_hit),
  .wr0_io(wr0_iol),
  .wr0_addrE(wr0_addrE),.wr0_addrO(wr0_addrO),
  .wr0_banks(wr0_banks),
  .wr0_begin(wr0_begin),.wr0_end(wr0_end),
  .wr0_bgn_ben(wr0_bgn_ben),.wr0_end_ben(wr0_end_ben),
  .wr0_odd(wr0_odd),.wr0_split(wr0_split),
  .wr0_data(wr0_data),
  .wr0_pbit(wr0_pbit),.wr0_d128(wr0_d128),
  .wr1_hit(wr1_hit),
  .wr1_io(wr1_iol),
  .wr1_addrE(wr1_addrE),.wr1_addrO(wr1_addrO),
  .wr1_banks(wr1_banks),
  .wr1_begin(wr1_begin),.wr1_end(wr1_end),
  .wr1_bgn_ben(wr1_bgn_ben),.wr1_end_ben(wr1_end_ben),
  .wr1_odd(wr1_odd),.wr1_split(wr1_split),
  .wr1_data(wr1_data),
  .wr1_pbit(wr1_pbit),.wr1_d128(wr1_d128),
  .wrStall(wrStall)
  );
 
//  assign op_cl=L && mflags[`mflags_vec];
//  assign op_ch=H && mflags[`mflags_vec];

  fun_lsq LSQ_grouped(
  .clk(clk),
  .rst(rst|do_rst_sched),
  .except(except),
  .bus_holds_addrcalc_reg2(bus_holds_addrcalc_reg2),
  .miss_holds_addrcalc_reg2(miss_holds_addrcalc_reg2),
  .miss_pause_addrcalc_reg2(miss_pause_addrcalc_reg2),
  .insert_isData_reg2(insert_isData_reg2),
  .pause_addrcalc(pause_addrcalc),.WDoRsPause(Waddrcalc_blockRS),
  .p0_adata(lsr_wr_data[0]),.p0_LSQ(dc_LSQ[0]),.p0_en(dc_rdEn[0]),.p0_rsEn(dc_rsEn[0]),.p0_smpc(p_repl[0]),.p0_lsfwd(p_lsfwd[0]),
  .p1_adata(lsr_wr_data[1]),.p1_LSQ(dc_LSQ[1]),.p1_en(dc_rdEn[1]),.p1_rsEn(dc_rsEn[1]),.p1_smpc(p_repl[1]),.p1_lsfwd(p_lsfwd[1]),
  .p2_adata(lsr_wr_data[2]),.p2_LSQ(dc_LSQ[2]),.p2_en(dc_rdEn[2]),.p2_rsEn(dc_rsEn[2]),.p2_smpc(p_repl[2]),.p2_lsfwd(p_lsfwd[2]),
  .p3_adata(lsr_wr_data[3]),.p3_LSQ(dc_LSQ[3]),.p3_en(dc_rdEn[3]),.p3_rsEn(dc_rsEn[3]),.p3_smpc(p_repl[3]),.p3_lsfwd(p_lsfwd[3]),
  .p4_adata(op_ch ? lsr_wr_ext_data :lsr_wr_data[4]),.p4_LSQ(op_ch ? p_ext_LSQ : p_LSQ[4]),.p4_en(op_ch ? dc_ext_wrEn : dc_wrEn[0]),
  .p5_adata(op_cl ? lsr_wr_ext_data :lsr_wr_data[5]),.p5_LSQ(op_cl ? p_ext_LSQ : p_LSQ[5]),.p5_en(op_cl ? dc_ext_wrEn : dc_wrEn[1]),
  .FU0Hit(FU0Hit|p0_sec_reg2),.FU0Data(dc_rdataA[0]),//not rdat[0]
  .FU1Hit(FU1Hit|p1_sec_reg2),.FU1Data(dc_rdataA[1]),//
  .FU2Hit(FU2Hit|p2_sec_reg2),.FU2Data(dc_rdataA[2]),//
  .FU3Hit(FU3Hit),.FU3Data(dc_rdataA[3]),//
  .st_stall(miss_pause_addrcalc_reg2|bus_holds_addrcalc_reg2),
  .st0_adata(st0_adata),.st0_en(st0_en),.st0_bank1(st0_bank1),.st0_bgn_ben(st0_bgn_ben),.st0_end_ben(st0_end_ben),.st0_data(st0_data),
  .st0_dataX(st0_dataX),.st0_pbit(st0_pbit),
  .st1_adata(st1_adata),.st1_en(st1_en),.st1_bank1(st1_bank1),.st1_bgn_ben(st1_bgn_ben),.st1_end_ben(st1_end_ben),.st1_data(st1_data),
  .st1_dataX(st1_dataX),.st1_pbit(st1_pbit),
  .wb0_adata(lso_adata),.wb0_LSQ(lso_LSQ),.wb0_en(lso_en),.wb0_ret(),.wb0_data(lso_data),.wb0_dataX(lso_dataX),
  .wb0_brdbanks(lso_bnkread),  .wb0_brdbanks2(lso_bnkread2),.wb0_pbit(lso_pbit),
  .wb1_adata(lso2_adata),.wb1_LSQ(lso2_LSQ),.wb1_en(lso2_en),.wb1_ret(),.wb1_data(lso2_data),.wb1_dataX(lso2_dataX),
  .wb1_brdbanks(lso2_bnkread),.wb1_brdbanks2(lso2_bnkread2),.wb1_pbit(lso2_pbit),
  .mem_II_upper(retM_II0),
  .mem_II_upper2(retM_II1),
  .has_store(retM_has_store),
  .mem_II_upper_in(retM_II),
  .mem_II_bits_fine(retM_fine),
  .mem_II_bits_ldconfl(retM_ldconfl),
  .mem_II_bits_waitconfl(retM_waitconfl),
  .mem_II_bits_except(retM_excpt),
  .mem_II_bits_ret(retM_ret),
  .mem_II_exbitsx6(),
  .mem_II_stall(bDoStall_rqSpit),
  .mem_II_stall2(bDoStall_rqSpit0),
  .doStall_rs(doStall_rs),.stall_cntrl(stall_cntrl), 
  .doStall_alloc(doStall_alloc|doStall_alloc2),.doStall_cntrl(doStall_cntrl),
  .doStall_WQ(doStall_WQ),.stall_WQ(stall_WQ),
  .dotire_d(retM_do_tire),
  .xbreak(retM_xbreak),
  .has_xbreak(retM_xbreak_has),
  .ldq_new_mask_reg(ldq_new_mask_reg),.bundle_in_reg2(bundle_in_reg2),.II_upper(II_upper),.LSQ_shr_data(LSQ_shr_data),
  .WQS0_reg(WQS_reg[0]),.WQR0_reg(WQR_reg[0]),
  .WQS1_reg(WQS_reg[1]),.WQR1_reg(WQR_reg[1]),
  .WQS2_reg(WQS_reg[2]),.WQR2_reg(WQR_reg[2]),
  .lsw_wq0(op_ch ? pfxWQ : WDfxWQ_reg3[0]),.lsw_wdata0(op_ch ? pfx_wdata : lsw_wdata[0]),.lsw_wdataX0(op_ch ? pfx_wdataU : lsw_wdataU[0]),
     .lsw_pdata0(op_ch? pfx_pdata : lsw_pdata[0]),.lsw_rs_en0(op_ch ? pfx_dataEn : WDfxDataEn_reg3[0]),
  .lsw_wq1(op_cl ? pfxWQ : WDfxWQ_reg3[1]),.lsw_wdata1(op_cl ? pfx_wdata : lsw_wdata[1]),.lsw_wdataX1(op_cl ? pfx_wdataU : lsw_wdataU[1]),
     .lsw_pdata1(op_cl ? pfx_pdata : lsw_pdata[1]),.lsw_rs_en1(op_cl ? pfx_dataEn : WDfxDataEn_reg3[1]),
  .mOpY4_II(st0_II_reg3),.mOpY4_hit(dc_wrHit[0]),
  .mOpY5_II(st1_II_reg3),.mOpY5_hit(dc_wrHit[1]),
  .lsi0_reg(rs_lsi_reg[0]),.lsi1_reg(rs_lsi_reg[1]),.lsi2_reg(rs_lsi_reg[2]),//only used to check if has mem reqs
  .MSI_exp_addr(MSI_exp_addr_reg),.MSI_en(MSI_exp_en_reg),.lsq_index(LSQ_upper),
  .doStall_STQ(doStall_STQ),
  .doStall_LDQ(doStall_LDQ),
  .doStall_LSQ(doStall_LSQ),
  .rsStall(rsStall),
  .rsDoStall(rsDoStall)
  );
`define swapedge
  fun_fpu_BOTH #(H) fpuL_mod(
  .clk(clk),
  .rst(rst),
  .fpcsr(fpcsr[31:0]),
  .u1_A0(outDataAVL_regn[0]),.u1_B0(outDataBVL_regn[0]),
  .u1_A1(outDataAVH_regn[1]),.u1_B1(outDataBVH_regn[1]),.u1_B0x(outDataBVH_regn[0]),.u1_B1x(outDataBVL_regn[1]),.u1_en(outEn_reg_n[1]),.u1_op(outOp_reg_n[1]),
  .u1_fufwd_A(fuFwdA_reg_n[1]),.u1_fuufwd_A(fuuFwdA_reg_n[1]),
  .u1_fufwd_B(fuFwdB_reg_n[1]),.u1_fuufwd_B(fuuFwdB_reg_n[1]),
  .u1_ret(fretA[0]),.u1_ret_en(fretA_en[0]),.u1_XADD(outXAM_reg_n[1]),.u1_flag(FUS_alu_reg[0]),
  .u3_A0(outDataAVL_regn[2]),.u3_B0(outDataBVL_regn[2]),
  .u3_A1(outDataAVH_regn[3]),.u3_B1(outDataBVH_regn[3]),.u3_B0x(outDataBVH_regn[2]),.u3_B1x(outDataBVL_regn[3]),.u3_en(outEn_reg_n[4]),.u3_op(outOp_reg_n[4]),
  .u3_fufwd_A(fuFwdA_reg_n[4]),.u3_fuufwd_A(fuuFwdA_reg_n[4]),
  .u3_fufwd_B(fuFwdB_reg_n[4]),.u3_fuufwd_B(fuuFwdB_reg_n[4]),
  .u3_ret(fretA[2]),.u3_ret_en(fretA_en[2]),.u3_XADD(outXAM_reg_n[4]),.u3_flag(FUS_alu_reg[2]),
  .u5_A0(outDataAVL_regn[4]),.u5_B0(outDataBVL_regn[4]),
  .u5_A1(outDataAVH_regn[4]),.u5_B1(outDataBVH_regn[4]),.u5_en(outEn_reg_n[7]),.u5_op(outOp_reg_n[7]),
  .u5_fufwd_A(fuFwdA_reg_n[7]),.u5_fuufwd_A(fuuFwdA_reg_n[7]),
  .u5_fufwd_B(fuFwdB_reg_n[7]),.u5_fuufwd_B(fuuFwdB_reg_n[7]),
  .u5_ret(fretA[4]),.u5_ret_en(fretA_en[4]),.u5_XADD(outXAM_reg_n[7]),.u5_flag(FUS_alu_reg[4]),
  .FUFH0(FUVH[0]),.FUFH1(FUVH[1]),.FUFH2(FUVH[2]),
  .FUFH3(FUVH[3]),.FUFH4(FUVH[4]),.FUFH5(FUVH[5]),
  .FUFH6(FUVH[6]),.FUFH7(FUVH[7]),.FUFH8(FUVH[8]),
  .FUFH9(FUVH[9]),
  .FUFL0(FUVL[0]),.FUFL1(FUVL[1]),.FUFL2(FUVL[2]),
  .FUFL3(FUVL[3]),.FUFL4(FUVL[4]),.FUFL5(FUVL[5]),
  .FUFL6(FUVL[6]),.FUFL7(FUVL[7]),.FUFL8(FUVL[8]),
  .FUFL9(FUVL[9]),
  .FUFXL4(FUFXL[4]),  .FUFXL5(FUFXL[5]),  .FUFXL6(FUFXL[6]),
  .FUFXH4(FUFXL[4]),  .FUFXH5(FUFXH[5]),  .FUFXH6(FUFXH[6]),
  .ALTDATAH0(sqrDatFL_reg[67:0]),.ALTDATAH1({FUTYPE_reg,66'b0}),
  .ALTDATAL0(sqrDatFL_reg),.ALTDATAL1({FUCVT2_reg[15+66:66],FUTYPE_reg,FUCVT2_reg[65:0]}),
  .ALT_INP({dalt[1],sqrDatEn_reg}),
  .FUS_alu0(FUS_alu_reg2[0]),.FUS_alu1(FUS_alu_reg5[1]),
  .FUS_alu2(FUS_alu_reg2[2]),.FUS_alu3(FUS_alu_reg5[3]),
  .FUS_alu4(FUS_alu_reg2[4]),.FUS_alu5(FUS_alu_reg5[5]),
  .ex_alu0(ex_alu_reg2[0]),.ex_alu1(ex_alu_reg5[1]),
  .ex_alu2(ex_alu_reg2[2]),.ex_alu3(ex_alu_reg5[3]),
  .ex_alu4(ex_alu_reg2[4]),.ex_alu5(ex_alu_reg5[5]),
  .fxFADD0_raise_s(fsretA[0][10:0]),
  .fxFCADD1_raise_s(fsretA[1][10:0]),
  .fxFADD2_raise_s(fsretA[2][10:0]),
  .fxFCADD3_raise_s(fsretA[3][10:0]),
  .fxFADD4_raise_s(fsretA[4][10:0]),
  .fxFCADD5_raise_s(fsretA[5][10:0]),
  .FUS0(FUS1),.FUS1(FUS2),.FUS2(FUS3),
  .FOOSL0(FOOFL1),.FOOSL1(FOOFL2),.FOOSL2(FOOFL3),
  .XI_dataS(XI_dataS),
  .fxFRT_alten_reg3(|fxFRT_alten_reg3[2]),
  .daltX(nDataAlt[2][1]),
  .FUCVT1(FUCVT1[63:0]),
  .fork_in(frkDH_reg),.fork_out(frkDL)
  );

  

  assign piff=outOp_regn2[11] && outEn_regn2[3] && outOp_regn2[7:0]==8'd0;

  fun_fpsu_BOTH fpsuL_mod(
  .clk(clk),
  .rst(rst),
  .fpcsr(fpcsr[31:0]),
  .u1_A0(outDataAVL[0]),.u1_B0(outDataBVL[0]),
  .u1_A1(outDataAVH[0]),.u1_B1(outDataBVH[0]),
  .u1_en(outEn_reg[1]),.u1_op(outOp_reg[1]),
  .u1_fufwd_A(fuFwdA_reg[1]),.u1_fuufwd_A(fuuFwdA_reg[1]),
  .u1_fufwd_B(fuFwdB_reg[1]),.u1_fuufwd_B(fuuFwdB_reg[1]),
  .u1_ret(fsretA[0]),.u1_ret_en(),.u1_XSUB(outXAM_reg[1]),
  .u3_A0(outDataAVL[2]),.u3_B0(outDataBVL[2]),
  .u3_A1(outDataAVH[2]),.u3_B1(outDataBVH[2]),
  .u3_en(outEn_reg[4]),.u3_op(outOp_reg[4]),
  .u3_fufwd_A(fuFwdA_reg[4]),.u3_fuufwd_A(fuuFwdA_reg[4]),
  .u3_fufwd_B(fuFwdB_reg[4]),.u3_fuufwd_B(fuuFwdB_reg[4]),
  .u3_ret(fsretA[2]),.u3_ret_en(),.u3_XSUB(outXAM_reg[4]),
  .u5_A0(outDataAVL[4]),.u5_B0(outDataBVL[4]),
  .u5_A1(outDataAVH[4]),.u5_B1(outDataBVH[4]),
  .u5_en(outEn_reg[7]),.u5_op(outOp_reg[7]),
  .u5_fufwd_A(fuFwdA_reg[7]),.u5_fuufwd_A(fuuFwdA_reg[7]),
  .u5_fufwd_B(fuFwdB_reg[7]),.u5_fuufwd_B(fuuFwdB_reg[7]),
  .u5_ret(fsretA[4]),.u5_ret_en(),.u5_XSUB(outXAM_reg[7]),
  .FUFH0(FUVH[0]),.FUFH1(FUVH[1]),.FUFH2(FUVH[2]),
  .FUFH3(FUVH[3]),.FUFH4(FUVH[4]),.FUFH5(FUVH[5]),
  .FUFH6(FUVH[6]),.FUFH7(FUVH[7]),.FUFH8(FUVH[8]),
  .FUFH9(FUVH[9]),
  .FUFL0(FUVL[0]),.FUFL1(FUVL[1]),.FUFL2(FUVL[2]),
  .FUFL3(FUVL[3]),.FUFL4(FUVL[4]),.FUFL5(FUVL[5]),
  .FUFL6(FUVL[6]),.FUFL7(FUVL[7]),.FUFL8(FUVL[8]),
  .FUFL9(FUVL[9]),
  .FUFXL4(FUFXL[4]),  .FUFXL5(FUFXL[5]),  .FUFXL6(FUFXL[6]),
  .FUFXH4(FUFXL[4]),  .FUFXH5(FUFXH[5]),  .FUFXH6(FUFXH[6]),
  .ALTDATAH0(sqrDatVL_reg[67:0]),.ALTDATAH1({FUTYPE,66'b0}),
  .ALTDATAL0(sqrDatVL_reg[67:0]),.ALTDATAL1({FUTYPE,FUCVT2[65:0]}),
  .ALT_INP({dalt[1],sqrDatEn_reg}),
  .FOOFL0(FOOFL1),.FOOFL1(FOOFL2),.FOOFL2(FOOFL3),
  .XI_dataS(XI_dataS),
  .fork_in(frkXH_reg),.fork_out(frkXL)
  );


  assign piff_paff_B={frkDH,frkDL};

  assign fxFRT_alten[2]={3'b0,sqrDatEn_reg};
  assign fxFRT_alten[0]=4'b0;
  assign fxFRT_alten[1]=4'b0;

  assign outEn[7]=outOp_reg2[9][11] ? 4'b11 : 4'bz;
  assign outII[7]=outOp_reg2[9][11] ? outII_reg2[9] :10'bz;
  assign outOp[7]=outOp_reg2[9][11] ? outOp_reg2[9] :18'bz;
  assign outReg[7]=outOp_reg2[9][11] ? outReg_reg2[9] : 9'bz;
  assign outRegS[7]=outOp_reg2[9][11] ? outRegS_reg2[9] : 9'bz;

  get_LDQ_new_en ldq_new_mod(
  rs_port[0],rs_ldst_flg[0], 
  rs_port[3],rs_ldst_flg[3], 
  rs_port[6],rs_ldst_flg[6], 
  rs_port[1],rs_ldst_flg[1], 
  rs_port[4],rs_ldst_flg[4], 
  rs_port[7],rs_ldst_flg[7],
  ldq_new_mask);

  
  get_wSwp wSwp_mod(
  .clk(clk),.rst(rst),
  .lsi0(get_lsi(rs_lsi[0])),.st0(rs_port[0]==PORT_STORE),
  .lsi1(get_lsi(rs_lsi[1])),.st1(rs_port[3]==PORT_STORE),
  .lsi2(get_lsi(rs_lsi[2])),.st2(rs_port[6]==PORT_STORE),
  .Wswp(Wswp),
  .lsiA(LSQ_lsqA[2:0]),
  .lsiB(LSQ_lsqB[2:0]),
  .port0(Wport[0]),.port1(Wport[1]),.port2(Wport[2]),
  .domA0(rs_rA_isAnyV[0] ? ~domA[0][0] : ~rs_rA_isV[0]),.domB0(rs_rB_isAnyV[0] ? ~domB[0][0] : ~rs_rB_isV[0]),
  .domA1(rs_rA_isAnyV[3] ? ~domA[3][0] : ~rs_rA_isV[3]),.domB1(rs_rB_isAnyV[3] ? ~domB[3][0] : ~rs_rB_isV[3]),
  .domA2(rs_rA_isAnyV[6] ? ~domA[6][0] : ~rs_rA_isV[6]),.domB2(rs_rB_isAnyV[6] ? ~domB[6][0] : ~rs_rB_isV[6]),
  .rA_useF0(rs_rA_useF[0]),.rB_useF0(rs_rB_useF[0]),
  .rA_useF1(rs_rA_useF[3]),.rB_useF1(rs_rB_useF[3]),
  .rA_useF2(rs_rA_useF[6]),.rB_useF2(rs_rB_useF[6]),
  .op0(rs_operation[0][12:0]),.op1(rs_operation[3][12:0]),.op2(rs_operation[6][12:0]),
  .opA(WopA),.opB(WopB),
  .ind0(rs_index[0]),.ind1(rs_index[3]),.ind2(rs_index[6]),
  .indA(LSQ_indA),.indB(LSQ_indB),
  .wq0(WQR[0]),.wq1(WQR[1]),.wq2(WQR[2]),
  .wqA(LSQ_wqA),.wqB(LSQ_wqB)
  );

  get_wrtII wrtII_mod(
  .wrt0(wrt0_reg),.wrt1(wrt1_reg),.wrt2(wrt2_reg),
  .lsi0(rs_lsi[0]),.lsi1(rs_lsi[1]),.lsi2(rs_lsi[2]),
  .II0(rs0i0_index_reg),.II1(rs1i0_index_reg),.II2(rs2i0_index_reg),
  .wrtII0(wrtII0),.wrtII1(wrtII1),.wrtII2(wrtII2),
  .wrtO0(wrtO0),.wrtO1(wrtO1),.wrtO2(wrtO2)
  );
  
  backend_get_ret ret_mod(
  .newR0(newR[0]),.newR1(newR[1]),.newR2(newR[2]),
  .newR3(newR[3]),.newR4(newR[4]),.newR5(newR[5]),
  .newR6(newR[6]),.newR7(newR[7]),.newR8(newR[8]),
  .en0(rs0i0_allocR_reg),.en1(rs0i1_allocR_reg),
  .en2(rs0i2_allocR_reg),.en3(rs1i0_allocR_reg),
  .en4(rs1i1_allocR_reg),.en5(rs1i2_allocR_reg),
  .en6(rs2i0_allocR_reg),.en7(rs2i1_allocR_reg),.en8(rs2i2_allocR_reg), 
  .rs_index0(rs_index[0]),.rs_index1(rs_index[1]),.rs_index2(rs_index[2]),.rs_index3(rs_index[3]),
  .rs_index4(rs_index[4]),.rs_index5(rs_index[5]),.rs_index6(rs_index[6]),.rs_index7(rs_index[7]),
  .rs_index8(rs_index[8]),
  .ret0(instr_ret[0]),.ret1(instr_ret[1]),.ret2(instr_ret[2]),
  .ret3(instr_ret[3]),.ret4(instr_ret[4]),.ret5(instr_ret[5]),
  .ret6(instr_ret[6]),.ret7(instr_ret[7]),.ret8(instr_ret[8])
  );
 

  get_lsi_en sliMask_mod(
    rs_lsi_reg[0],rs_ldst_flg_reg[0]&~rs_operation_reg[0][0],
    rs_lsi_reg[3],rs_ldst_flg_reg[1]&~rs_operation_reg[1][0],
    rs_lsi_reg[1],rs_ldst_flg_reg[2]&~rs_operation_reg[3][0],
    rs_lsi_reg[4],rs_ldst_flg_reg[3]&~rs_operation_reg[4][0],
    rs_lsi_reg[2],rs_ldst_flg_reg[4]&~rs_operation_reg[6][0],
    rs_lsi_reg[5],rs_ldst_flg_reg[5]&~rs_operation_reg[7][0],
    lsi_bits);

  alloc_WQ WQget_mod(
  .clk(clk),
  .rst(rst),
  .stall(stall_WQ),
  .doStall(doStall_WQ),
  .newEn(bundle_in_reg),
  .newThr(thread_reg),
  .except(except),
  .except_thread(1'b0),
  .except_both(1'b0),
  .wrt0(wrt0_reg),.wrt1(wrt1_reg),.wrt2(wrt2_reg),
  .lsi0(rs_lsi[0]),.lsi1(rs_lsi[1]),.lsi2(rs_lsi[2]),
  .WQr0(WQR[0]),.WQr1(WQR[1]),.WQr2(WQR[2]),
  .WQs0(WQS[0]),.WQs1(WQS[1]),.WQs2(WQS[2]),
  .free0(st0_en),.freeWQ0(st0_adata[`lsaddr_WQ]),
  .free1(st1_en),.freeWQ1(st1_adata[`lsaddr_WQ])
  );

dcache1 L1D_mod(
  .clk(clk),
  .rst(rst),
  .read_addrE0(lsr_wr_data[0][`lsaddr_addrE]), .read_addrO0(lsr_wr_data[0][`lsaddr_addrO]), 
    .read_bank0(lsr_wr_data[0][`lsaddr_banks]), .read_clkEn0(dc_rdEn[0]), .read_hit0(FU0HitP),
    .read_hitCl0(dc_rdHitCl[0]),.read_odd0(lsr_wr_data[0][`lsaddr_odd]), 
    .read_split0(lsr_wr_data[0][`lsaddr_split]), .read_dataA0(dc_rdataA[0]), .read_dataX0(dc_rdataA_X[0]),
    .read_beginA0(lsr_wr_data[0][`lsaddr_bank0]), .read_low0(lsr_wr_data[0][`lsaddr_low]), 
    .read_sz0(lsr_wr_data[0][`lsaddr_sz]),.read_pbit0(dc_pdataA[0]),
  .read_addrE1(lsr_wr_data[1][`lsaddr_addrE]), .read_addrO1(lsr_wr_data[1][`lsaddr_addrO]), 
    .read_bank1(lsr_wr_data[1][`lsaddr_banks]), .read_clkEn1(dc_rdEn[1]), .read_hit1(FU1HitP),   
    .read_hitCl1(dc_rdHitCl[1]),.read_odd1(lsr_wr_data[1][`lsaddr_odd]), 
    .read_split1(lsr_wr_data[1][`lsaddr_split]), .read_dataA1(dc_rdataA[1]), .read_dataX1(dc_rdataA_X[1]), 
    .read_beginA1(lsr_wr_data[1][`lsaddr_bank0]), .read_low1(lsr_wr_data[1][`lsaddr_low]), 
    .read_sz1(lsr_wr_data[1][`lsaddr_sz]),.read_pbit1(dc_pdataA[1]),
  .read_addrE2(lsr_wr_data[2][`lsaddr_addrE]), .read_addrO2(lsr_wr_data[2][`lsaddr_addrO]), 
    .read_bank2(lsr_wr_data[2][`lsaddr_banks]), .read_clkEn2(dc_rdEn[2]), .read_hit2(FU2HitP),   
    .read_hitCl2(dc_rdHitCl[2]),.read_odd2(lsr_wr_data[2][`lsaddr_odd]), 
    .read_split2(lsr_wr_data[2][`lsaddr_split]), .read_dataA2(dc_rdataA[2]), .read_dataX2(dc_rdataA_X[2]),
    .read_beginA2(lsr_wr_data[2][`lsaddr_bank0]), .read_low2(lsr_wr_data[2][`lsaddr_low]), 
    .read_sz2(lsr_wr_data[2][`lsaddr_sz]),.read_pbit2(dc_pdataA[2]),
  .read_addrE3(lsr_wr_data[3][`lsaddr_addrE]), .read_addrO3(lsr_wr_data[3][`lsaddr_addrO]), 
    .read_bank3(lsr_wr_data[3][`lsaddr_banks]), .read_clkEn3(dc_rdEn[3]), .read_hit3(FU3HitP),   
    .read_hitCl3(dc_rdHitCl[3]),.read_odd3(lsr_wr_data[3][`lsaddr_odd]), 
    .read_split3(lsr_wr_data[3][`lsaddr_split]), .read_dataA3(dc_rdataA[3]), .read_dataX3(dc_rdataA_X[3]),
    .read_beginA3(lsr_wr_data[3][`lsaddr_bank0]), .read_low3(lsr_wr_data[3][`lsaddr_low]), 
    .read_sz3(lsr_wr_data[3][`lsaddr_sz]),.read_pbit3(dc_pdataA[3]),.read_pf3(p3_pfx),
  .read_bankNoRead(dc_bankNone),
  .read_invalidate(1'b0),
  .expun_addr(dc_expun_addr),
  .expun_en(dc_expun_en),
  .insert_from_ram(),//no need to implement. was going to be spectre protection
  .write_addrE0(dc_wrAddrE[0]),
  .write_addrO0(dc_wrAddrO[0]),
  .write_bank0(dc_wrBanks[0]),
  .write_clkEn0(dc_wrEn[0] && ~(dc_wrSz[0][4] & dc_wrSz[0][2])),
  .write_hit0(dc_wrHit[0]),
  .write_hitCl0(dc_wrHitCl[0]),
  .write_dupl0(dc_wrDuplCl[0]),
  .write_split0(dc_split_wr[0]),
  .write_pbit0(dc_pdata[0]),
  .write_d128_0(get_d128(dc_wrSZ[0])),
  .write_odd0(dc_odd_wr[0]),
  .write_begin0(dc_wrBegin[0]),
  .write_end0(dc_wrEnd[0]),
  .write_bgnBen0(dc_wrBGN_BNK[0]),
  .write_endBen0(dc_wrEND_BNK[0]),
  .write_data0(dc_wdata[0]),
  .write_dataM0(dc_wdata_N[0]),
  .write_addrE1(dc_wrAddrE[1]),
  .write_addrO1(dc_wrAddrO[1]),
  .write_bank1(dc_wrBanks[1]),
  .write_clkEn1(dc_wrEn[1] && ~(dc_wrSz[1][4] & dc_wrSz[1][2])),
  .write_hit1(dc_wrHit[1]),
  .write_hitCl1(dc_wrHitCl[1]),
  .write_dupl1(dc_wrDuplCl[1]),
  .write_split1(dc_split_wr[1]),
  .write_pbit1(dc_pdata[1]),
  .write_d128_1(get_d128(dc_wrSZ[1])),
  .write_odd1(dc_odd_wr[1]),
  .write_begin1(dc_wrBegin[1]),
  .write_end1(dc_wrEnd[1]),
  .write_bgnBen1(dc_wrBGN_BNK[1]),
  .write_endBen1(dc_wrEND_BNK[1]),
  .write_data1(dc_wdata[1]),
  .write_dataM1(dc_wdata_N[1]),
  .write_clear(write_clear),
  .insert_en(insert_isData_reg3),
  .insert_exclusive(insBus_exclusive_reg3),
  .insert_dirty(insBus_dirty_reg3),
  //.wb_en,
  //.busWb_data
  .busIns_data(insBus_data_reg2),
  .busIns_dataPTR(insBus_dataPTR_reg2),
  .insbus_A(insert_isData_reg2),
  .insbus_B(insert_isData_reg3),
  .msrss_addr(msrss_no),
  .msrss_data(msrss_data),
  .msrss_en(msrss_en)
  );
  
 
  
  cntrl_find_outcome cntrl_unit_mod(
  .clk(clk),.rst(rst),
  .stall(stall_cntrl),.doStall(doStall_cntrl),
  .do_rst_sched(do_rst_sched),
  .new_en(bundle_in_reg2),
  .new_thread(thread_reg2),
  .new_addr(II_upper),
  .except(except),
  .exceptIP(exceptIP),
  .except_attr(excpt_attr),
  .except_thread(),
  .except_both(),
  .except_due_jump(excpt_due_jump),
  .except_jump_ght(excpt_ght),
  .except_jump_ght(excpt_ght2),
  .except_set_instr_flag(except_set_flag),
  .except_jmp_mask_en(except_jmp_mask_en),
  .except_jmp_mask(except_jmp_mask),
  .msrss_no(msrss_no),.msrss_thread(msrss_thread),.msrss_en(msrss_en),.msrss_data(msrss_data),
  .instr0_en(instr_en_reg[0]),.instr0_wren(instr_wren_reg[0]),.instr0_IPOff(instr_IPOff_reg[0]),
    .instr0_magic(instr_magicOff[0]),.instr0_last(instr_last_reg[0]),.instr0_err(instr_err_reg[0]),
  .instr1_en(instr_en_reg[1]),.instr1_wren(instr_wren_reg[1]),.instr1_IPOff(instr_IPOff_reg[1]),
    .instr1_magic(instr_magicOff[1]),.instr1_last(instr_last_reg[1]),.instr1_err(instr_err_reg[0]),
  .instr2_en(instr_en_reg[2]),.instr2_wren(instr_wren_reg[2]),.instr2_IPOff(instr_IPOff_reg[2]),
    .instr2_magic(instr_magicOff[2]),.instr2_last(instr_last_reg[2]),.instr2_err(instr_err_reg[0]),
  .instr3_en(instr_en_reg[3]),.instr3_wren(instr_wren_reg[3]),.instr3_IPOff(instr_IPOff_reg[3]),
    .instr3_magic(instr_magicOff[3]),.instr3_last(instr_last_reg[3]),.instr3_err(instr_err_reg[0]),
  .instr4_en(instr_en_reg[4]),.instr4_wren(instr_wren_reg[4]),.instr4_IPOff(instr_IPOff_reg[4]),
    .instr4_magic(instr_magicOff[4]),.instr4_last(instr_last_reg[4]),.instr4_err(instr_err_reg[0]),
  .instr5_en(instr_en_reg[5]),.instr5_wren(instr_wren_reg[5]),.instr5_IPOff(instr_IPOff_reg[5]),
    .instr5_magic(instr_magicOff[5]),.instr5_last(instr_last_reg[5]),.instr5_err(instr_err_reg[0]),
  .instr6_en(instr_en_reg[6]),.instr6_wren(instr_wren_reg[6]),.instr6_IPOff(instr_IPOff_reg[6]),
    .instr6_magic(instr_magicOff[6]),.instr6_last(instr_last_reg[6]),.instr6_err(instr_err_reg[0]),
  .instr7_en(instr_en_reg[7]),.instr7_wren(instr_wren_reg[7]),.instr7_IPOff(instr_IPOff_reg[7]),
    .instr7_magic(instr_magicOff[7]),.instr7_last(instr_last_reg[7]),.instr7_err(instr_err_reg[0]),
  .instr8_en(instr_en_reg[8]),.instr8_wren(instr_wren_reg[8]),.instr8_IPOff(instr_IPOff_reg[8]),
    .instr8_magic(instr_magicOff[8]),.instr8_last(instr_last_reg[8]),.instr8_err(instr_err_reg[0]),
  .instr9_en(instr_en_reg[9]),.instr9_wren(instr_wren_reg[9]),.instr9_IPOff(instr_IPOff_reg[9]),
    .instr9_magic(instr_magicOff[9]),.instr9_last(instr_last_reg[9]),.instr9_err(instr_err_reg[0]),
  .instr0_rT(instr_rT_reg[0]),.instr0_gen(instr_gen[0]),.instr0_vec(instr_vec[0]),
  .instr1_rT(instr_rT_reg[1]),.instr1_gen(instr_gen[1]),.instr1_vec(instr_vec[1]),
  .instr2_rT(instr_rT_reg[2]),.instr2_gen(instr_gen[2]),.instr2_vec(instr_vec[2]),
  .instr3_rT(instr_rT_reg[3]),.instr3_gen(instr_gen[3]),.instr3_vec(instr_vec[3]),
  .instr4_rT(instr_rT_reg[4]),.instr4_gen(instr_gen[4]),.instr4_vec(instr_vec[4]),
  .instr5_rT(instr_rT_reg[5]),.instr5_gen(instr_gen[5]),.instr5_vec(instr_vec[5]),
  .instr6_rT(instr_rT_reg[6]),.instr6_gen(instr_gen[6]),.instr6_vec(instr_vec[6]),
  .instr7_rT(instr_rT_reg[7]),.instr7_gen(instr_gen[7]),.instr7_vec(instr_vec[7]),
  .instr8_rT(instr_rT_reg[8]),.instr8_gen(instr_gen[8]),.instr8_vec(instr_vec[8]),
  .instr9_rT(instr_rT_reg[9]),.instr9_gen(instr_gen[9]),.instr9_vec(instr_vec[9]),
  .instr0_after_spec(instr_aft_spc_reg[0]),  .instr1_after_spec(instr_aft_spc_reg[1]),
  .instr2_after_spec(instr_aft_spc_reg[2]),  .instr3_after_spec(instr_aft_spc_reg[3]),
  .instr4_after_spec(instr_aft_spc_reg[4]),  .instr5_after_spec(instr_aft_spc_reg[5]),
  .instr6_after_spec(instr_aft_spc_reg[6]),  .instr7_after_spec(instr_aft_spc_reg[7]),
  .instr8_after_spec(instr_aft_spc_reg[8]),  .instr9_after_spec(instr_aft_spc_reg[9]),
  .instr_attr(newAttr_reg2),
  .iret0(instr_ret_reg[0]),.iret1(instr_ret_reg[1]),.iret2(instr_ret_reg[2]),.iret3(instr_ret_reg[3]),.iret4(instr_ret_reg[4]),
  .iret5(instr_ret_reg[5]),.iret6(instr_ret_reg[6]),.iret7(instr_ret_reg[7]),.iret8(instr_ret_reg[8]),
  .iret0_rF(clrR_reg[0][8:4]),.iret1_rF(clrR_reg[1][8:4]),.iret2_rF(clrR_reg[2][8:4]),
  .iret3_rF(clrR_reg[3][8:4]),.iret4_rF(clrR_reg[4][8:4]),.iret5_rF(clrR_reg[5][8:4]),
  .iret6_rF(clrR_reg[6][8:4]),.iret7_rF(clrR_reg[7][8:4]),.iret8_rF(clrR_reg[8][8:4]),
  .iret0_rFl(clrRS_reg[0][8:4]),.iret1_rFl(clrRS_reg[1][8:4]),.iret2_rFl(clrRS_reg[2][8:4]),
  .iret3_rFl(clrRS_reg[3][8:4]),.iret4_rFl(clrRS_reg[4][8:4]),.iret5_rFl(clrRS_reg[5][8:4]),
  .iret6_rFl(clrRS_reg[6][8:4]),.iret7_rFl(clrRS_reg[7][8:4]),.iret8_rFl(clrRS_reg[8][8:4]),
  .iret_clr(clr_reg),
  .ijump0Type(jump0Type_reg2),.ijump0Off(jump0Pos_reg2),.ijump0Val(jump0Val_reg2),.ijump0CLP(jump0CLP_reg2),
  .ijump0IP(jump0IP_reg2[43:1]),.ijump0Mask(jump0Mask_reg2),.ijump0GHT2(jump0GHT2_reg2),
  .ijump1Type(jump1Type_reg2),.ijump1Off(jump1Pos_reg2),.ijump1Val(jump1Val_reg2),.ijump1CLP(jump1CLP_reg2),
  .ijump1IP(jump1IP_reg2[43:1]),.ijump1Mask(jump1Mask_reg2),.ijump1GHT2(jump1GHT2_reg2),
  .ijump0BtbWay(jump0TbufWay_reg2),.ijump0JmpInd(jump0JmpInd_reg2),.ijump0GHT(jump0GHT_reg2),
  .ijump1BtbWay(jump1TbufWay_reg2),.ijump1JmpInd(jump1JmpInd_reg2),.ijump1GHT(jump1GHT_reg2),
  .ijump0SC(jump0SC_reg2),.ijump0Miss(jump0Miss_reg2),.ijump0BtbOnly(jump0TbufOnly_reg2),
  .ijump1SC(jump1SC_reg2),.ijump1Miss(jump1Miss_reg2),.ijump1BtbOnly(jump1TbufOnly_reg2),
  .itk_after(instr_afterTaken_reg),.ifsimd(instr_fsimd_reg2),
  .iJump0Taken(jump0Pred_reg2),.iJump1Taken(jump1Pred_reg2),
  .iJump0Attr(jump0Attr_reg2),.iJump1Attr(jump1Attr_reg2),
  .flTE(retfl_rF),.tire_enFl(retfl_enG),
  .tire0_rT(tire0_rT),.tire0_rF(tire0_rF),.tire0_enG(tire0_enG),.tire0_enV(tire0_enV),.tire0_enF(tire0_enF),
  .tire1_rT(tire1_rT),.tire1_rF(tire1_rF),.tire1_enG(tire1_enG),.tire1_enV(tire1_enV),.tire1_enF(tire1_enF),
  .tire2_rT(tire2_rT),.tire2_rF(tire2_rF),.tire2_enG(tire2_enG),.tire2_enV(tire2_enV),.tire2_enF(tire2_enF),
  .tire3_rT(tire3_rT),.tire3_rF(tire3_rF),.tire3_enG(tire3_enG),.tire3_enV(tire3_enV),.tire3_enF(tire3_enF),
  .tire4_rT(tire4_rT),.tire4_rF(tire4_rF),.tire4_enG(tire4_enG),.tire4_enV(tire4_enV),.tire4_enF(tire4_enF),
  .tire5_rT(tire5_rT),.tire5_rF(tire5_rF),.tire5_enG(tire5_enG),.tire5_enV(tire5_enV),.tire5_enF(tire5_enF),
  .tire6_rT(tire6_rT),.tire6_rF(tire6_rF),.tire6_enG(tire6_enG),.tire6_enV(tire6_enV),.tire6_enF(tire6_enF),
  .tire7_rT(tire7_rT),.tire7_rF(tire7_rF),.tire7_enG(tire7_enG),.tire7_enV(tire7_enV),.tire7_enF(tire7_enF),
  .tire8_rT(tire8_rT),.tire8_rF(tire8_rF),.tire8_enG(tire8_enG),.tire8_enV(tire8_enV),.tire8_enF(tire8_enF),
  .dotire(),
  .retcnt(retcnt),
  .retclr(retclr),
  .jupd0_en(jupd0_en),.jupdt0_en(jupdt0_en),.jupd0_ght_en(jupd0_ght_en),.jupd0_ght2_en(jupd0_ght2_en),
  .jupd0_addr(jupd0_addr),.jupd0_baddr(jupd0_baddr),
  .jupd0_sc(jupd0_sc),.jupd0_tk(jupd0_tk),
  .jupd1_en(jupd1_en),.jupdt1_en(jupdt1_en),.jupd1_ght_en(jupd1_ght_en),.jupd1_ght2_en(jupd1_ght2_en),
  .jupd1_addr(jupd1_addr),.jupd1_baddr(jupd1_baddr),
  .jupd1_sc(jupd1_sc),.jupd1_tk(jupd1_tk),
  .ret0_addr(outII_reg2[1]),
  .ret0_data({6'b0,FUS_alu[0],ex_alu[0]}),
  .ret0_wen(enS_alu[0]),
  .ret1_addr(outII_reg2[2]),
    .ret1_data({6'b0,FUS_alu[1],ex_alu[1]}),
    .ret1_wen(enS_alu[1]),
  .ret2_addr(outII_reg2[4]),
    .ret2_data({6'b0,FUS_alu[2],ex_alu[2]}),
    .ret2_wen(enS_alu[2]),
  .ret0F_addr(outII_reg7[1]),
  .ret0F_data({1'b0,fretX[0]}),
  .ret0F_wen(fretA_en[0]|fretB_en[0]),
  .ret1F_addr(outII_reg7[4]),
  .ret1F_data({1'b0,fretX[2]}),
  .ret1F_wen(fretA_en[2]|fretB_en[2]),
  .ret2F_addr(outII_reg7[7]),
  .ret2F_data({1'b0,fretX[4]}),
  .ret2F_wen(fretA_en[4]|fretB_en[4]),
  .ret3_addr(outII_reg2[5]),
    .ret3_data({6'b0,FUS_alu[3],ex_alu[3]}),
    .ret3_wen(enS_alu[3]),
  .ret4_addr(outII_reg2[7]),
    .ret4_data({6'b0,FUS_alu[4],ex_alu[4]}),
    .ret4_wen(enS_alu[4]),
  .ret5_addr(outII_reg2[8]),
    .ret5_data({6'b0,FUS_alu[5],ex_alu[5]}/*h*/),
    .ret5_wen(enS_alu[5]),
  .ret5_IP(FU_reg[9]),.ret5_IP_en(alu_jupdate),
  .ret6_addr({lsr_wr_data_reg2[3][`lsaddr_II],lsr_wr_data_reg2[3][`lsaddr_II_low]+1}),
  .ret6_data({6'b0,p3_excl,5'b0,2'd0,1'b1}),
  .ret6_wen(lsr_wr_data_reg2[3][`lsaddr_sz][7] && FU3HitP),
  .mem_II_upper(retM_II0),
  .mem_II_upper2(retM_II1),
  .has_stores(retM_has_store),
  .mem_II_upper_out(retM_II),
  .mem_II_bits_fine(retM_fine),
  .mem_II_bits_ldconfl(retM_ldconfl),
  .mem_II_bits_waitconfl(retM_waitconfl),
  .mem_II_bits_except(retM_excpt),
  .mem_II_bits_ret(retM_ret),
  .mem_II_stall((bDoStall_rqSpit|bDoStall_rqSpit0 && retM_has_store)|stall_clkREF), 
  .dotire_d(retM_do_tire),
  .xbreak(retM_xbreak),
  .has_xbreak(retM_xbreak_has)
  );

  assign fretX[0]=fretA_regn[0][1:0]==2'd1 ? fretA_regn[0] : 'z;
  assign fretX[0]=fretA_regn[0][1:0]!=2'd1 && fretB[0][1:0]==2'd1 ? fretB[0] : 'z;
  assign fretX[0]=fretA_regn[0][1:0]!=2'd1 &&	fretB[0][1:0]!=2'd1 ? {fretA_regn[0][13:3]|fretB[0][13:3],fretA_regn[0][2:0]} : 'z;
 
  assign fretX[2]=fretA_regn[2][1:0]==2'd1 ? fretA_regn[2] : 'z;
  assign fretX[2]=fretA_regn[2][1:0]!=2'd1 && fretB[2][1:0]==2'd1 ? fretB[2] : 'z;
  assign fretX[2]=fretA_regn[2][1:0]!=2'd1 &&	fretB[2][1:0]!=2'd1 ? {fretA_regn[2][13:3]|fretB[2][13:3],fretA_regn[2][2:0]} : 'z;
 
  assign fretX[4]=fretA_regn[4][1:0]==2'd1 ? fretA_regn[4] : 'z;
  assign fretX[4]=fretA_regn[4][1:0]!=2'd1 && fretB[4][1:0]==2'd1 ? fretB[4] : 'z;
  assign fretX[4]=fretA_regn[4][1:0]!=2'd1 &&	fretB[4][1:0]!=2'd1 ? {fretA_regn[4][13:3]|fretB[4][13:3],fretA_regn[4][2:0]} : 'z;
 
  assign stall_alloc=|{doStall_rs[3:0],doStall_LSQ,doStall_LDQ,doStall_STQ,doStall_cntrl,doStall_WQ,doStall_alloc2,stall_clkREF};
  assign doStall=doStall_alloc | (|{doStall_rs[3:0]}) | doStall_LSQ | doStall_LDQ | doStall_STQ | doStall_cntrl | doStall_WQ;
  assign stall_rs[0]=doStall_alloc | doStall_rs[1] | doStall_rs[2] | 
    doStall_rs[3] | doStall_LSQ | doStall_LDQ | doStall_STQ | doStall_cntrl | doStall_WQ | doStall_alloc2 | stall_clkREF;
  assign stall_rs[1]=doStall_alloc | doStall_rs[0] | doStall_rs[2] |
    doStall_rs[3] | doStall_LSQ | doStall_LDQ | doStall_STQ | doStall_cntrl | doStall_WQ | doStall_alloc2 | stall_clkREF;
  assign stall_rs[2]=doStall_alloc | doStall_rs[1] | doStall_rs[0] | 
    doStall_rs[3] | doStall_LSQ | doStall_LDQ | doStall_STQ | doStall_cntrl | doStall_WQ | doStall_alloc2 | stall_clkREF;
  assign stall_rs[3]=doStall_alloc | doStall_rs[1] | doStall_rs[0] |
    doStall_rs[2] | doStall_LSQ | doStall_LDQ | doStall_STQ | doStall_cntrl | doStall_WQ | doStall_alloc2 | stall_clkREF;
  assign stall_LSQ=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LDQ,doStall_STQ | doStall_WQ | doStall_alloc2 | stall_clkREF};
  assign stall_cntrl=|{doStall_rs[3:0],doStall_alloc,doStall_LSQ,doStall_LDQ,doStall_STQ | doStall_WQ | doStall_alloc2 | stall_clkREF};
  assign stall_LDQ=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LSQ,doStall_STQ | doStall_WQ | doStall_alloc2 | stall_clkREF};
  assign stall_STQ=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LSQ,doStall_LDQ | doStall_WQ | doStall_alloc2 | stall_clkREF};
  assign stall_WQ=|{doStall_rs[3:0],doStall_alloc,doStall_cntrl,doStall_LSQ,doStall_LDQ,doStall_STQ,doStall_alloc2 | stall_clkREF};

  assign aStall_STQ=stall_clkREF;
  assign aStall_LSQ=aDoStall_STQ | stall_clkREF;
  assign lStall_STQ=lDoStall_lsfw | stall_clkREF;
  assign lStall_lsfw=lDoStall_STQ | stall_clkREF;
  assign lStall=lDoStall_lsfw|lDoStall_STQ | stall_clkREF;
  

  assign regS[0]=9'b0;
  assign regS[3]=9'b0;
  assign regS[6]=9'b0;
  assign retS[0]=1'b1;
  assign retS[3]=1'b1;
  assign retS[6]=1'b1;
  assign funS[0]=10'b0;
  assign funS[3]=10'b0;
  assign funS[6]=10'b0;


  assign FUreg[4]=outReg[3*0+1];
  assign FUreg[5]=outReg[3*1+1];
  assign FUreg[6]=outReg[3*2+1];
  assign FUreg[7]=outReg[3*0+2];
  assign FUreg[8]=outReg[3*1+2];
  assign FUreg[9]=outReg[3*2+2];

  assign FUwen[4]=outEn[3*0+1][0];
  assign FUwen[5]=outEn[3*1+1][0];
  assign FUwen[6]=outEn[3*2+1][0];
  assign FUwen[7]=outEn[3*0+2][0];
  assign FUwen[8]=outEn[3*1+2][0];
  assign FUwen[9]=outEn[3*2+2][0] & ~outOp[3*2+2][11];

  assign FUwen[0]=FUwen0;
  assign FUwen[1]=FUwen1;
  assign FUwen[2]=FUwen2;
  assign FUwen[3]=FUwen3;
  
  assign FUSreg[4]=outRegS[3*0+1];
  assign FUSreg[5]=outRegS[3*1+1];
  assign FUSreg[6]=outRegS[3*2+1];
  assign FUSreg[7]=outRegS[3*0+2];
  assign FUSreg[8]=outRegS[3*1+2];
  assign FUSreg[9]=outRegS[3*2+2];

  rs_s storeRs(
  .clk(clk),
  .dataRst(rst|do_rst_sched),.nonDataRst(except|rst),.rst_thread(1'b0),
  .stall(stall_rs[3]),
  .doStall(doStall_rs[3]),
  .FU0Hit(FU0Hit),.FU1Hit(FU1Hit),.FU2Hit(FU2Hit),.FU3Hit(FU3Hit),
  .rsEnab(~{1'b0,wt_pause_addrcalc|Waddrcalc_blockRS[1],1'b0,wt_pause_addrcalc|Waddrcalc_blockRS[0]}),
  .new_thread(thread_reg2),
// wires to store new values in a buffer
  .newDataA0(dataA[0]),.newDataB0(dataB[0]),.newDataC0(rs_const_reg[0][43:0]&{44{~rs_useBConst_reg[0]}}),
    .newRegA0(WregA[0]),.newRegB0(WregB[0]),
    .newANeeded0(WinflA[0]),.newBNeeded0(WinflB[0]),
    .newOpA0((rs_lsi_reg[0]!=3'd7) ? rs_operation_reg[0][12:0] : WopA_reg[12:0]),
    .newOpB0((rs_lsi_reg[0]!=3'd7) ? rs_operation_reg[0][12:0] : WopB_reg[12:0]),
    .newPort0(Wport_reg[0]),
    .newEnA0(rs_enAW_reg[0]),.newEnB0(rs_enBW_reg[0]),
    .newInstrIndexA0((rs_lsi_reg[0]!=3'd7) ? {II_upper,rs_index_reg[0]} : {II_upper,LSQ_indA_reg}),
    .newInstrIndexB0((rs_lsi_reg[0]!=3'd7) ? {II_upper,rs_index_reg[0]} : {II_upper,LSQ_indB_reg}),
    .newLSQA0((rs_lsi_reg[0]!=3'd7) ? {LSQ_upper,rs_lsi_reg[0]} : {LSQ_upper,LSQ_lsqA_reg}),
    .newLSQB0((rs_lsi_reg[0]!=3'd7) ? {LSQ_upper,rs_lsi_reg[0]} : {LSQ_upper,LSQ_lsqB_reg}),
    .newWQA0((rs_lsi_reg[0]!=3'd7) ? WQR_reg[0] : LSQ_wqA_reg),
    .newWQB0((rs_lsi_reg[0]!=3'd7) ? WQR_reg[0] : LSQ_wqB_reg),
    .rsAlloc0(rs_en_reg[0]&rs_alt_reg[0]),.newGazumpA0(gazumpA[0]),.newGazumpB0(gazumpB[0]),
    .newFunitA0(WfunA[0]),.newFunitB0(WfunB[0]),
    .newLSFlag0(rs_ldst_flg[0]),
    .newAttr0(newAttr_reg2),
  .newDataA1(dataA[3]),.newDataB1(dataB[3]),.newDataC1(rs_const_reg[3][43:0]&{44{~rs_useBConst_reg[3]}}),
    .newRegA1(WregA[1]),.newRegB1(WregB[1]),
    .newANeeded1(WinflA[1]),.newBNeeded1(WinflB[1]),
    .newOpA1((rs_lsi_reg[1]!=3'd7) ? rs_operation_reg[3][12:0] : WopA_reg[12:0]),
    .newOpB1((rs_lsi_reg[1]!=3'd7) ? rs_operation_reg[3][12:0] : WopB_reg[12:0]),
    .newPort1(Wport_reg[1]),
    .newEnA1(rs_enAW_reg[1]),.newEnB1(rs_enBW_reg[1]),
    .newInstrIndexA1((rs_lsi_reg[1]!=3'd7) ? {II_upper,rs_index_reg[3]} : {II_upper,LSQ_indA_reg}),
    .newInstrIndexB1((rs_lsi_reg[1]!=3'd7) ? {II_upper,rs_index_reg[3]} : {II_upper,LSQ_indB_reg}),
    .newLSQA1((rs_lsi_reg[1]!=3'd7) ? {LSQ_upper,rs_lsi_reg[1]} : {LSQ_upper,LSQ_lsqA_reg}),
    .newLSQB1((rs_lsi_reg[1]!=3'd7) ? {LSQ_upper,rs_lsi_reg[1]} : {LSQ_upper,LSQ_lsqB_reg}),
    .newWQA1((rs_lsi_reg[1]!=3'd7) ? WQR_reg[1] : LSQ_wqA_reg),
    .newWQB1((rs_lsi_reg[1]!=3'd7) ? WQR_reg[1] : LSQ_wqB_reg),
    .rsAlloc1(rs_en_reg[3]&rs_alt_reg[1]),.newGazumpA1(gazumpA[3]),.newGazumpB1(gazumpB[3]),
    .newFunitA1(WfunA[1]),.newFunitB1(WfunB[1]),
    .newLSFlag1(rs_ldst_flg[2]),
    .newAttr1(newAttr_reg2),
  .newDataA2(dataA[6]),.newDataB2(dataB[6]),.newDataC2(rs_const_reg[6][43:0]&{44{~rs_useBConst_reg[6]}}),
    .newRegA2(WregA[2]),.newRegB2(WregB[2]),
    .newANeeded2(WinflA[2]),.newBNeeded2(WinflB[2]),
    .newOpA2((rs_lsi_reg[2]!=3'd7) ? rs_operation_reg[6][12:0] : WopA_reg[12:0]),
    .newOpB2((rs_lsi_reg[2]!=3'd7) ? rs_operation_reg[6][12:0] : WopB_reg[12:0]),
    .newPort2(Wport_reg[2]),
    .newEnA2(rs_enAW_reg[2]),.newEnB2(rs_enBW_reg[2]),
    .newInstrIndexA2((rs_lsi_reg[2]!=3'd7) ? {II_upper,rs_index_reg[6]} : {II_upper,LSQ_indA_reg}),
    .newInstrIndexB2((rs_lsi_reg[2]!=3'd7) ? {II_upper,rs_index_reg[6]} : {II_upper,LSQ_indB_reg}),
    .newLSQA2((rs_lsi_reg[2]!=3'd7) ? {LSQ_upper,rs_lsi_reg[2]} : {LSQ_upper,LSQ_lsqA_reg}),
    .newLSQB2((rs_lsi_reg[2]!=3'd7) ? {LSQ_upper,rs_lsi_reg[2]} : {LSQ_upper,LSQ_lsqB_reg}),
    .newWQA2((rs_lsi_reg[2]!=3'd7) ? WQR_reg[2] : LSQ_wqA_reg),
    .newWQB2((rs_lsi_reg[2]!=3'd7) ? WQR_reg[2] : LSQ_wqB_reg),
    .rsAlloc2(rs_en_reg[6]&rs_alt_reg[2]),.newGazumpA2(gazumpA[6]),.newGazumpB2(gazumpB[6]),
    .newFunitA2(WfunA[2]),.newFunitB2(WfunB[2]),
    .newLSFlag2(rs_ldst_flg[4]),
    .newAttr2(newAttr_reg2),
// wires to get values out of buffer
  .outDataA0(WoutDataB[0]),.outDataB0(WoutDataA[0]),.outDataC0(WoutDataC[0]),
    .outOp0(WoutOp[0]),.outInstrIndex0(WoutII[0]),
    .outFuFwdA0(WfuFwdB[0]),.outFuFwdB0(WfuFwdA[0]),.outFuuFwdA0(WfuuFwdB[0]),.outFuuFwdB0(WfuuFwdA[0]),
    .outLSQ0(WoutLSQ[0]),.outDataEn0(WoutDataEn[0]),.outThread0(WoutThread[0]),.outWQ0(WoutWQ[0]),
    .outLSFlag0(WoutLSflag[0]),//addrcalc
    .outAttr0(WoutAttr[0]),
  .outDataB1(WDoutData[0]),.outOp1(WDoutOp[0]),.outInstrIndex1(WDoutII[0]),
    .outFuFwdB1(WDoutFuFwd[0]),.outFuuFwdB1(WDoutFuuFwd[0]),.outLSQ1(WDoutLSQ[0]),
    .outDataEn1(WDoutDataEn[0]),.outThread1(WDoutThread[0]),.outWQ1(WDoutWQ[0]),//data
    .outAttr1(),
  .outDataA2(WoutDataA[1]),.outDataB2(WoutDataB[1]),.outDataC2(WoutDataC[1]),
    .outOp2(WoutOp[1]),.outInstrIndex2(WoutII[1]),
    .outFuFwdA2(WfuFwdA[1]),.outFuFwdB2(WfuFwdB[1]),.outFuuFwdA2(WfuuFwdA[1]),.outFuuFwdB2(WfuuFwdB[1]),
    .outLSQ2(WoutLSQ[1]),.outDataEn2(WoutDataEn[1]),.outThread2(WoutThread[1]),.outWQ2(WoutWQ[1]),
    .outLSFlag2(WoutLSflag[1]),//addrcalc
    .outAttr2(WoutAttr[1]),
  .outDataA3(WDoutData[1]),.outOp3(WDoutOp[1]),.outInstrIndex3(WDoutII[1]),
    .outFuFwdA3(WDoutFuFwd[1]),.outFuuFwdA3(WDoutFuuFwd[1]),.outLSQ3(WDoutLSQ[1]),
    .outDataEn3(WDoutDataEn[1]),.outThread3(WDoutThread[1]),.outWQ3(WDoutWQ[1]),//data
    .outAttr3(),
// wires from functional units  
  .FU0(FU_reg[0]),.FUreg0(FUreg[0]),.FUwen0(FUwen[0]),
  .FU1(FU_reg[1]),.FUreg1(FUreg[1]),.FUwen1(FUwen[1]),
  .FU2(FU_reg[2]),.FUreg2(FUreg[2]),.FUwen2(FUwen[2]),
  .FU3(FU_reg[3]),.FUreg3(FUreg[3]),.FUwen3(FUwen[3]),
  .FU4(FU_reg[4]),.FUreg4(FUreg[4]),.FUwen4(FUwen[4]),
  .FU5(FU_reg[5]),.FUreg5(FUreg[5]),.FUwen5(FUwen[5]),
  .FU6(FU_reg[6]),.FUreg6(FUreg[6]),.FUwen6(FUwen[6]),
  .FU7(FU_reg[7]),.FUreg7(FUreg[7]),.FUwen7(FUwen[7]),
  .FU8(FU_reg[8]),.FUreg8(FUreg[8]),.FUwen8(FUwen[8]),
  .FU9(FU_reg[9]),.FUreg9(FUreg[9]),.FUwen9(FUwen[9]),

  .FUWQ0(lsr_wr_data[4][`lsaddr_WQ]), .FUWQen0(dc_wrEn[0]),
  .FUWQ1(lsr_wr_data[5][`lsaddr_WQ]), .FUWQen1(dc_wrEn[1]),
  
  .newDataVA0H(dataAVH[0]),.newDataVB0H(dataBVH[0]),.newDataVA0L(dataAVL[0]),.newDataVB0L(dataBVL[0]),
  .newDataFA0H(dataAFH[0]),.newDataFB0H(dataBFH[0]),.newDataFA0L(dataAFL[0]),.newDataFB0L(dataBFL[0]),
  .newDataVA1H(dataAVH[1]),.newDataVB1H(dataBVH[1]),.newDataVA1L(dataAVL[1]),.newDataVB1L(dataBVL[1]),
  .newDataFA1H(dataAFH[1]),.newDataFB1H(dataBFH[1]),.newDataFA1L(dataAFL[1]),.newDataFB1L(dataBFL[1]),
  .newDataVA2H(dataAVH[2]),.newDataVB2H(dataBVH[2]),.newDataVA2L(dataAVL[2]),.newDataVB2L(dataBVL[2]),
  .newDataFA2H(dataAFH[2]),.newDataFB2H(dataBFH[2]),.newDataFA2L(dataAFL[2]),.newDataFB2L(dataBFL[2]),

  .outDataVB1H(WDoutDataVH[0]),.outDataVB1L(WDoutDataVL[0]),
  .outDataFB1H(WDoutDataFH[0]),.outDataFB1L(WDoutDataFL[0]),
  .outDataVA3H(WDoutDataVH[1]),.outDataVA3L(WDoutDataVL[1]),
  .outDataFA3H(WDoutDataFH[1]),.outDataFA3L(WDoutDataFL[1]),

  .FUV0H(FUVH[0]),.FUV0L(FUVL[0]),.FUF0H(FUFH[0]),.FUF0L(FUFL[0]),
  .FUV1H(FUVH[1]),.FUV1L(FUVL[1]),.FUF1H(FUFH[1]),.FUF1L(FUFL[1]),
  .FUV2H(FUVH[2]),.FUV2L(FUVL[2]),.FUF2H(FUFH[2]),.FUF2L(FUFL[2]),
  .FUV3H(FUVH[3]),.FUV3L(FUVL[3]),.FUF3H(FUFH[3]),.FUF3L(FUFL[3]),
  .FUV4H(FUVH[4]),.FUV4L(FUVL[4]),.FUF4H(FUFH[4]),.FUF4L(FUFL[4]),
  .FUV5H(FUVH[5]),.FUV5L(FUVL[5]),.FUF5H(FUFH[5]),.FUF5L(FUFL[5]),
  .FUV6H(FUVH[6]),.FUV6L(FUVL[6]),.FUF6H(FUFH[6]),.FUF6L(FUFL[6]),
  .FUV7H(FUVH[7]),.FUV7L(FUVL[7]),.FUF7H(FUFH[7]),.FUF7L(FUFL[7]),
  .FUV8H(FUVH[8]),.FUV8L(FUVL[8]),.FUF8H(FUFH[8]),.FUF8L(FUFL[8]),
  .FUV9H(FUVH[9]),.FUV9L(FUVL[9]),.FUF9H(FUFH[9]),.FUF9L(FUFL[9])
  );

  generate
      genvar q,q1;
      for (q=0;q<8;q=q+1) begin : data_general
          assign FU[0][7+8*q:8*q]=lso_bnkread2[q] & lso_way_reg[0]||~lso_en_reg ? dc_rdataA[0][7+8*q:8*q] : 8'bz;
          assign FU[0][7+8*q:8*q]=lso_bnkread[q] && lso_way_reg[0] && ~lso_en_reg ? lso_data_reg[7+8*q:8*q] : 8'bz;
          assign FU[0][7+8*q:8*q]=(~lso_bnkread2[q] & ~lso_bnkread[q] || ~lso_way_reg[0]) &&~lso_en_reg ? 8'b0 : 8'bz;
          assign FU[1][7+8*q:8*q]=lso_bnkread2[q] & lso_way_reg[1]||~lso_en_reg ? dc_rdataA[1][7+8*q:8*q] : 8'bz;
          assign FU[1][7+8*q:8*q]=lso_bnkread[q] && lso_way_reg[1] && ~lso_en_reg ? lso_data_reg[7+8*q:8*q] : 8'bz;
          assign FU[1][7+8*q:8*q]=(~lso_bnkread2[q] & ~lso_bnkread[q] || ~lso_way_reg[1]) &&~lso_en_reg ? 8'b0 : 8'bz;
          assign FU[2][7+8*q:8*q]=lso_bnkread2[q] & lso_way_reg[2]||~lso_en_reg ? dc_rdataA[2][7+8*q:8*q] : 8'bz;
          assign FU[2][7+8*q:8*q]=lso_bnkread[q] && lso_way_reg[2] && ~lso_en_reg ? lso_data_reg[7+8*q:8*q] : 8'bz;
          assign FU[2][7+8*q:8*q]=(~lso_bnkread2[q] & ~lso_bnkread[q] || ~lso_way_reg[2]) &&~lso_en_reg ? 8'b0 : 8'bz;
          assign FU[3][7+8*q:8*q]=lso2_bnkread2[q] ||~lso2_en_reg ? dc_rdataA[3][7+8*q:8*q] : 8'bz;
          assign FU[3][7+8*q:8*q]=lso2_bnkread[q] && ~lso2_en_reg ? lso2_data_reg[7+8*q:8*q] : 8'bz;
          assign FU[3][7+8*q:8*q]=(~lso2_bnkread2[q] & ~lso2_bnkread[q]) &&~lso2_en_reg ? 8'b0 : 8'bz;
      end
      for (q1=0;q1<17;q1=q1+1) begin : data_general2
          assign dc_rdat[0][7+8*q1:8*q1]=lso_bnkread2[q1] & lso_way_reg[0]||~lso_en_reg ? dc_rdataA[0][7+8*q1:8*q1] : 8'bz;
          assign dc_rdat[0][7+8*q1:8*q1]=lso_bnkread[q1] && lso_way_reg[0] && ~lso_en_reg ? lso_data_reg[7+8*q1:8*q1] : 8'bz;
          assign dc_rdat[0][7+8*q1:8*q1]=(~lso_bnkread2[q1] & ~lso_bnkread[q1] || ~lso_way_reg[0]) &&~lso_en_reg ? 8'b0 : 8'bz;
          assign dc_rdat[1][7+8*q1:8*q1]=lso_bnkread2[q1] & lso_way_reg[1]||~lso_en_reg ? dc_rdataA[1][7+8*q1:8*q1] : 8'bz;
          assign dc_rdat[1][7+8*q1:8*q1]=lso_bnkread[q1] && lso_way_reg[1] && ~lso_en_reg ? lso_data_reg[7+8*q1:8*q1] : 8'bz;
          assign dc_rdat[1][7+8*q1:8*q1]=(~lso_bnkread2[q1] & ~lso_bnkread[q1] || ~lso_way_reg[1]) &&~lso_en_reg ? 8'b0 : 8'bz;
          assign dc_rdat[2][7+8*q1:8*q1]=lso_bnkread2[q1] & lso_way_reg[2]||~lso_en_reg ? dc_rdataA[2][7+8*q1:8*q1] : 8'bz;
          assign dc_rdat[2][7+8*q1:8*q1]=lso_bnkread[q1] && lso_way_reg[2] && ~lso_en_reg ? lso_data_reg[7+8*q1:8*q1] : 8'bz;
          assign dc_rdat[2][7+8*q1:8*q1]=(~lso_bnkread2[q1] & ~lso_bnkread[q1] || ~lso_way_reg[2]) &&~lso_en_reg ? 8'b0 : 8'bz;
          assign dc_rdat[3][7+8*q1:8*q1]=lso2_bnkread2[q1] ||~lso2_en_reg ? dc_rdataA[3][7+8*q1:8*q1] : 8'bz;
          assign dc_rdat[3][7+8*q1:8*q1]=lso2_bnkread[q1] && ~lso2_en_reg ? lso2_data_reg[7+8*q1:8*q1] : 8'bz;
          assign dc_rdat[3][7+8*q1:8*q1]=(~lso2_bnkread2[q1] & ~lso2_bnkread[q1]) &&~lso2_en_reg ? 8'b0 : 8'bz;
          
	  assign dc_rdat_X[0][7+8*q1:8*q1]=lso_bnkread2[q1] & lso_way_reg[0]||~lso_en_reg ? dc_rdataA_X[0][7+8*q1:8*q1] : 8'bz;
          assign dc_rdat_X[0][7+8*q1:8*q1]=lso_bnkread[q1] && lso_way_reg[0] && ~lso_en_reg ? lso_dataX_reg[7+8*q1:8*q1] : 8'bz;
          assign dc_rdat_X[0][7+8*q1:8*q1]=(~lso_bnkread2[q1] & ~lso_bnkread[q1] || ~lso_way_reg[0]) &&~lso_en_reg ? 8'b11111111 : 8'bz;
          assign dc_rdat_X[1][7+8*q1:8*q1]=lso_bnkread2[q1] & lso_way_reg[1]||~lso_en_reg ? dc_rdataA_X[1][7+8*q1:8*q1] : 8'bz;
          assign dc_rdat_X[1][7+8*q1:8*q1]=lso_bnkread[q1] && lso_way_reg[1] && ~lso_en_reg ? lso_dataX_reg[7+8*q1:8*q1] : 8'bz;
          assign dc_rdat_X[1][7+8*q1:8*q1]=(~lso_bnkread2[q1] & ~lso_bnkread[q1] || ~lso_way_reg[1]) &&~lso_en_reg ? 8'b11111111 : 8'bz;
          assign dc_rdat_X[2][7+8*q1:8*q1]=lso_bnkread2[q1] & lso_way_reg[2]||~lso_en_reg ? dc_rdataA_X[2][7+8*q1:8*q1] : 8'bz;
          assign dc_rdat_X[2][7+8*q1:8*q1]=lso_bnkread[q1] && lso_way_reg[2] && ~lso_en_reg ? lso_dataX_reg[7+8*q1:8*q1] : 8'bz;
          assign dc_rdat_X[2][7+8*q1:8*q1]=(~lso_bnkread2[q1] & ~lso_bnkread[q1] || ~lso_way_reg[2]) &&~lso_en_reg ? 8'b11111111 : 8'bz;
          assign dc_rdat_X[3][7+8*q1:8*q1]=lso2_bnkread2[q1] ||~lso2_en_reg ? dc_rdataA_X[3][7+8*q1:8*q1] : 8'bz;
          assign dc_rdat_X[3][7+8*q1:8*q1]=lso2_bnkread[q1] && ~lso2_en_reg ? lso2_dataX_reg[7+8*q1:8*q1] : 8'bz;
          assign dc_rdat_X[3][7+8*q1:8*q1]=(~lso2_bnkread2[q1] & ~lso2_bnkread[q1]) &&~lso2_en_reg ? 8'b11111111 : 8'bz;
      end
  endgenerate
  assign FU[0][64]=lso_bnkread2[0] & lso_way_reg[0] || lso_en_reg              ? dc_pdataA[0][0] : 1'bz;
  assign FU[0][64]=lso_bnkread[0]  & lso_way_reg[0] && ~lso_en_reg             ? lso_pbit_reg[0] : 1'bz;
  assign FU[0][64]=(~lso_bnkread2[0] & ~lso_bnkread[0] || ~lso_way_reg[0]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign FU[1][64]=lso_bnkread2[0] & lso_way_reg[1] || lso_en_reg              ? dc_pdataA[1][0] : 1'bz;
  assign FU[1][64]=lso_bnkread[0]  & lso_way_reg[1] && ~lso_en_reg             ? lso_pbit_reg[0] : 1'bz;
  assign FU[1][64]=(~lso_bnkread2[0] & ~lso_bnkread[0] || ~lso_way_reg[1]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign FU[2][64]=lso_bnkread2[0] & lso_way_reg[2] || lso_en_reg              ? dc_pdataA[2][0] : 1'bz;
  assign FU[2][64]=lso_bnkread[0]  & lso_way_reg[2] && ~lso_en_reg             ? lso_pbit_reg[0] : 1'bz;
  assign FU[2][64]=(~lso_bnkread2[0] & ~lso_bnkread[0] || ~lso_way_reg[2]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign FU[3][64]=lso2_bnkread2[0] || lso2_en_reg              ? dc_pdataA[3][0] : 1'bz;
  assign FU[3][64]=lso2_bnkread[0]  && ~lso2_en_reg             ? lso2_pbit_reg[0] : 1'bz;
  assign FU[3][64]=(~lso2_bnkread2[0] & ~lso2_bnkread[0]) && ~lso2_en_reg ? 1'b0 : 1'bz;

  assign dc_pdat[0][0]=lso_bnkread2[0] & lso_way_reg[0] || lso_en_reg              ? dc_pdataA[0][0] : 1'bz;
  assign dc_pdat[0][0]=lso_bnkread[0]  & lso_way_reg[0] && ~lso_en_reg             ? lso_pbit_reg[0] : 1'bz;
  assign dc_pdat[0][0]=(~lso_bnkread2[0] & ~lso_bnkread[0] || ~lso_way_reg[0]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign dc_pdat[1][0]=lso_bnkread2[0] & lso_way_reg[1] || lso_en_reg              ? dc_pdataA[1][0] : 1'bz;
  assign dc_pdat[1][0]=lso_bnkread[0]  & lso_way_reg[1] && ~lso_en_reg             ? lso_pbit_reg[0] : 1'bz;
  assign dc_pdat[1][0]=(~lso_bnkread2[0] & ~lso_bnkread[0] || ~lso_way_reg[1]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign dc_pdat[2][0]=lso_bnkread2[0] & lso_way_reg[2] || lso_en_reg              ? dc_pdataA[2][0] : 1'bz;
  assign dc_pdat[2][0]=lso_bnkread[0]  & lso_way_reg[2] && ~lso_en_reg             ? lso_pbit_reg[0] : 1'bz;
  assign dc_pdat[2][0]=(~lso_bnkread2[0] & ~lso_bnkread[0] || ~lso_way_reg[2]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign dc_pdat[3][0]=lso2_bnkread2[0] || lso2_en_reg              ? dc_pdataA[3][0] : 1'bz;
  assign dc_pdat[3][0]=lso2_bnkread[0]  && ~lso2_en_reg             ? lso2_pbit_reg[0] : 1'bz;
  assign dc_pdat[3][0]=(~lso2_bnkread2[0] & ~lso2_bnkread[0]) && ~lso2_en_reg ? 1'b0 : 1'bz;

  assign dc_pdat[0][1]=lso_bnkread2[2] & lso_way_reg[0] || lso_en_reg              ? dc_pdataA[0][1] : 1'bz;
  assign dc_pdat[0][1]=lso_bnkread[2]  & lso_way_reg[0] && ~lso_en_reg             ? lso_pbit_reg[1] : 1'bz;
  assign dc_pdat[0][1]=(~lso_bnkread2[2] & ~lso_bnkread[2] || ~lso_way_reg[0]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign dc_pdat[1][1]=lso_bnkread2[2] & lso_way_reg[1] || lso_en_reg              ? dc_pdataA[1][1] : 1'bz;
  assign dc_pdat[1][1]=lso_bnkread[2]  & lso_way_reg[1] && ~lso_en_reg             ? lso_pbit_reg[1] : 1'bz;
  assign dc_pdat[1][1]=(~lso_bnkread2[2] & ~lso_bnkread[2] || ~lso_way_reg[1]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign dc_pdat[2][1]=lso_bnkread2[2] & lso_way_reg[2] || lso_en_reg              ? dc_pdataA[2][1] : 1'bz;
  assign dc_pdat[2][1]=lso_bnkread[2]  & lso_way_reg[2] && ~lso_en_reg             ? lso_pbit_reg[1] : 1'bz;
  assign dc_pdat[2][1]=(~lso_bnkread2[2] & ~lso_bnkread[2] || ~lso_way_reg[2]) && ~lso_en_reg ? 1'b0 : 1'bz;
  assign dc_pdat[3][1]=lso2_bnkread2[2] || lso2_en_reg              ? dc_pdataA[3][1] : 1'bz;
  assign dc_pdat[3][1]=lso2_bnkread[2]  && ~lso2_en_reg             ? lso2_pbit_reg[1] : 1'bz;
  assign dc_pdat[3][1]=(~lso2_bnkread2[2] & ~lso2_bnkread[2]) && ~lso2_en_reg ? 1'b0 : 1'bz;

  assign dc_expun_en=MSI_exp_en_reg;
  assign dc_expun_addr=MSI_exp_addr_reg;
  assign dc_expun_mkshared=MSI_exp_mkshared;

//  assign FU0=dc_rdataA[0][63:0];
//  assign FU1=dc_rdataA[1][63:0];
//  assign FU2=dc_rdataA[2][63:0];
//  assign FU3=dc_rdataA[3][63:0];
 
 // assign dc_rdReg[3]=rec_register_reg;
  
  assign FUreg[0]=lso_way[0] & lso_en ? {lso_adata[`lsaddr_reg_hi],lso_adata[`lsaddr_reg_low]} : dc_rdReg_reg[0];
  assign FUreg[1]=lso_way[1] & lso_en ? {lso_adata[`lsaddr_reg_hi],lso_adata[`lsaddr_reg_low]} : dc_rdReg_reg[1];
  assign FUreg[2]=lso_way[2] & lso_en ? {lso_adata[`lsaddr_reg_hi],lso_adata[`lsaddr_reg_low]} : dc_rdReg_reg[2];
  assign FUreg[3]=lso2_en ? {lso2_adata[`lsaddr_reg_hi],lso2_adata[`lsaddr_reg_low]} : dc_rdReg_reg[3];

  assign FU0Hit=FU0HitP;
  assign FU1Hit=FU1HitP;
  assign FU2Hit=FU2HitP;
  assign FU3Hit=FU3HitP;
  
  popcnt10_or_more cnt_lsi_mod({4'b0,rs_lsi[5][2:1]!=2'd3,rs_lsi[4][2:1]!=2'd3,rs_lsi[3][2:1]!=2'd3,
    rs_lsi[2][2:1]!=2'd3,rs_lsi[1][2:1]!=2'd3,rs_lsi[0][2:1]!=2'd3},lsi_cnt);
  assign LSQ_shr_data[`lsqshare_used]=lsi_cnt_reg;
  assign LSQ_shr_data[`lsqshare_usedB]=lsi_cnt_reg&lsi_bits;
  assign LSQ_shr_data[`lsqshare_II]=II_upper;
  assign LSQ_shr_data[`lsqshare_wrt0]=wrtO0_reg;
  assign LSQ_shr_data[`lsqshare_wrt1]=wrtO1_reg;
  assign LSQ_shr_data[`lsqshare_wrt2]=wrtO2_reg;
  assign LSQ_shr_data[`lsqshare_wrtII0]=wrtII0_reg;
  assign LSQ_shr_data[`lsqshare_wrtII1]=wrtII1_reg;
  assign LSQ_shr_data[`lsqshare_wrtII2]=wrtII2_reg;
//  assign LSQ_shr_data[`lsqshare_flagged]=6'b0; //kludge
  
  
  assign FUS4=FUS_alu[0];
  assign FUS5=FUS_alu[2];
  assign FUS6=FUS_alu[4];
  assign FUS7=FUS_alu[1];
  assign FUS8=FUS_alu[3];
  assign FUS9=FUS_alu[5];

//  assign FUS1=fret_reg[0][8:3];//come from fpu; very fat pwire e.g.g 4x
//  assign FUS2=fret_reg[2][8:3];
//  assign FUS3=fret_reg[4][8:3];
 
   
//  assign LSQ_lsqA[8:3]=LSQ_upper;
//  assign LSQ_lsqB[8:3]=LSQ_upper;
  always @(negedge clk) begin
      if (piff) {frkDH_reg,frkDL_reg}<=piff_paff_A;
      else {frkDH_reg,frkDL_reg}<={frkDH,frkDL};
  end
  always @(posedge clk) begin
      if (rst) begin
	  newAttr_reg<=4'b0;
	  newAttr_reg2<=4'b0;
          rs0i0_alloc_reg<=1'b0;
          rs0i1_alloc_reg<=1'b0;
          rs0i2_alloc_reg<=1'b0;
          rs1i0_alloc_reg<=1'b0;
          rs1i1_alloc_reg<=1'b0;
          rs1i2_alloc_reg<=1'b0;
          rs2i0_alloc_reg<=1'b0;
          rs2i1_alloc_reg<=1'b0;
          rs2i2_alloc_reg<=1'b0;

          rs0i0_allocF_reg<=1'b0;
          rs0i1_allocF_reg<=1'b0;
          rs0i2_allocF_reg<=1'b0;
          rs1i0_allocF_reg<=1'b0;
          rs1i1_allocF_reg<=1'b0;
          rs1i2_allocF_reg<=1'b0;
          rs2i0_allocF_reg<=1'b0;
          rs2i1_allocF_reg<=1'b0;
          rs2i2_allocF_reg<=1'b0;

          rs0i0_allocR_reg<=1'b0;
          rs0i1_allocR_reg<=1'b0;
          rs0i2_allocR_reg<=1'b0;
          rs1i0_allocR_reg<=1'b0;
          rs1i1_allocR_reg<=1'b0;
          rs1i2_allocR_reg<=1'b0;
          rs2i0_allocR_reg<=1'b0;
          rs2i1_allocR_reg<=1'b0;
          rs2i2_allocR_reg<=1'b0;

          rs0i0_en_reg<=1'b0;
          rs0i1_en_reg<=1'b0;
          rs0i2_en_reg<=1'b0;
          rs1i0_en_reg<=1'b0;
          rs1i1_en_reg<=1'b0;
          rs1i2_en_reg<=1'b0;
          rs2i0_en_reg<=1'b0;
          rs2i1_en_reg<=1'b0;
          rs2i2_en_reg<=1'b0;

          rs0i0_useBConst_reg<=1'b0;
          rs0i1_useBConst_reg<=1'b0;
          rs0i2_useBConst_reg<=1'b0;
          rs1i0_useBConst_reg<=1'b0;
          rs1i1_useBConst_reg<=1'b0;
          rs1i2_useBConst_reg<=1'b0;
          rs2i0_useBConst_reg<=1'b0;
          rs2i1_useBConst_reg<=1'b0;
          rs2i2_useBConst_reg<=1'b0;
          
          rs0i0_rT_reg<={IN_REG_WIDTH{1'B0}};
          rs0i1_rT_reg<={IN_REG_WIDTH{1'B0}};
          rs0i2_rT_reg<={IN_REG_WIDTH{1'B0}};
          rs1i0_rT_reg<={IN_REG_WIDTH{1'B0}};
          rs1i1_rT_reg<={IN_REG_WIDTH{1'B0}};
          rs1i2_rT_reg<={IN_REG_WIDTH{1'B0}};
          rs2i0_rT_reg<={IN_REG_WIDTH{1'B0}};
          rs2i1_rT_reg<={IN_REG_WIDTH{1'B0}};
          rs2i2_rT_reg<={IN_REG_WIDTH{1'B0}};

          rs0i0_rA_reg<={IN_REG_WIDTH{1'B0}};
          rs0i1_rA_reg<={IN_REG_WIDTH{1'B0}};
          rs0i2_rA_reg<={IN_REG_WIDTH{1'B0}};
          rs1i0_rA_reg<={IN_REG_WIDTH{1'B0}};
          rs1i1_rA_reg<={IN_REG_WIDTH{1'B0}};
          rs1i2_rA_reg<={IN_REG_WIDTH{1'B0}};
          rs2i0_rA_reg<={IN_REG_WIDTH{1'B0}};
          rs2i1_rA_reg<={IN_REG_WIDTH{1'B0}};
          rs2i2_rA_reg<={IN_REG_WIDTH{1'B0}};

          rs0i0_rB_reg<={IN_REG_WIDTH{1'B0}};
          rs0i1_rB_reg<={IN_REG_WIDTH{1'B0}};
          rs0i2_rB_reg<={IN_REG_WIDTH{1'B0}};
          rs1i0_rB_reg<={IN_REG_WIDTH{1'B0}};
          rs1i1_rB_reg<={IN_REG_WIDTH{1'B0}};
          rs1i2_rB_reg<={IN_REG_WIDTH{1'B0}};
          rs2i0_rB_reg<={IN_REG_WIDTH{1'B0}};
          rs2i1_rB_reg<={IN_REG_WIDTH{1'B0}};
          rs2i2_rB_reg<={IN_REG_WIDTH{1'B0}};

          rs0i0_rA_reg2<={IN_REG_WIDTH{1'B0}};
          rs0i1_rA_reg2<={IN_REG_WIDTH{1'B0}};
          rs0i2_rA_reg2<={IN_REG_WIDTH{1'B0}};
          rs1i0_rA_reg2<={IN_REG_WIDTH{1'B0}};
          rs1i1_rA_reg2<={IN_REG_WIDTH{1'B0}};
          rs1i2_rA_reg2<={IN_REG_WIDTH{1'B0}};
          rs2i0_rA_reg2<={IN_REG_WIDTH{1'B0}};
          rs2i1_rA_reg2<={IN_REG_WIDTH{1'B0}};
          rs2i2_rA_reg2<={IN_REG_WIDTH{1'B0}};

          rs0i0_rB_reg2<={IN_REG_WIDTH{1'B0}};
          rs0i1_rB_reg2<={IN_REG_WIDTH{1'B0}};
          rs0i2_rB_reg2<={IN_REG_WIDTH{1'B0}};
          rs1i0_rB_reg2<={IN_REG_WIDTH{1'B0}};
          rs1i1_rB_reg2<={IN_REG_WIDTH{1'B0}};
          rs1i2_rB_reg2<={IN_REG_WIDTH{1'B0}};
          rs2i0_rB_reg2<={IN_REG_WIDTH{1'B0}};
          rs2i1_rB_reg2<={IN_REG_WIDTH{1'B0}};
          rs2i2_rB_reg2<={IN_REG_WIDTH{1'B0}};

          rs0i0_rA_reg3<={IN_REG_WIDTH{1'B0}};
          rs0i1_rA_reg3<={IN_REG_WIDTH{1'B0}};
          rs0i2_rA_reg3<={IN_REG_WIDTH{1'B0}};
          rs1i0_rA_reg3<={IN_REG_WIDTH{1'B0}};
          rs1i1_rA_reg3<={IN_REG_WIDTH{1'B0}};
          rs1i2_rA_reg3<={IN_REG_WIDTH{1'B0}};
          rs2i0_rA_reg3<={IN_REG_WIDTH{1'B0}};
          rs2i1_rA_reg3<={IN_REG_WIDTH{1'B0}};
          rs2i2_rA_reg3<={IN_REG_WIDTH{1'B0}};

          rs0i0_rB_reg3<={IN_REG_WIDTH{1'B0}};
          rs0i1_rB_reg3<={IN_REG_WIDTH{1'B0}};
          rs0i2_rB_reg3<={IN_REG_WIDTH{1'B0}};
          rs1i0_rB_reg3<={IN_REG_WIDTH{1'B0}};
          rs1i1_rB_reg3<={IN_REG_WIDTH{1'B0}};
          rs1i2_rB_reg3<={IN_REG_WIDTH{1'B0}};
          rs2i0_rB_reg3<={IN_REG_WIDTH{1'B0}};
          rs2i1_rB_reg3<={IN_REG_WIDTH{1'B0}};
          rs2i2_rB_reg3<={IN_REG_WIDTH{1'B0}};

          rs0i0_index_reg<=4'b0;
          rs0i1_index_reg<=4'b0;
          rs0i2_index_reg<=4'b0;
          rs1i0_index_reg<=4'b0;
          rs1i1_index_reg<=4'b0;
          rs1i2_index_reg<=4'b0;
          rs2i0_index_reg<=4'b0;
          rs2i1_index_reg<=4'b0;
          rs2i2_index_reg<=4'b0;
	  rs2i2_mul_reg<=1'b0;

          rs_rA_isV<=9'b0;
          rs_rA_isAnyV<=9'b0;
          rs_rB_isV<=9'b0;
          rs_rB_isAnyV<=9'b0;
          rs_rT_isV<=9'b0;
          rs_rT_use<=9'b0;
          rs_rT_useF<=9'b0;
	  isAV_reg<=9'b0;
	  isBV_reg<=9'b0;
	  isAF_reg<=9'b0;
	  isBF_reg<=9'b0;
          rs_enA<=3'b0;
          rs_enB<=3'b0;
          rs_enA_reg<=3'b0;
          rs_enB_reg<=3'b0;
          rs_enAW_reg<=3'b0;
          rs_enBW_reg<=3'b0;

          rs0i1_lastFl_reg<=1'b0;
          rs0i2_lastFl_reg<=1'b0;
          rs1i1_lastFl_reg<=1'b0;
          rs1i2_lastFl_reg<=1'b0;
          rs2i1_lastFl_reg<=1'b0;
          rs2i2_lastFl_reg<=1'b0;

          rs0i1_flag_wr_reg<=1'b0;
          rs0i2_flag_wr_reg<=1'b0;
          rs1i1_flag_wr_reg<=1'b0;
          rs1i2_flag_wr_reg<=1'b0;
          rs2i1_flag_wr_reg<=1'b0;
          rs2i2_flag_wr_reg<=1'b0;

          rs_ldst_flg<=9'b0;
          rs_ldst_flg_reg<=9'b0;

          rs0i1_flagDep_reg<=4'hd;
          rs0i2_flagDep_reg<=4'hd;
          rs1i1_flagDep_reg<=4'hd;
          rs1i2_flagDep_reg<=4'hd;
          rs2i1_flagDep_reg<=4'hd;
          rs2i2_flagDep_reg<=4'hd;

          rs0i1_flagDep_reg2<=4'hd;
          rs0i2_flagDep_reg2<=4'hd;
          rs1i1_flagDep_reg2<=4'hd;
          rs1i2_flagDep_reg2<=4'hd;
          rs2i1_flagDep_reg2<=4'hd;
          rs2i2_flagDep_reg2<=4'hd;
          
          thread_reg<=1'b0;
          thread_reg2<=1'b0;
          thread_reg3<=1'b0;
          bundle_in_reg<=1'b0;
          bundle_in_reg2<=1'b0;
          clr_reg<=9'b0;
          clrS_reg<=9'b0;
          
          rs_useAConst<=9'b0;
          rs_useBConst<=9'b0;
          rs_useBConst_reg<=9'b0;
          
          depA_reg<=9'b0;
          depB_reg<=9'b0;
     
          rs_rA_use<=9'b0;
          rs_rB_use<=9'b0;
          rs_rA_useF<=9'b0;
          rs_rB_useF<=9'b0;
          rs_rA_useF_reg<=9'b0;
          rs_rB_useF_reg<=9'b0;
          rs_rA_useF_reg2<=9'b0;
          rs_rB_useF_reg2<=9'b0;

	  rs_alt<=3'b0;
	  rs_alt_reg<=3'b0;
          
	  jump0TbufWay_reg<=1'd0;
          jump0JmpInd_reg<=2'd0;
          jump0GHT_reg<=8'd0;
          jump0GHT2_reg<=16'd0;
          jump0Val_reg<=1'b0;
          jump1TbufWay_reg<=1'd0;
          jump1JmpInd_reg<=2'd0;
          jump1GHT_reg<=8'd0;
          jump1GHT2_reg<=16'd0;
          jump1Val_reg<=1'b0;
          jump0SC_reg<=2'd0;
          jump0Miss_reg<=1'b0;
          jump0TbufOnly_reg<=1'b0;
          jump1SC_reg<=2'd0;
          jump1Miss_reg<=1'd0;
          jump1TbufOnly_reg<=1'd0;
	  jump0Type_reg<=5'd0;
	  jump0Pos_reg<=4'hf;
	  jump0Pred_reg<=1'b0;
	  jump0IP_reg<=64'b0;
	  jump0Attr_reg<=4'b0;
	  jump0Mask_reg<=4'b0;
	  jump0Attr_reg<=4'h0;
          jump1Type_reg<=5'd0;
	  jump1Pos_reg<=4'hf;
	  jump1Pred_reg<=1'b0;
	  jump1IP_reg<=64'b0;
	  jump1Attr_reg<=4'b0;
	  jump1Mask_reg<=4'b0;
	  jump1Attr_reg<=4'h0;
	  instr_fsimd_reg<=10'b0;
	  
	  baseIP_reg<=63'b0;
          
              
	  jump0TbufWay_reg2<=1'd0;
          jump0JmpInd_reg2<=2'd0;
          jump0GHT_reg2<=8'd0;
          jump1TbufWay_reg2<=1'd0;
          jump1JmpInd_reg2<=2'd0;
          jump1GHT_reg2<=8'd0;
          jump0GHT2_reg2<=16'd0;
          jump0Val_reg2<=1'b0;
          jump1GHT2_reg2<=16'd0;
          jump1Val_reg2<=1'b0;
          jump0SC_reg2<=2'd0;
          jump0Miss_reg2<=1'b0;
          jump0TbufOnly_reg2<=1'b0;
          jump1SC_reg2<=2'd0;
          jump1Miss_reg2<=1'd0;
          jump1TbufOnly_reg2<=1'd0;
	  jump0Type_reg2<=5'd0;
	  jump0Pos_reg2<=4'hf;
	  jump0Pred_reg2<=1'b0;
	  jump0IP_reg2<=64'b0;
	  jump0Attr_reg2<=4'b0;
	  jump0Mask_reg2<=4'b0;
	  jump0Attr_reg2<=4'h0;
	  jump1Type_reg2<=5'd0;
	  jump1Pos_reg2<=4'hf;
	  jump1Pred_reg2<=1'b0;
	  jump1IP_reg2<=64'b0;
	  jump1Attr_reg2<=4'b0;
	  jump1Mask_reg2<=4'b0;
	  jump1Attr_reg2<=4'h0;
          instr_fsimd_reg2<=10'b0;
      
          wrtO0_reg<=3'b0;
          wrtO1_reg<=3'b0;
          wrtO2_reg<=3'b0;
          wrtII0_reg<=4'b0;
          wrtII1_reg<=4'b0;
          wrtII2_reg<=4'b0;
          WQR_reg[0]<=6'd0;
          WQR_reg[1]<=6'd0;
          WQR_reg[2]<=6'd0;
          WQS_reg[0]<=6'd0;
          WQS_reg[1]<=6'd0;
          WQS_reg[2]<=6'd0;
          lsi_cnt_reg<=6'b0;
          ldq_new_mask_reg<=6'b0; 
          wrt0_reg<=6'h3f;
          wrt1_reg<=6'h3f;
          wrt2_reg<=6'h3f;
          LSQ_lsqA_reg<=3'h7;
          LSQ_lsqB_reg<=3'h7;
          LSQ_indA_reg<=4'hf;
          LSQ_indB_reg<=4'hf;
          LSQ_wqA_reg<=6'b0;
          LSQ_wqB_reg<=6'b0;
          Wswp_reg<=3'b0;
          WopA_reg<=13'b0;
          WopB_reg<=13'b0;
          for(k=0;k<9;k=k+1) begin
              clrR_reg[k]<=9'b0;
              clrRS_reg[k]<=9'b0;
              rs_const[k]<={DATA_WIDTH{1'B0}};
              rs_const_reg[k]<={DATA_WIDTH{1'B0}};
	      rs_IPRel[k]<=1'b0;
	      rs_afterTK[k]<=1'b0;
              rs_index[k]<=4'b0;
              rs_index_reg[k]<=4'b0;
              rs_operation[k]<={OPERATION_WIDTH{1'B0}};
              rs_operation_reg[k]<={OPERATION_WIDTH{1'B0}};
              rs_operation_reg2[k]<={OPERATION_WIDTH{1'B0}};
              rs_port[k]<=4'b0;
              rs_port_reg[k]<=4'b0;
              rs_port_sch[k]<=4'b0;
              regA_reg[k]<={REG_WIDTH{1'B0}};
              regB_reg[k]<={REG_WIDTH{1'B0}};
              regS_reg[k]<={REG_WIDTH{1'B0}};
              regAF_reg[k]<={REG_WIDTH{1'B0}};
              regBF_reg[k]<={REG_WIDTH{1'B0}};
              regAF_reg2[k]<={REG_WIDTH{1'B0}};
              regBF_reg2[k]<={REG_WIDTH{1'B0}};
	      retAF_reg[k]<=1'b0;
	      retBF_reg[k]<=1'b0;
	      retAF_reg2[k]<=1'b0;
	      retBF_reg2[k]<=1'b0;
              newR_reg[k]<={REG_WIDTH{1'B0}};
              newRF_reg[k]<={REG_WIDTH{1'B0}};
              rs_en[k]<=1'b0;
              rs_en_reg[k]<=1'b0;
              funA_reg[k]<=10'b0;
              funB_reg[k]<=10'b0;
              funS_reg[k]<=10'b0;
              rs_lsi[k]<=6'b0;
              rs_lsi_reg[k]<=3'b0;
              domA_reg[k]<=2'b0;
              domB_reg[k]<=2'b0;
              instr_ret_reg[k]<=4'hf;
              rs_xport[k]<=1'b0;
          end
	  for(t=0;t<3;t=t+1) begin
              rrfAW_reg[t]<={IN_REG_WIDTH{1'B0}};
              rrfBW_reg[t]<={IN_REG_WIDTH{1'B0}};
              rrfAW_reg2[t]<={IN_REG_WIDTH{1'B0}};
              rrfBW_reg2[t]<={IN_REG_WIDTH{1'B0}};
              regAW_reg[t]<={REG_WIDTH{1'B0}};
              regBW_reg[t]<={REG_WIDTH{1'B0}};
              regAWF_reg[t]<={REG_WIDTH{1'B0}};
              regBFW_reg[t]<={REG_WIDTH{1'B0}};
              regAWF_reg2[t]<={REG_WIDTH{1'B0}};
              regBFW_reg2[t]<={REG_WIDTH{1'B0}};
	      retAWF_reg[t]<=1'b0;
	      retBFW_reg[t]<=1'b0;
	      retAWF_reg2[t]<=1'b0;
	      retBFW_reg2[t]<=1'b0;
	      isAWF_reg[t]<=1'b0;
	      isBFW_reg[t]<=1'b0;
	      isAWV_reg[t]<=1'b0;
          isBVW_reg[t]<=1'b0;
	      rs_rAW_useF_reg[t]<=1'b0;
	      rs_rBW_useF_reg[t]<=1'b0;
	      rs_rAW_useF_reg2[t]<=1'b0;
	      rs_rBW_useF_reg2[t]<=1'b0;
	      Wport_reg[t]<=0;
	  end
	  for(t=0;t<10;t=t+1) begin
              instr_rT[t]<={IN_REG_WIDTH{1'B0}};
              instr_en[t]<=1'b0;
              instr_wren[t]<=1'b0;
              instr_IPOff[t]<=9'b0;
              instr_afterTaken[t]<=1'b0;
              instr_rT_useF[t]<=1'b0;
              instr_rT_isV[t]<=1'b0;
              instr_port[t]<={PORT_WIDTH{1'B0}};
              instr_magic[t]<=4'b0;
              instr_last[t]<=1'b0;
	      instr_aft_spc[t]<=1'b0;
              instr_err<=2'b0;
              instr_err_reg<=2'b0;
              
	      instr_rT_reg[t]<={IN_REG_WIDTH{1'B0}};
              instr_en_reg[t]<=1'b0;
              instr_wren_reg[t]<=1'b0;
              instr_IPOff_reg[t]<=9'b0;
              instr_afterTaken_reg[t]<=1'b0;
              instr_rT_useF_reg[t]<=1'b0;
              instr_rT_isV_reg[t]<=1'b0;
              instr_port_reg[t]<={PORT_WIDTH{1'B0}};
              //instr_magic_reg[t]<=4'b0;
              instr_last_reg[t]<=1'b0;
	      instr_magicOff[t]<=3'b0;
	      instr_gen[t]<=1'b0;
	      instr_vec[t]<=1'b0;
	      instr_aft_spc_reg[t]<=1'b0;
	  end
      end else if (~doStall) begin
	  newAttr_reg<=newAttr;
	  newAttr_reg2<=newAttr_reg;
          rs0i0_alloc_reg<=rs0i0_alloc;
          rs0i1_alloc_reg<=rs0i1_alloc;
          rs0i2_alloc_reg<=rs0i2_alloc;
          rs1i0_alloc_reg<=rs1i0_alloc;
          rs1i1_alloc_reg<=rs1i1_alloc;
          rs1i2_alloc_reg<=rs1i2_alloc;
          rs2i0_alloc_reg<=rs2i0_alloc;
          rs2i1_alloc_reg<=rs2i1_alloc;
          rs2i2_alloc_reg<=rs2i2_alloc;

          rs0i0_allocF_reg<=rs0i0_allocF;
          rs0i1_allocF_reg<=rs0i1_allocF;
          rs0i2_allocF_reg<=rs0i2_allocF;
          rs1i0_allocF_reg<=rs1i0_allocF;
          rs1i1_allocF_reg<=rs1i1_allocF;
          rs1i2_allocF_reg<=rs1i2_allocF;
          rs2i0_allocF_reg<=rs2i0_allocF;
          rs2i1_allocF_reg<=rs2i1_allocF;
          rs2i2_allocF_reg<=rs2i2_allocF;

          rs0i0_allocR_reg<=rs0i0_allocR;
          rs0i1_allocR_reg<=rs0i1_allocR;
          rs0i2_allocR_reg<=rs0i2_allocR;
          rs1i0_allocR_reg<=rs1i0_allocR;
          rs1i1_allocR_reg<=rs1i1_allocR;
          rs1i2_allocR_reg<=rs1i2_allocR;
          rs2i0_allocR_reg<=rs2i0_allocR;
          rs2i1_allocR_reg<=rs2i1_allocR;
          rs2i2_allocR_reg<=rs2i2_allocR;

          rs0i0_en_reg<=rs0i0_en;
          rs0i1_en_reg<=rs0i1_en;
          rs0i2_en_reg<=rs0i2_en;
          rs1i0_en_reg<=rs1i0_en;
          rs1i1_en_reg<=rs1i1_en;
          rs1i2_en_reg<=rs1i2_en;
          rs2i0_en_reg<=rs2i0_en;
          rs2i1_en_reg<=rs2i1_en;
          rs2i2_en_reg<=rs2i2_en;

          rs0i0_useBConst_reg<=rs0i0_useBConst;
          rs0i1_useBConst_reg<=rs0i1_useBConst;
          rs0i2_useBConst_reg<=rs0i2_useBConst;
          rs1i0_useBConst_reg<=rs1i0_useBConst;
          rs1i1_useBConst_reg<=rs1i1_useBConst;
          rs1i2_useBConst_reg<=rs1i2_useBConst;
          rs2i0_useBConst_reg<=rs2i0_useBConst;
          rs2i1_useBConst_reg<=rs2i1_useBConst;
          rs2i2_useBConst_reg<=rs2i2_useBConst;
          
          rs0i0_rT_reg<=rs0i0_rT;
          rs0i1_rT_reg<=rs0i1_rT;
          rs0i2_rT_reg<=rs0i2_rT;
          rs1i0_rT_reg<=rs1i0_rT;
          rs1i1_rT_reg<=rs1i1_rT;
          rs1i2_rT_reg<=rs1i2_rT;
          rs2i0_rT_reg<=rs2i0_rT;
          rs2i1_rT_reg<=rs2i1_rT;
          rs2i2_rT_reg<=rs2i2_rT;

          rs0i0_rA_reg<=rs0i0_rA;
          rs0i1_rA_reg<=rs0i1_rA;
          rs0i2_rA_reg<=rs0i2_rA;
          rs1i0_rA_reg<=rs1i0_rA;
          rs1i1_rA_reg<=rs1i1_rA;
          rs1i2_rA_reg<=rs1i2_rA;
          rs2i0_rA_reg<=rs2i0_rA;
          rs2i1_rA_reg<=rs2i1_rA;
          rs2i2_rA_reg<=rs2i2_rA;

          rs0i0_rB_reg<=rs0i0_rB;
          rs0i1_rB_reg<=rs0i1_rB;
          rs0i2_rB_reg<=rs0i2_rB;
          rs1i0_rB_reg<=rs1i0_rB;
          rs1i1_rB_reg<=rs1i1_rB;
          rs1i2_rB_reg<=rs1i2_rB;
          rs2i0_rB_reg<=rs2i0_rB;
          rs2i1_rB_reg<=rs2i1_rB;
          rs2i2_rB_reg<=rs2i2_rB;

          rs0i0_rA_reg2<=rs0i0_rA_reg;
          rs0i1_rA_reg2<=rs0i1_rA_reg;
          rs0i2_rA_reg2<=rs0i2_rA_reg;
          rs1i0_rA_reg2<=rs1i0_rA_reg;
          rs1i1_rA_reg2<=rs1i1_rA_reg;
          rs1i2_rA_reg2<=rs1i2_rA_reg;
          rs2i0_rA_reg2<=rs2i0_rA_reg;
          rs2i1_rA_reg2<=rs2i1_rA_reg;
          rs2i2_rA_reg2<=rs2i2_rA_reg;

          rs0i0_rB_reg2<=rs0i0_rB_reg;
          rs0i1_rB_reg2<=rs0i1_rB_reg;
          rs0i2_rB_reg2<=rs0i2_rB_reg;
          rs1i0_rB_reg2<=rs1i0_rB_reg;
          rs1i1_rB_reg2<=rs1i1_rB_reg;
          rs1i2_rB_reg2<=rs1i2_rB_reg;
          rs2i0_rB_reg2<=rs2i0_rB_reg;
          rs2i1_rB_reg2<=rs2i1_rB_reg;
          rs2i2_rB_reg2<=rs2i2_rB_reg;

          rs0i0_rA_reg3<=rs0i0_rA_reg2;
          rs0i1_rA_reg3<=rs0i1_rA_reg2;
          rs0i2_rA_reg3<=rs0i2_rA_reg2;
          rs1i0_rA_reg3<=rs1i0_rA_reg2;
          rs1i1_rA_reg3<=rs1i1_rA_reg2;
          rs1i2_rA_reg3<=rs1i2_rA_reg2;
          rs2i0_rA_reg3<=rs2i0_rA_reg2;
          rs2i1_rA_reg3<=rs2i1_rA_reg2;
          rs2i2_rA_reg3<=rs2i2_rA_reg2;

          rs0i0_rB_reg3<=rs0i0_rB_reg2;
          rs0i1_rB_reg3<=rs0i1_rB_reg2;
          rs0i2_rB_reg3<=rs0i2_rB_reg2;
          rs1i0_rB_reg3<=rs1i0_rB_reg2;
          rs1i1_rB_reg3<=rs1i1_rB_reg2;
          rs1i2_rB_reg3<=rs1i2_rB_reg2;
          rs2i0_rB_reg3<=rs2i0_rB_reg2;
          rs2i1_rB_reg3<=rs2i1_rB_reg2;
          rs2i2_rB_reg3<=rs2i2_rB_reg2;

          rs0i0_index_reg<=rs0i0_index;
          rs0i1_index_reg<=rs0i1_index;
          rs0i2_index_reg<=rs0i2_index;
          rs1i0_index_reg<=rs1i0_index;
          rs1i1_index_reg<=rs1i1_index;
          rs1i2_index_reg<=rs1i2_index;
          rs2i0_index_reg<=rs2i0_index;
          rs2i1_index_reg<=rs2i1_index;
          rs2i2_index_reg<=rs2i2_index;

	  rs2i2_mul_reg<=rs2i2_mul;

          rs0i1_lastFl_reg<=rs0i1_lastFl;
          rs0i2_lastFl_reg<=rs0i2_lastFl;
          rs1i1_lastFl_reg<=rs1i1_lastFl;
          rs1i2_lastFl_reg<=rs1i2_lastFl;
          rs2i1_lastFl_reg<=rs2i1_lastFl;
          rs2i2_lastFl_reg<=rs2i2_lastFl;

          rs0i1_flag_wr_reg<=rs0i1_flag_wr;
          rs0i2_flag_wr_reg<=rs0i2_flag_wr;
          rs1i1_flag_wr_reg<=rs1i1_flag_wr;
          rs1i2_flag_wr_reg<=rs1i2_flag_wr;
          rs2i1_flag_wr_reg<=rs2i1_flag_wr;
          rs2i2_flag_wr_reg<=rs2i2_flag_wr;

          rs_ldst_flg[0]<=rs0i0_ldst_flg;
          rs_ldst_flg[1]<=rs0i1_ldst_flg;
          rs_ldst_flg[2]<=rs1i0_ldst_flg;
          rs_ldst_flg[3]<=rs1i1_ldst_flg;
          rs_ldst_flg[4]<=rs2i0_ldst_flg;
          rs_ldst_flg[5]<=rs2i1_ldst_flg;

          rs_ldst_flg_reg<=rs_ldst_flg;

          rs0i1_flagDep_reg<=rs0i1_flagDep;
          rs0i2_flagDep_reg<=rs0i2_flagDep;
          rs1i1_flagDep_reg<=rs1i1_flagDep;
          rs1i2_flagDep_reg<=rs1i2_flagDep;
          rs2i1_flagDep_reg<=rs2i1_flagDep;
          rs2i2_flagDep_reg<=rs2i2_flagDep;

          rs0i1_flagDep_reg2<=rs0i1_flagDep_reg;
          rs0i2_flagDep_reg2<=rs0i2_flagDep_reg;
          rs1i1_flagDep_reg2<=rs1i1_flagDep_reg;
          rs1i2_flagDep_reg2<=rs1i2_flagDep_reg;
          rs2i1_flagDep_reg2<=rs2i1_flagDep_reg;
          rs2i2_flagDep_reg2<=rs2i2_flagDep_reg;
          
          rs_const[0]<={^rs0i0_const,rs0i0_const};
          rs_const[1]<={^rs0i1_const,rs0i1_const};
          rs_const[2]<={^rs0i2_const,rs0i2_const};
          rs_const[3]<={^rs1i0_const,rs1i0_const};
          rs_const[4]<={^rs1i1_const,rs1i1_const};
          rs_const[5]<={^rs1i2_const,rs1i2_const};
          rs_const[6]<={^rs2i0_const,rs2i0_const};
          rs_const[7]<={^rs2i1_const,rs2i1_const};
          rs_const[8]<={^rs2i2_const,rs2i2_const};
          
	  rs_IPRel[0]<=rs0i0_IPRel;
          rs_IPRel[1]<=rs0i1_IPRel;
          rs_IPRel[2]<=rs0i2_IPRel;
          rs_IPRel[3]<=rs1i0_IPRel;
          rs_IPRel[4]<=rs1i1_IPRel;
          rs_IPRel[5]<=rs1i2_IPRel;
          rs_IPRel[6]<=rs2i0_IPRel;
          rs_IPRel[7]<=rs2i1_IPRel;
          rs_IPRel[8]<=rs2i2_IPRel;

	  rs_afterTK[0]<=rs0i0_afterTaken;
          rs_afterTK[1]<=rs0i1_afterTaken;
          rs_afterTK[2]<=rs0i2_afterTaken;
          rs_afterTK[3]<=rs1i0_afterTaken;
          rs_afterTK[4]<=rs1i1_afterTaken;
          rs_afterTK[5]<=rs1i2_afterTaken;
          rs_afterTK[6]<=rs2i0_afterTaken;
          rs_afterTK[7]<=rs2i1_afterTaken;
          rs_afterTK[8]<=rs2i2_afterTaken;

          rs_index[0]<=rs0i0_index;
          rs_index[1]<=rs0i1_index;
          rs_index[2]<=rs0i2_index;
          rs_index[3]<=rs1i0_index;
          rs_index[4]<=rs1i1_index;
          rs_index[5]<=rs1i2_index;
          rs_index[6]<=rs2i0_index;
          rs_index[7]<=rs2i1_index;
          rs_index[8]<=rs2i2_index;

          rs_rA_isV[0]<=rs0i0_rA_isV;
          rs_rA_isV[1]<=rs0i1_rA_isV;
          rs_rA_isV[2]<=rs0i2_rA_isV;
          rs_rA_isV[3]<=rs1i0_rA_isV;
          rs_rA_isV[4]<=rs1i1_rA_isV;
          rs_rA_isV[5]<=rs1i2_rA_isV;
          rs_rA_isV[6]<=rs2i0_rA_isV;
          rs_rA_isV[7]<=rs2i1_rA_isV;
          rs_rA_isV[8]<=rs2i2_rA_isV;
          
          rs_rA_isAnyV[0]<=rs0i0_rA_isAnyV;
          rs_rA_isAnyV[1]<=rs0i1_rA_isAnyV;
          rs_rA_isAnyV[2]<=rs0i2_rA_isAnyV;
          rs_rA_isAnyV[3]<=rs1i0_rA_isAnyV;
          rs_rA_isAnyV[4]<=rs1i1_rA_isAnyV;
          rs_rA_isAnyV[5]<=rs1i2_rA_isAnyV;
          rs_rA_isAnyV[6]<=rs2i0_rA_isAnyV;
          rs_rA_isAnyV[7]<=rs2i1_rA_isAnyV;
          rs_rA_isAnyV[8]<=rs2i2_rA_isAnyV;

          rs_rB_isV[0]<=rs0i0_rB_isV;
          rs_rB_isV[1]<=rs0i1_rB_isV;
          rs_rB_isV[2]<=rs0i2_rB_isV;
          rs_rB_isV[3]<=rs1i0_rB_isV;
          rs_rB_isV[4]<=rs1i1_rB_isV;
          rs_rB_isV[5]<=rs1i2_rB_isV;
          rs_rB_isV[6]<=rs2i0_rB_isV;
          rs_rB_isV[7]<=rs2i1_rB_isV;
          rs_rB_isV[8]<=rs2i2_rB_isV;

          rs_rB_isAnyV[0]<=rs0i0_rB_isAnyV;
          rs_rB_isAnyV[1]<=rs0i1_rB_isAnyV;
          rs_rB_isAnyV[2]<=rs0i2_rB_isAnyV;
          rs_rB_isAnyV[3]<=rs1i0_rB_isAnyV;
          rs_rB_isAnyV[4]<=rs1i1_rB_isAnyV;
          rs_rB_isAnyV[5]<=rs1i2_rB_isAnyV;
          rs_rB_isAnyV[6]<=rs2i0_rB_isAnyV;
          rs_rB_isAnyV[7]<=rs2i1_rB_isAnyV;
          rs_rB_isAnyV[8]<=rs2i2_rB_isAnyV;

          rs_rT_isV[0]<=rs0i0_rT_isV;
          rs_rT_isV[1]<=rs0i1_rT_isV;
          rs_rT_isV[2]<=rs0i2_rT_isV;
          rs_rT_isV[3]<=rs1i0_rT_isV;
          rs_rT_isV[4]<=rs1i1_rT_isV;
          rs_rT_isV[5]<=rs1i2_rT_isV;
          rs_rT_isV[6]<=rs2i0_rT_isV;
          rs_rT_isV[7]<=rs2i1_rT_isV;
          rs_rT_isV[8]<=rs2i2_rT_isV;

          rs_rT_use[0]<=rs0i0_rT_use;
          rs_rT_use[1]<=rs0i1_rT_use;
          rs_rT_use[2]<=rs0i2_rT_use;
          rs_rT_use[3]<=rs1i0_rT_use;
          rs_rT_use[4]<=rs1i1_rT_use;
          rs_rT_use[5]<=rs1i2_rT_use;
          rs_rT_use[6]<=rs2i0_rT_use;
          rs_rT_use[7]<=rs2i1_rT_use;
          rs_rT_use[8]<=rs2i2_rT_use;

          rs_rT_useF[0]<=rs0i0_rT_useF;
          rs_rT_useF[1]<=rs0i1_rT_useF;
          rs_rT_useF[2]<=rs0i2_rT_useF;
          rs_rT_useF[3]<=rs1i0_rT_useF;
          rs_rT_useF[4]<=rs1i1_rT_useF;
          rs_rT_useF[5]<=rs1i2_rT_useF;
          rs_rT_useF[6]<=rs2i0_rT_useF;
          rs_rT_useF[7]<=rs2i1_rT_useF;
          rs_rT_useF[8]<=rs2i2_rT_useF;

	  isAV_reg<=isAV;
	  isBV_reg<=isBV;
	  isAF_reg<=isAF;
	  isBF_reg<=isBF;

	  rs_operation[0]<=rs0i0_operation;
          rs_operation[1]<=rs0i1_operation;
          rs_operation[2]<=rs0i2_operation;
          rs_operation[3]<=rs1i0_operation;
          rs_operation[4]<=rs1i1_operation;
          rs_operation[5]<=rs1i2_operation;
          rs_operation[6]<=rs2i0_operation;
          rs_operation[7]<=rs2i1_operation;
          rs_operation[8]<=rs2i2_operation;

          rs_port[0]<=rs0i0_port;
          rs_port[1]<=rs0i1_port;
          rs_port[2]<=rs0i2_port;
          rs_port[3]<=rs1i0_port;
          rs_port[4]<=rs1i1_port;
          rs_port[5]<=rs1i2_port;
          rs_port[6]<=rs2i0_port;
          rs_port[7]<=rs2i1_port;
          rs_port[8]<=rs2i2_port;

          rs_enA<={rs2i0_enA,rs1i0_enA,rs0i0_enA};
          rs_enB<={rs2i0_enB,rs1i0_enB,rs0i0_enB};
          rs_enA_reg<=rs_enA;
          rs_enB_reg<=rs_enB;
          rs_enAW_reg<=rs_enAW;
          rs_enBW_reg<=rs_enBW;

          rs_en[0]<=rs0i0_en;
          rs_en[1]<=rs0i1_en;
          rs_en[2]<=rs0i2_en;
          rs_en[3]<=rs1i0_en;
          rs_en[4]<=rs1i1_en;
          rs_en[5]<=rs1i2_en;
          rs_en[6]<=rs2i0_en;
          rs_en[7]<=rs2i1_en;
          rs_en[8]<=rs2i2_en;
          
          rs_lsi[0]<=rs0i0_lsi;
          rs_lsi[1]<=rs1i0_lsi;
          rs_lsi[2]<=rs2i0_lsi;
          rs_lsi[3]<=rs0i1_lsi;
          rs_lsi[4]<=rs1i1_lsi;
          rs_lsi[5]<=rs2i1_lsi;
          
          thread_reg<=thread;
          thread_reg2<=thread_reg;
	  thread_reg3<=thread_reg2;
          bundle_in_reg<=bundle_in;
          bundle_in_reg2<=bundle_in_reg;
          clr_reg<=clr;
          clrS_reg<=clrS;
          
          rs_useBConst<={rs2i2_useBConst,rs2i1_useBConst,rs2i0_useBConst,
            rs1i2_useBConst,rs1i1_useBConst,rs1i0_useBConst,
            rs0i2_useBConst,rs0i1_useBConst,rs0i0_useBConst};
          rs_useBConst_reg<=rs_useBConst&~rs_IPRel;
          rs_useAConst<=useAConst_d;
          depA_reg[2:1]<=(depA[2:1]& rs_rA_use[2:1]) | (depAF[2:1] & rs_rA_useF[2:1]) ;
          depB_reg[2:1]<=(depB[2:1]& rs_rB_use[2:1] & ~rs_useBConst[2:1]) | 
	     (depBF[2:1]& rs_rB_useF[2:1] & ~rs_useBConst[2:1]);
          depA_reg[5:4]<=(depA[5:4]& rs_rA_use[5:4]) | (depAF[5:4] & rs_rA_useF[5:4]) ;
          depB_reg[5:4]<=(depB[5:4]& rs_rB_use[5:4] & ~rs_useBConst[5:4]) | 
	     (depBF[5:4]& rs_rB_useF[5:4] & ~rs_useBConst[5:4]);
          depA_reg[8:7]<=(depA[8:7]& rs_rA_use[8:7]) | (depAF[8:7] & rs_rA_useF[8:7]) ;
          depB_reg[8:7]<=(depB[8:7]& rs_rB_use[8:7] & ~rs_useBConst[8:7]) | 
	     (depBF[8:7]& rs_rB_useF[8:7] & ~rs_useBConst[8:7]);
          depA_reg[0]<=(depA[0]& rs_rA_use[0]) | (depAF[0] & rs_rA_useF[0]);
          depB_reg[0]<=(depB[0]& rs_rB_use[0] & ~rs_useBConst[0] & ~rs_IPRel[0]) |(depBF[0]& rs_rB_useF[0] & ~rs_useBConst[0] & ~rs_IPRel[0]);
          depA_reg[3]<=(depA[3]& rs_rA_use[3]) | (depAF[3] & rs_rA_useF[3]);
          depB_reg[3]<=(depB[3]& rs_rB_use[3] & ~rs_useBConst[3] & ~rs_IPRel[3]) |(depBF[3]& rs_rB_useF[3] & ~rs_useBConst[3] & ~rs_IPRel[3]);
          depA_reg[6]<=(depA[6]& rs_rA_use[6]) | (depAF[6] & rs_rA_useF[6]);
          depB_reg[6]<=(depB[6]& rs_rB_use[6] & ~rs_useBConst[6] & ~rs_IPRel[6]) |(depBF[6]& rs_rB_useF[6] & ~rs_useBConst[6] & ~rs_IPRel[6]);
              
          rs_rA_use<=rs_rA_use_d;
             
          rs_rB_use<=
             {rs2i2_rB_use,rs2i1_rB_use,rs2i0_rB_use,
              rs1i2_rB_use,rs1i1_rB_use,rs1i0_rB_use,
              rs0i2_rB_use,rs0i1_rB_use,rs0i0_rB_use};
              
          rs_rA_useF<=rs_rA_useF_d;

          rs_rB_useF<=
             {rs2i2_rB_useF,rs2i1_rB_useF,rs2i0_rB_useF,
              rs1i2_rB_useF,rs1i1_rB_useF,rs1i0_rB_useF,
              rs0i2_rB_useF,rs0i1_rB_useF,rs0i0_rB_useF};
          
          rs_rA_useF_reg<=rs_rA_useF;
          rs_rB_useF_reg<=rs_rB_useF;
          rs_rA_useF_reg2<=rs_rA_useF_reg;
          rs_rB_useF_reg2<=rs_rB_useF_reg;

	  rs_alt<={rs2i0_alt,rs1i0_alt,rs0i0_alt};
	  rs_alt_reg<=rs_alt;
          
	  instr_rT[0]<=instr0_rT;
	  instr_rT[1]<=instr1_rT;
	  instr_rT[2]<=instr2_rT;
	  instr_rT[3]<=instr3_rT;
	  instr_rT[4]<=instr4_rT;
	  instr_rT[5]<=instr5_rT;
	  instr_rT[6]<=instr6_rT;
	  instr_rT[7]<=instr7_rT;
	  instr_rT[8]<=instr8_rT;
	  instr_rT[9]<=instr9_rT;

          instr_err[0]<=instr0_err;
          instr_err[1]<=instr1_err;
          instr_err[2]<=instr2_err;
          instr_err[3]<=instr3_err;
          instr_err[4]<=instr4_err;
          instr_err[5]<=instr5_err;
          instr_err[6]<=instr6_err;
          instr_err[7]<=instr7_err;
          instr_err[8]<=instr8_err;
          instr_err[9]<=instr9_err;

          instr_en[0]<=instr0_en;
          instr_en[1]<=instr1_en;
          instr_en[2]<=instr2_en;
          instr_en[3]<=instr3_en;
          instr_en[4]<=instr4_en;
          instr_en[5]<=instr5_en;
          instr_en[6]<=instr6_en;
          instr_en[7]<=instr7_en;
          instr_en[8]<=instr8_en;
          instr_en[9]<=instr9_en;

          instr_wren[0]<=instr0_wren;
          instr_wren[1]<=instr1_wren;
          instr_wren[2]<=instr2_wren;
          instr_wren[3]<=instr3_wren;
          instr_wren[4]<=instr4_wren;
          instr_wren[5]<=instr5_wren;
          instr_wren[6]<=instr6_wren;
          instr_wren[7]<=instr7_wren;
          instr_wren[8]<=instr8_wren;
          instr_wren[9]<=instr9_wren;

          instr_IPOff[0]<=instr0_IPOff;
          instr_IPOff[1]<=instr1_IPOff;
          instr_IPOff[2]<=instr2_IPOff;
          instr_IPOff[3]<=instr3_IPOff;
          instr_IPOff[4]<=instr4_IPOff;
          instr_IPOff[5]<=instr5_IPOff;
          instr_IPOff[6]<=instr6_IPOff;
          instr_IPOff[7]<=instr7_IPOff;
          instr_IPOff[8]<=instr8_IPOff;
          instr_IPOff[9]<=instr9_IPOff;

          instr_afterTaken[0]<=instr0_afterTaken;
          instr_afterTaken[1]<=instr1_afterTaken;
          instr_afterTaken[2]<=instr2_afterTaken;
          instr_afterTaken[3]<=instr3_afterTaken;
          instr_afterTaken[4]<=instr4_afterTaken;
          instr_afterTaken[5]<=instr5_afterTaken;
          instr_afterTaken[6]<=instr6_afterTaken;
          instr_afterTaken[7]<=instr7_afterTaken;
          instr_afterTaken[8]<=instr8_afterTaken;
          instr_afterTaken[9]<=instr9_afterTaken;

          instr_rT_useF[0]<=instr0_rT_useF;
          instr_rT_useF[1]<=instr1_rT_useF;
          instr_rT_useF[2]<=instr2_rT_useF;
          instr_rT_useF[3]<=instr3_rT_useF;
          instr_rT_useF[4]<=instr4_rT_useF;
          instr_rT_useF[5]<=instr5_rT_useF;
          instr_rT_useF[6]<=instr6_rT_useF;
          instr_rT_useF[7]<=instr7_rT_useF;
          instr_rT_useF[8]<=instr8_rT_useF;
          instr_rT_useF[9]<=instr9_rT_useF;

          instr_rT_isV[0]<=instr0_rT_isV;
          instr_rT_isV[1]<=instr1_rT_isV;
          instr_rT_isV[2]<=instr2_rT_isV;
          instr_rT_isV[3]<=instr3_rT_isV;
          instr_rT_isV[4]<=instr4_rT_isV;
          instr_rT_isV[5]<=instr5_rT_isV;
          instr_rT_isV[6]<=instr6_rT_isV;
          instr_rT_isV[7]<=instr7_rT_isV;
          instr_rT_isV[8]<=instr8_rT_isV;
          instr_rT_isV[9]<=instr9_rT_isV;

          instr_port[0]<=instr0_port;
          instr_port[1]<=instr1_port;
          instr_port[2]<=instr2_port;
          instr_port[3]<=instr3_port;
          instr_port[4]<=instr4_port;
          instr_port[5]<=instr5_port;
          instr_port[6]<=instr6_port;
          instr_port[7]<=instr7_port;
          instr_port[8]<=instr8_port;
          instr_port[9]<=instr9_port;

          instr_magic[0]<=instr0_magic;
          instr_magic[1]<=instr1_magic;
          instr_magic[2]<=instr2_magic;
          instr_magic[3]<=instr3_magic;
          instr_magic[4]<=instr4_magic;
          instr_magic[5]<=instr5_magic;
          instr_magic[6]<=instr6_magic;
          instr_magic[7]<=instr7_magic;
          instr_magic[8]<=instr8_magic;
          instr_magic[9]<=instr9_magic;
          
	  instr_last[0]<=instr0_last;
          instr_last[1]<=instr1_last;
          instr_last[2]<=instr2_last;
          instr_last[3]<=instr3_last;
          instr_last[4]<=instr4_last;
          instr_last[5]<=instr5_last;
          instr_last[6]<=instr6_last;
          instr_last[7]<=instr7_last;
          instr_last[8]<=instr8_last;
          instr_last[9]<=instr9_last;
          
	  instr_aft_spc[0]<=instr0_aft_spc;
	  instr_aft_spc[1]<=instr1_aft_spc;
	  instr_aft_spc[2]<=instr2_aft_spc;
	  instr_aft_spc[3]<=instr3_aft_spc;
	  instr_aft_spc[4]<=instr4_aft_spc;
	  instr_aft_spc[5]<=instr5_aft_spc;
	  instr_aft_spc[6]<=instr6_aft_spc;
	  instr_aft_spc[7]<=instr7_aft_spc;
	  instr_aft_spc[8]<=instr8_aft_spc;
	  instr_aft_spc[9]<=instr9_aft_spc;

	  jump0TbufWay_reg<=jump0TbufWay;
          jump0JmpInd_reg<=jump0JmpInd;
          jump0GHT_reg<=jump0GHT;
          jump0GHT2_reg<=jump0GHT2;
          jump0Val_reg<=jump0Val;
          jump1TbufWay_reg<=jump1TbufWay;
          jump1JmpInd_reg<=jump1JmpInd;
          jump1GHT_reg<=jump1GHT;
          jump1GHT2_reg<=jump1GHT2;
          jump1Val_reg<=jump1Val;
          jump0SC_reg<=jump0SC;
          jump0Miss_reg<=jump0Miss;
          jump0TbufOnly_reg<=jump0TbufOnly;
          jump1SC_reg<=jump1SC;
          jump1Miss_reg<=jump1Miss;
          jump1TbufOnly_reg<=jump1TbufOnly;
	  jump0Type_reg<=jump0Type;
	  jump0Pos_reg<=jump0Pos;
	  jump0Pred_reg<=jump0Pred;
	  jump0IP_reg<=jump0IP;
	  jump0Attr_reg<=jump0Attr;
          jump0Mask_reg<=jump0Mask;
	  jump0Attr_reg<=jump0Attr;
	  jump1Type_reg<=jump1Type;
	  jump1Pos_reg<=jump1Pos;
	  jump1Pred_reg<=jump1Pred;
	  jump1IP_reg<=jump1IP;
	  jump1Attr_reg<=jump1Attr;
          jump1Mask_reg<=jump1Mask;
	  jump1Attr_reg<=jump1Attr;
          instr_fsimd_reg<=instr_fsimd;
	  baseIP_reg<=baseIP;
          
	  jump0TbufWay_reg2<=jump0TbufWay_reg;
          jump0JmpInd_reg2<=jump0JmpInd_reg;
          jump0GHT_reg2<=jump0GHT_reg;
          jump0GHT2_reg2<=jump0GHT2_reg;
          jump0Val_reg2<=jump0Val_reg;
          jump1TbufWay_reg2<=jump1TbufWay_reg;
          jump1JmpInd_reg2<=jump1JmpInd_reg;
          jump1GHT_reg2<=jump1GHT_reg;
          jump1GHT2_reg2<=jump1GHT2_reg;
          jump1Val_reg2<=jump1Val_reg;
          jump0SC_reg2<=jump0SC_reg;
          jump0Miss_reg2<=jump0Miss_reg;
          jump0TbufOnly_reg2<=jump0TbufOnly_reg;
          jump1SC_reg2<=jump1SC_reg;
          jump1Miss_reg2<=jump1Miss_reg;
          jump1TbufOnly_reg2<=jump1TbufOnly_reg;
	  jump0Type_reg2<=jump0Type_reg;
	  jump0Pos_reg2<=jump0Pos_reg;
	  jump0Pred_reg2<=jump0Pred_reg;
	  jump0IP_reg2<=jump0IP_reg;
	  jump0Attr_reg2<=jump0Attr_reg;
          jump0Mask_reg2<=jump0Mask_reg;
	  jump0Attr_reg2<=jump0Attr_reg;
	  jump1Type_reg2<=jump1Type_reg;
	  jump1Pos_reg2<=jump1Pos_reg;
	  jump1Pred_reg2<=jump1Pred_reg;
	  jump1IP_reg2<=jump1IP_reg;
	  jump1Attr_reg2<=jump1Attr_reg;
          jump1Mask_reg2<=jump1Mask_reg;
	  jump1Attr_reg2<=jump1Attr_reg;
          instr_fsimd_reg2<=instr_fsimd_reg;
     
          wrt0_reg<=wrt0;
          wrt1_reg<=wrt1;
          wrt2_reg<=wrt2;
          
          wrtO0_reg<=wrtO0;
          wrtO1_reg<=wrtO1;
          wrtO2_reg<=wrtO2;
          wrtII0_reg<=wrtII0;
          wrtII1_reg<=wrtII1;
          wrtII2_reg<=wrtII2;
          WQR_reg[0]<=WQR[0];
          WQR_reg[1]<=WQR[1];
          WQR_reg[2]<=WQR[2];
          WQS_reg[0]<=WQS[0];
          WQS_reg[1]<=WQS[1];
          WQS_reg[2]<=WQS[2];
 
          lsi_cnt_reg<=lsi_cnt[5:0];
 
          ldq_new_mask_reg<=ldq_new_mask;
          LSQ_lsqA_reg<=LSQ_lsqA;
          LSQ_lsqB_reg<=LSQ_lsqB;
          LSQ_indA_reg<=LSQ_indA;
          LSQ_indB_reg<=LSQ_indB;
          LSQ_wqA_reg<=LSQ_wqA;
          LSQ_wqB_reg<=LSQ_wqB;
          Wswp_reg<=Wswp;
          WopA_reg<=WopA;
          WopB_reg<=WopB;
          for(k=0;k<9;k=k+1) begin
              clrR_reg[k]<=clrR[k];
              clrRS_reg[k]<=clrRS[k];
              rs_const_reg[k]<=rs_const[k];
              rs_index_reg[k]<=rs_index[k];
              rs_operation_reg[k]<=rs_operation[k];
              rs_operation_reg2[k]<=rs_operation_reg[k];
              rs_xport[k]<=1'b0;
              if (rs_port[k]==PORT_LOAD || rs_port[k]==PORT_STORE) rs_port_sch[k]<=4'd0;
              else if (k%3==1) rs_port_sch[k]<=4'd1;
              else rs_port_sch[k]<=4'd2;
              if (rs_port[k]==PORT_SHIFT || rs_port[k]==PORT_MUL) rs_port_sch[k]<=4'd2;
              if (rs_port[k]==PORT_FADD) begin rs_port_sch[k]<=4'b1001; rs_xport[k]<=1'b1; end
              if (rs_port[k]==PORT_FMUL) rs_port_sch[k]<=4'b1010;
              if (rs_port[k]==PORT_FANY) rs_port_sch[k]<=5'b1011;
              if (rs_port[k]==PORT_VADD) begin rs_port_sch[k]<=4'b101; rs_xport[k]<=1'b1; end
              if (rs_port[k]==PORT_VCMP) rs_port_sch[k]<=4'b110;
              if (rs_port[k]==PORT_VANY) rs_port_sch[k]<=4'b111;
              if (rs_port[k]==PORT_ALU && (rs_port[(k/3)*3+2]==PORT_VADD || rs_port[(k/3)*3+2]==PORT_FADD))
                 rs_port_sch[k]<=4'd2;             
              if (rs_port[k]==PORT_ALU && rs_operation[k][7:0]==`op_cax)
                 rs_port_sch[k]<=4'd1;
              
              rs_port_reg[k]<=rs_port[k];
              
              regA_reg[k]<=(rs_rA_use[k] ? regA[k] : regAF[k])|{REG_WIDTH{~rs_rA_use[k]&~rs_rA_useF[k]}};
              regB_reg[k]<=(rs_rB_use[k] ? regB[k] : regBF[k])|{REG_WIDTH{~rs_rB_use[k]&~rs_rB_useF[k]||rs_useBConst[k]}};
	      if (rs_rA_useF[k]) regAF_reg[k]<=regAF[k];
	      if (rs_rB_useF[k]) regBF_reg[k]<=regBF[k];
	      regAF_reg2[k]<=regAF_reg[k];
	      regBF_reg2[k]<=regBF_reg[k];
	      retAF_reg[k]<=retAF[k];
	      retBF_reg[k]<=retBF[k];
	      retAF_reg2[k]<=retAF_reg[k];
	      retBF_reg2[k]<=retBF_reg[k];
              regS_reg[k]<=regS[k];
              newR_reg[k]<=newR[k];
              if (k<9 &&  instr_aft_spc_reg[rs_index_reg[k+1][3:0]]) begin
                  if (rs_index_reg[1][3:0]==(k+1)) newR_reg=newR[1];
                  if (rs_index_reg[2][3:0]==(k+1)) newR_reg=newR[2];
                  if (rs_index_reg[3+1][3:0]==(k+1)) newR_reg=newR[3+1];
                  if (rs_index_reg[3+2][3:0]==(k+1)) newR_reg=newR[3+2];
                  if (rs_index_reg[6+1][3:0]==(k+1)) newR_reg=newR[6+1];
                  if (rs_index_reg[6+2][3:0]==(k+1)) newR_reg=newR[6+2];
              end
              newRF_reg[k]<=newRF[k];
              rs_en_reg[k]<=rs_en[k];
              funA_reg[k]<=rs_rA_useF[k] ? funAF[k] : funA[k];
              funB_reg[k]<=rs_rB_useF[k] ? funBF[k] : funB[k];
              funS_reg[k]<=funS[k];
              rs_lsi_reg[k]<=get_lsi(rs_lsi[k]);
              domA_reg[k]<=domA[k];
              domB_reg[k]<=domB[k];
              instr_ret_reg[k]<=instr_ret[k];
          end
	  for(t=0;t<3;t=t+1) begin
              rrfAW_reg[t]<=rrfAW[t];
              rrfBW_reg[t]<=rrfBW[t];
              rrfAW_reg2[t]<=rrfAW_reg[t];
              rrfBW_reg2[t]<=rrfBW_reg[t];
              regAW_reg[t]<=(rs_rAW_use[t] ? regAW[t] : regAWF[t])|{REG_WIDTH{~rs_rAW_use[t]&~rs_rAW_useF[t]||useAConstW[t]}};
              regBW_reg[t]<=(rs_rBW_use[t] ? regBW[t] : regBFW[t])|{REG_WIDTH{~rs_rBW_use[t]&~rs_rBW_useF[t]||useBConstW[t]}};
              regAW_reg[t]<=regAW[t];
              regBW_reg[t]<=regBW[t];
              regAWF_reg[t]<=regAWF[t];
              regBFW_reg[t]<=regBFW[t];
              regAWF_reg2[t]<=regAWF_reg[t];
              regBFW_reg2[t]<=regBFW_reg[t];
	      retAWF_reg[t]<=retAWF[t];
	      retBFW_reg[t]<=retBFW[t];
	      retAWF_reg2[t]<=retAWF_reg[t];
	      retBFW_reg2[t]<=retBFW_reg[t];
	      isAWF_reg[t]<=isAWF[t];
	      isBFW_reg[t]<=isBFW[t];
	      isAWV_reg[t]<=isAWV[t];
          isBVW_reg[t]<=isBVW[t];
	      rs_rAW_useF_reg[t]<=rs_rAW_useF[t];
	      rs_rBW_useF_reg[t]<=rs_rBW_useF[t];
	      rs_rAW_useF_reg2[t]<=rs_rAW_useF_reg[t];
	      rs_rBW_useF_reg2[t]<=rs_rBW_useF_reg[t];
	      Wport_reg[t]<=Wport[t];
	  end
	  for(t=0;t<10;t=t+1) begin
              instr_err_reg[t]<=instr_err;
	      instr_rT_reg[t]<=instr_rT[t];
              instr_en_reg[t]<=instr_en[t];
              instr_wren_reg[t]<=instr_wren[t];
              instr_IPOff_reg[t]<=instr_IPOff[t];
              instr_afterTaken_reg[t]<=instr_afterTaken[t];
              instr_rT_useF_reg[t]<=instr_rT_useF[t];
              instr_rT_isV_reg[t]<=instr_rT_isV[t];
              instr_port_reg[t]<=instr_port[t];
              //instr_magic_reg[t]<=instr_magic[t];
              instr_last_reg[t]<=instr_last[t];
	      instr_aft_spc_reg[t]<=instr_aft_spc[t];
	      casex(instr_magic[t])
		  4'bxxx0: instr_magicOff[t]<=3'd1;
		  4'bxx01: instr_magicOff[t]<=3'd2;
		  4'bx011: instr_magicOff[t]<=3'd3;
		  4'b0111: instr_magicOff[t]<=3'd4;
		  4'b1111: instr_magicOff[t]<=3'd5;
	      endcase
	      casex({instr_rT_useF[t],instr_rT_isV[t],instr_port[t]==PORT_LOAD})
		  3'b0xx: begin instr_gen[t]<=1'b1; instr_vec[t]<=1'b0; end
		  3'b100: begin instr_gen[t]<=1'b0; instr_vec[t]<=1'b0; end
		  3'b110: begin instr_gen[t]<=1'b0; instr_vec[t]<=1'b1; end
		  3'b1x1: begin instr_gen[t]<=1'b1; instr_vec[t]<=1'b1; end
	      endcase
	  end
	  
      end
      if (except) begin
          if ((~doStall)||(doStall)) begin
              bundle_in_reg<=1'b0;
              rs_en[0]<=1'b0;            
              rs_en[1]<=1'b0;            
              rs_en[2]<=1'b0;            
              rs_en[3]<=1'b0;            
              rs_en[4]<=1'b0;            
              rs_en[5]<=1'b0;            
              rs_en[6]<=1'b0;            
              rs_en[7]<=1'b0;            
              rs_en[8]<=1'b0;            
              
              rs0i0_alloc_reg<=1'b0;
              rs0i1_alloc_reg<=1'b0;
              rs0i2_alloc_reg<=1'b0;
              rs1i0_alloc_reg<=1'b0;
              rs1i1_alloc_reg<=1'b0;
              rs1i2_alloc_reg<=1'b0;
              rs2i0_alloc_reg<=1'b0;
              rs2i1_alloc_reg<=1'b0;
              rs2i2_alloc_reg<=1'b0;
    
              rs0i0_allocF_reg<=1'b0;
              rs0i1_allocF_reg<=1'b0;
              rs0i2_allocF_reg<=1'b0;
              rs1i0_allocF_reg<=1'b0;
              rs1i1_allocF_reg<=1'b0;
              rs1i2_allocF_reg<=1'b0;
              rs2i0_allocF_reg<=1'b0;
              rs2i1_allocF_reg<=1'b0;
              rs2i2_allocF_reg<=1'b0;
    
              rs0i0_allocR_reg<=1'b0;
              rs0i1_allocR_reg<=1'b0;
              rs0i2_allocR_reg<=1'b0;
              rs1i0_allocR_reg<=1'b0;
              rs1i1_allocR_reg<=1'b0;
              rs1i2_allocR_reg<=1'b0;
              rs2i0_allocR_reg<=1'b0;
              rs2i1_allocR_reg<=1'b0;
              rs2i2_allocR_reg<=1'b0;
              
              rs_rT_use<=9'b0;
              rs_rT_useF<=9'b0;
          end
          if (( ~doStall) || (doStall)) begin
              bundle_in_reg2<=1'b0;
              rs_en_reg[0]<=1'b0;
              rs_en_reg[1]<=1'b0;
              rs_en_reg[2]<=1'b0;
              rs_en_reg[3]<=1'b0;
              rs_en_reg[4]<=1'b0;
              rs_en_reg[5]<=1'b0;
              rs_en_reg[6]<=1'b0;
              rs_en_reg[7]<=1'b0;
              rs_en_reg[8]<=1'b0;
              ldq_new_mask_reg<=6'b0;
          end
      end

      if (rst) begin
           lsr_wr_out_data<=0;
           p_out_LSQ<=0; 
           dc_out_wrEn<=0;
           pfyWQ<=0;
           pfy_wdata<=0;
           pfy_wdataU<=0;
           pfy_pdata<=0;
           pfy_dataEn<=0;
      end else begin
           lsr_wr_out_data<=lsr_wr_data[H];
           p_out_LSQ<=p_LSQ[H];
           dc_out_wrEn<=dc_rwEn[H];
           pfyWQ<=outWDFxWQ_reg3[H];
           pfy_wdata<=lsw_wdata[H];
           pfy_wdataU<=lsw_wdataU[H];
           pfy_pdata<=lsw_pdata[H];
           pfy_dataEn<=outWDFxDataEn_reg3[H];
      end
      if (rst) begin
	  for(k=0;k<4;k=k+1) begin
	      fxLD_dbl[k]=1'b1;
	      fxLD_ext[k]=1'b0;
	      fxLD_dblext[k]=1'b1;
	      fxLD_sin[k]=1'b0;
	      fxLD_dbl_t[k]=1'b1;
	      fxLD_ext_t[k]=1'b0;
	      fxLD_sngl_t[k]=1'b0;
	      fxLD_spair_t[k]=1'b0;
	      fxLD_dbl_reg[k]=1'b1;
	      fxLD_ext_reg[k]=1'b0;
	      fxLD_dblext_reg[k]=1'b1;
	      fxLD_sin_reg[k]=1'b0;
	      fxLD_dbl_t_reg[k]=1'b1;
	      fxLD_ext_t_reg[k]=1'b0;
	      fxLD_sngl_t_reg[k]=1'b0;
	      fxLD_spair_t[k]=1'b0;
	      if (k!=3) fxFRT_alten_reg[k]<=4'b0;
	      if (k!=3) fxFRT_alten_reg2[k]<=4'b0;
	      if (k!=3) fxFRT_alten_reg3[k]<=4'b0;
	  end
      end else begin
	  for(k=0;k<4;k=k+1) if (!rsDoStall[k]) begin
	      fxLD_dbl[k]=1'b0;
	      fxLD_ext[k]=1'b0;
	      fxLD_sin[k]=1'b0;
	      fxLD_dbl_t[k]=1'b0;
	      fxLD_ext_t[k]=1'b0;
	      fxLD_sngl_t[k]=1'b0;
	      fxLD_spair_t[k]=1'b0;
	      case(outOp_reg2[k][5:1])
		  4,5,6,2,5'he,5'hb: fxLD_sin[k]=1'b1;
		  3: fxLD_ext[k]=1'b1;
		  default: fxLD_dbl[k]=1'b1;
	      endcase
	      case(outOp_reg2[k][5:1])
                  2,5'he,5: fxLD_sngl_t[k]=1'b1;
		  3,4,8: fxLD_ext_t[k]=1'b1;
		  0,12,7: ;
		  default: fxLD_dbl_t[k]=1'b1; 
	      endcase
	      fxLD_spair_t[k]=outOp_reg2[k][5:1]==5'ha;
	      fxLD_dblext[k]=fxLD_dbl[k]|fxLD_ext[k];
	      if (k!=3) fxFRT_alten_reg[k]<=fxFRT_alten[k];
	      if (k!=3) fxFRT_alten_reg2[k]<=fxFRT_alten_reg[k];
	      if (k!=3) fxFRT_alten_reg3[k]<=fxFRT_alten_reg2[k];
	      fxLD_dbl_reg[k]=fxLD_dbl[k];
	      fxLD_ext_reg[k]=fxLD_ext[k];
	      fxLD_sin_reg[k]=fxLD_sin[k];
	      fxLD_dbl_t_reg[k]=fxLD_dbl_t[k];
	      fxLD_ext_t_reg[k]=fxLD_ext_t[k];
	      fxLD_sngl_t_reg[k]=~fxLD_dbl_t[k]&~fxLD_ext_t[k];
	      fxLD_spair_t_reg[k]=fxLD_spair_t[k];
	  end
      end
      if (rst) begin
          for (k=0;k<9;k=k+1) begin
              outReg_reg[k]<={REG_WIDTH{1'B0}};
              outReg_reg2[k]<={REG_WIDTH{1'B0}};
              outReg_reg3[k]<={REG_WIDTH{1'B0}};
              outOp_reg[k]<={OPERATION_WIDTH{1'B0}};
              outOp_reg2[k]<={OPERATION_WIDTH{1'B0}};
              outOp_reg3[k]<={OPERATION_WIDTH{1'B0}};
              outOp_reg4[k]<={OPERATION_WIDTH{1'B0}};
              outOp_reg5[k]<={OPERATION_WIDTH{1'B0}};
              outOp_reg6[k]<={OPERATION_WIDTH{1'B0}};
              outOp_reg7[k]<={OPERATION_WIDTH{1'B0}};
              outOp_reg8[k]<={OPERATION_WIDTH{1'B0}};
              outXAM_reg[k]<=1'b0;
              outXAM_reg2[k]<=1'b0;
              outII_reg[k]<=10'b0;
              outII_reg2[k]<=10'b0;
              outII_reg3[k]<=10'b0;
              outII_reg4[k]<=10'b0;
              outII_reg5[k]<=10'b0;
              outII_reg6[k]<=10'b0;
              outII_reg7[k]<=10'b0;
              outII_reg8[k]<=10'b0;
              outII_reg9[k]<=10'b0;
              outII_reg10[k]<=10'b0;
              outII_reg11[k]<=10'b0;
              outEn_reg[k]<=4'b0;
              outEn_reg2[k]<=4'b0;
              outEn_reg3[k]<=4'b0;
              outEn_reg4[k]<=4'b0;
              outEn_reg5[k]<=4'b0;
              outEn_reg6[k]<=4'b0;
              outEn_reg7[k]<=4'b0;
              outEn_reg8[k]<=4'b0;
              outThr_reg[k]<=1'b0;
          end
          for (k=0;k<6;k=k+1) begin
	      FUS_alu_reg[k]<=6'b0;
	      ex_alu_reg[k]<=3'b0;
	      enS_alu_reg[k]<=1'b0;
	      FUS_alu_reg2[k]<=6'b0;
	      ex_alu_reg2[k]<=3'b0;
	      enS_alu_reg2[k]<=1'b0;
	      FUS_alu_reg3[k]<=6'b0;
	      ex_alu_reg3[k]<=3'b0;
	      enS_alu_reg3[k]<=1'b0;
	      FUS_alu_reg4[k]<=6'b0;
	      ex_alu_reg4[k]<=3'b0;
	      enS_alu_reg4[k]<=1'b0;
	      FUS_alu_reg5[k]<=6'b0;
	      ex_alu_reg5[k]<=3'b0;
	      enS_alu_reg5[k]<=1'b0;
	      FUS_alu_reg6[k]<=6'b0;
	      ex_alu_reg6[k]<=3'b0;
	      enS_alu_reg6[k]<=1'b0;
          end
         /* fxAlt1_reg<=1'b0;
          fxAlt2_reg<=1'b0;
          fxAlt1_reg2<=1'b0;
          fxAlt2_reg2<=1'b0;
          fxAlt1_reg3<=1'b0;
          fxAlt2_reg3<=1'b0;*/
	  outEnX_reg<=4'b0;
	  outIIX_reg<=10'hf;
	  outOpX_reg<=18'b0;
	  outRegX_reg<=9'b0;
	  outRegSX_reg<=9'b0;
          outDataAVH_reg<={SIMD_WIDTH{1'b0}};
          outDataBVH_reg<={SIMD_WIDTH{1'b0}};
          outDataAVL_reg<={SIMD_WIDTH{1'b0}};
          outDataBVL_reg<={SIMD_WIDTH{1'b0}};
          outDataAFH_reg<={SIMD_WIDTH{1'b0}};
          outDataBFH_reg<={SIMD_WIDTH{1'b0}};
          outDataAFL_reg<={16+SIMD_WIDTH{1'b0}};
          outDataBFL_reg<={16+SIMD_WIDTH{1'b0}};
      end else begin
          for (k=0;k<9;k=k+1) if (k>3 || !rsDoStall[k]) begin
              outReg_reg[k]<=outReg[k];
              outReg_reg2[k]<=outReg_reg[k];
              outReg_reg3[k]<=outReg_reg2[k];
              outOp_reg[k]<=outOp[k];
              outOp_reg2[k]<=outOp_reg[k];
              outXAM_reg[k]<=outXAM[k];
              outOp_reg3[k]<=outOp_reg2[k];
              outOp_reg4[k]<=outOp_reg3[k];
              outOp_reg5[k]<=outOp_reg4[k];
              outOp_reg6[k]<=outOp_reg5[k];
              outOp_reg7[k]<=outOp_reg6[k];
              outOp_reg8[k]<=outOp_reg7[k];
              outXAM_reg2[k]<=outXAM_reg[k];
              outII_reg[k]<=outII[k];
              outII_reg2[k]<=outII_reg[k];
              outII_reg3[k]<=outII_reg2[k];
              outII_reg4[k]<=outII_reg3[k];
              outII_reg5[k]<=outII_reg4[k];
              outII_reg6[k]<=outII_reg5[k];
              outII_reg7[k]<=outII_reg6[k];
              outII_reg8[k]<=outII_reg7[k];
              outII_reg9[k]<=outII_reg8[k];
              outII_reg10[k]<=outII_reg9[k];
              outII_reg11[k]<=outII_reg10[k];
              outEn_reg[k]<=outEn[k];
              outEn_reg2[k]<=outEn_reg[k];
              outEn_reg3[k]<=outEn_reg2[k];
              outEn_reg4[k]<=outEn_reg3[k];
              outEn_reg5[k]<=outEn_reg4[k];
              outEn_reg6[k]<=outEn_reg5[k];
              outEn_reg7[k]<=outEn_reg6[k];
              outEn_reg8[k]<=outEn_reg7[k];
              outThr_reg[k]<=outThr[k];
          end
          for (k=0;k<6;k=k+1) begin
	      FUS_alu_reg[k]<=FUS_alu[k];
	      ex_alu_reg[k]<=ex_alu[k]&{3{enS_alu[k]}};
	      enS_alu_reg[k]<=enS_alu[k]&~fret_en[k];
	      FUS_alu_reg2[k]<=FUS_alu_reg[k];
	      ex_alu_reg2[k]<=ex_alu_reg[k]&{3{~enS_alu_reg[k]}};
	      enS_alu_reg2[k]<=enS_alu_reg[k];
	      FUS_alu_reg3[k]<=FUS_alu_reg2[k];
	      ex_alu_reg3[k]<=ex_alu_reg2[k];
	      enS_alu_reg3[k]<=enS_alu_reg2[k];
	      FUS_alu_reg4[k]<=FUS_alu_reg3[k];
	      ex_alu_reg4[k]<=ex_alu_reg3[k];
	      enS_alu_reg4[k]<=enS_alu_reg3[k];
	      FUS_alu_reg5[k]<=FUS_alu_reg4[k];
	      ex_alu_reg5[k]<=ex_alu_reg4[k];
	      enS_alu_reg5[k]<=enS_alu_reg4[k];
	      FUS_alu_reg6[k]<=FUS_alu_reg5[k];
	      ex_alu_reg6[k]<=ex_alu_reg5[k];
	      enS_alu_reg6[k]<=enS_alu_reg5[k];
          end
          outDataAVH_reg<=outDataAVH[5];
          outDataBVH_reg<=outDataBVH[5];
          outDataAVL_reg<=outDataAVL[5];
          outDataBVL_reg<=outDataBVL[5];
          outDataAFH_reg<=outDataAFH[5];
          outDataBFH_reg<=outDataBFH[5];
          outDataAFL_reg<=outDataAFL[5];
          outDataBFL_reg<=outDataBFL[5];
    
      end
      
      if (rst) begin
          bus_holds_addrcalc<=1'b0;
          bus_holds_addrcalc_reg<=1'b0;
          bus_holds_addrcalc_reg2<=1'b0;
          bus_holds_addrcalc_reg3<=1'b0;
          bus_holds_addrcalc_reg4<=1'b0;
          bus_holds_addrcalc_reg5<=1'b0;
          miss_holds_addrcalc_reg<=1'b0;
          miss_holds_addrcalc_reg2<=1'b0;
          miss_pause_addrcalc_reg<=1'b0;
          miss_pause_addrcalc_reg2<=1'b0;
          insert_isData_reg<=1'b0;
          insert_isData_reg2<=1'b0;
          insert_isData_reg3<=1'b0;
          insert_isData_reg4<=1'b0;
          insert_isData_reg5<=1'b0;
          insert_isData_reg6<=1'b0;
          insert_isData_reg7<=1'b0;
          insert_isData_reg8<=1'b0;
          insBus_exclusive_reg<=1'b0;
          insBus_exclusive_reg2<=1'b0;
          insBus_exclusive_reg3<=1'b0;
          insBus_dirty_reg<=1'b0;
          insBus_dirty_reg2<=1'b0;
          insBus_dirty_reg3<=1'b0;
          insBus_io_reg<=1'b0;
          insBus_io_reg2<=1'b0;
          insBus_io_reg3<=1'b0;
          insBus_data_reg<={BUS_WIDTH{1'B0}};
          insBus_data_reg2<={BUS_WIDTH{1'B0}};
          insert_addr_reg<=37'b0;
          insert_addr_reg2<=37'b0;
          insert_addr_reg3<=37'b0;
          insBus_req_reg<={REQ_WIDTH{1'B0}};
          dc_rdEn_reg<=4'b0;
          dc_rdEn_reg2<=4'b0;
          dc_rdEn_reg3<=4'b0;
          dc_wrEn_reg<=2'b0;
          dc_wrEn_reg2<=2'b0;
          dc_wrEn_reg3<=2'b0;
	  dc_rdReg_reg[0]<=9'b0;
	  dc_rdReg_reg[1]<=9'b0;
	  dc_rdReg_reg[2]<=9'b0;
	  dc_rdReg_reg[3]<=9'b0;
          wrStall_reg<=1'b0;
	  p3_data_reg<=136'b0;
	  p3_data_reg2<=136'b0;
	  p2_ret_reg<=14'b0;
	  p2_ret_reg2<=14'b0;
	  p3_ret_reg<=14'b0;
	  p3_ret_reg2<=14'b0;
	  lsr3_II_reg<=10'b0;
	  lsr3_II_reg2<=10'b0;
	  lsr2_II_reg<=10'b0;
	  lsr2_II_reg2<=10'b0;
	  p_lsfwd_reg<=4'b0;
	  p_lsfwd_reg2<=4'b0;
	  p2_brdbanks_reg<=5'b0;
	  p2_brdbanks_reg2<=5'b0;
	  p3_brdbanks_reg<=5'b0;
	  p3_brdbanks_reg2<=5'b0;
	  p2_pdata_reg<=2'b0;
	  p2_pdata_reg2<=2'b0;
	  p3_pdata_reg<=2'b0;
	  p3_pdata_reg2<=2'b0;

	  st0_en_reg<=1'b0;
	  st0_en_reg2<=1'b0;
	  st0_en_reg3<=1'b0;
	  st0_type_reg<=2'b0;
	  st0_type_reg2<=2'b0;
	  st0_type_reg3<=2'b0;
	  st0_II_reg<=10'b0;
	  st0_II_reg2<=10'b0;
	  st0_II_reg3<=10'b0;
	  st1_en_reg<=1'b0;
	  st1_en_reg2<=1'b0;
	  st1_en_reg3<=1'b0;
	  st1_type_reg<=2'b0;
	  st1_type_reg2<=2'b0;
	  st1_type_reg3<=2'b0;
	  st1_II_reg<=10'b0;
	  st1_II_reg2<=10'b0;
	  st1_II_reg3<=10'b0;
          MSI_exp_addr_reg<=37'b0;
          MSI_exp_en_reg<=1'b0;
          MSI_exp_mkshared<=1'b0;
          MSI_swap_want_reg<=1'b0;
          MSI_swap_repl_reg<=1'b0;
          MSI_exp_addr_save[0]<=37'b0;
          MSI_exp_en_save[0]<=1'b0;
          MSI_swap_want_save[0]<=1'b0;
          MSI_swap_repl_save[0]<=1'b0;
          MSI_exp_addr_save[1]<=37'b0;
          MSI_exp_en_save[1]<=1'b0;
          MSI_swap_want_save[1]<=1'b0;
          MSI_swap_repl_save[1]<=1'b0;
          MSI_lock[0]<=37'b0;
          MSI_lock_cnt[0]<=14'b0;
          MSI_locked[0]<=1'b0;
          MSI_lock[1]<=37'b0;
          MSI_lock_cnt[1]<=14'b0;
          MSI_locked[1]<=1'b0;
	  fret_reg[0]<=14'b0;
	  fret_reg[1]<=14'b0;
	  fret_reg[2]<=14'b0;
	  fret_reg[3]<=14'b0;
	  fret_reg[4]<=14'b0;
	  fret_reg[5]<=14'b0;
	  sqrDatFL_reg<=0;
	  sqrDatVL_reg<=0;
	  sqrDatEn_reg<=1'b0;
      end else begin
          bus_holds_addrcalc<=insert_isData;
          bus_holds_addrcalc_reg<=bus_holds_addrcalc;
          bus_holds_addrcalc_reg2<=bus_holds_addrcalc_reg;
          bus_holds_addrcalc_reg3<=bus_holds_addrcalc_reg2;
          bus_holds_addrcalc_reg4<=bus_holds_addrcalc_reg3;
          bus_holds_addrcalc_reg5<=bus_holds_addrcalc_reg4;
          miss_holds_addrcalc_reg<=miss_holds_addrcalc;
          miss_holds_addrcalc_reg2<=miss_holds_addrcalc_reg;
          miss_pause_addrcalc_reg<=miss_pause_addrcalc;
          miss_pause_addrcalc_reg2<=miss_pause_addrcalc_reg;
          insert_isData_reg<=insert_isData;
          insert_isData_reg2<=insert_isData_reg;
          insert_isData_reg3<=insert_isData_reg2;
          insert_isData_reg4<=insert_isData_reg3;
          insert_isData_reg5<=insert_isData_reg4;
          insert_isData_reg6<=insert_isData_reg5;
          insert_isData_reg7<=insert_isData_reg6;
          insert_isData_reg8<=insert_isData_reg7;
          insBus_exclusive_reg<=insBus_exclusive;
          insBus_exclusive_reg2<=insBus_exclusive_reg;
          insBus_exclusive_reg3<=insBus_exclusive_reg2;
          insBus_dirty_reg<=insBus_dirty;
          insBus_dirty_reg2<=insBus_dirty_reg;
          insBus_dirty_reg3<=insBus_dirty_reg2;
          insBus_io_reg<=insBus_io;
          insBus_io_reg2<=insBus_io_reg;
          insBus_io_reg3<=insBus_io_reg2;
          insBus_data_reg<=insBus_data;
          insBus_data_reg2<=insBus_data_reg;
          insert_addr_reg<=insert_addr;
          insert_addr_reg2<=insert_addr_reg;
          insert_addr_reg3<=insert_addr_reg2;
          insBus_req_reg<=insBus_req;
          if (except) dc_rdEn_reg[0]<=1'b0;
          else dc_rdEn_reg[0]<=dc_rdEn[0];
          if (except) dc_rdEn_reg[1]<=1'b0;
          else dc_rdEn_reg[1]<=dc_rdEn[1];
          if (except) dc_rdEn_reg[2]<=1'b0;
          else dc_rdEn_reg[2]<=dc_rdEn[2];
          if (except) dc_rdEn_reg[3]<=1'b0;
          else dc_rdEn_reg[3]<=dc_rdEn[3];

          if (except) dc_rdEn_reg2[0]<=1'b0;
          else dc_rdEn_reg2[0]<=dc_rdEn_reg[0];
          if (except) dc_rdEn_reg2[1]<=1'b0;
          else dc_rdEn_reg2[1]<=dc_rdEn_reg[1];
          if (except) dc_rdEn_reg2[2]<=1'b0;
          else dc_rdEn_reg2[2]<=dc_rdEn_reg[2];
          if (except) dc_rdEn_reg2[3]<=1'b0;
          else dc_rdEn_reg2[3]<=dc_rdEn_reg[3];
          
          if (except) dc_rdEn_reg3[0]<=1'b0;
          else dc_rdEn_reg3[0]<=dc_rdEn_reg2[0];
          if (except) dc_rdEn_reg3[1]<=1'b0;
          else dc_rdEn_reg3[1]<=dc_rdEn_reg2[1];
          if (except) dc_rdEn_reg3[2]<=1'b0;
          else dc_rdEn_reg3[2]<=dc_rdEn_reg2[2];
          if (except) dc_rdEn_reg3[3]<=1'b0;
          else dc_rdEn_reg3[3]<=dc_rdEn_reg2[3];
	  dc_rdReg_reg[0]<={lsr_wr_data[0][`lsaddr_reg_hi],lsr_wr_data[0][`lsaddr_reg_low]};
	  dc_rdReg_reg[1]<={lsr_wr_data[1][`lsaddr_reg_hi],lsr_wr_data[1][`lsaddr_reg_low]};
	  dc_rdReg_reg[2]<={lsr_wr_data[2][`lsaddr_reg_hi],lsr_wr_data[2][`lsaddr_reg_low]};
	  dc_rdReg_reg[3]<={lsr_wr_data[3][`lsaddr_reg_hi],lsr_wr_data[3][`lsaddr_reg_low]};
        
          dc_wrEn_reg<=dc_wrEn;
          dc_wrEn_reg2<=dc_wrEn_reg;
          dc_wrEn_reg3<=dc_wrEn_reg2;
          wrStall_reg<=wrStall;
	  p3_data_reg<=p3_data;
	  p3_data_reg2<=insBus_io_reg2 ? insBus_data_reg2[135:0] : p3_data_reg;
	  if (p_lsfwd[0]) p2_ret_reg<=p_ret[0];
	  if (p_lsfwd[1]) p2_ret_reg<=p_ret[1];
	  if (p_lsfwd[2]) p2_ret_reg<=p_ret[2];
	  p2_ret_reg2<=p2_ret_reg;
	  p3_ret_reg<=p_ret[3];
	  p3_ret_reg2<=p3_ret_reg;
	  lsr3_II_reg<=lsr_wr_data[3][`lsaddr_II];
	  lsr3_II_reg2<=lsr3_II_reg;
	  if (p_lsfwd[0]) lsr2_II_reg<=lsr_wr_data[0][`lsaddr_II];
	  if (p_lsfwd[1]) lsr2_II_reg<=lsr_wr_data[1][`lsaddr_II];
	  if (p_lsfwd[2]) lsr2_II_reg<=lsr_wr_data[2][`lsaddr_II];
	  lsr2_II_reg2<=lsr2_II_reg;
	  p_lsfwd_reg<=p_lsfwd;
	  p_lsfwd_reg2<=p_lsfwd_reg;
	  p2_brdbanks_reg<=p2_brdbanks;
	  p2_brdbanks_reg2<=p2_brdbanks_reg;
	  p3_brdbanks_reg<=p3_brdbanks;
	  p3_brdbanks_reg2<=p3_brdbanks_reg;
	  p2_pdata_reg<=p2_pdata;
	  p2_pdata_reg2<=p2_pdata_reg;
	  p3_pdata_reg<=p3_pdata;
	  p3_pdata_reg2<=p3_pdata_reg;
          p3_pfx_reg<=p3_pfx;
          p3_pfx_reg2<=p3_pfx_reg;
	  st0_en_reg<=st0_en;
	  st0_en_reg2<=st0_en_reg;
	  st0_en_reg3<=st0_en_reg2;
	  st0_type_reg<=st0_adata[`lsaddr_mtype];
	  st0_type_reg2<=st0_type_reg;
	  st0_type_reg3<=st0_type_reg2;
	  st0_II_reg<=st0_adata[`lsaddr_II];
	  st0_II_reg2<=st0_II_reg;
	  st0_II_reg3<=st0_II_reg2;
	  st1_en_reg<=st1_en;
	  st1_en_reg2<=st1_en_reg;
	  st1_en_reg3<=st1_en_reg2;
	  st1_type_reg<=st1_adata[`lsaddr_mtype];
	  st1_type_reg2<=st1_type_reg;
	  st1_type_reg3<=st1_type_reg2;
	  st1_II_reg<=st1_adata[`lsaddr_II];
	  st1_II_reg2<=st1_II_reg;
	  st1_II_reg3<=st1_II_reg2;
          if ((MSI_exp_addr!=MSI_lock[0] || ~MSI_lock_en[0]) && (MSI_exp_addr!=MSI_lock[1] || ~MSI_lock_en[1]) && MSI_exp_en) begin 
              MSI_exp_addr_reg<=MSI_exp_addr;
              MSI_exp_en_reg<=MSI_exp_en;
              MSI_swap_want_reg<=MSI_swap_want;
              MSI_swap_repl_reg<=MSI_swap_repl;
              MSI_exp_mkshared<=1'b0;
          end else if (!MSI_exp_en) begin
              MSI_exp_addr_reg<=MSI_exp_addr_save[~MSI_exp_en_save[0]];
              MSI_exp_en_reg<=MSI_exp_en_save[~MSI_exp_en_save[0]];
              MSI_swap_want_reg<=MSI_swap_want_save[~MSI_exp_en_save[0]];
              MSI_swap_repl_reg<=MSI_swap_repl_save[~MSI_exp_en_save[0]];
              MSI_exp_en_save[~MSI_exp_en_save[0]]<=1'b0;
              MSI_exp_mkshared<=1'b1;
          end else begin
              if ((MSI_exp_addr!=MSI_lock[0] || ~MSI_lock_en[0])) begin
                  MSI_exp_addr_save[0]<=MSI_exp_addr;
                  MSI_exp_en_save[0]<=MSI_exp_en;
                  MSI_swap_want_save[0]<=MSI_swap_want;
                  MSI_swap_repl_save[0]<=MSI_swap_repl;
              end
              if ((MSI_exp_addr!=MSI_lock[1] || ~MSI_lock_en[1])) begin
                  MSI_exp_addr_save[1]<=MSI_exp_addr;
                  MSI_exp_en_save[1]<=MSI_exp_en;
                  MSI_swap_want_save[1]<=MSI_swap_want;
                  MSI_swap_repl_save[1]<=MSI_swap_repl;
              end
              MSI_exp_en_reg<=1'b0;
              MSI_exp_mkshared<=1'b0;
          end
          if (&MSI_lock_cnt[0]) begin
              MSI_locked[0]=1'b0;
          end else if (MSI_locked[0]) begin
              MSI_lock_cnt[0]=MSI_lock_cnt_inc[0];
          end
          if (&MSI_lock_cnt[1]) begin
              MSI_locked[1]=1'b0;
          end else if (MSI_locked[1]) begin
              MSI_lock_cnt[1]=MSI_lock_cnt_inc[1];
          end
          if (dc_wrEn[0] && dc_wrSz[0][2] && dc_wrSz[0][4]) begin
              MSI_lock[dc_wrSz[0]]<=dc_wrOdd[0] ? {dc_wrAddrO[0],1'b1} : {dc_wrAddrE[0],1'b0};;
              MSI_lock_cnt[dc_wrSz[0]]<=0;
              MSI_locked[dc_wrSz[0]]<=dc_wrSz[0][1];
          end 
          if (dc_wrEn[1] && dc_wrSz[1][2] && dc_wrSz[1][4]) begin
              MSI_lock[dc_wrSz[1]]<=dc_wrOdd[1] ? {dc_wrAddrO[1],1'b1} : {dc_wrAddrE[1],1'b0};;
              MSI_lock_cnt[dc_wrSz[1]]<=0;
              MSI_locked[dc_wrSz[1]]<=dc_wrSz[1][1];
          end 
	  fret_reg[0]<=fret[0];
	  fret_reg[1]<=fret[1];
	  fret_reg[2]<=fret[2];
	  fret_reg[3]<=fret[3];
	  fret_reg[4]<=fret[4];
	  fret_reg[5]<=fret[5];
	  sqrDatFL_reg<=sqrDatFL;
	  sqrDatVL_reg<=sqrDatVL;
	  sqrDatEn_reg<=|sqrDatEn || outOp_reg4[8][11]&outEn_reg4[8][1]&outEn_reg4[8][0];
      end
      
      if (rst) begin
	  for (f=0;f<10;f=f+1) begin
              FU_reg[f]<={DATA_WIDTH{1'B0}};
              FU_reg2[f]<={DATA_WIDTH{1'B0}};
              FUreg_reg[f]<={REG_WIDTH{1'B0}};
              FUreg_reg2[f]<={REG_WIDTH{1'B0}};
              FUreg_reg3[f]<={REG_WIDTH{1'B0}};
              FUreg_reg4[f]<={REG_WIDTH{1'B0}};
              FUreg_reg5[f]<={REG_WIDTH{1'B0}};
              FUreg_reg[f]<={REG_WIDTH{1'B0}};
              FUwen_reg[f]<=1'b0;
              FUreg_reg2[f]<={REG_WIDTH{1'B0}};
              FUwen_reg2[f]<=1'b0;
              FUreg_reg3[f]<={REG_WIDTH{1'B0}};
              FUwen_reg3[f]<=1'b0;
              FUreg_reg4[f]<={REG_WIDTH{1'B0}};
              FUwen_reg4[f]<=1'b0;
              FUreg_reg5[f]<={REG_WIDTH{1'B0}};
              FUwen_reg5[f]<=1'b0;
              FUreg_reg6[f]<={REG_WIDTH{1'B0}};
              FUwen_reg6[f]<=1'b0;
              FUreg_reg7[f]<={REG_WIDTH{1'B0}};
              FUwen_reg7[f]<=1'b0;
	      FUVH_reg[f]<={SIMD_WIDTH{1'B0}};
	      FUVL_reg[f]<={SIMD_WIDTH{1'B0}};
	      if (f<4) FUVLX_reg[f]<=16'B0;
	      FUFH_reg[f]<={SIMD_WIDTH{1'B0}};
	      FUFL_reg[f]<={16+SIMD_WIDTH{1'B0}};
	//      FUFUH_reg[f]<={SIMD_WIDTH{1'B0}};
	//      FUFUL_reg[f]<={SIMD_WIDTH{1'B0}};
	      FUVH_reg2[f]<={SIMD_WIDTH{1'B0}};
	      FUVL_reg2[f]<={SIMD_WIDTH{1'B0}};
	      FUFH_reg2[f]<={SIMD_WIDTH{1'B0}};
	      FUFL_reg2[f]<={16+SIMD_WIDTH{1'B0}};
	//      FUFUH_reg2[f]<={SIMD_WIDTH{1'B0}};
	//      FUFUL_reg2[f]<={SIMD_WIDTH{1'B0}};
	      if (f<=8) begin
		  fuFwdA_reg[f]<=4'hf;
		  fuFwdB_reg[f]<=4'hf;
		  fuuFwdA_reg[f]<=4'hf;
		  fuuFwdB_reg[f]<=4'hf;
		  fuFwdA_reg2[f]<=4'hf;
		  fuFwdB_reg2[f]<=4'hf;
		  fuuFwdA_reg2[f]<=4'hf;
		  fuuFwdB_reg2[f]<=4'hf;
	      end
              if (f<=2) begin
		  fuFwdAH_reg[f]<=4'hf;
		  fuFwdBH_reg[f]<=4'hf;
		  fuuFwdAH_reg[f]<=4'hf;
		  fuuFwdBH_reg[f]<=4'hf;
              end
          end
          FUS1_reg<=6'B0;
          FUS2_reg<=6'B0;
          FUS3_reg<=6'B0;
          FUS4_reg<=6'B0;
          FUS5_reg<=6'B0;
          FUS6_reg<=6'B0;
          FUS7_reg<=6'B0;
          FUS8_reg<=6'B0;
          FUS9_reg<=6'B0;
          FUwen0<=1'b0;
          FUwen1<=1'b0;
          FUwen2<=1'b0;
          FUwen3<=1'b0;
          FU0Hit_reg<=1'b0;
          FU1Hit_reg<=1'b0;
          FU2Hit_reg<=1'b0;
          FU3Hit_reg<=1'b0;
          FU0Hit_reg2<=1'b0;
          FU1Hit_reg2<=1'b0;
          FU2Hit_reg2<=1'b0;
          FU3Hit_reg2<=1'b0;
      end else begin
	  for (f=0;f<10;f=f+1) begin
              FU_reg[f]<=FU[f];
              FU_reg2[f]<=FU_reg[f];
              if (FUwen[f]) FUreg_reg[f]<=FUreg[f];
              if (FUwen[f]) FUSreg_reg[f]<=FUSreg[f];
              FUwen_reg[f]<=FUwen[f];
              FUreg_reg2[f]<=FUreg_reg[f];
              FUwen_reg2[f]<=FUwen_reg[f];
              FUreg_reg3[f]<=FUreg_reg2[f];
              FUwen_reg3[f]<=FUwen_reg2[f];
              FUreg_reg4[f]<=FUreg_reg3[f];
              FUwen_reg4[f]<=FUwen_reg3[f];
              FUreg_reg5[f]<=FUreg_reg4[f];
              FUwen_reg5[f]<=FUwen_reg4[f];
              FUreg_reg6[f]<=FUreg_reg5[f];
              FUwen_reg6[f]<=FUwen_reg5[f];
              FUreg_reg7[f]<=FUreg_reg6[f];
              FUwen_reg7[f]<=FUwen_reg6[f];
              FUSreg_reg2[f]<=FUSreg_reg[f];
              FUSreg_reg3[f]<=FUSreg_reg2[f];
              FUSreg_reg4[f]<=FUSreg_reg3[f];
              FUSreg_reg5[f]<=FUSreg_reg4[f];
	      if (f<4) begin
                  FUVH_reg[f]<=FUVH[f];
	          FUVL_reg[f]<=FUVL[f];
	          FUFH_reg[f]<=FUFH[f];
	          FUFL_reg[f]<=FUFL[f];
              end else if (f<7) begin
                  if (outEn_reg3[(f-4)*3+1][2]) begin
                      FUVH_reg[f]<=FUVH[f];
	              FUVL_reg[f]<=FUVL[f];
                  end else begin
                      FUVH_reg[f]<=FUVH[f];
	              FUVL_reg[f]<=FUVL[f];
                  end
                  if (outEn_reg4[(f-4)*3+1][2]) begin
                      FUFH_reg[f]<=FUVXH[f];
	              FUFL_reg[f]<=FUVXL[f];
                  end else begin
                      FUFH_reg[f]<=FUFH[f];
	              FUFL_reg[f]<=FUFL[f];
                  end
              end else begin
                  if (outEn_reg4[(f-7)*3+2][2]) begin
                      FUVH_reg[f]<=FUVH[f];
	              FUVL_reg[f]<=FUVL[f];
                  end else begin
                      FUVH_reg[f]<=FUVH[f];
	              FUVL_reg[f]<=FUVL[f];
                  end
                  if (outEn_reg5[(f-7)*3+2][2]) begin
                      FUFH_reg[f]<=FUVXH[f];
	              FUFL_reg[f]<=FUVXL[f];
                  end else begin
                      FUFH_reg[f]<=FUFH[f];
	              FUFL_reg[f]<=FUFL[f];
                  end
              end
	      if (f<4) FUVLX_reg[f]<=FUVLX[f];
	  //    FUFUH_reg[f]<=FUFUH[f];
	  //    FUFUL_reg[f]<=FUFUL[f];
	      FUVH_reg2[f]<=FUVH_reg[f];
	      FUVL_reg2[f]<=FUVL_reg[f];
	      FUFH_reg2[f]<=FUFH_reg[f];
	      FUFL_reg2[f]<=FUFL_reg[f];
	 //     FUFUH_reg2[f]<=FUFUH_reg[f];
	 //     FUFUL_reg2[f]<=FUFUL_reg[f];
	      if (f<=8) begin
		  fuFwdA_reg[f]<=fuFwdA[f];
		  fuFwdB_reg[f]<=fuFwdB[f];
		  fuuFwdA_reg[f]<=fuuFwdA[f];
		  fuuFwdB_reg[f]<=fuuFwdB[f];
		  fuFwdA_reg2[f]<=fuFwdA_reg[f];
		  fuFwdB_reg2[f]<=fuFwdB_reg[f];
		  fuuFwdA_reg2[f]<=fuuFwdA_reg[f];
		  fuuFwdB_reg2[f]<=fuuFwdB_reg[f];
	      end
              if (f<=2) begin
		  fuFwdAH_reg[f]<=fuFwdAH[f];
		  fuFwdBH_reg[f]<=fuFwdBH[f];
		  fuuFwdAH_reg[f]<=fuuFwdAH[f];
		  fuuFwdBH_reg[f]<=fuuFwdBH[f];
              end
          end
          FUS1_reg<=FUS1;
          FUS2_reg<=FUS2;
          FUS3_reg<=FUS3;
          FUS4_reg<=FUS4;
          FUS5_reg<=FUS5;
          FUS6_reg<=FUS6;
          FUS7_reg<=FUS7;
          FUS8_reg<=FUS8;
          FUS9_reg<=FUS9;
          if (except) FUwen0<=1'b0;
          else FUwen0<=dc_rdEn[0];
          if (except) FUwen1<=1'b0;
          else FUwen1<=dc_rdEn[1];
          if (except) FUwen2<=1'b0;
          else FUwen2<=dc_rdEn[2];
          if (except) FUwen3<=1'b0;
          else FUwen3<=dc_rdEn[3];
          FU0Hit_reg<=FU0Hit;
          FU1Hit_reg<=FU1Hit;
          FU2Hit_reg<=FU2Hit;
          FU3Hit_reg<=FU3Hit;
          FU0Hit_reg2<=FU0Hit_reg;
          FU1Hit_reg2<=FU1Hit_reg;
          FU2Hit_reg2<=FU2Hit_reg;
          FU3Hit_reg2<=FU3Hit_reg;
      end
      
      if (rst) begin
          wt_pause_addrcalc_reg<=1'b0;
          wt_pause_addrcalc_reg2<=1'b0;
          for(v=0;v<=3;v=v+1) begin
              dc_rsEn_reg[v]<=1'b0;
	      dc_LSQ_reg[v]<=9'b0;
	      dc_rdataA_reg[v]<=136'b0;
	      dc_rdataA_X_reg[v]<=128'b0;
	      dc_pdataA_reg[v]<=2'b0;
	      dc_rdataA_reg2[v]<=136'b0;
	      dc_rdataA_X_reg2[v]<=128'b0;
          end
          for(v=0;v<=1;v=v+1) begin
             WDfxWQ_reg[v]<=6'b0;
             WDfxWQ_reg2[v]<=6'b0;
             WDfxWQ_reg3[v]<=6'b0;
             WDfxWQ_reg4[v]<=6'b0;
             WDfxII_reg[v]<=10'b0;
             WDfxII_reg2[v]<=10'b0;
             WDfxII_reg3[v]<=10'b0;
             WDfxDataEn_reg[v]<=4'b0;
             WDfxDataEn_reg2[v]<=4'b0;
             WDfxDataEn_reg3[v]<=4'b0;
             WDfxDataEn_reg4[v]<=4'b0;
             WDfxData_reg[v]<={DATA_WIDTH{1'B0}};
             WDfxData_reg2[v]<={DATA_WIDTH{1'B0}};
             WDfxData_reg3[v]<={DATA_WIDTH{1'B0}};
             WDoutFuFwd_reg[v]<=4'hf;
             WDoutFuFwd_reg2[v]<=4'hf;
             WDoutFuuFwd_reg[v]<=4'hf;
             WDoutFuuFwd_reg2[v]<=4'hf;
             WDoutDataEn_reg[v]<=4'b0;
             WDoutDataEn_reg2[v]<=4'b0;
	     WDoutOp_reg[v]<=13'b0;
	     WDoutOp_reg2[v]<=13'b0;
	     WDoutOp_reg3[v]<=13'b0;
             lsw_wdataF_reg[v]<=136'b0;
             lsw_wdataV_reg[v]<=136'b0;
             Waddrcalc_blockRS_reg[v]<=1'b0;
          end
      end else begin
          wt_pause_addrcalc_reg<=wt_pause_addrcalc;
          wt_pause_addrcalc_reg2<=wt_pause_addrcalc_reg;
          for(v=0;v<=3;v=v+1) begin
	      if (!rsDoStall[v]) begin
                  dc_rsEn_reg[v]<=dc_rsEn[v];
	          dc_LSQ_reg[v]<=dc_LSQ[v];
	          dc_rdataA_reg[v]<=dc_rdat[v];
	          dc_rdataA_X_reg[v]<=dc_rdat_X[v];
	          dc_pdataA_reg[v]<=dc_pdat[v];
	          dc_rdataA_reg2[v]<=dc_rdataA_reg[v];
	          dc_rdataA_X_reg2[v]<=~dc_sz256_reg3[v] ? 
                    dc_rdataA_reg[v][127:0] : dc_rdataA_X_reg[v];
                  dc_sz256[v]<=lsr_wr_data[v][`lsaddr_sz]==5'hc || lsr_wr_data[v][`lsaddr_sz]==5'hd || 
                    lsr_wr_data[v][`lsaddr_sz]==5'he;
                  dc_sz256_reg[v]<=dc_sz256[v];
                  dc_sz256_reg2[v]<=dc_sz256_reg[v];
                  dc_sz256_reg3[v]<=dc_sz256_reg2[v];
              end
          end
          for(v=0;v<=1;v=v+1) begin
             WDfxWQ_reg[v]<=WDfxWQ[v];
             WDfxWQ_reg2[v]<=WDfxWQ_reg[v];
             WDfxWQ_reg3[v]<=WDfxWQ_reg2[v];
             WDfxWQ_reg4[v]<=WDfxWQ_reg3[v];
             WDfxII_reg[v]<=WDfxII[v];
             WDfxII_reg2[v]<=WDfxII_reg[v];
             WDfxII_reg3[v]<=WDfxII_reg2[v];
             WDfxDataEn_reg[v]<=WDfxDataEn[v];
             WDfxDataEn_reg2[v]<=WDfxDataEn_reg[v];
             WDfxDataEn_reg3[v]<=WDfxDataEn_reg2[v];
             WDfxDataEn_reg4[v]<=WDfxDataEn_reg3[v];
             WDfxData_reg[v]<=WDfxData[v];
             WDfxData_reg2[v]<=WDfxData_reg[v];
             WDfxData_reg3[v]<=WDfxData_reg2[v];
             WDoutFuFwd_reg[v]<=WDoutFuFwd[v];
             WDoutFuFwd_reg2[v]<=WDoutFuFwd_reg[v];
             WDoutFuuFwd_reg[v]<=WDoutFuuFwd[v];
             WDoutFuuFwd_reg2[v]<=WDoutFuuFwd_reg[v];
             WDoutDataEn_reg[v]<=WDoutDataEn[v];
             WDoutDataEn_reg2[v]<=WDoutDataEn_reg[v];
	     WDoutOp_reg[v]<=WDoutOp[v];
	     WDoutOp_reg2[v]<=WDoutOp_reg[v];
	     WDoutOp_reg3[v]<=WDoutOp_reg2[v];
             lsw_wdataF_reg[v]<=lsw_wdataF[v];
             lsw_wdataV_reg[v]<=lsw_wdataV[v];
             Waddrcalc_blockRS_reg[v]<=Waddrcalc_blockRS[v];
          end
      end
      if (rst) begin
	  tire0_rT_reg<=6'b0;
	  tire0_rF_reg<=9'b0;
          tire0_rFl_reg<=9'b0;
	  tire0_enV_reg<=1'b0;
	  tire0_enF_reg<=1'b0;
	  tire1_rT_reg<=6'b0;
	  tire1_rF_reg<=9'b0;
          tire1_rFl_reg<=9'b0;
	  tire1_enV_reg<=1'b0;
	  tire1_enF_reg<=1'b0;
	  tire2_rT_reg<=6'b0;
	  tire2_rF_reg<=9'b0;
          tire2_rFl_reg<=9'b0;
	  tire2_enV_reg<=1'b0;
	  tire2_enF_reg<=1'b0;
	  tire3_rT_reg<=6'b0;
	  tire3_rF_reg<=9'b0;
          tire3_rFl_reg<=9'b0;
	  tire3_enV_reg<=1'b0;
	  tire3_enF_reg<=1'b0;
	  tire4_rT_reg<=6'b0;
	  tire4_rF_reg<=9'b0;
          tire4_rFl_reg<=9'b0;
	  tire4_enV_reg<=1'b0;
	  tire4_enF_reg<=1'b0;
	  tire5_rT_reg<=6'b0;
	  tire5_rF_reg<=9'b0;
          tire5_rFl_reg<=9'b0;
	  tire5_enV_reg<=1'b0;
	  tire5_enF_reg<=1'b0;
	  tire6_rT_reg<=6'b0;
	  tire6_rF_reg<=9'b0;
          tire6_rFl_reg<=9'b0;
	  tire6_enV_reg<=1'b0;
	  tire6_enF_reg<=1'b0;
	  tire7_rT_reg<=6'b0;
	  tire7_rF_reg<=9'b0;
          tire7_rFl_reg<=9'b0;
	  tire7_enV_reg<=1'b0;
	  tire7_enF_reg<=1'b0;
	  tire8_rT_reg<=6'b0;
	  tire8_rF_reg<=9'b0;
          tire8_rFl_reg<=9'b0;
	  tire8_enV_reg<=1'b0;
	  tire8_enF_reg<=1'b0;
	  
	  tire0_rT_reg2<=6'b0;
	  tire0_rF_reg2<=9'b0;
	  tire0_enF_reg2<=1'b0;
	  tire1_rT_reg2<=6'b0;
	  tire1_rF_reg2<=9'b0;
	  tire1_enF_reg2<=1'b0;
	  tire2_rT_reg2<=6'b0;
	  tire2_rF_reg2<=9'b0;
	  tire2_enF_reg2<=1'b0;
	  tire3_rT_reg2<=6'b0;
	  tire3_rF_reg2<=9'b0;
	  tire3_enF_reg2<=1'b0;
	  tire4_rT_reg2<=6'b0;
	  tire4_rF_reg2<=9'b0;
	  tire4_enF_reg2<=1'b0;
	  tire5_rT_reg2<=6'b0;
	  tire5_rF_reg2<=9'b0;
	  tire5_enF_reg2<=1'b0;
	  tire6_rT_reg2<=6'b0;
	  tire6_rF_reg2<=9'b0;
	  tire6_enF_reg2<=1'b0;
	  tire7_rT_reg2<=6'b0;
	  tire7_rF_reg2<=9'b0;
	  tire7_enF_reg2<=1'b0;
	  tire8_rT_reg2<=6'b0;
	  tire8_rF_reg2<=9'b0;
	  tire8_enF_reg2<=1'b0;
	  retfl_rF_reg<=9'b0;
      end else begin
	  tire0_rT_reg<=tire0_rT;
	  tire0_rF_reg<=tire0_rF;
          tire0_rFl_reg<=tire0_rFl;
	  tire0_enV_reg<=tire0_enV;
	  tire0_enF_reg<=tire0_enF;
	  tire1_rT_reg<=tire1_rT;
	  tire1_rF_reg<=tire1_rF;
          tire1_rFl_reg<=tire1_rFl;
	  tire1_enV_reg<=tire1_enV;
	  tire1_enF_reg<=tire1_enF;
	  tire2_rT_reg<=tire2_rT;
	  tire2_rF_reg<=tire2_rF;
          tire2_rFl_reg<=tire2_rFl;
	  tire2_enV_reg<=tire2_enV;
	  tire2_enF_reg<=tire2_enF;
	  tire3_rT_reg<=tire3_rT;
	  tire3_rF_reg<=tire3_rF;
          tire3_rFl_reg<=tire3_rFl;
	  tire3_enV_reg<=tire3_enV;
	  tire3_enF_reg<=tire3_enF;
	  tire4_rT_reg<=tire4_rT;
	  tire4_rF_reg<=tire4_rF;
          tire4_rFl_reg<=tire4_rFl;
	  tire4_enV_reg<=tire4_enV;
	  tire4_enF_reg<=tire4_enF;
	  tire5_rT_reg<=tire5_rT;
	  tire5_rF_reg<=tire5_rF;
          tire5_rFl_reg<=tire5_rFl;
	  tire5_enV_reg<=tire5_enV;
	  tire5_enF_reg<=tire5_enF;
	  tire6_rT_reg<=tire6_rT;
	  tire6_rF_reg<=tire6_rF;
          tire6_rFl_reg<=tire6_rFl;
	  tire6_enV_reg<=tire6_enV;
	  tire6_enF_reg<=tire6_enF;
	  tire7_rT_reg<=tire7_rT;
	  tire7_rF_reg<=tire7_rF;
          tire7_rFl_reg<=tire7_rFl;
	  tire7_enV_reg<=tire7_enV;
	  tire7_enF_reg<=tire7_enF;
	  tire8_rT_reg<=tire8_rT;
	  tire8_rF_reg<=tire8_rF;
          tire8_rFl_reg<=tire8_rFl;
	  tire8_enV_reg<=tire8_enV;
	  tire8_enF_reg<=tire8_enF;
	  
	  tire0_rT_reg2<=tire0_rT_reg;
	  tire0_rF_reg2<=tire0_rF_reg;
	  tire0_enF_reg2<=tire0_enF_reg;
	  tire1_rT_reg2<=tire1_rT_reg;
	  tire1_rF_reg2<=tire1_rF_reg;
	  tire1_enF_reg2<=tire1_enF_reg;
	  tire2_rT_reg2<=tire2_rT_reg;
	  tire2_rF_reg2<=tire2_rF_reg;
	  tire2_enF_reg2<=tire2_enF_reg;
	  tire3_rT_reg2<=tire3_rT_reg;
	  tire3_rF_reg2<=tire3_rF_reg;
	  tire3_enF_reg2<=tire3_enF_reg;
	  tire4_rT_reg2<=tire4_rT_reg;
	  tire4_rF_reg2<=tire4_rF_reg;
	  tire4_enF_reg2<=tire4_enF_reg;
	  tire5_rT_reg2<=tire5_rT_reg;
	  tire5_rF_reg2<=tire5_rF_reg;
	  tire5_enF_reg2<=tire5_enF_reg;
	  tire6_rT_reg2<=tire6_rT_reg;
	  tire6_rF_reg2<=tire6_rF_reg;
	  tire6_enF_reg2<=tire6_enF_reg;
	  tire7_rT_reg2<=tire7_rT_reg;
	  tire7_rF_reg2<=tire7_rF_reg;
	  tire7_enF_reg2<=tire7_enF_reg;
	  tire8_rT_reg2<=tire8_rT_reg;
	  tire8_rF_reg2<=tire8_rF_reg;
	  tire8_enF_reg2<=tire8_enF_reg;
	  retfl_rF_reg<=retfl_rF;
      end
      if (rst) begin
	  nDataAlt_reg[0]<=3'b0;
	  nDataAlt_reg[1]<=3'b0;
	  nDataAlt_reg[2]<=3'b0;
      end else begin
	  nDataAlt_reg[0]<=nDataAlt[0];
	  nDataAlt_reg[1]<=nDataAlt[1];
	  nDataAlt_reg[2]<=nDataAlt[2];
      end
      if (rst) begin
	  lso_en_reg<=0;
	  lso_way_reg<=0;
	  lso2_en_reg<=0;
	  lso_data_reg<=0;
	  lso2_data_reg<=0;
	  lso_dataN_reg<=0;
	  lso2_dataN_reg<=0;
	  lso_pbit_reg<=0;
	  lso2_pbit_reg<=0;
          p0_sec_reg<=1'b0;
          p1_sec_reg<=1'b0;
          p2_sec_reg<=1'b0;
          p0_sec_reg2<=1'b0;
          p1_sec_reg2<=1'b0;
          p2_sec_reg2<=1'b0;
      end else begin
	  lso_en_reg<=lso_en;
	  lso_way_reg<=lso_way;
	  lso2_en_reg<=0;
	  lso_data_reg<=lso_data;
	  lso2_data_reg<=lso2_data;
	  lso_dataN_reg<=lso_dataN;
	  lso2_dataN_reg<=lso2_dataN;
	  lso_pbit_reg<=lso_pbit;
	  lso2_pbit_reg<=lso2_pbit;
          p0_sec_reg<=p0_sec;
          p1_sec_reg<=p1_sec;
          p2_sec_reg<=p2_sec;
          p0_sec_reg2<=p0_sec_reg;
          p1_sec_reg2<=p1_sec_reg;
          p2_sec_reg2<=p2_sec_reg;
      end
  end
 
endmodule


