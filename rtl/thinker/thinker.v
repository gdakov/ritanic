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

`define permreq_code 0
`define permreq_transl 1
`define permreq_width 2

module pager(
  clk,
  rst,
  except,
  bus_hold,
  req_bus,
  new_en,
  new_can,
  new_addr,
  new_attr,
  new_indir,
  new_inv,
  new_permReq,
  msrss_no,
  msrss_thread,
  msrss_en,
  msrss_data,
  mOp_register,
  mOp_LSQ,
  mOp_II,
  mOp_WQ,
  mOp_addrEven,
  mOp_addrOdd,
  mOp_sz,
  mOp_st,
  mOp_en,
//  mOp_thread,
  mOp_lsflag,
  mOp_banks,
  mOp_bank0,
  mOp_odd,
  mOp_addr_low,
  mOp_split,
  FUHit,FUreg,data_in,
  writeTlb_IP,
  writeTlb_low,
  writeTlb_wen,
  writeTlb_wen_c,
  writeTlb_wenH_c,
  writeTlb_data0,
  writeTlb_xdata0,
  writeTlb_data1,
  writeTlb_data2
  );

  parameter INDEX=0; //0 1 2 
  localparam ADDR_WIDTH=64;
  localparam PADDR_WIDTH=44;
  localparam OPERATION_WIDTH=`operation_width;
  localparam BANK_COUNT=32;
  localparam TLB_DATA_WIDTH=`dmlbData_width;
  localparam TLB_IP_WIDTH=52;
  localparam REG_WIDTH=`reg_addr_width;
  localparam PERM_WIDTH=`permreq_width;

  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire bus_hold;
  output pwire [2:0] req_bus;
  input pwire [2:0]new_en;
  output pwire reg[2:0] new_can;
  input[2:0] [47:0] new_addr;
  input[2:0] [3:0] new_attr;
  input[2:0] new_indir;
  input[2:0] new_inv;
  input[2:0] [PERM_WIDTH-1:0] new_permReq;
  input pwire [15:0] msrss_no;
  input pwire msrss_thread;
  input pwire msrss_en;
  input pwire [64:0] msrss_data;
  output pwire [REG_WIDTH-1:0] mOp_register;
  output pwire [8:0] mOp_LSQ;
  output pwire [9:0] mOp_II;
  output pwire [5:0] mOp_WQ;
  output pwire [PADDR_WIDTH-1:8] mOp_addrEven;
  output pwire [PADDR_WIDTH-1:8] mOp_addrOdd;
  output pwire [4:0] mOp_sz;
  output pwire mOp_st;
  output pwire mOp_en;
 // output pwire mOp_thread;
  output pwire mOp_lsflag;
  output pwire [BANK_COUNT-1:0] mOp_banks;
  output pwire [4:0] mOp_bank0;
  output pwire mOp_odd;
  output pwire [1:0] mOp_addr_low;
  output pwire mOp_split;
  input pwire FUHit;
  input pwire [REG_WIDTH-1:0] FUreg;
  input pwire [127:0] data_in;
  output[2:0] [TLB_IP_WIDTH-2:0] writeTlb_IP;
  output[2:0] writeTlb_low;
  output[2:0] writeTlb_wen;
  output[2:0] writeTlb_wen_c;
  output[2:0] writeTlb_wenH_c;
  output[2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data0;
  output[2:0] [19:0] writeTlb_xdata0;
  output[2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data1;
  output[2:0] [TLB_DATA_WIDTH-1:0] writeTlb_data2;

  //reg [1:0] pg;
  //reg [1:0] vm;
  //reg [1:0] codeInVm;
  pwire [64:0] mflags;
  pwire [64:0] PTR[1:0];
  pwire [64:0] VPTR[1:0];
  pwire [64:0] CPTR;
  pwire [64:0] CMSK;
  pwire [64:0] IPTR;
  pwire [64:0] IMSK;
  reg[2:0] [64:0] ptr;
  reg[2:0] [64:0] ptr2;
  reg[2:0] [64:0] ptrB;
  reg[2:0] do_ptr2;
  pwire [64:0] SPTR;
  pwire [20:0] sptr;
  reg[2:0] [11:0] stageA;
  reg[2:0] [7:0] stageB;
  reg[2:0] [7:0] stageB_pre;
  reg[2:0] stageA_running;
  reg[2:0] [47:0] addr;
  reg[2:0] [47:0] addrB;
  pwire thread;
  pwire rst_reg;
  integer p,q;
  pwire [31:0] banks;
  
  reg[2:0] [30:0] finalAddr0; 
  reg[2:0] [30:0] finalAddr1; 
  reg[2:0] [30:0] finalAddr2;
  reg[2:0] [12:0] finalXtra0; 
  reg[2:0] [12:0] finalXtra1; 
  reg[2:0] [12:0] finalXtra2;
  reg[2:0] finalSub0;
  reg[2:0] finalSub1;
  reg[2:0] finalSub2;
  reg[2:0] finalHug0;
  
  pwire[2:0] [47:0] addr_inc_d;
  reg[2:0] [47:0] addr_inc; 
  pwire[2:0] [47:0] addr_inc2_d;
  reg[2:0] [47:0] addr_inc2; 
  pwire[2:0] [4:0] addrE; 
  pwire[2:0] [4:0] addrO; 
  reg[2:0] [47:0] addr_orig; 
  reg[2:0] [47:0] addr_orig_inc; 
  pwire [REG_WIDTH-1:0] mOp_register_reg;
  pwire [REG_WIDTH-1:0] mOp_register_reg2;
  pwire [REG_WIDTH-1:0] mOp_register_reg3;
  reg[2:0] new_en_reg;
  reg[2:0] ready;
  reg[2:0] [PERM_WIDTH-1:0] permReq;
  pwire[2:0] all_shr;
  pwire [64:0] data_in_reg;
  reg[2:0] new_inv_reg;

  integer k;
  always @* begin
      all_shr[k]=1'b0;
      writeTlb_data0[k][`dmlbData_user]=finalXtra0[k][`page_user];  
      writeTlb_data0[k][`dmlbData_wp]=finalXtra0[k][`page_wr];  
      writeTlb_data0[k][`dmlbData_na]=finalXtra0[k][`page_na] && ~new_inv_reg;  
      writeTlb_data0[k][`dmlbData_ne]=finalXtra0[k][-14+`page_ne-14];  
      writeTlb_data0[k][`dmlbData_glo]=1'b0;  
      writeTlb_data0[k][`dmlbData_type]={finalXtra0[k][`page_nc],finalXtra0[k][`page_wt]};  
      writeTlb_data0[k][`dmlbData_subpage]=finalSub0[k];  
      writeTlb_data0[k][`dmlbData_phys]=finalAddr0[k];  
      writeTlb_xdata0[k]=finalXtra0[k];
  
      writeTlb_data1[k][`dmlbData_user]=finalXtra1[k][`page_user];  
      writeTlb_data1[k][`dmlbData_wp]=finalXtra1[k][`page_wr];  
      writeTlb_data1[k][`dmlbData_na]=finalXtra1[k][`page_na] && ~new_inv_reg;  
      writeTlb_data1[k][`dmlbData_ne]=finalXtra1[k][-14+`page_ne-14];  
      writeTlb_data1[k][`dmlbData_glo]=1'b0;  
      writeTlb_data1[k][`dmlbData_type]={finalXtra1[k][`page_nc],finalXtra1[k][`page_wt]};  
      writeTlb_data1[k][`dmlbData_subpage]=finalSub1[k];  
      writeTlb_data1[k][`dmlbData_phys]=finalAddr1[k];  
 
      writeTlb_data2[k][`dmlbData_user]=finalXtra2[k][`page_user];  
      writeTlb_data2[k][`dmlbData_wp]=finalXtra2[k][`page_wr];  
      writeTlb_data2[k][`dmlbData_na]=finalXtra2[k][`page_na] && ~new_inv_reg;  
      writeTlb_data2[k][`dmlbData_ne]=finalXtra2[k][-14+`page_ne-14];  
      writeTlb_data2[k][`dmlbData_acc]=finalXtra2[k][`page_accessed];  
      writeTlb_data2[k][`dmlbData_wrt]=finalXtra2[k][`page_dirty];  
      writeTlb_data2[k][`dmlbData_glo]=1'b0;  
      writeTlb_data2[k][`dmlbData_type]={finalXtra2[k][`page_nc],finalXtra2[k][`page_wt]};  
      writeTlb_data2[k][`dmlbData_subpage]=finalSub2[k];  
      writeTlb_data2[k][`dmlbData_phys]=finalAddr2[k];  

      writeTlb_wen[k]=ready[k] & (permReq[k]==0);
      writeTlb_wen_c[k]=ready[k] & ~finalHug0[k] & permReq[k][`permreq_code];
      writeTlb_wenH_c[k]=ready[k] & finalHug0[k] & permReq[k][`permreq_code];
 
      writeTlb_IP[k][TLB_IP_WIDTH-2:TLB_IP_WIDTH-22]=all_shr[k] ? SPTR[60:40] :
    PTR[1][60:40];
      writeTlb_IP[k][TLB_IP_WIDTH-23:0]=addr_orig[k][43:14];
      writeTlb_low[k]=addr_orig[k][13];
  end
  assign req_bus[0]=(stageA[0]|{4'b0,stageB[0]})!=0 && ~stageA_running[0] && ~|dly[0] && ~bus_hold;
  assign req_bus[1]=(stageA[1]|{4'b0,stageB[1]})!=0 && ~stageA_running[1] && ~|dly[1] && ~bus_hold && ~req_bus[0];
  assign req_bus[2]=(stageA[2]|{4'b0,stageB[2]})!=0 && ~stageA_running[2] && ~|dly[2] && ~bus_hold && ~|req_bus[1:0];
  
  assign mOp_register=|req_bus ? 9'h1fc+{7'b0,req_bus[2],req_bus[1]} : 9'bz;
  assign mOp_LSQ=|req_bus ? 9'h07 : 9'bz; 
  assign mOp_II=|req_bus ? 10'h0 : 10'bz; 
  assign mOp_WQ=|req_bus ? 6'h0 : 6'bz; 
  assign mOp_addrEven=|req_bus ? 
    {ptr[{req_bus[2],req_bus[1]}][43:13],addrE[{req_bus[2],req_bus[1]}]} : 36'bz;
  assign mOp_addrOdd= |req_bus ? 
    {ptr[{req_bus[2],req_bus[1]}][43:13],addrO[{req_bus[2],req_bus[1]}]} : 36'bz;

  assign mOp_sz= |req_bus ? 
    (stageA[{req_bus[2],req_bus[1]}][3] ? 5'h0 : 5'h13) : 5'bz;
  assign mOp_en= |req_bus ? 
    1'b1 : 1'bz;
  assign mOp_lsflag= |req_bus ? 
    1'b1 : 1'bz;
  assign mOp_banks= |req_bus ? 
      banks[{req_bus[2],req_bus[1]}] : 32'bz;
  assign mOp_bank0= |req_bus ? 
    {addr[{req_bus[2],req_bus[1]}][36:33],1'b0} : 5'bz;
  assign mOp_odd= |req_bus ? 
    addr[{req_bus[2],req_bus[1]}][37] : 1'bz;
  assign mOp_addr_low= |req_bus ? 
    2'b0 : 2'bz;
  assign mOp_split= |req_bus ? 
    1'b0 : 1'bz;

  generate
    genvar t;
    for(t=0;t<3;t=t+1) begin : adders_gen
        adder_inc #(34) addrB_mod(new_addr[t][47:14],addr_inc_d[t][47:14],1'b1,);
        adder_inc #(25) addrBH_mod(new_addr[t][47:23],addr_inc2_d[t][47:23],1'b1,);

        assign addr_inc_d[t][13:0]=addr[t][13:0];
        assign addr_inc2_d[t][22:0]=addr[t][22:0];

        assign addrE[t]=addr[t][42:38];
        assign addrO[t]=addr[t][42:38];
    end
  endgenerate

  pwire [2:0][pdc_width-1:0] read_data_pdbr;

  pdc_ram ram_mod(
  clk,
  rst_reg,
  {new_addr[2][35:25],new_addr[1][35:25],new_addr[0][35:25]},
  new_en&new_can,
  read_data_pdbr,
  ptr[FUreg[1:0]][24:14],//write_addr
  {ptr[FUreg[1:0]][43:25],1'b1,data_in[56:25]},//fixme: some bits are redundant as not used by bus; but meight be needed in later implementation
  stageA[y][1] && |data_in[`page_na] && FUHit && &FUreg[8:2]//write_wen
  );

  integer l,y;
  always @(banks,addr,stageA) begin
    for(l=0;l<3;l=l+1) begin
        for(p=0;p<32;p=p+1) begin
            q=p-2;
            banks[l][p]=addr[l][36:33]==p[4:1] ||
            stageA[l][2] & (addr[l][36:34]==q[4:2]);
        end
    end
  end
  always @(posedge clk) begin
    for(y=0;y<3;y=y+1) begin
      if (writeTlb_wen[y]) begin
          $display("mlb ip 0x%x",writeTlb_IP," ",new_inv_reg[y],y);
          $display("data 0: 0x%x",writeTlb_data0[y],y);
          $display("data 1: 0x%x",writeTlb_data1[y],y);
          $display("data 2: 0x%x",writeTlb_data2[y],y);
      end
      if (rst) begin
       //   new_can[y]<=1'b1;
          ptr[y]<=64'b0;
          ptr2[y]<=64'b0;
          ptrB[y]<=64'b0;
          addr[y]<=48'b0;
          addr_inc[y]<=48'b0;
