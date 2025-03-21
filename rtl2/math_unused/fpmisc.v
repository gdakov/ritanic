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

module rt2_fp(
  clk,
  rst,
  except,
  rdy,
  start_process,
  step_cnt,
  type_,
  is_root,
  rmode,
  reg_in,
  outII_in,
  oper_in,
  normA,
  expA,
  nsignA,
  normB,
  expB,
  nsignB,
  result,
  reg_out,
  outII_out,
  oper_out,
  out_en,
  out_can
  );
  localparam ROUND_TRUNC=0;
  localparam ROUND_ROUND=1;
  localparam ROUND_EVEN =2;
  localparam ROUND_PLUS =3;
  localparam ROUND_MINUS=4;
  localparam ROUND_UP   =5;
  localparam ROUND_DOWN =6;
  localparam [16:0] BIAS=17'h7fff;
  localparam SIMD_WIDTH=68;
  localparam II_WIDTH=10;
/*verilator hier_block*/
  input clk;
  input rst;
  input except;
  output reg rdy;
  input start_process;
  input [4:0] step_cnt;
  input [2:0] type_;
  input is_root;
  input [2:0] rmode;
  input [8:0] reg_in;
  input [II_WIDTH-1:0] outII_in;
  input [12:0] oper_in;
  input [64:0] normA;
  input [16:0] expA;
  input nsignA;
  input [64:0] normB;
  input [16:0] expB;
  input nsignB;
  output [2*SIMD_WIDTH-1:0] result;
  output reg [8:0] reg_out;
  output reg [II_WIDTH-1:0] outII_out;
  output reg [12:0] oper_out;
  output reg out_en;
  input out_can;
 reg [55:-1] inv_bits;
 wire [3:0] new_digit;
 wire [119:0] prod;
 wire [119:0] square;
 reg [63:-8] Se[15:1];
 reg [55:0] SeA[15:1];
 reg SeB[15:1];
 wire [15:1][63:-8] Se_d;
 reg [135:0] P;
 wire [15:1][127:0] P_out;
 wire [135:0] P_d;
 wire P_cout[15:1];
 wire [15:1][7:0] P8_out;
 wire [63:-1] minus_norm;
 reg [16:0] expA_reg;
 reg [16:0] expB_reg;
 reg [16:0] expA_reg2;
 wire exact_result;
 reg exact_reg;
 reg is_root_reg;
 wire [15:0] P_en;
 reg [15:0] P_en_reg;
 reg perform_stage;
 reg [4:0] cnt;
 reg [4:0] cnt1;
 wire [4:0] cnt_d;
 reg [67:0] digits;
 reg isrnd_zero,isrnd_plus,isrnd_even;
 wire DBL_rnbit,DBL_tail,DBL_rnd,DBL_lead,DBL_last;
 wire DBL_oor;
 wire SNGL_rnbit,SNGL_tail,SNGL_rnd,SNGL_lead,SNGL_last;
 wire SNGL_oor;
 wire EXT_rnbit,EXT_tail,EXT_rnd,EXT_lead,EXT_last;
 wire EXT_oor;
 wire [67:0] rndbits;
 reg [2:0] type_reg;
 wire [15:1][7:0] Se_arg;
 wire [15:1][13:0] Se_arg2;
 reg [15:1][7:0] Se_arg_reg;
 reg [15:1][13:0] Se_arg2_reg;
 wire [16:0] exp_inc;
 wire [16:0] exp_incy;
 reg nsignA_reg;
 reg nsignB_reg;
 reg [14:0] rdy_cnt;
 wire [67:0] normB_11;
 wire [67:0] normB_101;
 wire [67:0] normB_1001;
 wire [67:0] normB_111;
 wire [67:0] normB_1011;
 wire [67:0] normB_1101;
 wire [67:0] normB_1111;
 wire A_h,A_zero,A_infty,A_nan;
 wire B_h,B_zero,B_infty,B_nan;
 reg A_h_reg,B_h_reg;
 wire specR_zero,specR_nan;
 wire specR_infty;
 wire [16:0] e2p0;
 wire [16:0] e2p1;
 wire [16:0] exp2;
 wire [16:0] exp2x;
 reg rdy0;
 reg rdy0_reg;
 reg rdy0_reg2;
 wire [16:0] ANY_denor;
 wire [16:0] ANY_enan;
 wire exp2x_cmp,exp2y_cmp;
 wire ANY_lead;
 wire ANY_xbit2;
 integer p;
 wire [2*SIMD_WIDTH-1:0] result_X;

