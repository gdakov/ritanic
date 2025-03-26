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

//read-during-write behaviour: write first
module addrcalccam_ram0(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=(3+3*`mOp_width)/2+1;
  localparam ADDR_WIDTH=3;
  localparam ADDR_COUNT=8;

  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  reg [DATA_WIDTH-1:0] ram [7:0];
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module addrcalccam_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=3+3*`mOp_width;
  localparam ADDR_WIDTH=3;
  localparam ADDR_COUNT=8;
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  //verilator lint_off WIDTH
  addrcalccam_ram0 ramA(clk,rst,read_clkEn,read_addr,read_data[DATA_WIDTH/2-1:0],
    write_addr,write_data[DATA_WIDTH/2-1:0],write_wen);
  addrcalccam_ram0 ramB(clk,rst,read_clkEn,read_addr,read_data[DATA_WIDTH-1:
    DATA_WIDTH/2],write_addr,write_data[DATA_WIDTH-1:DATA_WIDTH/2],write_wen);
  //verilator lint_on WIDTH
endmodule



module addrcalccam(
  clk,
  rst,
  except,
  except_thread,
  read_clkEn,
  doSkip,
  rsStall,
  conflict0,
  mOp0_addrMain,
  mOp0_regNo,
  mOp0_type,
  mOp0_sz,
  mOp0_invmlb,
  mOp0_split,
  mOp0_bank0,
  mOp0_LSQ,
  mOp0_II,
  mOp0_WQ,
  mOp0_thread,
  mOp0_lsflag,
  mOp0_attr,
  conflict1,
  mOp1_addrMain,
  mOp1_regNo,
  mOp1_type,
  mOp1_sz,
  mOp1_invmlb,
  mOp1_split,
  mOp1_bank0,
  mOp1_LSQ,
  mOp1_II,
  mOp1_WQ,
  mOp1_thread,
  mOp1_lsflag,
  mOp1_attr,
  conflict2,
  mOp2_addrMain,
  mOp2_regNo,
  mOp2_type,
  mOp2_sz,
  mOp2_invmlb,
  mOp2_split,
  mOp2_bank0,
  mOp2_LSQ,
  mOp2_II,
  mOp2_WQ,
  mOp2_thread,
  mOp2_lsflag,
  mOp2_attr,

  mOpR_addrMain,
  mOpR_lsfw,
  mOpR_addrEven,
  mOpR_addrOdd,
  mOpR_regNo,
  mOpR_type,
  mOpR_odd,
  mOpR_low,
  mOpR_sz,
  mOpR_invmlb,
  mOpR_split,
  mOpR_en,
  mOpR_bank0,
  mOpR_LSQ,
  mOpR_II,
  mOpR_WQ,
  mOpR_thread,
  mOpR_lsflag,
  mOpR_attr
  );

  localparam DEPTH=8;
  localparam ADDR_WIDTH=3;
  localparam DATA_WIDTH=3+3*`mOp_width;
  localparam MOP_WIDTH=`mOp_width;
  localparam MOPX_WIDTH=`mOpX_width;
  localparam MDATA_WIDTH=2+MOPX_WIDTH+128+8;
  localparam STALL_COUNT=4;
  localparam VADDR_WIDTH=44;
  localparam PADDR_WIDTH=44;
  localparam OPERATION_WIDTH=`operation_width;
  localparam TLB_DWIDTH=`dmlbData_width;
  localparam BANK_COUNT=32;
  localparam REG_WIDTH=`reg_addr_width;
  localparam WQ_WIDTH=6;
 
  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire except_thread;
  input pwire read_clkEn;
  output pwire reg doSkip;
  input pwire rsStall;

  input pwire conflict0;
  input pwire [VADDR_WIDTH-1:0] mOp0_addrMain;
  input pwire [REG_WIDTH-1:0] mOp0_regNo;
  input pwire [1:0] mOp0_type;
  input pwire [4:0] mOp0_sz;
  input pwire mOp0_invmlb;
//  input pwire mOp0_st;
  input pwire mOp0_split;
  input pwire [4:0] mOp0_bank0;
  input pwire [8:0] mOp0_LSQ;
  input pwire [9:0] mOp0_II;
  input pwire [5:0] mOp0_WQ;
  input pwire mOp0_thread;
  input pwire mOp0_lsflag;
  input pwire [3:0] mOp0_attr;

  input pwire conflict1;
  input pwire [VADDR_WIDTH-1:0] mOp1_addrMain;
  input pwire [REG_WIDTH-1:0] mOp1_regNo;
  input pwire [1:0] mOp1_type;
  input pwire [4:0] mOp1_sz;
  input pwire mOp1_invmlb;
//  input pwire mOp1_st;
  input pwire mOp1_split;
  input pwire [4:0] mOp1_bank0;
  input pwire [8:0] mOp1_LSQ;
  input pwire [9:0] mOp1_II;
  input pwire [5:0] mOp1_WQ;
  input pwire mOp1_thread;
  input pwire mOp1_lsflag;
  input pwire [3:0] mOp1_attr;

  input pwire conflict2;
  input pwire [VADDR_WIDTH-1:0] mOp2_addrMain;
  input pwire [REG_WIDTH-1:0] mOp2_regNo;
  input pwire [1:0] mOp2_type;
  input pwire [4:0] mOp2_sz;
  input pwire mOp2_invmlb;
//  input pwire mOp2_st;
  input pwire mOp2_split;
  input pwire [4:0] mOp2_bank0;
  input pwire [8:0] mOp2_LSQ;
  input pwire [9:0] mOp2_II;
  input pwire [5:0] mOp2_WQ;
  input pwire mOp2_thread;
  input pwire mOp2_lsflag;
  input pwire [3:0] mOp2_attr;

  output pwire [VADDR_WIDTH-1:0] mOpR_addrMain;
  output pwire [PADDR_WIDTH-9:0] mOpR_addrEven;
  output pwire [PADDR_WIDTH-9:0] mOpR_addrOdd;
  output pwire mOpR_lsfw;
  output pwire [REG_WIDTH-1:0] mOpR_regNo;
  output pwire [1:0] mOpR_type;
  output pwire mOpR_odd;
  output pwire [1:0] mOpR_low;
  output pwire [4:0] mOpR_sz;
  output pwire mOpR_invmlb;
  output pwire mOpR_split;
  output pwire mOpR_en;
  output pwire [4:0] mOpR_bank0;
  output pwire [8:0] mOpR_LSQ;
  output pwire [9:0] mOpR_II;
  output pwire [5:0] mOpR_WQ;
  output pwire mOpR_thread;
  output pwire mOpR_lsflag;
  output pwire [3:0] mOpR_attr;

  pwire [2:0] curConfl;
 // pwire [3:0] write_confl;
  pwire [2:0] read_conflA;
  pwire [2:0] read_confl;
  pwire [2:0] sel;  
  pwire conflFound;
  pwire doStep;
  
  reg [ADDR_WIDTH-1:0] read_addr;
  pwire [ADDR_WIDTH-1:0] read_addr_d;
  pwire [ADDR_WIDTH-1:0] read_addrU_d;
  pwire [ADDR_WIDTH-1:0] read_addrA_d;
  pwire [ADDR_WIDTH-1:0] read_addrB_d;
  reg [ADDR_WIDTH-1:0] write_addr;
  pwire [ADDR_WIDTH-1:0] write_addr_d;
  pwire [10:0] count;
  pwire [10:1] cmore;
  pwire wen;
  
  pwire [MOP_WIDTH-1:0] write_mop[2:0];
  pwire [DATA_WIDTH-1:0] write_dataA;
  pwire [MDATA_WIDTH-1:0] write_dataB;
  pwire [MOP_WIDTH-1:0] read_mop[2:0];
  pwire [DATA_WIDTH-1:0] read_dataA;
  pwire [MDATA_WIDTH-1:0] read_dataB;

  pwire [VADDR_WIDTH-1:0] mOpR_addrMain;
 // pwire [VADDR_WIDTH-1:0] mOpR_addrNext;
  
//  pwire pageIsNext;
  
 
  reg [2:0] confl_mask;

  reg [MOP_WIDTH-1:0] write_mop_reg[2:0];

  reg init;
  reg [2:0] initCount;
  pwire [2:0] initCount_next;
  
  //genvar k;
  
  reg [DEPTH-1:0] valid[1:0];
  reg [DEPTH-1:0] vMask;
  reg [DEPTH-1:0] vMaskN;
  reg vOn_next;
  pwire [7:0] rdvalid1;
  pwire [7:0] rdvalid0;
  pwire drvalid1_found;
  pwire drvalid0_found;
  pwire [7:0] rdxvalid1;
  pwire [7:0] rdxvalid0;
  pwire drxvalid_1_found;
  pwire drxvalid_0_found;
  pwire [2:0] write_addr_inc;

  pwire excpt_fwd; 
  pwire thrmask;
  pwire [2:0] in_mask;
  
  assign write_dataA={conflict2&in_mask[2],conflict1&in_mask[1],conflict0&in_mask[0],
	  write_mop_reg[2],write_mop_reg[1],write_mop_reg[0]};
  assign wen=conflict0&in_mask[0]||conflict1&in_mask[1]||conflict2&in_mask[2];
  assign write_addr_d=(~wen & ~rst) ? write_addr : 3'bz; 
  
  assign write_addr_d=rst ? 3'b0:3'bz;
  
  assign in_mask[0]=~except;
  assign in_mask[1]=~except;
  assign in_mask[2]=~except;
  
  assign {read_conflA[2:0],read_mop[2],read_mop[1],read_mop[0]}=(wen & count[0]) ? write_dataA : read_dataA;

  assign write_mop[0][`mOp_addrMain]=mOp0_addrMain;
  assign write_mop[0][`mOp_reg]=     mOp0_regNo;
  assign write_mop[0][`mOp_type]=    mOp0_type;
  assign write_mop[0][`mOp_sz]=      mOp0_sz;
  assign write_mop[0][`mOp_st]=      mOp0_invmlb;
  assign write_mop[0][`mOp_split]=   mOp0_split;
  assign write_mop[0][`mOp_bank0]=   mOp0_bank0;
  assign write_mop[0][`mOp_LSQ]=     mOp0_LSQ;
  assign write_mop[0][`mOp_II]=      mOp0_II;
  assign write_mop[0][`mOp_WQ]=      mOp0_WQ;
  assign write_mop[0][`mOp_thread]=  mOp0_thread;
  assign write_mop[0][`mOp_lsflag]=  mOp0_lsflag;
  assign write_mop[0][`mOp_attr]=    mOp0_attr;

  assign write_mop[1][`mOp_addrMain]=mOp1_addrMain;
  assign write_mop[1][`mOp_reg]=     mOp1_regNo;
  assign write_mop[1][`mOp_type]=    mOp1_type;
  assign write_mop[1][`mOp_sz]=      mOp1_sz;
  assign write_mop[1][`mOp_st]=      mOp1_invmlb;
  assign write_mop[1][`mOp_split]=   mOp1_split;
  assign write_mop[1][`mOp_bank0]=   mOp1_bank0;
  assign write_mop[1][`mOp_LSQ]=     mOp1_LSQ;
  assign write_mop[1][`mOp_II]=      mOp1_II;
  assign write_mop[1][`mOp_WQ]=      mOp1_WQ;
  assign write_mop[1][`mOp_thread]=  mOp1_thread;
  assign write_mop[1][`mOp_lsflag]=  mOp1_lsflag;
  assign write_mop[1][`mOp_attr]=    mOp1_attr;


  assign write_mop[2][`mOp_addrMain]=mOp2_addrMain;
  assign write_mop[2][`mOp_reg]=     mOp2_regNo;
  assign write_mop[2][`mOp_type]=    mOp2_type;
  assign write_mop[2][`mOp_sz]=      mOp2_sz;
  assign write_mop[2][`mOp_st]=      mOp2_invmlb;
  assign write_mop[2][`mOp_split]=   mOp2_split;
  assign write_mop[2][`mOp_bank0]=   mOp2_bank0;
  assign write_mop[2][`mOp_LSQ]=     mOp2_LSQ;
  assign write_mop[2][`mOp_II]=      mOp2_II;
  assign write_mop[2][`mOp_WQ]=      mOp2_WQ;
  assign write_mop[2][`mOp_thread]=  mOp2_thread;
  assign write_mop[2][`mOp_lsflag]=  mOp2_lsflag;
  assign write_mop[2][`mOp_attr]=    mOp2_attr;

//  assign write_mop3[`mOpX_thr]=  1'b0; //fixme: not thread safe

  assign mOpR_en=(|sel) && ~init && (cmore[1]|wen) && ~excpt_fwd && read_clkEn;

  assign mOpR_addrMain=(!conflFound) ? {VADDR_WIDTH{1'B0}} : 'z;
  assign mOpR_addrEven=(!conflFound) ? {PADDR_WIDTH-8{1'B0}} : {PADDR_WIDTH-8{1'BZ}};
  assign mOpR_addrOdd=(!conflFound) ? {PADDR_WIDTH-8{1'B0}} : {PADDR_WIDTH-8{1'BZ}};
  assign mOpR_regNo=(!conflFound) ? {REG_WIDTH{1'B0}} : 'z;
  assign mOpR_type=(!conflFound) ? 2'B0 : 2'BZ;
  assign mOpR_sz=(!conflFound) ? 5'B0 : 5'BZ;
  assign mOpR_odd=(!conflFound) ? 1'B0 : 1'BZ;
  assign mOpR_low=(!conflFound) ? 2'B0 : 2'BZ;
  assign mOpR_invmlb=(!conflFound) ? 1'B0 : 1'BZ;
  assign mOpR_split=(!conflFound) ? 1'B0 : 1'BZ;
  assign mOpR_bank0=(!conflFound) ? 5'b0 : 5'BZ;
  assign mOpR_bank0=(!conflFound) ? 5'b0 : 5'BZ;
//  assign mOpR_data=(!conflFound) ? 136'b0 : 136'BZ;
  assign mOpR_II=(!conflFound) ? 10'b0 : 10'BZ;
  assign mOpR_WQ=(!conflFound) ? 6'b0 : 6'BZ;
  assign mOpR_thread=(!conflFound) ? 1'b0 : 1'BZ;
  assign mOpR_LSQ=(!conflFound) ? 9'b0 : 9'BZ;
  assign mOpR_lsflag=(!conflFound) ? 1'b0 : 1'BZ;
  assign thrmask=(!conflFound) ? 1'b1 : 1'BZ;
  assign mOpR_lsfw=(!conflFound) ? 1'b0 : 1'BZ;
  assign mOpR_attr=(!conflFound) ? 4'b0 : 4'BZ;
  
  assign read_confl[0]=(wen & count[0]) ? read_conflA[0] : read_conflA[0] && valid[read_mop[0][`mOp_thread]][read_addr];
  assign read_confl[1]=(wen & count[0]) ? read_conflA[1] : read_conflA[1] && valid[read_mop[1][`mOp_thread]][read_addr];
  assign read_confl[2]=(wen & count[0]) ? read_conflA[2] : read_conflA[2] && valid[read_mop[2][`mOp_thread]][read_addr];
  
  assign curConfl=read_confl&(confl_mask|{3{count[0]&&wen}});

  generate
    genvar p,k;
    for(k=0;k<=2;k=k+1) begin
        assign mOpR_addrMain=sel[k] ? read_mop[k][`mOp_addrMain] : 'z;
        assign mOpR_addrEven=sel[k] ? 36'b0 : 36'bz;
        assign mOpR_addrOdd=sel[k] ? 36'b0 : 36'bz;
        assign mOpR_odd=sel[k] ? 1'b0 : 1'bz;
        assign mOpR_low=sel[k] ? 2'b0 : 2'bz;
        assign mOpR_regNo=sel[k] ? read_mop[k][`mOp_reg] : 'z;
        assign mOpR_type=sel[k] ? read_mop[k][`mOp_type] : 2'BZ;
        assign mOpR_sz=sel[k] ? read_mop[k][`mOp_sz] : 5'BZ;
        assign mOpR_invmlb=sel[k] ? read_mop[k][`mOp_st] : 1'BZ;
        assign mOpR_split=sel[k] ? read_mop[k][`mOp_split] : 1'BZ;
        assign mOpR_bank0=sel[k] ? read_mop[k][`mOp_bank0] : 5'BZ;
        assign mOpR_LSQ=sel[k] ? read_mop[k][`mOp_LSQ] : 9'BZ;
        assign mOpR_II=sel[k] ? read_mop[k][`mOp_II] : 10'BZ;
        assign mOpR_WQ=sel[k] ? read_mop[k][`mOp_WQ] : 6'BZ;
        assign mOpR_thread=sel[k] ? read_mop[k][`mOp_thread] : 1'BZ;
        assign mOpR_lsflag=sel[k] ? read_mop[k][`mOp_lsflag] : 1'BZ;
        assign thrmask=sel[k] ? (read_mop[k][`mOp_thread]) | (~read_mop[k][`mOp_thread]) : 1'bz;
        assign mOpR_lsfw=sel[k] ? 1'b0 : 1'bz;
        assign mOpR_attr=sel[k] ? read_mop[k][`mOp_attr] : 4'bz;
    end
    for(p=0;p<8;p=p+1) begin
	assign read_addrU_d=(rdxvalid0[p] || rdvalid1[p] & drvalid0_found &
        ~drxvalid_0_found || rdxvalid1[p] & ~drvalid0_found & ~drxvalid_0_found) ? p[2:0] : 3'bz;
//	assign read_addrA_d=(rdvalidA0[p] || rdvalidA1[p] & ~drvalidA0_found) ? p[2:0] : 3'bz;
//	assign read_addrB_d=(rdvalidB0[p] || rdvalidB1[p] & ~drvalidB0_found) ? p[2:0] : 3'bz;
    end
    assign read_addrU_d=(~drxvalid_0_found && ~drxvalid_1_found &&
     ~(drvalid0_found && drvalid1_found)) && cmore[1] ? write_addr : 3'bz;
    assign read_addrU_d=(~drxvalid_0_found && ~drxvalid_1_found &&
     ~(drvalid0_found && drvalid1_found)) && ~cmore[1] ? write_addr_inc : 3'bz;
   // assign read_addrA_d=(~drvalidA0_found && ~drvalidA1_found) ? write_addr : 3'bz;
   // assign read_addrB_d=(~drvalidB0_found && ~drvalidB1_found) ? write_addr : 3'bz;

    assign read_addr_d=excpt_fwd ? write_addr : read_addrU_d;
  //  assign read_addr_d=(except && except_thread) ? read_addrA_d : 3'bz;
  //  assign read_addr_d=(except && ~except_thread) ? read_addrB_d : 3'bz;
  endgenerate
  
//  adder_inc #(3) read_inc_mod(read_addr,read_addr_d,doStep &~rst);
  adder_inc #(3) write_inc_mod(write_addr,write_addr_d,wen&~rst,);
  adder_inc #(3) write_inc2_mod(write_addr,write_addr_inc,1'b1,);
  //adder_inc #(4) count_inc_mod(count,count_d,~doStep & wen & ~rst);
  //adder #(4) count_dec_mod(count,4'hf,count_d,1'b0,~wen & doStep & ~rst);
 
  bit_find_first_bit #(8) rdfirst0_mod(valid[0]&vMask,rdvalid0,drvalid0_found);
  bit_find_first_bit #(8) rdfirst1_mod(valid[0]&vMaskN,rdvalid1,drvalid1_found);
  bit_find_first_bit #(8) rdxfirst0_mod(valid[0]&vMask&~rdvalid0,rdxvalid0,drxvalid_0_found);
  bit_find_first_bit #(8) rdxfirst1_mod(valid[0]&vMaskN&~rdvalid1,rdxvalid1,drxvalid_1_found);
  
//  bit_find_first_bit #(8) rdfirstA0_mod((valid[0])&vMask,rdvalidA0,drvalidA0_found);
//  bit_find_first_bit #(8) rdfirstA1_mod((valid[0])&vMaskN,rdvalidA1,drvalidA1_found);
//  bit_find_first_bit #(8) rdfirstB0_mod((valid[1])&vMask,rdvalidB0,drvalidB0_found);
//  bit_find_first_bit #(8) rdfirstB1_mod((valid[1])&vMaskN,rdvalidB1,drvalidB1_found);

  popcnt10 cntMod({2'b0,valid[0]|valid[1]},count);
  popcnt10_or_more cntM_mod({2'b0,valid[0]|valid[1]},cmore);

  
  bit_find_first_bit #(3) findConfl_mod(curConfl,sel,conflFound);

  addrcalccam_ram ramA_mod(
  clk,
  rst,
  doStep,
  read_addr_d,
  read_dataA,
  init ? initCount : write_addr,
  write_dataA&{DATA_WIDTH{~init}},
  wen|init
  );

  adder_inc #(3) initAdd_mod(initCount,initCount_next,1'b1,);
  
  assign doStep=((curConfl==3'b001 || curConfl==3'b010 || curConfl==3'b100) 
    && read_clkEn && cmore[1]|wen && !rsStall)|excpt_fwd;
  assign excpt_fwd=except;// && ((rdvalid0 & valid[~except_thread])!=0 || ((rdvalid1 & valid[~except_thread])!=0 && ~drvalid0_found)!=0);

  always @(posedge clk)
    begin
          if (mOpR_en) $display("cc ",curConfl," ",mOpR_LSQ,":",read_mop[0][`mOp_LSQ]," ",valid[0]," "
              ,wen," ",read_addr," ",vMask,"\\",vMaskN);
          if (wen) $display(":::",write_mop_reg[0][`mOp_LSQ]," ",write_addr," ",conflict0);
	  if (rst) begin
	      valid[0]<=8'b0;
	      valid[1]<=8'b0;
	      vOn_next=1'b0;
	      vMask=8'b0;
	      vMaskN=8'b0;
	  end else if (!rsStall) begin
	      if (wen && ~doStep|cmore[1]) begin
	            valid[0][write_addr]<=1'b1;
		    if (vMask!=0&&write_addr==0) begin
		        vMaskN=8'b1;
			vOn_next=1'b1;
                        if (doStep) vMask[read_addr]=1'b0;
			if (doStep&&~drxvalid_0_found&&vMaskN!=0) begin
			    vMask=8'b1;
			    vOn_next=1'b0;
			    vMaskN=0;
			end
		    end else begin
		        if (vOn_next) vMaskN[write_addr]=1'b1;
		        else vMask[write_addr]=1'b1;
		        if (doStep) begin
                            vMask[read_addr]=1'b0;
		            if (~drxvalid_0_found && vMaskN!=0) begin
				vOn_next=1'b0;
				vMask=vMaskN;
				vMaskN=0;
			    end
			end
		    end
	      end else begin
	          if (doStep) begin
                      vMask[read_addr]=1'b0;
	              if (~drxvalid_0_found && vMaskN!=0) begin
	                  vOn_next=1'b0;
			  vMask=vMaskN;
			  vMaskN=0;
		     end
		  end
		  //usign    
	      end
              if (doStep) begin
	          valid[0][read_addr]<=1'b0;
	          valid[1][read_addr]<=1'b0;
	      end
	      if (except) begin
	          if (except_thread) valid[1]<=8'b0;
	          else valid[0]<=8'b0;
	      end
	  end
	  if (rst) confl_mask<=3'b111;
	  else if (doStep &~init || except)  begin
	      confl_mask<=3'b111;
	  end else if (~init && !rsStall) begin
	      if (cmore[1] && read_clkEn) confl_mask<=confl_mask&~sel;
	      else if (wen && count[0]) begin
	         if (read_clkEn) confl_mask<=~sel;
	         //else confl_mask<=4'b1111;
	      end 
	  end
	  if (rst) read_addr<=3'b0;
	  else if (doStep) read_addr<=read_addr_d;
	  if (!rsStall) write_addr<=write_addr_d;
	  if (rst) doSkip<=1'b0;
	  else if (cmore[STALL_COUNT-1]) doSkip<=1'b1;
	  else if (count[0]) doSkip<=1'b0;
          if (!rsStall) begin
	      write_mop_reg[0]<=write_mop[0];
	      write_mop_reg[1]<=write_mop[1];
	      write_mop_reg[2]<=write_mop[2];
          end
	  

	  if (rst) begin
	      init<=1'b1;
	      initCount<=3'b0;
	  end else if (init) begin
	      initCount<=initCount_next;
	      if (initCount==3'h7) init<=1'b0;
	  end
    end
  
endmodule



