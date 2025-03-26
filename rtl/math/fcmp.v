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


module fcmpd(clk,rst,
  A,B,ord,invExcpt,isExt,isDbl,isSng,afm,flags,paired,int_srch,srch_sz,vec,jumpType,
  cmod,res_pkd);
  parameter HAS_SRCH=0;
  input pwire clk;
  input pwire rst;
  input pwire [81:0] A;
  input pwire [81:0] B;
  input pwire ord;
  input pwire invExcpt;
  input pwire isExt,isDbl,isSng;
  input pwire afm; //alternative flag mode
  output pwire [5:0] flags;
  input pwire paired;
  input pwire int_srch;
  input pwire [1:0] srch_sz;
  input pwire vec;
  input pwire [4:0] jumpType;
  input pwire [1:0] cmod;
  output pwire [67:0] res_pkd;
  pwire cmpC,x_cmpC;

  pwire [15:0] extA;
  pwire [15:0] extB;
  pwire fEQl;
  pwire A_s,B_s;
  pwire [1:0] A_h,B_h;
  pwire[15:0] emsk;
  
  pwire [67:0] res_pkd_X;
  assign res_pkd=res_pkd_X;

  pwire res_unord;
  pwire res_S,res_C,res_Z;
  pwire COA,COB;
  pwire [5:0] flags_other;

  pwire [8:0] x_extA={A[63],A[65],A[62:56]};
  pwire [8:0] x_extB={B[63],B[65],B[62:56]};
  pwire x_fEQl;
  pwire A_x_s,B_x_s;
  pwire [1:0] A_x_h,B_x_h;

  pwire res_x_unord;
  pwire res_x_S,res_x_C,res_x_Z;
  pwire x_COA,x_COB;

  pwire A_zero,A_infty,A_nan,A_x_zero,A_x_infty,A_x_nan;
  pwire B_zero,B_infty,B_nan,B_x_zero,B_x_infty,B_x_nan;
  pwire [1:0] vres;
  pwire vres1;
  pwire [1:0] vres_reg;
  pwire ven_reg;
  pwire [1:0] vtype_reg;
  pwire [3:0][15:0] srchbits;
  pwire [15:0] s_first;
  pwire s_has;

  pwire [3:0] res_first;

  assign srchbits[0]={B[64],B[56],B[48],B[40],B[32],B[23],B[15],B[7],
	  A[64],A[56],A[48],A[40],A[32],A[23],A[15],A[7]};
  assign srchbits[1]={B[64],1'b0  ,B[48],1'b0  ,B[32],1'b0  ,B[15],1'b0 ,
	  A[64], 1'b0,A[48],1'b0,A[32],1'b0,A[15],1'b0};
  assign srchbits[2]={B[64],              3'b0  ,B[32],              3'b0,
	  A[64],3'b0,A[32],3'b0};
  assign srchbits[3]={7'b0,B[7],7'b0,A[7]};

  bit_find_first_bit #(16) srch_mod(srchbits[srch_sz],s_first,s_has);

  assign vres[0]=pwh#(32)::cmpEQ(cmod,0 )? flags[5] : 1'bz;
  assign vres[0]=pwh#(32)::cmpEQ(cmod,1 )? ~flags[5] : 1'bz;
  assign vres[0]=pwh#(32)::cmpEQ(cmod,2 )? flags[1] : 1'bz;
  assign vres[0]=pwh#(32)::cmpEQ(cmod,3 )? ~flags[1] : 1'bz;

  assign vres[1]=pwh#(32)::cmpEQ(cmod,0 )&& ~paired ? flags[5] : 1'bz;
  assign vres[1]=pwh#(32)::cmpEQ(cmod,1 )&& ~paired ? ~flags[5] : 1'bz;
  assign vres[1]=pwh#(32)::cmpEQ(cmod,2 )&& ~paired ? flags[1] : 1'bz;
  assign vres[1]=pwh#(32)::cmpEQ(cmod,3 )&& ~paired? ~flags[1] : 1'bz;
  assign vres1=pwh#(32)::cmpEQ(cmod,0 )? flags_other[5] : 1'bz;
  assign vres1=pwh#(32)::cmpEQ(cmod,1 )? ~flags_other[5] : 1'bz;
  assign vres1=pwh#(32)::cmpEQ(cmod,2 )? flags_other[1] : 1'bz;
  assign vres1=pwh#(32)::cmpEQ(cmod,3 )? ~flags_other[1] : 1'bz;
  assign vres[1]=paired ? vres1 : 1'bz;
  function [64:0] fracxfrm;
    input pwire [64:0] d_in;
    input pwire sngl;
    input pwire dbl;
    input pwire ext;
    begin
        fracxfrm[22:0]=d_in[22:0];
	fracxfrm[23]=d_in[23]|sngl;
	fracxfrm[51:24]=d_in[51:24]&{27'b0,~sngl};
	fracxfrm[52]=d_in[52]&~sngl||dbl;
	fracxfrm[63:53]=d_in[63:53]&{10'b0,~ext};
    end
  endfunction

  get_carry #(64) cmpM_mod(fracxfrm({A[64:33],A[31:0]},isSng,isDbl,isExt),
    ~fracxfrm({B[64:33],B[31:0]},isSng,isDbl,isExt),1'b1,cmpC);
  get_carry #(16) cmpA_mod(extA,~extB,1'b1,COA);
  get_carry #(16) cmpB_mod(~extA,extB,1'b1,COB);
  
  
  get_carry #(24) x_cmpM_mod({1'b1,A[55:33]},
    ~{1'b1,B[55:33]},1'b1,x_cmpC);
  get_carry #(9) x_cmpA_mod(x_extA,~x_extB,1'b1,x_COA);
  get_carry #(9) _xcmpB_mod(~x_extA,x_extB,1'b1,x_COB);

  generate
    genvar p;
    for(p=0;p<16;p=p+1) begin
	assign res_first=s_first[p] ? p[3:0] : 4'bz;
    end
    assign res_first=s_has ? 4'bz : 4'b0;

  endgenerate
  assign x_fEQl=A[55:33]==B[55:33];
  assign A_x_s=A[64];
  assign B_x_s=B[64];

  assign fEQl=fracxfrm({A[64:33],A[31:0]},isSng,isDbl,isExt)==
    fracxfrm({B[64:33],B[31:0]},isSng,isDbl,isExt);
  assign extA=isExt ? {A[81],A[65],A[79:66]} : 16'bz;
  assign extA=isDbl ? {A[64],A[65],{4{~A[63]}},A[63:54]} : 16'bz;
  assign extA=(~isDbl&~isExt) ? {A[30],A[32],{7{~A[30]}},A[29:23]} : 16'bz;
  assign extB=isExt ? {B[81],B[65],B[79:66]} : 16'bz;
  assign extB=isDbl ? {B[64],B[65],{4{~B[63]}},B[63:54]} : 16'bz;
  assign extB=(~isDbl & ~isExt) ? {B[30],B[32],{7{~B[30]}},B[29:23]} : 16'bz;

  assign emsk=isExt ? 16'hffff : 16'bz;
  assign emsk=isDbl ? 16'h87ff : 16'bz;
  assign emsk=(~isDbl&~isExt) ? 16'h80ff : 16'bz;

  assign A_s=isExt ? A[80] : 1'bz;
  assign A_s=isDbl ? A[64] : 1'bz;
  assign A_s=(~isDbl & ~isExt) ? A[31] : 1'bz;
  assign B_s=isExt ? B[80] : 1'bz;
  assign B_s=isDbl ? B[64] : 1'bz;
  assign B_s=(~isDbl & ~isExt) ? B[31] : 1'bz;

  assign A_h=isExt ? {|A[61:0],A[62]} : 2'bz;
  assign A_h=isDbl ? {|A[50:0],A[51]} : 2'bz;
  assign A_h=(~isDbl & ~isExt) ? {|A[21:0],A[22]} : 2'bz;
  assign B_h=isExt ? {|B[61:0],B[62]} : 2'bz;
  assign B_h=isDbl ? {|B[50:0],B[51]} : 2'bz;
  assign B_h=(~isDbl & ~isExt) ? {|B[21:0],B[22]} : 2'bz;
  
//  assign A_x_h={|A[54:33],A[55]};
//  assign B_x_h={|B[54:33],B[55]};
  
  assign A_x_zero=pwh#(9)::cmpEQ(x_extA,9'b0);
  assign A_x_infty=pwh#(9)::cmpEQ(x_extA,9'h1fe);
  assign A_x_nan=pwh#(9)::cmpEQ(x_extA,9'h1ff);
  
  assign B_x_zero=pwh#(9)::cmpEQ(x_extB,9'b0);
  assign B_x_infty=pwh#(9)::cmpEQ(x_extB,9'h1fe);
  assign B_x_nan=pwh#(9)::cmpEQ(x_extB,9'h1ff);

  assign A_zero=(extA&emsk)==16'b0;
  assign A_infty=(extA|~emsk)==16'hfffe;
  assign A_nan=(extA|~emsk)==16'hffff;
  
  assign B_zero=(extB&emsk)==16'b0;
  assign B_infty=(extB|~emsk)==16'hfffe;
  assign B_nan=(extB|~emsk)==16'hffff;

  assign res_unord=A_nan || B_nan;
  assign res_C=res_unord || (A_s && ~B_s && ~A_zero|~B_zero) || (~A_s && ~B_s 
    && ~COA) || (A_s && B_s && ~COB) || (~A_s && ~B_s && COA && COB && ~cmpC) ||
    (A_s && B_s && COA && COB && cmpC|fEQl);
  assign res_S=~res_unord & ~afm && (A_s && ~B_s && ~A_zero|~B_zero) | (~A_s && ~B_s 
    && ~COA) | (A_s && B_s && ~COB) | (~A_s && ~B_s && COA && COB && ~cmpC) |
    (A_s && B_s && COA && COB && cmpC|fEQl);
  assign res_Z=~res_unord && (A_zero&B_zero) | (pwh#(32)::cmpEQ(extA,extB)&&pwh#(32)::cmpEQ(A_s,B_s)&&fEQl|
    A_infty) && ~afm;
  
  assign res_x_unord=A_x_nan || B_x_nan;
  assign res_x_C=res_x_unord || (A_x_s && ~B_x_s && ~A_x_zero|~B_x_zero) || (~A_x_s && ~B_x_s 
    && ~x_COA) || (A_x_s && B_x_s && ~x_COB) || (~A_x_s && ~B_x_s && x_COA && x_COB && ~x_cmpC) ||
    (A_x_s && B_x_s && x_COA && x_COB && x_cmpC|x_fEQl);
  assign res_x_S=~res_x_unord && (A_x_s && ~B_x_s && ~A_x_zero|~B_x_zero) | (~A_x_s && ~B_x_s 
    && ~x_COA) | (A_x_s && B_x_s && ~x_COB) | (~A_x_s && ~B_x_s && x_COA && x_COB && ~x_cmpC) |
    (A_x_s && B_x_s && x_COA && x_COB && x_cmpC|x_fEQl);
  assign res_x_Z=~res_x_unord && (A_x_zero&B_x_zero) | (pwh#(32)::cmpEQ(extA,extB)&&pwh#(32)::cmpEQ(A_x_s,B_x_s)&&x_fEQl|
    A_x_infty);

  assign flags=int_srch ? {s_has,res_first,^res_first[1:0]} : {~res_C,res_unord,1'b0,res_S,res_Z,res_unord};

  assign res_pkd_X[67:0]=ven_reg ? {vtype_reg,{33{vres_reg[1]}},{33{vres_reg[0]}}} : 68'bz; 
  `ifndef swapedge
  always @(negedge clk) begin
  `else
  always @(negedge clk) begin
  `endif
    if (rst) vres_reg<=2'b0;
    else vres_reg<=vres;
    if (rst) ven_reg<=1'b0;
    else ven_reg<=paired|vec;
    vtype_reg<=vec ? `ptype_dbl : `ptype_sngl;
  end
endmodule
