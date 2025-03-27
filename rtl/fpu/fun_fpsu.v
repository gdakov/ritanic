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
`include "../msrss_no.sv"

module fun_fpsu(
  clk,
  rst,
  fpcsr,
  u1_A,u1_B,u1_Bx,u1_Ax,u1_en,u1_op,
  u1_fufwd_A,u1_fuufwd_A,u1_fufwd_B,u1_fuufwd_B,
  u1_ret,u1_ret_en,u1_XSUB,u1_FK,
  FUF0,FUF1,FUF2,
  FUF3,FUF4,FUF5,
  FUF6,FUF7,FUF8,
  FUF9,
  FUF4X,FUF5X,FUF6X,
  ALTDATA0,ALTDATA1,
  ALT_INP,
  FOOSL_out,
  HH_data,
  XY_data,
  xdata,
  xdata2
  );
  parameter [1:0] INDEX=2'd2;
  parameter [0:0] H=1'b0;
  localparam SIMD_WIDTH=70; //half width
  localparam S=0;
  input pwire clk;
  input pwire rst;
  input pwire [31:0] fpcsr;
  input pwire [S+69:0] u1_A;
  input pwire [S+69:0] u1_B;
  input pwire [69:0] u1_Bx;
  output pwire [69:0] u1_Ax;
  input pwire [3:0] u1_en;
  input pwire [20:0] u1_op;
  input pwire [3:0] u1_fufwd_A;
  input pwire [3:0] u1_fuufwd_A;
  input pwire [3:0] u1_fufwd_B;
  input pwire [3:0] u1_fuufwd_B;
  output pwire [13:0] u1_ret;
  output pwire u1_ret_en;
  input pwire u1_XSUB;
  input pwire [2:0] u1_FK;

  (* register equiload *) input pwire [S+69:0] FUF0;
  (* register equiload *) input pwire [S+69:0] FUF1;
  (* register equiload *) input pwire [S+69:0] FUF2;
  (* register equiload *) input pwire [S+69:0] FUF3;
  (* register equiload *) inout pwire [S+69:0] FUF4;
  (* register equiload *) inout pwire [S+69:0] FUF5;
  (* register equiload *) inout pwire [S+69:0] FUF6;
  (* register equiload *) inout pwire [S+69:0] FUF7;
  (* register equiload *) inout pwire [S+69:0] FUF8;
  (* register equiload *) inout pwire [S+69:0] FUF9;
  (* register equiload *) inout pwire [S+69:0] FUF4X;
  (* register equiload *) inout pwire [S+69:0] FUF5X;
  (* register equiload *) inout pwire [S+69:0] FUF6X;
  input pwire [1:0] ALT_INP;
  input pwire [S+69:0] ALTDATA0;
  input pwire [S+69:0] ALTDATA1;
  output pwire [5:0] FOOSL_out;
  output pwire [69:0] HH_data;
  input pwire [69:0] XY_data;
  inout pwire  [S+67:0] xdata;
  inout pwire  [S+67:0] xdata2;


  pwire  [S+67:0] xdata_reg;
  pwire  [S+67:0] xdata2_reg;

  pwire [1:0][S+67:0] FOOF;
  pwire [1:0][S+67:0] FOOF_reg;
  pwire [5:0] FOOSL;
  pwire [5:0] FOOSL_reg;

  pwire [2:0] u1_FK_reg;
  
  pwire error,error_reg,error_reg2,error_reg3;
  
  pwire  gxFADD_hi;
  pwire  gxFADD_en;
  pwire  gxFADD_en_reg;
  pwire  gxFADD_en_reg2;
  pwire  gxFADD_dbl;
  pwire  gxFADD_ext;
  pwire  gxFADD_sn;
  pwire  gxFADD_sin;
  pwire  gxFADD_ord;
  pwire  gxFADD_pkdS;
  pwire  gxFADD_pkdD;
/*  pwire fxAlt1;
  pwire fxAlt2;
  pwire fxAlt1_reg;
  pwire fxAlt1_reg2;
  pwire [2:0] fxAlt1_reg3;
  pwire fxAlt2_reg;
  pwire fxAlt2_reg2;
  pwire fxAlt2_reg3;*/
  pwire  fxFADD_dbl;
  pwire  fxFADD_ext;
  pwire  fxFADD_sin;
  pwire  fxFADD_int;
  pwire  fxFADD_sn_reg;
  pwire  fxFADD_sn_reg2;
  pwire  fxFADD_dblext;
  pwire [1:0] fxFADD_sub;
  pwire  fxFADD_rsub;
  pwire [1:0] fxFADD_copyA;
  pwire [3:0] fxFADD_copySA;
  pwire [1:0] fxFADD_com;
  pwire  fxFADD_pswp;
  pwire  fxFADD_dupl;
  pwire  fxFADD_pcmp;
  pwire  fxFADD_lo;
  pwire [1:0] fxFADD_loSel;
  pwire  fxFCADD_dbl;
  pwire  fxFCADD_ext;
  pwire  fxFCADD_sn;
  pwire  fxFCADD_sn_reg;
  pwire  fxFCADD_sn_reg2;
  pwire  fxFCADD_sn_reg3;
  pwire  fxFCADD_sn_reg4;
  pwire  fxFCADD_sn_reg5;
  pwire  fxFCADD_dblext;
  pwire [1:0] fxFCADD_copyA;
  pwire [3:0] fxFCADD_copyASN;
  pwire [1:0] fxFCADD_com;
  pwire  fxFCADD_pswp;
  pwire  fxFCADD_dupl;
  pwire  fxFCADD_dupl_reg;
  pwire  fxFCADD_rndD;
  pwire  fxFCADD_rndS;
  pwire  fxFADD_dbl_reg;
  pwire  fxFADD_ext_reg;
  pwire  fxFADD_dblext_reg;
  pwire [1:0] fxFADD_sub_reg;
  pwire  fxFADD_rsub_reg;
  pwire [1:0] fxFADD_copyA_reg;
  pwire [1:0] fxFADD_com_reg;
  pwire  fxFADD_pswp_reg;
  pwire  fxFCADD_dbl_reg;
  pwire  fxFCADD_ext_reg;
  pwire  fxFCADD_dblext_reg;
  pwire [1:0] fxFCADD_copyA_reg;
  pwire [1:0] fxFCADD_com_reg;
  pwire  fxFCADD_pswp_reg;
  pwire [1:0][10:0] fxFCADD_raise;
  pwire [10:0] fxFCADD_raise_reg[1:0];
  pwire [10:0] fxFCADD_raise_s_reg[1:0];
  pwire [1:0][10:0] fxFADD_raise;
  pwire [10:0] fxFADD_raise_reg[1:0];
  pwire [10:0] fxFADD_raise_s_reg[1:0];
  pwire [10:0] fraise2;
  pwire [10:0] fraise3;
  pwire [10:0] fmask2;
  pwire [10:0] fmask3;
  pwire [10:0] fraise2_reg;
  pwire [10:0] fraise3_reg;
  pwire [10:0] fmask2_reg;
  pwire [10:0] fmask3_reg;
  //wire [15:0] u1_Bx=u1_BH[15:0];
  //wire [15:0] u1_Bx=u1_BH[15:0];
  integer k;
  pwire [13:0] u1_retX;
  pwire u1_retX_en;
  pwire [13:0] u1_retY;
  pwire u1_retY_en;
  pwire  [13:0] u1_retX_reg;
  pwire  u1_retX_en_reg;
  pwire  [13:0] u1_retX_reg2;
  pwire  u1_retX_en_reg2;
  pwire  [13:0] u1_retX_reg3;
  pwire  u1_retX_en_reg3;


  pwire [1:0] ALT_INP_reg;

  pwire [1:0] gxFADD_sz;
  pwire gxFADD_srch;

  pwire [1:0][69:0] gxDataBFL;
  pwire [1:0][69:0] gxDataBFL_reg;
  pwire [1:0][69:0] fxDataAFL_reg;
  pwire [1:0][69:0] fxDataAFL_REG;
  pwire [1:0][69:0] gxDataBXL_reg;
  pwire [1:0][69:0] fxDataAXL_reg;
  pwire [1:0][69:0] gxDataBXL_reg2;
  pwire [1:0][69:0] fxDataAXL_reg2;
  pwire [3:0] u1_en_reg;
  pwire [3:0] u2_en_reg;
  pwire [S+69:0] uu_A1;
  pwire [S+69:0] uu_A2;
  pwire [S+69:0] uu_B1;
  pwire [S+69:0] uu_B2;

  pwire [S+69:0] FUF0_reg;
  pwire [S+69:0] FUF1_reg;
  pwire [S+69:0] FUF2_reg;
  pwire [S+69:0] FUF3_reg;
  pwire [S+69:0] FUF4_reg;
  pwire [S+69:0] FUF5_reg;
  pwire [S+69:0] FUF6_reg;
  pwire [S+69:0] FUF7_reg;
  pwire [S+69:0] FUF8_reg;
  pwire [S+69:0] FUF9_reg;
  pwire [S+69:0] FUFX4_reg;
  pwire [S+69:0] FUFX5_reg;
  pwire [S+69:0] FUFX6_reg;

  pwire [20:0] u1_op_reg;
  pwire [20:0] u1_op_reg2;
  pwire [3:0] u1_en_reg2;
  pwire [3:0] u1_en_reg3;
  pwire [3:0] u1_en_reg4;
  pwire [3:0] u1_en_reg5;
  pwire [3:0] u1_en_reg6;
  pwire [3:0] u1_en_reg7;
  
  pwire pookH,pookL;

  rs_write_forward #(S+70) u1_A_fwd(
  clk,rst,
  ~u1_en[3]&u1_XADD,
  u1_A,uu_A1,
  u1_fufwd_A,u1_fuufwd_A,
  FUF0,FUF0_reg,
  FUF1,FUF1_reg,
  FUF2,FUF2_reg,
  FUF3,FUF3_reg,
  FUF4,FUF4_reg,
  FUF5,FUF5_reg,
  FUF6,FUF6_reg,
  FUF7,FUF7_reg,
  FUF8,FUF8_reg,
  FUF9,FUF9_reg
  );
  
  rs_write_forward #(S+70) u1_B_fwd(
  clk,rst,
  ~u1_en[3]&u1_XADD,
  u1_B,uu_B1,
  u1_fufwd_B,u1_fuufwd_B,
  FUF0,FUF0_reg,
  FUF1,FUF1_reg,
  FUF2,FUF2_reg,
  FUF3,FUF3_reg,
  FUF4,FUF4_reg,
  FUF5,FUF5_reg,
  FUF6,FUF6_reg,
  u1_FK[0] ? FUF4X : FUF7, u1_FK_reg[0]? FUFX4_reg : FUF7_reg,//free due to splitting 
  u1_FK[1] ? FUF5X : FUF8, u1_FK_reg[1] ? FUFX5_reg : FUF8_reg,
  u1_FK[2] ? FUF6X : FUF9, u1_FK_reg[2] ? FUFX6_reg : FUF9_reg
  );
  
  rs_write_forward #(S+70) u2_A_fwd(
  clk,rst,
  ~u1_en[3]&~u1_XADD,
  u1_A,uu_A2,
  u1_fufwd_A,u1_fuufwd_A,
  FUF0,FUF0_reg,
  FUF1,FUF1_reg,
  FUF2,FUF2_reg,
  FUF3,FUF3_reg,
  FUF4,FUF4_reg,
  FUF5,FUF5_reg,
  FUF6,FUF6_reg,
  FUF7,FUF7_reg,
  FUF8,FUF8_reg,
  FUF9,FUF9_reg
  );
  
  rs_write_forward #(S+70) u2_B_fwd(
  clk,rst,
  ~u1_en[3]&~u1_XADD,
  u1_B,uu_B2,
  u1_fufwd_B,u1_fuufwd_B,
  FUF0,FUF0_reg,
  FUF1,FUF1_reg,
  FUF2,FUF2_reg,
  FUF3,FUF3_reg,
  FUF4,FUF4_reg,
  FUF5,FUF5_reg,
  FUF6,FUF6_reg,
  FUF7,FUF7_reg,
  FUF8,FUF8_reg,
  FUF9,FUF9_reg
  );
 
  assign FOOSL_out=FOOSL_reg; 
  
  fadds fadd1H_mod(
  .clk(clk),
  .rst(rst),
  .A({fxDataAXL_reg[0][65],fxDataAXL_reg[0][64:33]}),
  .B({gxDataBXL_reg[1][65],gxDataBXL_reg[1][64:33]}),
  .pook_inX(gxDataBXL_reg[1][67]),
  .pook(pookH),
  .pook_op_bit(u1_op_reg[10]),
  .isSub(fxFADD_sub[H]),
  .isRSub(fxFADD_rsub),
  .raise(fxFADD_raise[0]),
  .fpcsr(fpcsr[31:0]),
  .rmode(pwh#(3)::cmpEQ(u1_op_reg[20:18],3'b111) ? fpcsr[`csrfpu_rmode] : u1_op_reg[20:18]),
  .copyA(fxFADD_copyA[H]),
  .logic_en(fxFADD_lo),
  .logic_sel(fxFADD_loSel),
  .en(H? gxFADD_sn:gxFADD_sin),
  .res(FOOF[0][65:33])
  );
  
  fadds fadd1L_mod(
  .clk(clk),
  .rst(rst),
  .A({fxDataAXL_reg[0][32],fxDataAXL_reg[0][31:0]}),
  .B({gxDataBXL_reg[1][32],gxDataBXL_reg[1][31:0]}),
  .pook_inX(gxDataBXL_reg[1][66]),
  .pook(pookL),
  .pook_op_bit(u1_op_reg[10]),
  .isSub(fxFADD_sub[H]),
  .isRSub(fxFADD_rsub),
  .raise(fxFADD_raise[1]),
  .fpcsr(fpcsr[31:0]),
  .rmode(pwh#(3)::cmpEQ(u1_op_reg[20:18],3'b111) ? fpcsr[`csrfpu_rmode] : u1_op_reg[20:18]),
  .copyA(fxFADD_copyA[H]),
  .logic_en(fxFADD_lo),
  .logic_sel(fxFADD_loSel),
  .en(H? gxFADD_sn:gxFADD_sin),
  .res(FOOF[0][32:0])
  );
  
  simd_non_socialiste simd_mod(
  .clk(clk),
  .rst(rst),
  .en(fxFADD_int),
  .operation(u1_op_reg),
  .A(fxDataAXL_reg[0]),
  .B(gxDataBFL_reg[1]),
  .res(FOOF[0])
  );
  
  fperm fperm1H_mod(
  .clk(clk),
  .rst(rst),
  .en(~(H? fxFADD_dbl:fxFADD_dblext)&~fxFADD_sin&~fxFADD_pcmp&~fxFADD_int),
  .copyA(H? pwh#(2)::cmpEQ(fxFADD_com,2'b01) : ~fxFADD_com[0]),
  .swpSngl(fxFADD_pswp),
  .dupSngl(fxFADD_dupl),
  .is_sqrt(1'b0),
  .is_div(1'b0),
  .tbl_read(1'b0),
  .tbl_write(1'b0),
  .xtra(3'b0),
  .A(fxDataAXL_reg[0]),.B(gxDataBXL_reg[1]),
  .res(FOOF[0]));
  
  
  fcmpd fcmpL_mod(
  .clk(clk),
  .rst(rst),
  .A({16'b0,fxDataAXL_reg[0][65:0]}),
  .B({16'b0,gxDataBXL_reg[1][65:0]}),
  .ord(gxFADD_ord),.invExcpt(fpcsr[`csrfpu_inv_excpt]),
  .isExt(H ? 1'b0: gxFADD_ext),.isDbl(gxFADD_dbl),.isSng(H? gxFADD_sn:gxFADD_sin),
  .afm(1'b0),.flags(FOOSL),
  .paired(gxFADD_pkdS),
  .int_srch(gxFADD_srch),
  .srch_sz(gxFADD_sz),
  .vec(gxFADD_pkdD),
  .jumpType(5'b0),
  .cmod(u1_op_reg2[1:0]),
  .res_pkd(FOOF[0])
  );

  //assign FOOS=gxFADD_hi ? FOOSH[m] : FOOSL[m];

  assign fraise2=fxFCADD_sn_reg5 ?
    (fxFCADD_raise_reg[0]|fxFCADD_raise_reg[1])&fpcsr[21:11] :
    11'b0&fpcsr[21:11];
  assign fmask2=fxFCADD_sn_reg5 ?
    (fxFCADD_raise_s_reg[0]|fxFCADD_raise_s_reg[1]) :
    11'b0;
  fexcpt fexcpt2_mod(fraise2_reg,{6'b0|{6{error_reg3&|u1_en_reg5[3:2]&u1_en_reg5[0]}},2'b0,error_reg3&|u1_en_reg5[3:2]&u1_en_reg5[0]},
    fmask2_reg,|u1_en_reg5[3:2]&u1_en_reg5[0]&~error_reg3,u1_retY,u1_retY_en);
  assign fraise3=fxFADD_sn_reg2 ?
    (fxFADD_raise_reg[0]|fxFADD_raise_reg[1])&fpcsr[21:11] :
    11'b0&fpcsr[21:11];
  assign fmask3=fxFADD_sn_reg2 ?
    (fxFADD_raise_reg[0]|fxFADD_raise_reg[1]) :
    11'b0;
  fexcpt fexcpt3_mod(fraise3_reg,{6'b0,3'b0},
    fmask3_reg,|u1_en_reg4[3:2]&u1_en_reg4[0]&~error_reg2,u1_retX,u1_retX_en);

  assign HH_data=gxDataBXL_reg[0];
  assign u1_ret=u1_retY|u1_retX_reg;
  assign u1_ret_en=u1_retY_en|u1_retX_en_reg;

  fpumuls cadd2H_mod(
  .clk(clk),
  .rst(rst),
  .A({fxDataAXL_reg[1][65],fxDataAXL_reg[1][64:33]}),
  .B({gxDataBXL_reg[0][65],gxDataBXL_reg[0][64:33]}),
  .copyA(fxFCADD_copyA[H]),
  .en(fxFCADD_sn),
  .rmode(pwh#(3)::cmpEQ(u1_op_reg[20:18],3'b111) ? fpcsr[`csrfpu_rmode] : u1_op_reg[20:18]),
  .res(FOOF[1][65:33]),
  .xdata(xdata[65:33]),
  .raise(fxFCADD_raise[0]),
  .fpcsr(fpcsr[31:0])
  );
  
  
  fpumuls cadd2L_mod(
  .clk(clk),
  .rst(rst),
  .A({fxDataAXL_reg[1][32],fxDataAXL_reg[1][31:0]}),
  .B({gxDataBXL_reg[0][32],gxDataBXL_reg[0][31:0]}),
  .copyA(fxFCADD_copyA[H]),
  .en(fxFCADD_sn),
  .rmode(pwh#(3)::cmpEQ(u1_op_reg[20:18],3'b111) ? fpcsr[`csrfpu_rmode] : u1_op_reg[20:18]),
  .res(FOOF[1][32:0]),
  .xdata(xdata[32:0]),
  .raise(fxFCADD_raise[1]),
  .fpcsr(fpcsr[31:0])
  );
  
  fperm #(0) fperm1CL_mod(
  .clk(clk),
  .rst(rst),
  .en(~fxFCADD_sn_reg),
  .copyA(H? pwh#(2)::cmpEQ(fxFCADD_com_reg,2'b01) : ~fxFCADD_com_reg[0]),
  .swpSngl(fxFCADD_pswp_reg),
  .dupSngl(fxFCADD_dupl_reg),
  .is_sqrt(1'b0),
  .is_div(1'b0),
  .tbl_read(1'b0),
  .tbl_write(1'b0),
  .xtra(3'b0),
  .A(fxDataAXL_reg2[1][67:0]),.B(u1_op_reg3[13+H] ? XY_data[67:0] : gxDataBXL_reg2[0][67:0]),
  .res(FOOF[1]));
 
  assign FOOF[0][67:66]=(H? gxFADD_sn:gxFADD_sin) & u1_op_reg3[10] ? {pookH,pookL} : 2'bz;
  assign FOOF[0][67:66]=(H? gxFADD_sn:gxFADD_sin) & ~u1_op_reg3[10] ? `ptype_sngl : 2'bz;
  assign FOOF[1][67:66]=fxFCADD_sn ? `ptype_sngl : 2'bz;

  generate
	  if (H) assign gxDataBFL[1]=u1_op_reg[9] ? u1_Bx : uu_B1;
	  else assign gxDataBFL[1]=u1_op_reg[8] ? {u1_Bx} : uu_B1;
	  if (H) assign gxDataBFL[0]=u1_op_reg[9] ? u1_Bx : uu_B2;
	  else assign gxDataBFL[0]=u1_op_reg[8] ? {u1_Bx} : uu_B2;
      if (pwh#(32)::cmpEQ(INDEX,0)) begin
	      assign FUF4={1'b0,^FOOF_reg[0][67:0],FOOF_reg[0][67:0]};
	      assign FUF7={1'b0,^FOOF_reg[1][67:0],FOOF_reg[1][67:0]};
              assign FUF4X={1'b0,^xdata_reg[67:0],xdata_reg[67:0]};
      end
      if (pwh#(32)::cmpEQ(INDEX,1)) begin
	      assign FUF5={1'b0,^FOOF_reg[0][67:0],FOOF_reg[0][67:0]};
	      assign FUF8={1'b0,^FOOF_reg[1][67:0],FOOF_reg[1][67:0]};
              assign FUF5X={1'b0,^xdata_reg[67:0],xdata_reg[67:0]};
      end
      if (pwh#(32)::cmpEQ(INDEX,2)) begin
	      assign FUF6=|ALT_INP_reg ? {S+SIMD_WIDTH{1'BZ}} : 
                {1'b0,^FOOF_reg[0][67:0],FOOF_reg[0][67:0]};
	      assign FUF6=ALT_INP_reg[0] ? ALTDATA0 : {S+SIMD_WIDTH{1'BZ}};
	      assign FUF6=ALT_INP_reg[1] ? ALTDATA1 : {S+SIMD_WIDTH{1'BZ}};
	      assign FUF9={1'b0,^FOOF_reg[0][67:0],FOOF_reg[0][67:0]};
              assign FUF6X={1'b0,^xdata_reg[67:0],xdata_reg[67:0]};
      end
  endgenerate

//  if (m!=2) assign FUFL[4+m]=FOOFL_reg[2*m+0];
//  else assign FUFL[4+m]=fxFRT_alten_reg5[2]||~nDataAlt_reg5[2][2] ? 'z : FOOFL_reg[2*m+0];
//  assign FUFL[7+m]=FOOFL_reg[2*m+1];

  always @(negedge clk) begin
    xdata_reg<=xdata;
    fxFCADD_sn_reg<=fxFCADD_sn;
    fxFCADD_sn_reg2<=fxFCADD_sn_reg;
    fxFCADD_sn_reg3<=fxFCADD_sn_reg2;
    fxFCADD_sn_reg4<=fxFCADD_sn_reg3;
    fxFCADD_sn_reg5<=fxFCADD_sn_reg4;
    fxFADD_sn_reg<=fxFADD_sin;
    fxFADD_sn_reg2<=fxFADD_sn_reg;
    FOOSL_reg<=FOOSL;
    gxFADD_sz<=u1_op_reg[1:0];
    if (rst) begin
	  fxFADD_dbl=1'b1;
	  fxFADD_dblext=1'b1;
	  fxFADD_ext=1'b0;
	  fxFADD_int=1'b0;
	  fxFADD_sub=2'b00;
	  fxFADD_rsub=1'b0;
	  fxFADD_copyA=2'b0;
	  fxFADD_com<=2'b0;
	  fxFADD_dupl<=1'b0;
          //fxFADD_sqrt<=1'b1;
          //fxFADD_div<=1'b0;
	  fxFCADD_dupl<=1'b0;
	  fxFCADD_dupl_reg<=1'b0;
	  fxFADD_pswp<=1'b0;
	  fxFADD_pcmp<=1'b0;
	  fxFCADD_dbl=1'b1;
	  fxFCADD_dblext=1'b1;
	  fxFCADD_ext=1'b0;
	  fxFCADD_copyA=2'b0;
	  fxFCADD_com<=2'b0;
	  fxFCADD_pswp<=1'b0;
	  fxFADD_sin=1'b0;
          fxFADD_copySA=4'b0;
	  fxFCADD_sn=1'b0;
	  fxFCADD_copyASN=4'b0;
	  fxFADD_lo=1'b0;
	  fxFADD_loSel=2'b0;
	  fxFCADD_rndD=1'b0;
	  fxFCADD_rndS=1'b0;
          for (k=0;k<2;k=k+1) begin
	      fxDataAFL_reg[k]<={S+SIMD_WIDTH{1'B0}};
	      gxDataBFL_reg[k]<={S+SIMD_WIDTH{1'B0}};
	      fxDataAFL_REG[k]<={S+SIMD_WIDTH{1'B0}};
	      fxDataAXL_reg[k]<={S+SIMD_WIDTH{1'B0}};
	      gxDataBXL_reg[k]<={S+SIMD_WIDTH{1'B0}};
	      fxDataAXL_reg2[k]<={S+SIMD_WIDTH{1'B0}};
	      gxDataBXL_reg2[k]<={S+SIMD_WIDTH{1'B0}};
	  end
	  gxFADD_srch<=1'b0;
    end else begin
	      fxFADD_dbl=(pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addDL) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addDH) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addDP) ||
                pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subDL) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subDH) ||
                pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subDP) ||
                pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addsubDP) ||
                {u1_op_reg[7:2],2'b0}==`fop_logic) && u1_en_reg[3];
             fxFADD_ext=(pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addEE) ||
                pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subEE)) && u1_en_reg[3];
              fxFADD_dblext=fxFADD_dbl||fxFADD_ext;
	      fxFADD_int=u1_en_reg[2] && pwh#(1)::cmpEQ(u1_op_reg[5],1'b0);
	      fxFADD_sub[0]=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subDL) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subDH) ||
                pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subDP) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subEE) ||
		pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subS) ||
		pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subSP) ||
		pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addsubDP);
	      fxFADD_sub[1]=fxFADD_sub[0] || 
		u1_op_reg[7:0]!=`fop_addsubDP;
	      fxFADD_rsub=fxFADD_sub[0] && u1_op_reg[12];
	      fxFADD_copyA[1]=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addDL) ||
                pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subDL);
	      fxFADD_copyA[0]=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addDH) ||
                pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subDH);
	      fxFADD_lo={u1_op_reg[7:2],2'b0}==`fop_logic;
	      fxFADD_loSel=u1_op_reg[1:0];
              fxFADD_pcmp<=gxFADD_pkdS | gxFADD_pkdD;
	      {fxFADD_pswp,fxFADD_com}<=u1_op_reg[10:8];
	      {fxFCADD_pswp,fxFCADD_com}<=u1_op_reg[10:8];
              fxFADD_dupl<=u1_op_reg[12];
              fxFCADD_dupl_reg<=fxFCADD_dupl;
              fxFCADD_dupl<=u1_op_reg[12];
	      //fxFADD_sqrt<=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_sqrtDH);
	      //fxFADD_div<=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_sqrtDL);

	      fxFCADD_dbl=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_mulDL) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_mulDH) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_mulDP) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_rndDSP);
              fxFCADD_ext=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_mulEE) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_rndES) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_rndED);
              fxFCADD_dblext=fxFCADD_dbl||fxFCADD_ext;
	      fxFCADD_copyA[1]=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_mulDL);
	      fxFCADD_copyA[0]=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_mulDH);
	     
	      fxFCADD_rndD=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_rndED);
	      fxFCADD_rndS=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_rndES) ||
	        pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_rndDSP);

	      fxFADD_sin=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addS) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_addSP) ||
                  pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subS) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subSP);
              fxFADD_copySA=(pwh#(32)::cmpEQ(u1_op_reg,`fop_addSP) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_subSP) ||
	          {u1_op_reg[7:2],2'b0}==`fop_logic) ?
		  {u1_op_reg[10],3'b0}:{2'b11,u1_op_reg[10],1'b0}; 
	      fxFCADD_sn=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_mulS) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_mulSP);
              fxFCADD_copyASN=(pwh#(32)::cmpEQ(u1_op_reg,`fop_mulSP)) ?
		  {u1_op_reg[10],3'b0}:{2'b11,u1_op_reg[10],1'b0}; 
	      if (fxFADD_dblext) begin
	          if (~fxFADD_copyA[0]) fxDataAFL_reg[0]<=uu_A1; else fxDataAFL_reg[0]<='z;
	          if (~fxFADD_copyA[0]) gxDataBFL_reg[1]<=gxDataBFL[1]; else gxDataBFL_reg[1]<='z;
	          fxDataAFL_REG[0]<=uu_A1;
	      end
	      if (fxFCADD_dblext) begin
	          if (~fxFCADD_copyA[0]) fxDataAFL_reg[1]<=uu_A2; else fxDataAFL_reg[1]<='z;
	          if (~fxFCADD_copyA[0]) gxDataBFL_reg[0]<=gxDataBFL[0]; else gxDataBFL_reg[0]<='z;
	          fxDataAFL_REG[1]<=uu_A2;
	      end
	      if (~fxFADD_dblext) begin
	          fxDataAXL_reg[0]<=uu_A1;
	          gxDataBXL_reg[1]<=gxDataBFL[1];
	      end else begin
	          fxDataAXL_reg[0]<='z;
	          gxDataBXL_reg[1]<='z;
              end
	      if (~fxFCADD_dblext) begin
	          fxDataAXL_reg[1]<=uu_A2;
	          gxDataBXL_reg[0]<=gxDataBFL[0];
	      end else begin
	          fxDataAXL_reg[1]<='z;
	          gxDataBXL_reg[0]<='z;
              end
              fxDataAXL_reg2<=fxDataAXL_reg;
              gxDataBXL_reg2<=gxDataBXL_reg;
    end
    for(k=0;k<2;k=k+1) begin
        FOOF_reg[k]<=FOOF[k];
        fxFCADD_raise_reg[k]<=fxFCADD_raise[k];
        fxFADD_raise_reg[k]<=fxFADD_raise[k];
    end
      gxFADD_en=u1_op_reg[0] && u1_en_reg[2] && pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_cmpDH) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_cmpDL) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_cmpE) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_cmpS) || {u1_op_reg[7:2],2'b0}==`fop_linsrch;
      gxFADD_srch<={u1_op_reg[7:2],2'b0}==`fop_linsrch;
      gxFADD_ord=u1_op_reg[10];
      gxFADD_hi=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_cmpDH);
      gxFADD_ext=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_cmpE);
      gxFADD_dbl=pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_cmpDH) || pwh#(8)::cmpEQ(u1_op_reg[7:0],`fop_cmpDL);
      gxFADD_sn=~gxFADD_ext & ~gxFADD_dbl;
      gxFADD_sin=~gxFADD_dbl; 
      gxFADD_pkdS<={u1_op_reg[7:2],2'b0}==`fop_pcmplt && u1_op_reg[10];
      gxFADD_pkdD<={u1_op_reg[7:2],2'b0}==`fop_pcmplt && ~u1_op_reg[10];
      gxFADD_en_reg<=gxFADD_en;
      gxFADD_en_reg2<=gxFADD_en_reg;
      u1_op_reg2<=u1_op_reg;
      u1_en_reg2<=u1_en_reg;
      u1_en_reg3<=u1_en_reg2;
      u1_en_reg4<=u1_en_reg3;
      u1_en_reg5<=u1_en_reg4;
      u1_en_reg6<=u1_en_reg5;

  end

  always @(posedge clk) begin
      error=^u1_A || ^u1_B;
      error_reg<=error;
      error_reg2<=error_reg;
      error_reg3<=error_reg2;
      ALT_INP_reg<=ALT_INP;
      u1_op_reg<=u1_op;
      u1_en_reg<=u1_en;
      u1_en_reg7<=u1_en_reg6;
      u1_FK_reg<=u1_FK;
      FUF0_reg<=FUF0;
      FUF1_reg<=FUF1;
      FUF2_reg<=FUF2;
      FUF3_reg<=FUF3;
      FUF4_reg<=FUF4;
      FUFX4_reg<=FUF4X;
      FUFX5_reg<=FUF5X;
      FUFX6_reg<=FUF6X;
      u1_retX_en_reg<=u1_retX_en;
      u1_retX_en_reg2<=u1_retX_en_reg;
      u1_retX_en_reg3<=u1_retX_en_reg2;
      u1_retX_reg<=u1_retX;
      u1_retX_reg2<=u1_retX_reg;
      u1_retX_reg3<=u1_retX_reg2;
      FUF5_reg<=FUF5;
      FUF6_reg<=FUF6;
      FUF7_reg<=FUF7;
      FUF8_reg<=FUF8;
      FUF9_reg<=FUF9;
  end

endmodule
