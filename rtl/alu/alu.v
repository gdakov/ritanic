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
`include "../operations.sv"


//compile alu into hard macro with 1 horizontal x2 wire
//do not delete redundant output
//place next to alu_shift in alu-shift combo

module 
alu(clk,rst,except,except_thread,thread,operation,cond,sub,dataEn,nDataAlt,retData,retEn,val1,val2,valS,valRes,sec,error,rmode);

  localparam REG_WIDTH=`reg_addr_width;
  localparam OPERATION_WIDTH=`operation_width;
  localparam EXCEPT_WIDTH=9;
  localparam FLAG_WIDTH=6; 
  parameter NOSHIFT=1'b1;  
  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire except_thread;
  input pwire thread;
  input pwire [OPERATION_WIDTH-1:0] operation;
  input pwire [4:0] cond;
  input pwire [5:0] sub; //high power fat wire
  input pwire dataEn;//1=coming data from rs
  input pwire nDataAlt;//0=feeding data through multiclk unit
  output pwire [EXCEPT_WIDTH-1:0] retData;
  output pwire retEn;
  input pwire [2:0][65:0] val1;
  input pwire [2:0][65:0] val2;
  input pwire [5:0] valS;//flag
  inout pwire  [65:0] valRes;  
  input pwire sec;
  input pwire error;
  input pwire [2:0] rmode;
  

  pwire [64:0] valRes_reg;

  pwire [64:0] valRes1;  
  pwire [7:0] valRes8;
  pwire [64:0] valRes2;  


  pwire flag64_ZF;
  pwire flag32_ZF;
  pwire flag64_ZF_reg;
  pwire flag32_ZF_reg;
  pwire flag16_ZF;
  pwire flag8_ZF;
  pwire flag16_ZF_reg;
  pwire flag8_ZF_reg;
        
  pwire flag8_PF;
  pwire flag8_PF_reg;
  pwire flag8_SF;
  pwire flagAdd8_CF;
  pwire flagAdd8_AF;

  
  pwire carryAdd44;
  pwire carryAdd64;
  pwire carryAdd32;
  pwire carryAdd16;
  pwire carryAdd8LL;
  pwire carryAdd4LL;
        
  
  
  
  pwire carryAdd44_reg;
  pwire carryAdd64_reg;
  pwire carryAdd32_reg;
  pwire carryAdd16_reg;
  pwire carryAdd8LL_reg;
  pwire carryAdd4LL_reg;
        
  
  pwire val1_sign44;
  pwire val1_sign65;
  pwire val1_sign64;
  pwire val1_sign32;
  pwire val1_sign16;
  pwire val1_sign8;

  function [55:0] fff;
  input pwire [15:0] val;
  input pwire [55:0] v2;
      fff[14:0]=v2[14:0] ^ val[14:0];
      fff[27:15]=v2[27:15] ^ (v2[14:0] & val[14:0]);
      fff[41:28]=v2[41:28] ^ (v2[27:15] & v2[14:0] & val[14:0]);
      fff[55:42]=v2[55:42] ^ (v2[41:28] & v2[27:15] & v2[14:0] & val[14:0]);
      fff[63:56]={1'b0,fff[55:49]};
  endfunction
          
  pwire val2_sign64;
  pwire val2_sign65;
  pwire val2_sign44;
  pwire val2_sign32;
  pwire val2_sign16;
  pwire val2_sign8;
  
  pwire flagAdd64_OF;
  pwire flagAdd32_OF;
  pwire flagAdd16_OF;
  pwire flagAdd8_OF;
          
  pwire flagSub64_OF;
  pwire flagSub44_OF;
  pwire flagSub32_OF;
  pwire flagSub16_OF;
  pwire flagSub8_OF;
  
  pwire flagAdd64_OF_reg;
  pwire flagAdd32_OF_reg;
  pwire flagSub64_OF_reg;
  pwire flagSub44_OF_reg;
  pwire flagSub32_OF_reg;
  pwire flagSub16_OF_reg;
  pwire flagSub8_OF_reg;

  pwire [5:0] flags_COASZP;



  pwire isFlags;
  pwire isFlags_reg;
  pwire [2:0] reg8flg;
  pwire [7:0] smallOP;
  pwire nDataAlt_reg;

  pwire [64:0] val_and;
  pwire [64:0] val_or;
  pwire [64:0] val_xor;
 
  pwire nDataAlt2; 
  pwire [3:0] val1One;
  pwire [3:0] val1One_reg;
 
  pwire [4:0] jumpType; 
  pwire doJmp;
  pwire doJmp_reg;
  pwire doJmp2;

  pwire add_en;
  pwire shift_en;
  pwire add8_en;
  pwire sahf_en;
  pwire shift_en_reg;
  
  pwire [OPERATION_WIDTH-1:0] retOp;
  pwire [5:0] valS_reg;
  pwire [5:0] val1_reg;

  pwire dataEn_reg;
  pwire thrinh;
  pwire thrinh_reg;
  pwire except_reg;
  pwire except_thread_reg;
  pwire logic_en,spec1_en,spec2_en;
  pwire cmov_en;
  pwire logic_en_reg;

  pwire [2:0] cin_seq;
  pwire cin_seq_reg;
  pwire is_ptr,is_sub;
  pwire cout_seq;
  pwire [64:0] ptr;
  pwire [64:0] ptr_reg;
  pwire is_ptr_reg;
  pwire is_ptr_sub;

  assign reg8flg=operation[10:8];
  assign smallOP=operation[7:0];

  assign jumpType[4]=1'b0;
  assign jumpType[3:1]=operation[10:8];
  assign jumpType[0]=operation[0]; //1 for inverse

  
  assign isFlags=~operation[12];
  
  assign val1One[0]=|val1[1][7:0];
  assign val1One[1]=|val1[1][15:8];
  assign val1One[2]=|val1[1][31:16];
  assign val1One[3]=|val1[1][63:32];
  
  assign val_or={is_ptr ? ptr[63:44] : val1[1][63:44]|val2[1][63:44],val1[1][43:0]|val2[1][43:0]};
  assign val_xor={is_ptr ? ptr[63:44] : val1[1][63:44]^val2[1][63:44],val1[1][43:0]^val2[1][43:0]};
  assign val_and={is_ptr ? ptr[63:44] : val1[1][63:44]&(val2[1][63:44]^{20{rmode[1]}}),val1[1][43:0]&(val2[1][43:0]^{44{rmode[1]}})};
  
  assign nDataAlt2=nDataAlt && doJmp2 | ~cond[4];
  assign valRes=(add_en||shift_en&~NOSHIFT||(pwh#(8)::cmpEQ(operation[7:0],`op_cax) && NOSHIFT)||~nDataAlt)&~(~doJmp2|~cond[4]) ? 
    66'bz : {^{nDataAlt & ~nDataAlt2 ? val1[1][64]&~|operation[10:9] : is_ptr,valRes2},
    {nDataAlt & ~nDataAlt2 ? val1[1][64]&~|operation[10:9] : is_ptr,valRes2}};
