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

module fun_fpusqr0(
  clk,
  rst,
  except,
  fpcsr,
  uh_A,uh_B,ul_A,ul_B,u1_en,u1_op,
  u1_ret,u1_ret_en,
  u1_regNo,u1_II,
  en_early,op_early,
  outEn,
  outII,
  outOp,
  FUreg,
  FUSreg,
  FUwen,
  outAltData,
  fxFRT_alten,
  fxFRT_pause
  );
  //parameter [1:0] INDEX=2'd2;
  parameter [0:0] H=1'b0;
  localparam SIMD_WIDTH=68; //half width
  localparam S=H ? 16 : 0;
  localparam REG_WIDTH=9;
  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire [31:0] fpcsr;
  input pwire [S+67:0] uh_A;
  input pwire [S+67:0] uh_B;
  input pwire [S+67:0] ul_A;
  input pwire [S+67:0] ul_B;
  input pwire [3:0] u1_en;
  input pwire [12:0] u1_op;
  output pwire [13:0] u1_ret;
  output pwire u1_ret_en;
  input pwire [REG_WIDTH-1:0] u1_regNo;
  input pwire [9:0] u1_II;
  input pwire [3:0] en_early;
  input pwire [12:0] op_early;
  
  output pwire [3:0] outEn;
  output pwire [9:0] outII;
  output pwire [12:0] outOp;
  output pwire [8:0] FUreg;
  output pwire [8:0] FUSreg;
  output pwire FUwen;
  output pwire [S+SIMD_WIDTH-1:0] outAltData;

  output pwire [2:0] fxFRT_alten;//very fat wire
	output [2:0]      fxFRT_pause;//same here

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
  //wire [15:0] u1_Bx=u1_BH[15:0];
  //wire [15:0] u2_Bx=u2_BH[15:0];
  integer k;

  pwire [1:0] ALT_INP_reg;
  
	wire [2:0] fxFRT_alten;
	reg [2:0] fxFRT_alten_reg;
	reg [2:0] fxFRT_alten_reg2;
	reg [2:0] fxFRT_alten_reg3;
	reg [2:0] fxFRT_alten_reg4;
	reg [2:0] fxFRT_alten_reg5;
	reg [2:0] fxFRT_alten_reg6;
	wire [2:0] fxFRT_pause;
	wire [2:0] fxFRT_can;
    pwire [2:0] fxFRT_don;
    pwire [2:0] fxFRT_can_reg;
    pwire [2:0] fxFRT_don_reg;
    pwire [2:0] fxFRT_don_reg2;
    pwire [2:0] fxFRT_don_reg3;
    pwire [2:0] fxFRT_don_reg4;
  pwire [4:0] fxFRT_steps;
  pwire [2:0] fxFRT_type;
  pwire [4:0] fxFRT_steps_reg;
  pwire [2:0] fxFRT_type_reg;
  pwire fxFRT_isRoot;
  pwire fxFRT_isRoot_reg;