//WARNING: need to tage negative sign from bit 128; 129 bit adder with same
//delay as 128 easy to make
//
 assign result=result_X;
 generate
     genvar Se_ind,d_ind;
     for(Se_ind=1;Se_ind<16;Se_ind=Se_ind+1) begin  : Se_add_gen
	 wire [136:0] par1;
	 wire [136:0] par2;
	 for(d_ind=0;d_ind<16;d_ind=d_ind+1) begin
	     assign Se_arg2[Se_ind]=P_en[d_ind] ? d_ind*Se_ind*32+Se_ind*Se_ind : 14'bz;
	     assign Se_arg[Se_ind]=P_en[d_ind] ? d_ind*Se_ind : 8'bz;
	 end
   //  assign square[Se_ind*8-8+:8]=Se_ind*Se_ind;
	 adder #(72) Se_add({Se[Se_ind][59:-8],4'b0},{60'b0,3'b0,Se_arg_reg[Se_ind],1'b0},Se_d[Se_ind],1'b0,1'b1,,,,);
         adder_CSA #(136) CSA_P(P,{SeA[Se_ind],Se[Se_ind],SeB[Se_ind],7'b0},{122'b0,Se_arg2_reg[Se_ind]},par1,par2);
	 //one 8-bit adder for final digit and one 128 bit for all.
	 adder2o #(128) P_add(par1[135:8],par2[135:8],{P8_out[Se_ind],P_out[Se_ind][127:8]},P_d[135:8],P_cout[Se_ind],1'b1,P_en[Se_ind],,,,);
	 adder2o #(8) P8_add(par1[7:0],par2[7:0],P_out[Se_ind][7:0],P_d[7:0],1'b0,1'b1,P_en[Se_ind],P_cout[Se_ind],,,);
	 if (Se_ind<15) assign P_en[Se_ind]=P8_out[Se_ind][7] & ~P8_out[Se_ind+1][7];
	 else assign P_en[Se_ind]=P8_out[Se_ind][7]; 
	 assign new_digit=P_en[Se_ind] ? Se_ind[3:0] : 4'bz;
     end
 endgenerate
 
 

 assign P_en[0]=~P8_out[1][7];
 assign P_d=P_en[0] ? P[135:0] : 136'bz;
 assign new_digit=P_en[0] ? 4'd0 : 4'bz;

 assign minus_norm=~normA;

 assign exact_result=&P && ~|inv_bits;
 
 assign EXT_lead=digits[67];
 assign EXT_rnbit=EXT_lead ? digits[3] : digits[2];
 assign EXT_tail=EXT_lead ? |digits[2:0] | ~exact_result : |digits[1:0] | ~exact_result;
 assign EXT_last=EXT_lead? digits[4] : digits[3]; 
 assign EXT_rnd=~isrnd_zero && (EXT_rnbit & ~(isrnd_even & ~EXT_tail & EXT_last) 
    || (isrnd_plus && EXT_rnbit | EXT_tail));  
 
 assign SNGL_lead=digits[27];
 assign SNGL_rnbit=SNGL_lead ? digits[3] : digits[2];
 assign SNGL_tail=SNGL_lead ? |digits[2:0] | ~exact_result : |digits[1:0] | ~exact_result;
 assign SNGL_last=SNGL_lead? digits[4] : digits[3]; 
 assign SNGL_rnd=~isrnd_zero && (SNGL_rnbit & ~(isrnd_even & ~SNGL_tail & SNGL_last) 
    || (isrnd_plus && SNGL_rnbit | SNGL_tail));  
 

 assign DBL_lead=digits[55];
 assign DBL_rnbit=DBL_lead ? digits[2] : digits[1];
 assign DBL_tail=DBL_lead ? |digits[1:0] | ~exact_result : digits[0] | ~exact_result;
 assign DBL_last=DBL_lead? digits[3] : digits[2]; 
 assign DBL_rnd=~isrnd_zero && (DBL_rnbit & ~(isrnd_even & ~DBL_tail & DBL_last) 
    || (isrnd_plus && DBL_rnbit | DBL_tail));  
 
 assign rndbits={64'b0,type_reg==3'd0,3'b0};
 adder #(5) cntAdd_mod(cnt,5'h1f,cnt_d,1'b0,1'b1,,,,);
 
 adder #(64) digg1Add(digits[67:4],64'b1,{result_X[64:33],result_X[31:0]},1'b0,
  EXT_rnd && type_reg==1 && EXT_lead,,,,);
 adder #(64) digg0Add(digits[66:3],64'b1,{result_X[64:33],result_X[31:0]},1'b0,
   EXT_rnd && type_reg==1 && ~EXT_lead,,,,);
 assign {result_X[64:33],result_X[31:0]}=(type_reg==1  && ~EXT_rnd && EXT_lead) ? digits[67:4] : 64'bz;
 assign {result_X[64:33],result_X[31:0]}=(type_reg==1  && ~EXT_rnd && ~EXT_lead) ? digits[66:3] : 64'bz;
 assign {result_X[65],result_X[SIMD_WIDTH+14:SIMD_WIDTH]}=type_reg==1 && 
   is_root_reg ? {exp_inc[16],exp_inc[15:1]} : 16'bz; 
 assign result_X[SIMD_WIDTH+15]=(type_reg==1 & is_root_reg) ? 1'b0 : 1'bz;
 assign {result_X[65],result_X[SIMD_WIDTH+14:SIMD_WIDTH]}=type_reg==1 &&
   ~is_root_reg ? {exp2[15],exp2[14:0]} : 16'bz; 
 assign result_X[SIMD_WIDTH+15]=type_reg==1 & ~is_root_reg
   ? nsignA_reg^nsignB_reg : 1'bz;
 assign result_X[67:66]=(type_reg==1) ? 2'd`ptype_ext : 2'bz;
 assign result_X[SIMD_WIDTH+67:SIMD_WIDTH+66]=type_reg==1 
   ? 2'd`ptype_ext : 2'bz;
 
 adder2o #(52) digg1Add_E(digits[54:3],rndbits[54:3],{result_X[52:33],result_X[31:0]},
  {result_X[SIMD_WIDTH+52:SIMD_WIDTH+33],result_X[SIMD_WIDTH+31:SIMD_WIDTH]},1'b0,
  DBL_rnd && type_reg==0 && DBL_lead,DBL_rnd && type_reg==4 && DBL_lead,,,,);
 adder2o #(52) digg0Add_E(digits[53:2],rndbits[54:3],{result_X[52:33],result_X[31:0]},
   {result_X[SIMD_WIDTH+52:SIMD_WIDTH+33],result_X[SIMD_WIDTH+31:SIMD_WIDTH]},1'b0,
   DBL_rnd && type_reg==0 && ~DBL_lead,DBL_rnd && type_reg==4 && ~DBL_lead,,,,);
 assign {result_X[52:33],result_X[31:0]}=(type_reg==0  && ~DBL_rnd && DBL_lead) ? digits[54:3] : 52'bz;
 assign {result_X[52:33],result_X[31:0]}=(type_reg==0  && ~DBL_rnd && ~DBL_lead) ? digits[53:2] : 52'bz;
 assign {result_X[SIMD_WIDTH+52:SIMD_WIDTH+33],result_X[SIMD_WIDTH+31:SIMD_WIDTH]}=
   (type_reg==4  && ~DBL_rnd && DBL_lead) ? digits[54:3] : 52'bz;
 assign {result_X[SIMD_WIDTH+52:SIMD_WIDTH+33],result_X[SIMD_WIDTH+31:SIMD_WIDTH]}=
   (type_reg==4  && ~DBL_rnd && ~DBL_lead) ? digits[53:2] : 52'bz;
 assign {result_X[65],result_X[63:53]}=(type_reg==0 && is_root_reg) ? {exp_inc[16],exp_inc[11:1]} : 12'bz; 
 assign result_X[64]=(type_reg==0 & is_root_reg) ? 1'b0 : 1'bz;
 assign {result_X[65],result_X[63:53]}=(type_reg==0 && ~is_root_reg) ? {exp2[15],exp2[10:0]} : 12'bz; 
 assign result_X[64]=(type_reg==0 & ~is_root_reg) ? nsignA_reg^nsignB_reg : 1'bz;
 assign {result_X[SIMD_WIDTH+65],result_X[SIMD_WIDTH+63:SIMD_WIDTH+53]}=(type_reg==4
   && is_root_reg) ? {exp_inc[16],exp_inc[11:1]} : 12'bz; 
 assign result_X[SIMD_WIDTH+64]=(type_reg==4 & is_root_reg) ? 1'b0 : 1'bz;
 assign {result_X[SIMD_WIDTH+65],result_X[SIMD_WIDTH+63:SIMD_WIDTH+53]}=(type_reg==4
   && ~is_root_reg) ? {exp2[15],exp2[10:0]} : 12'bz; 
 assign result_X[SIMD_WIDTH+64]=(type_reg==4 & ~is_root_reg) ? nsignA_reg^nsignB_reg : 1'bz;
 assign result_X[67:66]=(type_reg==0 || type_reg==4) ? 2'd`ptype_dbl : 2'bz;
 assign result_X[SIMD_WIDTH+67:SIMD_WIDTH+66]=(type_reg==0 || type_reg==4) ? 2'd`ptype_dbl : 2'bz;
 assign result_X[65:0]=(type_reg==4) ? 66'b0 : 66'bz;
 assign result_X[SIMD_WIDTH+65:SIMD_WIDTH+16]=(type_reg==0||
   type_reg==2 || type_reg==1) ? 50'b0 : 50'bz;
 assign result_X[SIMD_WIDTH+15:SIMD_WIDTH]=(type_reg==0||
   type_reg==2) ? 16'b0 : 16'bz;
 assign result_X[32]=(type_reg==0) ? 1'b0 : 1'bz;
 assign result_X[SIMD_WIDTH+32]=(type_reg==4) ? 1'b0 : 1'bz;

 adder #(23) digg1Add_S(digits[26:4],{22'b0,1'b1},result_X[22:0],1'b0,SNGL_rnd && type_reg==2 && SNGL_lead,,,,);
 adder #(23) digg0Add_S(digits[25:3],{22'b0,1'b1},result_X[22:0],1'b0,SNGL_rnd && type_reg==2 && ~SNGL_lead,,,,);
 assign result_X[22:0]=(type_reg==2  && ~SNGL_rnd && SNGL_lead) ? digits[26:4] : 23'bz;
 assign result_X[22:0]=(type_reg==2  && ~SNGL_rnd && ~SNGL_lead) ? digits[25:3] : 23'bz;
 assign {result_X[32],result_X[30:23]}=(type_reg==2 && is_root_reg) ? {exp_inc[16],exp_inc[8:1]} : 9'bz; 
 assign result_X[31]=(type_reg==2 & is_root_reg) ? 1'b0 : 1'bz;
 assign {result_X[32],result_X[30:23]}=(type_reg==2 && ~is_root_reg) ? {exp2[15],exp2[7:0]} : 9'bz; 
 assign result_X[31]=(type_reg==2 & ~is_root_reg) ? nsignA_reg^nsignB_reg : 1'bz;
 assign result_X[67:66]=(type_reg==2) ? 2'd`ptype_sngl : 2'bz;
 assign result_X[SIMD_WIDTH+67:SIMD_WIDTH+66]=(type_reg==2) ? 2'd`ptype_sngl : 2'bz;
