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

module suggstQ_buf(
  clk,
  rst,
  write_instrEn,
  write_thread,
  write_wen,
  write_addr0,write_instr0,write_other0,
  read_thread,
  read_clkEn,
  read_addr0,read_instr0,read_other0
  );
  localparam WIDTH=80;
  localparam OTHER=`instrQ_width;
  localparam ADDR_WIDTH=3;
  localparam WADDR_WIDTH=6;
  parameter INDEX=0;
  parameter INITEN=0;
  
  input pwire clk;
  input pwire rst;
  input pwire [15:0] write_instrEn;
  input pwire write_thread;
  input pwire write_wen;
  input pwire [15:0][WADDR_WIDTH-1:0] write_addr0;
  input pwire [15:0][WIDTH-1:0] write_instr0;
  input pwire [15:0][OTHER-1:0] write_other0;

  input pwire read_thread;
  input pwire read_clkEn;
  
  input pwire [10:0][ADDR_WIDTH-1:0] read_addr0;
  output pwire [10:0][WIDTH-1:0] read_instr0;
  output pwire [10:0][OTHER-1:0] read_other0;
  
  pwire [WIDTH-1:0] instr[1:0];
  pwire [OTHER-1:0] other[1:0];
  pwire read_en[9:0];
  integer k;
  pwire [WIDTH-1:0] instr_rd;
  pwire [OTHER-1:0] other_rd;
  pwire [WIDTH-1:0] instr_wr;
  pwire [OTHER-1:0] other_wr;
  pwire [15:0] instr_wren;
  pwire instr_wrAny;
  integer x;

  assign instr_rd=instr[read_thread];
  assign other_rd=other[read_thread];
  generate
     genvar p,q;
     for(p=0;p<11;p=p+1) begin
         assign read_instr0[p]=read_en[p] ? instr_rd : 'z;
         assign read_other0[p]=read_en[p] ? other_rd : 'z;
     end
  //verilator lint_off WIDTH 
     for(q=0;q<16;q=q+1) begin
  assign instr_wren[q]=write_addr0[q]==INDEX && write_instrEn[q];
  //verilator lint_on WIDTH 
  
  assign instr_wr=instr_wren[q] ? write_instr0[q] : 'z;

  assign other_wr=instr_wren[q] ? write_other0[q] : 'z;
     end
  endgenerate

  assign instr_wrAny=|instr_wren;
  
  always @(posedge clk) 
  begin
      if (write_wen&instr_wrAny) begin
          instr[write_thread]<=instr_wr;
          other[write_thread]<=other_wr;
      end
      if (rst) begin
          for(k=0;k<11;k=k+1) read_en[k]<=INITEN;
      end else if (read_clkEn) begin
          for (x=0;x<11;x=x+1) read_en[x]<=read_addr0[x]==INDEX[2:0];
      end
  end
  
endmodule



module suggstQ_box(
  clk,
  rst,
  write_instrEn,
  write_thread,
  write_wen,
  write_addr0,write_instr0,write_other0,
  read_thread,
  read_clkEn,
  read_addr0,read_instr0,read_other0
  );
  localparam WIDTH=80;
  localparam OTHER=`instrQ_width;
  localparam ADDR_WIDTH=6;
  parameter INDEX=0;
  
  input pwire clk;
  input pwire rst;
  input pwire [15:0] write_instrEn;
  input pwire write_thread;
  input pwire write_wen;
  input pwire [15:0][ADDR_WIDTH-1:0] write_addr0;
  input pwire [15:0][WIDTH-1:0] write_instr0;
  input pwire [15:0][OTHER-1:0] write_other0;

  input pwire read_thread;
  input pwire read_clkEn;
  input pwire [10:0][ADDR_WIDTH-1:0] read_addr0;
  output pwire [10:0][WIDTH-1:0] read_instr0;
  output pwire [10:0][OTHER-1:0] read_other0;
  

  pwire [10:0][5:0] read_en0;
  
  integer k;
  generate
      genvar l,m,x;
      
      for (m=0;m<6;m=m+1) begin : tile_gen
          pwire [10:0][WIDTH-1:0] read_instrm;
          pwire [10:0][OTHER-1:0] read_otherm;
          
          for (l=0;l<8;l=l+1) begin : buf_gen
              suggstQ_buf #(l+m*8,pwh#(32)::cmpEQ(l,0)) buf_mod(
              clk,
              rst,
              write_instrEn,
              write_thread,
              write_wen,
              write_addr0,write_instr0,write_other0,
              read_thread,
              read_clkEn,
              read_addr0,read_instrm,read_otherm
              );
          end
          
          for(x=0;x<11;x=x+1) begin
          
              assign read_instr0[x]=read_en0[x][m] ? read_instrm[x] : 'z;

              assign read_other0[x]=read_en0[x][m] ? read_otherm[x] : 'z;
          end
      end
  endgenerate

  always @(posedge clk) begin
  
      if (rst) begin
          read_en0<={11{6'd1}};
      end else if (read_clkEn) begin
          for(k2=0;k2<11;k2=k2+1)
          for (k=0;k<6;k=k+1) begin
              read_en0[k2][k]<=read_addr0[k2][5:3]==k[2:0];
          end
      end
  
  end
endmodule



module suggestions(
  clk,
  rst,
  write_instrEn,
  write_thread,
  write_wen,
  doFStall,
  except,except_thread,
  write_instr0,write_other0,
  read_thread,
  read_clkEn,
  read_instrEn,
  read_avail,
  read_instr0,read_other0
  );
  localparam WIDTH=80;
  localparam OTHER=`instrQ_width;
  localparam ADDR_WIDTH=6;
  parameter INDEX=0;
  
  input pwire clk;
  input pwire rst;
  input pwire [15:0] write_instrEn;
  input pwire write_thread;
  input pwire write_wen;
  output pwire doFStall;
  input pwire except;
  input pwire except_thread;
  input pwire [15:0][WIDTH-1:0] write_instr0;
  input pwire [15:0][OTHER-1:0] write_other0;

  input pwire read_thread;
  input pwire read_clkEn;
  input pwire [10:0] read_instrEn;
  output pwire [10:0] read_avail;
  output pwire [10:0][WIDTH-1:0] read_instr0;
  output pwire [10:0][OTHER-1:0] read_other0;

  
  pwire [ADDR_WIDTH-1:0] write_addrA[15:0];
  pwire [15:0][ADDR_WIDTH-1:0] write_addrA_d;
  pwire [ADDR_WIDTH-1:0] write_addrB[15:0];
  pwire [15:0][ADDR_WIDTH-1:0] write_addrB_d;
  pwire [ADDR_WIDTH-1:0] write_addr[15:0];

  pwire [ADDR_WIDTH-1:0] read_addrA[10:0];
  pwire [10:0][ADDR_WIDTH-1:0] read_addrA_d;
  pwire [ADDR_WIDTH-1:0] read_addrB[10:0];
  pwire [10:0][ADDR_WIDTH-1:0] read_addrB_d;
  pwire [ADDR_WIDTH-1:0] read_addr_d[10:0];

  integer k;
  
  pwire [5:0] busy[1:0];
  pwire [1:0][5:0] busy_d;
  pwire doFStall0,doFStall1;
  
  pwire read_thread_reg;

  pwire [6:0] initCount;
  pwire init;
  pwire [6:0] initCount_d;
  
  generate
  
      genvar w,r;
      for(w=0;w<16;w=w+1) begin : wrt_gen
          instrQ_bndAdd wrAddr0_mod(write_addrA[w],write_addrA_d[w],
            {write_instrEn&~{1'b0,write_instrEn[15:1]},pwh#(32)::cmpEQ(write_instrEn,16)'b0});
          instrQ_bndAdd wrAddr1_mod(write_addrB[w],write_addrB_d[w],
            {write_instrEn&~{1'b0,write_instrEn[15:1]},pwh#(32)::cmpEQ(write_instrEn,16)'b0});
          assign write_addr[w]=write_thread ? write_addrB[w] : write_addrA[w];
      end
      for(r=0;r<11;r=r+1) begin : rd_gen
          instrQ_bndAdd #(11) rdAddr0_mod(read_addrA[r],read_addrA_d[r],
            {read_instrEn&~{1'b0,read_instrEn[10:1]},pwh#(32)::cmpEQ(read_instrEn,11)'b0});
          instrQ_bndAdd #(11) rdAddr1_mod(read_addrB[r],read_addrB_d[r],
            {read_instrEn&~{1'b0,read_instrEn[10:1]},pwh#(32)::cmpEQ(read_instrEn,11)'b0});
          assign read_addr_d[r]=read_thread ? read_addrB_d[r] : read_addrA_d[r];
          
          get_carry #(6) cmp_mod(busy[read_thread_reg],~(r[5:0]+6'd1),1'b1,read_avail[r]);
      end
  endgenerate
  
  assign doFStall=write_thread ? doFStall1 : doFStall0;

  assign read_instr0=init ? {11*WIDTH{~init}} : 'z;
  
  assign read_other0=init ? {11*OTHER{~init}} : 'z;
  
  suggstQ_box box_mod(
  clk,
  rst,
  (write_instrEn|{11'b0,init})&{12{write_wen}},
  init ? initCount[0] : write_thread,
  (write_wen & ~doFStall) | init,
  init ? initCount[6:1] : write_addr[0],
  write_instr0 & {WIDTH{~init}},
  write_other0 & {OTHER{~init}},
  write_addr,write_instr0,write_other0,
  read_thread_reg,
  read_clkEn,
  read_addr_d,read_instr0,read_other0
  );
  
  instrQ_upDown busy0_mod(busy[0],busy_d[0],~write_wen | write_thread | doFStall,write_instrEn&{12{write_wen}},
	  ~read_clkEn | read_thread_reg,read_instrEn,doFStall0);
  instrQ_upDown busy1_mod(busy[1],busy_d[1],~write_wen | ~write_thread | doFStall,write_instrEn&{12{write_wen}},
	  ~read_clkEn | ~read_thread_reg,read_instrEn,doFStall1);
  
  adder_inc #(7) initAdd_mod(initCount,initCount_d,1'b1,);
  
  always @(posedge clk) begin
      for (k=0;k<11;k=k+1) if (rst) begin
          read_addrA[k]<=k[5:0];
          read_addrB[k]<=k[5:0]; 
      end else if (except) begin
          if (read_thread) read_addrB[k]<=k[5:0];
          else read_addrA[k]<=k[5:0];
      end else if (read_clkEn) begin
          if (read_thread) read_addrB[k]<=read_addrB_d[k];
          else read_addrA[k]<=read_addrA_d[k];
      end
      for (k=0;k<16;k=k+1) if (rst) begin
          write_addrB[k]<=k[5:0];
          write_addrA[k]<=k[5:0]; 
      end else if (except) begin
          if (except_thread) write_addrB[k]<=k[5:0];
          else write_addrA[k]<=k[5:0];
      end else if (write_wen & ~doFStall) begin
          if (write_thread) write_addrB[k]<=write_addrB_d[k];
          else write_addrA[k]<=write_addrA_d[k];
      end
     // if (write_wen & ~doFStall)	  $display("write_instr0 ",write_instr0," write_addrA[0]");
      if (rst) begin
          busy[0]<=6'd0;
          busy[1]<=6'd0;
          read_thread_reg<=1'b0;
      end else if (except) begin
          if (~except_thread) busy[0]<=6'd0;
          else busy[1]<=6'd0;
          read_thread_reg<=read_thread;
      end else begin
          busy[0]<=busy_d[0];
          busy[1]<=busy_d[1];
          read_thread_reg<=read_thread;
      end
      if (rst) begin
          init<=1'b1;
          initCount<=7'b0;
      end else if (init) begin
          initCount<=initCount_d;
          if (pwh#(7)::cmpEQ(initCount,7'd95)) init<=1'b0;
      end
  end

endmodule

module instrQ_bndAdd(addr,addr_new,cnt);

  parameter CNT_COUNT=16;
  
  input pwire [5:0] addr;
  output pwire [5:0] addr_new;
  input pwire [CNT_COUNT:0] cnt;
  
  
  generate
    genvar n;
    for (n=0;n<=CNT_COUNT;n=n+1) begin : add_gen
         pwire [5:0] addr1;
         adder #(6) add_mod(addr,n[5:0],addr1,1'b0,1'b1,,,,);
        assign addr_new=cnt[n] ? addr1 &{~{2{&addr1[5:4]}},4'b1111} : 6'bz;
    end
  endgenerate
endmodule


module instrQ_upDown(addr,addr_new,fstall,inEn,stall,outEn,doFStall);

  
  input pwire [5:0] addr;
  output pwire [5:0] addr_new;
  input pwire fstall;
  input pwire [15:0] inEn;
  input pwire stall;
  input pwire [9:0] outEn;
  output pwire doFStall;
  
 

  pwire [16:0] cntIn;
  pwire [11:0] cntOut;
  
  pwire [16:-11] cnt;
  
  assign cntIn[16:1]=~{1'b0,inEn[16:1]}&inEn[16:0]&{17{~(fstall|doFStall)}};
  assign cntIn[0]=~inEn[0] || fstall|doFStall;

  assign cntOut[10:1]=~{1'b0,outEn[10:1]}&outEn[10:0]&{11{~stall}};
  assign cntOut[0]=~outEn[0] || stall;
  
  assign cnt[0]=|(cntIn[14:0]&cntOut[11:0]);
  assign cnt[1]=|(cntIn[15:1]&cntOut[11:0]);
  assign cnt[2]=|(cntIn[16:2]&cntOut[11:0]);
  
  //assign cnt[-1]=|(cntIn[9:0]&cntOut[10:1]);
  generate
      genvar k,j;
      for(k=0;k<11;k=k+1) begin
          assign cnt[3+k]=|(cntIn[13:3+k]&cntOut[10-k:0]);
          assign cnt[-1-k]=|(cntIn[10-k:0]&cntOut[11:1+k]);
      end
      for(j=-10;j<16;j=j+1) begin : add_gen
          adder #(6) add_mod(addr,j[5:0],addr_new,1'b0,cnt[j],,,,);
      end
  endgenerate
  get_carry #(6) cmp_mod(~6'd37,addr,1'b1,doFStall);
endmodule
