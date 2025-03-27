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

module predecoder_class(instr,magic,flag,FMA_mul,prev_FMA_mul,thread,class_,isLNK,isRet,LNK);
  parameter LARGE_CORE=0;
  parameter H=0;

  input pwire [31:0] instr;
  input pwire [3:0] magic;
  input pwire flag;
  output pwire FMA_mul;
  input pwire prev_FMA_mul;
  input pwire thread;
  output pwire [12:0] class_;
  output pwire isLNK;
  output pwire isRet;
  output pwire [4:0] LNK;

  pwire clsIndir;
  pwire clsJump;
  pwire clsALU;
  pwire clsShift;
  pwire clsMul;
  pwire clsLoad;
  pwire clsStore;
  pwire clsStore2;
  pwire clsFPU;
  pwire clsLoadFPU;
  pwire clsSys;
  pwire clsPos0;
  pwire clsFMA;
  
  pwire [7:0] opcode_main;

  pwire subIsBasicALU;
  pwire subIsMovOrExt;
  pwire subIsBasicShift;
  pwire subIsCmpTest;
  pwire subIsCJ;
  pwire subIsFPUD;
  pwire subIsFPUPD;
  pwire subIsFPUE;
  pwire subIsFPUSngl;
  pwire subIsSIMD;
  pwire subIsLinkRet;
  pwire subIsBasicXOR;
  pwire isBasicXOR;

  
  pwire isBasicALU;
  pwire isBasicALUExcept;
  pwire isBasicShift;
  pwire isBasicShiftExcept;
  pwire isBasicCmpTest;