// assign result_X[2*SIMD_WIDTH:0]=(type_reg==4) ? 66'b0 : 66'bz;
 assign result_X[65:33]=(type_reg==2) ? 33'b0 : 33'bz;


 adder #(17) expAdd_mod(expA_reg,17'h7fff,exp_incy,1'b0,1'b1,,,,);
 adder_CSA #(16) exp2CSA_mod(expA_reg[15:0],~expB_reg[15:0],BIAS[15:0],e2p0,e2p1);
 adder2c #(17) exp2Add_mod(e2p0,e2p1,exp2x,exp2x,1'b0,1'b1,~ANY_lead&&expA_reg!=0,ANY_lead&&expA_reg!=0,,,,);
 assign exp2x=( expA_reg==0) ? 0 : 17'bz;
 assign exp2=(A_nan||B_nan||B_zero&A_zero||A_infty&B_infty) ? 17'hffff: 17'bz;
 assign exp2=(A_infty&~B_infty&~B_nan||~A_infty&~A_nan&B_zero||(exp2[16]^exp2[15])&ANY_xbit2||
       (exp2x==ANY_enan&&~A_nan&&~B_nan)) ? 17'hfffe : 17'bz;
 assign exp2=(A_zero&~B_nan||B_infty&~A_nan&~A_infty||~exp2x_cmp&~exp2[16]&~A_nan&~B_nan&~B_zero&~A_infty) ? 17'h0 : 17'bz;

 assign exp_inc=specR_zero ? 17'b0 : 17'bz;
 assign exp_inc=specR_infty ? 17'hfffe : 17'bz;

 assign exp_inc=specR_nan ? 17'hffff : 17'bz;

 assign exp_inc=specR_nan|specR_infty|specR_zero ? 17'bz : exp_incy;

 assign exp2=~A_nan&&~B_nan&&~A_infty&&~B_infty&&~A_zero&&~B_zero&&!~exp2x_cmp&~exp2[16]&&!(exp2[16]^exp2[15])&ANY_xbit2&&
	 !(exp2x==ANY_enan&&~A_nan&&~B_nan) ? exp2x : 17'bz;//bottle

 get_carry #(17) exp2cmp_mod(exp2x,~ANY_denor,1'b1,exp2x_cmp);
 get_carry #(17) exp2tycmp_mod(exp_incy,~ANY_denor,1'b1,exp2y_cmp);

 assign ANY_denor=type_reg[1:0]==2'b0 ? 17'hbfff-17'd53 : 17'bz;
 assign ANY_denor=type_reg==3'b1 ? 17'hbfff-17'd64 : 17'bz;
 assign ANY_denor=type_reg[1:0]!=2'b0 && type_reg!=3'd1 ? 17'hbfff-17'd24 : 17'bz;

 assign ANY_enan=17'hffff;

 assign ANY_lead=type_reg[1:0]==2'b0 ? DBL_lead : 1'bz;
 assign ANY_lead=type_reg==3'b1 ? EXT_lead : 1'bz;
 assign ANY_lead=type_reg[1:0]!=2'b0 && type_reg!=3'd1 ? SNGL_lead : 1'bz;

 assign ANY_xbit2=type_reg[1:0]==2'b0 ? exp2[10] : 1'bz;
 assign ANY_xbit2=type_reg==3'b1 ? exp2[14] : 1'bz;
 assign ANY_xbit2=type_reg[1:0]!=2'b0 && type_reg!=3'd1 ? exp2[7] : 1'bz;

  sdupmass pm_mod(
  normB[64:1],
  normB_11,
  normB_101,
  normB_1001,
  normB_111,
  normB_1011,
  normB_1101,
  normB_1111);

 assign specR_zero=expA_reg==17'b0||~exp2y_cmp&~exp_inc[16];
 assign specR_nan=~nsignA_reg && expA_reg!=0 || A_nan;
 assign specR_infty=nsignA_reg && A_infty;

 assign DBL_oor=exp2[14:11]!={4{~exp2[15]}};
  
 assign A_h=|normA[63:1]; 

 assign A_zero=expA_reg==17'b0;
 assign A_infty=~A_h_reg && &expA_reg[15:0];
 assign A_nan=A_h_reg && &expA_reg[15:0];

 assign B_h=|normB[63:1]; 

 assign B_zero=expB_reg==17'b0;
 assign B_infty=~B_h_reg && &expB_reg[15:0];
 assign B_nan=B_h_reg && &expB_reg[15:0];

 always @(posedge clk) begin
     if (result_X!=result_X) $display("sqrt_zresult");
     if (rst|except) rdy0<=1'b0; 
     else rdy0<=out_en&out_can;
     if (rst|except) rdy0_reg<=1'b0; 
     else rdy0_reg<=rdy0;
     if (rst|except) rdy0_reg2<=1'b0; 
     else rdy0_reg2<=rdy0_reg;
     if (rst|except) begin
	 inv_bits<=0;
	 P<='z;
	 for(p=1;p<16;p=p+1) begin
	     Se[p]<='z;
		 //verilator lint_off WIDTH
	     Se_arg2_reg[p]<=p*p;
		 //verilator lint_on WIDTH
	     Se_arg_reg[p]<='z;
	 end
	 P_en_reg<=16'b1;
         expA_reg<=0;
         expB_reg<=0;
         A_h_reg<=1'b0;
         B_h_reg<=1'b0;
	 exact_reg<=1'b0;
	 perform_stage<=1'b0;
	 cnt<=5'h1f;
	 rdy<=1'b1;
         rdy_cnt<=15'b0;
	 digits<=68'b0;
	 type_reg<=3'b0;
	 isrnd_even<=1'b1;
	 isrnd_zero<=1'b0;
	 isrnd_plus<=1'b0;
	 out_en<=1'b0;
	 nsignA_reg<=1'b1;
	 nsignB_reg<=1'b1;
         is_root_reg<=1'b1;
	 reg_out<=9'b0;
	 outII_out<=10'b0;
	 oper_out<=13'b0;
     end else if (start_process) begin
	 if (is_root) begin
	     inv_bits<={minus_norm[55:-1]};
	     P<={8'hff,64'hffff_ffff_ffff_ffff,56'hffff_ffff_ffff_ff,minus_norm[63:56]};
	     for(p=1;p<16;p=p+1) begin
                 Se[p]<=72'b0;
                 SeA[p]<=0;
                 SeB[p]<=1'b0;
		 //verilator lint_off WIDTH
                 Se_arg2_reg[p]<=p*p;
		 //verilator lint_on WIDTH
                 Se_arg_reg[p]<=8'b0;
             end
         end else begin
             P<={2'b11,minus_norm[63:0],64'hffff_ffff_ffff_ffff,6'h3f};
             {SeA[1],Se[1][63:51]}<={1'b0,4'b0,normB[64:1]};
             {SeA[2],Se[2][63:51]}<={1'b0,3'b0,normB[64:1],1'b0};
             {SeA[4],Se[4][63:51]}<={1'b0,2'b0,normB[64:1],2'b0};
             {SeA[8],Se[8][63:51]}<={1'b0,1'b0,normB[64:1],3'b0};
             {SeA[3],Se[3][63:51]}<={1'b0,normB_11};
             {SeA[6],Se[6][63:51]}<={1'b0,normB_11[66:0],1'b0};
             {SeA[12],Se[12][63:51]}<={1'b0,normB_11[65:0],2'b0};
             {SeA[5],Se[5][63:51]}<={1'b0,normB_101};
             {SeA[10],Se[10][63:51]}<={1'b0,normB_101[66:0],1'b0};
             {SeA[9],Se[9][63:51]}<={1'b0,normB_1001};
             {SeA[7],Se[7][63:51]}<={1'b0,normB_111};
             {SeA[14],Se[14][63:51]}<={1'b0,normB_111[66:0],1'b0};
             {SeA[11],Se[11][63:51]}<={1'b0,normB_1011};
             {SeA[13],Se[13][63:51]}<={1'b0,normB_1101};
             {SeA[15],Se[15][63:51]}<={1'b0,normB_1111};

	     for(p=1;p<16;p=p+1) begin
		 Se[p][52:-8]<=61'b0;
		 SeB[p]<=1'b0;
                 Se_arg2_reg[p]<=14'b0;
                 Se_arg_reg[p]<=8'b0;
             end
         end
	 P_en_reg<=16'b1;
         expA_reg<=expA;
         expB_reg<=expB;
         A_h_reg<=A_h;
         B_h_reg<=B_h;
	 exact_reg<=1'b0;
	 perform_stage<=1'b1;
	 cnt<=step_cnt;
	 rdy<=1'b0;
         rdy_cnt<=15'b0;
	 digits<=68'b0;
	 type_reg<=type_==3 ? 1 : type_;//int=EXT
	 nsignA_reg<=nsignA;
	 nsignB_reg<=nsignB;
	 is_root_reg<=is_root;
	 reg_out<=reg_in;
	 outII_out<=outII_in;
	 oper_out<=oper_in;
         case(rmode)
          ROUND_TRUNC: begin isrnd_even<=1'b0; isrnd_zero<=1'b1; isrnd_plus<=1'b0; end
          ROUND_ROUND: begin isrnd_even<=1'b0; isrnd_zero<=1'b0; isrnd_plus<=1'b0; end
          ROUND_EVEN : begin isrnd_even<=1'b1; isrnd_zero<=1'b0; isrnd_plus<=1'b0; end
          ROUND_PLUS : begin isrnd_even<=1'b0; isrnd_zero<=!(is_root||nsignA^~nsignB); isrnd_plus<=1'b0; end
          ROUND_MINUS: begin isrnd_even<=1'b0; isrnd_zero<=(is_root||nsignA^~nsignB); isrnd_plus<=1'b0; end
          ROUND_UP   : begin isrnd_even<=1'b0; isrnd_zero<=!(is_root||nsignA^~nsignB); isrnd_plus<=(is_root||nsignA^~nsignB); end
          ROUND_DOWN : begin isrnd_even<=1'b0; isrnd_zero<=(is_root||nsignA^~nsignB); isrnd_plus<=!(is_root||nsignA^~nsignB); end
         endcase
	 if (type_==3) begin
             begin isrnd_even<=1'b0; isrnd_zero<=1'b1; isrnd_plus<=1'b0; end//int=round_trunc
	 end
     end else if (perform_stage && is_root_reg) begin
	 inv_bits<={inv_bits[47:-1],8'hff};
	 P<={P_d[127:0],inv_bits[55:48]};
	 for(p=1;p<16;p=p+1) begin
	     Se[p]<=Se_d[p];
	     Se_arg2_reg[p]<=Se_arg2[p];
	     Se_arg_reg[p]<=Se_arg[p];
	     //Se[p][3:-8]<=Se_d[p];
	 end
	 exact_reg<=exact_reg|exact_result;
	 P_en_reg<=P_en;
	 cnt<=cnt_d;
	 if (!|cnt) perform_stage<=1'b0;
	// if (out_en&out_can) rdy<=1'b1;
	 digits<={digits[63:0],new_digit};
     end else if (perform_stage && ~is_root_reg) begin
	 //inv_bits<={inv_bits[51:-1],4'h00};
	 P<=P_d;
	 for(p=1;p<16;p=p+1) begin
	     {SeA[p],Se[p],SeB[p]}<={SeA[p],Se[p],SeB[p]}>>4;
	 end
	 exact_reg<=exact_reg|exact_result;
	 P_en_reg<=P_en;
	 cnt<=cnt_d;
	 if (!|cnt) perform_stage<=1'b0;
	// if (out_en&out_can) rdy<=1'b1;
	 digits<={digits[63:0],new_digit};
     end
     if ({27'b0,cnt}==(2+1+{31'b0,(type_reg!=2)}) && perform_stage && ~rst) begin
         out_en<=1'b1;
     end else begin
         if (rst|out_can) begin
             out_en<=1'b0;
             P<='z;
	     for(p=1;p<16;p=p+1) begin
	         Se[p]<='z;
		     //verilator lint_off WIDTH
	         Se_arg2_reg[p]<=p*p;
		     //verilator lint_on WIDTH
	         Se_arg_reg[p]<='z;
	     end
         end
     end
     if (rdy0_reg2) rdy_cnt<=15'b1;
     else rdy_cnt<={rdy_cnt[13:0],1'b0};
     rdy<=rdy_cnt[14];
      

 end
endmodule
