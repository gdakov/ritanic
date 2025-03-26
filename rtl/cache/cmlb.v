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

module cmlb_ram(
  clk,
  rst,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );

  localparam DATA_WIDTH=`cmlb_width;
  localparam ADDR_WIDTH=8;
  localparam ADDR_COUNT=256;
  
  input pwire clk;
  input pwire rst;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  
  assign read_data=ram[read_addr];

  always @(posedge clk)
    begin
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule


module cmlb_way(
  clk,
  rst,
  read_clkEn,
  fStall,
  addr,
  tr_jump,
  sproc,
  read_data,
  read_lru,
  read_hit,
  write_data,
  write_wen,
  write_tr,
  invalidate,
  init,
  newLRU
  );

  parameter WAYNO=0;
  localparam DATA_WIDTH=`cmlb_width;
  localparam OUTDATA_WIDTH=`cmlbData_width;
  localparam IP_WIDTH=65;
  localparam ADDR_WIDTH=5;

  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire fStall;
  input pwire [IP_WIDTH-1:0] addr;
  input pwire tr_jump;
  input pwire [20:0] sproc;
  output pwire [OUTDATA_WIDTH-1:0] read_data;
  output pwire [2:0] read_lru;
  output pwire read_hit;
  input pwire [OUTDATA_WIDTH-1:0] write_data;
  input pwire write_wen;
  input pwire write_tr;
  input pwire invalidate;
  input pwire init;
  input pwire [2:0] newLRU;
  
  pwire valid;
  pwire [IP_WIDTH-1:0] ip;
  pwire write_wen_ram;
  pwire [DATA_WIDTH-1:0] read_data_ram;
  pwire [DATA_WIDTH-1:0] write_data_ram;
  pwire [DATA_WIDTH-1:0] write_data_new;
  pwire [DATA_WIDTH-1:0] write_data_same;
  pwire [DATA_WIDTH-1:0] write_data_init;

  pwire [OUTDATA_WIDTH-1:0] mlb_data;

  pwire validN;
  
  pwire [IP_WIDTH-1:0] addr_reg;

  pwire write_wen_reg;

  pwire write_tr_reg;

  pwire [OUTDATA_WIDTH-1:0] write_data_reg;
  
  pwire invalidate_reg;
  
  pwire read_clkEn_reg;
  
  pwire [1:0] read_lru_reg;

  assign ip=read_data_ram[`cmlb_ip];
  assign valid=read_data_ram[`cmlb_valid];
  assign validN=read_data_ram[`cmlb_validN];
  assign read_lru=read_data_ram[`cmlb_lru];
 //verilator lint_off WIDTH 
  assign read_hit=(valid&~tr_jump||validN&tr_jump) && ((ip|{14{~tr_jump}})==(addr|{14{~tr_jump}}) ||
    ((ip|{14{~tr_jump}})=={sproc,addr[43:0]|{14{~tr_jump}}} && mlb_data[`cmlbData_global])) && addr[43:40]!=4'b1110 && ~invalidate;
 //verilator lint_on WIDTH
  
  assign write_wen_ram=(write_wen && pwh#(3)::cmpEQ(read_lru,3'b111)) || read_clkEn&~fStall&~write_wen;
  
  assign mlb_data=read_data_ram[`cmlb_data];
  assign read_data=read_hit ? read_data_ram[`cmlb_data] : 'z;
  assign write_data_new[`cmlb_ip]=addr;
  assign write_data_new[`cmlb_valid]=~write_tr;
  assign write_data_new[`cmlb_validN]=write_tr;
  assign write_data_new[`cmlb_data]=write_data;
  assign write_data_new[`cmlb_lru]=3'b111;
  
  assign write_data_init[`cmlb_ip]=0;
  assign write_data_init[`cmlb_valid]=0;
  assign write_data_init[`cmlb_validN]=0;
  assign write_data_init[`cmlb_data]=0;
  assign write_data_init[`cmlb_lru]=WAYNO[2:0];

  assign write_data_same[`cmlb_ip]=ip;
  assign write_data_same[`cmlb_valid]=valid && ~(invalidate&read_hit);
  assign write_data_same[`cmlb_validN]=validN && ~(invalidate&read_hit);
  assign write_data_same[`cmlb_data]=read_data_ram[`cmlb_data];

  assign write_data_same[`cmlb_lru]=newLRU;
  
  
  assign write_data_ram=write_wen & ~init ? write_data_new : 'z;
  assign write_data_ram=~write_wen & ~init ? write_data_same : 'z;
  assign write_data_ram=init ? write_data_init : 'z;
  
  cmlb_ram ram_mod(
  .clk(clk),
  .rst(rst),
  .read_addr(tr_jump ? addr[11:4] : addr[21:14]),
  .read_data(read_data_ram),
  .write_addr(tr_jump ? addr[11:4] : addr[21:14]),
  .write_data(write_data_ram),
  .write_wen(write_wen_ram|init)
  );

  always @(posedge clk)
    begin
	  if (write_wen_ram && write_wen_reg) $display("TL_B ",tr_jump ? addr[9:4] : addr[18:13]," ",write_data_ram," ",write_data_new);
	  if (rst)
	    begin
		  write_wen_reg<=1'b0;
	//	  addr_reg<={ADDR_WIDTH{1'B0}};
		  write_data_reg<={OUTDATA_WIDTH{1'B0}};
		  invalidate_reg<=1'b0;
		  read_clkEn_reg<=1'b0;
		  write_tr_reg<=1'b0;
		  addr_reg<=0;
		  read_lru_reg<=0;
		end
	  else if (~fStall)
	    begin 
	//	  addr_reg<=addr;
		  write_wen_reg<=write_wen;
		  write_data_reg<=write_data;
		  invalidate_reg<=invalidate;
		  read_clkEn_reg<=read_clkEn;
		  write_tr_reg<=write_tr;
		  addr_reg<=addr;
		  read_lru_reg<=read_lru;
		end
    end
  
endmodule


module cmlb(
  clk,
  rst,
  read_clkEn,
  read_thread,
  fStall,
  addr,
  read_data,
  transl_jump,
  read_hit,
  write_data,
  write_wen,
  msrss_en,
  msrss_addr,
  msrss_data
  );

  localparam DATA_WIDTH=`cmlb_width;
  localparam OUTDATA_WIDTH=`cmlbData_width;
  localparam IP_WIDTH=65;
  localparam ADDR_WIDTH=5;

  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire read_thread;
  input pwire fStall;
  input pwire [IP_WIDTH-1:0] addr;
  output pwire [OUTDATA_WIDTH-1:0] read_data;
  input pwire transl_jump;
  output pwire read_hit;
  input pwire [OUTDATA_WIDTH-1:0] write_data;
  input pwire write_wen;
  input pwire msrss_en;
  input pwire [15:0] msrss_addr;
  input pwire [64:0] msrss_data;
  
  pwire [3:0][2:0] newLRU;
  pwire [3:0][2:0] oldLRU;
  pwire [2:0] LRU_hit;
  pwire [3:0] read_hit_way;
  pwire init_pending;
  pwire [5:0] init_count;
  pwire init_pending_reg;
  pwire [5:0] init_count_d;
  pwire [23:0] sproc;
  pwire [1:0][23:0] pproc;
  pwire [1:0][39:0] dummy_pproc;
  pwire [1:0][23:0] vmproc;
  pwire [1:0][39:0] dummy_vmproc;
  pwire [1:0][63:0] mflags;
  pwire  [OUTDATA_WIDTH-1:0] read_data_pmm;
  pwire [IP_WIDTH-1:0] addr_reg;
  
  pwire read_clkEn_reg;

  assign read_hit=(|read_hit_way || addr[43:40]==4'b1110) & ~init_pending;
  assign LRU_hit=read_hit ? 3'bz : 3'b00;
  assign read_data=(|read_hit_way) ? 'z : read_data_pmm;

  generate
    genvar k;
    for(k=0;k<8;k=k+1)
      begin : ways_gen
        cmlb_way #(k) way_mod(
        clk,
        rst,
        read_clkEn,
        fStall,
        init_pending ? {45'b0,init_count,14'b0} : addr,
	transl_jump,
	sproc[20:0],
        read_data,
        oldLRU[k],
        read_hit_way[k],
        write_data,
        write_wen,
	transl_jump&write_wen,
        1'B0,
        init_pending,
        newLRU[k]
        );
        
        lru_single #(3,k) lru_mod(oldLRU[k],newLRU[k],LRU_hit,init_pending,read_clkEn);
        
        assign LRU_hit=read_hit_way[k] ? oldLRU[k] : 3'bz;
        
      end
  endgenerate
  
  adder_inc #(6) initAdd_mod(init_count,init_count_d,1'b1,);
  msrss_watch #(`csr_page) csrSproc0_mod(
  clk,
  rst,
  msrss_addr,
  msrss_data,
  msrss_en,
  {pproc[1],dummy_pproc[1],pproc[0],dummy_pproc[0]});

  msrss_watch #(`csr_vmpage) csrSproc1_mod(
  clk,
  rst,
  msrss_addr,
  msrss_data,
  msrss_en,
  {vmproc[1],dummy_vmproc[1],vmproc[0],dummy_vmproc[0]});

  msrss_watch #(`csr_mflags) csrSproc2_mod(
  clk,
  rst,
  msrss_addr,
  msrss_data,
  msrss_en,
  mflags);

  assign sproc=mflags[read_thread][`mflags_vm] ? pproc[read_thread]^{24'd1} : 24'b0;



  
  always @(posedge clk)
    begin
   /*   if (rst)
        read_clkEn_reg<=1'b0;
      else if (~fStall)
        read_clkEn_reg<=read_clkEn;
     */ 
      if (rst)
        begin 
          init_pending<=1'b1;
          init_count<=0;
        end
      else if (init_pending)
        begin
          init_count<=init_count_d;
          if (pwh#(32)::cmpEQ(init_count,63))
            init_pending<=1'b0;
        end
        
     /* if (rst)
        init_pending_reg<=1'b0;
      else
        init_pending_reg<=init_pending;*/
    end
  
endmodule