//  pwire isCmpTestExtra;   
  
  pwire isBaseLoadStore;
  pwire isBaseIndexLoadStore;
  pwire isBaseSpecLoad;
  pwire isBaseIndexSpecLoad;
  pwire isBaseSpecStore;
  pwire isBaseIndexSpecStore;
  pwire isImmLoadStore;
  pwire isBasicMUL;
  pwire isLeaIPRel;

  pwire isBasicCJump;
  pwire isInvCJumpLong;
  pwire isSelfTestCJump;
  pwire isLongCondJump;
  pwire isUncondJump;
  
  pwire isIndirJump;
  pwire isCall;
  
  pwire isMovOrExt;
  pwire isMovOrExtExcept;
  pwire isCmov;
  pwire isCSet;
  pwire isBasicAddNoFl;
  pwire isAddNoFlExtra;
  pwire isShiftNoFl;

  pwire isCexALU;

  pwire isSimdInt; 
  pwire isFPUreor;

  pwire isShlAddMulLike;
  pwire isPtrSec;
  pwire isJalR;

  pwire isBasicFPUScalarA;
  pwire isBasicFPUScalarB;
  pwire isBasicFPUScalarC;
  pwire isBasicFPUScalarCmp;
  pwire isBasicFPUScalarCmp2;
  pwire isBasicFPUScalarCmp3;

  pwire isGA; 

  pwire isBasicSysInstr;
  
  pwire isCallPrep;

  pwire [5:0] opcode_sub;

  pwire thisSpecLoad;
  
  assign subIsBasicALU=(!|opcode_sub[5:4] || pwh#(4)::cmpEQ(opcode_sub[5:2],4'b0100)) & ~magic[0];
  assign subIsBasicShift=(~opcode_sub[5] && ~subIsBasicALU && opcode_sub[0]) & ~magic[0];
  assign subIsFPUE=pwh#(6)::cmpEQ(opcode_sub,6'b010100) && ~magic[0]; 
  assign subIsFPUSngl=((pwh#(6)::cmpEQ(opcode_sub,6'b010110) || pwh#(6)::cmpEQ(opcode_sub,6'b011000)) && opcode_main[7:6]!=2'b11) & ~magic[0];
  assign subIsLinkRet=(pwh#(6)::cmpEQ(opcode_sub,6'b010110) || pwh#(6)::cmpEQ(opcode_sub,6'b011000)) && pwh#(2)::cmpEQ(opcode_main[7:6],2'b11) && ~magic[0];
  assign subIsSIMD=(pwh#(3)::cmpEQ(opcode_sub[5:3],3'b011) && |opcode_sub[2:1] && ~opcode_sub[0]) & ~magic[0];
  assign subIsMovOrExt=(pwh#(3)::cmpEQ(opcode_sub[5:3],3'b100) || pwh#(5)::cmpEQ(opcode_sub[5:1],5'b10100)) & ~magic[0];
  assign subIsCmpTest=(pwh#(5)::cmpEQ(opcode_sub[5:1],5'b10101) || pwh#(4)::cmpEQ(opcode_sub[5:2],4'b1011)) & ~magic[0];
  assign subIsCJ=pwh#(4)::cmpEQ(opcode_sub[5:2],4'b1100)  && |instr[15:8] && ~magic[0]; //zero offset jumps are hint instructions! 
  assign subIsFPUD=(pwh#(4)::cmpEQ(opcode_sub[5:2],4'b1101) || pwh#(5)::cmpEQ(opcode_sub[5:1],5'b11100)) & ~magic[0];
  assign subIsFPUPD=(pwh#(3)::cmpEQ(opcode_sub[5:3],3'b111) && opcode_sub[5:1]!=5'b11100) & ~magic[0];
  assign subIsBasicXOR=pwh#(4)::cmpEQ(opcode_sub[5:2],4'b0100);//not a separate class
  assign isBasicXOR=(pwh#(5)::cmpEQ(opcode_main[7:3],5'b00100)) & ~opcode_main[2];//not a seprarate class
  
  //hint_begin_vec=pwh#(8)::cmpEQ(opcode_main[7:0],8'b11110011) uc jump offset=0; 2x vectorisation
  //hind_begin_vec_x4=pwh#(8)::cmpEQ(opcode_main[7:0],8'b01110011) uc jump offset=0; not yet implemented and might not be in the future
  //hint_end_vec=pwh#(8)::cmpEQ(opcode_main[7:0],8'b10110011) uc jump offset=0
  //ext insn for multi uop=pwh#(8)::cmpEQ(opcode_main[7:0],8'b11110010)

  assign isBasicSysInstr=pwh#(8)::cmpEQ(opcode_main,8'hff)&&magic[0]; 

  assign opcode_main=instr[7:0];
  assign opcode_sub=instr[5:0];
  
  
  assign isBasicALU=(!|opcode_main[7:5] || pwh#(5)::cmpEQ(opcode_main[7:3],5'b00100)) & ~opcode_main[2] & magic[0];
  assign isBasicMUL=(!|opcode_main[7:5] || pwh#(5)::cmpEQ(opcode_main[7:3],5'b00100)) & opcode_main[2] & magic[0];
  assign isBasicALUExcept=~opcode_main[0] && (pwh#(2)::cmpEQ(magic[1:0],2'b01) && |instr[28:26]);  
  assign isBasicShift=(pwh#(7)::cmpEQ(opcode_main[7:1],7'd20) || pwh#(7)::cmpEQ(opcode_main[7:1],7'd21) ||
      pwh#(7)::cmpEQ(opcode_main[7:1],7'd22))&&magic[0];      
  assign isBasicShiftExcept=pwh#(2)::cmpEQ(magic[1:0],2'b01) && |instr[29:25];
  
  assign isBasicCmpTest=(pwh#(7)::cmpEQ(opcode_main[7:1],7'd23) || pwh#(6)::cmpEQ(opcode_main[7:2],6'd12) ||
    pwh#(7)::cmpEQ(opcode_main[7:1],7'd26) || pwh#(6)::cmpEQ(opcode_main[7:2],6'd54)) && magic[0];

  assign isBaseSpecLoad=(pwh#(8)::cmpEQ(opcode_main,8'd54) || pwh#(8)::cmpEQ(opcode_main,8'd202)) && magic[0];
  assign isBaseIndexSpecLoad=(pwh#(8)::cmpEQ(opcode_main,8'd55) || pwh#(8)::cmpEQ(opcode_main,8'd203)) && magic[0];
  assign isBaseSpecStore=(pwh#(8)::cmpEQ(opcode_main,8'd204) || pwh#(8)::cmpEQ(opcode_main,8'd205)) && magic[0];
  assign isBaseIndexSpecStore=(opcode_main=8'd206 || pwh#(8)::cmpEQ(opcode_main,8'd207)) && magic[0];

  assign isImmLoadStore=((pwh#(6)::cmpEQ(opcode_main[7:2],6'd15)) || pwh#(7)::cmpEQ(opcode_main[7:1],7'b1011000)) & magic[0];  
  assign isBaseLoadStore=((pwh#(3)::cmpEQ(opcode_main[7:5],3'b010)) || pwh#(4)::cmpEQ(opcode_main[7:4],4'b0110)) & magic[0];
  assign isBaseIndexLoadStore=((pwh#(3)::cmpEQ(opcode_main[7:5],3'b100)) || pwh#(4)::cmpEQ(opcode_main[7:4],4'b0111)) & magic[0];


  assign isBasicCJump=(pwh#(4)::cmpEQ(opcode_main[7:4],4'b1010)) && magic[0];
  assign isSelfTestCJump=(pwh#(8)::cmpEQ(opcode_main,8'd178) || pwh#(8)::cmpEQ(opcode_main,8'd179)) && magic[0];
  assign isLongCondJump=(pwh#(8)::cmpEQ(opcode_main,8'd180)) && magic[0];
  assign isUncondJump=(pwh#(8)::cmpEQ(opcode_main,8'd181)) && magic[0];
  assign isIndirJump=(pwh#(8)::cmpEQ(opcode_main,8'd182) && pwh#(3)::cmpEQ(instr[15:13],3'd0)) && magic[0];
  assign isCall=(pwh#(8)::cmpEQ(opcode_main,8'd182) && (pwh#(3)::cmpEQ(instr[15:13],3'd1) || pwh#(3)::cmpEQ(instr[15:13],3'd2))) && magic[0];
  assign isRet=(pwh#(8)::cmpEQ(opcode_main,8'd182) && pwh#(3)::cmpEQ(instr[15:13],3'd3)) && magic[0];
  assign isMovOrExt=(pwh#(8)::cmpEQ(opcode_main,8'd183) || pwh#(5)::cmpEQ(opcode_main[7:3],5'b10111) || pwh#(7)::cmpEQ(opcode_main[7:1],7'd96)) && magic[0];
  assign isMovOrExtExcept=pwh#(2)::cmpEQ(magic[1:0],2'b11) && opcode_main!=8'd183 && opcode_main[7:1]!=7'd92;
  assign isCSet=(pwh#(8)::cmpEQ(opcode_main,8'd194)) && magic[0]; 
  assign isBasicAddNoFl=(pwh#(8)::cmpEQ(opcode_main,8'd195) || pwh#(8)::cmpEQ(opcode_main,8'd196)) && magic[0];
  
  assign isLeaIPRel=(pwh#(8)::cmpEQ(opcode_main,8'd197)) & magic[0];

  assign isCmov=pwh#(32)::cmpEQ(opcode_main,198) && pwh#(2)::cmpEQ(magic[1:0],2'b01);
  
  
  assign isSimdInt=pwh#(8)::cmpEQ(opcode_main,8'd200) && magic[0];
  assign isFPUreor=pwh#(8)::cmpEQ(opcode_main,8'd201) && magic[0];
  
  assign isShlAddMulLike=(pwh#(8)::cmpEQ(opcode_main,8'd210) || pwh#(8)::cmpEQ(opcode_main,8'd211) ||
    pwh#(8)::cmpEQ(opcode_main,8'd231) || pwh#(8)::cmpEQ(opcode_main,8'd232)) && magic[0];
  assign isPtrSec=(pwh#(8)::cmpEQ(opcode_main,8'd212) || pwh#(8)::cmpEQ(opcode_main,8'd233) )&& magic[0];
  assign isJalR=(pwh#(8)::cmpEQ(opcode_main,8'd213) || pwh#(8)::cmpEQ(opcode_main,8'd214) || pwh#(8)::cmpEQ(opcode_main,8'd215) || pwh#(8)::cmpEQ(opcode_main,8'd220) || pwh#(8)::cmpEQ(opcode_main,8'd221)) && magic[0];
  assign isCexALU=pwh#(8)::cmpEQ(opcode_main,8'd222) && magic[0];

  assign isCLeave=(pwh#(8)::cmpEQ(opcode_main,8'd235) || pwh#(8)::cmpEQ(opcode_main[7:0],8'd236) || pwh#(8)::cmpEQ(opcode_main[7:0],8'd238)) && magic[0];
  //237 and 239 unused so far
  assign isBasicFPUScalarA=pwh#(4)::cmpEQ(opcode_main[7:4],4'hf) && ~&opcode_main[1:0] && pwh#(2)::cmpEQ(instr[13:12],2'b0) && magic[0];
  assign isBasicFPUScalarB=pwh#(4)::cmpEQ(opcode_main[7:4],4'hf) && ~&opcode_main[1:0] && pwh#(2)::cmpEQ(instr[13:12],2'b1) && magic[0];
  assign isBasicFPUScalarC=pwh#(4)::cmpEQ(opcode_main[7:4],4'hf) && ~&opcode_main[1:0] && pwh#(4)::cmpEQ(instr[15:12],4'd2) && magic[0];
  assign isBasicFPUScalarCmp=pwh#(4)::cmpEQ(opcode_main[7:4],4'hf) && ~&opcode_main[1:0] && pwh#(4)::cmpEQ(instr[15:12],4'd6) && magic[0];
  assign isBasicFPUScalarCmp2=pwh#(4)::cmpEQ(opcode_main[7:4],4'hf) && ~&opcode_main[1:0] && pwh#(4)::cmpEQ(instr[15:12],4'ha) && magic[0];
  assign isBasicFPUScalarCmp3=pwh#(4)::cmpEQ(opcode_main[7:4],4'hf) && ~&opcode_main[1:0] && pwh#(4)::cmpEQ(instr[15:12],4'd12);

  assign isCallPrep=(pwh#(8)::cmpEQ(opcode_main,8'd199)) && magic[0];

  assign isGA=pwh#(8)::cmpEQ(opcode_main,8'd237) && magic[0];

  assign isPtrBump_other_domain=pwh#(8)::cmpEQ(opcode_main,8'hf7) && pwh#(2)::cmpEQ(magic[1:0],2'b01);

  assign thisSpecLoad=isBaseSpecLoad || isBaseIndexSpecLoad || isBaseSpecStore || isBaseIndexSpecStore || 
      ({instr[11],instr[15:12]}==5'd16 &&  pwh#(7)::cmpEQ(opcode_main[7:1],7'b1011000)) || 
      ({instr[1],instr[15:12]}==5'd15 && pwh#(6)::cmpEQ(opcode_main[7:2],6'd15));

  
  assign clsJump=|{
  isBasicCJump,
  isSelfTestCJump,
  isLongCondJump,
  isCLeave && |instr[31:17],
  isUncondJump,
  isIndirJump,
  isCall,
  isRet,
  subIsCJ,
  pwh#(8)::cmpEQ(opcode_main,8'hff) && ~instr[15] && ~instr[13] && magic[0] && 
    instr[30:16]!=15'd22
  };

  assign clsIndir=|{
  isIndirJump,
  isRet,
  isFPUreor,
  pwh#(8)::cmpEQ(opcode_main,8'hff) && ~instr[15] && ~instr[13] && magic[0]
  };

  assign clsFMA=|{
  FMA_mul,
  subIsFPUD && instr[7],
  subIsFPUPD && instr[7],
  subIsFPUE && ~instr[7]
  };

  assign FMA_mul={pwh#(5)::cmpEQ(instr[31:27],5'd16) && isBasicFPUScalarB && (pwh#(6)::cmpEQ(instr[13:8],6'd18)) | (pwh#(6)::cmpEQ(instr[13:8],6'd21)) | (pwh#(6)::cmpEQ(instr[13:8],6'd24)),
  pwh#(5)::cmpEQ(instr[31:27],5'd16) && isBasicFPUScalarA && (pwh#(5)::cmpEQ(instr[13:9],5'd2)) | (pwh#(6)::cmpEQ(instr[13:8],6'd8))};
  
  assign clsALU=|{
  isBasicALU & ~isBasicALUExcept & ~isBasicXOR,
  isBasicMUL && ({opcode_main[6:3],opcode_main[1]}==3 || {opcode_main[6:3],opcode_main[1]}==7),
  isPtrBump_other_domain,
  isCexALU & ~instr[12] & ~instr[10],
  isBasicCmpTest,
  isBasicCJump & magic[0],
  isSelfTestCJump,
  isMovOrExt & ~isMovOrExtExcept,
  isCSet,
  isBasicAddNoFl,
  isCmov,
  isShlAddMulLike,
  isSimdInt & ~instr[16],
  subIsFPUD,
  subIsFPUPD, subIsFPUSngl,
  subIsFPUE,
  subIsSIMD,
  isSimdInt && ((pwh#(5)::cmpEQ(instr[13:9],5'd0) && ~instr[16]) || (pwh#(5)::cmpEQ(instr[13:9],5'd5) && ~instr[16]) || (pwh#(6)::cmpEQ(instr[13:8],6'b11) && instr[16])),
  subIsBasicALU & ~subIsBasicXOR,subIsCmpTest,subIsLinkRet,
  pwh#(8)::cmpEQ(opcode_main,8'hff) && pwh#(3)::cmpEQ(instr[15:13],3'd1) && magic[0],
  isBasicFPUScalarA && instr[13:9]!=5'd2 && instr[13:8]!=6'd8,
  isBasicFPUScalarB && instr[13:8]!=6'd18 && instr[13:8]!=6'd21,
  isBasicFPUScalarC && instr[13:8]!=6'd32,
  isBasicFPUScalarCmp && pwh#(3)::cmpEQ(instr[13:11],3'b100),
  isBasicFPUScalarCmp2 && pwh#(4)::cmpEQ(instr[13:10],4'b1000),
  isBasicFPUScalarCmp3 && pwh#(4)::cmpEQ(instr[13:10],4'b1000),
  subIsMovOrExt,
  isLeaIPRel,
  isJalR,
  pwh#(8)::cmpEQ(opcode_main,8'd236) && magic[0]
  };
  
  assign clsPos0=pwh#(8)::cmpEQ(opcode_main,8'hff) && pwh#(3)::cmpEQ(instr[15:13],3'd1) && magic[0] && instr[31:16]==`csr_FPU;
  
  assign clsShift=isBasicShift & ~isBasicShiftExcept || subIsBasicShift || subIsFPUD & (pwh#(5)::cmpEQ(opcode_sub[5:1],5'b11100)) ||
    isCexALU & ~instr[12] & instr[10] ||
    subIsFPUPD & prev_FMA_mul || subIsFPUSngl & prev_FMA_mul
    || subIsFPUE & prev_FMA_mul || isSimdInt & instr[16] ||
    (isSimdInt && ~((pwh#(5)::cmpEQ(instr[13:9],5'd0) && ~instr[16]) || (pwh#(5)::cmpEQ(instr[13:9],5'd5) && ~instr[16]) ||
     (pwh#(6)::cmpEQ(instr[13:8],6'b11) && instr[16]))) || 
    isBasicALU & ~isBasicALUExcept & isBasicXOR ||
    subIsBasicALU & subIsBasicXOR ||
    pwh#(5)::cmpEQ(instr[31:27],5'd16) && prev_FMA_mul && isBasicFPUScalarB && (pwh#(6)::cmpEQ(instr[13:8],6'd19)) | (pwh#(6)::cmpEQ(instr[13:8],6'd20)) |
    (pwh#(5)::cmpEQ(instr[13:9],5'd11)) ||
    pwh#(5)::cmpEQ(instr[31:27],5'd16) && prev_FMA_mul && isBasicFPUScalarA && (pwh#(4)::cmpEQ(instr[13:10],4'b0)) | (instr [13:9]==5'd3) | (pwh#(6)::cmpEQ(instr[13:10],6'd9)) ||
    (isBasicFPUScalarA && ~(instr[13:9]!=5'd2 && instr[13:8]!=6'd8)) ||
    (isBasicFPUScalarB && ~(instr[13:8]!=6'd18 && instr[13:8]!=6'd21));
  
  assign clsLoad=|{
  isBaseLoadStore & ~opcode_main[0],
  isBaseIndexLoadStore & ~opcode_main[0],  
  isBaseSpecLoad,
  isBaseIndexSpecLoad,
  isBaseSpecStore,
  isBaseIndexSpecStore,
  isImmLoadStore && ~opcode_main[0],
  isBasicFPUScalarCmp3 && pwh#(6)::cmpEQ(instr[13:8],6'b100100)//mlb jump table load gen purp
  };

  assign clsStore=|{
  isBaseLoadStore &  opcode_main[0],
  isImmLoadStore && opcode_main[0],
  isBaseIndexLoadStore & opcode_main[0],
  isBaseSpecStore,
  isBaseIndexSpecStore,
  isCall & magic[0]
  };
  
  assign clsStore2=|{
  isBaseLoadStore &  opcode_main[0],
  isImmLoadStore && opcode_main[0],
  isBaseIndexLoadStore & opcode_main[0],
  isBaseSpecStore,
  isBaseIndexSpecStore,
  isCall & magic[0]
  };
  
//  assign clsStore2=isBaseIndexLoadStore & opcode_main[0];

  assign clsLoadFPU=|{
    isBaseLoadStore & ~opcode_main[0] & ~opcode_main[5],
    isBaseIndexLoadStore & ~opcode_main[0] & opcode_main[7:4]!=4'b0111,  
    isBaseSpecLoad & ~opcode_main[7],
    isBaseIndexSpecLoad & ~opcode_main[7],
    isImmLoadStore && ~opcode_main[0] && opcode_main[7:1]!=7'b1011000
  };
  
  assign clsMul=|{
    isBasicMUL && ({opcode_main[6:3],opcode_main[1]}!=3 && {opcode_main[6:3],opcode_main[1]}!=7),
    magic[0] && pwh#(8)::cmpEQ(opcode_main,8'd234),
    isGA,
    isPtrSec,
    isCexALU & instr[12],
    pwh#(8)::cmpEQ(opcode_main,8'hff) && ~instr[15] && ~instr[13] && magic[0],
     isBasicFPUScalarC && pwh#(6)::cmpEQ(instr[13:8],6'd32),

     isBasicFPUScalarCmp && |instr[12:11],
     isBasicFPUScalarCmp2 && |instr[12:10]
  };
  
  assign clsSys=isBasicSysInstr|isFPUreor;
  
  assign clsFPU=isBasicFPUScalarA || isBasicFPUScalarB || isBasicFPUScalarC || subIsFPUD || subIsFPUPD || subIsFPUSngl ||
    subIsFPUE || subIsSIMD;
  assign class_[`iclass_indir]=clsIndir;
  assign class_[`iclass_jump]= clsJump;
  assign class_[`iclass_ALU]= clsALU;
  assign class_[`iclass_shift]= clsShift;
  assign class_[`iclass_mul]= clsMul;
  assign class_[`iclass_load]=clsLoad;
  assign class_[`iclass_store]=clsStore;
  assign class_[`iclass_store2]=clsFMA;
  assign class_[`iclass_FPU]=clsFPU;
  assign class_[`iclass_loadFPU]=thisSpecLoad;
  assign class_[`iclass_sys]=clsSys;
  assign class_[`iclass_flag]=flag;
  assign class_[`iclass_pos0]=clsPos0;
  
  assign LNK=isRet ? 5'h1f : 5'bz;
//  assign LNK=(isCallPrep & ~magic[0]) ? instr[11:8] : 16'bz;
  assign LNK=isCallPrep ? instr[20:16] : 5'bz;
  assign LNK=subIsLinkRet&~opcode_sub[1] ? {1'b0,instr[15:12]} : 5'bz;
  assign LNK=(~isRet & ~isCallPrep & ~(subIsLinkRet&~opcode_sub[1])) ? 5'h1f : 5'bz;
  
  assign isLNK=isRet | isCallPrep | (subIsLinkRet&~opcode_sub[1]);
  
endmodule

module predecoder_get(
    clk,
    rst,
    thread,
    bundle,btail,bstop,bFMA_mul,
    bnext,bnext_tail,has_next,
    startOff,
    instr0,
    magic0,
    off0,
    class0,
    instrEn,
    _splitinsn,
    hasJumps,
    error,
    jerror,
    Jinstr0,
    Jmagic0,
    Joff0,
    Jclass0,
    Jen,
    lnkLink0,lnkOff0,lnkMagic0,lnkRet0,lnkJumps0
    );
    localparam CLSWIDTH=12;
    parameter LARGE_CORE=0;
    parameter H=0;

    input pwire clk;
    input pwire rst;
    input pwire thread;
    input pwire [255:0] bundle;
    input pwire [64:0] btail;
    input pwire [3:0] bstop;
    input pwire bFMA_mul;
    input pwire [127:0] bnext;
    input pwire [7:0] bnext_tail;
    input pwire has_next;
    input pwire [3:0] startOff;
    output pwire [3:0] startOff_override;
    output pwire [15:0][79:0] instr0;
    output pwire [15:0][3:0] magic0;
    output pwire [15:0][3:0] off0;
    output pwire [15:0][12:0] class0;
    output pwire [15:0] instrEn;
    output pwire _splitinsn;
    output pwire hasJumps;
    output pwire last_is_FMAMul;
    output pwire error;
    output pwire jerror;
    
    output pwire [3:0][79:0] Jinstr0;
    output pwire [3:0][3:0] Jmagic0;
    output pwire [3:0][3:0] Joff0;
    output pwire [3:0][12:0] Jclass0;
    
    output pwire [3:0] Jen;
    output pwire [3:0][4:0] lnkLink0;
    output pwire [3:0][4:0] lnkOff0;
    output pwire [3:0][3:0] lnkMagic0;
    output pwire [3:0]      lnkRet0;
    output pwire [3:0][4:0] lnkJumps0;

    pwire [19:-1] instrEnd;
    pwire [19:-1] instrEndF;
    
    pwire [19:-2][15:0] cntEnd;
    pwire [19:-1] mask;
 
    pwire [19:0] cntEnd2;
    pwire [20:1] cntEnd3;
    pwire [14:0] cntEnd2_15;
    pwire [15:1] cntEnd3_15;
    
    pwire [19:0][12:0] class_ ;
    pwire [255+16+64:0] bundle0;
    pwire [255+16+64:0] bundleF;

    pwire [19:0] is_jmp;
    pwire [19:0] is_jmpX;
    pwire [20:-1][15:0] cntJEnd;
    pwire [19:0] jcnt_or_less;
    pwire [14:0] jcnt_or_less_15;
    pwire [20:1] jcnt_or_more;
    
    pwire [19:0] is_lnk0;
    pwire [19:0] is_lnk;
    pwire [19:0] is_lnk_reg;
    pwire [19:0] first_lnk;
    pwire has_lnk;
    pwire [19:0][4:0] LNK;
    pwire [19:0] lcnt_or_less;
    pwire [19:-1][15:0] lcnt;
    pwire [19:0] is_ret0;
    pwire [19:0] is_ret;
    pwire [19:0] is_ret_reg;
    pwire [19:0] flag_bits0;
    pwire [19:0] mask0;

    pwire [19:-1] FMAmul;
    pwire [11:0] FMAmulI;

    function [255+64+16:0] boogy_baboogy;
        input pwire [3:0] bstop;
        input pwire cond;
        input pwire [255+64+16:0] index0;
        input pwire [255+64+16:0] index1;
        input pwire [255+64+16:0] index2;
        input pwire [255+64+16:0] index3;
        input pwire [255+64+16:0] index_else;
        begin
            if (cond && pwh#(2)::cmpEQ(bstop[3:2],2'b01)) boogy_baboogy=index0;
            if (cond && pwh#(3)::cmpEQ(bstop[3:1],3'b001)) boogy_baboogy=index1;
            if (cond && pwh#(4)::cmpEQ(bstop[3:0],4'b0001)) boogy_baboogy=index2;
            if (cond &&  pwh#(4)::cmpEQ(bstop[3:0],4'b0)) boogy_baboogy=index3;
            if (!cond || bstop[3]) boogy_baboogy=index_else;
        end
    endfunction
    generate
        genvar k,subloop_insn,subloop_jump;
        for(k=0;k<20;k=k+1) begin : popcnt_gen
            popcnt20 cnt_mod(instrEnd[19:0] & ((20'b10<<k)-20'b1) & mask[19:0],cntEnd[k]);
            get_carry #(5) carry_mod(k[4:0],~{1'b0,startOff},1'b1,mask0[k]);
            assign mask[k]=mask0[k] || ((k+1)==startOff && !instrEnd[k]) ||
               ((k+2)==startOff && instrEnd[k+:2]==2'b00) ||
               ((k+3)==startOff && instrEnd[k+:3]==3'b000) ||
               ((k+4)==startOff && instrEnd[k+:4]==4'b0000);
            assign brk=cntEnd[k][12] ? k[3:0] && k[4] : 4'bz;
            pwire [4:0] kk;
            //verilator lint_off WIDTH
            assign kk=boogy_baboogy(bstop[3:0],pwh#(32)::cmpEQ(k,0 )&& bundle0[255],5'hf,5'he,5'hd,5'hc,k[4:0]);
            //verilator lint_on WIDTH
            predecoder_class #(LARGE_CORE,H) cls_mod(bundleF[k*16+:32],~instrEndF[k+:4],flag_bits0[k],FMAmul[k],FMAmul[k-1],thread,class_[k],
              is_lnk0[k],is_ret0[k],LNK[k]);
            popcnt20 cntJ_mod(is_jmp[19:0] & ((20'b10<<k)-20'b1),cntJEnd[k]);
            popcnt20 cntL_mod(is_lnk[19:0] & ((20'b10<<k)-20'b1),lcnt[k]);
            assign is_jmpX[k]=class_[`iclass_jump];
            for(subloop_jump=0;subloop_jump<4;subloop_jump=subloop_jump+1) begin : jmp_gen
                assign {lnkLink0[subloop_jump],lnkOff0[subloop_jump],lnkMagic0[subloop_jump],
                    lnkRet0[subloop_jump]}=lcnt[k][subloop_jump+1] & lcnt[k-1][subloop_jump] ? 
                    {LNK[k],kk[4:0],instrEnd[k+:4],is_ret[k]} : 15'bz;
                assign lnkJumps0[subloop_jump]=lcnt[k][subloop_jump+1] & lcnt[k-1][subloop_jump] ? cntJEnd[k][4:0] : 5'bz;
            
                if (pwh#(32)::cmpEQ(k,0)) assign {Jclass0[subloop_jump],Jmagic0[subloop_jump],Jinstr0[subloop_jump],Joff0[subloop_jump]}= 
                    (mask[k] & ~mask[k-1]) ? {class_[k], instrEnd[k+:4],bundle[k*16+:80],kk[4:0]} : 102'bz;
                else assign {Jclass0[subloop_jump],Jmagic0[subloop_jump],Jinstr0[subloop_jump],Joff0[subloop_jump]}= 
                    cntJEnd[k-1][subloop_jump] & cntJEnd[k-2][subloop_jump-1] ? {class_[k], instrEnd[k+:4],bundle0[k*16+:80],k[4:0]} : 102'bz;
                assign {lnkLink0[subloop_jump],lnkOff0[subloop_jump],lnkMagic0[subloop_jump],lnkRet0[subloop_jump]}=lcnt_or_less[subloop_jump] ? 15'b1110_10000_0001_0 : 15'bz; //note - overhang cannot contain link instructions
                assign lnkJumps0[subloop_jump]=lcnt_or_less[subloop_jump] ?  5'd1 : 5'bz;
            end
            for(subloop_insn=0;subloop_insn<16;subloop_insn=subloop_insn+1) begin : insn_gen
                if (pwh#(32)::cmpEQ(k,0)) assign {FMAmulI[0],class0[0],magic0[0],instr0[0],off0[0]}=(mask[k] & ~mask[k-1]) ?
                    {FMAmulI[k],class_[k],instrEnd[k+:4],bundle[k*16+:80],kk[4:0]} : 102'bz;
                else assign {FMAmulI[subloop_insn],class0[subloop_insn],magic0[subloop_insn],instr0[subloop_insn],off0[subloop_insn]}=mask[k] & 
                    cntEnd[k-1][subloop_insn] & cntEnd[k-2][subloop_insn-1] ? {FMAmulI[k],class_[k], instrEnd[k+:4],bundle0[k*16+:80],k[4:0]} : 102'bz;
            end
        end
    endgenerate

    popcnt20_or_less ce2_mod(instrEnd[19:0]&mask[19:0],cntEnd2);
    popcnt20_or_more ce3_mod(instrEnd[19:0]&mask[19:0],cntEnd3);
    popcnt15_or_less ce215_mod(instrEnd[14:0]&mask[14:0],cntEnd2_15);
    popcnt15_or_more ce315_mod(instrEnd[14:0]&mask[14:0],cntEnd3_15);
    popcnt20_or_less jce_mod(is_jmp,jcnt_or_less);
    popcnt15_or_less jce15_mod(is_jmp[14:0],jcnt_or_less_15);
    popcnt20_or_more jcen_mod(is_jmp,jcnt_or_more);
    bit_find_first_bit #(15) getLNK_mod(is_lnk[14:0],first_lnk,has_lnk);    
    popcnt15_or_less lce_mod(is_lnk[14:0],lcnt_or_less);
    assign mask[-1]=1'b0;

    assign cntEnd[-1]=16'd1;
    assign cntEnd[-2]=16'd1;
    assign cntJEnd[-1]=16'd1;
    assign lcnt[-1]=16'd1;
    
    assign last_is_FMAmul=|(FMAmulI[11:0] & (instrEn[11:0]&~(instrEn[11:0]>>1)));
    //verilator lint_off WIDTH
    assign bundleF=boogy_baboogy(bstop[3:0],bundle[255] && pwh#(32)::cmpEQ(startOff,0,){bundle0[255+48:0],btail[63:48]},{bundle0[255+32:0],btail[63:32]}, {bundle0[255+16:0],btail[63:16]},{bundle0[255:0],btail[63:0]},bundle0);

    assign instrEndF=boogy_baboogy(bstop[3:0],bundle0[255] && pwh#(32)::cmpEQ(startOff,0,){instrEnd[16:0],bstop[3:1],instrEnd[-1]},
     {instrEnd[17:0],bstop[3:2],instrEnd[-1]},{instrEnd[18:0],bstop[3],instrEnd[-1]},
      {instrEnd[15:0],bstop[3:0],instrEnd[-1]},instrEnd);
    //veritlator lint_on WIDTH

    assign bundle0={bnext,bundle};
    
    assign FMAmul[-1]=bFMA_mul;

    assign has_brk=has_next && cntEnd2_15[11];

    assign instrEn=cntEnd2[12:1]|{11'b0,pwh#(4)::cmpEQ(startOff,4'hf)};
    assign Jen=jcnt_or_more[4:1];
    
    assign is_jmp=is_jmpX & instrEnd[18:-1];

    assign is_lnk=is_lnk0[14:0] & instrEnd[13:-1];
    assign is_ret=is_lnk0[14:0] & instrEnd[13:-1] & is_ret0[14:0];
    
    assign hasJumps=(is_jmp & mask[19:0])!=15'b0;
    
    always @*
      begin
        instrEnd={2'b0,bnext_stop,bundle[254:240],1'b1};
        error=cntEnd3[13]&~cntEnd3_15[13] || pwh#(32)::cmpEQ(startOff,15);
        _splitinsn=bundle[255];
        jerror=~lcnt_or_less[4] || ~jcnt_or_less[4]&~jcnt_or_less_15[4];
        flag_bits0=20'b0;
        startOff_override=has_brk & ~brk[3] ? brk  : 0;
      end
endmodule