//4 phase offset for the ecc bit
  assign valRes2[63:0]=(operation[11] || ~nDataAlt) ? 64'b0: 64'bz;
  assign valRes2[63:0]=nDataAlt & ~nDataAlt2 ? (|operation[10:9] ? {{63{~operation[9]}},operation[10]} : val1[1][63:0]) : 64'bz;
  assign valRes2[63:0]=(~add8_en & ~sahf_en && nDataAlt2) ? valRes1 : 64'bz;
  assign valRes2[63:8]=(add8_en|sahf_en && nDataAlt2) ? 56'b0 : 56'bz;
  assign valRes2[7:0]=(add8_en|sahf_en && nDataAlt2) ? valRes8 : 8'bz;

  assign valRes8=(sahf_en) ? 8'bz : 8'b0;
  assign valRes8=sahf_en ? {2'b0,valS} : 8'bz;

  assign logic_en=(operation[7:3]==5'd1 || operation[7:2]==6'b100);
  assign spec1_en=operation[7:2]==6'b1010;
  assign spec2_en=(operation[7:3]==5'b110 && operation[7:0]!=8'd56) || operation[7:1]==7'd29;
  
  assign valRes1=(operation[11] || ~nDataAlt || (~logic_en && ~spec1_en && ~spec2_en)) ? 
    64'b0: 64'bz;
  assign add_en=(~(|operation[7:3])|(operation[7:1]==7'd30)|(operation[7:1]==7'd23) && ~operation[11]) && nDataAlt;
  assign add8_en=1'b0;
  assign sahf_en=~operation[11] && pwh#(8)::cmpEQ(operation[7:0],`op_sahf) && nDataAlt;
  assign shift_en=(operation[7:2]==6'd5 || operation[7:2]==6'd6 || operation[7:2]==6'd7) && nDataAlt && ~operation[11];
  assign valRes1=(add_en|shift_en) ? 64'b0 : 64'bz;
    
  assign flag8_SF=retOp[8] ? valRes_reg[15] : valRes_reg[7];

  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_and64)) && nDataAlt) ? val_and[63:32] : 32'bz;   
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_and32)) && nDataAlt) ? 32'b0 : 32'bz;   
  assign valRes1[31:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_and32) || pwh#(12)::cmpEQ(operation[11:0],`op_and64)) && nDataAlt) ? val_and[31:0] : 32'bz;   
  

  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_or64) || operation[11:1]==11'd29) && nDataAlt) ? val_or[63:32] : 32'bz;   
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_or32)) && nDataAlt) ? 32'b0  : 32'bz;   
  assign valRes1[31:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_or32) || pwh#(12)::cmpEQ(operation[11:0],`op_or64)) && nDataAlt) ? val_or[31:0] : 32'bz;   
  
  
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_xor64)) && nDataAlt) ? val_xor[63:32] : 32'bz;   
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_xor32)) && nDataAlt) ? 32'b0  : 32'bz;   
  assign valRes1[31:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_xor32) || pwh#(12)::cmpEQ(operation[11:0],`op_xor64)) && nDataAlt) ? val_xor[31:0] : 32'bz;   
  
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_nxor64)) && nDataAlt) ? (~val_xor[63:32]) : 32'bz;   
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_nxor32)) && nDataAlt) ? 32'b0  : 32'bz;   
  assign valRes1[31:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_nxor32) || pwh#(12)::cmpEQ(operation[11:0],`op_nxor64)) && nDataAlt) ? 
	  (~val_xor[31:0]) : 32'bz;   
  

  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_mov64)) && nDataAlt) ? val2[1][63:32] : 32'bz;   
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_mov32)) && nDataAlt) ? 32'b0 : 32'bz;   
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_mov16) || (pwh#(8)::cmpEQ(operation[7:0],`op_mov8) || operation[11:1]==11'd3)&~operation[11]) && nDataAlt) ? val1[1][63:32] : 32'bz;   
  assign valRes1[31:16]=((pwh#(12)::cmpEQ(operation[11:0],`op_mov32) || pwh#(12)::cmpEQ(operation[11:0],`op_mov64)) && nDataAlt) ? val2[1][31:16] : 16'bz;   
  assign valRes1[31:16]=((pwh#(12)::cmpEQ(operation[11:0],`op_mov16) || (pwh#(8)::cmpEQ(operation[7:0],`op_mov8) || operation[11:1]==11'd3)&~operation[11]) && nDataAlt) ? val1[1][31:16] : 16'bz;   
  assign valRes1[15:0]=((((operation[9:0]==`op_mov16) && ~operation[10]) || pwh#(12)::cmpEQ(operation[11:0],`op_mov32) || pwh#(12)::cmpEQ(operation[11:0],`op_mov64)) && nDataAlt) ?
    val2[1][15:0] : 16'bz;   
  assign valRes1[15:0]=((((operation[9:0]==`op_mov16) && operation[10])) && nDataAlt) ?
    val2[1][31:16] : 16'bz;   
  assign valRes1[15:0]=((operation[9:0]=={2'b000,8'd`op_mov8}) && nDataAlt) ? {val1[1][15:8],val2[1][7:0]} : 16'bz;   
  assign valRes1[15:0]=((operation[9:0]=={2'b01,8'd`op_mov8}) && nDataAlt) ? {val1[1][15:8],val2[1][15:8]} : 16'bz;   
  assign valRes1[15:0]=((operation[9:0]=={2'b10,8'd`op_mov8}) && nDataAlt) ? {val2[1][7:0],val1[1][7:0]} : 16'bz;   
  assign valRes1[15:0]=((operation[9:0]=={2'b11,8'd`op_mov8}) && nDataAlt) ? {val2[1][15:8],val1[1][7:0]} : 16'bz;   
  assign valRes1[15:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_or8)) && nDataAlt) ? {val1[1][15:8],val_or[7:0]} : 16'bz;   
  assign valRes1[15:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_or16)) && nDataAlt) ? {val_or[15:0]} : 16'bz;   
  assign valRes1[15:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_and8)) && nDataAlt) ? {val1[15:8],val_and[7:0]} : 16'bz;   
  assign valRes1[15:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_and16)) && nDataAlt) ? {val_and[15:0]} : 16'bz;   
  

  assign valRes1[63:32]=(((pwh#(12)::cmpEQ(operation[11:0],`op_zxt16_64)) || (pwh#(8)::cmpEQ(operation[7:0],`op_zxt8_64) && ~operation[11]))
    && nDataAlt) ? 32'b0 : 32'bz;   
  assign valRes1[31:16]=((pwh#(12)::cmpEQ(operation[11:0],`op_zxt16_64) || (pwh#(8)::cmpEQ(operation[7:0],`op_zxt8_64) && ~operation[11])) && nDataAlt) ? 16'b0 : 16'bz;   
  assign valRes1[15:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_zxt16_64)) && nDataAlt) ?
    val2[1][15:0] : 16'bz;
  assign valRes1[15:8]=((pwh#(8)::cmpEQ(operation[7:0],`op_zxt8_64)) && ~operation[11] && nDataAlt) ? 8'b0 : 8'bz;   
  assign valRes1[7:0]=((pwh#(8)::cmpEQ(operation[7:0],`op_zxt8_64)) && nDataAlt) ? val2[1][7:0]: 8'bz;   

  assign cmov_en=~operation[11] && (pwh#(8)::cmpEQ(operation[7:0],`op_cmov64) || pwh#(8)::cmpEQ(operation[7:0],`op_cmovn64));

  assign valRes1[63:32]=pwh#(12)::cmpEQ(operation[11:0],`op_sxt16_32) || (pwh#(8)::cmpEQ(operation[7:0],`op_sxt8_32) && ~operation[11])
    && nDataAlt ? 32'b0 : 32'bz;   
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_sxt16_64)) && nDataAlt) ? {32{val2[1][15]}} : 32'bz;
  assign valRes1[63:32]=((pwh#(12)::cmpEQ(operation[11:0],`op_sxt32_64)) && nDataAlt) ? {32{val2[1][31]}} : 32'bz;
  assign valRes1[63:32]=((pwh#(8)::cmpEQ(operation[7:0],`op_sxt8_64)) && nDataAlt) ? {32{val2[1][7]}} : 32'bz;
  assign valRes1[31:16]=(pwh#(12)::cmpEQ(operation[11:0],`op_sxt32_64) && nDataAlt) ? val2[1][31:16] : 16'bz;
  assign valRes1[31:16]=((pwh#(12)::cmpEQ(operation[11:0],`op_sxt16_32) || pwh#(12)::cmpEQ(operation[11:0],`op_sxt16_64)) && nDataAlt) ? {16{val2[1][15]}} : 16'bz;
  assign valRes1[31:8]=((pwh#(8)::cmpEQ(operation[7:0],`op_sxt8_32) || pwh#(8)::cmpEQ(operation[7:0],`op_sxt8_64)) 
    && nDataAlt) ? {24{val2[1][7]}} : 24'bz;
  assign valRes1[15:0]=((pwh#(12)::cmpEQ(operation[11:0],`op_sxt16_32) || pwh#(12)::cmpEQ(operation[11:0],`op_sxt16_64) || pwh#(12)::cmpEQ(operation[11:0],`op_sxt32_64))
    && nDataAlt) ? val2[1][15:0] : 16'bz;
  assign valRes1[7:0]=((pwh#(8)::cmpEQ(operation[7:0],`op_sxt8_64) || pwh#(8)::cmpEQ(operation[7:0],`op_sxt8_32))
    && nDataAlt) ? val2[1][7:0]: 8'bz;   
  
  assign valRes1[63:0]=((smallOP==`op_cmov64 || smallOP==`op_cmov32 ||
    smallOP==`op_cmovn32 || smallOP==`op_cmovn64) && ~operation[11] && doJmp) ? fff(val2[15:0],val1[63:0]) : 32'bz;
  assign valRes1[63:0]=((smallOP==`op_cmov64 || smallOP==`op_cmov32 ||
    smallOP==`op_cmovn32 || smallOP==`op_cmovn64) && ~operation[11] && ~doJmp) ? val1[1][31:0] : 32'bz;

  assign valRes1[31:0]=((smallOP==`op_clahf || smallOP==`op_clahfn) && ~operation[11] ) ? 32'b0 : 32'bz;

  assign valRes1[63:32]=((smallOP==`op_clahf || smallOP==`op_clahfn ) && ~operation[11]) ? 32'b0 : 32'bz;

    
  assign valRes1[63:32]=((smallOP==`op_cmov64 || smallOP==`op_cmovn64) && ~operation[11] && doJmp) ? val2[1][63:32] : 32'bz;
  assign valRes1[63:32]=((smallOP==`op_cmov64 || smallOP==`op_cmovn64) && ~operation[11] && ~doJmp) ? val1[1][63:32] : 32'bz;

  assign valRes1[7:0]=((smallOP==`op_cset || smallOP==`op_csetn) && ~operation[11]) ? {7'b0,doJmp} : 8'bz;
//  assign valRes1[7:0]=((smallOP==`op_csand || smallOP==`op_csandn) && ~operation[11]) ? {7'b0,doJmp&val1[1][0]} : 8'bz;
//  assign valRes1[7:0]=((smallOP==`op_csor || smallOP==`op_csor_n) && ~operation[11]) ? {7'b0,doJmp|val1[1][0]} : 8'bz;

  assign valRes1[63:8]=((smallOP==`op_cset || smallOP==`op_csetn) && ~operation[11]) ? 56'b0 : 56'bz;
 
  assign is_ptr=val1[0][64]|val2[0][64]|(operation[11:0]==12'd58) && ~(val1[0][64]&val2[0][64]&is_sub||val2[0][64]&is_sub) && (add_en&~operation[8])|logic_en|
    (cmov_en&&(doJmp&val2[1][64]||~doJmp&val1[1][64]))|(operation[11:0]==12'd58)|(pwh#(12)::cmpEQ(operation[11:0],`op_mov64)) && 
    ((operation[1:0]==2'b0 && operation[7:5]==3'b0|(operation[7:2]==6'b001000))||cmov_en||operation[11:1]==11'd29);

  assign is_sub=pwh#(8)::cmpEQ(operation[7:0],`op_sub64);

  assign ptr=val1[0][64] ? val1[0][63:0] : val2[0][63:0];
  
  addsub_alu mainAdder_mod(
    .a(val1[0][64:0]),
    .b(val2[0][64:0]),
    .out(valRes),
    .sub(sub),
    .cin(~rmode[0]),
    .en(add_en),
    .sxtEn(operation[8]|rmode[1]),
	  .pooh(1'b0),
    .ben({(pwh#(8)::cmpEQ(operation[7:0],`op_add64) || pwh#(8)::cmpEQ(operation[7:0],`op_sub64) || operation[7:1]==7'd30 || operation[7:1]==7'd1 || operation[7:1]==7'd23) && 
    ~is_ptr && ~(val1[0][64]&val2[0][64]&is_sub||val2[0][64]&is_sub),
    (pwh#(8)::cmpEQ(operation[7:0],`op_add64) || pwh#(8)::cmpEQ(operation[7:0],`op_sub64) || operation[7:1]==7'd30 || operation[7:1]==7'd1 || operation[7:1]==7'd23),operation[7:3]==5'd0 && ~operation[1] || 
      operation[7:1]==7'd30 || operation[7:1]==7'd23, 
      operation[7:3]==5'd0 && operation[1:0]!=2'b11 ||operation[7:1]==7'd30 || operation[7:1]==7'd23}),
    .cout(carryAdd64),
    .cout4(carryAdd4LL),
    .cout8LL(carryAdd8LL),
    .cout16(carryAdd16),
    .cout32(carryAdd32),
    .cout_sec(cin_seq),
    .ndiff(),
    .cout44(carryAdd44)
    );

  except_jump_cmp jcmp_mod (valS,jumpType,doJmp);
  except_jump_cmp jcmp2_mod (valS,{1'b0,cond[3:0]},doJmp2);
  
 
  assign flag64_ZF=(valRes[63:1]==64'b0);
  assign flag32_ZF=(valRes[31:1]==32'b0);
  assign flag16_ZF=(valRes[15:1]==16'b0);
  assign flag8_ZF=(valRes[7:1]==8'b0);

  
  assign flag8_PF=~^(valRes[7:0]);

  assign flagAdd64_OF=val1[0][63] & val2[0][63] & ~valRes[63] | ~val1[0][63] & ~val2[0][63] & valRes[63];  
  assign flagAdd32_OF=val1[0][31] & val2[0][31] & ~valRes[31] | ~val1[0][31] & ~val2[0][31] & valRes[31];  
  assign flagAdd16_OF=val1[0][15] & val2[0][15] & ~valRes[15] | ~val1[0][15] & ~val2[0][15] & valRes[15];  

  assign flagSub44_OF=val1[0][43] & ~val2[0][43] & ~valRes[43] | ~val1[0][43] & val2[0][43] & valRes[43];  
  assign flagSub64_OF=val1[0][63] & ~val2[0][63] & ~valRes[63] | ~val1[0][63] & val2[0][63] & valRes[63];  
  assign flagSub32_OF=val1[0][31] & ~val2[0][31] & ~valRes[31] | ~val1[0][31] & val2[0][31] & valRes[31];  
  assign flagSub16_OF=val1[0][15] & ~val2[0][15] & ~valRes[15] | ~val1[0][15] & val2[0][15] & valRes[15];  
  assign flagSub8_OF=val1[0][7] & ~val2[0][7] & ~valRes[7] | ~val1[0][7] & val2[0][7] & valRes[7];  
   
// flag assignment mux
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_add64)) && ~(retOp[2]&operation_reg[8]) && isFlags_reg) ? 
      {carryAdd64_reg&~is_ptr_reg,flagAdd64_OF_reg&~is_ptr_reg,carryAdd4LL_reg&~is_ptr_reg,valRes_reg[63],flag64_ZF_reg,valRes_reg[0]} : 6'bz;
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_add32) || pwh#(8)::cmpEQ(retOp[7:0],`op_sub32)) && isFlags_reg) ? {carryAdd32_reg,flagAdd32_OF_reg,carryAdd4LL_reg,valRes_reg[31],flag32_ZF_reg,valRes_reg[0]} : 6'bz;
  assign flags_COASZP=((retOp[7:1]==7'd23) && isFlags_reg) ? {(flag64_SF_reg^flag64_OF_reg)&&~&valRes_reg[51:47]||~doJmp_reg,flag64_OF_reg,1'b0,valRes_reg[63],valRes_reg[63:47]==17'b0,
     valRes_reg[0]} : 6'bz;
  
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_sub64)) && isFlags_reg && is_ptr_sub) ? {carryAdd44_reg,flagSub44_OF_reg,~carryAdd4LL_reg,valRes_reg[43],flag64_ZF_reg,valRes_reg[0]} : 6'bz;
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_sub64)) && isFlags_reg && ~is_ptr_sub) ? {carryAdd64_reg & ~is_ptr_reg,flagSub64_OF_reg&~is_ptr_reg,~carryAdd4LL_reg&~is_ptr_reg,valRes_reg[63],flag64_ZF_reg,valRes_reg[0]} : 6'bz;
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_cmp16) || pwh#(8)::cmpEQ(retOp[7:0],`op_add16)) && isFlags_reg) ? {carryAdd16_reg,flagSub16_OF_reg,~carryAdd4LL_reg,valRes_reg[15],flag16_ZF_reg,valRes_reg[0]} : 6'bz;
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_cmp8) || pwh#(8)::cmpEQ(retOp[7:0],`op_add8)) && isFlags_reg) ? {carryAdd8LL_reg,flagSub8_OF_reg,~carryAdd4LL_reg,valRes_reg[7],flag8_ZF_reg,1'b0} : 6'bz;

  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_and64)) | (retOp==`op_or64) | (retOp==`op_xor64) | (retOp==`op_nxor64) && isFlags_reg) ? 
    {retOp==`op_nxor64 && is_ptr_reg,2'b000,valRes_reg[63],flag64_ZF_reg,1'b0} : 6'bz;
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_and32)) | (retOp==`op_or32) | (retOp==`op_xor32) | (retOp[7:1]==7'd5) | (retOp[7:1]==7'd7)
     | (retOp==`op_nxor32) | (retOp=`op_add64 && operation_reg[8]) && isFlags_reg) ? {flagAdd16_CF_reg,flagAdd16_OF_reg,1'b0,valRes_reg[31],flag32_ZF_reg,1'b0} : 6'bz;

  assign flags_COASZP=((|retOp[7:5]) && retOp[7:0]!=`op_lahf && retOp[7:0]!=`op_clahf && retOp[7:0]!=`op_clahfn &&
	  ~retOp[11]) ? 6'b0 : 6'bz;
  assign flags_COASZP=(pwh#(8)::cmpEQ(retOp[7:0],`op_lahf) && ~retOp[11]) ? val1_reg[5:0] : 6'bz;
  assign flags_COASZP=(isFlags_reg&~retOp[11]&(retOp[7:5]==3'b0)) ? 6'bz : 6'b0;  
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_clahf) || pwh#(8)::cmpEQ(retOp[7:0],`op_clahfn)) && doJmp_reg) ? val1_reg[5:0] : 6'bz;
  assign flags_COASZP=((pwh#(8)::cmpEQ(retOp[7:0],`op_clahf) || pwh#(8)::cmpEQ(retOp[7:0],`op_clahfn)) && ~doJmp_reg) ? valS_reg : 6'bz;
  //other stuff
  
  assign retData[`except_flags]=nDataAlt_reg && ~shift_en_reg|NOSHIFT 
    && cin_seq_reg|~is_ptr_reg && (sec&&pwh#(8)::cmpEQ(retOp[7:0],`op_cax))|~NOSHIFT && (~val2_sign65||val1_sign65||retOp[7:0]!=`op_sub64) &&
    (!val1_sign65 || !val2_sign65 || !logic_en_reg) && ~error  ? flags_COASZP : 6'bz;
  assign retData[`except_flags]=nDataAlt_reg && (~shift_en_reg|NOSHIFT 
    && (~cin_seq_reg & is_ptr_reg || val2_sign65 & ~val1_sign65 & (pwh#(8)::cmpEQ(retOp[7:0],`op_sub64))
    || val2_sign65 & val1_sign65 & logic_en_reg || NOSHIFT&(~sec&&pwh#(8)::cmpEQ(retOp[7:0],`op_cax))) | error) ? (error ? 6'd63 : 6'd11) : 6'bz;
  assign retData[`except_status]=nDataAlt_reg && cin_seq_reg|~is_ptr_reg && (~val2_sign65||val1_sign65||retOp[7:0]!=`op_sub64) &&
    (!val1_sign65 || !val2_sign65 || !logic_en_reg) && !(NOSHIFT&(~sec&&pwh#(8)::cmpEQ(retOp[7:0],`op_cax))) && ~ error ? 2'd2 : 2'bz; //done
  assign retData[`except_status]=nDataAlt_reg && ((~cin_seq_reg & is_ptr_reg || val2_sign65 & ~val1_sign65 & (pwh#(8)::cmpEQ(retOp[7:0],`op_sub64))
    || val2_sign65 & val1_sign65 & logic_en_reg || NOSHIFT&(~sec&&pwh#(8)::cmpEQ(retOp[7:0],`op_cax))) | error) ? 2'd1 : 2'bz; //done
  assign retData[`except_setsFlags]=nDataAlt_reg ? isFlags_reg&dataEn_reg : 1'bz;
  
  assign retEn=nDataAlt_reg ? dataEn_reg & ~retOp[11] &~thrinh_reg : 1'bz; 

  assign thrinh=(thread^~except_thread && except) || (thread^~except_thread_reg && except_reg);

  assign boogy_baboogy=is_ptr && ~|valRes[`ptr_low] && &valRes[`ptr_hi]; //this indicates an elided load

  
`ifndef aluneg
  always @(posedge clk)
`else
  always @(negedge clk)
`endif
    begin
//      $display("flg ",valS," jt ",jumpType," j",doJmp," op ",operation);
      if (rst)
        begin
          valRes_reg<=65'b0;
         // retEn<=1'b0;
          isFlags_reg<=1'b1;
          retOp<={OPERATION_WIDTH{1'b0}};

          carryAdd44_reg<=1'b0;
          carryAdd64_reg<=1'b0;
          carryAdd32_reg<=1'b0;
          carryAdd16_reg<=1'b0;
          carryAdd8LL_reg <=1'b0;
          carryAdd4LL_reg <=1'b0;
      
          val1_sign65<=1'b0;
          val1_sign64<=1'b0;
          val1_sign44<=1'b0;
          val1_sign32<=1'b0;
          val1_sign16<=1'b0;
          val1_sign8<=1'b0;

          val2_sign44<=1'b0;
          val2_sign65<=1'b0;
          val2_sign64<=1'b0;
          val2_sign32<=1'b0;
          val2_sign16<=1'b0;
          val2_sign8<=1'b0;
          
          val1One_reg<=4'b0;
          
          dataEn_reg<=1'b0;
          
          nDataAlt_reg<=1'b1;
          
          valS_reg<=6'b0;
          val1_reg<=6'b0;

	  shift_en_reg<=1'b0;

	  doJmp_reg<=1'b0;

          thrinh_reg<=1'b0;
          except_reg<=1'b0;
          except_thread_reg<=1'b0;
          cin_seq_reg<=1'b0;
          is_ptr_reg<=1'b0;
	  is_ptr_sub<=1'b0;
	  logic_en_reg<=1'b0;
          
	  flag64_ZF_reg<=1'b0;
          flag32_ZF_reg<=1'b0;
	  flag16_ZF_reg<=1'b0;
          flag8_ZF_reg<=1'b0;
          flag8_PF_reg<=1'b0;
	  flagAdd64_OF_reg<=1'b0;
          flagAdd32_OF_reg<=1'b0;
          flagAdd16_OF_reg<=1'b0;
	  flagSub64_OF_reg<=1'b0;
          flagSub32_OF_reg<=1'b0;
	  flagSub44_OF_reg<=1'b0;
          flagSub16_OF_reg<=1'b0;
          flagSub8_OF_reg<=1'b0;
        end
      else
        begin
          valRes_reg<=valRes[64:0];
//          retEn<=dataEn & ~except;
          isFlags_reg<=isFlags || {opcode[7:1],1'b0}==`op_cloop_even;
          retOp<=operation;

          carryAdd64_reg<=(carryAdd64 && valS[0]|(calu[3:0]!=4'he)) & ~calu[4]|doJmp2 | calu[4]&~doJmp2&~operation[10]&operation[9];
          carryAdd44_reg<=(carryAdd44) & ~calu[4]|doJmp2| calu[4]&~doJmp2&~operation[10]&operation[9];
          carryAdd32_reg<=(carryAdd32) & ~calu[4]|doJmp2| calu[4]&~doJmp2&~operation[10]&operation[9];
          carryAdd16_reg<=(carryAdd16) & ~calu[4]|doJmp2;
          carryAdd4LL_reg <=(carryAdd4LL) & ~calu[4]|doJmp2 ;
          carryAdd8LL_reg <=(carryAdd8LL) & ~calu[4]|doJmp2;
        

          val1_sign65<=val1[~add_en][64];
          val1_sign44<=val1[~add_en][43];
          val1_sign64<=val1[~add_en][63];
          val1_sign32<=val1[~add_en][31];
          val1_sign16<=val1[~add_en][15];
          val1_sign8<=operation[9] ? val1[~add_en][15] : val1[~add_en][7];

          val2_sign44<=val2[~add_en][43];
          val2_sign65<=val2[~add_en][64];
          val2_sign64<=val2[~add_en][63];
          val2_sign32<=val2[~add_en][31];
          val2_sign16<=val2[~add_en][15];
          val2_sign8<=operation[10] ? val2[~add_en][15] : val2[~add_en][7];
          
          val1One_reg<=val1One;
          
          dataEn_reg<=dataEn;
          
          nDataAlt_reg<=nDataAlt;
          
	  doJmp_reg<=doJmp;
	  shift_en_reg<=shift_en;
          valS_reg<=valS;
          val1_reg<=val1[5:0];
          thrinh_reg<=thrinh;
          except_reg<=except;
          except_thread_reg<=except_thread;

          if (add_en) cin_seq_reg<=cin_seq[0]&~boogy_baboogy;
          else if (pwh#(8)::cmpEQ(operation[7:0],`op_and64))
              cin_seq_reg<=cin_seq[2]&~boogy_baboogy;
          else cin_seq_reg<=cin_seq[1]|cmov_en&&~boogy_baboogy;

          is_ptr_reg<=is_ptr;       
          is_ptr_sub<=val1[0][64]&val2[0][64]&is_sub;

	  logic_en_reg<=(pwh#(8)::cmpEQ(operation[7:0],`op_and64)) || (pwh#(8)::cmpEQ(operation[7:0],`op_or64)) || (pwh#(8)::cmpEQ(operation[7:0],`op_xor64));
	  //$display("LL ",logic_en_reg," ",val1_sign65," ",val2_sign65," ",is_ptr_reg," ",cin_seq_reg);
	  flag64_ZF_reg<=flag64_ZF;
          flag32_ZF_reg<=flag32_ZF;
	  flag16_ZF_reg<=flag16_ZF;
          flag8_ZF_reg<=flag8_ZF;
          flag8_PF_reg<=flag8_PF;
	  flagAdd64_OF_reg<=flagAdd64_OF && ~calu[4] | doJmp2;
          flagAdd32_OF_reg<=flagAdd32_OF && ~calu[4] | doJmp2;
          flagAdd16_OF_reg<=flagAdd16_OF && ~calu[4] | doJmp2;
	  flagSub64_OF_reg<=flagSub64_OF && ~calu[4] | doJmp2;
          flagSub32_OF_reg<=flagSub32_OF && ~calu[4] | doJmp2;
	  flagSub44_OF_reg<=flagSub44_OF && ~calu[4] | doJmp2;
          flagSub16_OF_reg<=flagSub16_OF && ~calu[4] | doJmp2;
          flagSub8_OF_reg<=flagSub8_OF && ~calu[4] | doJmp2;
          if (operation[7:0]==8'ha || operation[7:0]==8'he) begin
              valRes_reg[31]<=valRes[15];
              flag32_ZF_reg<=flag16_ZF;
              flag32_CF_reg<=flag16_CF;
              flag32_OF_reg<=flag16_OF;
          end else if (operation[7:0]==8'hb || operation[7:0]==8'hf) begin
              valRes_reg[31]<=valRes[7];
              flag32_ZF_reg<=flag8_ZF;
              flag32_CF_reg<=flag8_CF;
              flag32_OF_reg<=flag8_OF;
          end


        end
    end
endmodule



module except_jump_cmp(
  flags,
  jumpType,
  doJump
  );
  parameter JUMP_TYPE_WIDTH=5;
  parameter FLAGS_WIDTH=`flags_width;

  input pwire [FLAGS_WIDTH-1:0] flags;
  input pwire [JUMP_TYPE_WIDTH-1:0] jumpType;
  output pwire doJump;

  pwire C;
  pwire O;
  pwire A;
  pwire S;
  pwire Z;
  pwire P;

  assign {C,O,A,S,Z,P}=flags;

  always @(*)
    begin
      case(jumpType)
        `jump_Z:	doJump=Z&~P;
        `jump_nZ:	doJump=~(Z&~P);
        `jump_S:	doJump=S;
        `jump_nS:	doJump=~S;
        `jump_uGT:	doJump=~(~C | (Z&~P));
        `jump_uLE:	doJump=~C | (Z&~P);
        `jump_uGE:	doJump=C;
        `jump_uLT:	doJump=~C;
        `jump_sGT:	doJump=~((S^O)|(Z&~P));
        `jump_sLE:	doJump=(S^O)|(Z&~P);
        `jump_sGE:	doJump=~S^O;
        `jump_sLT:	doJump=S^O;
        `jump_O:	doJump=~((S)|(Z&~P));
        `jump_nO:	doJump=(S)|(Z&~P);
        `jump_P:	doJump=P|(~Z&~S);
        `jump_nP:	doJump=1'b1;
        5'b11001:	doJump=0;//wr msrss
        default:	doJump=1;
      endcase
    end
endmodule




