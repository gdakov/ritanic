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


module saddrcalc(
  clk,
  rst,
  except,
  attr,
  read_clkEn,
  doStall,
  bus_hold,
  mex_addr,
  mex_attr,
  mex_en,
  op,
  shiftSize,
  regno,
  LSQ_no,
  II_no,
  WQ_no,
  calu_code,
  valS,
  thread,
  lsflag,
  cmplxAddr,
  cin_secq,
  ptrdiff,
  error,
  mlbMiss,
  pageFault,
  faultCode,
  faultNo,
  mOp_register,
  mOp_type,
  mOp_LSQ,
  mOp_II,
  mOp_WQ,
  mOp_attr,
  mOp_addrEven,
  mOp_addrOdd,
  mOp_addrMain,
  mOp_sz,
  mOp_st,
  mOp_en,
  mOp_secq,
  mOp_rsEn,
  mOp_thread,
  mOp_lsflag,
  mOp_banks,
  mOp_bank0,
  mOp_odd,
  mOp_addr_low,
  mOp_split,
//  mOp_noBanks,
  msrss_no,
  msrss_en,
  msrss_thr,
  msrss_data,
  mlb_clkEn,
  cout_secq,
  addrTlb,
  sproc,
  mlb_data0,
  mlb_data1,
  mlb_hit
  );

  parameter INDEX=0; //0 1 2 
  localparam ADDR_WIDTH=64;
  localparam PADDR_WIDTH=44;
  localparam OPERATION_WIDTH=`operation_width;
  localparam BANK_COUNT=32;
  localparam TLB_DATA_WIDTH=`dmlbData_width;
  localparam TLB_IP_WIDTH=52;
  localparam REG_WIDTH=`reg_addr_width;

  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire [3:0] attr;
  input pwire read_clkEn;
  output pwire doStall;
  input pwire bus_hold;
  input pwire [43:0] mex_addr;
  input pwire [3:0] mex_attr;
  input pwire mex_en;
  input pwire [OPERATION_WIDTH-1:0] op;
  input pwire [3:0] shiftSize;
  input pwire [REG_WIDTH-1:0] regno;
  input pwire [8:0] LSQ_no;
  input pwire [9:0] II_no;
  input pwire [5:0] WQ_no;
  input pwire [4:0] calu_code;
  input pwire [5:0] valS;
  input pwire thread;
  input pwire lsflag;
  input pwire [64:0] cmplxAddr;
  input pwire cin_secq;
  input pwire ptrdiff;
  input pwire error;
  output pwire mlbMiss;
  output pageFault;
  output pwire [7:0] faultCode;
  output pwire [8:0] faultNo;
  output pwire [REG_WIDTH-1:0] mOp_register;
  output pwire [2:0] mOp_type;
  output pwire [8:0] mOp_LSQ;
  output pwire [9:0] mOp_II;
  output pwire [5:0] mOp_WQ;
  output pwire [3:0] mOp_attr;
  output pwire [PADDR_WIDTH-1:8] mOp_addrEven;
  output pwire [PADDR_WIDTH-1:8] mOp_addrOdd;
  output pwire [43:0] mOp_addrMain;
  output pwire [4:0] mOp_sz;
  output pwire mOp_st;
  output pwire mOp_en;
  output pwire mOp_secq;
  output pwire mOp_rsEn;
  output pwire mOp_thread;
  output pwire mOp_lsflag;
  output pwire [BANK_COUNT-1:0] mOp_banks;
  output pwire [4:0] mOp_bank0;
  output pwire mOp_odd;
  output pwire [1:0] mOp_addr_low;
  output pwire mOp_split;
//  output pwire [BANK_COUNT-1:0] mOp_noBanks;
  input pwire [15:0] msrss_no;
  input pwire msrss_en;
  input pwire msrss_thr;
  input pwire [64:0] msrss_data;
  output pwire mlb_clkEn;
  output pwire cout_secq;
  output pwire [TLB_IP_WIDTH-1:0] addrTlb;
  output pwire [23:0] sproc;
  input pwire [TLB_DATA_WIDTH-1:0] mlb_data0;
  input pwire [TLB_DATA_WIDTH-1:0] mlb_data1;
  input pwire mlb_hit;

  pwire [2:0] opsize;
  pwire hasIndex;
  pwire aligned;//aligned for int subsys purpose not arch
  pwire aligned2;//same for complex addressing
  pwire tiny; //1 or 2 byte
  pwire mex_en_reg,mex_en_reg2;

  pwire [2:2] addrMain_reg;

  pwire mode64;
  pwire modeCmplx;
  pwire modeCmplx_reg;
  
  pwire error_reg;

//  pwire isLongOffset;
  pwire stepOver;//step over to next bank because of offset
  pwire stepOver2;
  pwire addrCarry;//offset by one bank
  pwire stepOverCmplx;
  pwire stepOverCmplx2;

  pwire modeCmplx_d;
  //complex mode when index register used, or offset not fit in unsigned 12-bit range

  pwire [31:0] banks0;
  
  pwire [4:0] bank0;
  pwire [4:0] bankL1;
  pwire [1:0] pageFault_t;
  pwire  [1:0] pageFault_t_reg;
  
  pwire mOp_split_X;

  assign mOp_split=mOp_split_X;

  pwire [13:0] addrMain;
  pwire [14:0] addrNext;
  pwire [13:0] dummy0;
 // pwire [13:0] CSAarg1;
 // pwire [13:0] CSAarg2;
 // pwire pageCarry;
 // pwire pageCarry1;
  
//  pwire [5:0] CSAbn0;
//  pwire [5:0] CSAbn1;
  
  pwire [TLB_IP_WIDTH-1:0] addrTlb;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data0;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data1;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data_next;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data_reg;

  pwire wp;
  pwire wp_next;
	
  pwire mlb_clkEn;
  pwire mlb_hit;

  pwire [3:0] attr2; 

  pwire read_clkEn_reg;
  pwire read_clkEn_reg2;
  pwire [OPERATION_WIDTH-1:0] op_reg;


  pwire [BANK_COUNT-1:0] all_banks;
  pwire otherness;

  pwire [BANK_COUNT-1:0] bit_confl;
  pwire  [BANK_COUNT-1:0] bit_confl_reg;
  
  
  pwire carryNext;
//  pwire non_overlap;

//  pwire [23:0] proc_reg;
//  pwire [23:0] proc_reg2;
  
  integer i;
  
//  pwire [4:0] bankNextOff;
//  pwire hasBankNext;
  
  pwire bus_hold_reg;
  pwire bus_hold_reg2;

  pwire doJmp;
  
  pwire [REG_WIDTH-1:0] regno_reg;
  pwire [8:0] LSQ_no_reg;
  pwire [9:0] II_no_reg;
  pwire [5:0] WQ_no_reg;
  pwire thread_reg;
  pwire lsflag_reg;

  pwire [1:0] rcn_mask;

  pwire doJmp;

  pwire except_reg;
  pwire except_reg2;
  pwire except_thread_reg;
  pwire except_thread_reg2;
  pwire cout_secq;
  pwire fault_cann;
  pwire fault_cann_reg;

  pwire [3:0] attr2_reg;

  pwire [4:0] lastSz;

  pwire [1:0][63:0] mflags;
  pwire [64:0] mflags0;
  pwire [1:0][23:0] pproc;  
  pwire [23:0] sproc;  
  pwire [23:0] proc;
  pwire [1:0][23:0] vproc;
  pwire split;
  pwire [1:0] fault_mlb;
  pwire [1:0] fault_mlb_next;
  generate
      genvar p,q;
      for(p=0;p<32;p=p+1) begin
          assign mOp_banks[p]=(~bus_hold_reg) ? all_banks[p] &  read_clkEn_reg
          : 1'b0;
      end

  endgenerate
 
//  assign bankNextOff=5'd2; //##
//  assign hasBankNext=1'b0;//##
  assign hasIndex=pwh#(2)::cmpEQ(op[7:6],2'b01);
  assign stepOverCmplx=|cmplxAddr[1:0];
  assign stepOverCmplx2=&cmplxAddr[1:0];
  assign bank0=cmplxAddr[6:2];
  assign mOp_bank0=bank0;
 
  assign lastSz[1]=(pwh#(32)::cmpEQ(opsize,1 )&& stepOver2) || (pwh#(32)::cmpEQ(opsize,2 )&& stepOver) || (pwh#(32)::cmpEQ(opsize,3 )&& ~stepOver);
  assign lastSz[2]=pwh#(32)::cmpEQ(opsize,3 )&& stepOver;
  assign lastSz[4:3]=2'b0;
  assign lastSz[0]=(pwh#(32)::cmpEQ(opsize,0)) || (pwh#(32)::cmpEQ(opsize,1 )& ~stepOver2) || (pwh#(32)::cmpEQ(opsize,2 )& ~stepOver);  
  assign mOp_split_X=(pwh#(32)::cmpEQ(opsize,1)) ?
    pwh#(5)::cmpEQ(bank0,5'h1f) && stepOver2 : 1'bz;
  assign mOp_split_X=(pwh#(32)::cmpEQ(opsize,2)) ?
    pwh#(5)::cmpEQ(bank0,5'h1f) && stepOver : 1'bz;
  assign mOp_split_X=(pwh#(32)::cmpEQ(opsize,3)) ?
    pwh#(5)::cmpEQ(bank0,5'h1f) || (pwh#(5)::cmpEQ(bank0,5'h1e) && stepOver) : 1'bz;
  assign mOp_split_X=(pwh#(32)::cmpEQ(opsize,4)) ?
    pwh#(4)::cmpEQ(bank0[4:1],4'hf) || (pwh#(5)::cmpEQ(bank0,5'h1d) && stepOver2) : 1'bz;
  assign mOp_split_X=(pwh#(32)::cmpEQ(opsize,5 )|| pwh#(32)::cmpEQ(opsize,6)) ?
    pwh#(3)::cmpEQ(bank0[4:2],3'h7) && (bank0[1:0]!=0 || stepOver || pwh#(32)::cmpEQ(opsize,6)) : 1'bz;
  assign mOp_split_X=(pwh#(32)::cmpEQ(opsize,0)) ? 1'b0 : 1'bz;
  
  assign all_banks=banks0;

  except_jump_cmp cmp_mod(valS,calu[4] ? 4'hf : calu[3:0],doJmp);


  assign attr2=mex_en ? mex_attr : attr;  
  
  assign mOp_addrEven[12:8]=addrMain[7] ? addrNext[12:8] : addrMain[12:8];
  assign mOp_addrOdd[12:8]=addrMain[7] ? addrMain[12:8] : addrNext[12:8];
  
  assign mOp_odd=addrMain[7];
  assign mOp_addr_low=addrMain[1:0];
  
  assign addrTlb={proc[20:0],cmplxAddr[43:13]};

  assign mlb_data=mlb_data0;
  assign mlb_data_next=mlb_data1;

  assign mOp_type={mlb_data[`dmlbData_semaphore_area],mlb_data[`dmlbData_type]};
  
  assign mOp_addrEven[43:13]=(addrMain[7] & addrNext[14]) ? mlb_data_next[`dmlbData_phys] : mlb_data[`dmlbData_phys];
  assign mOp_addrOdd[43:13]=(~(~addrMain[7] & addrNext[14])) ? mlb_data[`dmlbData_phys] : mlb_data_next[`dmlbData_phys];
  
  assign pageFault_t=(addrNext[14]) ? (fault_mlb | ({2{mOp_split}} & fault_mlb_next)) & {2{mlb_hit}} : fault_mlb & {2{mlb_hit}};
  assign pageFault=(pageFault_t_reg!=0) | fault_cann_reg | error_reg && read_clkEn_reg2|mex_en_reg2 && ~bus_hold_reg2;
  assign fault_cann=~cout_secq;
  assign faultNo=fault_cann_reg | (pageFault_t_reg!=0) | error_reg ? {error_reg ? 6'd63 : 6'd11,1'b0,2'd1} : {6'd0,1'b0,2'd2};
  assign faultCode={3'b0,fault_cann_reg,is_stack_reg,is_kstack_reg,addrMain_reg[2],mflags[thread_reg][-1+`mflags_priv]};

  assign is_kstack=&addrMain[43:41] || ~addrMain[43] && ~mflags[thread][`mflags_priv+1]; //it is not all stack but we must disallow stealing global map pointers
  assign is_stack=~addrMain[43] & &addrMain[42:40]; //reserved area for subsystem and /or stack

  assign mOp_addrMain={addrTlb[30:0],addrMain[12:0]};
  
  assign mlbMiss=(read_clkEn_reg)&~mlb_hit&~fault_cann&~except;
  
  assign addrMain=cmplxAddr[13:0];
  
  assign mOp_en=read_clkEn_reg &mlb_hit
   & rcn_mask[1] & ~bus_hold_reg;
  
  assign mOp_thread=thread_reg;

  assign wp=|(mlb_data[`dmlbData_wp]&(4'b1<<addrTlb[13:12])) || |(mlb_data[`dmlbData_wp]&(1'b1<<(addrTlb[13:12]+2'd1))) & addrNext[12] & mOp_split_X;
  assign wp_next= |(mlb_data_next[`dmlbData_wp]&(1'b1<<(addrTlb[13:12]+2'd1))) & addrNext[12] & mOp_split_X;
  
  assign mOp_lsflag=lsflag_reg;
  
  assign mOp_sz=op_reg[5:1];
  
  assign mOp_st=op_reg[0] && doJmp_reg;
  
  assign mOp_register=regno_reg;

  assign mOp_LSQ=LSQ_no_reg;

  assign mOp_II=II_no_reg;
  
  assign mOp_WQ=WQ_no_reg;

  assign mOp_attr=attr2_reg;
  
  assign mlb_clkEn=read_clkEn_reg|mex_en_reg;
  
  assign doStall=1'b0;

//mOp_rsEn used as enable to wtmiss
  assign mOp_rsEn= read_clkEn_reg & rcn_mask[1] & ~bus_hold_reg;
    
  assign rcn_mask={~(except),~(except)};
  
  assign mflags0=mflags[thread];
  
  assign fault_mlb={mflags0[`mflags_priv+1] & mlb_data[`dmlbData_user], ~mlb_data[`dmlbData_na]|~wp}; 
	assign fault_mlb_next={mflags0[`mflags_priv+1] & mlb_data_next[`dmlbData_user] , ~mlb_data_next[`dmlbData_na]|~wp_next}; 

  pwire coov,cout_secq1,cout_secq2;

  adder_15_11 #(15) nextCAddr_mod({1'b0,cmplxAddr[13:0]},15'b10000000,addrNext,1'b0,1'b1,,coov,,);

  addrcalcsec_range rng_mod(
  cmplxAddr,
  cin_secq,
  ptrdiff,
  cout_secq1);
 
  assign cmplxAddr_overreach[10:0]=addrNext[10:0];
  adder_inc #(33) cmplxAddr_add(cmplxAddr[43:11],cmplxAddr_overreach[43:11],coov,1'b1);

  addrcalcsec_range rng_mod(
  cmplxAddr_overreach,
  cin_secq,
  ptrdiff,
  cout_secq2);

  assign cout_secq=cout_secq1 && (cout_secq2 | ~mOp_split);
  
  always @*
    begin
      case(opsize)
        0: begin aligned2=1'b1; tiny=1'b1; end //byte
        1: begin aligned2=~cmplxAddr[0]; tiny=1'b1; end //2 byte
        2,3,4: 
          begin 
            aligned2=cmplxAddr[1:0]==0;
            tiny=1'b0;
          end //4,8,16 byte
      endcase
    end
  
  always @*
    begin
//addrCarry=starting at +1 offset
//stepOver=step to next 4 byte for 4 byte op
              stepOver=stepOverCmplx;
              addrCarry=1'b0;
              stepOver2=stepOverCmplx2;
    end
	
  always @*
    begin
      for (i=0;i<32;i=i+1)
        begin
  /* verilator lint_off WIDTH */
          banks0[i]=pwh#(32)::cmpEQ(bank0,i) || 
          ((pwh#(32)::cmpEQ(opsize,3 )|| opsize[2] || (stepOver && pwh#(32)::cmpEQ(opsize,2)) || 
            (stepOver2 && pwh#(32)::cmpEQ(opsize,1))) && bank0==((i-1)&5'h1f)) ||
          (((pwh#(32)::cmpEQ(opsize,3 )&& stepOver) | opsize[2]) && bank0==((i-2)&5'h1f)) || 
          (((pwh#(32)::cmpEQ(opsize,4 )&& stepOver2) || pwh#(32)::cmpEQ(opsize,5 )|| pwh#(32)::cmpEQ(opsize,6)) && bank0==((i-3)&5'h1f)) ||
          (((pwh#(32)::cmpEQ(opsize,5 )&& stepOver) || pwh#(32)::cmpEQ(opsize,6)) && bank0==((i-4)&5'h1f)) || (pwh#(32)::cmpEQ(opsize,7 )&& bank0[4:3]=={i[4:3],3'b0}) ;
        end
  /* verilator lint_on WIDTH */
    end
    
  always @* begin
      case(op_reg[5:1])
         5'd16: opsize=0;
         5'd17: opsize=1;
         5'd18: opsize=2;
         5'd19: opsize=3;
         5'h3:  opsize=4; //long double
         5'h0,5'h1,5'h2:  opsize=5; //int, double, single 64 bit
         5'hc,5'hd,5'he:  opsize=7; //int, double, single 128 bit
         5'h4,5'h5,5'h6:  opsize=2; //singleE,single,singleD
         5'h8,5'h9,5'ha:  opsize=3; //doubleE, double, singlePairD
	 //7,11=64 bit
	 5'hf: opsize=6;//fill-spill
	 default: opsize=3;
      endcase
  end
	
  always @(posedge clk)
    begin
//	  if (rst) cmplxAddr<={ADDR_WIDTH{1'B0}};
//	  else cmplxAddr<=mex_en ? mex_addr : cmplxAddr_d;
          doJmp_reg<=doJmp;
	  if (|fault_mlb && read_clkEn_reg|mex_en_reg) $display("WfaultTlb");
	  if (fault_cann && read_clkEn_reg|mex_en_reg) $display("WfaultPtr");
          if (rst) mex_en_reg<=1'b0;
          else mex_en_reg<=mex_en;
          if (rst) mex_en_reg2<=1'b0;
          else mex_en_reg2<=mex_en_reg;
	  if (rst) mlb_data_reg<={TLB_DATA_WIDTH{1'B0}};
	  else mlb_data_reg<=mlb_data;
          if (rst) error_reg<=1'b0;
          else error_reg<=error;

	  if (mex_en_reg && ~mlb_hit) $display("sch ",addrTlb>>1," ",mlb_clkEn); 
          if (rst) begin
             // cmplxAddr_reg<=16'b0;
              pageFault_t_reg<=2'b0;
              fault_cann_reg<=1'b0;
              is_kstack_reg<=1'b0;
              is_stack_reg<=1'b0;
              addrMain_reg<=1'b0;
          end else begin
             // cmplxAddr_reg<=cmplxAddr;
              pageFault_t_reg<=pageFault_t;
              fault_cann_reg<=fault_cann;
              is_kstack_reg<=is_kstack;
              is_stack_reg<=is_stack;
              addrMain_reg<=cmplxAddr[2];
          end


	  if (rst)
	    begin
	      //proc_reg<=15'b0;
	      //proc_reg2<=15'b0;
              op_reg<=13'b0;
              regno_reg<={REG_WIDTH{1'B0}};
              LSQ_no_reg<=9'b0;
              II_no_reg<=10'b0;
              WQ_no_reg<=6'b0;
	      attr2_reg<=4'b0;
              thread_reg<=1'b0;
              lsflag_reg<=1'b0;
	    end
	  else
	    begin
	      //proc_reg<=proc;
	      //proc_reg2<=proc_reg;
              op_reg<=op;
              regno_reg<=regno;
              LSQ_no_reg<=LSQ_no;
              II_no_reg<=II_no;
              WQ_no_reg<=WQ_no;
	      attr2_reg<=attr2;
              thread_reg<=thread;
              lsflag_reg<=lsflag;
	    end
	  if (rst) begin
	      bus_hold_reg<=1'b0;
	      bus_hold_reg2<=1'b0;
	  end else begin
	      bus_hold_reg<=bus_hold;
	      bus_hold_reg2<=bus_hold_reg;
	  end
	  if (rst) bit_confl_reg<=32'b0;
	  else bit_confl_reg<=bit_confl;
	  
	  if (rst) begin
	      modeCmplx_reg<=1'b0;
	      read_clkEn_reg<=1'b0;
	      read_clkEn_reg2<=1'b0;
              except_reg<=1'b0;
              except_reg2<=1'b0;
              //except_thread_reg<=1'b0;
              //except_thread_reg2<=1'b0;
	  end else begin 
	      modeCmplx_reg<=modeCmplx;
              read_clkEn_reg<=read_clkEn && rcn_mask[0] & ~except_reg;
              read_clkEn_reg2<=read_clkEn_reg && rcn_mask[1];
              except_reg<=except;
              except_reg2<=except_reg;
              //except_thread_reg<=except_thread;
              //except_thread_reg2<=except_thread_reg;
	  end
          if (rst) begin
              pproc[0]<=24'b0;
              vproc[0]<=24'b0;
              mflags[0]<=64'b0;
              pproc[1]<=24'b0;
              vproc[1]<=24'b0;
              mflags[1]<=64'b0;
          end else if (msrss_en) begin
              case(msrss_no[14:0])
           `csr_page: begin pproc[msrss_no[15]]<=msrss_data[63:40]; end
           `csr_vmpage: vproc[msrss_no[15]]<=msrss_data[63:40];
           `csr_mflags: mflags[msrss_no[15]]<=msrss_data;
              endcase
	      mflags[msrss_no[15]][`mflags_priv]<={attr2[`attr_um],attr2[`attr_sec]};
          end else begin
	      mflags[msrss_no[15]][`mflags_priv]<={attr2[`attr_um],attr2[`attr_sec]};
	      mflags[msrss_no[15]][`mflags_sec]<=attr2[`attr_sec];
	  end
    end

    always @* begin
	if (~attr2[`attr_vm]) begin
	    proc=pproc[thread];
	    sproc=0;
	end
	if (attr2[`attr_vm]) begin
	    proc=vproc[thread];
	    sproc=pproc[thread]^1;
	end
    end   
endmodule
