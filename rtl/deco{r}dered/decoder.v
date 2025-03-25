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
`include "../msrss_no.sv"

module decoder_permitted_i(
  branch,
  taken,
  indir,
  alu,
  shift,
  load,
  store,
  storeL,
  fma,
  mul,
  sys,
  pos0,
  FPU,
  spec,
  specNext,
  vec,
  iAvail,
  stall,
  halt,
  vec_mode,
  allret,
  perm
  );
  input [9:0] branch;
  input [9:0] taken;
  input [9:0] indir;
  input [9:0] alu;
  input [9:0] shift;
  input [9:0] load;
  input [9:0] store;
  input [9:0] storeL;
  input [9:0] fma;
  input [9:0] mul;
  input [9:0] sys;
  input [9:0] pos0;
  input [9:0] FPU;
  input [9:0] spec;
  input [9:0] specNext;
  input [9:0] vec;
  input [9:0] iAvail;
  input stall;
  input halt;
  input vec_mode;
  input allret;
  output [9:0] perm;

  wire [9:0][9:0] branch_cnt;
  wire [9:0][9:0] taken_cnt;
  wire [9:0][9:0] indir_cnt;
  wire [9:0][9:0] alu_cnt;
  wire [9:0][9:0] sysinstr_cnt;
  wire [9:0][9:0] shift_cnt;
  wire [9:0][9:0] load_cnt;
  wire [9:0][9:0] store_cnt;
  wire [9:0][10:0] mul_cnt;
  wire [9:0][10:1] mul_more_cnt;
  wire [9:0][9:0] lsas_cnt;
  wire [9:0][9:0] ldst_cnt;
  wire [9:0][9:0] alu_shift_cnt;
  wire [9:0][9:0] FPU_dke;
  wire [9:0][9:0] fma_dke;
  
  wire [9:0] storeL_has;
  wire [9:0] permA;

  wire [9:0] permB;
  wire [9:0] permC;

  wire [9:0] permX;
  
  generate
      genvar k;
      for(k=0;k<10;k=k+1) begin : cnt_gen
          popcnt10_or_less branch_mod(branch & ((10'd2<<k)-10'd1),branch_cnt[k]);
          popcnt10_or_less taken_mod(taken & ((10'd2<<k)-10'd1),taken_cnt[k]);
          popcnt10_or_less indir_mod(indir & ((10'd2<<k)-10'd1),indir_cnt[k]);
          popcnt10_or_less load_mod(load & ((10'd2<<k)-10'd1),load_cnt[k]);
          popcnt10_or_less alu_mod(alu & ((10'd2<<k)-10'd1),alu_cnt[k]);
          popcnt10_or_less sysinstr_mod(sys & ((10'd2<<k)-10'd1),sysinstr_cnt[k]);
          popcnt10_or_less aluf_mod(FPU & alu & ((10'd2<<k)-10'd1),FPU_dke[k]);
          popcnt10_or_less shift_mod(shift & ((10'd2<<k)-10'd1),shift_cnt[k]);
          popcnt10_or_less alu_shift_mod((alu|shift) & ((10'd2<<k)-10'd1),alu_shift_cnt[k]);
          popcnt10_or_less store_mod(store & ((10'd2<<k)-10'd1),store_cnt[k]);
          popcnt10_or_less ldst_mod((store|load) & ((10'd2<<k)-10'd1),ldst_cnt[k]);
          popcnt10 mul_mod(mul&~shift & ((10'd2<<k)-10'd1),mul_cnt[k]);
          popcnt10 mul_mod(fma & ((10'd2<<k)-10'd1),fma_dke[k]);
          popcnt10_or_more mul_more_mod(mul&~shift & ((10'd2<<k)-10'd1),mul_more_cnt[k]);
          popcnt10_or_more mulx_more_mod(mul&shift & ((10'd2<<k)-10'd1),mulx_more_cnt[k]);
          popcnt10_or_less lsas_mod((load|shift|alu|store) & ((10'd2<<k)-10'd1),lsas_cnt[k]);

          assign has_vec=|(vec & ((10'd2<<k)-10'd1)) || vec_mode;
          
          assign storeL_has[k]=(storeL & ((10'd2<<k)-10'd1))!=0;
          
          
          assign permA[k]=(~storeL_has[k] & mul_cnt[k][0]) ? load_cnt[k][6] & alu_cnt[k][6] & shift_cnt[k][3] & 
            store_cnt[k][{has_vec,~has_vec}] & ldst_cnt[k][5] & alu_shift_cnt[k][6] & lsas_cnt[k][9] : 1'bz; 
          assign permA[k]=(storeL_has[k] & mul_cnt[k][0]) ? load_cnt[k][5] & alu_cnt[k][6] & shift_cnt[k][3] & 
            store_cnt[k][{has_vec,~has_vec}] & ldst_cnt[k][1] & alu_shift_cnt[k][6] & lsas_cnt[k][8] : 1'bz; 
          assign permA[k]=(~storeL_has[k] & mul_cnt[k][1]) ? load_cnt[k][3] & alu_cnt[k][4] && shift_cnt[k][3] & 
            store_cnt[k][{has_vec,~has_vec}] & lsas_cnt[k][7] & alu_shift_cnt[k][4] & ldst_cnt[k][5] : 1'bz; 
          assign permA[k]=(storeL_has[k] && mul_cnt[k][1]) ? load_cnt[k][3] & alu_cnt[k][4] && shift_cnt[k][3] & 
            store_cnt[k][{has_vec,~has_vec}] & lsas_cnt[k][6] & alu_shift_cnt[k][4] & ldst_cnt[k][1]: 1'bz; 
          assign permA[k]=mul_more_cnt[k][2] ? 1'b0 : 1'bz;
          
          assign permB[k]=branch_cnt[k][2] & taken_cnt[k][1] & indir_cnt[k][1] & ~mulx_more_cnt[3];

          if (k<9) assign perm[k]=permX[k] && (fma_dke[k][0] | (permX[k+1] && fma_dke[k+1][2]) | fma_dke[k][2] | (k==0)) &&
              !spec[k] | permX[k+1];
          else  assign perm[k]=permX[k] && fma_dke[k][0] | fma_dke[k][2] && !spec[k];
          
          if (k>0)
              assign permC[k]=pos0[k]==0 && FPU_dke[k][4] && sysinstr_cnt[1];
          else
              assign permC[k]=(pos0[0] && allret)==0 && FPU_dke[k][4];
              //assign permC[k]=(pos0[0] && allret)==0 && FPU_dke[k][4];
      end
  endgenerate
  
//  assign permC[0]=~halt;
  
  assign permX=permA & permB & permC & iAvail & {10{~stall}};

endmodule


module decoder_aux_const(
  clk,
  rst,
  stall,
  fat_stall_en,
  cls_sys,
  instr0,
  aux_const,
  aux_can_jump,
  aux_can_read,
  aux_can_write,
  msrss_no,
  msrss_en,
  msrss_data,
  fpE_set,
  fpE_en,
  fpE_thr,
  altEn,
  altData,
  altThr2,
  altEn2,
  altData2,
  thread,
  riscmode,
  disstruss,
  thrmode,
  doStall);
 
  input clk;
  input rst;
  input stall;
  input [9:0] cls_sys;
  input [9:0][31:0] instr0; 
  output reg [64:0] aux_const;
  output reg aux_can_jump;
  output reg aux_can_read;
  output reg aux_can_write;
  input [15:0] msrss_no;
  input msrss_en;
  input [64:0] msrss_data;
  input [10:0] fpE_set;
  input fpE_en;
  input fpE_thr;
  input altEn;
  input [64:0] altData;
  input altThr2;
  input altEn2;
  input [16:0] altData2;
  input thread;
  output riscmode;
  output disstruss;
  output reg [1:0] thrmode;
  output doStall;

  wire [15:0] iconst[9:0];
  wire [9:0] cls_sys_first;
  wire cls_sys_has;
  wire [15:0] aux0;
  reg thread_reg;
  reg [15:0] aux0_reg;
  reg [1:0][63:0] csr_retIP;
  reg [1:0][64:0] csr_excStackSave;
  reg [1:0][64:0] csr_excStack;
  reg [1:0][64:0] csr_PCR;
  reg [1:0][64:0] csr_PCR_reg_save;
  reg [1:0][63:0] csr_mflags;
  reg [1:0][63:0] csr_fpu;
  reg [1:0][63:0] csr_page;
  reg [1:0][63:0] csr_vmpage;
  reg [1:0][63:0] csr_page0;
  reg [1:0][63:0] csr_vmpage0;
  reg [1:0][63:0] csr_excTbl;
  reg [1:0][63:0] csr_syscall;
  reg [1:0][63:0] csr_subsyscall;
  reg [1:0][63:0] csr_USER1;
  reg [1:0][63:0] csr_USER2;
  reg [1:0][63:0] csr_vmcall;
  reg [1:0][63:0] csr_cpage_mask;
  reg [1:0][63:0] csr_USER3;
  reg [1:0][63:0] csr_GORQ_send;
  reg [1:0][63:0] csr_GORQ_recv_vector;
  reg [1:0][63:0] csr_last_jmp;
  reg [1:0][63:0] csr_last_jmp2;
  reg [1:0][1:0] thrmode0;

  assign aux0=cls_sys_has ? 16'bz : 16'b0;

  generate
    genvar t;
    for(t=0;t<10;t=t+1) begin
        assign iconst[t]={thread,instr0[t][30:16]};
        assign aux0=cls_sys_first[t] ? iconst[t] : 16'bz;
    end
  endgenerate
  bit_find_first_bit #(10) cls_1_mod(cls_sys,cls_sys_first,cls_sys_has);

  always @* begin
      aux_can_jump=1'b0;
      aux_can_read=1'b1;
      aux_can_write=1'b1;
      case(aux0_reg[6:0])
      `csr_retIP: begin	aux_const={1'b0,csr_retIP[thread]}; 
          aux_can_jump=csr_mflags[thread][`mflags_priv]==2'b0;
          aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_excStackSave: begin aux_const=csr_excStackSave[thread];
          aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_excStack: begin aux_const=csr_excStack[thread];
          aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_PCR: begin	aux_const=csr_PCR[thread];
          aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_PCR_reg_save: begin aux_const= csr_PCR_reg_save[thread];
          aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_mflags: begin	aux_const={1'b0,csr_mflags[thread]}; aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_FPU:			aux_const={1'b0,csr_fpu[thread]};
      `csr_page: begin aux_const={1'b0,csr_page[thread]}; aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_vmpage: begin aux_const={1'b0,csr_vmpage[thread]}; aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_page0: begin aux_const={1'b0,csr_page0[thread]}; aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_vmpage0: begin aux_const={1'b0,csr_vmpage0[thread]}; aux_can_read=~csr_mflags[thread][`mflags_vm] && 0==csr_mflags[thread][`mflags_priv]; aux_can_write=aux_can_read; end
      `csr_syscall: begin aux_const={1'b0,csr_syscall[thread]};
           aux_can_jump=1'b1; 
           aux_can_read=~csr_mflags[thread][`mflags_vm] && csr_mflags[thread][`mflags_priv]==2'b00; aux_can_write=aux_can_read; end
      `csr_subsyscall: begin aux_const={1'b0,csr_subsyscall[thread]};
           aux_can_jump=csr_mflags[thread][`mflags_priv]==2'b11; 
           aux_can_read=~csr_mflags[thread][`mflags_vm] && csr_mflags[thread][`mflags_priv]==2'b00; aux_can_write=aux_can_read; end
      `csr_vmcall: begin aux_const={1'b0,csr_vmcall[thread]}; aux_can_jump=
	   csr_mflags[thread][`mflags_vm] && csr_mflags[thread][`mflags_priv]==2'b00;
           aux_can_read=~csr_mflags[thread][`mflags_vm] && csr_mflags[thread][`mflags_priv]==2'b00; aux_can_write=aux_can_read; end
      `csr_USER3: aux_const={1'b1,csr_indir_tbl[thread]}; 
      `csr_GORQ_recv_vector: aux_const={1'b0,csr_GORQ_recv_vector[thread]};
      `csr_USER1: aux_const={1'b1,csr_USER1[thread]};
      `csr_USER2: aux_const={1'b1,csr_USER2[thread]};
      `csr_vlen: aux_const={1'b0,64'd32};
      `csr_last_jmp: aux_const={1'b0,csr_last_jmp[thread]};
      `csr_last_jmp2: aux_const={1'b0,csr_last_jmp2[thread]};
      `csr_cl_lock: begin aux_const={64'b0,csr_mflags[thread][18]}; end
      default:			aux_const=65'b0;
      endcase
      thrmode=thrmode0[thread];
  end

  assign riscmode=csr_mflags[thread][21];
  assign disstruss=csr_mflags[thread][22];

  assign doStall=msrss_en && msrss_addr==`csr_pinvoke && ~thread && fat_stall_en;

  always @(posedge clk) begin
      if (rst) begin
          csr_retIP[0]<=64'b0;
	  csr_excStackSave[0]<=65'b0;
	  csr_excStack[0]<=65'b0;
	  csr_PCR[0]<=65'b0;
	  csr_PCR_reg_save[0]<=65'b0;
          csr_mflags[0]<=64'b0;
	  aux0_reg<=16'b0;
	  csr_fpu[0]<=64'h20000;
          csr_page[0]<=64'b0;
          csr_vmpage[0]<=64'b0;
          csr_page0[0]<=64'b0;
          csr_vmpage0[0]<=64'b0;
          csr_cpage[0]<=64'b0;
          csr_spage[0]<=64'b0;
          csr_syscall[0]<=64'b0;
          csr_subsyscall[0]<=64'b0;
          csr_vmcall[0]<=64'b0;
          csr_cpage_mask[0]<=64'b0;
          csr_USER3[0]<=64'b0;
          csr_retIP[1]<=64'b0;
	  csr_excStackSave[1]<=65'b0;
	  csr_excStack[1]<=65'b0;
	  csr_PCR[1]<=65'b0;
	  csr_PCR_reg_save[1]<=65'b0;
          csr_mflags[1]<=64'b0;
	  csr_fpu[1]<=64'h20000;
          csr_page[1]<=64'b0;
          csr_vmpage[1]<=64'b0;
          csr_page0[1]<=64'b0;
          csr_vmpage0[1]<=64'b0;
          csr_cpage[1]<=64'b0;
          csr_spage[1]<=64'b0;
          csr_syscall[1]<=64'b0;
          csr_subsyscall[1]<=64'b0;
          csr_vmcall[1]<=64'b0;
          csr_cpage_mask[1]<=64'b0;
          csr_USER3[1]<=64'b0;
          csr_GORQ_send[0]<=64'b0;
          csr_GORQ_send[1]<=64'b0;
          csr_USER1[0]<=64'b0;
          csr_USER1[1]<=64'b0;
          csr_USER2[0]<=64'b0;
          csr_USER2[1]<=64'b0;
          csr_last_jmp[0]<=64'b0;
          csr_last_jmp2[0]<=64'b0;
          csr_last_jmp[1]<=64'b0;
          csr_last_jmp2[1]<=64'b0;
          thread_reg<=1'b0;
          thrmode0[0]<=2'b0;
          thrmode0[1]<=2'b0;
      end else begin
          if (!stall & !doStall) thread_reg<=thread;
          if (msrss_en && ((csr_mflags[msrss_no[15]][`mflags_priv]==2'b0 && ~csr_mflags[msrss_no[15]][`mflags_vm]) ||
            msrss_no==`csr_FPU || msrss_no==`csr_pinvoke || msrss_no[14:0]==`csr_pkill)) begin
              case(msrss_no[14:0])
      `csr_retIP: 		csr_retIP[msrss_no[15]]<=msrss_data[63:0];
      `csr_excStackSave: 	csr_excStackSave[msrss_no[15]]<=msrss_data;
      `csr_excStack: 		csr_excStack[msrss_no[15]]<=msrss_data;
      `csr_PCR: 		csr_PCR[msrss_no[15]]<=msrss_data;
      `csr_PCR_reg_save:	csr_PCR_reg_save[msrss_no[15]]<=msrss_data;
      `csr_mflags:		csr_mflags[msrss_no[15]]<=msrss_data[63:0];
      `csr_USER1:		csr_USER1[msrss_no[15]]<=msrss_data[63:0];
      `csr_USER2:		csr_USER2[msrss_no[15]]<=msrss_data[63:0];
      `csr_GORQ_send:		csr_GORQ_send[msrss_no[15]]<=msrss_data[63:0];
      `csr_FPU:			csr_fpu[msrss_no[15]]<=msrss_data[63:0];
      `csr_excpt_fpu:		csr_fpu[msrss_no[15]][10:0]<=msrss_data[10:0];
      `csr_page:		csr_page[msrss_no[15]]<=msrss_data[63:0];
      `csr_vmpage:		csr_vmpage[msrss_no[15]]<=msrss_data[63:0];
      `csr_page0:		csr_page0[msrss_no[15]]<=msrss_data[63:0];
      `csr_vmpage0:		csr_vmpage0[msrss_no[15]]<=msrss_data[63:0];
      `csr_syscall:		csr_syscall[msrss_no[15]]<=msrss_data[63:0];
      `csr_subsyscall:		csr_subsyscall[msrss_no[15]]<=msrss_data[63:0];
      `csr_vmcall:		csr_vmcall[msrss_no[15]]<=msrss_data[63:0];
      `csr_USER3:		csr_USER3[msrss_no[15]]<=msrss_data[63:0];
      `csr_last_jmp: begin csr_last_jmp[msrss_no[15]]<=msrss_data[63:0]; csr_last_jmp2[msrss_no[15]]<=csr_last_jmp[msrss_no[15]]; end
      `csr_pinvoke:		if (!thread) thrmode0[0]<=thrmode0[0]+3'b1;
      `csr_pkill:		if (thread) thrmode0[1]<=thrmode0[1]+3'b1;
      `csr_cl_lock:             csr_mflags[msrss_no[15]][18]<=1'b1;
     	      endcase
              aux0_reg<=aux0;
	      if (altEn) csr_retIP[thread_reg]<=altData;
          end
          if (fpE_en && !msrss_en | (msrss_no!=`csr_FPU)) begin
              csr_fpu[fpE_thr]<=csr_fpu[fpE_thr] | {42'b0,fpE_set,11'b0};
          end
          if (altEn2) csr_GORQ_recv_vector[altThr2][16:0]<=altEn2_data;
      end
  end
endmodule

module shmuph_decr(
  sel,
  inp,
  outp);
  parameter WIDTH=1;
  input [9:0] sel;
  input [9:0][WIDTH-1:0] inp;
  output [WIDTH-1:0] outp;
  assign outp=(sel[0] & ~sel[1]) ? inp[0] : 'z;
  assign outp=(sel[1] & ~sel[0]) ? inp[1] : 'z;
  assign outp=(sel[2] & ~sel[1]) ? inp[2] : 'z;
  assign outp=(sel[3] & ~sel[1]) ? inp[3] : 'z;
  assign outp=(sel[4] & ~sel[1]) ? inp[4] : 'z;
  assign outp=(sel[5] & ~sel[1]) ? inp[5] : 'z;
  assign outp=(sel[6] & ~sel[1]) ? inp[6] : 'z;
  assign outp=(sel[7] & ~sel[1]) ? inp[7] : 'z;
  assign outp=(sel[8] & ~sel[1]) ? inp[8] : 'z;
  assign outp=sel[9] ? inp[9] : 'z;
endmodule
module decoder_reorder_mux(
  avail,
  enable,
  sel,mulsel,
  pwn_fma,
  isMul5,isMul8,isMul5_twinreg,
  store,
  storeL,
  storeDA,
  storeDB,
  operation,
  rA,rA_use,rA_useF,useAConst,
  rB,rB_use,rB_useF,useBConst,
  constant,
  rT,rT_use,rT_useF,
  port,
  useRs,
  afterTaken,
  IPRel,
  alloc,
  allocF,
  rAlloc,
  lastFl,
  flDep,
  flWr,
  rA_isV,
  rB_isV,
  rT_isV,
  rA_isAnyV,
  rB_isAnyV,
  ls_flag,
  st_enA,
  st_enB,
 
  dec_IPRel,
  dec_alloc,
  dec_allocF,
  dec_rAlloc,
  dec_lastFl,
  dec_flWr,
  dec_rA_isV,
  dec_rB_isV,
  dec_rT_isV,
  dec_ls_flag,
  
  dec0_operation,

  dec0_rA,

  dec0_rA_use,

  dec0_rA_useF,
  
  dec0_useAConst,

  dec0_rB,

  dec0_rB_use,

  dec0_rB_useF,

  dec0_useBConst,

  dec0_constant,

  aux_constant,

  dec_cls_sys,

  dec0_rC,

  dec0_rC_use,

  dec0_rC_useF,

  dec0_rT,

  dec0_rT_use,

  dec0_rT_useF,
  
  dec0_port,

  dec0_useRs,
  
  dec0_srcIPOff,

  dec0_flDep,

  dec_afterTaken
  );
  parameter INDEX=0;
  localparam OPERATION_WIDTH=`operation_width+5;
  localparam REG_WIDTH=6;
  
  input [9:0] avail;

  input enable;
  
  input [9:0] sel;
  input [2:0][9:0]mulsel;
  input [9:0] pwn_fma;

  input isMul5;
  input isMul8;

  input isMul5_twinreg;
  
  input store;
  input storeL;
  input [9:0] storeDA;
  input [9:0] storeDB;
  
  output [OPERATION_WIDTH-1:0] operation;
  output [REG_WIDTH-1:0] rA;
  output rA_use;
  output rA_useF;
  output useAConst;
  output [REG_WIDTH-1:0] rB;
  output rB_use;
  output rB_useF;
  output useBConst;
  output [64:0] constant;
  output [REG_WIDTH-1:0] rT;
  output rT_use;
  output rT_useF;
  output [3:0] port;
  output useRs;
  output afterTaken;
  output IPRel;
  output alloc,allocF;
  output rAlloc;
  output lastFl;
  output [3:0] flDep;
  output flWr;
  output rA_isV;
  output rB_isV;
  output rT_isV;
  output rA_isAnyV;
  output rB_isAnyV;
  output ls_flag;
  output st_enA;
  output st_enB;

  input [9:0] dec_IPRel;
  input [9:0] dec_alloc;
  input [9:0] dec_allocF;
  input [9:0] dec_rAlloc;
  input [9:0] dec_lastFl;
  input [9:0] dec_flWr;
  input [9:0] dec_rA_isV;
  input [9:0] dec_rB_isV;
  input [9:0] dec_rT_isV;
  input [9:0] dec_ls_flag;
  
  input [9:0][OPERATION_WIDTH-1:0] dec0_operation;

  input [9:0][REG_WIDTH-1:0] dec0_rA;

  input [9:0] dec0_rA_use;

  input [9:0] dec0_rA_useF;

  input [9:0] dec0_useAConst;

  input [9:0][REG_WIDTH-1:0] dec0_rB;

  input [9:0] dec0_rB_use;

  input [9:0] dec0_rB_useF;

  input [9:0] dec0_useBConst;

  input [9:0][64:0] dec0_constant;

  input [64:0] aux_constant;

  input [9:0] dec_cls_sys;

  input [9:0][REG_WIDTH-1:0] dec0_rC;

  input [9:0]dec0_rC_use;

  input [9:0]dec0_rC_useF;
  
  
  input [9:0][REG_WIDTH-1:0] dec0_rT;

  input [9:0]dec0_rT_use;

  input [9:0]dec0_rT_useF;

  input [9:0][3:0] dec0_port;

  input [9:0] dec0_useRs;
  
  input signed [9:0][43:0] dec0_srcIPOff;
  
  input [9:0][3:0] dec0_flDep;
  
  input [9:0] dec_afterTaken;

  wire [64:0] constantA;
  wire [64:0] constantB;
  wire [REG_WIDTH-1:0] rA1;
  wire [REG_WIDTH-1:0] rA2;
  wire [REG_WIDTH-1:0] rA3;
  wire [REG_WIDTH-1:0] rB1;
  wire [REG_WIDTH-1:0] rB2;
  wire rA1_use,rA2_use,rA3_use;
  wire rA1_useF,rA2_useF,rA3_useF;
  wire rB1_use,rB2_use;
  wire rB1_useF,rB2_useF;
  
  shmuph_decr #(OPERATION_WIDTH) op_mod(sel,dec0_operation,operation);
  shmuph_decr #(65) ca_mod(sel,dec0_constant,constantA);
  shmuph_decr #(64) cb_mod(sel,dec0_srcIPOff,constantB);

  assign constant=(0==(sel&dec_IPRel) && 0==(sel&dec_cls_sys)) ? constantA : 65'bz;
  assign constant=(0!=(sel&dec_IPRel) && 0==(sel&dec_cls_sys)) ? {1'b0,constantB} : 65'bz;
  assign constant=0!=(sel&dec_cls_sys) ? aux_constant : 65'bz;

  assign st_enA=!(&storeDA[1:0]);
  assign st_enB=!(&storeDB[1:0]);

  shmuph_decr #(4) port_mod(sel,dec0_port,port);
  shmuph_decr #(6) rA1_mod(sel,dec0_rA,rA1);
  shmuph_decr #(6) rB1_mod(sel,dec0_rB,rB1);
  shmuph_decr #(6) rA2_mod(storeDA,dec0_rC,rA2);
  shmuph_decr #(6) rB2_mod(storeDB,dec0_rC,rB2);

  assign rB=storeL ? rB2 : rB1;
  assign rA=storeL ? rA2 : rA1;

  wire [5:0] rTx;

  shmuph_decr #(6) rT_mod(sel,dec0_rT,rT0);
  shmuph_decr #(6) rTx_mod(sel,{6'h39,6'h38,6'h37,6'h36,6'h35,6'h34,6'h33,6'h32,6'h31,6'h30},rTx);
  assign rT=pwn_fma & sel ? rTx : rT;

  shmuph_decr #(1) rA_isV_mod(sel&{10{~storeL}},dec0_rA_isV,rA_isV);
  assign rA_isV=(storeL) ? 1'b0 : 1'bz;

  assign rA_isAnyV=(~storeL) ? 1'b0 : 1'BZ;
  assign rA_isAnyV=(storeDA[0] & storeDA[1] & storeL) ? 1'b0 : 1'BZ;
  assign rA_isAnyV=(~(storeDA[0] & storeDA[1]) & storeL) ? 1'b1 : 1'BZ;

  shmuph_decr #(1) rB_isV_mod(sel&{10{~storeL}},dec0_rB_isV,rB_isV);
  assign rB_isV=(storeL) ? 1'b0 : 1'bz;

  assign rB_isAnyV=(storeDB[0] & storeDB[1] & storeL) ? 1'b0 : 1'BZ;
  assign rB_isAnyV=(~(storeDB[0] & storeDB[1]) & storeL) ? 1'b1 : 1'BZ;
  assign rB_isAnyV=(~storeL) ? 1'b0 : 1'bz;

  shmuph_decr #(1) rT_isV_mod(sel,dec0_rT_isV,rT_isV);

  shmuph_decr #(1) rA1_use_mod(sel,dec0_rA_use&avail,rA1_use);
  shmuph_decr #(1) rA2_use_mod(storeDA,dec0_rC_use&avail,rA2_use);

  assign rA_use=storeL ? rA2_use : rA1_use;

  shmuph_decr #(1) rA1_useF_mod(sel,dec0_rA_useF&avail,rA1_useF);
  shmuph_decr #(1) rA2_useF_mod(storeDA,dec0_rC_useF&avail,rA2_useF);

  assign rA_useF=storeL ? rA2_useF : rA1_useF;
  shmuph_decr #(1) rB1_use_mod(sel,dec0_rB_use&avail,rB1_use);
  shmuph_decr #(1) rB2_use_mod(storeDB,dec0_rC_use&avail,rB2_use);

  assign rB_use=storeL ? rB2_use : rB1_use;
  shmuph_decr #(1) rB1_useF_mod(sel,dec0_rB_useF&avail,rB1_useF);
  shmuph_decr #(1) rB2_useF_mod(storeDB,dec0_rC_useF&avail,rB2_useF);

  assign rB_useF=storeL ? rB2_useF : rB1_useF;

  shmuph_decr #(1) rT_use_mod(sel,dec0_rT_use&avail,rT_use);  
  shmuph_decr #(1) rT_useF_mod(sel,dec0_rT_useF&avail,rT_useF);
  shmuph_decr #(1) ls_flag_mod(sel,dec_ls_flag&avail,ls_flag);
  shmuph_decr #(1) IPRel_mod(sel,dec_IPRel&avail,IPRel);
  shmuph_decr #(1) useAConst_mod(sel,dec0_useAConst&avail,useAConst);  
  shmuph_decr #(1) useBConst_mod(sel,dec0_useBConst&avail,useBConst);  
  shmuph_decr #(1) useRs_mod(sel,(dec0_useRs&avail&{10{~isMul5}})|{10{&sel[1:0] & storeL}},useRs);
  shmuph_decr #(1) afterTaken_mod(sel,dec_afterTaken&avail,afterTaken);    
  shmuph_decr #(1) alloc_mod(sel&({10{isMul5_twinreg}}&mulsel[INDEX%3]),dec_alloc&avail,alloc);
  shmuph_decr #(1) allocF_mod(sel&({10{isMul5_twinreg}}&mulsel[INDEX%3]&~pwn_fma),dec_allocF&avail,allocF);
  shmuph_decr #(1) rAlloc_mod(sel&({10{isMul5_twinreg}}&mulsel[INDEX%3]),dec_rAlloc&avail,rAlloc);    
  shmuph_decr #(1) lastFl_mod(sel,dec_lastFl&avail,lastFl);    
  shmuph_decr #(1) flWr_mod(sel,dec_flWr&avail,flWr);    

  assign flDep=(sel[0] & ~sel[1]) ? dec0_flDep : 4'BZ;
  assign flDep=(sel[1] & ~sel[0]) ? dec1_flDep : 4'BZ;
  assign flDep=(sel[2] & ~sel[1]) ? dec2_flDep : 4'BZ;
  assign flDep=(sel[3] & ~sel[1]) ? dec3_flDep : 4'BZ;
  assign flDep=(sel[4] & ~sel[1]) ? dec4_flDep : 4'BZ;
  assign flDep=(sel[5] & ~sel[1]) ? dec5_flDep : 4'BZ;
  assign flDep=(sel[6] & ~sel[1]) ? dec6_flDep : 4'BZ;
  assign flDep=(sel[7] & ~sel[1]) ? dec7_flDep : 4'BZ;
  assign flDep=(sel[8] & ~sel[1]) ? dec8_flDep : 4'BZ;
  assign flDep=(sel[9] & ~sel[1]) ? dec9_flDep : 4'BZ;
  assign flDep=(&sel[1:0]) ? 4'hd : 4'bz;

endmodule


module decoder_jpos(
  jump,
  used,
  jump0,
  jump1);

  input [9:0] jump;
  input [9:0] used;
  output [9:0] jump0;
  output [9:0] jump1;

  wire [9:-1] has1;
  wire [9:-1] has2;

  assign has1[-1]=1'b0;
  assign has2[-1]=1'b0;

  generate
      genvar k;
      for (k=0;k<10;k=k+1) begin : cnt_gen
	  wire [10:0] cnt;
	  popcnt10 pc1_mod(jump&used&((10'd2<<k)-10'd1),cnt);
	  assign has1[k]=cnt[1];
	  assign has2[k]=cnt[2];
	  assign jump0[k]=has1[k]&&~has1[k-1];
	  assign jump1[k]=has2[k]&&~has2[k-1];
      end
  endgenerate

endmodule

module decoder(
  clk,
  rst,
  stall,
  fat_stall_en,
  except,
  exceptIP,
  exceptAttr,
  
  btbl_step,
  
  iAvail,
  iUsed,
  GORQ,
  GORQ_data,
  GORQ_thr,
  inst0,instQ0,
  inst1,instQ1,
  inst2,instQ2,
  inst3,instQ3,
  inst4,instQ4,
  inst5,instQ5,
  inst6,instQ6,
  inst7,instQ7,
  inst8,instQ8,
  inst9,instQ9,


  jqe_IP0,
  jqe_IP1,

  jqe_attr0,
  jqe_attr1,

  halt,
  
  all_retired,
  fp_excpt_en,
  fp_excpt_set,
  fp_excpt_thr,

  bundleFeed,
//begin instructions ordered by rs input port
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
  rs0i0_ldst_flag,
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
  rs0i1_ldst_flag,
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
  rs1i0_ldst_flag,
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
  rs1i1_ldst_flag,
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
  rs2i0_ldst_flag,
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
  rs2i1_ldst_flag,
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
  instr0_error,
  
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
  instr1_error,
    
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
  instr2_error,
  
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
  instr3_error,
  
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
  instr4_error,
  
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
  instr5_error,

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
  instr6_error,

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
  instr7_error,

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
  instr8_error,

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
  instr9_error,

  jump0Type,jump0Pos,jump0Taken,
  jump1Type,jump1Pos,jump1Taken,
  jump0BtbWay,jump0JmpInd,jump0GHT,jump0GHT2,jump0Val,
  jump1BtbWay,jump1JmpInd,jump1GHT,jump1GHT2,jump1Val,
  jump0SC,jump0Miss,jump0TbufOnly,
  jump1SC,jump1Miss,jump1TbufOnly,
  instr_fsimd,
  baseIP,
  baseAttr,
  wrt0,wrt1,wrt2,
  msrss_no,msrss_en,msrss_data,
  thread
  );
  localparam DATA_WIDTH=`alu_width+1;
  localparam OPERATION_WIDTH=`operation_width+5+3;
  localparam RRF_WIDTH=6;
  localparam IN_REG_WIDTH=6;
  localparam PORT_WIDTH=4;
  localparam PORT_DEC_WIDTH=3;
  localparam INSTR_WIDTH=80;
  localparam INSTRQ_WIDTH=`instrQ_width;
  localparam REG_WIDTH=6;
  localparam IP_WIDTH=64;
  
  input clk;
  input rst;
  input stall;
  input fat_stall_en;
  input except;
  input [IP_WIDTH-1:0] exceptIP;
  input [3:0] exceptAttr;

  output [2:0] btbl_step;

  input [9:0] iAvail;
  output [9:0] iUsed;

  input GORQ;
  input [16:0] GORQ_data;
  input GORQ_thr;
  
  input [INSTR_WIDTH-1:0] inst0;
  input [INSTRQ_WIDTH-1:0] instQ0;
  input [INSTR_WIDTH-1:0] inst1;
  input [INSTRQ_WIDTH-1:0] instQ1;
  input [INSTR_WIDTH-1:0] inst2;
  input [INSTRQ_WIDTH-1:0] instQ2;
  input [INSTR_WIDTH-1:0] inst3;
  input [INSTRQ_WIDTH-1:0] instQ3;
  input [INSTR_WIDTH-1:0] inst4;
  input [INSTRQ_WIDTH-1:0] instQ4;
  input [INSTR_WIDTH-1:0] inst5;
  input [INSTRQ_WIDTH-1:0] instQ5;
  input [INSTR_WIDTH-1:0] inst6;
  input [INSTRQ_WIDTH-1:0] instQ6;
  input [INSTR_WIDTH-1:0] inst7;
  input [INSTRQ_WIDTH-1:0] instQ7;
  input [INSTR_WIDTH-1:0] inst8;
  input [INSTRQ_WIDTH-1:0] instQ8;
  input [INSTR_WIDTH-1:0] inst9;
  input [INSTRQ_WIDTH-1:0] instQ9;
  
  input [62:0] jqe_IP0;
  input [62:0] jqe_IP1;

  input [3:0] jqe_attr0;
  input [3:0] jqe_attr1;

  output halt;

  input all_retired;
  input fp_excpt_en;
  input [10:0] fp_excpt_set;
  input fp_excpt_thr;

  output reg bundleFeed;
  

  output [IN_REG_WIDTH-1:0] rs0i0_rA;
  output rs0i0_rA_use;
  output rs0i0_rA_useF;
  output rs0i0_rA_isV;
  output rs0i0_rA_isAnyV;
  output [IN_REG_WIDTH-1:0] rs0i0_rB;
  output rs0i0_rB_use;
  output rs0i0_rB_useF;
  output rs0i0_rB_isV;
  output rs0i0_rB_isAnyV;
  output rs0i0_useBConst;
  output [IN_REG_WIDTH-1:0] rs0i0_rT;
  output rs0i0_rT_use;
  output rs0i0_rT_useF;
  output rs0i0_rT_isV;
  output [PORT_WIDTH-1:0] rs0i0_port;
  output [OPERATION_WIDTH-1:0] rs0i0_operation;
  output rs0i0_en;
  output [DATA_WIDTH-1:0] rs0i0_const;
  output [3:0] rs0i0_index;
  output rs0i0_IPRel;
  output rs0i0_afterTaken;
  output rs0i0_alt;
  output rs0i0_alloc;
  output rs0i0_allocF;
  output rs0i0_allocR;
  output [5:0]  rs0i0_lsi;
  output rs0i0_ldst_flag;
  output rs0i0_enA;
  output rs0i0_enB;

  output [IN_REG_WIDTH-1:0] rs0i1_rA;
  output rs0i1_rA_use;
  output rs0i1_rA_useF;
  output rs0i1_rA_isV;
  output rs0i1_rA_isAnyV;
  output rs0i1_useAConst;
  output [IN_REG_WIDTH-1:0] rs0i1_rB;
  output rs0i1_rB_use;
  output rs0i1_rB_useF;
  output rs0i1_rB_isV;
  output rs0i1_rB_isAnyV;
  output rs0i1_useBConst;
  output [IN_REG_WIDTH-1:0] rs0i1_rT;
  output rs0i1_rT_use;
  output rs0i1_rT_useF;
  output rs0i1_rT_isV;
  output [PORT_WIDTH-1:0] rs0i1_port;
  output [OPERATION_WIDTH-1:0] rs0i1_operation;
  output rs0i1_en;
  output [DATA_WIDTH-1:0] rs0i1_const;
  output [3:0] rs0i1_index;
  output rs0i1_IPRel;
  output rs0i1_afterTaken;
  output rs0i1_alloc;
  output rs0i1_allocF;
  output rs0i1_allocR;
  output [3:0] rs0i1_flagDep;
  output rs0i1_lastFl;
  output [5:0]  rs0i1_lsi;
  output rs0i1_ldst_flag;
  output rs0i1_flag_wr;
  
  output [IN_REG_WIDTH-1:0] rs0i2_rA;
  output rs0i2_rA_use;
  output rs0i2_rA_useF;
  output rs0i2_rA_isV;
  output rs0i2_rA_isAnyV;
  output rs0i2_useAConst;
  output [IN_REG_WIDTH-1:0] rs0i2_rB;
  output rs0i2_rB_use;
  output rs0i2_rB_useF;
  output rs0i2_rB_isV;
  output rs0i2_rB_isAnyV;
  output rs0i2_useBConst;
  output [IN_REG_WIDTH-1:0] rs0i2_rT;
  output rs0i2_rT_use;
  output rs0i2_rT_useF;
  output rs0i2_rT_isV;
  output [PORT_WIDTH-1:0] rs0i2_port;
  output [OPERATION_WIDTH-1:0] rs0i2_operation;
  output rs0i2_en;
  output [DATA_WIDTH-1:0] rs0i2_const;
  output [3:0] rs0i2_index;
  output rs0i2_IPRel;
  output rs0i2_afterTaken;
  output rs0i2_alloc;
  output rs0i2_allocF;
  output rs0i2_allocR;
  output [3:0] rs0i2_flagDep;
  output rs0i2_lastFl;
  output rs0i2_flag_wr;
  
  output [IN_REG_WIDTH-1:0] rs1i0_rA;
  output rs1i0_rA_use;
  output rs1i0_rA_useF;
  output rs1i0_rA_isV;
  output rs1i0_rA_isAnyV;
  output [IN_REG_WIDTH-1:0] rs1i0_rB;
  output rs1i0_rB_use;
  output rs1i0_rB_useF;
  output rs1i0_rB_isV;
  output rs1i0_rB_isAnyV;
  output rs1i0_useBConst;
  output [IN_REG_WIDTH-1:0] rs1i0_rT;
  output rs1i0_rT_use;
  output rs1i0_rT_useF;
  output rs1i0_rT_isV;
  output [PORT_WIDTH-1:0] rs1i0_port;
  output [OPERATION_WIDTH-1:0] rs1i0_operation;
  output rs1i0_en;
  output [DATA_WIDTH-1:0] rs1i0_const;
  output [3:0] rs1i0_index;
  output rs1i0_IPRel;
  output rs1i0_afterTaken;
  output rs1i0_alt;
  output rs1i0_alloc;
  output rs1i0_allocF;
  output rs1i0_allocR;
  output [5:0]  rs1i0_lsi;
  output rs1i0_ldst_flag;
  output rs1i0_enA;
  output rs1i0_enB;
  
  output [IN_REG_WIDTH-1:0] rs1i1_rA;
  output rs1i1_rA_use;
  output rs1i1_rA_useF;
  output rs1i1_rA_isV;
  output rs1i1_rA_isAnyV;
  output rs1i1_useAConst;
  output [IN_REG_WIDTH-1:0] rs1i1_rB;
  output rs1i1_rB_use;
  output rs1i1_rB_useF;
  output rs1i1_rB_isV;
  output rs1i1_rB_isAnyV;
  output rs1i1_useBConst;
  output [IN_REG_WIDTH-1:0] rs1i1_rT;
  output rs1i1_rT_use;
  output rs1i1_rT_useF;
  output rs1i1_rT_isV;
  output [PORT_WIDTH-1:0] rs1i1_port;
  output [OPERATION_WIDTH-1:0] rs1i1_operation;
  output rs1i1_en;
  output [DATA_WIDTH-1:0] rs1i1_const;
  output [3:0] rs1i1_index;
  output rs1i1_IPRel;
  output rs1i1_afterTaken;
  output rs1i1_alloc;
  output rs1i1_allocF;
  output rs1i1_allocR;
  output [3:0] rs1i1_flagDep;
  output rs1i1_lastFl;
  output [5:0]  rs1i1_lsi;
  output rs1i1_ldst_flag;
  output rs1i1_flag_wr;

  output [IN_REG_WIDTH-1:0] rs1i2_rA;
  output rs1i2_rA_use;
  output rs1i2_rA_useF;
  output rs1i2_rA_isV;
  output rs1i2_rA_isAnyV;
  output rs1i2_useAConst;
  output [IN_REG_WIDTH-1:0] rs1i2_rB;
  output rs1i2_rB_use;
  output rs1i2_rB_useF;
  output rs1i2_rB_isV;
  output rs1i2_rB_isAnyV;
  output rs1i2_useBConst;
  output [IN_REG_WIDTH-1:0] rs1i2_rT;
  output rs1i2_rT_use;
  output rs1i2_rT_useF;
  output rs1i2_rT_isV;
  output [PORT_WIDTH-1:0] rs1i2_port;
  output [OPERATION_WIDTH-1:0] rs1i2_operation;
  output rs1i2_en;
  output [DATA_WIDTH-1:0] rs1i2_const;
  output [3:0] rs1i2_index;
  output rs1i2_IPRel;
  output rs1i2_afterTaken;
  output rs1i2_alloc;
  output rs1i2_allocF;
  output rs1i2_allocR;
  output [3:0] rs1i2_flagDep;
  output rs1i2_lastFl;
  output rs1i2_flag_wr;

  output [IN_REG_WIDTH-1:0] rs2i0_rA;
  output rs2i0_rA_use;
  output rs2i0_rA_useF;
  output rs2i0_rA_isV;
  output rs2i0_rA_isAnyV;
  output [IN_REG_WIDTH-1:0] rs2i0_rB;
  output rs2i0_rB_use;
  output rs2i0_rB_useF;
  output rs2i0_rB_isV;
  output rs2i0_rB_isAnyV;
  output rs2i0_useBConst;
  output [IN_REG_WIDTH-1:0] rs2i0_rT;
  output rs2i0_rT_use;
  output rs2i0_rT_useF;
  output rs2i0_rT_isV;
  output [PORT_WIDTH-1:0] rs2i0_port;
  output [OPERATION_WIDTH-1:0] rs2i0_operation;
  output rs2i0_en;
  output [DATA_WIDTH-1:0] rs2i0_const;
  output [3:0] rs2i0_index;
  output rs2i0_IPRel;
  output rs2i0_afterTaken;
  output rs2i0_alt;
  output rs2i0_alloc;
  output rs2i0_allocF;
  output rs2i0_allocR;
  output [5:0]  rs2i0_lsi;
  output rs2i0_ldst_flag;
  output rs2i0_enA;
  output rs2i0_enB;
  
  output [IN_REG_WIDTH-1:0] rs2i1_rA;
  output rs2i1_rA_use;
  output rs2i1_rA_useF;
  output rs2i1_rA_isV;
  output rs2i1_rA_isAnyV;
  output rs2i1_useAConst;
  output [IN_REG_WIDTH-1:0] rs2i1_rB;
  output rs2i1_rB_use;
  output rs2i1_rB_useF;
  output rs2i1_rB_isV;
  output rs2i1_rB_isAnyV;
  output rs2i1_useBConst;
  output [IN_REG_WIDTH-1:0] rs2i1_rT;
  output rs2i1_rT_use;
  output rs2i1_rT_useF;
  output rs2i1_rT_isV;
  output [PORT_WIDTH-1:0] rs2i1_port;
  output [OPERATION_WIDTH-1:0] rs2i1_operation;
  output rs2i1_en;
  output [DATA_WIDTH-1:0] rs2i1_const;
  output [3:0] rs2i1_index;
  output rs2i1_IPRel;
  output rs2i1_afterTaken;
  output rs2i1_alloc;
  output rs2i1_allocF;
  output rs2i1_allocR;
  output [3:0] rs2i1_flagDep;
  output rs2i1_lastFl;
  output [5:0]  rs2i1_lsi;
  output rs2i1_ldst_flag;
  output rs2i1_flag_wr;

  output [IN_REG_WIDTH-1:0] rs2i2_rA;
  output rs2i2_rA_use;
  output rs2i2_rA_useF;
  output rs2i2_rA_isV;
  output rs2i2_rA_isAnyV;
  output rs2i2_useAConst;
  output [IN_REG_WIDTH-1:0] rs2i2_rB;
  output rs2i2_rB_use;
  output rs2i2_rB_useF;
  output rs2i2_rB_isV;
  output rs2i2_rB_isAnyV;
  output rs2i2_useBConst;
  output [IN_REG_WIDTH-1:0] rs2i2_rT;
  output rs2i2_rT_use;
  output rs2i2_rT_useF;
  output rs2i2_rT_isV;
  output [PORT_WIDTH-1:0] rs2i2_port;
  output [OPERATION_WIDTH-1:0] rs2i2_operation;
  output rs2i2_en;
  output [DATA_WIDTH-1:0] rs2i2_const;
  output [3:0] rs2i2_index;
  output rs2i2_IPRel;
  output rs2i2_afterTaken;
  output rs2i2_alloc;
  output rs2i2_allocF;
  output rs2i2_allocR;
  output [3:0] rs2i2_flagDep;
  output rs2i2_lastFl;
  output rs2i2_mul;
  output rs2i2_flag_wr;

  
  output [IN_REG_WIDTH-1:0] instr0_rT;
  output instr0_en;
  output instr0_wren;
  output [8:0] instr0_IPOff;
  output instr0_afterTaken;
  output instr0_rT_useF;
  output instr0_rT_isV;
  output [PORT_WIDTH-1:0] instr0_port;
  output [3:0] instr0_magic;
  output instr0_last;
  output reg instr0_aft_spc;
  output reg [1:0] instr0_error;
  
  output [IN_REG_WIDTH-1:0] instr1_rT;
  output instr1_en;
  output instr1_wren;
  output [8:0] instr1_IPOff;
  output instr1_afterTaken;
  output instr1_rT_useF;
  output instr1_rT_isV;
  output [PORT_WIDTH-1:0] instr1_port;
  output [3:0] instr1_magic;
  output instr1_last;
  output reg instr1_aft_spc;
  output reg [1:0] instr1_error;
  
  output [IN_REG_WIDTH-1:0] instr2_rT;
  output instr2_en;
  output instr2_wren;
  output [8:0] instr2_IPOff;
  output instr2_afterTaken;
  output instr2_rT_useF;
  output instr2_rT_isV;
  output [PORT_WIDTH-1:0] instr2_port;
  output [3:0] instr2_magic;
  output instr2_last;
  output reg instr2_aft_spc;
  output reg [1:0] instr2_error;
  
  output [IN_REG_WIDTH-1:0] instr3_rT;
  output instr3_en;
  output instr3_wren;
  output [8:0] instr3_IPOff;
  output instr3_afterTaken;
  output instr3_rT_useF;
  output instr3_rT_isV;
  output [PORT_WIDTH-1:0] instr3_port;
  output [3:0] instr3_magic;
  output instr3_last;
  output reg instr3_aft_spc;
  output reg [1:0] instr3_error;
  
  output [IN_REG_WIDTH-1:0] instr4_rT;
  output instr4_en;
  output instr4_wren;
  output [8:0] instr4_IPOff;
  output instr4_afterTaken;
  output instr4_rT_useF;
  output instr4_rT_isV;
  output [PORT_WIDTH-1:0] instr4_port;
  output [3:0] instr4_magic;
  output instr4_last;
  output reg instr4_aft_spc;
  output reg [1:0] instr4_error;
  
  output [IN_REG_WIDTH-1:0] instr5_rT;
  output instr5_en;
  output instr5_wren;
  output [8:0] instr5_IPOff;
  output instr5_afterTaken;
  output instr5_rT_useF;
  output instr5_rT_isV;
  output [PORT_WIDTH-1:0] instr5_port;
  output [3:0] instr5_magic;
  output instr5_last;
  output reg instr5_aft_spc;
  output reg [1:0] instr5_error;

  output [IN_REG_WIDTH-1:0] instr6_rT;
  output instr6_en;
  output instr6_wren;
  output [8:0] instr6_IPOff;
  output instr6_afterTaken;
  output instr6_rT_useF;
  output instr6_rT_isV;
  output [PORT_WIDTH-1:0] instr6_port;
  output [3:0] instr6_magic;
  output instr6_last;
  output reg instr6_aft_spc;
  output reg [1:0] instr6_error;

  output [IN_REG_WIDTH-1:0] instr7_rT;
  output instr7_en;
  output instr7_wren;
  output [8:0] instr7_IPOff;
  output instr7_afterTaken;
  output instr7_rT_useF;
  output instr7_rT_isV;
  output [PORT_WIDTH-1:0] instr7_port;
  output [3:0] instr7_magic;
  output instr7_last;
  output reg instr7_aft_spc;
  output reg [1:0] instr7_error;

  output [IN_REG_WIDTH-1:0] instr8_rT;
  output instr8_en;
  output instr8_wren;
  output [8:0] instr8_IPOff;
  output instr8_afterTaken;
  output instr8_rT_useF;
  output instr8_rT_isV;
  output [PORT_WIDTH-1:0] instr8_port;
  output [3:0] instr8_magic;
  output instr8_last;
  output reg instr8_aft_spc;
  output reg [1:0] instr8_error;

  output [IN_REG_WIDTH-1:0] instr9_rT;
  output instr9_en;
  output instr9_wren;
  output [8:0] instr9_IPOff;
  output instr9_afterTaken;
  output instr9_rT_useF;
  output instr9_rT_isV;
  output [PORT_WIDTH-1:0] instr9_port;
  output [3:0] instr9_magic;
  output instr9_last;
  output reg instr9_aft_spc;
  output reg [1:0] instr9_error;

  output [4:0] jump0Type;
  output [3:0] jump0Pos;
  output jump0Taken;
  output [4:0] jump1Type;
  output [3:0] jump1Pos;
  output jump1Taken;
  output jump0BtbWay;
  output [1:0] jump0JmpInd;
  output [7:0] jump0GHT;
  output [15:0] jump0GHT2;
  output jump0Val;
  output jump1BtbWay;
  output [1:0] jump1JmpInd;
  output [7:0] jump1GHT;
  output [15:0] jump1GHT2;
  output jump1Val;
  output [1:0] jump0SC;
  output jump0Miss;
  output jump0TbufOnly;
  output [1:0] jump1SC;
  output jump1Miss;
  output jump1TbufOnly;
  output [9:0] instr_fsimd;
  output [62:0] baseIP;
  output [3:0] baseAttr;
  
  output [5:0] wrt0;
  output [5:0] wrt1;
  output [5:0] wrt2;
  
  input [15:0] msrss_no;
  input msrss_en;
  input [64:0] msrss_data;
  input thread;

  function [5:0] ffx;
    input thr;
    input [2:0] thrmode;
    input wr_gen_purp;
    input [5:0] reeg;
    begin
        ffx=&reeg[4:3] ? {thrmode,reeg[2:0]} : reeg;
    end
  endfunction
  wire [9:0] msrss_retIP_en;
  wire [64:0] msrss_retIP_data;
  reg  [9:0] msrss_retIP_en_reg;

  reg last_trce;

  wire thrmode;

  wire [9:0][INSTR_WIDTH-1:0] inst;
  wire [9:0][INSTRQ_WIDTH-1:0] instQ;
  
  wire [9:0][OPERATION_WIDTH-6:0] dec_operation;
  wire [9:0][4:0] dec_alucond;
  wire [9:0][2:0] dec_rndmode;
  wire [9:0][REG_WIDTH-1:0] dec_rA;
  wire [9:0]dec_rA_use;
  wire [9:0]dec_rA_useF;
  wire [9:0][REG_WIDTH-1:0] dec_rB;
  wire [9:0]dec_rB_use;
  wire [9:0]dec_rB_useF;
  wire [9:0]dec_useBConst;
  wire [9:0][REG_WIDTH-1:0] dec_rC;
  wire [9:0]dec_rC_use;
  wire [9:0]dec_rC_useF;
  wire [9:0] dec_useCRet;
  wire [9:0][64:0] dec_constant;
  wire [9:0][64:0] dec_constantN;
  wire [9:0][REG_WIDTH-1:0] dec_rT;
  wire [9:0]dec_rT_use;
  wire [9:0]dec_rT_useF;
  wire [9:0][3:0] dec_port;
  wire [9:0]dec_useRs;
  wire [9:0]dec_halt;

  wire [9:0] dec_btbWay;
  wire [9:0][1:0] dec_jmpInd;
  wire [9:0][7:0] dec_ght;
  wire [9:0][15:0] dec_ght2;
  wire [9:0] dec_val;
  wire [9:0][1:0] dec_sc;
  wire [9:0] dec_miss;
  wire [9:0] dec_tbufOnly;

  reg was_FMA_last;
  reg [15:0] instr_save;


  wire [9:0][4:0] 		dec_jumpType;

  wire [9:0] dec_taken;
  
  wire [9:0] dec_rA_isV;
  wire [9:0] dec_rB_isV;
  wire [9:0] dec_rT_isV;

  wire [9:0] dec_fsimd;

  wire [9:0][7:0] dec_srcIPOff;
  reg  [8:0] dec_srcIPOff_reg[9:0];
  wire [9:0][8:0] dec_srcIPOffA;
  wire [9:0][43:0] dec_srcIPOffx;
  
  reg [8:0] dec_srcIPOffA_reg[9:0];

  
  wire [9:0] dec_allocR;
  reg [9:0] dec_allocR_reg;

  
  wire [9:0] dec_IPRel;
  reg [9:0] dec_IPRel_reg;
  
  wire has_taken;
  wire has_tick;

  wire [9:0][3:0] dec_magic;
  wire [9:0] dec_last;
  wire [9:-1] dec_lspec;
//  wire [9:-1] dec_aspec;
  reg dec_lspecR;
//  reg dec_aspecR;
  wire dec_lspecR_d;
//  wire dec_aspecR_d;
  wire [3:0] baseAttr;

  reg [OPERATION_WIDTH-6:0] 	dec_operation_reg[9:0];
  reg [4:0]			dec_alucond_reg[9:0];
  reg [2:0]			dec_rndmode_reg[9:0];
  reg [REG_WIDTH-1:0] 		dec_rA_reg[9:0];
  reg 				dec_rA_use_reg[9:0];
  reg 				dec_rA_useF_reg[9:0];
  reg [REG_WIDTH-1:0] 		dec_rB_reg[9:0];
  reg 				dec_rB_use_reg[9:0];
  reg 				dec_rB_useF_reg[9:0];
  reg 				dec_useAConst_reg[9:0];
  reg 				dec_useBConst_reg[9:0];
  reg [REG_WIDTH-1:0] 		dec_rC_reg[9:0];
  reg 				dec_rC_use_reg[9:0];
  reg 				dec_rC_useF_reg[9:0];
  reg [9:0]			dec_useCRet_reg;
  reg [64:0] 			dec_constant_reg[9:0];
  reg [64:0] 			dec_constantN_reg[9:0];
  reg [REG_WIDTH-1:0] 		dec_rT_reg[9:0];
  reg 				dec_rT_use_reg[9:0];
  reg 				dec_rT_useF_reg[9:0];
  reg [3:0] 			dec_port_reg[9:0];
  reg 				dec_useRs_reg[9:0];
  reg [4:0] 			dec_jumpType_reg[9:0];
  
  reg dec_btbWay_reg[9:0];
  reg [1:0] dec_jmpInd_reg[9:0];
  reg [7:0] dec_ght_reg[9:0];
  reg [15:0] dec_ght2_reg[9:0];
  reg dec_val_reg[9:0];
  reg [1:0] dec_sc_reg[9:0];
  reg [9:0] dec_miss_reg;
  reg [9:0] dec_tbufOnly_reg;
  
  reg [3:0] dec_magic_reg[9:0];
  reg [9:0] dec_last_reg;

  reg [9:0] dec_taken_reg;

  reg [9:0] dec_rA_isV_reg;
  reg [9:0] dec_rB_isV_reg;
  reg [9:0] dec_rT_isV_reg;

  reg [9:0] dec_fsimd_reg;
  
  reg halt_reg;



  wire [IP_WIDTH-1:0] taken_srcIP;

  wire [9:0][REG_WIDTH-1:0] dep_rA;
  wire [9:0][REG_WIDTH-1:0] dep_rB;
  wire [9:0][REG_WIDTH-1:0] dep_rC;

  wire [9:0] dec_afterTaken;
  reg [9:0] dec_afterTaken_reg;
  
  
  wire [9:0][`iclass_width-1:0] instCls;
  wire [9:0] cls_indir;
  wire [9:0] cls_jump;
  wire [9:0] cls_ALU;
  wire [9:0] cls_shift;
  wire [9:0] cls_mul;
  wire [9:0] cls_load;
  wire [9:0] cls_store;
  wire [9:0] cls_storeI;
  wire [9:0] cls_store2;
  wire [9:0] cls_FPU;
  wire [9:0] cls_loadFPU;
  wire [9:0] cls_sys;
  wire [9:0] cls_pos0;
  wire [9:0] cls_flag;

  reg [9:0] cls_indir_reg;
  reg [9:0] cls_jump_reg;
  reg [9:0] cls_ALU_reg;
  reg [9:0] cls_shift_reg;
  reg [9:0] cls_mul_reg;
  reg [9:0] cls_load_reg;
  reg [9:0] cls_store_reg;
  reg [9:0] cls_storeI_reg;
  reg [9:0] cls_store2_reg;
  reg [9:0] cls_FPU_reg;
  reg [9:-1] cls_loadFPU_reg;
  reg [9:0] cls_sys_reg;
  reg [9:0] cls_pos0_reg;
  reg [9:0] cls_flag_reg;
  
  reg [9:0] iUsed_reg;

  wire [8:0][OPERATION_WIDTH-1:0] rs_operation;
  wire [8:0][REG_WIDTH-1:0] rs_rA;
  wire [8:0]rs_rA_use;
  wire [8:0]rs_rA_useF;
  wire [8:0]rs_useAConst;
  wire [8:0][REG_WIDTH-1:0] rs_rB;
  wire [8:0]rs_rB_use;
  wire [8:0]rs_rB_useF;
  wire [8:0]rs_useBConst;
  wire [8:0][64:0] rs_constant;
  wire [8:0][REG_WIDTH-1:0] rs_rT;
  wire [8:0]rs_rT_use;
  wire [8:0]rs_rT_useF;
  wire [8:0][3:0] rs_port;
  wire [8:0]rs_useRs;
  wire [8:0] rs_afterTaken;
  wire [8:0] rs_IPRel;
  wire [8:0] rs_rA_isV;  
  wire [8:0] rs_rB_isV;  
  wire [8:0] rs_rT_isV;  
  wire [8:0] rs_rA_isAnyV;  
  wire [8:0] rs_rB_isAnyV;  
  wire [8:0][9:0] rs_index;
  wire [5:0][5:0] rs_lsi;
  wire [8:0] rs_flagWr;

  wire [2:0] rs_alt;
  wire [8:0] rs_allocR;
  wire [8:0] rs_ldst_flag;
 
  wire [8:0] rs_enA;
  wire [8:0] rs_enB;
 
  wire has_mul;
  integer n;

  wire [9:0] jump0;
  wire [9:0] jump1;
  wire hasJump0;
  wire hasJump1;

  reg [9:0] iAvail_reg;
  wire [9:0] rs_storeDA;
  wire [9:0] rs_storeDB;
  wire [8:0] rs_store;
  wire [8:0] rs_storeL;
  
  wire [9:0][1:0] dec_error;

  wire [9:0] afterTick;
  reg  [9:0] afterTick_reg;
  wire [9:0] dec_tick;
  
  wire [9:0] alloc;
  wire [8:0] rs_alloc;

  wire [9:0] allocF;
  wire [8:0] rs_allocF;
  
  wire [9:0] iAvail0;
  
  wire [9:0] dec_wrFlags;
  reg [9:0] dec_wrFlags_reg;

  wire [9:0] dec_useFlags;
  reg [9:0] dec_useFlags_reg;
  
  wire [9:0][3:0] flag_dep;
  wire [9:0] flag_lastWr;
  
  wire [8:0] rs_lastFl;
  wire [8:0][3:0] rs_flDep;

  wire [7:0] dummy8_1;
  wire [9:0] jump0_bit;
  wire [9:0] jump1_bit;
  wire jump0_any;
  wire jump1_any;
  
  wire [64:0] aux_const;
  wire aux_can_jump;

  generate 
      genvar k;
      for(k=0;k<10;k=k+1) begin : dec_gen

	  assign jump0Pos=jump0_bit[k] ? k[3:0] : 4'bz;
	  assign jump1Pos=jump1_bit[k] ? k[3:0] : 4'bz;

	  assign jump0Type=jump0_bit[k] ? dec_jumpType_reg[k] : 5'bz;
	  assign jump1Type=jump1_bit[k] ? dec_jumpType_reg[k] : 5'bz;

	  assign jump0Taken=jump0_bit[k] ? dec_taken_reg[k] : 1'bz;
	  assign jump1Taken=jump1_bit[k] ? dec_taken_reg[k] : 1'bz;

	  assign jump0BtbWay=jump0_bit[k] ? dec_btbWay_reg[k] : 1'bz;
	  assign jump1BtbWay=jump1_bit[k] ? dec_btbWay_reg[k] : 1'bz;

	  assign jump0JmpInd=jump0_bit[k] ? dec_jmpInd_reg[k] : 2'bz;
	  assign jump1JmpInd=jump1_bit[k] ? dec_jmpInd_reg[k] : 2'bz;

	  assign jump0GHT=jump0_bit[k] ? dec_ght_reg[k] : 8'bz;
	  assign jump1GHT=jump1_bit[k] ? dec_ght_reg[k] : 8'bz;

	  assign jump0GHT2=jump0_bit[k] ? dec_ght2_reg[k] : 8'bz;
	  assign jump1GHT2=jump1_bit[k] ? dec_ght2_reg[k] : 8'bz;

	  assign jump0Val=jump0_bit[k] ? dec_val_reg[k] : 8'bz;
	  assign jump1Val=jump1_bit[k] ? dec_val_reg[k] : 8'bz;


	  assign jump0SC=jump0_bit[k] ? dec_sc_reg[k] : 2'bz;
	  assign jump1SC=jump1_bit[k] ? dec_sc_reg[k] : 2'bz;
	  
	  assign jump0Miss=jump0_bit[k] ? dec_miss_reg[k] : 1'bz;
	  assign jump1Miss=jump1_bit[k] ? dec_miss_reg[k] : 1'bz;
	  assign jump0TbufOnly=jump0_bit[k] ? dec_tbufOnly_reg[k] : 1'bz;
	  assign jump1TbufOnly=jump1_bit[k] ? dec_tbufOnly_reg[k] : 1'bz;

//verilator lint_off PINMISSING
          smallInstr_decoder dec_mod(
          .clk(clk),
          .rst(rst),
          .mode64(1'b1),
          .error(dec_error[k]),
          .riscmove(riscmode),
          .distrust(lizztruss),
          .instrQ(instQ[k]),
          .instr(inst[k]),
          .instr_prev(k==0 ? instr_save[15:0] : instr[k-1][15:0]),
          .prevClsFMA(k==0 ? was_FMA_last : instrQ[k-1][`instrQ_class+`iclass_store2]),
          .operation(dec_operation[k]),
	  .can_jump_csr(aux_can_jump),
	  .can_read_csr(aux_can_read),
	  .can_write_csr(aux_can_write),
          .rA(dec_rA[k]),.rA_use(dec_rA_use[k]),
          .rB(dec_rB[k]),.rB_use(dec_rB_use[k]),.useBConst(dec_useBConst[k]),
          .rC(dec_rC[k]),.rC_use(dec_rC_use[k]),.useCRet(dec_useCRet[k]),
          .constant(dec_constant[k]),
          .constantN(dec_constantN[k]),
          .rT(dec_rT[k]),.rT_use(dec_rT_use[k]),
          .port(dec_port[k]),
          .useRs(dec_useRs[k]),
          .rA_useF(dec_rA_useF[k]),.rB_useF(dec_rB_useF[k]),.rT_useF(dec_rT_useF[k]),.rC_useF(dec_rC_useF[k]),
          .rA_isV(dec_rA_isV[k]),.rB_isV(dec_rB_isV[k]),.rT_isV(dec_rT_isV[k]),
	  .alucond(dec_alucond[k]),
          .rndmode(dec_rndmode[k]),
//          .clr64,.clr128,
//          .chain,
          .flags_use(dec_useFlags[k]),
          .flags_write(dec_wrFlags[k]),
          .instr_fsimd(dec_fsimd[k]),//choose simd-like over extended instr
          .halt(dec_halt[k]),
          
//          .pushCallStack,
//          .popCallStack,
//          .isJump,
//          .jumpTaken(dec_taken[k]),
          .jumpType(dec_jumpType[k]),
//          .jumpBtbHit,
//          .jumpEmbed,
//          .jumpIndir,
          .prevSpecLoad(dec_lspec[k-1]),
          .thisSpecLoad(dec_lspec[k]),
        //  .prevSpecAlu(dec_aspec[k-1]),
        //  .thisSpecAlu(dec_aspec[k]),
          .isIPRel(dec_IPRel[k]),
          .rAlloc(dec_allocR[k]),
	  .msrss_retIP_en(msrss_retIP_en[k])
          );
//verilator lint_on PINMISSING
          assign instCls[k]=instQ[k][`instrQ_nop] ? '0 : instQ[k][`instrQ_class];
          assign cls_indir[k]=instCls[k][`iclass_indir];
          assign cls_jump[k]=instCls[k][`iclass_jump];
          assign cls_flag[k]=instCls[k][`iclass_flag];
          assign cls_ALU[k]=instCls[k][`iclass_ALU];
          assign cls_shift[k]=instCls[k][`iclass_shift];
          assign cls_mul[k]=instCls[k][`iclass_mul];
          assign cls_load[k]=instCls[k][`iclass_load];
          assign cls_store[k]=instCls[k][`iclass_store];
          assign cls_storeI=cls_store&cls_flag;//instCls[k][`iclass_storeI];
          assign cls_store2[k]=instCls[k][`iclass_store2];
          assign cls_FPU[k]=instCls[k][`iclass_FPU];
          assign cls_loadFPU[k]=instCls[k][`iclass_loadFPU];
          assign cls_sys[k]=instCls[k][`iclass_sys];
          assign cls_pos0[k]=instCls[k][`iclass_pos0];
          
          assign dec_srcIPOff[k]=instQ[k][`instrQ_srcIPOff];
          
          assign dec_tick[k]=instQ[k][`instrQ_srcTick];
          
          assign dec_magic[k]=instQ[k][`instrQ_magic];
          assign dec_taken[k]=instQ[k][`instrQ_taken];
	  assign dec_last[k]=instQ[k][`instrQ_lastInstr];
	  assign dec_btbWay[k]=instQ[k][`instrQ_btb_way];
	  assign dec_jmpInd[k]=instQ[k][`instrQ_jmp_ind];
	  assign dec_ght[k]=instQ[k][`instrQ_ght_addr];
	  assign dec_ght2[k]=instQ[k][`instrQ_ght2_addr];
	  assign dec_val[k]=instQ[k][`instrQ_jval];
	  assign dec_sc[k]=instQ[k][`instrQ_sc];
	  assign dec_miss[k]=instQ[k][`instrQ_btbMiss];
	  assign dec_tbufOnly[k]=instQ[k][`instrQ_btb_only];
         
	  assign rs2i2_mul=has_mul; 
           
          assign rs0i0_index=(rs_index[0][k] & ~rs_index[0][k^1]) ? k : 4'bz;
          assign rs1i0_index=(rs_index[1][k] & ~rs_index[1][k^1]) ? k : 4'bz;
          assign rs2i0_index=(rs_index[2][k] & ~rs_index[2][k^1]) ? k : 4'bz;
          assign rs0i1_index=(rs_index[3][k] & ~rs_index[3][k^1]) ? k : 4'bz;
          assign rs1i1_index=(rs_index[4][k] & ~rs_index[4][k^1]) ? k : 4'bz;
          assign rs2i1_index=(rs_index[5][k] & ~rs_index[5][k^1]) ? k : 4'bz;
          assign rs0i2_index=(rs_index[6][k] & ~rs_index[6][k^1]) ? k : 4'bz;
          assign rs1i2_index=(rs_index[7][k] & ~rs_index[7][k^1]) ? k : 4'bz;
          assign rs2i2_index=(rs_index[8][k] & ~rs_index[8][k^1]) ? k : 4'bz;

          adder #(9) srcAddA1_mod({afterTick[k],dec_srcIPOff[k]},9'd1,dec_srcIPOffA[k],1'b0,~dec_magic[k][0],,,,);
          adder #(9) srcAddA2_mod({afterTick[k],dec_srcIPOff[k]},9'd2,dec_srcIPOffA[k],1'b0,dec_magic[k][1:0]==2'b01,,,,);
          adder #(9) srcAddA3_mod({afterTick[k],dec_srcIPOff[k]},9'd3,dec_srcIPOffA[k],1'b0,dec_magic[k][2:0]==3'b011,,,,);
          adder #(9) srcAddA4_mod({afterTick[k],dec_srcIPOff[k]},9'd4,dec_srcIPOffA[k],1'b0,dec_magic[k][3:0]==4'b0111,,,,);
          adder #(9) srcAddA5_mod({afterTick[k],dec_srcIPOff[k]},9'd5,dec_srcIPOffA[k],1'b0,dec_magic[k][3:0]==4'b1111,,,,);

          
          adder #(44) srcXAdd_mod({34'b0,dec_srcIPOffA_reg[k],1'b0   },{dec_constant_reg[k][43:0]},dec_srcIPOffx[k],1'b0, 1'b1,,,,);

	  popcnt10 jpop_mod(cls_jump_reg&iUsed_reg,{dummy8_1,btbl_step});
	  adder #(43) csrAdd_mod({34'b0,dec_srcIPOffA_reg[k]},baseIP[42:0],msrss_retIP_data[43:1],1'b0,msrss_retIP_en_reg[k],,,,);

          if (k<9) 
          decoder_reorder_mux mux_mod(
          iUsed_reg,
          1'b1,
          rs_index[k],
          k==5 && has_mul,k==8 && has_mul,
          rs_store[k] && rs_storeL==0,
          rs_storeL[k],
          rs_storeDA,
          rs_storeDB,
          rs_operation[k],
          rs_rA[k],rs_rA_use[k],rs_rA_useF[k],rs_useAConst[k],
          rs_rB[k],rs_rB_use[k],rs_rB_useF[k],rs_useBConst[k],
          rs_constant[k],
          rs_rT[k],rs_rT_use[k],rs_rT_useF[k],
          rs_port[k],
          rs_useRs[k],
          rs_afterTaken[k],
          rs_IPRel[k],
          rs_alloc[k],
          rs_allocF[k],
          rs_allocR[k],
          rs_lastFl[k],
          rs_flDep[k],
	  rs_flagWr[k],
          rs_rA_isV[k],
          rs_rB_isV[k],
          rs_rT_isV[k],
          rs_rA_isAnyV[k],
          rs_rB_isAnyV[k],
          rs_ldst_flag[k],
          rs_enA[k],
          rs_enB[k],  
          dec_IPRel_reg,
          alloc,
          allocF,
          dec_allocR_reg,
          flag_lastWr,
	  dec_wrFlags_reg,
          dec_rA_isV_reg,
          dec_rB_isV_reg,
          dec_rT_isV_reg,
          cls_flag_reg,
          
          {dec_rndmode_reg[0],dec_alucond_reg[0],dec_operation_reg[0]},
          {dec_rndmode_reg[1],dec_alucond_reg[1],dec_operation_reg[1]},
          {dec_rndmode_reg[2],dec_alucond_reg[2],dec_operation_reg[2]},
          {dec_rndmode_reg[3],dec_alucond_reg[3],dec_operation_reg[3]},
          {dec_rndmode_reg[4],dec_alucond_reg[4],dec_operation_reg[4]},
          {dec_rndmode_reg[5],dec_alucond_reg[5],dec_operation_reg[5]},
          {dec_rndmode_reg[6],dec_alucond_reg[6],dec_operation_reg[6]},
          {dec_rndmode_reg[7],dec_alucond_reg[7],dec_operation_reg[7]},
          {dec_rndmode_reg[8],dec_alucond_reg[8],dec_operation_reg[8]},
          {dec_rndmode_reg[9],dec_alucond_reg[9],dec_operation_reg[9]},

          dep_rA[0],
          dep_rA[1],
          dep_rA[2],
          dep_rA[3],
          dep_rA[4],
          dep_rA[5],
          dep_rA[6],
          dep_rA[7],
          dep_rA[8],
          dep_rA[9],

          dec_rA_use_reg[0],
          dec_rA_use_reg[1],
          dec_rA_use_reg[2],
          dec_rA_use_reg[3],
          dec_rA_use_reg[4],
          dec_rA_use_reg[5],
          dec_rA_use_reg[6],
          dec_rA_use_reg[7],
          dec_rA_use_reg[8],
          dec_rA_use_reg[9],

          dec_rA_useF_reg[0],
          dec_rA_useF_reg[1],
          dec_rA_useF_reg[2],
          dec_rA_useF_reg[3],
          dec_rA_useF_reg[4],
          dec_rA_useF_reg[5],
          dec_rA_useF_reg[6],
          dec_rA_useF_reg[7],
          dec_rA_useF_reg[8],
          dec_rA_useF_reg[9],
          
          dec_useAConst_reg[0],
          dec_useAConst_reg[1],
          dec_useAConst_reg[2],
          dec_useAConst_reg[3],
          dec_useAConst_reg[4],
          dec_useAConst_reg[5],
          dec_useAConst_reg[6],
          dec_useAConst_reg[7],
          dec_useAConst_reg[8],
          dec_useAConst_reg[9],

          dep_rB[0],
          dep_rB[1],
          dep_rB[2],
          dep_rB[3],
          dep_rB[4],
          dep_rB[5],
          dep_rB[6],
          dep_rB[7],
          dep_rB[8],
          dep_rB[9],

          dec_rB_use_reg[0],
          dec_rB_use_reg[1],
          dec_rB_use_reg[2],
          dec_rB_use_reg[3],
          dec_rB_use_reg[4],
          dec_rB_use_reg[5],
          dec_rB_use_reg[6],
          dec_rB_use_reg[7],
          dec_rB_use_reg[8],
          dec_rB_use_reg[9],

          dec_rB_useF_reg[0],
          dec_rB_useF_reg[1],
          dec_rB_useF_reg[2],
          dec_rB_useF_reg[3],
          dec_rB_useF_reg[4],
          dec_rB_useF_reg[5],
          dec_rB_useF_reg[6],
          dec_rB_useF_reg[7],
          dec_rB_useF_reg[8],
          dec_rB_useF_reg[9],

          dec_useBConst_reg[0],
          dec_useBConst_reg[1],
          dec_useBConst_reg[2],
          dec_useBConst_reg[3],
          dec_useBConst_reg[4],
          dec_useBConst_reg[5],
          dec_useBConst_reg[6],
          dec_useBConst_reg[7],
          dec_useBConst_reg[8],
          dec_useBConst_reg[9],

          dec_constant_reg[0]|~dec_constantN_reg[0],
          dec_constant_reg[1]|~dec_constantN_reg[1],
          dec_constant_reg[2]|~dec_constantN_reg[2],
          dec_constant_reg[3]|~dec_constantN_reg[3],
          dec_constant_reg[4]|~dec_constantN_reg[4],
          dec_constant_reg[5]|~dec_constantN_reg[5],
          dec_constant_reg[6]|~dec_constantN_reg[6],
          dec_constant_reg[7]|~dec_constantN_reg[7],
          dec_constant_reg[8]|~dec_constantN_reg[8],
          dec_constant_reg[9]|~dec_constantN_reg[9],
          
          aux_const,
          cls_sys_reg,
          
          dep_rC[0],
          dep_rC[1],
          dep_rC[2],
          dep_rC[3],
          dep_rC[4],
          dep_rC[5],
          dep_rC[6],
          dep_rC[7],
          dep_rC[8],
          dep_rC[9],

          dec_rC_use_reg[0],
          dec_rC_use_reg[1],
          dec_rC_use_reg[2],
          dec_rC_use_reg[3],
          dec_rC_use_reg[4],
          dec_rC_use_reg[5],
          dec_rC_use_reg[6],
          dec_rC_use_reg[7],
          dec_rC_use_reg[8],
          dec_rC_use_reg[9],

          dec_rC_useF_reg[0],
          dec_rC_useF_reg[1],
          dec_rC_useF_reg[2],
          dec_rC_useF_reg[3],
          dec_rC_useF_reg[4],
          dec_rC_useF_reg[5],
          dec_rC_useF_reg[6],
          dec_rC_useF_reg[7],
          dec_rC_useF_reg[8],
          dec_rC_useF_reg[9],

          dec_rT_reg[0],
          dec_rT_reg[1],
          dec_rT_reg[2],
          dec_rT_reg[3],
          dec_rT_reg[4],
          dec_rT_reg[5],
          dec_rT_reg[6],
          dec_rT_reg[7],
          dec_rT_reg[8],
          dec_rT_reg[9],

          dec_rT_use_reg[0],
          dec_rT_use_reg[1],
          dec_rT_use_reg[2],
          dec_rT_use_reg[3],
          dec_rT_use_reg[4],
          dec_rT_use_reg[5],
          dec_rT_use_reg[6],
          dec_rT_use_reg[7],
          dec_rT_use_reg[8],
          dec_rT_use_reg[9],

          dec_rT_useF_reg[0],
          dec_rT_useF_reg[1],
          dec_rT_useF_reg[2],
          dec_rT_useF_reg[3],
          dec_rT_useF_reg[4],
          dec_rT_useF_reg[5],
          dec_rT_useF_reg[6],
          dec_rT_useF_reg[7],
          dec_rT_useF_reg[8],
          dec_rT_useF_reg[9],

          
          dec_port_reg[0],
          dec_port_reg[1],
          dec_port_reg[2],
          dec_port_reg[3],
          dec_port_reg[4],
          dec_port_reg[5],
          dec_port_reg[6],
          dec_port_reg[7],
          dec_port_reg[8],
          dec_port_reg[9],

          dec_useRs_reg[0],
          dec_useRs_reg[1],
          dec_useRs_reg[2],
          dec_useRs_reg[3],
          dec_useRs_reg[4],
          dec_useRs_reg[5],
          dec_useRs_reg[6],
          dec_useRs_reg[7],
          dec_useRs_reg[8],
          dec_useRs_reg[9],
          
          dec_srcIPOffx[0],
          dec_srcIPOffx[1],
          dec_srcIPOffx[2],
          dec_srcIPOffx[3],
          dec_srcIPOffx[4],
          dec_srcIPOffx[5],
          dec_srcIPOffx[6],
          dec_srcIPOffx[7],
          dec_srcIPOffx[8],
          dec_srcIPOffx[9],
          
          flag_dep[0],
          flag_dep[1],
          flag_dep[2],
          flag_dep[3],
          flag_dep[4],
          flag_dep[5],
          flag_dep[6],
          flag_dep[7],
          flag_dep[8],
          flag_dep[9],
          
          dec_afterTaken_reg
          );

          decoder_find_single_dep depA_mod(
          dec_rT_reg[0],dec_rT_use_reg[0] && k>0,dec_rT_useF_reg[0] && (k>0)|(k==0&cls_loadFPU_reg[k-1]),
          k==1 ? dec_rT_reg[1-1] : dec_rT_reg[1],dec_rT_use_reg[1] && k>1,dec_rT_useF_reg[1] && (k>1)|(k==1&cls_loadFPU_reg[k-1]),
          k==2 ? dec_rT_reg[2-1] : dec_rT_reg[2],dec_rT_use_reg[2] && k>2,dec_rT_useF_reg[2] && (k>2)|(k==2&cls_loadFPU_reg[k-1]),
          k==3 ? dec_rT_reg[3-1] : dec_rT_reg[3],dec_rT_use_reg[3] && k>3,dec_rT_useF_reg[3] && (k>3)|(k==3&cls_loadFPU_reg[k-1]),
          k==4 ? dec_rT_reg[4-1] : dec_rT_reg[4],dec_rT_use_reg[4] && k>4,dec_rT_useF_reg[4] && (k>4)|(k==4&cls_loadFPU_reg[k-1]),
          k==5 ? dec_rT_reg[5-1] : dec_rT_reg[5],dec_rT_use_reg[5] && k>5,dec_rT_useF_reg[5] && (k>5)|(k==5&cls_loadFPU_reg[k-1]),
          k==6 ? dec_rT_reg[6-1] : dec_rT_reg[6],dec_rT_use_reg[6] && k>6,dec_rT_useF_reg[6] && (k>6)|(k==6&cls_loadFPU_reg[k-1]),
          k==7 ? dec_rT_reg[7-1] : dec_rT_reg[7],dec_rT_use_reg[7] && k>7,dec_rT_useF_reg[7] && (k>7)|(k==7&cls_loadFPU_reg[k-1]),
          k==8 ? dec_rT_reg[8-1] : dec_rT_reg[8],dec_rT_use_reg[8] && k>8,dec_rT_useF_reg[8] && (k>8)|(k==8&cls_loadFPU_reg[k-1]),
          dec_rA_reg[k],dec_rA_useF_reg[k],
          dep_rA[k]
          );

          decoder_find_single_dep depB_mod(
          dec_rT_reg[0],dec_rT_use_reg[0] && k>0,dec_rT_useF_reg[0] && (k>0)|(k==0&cls_loadFPU_reg[k-1]),
          k==1 ? dec_rT_reg[1-1] : dec_rT_reg[1],dec_rT_use_reg[1] && k>1,dec_rT_useF_reg[1] && (k>1)|(k==1&cls_loadFPU_reg[k-1]),
          k==2 ? dec_rT_reg[2-1] : dec_rT_reg[2],dec_rT_use_reg[2] && k>2,dec_rT_useF_reg[2] && (k>2)|(k==2&cls_loadFPU_reg[k-1]),
          k==3 ? dec_rT_reg[3-1] : dec_rT_reg[3],dec_rT_use_reg[3] && k>3,dec_rT_useF_reg[3] && (k>3)|(k==3&cls_loadFPU_reg[k-1]),
          k==4 ? dec_rT_reg[4-1] : dec_rT_reg[4],dec_rT_use_reg[4] && k>4,dec_rT_useF_reg[4] && (k>4)|(k==4&cls_loadFPU_reg[k-1]),
          k==5 ? dec_rT_reg[5-1] : dec_rT_reg[5],dec_rT_use_reg[5] && k>5,dec_rT_useF_reg[5] && (k>5)|(k==5&cls_loadFPU_reg[k-1]),
          k==6 ? dec_rT_reg[6-1] : dec_rT_reg[6],dec_rT_use_reg[6] && k>6,dec_rT_useF_reg[6] && (k>6)|(k==6&cls_loadFPU_reg[k-1]),
          k==7 ? dec_rT_reg[7-1] : dec_rT_reg[7],dec_rT_use_reg[7] && k>7,dec_rT_useF_reg[7] && (k>7)|(k==7&cls_loadFPU_reg[k-1]),
          k==8 ? dec_rT_reg[8-1] : dec_rT_reg[8],dec_rT_use_reg[8] && k>8,dec_rT_useF_reg[8] && (k>8)|(k==8&cls_loadFPU_reg[k-1]),
          dec_rB_reg[k],dec_rB_useF_reg[k],
          dep_rB[k]
          );
          
          decoder_find_single_dep depC_mod(
          dec_rT_reg[0],dec_rT_use_reg[0] && k>0,dec_rT_useF_reg[0] && (k>0)|(k==0&cls_loadFPU_reg[k-1]),
          k==1 ? dec_rT_reg[1-1] : dec_rT_reg[1],dec_rT_use_reg[1] && k>1,dec_rT_useF_reg[1] && (k>1)|(k==1&cls_loadFPU_reg[k-1]),
          k==2 ? dec_rT_reg[2-1] : dec_rT_reg[2],dec_rT_use_reg[2] && k>2,dec_rT_useF_reg[2] && (k>2)|(k==2&cls_loadFPU_reg[k-1]),
          k==3 ? dec_rT_reg[3-1] : dec_rT_reg[3],dec_rT_use_reg[3] && k>3,dec_rT_useF_reg[3] && (k>3)|(k==3&cls_loadFPU_reg[k-1]),
          k==4 ? dec_rT_reg[4-1] : dec_rT_reg[4],dec_rT_use_reg[4] && k>4,dec_rT_useF_reg[4] && (k>4)|(k==4&cls_loadFPU_reg[k-1]),
          k==5 ? dec_rT_reg[5-1] : dec_rT_reg[5],dec_rT_use_reg[5] && k>5,dec_rT_useF_reg[5] && (k>5)|(k==5&cls_loadFPU_reg[k-1]),
          k==6 ? dec_rT_reg[6-1] : dec_rT_reg[6],dec_rT_use_reg[6] && k>6,dec_rT_useF_reg[6] && (k>6)|(k==6&cls_loadFPU_reg[k-1]),
          k==7 ? dec_rT_reg[7-1] : dec_rT_reg[7],dec_rT_use_reg[7] && k>7,dec_rT_useF_reg[7] && (k>7)|(k==7&cls_loadFPU_reg[k-1]),
          k==8 ? dec_rT_reg[8-1] : dec_rT_reg[8],dec_rT_use_reg[8] && k>8,dec_rT_useF_reg[8] && (k>8)|(k==8&cls_loadFPU_reg[k-1]),
          dec_rC_reg[k],dec_rC_useF_reg[k],
          dep_rC[k]
          );

          decoder_find_alloc alloc_mod(
          dec_rT_reg[1],dec_rT_use_reg[1] && k<1,dec_rT_useF_reg[1] && k<1,
          dec_rT_reg[2],dec_rT_use_reg[2] && k<2,dec_rT_useF_reg[2] && k<2,
          dec_rT_reg[3],dec_rT_use_reg[3] && k<3,dec_rT_useF_reg[3] && k<3,
          dec_rT_reg[4],dec_rT_use_reg[4] && k<4,dec_rT_useF_reg[4] && k<4,
          dec_rT_reg[5],dec_rT_use_reg[5] && k<5,dec_rT_useF_reg[5] && k<5,
          dec_rT_reg[6],dec_rT_use_reg[6] && k<6,dec_rT_useF_reg[6] && k<6,
          dec_rT_reg[7],dec_rT_use_reg[7] && k<7,dec_rT_useF_reg[7] && k<7,
          dec_rT_reg[8],dec_rT_use_reg[8] && k<8,dec_rT_useF_reg[8] && k<8,
          dec_rT_reg[9],dec_rT_use_reg[9] && k<9,dec_rT_useF_reg[9] && k<9,
          dec_rT_reg[k],dec_rT_use_reg[k],dec_rT_useF_reg[k],
          alloc[k],allocF[k]
          );

          decoder_flag_dep depFL_mod(
          {
            dec_wrFlags_reg[8] && k>8,
            dec_wrFlags_reg[7] && k>7,
            dec_wrFlags_reg[6] && k>6,
            dec_wrFlags_reg[5] && k>5,
            dec_wrFlags_reg[4] && k>4,
            dec_wrFlags_reg[3] && k>3,
            dec_wrFlags_reg[2] && k>2,
            dec_wrFlags_reg[1] && k>1,
            dec_wrFlags_reg[0] && k>0
          },
          dec_useFlags_reg[k],
          flag_dep[k]
          );
          
          decoder_flag_wr flagWr_mod(
          {
            dec_wrFlags_reg[9] && k<9,
            dec_wrFlags_reg[8] && k<8,
            dec_wrFlags_reg[7] && k<7,
            dec_wrFlags_reg[6] && k<6,
            dec_wrFlags_reg[5] && k<5,
            dec_wrFlags_reg[4] && k<4,
            dec_wrFlags_reg[3] && k<3,
            dec_wrFlags_reg[2] && k<2,
            dec_wrFlags_reg[1] && k<1
          },
          dec_wrFlags_reg[k],
          flag_lastWr[k]
          );
          
          
          assign afterTick[k]=(|dec_tick[k:0]);
          if (k>0) assign dec_afterTaken[k]=(|dec_taken[k-1:0]);
          else assign dec_afterTaken[0]=1'b0;
          
          if (k<9) begin
              assign dec_lspecR_d=(iUsed[k+:2]==2'b01) ? dec_lspec[k] : 1'bz;
              assign instr_save_d=(iUsed[k+:2]==2'b01) ? instr[k] : 15'bz;
              assign was_FMA_last_d=(iUsed[k+:2]==2'b01) ? instrQ[`instrQ_class+`iclass_store2] : 1'bz;
          end else begin
              assign dec_lspecR_d=iUsed[k] ? dec_lspec[k] : 1'bz;
              assign instr_save_d=iUsed[k] ? instr[k] : 15'bz;
              assign was_FMA_last_d=iUsed[k] ? instrQ[`instrQ_class+`iclass_store2] : 1'bz;
          end
      end
  endgenerate
  
  assign dec_lspec[-1]=dec_lspecR;
  assign dec_lspecR_d=(~iUsed[0]) ? dec_lspecR : 1'bz;
  assign was_FMA_last_d=(~iUsed[0]) ? was_FMA_last : 1'bz;
  assign instr_save_d=(~iUsed[0]) ? instr_save : 15'bz;

  assign msrss_retIP_data=msrss_retIP_en_reg==10'b0 ? 64'b0 : 64'bz;
  assign msrss_retIP_data[63:44]=msrss_retIP_en_reg!=10'b0 ? {baseAttr[0],baseAttr[1],1'b0,baseAttr[3],16'b0} : 20'bz; 
  assign msrss_retIP_data[0]=msrss_retIP_en_reg!=10'b0 ? 1'b0 : 1'bz; 

  assign has_taken=|(dec_taken & iUsed);
  assign has_tick=|(dec_tick & iUsed);
 
  assign has_mul=|(cls_mul_reg&iUsed_reg); 

  assign rs0i0_index=(&rs_index[0][1:0]) ? 4'hf : 4'bz;
  assign rs1i0_index=(&rs_index[1][1:0]) ? 4'hf : 4'bz;
  assign rs2i0_index=(&rs_index[2][1:0]) ? 4'hf : 4'bz;
  assign rs0i1_index=(&rs_index[3][1:0]) ? 4'hf : 4'bz;
  assign rs1i1_index=(&rs_index[4][1:0]) ? 4'hf : 4'bz;
  assign rs2i1_index=(&rs_index[5][1:0]) ? 4'hf : 4'bz;
  assign rs0i2_index=(&rs_index[6][1:0]) ? 4'hf : 4'bz;
  assign rs1i2_index=(&rs_index[7][1:0]) ? 4'hf : 4'bz;
  assign rs2i2_index=(&rs_index[8][1:0]) ? 4'hf : 4'bz;

  assign jump0Pos=jump0_bit!=0 ? 4'bz : 4'hf;
  assign jump1Pos=jump1_bit!=0 ? 4'bz : 4'hf;

  assign jump0Type=jump0_bit!=0 ? 5'bz : 5'h10;
  assign jump1Type=jump1_bit!=0 ? 5'bz : 5'h10;

  assign jump0Taken=jump0_bit!=0 ? 1'bz : 1'b0;
  assign jump1Taken=jump1_bit!=0 ? 1'bz : 1'b0;
  
  assign jump0BtbWay=jump0_bit!=0 ? 1'bz : 1'b0;
  assign jump1BtbWay=jump1_bit!=0 ? 1'bz : 1'b0;

  assign jump0JmpInd=jump0_bit!=0 ? 2'bz : 2'b0;
  assign jump1JmpInd=jump1_bit!=0 ? 2'bz : 2'b0;

  assign jump0GHT=jump0_bit!=0 ? 8'bz : 8'b0;
  assign jump1GHT=jump1_bit!=0 ? 8'bz : 8'b0;

  assign jump0GHT2=jump0_bit!=0 ? 16'bz : 16'b0;
  assign jump1GHT2=jump1_bit!=0 ? 16'bz : 16'b0;

  assign jump0Val=jump0_bit!=0 ? 1'bz : 1'b0;
  assign jump1Val=jump1_bit!=0 ? 1'bz : 1'b0;

  assign jump0SC=jump0_bit!=0 ? 2'bz : 2'b0;
  assign jump1SC=jump1_bit!=0 ? 2'bz : 2'b0;

  assign jump0Miss=jump0_bit!=0 ? 1'bz : 1'b0;
  assign jump1Miss=jump1_bit!=0 ? 1'bz : 1'b0;

  assign jump0TbufOnly=jump0_bit!=0 ? 1'bz : 1'b0;
  assign jump1TbufOnly=jump1_bit!=0 ? 1'bz : 1'b0;
  
  decoder_permitted_i permi_mod(
  .branch(cls_jump),
  .taken(dec_taken),
  .indir(cls_indir),
  .alu(cls_ALU),
  .shift(cls_shift),
  .load(cls_load),
  .store(cls_store),
  .storeL(cls_storeI),
  .fma(cls_store2),
  .mul(cls_mul),
  .sys(cls_sys),
  .pos0(cls_pos0),
  .FPU(cls_FPU),
  .spec(cls_loadFPU),
  .specNext(10'b0),//unused by module
  .iAvail(iAvail0),
  .stall(stall),
  .halt(dec_halt[0]),
  .allret(all_retired),
  .perm(iUsed)
  );

  assign iAvail=iAvail0&{10{~stall_issue}};

  distrib distr_mod(
  clk,
  rst,
  stall,
  cls_ALU_reg & iUsed_reg,
  cls_shift_reg & iUsed_reg,
  cls_load_reg & iUsed_reg,
  cls_store_reg & iUsed_reg,
  cls_storeI_reg & iUsed_reg,//12,8 bit and misaligned
  cls_store_reg & iUsed_reg,//base+index
  cls_FPU_reg & iUsed_reg,
  cls_loadFPU_reg & iUsed_reg,
  cls_mul_reg & iUsed_reg,
  rs_index[0],
  rs_index[1],
  rs_index[2],
  rs_index[3],
  rs_index[4],
  rs_index[5],
  rs_index[6],
  rs_index[7],
  rs_index[8],
  rs_store[0],
  rs_store[1],
  rs_store[2],
  rs_storeL[0],
  rs_storeL[1],
  rs_storeL[2],
  rs_storeDA,
  rs_storeDB,
  rs_alt,
  rs_lsi[0],
  rs_lsi[1],
  rs_lsi[2],
  rs_lsi[3],
  rs_lsi[4],
  rs_lsi[5],
  wrt0,
  wrt1,
  wrt2
  );
  
  bit_find_first_bit #(10) jump0_mod(cls_jump|cls_indir,jump0,hasJump0);
  bit_find_first_bit #(10) jump1_mod((cls_jump|cls_indir)&~jump0,jump1,hasJump1);

  decoder_jpos jpos_mod(
  .jump(cls_jump_reg),
  .used(iUsed_reg),
  .jump0(jump0_bit),
  .jump1(jump1_bit)
  );
  decoder_aux_const csrconst_mod(
  .clk(clk),
  .rst(rst),
  .stall(stall),
  .fat_stall_en(fat_stall_en),
  .cls_sys(cls_sys),
  .instr0(inst[0][31:0]),
  .instr1(inst[1][31:0]),
  .instr2(inst[2][31:0]),
  .instr3(inst[3][31:0]),
  .instr4(inst[4][31:0]),
  .instr5(inst[5][31:0]),
  .instr6(inst[6][31:0]),
  .instr7(inst[7][31:0]),
  .instr8(inst[8][31:0]),
  .instr9(inst[9][31:0]),
  .aux_const(aux_const),
  .aux_can_jump(aux_can_jump),
  .aux_can_read(aux_can_read),
  .aux_can_write(aux_can_write),
  .msrss_no(msrss_no),
  .msrss_en(msrss_en),
  .msrss_data(msrss_data),
  .fpE_en(fp_excpt_en),
  .fpE_set(fp_excpt_set),
  .fpE_thr(fp_excpt_thr),
  .altEn(msrss_retIP_en_reg!=0),
  .altData(msrss_retIP_data),
  .altThr2(GORQ_thr),
  .altEn2(GORQ),
  .altData2(GORQ_data),
  .thread(thread),
  .riscmode(riscmode),
  .disstruss(lizztruss),
  .thrmode(thrmode),
  .doStall(stall_issue)
);

  decoder_get_baseIP getIP_mod(
  .clk(clk),
  .rst(rst),
  .baseIP(baseIP),
  .baseAttr(baseAttr),
  //base_traceIP,
  .afterTK(dec_afterTaken_reg&iUsed_reg&{10{~stall}}),
  .iUsed(iUsed_reg&{10{~stall}}),
  .afterTick(afterTick_reg&iUsed_reg&{10{~stall}}),
  .srcIPOff0(dec_srcIPOff_reg[0]),
  .srcIPOff1(dec_srcIPOff_reg[1]),
  .srcIPOff2(dec_srcIPOff_reg[2]),
  .srcIPOff3(dec_srcIPOff_reg[3]),
  .srcIPOff4(dec_srcIPOff_reg[4]),
  .srcIPOff5(dec_srcIPOff_reg[5]),
  .srcIPOff6(dec_srcIPOff_reg[6]),
  .srcIPOff7(dec_srcIPOff_reg[7]),
  .srcIPOff8(dec_srcIPOff_reg[8]),
  .srcIPOff9(dec_srcIPOff_reg[9]),
  .jump0IP(jqe_IP0),.jump0TK(jump0Taken&~stall),.jump0Attr(jqe_attr0),
  .jump1IP(jqe_IP1),.jump1TK(jump1Taken&~stall),.jump1Attr(jqe_attr1),
  .except(except),
  .exceptIP(exceptIP[63:1]),
  .exceptAttr(exceptAttr)
  );

  assign rs_store[8:3]=6'b0;
  assign rs_storeL[8:3]=6'b0;
  
  assign  inst[0]= inst0;
  assign instQ[0]=instQ0;
  assign  inst[1]= inst1;
  assign instQ[1]=instQ1;
  assign  inst[2]= inst2;
  assign instQ[2]=instQ2;
  assign  inst[3]= inst3;
  assign instQ[3]=instQ3;
  assign  inst[4]= inst4;
  assign instQ[4]=instQ4;
  assign  inst[5]= inst5;
  assign instQ[5]=instQ5;
  assign  inst[6]= inst6;
  assign instQ[6]=instQ6;
  assign  inst[7]= inst7;
  assign instQ[7]=instQ7;
  assign  inst[8]= inst8;
  assign instQ[8]=instQ8;
  assign  inst[9]= inst9;
  assign instQ[9]=instQ9;

  assign rs0i0_operation=rs_operation[0];
  assign rs0i0_rA=rs_rA[0];
  assign rs0i0_rA_use=rs_rA_use[0];
  assign rs0i0_rA_useF=rs_rA_useF[0];
  assign rs0i0_rA_isV=rs_rA_isV[0];
  assign rs0i0_rA_isAnyV=rs_rA_isAnyV[0];
  assign rs0i0_rB=rs_rB[0];
  assign rs0i0_rB_use=rs_rB_use[0];
  assign rs0i0_rB_useF=rs_rB_useF[0];
  assign rs0i0_rB_isV=rs_rB_isV[0];
  assign rs0i0_rB_isAnyV=rs_rB_isAnyV[0];
  assign rs0i0_useBConst=rs_useBConst[0];
  assign rs0i0_const=rs_constant[0];
  assign rs0i0_rT=rs_rT[0];
  assign rs0i0_rT_use=rs_rT_use[0];
  assign rs0i0_rT_useF=rs_rT_useF[0];
  assign rs0i0_rT_isV=rs_rT_isV[0];
  assign rs0i0_port=rs_port[0];
  assign rs0i0_en=rs_useRs[0];
  assign rs0i0_IPRel=rs_IPRel[0];
  assign rs0i0_afterTaken=rs_afterTaken[0];
  assign rs0i0_alt=rs_alt[0];
  assign rs0i0_alloc=rs_alloc[0];
  assign rs0i0_allocF=rs_allocF[0];
  assign rs0i0_allocR=rs_allocR[0];
  assign rs0i0_lsi=rs_lsi[0];
  assign rs0i0_ldst_flag=rs_ldst_flag[0];
  assign rs0i0_enA=rs_enA[0];
  assign rs0i0_enB=rs_enB[0];
  
  assign rs0i1_operation=rs_operation[3];
  assign rs0i1_rA=rs_rA[3];
  assign rs0i1_rA_use=rs_rA_use[3];
  assign rs0i1_rA_useF=rs_rA_useF[3];
  assign rs0i1_rA_isV=rs_rA_isV[3];
  assign rs0i1_rA_isAnyV=rs_rA_isAnyV[3];
  assign rs0i1_useAConst=rs_useAConst[3];
  assign rs0i1_rB=rs_rB[3];
  assign rs0i1_rB_use=rs_rB_use[3];
  assign rs0i1_rB_useF=rs_rB_useF[3];
  assign rs0i1_rB_isV=rs_rB_isV[3];
  assign rs0i1_rB_isAnyV=rs_rB_isAnyV[3];
  assign rs0i1_useBConst=rs_useBConst[3];
  assign rs0i1_const=rs_constant[3];
  assign rs0i1_rT=rs_rT[3];
  assign rs0i1_rT_use=rs_rT_use[3];
  assign rs0i1_rT_useF=rs_rT_useF[3];
  assign rs0i1_rT_isV=rs_rT_isV[3];
  assign rs0i1_port=rs_port[3];
  assign rs0i1_en=rs_useRs[3];
  assign rs0i1_IPRel=rs_IPRel[3];
  assign rs0i1_afterTaken=rs_afterTaken[3];
  assign rs0i1_alloc=rs_alloc[3];
  assign rs0i1_allocF=rs_allocF[3];
  assign rs0i1_allocR=rs_allocR[3];
  assign rs0i1_flagDep=rs_flDep[3];
  assign rs0i1_lastFl=rs_lastFl[3];
  assign rs0i1_lsi=rs_lsi[3];
  assign rs0i1_ldst_flag=rs_ldst_flag[3];
  assign rs0i1_flag_wr=rs_flagWr[3];

  assign rs0i2_operation=rs_operation[6];
  assign rs0i2_rA=rs_rA[6];
  assign rs0i2_rA_use=rs_rA_use[6];
  assign rs0i2_rA_useF=rs_rA_useF[6];
  assign rs0i2_rA_isV=rs_rA_isV[6];
  assign rs0i2_rA_isAnyV=rs_rA_isAnyV[6];
  assign rs0i2_useAConst=rs_useAConst[6];
  assign rs0i2_rB=rs_rB[6];
  assign rs0i2_rB_use=rs_rB_use[6];
  assign rs0i2_rB_useF=rs_rB_useF[6];
  assign rs0i2_rB_isV=rs_rB_isV[6];
  assign rs0i2_rB_isAnyV=rs_rB_isAnyV[6];
  assign rs0i2_useBConst=rs_useBConst[6];
  assign rs0i2_const=rs_constant[6];
  assign rs0i2_rT=rs_rT[6];
  assign rs0i2_rT_use=rs_rT_use[6];
  assign rs0i2_rT_useF=rs_rT_useF[6];
  assign rs0i2_rT_isV=rs_rT_isV[6];
  assign rs0i2_port=rs_port[6];
  assign rs0i2_en=rs_useRs[6];
  assign rs0i2_IPRel=rs_IPRel[6];
  assign rs0i2_afterTaken=rs_afterTaken[6];
  assign rs0i2_alloc=rs_alloc[6];
  assign rs0i2_allocF=rs_allocF[6];
  assign rs0i2_allocR=rs_allocR[6];
  assign rs0i2_flagDep=rs_flDep[6];
  assign rs0i2_lastFl=rs_lastFl[6];
  assign rs0i2_flag_wr=rs_flagWr[6];

  assign rs1i0_operation=rs_operation[1];
  assign rs1i0_rA=rs_rA[1];
  assign rs1i0_rA_use=rs_rA_use[1];
  assign rs1i0_rA_useF=rs_rA_useF[1];
  assign rs1i0_rA_isV=rs_rA_isV[1];
  assign rs1i0_rA_isAnyV=rs_rA_isAnyV[1];
  assign rs1i0_rB=rs_rB[1];
  assign rs1i0_rB_use=rs_rB_use[1];
  assign rs1i0_rB_useF=rs_rB_useF[1];
  assign rs1i0_rB_isV=rs_rB_isV[1];
  assign rs1i0_rB_isAnyV=rs_rB_isAnyV[1];
  assign rs1i0_useBConst=rs_useBConst[1];
  assign rs1i0_const=rs_constant[1];
  assign rs1i0_rT=rs_rT[1];
  assign rs1i0_rT_use=rs_rT_use[1];
  assign rs1i0_rT_useF=rs_rT_useF[1];
  assign rs1i0_rT_isV=rs_rT_isV[1];
  assign rs1i0_port=rs_port[1];
  assign rs1i0_en=rs_useRs[1];
  assign rs1i0_IPRel=rs_IPRel[1];
  assign rs1i0_afterTaken=rs_afterTaken[1];
  assign rs1i0_alt=rs_alt[1];
  assign rs1i0_alloc=rs_alloc[1];
  assign rs1i0_allocF=rs_allocF[1];
  assign rs1i0_allocR=rs_allocR[1];
  assign rs1i0_lsi=rs_lsi[1];
  assign rs1i0_ldst_flag=rs_ldst_flag[1];
  assign rs1i0_enA=rs_enA[1];
  assign rs1i0_enB=rs_enB[1];

  assign rs1i1_operation=rs_operation[4];
  assign rs1i1_rA=rs_rA[4];
  assign rs1i1_rA_use=rs_rA_use[4];
  assign rs1i1_rA_useF=rs_rA_useF[4];
  assign rs1i1_rA_isV=rs_rA_isV[4];
  assign rs1i1_rA_isAnyV=rs_rA_isAnyV[4];
  assign rs1i1_useAConst=rs_useAConst[4];
  assign rs1i1_rB=rs_rB[4];
  assign rs1i1_rB_use=rs_rB_use[4];
  assign rs1i1_rB_useF=rs_rB_useF[4];
  assign rs1i1_rB_isV=rs_rB_isV[4];
  assign rs1i1_rB_isAnyV=rs_rB_isAnyV[4];
  assign rs1i1_useBConst=rs_useBConst[4];
  assign rs1i1_const=rs_constant[4];
  assign rs1i1_rT=rs_rT[4];
  assign rs1i1_rT_use=rs_rT_use[4];
  assign rs1i1_rT_useF=rs_rT_useF[4];
  assign rs1i1_rT_isV=rs_rT_isV[4];
  assign rs1i1_port=rs_port[4];
  assign rs1i1_en=rs_useRs[4];
  assign rs1i1_IPRel=rs_IPRel[4];
  assign rs1i1_afterTaken=rs_afterTaken[4];
  assign rs1i1_alloc=rs_alloc[4];
  assign rs1i1_allocF=rs_allocF[4];
  assign rs1i1_allocR=rs_allocR[4];
  assign rs1i1_flagDep=rs_flDep[4];
  assign rs1i1_lastFl=rs_lastFl[4];
  assign rs1i1_lsi=rs_lsi[4];
  assign rs1i1_ldst_flag=rs_ldst_flag[4];
  assign rs1i1_flag_wr=rs_flagWr[4];

  assign rs1i2_operation=rs_operation[7];
  assign rs1i2_rA=rs_rA[7];
  assign rs1i2_rA_use=rs_rA_use[7];
  assign rs1i2_rA_useF=rs_rA_useF[7];
  assign rs1i2_rA_isV=rs_rA_isV[7];
  assign rs1i2_rA_isAnyV=rs_rA_isAnyV[7];
  assign rs1i2_useAConst=rs_useAConst[7];
  assign rs1i2_rB=rs_rB[7];
  assign rs1i2_rB_use=rs_rB_use[7];
  assign rs1i2_rB_useF=rs_rB_useF[7];
  assign rs1i2_rB_isV=rs_rB_isV[7];
  assign rs1i2_rB_isAnyV=rs_rB_isAnyV[7];
  assign rs1i2_useBConst=rs_useBConst[7];
  assign rs1i2_const=rs_constant[7];
  assign rs1i2_rT=rs_rT[7];
  assign rs1i2_rT_use=rs_rT_use[7];
  assign rs1i2_rT_useF=rs_rT_useF[7];
  assign rs1i2_rT_isV=rs_rT_isV[7];
  assign rs1i2_port=rs_port[7];
  assign rs1i2_en=rs_useRs[7];
  assign rs1i2_IPRel=rs_IPRel[7];
  assign rs1i2_afterTaken=rs_afterTaken[7];
  assign rs1i2_alloc=rs_alloc[7];
  assign rs1i2_allocF=rs_allocF[7];
  assign rs1i2_allocR=rs_allocR[7];
  assign rs1i2_flagDep=rs_flDep[7];
  assign rs1i2_lastFl=rs_lastFl[7];
  assign rs1i2_flag_wr=rs_flagWr[7];

  assign rs2i0_operation=rs_operation[2];
  assign rs2i0_rA=rs_rA[2];
  assign rs2i0_rA_use=rs_rA_use[2];
  assign rs2i0_rA_useF=rs_rA_useF[2];
  assign rs2i0_rA_isV=rs_rA_isV[2];
  assign rs2i0_rA_isAnyV=rs_rA_isAnyV[2];
  assign rs2i0_rB=rs_rB[2];
  assign rs2i0_rB_use=rs_rB_use[2];
  assign rs2i0_rB_useF=rs_rB_useF[2];
  assign rs2i0_rB_isV=rs_rB_isV[2];
  assign rs2i0_rB_isAnyV=rs_rB_isAnyV[2];
  assign rs2i0_useBConst=rs_useBConst[2];
  assign rs2i0_const=rs_constant[2];
  assign rs2i0_rT=rs_rT[2];
  assign rs2i0_rT_use=rs_rT_use[2];
  assign rs2i0_rT_useF=rs_rT_useF[2];
  assign rs2i0_rT_isV=rs_rT_isV[2];
  assign rs2i0_port=rs_port[2];
  assign rs2i0_en=rs_useRs[2];
  assign rs2i0_IPRel=rs_IPRel[2];
  assign rs2i0_afterTaken=rs_afterTaken[2];
  assign rs2i0_alt=rs_alt[2];
  assign rs2i0_alloc=rs_alloc[2];
  assign rs2i0_allocF=rs_allocF[2];
  assign rs2i0_allocR=rs_allocR[2];
  assign rs2i0_lsi=rs_lsi[2];
  assign rs2i0_ldst_flag=rs_ldst_flag[2];
  assign rs2i0_enA=rs_enA[2];
  assign rs2i0_enB=rs_enB[2];

  assign rs2i1_operation=rs_operation[5];
  assign rs2i1_rA=rs_rA[5];
  assign rs2i1_rA_use=rs_rA_use[5];
  assign rs2i1_rA_useF=rs_rA_useF[5];
  assign rs2i1_rA_isV=rs_rA_isV[5];
  assign rs2i1_rA_isAnyV=rs_rA_isAnyV[5];
  assign rs2i1_useAConst=rs_useAConst[5];
  assign rs2i1_rB=rs_rB[5];
  assign rs2i1_rB_use=rs_rB_use[5];
  assign rs2i1_rB_useF=rs_rB_useF[5];
  assign rs2i1_rB_isV=rs_rB_isV[5];
  assign rs2i1_rB_isAnyV=rs_rB_isAnyV[5];
  assign rs2i1_useBConst=rs_useBConst[5];
  assign rs2i1_const=rs_constant[5];
  assign rs2i1_rT=rs_rT[5];
  assign rs2i1_rT_use=rs_rT_use[5];
  assign rs2i1_rT_useF=rs_rT_useF[5];
  assign rs2i1_rT_isV=rs_rT_isV[5];
  assign rs2i1_port=rs_port[5];
  assign rs2i1_en=rs_useRs[5];
  assign rs2i1_IPRel=rs_IPRel[5];
  assign rs2i1_afterTaken=rs_afterTaken[5];
  assign rs2i1_alloc=rs_alloc[5];
  assign rs2i1_allocF=rs_allocF[5];
  assign rs2i1_allocR=rs_allocR[5];
  assign rs2i1_flagDep=rs_flDep[5];
  assign rs2i1_lastFl=rs_lastFl[5];
  assign rs2i1_lsi=rs_lsi[5];
  assign rs2i1_ldst_flag=rs_ldst_flag[5];
  assign rs2i1_flag_wr=rs_flagWr[5];

  assign rs2i2_operation=rs_operation[8];
  assign rs2i2_rA=rs_rA[8];
  assign rs2i2_rA_use=rs_rA_use[8];
  assign rs2i2_rA_useF=rs_rA_useF[8];
  assign rs2i2_rA_isV=rs_rA_isV[8];
  assign rs2i2_rA_isAnyV=rs_rA_isAnyV[8];
  assign rs2i2_useAConst=rs_useAConst[8];
  assign rs2i2_rB=rs_rB[8];
  assign rs2i2_rB_use=rs_rB_use[8];
  assign rs2i2_rB_useF=rs_rB_useF[8];
  assign rs2i2_rB_isV=rs_rB_isV[8];
  assign rs2i2_rB_isAnyV=rs_rB_isAnyV[8];
  assign rs2i2_useBConst=rs_useBConst[8];
  assign rs2i2_const=rs_constant[8];
  assign rs2i2_rT=rs_rT[8];
  assign rs2i2_rT_use=rs_rT_use[8];
  assign rs2i2_rT_useF=rs_rT_useF[8];
  assign rs2i2_rT_isV=rs_rT_isV[8];
  assign rs2i2_port=rs_port[8];
  assign rs2i2_en=rs_useRs[8];
  assign rs2i2_IPRel=rs_IPRel[8];
  assign rs2i2_afterTaken=rs_afterTaken[8];
  assign rs2i2_alloc=rs_alloc[8];
  assign rs2i2_allocF=rs_allocF[8];
  assign rs2i2_allocR=rs_allocR[8];
  assign rs2i2_flagDep=rs_flDep[8];
  assign rs2i2_lastFl=rs_lastFl[8];
  assign rs2i2_flag_wr=rs_flagWr[8];
  

  assign instr0_rT=	dec_rT_reg[0];
  assign instr0_wren=	dec_rT_use_reg[0] | dec_rT_useF_reg[0] && iUsed_reg[0];
  assign instr0_en=	dec_useRs_reg[0] & iUsed_reg[0];
  assign instr0_rT_useF=dec_rT_useF_reg[0];
  assign instr0_rT_isV= dec_rT_isV_reg[0];
  assign instr0_port=   dec_port_reg[0];
  assign instr0_magic=  dec_magic_reg[0];
  
  assign instr1_rT=	dec_rT_reg[1];
  assign instr1_wren=	dec_rT_use_reg[1] | dec_rT_useF_reg[1] && iUsed_reg[1];
  assign instr1_en=	dec_useRs_reg[1] & iUsed_reg[1];
  assign instr1_rT_useF=dec_rT_useF_reg[1];
  assign instr1_rT_isV= dec_rT_isV_reg[1];
  assign instr1_port=   dec_port_reg[1];
  assign instr1_magic=  dec_magic_reg[1];

  assign instr2_rT=	dec_rT_reg[2];
  assign instr2_wren=	dec_rT_use_reg[2] | dec_rT_useF_reg[2] && iUsed_reg[2];
  assign instr2_en=	dec_useRs_reg[2] & iUsed_reg[2];
  assign instr2_rT_useF=dec_rT_useF_reg[2];
  assign instr2_rT_isV= dec_rT_isV_reg[2];
  assign instr2_port=   dec_port_reg[2];
  assign instr2_magic=  dec_magic_reg[2];

  assign instr3_rT=	dec_rT_reg[3];
  assign instr3_wren=	dec_rT_use_reg[3] | dec_rT_useF_reg[3] && iUsed_reg[3];
  assign instr3_en=	dec_useRs_reg[3] & iUsed_reg[3];
  assign instr3_rT_useF=dec_rT_useF_reg[3];
  assign instr3_rT_isV= dec_rT_isV_reg[3];
  assign instr3_port=   dec_port_reg[3];
  assign instr3_magic=  dec_magic_reg[3];

  assign instr4_rT=	dec_rT_reg[4];
  assign instr4_wren=	dec_rT_use_reg[4] | dec_rT_useF_reg[4] && iUsed_reg[4];
  assign instr4_en=	dec_useRs_reg[4] & iUsed_reg[4];
  assign instr4_rT_useF=dec_rT_useF_reg[4];
  assign instr4_rT_isV= dec_rT_isV_reg[4];
  assign instr4_port=   dec_port_reg[4];
  assign instr4_magic=  dec_magic_reg[4];

  assign instr5_rT=	dec_rT_reg[5];
  assign instr5_wren=	dec_rT_use_reg[5] | dec_rT_useF_reg[5] && iUsed_reg[5];
  assign instr5_en=	dec_useRs_reg[5] & iUsed_reg[5];
  assign instr5_rT_useF=dec_rT_useF_reg[5];
  assign instr5_rT_isV= dec_rT_isV_reg[5];
  assign instr5_port=   dec_port_reg[5];
  assign instr5_magic=  dec_magic_reg[5];
    
  assign instr6_rT=	dec_rT_reg[6];
  assign instr6_wren=	dec_rT_use_reg[6] | dec_rT_useF_reg[6] && iUsed_reg[6];
  assign instr6_en=	dec_useRs_reg[6] & iUsed_reg[6];
  assign instr6_rT_useF=dec_rT_useF_reg[6];
  assign instr6_rT_isV= dec_rT_isV_reg[6];
  assign instr6_port=   dec_port_reg[6];
  assign instr6_magic=  dec_magic_reg[6];

  assign instr7_rT=	dec_rT_reg[7];
  assign instr7_wren=	dec_rT_use_reg[7] | dec_rT_useF_reg[7] && iUsed_reg[7];
  assign instr7_en=	dec_useRs_reg[7] & iUsed_reg[7];
  assign instr7_rT_useF=dec_rT_useF_reg[7];
  assign instr7_rT_isV= dec_rT_isV_reg[7];
  assign instr7_port=   dec_port_reg[7];
  assign instr7_magic=  dec_magic_reg[7];
  
  assign instr8_rT=	dec_rT_reg[8];
  assign instr8_wren=	dec_rT_use_reg[8] | dec_rT_useF_reg[8] && iUsed_reg[8];
  assign instr8_en=	dec_useRs_reg[8] & iUsed_reg[8];
  assign instr8_rT_useF=dec_rT_useF_reg[8];
  assign instr8_rT_isV= dec_rT_isV_reg[8];
  assign instr8_port=   dec_port_reg[8];
  assign instr8_magic=  dec_magic_reg[8];
  
  assign instr9_rT=	dec_rT_reg[9];
  assign instr9_wren=	dec_rT_use_reg[9] | dec_rT_useF_reg[9] && iUsed_reg[9];
  assign instr9_en=	dec_useRs_reg[9] & iUsed_reg[9];
  assign instr9_rT_useF=dec_rT_useF_reg[9];
  assign instr9_rT_isV= dec_rT_isV_reg[9];
  assign instr9_port=   dec_port_reg[9];
  assign instr9_magic=  dec_magic_reg[9];
  
  assign instr0_IPOff=dec_srcIPOffA_reg[0];
  assign instr1_IPOff=dec_srcIPOffA_reg[1];
  assign instr2_IPOff=dec_srcIPOffA_reg[2];
  assign instr3_IPOff=dec_srcIPOffA_reg[3];
  assign instr4_IPOff=dec_srcIPOffA_reg[4];
  assign instr5_IPOff=dec_srcIPOffA_reg[5];
  assign instr6_IPOff=dec_srcIPOffA_reg[6];
  assign instr7_IPOff=dec_srcIPOffA_reg[7];
  assign instr8_IPOff=dec_srcIPOffA_reg[8];
  assign instr9_IPOff=dec_srcIPOffA_reg[9];
  
  assign instr0_afterTaken=dec_afterTaken_reg[0];
  assign instr1_afterTaken=dec_afterTaken_reg[1];
  assign instr2_afterTaken=dec_afterTaken_reg[2];
  assign instr3_afterTaken=dec_afterTaken_reg[3];
  assign instr4_afterTaken=dec_afterTaken_reg[4];
  assign instr5_afterTaken=dec_afterTaken_reg[5];
  assign instr6_afterTaken=dec_afterTaken_reg[6];
  assign instr7_afterTaken=dec_afterTaken_reg[7];
  assign instr8_afterTaken=dec_afterTaken_reg[8];
  assign instr9_afterTaken=dec_afterTaken_reg[9];

  assign instr0_last=dec_last_reg[0];
  assign instr1_last=dec_last_reg[1];
  assign instr2_last=dec_last_reg[2];
  assign instr3_last=dec_last_reg[3];
  assign instr4_last=dec_last_reg[4];
  assign instr5_last=dec_last_reg[5];
  assign instr6_last=dec_last_reg[6];
  assign instr7_last=dec_last_reg[7];
  assign instr8_last=dec_last_reg[8];
  assign instr9_last=dec_last_reg[9];

//  assign instr_trce=dec_isTrce_reg & iUsed_reg;
  assign instr_fsimd=dec_fsimd_reg;
  
  always @(posedge clk)
    begin
      if (rst) begin
          for (n=0;n<10;n=n+1) begin
              dec_operation_reg[n]<={OPERATION_WIDTH-5{1'b0}};
	      dec_alucond_reg[n]<=5'b0;
	      dec_rndmode_reg[n]<=3'b0;
              dec_rA_reg[n]<={REG_WIDTH{1'b0}};
              dec_rA_use_reg[n]<=1'b0;
              dec_rA_useF_reg[n]<=1'b0;
              dec_rB_reg[n]<={REG_WIDTH{1'b0}};
              dec_rB_use_reg[n]<=1'b0;
              dec_rB_useF_reg[n]<=1'b0;
              dec_useBConst_reg[n]<=1'b0;
              dec_rC_reg[n]<={REG_WIDTH{1'b0}};
              dec_rC_use_reg[n]<=1'b0;
              dec_rC_useF_reg[n]<=1'b0;
              dec_useCRet_reg[n]<=1'b0;
              dec_constant_reg[n]<=65'b0;
              dec_constantN_reg[n]<=65'b0;
              dec_rT_reg[n]<={REG_WIDTH{1'b0}};
              dec_rT_use_reg[n]<=1'b0;
              dec_rT_useF_reg[n]<=1'b0;
              dec_port_reg[n]<=4'b0;
              dec_useRs_reg[n]<=1'b0;
              dec_srcIPOffA_reg[n]<=9'b0;
              dec_jumpType_reg[n]<=5'b0;
	      dec_magic_reg[n]<=4'b0;
	      dec_srcIPOff_reg[n]<=9'b0;
	      dec_btbWay_reg[n]<=1'd0;
	      dec_jmpInd_reg[n]<=2'b0;
	      dec_ght_reg[n]<=8'b0;
	      dec_ght2_reg[n]<=16'b0;
	      dec_val_reg[n]<=1'b0;
	      dec_sc_reg[n]<=2'b0;
	      dec_miss_reg[n]<=1'b0;
	      dec_tbufOnly_reg[n]<=1'b0;
          end
         // has_mul<=1'b0;
          bundleFeed<=1'b0;
          iAvail_reg<=10'b0;
          dec_lspecR<=1'b0;
          was_FMA_last<=1'b0;
          instr_save<=16'b0;
          dec_IPRel_reg<=10'b0;
          iUsed_reg<=10'b0;
          cls_indir_reg<=10'b0;
          cls_jump_reg<=10'b0;
          cls_ALU_reg<=10'b0;
          cls_shift_reg<=10'b0;
          cls_mul_reg<=10'b0;
          cls_load_reg<=10'b0;
          cls_store_reg<=10'b0;
          cls_storeI_reg<=10'b0;
          cls_store2_reg<=10'b0;
          cls_FPU_reg<=10'b0;
          cls_loadFPU_reg<=11'b0;
          cls_sys_reg<=10'b0;
          cls_pos0_reg<=10'b0;
          cls_flag_reg<=cls_flag;
          dec_afterTaken_reg<=10'b0;
          dec_taken_reg<=10'b0;
          dec_allocR_reg<=10'b0;
          dec_useFlags_reg<=10'b0;
          dec_wrFlags_reg<=10'b0;
          dec_rA_isV_reg<=10'b0;
          dec_rB_isV_reg<=10'b0;
          dec_rT_isV_reg<=10'b0;
	  dec_last_reg<=10'b0;
	  dec_fsimd_reg<=10'b0;
	  afterTick_reg<=10'b0;
	  msrss_retIP_en_reg<=10'b0;
	  instr0_aft_spc<=1'b0;
	  instr1_aft_spc<=1'b0;
	  instr2_aft_spc<=1'b0;
	  instr3_aft_spc<=1'b0;
	  instr4_aft_spc<=1'b0;
	  instr5_aft_spc<=1'b0;
	  instr6_aft_spc<=1'b0;
	  instr7_aft_spc<=1'b0;
	  instr8_aft_spc<=1'b0;
	  instr9_aft_spc<=1'b0;
          instr0_error<=2'b0;
          instr1_error<=2'b0;
          instr2_error<=2'b0;
          instr3_error<=2'b0;
          instr4_error<=2'b0;
          instr5_error<=2'b0;
          instr6_error<=2'b0;
          instr7_error<=2'b0;
          instr8_error<=2'b0;
          instr9_error<=2'b0;
      end
      else if (~stall||except) begin
          for (n=0;n<10;n=n+1) begin
              dec_operation_reg[n]<=dec_operation[n];
	      dec_alucond_reg[n]<=dec_alucond[n];
              dec_rA_reg[n]<=ffx(thread,thrmode,1'b0,dec_rA[n]);
              dec_rndmode_reg[n]<=dec_rndmode;
              dec_rA_use_reg[n]<=dec_rA_use[n] && iUsed[n];
              dec_rA_useF_reg[n]<=dec_rA_useF[n] && iUsed[n];
              dec_rB_reg[n]<=ffx(thread,thrmode,1'b0,dec_rB[n]);
              dec_rB_use_reg[n]<=dec_rB_use[n] && iUsed[n] && !(dec_rB==31 && instrQ[n][-4+`instrQ_magic]);
              dec_rB_useF_reg[n]<=dec_rB_useF[n] && iUsed[n];
              dec_useBConst_reg[n]<=dec_useBConst[n] && iUsed[n];
              dec_useAConst_reg[n]<=dec_useBConst[n] && iUsed[n] && dec_IPRel[n] && dec_rA_use[n];
              dec_rC_reg[n]<=ffx(thread,thrmode,1'b0,dec_rC[n]);
              dec_rC_use_reg[n]<=dec_rC_use[n] && dec_rC[n]!=31 && iUsed[n];
              dec_rC_useF_reg[n]<=dec_rC_useF[n] && iUsed[n];
              dec_useCRet_reg[n]<=dec_useCRet[n] && iUsed[n];
              dec_constant_reg[n]<=dec_constant[n];
              dec_constantN_reg[n]<=dec_constantN[n];
              dec_rT_reg[n]<=ffx(thread,thrmode,dec_rT_use,dec_rT[n]);
              dec_rT_use_reg[n]<=dec_rT_use[n] && iUsed[n] && ~except;
              dec_rT_useF_reg[n]<=dec_rT_useF[n] && iUsed[n] && ~except;
              dec_port_reg[n]<=dec_port[n];
              dec_useRs_reg[n]<=dec_useRs[n] && iUsed[n] && ~except;
              dec_srcIPOffA_reg[n]<=dec_srcIPOffA[n];
              dec_jumpType_reg[n]<=dec_jumpType[n];
	      dec_magic_reg[n]<=dec_magic[n];
	      dec_srcIPOff_reg[n]<={afterTick[n],dec_srcIPOff[n]};
	      dec_btbWay_reg[n]<=dec_btbWay[n];
	      dec_jmpInd_reg[n]<=dec_jmpInd[n];
	      dec_ght_reg[n]<=dec_ght[n];
	      dec_ght2_reg[n]<=dec_ght2[n];
	      dec_val_reg[n]<=dec_val[n];
	      dec_sc_reg[n]<=dec_sc[n];
	      dec_miss_reg[n]<=dec_miss[n];
	      dec_tbufOnly_reg[n]<=dec_tbufOnly[n];
          end
         // has_mul<=|cls_mul;
          bundleFeed<=iUsed[0] & ~except;
          iAvail_reg<=iAvail;
          dec_lspecR<=dec_lspecR_d;
          was_FMA_last<=was_FMA_last_d;
          instr_save<=instr_save_d;
          if (except) begin
              dec_lspecR<=1'b0;
              was_FMA_last<=1'b0;
              instr_save<=16'b0;
          end
          dec_IPRel_reg<=dec_IPRel;
          iUsed_reg<=iUsed;
          cls_indir_reg<=cls_indir;
          cls_jump_reg<=cls_jump & {10{~except}};
          cls_ALU_reg<=cls_ALU;
          cls_shift_reg<=cls_shift;
          cls_mul_reg<=cls_mul;
          cls_load_reg<=cls_load;
          cls_store_reg<=cls_store;
          cls_storeI_reg<=cls_storeI;
          cls_store2_reg<=cls_store2;
          cls_FPU_reg<=cls_FPU;
          cls_loadFPU_reg<={cls_loadFPU,1'b0};
          cls_sys_reg<=cls_sys;
          cls_pos0_reg<=cls_pos0;
          cls_flag_reg<=cls_flag;
          dec_afterTaken_reg<=dec_afterTaken & iUsed;
          dec_taken_reg<=dec_taken;
          dec_allocR_reg<=dec_allocR & iUsed &{10{~except}};
          dec_useFlags_reg<=dec_useFlags&iUsed;
          dec_wrFlags_reg<=dec_wrFlags&iUsed&{10{~except}};
          dec_rA_isV_reg<=dec_rA_isV;
          dec_rB_isV_reg<=dec_rB_isV;
          dec_rT_isV_reg<=dec_rT_isV;
	  dec_last_reg<=dec_last;
	  dec_fsimd_reg<=dec_fsimd;
	  afterTick_reg<=afterTick;
	  msrss_retIP_en_reg<=msrss_retIP_en_reg & iUsed;
	  instr0_aft_spc<=dec_lspec[-1];
	  instr1_aft_spc<=dec_lspec[1-1];
	  instr2_aft_spc<=dec_lspec[2-1];
	  instr3_aft_spc<=dec_lspec[3-1];
	  instr4_aft_spc<=dec_lspec[4-1];
	  instr5_aft_spc<=dec_lspec[5-1];
	  instr6_aft_spc<=dec_lspec[6-1];
	  instr7_aft_spc<=dec_lspec[7-1];
	  instr8_aft_spc<=dec_lspec[8-1];
	  instr9_aft_spc<=dec_lspec[9-1];
          instr0_error<=dec_error[0] & iUsed;
          instr1_error<=dec_error[1] & iUsed;
          instr2_error<=dec_error[2] & iUsed;
          instr3_error<=dec_error[3] & iUsed;
          instr4_error<=dec_error[4] & iUsed;
          instr5_error<=dec_error[5] & iUsed;
          instr6_error<=dec_error[6] & iUsed;
          instr7_error<=dec_error[7] & iUsed;
          instr8_error<=dec_error[8] & iUsed;
          instr9_error<=dec_error[9] & iUsed;
      end
    end
endmodule  


module decoder_find_single_dep(
  instr0_rT,instr0_rT_use,instr0_rT_useF,
  instr1_rT,instr1_rT_use,instr1_rT_useF,
  instr2_rT,instr2_rT_use,instr2_rT_useF,
  instr3_rT,instr3_rT_use,instr3_rT_useF,
  instr4_rT,instr4_rT_use,instr4_rT_useF,
  instr5_rT,instr5_rT_use,instr5_rT_useF,
  instr6_rT,instr6_rT_use,instr6_rT_useF,
  instr7_rT,instr7_rT_use,instr7_rT_useF,
  instr8_rT,instr8_rT_use,instr8_rT_useF,
  chkReg,chk_useF,
  dep
  );
  parameter REG_WIDTH=6;
  
  input [REG_WIDTH-1:0]	instr0_rT;
  input 		instr0_rT_use;
  input 		instr0_rT_useF;
  input [REG_WIDTH-1:0]	instr1_rT;
  input 		instr1_rT_use;
  input 		instr1_rT_useF;
  input [REG_WIDTH-1:0]	instr2_rT;
  input 		instr2_rT_use;
  input 		instr2_rT_useF;
  input [REG_WIDTH-1:0]	instr3_rT;
  input 		instr3_rT_use;
  input 		instr3_rT_useF;
  input [REG_WIDTH-1:0]	instr4_rT;
  input 		instr4_rT_use;
  input 		instr4_rT_useF;
  input [REG_WIDTH-1:0]	instr5_rT;
  input 		instr5_rT_use;
  input 		instr5_rT_useF;
  input [REG_WIDTH-1:0]	instr6_rT;
  input 		instr6_rT_use;
  input 		instr6_rT_useF;
  input [REG_WIDTH-1:0]	instr7_rT;
  input 		instr7_rT_use;
  input 		instr7_rT_useF;
  input [REG_WIDTH-1:0]	instr8_rT;
  input 		instr8_rT_use;
  input 		instr8_rT_useF;
 
  input [REG_WIDTH-1:0] chkReg;
  input chk_useF;
  output [REG_WIDTH-1:0] dep;


  wire hasDep,hasDepF;
    
  wire [8:0] allDeps;
  wire [8:0] allDepsF;
  wire [8:0] allCmp;
  wire [8:0] bitDep;
  wire [8:0] bitDepF;
  
  assign allCmp[0]=(chkReg==instr0_rT);
  assign allCmp[1]=(chkReg==instr1_rT);
  assign allCmp[2]=(chkReg==instr2_rT);
  assign allCmp[3]=(chkReg==instr3_rT);
  assign allCmp[4]=(chkReg==instr4_rT);
  assign allCmp[5]=(chkReg==instr5_rT);
  assign allCmp[6]=(chkReg==instr6_rT);
  assign allCmp[7]=(chkReg==instr7_rT);
  assign allCmp[8]=(chkReg==instr8_rT);
  
  assign allDeps[0]=allCmp[0] & instr0_rT_use & ~chk_useF;
  assign allDeps[1]=allCmp[1] & instr1_rT_use & ~chk_useF;
  assign allDeps[2]=allCmp[2] & instr2_rT_use & ~chk_useF;
  assign allDeps[3]=allCmp[3] & instr3_rT_use & ~chk_useF;
  assign allDeps[4]=allCmp[4] & instr4_rT_use & ~chk_useF;
  assign allDeps[5]=allCmp[5] & instr5_rT_use & ~chk_useF;
  assign allDeps[6]=allCmp[6] & instr6_rT_use & ~chk_useF;
  assign allDeps[7]=allCmp[7] & instr7_rT_use & ~chk_useF;
  assign allDeps[8]=allCmp[8] & instr8_rT_use & ~chk_useF;

  assign allDepsF[0]=allCmp[0] & instr0_rT_useF & chk_useF;
  assign allDepsF[1]=allCmp[1] & instr1_rT_useF & chk_useF;
  assign allDepsF[2]=allCmp[2] & instr2_rT_useF & chk_useF;
  assign allDepsF[3]=allCmp[3] & instr3_rT_useF & chk_useF;
  assign allDepsF[4]=allCmp[4] & instr4_rT_useF & chk_useF;
  assign allDepsF[5]=allCmp[5] & instr5_rT_useF & chk_useF;
  assign allDepsF[6]=allCmp[6] & instr6_rT_useF & chk_useF;
  assign allDepsF[7]=allCmp[7] & instr7_rT_useF & chk_useF;
  assign allDepsF[8]=allCmp[8] & instr8_rT_useF & chk_useF;
 
  bit_find_last_bit #(9) findBit_mod(allDeps,bitDep,hasDep);
  bit_find_last_bit #(9) findBitF_mod(allDepsF,bitDepF,hasDepF);
  
  assign dep=(bitDep[0] | bitDepF[0]) ? {{REG_WIDTH-4{1'b1}},4'd0} : 'z;
  assign dep=(bitDep[1] | bitDepF[1]) ? {{REG_WIDTH-4{1'b1}},4'd1} : 'z;
  assign dep=(bitDep[2] | bitDepF[2]) ? {{REG_WIDTH-4{1'b1}},4'd2} : 'z;
  assign dep=(bitDep[3] | bitDepF[3]) ? {{REG_WIDTH-4{1'b1}},4'd3} : 'z;
  assign dep=(bitDep[4] | bitDepF[4]) ? {{REG_WIDTH-4{1'b1}},4'd4} : 'z;
  assign dep=(bitDep[5] | bitDepF[5]) ? {{REG_WIDTH-4{1'b1}},4'd5} : 'z;
  assign dep=(bitDep[6] | bitDepF[6]) ? {{REG_WIDTH-4{1'b1}},4'd6} : 'z;
  assign dep=(bitDep[7] | bitDepF[7]) ? {{REG_WIDTH-4{1'b1}},4'd7} : 'z;
  assign dep=(bitDep[8] | bitDepF[8]) ? {{REG_WIDTH-4{1'b1}},4'd8} : 'z;
  assign dep=(hasDep|hasDepF) ? 'z : chkReg;
endmodule


module decoder_find_alloc(
  instr1_rT,instr1_rT_use,instr1_rT_useF,
  instr2_rT,instr2_rT_use,instr2_rT_useF,
  instr3_rT,instr3_rT_use,instr3_rT_useF,
  instr4_rT,instr4_rT_use,instr4_rT_useF,
  instr5_rT,instr5_rT_use,instr5_rT_useF,
  instr6_rT,instr6_rT_use,instr6_rT_useF,
  instr7_rT,instr7_rT_use,instr7_rT_useF,
  instr8_rT,instr8_rT_use,instr8_rT_useF,
  instr9_rT,instr9_rT_use,instr9_rT_useF,
  chkReg,chkReg_use,chkReg_useF,
  alloc,allocF
  );
  localparam REG_WIDTH=6;
  
  input [REG_WIDTH-1:0]	instr1_rT;
  input 		instr1_rT_use;
  input 		instr1_rT_useF;
  input [REG_WIDTH-1:0]	instr2_rT;
  input 		instr2_rT_use;
  input 		instr2_rT_useF;
  input [REG_WIDTH-1:0]	instr3_rT;
  input 		instr3_rT_use;
  input 		instr3_rT_useF;
  input [REG_WIDTH-1:0]	instr4_rT;
  input 		instr4_rT_use;
  input 		instr4_rT_useF;
  input [REG_WIDTH-1:0]	instr5_rT;
  input 		instr5_rT_use;
  input 		instr5_rT_useF;
  input [REG_WIDTH-1:0]	instr6_rT;
  input 		instr6_rT_use;
  input 		instr6_rT_useF;
  input [REG_WIDTH-1:0]	instr7_rT;
  input 		instr7_rT_use;
  input 		instr7_rT_useF;
  input [REG_WIDTH-1:0]	instr8_rT;
  input 		instr8_rT_use;
  input 		instr8_rT_useF;
  input [REG_WIDTH-1:0]	instr9_rT;
  input 		instr9_rT_use;
  input 		instr9_rT_useF;
 
  input [REG_WIDTH-1:0] chkReg;
  input chkReg_use;
  input chkReg_useF;
  output alloc;
  output allocF;
  
  wire [9:1] cmp;
  
  assign cmp={
    instr9_rT==chkReg,
    instr8_rT==chkReg,
    instr7_rT==chkReg,
    instr6_rT==chkReg,
    instr5_rT==chkReg,
    instr4_rT==chkReg,
    instr3_rT==chkReg,
    instr2_rT==chkReg,
    instr1_rT==chkReg};
    
  assign alloc=chkReg_use &
    ~(|{ 
    cmp[1] && instr1_rT_use,
    cmp[2] && instr2_rT_use,
    cmp[3] && instr3_rT_use,
    cmp[4] && instr4_rT_use,
    cmp[5] && instr5_rT_use,
    cmp[6] && instr6_rT_use,
    cmp[7] && instr7_rT_use,
    cmp[8] && instr8_rT_use,
    cmp[9] && instr9_rT_use});

  assign allocF=chkReg_useF &
    ~(|{ 
    cmp[1] && instr1_rT_useF,
    cmp[2] && instr2_rT_useF,
    cmp[3] && instr3_rT_useF,
    cmp[4] && instr4_rT_useF,
    cmp[5] && instr5_rT_useF,
    cmp[6] && instr6_rT_useF,
    cmp[7] && instr7_rT_useF,
    cmp[8] && instr8_rT_useF,
    cmp[9] && instr9_rT_useF});
    
endmodule


module decoder_flag_dep(
  instr_write_0_8,
  doRead,
  dep
  );
  
  input [8:0] instr_write_0_8;
  input doRead;
  output [3:0] dep;

  wire [8:0] last;
  wire found;
  

  bit_find_last_bit #(9) last_mod(instr_write_0_8,last,found);
  
  generate
      genvar k;
      for(k=0;k<=8;k=k+1) begin
          assign dep=(doRead & last[k]) ? k[3:0] : 4'bz;
      end
  endgenerate
  
  assign dep=(doRead & ~found) ? 4'he : 4'bz;
  assign dep=(~doRead) ? 4'hd : 4'bz;
  
endmodule


module decoder_flag_wr(
  instr_write_1_9,
  doWrite,
  lastWr
  );
  
  input [9:1] instr_write_1_9;
  input doWrite;
  output lastWr;

  
  assign lastWr=doWrite & 0==instr_write_1_9;
  
endmodule

module decoder_get_baseIP(
  clk,
  rst,
  baseIP,
  baseAttr,
  afterTK,
  iUsed,
  afterTick,
  srcIPOff0,
  srcIPOff1,
  srcIPOff2,
  srcIPOff3,
  srcIPOff4,
  srcIPOff5,
  srcIPOff6,
  srcIPOff7,
  srcIPOff8,
  srcIPOff9,
  jump0IP,jump0TK,jump0Attr,
  jump1IP,jump1TK,jump1Attr,
  except,
  exceptIP,
  exceptAttr
  );
  input clk;
  input rst;
  output reg [62:0] baseIP;
  output reg [3:0] baseAttr;
  input [9:0] afterTK;
  input [9:0] iUsed;
  input [9:0] afterTick;
  input [8:0] srcIPOff0;
  input [8:0] srcIPOff1;
  input [8:0] srcIPOff2;
  input [8:0] srcIPOff3;
  input [8:0] srcIPOff4;
  input [8:0] srcIPOff5;
  input [8:0] srcIPOff6;
  input [8:0] srcIPOff7;
  input [8:0] srcIPOff8;
  input [8:0] srcIPOff9;
  input [62:0] jump0IP;
  input [3:0] jump0Attr;
  input jump0TK;
  input [62:0] jump1IP;
  input [3:0] jump1Attr;
  input jump1TK;
  input except;
  input [62:0] exceptIP;
  input [3:0] exceptAttr;

  wire [8:0] srcIPOff[9:0];
  wire [62:0] nextIP;
  wire [3:0] next_baseAttr;
  wire [62:0] next_baseIP;


  adder_inc #(35) nextAdd_mod(baseIP[42:8],nextIP[42:8],1'b1,);
  assign nextIP[7:0]=baseIP[7:0];
  //assign second_IP=|second_tr_jump ? tk_jumpIP : 47'bz;
  assign nextIP[7:0]=baseIP[7:0];
  assign nextIP[62:43]=baseIP[62:43];
  //assign second_IP=|second_tr_jump ? tk_jumpIP : 47'bz;

  assign next_baseAttr=(jump0TK && ~except) ? jump0Attr : 4'bz;
  assign next_baseAttr=(jump1TK && ~except) ? jump1Attr : 4'bz;
  assign next_baseAttr=(~jump0TK && ~jump1TK && 0==(afterTick&iUsed) 
    && ~except) ? baseAttr: 4'bz;
  assign next_baseAttr=(~jump0TK && ~jump1TK && 0!=(afterTick&iUsed) 
    && ~except) ? baseAttr: 4'bz;
  assign next_baseAttr=except ? exceptAttr : 4'bz;


  
  assign next_baseIP=(jump0TK && ~except) ? jump0IP : 63'bz;
  assign next_baseIP=(jump1TK && ~except) ? jump1IP : 63'bz;
  assign next_baseIP=(~jump0TK && ~jump1TK && 0==(afterTick&iUsed) 
    && ~except) ? baseIP: 63'bz;
  assign next_baseIP=(~jump0TK && ~jump1TK && 0!=(afterTick&iUsed) 
    && ~except) ? nextIP: 63'bz;
  assign next_baseIP=except ? exceptIP : 63'bz;

  assign srcIPOff[0]=srcIPOff0;
  assign srcIPOff[1]=srcIPOff1;
  assign srcIPOff[2]=srcIPOff2;
  assign srcIPOff[3]=srcIPOff3;
  assign srcIPOff[4]=srcIPOff4;
  assign srcIPOff[5]=srcIPOff5;
  assign srcIPOff[6]=srcIPOff6;
  assign srcIPOff[7]=srcIPOff7;
  assign srcIPOff[8]=srcIPOff8;
  assign srcIPOff[9]=srcIPOff9;
  
  always @(posedge clk) begin
      if (rst) begin
          baseIP<={20'hf80fe,43'b0};
      end else begin
	  baseIP<=next_baseIP;
      end
      if (rst) begin
          baseAttr<=4'b0;
      end else begin
	  baseAttr<=next_baseAttr;
      end
  end
endmodule
  
