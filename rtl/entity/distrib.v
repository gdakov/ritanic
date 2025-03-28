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


module distrib(
  clk,
  rst,
  is_vec,
  is_vec_other,
  stall,
  alu,
  shift,
  load,
  store,
  storeI,//16,8 bit and/or misaligned
  storeL,//base+index
  fpu,
  load_fpu,
  mul,
  pos0,
  pos1,
  pos2,
  pos3,
  pos4,
  pos5,
  pos6,
  pos7,
  pos8,
  sto0,
  sto1,
  sto2,
  stol0,
  stol1,
  stol2,
  stoA,
  stoB,
  altRs,
  lsi0,
  lsi1,
  lsi2,
  lsi3,
  lsi4,
  lsi5,
  wrt0,
  wrt1,
  wrt2
  );
  
  localparam WIDTH=10;
  localparam POS_WIDTH=10;
  
  input pwire clk;
  input pwire rst;
  input pwire is_vec;
  input pwire [1:0] is_vec_other;
  input pwire stall;
  input pwire [WIDTH-1:0] alu;
  input pwire [WIDTH-1:0] shift;
  input pwire [WIDTH-1:0] load;
  input pwire [WIDTH-1:0] store;
  input pwire [WIDTH-1:0] storeI;
  input pwire [WIDTH-1:0] storeL;
  input pwire [WIDTH-1:0] fpu;
  input pwire [WIDTH-1:0] load_fpu;
  input pwire [WIDTH-1:0] mul;
  
  output pwire [POS_WIDTH-1:0] pos0;
  output pwire [POS_WIDTH-1:0] pos1;
  output pwire [POS_WIDTH-1:0] pos2;
  output pwire [POS_WIDTH-1:0] pos3;
  output pwire [POS_WIDTH-1:0] pos4;
  output pwire [POS_WIDTH-1:0] pos5;
  output pwire [POS_WIDTH-1:0] pos6;
  output pwire [POS_WIDTH-1:0] pos7;
  output pwire [POS_WIDTH-1:0] pos8;

  output pwire sto0,sto1,sto2;
  output pwire stol0,stol1,stol2;
  output pwire [9:0] stoA;
  output pwire [9:0] stoB;
  
  output pwire [2:0] altRs;

  output pwire [5:0] lsi0;
  output pwire [5:0] lsi1;
  output pwire [5:0] lsi2;
  output pwire [5:0] lsi3;
  output pwire [5:0] lsi4;
  output pwire [5:0] lsi5;

  output pwire [5:0] wrt0;
  output pwire [5:0] wrt1;
  output pwire [5:0] wrt2;
  
  pwire nmul;
  
  pwire [10:0] load_cnt;
  pwire [10:0] alu_cnt;
  pwire [10:0] shift_cnt;
  pwire [10:0] lsa_cnt;
  pwire [10:0] store_cnt;
  pwire [10:1] store_cnt_or_more;
  pwire [10:1] load_cnt_or_more;
  pwire [9:0] ldst_cnt_or_less;
  pwire [10:1] alu_cnt_or_more;
  pwire [10:0] ldst_cnt;
  pwire [10:1] shift_cnt_or_more;
  pwire [9:0] lsa_cnt_or_less;
  pwire [9:0] alu_cnt_or_less;
  pwire [10:1] ldst_cnt_or_more;
  pwire [9:0] load_cnt_or_less;
  pwire [9:0] store_cnt_or_less;
  pwire [9:0] shift_cnt_or_less;


  pwire [9:-1][10:0] load_cntA;
  pwire [9:-1][10:0] alu_cntA;
  pwire [9:-1][10:0] shift_cntA;
  pwire [9:-1][10:0] store_cntA;
  pwire [9:-1][10:0] ldst_cntA;
  

  pwire [9:0][POS_WIDTH-1:0] load_index;
  pwire [9:0][POS_WIDTH-1:0] alu_index;
  pwire [9:0][POS_WIDTH-1:0] shift_index;
  pwire [9:0][POS_WIDTH-1:0] store_index;
  
  pwire [POS_WIDTH-1:0] mul_index;
 
  pwire stol;
  pwire fmem;
  
  pwire sto0H,sto1H,sto2H;
  
  pwire [2:0] ldpos;
  pwire [2:0] lpos;
  pwire [2:0] lpos_d;
  pwire [2:0] shpos;
  pwire [2:0] shpos_d;
  pwire [3:0] shpos_cnt;

  pwire [WIDTH-1:0] storeI_reg;

  pwire [2:0] altRs0;
  
  pwire [POS_WIDTH-1:0] posA0;
  pwire [POS_WIDTH-1:0] posA1;
  pwire [POS_WIDTH-1:0] posA2;
  pwire [POS_WIDTH-1:0] posA3;
  pwire [POS_WIDTH-1:0] posA4;
  pwire [POS_WIDTH-1:0] posA5;
  pwire [POS_WIDTH-1:0] posA6;
  pwire [POS_WIDTH-1:0] posA7;
  pwire [POS_WIDTH-1:0] posA8;

  pwire [POS_WIDTH-1:0] posB0;
  pwire [POS_WIDTH-1:0] posB1;
  pwire [POS_WIDTH-1:0] posB2;
  pwire [POS_WIDTH-1:0] posB3;
  pwire [POS_WIDTH-1:0] posB4;
  pwire [POS_WIDTH-1:0] posB5;
  pwire [POS_WIDTH-1:0] posB6;
  pwire [POS_WIDTH-1:0] posB7;
  pwire [POS_WIDTH-1:0] posB8;
  
  
  pwire [POS_WIDTH-1:0] posC0;
  pwire [POS_WIDTH-1:0] posC1;
  pwire [POS_WIDTH-1:0] posC2;
  pwire [POS_WIDTH-1:0] posC3;
  pwire [POS_WIDTH-1:0] posC4;
  pwire [POS_WIDTH-1:0] posC5;
  pwire [POS_WIDTH-1:0] posC6;
  pwire [POS_WIDTH-1:0] posC7;
  pwire [POS_WIDTH-1:0] posC8;

  pwire [POS_WIDTH-1:0] posD0;
  pwire [POS_WIDTH-1:0] posD1;
  pwire [POS_WIDTH-1:0] posD2;
  pwire [POS_WIDTH-1:0] posD3;
  pwire [POS_WIDTH-1:0] posD4;
  pwire [POS_WIDTH-1:0] posD5;
  pwire [POS_WIDTH-1:0] posD6;
  pwire [POS_WIDTH-1:0] posD7;
  pwire [POS_WIDTH-1:0] posD8;

  pwire [POS_WIDTH-1:0] posH0;
  pwire [POS_WIDTH-1:0] posH1;
  pwire [POS_WIDTH-1:0] posH2;
  pwire [POS_WIDTH-1:0] posH3;
  pwire [POS_WIDTH-1:0] posH4;
  pwire [POS_WIDTH-1:0] posH5;
  pwire [POS_WIDTH-1:0] posH6;
  pwire [POS_WIDTH-1:0] posH7;
  pwire [POS_WIDTH-1:0] posH8;

  pwire [5:0] lsiH0;
  pwire [5:0] lsiH1;
  pwire [5:0] lsiH2;
  pwire [5:0] lsiH3;
  pwire [5:0] lsiH4;
  pwire [5:0] lsiH5;

  pwire [5:0] lsiA0;
  pwire [5:0] lsiA1;
  pwire [5:0] lsiA2;
  pwire [5:0] lsiA3;
  pwire [5:0] lsiA4;
  pwire [5:0] lsiA5;

  pwire [5:0] lsiB0;
  pwire [5:0] lsiB1;
  pwire [5:0] lsiB2;
  pwire [5:0] lsiB3;
  pwire [5:0] lsiB4;
  pwire [5:0] lsiB5;

  pwire [5:0] lsiC0;
  pwire [5:0] lsiC1;
  pwire [5:0] lsiC2;
  pwire [5:0] lsiC3;
  pwire [5:0] lsiC4;
  pwire [5:0] lsiC5;

  pwire [5:0] lsiD0;
  pwire [5:0] lsiD1;
  pwire [5:0] lsiD2;
  pwire [5:0] lsiD3;
  pwire [5:0] lsiD4;
  pwire [5:0] lsiD5;

  pwire [5:0] lsi_P0;
  pwire [5:0] lsi_P1;
  pwire [5:0] lsi_P2;
  pwire [5:0] lsi_Q0;
  pwire [5:0] lsi_Q1;
  pwire [5:0] lsi_Q2;
  pwire [5:0] lsi_Q3;
  pwire [5:0] lsi_Q4;
  pwire [5:0] lsi_Q5;
 
  integer n;
  
  generate
      genvar k,j;
      for(k=0;k<10;k=k+1) begin : indices_gen
          popcnt10 load_mod(load & ((10'd2<<k)-10'd1),load_cntA[k]);
          popcnt10 alu_mod(alu & ((10'd2<<k)-10'd1),alu_cntA[k]);
          popcnt10 shift_mod(shift & ((10'd2<<k)-10'd1),shift_cntA[k]);
          popcnt10 store_mod(store & ((10'd2<<k)-10'd1),store_cntA[k]);
          popcnt10 ldst_mod((load|store) & ((10'd2<<k)-10'd1),ldst_cntA[k]);
          for (j=0;j<10;j=j+1) begin
              assign load_index[j][k]=load_cntA[k][j+1]&load_cntA[k-1][j] || load_cnt_or_less[j];
              assign alu_index[j][k]=alu_cntA[k][j+1]&alu_cntA[k-1][j] || alu_cnt_or_less[j];
              assign shift_index[j][k]=shift_cntA[k][j+1]&shift_cntA[k-1][j] || shift_cnt_or_less[j];
              assign store_index[j][k]=store_cntA[k][j+1]&store_cntA[k-1][j] || store_cnt_or_less[j];
          end
          assign wrt0=(store_cntA[k][1] && store_cntA[k-1][0]) ? ldst_cntA[k][6:1]<<is_vec_other[0] : 6'bz;
          assign wrt1=(store_cntA[k][{~is_vec,is_vec}] && store_cntA[k-1][~is_vec]) ? ldst_cntA[k][6:1]<<is_vec_other[1] : 6'bz;
          assign wrt2=(store_cntA[k][3] && store_cntA[k-1][2]) ? ldst_cntA[k][6:1] : 6'bz;
          assign lsi_P0=(store_index[0][k] && ~store_index[0][k^1]) ? ldst_cntA[k][6:1]<<is_vec_other[0] : 6'bz;
          assign lsi_P1=(store_index[~is_vec][k] && ~store_index[~is_vec][k^1]) ? ldst_cntA[k][6:1]<<is_vec_other[1] : 6'bz;
          assign lsi_P2=(store_index[2][k] && ~store_index[2][k^1]) ? ldst_cntA[k][6:1] : 6'bz;
          assign lsi_Q0=(load_index[0][k] && ~load_index[0][k^1]) ? ldst_cntA[k][6:1] : 6'bz;
          assign lsi_Q1=(load_index[1][k] && ~load_index[1][k^1]) ? ldst_cntA[k][6:1] : 6'bz;
          assign lsi_Q2=(load_index[2][k] && ~load_index[2][k^1]) ? ldst_cntA[k][6:1] : 6'bz;
          assign lsi_Q3=(load_index[3][k] && ~load_index[3][k^1]) ? ldst_cntA[k][6:1] : 6'bz;
          assign lsi_Q4=(load_index[4][k] && ~load_index[4][k^1]) ? ldst_cntA[k][6:1] : 6'bz;
          assign lsi_Q5=(load_index[5][k] && ~load_index[5][k^1]) ? ldst_cntA[k][6:1] : 6'bz;
      end
  endgenerate
  
  assign load_cntA[-1]=11'd1;
  assign shift_cntA[-1]=11'd1;
  assign alu_cntA[-1]=11'd1;
  assign store_cntA[-1]=11'd1;
  assign ldst_cntA[-1]=11'd1;

  assign lsi_P0=store_cnt_or_less[0] ? 6'h3f : 6'bz;
  assign lsi_P1=store_cnt_or_less[~is_vec] ? 6'h3f : 6'bz;
  assign lsi_P2=store_cnt_or_less[2] ? 6'h3f : 6'bz;
  assign lsi_Q0=load_cnt_or_less[0]  ? 6'h3f : 6'bz;
  assign lsi_Q1=load_cnt_or_less[1]  ? 6'h3f : 6'bz;
  assign lsi_Q2=load_cnt_or_less[2]  ? 6'h3f : 6'bz;
  assign lsi_Q3=load_cnt_or_less[3]  ? 6'h3f : 6'bz;
  assign lsi_Q4=load_cnt_or_less[4]  ? 6'h3f : 6'bz;
  assign lsi_Q5=load_cnt_or_less[5]  ? 6'h3f : 6'bz;

  assign wrt0=store_cnt_or_less[0] ?  6'b111111 : 6'bz;
  assign wrt1=store_cnt_or_less[~is_vec] ?  6'b111111 : 6'bz;
  assign wrt2=store_cnt_or_less[2] ?  6'b111111 : 6'bz;
   
  assign {stol2,stol1,stol0}=(nmul & stol) ? {ldpos[1],ldpos[2],ldpos[0]} : 3'BZ;
  assign {stol2,stol1,stol0}=(~nmul & stol) ? 3'b001 : 3'BZ;
  assign {stol2,stol1,stol0}=(~stol) ? 3'b0 : 3'BZ;
  
  assign {sto2,sto1,sto0}=(nmul & ldpos[0]) ? {sto2H,sto1H,sto0H} : 3'bz;
  assign {sto2,sto1,sto0}=(nmul & ldpos[1]) ? {sto0H,sto2H,sto1H} : 3'bz;
  assign {sto2,sto1,sto0}=(nmul & ldpos[2]) ? {sto1H,sto0H,sto2H} : 3'bz;
  assign {sto2,sto1,sto0}=(~nmul) ? {sto2H,sto1H,sto0H} : 3'bz;

  assign altRs={sto2,sto1,sto0}|{stol2,stol1,stol0}; 

  assign stoA=(stol & sto1H) ? posH1 : 10'h3ff;
  assign stoB=(stol & sto2H) ? posH2 : 10'h3ff;

  assign {lsi2,lsi1,lsi0}=(nmul & ldpos[0]) ? {lsiH2,lsiH1,lsiH0} : 18'BZ;
  assign {lsi2,lsi1,lsi0}=(nmul & ldpos[1]) ? {lsiH0,lsiH2,lsiH1} : 18'BZ;
  assign {lsi2,lsi1,lsi0}=(nmul & ldpos[2]) ? {lsiH1,lsiH0,lsiH2} : 18'BZ;
  assign {lsi2,lsi1,lsi0}=(~nmul) ? {lsiH2,lsiH1,lsiH0} : 18'BZ;

  assign {lsi5,lsi4,lsi3}=(nmul & ldpos[0]) ? {lsiH5,lsiH4,lsiH3} : 18'BZ;
  assign {lsi5,lsi4,lsi3}=(nmul & ldpos[1]) ? {lsiH3,lsiH5,lsiH4} : 18'BZ;
  assign {lsi5,lsi4,lsi3}=(nmul & ldpos[2]) ? {lsiH4,lsiH3,lsiH5} : 18'BZ;
  assign {lsi5,lsi4,lsi3}=(~nmul) ? {lsiH5,lsiH4,lsiH3} : 18'BZ;
  
 
  assign {pos2,pos1,pos0}=(nmul & ldpos[0]) ? {posH2,posH1,posH0} : {3*POS_WIDTH{1'BZ}};
  assign {pos2,pos1,pos0}=(nmul & ldpos[1]) ? {posH0,posH2,posH1} : {3*POS_WIDTH{1'BZ}};
  assign {pos2,pos1,pos0}=(nmul & ldpos[2]) ? {posH1,posH0,posH2} : {3*POS_WIDTH{1'BZ}};
  assign {pos2,pos1,pos0}=(~nmul) ? {posH2,posH1,posH0} : {3*POS_WIDTH{1'BZ}};

  assign {pos5,pos4,pos3}=(nmul & ldpos[0]) ? {posH5,posH4,posH3} : {3*POS_WIDTH{1'BZ}};
  assign {pos5,pos4,pos3}=(nmul & ldpos[1]) ? {posH3,posH5,posH4} : {3*POS_WIDTH{1'BZ}};
  assign {pos5,pos4,pos3}=(nmul & ldpos[2]) ? {posH4,posH3,posH5} : {3*POS_WIDTH{1'BZ}};
  assign {pos5,pos4,pos3}=(~nmul) ? {posH5,posH4,posH3} : {3*POS_WIDTH{1'BZ}};

  assign {pos8,pos7,pos6}=(nmul & shpos[0]) ? {posH8,posH7,posH6} : {3*POS_WIDTH{1'BZ}};
  assign {pos8,pos7,pos6}=(nmul & shpos[1]) ? {posH6,posH8,posH7} : {3*POS_WIDTH{1'BZ}};
  assign {pos8,pos7,pos6}=(nmul & shpos[2]) ? {posH7,posH6,posH8} : {3*POS_WIDTH{1'BZ}};
  assign {pos8,pos7,pos6}=(~nmul) ? {posH8,posH7,posH6} : {3*POS_WIDTH{1'BZ}};

  popcnt3 shpos_mod({&posH8[1:0],&posH7[1:0],&posH6[1:0]},shpos_cnt);

  assign posH0=posA0;

  assign posH1=posA1;

  assign posH2=posA2 : 'z;

  assign posH3=mulx[0] ? posA3 : 'z;
  assign posH3=mulx[1] ? posB3 : 'z;
  assign posH3=mulx[2] ? posC3 : 'z;

  assign posH4=mulx[0] ? posA4 : 'z;
  assign posH4=mulx[1] ? posB4 : 'z;
  assign posH4=mulx[2] ? posC4 : 'z;

  assign posH5=mulx[0] ? posA5 : 'z;
  assign posH5=mulx[1] ? posB5 : 'z;
  assign posH5=mulx[2] ? posC5 : 'z;

  assign posH6=mulx[0] ? posA6 : 'z;
  assign posH6=mulx[1] ? posB6 : 'z;
  assign posH6=mulx[2] ? posC6 : 'z;

  assign posH7=mulx[0] ? posA7 : 'z;
  assign posH7=mulx[1] ? posB7 : 'z;
  assign posH7=mulx[2] ? posC7 : 'z;

  assign posH8=mulx[0] ? posA8 : 'z;
  assign posH8=mulx[1] ? posB8 : 'z;
  assign posH8=mulx[2] ? posC8 : 'z;


  assign posA0=store_cnt_or_more[1] ? store_index[0] : 'z;
  assign posA1=store_cnt_or_more[2] ? store_index[1] : 'z;
  assign posA2=store_cnt_or_more[3] ? store_index[2] : 'z;
  
  assign posA0=store_cnt[0] ? load_index[0] : 'z;
  assign posA1=store_cnt[0] ? load_index[1] : 'z;
  assign posA2=store_cnt[0] ? load_index[2] : 'z;

  assign posA1=store_cnt[1] ? load_index[0] : 'z;
  assign posA2=store_cnt[1] ? load_index[1] : 'z;

  assign posA2=store_cnt[2] ? load_index[0] : 'z;

  assign posB0=posA0;
  assign posB1=posA1;
  assign posB2=posA2;

  assign posC0=posA0;
  assign posC1=posA1;
  assign posC2=posA2;
  

  assign posA3=(load_cnt_or_more[4]) ? load_index[3] : 'z;
  assign posA4=(load_cnt_or_more[5]) ? load_index[4] : 'z;
  assign posA5=(load_cnt_or_more[6]) ? load_index[5] : 'z;

  assign posB4=(load_cnt_or_more[4]) ? load_index[3] : 'z;
  assign posB5=(load_cnt_or_more[5]) ? load_index[4] : 'z;





  


//alu
  assign posA3=(load_cnt_or_less[3] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;
  assign posA4=(load_cnt_or_less[3] & alu_cnt_or_more[2]) ? alu_index[1] : 'z;
  assign posA5=(load_cnt_or_less[3] & alu_cnt_or_more[3]) ? alu_index[2] : 'z;
  assign posA8=(load_cnt_or_less[3] & alu_cnt_or_more[4]) ? alu_index[3] : 'z;
  assign posA7=(load_cnt_or_less[3] & alu_cnt_or_more[5]) ? alu_index[4] : 'z;
  assign posA6=(load_cnt_or_less[3] & alu_cnt_or_more[6]) ? alu_index[5] : 'z;

  assign posC5=(load_cnt_or_less[3] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;

  assign posA4=(load_cnt[4] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;
  assign posA5=(load_cnt[4] & alu_cnt_or_more[2]) ? alu_index[1] : 'z;
  assign posA8=(load_cnt[4] & alu_cnt_or_more[3]) ? alu_index[2] : 'z;
  assign posA7=(load_cnt[4] & alu_cnt_or_more[4]) ? alu_index[3] : 'z;
  assign posA6=(load_cnt[4] & alu_cnt_or_more[5]) ? alu_index[4] : 'z;

  assign posC5=(load_cnt[4] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;

  assign posA5=(load_cnt[5] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;
  assign posA8=(load_cnt[5] & alu_cnt_or_more[2]) ? alu_index[1] : 'z;
  assign posA7=(load_cnt[5] & alu_cnt_or_more[3]) ? alu_index[2] : 'z;
  assign posA6=(load_cnt[5] & alu_cnt_or_more[4]) ? alu_index[3] : 'z;

  assign posA8=(load_cnt[6] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;
  assign posA7=(load_cnt[6] & alu_cnt_or_more[2]) ? alu_index[1] : 'z;
  assign posA6=(load_cnt[6] & alu_cnt_or_more[3]) ? alu_index[2] : 'z;

  assign posB4=(load_cnt_or_less[3] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;
  assign posB5=(load_cnt_or_less[3] & alu_cnt_or_more[2]) ? alu_index[1] : 'z;

  assign posB7=(load_cnt_or_less[3] & alu_cnt_or_more[4]) ? alu_index[3] : 'z;
  assign posB8=(load_cnt_or_less[3] & alu_cnt_or_more[5]) ? alu_index[4] : 'z;


  assign posB4=(load_cnt[3] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;
  assign posB5=(load_cnt[3] & alu_cnt_or_more[2]) ? alu_index[1] : 'z;
  assign posB7=(load_cnt[3] & alu_cnt_or_more[3]) ? alu_index[2] : 'z;
  assign posB8=(load_cnt[3] & alu_cnt_or_more[4]) ? alu_index[3] : 'z;


  assign posB5=(load_cnt[4] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;
  assign posB7=(load_cnt[4] & alu_cnt_or_more[2]) ? alu_index[1] : 'z;
  assign posB8=(load_cnt[4] & alu_cnt_or_more[3]) ? alu_index[2] : 'z;

  assign posB7=(load_cnt[5] & alu_cnt_or_more[1]) ? alu_index[0] : 'z;
  assign posB8=(load_cnt[5] & alu_cnt_or_more[2]) ? alu_index[1] : 'z;
  
  assign posB3={POS_WIDTH{1'B1}};
  assign posB6=mul_index[0];
  assign posC3={POS_WIDTH{1'B1}};
  assign posC4={POS_WIDTH{1'B1}};
  assign posC6=mul_index[0];
  assign posC7=mul_index[1];


//shift   
  assign posA6=shift_cnt_or_more[1] ? shift_index[0] : 'z;
  assign posA7=shift_cnt_or_more[2] ? shift_index[1] : 'z;
  assign posA8=shift_cnt_or_more[3] ? shift_index[2] : 'z;
  assign posA5=shift_cnt_or_more[4] ? shift_index[3] : 'z;
  assign posA4=shift_cnt_or_more[5] ? shift_index[4] : 'z;
  assign posA3=shift_cnt_or_more[6] ? shift_index[5] : 'z;

  assign posB7=shift_cnt_or_more[1] ? shift_index[0] : 'z;
  assign posB8=shift_cnt_or_more[2] ? shift_index[1] : 'z;

  assign posB5=shift_cnt_or_more[4] ? shift_index[3] : 'z;
  assign posB4=shift_cnt_or_more[5] ? shift_index[4] : 'z;
  assign posB3=shift_cnt_or_more[6] ? shift_index[5] : 'z;

  assign posC8=shift_cnt_or_more[1] ? shift_index[0] : 'z;
  assign posC4=shift_cnt_or_more[3] ? shift_index[2] : 'z;
  assign posC3=shift_cnt_or_more[4] ? shift_index[3] : 'z;

  assign posD7=shift_cnt_or_more[1] ? shift_index[0] : 'z;
  assign posD6=shift_cnt_or_more[2] ? shift_index[1] : 'z;
  assign posD4=shift_cnt_or_more[3] ? shift_index[2] : 'z;
  assign posD3=shift_cnt_or_more[4] ? shift_index[3] : 'z;
  

//holes -- needs total rewrite
  assign posA8=(fmem & lsa_cnt_or_less[8] & ~shift_cnt_or_more[1]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB8=(fmem & lsa_cnt_or_less[7] & ~shift_cnt_or_more[1]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA7=(fmem & lsa_cnt_or_less[7] & ~shift_cnt_or_more[2]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB7=(fmem & lsa_cnt_or_less[6] & ~shift_cnt_or_more[2]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posC7=(fmem & lsa_cnt_or_less[6] & ~shift_cnt_or_more[1]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posD7=(fmem & lsa_cnt_or_less[5] & ~shift_cnt_or_more[1]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA6=(fmem & lsa_cnt_or_less[6] & ~shift_cnt_or_more[3]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB6=(fmem & lsa_cnt_or_less[5] & ~shift_cnt_or_more[3]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posC6=(fmem & lsa_cnt_or_less[5] & ~shift_cnt_or_more[2]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posD6=(fmem & lsa_cnt_or_less[4] & ~shift_cnt_or_more[2]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA5=(fmem & lsa_cnt_or_less[5] & ~shift_cnt_or_more[4]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB5=(fmem & lsa_cnt_or_less[4] & ~shift_cnt_or_more[4]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA4=(fmem & lsa_cnt_or_less[4] & ~shift_cnt_or_more[5]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB4=(fmem & lsa_cnt_or_less[3] & ~shift_cnt_or_more[5]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posC4=(fmem & lsa_cnt_or_less[4] & ~shift_cnt_or_more[3]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posD4=(fmem & lsa_cnt_or_less[3] & ~shift_cnt_or_more[3]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA3=(fmem & lsa_cnt_or_less[3] & ~shift_cnt_or_more[6]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB3=(fmem & lsa_cnt_or_less[2] & ~shift_cnt_or_more[6]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posC3=(fmem & lsa_cnt_or_less[3] & ~shift_cnt_or_more[4]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posD3=(fmem & lsa_cnt_or_less[2] & ~shift_cnt_or_more[4]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA8=(~fmem & alu_cnt_or_less[5] & ~shift_cnt_or_more[1]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB8=(~fmem & alu_cnt_or_less[5] & ~shift_cnt_or_more[1]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA7=(~fmem & alu_cnt_or_less[4] & ~shift_cnt_or_more[2]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB7=(~fmem & alu_cnt_or_less[4] & ~shift_cnt_or_more[2]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posC7=(~fmem & alu_cnt_or_less[3] & ~shift_cnt_or_more[1]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posD7=(~fmem & alu_cnt_or_less[3] & ~shift_cnt_or_more[1]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA6=(~fmem & alu_cnt_or_less[3] & ~shift_cnt_or_more[3]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB6=(~fmem & alu_cnt_or_less[3] & ~shift_cnt_or_more[3]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posC6=(~fmem & alu_cnt_or_less[2] & ~shift_cnt_or_more[2]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posD6=(~fmem & alu_cnt_or_less[2] & ~shift_cnt_or_more[2]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA5=(~fmem & alu_cnt_or_less[2] & ~shift_cnt_or_more[4]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB5=(~fmem & alu_cnt_or_less[2] & ~shift_cnt_or_more[4]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA4=(~fmem & alu_cnt_or_less[1] & ~shift_cnt_or_more[5]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB4=(~fmem & alu_cnt_or_less[1] & ~shift_cnt_or_more[5]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posC4=(~fmem & alu_cnt_or_less[1] & ~shift_cnt_or_more[3]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posD4=(~fmem & alu_cnt_or_less[1] & ~shift_cnt_or_more[3]) ? {POS_WIDTH{1'B1}} : 'z;

  assign posA3=(~fmem & alu_cnt[0] & ~shift_cnt_or_more[6]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posB3=(~fmem & alu_cnt[0] & ~shift_cnt_or_more[6]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posC3=(~fmem & alu_cnt[0] & ~shift_cnt_or_more[4]) ? {POS_WIDTH{1'B1}} : 'z;
  assign posD3=(~fmem & alu_cnt[0] & ~shift_cnt_or_more[4]) ? {POS_WIDTH{1'B1}} : 'z;
//end holes and total rewrite section
  assign fmem=stol ? ldst_cnt_or_more[2] : ldst_cnt_or_more[3];
  assign stol=|{storeL,storeI};
  assign nmul=0==mul;
//sto and lsi needs total rewrite
  assign sto0H=stol ? 1'b0 : store_cnt_or_more[1];
  assign sto1H=stol ? store_cnt_or_more[1] : store_cnt_or_more[2];
  assign sto2H=stol ? store_cnt_or_more[2] : store_cnt_or_more[3];
  
  assign ldpos=(~stol & store_cnt[0]) ? lpos : 3'bz;
  assign ldpos=(~stol & store_cnt[1]) ? {lpos[0],lpos[2:1]} : 3'bz;
  assign ldpos=(~stol & store_cnt[2]) ? {lpos[1:0],lpos[2]} : 3'bz;
  assign ldpos=(~stol & store_cnt[3]) ? lpos : 3'bz;

  assign ldpos=(stol & store_cnt[1]) ? {lpos[1:0],lpos[2]} : 3'bz;
  assign ldpos=(stol & store_cnt[2]) ? lpos : 3'bz;

  assign lsiH0=(~stol & nmul ) ? lsiA0 : 'z;
  assign lsiH0=(stol & nmul  ) ? lsiB0 : 'z;
  assign lsiH0=(~stol & ~nmul) ? lsiC0 : 'z;
  assign lsiH0=(stol & ~nmul ) ? lsiD0 : 'z;

  assign lsiH1=(~stol & nmul ) ? lsiA1 : 'z;
  assign lsiH1=(stol & nmul  ) ? lsiB1 : 'z;
  assign lsiH1=(~stol & ~nmul) ? lsiC1 : 'z;
  assign lsiH1=(stol & ~nmul ) ? lsiD1 : 'z;

  assign lsiH2=(~stol & nmul ) ? lsiA2 : 'z;
  assign lsiH2=(stol & nmul  ) ? lsiB2 : 'z;
  assign lsiH2=(~stol & ~nmul) ? lsiC2 : 'z;
  assign lsiH2=(stol & ~nmul ) ? lsiD2 : 'z;

  assign lsiH3=(~stol & nmul ) ? lsiA3 : 'z;
  assign lsiH3=(stol & nmul  ) ? lsiB3 : 'z;
  assign lsiH3=(~stol & ~nmul) ? lsiC3 : 'z;
  assign lsiH3=(stol & ~nmul ) ? lsiD3 : 'z;

  assign lsiH4=(~stol & nmul ) ? lsiA4 : 'z;
  assign lsiH4=(stol & nmul  ) ? lsiB4 : 'z;
  assign lsiH4=(~stol & ~nmul) ? lsiC4 : 'z;
  assign lsiH4=(stol & ~nmul ) ? lsiD4 : 'z;

  assign lsiH5=(~stol & nmul ) ? lsiA5 : 'z;
  assign lsiH5=(stol & nmul  ) ? lsiB5 : 'z;
  assign lsiH5=(~stol & ~nmul) ? lsiC5 : 'z;
  assign lsiH5=(stol & ~nmul ) ? lsiD5 : 'z;

  assign lpos_d=(load_cnt[0]) ? lpos : 3'bz;
  assign lpos_d=(load_cnt[2]) ? {lpos[1:0],lpos[2]} : 3'bz;
  assign lpos_d=(load_cnt[1]) ? {lpos[0],lpos[2:1]} : 3'bz;
  assign lpos_d=(load_cnt[3]) ? lpos : 3'bz;
  assign lpos_d=(load_cnt[5]) ? {lpos[1:0],lpos[2]} : 3'bz;
  assign lpos_d=(load_cnt[4]) ? {lpos[0],lpos[2:1]} : 3'bz;
  assign lpos_d=(load_cnt[6]) ? lpos : 3'bz;
 
  assign shpos_d=shpos_cnt[0] ? shpos : 3'bz;
  assign shpos_d=shpos_cnt[2] ? {shpos[1:0],shpos[2]} : 3'bz;
  assign shpos_d=shpos_cnt[1] ? {shpos[0],shpos[2:1]} : 3'bz;
  assign shpos_d=shpos_cnt[3] ? shpos : 3'bz;
  
  
  assign lsiA0=store_cnt[{~is_vec,is_vec}] ? lsi_P0 : 6'bz; 
  assign lsiA1=store_cnt[{~is_vec,is_vec}] ? lsi_P1 : 6'bz; 
  assign lsiA2=store_cnt[{~is_vec,is_vec}] ? lsi_Q0 : 6'bz; 
  assign lsiA3=store_cnt[{~is_vec,is_vec}] ? lsi_Q1 : 6'bz; 
  assign lsiA4=store_cnt[{~is_vec,is_vec}] ? lsi_Q2 : 6'bz; 
  assign lsiA5=store_cnt[{~is_vec,is_vec}] ? lsi_Q3 : 6'bz; 
  
  assign lsiA0=store_cnt[1]&~is_vec ? lsi_P0 : 6'bz; 
  assign lsiA1=store_cnt[1]&~is_vec ? lsi_Q0 : 6'bz; 
  assign lsiA2=store_cnt[1]&~is_vec ? lsi_Q1 : 6'bz; 
  assign lsiA3=store_cnt[1]&~is_vec ? lsi_Q2 : 6'bz; 
  assign lsiA4=store_cnt[1]&~is_vec ? lsi_Q3 : 6'bz; 
  assign lsiA5=store_cnt[1]&~is_vec ? lsi_Q4 : 6'bz; 

  assign lsiA0=store_cnt[0] ? lsi_Q0 : 6'bz; 
  assign lsiA1=store_cnt[0] ? lsi_Q1 : 6'bz; 
  assign lsiA2=store_cnt[0] ? lsi_Q2 : 6'bz; 
  assign lsiA3=store_cnt[0] ? lsi_Q3 : 6'bz; 
  assign lsiA4=store_cnt[0] ? lsi_Q4 : 6'bz; 
  assign lsiA5=store_cnt[0] ? lsi_Q5 : 6'bz; 

  assign lsiB0=6'h1f; 
  assign lsiB1=lsiA0; 
  assign lsiB2=lsiA1; 
  assign lsiB3=lsiA2; 
  assign lsiB4=lsiA3; 
  assign lsiB5=lsiA4; 

  assign lsiC0=lsiA0; 
  assign lsiC1=lsiA1; 
  assign lsiC2=lsiA2; 
  assign lsiC3=lsiA3; 
  assign lsiC4=lsiA4; 
  assign lsiC5=6'h3f;

  assign lsiD0=6'h1f; 
  assign lsiD1=lsiA0; 
  assign lsiD2=lsiA1; 
  assign lsiD3=lsiA2; 
  assign lsiD4=lsiA3; 
  assign lsiD5=6'h3f; 
  
  popcnt10 load_mod(load,load_cnt);
  popcnt10 alu_mod(alu,alu_cnt);
  popcnt10 shift_mod(shift,shift_cnt);
  popcnt10 lsa_mod(load|shift|alu,lsa_cnt);
  popcnt10 store_mod(store,store_cnt);
  popcnt10_or_more store_more_mod(store,store_cnt_or_more);
  popcnt10_or_more load_more_mod(load,load_cnt_or_more);
  popcnt10_or_less ldst_less_mod(load|store,ldst_cnt_or_less);
  popcnt10_or_more alu_more_mod(alu,alu_cnt_or_more);
  popcnt10 ldst_mod(load|store,ldst_cnt);
  popcnt10_or_more shift_more_mod(shift,shift_cnt_or_more);
  popcnt10_or_less lsa_less_mod(load|store|alu,lsa_cnt_or_less);
  popcnt10_or_less alu_less_mod(alu,alu_cnt_or_less);
  popcnt10_or_more ldst_more_mod(load|store,ldst_cnt_or_more);
  popcnt10_or_less load_less_mod(load,load_cnt_or_less);
  popcnt10_or_less store_less_mod(store,store_cnt_or_less);
  popcnt10_or_less shift_less_mod(shift,shift_cnt_or_less);

  
  bit_find_first_bit #(POS_WIDTH) firstMul_mod(mul,mul_index,);
  
  always @(posedge clk) begin
      if (rst) begin
          lpos<=3'b001;
          shpos<=3'b001;
      end else if (~stall) begin
          lpos<=lpos_d;
          shpos<=shpos_d;
      end
  end
endmodule