//          addr_inc2[y]<=48'b0;
          addr_orig[y]<=48'b0;
          addrB[y]<=48'b0;
          do_ptr2[y]<=1'b0;
          stageA[y]<=12'b0;
          stageB[y]<=8'b0;
          stageA_running[y]<=1'b0;
          stageB_pre[y]<=8'b0;
          //thread[y]<=1'b0;
          sptr[y]<=21'b0;
          finalAddr0[y]<=31'b0;
          finalXtra0[y]<=13'b0;
          finalAddr1[y]<=31'b0;
          finalXtra1[y]<=13'b0;
          finalAddr2[y]<=31'b0;
          finalXtra2[y]<=13'b0;
          finalHug0[y]<=1'b0;
          finalSub0[y]<=1'b0;
          finalSub1[y]<=1'b0;
          finalSub2[y]<=1'b0;
          permReq[y]<=1'b0;
          data_in_reg[y]<=64'b0;
          new_inv_reg[y]<=1'b0;
      end else if (new_en&new_can) begin
         // new_can[y]<=1'b0;
	  $display("<new>");
          if (new_permReq[y][`permreq_code]) begin
              if (new_attr[y][`attr_vm]) ptr[y]<={12'b0,VPTR[new_addr[43]][38:0],13'b0};
              else ptr[y]<={12'b0,PTR[new_addr[43]][38:0],13'b0};
          end else begin
              ptr[y]<= new_attr[y][`attr_vm]? {12'b0,VPTR[new_addr[43]][38:0],13'b0} : 
		      {12'b0,PTR[new_addr[43]][38:0],13'b0};
          end
	  //up to horo
          new_inv_reg[y]<=new_inv;
          if (mflags[`mflags_pg] && ~new_inv) begin
              stageA[y]<=12'b1;
          end else begin
              finalAddr0[y]<={new_addr[y][43:14],1'b0};
              finalAddr1[y]<={new_addr[y][43:14],1'b1};
              finalAddr2[y]<={addr_inc_d[y][43:14],1'b0};
              finalHug0[y]<=1'b0;
              finalSub0[y]<=1'b0;
              finalSub1[y]<=1'b0;
              finalSub2[y]<=1'b0;
	      if (&new_addr[y][43:40]) begin
                  finalXtra0[y]<=13'b0000101110101;
                  finalXtra1[y]<=13'b0000101110101;
                  finalXtra2[y]<=13'b0000101110101;
	      end else begin
                  finalXtra0[y]<=13'b0000101100101;
                  finalXtra1[y]<=13'b0000101100101;
                  finalXtra2[y]<=13'b0000101100101;
              end
          end
          stageA_running[y]<=1'b0;
          sptr[y]<=SPTR[60:40];
          //thread[y]<=new_thread;
          addr[y]<=new_addr[y];
          addr_inc[y]<=addr_inc_d[y];
          addr_orig[y]<=new_addr[y];
          permReq[y]<=new_permReq[y];
          ptrB[y]<=ptr[y];
          dly[y]<=3'b1;
      end else if (req_bus[y]) begin
          stageA_running[y]<=1'b1;
         // $display("bump");
      end else begin
          dly[y]<=dly[y]<<1;
          //if (FUHit)  $display("bmup ",FUreg," ",data_in);
          if (pwh#(3)::cmpEQ(dly[y],3'b100)) begin
              if (read_data_pdbr[y][`pdc_valid] && read_data_pdbr[y][`pdc_vaddr]==ptr[y][43:25]) begin
                 ptr[y]<={2'b0,read_data_pdbr[y][`pdc_addr],14'b0};
                 addr[y]<=addr[y]<<22;
                 addr_inc[y]<=addr_inc[y]<<22;
                 if (addr[y][42:33]!=addr_inc[y][42:33]) begin 
                      stageB_pre[y]<=stageA[y][7:0]<<1;
                      ptrB[y][47:0]<={read_data_pdbr[y][`pdc_addr],25'b0};
                      addrB[y]<=addr_inc[y];
                 end
                 stageA[y]<=stageA[y]<<2;
              end
          end
          if (FUreg==(9'h1fc+y) && stageA_running[y] && FUHit) begin
              if ((stageA[y][1:0]!=0 || stageA[y][2]&premReq[y][`permreq_transl]) && ~data_in[`page_huge]) begin
                  addr[y]<={addr[y][37:0],11'b0};
                  addr_inc[y]<={addr_inc[y][37:0],11'b0};
                  ptr[y][47:0]<={data_in[y][47:14],9'b0,stageA[y][2]&premReq[y][`permreq_transl],4'b0};
                  stageA_running[y]<=1'b0;
                  stageA[y]<={stageA[y][10:0],1'b0};
                  if (addr[y][42:33]!=addr_inc[y][42:33] && ~(stageA[y][2]&premReq[y][`permreq_transl])) begin 
                      stageB_pre[y]<=stageA[y][7:0];
                      ptrB[y][47:0]<={data_in[47:14],14'b0};
                      addrB[y]<=addr_inc[y];
                  end
                  finalAddr0[y]<=data_in[43:14];
                  finalXtra0[y]<={data_in[63:58],data_in[13:0]};
                  $display("burp");
              end else if (stageA[y][3]) begin
                  for(callin=0;callin<6;callin=callin+1) begin
                      if (data_in[96+4*callin+:4]==addr_orig[3:0] && |data_in[15+16*callin-:1]) begin
                          finalAddr0<={finalAddr0[43:28],data_in[16*callin+1+:15]};
                          finalXtra0<={1'b0,|finalXtra0[`page_na],finalXtra0[`page_sys],finalXtra0[-14+`page_ne-14],data_in[122+callin],data_in[16*callin],finalAddr0[27:14]};
                      end
                  end
              end else if (stageA[y][2] | data_in[`page_huge] && stageA[y][2:1]!=0) begin
                 // ready[y]<=1'b1;
                  finalAddr0[y]<=data_in[43:14];
                  finalXtra0[y]<={data_in[63:58],data_in[13:0]};
                  //finalHug0[y]<=~stageA[2];
                  finalSub0[y]<=stageA[y][1];
                  finalAddr1[y]<=data_in[43+64:13+64];
                  finalXtra1[y]<={data_in[64+64:58+64],data_in[13+64:64]};
                  stageB[y]<={stageB_pre[y][6:0],1'b0};
                  addr[y]<={addrB[y][37:0],10'b0};
                  stageA_running[y]<=1'b0;
                  stageA[y]<=12'b0;
                  ptr[47:0][y]<=ptrB[y][47:0];
	          if (stageA[y][1]) begin
	              addr[y][32:24]<=addr_orig[y][32:24];
		      finalAddr0[y][19:9][y]<=addr_orig[y][32:24];
		      finalAddr1[y][19:9]<=addr_orig[y][32:24];
	          end
                    //  new_can[y]<=1'b1;
              end else if (stageB[y][1:0]!=0 && ~data_in[`page_huge]) begin
                  addr[y]<={addr[y][36:0],11'b0};
                  addr_inc[y]<={addr_inc[y][36:0],11'b0};
                  ptr[47:0][y]<={4'b0,data_in[43:14],14'b0};
                  stageA_running[y]<=1'b0;
                  stageB[y]<={stageB[y][6:0],1'b0};
              end else if (stageB[y][2] | data_in[`page_huge] && stageB[y][2:1]!=0) begin
                  stageB[y]<=8'b0;
                  finalAddr2[y]<=data_in[43:14];
                  finalXtra2[y]<={data_in[63:58],data_in[13:0]};
                  finalSub2[y]<=stageB[y][1];
	          if (stageB[y][1]) begin
	              addr[y][32:23]<=addr_orig[y][32:23];
		      finalAddr2[y][19:10]<=addr_orig_inc[y][32:23];
	          end
                     // new_can[y]<=1'b1;
	      end else if (stageB[y]!=0 && ~|data_in[`page_na]) begin
                  stageB[y]<=8'b0;
                  finalAddr2[y]<=31'b0;
                  finalXtra2[y]<=13'b0;
                  finalSub2[y]<=stageB[1];
              end else begin
                  finalXtra2[y]<=13'b0;
                  finalXtra1[y]<=13'b0;
                  finalXtra0[y]<=13'b0;
                  stageA[y]<=12'b0;
                  stageB[y]<=8'b0;
              end
          end
      end
      if (rst) new_can[y]<=1'b1;
      else if (new_en[y]&new_can[y]) new_can[y]<=1'b0;
      else if ((stageA[y]==0 && stageB[y]==0)||~mflags[`mflags_pg]) new_can[y]<=1'b1;
      if (rst) ready[y]<=1'b0;
      else if (stageA[y]==0 && stageB[y]==0 && ~new_can[y]) ready[y]<=1'b1;
      else ready[y]<=1'b0;
      if (rst) begin
        //  new_en_reg[y]<=1'b0;
          addr_inc[y]<=48'b0;
          addr_inc2[y]<=48'b0;
	  addr_orig_inc[y]<=48'b0;
      end else begin
        //  new_en_reg[y]<=new_en;
          if (new_en[y] & new_can[y]) addr_inc[y]<=addr_inc_d[y];
          if (new_en[y] & new_can[y]) addr_orig_inc[y]<=addr_inc_d[y];
          if (new_en[y] & new_can[y]) addr_inc2[y]<=addr_inc2_d[y];
      end
  end
      if (rst) begin
          PTR[0]<=0;
          VPTR[0]<=0;
          PTR[1]<=0;
          VPTR[1]<=0;
          SPTR<=0;
	  mflags<=64'b0;
          rst_reg<=1'b1;
      end else if (msrss_en) begin
          rst_reg<=1'b0;
          if (pwh#(32)::cmpEQ(msrss_no,`csr_page)) begin PTR[1]<=msrss_data; mflags[`mflags_pg]<=1'b1; rst_reg<=1'b1;
              $display("pg ",msrss_data); end
          if (pwh#(32)::cmpEQ(msrss_no,`csr_vmpage)) begin 
              VPTR[1]<=msrss_data;
              rst_reg<=1'b1;
          end
          if (pwh#(32)::cmpEQ(msrss_no,`csr_page0)) begin PTR[0]<=msrss_data; mflags[`mflags_pg]<=1'b1; 
              $display("pg1 ",msrss_data); rst_reg<=1'b1; end
          if (pwh#(32)::cmpEQ(msrss_no,`csr_vmpage0)) begin 
              VPTR[0]<=msrss_data;
              rst_reg<=1'b1;
          end
      end else begin
          rst_reg<=1'b0;
      end
      
  end
endmodule
