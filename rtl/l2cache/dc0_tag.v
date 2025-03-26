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


//dcache1_tag_ram read during write behaviour: write first
module dcache2_tag_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write_addr,
  write_data,
  write_wen
  );
  localparam ADDR_WIDTH=8;
  localparam DATA_WIDTH=`dc2Tag_width;
  localparam ADDR_COUNT=256;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module dc2_thag_ram(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_data,
  write0_addr,
  write0_data,
  write0_wen,
  write0_bitEn,
  write1_addr,
  write1_data,
  write1_wen,
  write1_bitEn,
  write2_addr,
  write2_data,
  write2_wen,
  write2_bitEn
  );
  localparam ADDR_WIDTH=4;
  localparam DATA_WIDTH=16;
  localparam ADDR_COUNT=16;
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [ADDR_WIDTH-1:0] read_addr;
  output pwire [DATA_WIDTH-1:0] read_data;
  input pwire [ADDR_WIDTH-1:0] write0_addr;
  input pwire [DATA_WIDTH-1:0] write0_data;
  input pwire                  write0_wen;
  input pwire [15:0]           write0_bitEn;
  input pwire [ADDR_WIDTH-1:0] write1_addr;
  input pwire [DATA_WIDTH-1:0] write1_data;
  input pwire                  write1_wen;
  input pwire [15:0]           write1_bitEn;
  input pwire [ADDR_WIDTH-1:0] write2_addr;
  input pwire [DATA_WIDTH-1:0] write2_data;
  input pwire                  write2_wen;
  input pwire [15:0]           write2_bitEn;
  
  reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  reg [ADDR_WIDTH-1:0] read_addr_reg;
  integer b;
  
  assign read_data=ram[read_addr_reg];

  always @(posedge clk)
    begin
      if (rst) read_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (read_clkEn) read_addr_reg<=read_addr;
      if (write0_wen) for(b=0;b<16;b=b+1) if (write0_bitEn[b]) ram[write0_addr][b]<=write0_data[b];
      if (write1_wen) for(b=0;b<16;b=b+1) if (write1_bitEn[b]) ram[write1_addr][b]<=write1_data[b];
      if (write2_wen) for(b=0;b<16;b=b+1) if (write2_bitEn[b]) ram[write2_addr][b]<=write2_data[b];
    end

endmodule

module dcache2_tag(
  clk,
  rst,
  req_en,
  req_wrtEn,
  req_addrE,
  req_addrO,
  req_odd,
  req_waddrE,
  req_waddrO,
  req_wodd,
  req_split,
  req_hitE,req_hitO,
  req_shitE,req_shitO,
  req_exclE,req_exclO,
  req_dir_ins_E,req_dir_ins_O,
  req_hitEL,req_hitOL,
  req_hitEH,req_hitOH,
  req_LRUe,req_LRUo,
  write_wen,
  write_dupl,
  write_hit,
  write_exp,
  write_excl,write_dir_ins,
  expun_addrE,expun_addrO,
  init,
  initCount
  );
  localparam PADDR_WIDTH=44;
  parameter [0:0] DEP=0;
  input pwire clk;
  input pwire rst;
  input pwire req_en;
  input pwire req_wrtEn;
  input pwire [PADDR_WIDTH-9:0] req_addrE;
  input pwire [PADDR_WIDTH-9:0] req_addrO;
  input pwire req_odd;
  input pwire [PADDR_WIDTH-9:0] req_waddrE;
  input pwire [PADDR_WIDTH-9:0] req_waddrO;
  input pwire req_wodd;
  input pwire req_split;
  inout pwire req_hitE,req_hitO;
  output pwire req_shitE,req_shitO;
  output pwire req_exclE,req_exclO;
  output pwire req_dir_ins_E,req_dir_ins_O;
  output pwire reg req_hitEL;
  output pwire reg req_hitOL;
  output pwire reg req_hitEH;
  output pwire reg req_hitOH;
  input pwire [4:0] req_LRUe;
  input pwire [4:0] req_LRUo;
  input pwire write_wen;
  input pwire write_dupl;
  output pwire write_hit;
  input pwire write_exp;
  input pwire write_excl;
  input pwire write_dir_ins;
  output pwire [35:0] expun_addrE;
  output pwire [35:0] expun_addrO;
  input pwire init;
  input pwire [7:0] initCount;

  pwire hitE,hitO;
  pwire write_hitE,write_hitO;
  reg [PADDR_WIDTH-9:0] req_addrE_reg;
  reg [PADDR_WIDTH-9:0] req_addrO_reg;
  reg req_odd_reg,req_split_reg;
  reg [PADDR_WIDTH-9:0] req_waddrE_reg;
  reg [PADDR_WIDTH-9:0] req_waddrO_reg;
  reg req_wodd_reg,req_wsplit_reg;
  reg write_wen_reg,req_wrtEn_reg;
  reg write_excl_reg,write_dir_ins_reg;
  pwire [`dc2Tag_width-1:0] tag_dataE;
  pwire [`dc2Tag_width-1:0] tag_dataO;
  pwire [`dc2Tag_width-1:0] tag_wDataE;
  pwire [`dc2Tag_width-1:0] tag_wDataO;
  reg req_en_reg;
  reg write_dupl_reg,write_exp_req;
  
  dcache2_tag_ram ramE_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(req_en),
  .read_addr(req_addrE[7:0]),
  .read_data(tag_dataE),
  .write_addr(init ? initCount : req_waddrE_reg[7:0]),
  .write_data(tag_wDataE & {`dc2Tag_width{~init}}),
  .write_wen(write_wen_reg & write_hit & ~req_wodd_reg || req_en_reg & ~req_odd_reg || init)
  );

  dcache2_tag_ram ramO_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(req_en),
  .read_addr(req_addrO[7:0]),
  .read_data(tag_dataO),
  .write_addr(init ? initCount : req_waddrO_reg[7:0]),
  .write_data(tag_wDataO & {`dc2Tag_width{~init}}),
  .write_wen(write_wen_reg & write_hit & req_wodd_reg || req_en_reg & req_odd_reg || init)
  );

  pwire [5:0] POOG;

  LFSR16_6 #(16'hf0fe) p_mod(clk,rst,POOG);

  assign hitE=req_addrE_reg[PADDR_WIDTH-9:8]==tag_dataE[`dc2Tag_addr_43_16] &&
    tag_dataE[`dc2Tag_valid] && req_en_reg;
  assign hitO=req_addrO_reg[PADDR_WIDTH-9:8]==tag_dataO[`dc2Tag_addr_43_16] &&
    tag_dataO[`dc2Tag_valid] && req_en_reg;

  generate 
    if (!DEP) begin
        assign req_hitE=hitE && ~req_odd_reg | req_split_reg;
        assign req_hitO=hitO && req_odd_reg | req_split_reg;
    end
        assign req_shitE=hitE && ~req_odd_reg | req_split_reg;
        assign req_shitO=hitO && req_odd_reg | req_split_reg;
  endgenerate

  assign write_hit=write_dupl_reg|write_exp_req ? req_hitE|req_hitO : write_wen_reg && 
	  (req_wodd_reg ? req_LRUo==POOG[4:0] : req_LRUe==POOG[4:0]);
  assign write_hitE=write_dupl_reg|write_exp_req ? req_hitE : write_wen_reg && req_LRUo==5'd23 && ~req_odd_reg;
  assign write_hitO=write_dupl_reg|write_exp_req ? req_hitO : write_wen_reg && req_LRUe==5'd23 && req_odd_reg;
  
  assign req_exclE=tag_dataE[`dc2Tag_exclusive];
  assign req_exclO=tag_dataO[`dc2Tag_exclusive];
  assign req_dir_ins_E=tag_dataE[`dc2Tag_ins_dirty];
  assign req_dir_ins_O=tag_dataO[`dc2Tag_ins_dirty];
 
  assign expun_addrE={tag_dataE[`dc2Tag_addr_43_16],req_addrE_reg[7:0]};
  assign expun_addrO={tag_dataO[`dc2Tag_addr_43_16],req_addrO_reg[7:0]};
  
  assign tag_wDataE[`dc2Tag_addr_43_16]=(~write_wen_reg || ~write_hitE) ? tag_dataE[`dc2Tag_addr_43_16] : req_waddrE_reg[PADDR_WIDTH-9:8]; 
  assign tag_wDataO[`dc2Tag_addr_43_16]=(~write_wen_reg || ~write_hitO) ? tag_dataO[`dc2Tag_addr_43_16] : req_waddrO_reg[PADDR_WIDTH-9:8];
  assign tag_wDataE[`dc2Tag_valid]=(write_wen_reg & write_hitE) ? ~write_exp_req : tag_dataE[`dc2Tag_valid]; 
  assign tag_wDataO[`dc2Tag_valid]=(write_wen_reg & write_hitO) ? ~write_exp_req : tag_dataO[`dc2Tag_valid]; 
  assign tag_wDataE[`dc2Tag_exclusive]=(write_wen_reg & write_hitE) ? write_excl_reg  : tag_dataE[`dc2Tag_exclusive]; 
  assign tag_wDataO[`dc2Tag_exclusive]=(write_wen_reg & write_hitO) ? write_excl_reg  : tag_dataO[`dc2Tag_exclusive]; 
  assign tag_wDataE[`dc2Tag_ins_dirty]=(write_wen_reg & write_hitE) ? write_dir_ins_reg  : 
    tag_dataE[`dc2Tag_ins_dirty] || req_hitE & req_wrtEn_reg; 
  assign tag_wDataO[`dc2Tag_ins_dirty]=(write_wen_reg & write_hitO) ? write_dir_ins_reg  : 
    tag_dataO[`dc2Tag_ins_dirty] || req_hitO & req_wrtEn_reg; 

  
  always @* begin
      req_hitOH=req_odd_reg && hitO;
      req_hitEH=~req_odd_reg && hitE;
      req_hitOL=req_split_reg ? req_hitEH : req_hitOH;
      req_hitEL=req_split_reg ? req_hitOH : req_hitEH;
  end

  always @(posedge clk) begin
      if (rst) begin
          req_addrE_reg<=36'b0;
          req_addrO_reg<=36'b0;
          req_odd_reg<=1'b0;
          req_waddrE_reg<=36'b0;
          req_waddrO_reg<=36'b0;
          req_wodd_reg<=1'b0;
          req_split_reg<=1'b0;
          write_wen_reg<=1'b0;
          write_excl_reg<=1'b0;
          write_dir_ins_reg<=1'b0;
          req_wrtEn_reg<=1'b0;
          req_en_reg<=1'b0;
          write_dupl_reg<=1'b0;
	  write_exp_req<=1'b0;
      end else begin
          req_addrE_reg<=req_addrE;
          req_addrO_reg<=req_addrO;
          req_odd_reg<=req_odd;
          req_waddrE_reg<=req_waddrE;
          req_waddrO_reg<=req_waddrO;
          req_wodd_reg<=req_wodd;
          req_split_reg<=req_split;
          write_wen_reg<=write_wen;
          write_excl_reg<=write_excl;
          write_dir_ins_reg<=write_dir_ins;
          req_wrtEn_reg<=req_wrtEn;
          req_en_reg<=req_en;
          write_dupl_reg<=write_dupl;
	  write_exp_req<=write_exp;
      end
  end
endmodule