//  pwire [1:0] fxFRT_don_reg;
  pwire fxFRT_dbl_reg;
  pwire fxFRT_ext_reg;
  pwire fxFRT_sngl_reg;
  pwire fxFRT_dbl;
  pwire fxFRT_ext;
  pwire fxFRT_sngl;
  pwire fxFRT_dbl_s;
  pwire fxFRT_ext_s;
  pwire fxFRT_sngl_s;
  pwire fxFRT_dbl_ns;
  pwire fxFRT_ext_ns;
  pwire fxFRT_sngl_ns;
  pwire [63:-1] fxFRT_normA0;
  pwire [15:0] fxFRT_expA;
  pwire [63:-1] fxFRT_normB0;
  pwire [15:0] fxFRT_expB;
  pwire fxFRT_sgnA;
  pwire fxFRT_sgnB;
    pwire [2:0][8:0] rtReg;
    pwire [2:0][9:0] rtII;
  pwire [8:0] frtReg;
  pwire [9:0] frtII;
  pwire [12:0] frtOp;
  pwire [8:0] frtReg_reg;
  pwire [9:0] frtII_reg;
  pwire [12:0] frtOp_reg;
    pwire [2:0][12:0] rtOp;
    pwire [2:0][135:0] rtRes;
  pwire fxFRT_do,fxFRT_en;
  pwire [12:0] u1_op_reg;
  pwire [9:0]  u1_II_reg;
    pwire [3:0]  u1_en_reg;

  pwire [S+67:0] rtDataA;
  pwire [S+67:0] rtDataB;
  pwire  [S+67:0] rtDataA_reg;
  pwire  [S+67:0] rtDataB_reg;

  pwire [S+67:0] uu_Bv1;
  pwire [S+67:0] uu_Av1;
  pwire [S+67:0] uu_B1;
  pwire [S+67:0] uu_A1;
  pwire [S+67:0] uu_Bv_reg;
  pwire [S+67:0] uu_Av_reg;

  pwire [REG_WIDTH-1:0] u1_regNo_reg;
  
  pwire [3:0] u1_fufwd_A_reg;
  pwire [3:0] u1_fuufwd_A_reg;
  pwire [3:0] u1_fufwd_B_reg;
  pwire [3:0] u1_fuufwd_B_reg;

  
  in_flip_rt #(S+SIMD_WIDTH+9+10) rtDatA_mod(
    .clk(clk),.rst(rst),.in_en(fxFRT_en),.pause(fxFRT_pause[2]),
    .d_in({u1_II_reg,u1_regNo_reg,u1_op_reg==(`fop_sqrtDH|2048) || u1_op_reg==(`fop_divDH|2048) ? uh_A : ul_A}),
    .d_out({frtII,frtReg,rtDataA}),
    .dout_en((fxFRT_can[0] & ~fxFRT_don_reg[0] & ~fxFRT_don_reg2[0] & ~fxFRT_don_reg2[0] & ~fxFRT_don_reg3[0]) |
     (fxFRT_can[1] & ~fxFRT_don_reg[1] & ~fxFRT_don_reg2[1] & ~fxFRT_don_reg2[1] & ~fxFRT_don_reg3[1]) |
     (fxFRT_can[2] & ~fxFRT_don_reg[2] & ~fxFRT_don_reg2[2] & ~fxFRT_don_reg2[2] & ~fxFRT_don_reg3[2]) 
    ),.do_(fxFRT_do));
  in_flip_rt #(13+S+SIMD_WIDTH) rtDatB_mod(
    .clk(clk),.rst(rst),.in_en(fxFRT_en),.pause(),
    .d_in({u1_op_reg,u1_op_reg==(`fop_sqrtDH|2048) || u1_op_reg==(`fop_divDH|2048) ? uh_B : ul_B}),
    .d_out({frtOp,rtDataB}),
    .dout_en((fxFRT_can[0] & ~fxFRT_don_reg[0] & ~fxFRT_don_reg2[0] & ~fxFRT_don_reg2[0] & ~fxFRT_don_reg3[0]) |
     (fxFRT_can[1] & ~fxFRT_don_reg[1] & ~fxFRT_don_reg2[1] & ~fxFRT_don_reg2[1] & ~fxFRT_don_reg3[1]) |
     (fxFRT_can[2] & ~fxFRT_don_reg[2] & ~fxFRT_don_reg2[2] & ~fxFRT_don_reg2[2] & ~fxFRT_don_reg3[2]) 
      ),.do_());
  
  assign fxFRT_don[0]=fxFRT_do&fxFRT_can[0]&~fxFRT_don_reg[0]&~fxFRT_don_reg2[0]&~fxFRT_don_reg3[0];
  assign fxFRT_don[1]=fxFRT_do&&~fxFRT_can[0]|fxFRT_don_reg[0]|fxFRT_don_reg2[0]|fxFRT_don_reg3[0]
   && fxFRT_can[1] && ~fxFRT_don_reg[1]&&~fxFRT_don_reg2[1]&&~fxFRT_don_reg3[1];
  assign fxFRT_don[2]=fxFRT_do&&~fxFRT_can[0]|fxFRT_don_reg[0]|fxFRT_don_reg2[0]|fxFRT_don_reg3[0]
   && ~fxFRT_can[1]|fxFRT_don_reg[1]|fxFRT_don_reg2[1]|fxFRT_don_reg3[1] 
   && fxFRT_can[2] && ~fxFRT_don_reg[2]&&~fxFRT_don_reg2[2]&&~fxFRT_don_reg3[2];



  assign fxFRT_expA=fxFRT_dbl ? {rtDataA_reg[65],{4{~rtDataA_reg[65]&&|{rtDataA_reg[65],rtDataA_reg[63:53]}}},
    rtDataA_reg[63:53]} : 16'bz;
  assign fxFRT_expA=fxFRT_sngl ? {rtDataA_reg[65],{7{~rtDataA_reg[65]&&|{rtDataA_reg[65],rtDataA_reg[30:23]}}},
    rtDataA_reg[30:23]} : 16'bz;
  assign fxFRT_expB=fxFRT_dbl? {rtDataB_reg[65],{4{~rtDataB_reg[65]&&|{rtDataB_reg[65],rtDataB_reg[63:53]}}},
    rtDataB_reg[63:53]} : 16'bz;
  assign fxFRT_expB=fxFRT_sngl ? {rtDataB_reg[65],{7{~rtDataB_reg[65]&&|{rtDataB_reg[65],rtDataB_reg[30:23]}}},
    rtDataB_reg[30:23]} : 16'bz;
  generate
    if (H) begin
        assign fxFRT_expA=fxFRT_ext ? {rtDataA_reg[65],rtDataA_reg[SIMD_WIDTH+14:SIMD_WIDTH]} : 16'bz;
        assign fxFRT_expB=fxFRT_ext ? {rtDataB_reg[65],rtDataB_reg[SIMD_WIDTH+14:SIMD_WIDTH]} : 16'bz;
    end else begin
        assign fxFRT_expA=fxFRT_ext ? 16'b0 : 16'bz;
        assign fxFRT_expB=fxFRT_ext ? 16'b0 : 16'bz;
    end
  endgenerate

  assign fxFRT_normA0=fxFRT_dbl_ns ? {1'b1,rtDataA_reg[52:33],rtDataA_reg[31:0],12'b0} : 65'bz;
  assign fxFRT_normA0=fxFRT_sngl_ns ?{1'b1,rtDataA_reg[22:0],41'b0} : 65'bz;
  assign fxFRT_normA0=fxFRT_ext_ns ? {rtDataA_reg[64:33],rtDataA_reg[31:0],1'b0} : 65'bz;
  assign fxFRT_normA0=fxFRT_dbl_s ? {2'b1,rtDataA_reg[52:33],rtDataA_reg[31:0],11'b0} : 65'bz;
  assign fxFRT_normA0=fxFRT_sngl_s ?{2'b1,rtDataA_reg[22:0],40'b0} : 65'bz;
  assign fxFRT_normA0=fxFRT_ext_s ? {1'b0,rtDataA_reg[64:33],rtDataA_reg[31:0]} : 65'bz;
  assign fxFRT_normB0=fxFRT_dbl ? {1'b1,rtDataB_reg[52:33],rtDataB_reg[31:0],12'b0} : 65'bz;
  assign fxFRT_normB0=fxFRT_sngl ?{1'b1,rtDataB_reg[22:0],41'b0} : 65'bz;
  assign fxFRT_normB0=fxFRT_ext ? {rtDataB_reg[64:33],rtDataB_reg[31:0],1'b0} : 65'bz;

  assign fxFRT_sgnA=fxFRT_dbl ? rtDataA_reg[64] : 1'bz;
  assign fxFRT_sgnA=fxFRT_sngl ? rtDataA_reg[31] : 1'bz;
  assign fxFRT_sgnA=fxFRT_ext ? rtDataA_reg[31] : 1'bz;
  assign fxFRT_sgnB=fxFRT_dbl ? rtDataB_reg[64] : 1'bz;
  assign fxFRT_sgnB=fxFRT_sngl ? rtDataB_reg[31] : 1'bz;
  assign fxFRT_sgnB=fxFRT_ext ? rtDataB_reg[31] : 1'bz;

  generate
      genvar n;
      for(n=0;n<3;n=n+1) begin : rt2_mod 
	  rt2_fp rt2_mod(
          .clk(clk),
          .rst(rst),
	  .except(except), //warning: not SMT-ed
          .rdy(fxFRT_can[n]),
          .start_process(fxFRT_don_reg3[n]),
          .step_cnt(fxFRT_steps),
          .type_(fxFRT_type),
          .is_root(fxFRT_isRoot),
          .rmode(fxFRT_type==3'd1 ? fpcsr[`csrfpu_rmodeE] : fpcsr[`csrfpu_rmode]),
	  .reg_in(frtReg_reg),
	  .outII_in(frtII_reg),
	  .oper_in(frtOp_reg),
          .normA(fxFRT_normA0),
          .expA({1'b0,fxFRT_expA}),
          .nsignA(~fxFRT_sgnA),
          .normB(fxFRT_normB0),
          .expB({1'b0,fxFRT_expB}),
          .nsignB(~fxFRT_sgnB),
          .result(rtRes[n]),
	  .reg_out(rtReg[n]),
	  .outII_out(rtII[n]),
	  .oper_out(rtOp[n]),
          .out_en(fxFRT_alten[n]),
          .out_can(!|(({fxFRT_alten,4'b0}>>n)&8'hf))
          );

	  assign outEn=(fxFRT_alten[n] && (!|(({fxFRT_alten,4'b0}>>n)&8'hf)) & ~rst)?
	    4'b1001 : 4'bz;
	  assign outII=(fxFRT_alten[n] && (!|(({fxFRT_alten,4'b0}>>n)&8'hf)) & ~rst) ?
	    rtII[n] : 'z;
	  assign outOp=(fxFRT_alten[n] && (!|(({fxFRT_alten,4'b0}>>n)&8'hf)) & ~rst) ?
	    rtOp[n] : 'z;
	  assign FUreg=(fxFRT_alten[n] && (!|(({fxFRT_alten,4'b0}>>n)&8'hf)) & ~rst) ?
	    rtReg[n] : 'z;
	  assign FUSreg=(fxFRT_alten[n] && (!|(({fxFRT_alten,4'b0}>>n)&8'hf)) & ~rst) ?
	    9'h1ff : 'z;
	  assign FUwen=(fxFRT_alten[n] && (!|(({fxFRT_alten,4'b0}>>n)&8'hf)) & ~rst) ?
	    1'b1 : 1'bz;

	  assign outAltData=(fxFRT_alten_reg5[n]  && (!|(({fxFRT_alten_reg5,4'b0}>>n)&8'hf)) && ~rst) ? 
	    rtRes[n][S+67:0] : {S+SIMD_WIDTH{1'bz}};//tri state close to target
      end
  endgenerate 

  assign outAltData=fxFRT_alten_reg5==4'b0 ? {S+SIMD_WIDTH{1'b0}} : {S+SIMD_WIDTH{1'bz}};

  always @(posedge clk) begin
      if (rst) begin
	  fxFRT_dbl=1'b0;
	  fxFRT_ext=1'b0;
	  fxFRT_sngl=1'b0;
/*	  fxFRT_dblL_reg<=1'b0;
          fxFRT_dblH_reg<=1'b0;
          fxFRT_ext_reg<=1'b0;
          fxFRT_sngl_reg<=1'b0;*/
          fxFRT_isRoot=1'b0;
//	  fxFRT_isRoot_reg<=1'b0;
	  fxFRT_dbl_s<=1'b0;
          fxFRT_ext_s<=1'b0;
          fxFRT_sngl_s<=1'b0;
	  fxFRT_dbl_ns<=1'b0;
          fxFRT_ext_ns<=1'b0;
          fxFRT_sngl_ns<=1'b0;
	  fxFRT_steps<=5'd0;
	  fxFRT_type<=3'b0;
	  fxFRT_steps_reg<=5'd0;
	  fxFRT_type_reg<=3'b0;
	  fxFRT_don_reg<=4'b0;
	  fxFRT_en<=1'b0;
	  rtDataA_reg<={S+SIMD_WIDTH{1'b0}};
	  rtDataB_reg<={S+SIMD_WIDTH{1'b0}};
	  fxFRT_alten_reg<=4'b0;
	  fxFRT_alten_reg2<=4'b0;
	  fxFRT_alten_reg3<=4'b0;
	  fxFRT_alten_reg4<=4'b0;
	  fxFRT_alten_reg5<=4'b0;
	  fxFRT_alten_reg6<=4'b0;
	  fxFRT_can_reg<=4'd0;
	  fxFRT_don_reg<=4'd0;
	  fxFRT_don_reg2<=4'd0;
	  fxFRT_don_reg3<=4'd0;
	  fxFRT_don_reg4<=4'd0;
	  frtReg_reg<=9'b0;
	  frtII_reg<=10'b0;
	  frtOp_reg<=13'b0;
      end else begin
	  fxFRT_dbl=!H ? pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtDL) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_divDL) :
              pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtDH) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_divDH);
          fxFRT_ext=pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtE) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_divE);
          fxFRT_sngl=pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtS) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_divS);
	  fxFRT_isRoot=pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtDL) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtDH) ||
                pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtE) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtS); 
	  fxFRT_dbl_ns<=fxFRT_dbl && ~rtDataA[53]|~fxFRT_isRoot;
	  fxFRT_ext_ns<=fxFRT_ext && ~rtDataA[SIMD_WIDTH-16+S]|~fxFRT_isRoot;
	  fxFRT_sngl_ns<=fxFRT_sngl && ~rtDataA[23]|~fxFRT_isRoot;
	  fxFRT_dbl_s<=fxFRT_dbl && rtDataA[53]&fxFRT_isRoot;
	  fxFRT_ext_s<=fxFRT_ext && rtDataA[SIMD_WIDTH-16+S]&fxFRT_isRoot;
	  fxFRT_sngl_s<=fxFRT_sngl && rtDataA[23]&fxFRT_isRoot;
    /* 	  fxFRT_dblL_reg<=fxFRT_dblL;
          fxFRT_dblH_reg<=fxFRT_dblH;
          fxFRT_ext_reg<=fxFRT_ext;
          fxFRT_sngl_reg<=fxFRT_sngl;*/
     //     fxFRT_isRoot_reg<=fxFRT_isRoot;
	  fxFRT_en<=op_early[11] && en_early[3:2]!=0; 
	  if (pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtDL) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_divDL) ||
	    pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtDH) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_divDH)) begin
	      fxFRT_steps<=5'd13;
	      fxFRT_type<=3'b0;
	  end else if (pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtE) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_divE)) begin
	      fxFRT_steps<=5'd16;
	      fxFRT_type<=3'd1;
	  end else if (pwh#(8)::cmpEQ(frtOp[7:0],`fop_sqrtS) || pwh#(8)::cmpEQ(frtOp[7:0],`fop_divS)) begin
	      fxFRT_steps<=5'd6;
	      fxFRT_type<=3'd2;
	  end
	 /* fxFRT_steps_reg<=fxFRT_steps;
	  fxFRT_type_reg<=fxFRT_type;*/
	  fxFRT_don_reg<=fxFRT_don;
	  fxFRT_alten_reg<=fxFRT_alten;
	  fxFRT_alten_reg2<=fxFRT_alten_reg;
	  fxFRT_alten_reg3<=fxFRT_alten_reg2;
	  fxFRT_alten_reg4<=fxFRT_alten_reg3;
	  fxFRT_alten_reg5<=fxFRT_alten_reg4;
	  fxFRT_alten_reg6<=fxFRT_alten_reg5;
	  fxFRT_can_reg<=fxFRT_can;
	  fxFRT_don_reg<=fxFRT_don;
	  fxFRT_don_reg2<=fxFRT_don_reg;
	  fxFRT_don_reg3<=fxFRT_don_reg2;
	  fxFRT_don_reg4<=fxFRT_don_reg3;
	  frtReg_reg<=frtReg;
          frtII_reg<=frtII;
          frtOp_reg<=frtOp;
	  uu_Av_reg<=uu_A1;
	  uu_Bv_reg<=uu_B1;
	  u1_regNo_reg<=u1_regNo;
	  u1_op_reg<=u1_op;
	  u1_II_reg<=u1_II;
	  u1_en_reg<=u1_en;

	  if (|fxFRT_don_reg2) begin
              rtDataA_reg<=rtDataA;
	      rtDataB_reg<=rtDataB;
	  end else begin
              rtDataA_reg<='z;
	      rtDataB_reg<='z;
          end
      end
  end

endmodule
