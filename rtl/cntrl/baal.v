/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


`include "../../rtl/struct.sv"
`include "../msrss_no.sv"

module cntrl_jump_upto(
  flagSet,
  prevFlags,
  jumpType,
  jumpIndex,
  jumpPredTk,
  jumpTbufMiss,
  indirMismatch,
  jumpMisPred,
  jumpTaken,
  flagOut,
  flagOutN,
  flags0,
  flags1,  
  flags2,
  flags3,
  flags4,
  flags5,
  flags6,
  flags7,
  flags8,
  flags9
  );

  parameter INDEX=0;
  localparam WIDTH=6;
  
  input pwire [9:0] flagSet;
  input pwire [WIDTH-1:0] prevFlags;
  input pwire [4:0] jumpType;
  input pwire [3:0] jumpIndex;
  input pwire jumpPredTk;
  input pwire jumpTbufMiss;
  input pwire indirMismatch;
  output pwire jumpMisPred;
  output pwire jumpTaken;
  output pwire [WIDTH-1:0] flagOut;
  output pwire [WIDTH-1:0] flagOutN;
  input pwire [WIDTH-1:0] flags0;
  input pwire [WIDTH-1:0] flags1;
  input pwire [WIDTH-1:0] flags2;
  input pwire [WIDTH-1:0] flags3;
  input pwire [WIDTH-1:0] flags4;
  input pwire [WIDTH-1:0] flags5;
  input pwire [WIDTH-1:0] flags6;
  input pwire [WIDTH-1:0] flags7;
  input pwire [WIDTH-1:0] flags8;
  input pwire [WIDTH-1:0] flags9;
  
  pwire [WIDTH-1:0] flags[9:0];
  pwire [9:0] jumpTaken_x;
  pwire [9:0] mispred_x;

  pwire [9:0] flagLast;
  pwire nFlagIsPrev;
  
  pwire jumpTaken_0;
  pwire mispred_0;

  assign flags[0]=flags0;
  assign flags[1]=flags1;
  assign flags[2]=flags2;
  assign flags[3]=flags3;
  assign flags[4]=flags4;
  assign flags[5]=flags5;
  assign flags[6]=flags6;
  assign flags[7]=flags7;
  assign flags[8]=flags8;
  assign flags[9]=flags9;
  
  bit_find_last_bit #(10) flg_mod(flagSet,flagLast,nFlagIsPrev);
  
  generate
    genvar k;
    for(k=0;k<10;k=k+1) begin : jcmp_gen
        except_jump_cmp cmp_mod(flags[k],jumpType,jumpTaken_x[k]);
        assign mispred_x[k]=(jumpTaken_x[k] ^ jumpPredTk) | (indirMismatch && pwh#(5)::cmpEQ(jumpType,5'h11)) | jumpTbufMiss && pwh#(32)::cmpEQ(INDEX,jumpIndex);
        assign jumpTaken=(flagLast[k] && pwh#(32)::cmpEQ(INDEX,jumpIndex)) ? jumpTaken_x[k]&~jumpTbufMiss : 1'bz;
        assign jumpMisPred=flagLast[k] ? mispred_x[k] : 1'bz; 
        assign flagOut=(flagLast[k] && pwh#(32)::cmpEQ(INDEX,jumpIndex)) ? flags[k] : 'z;
        assign flagOutN=flagLast[k] ? flags[k] : 'z;
    end
  endgenerate

  except_jump_cmp cmp_mod(prevFlags,jumpType,jumpTaken_0);
  assign mispred_0=(jumpTaken_0 ^ jumpPredTk) | (indirMismatch && pwh#(5)::cmpEQ(jumpType,5'h11)) && pwh#(32)::cmpEQ(INDEX,jumpIndex);
  assign jumpTaken=(~nFlagIsPrev  && pwh#(32)::cmpEQ(INDEX,jumpIndex)) ? jumpTaken_0 : 1'bz;
  assign jumpMisPred=(~nFlagIsPrev) ? mispred_0 : 1'bz; 
  assign flagOut=(~nFlagIsPrev && pwh#(32)::cmpEQ(INDEX,jumpIndex)) ? prevFlags : 'z;
  assign flagOutN=(~nFlagIsPrev) ? prevFlags : 'z;

endmodule

module cntrl_get_IP(
  baseIP,
  srcIPOff,
  magicO,
  last,
  excpt,
  nextIP
  );
  input pwire [62:0] baseIP;
  input pwire [8:0] srcIPOff;
  input pwire [2:0] magicO;
  input pwire last;
  input pwire excpt;
  output pwire [62:0] nextIP;
  
  pwire [62:0] nextIP0;
  pwire [4:0] par0;
  pwire [4:0] par1;
  pwire [64:0] val2;
  pwire cout_sec;
  pwire ndiff;
  pwire mgt;
	get_carry #(4) cmp(magicO,~srcIPOff[3:0],1'b0,mgt);
  adder_CSA #(4) csa_mod(baseIP[3:0],srcIPOff[3:0],~{1'b0,magicO},par0,par1);
	adder #(4) nlast_add_small(par0[3:0],par1[3:0],nextIP0[3:0],~mgt,excpt,,,,);
  add_addrcalc adder_mod(
  {1'b1,baseIP,1'b0},{63'b0,last&~excpt},{1'b0,54'b0,srcIPOff[8:4],5'b0},
  val2,
  cout_sec,
  ndiff,
  1'b1,
  4'h1,
  2'h0
  );

  assign nextIP0=(last&~excpt) ? {val2[63:5],4'd0} : 63'bz;
  assign nextIP0=(~last&~excpt) ? {val2[63:5],srcIPOff[3:0]} : 63'bz;
  assign nextIP0[62:4]=excpt ? val2[63:5] : 59'bz;
	
  assign nextIP=nextIP0;

endmodule

module cntrl_get_shortIP(
  baseIP,
  srcIPOff,
  jupd0_IP, jupd0_en,
  jupd1_IP, jupd1_en
  );
  input pwire [19:0] baseIP;
  input pwire [8:0] srcIPOff;
  output pwire [19:0] jupd0_IP;
  input pwire jupd0_en;
  output pwire [19:0] jupd1_IP;
  input pwire jupd1_en;

  adder2o #(20-4) last_add(baseIP[19:4],{11'b0,srcIPOff[8:4]},jupd0_IP[19:4],jupd1_IP[19:4],1'b0,jupd0_en,jupd1_en,,,,);

  assign jupd0_IP[3:0]=jupd0_en ? srcIPOff[3:0] : 4'bz;
  assign jupd1_IP[3:0]=jupd1_en ? srcIPOff[3:0] : 4'bz;

endmodule

module cntrl_get_retcnt(
  reten,
  retcnt);
  input pwire [8:0] reten;
  output pwire [3:0] retcnt;
  
  pwire [3:0] cpop0;
  pwire [3:0] cpop1;
  pwire [3:0] cpop2;
  
  popcnt3 cpop0_mod({reten[6],reten[3],reten[0]},cpop0);
  popcnt3 cpop1_mod({reten[7],reten[4],reten[1]},cpop1);
  popcnt3 cpop2_mod({reten[8],reten[5],reten[2]},cpop2);
  
  assign retcnt[0]=cpop0[0] & cpop1[0] & cpop2[0];
  assign retcnt[1]=cpop0[1] | cpop1[1] | cpop2[1] && cpop0[3:2]==0 && cpop1[3:2]==0 && cpop2[3:2]==0;
  assign retcnt[2]=cpop0[2] | cpop1[2] | cpop2[2] && !cpop0[3] && !cpop1[3] && !cpop2[3];
  assign retcnt[3]=cpop0[3] | cpop1[3] | cpop2[3];
  
endmodule

module cntrl_find_outcome(
  clk,rst,
  stall,doStall,
  do_sched_reset,
  except,
  exceptIP,
  except_attr,
  except_thread,
  except_both,
  except_due_jump,
  except_jump_ght,
  except_jump_ght2,
  except_set_instr_flag,
  except_jmp_mask_en,
  except_jmp_mask,
  msrss_no,msrss_thread,msrss_en,msrss_data,msrss_xdata,
  new_en,new_thread,new_addr,
  GORQ,GORQ_data,
  instr0_err,instr1_err,instr2_err,instr3_err,instr4_err,instr5_err,
  instr6_err,instr7_err,instr8_err,instr9_err,
  instr0_en,instr0_wren,instr0_IPOff,instr0_magic,instr0_last,instr0_after_spec,
  instr1_en,instr1_wren,instr1_IPOff,instr1_magic,instr1_last,instr1_after_spec,
  instr2_en,instr2_wren,instr2_IPOff,instr2_magic,instr2_last,instr2_after_spec,
  instr3_en,instr3_wren,instr3_IPOff,instr3_magic,instr3_last,instr3_after_spec,
  instr4_en,instr4_wren,instr4_IPOff,instr4_magic,instr4_last,instr4_after_spec,
  instr5_en,instr5_wren,instr5_IPOff,instr5_magic,instr5_last,instr5_after_spec,
  instr6_en,instr6_wren,instr6_IPOff,instr6_magic,instr6_last,instr6_after_spec,
  instr7_en,instr7_wren,instr7_IPOff,instr7_magic,instr7_last,instr7_after_spec,
  instr8_en,instr8_wren,instr8_IPOff,instr8_magic,instr8_last,instr8_after_spec,
  instr9_en,instr9_wren,instr9_IPOff,instr9_magic,instr9_last,instr9_after_spec,
  instr_attr,
  instr0_rT,instr0_gen,instr0_vec,
  instr1_rT,instr1_gen,instr1_vec,
  instr2_rT,instr2_gen,instr2_vec,
  instr3_rT,instr3_gen,instr3_vec,
  instr4_rT,instr4_gen,instr4_vec,
  instr5_rT,instr5_gen,instr5_vec,
  instr6_rT,instr6_gen,instr6_vec,
  instr7_rT,instr7_gen,instr7_vec,
  instr8_rT,instr8_gen,instr8_vec,
  instr9_rT,instr9_gen,instr9_vec,
  iret0,iret1,iret2,iret3,iret4,
  iret5,iret6,iret7,iret8,
  iret0_rF,iret1_rF,iret2_rF,iret3_rF,iret4_rF,
  iret5_rF,iret6_rF,iret7_rF,iret8_rF,
  iret0_rFl,iret1_rFl,iret2_rFl,iret3_rFl,iret4_rFl,
  iret5_rFl,iret6_rFl,iret7_rFl,iret8_rFl,
  iret_clr,
  ijump0Type,ijump0Off,ijump0IP,ijump0Mask,
  ijump1Type,ijump1Off,ijump1IP,ijump1Mask,
  ijump0BtbWay,ijump0JmpInd,ijump0GHT,ijump0GHT2,ijump0Val2,ijump0CLP,
  ijump1BtbWay,ijump1JmpInd,ijump1GHT,ijump1GHT2,ijump0Val2,ijump1CLP,
  ijump0SC,ijump0Miss,ijump0BtbOnly,
  ijump1SC,ijump1Miss,ijump1BtbOnly,
  itk_after,ifsimd,
  iJump0Taken,iJump1Taken,
  iJump0Attr,iJump1Attr,
  flTE,tire_enFl,
  tire0_rT,tire0_rF,tire0_enG,tire0_enV,tire0_enF,
  tire1_rT,tire1_rF,tire1_enG,tire1_enV,tire1_enF,
  tire2_rT,tire2_rF,tire2_enG,tire2_enV,tire2_enF,
  tire3_rT,tire3_rF,tire3_enG,tire3_enV,tire3_enF,
  tire4_rT,tire4_rF,tire4_enG,tire4_enV,tire4_enF,
  tire5_rT,tire5_rF,tire5_enG,tire5_enV,tire5_enF,
  tire6_rT,tire6_rF,tire6_enG,tire6_enV,tire6_enF,
  tire7_rT,tire7_rF,tire7_enG,tire7_enV,tire7_enF,
  tire8_rT,tire8_rF,tire8_enG,tire8_enV,tire8_enF,
  dotire,retcnt,retclr,
  jupd0_en,jupdt0_en,jupd0_ght_en,jupd0_ght2_en,
  jupd0_addr,jupd0_baddr,
  jupd0_sc,jupd0_tk,
  jupd1_en,jupdt1_en,jupd1_ght_en,jupd1_ght2_en,
  jupd1_addr,jupd1_baddr,
  jupd1_sc,jupd1_tk,
  ret0_addr,ret0_data,ret0_wen,
  ret1_addr,ret1_data,ret1_wen,
  ret2_addr,ret2_data,ret2_wen,
  ret3_addr,ret3_data,ret3_wen,
  ret4_addr,ret4_data,ret4_wen,
  ret5_addr,ret5_data,ret5_wen,ret5_IP,ret5_IP_en,
  ret0F_addr,ret0F_data,ret0F_wen,
  ret1F_addr,ret1F_data,ret1F_wen,
  ret2F_addr,ret2F_data,ret2F_wen,
  mem_II_upper,
  mem_II_upper2,
  has_stores,
  mem_II_upper_out,
  mem_II_bits_fine,
  mem_II_bits_ldconfl,
  mem_II_bits_waitconfl,
  mem_II_bits_except,
  mem_II_bits_ret,
  mem_II_stall,
  
  dotire_d,
  xbreak,
  has_xbreak
  );
  localparam RET_WIDTH=`except_width;
  localparam BOB_WIDTH=`bob_width;
/*vrilator hier_block*/

  input pwire clk;
  input pwire rst;
  input pwire stall;
  output pwire doStall;

  output pwire do_sched_reset;
  
  output pwire except;
  output pwire [62:0] exceptIP;
  output pwire [3:0] except_attr;
  output pwire except_thread;
  output pwire except_both;
  output pwire except_due_jump;
  output pwire [7:0] except_jump_ght;
  output pwire [15:0] except_jump_ght2;
  output pwire except_set_instr_flag;
  output pwire except_jmp_mask_en;
  output pwire [3:0] except_jmp_mask;
  output pwire [15:0] msrss_no;
  output pwire msrss_thread;
  output pwire msrss_en;
  output pwire [6_4:0] msrss_data;
  output pwire [23:0] msrss_xdata;
  input pwire new_en;
  input pwire new_thread;
  output pwire [5:0] new_addr;
  input pwire GORQ;
  input pwire [15:0] GORQ_data;
  input pwire [1:0] instr0_err;
  input pwire [1:0] instr1_err;
  input pwire [1:0] instr2_err;
  input pwire [1:0] instr3_err;
  input pwire [1:0] instr4_err;
  input pwire [1:0] instr5_err;
  input pwire [1:0] instr6_err;
  input pwire [1:0] instr7_err;
  input pwire [1:0] instr8_err;
  input pwire [1:0] instr9_err;
  input pwire instr0_en;
  input pwire instr0_wren;  
  input pwire [8:0] instr0_IPOff;
  input pwire [2:0] instr0_magic;
  input pwire instr0_last;
  input pwire instr0_after_spec;
  input pwire instr1_en;
  input pwire instr1_wren;  
  input pwire [8:0] instr1_IPOff;
  input pwire [2:0] instr1_magic;
  input pwire instr1_last;
  input pwire instr1_after_spec;
  input pwire instr2_en;
  input pwire instr2_wren;  
  input pwire [8:0] instr2_IPOff;
  input pwire [2:0] instr2_magic;
  input pwire instr2_last;
  input pwire instr2_after_spec;
  input pwire instr3_en;
  input pwire instr3_wren;  
  input pwire [8:0] instr3_IPOff;
  input pwire [2:0] instr3_magic;
  input pwire instr3_last;
  input pwire instr3_after_spec;
  input pwire instr4_en;
  input pwire instr4_wren;  
  input pwire [8:0] instr4_IPOff;
  input pwire [2:0] instr4_magic;
  input pwire instr4_last;
  input pwire instr4_after_spec;
  input pwire instr5_en;
  input pwire instr5_wren;  
  input pwire [8:0] instr5_IPOff;
  input pwire [2:0] instr5_magic;
  input pwire instr5_last;
  input pwire instr5_after_spec;
  input pwire instr6_en;
  input pwire instr6_wren;  
  input pwire [8:0] instr6_IPOff;
  input pwire [2:0] instr6_magic;
  input pwire instr6_last;
  input pwire instr6_after_spec;
  input pwire instr7_en;
  input pwire instr7_wren;  
  input pwire [8:0] instr7_IPOff;
  input pwire [2:0] instr7_magic;
  input pwire instr7_last;
  input pwire instr7_after_spec;
  input pwire instr8_en;
  input pwire instr8_wren;  
  input pwire [8:0] instr8_IPOff;
  input pwire [2:0] instr8_magic;
  input pwire instr8_last;
  input pwire instr8_after_spec;
  input pwire instr9_en;
  input pwire instr9_wren;  
  input pwire [8:0] instr9_IPOff;
  input pwire [2:0] instr9_magic;
  input pwire instr9_last;
  input pwire instr9_after_spec;
  input pwire [3:0] instr_attr;

  input pwire [5:0] instr0_rT;
  input pwire instr0_gen;
  input pwire instr0_vec;
  input pwire [5:0] instr1_rT;
  input pwire instr1_gen;
  input pwire instr1_vec;
  input pwire [5:0] instr2_rT;
  input pwire instr2_gen;
  input pwire instr2_vec;
  input pwire [5:0] instr3_rT;
  input pwire instr3_gen;
  input pwire instr3_vec;
  input pwire [5:0] instr4_rT;
  input pwire instr4_gen;
  input pwire instr4_vec;
  input pwire [5:0] instr5_rT;
  input pwire instr5_gen;
  input pwire instr5_vec;
  input pwire [5:0] instr6_rT;
  input pwire instr6_gen;
  input pwire instr6_vec;
  input pwire [5:0] instr7_rT;
  input pwire instr7_gen;
  input pwire instr7_vec;
  input pwire [5:0] instr8_rT;
  input pwire instr8_gen;
  input pwire instr8_vec;
  input pwire [5:0] instr9_rT;
  input pwire instr9_gen;
  input pwire instr9_vec;

  input pwire [3:0] iret0;
  input pwire [3:0] iret1;
  input pwire [3:0] iret2;
  input pwire [3:0] iret3;
  input pwire [3:0] iret4;
  input pwire [3:0] iret5;
  input pwire [3:0] iret6;
  input pwire [3:0] iret7;
  input pwire [3:0] iret8;
  
  input pwire [4:0] iret0_rF;
  input pwire [4:0] iret1_rF;
  input pwire [4:0] iret2_rF;
  input pwire [4:0] iret3_rF;
  input pwire [4:0] iret4_rF;
  input pwire [4:0] iret5_rF;
  input pwire [4:0] iret6_rF;
  input pwire [4:0] iret7_rF;
  input pwire [4:0] iret8_rF;

  input pwire [4:0] iret0_rFl;
  input pwire [4:0] iret1_rFl;
  input pwire [4:0] iret2_rFl;
  input pwire [4:0] iret3_rFl;
  input pwire [4:0] iret4_rFl;
  input pwire [4:0] iret5_rFl;
  input pwire [4:0] iret6_rFl;
  input pwire [4:0] iret7_rFl;
  input pwire [4:0] iret8_rFl;

  input pwire [8:0] iret_clr;
  
  input pwire [4:0] ijump0Type;
  input pwire [3:0] ijump0Off;
  input pwire [42:0] ijump0IP;
  input pwire [15:0] ijump0GHT2;
  input pwire        ijump0Val;
  input pwire        ijump0CLP;
  input pwire [3:0] ijump0Mask;
  input pwire [4:0] ijump1Type;
  input pwire [3:0] ijump1Off;
  input pwire [42:0] ijump1IP;
  input pwire [15:0] ijump1GHT2;
  input pwire        ijump1Val;
  input pwire        ijump1CLP;
  input pwire [3:0] ijump1Mask;
  input pwire       ijump0BtbWay;
  input pwire [1:0] ijump0JmpInd;
  input pwire [7:0] ijump0GHT;
  input pwire       ijump1BtbWay;
  input pwire [1:0] ijump1JmpInd;
  input pwire [7:0] ijump1GHT;
  input pwire [1:0] ijump0SC;
  input pwire ijump0Miss;
  input pwire ijump0BtbOnly;
  input pwire [1:0] ijump1SC;
  input pwire ijump1Miss;
  input pwire ijump1BtbOnly;
  input pwire [9:0] itk_after;
  input pwire [9:0] ifsimd;
  input pwire iJump0Taken;
  input pwire iJump1Taken;
  input pwire [3:0] iJump0Attr;
  input pwire [3:0] iJump1Attr;
  output pwire [8:0] flTE;
  output pwire tire_enFl;
  output pwire [5:0] tire0_rT;
  output pwire [8:0] tire0_rF;
  output pwire tire0_enG;
  output pwire tire0_enV;
  output pwire tire0_enF;
  output pwire [5:0] tire1_rT;
  output pwire [8:0] tire1_rF;
  output pwire tire1_enG;
  output pwire tire1_enV;
  output pwire tire1_enF;
  output pwire [5:0] tire2_rT;
  output pwire [8:0] tire2_rF;
  output pwire tire2_enG;
  output pwire tire2_enV;
  output pwire tire2_enF;
  output pwire [5:0] tire3_rT;
  output pwire [8:0] tire3_rF;
  output pwire tire3_enG;
  output pwire tire3_enV;
  output pwire tire3_enF;
  output pwire [5:0] tire4_rT;
  output pwire [8:0] tire4_rF;
  output pwire tire4_enG;
  output pwire tire4_enV;
  output pwire tire4_enF;
  output pwire [5:0] tire5_rT;
  output pwire [8:0] tire5_rF;
  output pwire tire5_enG;
  output pwire tire5_enV;
  output pwire tire5_enF;
  output pwire [5:0] tire6_rT;
  output pwire [8:0] tire6_rF;
  output pwire tire6_enG;
  output pwire tire6_enV;
  output pwire tire6_enF;
  output pwire [5:0] tire7_rT;
  output pwire [8:0] tire7_rF;
  output pwire tire7_enG;
  output pwire tire7_enV;
  output pwire tire7_enF;
  output pwire [5:0] tire8_rT;
  output pwire [8:0] tire8_rF;
  output pwire tire8_enG;
  output pwire tire8_enV;
  output pwire tire8_enF;

  output pwire dotire;
  output pwire [3:0] retcnt;
  output pwire [8:0] retclr;

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
  
  
  input pwire [9:0] 			ret0_addr;
  input pwire [RET_WIDTH-1:0] 	ret0_data;
  input pwire 			ret0_wen;
  input pwire [9:0] 			ret1_addr;
  input pwire [RET_WIDTH-1:0] 	ret1_data;
  input pwire 			ret1_wen;
  input pwire [9:0] 			ret2_addr;
  input pwire [RET_WIDTH-1:0] 	ret2_data;
  input pwire 			ret2_wen;
  input pwire [9:0] 			ret3_addr;
  input pwire [RET_WIDTH-1:0] 	ret3_data;
  input pwire 			ret3_wen;
  input pwire [9:0] 			ret4_addr;
  input pwire [RET_WIDTH-1:0] 	ret4_data;
  input pwire 			ret4_wen;
  input pwire [9:0] 			ret5_addr;
  input pwire [RET_WIDTH-1:0] 	ret5_data;
  input pwire 			ret5_wen;
  input pwire [64:0]			ret5_IP;
  input				ret5_IP_en;
  input pwire [9:0] 			ret0F_addr;
  input pwire [RET_WIDTH-1:0] 	ret0F_data;
  input pwire 			ret0F_wen;
  input pwire [9:0] 			ret1F_addr;
  input pwire [RET_WIDTH-1:0] 	ret1F_data;
  input pwire 			ret1F_wen;
  input pwire [9:0] 			ret2F_addr;
  input pwire [RET_WIDTH-1:0] 	ret2F_data;
  input pwire 			ret2F_wen;

  input pwire [5:0] mem_II_upper;
  input pwire [5:0] mem_II_upper2;
  input pwire has_stores;
  output pwire [5:0] mem_II_upper_out;
  input pwire [9:0] mem_II_bits_fine;
  input pwire [9:0] mem_II_bits_ldconfl;
  input pwire [9:0] mem_II_bits_waitconfl;
  input pwire [9:0] mem_II_bits_except;
  input pwire [9:0] mem_II_bits_ret;
  input pwire mem_II_stall;

  output pwire dotire_d;
  output pwire [9:0] xbreak;
  output pwire has_xbreak;

  pwire mem_match;
  pwire [9:0][RET_WIDTH-1:0] ret_data; 
  pwire [3:0] ret[9:0];
  pwire [9:0] flagSet;
  pwire [9:0] pending;
  pwire [9:0] exceptn;
  pwire [9:0] replay;
  pwire [9:0] replay_safe;
  pwire [9:0] done;
  pwire [9:0] fpudone;
  pwire [9:0] btb_miss;
  pwire break_pending,break_prejmp_tick,break_prejmp_ntick;
  pwire break_exceptn;
  pwire break_replay,break_replayS;
  pwire break_jump0;
  pwire break_jump1;
  pwire [9:0][9:0] ret_prev;
  pwire [9:0][9:0] ret_prevG;
  pwire [9:0][9:0] ret_prevV;
  pwire [9:0][9:0] ret_prevF;
  pwire [9:0] xbreak0;
  pwire [9:0] break_;
  pwire [9:0][5:0] rT;
  pwire [8:0][5:0] rTe;
  pwire [9:0] jump0_misPred;
  pwire [9:0] jump1_misPred;
  pwire indirMismatch;
  pwire indir_error;
  pwire has_break;
  pwire has_xbreak0;

  pwire [3:0] retcnt_d;
  
  pwire [BOB_WIDTH-1:0] bob_wdata;
  pwire [BOB_WIDTH-1:0] bob_rdata;

  pwire [27:0] sched_rst_cnt;
  pwire [27:0] sched_rst_cnt_d;
  
  pwire [9:0][8:0] IPOff;
  pwire [9:0][2:0] magicO;
  pwire [8:0] tireG;
  pwire [8:0] tireV;
  pwire [8:0] tireF;
  pwire [8:0] no_tire;

  pwire [8:0][8:0] tire_rF;
  pwire [8:0][8:0] tire_rFl;

  pwire [4:0] jump0Type;
  pwire [3:0] jump0Pos;
  pwire [42:0] jump0IP;
  pwire [4:0] jump1Type;
  pwire [3:0] jump1Pos;
  pwire [42:0] jump1IP;
  
  pwire       jump0BtbWay;
  pwire [1:0] jump0JmpInd;
  pwire [7:0] jump0GHT;
  pwire [15:0] jump0GHT2;
  pwire        jump0Val;
  pwire       jump1BtbWay;
  pwire [1:0] jump1JmpInd;
  pwire [7:0] jump1GHT;
  pwire [15:0] jump1GHT2;
  pwire        jump1Val;
  pwire [1:0] jump0SC;
  pwire jump0Miss;
  pwire jump0BtbOnly;
  pwire [1:0] jump1SC;
  pwire jump1Miss;
  pwire jump1BtbOnly;

  pwire jump0_taken;
  pwire [5:0] jump0_flags;
  pwire jump1_taken;
  pwire [5:0] jump1_flags;

  pwire [9:0][5:0] nextFlags;
  
  pwire [42:0] breakIP;
  pwire [62:43] bbaseIP;
  pwire [9:0][62:0] nextIP;
  pwire [19:0] jupd0_IP;
  pwire [19:0] jupd1_IP;
  pwire lastIP;

  pwire both_threads;
  pwire thread0,thread1;

  pwire [10:0] excpt_fpu;

  pwire tire_thread;
  pwire tire_thread_reg;

  pwire [62:0] exceptIP_d;
  pwire except_thread_d=tire_thread_reg;
  pwire except_both_d=both_threads;
  pwire except_d;
  pwire [15:0] proc_d;
  pwire [3:0] except_attr_d;

  pwire [5:0] flags_d;
  pwire  [5:0] flags[1:0];

 // pwire dotire_d;
  pwire has_some,has_some2;

  pwire [5:0] tire_addr;
  pwire  [5:0] tire_addr_reg;

  pwire [64:0] indir_IP;
  pwire indir_ready;
  pwire has_indir;
  pwire i_has_indir;
  pwire [42:0] takenIP;

  pwire [3:0] attr;
  pwire [3:0] jump0Attr;
  pwire [3:0] jump1Attr;
  pwire jump0CLP;
  pwire jump1CLP;

  pwire [5:0] initcount;
  pwire [5:0] initcount_d;
  pwire init;

  pwire [62:0] excpt_handlerIP;
  pwire [7:0] excpt_code;
  pwire jump0Pred;
  pwire jump1Pred;

  pwire [15:0] update_ght_addr_j0;
  pwire [15:0] update_ght_addr_j1;
  pwire [15:0] update_ght2_addr_j0;
  pwire [15:0] update_ght2_addr_j1;
  pwire [12:0] update_btb_addr_j0;
  pwire [12:0] update_btb_addr_j1;
  pwire [1:0]  update_sc_j0;
  pwire [1:0]  update_sc_j1;

  pwire [9:0] jump0_here;
  pwire [9:0] jump1_here;
  pwire jump0_in,jump1_in;

  pwire [9:0] tk_after;
  pwire [9:0] afterTick;

  pwire [9:0] isGen;
  pwire [9:0] isVec;
  pwire [9:0] isFPU;
  
  pwire [9:0] rgen;
  pwire [9:0] rvec;
  pwire [9:0] last_instr;

  pwire [64:0] base_add;
  pwire is_after_spec;
  pwire [9:0] rd_after_spec;
  pwire [62:0] baseIP;
  pwire [62:0] baseIP_d;
  
  pwire [8:0] retclrP;

  pwire [3:0] jump0JMask;
  pwire [3:0] jump1JMask;
  pwire [3:0] jump0Mask;
  pwire [3:0] jump1Mask;
      
  pwire [9:0] flag_last;
  pwire flag_has;
  pwire [9:0] lfl;
  pwire lfl_has;
  pwire has_someX;

  pwire [19:0] jump0BND=20'hf80ff;
  pwire [19:0] jump1BND=20'hf80ff;

  pwire [15:0] msrss_no_d;
  pwire msrss_thread_d;
  pwire msrss_en_d;
  pwire [64:0] msrss_data_d;

  pwire [42:0] archReg_xcpt_retIP		[1:0];
  pwire [62:0] archReg_xcpt_handlerIP;
  pwire [15:0] archReg_proc		[1:0];
 // pwire [7:0]  archReg_xcpt_code		[1:0];
  
  generate
    genvar k,j;
    for(k=0;k<10;k=k+1) begin : jumps_gen
      assign flagSet[k]=ret_data[k][`except_setsFlags];
      assign flagSetY[k]=ret_data[k][`except_setsFlags] && !(pwh#(32)::cmpEQ(k,jump0Ind) && jump0CLP) && !(pwh#(32)::cmpEQ(k,jump1Ind) && jump1CLP);
      assign pending[k]=ret_data[k][`except_status]==2'd0 && !(mem_match & mem_II_bits_ret[k]);
      assign exceptn[k]=(ret_data[k][`except_status]==2'd1 && ~ret_data[k][14]) || (mem_match & mem_II_bits_except[k]) || GORQ_enX_reg
          ||(break_jump0&jump0_attr[`attr_vec]||break_jump1&jump1_attr[`attr_vec]);
      assign replay[k]=(ret_data[k][`except_status]==2'd1 && ret_data[k][14]) || (mem_match & mem_II_bits_ldconfl[k]);
      assign replay_safe[k]=(ret_data[k][`except_status]==2'd1 && ret_data[k][14]) || (mem_match & mem_II_bits_waitconfl[k]);
      assign done[k]=ret_data[k][`except_status]==2'd2 || (mem_match & mem_II_bits_fine[k] & mem_II_bits_ret[k]);
      assign fpudone[k]=ret_data[k][`except_status]==2'd3;//with exception flags set
          
      assign btb_miss[k]=(pwh#(32)::cmpEQ(jump0Pos,k) && jump0Miss) || (pwh#(32)::cmpEQ(jump1Pos,k) && jump1Miss);
      assign jump0_here[k]=pwh#(32)::cmpEQ(jump0Pos,k);
      assign jump1_here[k]=pwh#(32)::cmpEQ(jump1Pos,k);
      pwire [9:0] flag_last;
      pwire flag_has;
      /* verilator lint_off WIDTH */
      if (k>0) bit_find_last_bit #(10) lastfl_mod({10'b0,flagSet[k-1:0]},flag_last,flag_has);
      /* verilator lint_on WIDTH */
      if (k>0) assign lfl=xbreak0[k] ? flag_last : 10'bz;
      else assign lfl=xbreak0[k] ? 10'b0 : 10'bz;
      if (k>0) assign lfl_has=xbreak0[k] ? flag_has : 1'bz;
      else assign lfl_has=xbreak0[k] ? 1'b0 : 1'bz;
      if (k>0) assign jump0_in=xbreak0[k] ? |jump0_here[k-1:0] : 1'bz;
      else assign jump0_in=xbreak0[k] ? 1'b0 : 1'bz;
      if (k>0) assign jump1_in=xbreak0[k] ? |jump1_here[k-1:0] : 1'bz;
      else assign jump1_in=xbreak0[k] ? 1'b0 : 1'bz;
      assign break_pending=break_[k] ? pending[k] : 1'bz;
      if (k>0) assign break_prejmp_tick=break_[k] ? afterTick[k-1] & ~tk_after[k-1] : 1'bz;
      else assign break_prejmp_tick=break_[0] ? 1'b0 : 1'bz;
      if (k>0) assign break_prejmp_ntick=break_[k] ? ~afterTick[k-1] &~tk_after[k-1] : 1'bz;
      else assign break_prejmp_ntick=break_[0] ? 1'b1 : 1'bz;
      assign break_exceptn=break_[k] ? exceptn[k] : 1'bz;
      assign break_replay=break_[k] ? replay[k] : 1'bz;
      assign break_replayS=break_[k] ? replay_safe[k] : 1'bz;
      assign break_jump0=break_[k] ? jump0_misPred[k] & done[k] : 1'bz;
      assign break_jump1=break_[k] ? jump1_misPred[k] & done[k] : 1'bz;
      if (k<9) assign flags_d=xbreak0[k+1] ? nextFlags[k] : 6'bz; 
      else assign flags_d=has_xbreak0 ? 6'bz : nextFlags[9];

      assign afterTick[k]=IPOff[k][8];
     
      pwire [8:0] flE; 
      for(j=0;j<9;j=j+1) begin : ret_gen
	  pwire reteq=ret[j]==k;
          assign ret_prev[j][k]=rT[j]==rT[k] && ~xbreak[k] && k>j;
          assign ret_prevG[j][k]=ret_prev[j][k] && isGen[j] && isGen[k];
          assign ret_prevV[j][k]=ret_prev[j][k] && isVec[j] && isVec[k];
          assign ret_prevF[j][k]=ret_prev[j][k] && isFPU[j] && isFPU[k];
          
	  assign tireG[j]=reteq ? ~xbreak[k]  && ret_prevG[k]==0 && isGen[k] && ~&rT[k] : 1'bz; 
          assign tireV[j]=reteq ? ~xbreak[k]  && ret_prevV[k]==0 && isVec[k] : 1'bz; 
          assign tireF[j]=reteq ? ~xbreak[k]  && ret_prevF[k]==0 && isFPU[k] : 1'bz;

          assign rTe[j]=reteq ? rT[k] : 6'bz;

          assign flE=reteq && lfl[k] ? tire_rFl[j] : 9'bz;	  
      end
      assign flE=~lfl[k] ? 9'b0 : 9'bz;
      assign flTE=lfl[k] ? flE : 9'bz;
  
      if (k<9) begin
          assign no_tire[k]=ret[k]==4'hf;
          assign tireG[k]=no_tire[k] ? 1'b0 : 1'bz;
          assign tireV[k]=no_tire[k] ? 1'b0 : 1'bz;
          assign tireF[k]=no_tire[k] ? 1'b0 : 1'bz;
          assign rTe[k]=no_tire[k] ? 6'd0 : 6'bz;
          //assign rFe[k]=no_tire[k] ? 9'd0 : 9'bz;
      end

      assign excpt_code=break_[k]& & ~GORQ_enX_reg|(break_jump0&jump0_attr[`attr_vec]||break_jump1&jump1_attr[`attr_vec]) ? ret_data[k][10:3] : 8'bz;
      assign excpt_code=GORQ_enX_reg ? 62 : 8'bz;
      assign excpt_code=(break_jump0&jump0_attr[`attr_vec]||break_jump1&jump1_attr[`attr_vec]) ? 61 : 8'bz;
      
      cntrl_jump_upto #(k) j0_mod(
      .flagSet(flagSet&((10'b1<<(k+1))-10'b1)),
      .prevFlags(flags[tire_thread_reg]),
      .jumpType(jump0Type),
      .jumpIndex(jump0Pos),
      .jumpPredTk(jump0Pred),
      .jumpTbufMiss(jump0Miss),
      .indirMismatch(indirMismatch&~indir_error),
      .jumpMisPred(jump0_misPred[k]),
      .jumpTaken(jump0_taken),
      .flagOut(jump0_flags),
      .flagOutN(nextFlags[k]),
      .flags0(ret_data[0][`except_flags]),
      .flags1(ret_data[1][`except_flags]),   
      .flags2(ret_data[2][`except_flags]),
      .flags3(ret_data[3][`except_flags]),
      .flags4(ret_data[4][`except_flags]),
      .flags5(ret_data[5][`except_flags]),
      .flags6(ret_data[6][`except_flags]),
      .flags7(ret_data[7][`except_flags]),
      .flags8(ret_data[8][`except_flags]),
      .flags9(ret_data[9][`except_flags])
      );

      cntrl_jump_upto #(k) j1_mod(
      .flagSet(flagSet&((10'b1<<(k+1))-10'b1)),
      .prevFlags(flags[tire_thread_reg]),
      .jumpType(jump1Type),
      .jumpIndex(jump1Pos),
      .jumpPredTk(jump1Pred),
      .jumpTbufMiss(jump1Miss),
      .indirMismatch(indirMismatch&~indir_error),
      .jumpMisPred(jump1_misPred[k]),
      .jumpTaken(jump1_taken),
      .flagOut(jump1_flags),
      .flagOutN(),
      .flags0(ret_data[0][`except_flags]),
      .flags1(ret_data[1][`except_flags]),      
      .flags2(ret_data[2][`except_flags]),
      .flags3(ret_data[3][`except_flags]),
      .flags4(ret_data[4][`except_flags]),
      .flags5(ret_data[5][`except_flags]),
      .flags6(ret_data[6][`except_flags]),
      .flags7(ret_data[7][`except_flags]),
      .flags8(ret_data[8][`except_flags]),
      .flags9(ret_data[9][`except_flags])
      );

      pwire [62:0] from_IP;
      assign from_IP=(~tk_after[k]) ? baseIP[62:0] : 63'bz;
      assign from_IP=(tk_after[k] & jump0Pred) ? {jump0BND,jump0IP[42:0]} : 63'bz;
      assign from_IP=(tk_after[k] & jump1Pred) ? {jump1BND,jump1IP[42:0]} : 63'bz;

      assign breakIP=break_[k]||(break_jump0&jump0_attr[`attr_vec]&(pwh#(32)::cmpEQ(k,jump0_ind))||break_jump1&jump1_attr[`attr_vec] & (pwh#(32)::cmpEQ(k,jump1_ind)))
          &~IRQ_enX_reg ? nextIP[k][42:0] : 43'bz;
      assign bbaseIP=break_[k]||(break_jump0&jump0_attr[`attr_vec]&(pwh#(32)::cmpEQ(k,jump0_ind))||break_jump1&jump1_attr[`attr_vec] & (pwh#(32)::cmpEQ(k,jump1_ind)))
          &~IRQ_enX_reg ? nextIP[k][62:43] : 20'bz;

      assign lastIP=break_[k] ? last_instr[k] : 1'bz;
      assign is_after_spec=break_[k] ? rd_after_spec[k] : 1'bz;

      cntrl_get_IP newIP_mod(
      .baseIP(from_IP),
      .srcIPOff(IPOff[k]),
      .magicO(magicO[k]),
      .last(last_instr[k]),
      .excpt(exceptn[k]|btb_miss[k]|replay[k]|replay_safe[k]),
      .nextIP(nextIP[k])
      );
  
      cntrl_get_shortIP shortIP_mod(
      .baseIP(from_IP[19:0]),
      .srcIPOff(IPOff[k]),
      .jupd0_IP(jupd0_IP), .jupd0_en(pwh#(32)::cmpEQ(jump0Pos,k)),
      .jupd1_IP(jupd1_IP), .jupd1_en(pwh#(32)::cmpEQ(jump1Pos,k))
      );
    end
  endgenerate

  assign jupd0_IP=(pwh#(4)::cmpEQ(jump0Pos,4'hf)) ? 20'b0 : 20'bz;
  assign jupd1_IP=(pwh#(4)::cmpEQ(jump1Pos,4'hf)) ? 20'b0 : 20'bz;
  
  assign breakIP=has_break && ~IRQ_enX_reg ? 43'bz : nextIP[0][42:0];
  assign bbaseIP=has_break && ~IRQ_enX_reg ? 20'bz : nextIP[0][62:43];
  assign excpt_code=has_break && ~GORQ_enX_reg ? 8'bz : 8'b0;
  assign lastIP=has_break ? 1'bz : 1'b0;
      
  bit_find_last_bit #(10) lastfl_mod(flagSet,flag_last,flag_has);
  
  assign lfl=has_xbreak0 ? 10'bz : flag_last;
  assign lfl_has=has_xbreak0 ? 1'bz : flag_has;

  assign flTE=lfl_has ? 9'bz : 9'b0;

  assign jump0_in=has_xbreak0 ? 1'bz : jump0Pos!=4'hf;
  assign jump1_in=has_xbreak0 ? 1'bz : jump1Pos!=4'hf;

  assign break_prejmp_ntick=(~has_break) ? afterTick==0 && tk_after==0 : 1'bz;
  assign break_prejmp_tick=(~has_break) ? afterTick!=0 && tk_after==0 : 1'bz;

  assign tire_rF[0]=tire0_rF;
  assign tire_rF[1]=tire1_rF;
  assign tire_rF[2]=tire2_rF;
  assign tire_rF[3]=tire3_rF;
  assign tire_rF[4]=tire4_rF;
  assign tire_rF[5]=tire5_rF;
  assign tire_rF[6]=tire6_rF;
  assign tire_rF[7]=tire7_rF;
  assign tire_rF[8]=tire8_rF;

  assign jump0JMask=(pwh#(2)::cmpEQ(jump0JmpInd,2'd0) && ~jump0_taken) ? 4'he|{4{lastIP}} : 4'bz;
  assign jump0JMask=(pwh#(2)::cmpEQ(jump0JmpInd,2'd1) && ~jump0_taken) ? 4'hc|{4{lastIP}} : 4'bz;
  assign jump0JMask=(pwh#(2)::cmpEQ(jump0JmpInd,2'd2) && ~jump0_taken) ? 4'h8|{4{lastIP}} : 4'bz;
  assign jump0JMask=(pwh#(2)::cmpEQ(jump0JmpInd,2'd3) && ~jump0_taken) ? 4'h0|{4{lastIP}} : 4'bz;
  assign jump0JMask=(jump0_taken) ? jump0Mask : 4'bz;
  
  assign jump1JMask=(pwh#(2)::cmpEQ(jump1JmpInd,2'd0) && ~jump1_taken) ? 4'he|{4{lastIP}} : 4'bz;
  assign jump1JMask=(pwh#(2)::cmpEQ(jump1JmpInd,2'd1) && ~jump1_taken) ? 4'hc|{4{lastIP}} : 4'bz;
  assign jump1JMask=(pwh#(2)::cmpEQ(jump1JmpInd,2'd2) && ~jump1_taken) ? 4'h8|{4{lastIP}} : 4'bz;
  assign jump1JMask=(pwh#(2)::cmpEQ(jump1JmpInd,2'd3) && ~jump1_taken) ? 4'h0|{4{lastIP}} : 4'bz;
  assign jump1JMask=(jump1_taken) ? jump1Mask : 4'bz;

  assign update_ght_addr_j0[15:8]=jupd0_IP[19:12]^jump0GHT;
  assign update_ght_addr_j0[7:6]=jupd0_IP[11:10]^jump0JmpInd;
  assign update_ght_addr_j0[5:0]=jupd0_IP[9:4];

  assign update_ght2_addr_j0=jupd0_IP[19:4]^jump0GHT2^{8'b0,jump0JmpInd,6'b0};
  assign update_ght2_addr_j1=jupd1_IP[19:4]^jump1GHT2^{8'b0,jump1JmpInd,6'b0};
  
  assign update_ght_addr_j1[15:8]=jupd1_IP[19:12]^jump1GHT;
  assign update_ght_addr_j1[7:6]=jupd1_IP[11:10]^jump1JmpInd;
  assign update_ght_addr_j1[5:0]=jupd1_IP[9:4];
  
  assign update_btb_addr_j1[12:11]=jump1JmpInd;
  assign update_btb_addr_j1[0]=jump1BtbWay;
  assign update_btb_addr_j1[10:1]=jupd1_IP[13:4];
  
  assign update_btb_addr_j0[12:11]=jump0JmpInd;
  assign update_btb_addr_j0[0]=  jump0BtbWay;
  assign update_btb_addr_j0[10:1]=jupd0_IP[13:4];
  
  assign excpt_handlerIP=archReg_xcpt_handlerIP;
      
  assign isGen=rgen & ~rvec;
  assign isVec=rvec;
  assign isFPU=rgen~^rvec;
  
  assign ret_prev[9]=10'b0;
  assign ret_prevG[9]=10'b0;
  assign ret_prevV[9]=10'b0;
  assign ret_prevF[9]=10'b0;
//warning: trace not yet handled
  assign exceptIP_d=((break_jump0&~break_exceptn) & jump0_taken & ~indir_error) ? {jump0BND,jump0IP} : 63'bz;
  assign exceptIP_d=((break_jump1&~break_exceptn) & jump1_taken & ~indir_error) ? {jump1BND,jump1IP} : 63'bz;
  assign exceptIP_d=(indir_error && ((break_jump0&~break_exceptn) & jump0_taken)
    || ((break_jump1&~break_exceptn) & jump1_taken)) ? {excpt_handlerIP[62:43],excpt_handlerIP[42:11],6'd18,5'b0} : 63'bz;
  assign exceptIP_d=((break_jump0&~break_exceptn) && ~jump0_taken && !(jump0Type[4] && jump0Type[2:0]==3'd1)) ? {bbaseIP[62:43],breakIP} : 63'bz;
  assign exceptIP_d=((break_jump1&~break_exceptn) & ~jump1_taken && !(jump1Type[4] && jump1Type[2:0]==3'd1)) ? {bbaseIP[62:43],breakIP} : 63'bz;
  assign exceptIP_d=((break_jump0&~break_exceptn) && ~jump0_taken && (pwh#(5)::cmpEQ(jump0Type,5'h11))) ? indir_IP[63:1] : 63'bz;
  assign exceptIP_d=((break_jump1&~break_exceptn) & ~jump1_taken && (pwh#(5)::cmpEQ(jump1Type,5'h11))) ? indir_IP[63:1] : 63'bz;
  assign exceptIP_d=((break_jump0&~break_exceptn) && ~jump0_taken && (pwh#(5)::cmpEQ(jump0Type,5'h19))) ? 
    {indir_IP[59:50],2'b0,indir_IP[49:45],2'b0,indir_IP[44],indir_IP[43:5],indir_IP[4:1]^{3'b0,&indir_IP[4:1]}} : 63'bz;
  assign exceptIP_d=((break_jump1&~break_exceptn) & ~jump1_taken && (pwh#(5)::cmpEQ(jump1Type,5'h19))) ? 
    {indir_IP[59:50],2'b0,indir_IP[49:45],2'b0,indir_IP[44],indir_IP[43:5],indir_IP[4:1]^{3'b0,&indir_IP[4:1]}} : 63'bz;
  assign exceptIP_d=(break_exceptn) ? {excpt_handlerIP[62:43],excpt_handlerIP[42:11],excpt_code[5:0],5'b0} : 63'bz;
  assign exceptIP_d=(break_replay|break_replayS) ? {bbaseIP[62:43],breakIP} : 63'bz;
  assign exceptIP_d=(break_pending | ~has_break) ? 63'b0 : 63'bz;

  assign except_attr_d=((break_jump0&~break_exceptn) & jump0_taken) ? jump0Attr : 4'bz;
  assign except_attr_d=((break_jump1&~break_exceptn) & jump1_taken) ? jump1Attr : 4'bz;
  assign except_attr_d=((break_jump0&~break_exceptn) && ~jump0_taken && !(jump0Type[4] && jump0Type[2:0]==3'd1)) ? attr : 4'bz;
  assign except_attr_d=((break_jump1&~break_exceptn) & ~jump1_taken && !(jump1Type[4] && jump1Type[2:0]==3'd1)) ? attr : 4'bz;
  assign except_attr_d=((break_jump0&~break_exceptn) && ~jump0_taken && (pwh#(5)::cmpEQ(jump0Type,5'h11))) ? attr : 4'bz;
  assign except_attr_d=((break_jump1&~break_exceptn) & ~jump1_taken && (pwh#(5)::cmpEQ(jump1Type,5'h11))) ? attr : 4'bz;
  assign except_attr_d=((break_jump0&~break_exceptn) && ~jump0_taken && (pwh#(5)::cmpEQ(jump0Type,5'h19))) ? {indir_IP[60],indir_IP[61],indir_IP[62],indir_IP[63]} : 4'bz;
  assign except_attr_d=((break_jump1&~break_exceptn) & ~jump1_taken && (pwh#(5)::cmpEQ(jump1Type,5'h19))) ? {indir_IP[60],indir_IP[61],indir_IP[62],indir_IP[63]} : 4'bz;
  assign except_attr_d=(break_exceptn) ? {1'b0,1'b0,1'b0,1'b1} : 4'bz;
  assign except_attr_d=(break_replay|break_replayS) ? attr : 4'bz;
  assign except_attr_d=(break_pending | ~has_break) ? attr : 4'bz;//?attr2?

  assign msrss_no_d=((break_jump0&~break_exceptn) && pwh#(5)::cmpEQ(jump0Type,5'b11001)) ? {tire_thread_reg,jump0IP[14:0]} : 16'bz;
  assign msrss_no_d=((break_jump1&~break_exceptn) && pwh#(5)::cmpEQ(jump1Type,5'b11001)) ? {tire_thread_reg,jump1IP[14:0]} : 16'bz;
  assign msrss_no_d=((break_jump0&~break_exceptn) && jump0Type!=5'b11001 && jump0_taken) ||
    ((break_jump1&~break_exceptn) && jump1Type!=5'b11001 && jump1_taken) ? {tire_thread_reg,15'd`csr_last_jmp} : 16'bz;
  assign msrss_no_d=(break_exceptn) ? {tire_thread_reg,15'd`csr_retIP} : 16'bz;
  assign msrss_no_d=(~(break_jump0&~break_exceptn) & ~(break_jump1&~break_exceptn) & ~break_exceptn) ? {tire_thread_reg,GORQ_en_reg? 15'd`csr_GORQ_send : 15'd`csr_excpt_fpu} : 16'bz;

  assign msrss_xdata_d=((break_jump0&~break_exceptn) && pwh#(5)::cmpEQ(jump0Type,5'b11001)) ? {jump0IP[63:40]} : 24'bz;
  assign msrss_xdata_d=((break_jump1&~break_exceptn) && pwh#(5)::cmpEQ(jump1Type,5'b11001)) ? {jump1IP[63:40]} : 24'bz;
  assign msrss_xdata_d=((break_jump0&~break_exceptn) && jump0Type!=5'b11001 && jump0_taken) ||
    ((break_jump1&~break_exceptn) && jump1Type!=5'b11001 && jump1_taken) ? {tire_thread_reg,23'd`csr_last_jmp} : 24'bz;
  assign msrss_xdata_d=(break_exceptn) ? {tire_thread_reg,23'd`csr_retIP} : 24'bz;
  assign msrss_xdata_d=(~(break_jump0&~break_exceptn) & ~(break_jump1&~break_exceptn) & ~break_exceptn) ? {tire_thread_reg,23'd`csr_excpt_fpu} : 24'bz;
  assign msrss_en_d=((break_jump0&~break_exceptn)) ? (pwh#(5)::cmpEQ(jump0Type,5'b11001) || jump0_taken) && has_some && ~mem_II_stall : 1'bz;
  assign msrss_en_d=((break_jump1&~break_exceptn)) ? (pwh#(5)::cmpEQ(jump1Type,5'b11001) || jump1_taken) && has_some && ~mem_II_stall : 1'bz;
  assign msrss_en_d=(break_exceptn) ? has_some & ~mem_II_stall : 1'bz;
  assign msrss_en_d=(~(break_jump0&~break_exceptn) & ~(break_jump1&~break_exceptn) & ~break_exceptn) ? 1'b1 : 1'bz;
  assign msrss_data_d=(break_exceptn) ? {1'b0,attr[0],attr[1],is_after_spec,attr[3],bbaseIP[62:53],bbaseIP[50:46],bbaseIP[43],breakIP,1'b0} : 65'bz;
  assign msrss_data_d=(~break_exceptn && ((break_jump0&~break_exceptn)&jump0_taken || (break_jump1&~break_exceptn)&jump1_taken) && has_some) ? 
    {1'b0,attr[0],attr[1],is_after_spec,attr[3],bbaseIP[62:53],bbaseIP[50:46],bbaseIP[43],breakIP,1'b0} : 65'bz;
  assign msrss_data_d=(~break_exceptn & ~((break_jump0&~break_exceptn)&jump0_taken || (break_jump1&~break_exceptn)&jump1_taken)) ? {48'b0,GORQ_en_reg ? GORQ_data_reg : {6'b0,excpt_fpu}} : 65'bz;
  assign baseIP_d=(jump0_in & jump0_taken &~break_exceptn &~break_replay &~break_replayS) ? {jump0BND,jump0IP} : 6_3'bz;
  assign baseIP_d=(jump1_in & jump1_taken &~break_exceptn &~break_replay &~break_replayS) ? {jump1BND,jump1IP} : 63'bz;
  assign baseIP_d=(break_exceptn) ? {excpt_handlerIP[62:11],excpt_code[5:0],5'b0} : 63'bz;
  assign baseIP_d=break_replay || ~(jump0_in&jump0_taken) & ~(jump1_in&jump1_taken) & ((break_jump0&~break_exceptn)||
      (break_jump1&~break_exceptn)) ? {baseIP[62:43],breakIP} : 63'bz;
  assign baseIP_d=break_prejmp_ntick & ~(jump0_in&jump0_taken) & ~(jump1_in&jump1_taken) 
      & ~(break_jump0&~break_exceptn) & ~(break_jump1&~break_exceptn) & ~break_exceptn & ~break_replay ? baseIP : 63'bz;
  assign baseIP_d[7:0]=break_prejmp_tick & ~(jump0_in&jump0_taken) & ~(jump1_in&jump1_taken)  
      & ~(break_jump0&~break_exceptn) & ~(break_jump1&~break_exceptn) & ~break_exceptn & ~break_replay & !break_replayS ? baseIP[7:0] : 8'bz;
  assign baseIP_d[62:43]=break_prejmp_tick & ~(jump0_in&jump0_taken) & ~(jump1_in&jump1_taken)  
      & ~(break_jump0&~break_exceptn) & ~(break_jump1&~break_exceptn) & ~break_exceptn & ~break_replay & !break_replayS ? baseIP[62:43] : 20'bz;

  assign jump0_taken=(pwh#(4)::cmpEQ(jump0Pos,4'hf)) ? 1'b0 : 1'bz;
  assign jump0_flags=(pwh#(4)::cmpEQ(jump0Pos,4'hf)) ? 6'b0 : 6'bz;
  assign jump1_taken=(pwh#(4)::cmpEQ(jump1Pos,4'hf)) ? 1'b0 : 1'bz;
  assign jump1_flags=(pwh#(4)::cmpEQ(jump1Pos,4'hf)) ? 6'b0 : 6'bz;

  assign break_pending=(has_break) ? 1'bz : 1'b0;
  assign break_exceptn=(has_break) ? 1'bz : IRQ_enX_reg||(break_jump0&jump0_attr[`attr_vec]||break_jump1&jump1_attr[`attr_vec]);
  assign break_replay=(has_break) ? 1'bz : 1'b0;
  assign break_replayS=(has_break) ? 1'bz : 1'b0;
  assign break_jump0=(has_break) ? 1'bz : 1'b0;
  assign break_jump1=(has_break) ? 1'bz : 1'b0;
  
  assign flags_d=xbreak0[0] ? flags[tire_thread_reg] : 6'bz;

  assign tireG[0]=(ret[0]==4'hf) ? 1'b0 : 1'bz;
  assign tireV[0]=(ret[0]==4'hf) ? 1'b0 : 1'bz;
  assign tireF[0]=(ret[0]==4'hf) ? 1'b0 : 1'bz;
  
  assign proc_d=(pwh#(5)::cmpEQ(jump0Type,5'h1e) || pwh#(5)::cmpEQ(jump1Type,5'h1e)) ? indir_IP[15:0] : archReg_proc[tire_thread_reg];
	 
  assign bob_wdata[`bob_ret0_8]={iret8,iret7,iret6,iret5,
	 iret4,iret3,iret2,iret1,iret0};
  assign {ret[8],ret[7],ret[6],ret[5],ret[4],ret[3],ret[2],ret[1],ret[0]}=
	  bob_rdata[`bob_ret0_8];  
  
  assign bob_wdata[`bob_frr]=iret_clr;
  assign retclrP=bob_rdata[`bob_frr];

  assign bob_wdata[`bob_aspl]={instr9_after_spec,instr8_after_spec,instr7_after_spec,
     instr6_after_spec,instr5_after_spec,instr4_after_spec,instr3_after_spec,
     instr2_after_spec,instr1_after_spec,instr0_after_spec};
  assign bob_wdata[`bob_regs]={instr9_rT|{6{~instr9_wren}},instr8_rT|{6{~instr8_wren}},
         instr7_rT|{6{~instr7_wren}},instr6_rT|{6{~instr6_wren}},instr5_rT|{6{~instr5_wren}},
	 instr4_rT|{6{~instr4_wren}},instr3_rT|{6{~instr3_wren}},instr2_rT|{6{~instr2_wren}},
         instr1_rT|{6{~instr1_wren}},instr0_rT|{6{~instr0_wren}}};
  assign {rT[9],rT[8],rT[7],rT[6],rT[5],rT[4],rT[3],rT[2],rT[1],rT[0]}=
	  bob_rdata[`bob_regs];
  
  assign bob_wdata[`bob_freeregs]={iret8_rF,iret7_rF,iret6_rF,iret5_rF,
	  iret4_rF,iret3_rF,iret2_rF,iret1_rF,iret0_rF};
  assign bob_wdata[`bob_freeregsS]={iret8_rFl,iret7_rFl,iret6_rFl,iret5_rFl,
	  iret4_rFl,iret3_rFl,iret2_rFl,iret1_rFl,iret0_rFl};
  assign rd_after_spec=bob_rdata[`bob_aspl];
  assign bob_wdata[`bob_attr]=instr_attr;
  assign attr=bob_rdata[`bob_attr];

  assign {tire8_rF[8:4],tire7_rF[8:4],tire6_rF[8:4],tire5_rF[8:4],
	  tire4_rF[8:4],tire3_rF[8:4],tire2_rF[8:4],tire1_rF[8:4],tire0_rF[8:4]}=
	  bob_rdata[`bob_freeregs];
  assign {tire_rFl[8][8:4],tire_rFl[7][8:4],tire_rFl[6][8:4],tire_rFl[5][8:4],
	  tire_rFl[4][8:4],tire_rFl[3][8:4],tire_rFl[2][8:4],tire_rFl[1][8:4],tire_rFl[0][8:4]}=
	  bob_rdata[`bob_freeregsS];

  assign bob_wdata[`bob_ipOff0_9]={instr9_IPOff,instr8_IPOff,instr7_IPOff,instr6_IPOff,
	  instr5_IPOff,instr4_IPOff,instr3_IPOff,instr2_IPOff,instr1_IPOff,instr0_IPOff};
  assign {IPOff[9],IPOff[8],IPOff[7],IPOff[6],IPOff[5],IPOff[4],IPOff[3],IPOff[2],IPOff[1],IPOff[0]}=
	  bob_rdata[`bob_ipOff0_9];

  assign bob_wdata[`bob_rgen]={instr9_gen,instr8_gen,instr7_gen,instr6_gen,instr5_gen,
	  instr4_gen,instr3_gen,instr2_gen,instr1_gen,instr0_gen};
  assign bob_wdata[`bob_rvec]={instr9_vec,instr8_vec,instr7_vec,instr6_vec,instr5_vec,
	  instr4_vec,instr3_vec,instr2_vec,instr1_vec,instr0_vec};
  assign rgen=bob_rdata[`bob_rgen];
  assign rvec=bob_rdata[`bob_rvec];
 
  assign bob_wdata[`bob_afterTk]=itk_after;
  assign tk_after=bob_rdata[`bob_afterTk];

  assign bob_wdata[`bob_pred]={iJump1Taken,iJump0Taken};
  assign {jump1Pred,jump0Pred}=bob_rdata[`bob_pred];

  assign bob_wdata[`bob_attrJ0]=iJump0Attr;
  assign jump0Attr=bob_rdata[`bob_attrJ0];
  assign bob_wdata[`bob_attrJ1]=iJump1Attr;
  assign jump1Attr=bob_rdata[`bob_attrJ1];

  assign bob_wdata[`bob_j0cloop]=iJump0CLP;
  assign jump0CLP=bob_rdata[`bob_j0cloop];
  assign bob_wdata[`bob_j1cloop]=iJump1CLP;
  assign jump1CLP=bob_rdata[`bob_j1cloop];
  
  assign bob_wdata[`bob_magicO]={instr9_magic,instr8_magic,instr7_magic,instr6_magic,instr5_magic,
	  instr4_magic,instr3_magic,instr2_magic,instr1_magic,instr0_magic};
  assign {magicO[9],magicO[8],magicO[7],magicO[6],magicO[5],magicO[4],magicO[3],magicO[2],magicO[1],magicO[0]}=
	  bob_rdata[`bob_magicO];

  assign bob_wdata[`bob_last]={instr9_last,instr8_last,instr7_last,instr6_last,instr5_last,
	  instr4_last,instr3_last,instr2_last,instr1_last,instr0_last};
  assign last_instr= bob_rdata[`bob_last];
  
  assign bob_wdata[`bob_jump0Type]=ijump0Type;
  assign jump0Type=bob_rdata[`bob_jump0Type];
  assign bob_wdata[`bob_jump1Type]=ijump1Type;
  assign jump1Type=bob_rdata[`bob_jump1Type];
  assign bob_wdata[`bob_jump0Pos]=~ijump0Off;
  assign bob_wdata[`bob_j0GHT2]=ijump0GHT2;
  assign bob_wdata[`bob_j1GHT2]=ijump1GHT2;
  assign jump0GHT2=bob_rdata[`bob_j0GHT2];
  assign jump1GHT2=bob_rdata[`bob_j1GHT2];
  assign bob_wdata[`bob_j0Val]=ijump0Val;
  assign bob_wdata[`bob_j1Val]=ijump1Val;
  assign jump0Val=bob_rdata[`bob_j0Val];
  assign jump1Val=bob_rdata[`bob_j1Val];

  assign jump0Pos=~bob_rdata[`bob_jump0Pos];
  assign bob_wdata[`bob_jump1Pos]=~ijump1Off;
  assign jump1Pos=~bob_rdata[`bob_jump1Pos];
  assign bob_wdata[`bob_jump0IP]=ijump0IP;
  assign jump0IP=bob_rdata[`bob_jump0IP];
  assign bob_wdata[`bob_jump1IP]=ijump1IP;
  assign jump1IP=bob_rdata[`bob_jump1IP];
  assign bob_wdata[`bob_jump0Mask]=ijump0Mask;
  assign jump0Mask=bob_rdata[`bob_jump0Mask];
  assign bob_wdata[`bob_jump1Mask]=ijump1Mask;
  assign jump1Mask=bob_rdata[`bob_jump1Mask];

  assign bob_wdata[`bob_j0Way]=ijump0BtbWay;
  assign jump0BtbWay=bob_rdata[`bob_j0Way];
  assign bob_wdata[`bob_j1Way]=ijump1BtbWay;
  assign jump1BtbWay=bob_rdata[`bob_j1Way];
  assign bob_wdata[`bob_j0Ind]=ijump0JmpInd;
  assign jump0JmpInd=bob_rdata[`bob_j0Ind];
  assign bob_wdata[`bob_j1Ind]=ijump1JmpInd;
  assign jump1JmpInd=bob_rdata[`bob_j1Ind];
  assign bob_wdata[`bob_j0GHT]=ijump0GHT;
  assign jump0GHT=bob_rdata[`bob_j0GHT];
  assign bob_wdata[`bob_j1GHT]=ijump1GHT;
  assign jump1GHT=bob_rdata[`bob_j1GHT];

  assign bob_wdata[`bob_j0sc]=ijump0SC;
  assign jump0SC=bob_rdata[`bob_j0sc];
  assign bob_wdata[`bob_j1sc]=ijump1SC;
  assign jump1SC=bob_rdata[`bob_j1sc];
  assign bob_wdata[`bob_j0Miss]=ijump0Miss;
  assign jump0Miss=bob_rdata[`bob_j0Miss];
  assign bob_wdata[`bob_j1Miss]=ijump1Miss;
  assign jump1Miss=bob_rdata[`bob_j1Miss];
  assign bob_wdata[`bob_j0BtbOnly]=ijump0BtbOnly;
  assign jump0BtbOnly=bob_rdata[`bob_j0BtbOnly];
  assign bob_wdata[`bob_j1BtbOnly]=ijump1BtbOnly;
  assign jump1BtbOnly=bob_rdata[`bob_j1BtbOnly];

  assign bob_wdata[`bob_Fsimd]=ifsimd;
  
  assign takenIP=(jump0Pred) ? jump0IP : jump1IP;

  assign dotire_d=~break_pending && has_some && ~init && ~mem_II_stall && indir_ready|~has_indir;

  assign has_indir=(jump0Type[4] && jump0Type[2:0]==3'b001 && jump0Pos!=4'hf) || 
    (jump1Type[4] && jump1Type[2:0]==3'b001 && jump1Pos!=4'hf);
  assign i_has_indir=(ijump0Type[4] && ijump0Type[2:0]==3'b001 && ijump0Off!=4'hf) ||
    (ijump1Type[4] && ijump1Type[2:0]==3'b001 && ijump1Off!=4'hf);

  assign indirMismatch=(takenIP!=indir_IP[43:1] || ~indir_IP[64]) && has_indir && indir_ready;

  assign indir_error=indirMismatch&~indir_IP[64];

  assign except_d=(has_break && ~break_pending && has_some && ~init && indir_ready|~has_indir) || (~doRetire && &rst_sched_cnt);
  
  assign tire8_rF[3:0]=4'd8;
  assign tire7_rF[3:0]=4'd7;
  assign tire6_rF[3:0]=4'd6;
  assign tire5_rF[3:0]=4'd5;
  assign tire4_rF[3:0]=4'd4;
  assign tire3_rF[3:0]=4'd3;
  assign tire2_rF[3:0]=4'd2;
  assign tire1_rF[3:0]=4'd1;
  assign tire0_rF[3:0]=4'd0;

  assign tire_rFl[8][3:0]=4'd8;
  assign tire_rFl[7][3:0]=4'd7;
  assign tire_rFl[6][3:0]=4'd6;
  assign tire_rFl[5][3:0]=4'd5;
  assign tire_rFl[4][3:0]=4'd4;
  assign tire_rFl[3][3:0]=4'd3;
  assign tire_rFl[2][3:0]=4'd2;
  assign tire_rFl[1][3:0]=4'd1;
  assign tire_rFl[0][3:0]=4'd0;

  assign mem_match=pwh#(32)::cmpEQ(mem_II_upper,tire_addr_reg) && ~has_stores|(pwh#(32)::cmpEQ(mem_II_upper2,tire_addr_reg))|(mem_II_upper!=mem_II_upper2);
  assign mem_II_upper_out=tire_addr_reg;

  bob_ram bob_mod(
  .clk(clk),
  .read_clkEn(dotire_d||~has_some),
  .read_addr(tire_addr), .read_data(bob_rdata),
  .write_addr(init ? initcount : new_addr), .write_data(bob_wdata&{BOB_WIDTH{~init}}), .write_wen((new_en && ~stall && ~doStall)|init)
  );

  bob_addr addr_mod(
  .clk(clk),
  .rst(rst|(~doRetire && &rst_sched_cnt)),
  .except(except_d),
  .new_en(new_en&~except),
  .new_addr(new_addr),
  .stall(stall),
  .doStall(doStall),
  .hasRetire(has_some),
  .doRetire(dotire_d),
  .retire_addr(tire_addr)
  );

  bob_except xcpt_mod(
  .clk(clk),
  .rst(rst),
  .read_step(dotire_d||~has_some),
  .read_addr(tire_addr),
  .read_data0(ret_data[0]),
  .read_data1(ret_data[1]),
  .read_data2(ret_data[2]),
  .read_data3(ret_data[3]),
  .read_data4(ret_data[4]),
  .read_data5(ret_data[5]),
  .read_data6(ret_data[6]),
  .read_data7(ret_data[7]),
  .read_data8(ret_data[8]),
  .read_data9(ret_data[9]),
  
  .write0_addr(ret0_addr),.write0_data(ret0_data),.write0_wen(ret0_wen),
  .write1_addr(ret1_addr),.write1_data(ret1_data),.write1_wen(ret1_wen),
  .write2_addr(ret2_addr),.write2_data(ret2_data),.write2_wen(ret2_wen),
  .write6_addr(ret0F_addr),.write6_data(ret0F_data),.write6_wen(ret0F_wen),
  .write7_addr(ret1F_addr),.write7_data(ret1F_data),.write7_wen(ret1F_wen),
  .write8_addr(ret2F_addr),.write8_data(ret2F_data),.write8_wen(ret2F_wen),
  .write3_addr(ret3_addr),.write3_data(ret3_data),.write3_wen(ret3_wen),
  .write4_addr(ret4_addr),.write4_data(ret4_data),.write4_wen(ret4_wen),
  .write5_addr(ret5_addr),.write5_data(ret5_data),.write5_wen(ret5_wen),
  
  .writeInit_addr(init ? initcount : new_addr),.writeInit_wen((new_en && ~stall && ~doStall)|init),
  .writeInit_data0({GORQ ? 13'd28 : instr0_err[0] ? {12'd6,instr0_err[1]} : 13'b0,instr0_en|init ? 2'd0|{1'b0,GORQ|instr0_err[0]}:2'd2}),
  .writeInit_data1({GORQ ? 13'd28 : instr1_err[0] ? {12'd6,instr1_err[1]} : 13'b0,instr1_en|init ? 2'd0|{1'b0,GORQ|instr1_err[0]}: 2'd2}),
  .writeInit_data2({GORQ ? 13'd28 : instr2_err[0] ? {12'd6,instr2_err[1]} : 13'b0,instr2_en|init ? 2'd0|{1'b0,GORQ|instr2_err[0]}: 2'd2}),
  .writeInit_data3({GORQ ? 13'd28 : instr3_err[0] ? {12'd6,instr3_err[1]} : 13'b0,instr3_en|init ? 2'd0|{1'b0,GORQ|instr3_err[0]}: 2'd2}),
  .writeInit_data4({GORQ ? 13'd28 : instr4_err[0] ? {12'd6,instr4_err[1]} : 13'b0,instr4_en|init ? 2'd0|{1'b0,GORQ|instr4_err[0]}: 2'd2}),
  .writeInit_data5({GORQ ? 13'd28 : instr5_err[0] ? {12'd6,instr5_err[1]} : 13'b0,instr5_en|init ? 2'd0|{1'b0,GORQ|instr5_err[0]}: 2'd2}),
  .writeInit_data6({GORQ ? 13'd28 : instr6_err[0] ? {12'd6,instr6_err[1]} : 13'b0,instr6_en|init ? 2'd0|{1'b0,GORQ|instr6_err[0]}: 2'd2}),
  .writeInit_data7({GORQ ? 13'd28 : instr7_err[0] ? {12'd6,instr7_err[1]} : 13'b0,instr7_en|init ? 2'd0|{1'b0,GORQ|instr7_err[0]}: 2'd2}),
  .writeInit_data8({GORQ ? 13'd28 : instr8_err[0] ? {12'd6,instr8_err[1]} : 13'b0,instr8_en|init ? 2'd0|{1'b0,GORQ|instr8_err[0]}: 2'd2}),
  .writeInit_data9({GORQ ? 13'd28 : instr9_err[0] ? {12'd6,instr9_err[1]} : 13'b0,instr9_en|init ? 2'd0|{1'b0,GORQ|instr9_err[0]}: 2'd2})
  );

  BOBind indir_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(dotire_d||~has_some),
  .read_addr(tire_addr),
  .read_data(indir_IP),
  .read_ready(indir_ready),
  .write_addr(init ? initcount : ret5_addr[9:4]),
  .write_data(ret5_IP & {65{~init}}),
  .write_wen(ret5_wen & ret5_IP_en || init),
  .writeI_addr(init ? initcount : new_addr),
  .writeI_ready(~i_has_indir|init),
  .writeI_wen((new_en && ~stall && ~doStall)|init)
  );
  
  cntrl_get_retcnt cret_mod({ret[8]!=4'hf,ret[7]!=4'hf,ret[6]!=4'hf,ret[5]!=4'hf,ret[4]!=4'hf,
    ret[3]!=4'hf,ret[2]!=4'hf,ret[1]!=4'hf,ret[0]!=4'hf},retcnt_d);

  adder_inc #(6) initAdd_mod(initcount,initcount_d,1'b1,);
  
  add_addrcalc baseAdd_mod(
  {1'b1,baseIP[62:8],9'b0},64'h100,65'b0,
  base_add,
  ,//sec
  ,//ndiff
  1'b1,
  4'h1,
  2'h0
  );

  assign baseIP_d[62:8]=break_prejmp_tick & ~(jump0_in&jump0_taken) &~(jump1_in&jump1_taken) & ~break_exceptn ? base_add[63:9] : 55'bz;

  bit_find_first_bit #(10) break_mod(~(done|fpudone)|jump0_misPred|jump1_misPred,break_,has_break);
  bit_find_first_bit_tail #(10) xbreak_mod(~(done|fpudone)|{jump0_misPred[8:0]|jump1_misPred[8:0],1'b0},xbreak,has_xbreak);
  bit_find_first_bit #(10) xbreak0_mod(~(done|fpudone)|{jump0_misPred[8:0]|jump1_misPred[8:0],1'b0},xbreak0,has_xbreak0);

  sc_update sc0_mod(jump0SC,jump0_taken,update_sc_j0);
  sc_update sc1_mod(jump1SC,jump1_taken,update_sc_j1);

  always @(posedge clk) begin
      if (rst) begin
	  init<=1'b1;
	  initcount<=6'b0;
      end else if (init) begin
	  initcount<=initcount_d;
	  if (pwh#(6)::cmpEQ(initcount,6'd47)) init<=1'b0;
      end
      if (rst) begin
          sched_rst_cnt<=0;
          do_sched_reset<=0;
      end else if (!doRetire && !except) begin
          sched_rst_cnt<=sched_rst_cnt_d;
          if (&sched_rst_cnt) do_sched_reset<=1'b1;
          if (sched_rst_cnt==0) do_sched_reset<=1'b0;
      end else begin
          sched_rst_cnt<=0;
          do_sched_reset<=1'b0;
      end
      if (rst) begin
	  excpt_fpu=11'b0;
      end else if (msrss_en && pwh#(32)::cmpEQ(msrss_no,`csr_FPU)) begin
	  excpt_fpu=msrss_data[10:0];
      end else if (has_some) begin
	  if (~xbreak[0]&fpudone[0]) excpt_fpu=excpt_fpu|ret_data[0][13:3]; 
	  if (~xbreak[1]&fpudone[1]) excpt_fpu=excpt_fpu|ret_data[1][13:3]; 
	  if (~xbreak[2]&fpudone[2]) excpt_fpu=excpt_fpu|ret_data[2][13:3]; 
	  if (~xbreak[3]&fpudone[3]) excpt_fpu=excpt_fpu|ret_data[3][13:3]; 
	  if (~xbreak[4]&fpudone[4]) excpt_fpu=excpt_fpu|ret_data[4][13:3]; 
	  if (~xbreak[5]&fpudone[5]) excpt_fpu=excpt_fpu|ret_data[5][13:3]; 
	  if (~xbreak[6]&fpudone[6]) excpt_fpu=excpt_fpu|ret_data[6][13:3]; 
	  if (~xbreak[7]&fpudone[7]) excpt_fpu=excpt_fpu|ret_data[7][13:3]; 
	  if (~xbreak[8]&fpudone[8]) excpt_fpu=excpt_fpu|ret_data[8][13:3]; 
	  if (~xbreak[9]&fpudone[9]) excpt_fpu=excpt_fpu|ret_data[9][13:3]; 
      end
      if (rst) begin
          tire0_rT<=6'd0;
          tire1_rT<=6'd0;
          tire2_rT<=6'd0;
          tire3_rT<=6'd0;
          tire4_rT<=6'd0;
          tire5_rT<=6'd0;
          tire6_rT<=6'd0;
          tire7_rT<=6'd0;
          tire8_rT<=6'd0;
	  
	  tire0_enG<=1'b0;
	  tire1_enG<=1'b0;
	  tire2_enG<=1'b0;
	  tire3_enG<=1'b0;
	  tire4_enG<=1'b0;
	  tire5_enG<=1'b0;
	  tire6_enG<=1'b0;
	  tire7_enG<=1'b0;
	  tire8_enG<=1'b0;
	  
	  tire0_enV<=1'b0;
	  tire1_enV<=1'b0;
	  tire2_enV<=1'b0;
	  tire3_enV<=1'b0;
	  tire4_enV<=1'b0;
	  tire5_enV<=1'b0;
	  tire6_enV<=1'b0;
	  tire7_enV<=1'b0;
	  tire8_enV<=1'b0;
	  
	  tire0_enF<=1'b0;
	  tire1_enF<=1'b0;
	  tire2_enF<=1'b0;
	  tire3_enF<=1'b0;
	  tire4_enF<=1'b0;
	  tire5_enF<=1'b0;
	  tire6_enF<=1'b0;
	  tire7_enF<=1'b0;
	  tire8_enF<=1'b0;

	  tire_enFl<=1'b0;

	  dotire<=1'b0;

	  flags[0]<=6'b0;
	  flags[1]<=6'b0;

	  jupd0_addr<=16'b0;
	  jupd1_addr<=16'b0;
	  jupd0_baddr<=13'b0;
	  jupd1_baddr<=13'b0;
	  jupd0_sc<=2'b0;
	  jupd1_sc<=2'b0;
	  jupd0_tk<=1'b0;
	  jupd1_tk<=1'b0;
	  jupd0_en<=1'b0;
	  jupdt0_en<=1'b0;
	  jupd0_ght_en<=1'b0;
	  jupd0_ght2_en<=1'b0;
	  jupd1_en<=1'b0;
	  jupdt1_en<=1'b0;
	  jupd1_ght_en<=1'b0;
	  jupd1_ght2_en<=1'b0;

	  exceptIP<=63'b0;
	  except_thread<=1'b0;
	  except_attr<=4'b0;
	  except_both<=1'b0;
	  except<=1'b0;
          except_due_jump<=1'b0;
          except_jump_ght<=8'b0;
          except_jump_ght2<=16'b0;
          except_set_instr_flag<=1'b0;
          except_jmp_mask_en<=1'b0;
          except_jmp_mask<=4'hf;

          GORQ_en_reg<=1'b0;
          GORQ_enX_reg<=1'b0;
          GORQ_data_reg<=16'b0;
          
          msrss_no<=16'b0;
          msrss_thread<=1'b0;
          msrss_en<=1'b0;
          msrss_data<=65'b0;

	  baseIP<=63'h7c0ef80000000000;

          tire_addr_reg<=6'd0;
	  
//	  tire_thread<=1'b0;
	  tire_thread_reg<=1'b0;
	  
	  retcnt<=4'd1;
          retclr<=9'b0;
          
	  archReg_xcpt_retIP[0]<=43'b0;
          archReg_xcpt_retIP[1]<=43'b0;	
//	  archReg_xcpt_code[0]<=8'b0;
//        archReg_xcpt_code[1]<=8'b0;	
	  archReg_proc[0]<=16'b0;
	  archReg_proc[1]<=16'b0;
          oldbrk<=0;
      end else begin
          tire0_rT<=rTe[0];
          tire1_rT<=rTe[1];
          tire2_rT<=rTe[2];
          tire3_rT<=rTe[3];
          tire4_rT<=rTe[4];
          tire5_rT<=rTe[5];
          tire6_rT<=rTe[6];
          tire7_rT<=rTe[7];
          tire8_rT<=rTe[8];
	  
	  
	  tire0_enG<=dotire_d && tireG[0];
	  tire1_enG<=dotire_d && tireG[1];
	  tire2_enG<=dotire_d && tireG[2];
	  tire3_enG<=dotire_d && tireG[3];
	  tire4_enG<=dotire_d && tireG[4];
	  tire5_enG<=dotire_d && tireG[5];
	  tire6_enG<=dotire_d && tireG[6];
	  tire7_enG<=dotire_d && tireG[7];
	  tire8_enG<=dotire_d && tireG[8];
	  
	  tire0_enV<=dotire_d && tireV[0];
	  tire1_enV<=dotire_d && tireV[1];
	  tire2_enV<=dotire_d && tireV[2];
	  tire3_enV<=dotire_d && tireV[3];
	  tire4_enV<=dotire_d && tireV[4];
	  tire5_enV<=dotire_d && tireV[5];
	  tire6_enV<=dotire_d && tireV[6];
	  tire7_enV<=dotire_d && tireV[7];
	  tire8_enV<=dotire_d && tireV[8];
	  
	  tire0_enF<=dotire_d && tireF[0];
	  tire1_enF<=dotire_d && tireF[1];
	  tire2_enF<=dotire_d && tireF[2];
	  tire3_enF<=dotire_d && tireF[3];
	  tire4_enF<=dotire_d && tireF[4];
	  tire5_enF<=dotire_d && tireF[5];
	  tire6_enF<=dotire_d && tireF[6];
	  tire7_enF<=dotire_d && tireF[7];
	  tire8_enF<=dotire_d && tireF[8];

	  tire_enFl<=lfl_has && dotire_d;

	  dotire<=dotire_d;

	  if (dotire_d) flags[tire_thread_reg]<=flags_d;

	  jupd0_addr<=(jump0Val ? &rnd1 : rnd1[0]) ? update_ght2_addr_j0 : update_ght_addr_j0;
	  jupd1_addr<=(jump1Val ? &~rnd1 : rnd1[1]) ? update_ght2_addr_j1 : update_ght_addr_j1;
	  jupd0_baddr<=update_btb_addr_j0;
          jupd1_baddr<=update_btb_addr_j1;
	  jupd0_sc<=update_sc_j0;
	  jupd1_sc<=update_sc_j1;
	  jupd0_tk<=jump0_taken;
	  jupd1_tk<=jump1_taken;
	  jupd0_en<=jump0_in & ~jump0Miss & dotire_d;
	  //jupdt0_en<=
	  jupd0_ght_en<=jump0_in & ~jump0Miss & ~jump0BtbOnly & dotire_d & ~(jump0Val ? &rnd1 : rnd1[0]) ;
	  jupd0_ght2_en<=jump0_in & ~jump0Miss & ~jump0BtbOnly & dotire_d & (jump0Val ? &rnd1 : rnd1[0]) ;
	  jupd1_en<=jump1_in & ~jump1Miss & dotire_d;
	  //jupdt1_en<=
	  jupd1_ght_en<=jump1_in & ~jump1Miss & ~jump1BtbOnly & dotire_d & ~(jump0Val ? &rnd1 : rnd1[0]) ;
	  jupd1_ght2_en<=jump1_in & ~jump1Miss & ~jump1BtbOnly & dotire_d & (jump0Val ? &rnd1 : rnd1[0]) ;

	  exceptIP<={exceptIP_d};
          //except_thread<=except_thread_d;
	  except_attr<=except_attr_d;
	  //except_both<=except_both_d;
	  except<=except_d;
          except_due_jump<=(break_jump0&~break_exceptn)|(break_jump1&~break_exceptn) && except_d;
          if (dotire_d && jump0_in) except_jump_ght<=jump1_in ? {jump1GHT[6:0],jump1_taken} : {jump0GHT[6:0],jump0_taken};
          if (dotire_d && jump0_in) except_jump_ght2<=jump1_in ? {jump1GHT2[14:0],~jump1Val} : {jump0GHT2[14:0],~jump0Val};
          except_set_instr_flag<=break_replay&!break_replayS;
          except_jmp_mask_en<=((break_jump0&~break_exceptn) | (break_jump1&~break_exceptn)) && except_d;
          except_jmp_mask<=(break_jump0&~break_exceptn) ? jump0JMask : jump1JMask;

          GORQ_en_reg<=GORQ;
          GORQ_enX_reg<=GORQ_en_reg && ~break_jump0 && ~break_jump1 && ~break_exceptn;
          if (GORQ) GORQ_data_reg<=GORQ_data;
          
          if (!tire_thread_reg) oldbrk<={bbaseIP[62:43],breakIP};

          msrss_no<=msrss_no_d;
          //msrss_thread<=except_thread_d;
          msrss_en<=msrss_en_d;
          msrss_data<=msrss_data_d;

	  if (dotire_d) baseIP<=baseIP_d;
	  if (dotire_d||~has_some) tire_addr_reg<=tire_addr;

	  //if (both_threads) tire_thread<=~tire_thread;
	  //else tire_thread<=thread1;
	  //
	  //tire_thread_reg<=tire_thread;
	  retcnt<=(dotire_d&~init) ? retcnt_d : 4'd1;
	  retclr<={9{dotire_d&~init}} & retclrP;

	  if (msrss_en && msrss_no[14:0]==`csr_excIP) begin
              archReg_xcpt_handlerIP<=msrss_data[63:1];
	  end
          if (break_exceptn && has_some && indir_ready) begin
	      archReg_xcpt_retIP[tire_thread_reg]<=breakIP;	
//	      archReg_xcpt_code[tire_thread_reg]<=excpt_code;	
          end
      end
  end
  
endmodule

