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
`include "../exc.v"

module addrcalc(
  clk,
  rst,
  except,
 // except_gate,
 // except_in_vm,
//  except_in_km,
  attr,
  rsStall,
  read_clkEn,
  doStall,
  bus_hold,
  op,
  shiftSize,
  regno,
  LSQ_no,
  II_no,
  WQ_no,
  thread,
  lsflag,
  cmplxAddr,
  cin_secq,
  ptrdiff,
  error,
  other0_banks,
  other1_banks,
  otherR_banks,
  other_flip,
  conflict,
  mlbMiss,
  pageFault,
  faultCode,
  faultNo,
  mOp_register,
  mOp_type,
  mOp_skip_LDQ,
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
  mOp_invmlb,
  mOp_rsEn,
  mOp_thread,
  mOp_lsflag,
  mOp_banks,
  mOp_rsBanks,
  mOp_bank0,
  mOp_odd,
  mOp_addr_low,
  mOp_split,
  mOp_noBanks,
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
  input pwire rsStall;
  input pwire read_clkEn;
  output pwire doStall;
  input pwire bus_hold;
  input pwire [OPERATION_WIDTH-1:0] op;
  input pwire [3:0] shiftSize;
  input pwire [REG_WIDTH-1:0] regno;
  input pwire [8:0] LSQ_no;
  input pwire [9:0] II_no;
  input pwire [5:0] WQ_no;
  input pwire thread;
  input pwire lsflag;
  input pwire [64:0] cmplxAddr;
  input pwire cin_secq;
  input pwire ptrdiff;
  input pwire error;
  input pwire [BANK_COUNT-1:0] other0_banks;
  input pwire [BANK_COUNT-1:0] other1_banks;
  input pwire [BANK_COUNT-1:0] otherR_banks;
  input pwire other_flip;
  output pwire conflict;
  output pwire mlbMiss;
  output pageFault;
  output pwire [7:0] faultCode;
  output pwire [8:0] faultNo;
  output pwire [REG_WIDTH-1:0] mOp_register;
  output pwire [2:0] mOp_type;
  output pwire mOp_skip_LDQ;
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
  output pwire mOp_invmlb;
  output pwire mOp_rsEn;
  output pwire mOp_thread;
  output pwire mOp_lsflag;
  output pwire [BANK_COUNT-1:0] mOp_banks;
  output pwire [BANK_COUNT-1:0] mOp_rsBanks;
  output pwire [4:0] mOp_bank0;
  output pwire mOp_odd;
  output pwire [1:0] mOp_addr_low;
  output pwire mOp_split;
  output pwire [BANK_COUNT-1:0] mOp_noBanks;
  input pwire [15:0] msrss_no;
  input pwire msrss_en;
  input pwire msrss_thr;
  input pwire [64:0] msrss_data;
  output pwire mlb_clkEn;
  output pwire cout_secq;
  output pwire  [TLB_IP_WIDTH-1:0] addrTlb;
  output pwire [23:0] sproc;
  input pwire [TLB_DATA_WIDTH-1:0] mlb_data0;
  input pwire [TLB_DATA_WIDTH-1:0] mlb_data1;
  input pwire mlb_hit;

  reg [2:0] opsize;
  pwire hasIndex;
  reg aligned;//aligned for int subsys purpose not arch
  reg aligned2;//same for complex addressing
  reg tiny; //1 or 2 byte
  
  reg [2:0] addrMain_reg;

  reg mode64;
  reg modeCmplx;
  reg modeCmplx_reg;
  
  pwire isLongOffset;
  reg stepOver;//step over to next bank because of offset
  reg stepOver2;
  reg addrCarry;//offset by one bank
  pwire stepOverCmplx;
  pwire stepOverCmplx2;

  pwire modeCmplx_d;
  //complex mode when index register used, or offset not fit in unsigned 12-bit range

  reg [31:0] banks0;
  
  pwire [4:0] bank0;
  pwire [4:0] bankL1;
  reg  [2:0] mOp_type_reg;
  pwire split;
  pwire [13:0] addrMain;
  pwire [14:0] addrNext;
  pwire [13:0] dummy0;
//  pwire [13:0] CSAarg1;
//  pwire [13:0] CSAarg2;
//  pwire pageCarry;
//  pwire pageCarry1;
  
//  pwire [5:0] CSAbn0;
//  pwire [5:0] CSAbn1;
  
  pwire [TLB_IP_WIDTH-1:0] addrTlb;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data0;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data1;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data;
  pwire [TLB_DATA_WIDTH-1:0] mlb_data_next;
  reg [TLB_DATA_WIDTH-1:0] mlb_data_reg;
  
  pwire mlb_clkEn;
  pwire mlb_hit;
  pwire cout_secq;
  

  reg read_clkEn_reg;
  reg read_clkEn_reg2;
  reg [OPERATION_WIDTH-1:0] op_reg;


  pwire [BANK_COUNT-1:0] all_banks;
  pwire otherness;

  pwire [BANK_COUNT-1:0] bit_confl;
  reg  [BANK_COUNT-1:0] bit_confl_reg;
  
  reg cin_secq_reg;
  
  pwire carryNext;
 // pwire non_overlap;

  reg [23:0] proc;
  reg [1:0][23:0] pproc;
  reg [23:0] sproc;
  reg [1:0][23:0] vproc;
  //reg [23:0] proc_reg;
  //reg [23:0] proc_reg2;
  reg [1:0][63:0] mflags;
  pwire [64:0] mflags0; 
  integer i;
  
//  reg [ADDR_WIDTH-1:48] cmplxAddr_reg;
  
//  pwire [4:0] bankNextOff;
//  pwire hasBankNext;
  
  reg bus_hold_reg;
  reg bus_hold_reg2;
  
  reg [REG_WIDTH-1:0] regno_reg;
  reg [8:0] LSQ_no_reg;
  reg [9:0] II_no_reg;
  reg [5:0] WQ_no_reg;
  reg thread_reg;
  reg lsflag_reg;
  reg thread_reg2;

  pwire [1:0] rcn_mask;

  reg except_reg;
  reg except_reg2;
  reg except_thread_reg;
  reg except_thread_reg2;
  
  pwire [1:0] fault_mlb;
  pwire [1:0] fault_mlb_next;
  pwire [4:0] lastSz;
  pwire [1:0] pageFault_t;
  reg [1:0] pageFault_t_reg; 
  pwire fault_cann;
  reg fault_cann_reg;
  reg error_reg;

  reg [3:0] attr_reg;
  
  generate
      genvar p,q;
      for(p=0;p<32;p=p+1) begin
          pwire otherness;
          assign otherness=~(otherR_banks[p] & all_banks[p]);
        
          if (INDEX==0) begin
              assign bit_confl[p]=otherness && ~other_flip|~(all_banks[p]&&other0_banks[p]|other1_banks[p]);
          end
          if (INDEX==1) begin
              assign bit_confl[p]=other_flip ? otherness && ~(other1_banks[p]&all_banks[p]) :
                otherness && ~(other0_banks[p]&all_banks[p]);
          end
/*          if (INDEX==2) begin
              assign bit_confl[p]=(otherness && ~other_flip && !(other1_banks[p] & all_banks[p]))
                ? 1'b1 : 1'bz;
              assign bit_confl[p]=(otherness && other_flip && !(other0_banks[p] & all_banks[p]))
                ? 1'b1 : 1'bz;
              assign bit_confl[p]=((~other_flip && (other1_banks[p] & all_banks[p])) || ~otherness) ? 1'b0 : 1'bz;
              assign bit_confl[p]=((other_flip && (other0_banks[p] & all_banks[p])) || ~otherness) ? 1'b0 : 1'bz;
          end*/
          assign mOp_banks[p]=(all_banks[p] & read_clkEn_reg) & bit_confl[p]; 
      end
      if (INDEX==1) begin
        assign mOp_noBanks=~(mOp_banks|other0_banks|other1_banks|otherR_banks);
      end

  endgenerate
 
//  assign bankNextOff=5'd2; //##
//  assign hasBankNext=1'b0;//##
  assign hasIndex=op[7:6]==2'b01;
  assign stepOverCmplx=|cmplxAddr[1:0];
  assign stepOverCmplx2=&cmplxAddr[1:0];
  assign bank0=cmplxAddr[6:2];
  assign mOp_bank0=bank0;

  assign mOp_rsBanks=all_banks & {32{mOp_rsEn}}; 
  assign lastSz[1]=(opsize==1 && stepOver2) || (opsize==2 && stepOver) || (opsize==3 && ~stepOver);
  assign lastSz[2]=opsize==3 && stepOver;
  assign lastSz[4:3]=2'b0;
  assign lastSz[0]=(opsize==0) || (opsize==1 & ~stepOver2) || (opsize==2 & ~stepOver);  
  assign mOp_split=(opsize==1) ?
    bank0==5'h1f && stepOver2 : 1'bz;
  assign mOp_split=(opsize==2) ?
    bank0==5'h1f && stepOver : 1'bz;
  assign mOp_split=(opsize==3) ?
    bank0==5'h1f || (bank0==5'h1e && stepOver) : 1'bz;
  assign mOp_split=(opsize==4) ?
    bank0[4:1]==4'hf || (bank0==5'h1d && stepOver2) : 1'bz;
  assign mOp_split=(opsize==5||opsize==6) ?
    bank0[4:2]==3'h7 && (bank0[1:0]!=0 || stepOver || opsize==6) : 1'bz;
  assign mOp_split=(opsize==0) ? 1'b0 : 1'bz;
  
  assign mOp_skip_LDQ=~mlb_data[`dmlbData_wp] && ~mlb_data[`dmlbData_wp]|~addrNext[13];
  
  assign all_banks=banks0;

  assign split=(opsize==1) ?
    bank0==5'h1f && stepOver2 : 1'bz;
  assign split=(opsize==2) ?
    bank0==5'h1f && stepOver : 1'bz;
  assign split=(opsize==3) ?
    bank0==5'h1f || (bank0==5'h1e && stepOver) : 1'bz;
  assign split=(opsize==4) ?
    bank0[4:1]==4'hf || (bank0==5'h1d && stepOver2) : 1'bz;
  assign split=(opsize==5 || opsize==6) ?
    bank0[4:2]==3'h7 && (bank0[1:0]!=0 || stepOver || opsize==6) : 1'bz;
  assign split=(opsize==0) ? 1'b0 : 1'bz;

  assign conflict=(((|(~bit_confl_reg))||mOp_type_reg[1]) && ~bus_hold_reg2 && 
    read_clkEn_reg2 && ~fault_cann_reg);
  
  
  assign mOp_addrEven[12:8]=(addrMain[7] ) ? addrNext[12:8] : 5'bz;
  assign mOp_addrEven[12:8]=(~addrMain[7]) ? addrMain[12:8] : 5'bz;
  assign mOp_addrOdd[12:8]=(addrMain[7] ) ? addrMain[12:8] : 5'bz;
  assign mOp_addrOdd[12:8]=(~addrMain[7]) ? addrNext[12:8] : 5'bz;
  
  assign mOp_odd=addrMain[7];
  assign mOp_addr_low=addrMain[1:0];
  
  assign addrTlb={proc[20:0],cmplxAddr[43:13]};

  assign mlb_data=mlb_data0;
  assign mlb_data_next=mlb_data1;

  assign na=|(mlb_data[`dmlbData_na]&(4'b1<<addrTlb[13:12])) || |(mlb_data[`dmlbData_na]&(1'b1<<(addrTlb[13:12]+2'd1))) & addrNext[12] & mOp_split_X;
  assign na_next= |(mlb_data_next[`dmlbData_na]&(1'b1<<(addrTlb[13:12]+2'd1))) & addrNext[12] & mOp_split_X;

  assign mOp_type={mlb_data[`dmlbData_semaphore],mlb_data[`dmlbData_type]};
  assign mOp_addrEven[43:13]=(addrMain[7] && addrNext[14]) ? mlb_data_next[`dmlbData_phys] :
    31'bz;
  assign mOp_addrEven[43:13]=(~(addrMain[7] && addrNext[14] )) ?  mlb_data[`dmlbData_phys] :
    31'bz;
  assign mOp_addrOdd[43:13]=(~(~addrMain[7] && addrNext[14] ) ) ? mlb_data[`dmlbData_phys] : 
    31'bz;
  assign mOp_addrOdd[43:13]=(~addrMain[7] && addrNext[14] ) ? mlb_data_next[`dmlbData_phys] :
    31'bz;
//todo: add read_clkEn to pageFault
  assign pageFault_t=(addrNext[14]) ? (fault_mlb | ({2{split}} & fault_mlb_next)) & {2{mlb_hit}} : fault_mlb & {2{mlb_hit}};
  assign pageFault=(pageFault_t_reg!=0) | fault_cann_reg | error_reg && read_clkEn_reg2 && ~bus_hold_reg2;
  assign fault_cann=~cout_secq;
  assign faultNo=fault_cann_reg | (pageFault_t_reg!=0) | error_reg && ~bus_hold_reg2 ? {error_reg ? 6'd63 : 6'd11,1'b0,2'd1} : 
    {6'd0,1'b0,2'd2};
  assign faultCode={3'b0,fault_cann_reg,is_stack_reg,is_kstack_reg,addrMain_reg[2],attr_reg[`attr_sec]};
  assign mOp_addrMain={addrTlb[30:0],addrMain[12:0]};

  assign is_kstack=&addrMain[43:41] || ~addrMain[43] && ~mflags[thread][`mflags_priv+1]; //it is not all stack but we must disallow stealing global map pointers
  assign is_stack=~addrMain[43] & &addrMain[42:40]; //reserved area for subsystem and /or stack

  assign tlbMiss=read_clkEn_reg&~tlb_hit&~fault_cann & rcn_mask[1];
  
  assign addrMain=cmplxAddr[12:0];
  
  assign mOp_en= read_clkEn_reg &(mlb_hit||op[7]&op[1]) & rcn_mask[1];

  assign mOp_secq=fault_cann & read_clkEn;
  
  assign mOp_thread=thread_reg;
  
  assign mOp_lsflag=lsflag_reg;
  
  assign mOp_sz=op_reg[5:1];
  assign mOp_invmlb=op_reg[7];
  
  assign mOp_st=op_reg[0];
 

  assign mOp_register=regno_reg;

  assign mOp_LSQ=LSQ_no_reg;

  assign mOp_II=II_no_reg;
  
  assign mOp_WQ=WQ_no_reg;
  
  assign mOp_attr=attr_reg;
  
  assign mlb_clkEn=read_clkEn_reg;
  
  assign doStall=1'b0;

  assign mOp_rsEn=read_clkEn_reg &(mlb_hit||op[7]&op[1]) & rcn_mask[1];
    
  assign rcn_mask={~(except),~(except)};
//  assign proc=pproc[thread];
  
  assign mflags0=mflags[thread];
  
  assign fault_mlb={mflags0[`mflags_priv+1] & mlb_data[`dmlbData_user] , ~na}; 
  assign fault_mlb_next={mflags0[`mflags_priv+1] & mlb_data_next[`dmlbData_user],  ~na_next}; 

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
  always @*
    begin
      for (i=0;i<32;i=i+1)
       /* verilator lint_off WIDTH */
       begin
          banks0[i]=bank0==i || 
          ((opsize==6 || opsize==3 || opsize[2] || (stepOver && opsize==2) || 
            (stepOver2 && opsize==1)) && bank0==((i-1)&5'h1f)) ||
          (((opsize==3 && stepOver) || opsize[2] || opsize==6 ) && bank0==((i-2)&5'h1f)) || 
          (((opsize==4 && stepOver2) || opsize==5 || opsize==6) && bank0==((i-3)&5'h1f)) ||
          (((opsize==5 && stepOver) || opsize==6) && bank0==((i-4)&5'h1f)) || (opsize==7 && bank0[4:3]=={i[4:3],3'b0});
        end
      /* verilator lint_on WIDTH */
    end
    
	
  always @(posedge clk)
    begin
	  if (rst) mlb_data_reg<={TLB_DATA_WIDTH{1'B0}};
	  else mlb_data_reg<=mlb_data;
          if (rst) begin
             // cmplxAddr_reg<=64'b0;
              pageFault_t_reg<=2'b0;
              fault_cann_reg<=1'b0;
              error_reg<=1'b0;
              is_kstack_reg<=1'b0;
              is_stack_reg<=1'b1;
              addrMain_reg<=1'b0;
          end else if (!rsStall) begin
             // cmplxAddr_reg<=cmplxAddr;
              pageFault_t_reg<=pageFault_t;
              fault_cann_reg<=fault_cann;
              error_reg<=error;
              is_kstack_reg<=is_kstack;
              is_stack_reg<=is_stack;
              addrMain_reg<=addrMain[2];
          end
	  mOp_type_reg<=mOp_type;
	  if (rst)
	    begin
	      //proc_reg<=15'b0;
	      //proc_reg2<=15'b0;
              op_reg<=13'b0;
              regno_reg<={REG_WIDTH{1'B0}};
              LSQ_no_reg<=9'b0;
              II_no_reg<=10'b0;
              WQ_no_reg<=6'b0;
	      attr_reg<=4'b0;
              thread_reg<=1'b0;
              thread_reg2<=1'b0;
              lsflag_reg<=1'b0;
	    end
	  else if (!rsStall)
	    begin
	      //proc_reg<=proc;
	      //proc_reg2<=proc_reg;
              op_reg<=op;
              regno_reg<=regno;
              LSQ_no_reg<=LSQ_no;
              II_no_reg<=II_no;
              WQ_no_reg<=WQ_no;
	      attr_reg<=attr;
              thread_reg<=thread;
              thread_reg2<=thread_reg;
              lsflag_reg<=lsflag;
	    end
	  if (rst) begin
	      bus_hold_reg<=1'b0;
	      bus_hold_reg2<=1'b0;
	  end else if (!rsStall) begin
	      bus_hold_reg<=bus_hold;
	      bus_hold_reg2<=bus_hold_reg;
	  end
	  if (rst) bit_confl_reg<=32'b0;
	  else if (!rsStall) bit_confl_reg<=bit_confl;
	  
	  if (rst) begin
	      read_clkEn_reg<=1'b0;
	      read_clkEn_reg2<=1'b0;
              except_reg<=1'b0;
              except_reg2<=1'b0;
              //except_thread_reg<=1'b0;
              //except_thread_reg2<=1'b0;
	  end else if (!rsStall) begin 
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
           `csr_page: begin pproc[msrss_no[15]]<=msrss_data[63:40];  end
           `csr_vmpage: vproc[msrss_no[15]]<=msrss_data[63:40];
           `csr_mflags: mflags[msrss_no[15]]<=msrss_data;
              endcase
	      mflags[msrss_no[15]][`mflags_priv]<={attr[`attr_um],attr[`attr_sec]};
          end else if (!rsStall) begin
	      mflags[thread][`mflags_priv]<={attr[`attr_um],attr[`attr_sec]};
          end
	  
    end
    always @* begin
	      if (~attr[`attr_vm]) begin
		  proc=pproc[thread];
		  sproc=0;
	      end
	      if (attr[`attr_vm]) begin
		  proc=vproc[thread];
		  sproc=pproc[thread]^1;
	      end
    end
   
endmodule


module addrcalc_get_shiftSize(op,shiftSize,sh2);
  localparam OPERATION_WIDTH=`operation_width;
  input pwire [OPERATION_WIDTH-1:0] op;
  output pwire reg [3:0] shiftSize;
  output pwire reg [1:0] sh2;
  always @* begin
      if (op[7:6]==2'b01) begin
          case(op[9:8])
       2'd0: shiftSize=4'b1;
       2'd1: shiftSize=4'b10;
       2'd2: shiftSize=4'b100;
       2'd3: shiftSize=4'b1000;
          endcase
          sh2=op[9:8];
      end else begin
          shiftSize=4'b1;
          sh2=2'b0;
      end
  end
endmodule
