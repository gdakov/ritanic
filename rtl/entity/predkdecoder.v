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

  input [31:0] instr;
  input [3:0] magic;
  input flag;
  output FMA_mul;
  input prev_FMA_mul;
  input thread;
  output [12:0] class_;
  output isLNK;
  output isRet;
  output [4:0] LNK;

  wire clsIndir;
  wire clsJump;
  wire clsALU;
  wire clsShift;
  wire clsMul;
  wire clsLoad;
  wire clsStore;
  wire clsStore2;
  wire clsFPU;
  wire clsLoadFPU;
  wire clsSys;
  wire clsPos0;
  wire clsFMA;
  
  wire [7:0] opcode_main;

  wire subIsBasicALU;
  wire subIsMovOrExt;
  wire subIsBasicShift;
  wire subIsCmpTest;
  wire subIsCJ;
  wire subIsFPUD;
  wire subIsFPUPD;
  wire subIsFPUE;
  wire subIsFPUSngl;
  wire subIsSIMD;
  wire subIsLinkRet;
  wire subIsBasicXOR;
  wire isBasicXOR;

  
  wire isBasicALU;
  wire isBasicALUExcept;
  wire isBasicShift;
  wire isBasicShiftExcept;
  wire isBasicCmpTest;
//  wire isCmpTestExtra;   
  
  wire isBaseLoadStore;
  wire isBaseIndexLoadStore;
  wire isBaseSpecLoad;
  wire isBaseIndexSpecLoad;
  wire isBaseSpecStore;
  wire isBaseIndexSpecStore;
  wire isImmLoadStore;
  wire isBasicMUL;
  wire isLeaIPRel;

  wire isBasicCJump;
  wire isInvCJumpLong;
  wire isSelfTestCJump;
  wire isLongCondJump;
  wire isUncondJump;
  
  wire isIndirJump;
  wire isCall;
  
  wire isMovOrExt;
  wire isMovOrExtExcept;
  wire isCmov;
  wire isCSet;
  wire isBasicAddNoFl;
  wire isAddNoFlExtra;
  wire isShiftNoFl;

  wire isCexALU;

  wire isSimdInt; 
  wire isFPUreor;

  wire isShlAddMulLike;
  wire isPtrSec;
  wire isJalR;

  wire isBasicFPUScalarA;
  wire isBasicFPUScalarB;
  wire isBasicFPUScalarC;
  wire isBasicFPUScalarCmp;
  wire isBasicFPUScalarCmp2;
  wire isBasicFPUScalarCmp3;

  wire isGA; 

  wire isBasicSysInstr;
  
  wire isCallPrep;

  wire [5:0] opcode_sub;

  wire thisSpecLoad;
  
  assign subIsBasicALU=(!|opcode_sub[5:4] || opcode_sub[5:2]==4'b0100) & ~magic[0];
  assign subIsBasicShift=(~opcode_sub[5] && ~subIsBasicALU && opcode_sub[0]) & ~magic[0];
  assign subIsFPUE=opcode_sub==6'b010100 && ~magic[0]; 
  assign subIsFPUSngl=((opcode_sub==6'b010110 || opcode_sub==6'b011000) && opcode_main[7:6]!=2'b11) & ~magic[0];
  assign subIsLinkRet=(opcode_sub==6'b010110 || opcode_sub==6'b011000) && opcode_main[7:6]==2'b11 && ~magic[0];
  assign subIsSIMD=(opcode_sub[5:3]==3'b011 && |opcode_sub[2:1] && ~opcode_sub[0]) & ~magic[0];
  assign subIsMovOrExt=(opcode_sub[5:3]==3'b100 || opcode_sub[5:1]==5'b10100) & ~magic[0];
  assign subIsCmpTest=(opcode_sub[5:1]==5'b10101 || opcode_sub[5:2]==4'b1011) & ~magic[0];
  assign subIsCJ=opcode_sub[5:2]==4'b1100 && opcode_main[7:0]!=8'b11110010 && |instr[15:8] && ~magic[0]; //zero offset jumps are hint instructions! 
  assign subIsFPUD=(opcode_sub[5:2]==4'b1101 || opcode_sub[5:1]==5'b11100) & ~magic[0];
  assign subIsFPUPD=(opcode_sub[5:3]==3'b111 && opcode_sub[5:1]!=5'b11100) & ~magic[0];
  assign subIsBasicXOR=opcode_sub[5:2]==4'b0100;//not a separate class
  assign isBasicXOR=(opcode_main[7:3]==5'b00100) & ~opcode_main[2];//not a seprarate class
  
  //hint_begin_vec=opcode_main[7:0]==8'b11110011 uc jump offset=0; 2x vectorisation
  //hind_begin_vec_x4=opcode_main[7:0]==8'b01110011 uc jump offset=0; not yet implemented and might not be in the future
  //hint_end_vec=opcode_main[7:0]==8'b10110011 uc jump offset=0
  //ext insn for multi uop=opcode_main[7:0]==8'b11110010

  assign isBasicSysInstr=opcode_main==8'hff&&magic[0]; 

  assign opcode_main=instr[7:0];
  assign opcode_sub=instr[5:0];
  
  
  assign isBasicALU=(!|opcode_main[7:5] || opcode_main[7:3]==5'b00100) & ~opcode_main[2] & magic[0];
  assign isBasicMUL=(!|opcode_main[7:5] || opcode_main[7:3]==5'b00100) & opcode_main[2] & magic[0];
  assign isBasicALUExcept=~opcode_main[0] && (magic[1:0]==2'b01 && |instr[28:26]);  
  assign isBasicShift=(opcode_main[7:1]==7'd20 || opcode_main[7:1]==7'd21 ||
      opcode_main[7:1]==7'd22)&&magic[0];      
  assign isBasicShiftExcept=magic[1:0]==2'b01 && |instr[29:25];
  
  assign isBasicCmpTest=(opcode_main[7:1]==7'd23 || opcode_main[7:2]==6'd12 ||
    opcode_main[7:1]==7'd26 || opcode_main[7:2]==6'd54) && magic[0];

  assign isBaseSpecLoad=(opcode_main==8'd54 || opcode_main==8'd202) && magic[0];
  assign isBaseIndexSpecLoad=(opcode_main==8'd55 || opcode_main==8'd203) && magic[0];
  assign isBaseSpecStore=(opcode_main==8'd204 || opcode_main==8'd205) && magic[0];
  assign isBaseIndexSpecStore=(opcode_main=8'd206 || opcode_main==8'd207) && magic[0];

  assign isImmLoadStore=((opcode_main[7:2]==6'd15) || opcode_main[7:1]==7'b1011000) & magic[0];  
  assign isBaseLoadStore=((opcode_main[7:5]==3'b010) || opcode_main[7:4]==4'b0110) & magic[0];
  assign isBaseIndexLoadStore=((opcode_main[7:5]==3'b100) || opcode_main[7:4]==4'b0111) & magic[0];


  assign isBasicCJump=(opcode_main[7:4]==4'b1010) && magic[0];
  assign isSelfTestCJump=(opcode_main==8'd178 || opcode_main==8'd179) && magic[0];
  assign isLongCondJump=(opcode_main==8'd180) && magic[0];
  assign isUncondJump=(opcode_main==8'd181) && magic[0];
  assign isIndirJump=(opcode_main==8'd182 && instr[15:13]==3'd0) && magic[0];
  assign isCall=(opcode_main==8'd182 && (instr[15:13]==3'd1 || instr[15:13]==3'd2)) && magic[0];
  assign isRet=(opcode_main==8'd182 && instr[15:13]==3'd3) && magic[0];
  assign isMovOrExt=(opcode_main==8'd183 || opcode_main[7:3]==5'b10111 || opcode_main[7:1]==7'd96) && magic[0];
  assign isMovOrExtExcept=magic[1:0]==2'b11 && opcode_main!=8'd183 && opcode_main[7:1]!=7'd92;
  assign isCSet=(opcode_main==8'd194) && magic[0]; 
  assign isBasicAddNoFl=(opcode_main==8'd195 || opcode_main==8'd196) && magic[0];
  
  assign isLeaIPRel=(opcode_main==8'd197) & magic[0];

  assign isCmov=opcode_main==198 && magic[1:0]==2'b01;
  
  
  assign isSimdInt=opcode_main==8'd200 && magic[0];
  assign isFPUreor=opcode_main==8'd201 && magic[0];
  
  assign isShlAddMulLike=(opcode_main==8'd210 || opcode_main==8'd211 ||
    opcode_main==8'd231 || opcode_main==8'd232) && magic[0];
  assign isPtrSec=(opcode_main==8'd212 || opcode_main==8'd233 )&& magic[0];
  assign isJalR=(opcode_main==8'd213 || opcode_main==8'd214 || opcode_main==8'd215 || opcode_main==8'd220 || opcode_main==8'd221) && magic[0];
  assign isCexALU=opcode_main==8'd222 && magic[0];

  assign isCLeave=(opcode_main==8'd235 || opcode_main[7:0]==8'd236 || opcode_main[7:0]==8'd238) && magic[0];
  //237 and 239 unused so far
  assign isBasicFPUScalarA=opcode_main[7:4]==4'hf && ~&opcode_main[1:0] && instr[13:12]==2'b0 && magic[0];
  assign isBasicFPUScalarB=opcode_main[7:4]==4'hf && ~&opcode_main[1:0] && instr[13:12]==2'b1 && magic[0];
  assign isBasicFPUScalarC=opcode_main[7:4]==4'hf && ~&opcode_main[1:0] && instr[15:12]==4'd2 && magic[0];
  assign isBasicFPUScalarCmp=opcode_main[7:4]==4'hf && ~&opcode_main[1:0] && instr[15:12]==4'd6 && magic[0];
  assign isBasicFPUScalarCmp2=opcode_main[7:4]==4'hf && ~&opcode_main[1:0] && instr[15:12]==4'ha && magic[0];
  assign isBasicFPUScalarCmp3=opcode_main[7:4]==4'hf && ~&opcode_main[1:0] && instr[15:12]==4'd12;

  assign isCallPrep=(opcode_main==8'd199) && magic[0];

  assign isGA=opcode_main==8'd237 && magic[0];

  assign isPtrBump_other_domain=opcode_main==8'hf7 && magic[1:0]==2'b01;

  assign thisSpecLoad=isBaseSpecLoad || isBaseIndexSpecLoad || isBaseSpecStore || isBaseIndexSpecStore || 
      ({instr[11],instr[15:12]}==5'd16 &&  opcode_main[7:1]==7'b1011000) || 
      ({instr[1],instr[15:12]}==5'd15 && opcode_main[7:2]==6'd15);

  
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
  opcode_main==8'hff && ~instr[15] && ~instr[13] && magic[0] && 
    instr[30:16]!=15'd22;
  };

  assign clsIndir=|{
  isIndirJump,
  isRet,
  isFPUreor,
  opcode_main==8'hff && ~instr[15] && ~instr[13] && magic[0]
  };

  assign clsFMA=|{,
  FMA_mul,
  subIsFPUD && instr[7],
  subIsFPUPD && instr[7],
  subIsFPUE && ~instr[7]
  };

  assign FMA_mul={instr[31:27]==5'd16 && isBasicFPUScalarB && (instr[13:8]==6'd18) | (instr[13:8]==6'd21) | (instr[13:8]==6'd24),
  instr[31:27]==5'd16 && isBasicFPUScalarA && (instr[13:9]==5'd2) | (instr[13:8]==6'd8)};
  
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
  isSimdInt && ((instr[13:9]==5'd0 && ~instr[16]) || (instr[13:9]==5'd5 && ~instr[16]) || (instr[13:8]==6'b11 && instr[16])),
  subIsBasicALU & ~subIsBasicXOR,subIsCmpTest,subIsLinkRet,
  opcode_main==8'hff && instr[15:13]==3'd1 && magic[0],
  isBasicFPUScalarA && instr[13:9]!=5'd2 && instr[13:8]!=6'd8,
  isBasicFPUScalarB && instr[13:8]!=6'd18 && instr[13:8]!=6'd21,
  isBasicFPUScalarC && instr[13:8]!=6'd32,
  isBasicFPUScalarCmp && instr[13:11]==3'b100,
  isBasicFPUScalarCmp2 && instr[13:10]==4'b1000,
  isBasicFPUScalarCmp3 && instr[13:10]==4'b1000,
  subIsMovOrExt,
  isLeaIPRel,
  isJalR,
  opcode_main==8'd236 && magic[0]
  };
  
  assign clsPos0=opcode_main==8'hff && instr[15:13]==3'd1 && magic[0] && instr[31:16]==`csr_FPU;
  
  assign clsShift=isBasicShift & ~isBasicShiftExcept || subIsBasicShift || subIsFPUD & (opcode_sub[5:1]==5'b11100) ||
    isCexALU & ~instr[12] & instr[10] ||
    subIsFPUPD & prev_FMA_mul || subIsFPUSngl & prev_FMA_mul
    || subIsFPUE & prev_FMA_mul || isSimdInt & instr[16] ||
    (isSimdInt && ~((instr[13:9]==5'd0 && ~instr[16]) || (instr[13:9]==5'd5 && ~instr[16]) ||
     (instr[13:8]==6'b11 && instr[16]))) || 
    isBasicALU & ~isBasicALUExcept & isBasicXOR ||
    subIsBasicALU & subIsBasicXOR ||
    instr[31:27]==5'd16 && prev_FMA_mul && isBasicFPUScalarB && (instr[13:8]==6'd19) | (instr[13:8]==6'd20) |
    (instr[13:9]==5'd11) ||
    instr[31:27]==5'd16 && prev_FMA_mul && isBasicFPUScalarA && (instr[13:10]==4'b0) | (instr [13:9]==5'd3) | (instr[13:10]==6'd9) ||
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
  isBasicFPUScalarCmp3 && instr[13:8]==6'b100100//mlb jump table load gen purp
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
    magic[0] && opcode_main==8'd234,
    isGA,
    isPtrSec,
    isCexALU & instr[12],
    opcode_main==8'hff && ~instr[15] && ~instr[13] && magic[0],
     isBasicFPUScalarC && instr[13:8]==6'd32,

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

    input clk;
    input rst;
    input thread;
    input [255:0] bundle;
    input [64:0] btail;
    input [3:0] bstop;
    input bFMA_mul;
    input [127:0] bnext;
    input [7:0] bnext_tail;
    input has_next;
    input [3:0] startOff;
    output [3:0] startOff_override;
    output [15:0][79:0] instr0;
    output [15:0][3:0] magic0;
    output [15:0][3:0] off0;
    output [15:0][12:0] class0;
    output [15:0] instrEn;
    output reg _splitinsn;
    output hasJumps;
    output last_is_FMAMul;
    output reg error;
    output reg jerror;
    
    output [3:0][79:0] Jinstr0;
    output [3:0][3:0] Jmagic0;
    output [3:0][3:0] Joff0;
    output [3:0][12:0] Jclass0;
    
    output [3:0] Jen;
    output [3:0][4:0] lnkLink0;
    output [3:0][4:0] lnkOff0;
    output [3:0][3:0] lnkMagic0;
    output [3:0]      lnkRet0;
    output [3:0][4:0] lnkJumps0;

    reg [19:-1] instrEnd;
    reg [19:-1] instrEndF;
    
    wire [19:-2][15:0] cntEnd;
    wire [19:-1] mask;
 
    wire [19:0] cntEnd2;
    wire [20:1] cntEnd3;
    wire [14:0] cntEnd2_15;
    wire [15:1] cntEnd3_15;
    
    wire [19:0][12:0] class_ ;
    wire [255+16+64:0] bundle0;
    wire [255+16+64:0] bundleF;

    wire [19:0] is_jmp;
    wire [19:0] is_jmpX;
    wire [20:-1][15:0] cntJEnd;
    wire [19:0] jcnt_or_less;
    wire [14:0] jcnt_or_less_15;
    wire [20:1] jcnt_or_more;
    
    wire [19:0] is_lnk0;
    wire [19:0] is_lnk;
    reg [19:0] is_lnk_reg;
    wire [19:0] first_lnk;
    wire has_lnk;
    wire [19:0][4:0] LNK;
    wire [19:0] lcnt_or_less;
    wire [19:-1][15:0] lcnt;
    wire [19:0] is_ret0;
    wire [19:0] is_ret;
    reg [19:0] is_ret_reg;
    reg [19:0] flag_bits0;
    wire [19:0] mask0;

    wire [19:-1] FMAmul;
    wire [11:0] FMAmulI;

    function [255+64+16:0] boogy_baboogy;
        input [3:0] bstop;
        input cond;
        input [255+64+16:0] index0;
        input [255+64+16:0] index1;
        input [255+64+16:0] index2;
        input [255+64+16:0] index3;
        input [255+64+16:0] index_else;
        begin
            if (cond && bstop[3:2]==2'b01) boogy_baboogy=index0;
            if (cond && bstop[3:1]==3'b001) boogy_baboogy=index1;
            if (cond && bstop[3:0]==4'b0001) boogy_baboogy==index2;
            if (cond &&  bstop[3:0]==4'b0) boogy_baboogy=index3;
            if (!cond || bstop[3]) boogy_baboogy=index_else;
        end
    endfunction
    generate
        genvar k,subloop_insn,subloop_jump;
        for(k=0;k<20;k=k+1) begin : popcnt_gen
            popcnt20 cnt_mod(instrEnd[19:0] & ((20'b10<<k)-20'b1) & mask[19:0],cntEnd[k]);
            get_carry #(5) carry_mod(k[4:0],~{1'b0,startOff},1'b1,mask0[k]);
            mask[k]=mask0[k] || ((k+1)==startOff && !instrEnd[k]) ||
               ((k+2)==startOff && instrEnd[k+:2]==2'b00) ||
               ((k+3)==startOff && instrEnd[k+:3]==3'b000)
               ((k+4)==startOff && instrEnd[k+:4]==4'b0000);
            assign brk=cntEnd[k][12] ? k[3:0] && k[4] : 4'bz;
            wire [4:0] kk;
            //verilator lint_off WIDTH
            assign kk=boogy_baboogy(bstop[3:0],k==0 && bundle0[255],5'hf,5'he,5'hd,5'hc,k[4:0]);
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
            
                if (k==0) assign {Jclass0[subloop_jump],Jmagic0[subloop_jump],Jinstr0[subloop_jump],Joff0[subloop_jump]}= 
                    (mask[k] & ~mask[k-1]) ? {class_[k], instrEnd[k+:4],bundle[k*16+:80],kk[4:0]} : 102'bz;
                else assign {Jclass0[subloop_jump],Jmagic0[subloop_jump],Jinstr0[subloop_jump],Joff0[subloop_jump]}= 
                    cntJEnd[k-1][subloop_jump] & cntJEnd[k-2][subloop_jump-1] ? {class_[k], instrEnd[k+:4],bundle0[k*16+:80],k[4:0]} : 102'bz;
                assign {lnkLink0[subloop_jump],lnkOff0[subloop_jump],lnkMagic0[subloop_jump],lnkRet0[subloop_jump]}=lcnt_or_less[subloop_jump] ? 15'b1110_10000_0001_0 : 15'bz; //note - overhang cannot contain link instructions
                assign lnkJumps0[subloop_jump]=lcnt_or_less[subloop_jump] ?  5'd1 : 5'bz;
            end
            for(subloop_insn=0;subloop_insn<16;subloop_insn=subloop_insn+1) begin : insn_gen
                if (k==0) assign {FMAmulI[0],class0[0],magic0[0],instr0[0],off0[0]}=(mask[k] & ~mask[k-1]) ?
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
    
    assign last_is_FMAmul=|(FMAmulI[11:0] & (instrEn[11:0]&~(instrEn[11:0]>>1));
    //verilator lint_off WIDTH
    assign bundleF=boogy_baboogy(bstop[3:0],bundle[255] && startOff==0,{bundle0[255+48:0],btail[63:48]},{bundle0[255+32:0],btail[63:32]}, {bundle0[255+16:0],btail[63:16]},{bundle0[255:0],btail[63:0]},bundle0);

    assign instrEndF=boogy_baboogy(bstop[3:0],bundle0[255] && startOff==0,{instrEnd[16:0],bstop[3:1],instrEnd[-1]},
     {instrEnd[17:0],bstop[3:2],instrEnd[-1]},{instrEnd[18:0],bstop[3],instrEnd[-1]},
      {instrEnd[15:0],bstop[3:0],instrEnd[-1]},instrEnd);
    //veritlator lint_on WIDTH

    assign bundle0={bnext,bundle};
    
    assign FMAmul[-1]=bFMA_mul;

    assign has_brk=has_next && cntEnd2_15[11];

    assign instrEn=cntEnd2[12:1]|{11'b0,startOff==4'hf};
    assign Jen=jcnt_or_more[4:1];
    
    assign is_jmp=is_jmpX & instrEnd[18:-1];

    assign is_lnk=is_lnk0[14:0] & instrEnd[13:-1];
    assign is_ret=is_lnk0[14:0] & instrEnd[13:-1] & is_ret0[14:0];
    
    assign hasJumps=(is_jmp & mask[19:0])!=15'b0;
    
    always @*
      begin
        instrEnd={2'b0,bnext_stop,bundle[254:240],1'b1};
        error=cntEnd3[13]&~cntEnd3_15[13] || startOff==15;
        _splitinsn=bundle[255];
        jerror=~lcnt_or_less[4] || ~jcnt_or_less[4]&~jcnt_or_less_15[4];
        flag_bits0=20'b0;
        startOff_override=has_brk & ~brk[3] ? brk  : 0;
      end
endmodule

