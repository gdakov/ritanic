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

module cc_ram0(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  write_addr,
  write_data,
  write_wen,
  write_ben
  );

  localparam DATA_WIDTH=36;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;

  input pwire clk;
  input pwire rst;
  input pwire readA_clkEn;
  input pwire [ADDR_WIDTH-1:0] readA_addr;
  output pwire [DATA_WIDTH-1:0] readA_data;
  input pwire readB_clkEn;
  input pwire [ADDR_WIDTH-1:0] readB_addr;
  output pwire [DATA_WIDTH-1:0] readB_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;
  input pwire [3:0] write_ben;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] readA_addr_reg;
  pwire [ADDR_WIDTH-1:0] readB_addr_reg;
  
  assign readA_data=ram[readA_addr_reg];
  assign readB_data=ram[readB_addr_reg];

  always @(negedge clk)
    begin
      if (rst) readA_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (readA_clkEn) readA_addr_reg<=readA_addr;
      if (rst) readB_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (readB_clkEn) readB_addr_reg<=readB_addr;
      if (write_wen) ram[write_addr]<=write_data;
      if (write_wen & write_ben[0]) ram[write_addr][8:0]<=write_data[8:0]; (* keep *)  else ram[write_addr][8:0]<=ram[write_addr][8:0];
      if (write_wen & write_ben[1]) ram[write_addr][17:9]<=write_data[17:9]; (* keep *) else ram[write_addr][17:9]<=ram[write_addr][17:9];
      if (write_wen & write_ben[2]) ram[write_addr][26:18]<=write_data[26:18]; (* keep *) else ram[write_addr][26:18]<=ram[write_addr][26:18];
      if (write_wen & write_ben[3]) ram[write_addr][35:27]<=write_data[35:27]; (* keep *) else ram[write_addr][35:27]<=ram[write_addr][35:27];
    end

endmodule

module cc_ram(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  write_addrE,
  write_addrO,
  write_data,
  write_wen,
  write_ben
  );

  localparam DATA_WIDTH=36;
  localparam ADDR_WIDTH=6;
  localparam ADDR_COUNT=64;

  input pwire clk;
  input pwire rst;
  input pwire readA_clkEn;
  input pwire [ADDR_WIDTH-1:0] readA_addr;
  output pwire [DATA_WIDTH-1:0] readA_data;
  input pwire readB_clkEn;
  input pwire [ADDR_WIDTH-1:0] readB_addr;
  output pwire [DATA_WIDTH-1:0] readB_data;
  input pwire [ADDR_WIDTH-1:0] write_addrE;
  input pwire [ADDR_WIDTH-1:0] write_addrO;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire [1:0] write_wen;
  input pwire [3:0] write_ben;
  cc_ram ramE_mod(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  write_addrE,
  write_data,
  write_wen[0],
  write_ben
  );
  cc_ram ramO(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  write_addrO,
  write_data,
  write_wen[1],
  write_ben
  );
endmodule
module cc_ram_block(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readAZ_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  readBZ_data,
  write_addr,
  write_data,
  write_xdata,
  write_wen,
  write_wen_noins,
  write_addrE0, write_addrEZ,
  write_addrO0, write_addrOZ,
  write_odd0
  );

  parameter INDEX=0;
  localparam DATA_WIDTH=72*16;
  localparam ADDR_WIDTH=7;
  localparam ADDR_COUNT=128;

  input pwire clk;
  input pwire rst;
  input pwire readA_clkEn;
  input pwire [ADDR_WIDTH-1:0] readA_addr;
  output pwire [DATA_WIDTH-1:0] readA_data;
  output pwire [152:0] readAZ_data;
  input pwire readB_clkEn;
  input pwire [ADDR_WIDTH-1:0] readB_addr;
  output pwire [DATA_WIDTH-1:0] readB_data;
  output pwire [152:0] readBZ_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire [152:0] write_xdata;
  input pwire write_wen;
  input pwire write_wen_noins;
  input pwire [ADDR_WIDTH-1:0] write_addrE0;
  input pwire [ADDR_WIDTH-1:0] write_addrO0;
  input pwire [ADDR_WIDTH-1:0] write_addrEZ;
  input pwire [ADDR_WIDTH-1:0] write_addrOZ;

 

  generate
    genvar t;
    for(t=0;t<19;t=t+1) begin : ram_gen
        if (t<16)
        cc_ram ram_mod(
        clk,
        rst,
        readA_clkEn,
        readA_addr,
        readA_data[72*t+:72],
        readB_clkEn,
        readB_addr,
        readB_data[72*t+:72],
        write_addrE,
        write_addrO,
        write_data[72*t+:72],
        {2{write_wen}}&{~write_odd0,write_odd0}
        );
        else
        cc_ram ramB_mod(
        clk,
        rst,
        readA_clkEn,
        readA_addr,
        readAZ_data[72*(t-16)+:72],
        readB_clkEn,
        readB_addr,
        readBZ_data[72*(t-16)+:72],
        t>=16 ? write_addrEZ : write_addrE0,
        t>=16 ? write_addrOZ : write_addrO0,
        writex_data[72*(t-16)+:72],
        {2{write_wen}}&{~write_odd0,write_odd0}^{2{t>=16}}
        );
    end
  endgenerate
endmodule

module ccX_ram0(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  write_addr,
  write_data,
  write_wen
  );

  parameter DATA_WIDTH=60;
  localparam ADDR_WIDTH=7;
  localparam ADDR_COUNT=128;

  input pwire clk;
  input pwire rst;
  input pwire readA_clkEn;
  input pwire [ADDR_WIDTH-1:0] readA_addr;
  output pwire [DATA_WIDTH-1:0] readA_data;
  input pwire readB_clkEn;
  input pwire [ADDR_WIDTH-1:0] readB_addr;
  output pwire [DATA_WIDTH-1:0] readB_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;

  pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] readA_addr_reg;
  pwire [ADDR_WIDTH-1:0] readB_addr_reg;
  
  assign readA_data=ram[readA_addr_reg];
  assign readB_data=ram[readB_addr_reg];

  always @(negedge clk)
    begin
      if (rst) readA_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (readA_clkEn) readA_addr_reg<=readA_addr;
      if (rst) readB_addr_reg<={ADDR_WIDTH{1'b0}};
      else if (readB_clkEn) readB_addr_reg<=readB_addr;
      if (write_wen) ram[write_addr]<=write_data;
    end

endmodule

module ccX_ram(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readAZ_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  readBZ_data,
  write_addr,
  write_data,
  write_addrZ,
  write_wen
  );

  localparam DATA_WIDTH=60;
  localparam ADDR_WIDTH=7;
  localparam ADDR_COUNT=128;

  input pwire clk;
  input pwire rst;
  input pwire readA_clkEn;
  input pwire [ADDR_WIDTH-1:0] readA_addr;
  output pwire [DATA_WIDTH-1:0] readA_data;
  output pwire [7:0] readAZ_data;
  input pwire readB_clkEn;
  input pwire [ADDR_WIDTH-1:0] readB_addr;
  output pwire [DATA_WIDTH-1:0] readB_data;
  output pwire [7:0] readBZ_data;
  input pwire [ADDR_WIDTH-1:0] write_addr;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire [4:0] write_addrZ;
  input pwire write_wen;

  ccX_ram ramX_mod(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  write_addr,
  write_data,
  write_wen
  );
  ccX_ram #(8) ramXX_mod(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readAZ_data,
  readB_clkEn,
  readB_addr,
  readBZ_data,
  write_addrZ,
  write_data[7:0],
  write_wen
  );
endmodule

module ccRam_way(
  clk,
  rst,
  readA_clkEn,
  readA_IP,
  readA_IP_low,
  readA_set_flag,
  readA_data,readA_data_in,
  readA_dataX,readA_dataX_in,
  expun_addr,expun_addr_in,
  readA_hit,expun_hit,
  readB_clkEn,
  readB_IP,
  readB_IP_low,
  readB_set_flag,
  readB_data,readB_data_in,
  readB_dataX,readB_dataX_in,
  readB_hit,
  read_NRU,read_NRU_in,read_NRU_reg,
  chkCL_IP,
  chkCL_clkEn,
  chkCL_hit,
  write_IP,
  write_data,
  write_wen,
  invalidate,
  ErrA,ErrB,
  write_wen_noins,
  write_addrE0, write_hitE0,
  write_addrO0, write_hitO0,
  write_bankEn0, write_odd0,
  write_begin0,write_end0,
  write_bBen0,write_enBen0,
  write_addrE1, write_hitE1,
  write_addrO1, write_hitO1,
  write_bankEn1,write_odd1,
  write_begin1,write_end1,
  write_bBen1,write_enBen1
  );

  localparam DATA_WIDTH=72*18;
  localparam ADDR_WIDTH=7;
  localparam IP_WIDTH=44;
  localparam PHYS_WIDTH=44;
  parameter [2:0] INDEX=0;
  parameter UPPER=0;

  input pwire clk;
  input pwire rst;
  input pwire readA_clkEn;
  input pwire [IP_WIDTH-6:0] readA_IP;
  input pwire [3:0] readA_IP_low;
  input pwire readA_set_flag;
  output pwire [DATA_WIDTH-1:0] readA_data;
  input pwire [DATA_WIDTH-1:0] readA_data_in;
  output pwire [`wport-1:0] readA_dataX;
  input pwire [`wport-1:0] readA_dataX_in;
  output pwire [36:0] expun_addr;
  input pwire [36:0] expun_addr_in;
  output pwire readA_hit;
  output pwire expun_hit;
  input pwire readB_clkEn;
  input pwire [IP_WIDTH-6:0] readB_IP;
  input pwire [3:0] readB_IP_low;
  input pwire readB_set_flag;
  output pwire [DATA_WIDTH-1:0] readB_data;
  input pwire [DATA_WIDTH-1:0] readB_data_in;
  output pwire [`wport-1:0] readB_dataX;
  input pwire [`wport-1:0] readB_dataX_in;
  output pwire readB_hit;
  output pwire [2:0] read_NRU;
  input pwire [2:0] read_NRU_in;
  input pwire [2:0] read_NRU_reg;
  input pwire [IP_WIDTH-6:0] chkCL_IP;
  input pwire chkCL_clkEn;
  output pwire chkCL_hit;
  input pwire [IP_WIDTH-6:0] write_IP;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;
  input pwire invalidate;

  output pwire ErrA,ErrB;
  input pwire write_wen_noins;
  input pwire [`wport-1:0][ADDR_WIDTH-1:0] write_addrE0;
  input pwire [`wport-1:0]write_hitE0; //+1 cycle
  input pwire [`wport-1:0][ADDR_WIDTH-1:0] write_addrO0;
  input pwire [`wport-1:0]write_hitO0; //+1 cycle
  input pwire [`wport-1:0]write_odd0;

  pwire init;

  pwire [DATA_WIDTH-1:0] readA_data_ram;
  pwire [DATA_WIDTH-1:0] readB_data_ram;
  pwire [IP_WIDTH-6:0] write_IP_reg;
  
  pwire [`wport-1:0] readXA_data_ram;
  pwire [`wport-1:0] readXB_data_ram;
  pwire [`wport-1:0] writeX_data;
  pwire [6:0] writeX_addr;

  integer k,j;
  pwire readA_clkEn_reg;
  pwire readA_set_flag_reg;
  pwire readB_clkEn_reg;
  pwire readB_set_flag_reg;
  pwire [3:0] readA_IP_low_reg;
  pwire [9:0] readA_IP_reg;
  pwire read_hitC0; 
  pwire [3:0] readB_IP_low_reg;
  pwire [9:0] readB_IP_reg;
  pwire write_hit; 

  pwire [36:0] expun_naddr;

  pwire [6:0] initCountNext;
  pwire [6:0] initCount;

  pwire [DATA_WIDTH-1:0] write_data_reg;

  generate
    if (~INDEX[0]) begin
        assign readA_data=~(({DATA_WIDTH{readA_hit}} & readA_data_ram) | readA_data_in);
        assign readA_dataX=~(({60{readA_hit}} & readXA_data_ram[`wport-1:0]) | readA_dataX_in);
        assign expun_addr=~(({37{write_hit}} & expun_naddr[36:0]) | expun_addr_in);
        assign readB_data=~(({DATA_WIDTH{readB_hit}} & readB_data_ram) | readB_data_in);
        assign readB_dataX=~(({60{readB_hit}} & readXB_data_ram[`wport-1:0]) | readB_dataX_in);
        assign readAZ_data=~(({DATA_WIDTH/8{readAZ_hit}} & readAZ_data_ram) | readAZ_data_in);
        assign readAZ_dataX=~(({5{readAZ_hit}} & readXAZ_data_ram[4:0]) | readAZ_dataX_in);
        assign readBZ_data=~(({DATA_WIDTH/8{readBZ_hit}} & readBZ_data_ram) | readBZ_data_in);
        assign readBZ_dataX=~(({5{readBZ_hit}} & readXBZ_data_ram[4:0]) | readBZ_dataX_in);
    end else begin
        assign readA_data=~(~({DATA_WIDTH{readA_hit}} & readA_data_ram) & readA_data_in);
        assign readA_dataX=~(~({60{readA_hit}} & readXA_data_ram[`wport-1:0]) & readA_dataX_in);
        assign expun_addr=~(~({37{write_hit}} & expun_naddr[36:0]) & expun_addr_in);
        assign readB_data=~(~({DATA_WIDTH{readB_hit}} & readB_data_ram) & readB_data_in);
        assign readB_dataX=~(~({60{readB_hit}} & readXB_data_ram[`wport-1:0]) & readB_dataX_in);
        assign readAZ_data=~(~({DATA_WIDTH/8{readAZ_hit}} & readAZ_data_ram) & readAZ_data_in);
        assign readAZ_dataX=~(~({5{readAZ_hit}} & readXAZ_data_ram[4:0]) & readAZ_dataX_in);
        assign readBZ_data=~(~({DATA_WIDTH/8{readBZ_hit}} & readBZ_data_ram) & readBZ_data_in);
        assign readBZ_dataX=~(~({5{readBZ_hit}} & readXBZ_data_ram[4:0]) & readBZ_dataX_in);
    end
  endgenerate

  assign writeX_addr=init ? initCount : 7'bz;
  assign writeX_addr=(~init & readA_clkEn_reg) ? readA_IP_reg[8:2] : 7'bz;
  assign writeX_addr=(~init & readB_clkEn_reg) ? readB_IP_reg[8:2] : 7'bz;
  assign writeX_addr=(~init & ~readA_clkEn_reg & ~readB_clkEn_reg) ? write_IP_reg[8:2] : 7'bz;

  assign chkCL_hit=read_hitC0;

  ccX_ram ramX0_mod(
  .clk(clk),
  .rst(rst),
  .readA_clkEn(readA_clkEn),
  .readA_addr(readA_IP[8:2]),
  .readA_data(readXA_data_ram),
  .readAZ_data(readXAZ_data_ram),
  .readB_clkEn(readB_clkEn),
  .readB_addr(readB_IP[8:2]),
  .readB_data(readXB_data_ram),
  .readBZ_data(readXBZ_data_ram),
  .write_addr(writeX_addr),
  .write_addrZ(writeX_addr-7'd1),
  .write_data(init ? 60'b0 : writeX_data),
  .write_wen(write_hit|init|readA_clkEn_reg|readB_clkEn_reg)
  );


  
  cc_ram_block #(0) ram1_mod(
  .clk(clk),
  .rst(rst),
  .readA_clkEn(readA_clkEn),
  .readA_addr(readA_IP[8:2]),
  .readA_data(readA_data_ram),
  .readAZ_data(readAZ_data_ram),
  .readB_clkEn(readB_clkEn),
  .readB_addr(readB_IP[8:2]),
  .readB_data(readB_data_ram),
  .readBZ_data(readBZ_data_ram),
  .write_addr(init ? initCount : write_IP_reg[8:2]),
  .write_addrZ(init ? initCount-7'd1 : write_IP_reg[8:2]-7'd1),
  .write_data(write_data_reg & {DATA_WIDTH{~init}}),
  .write_datax({write_data_reg}),
  .write_wen(write_hit|init)
  );

  pwire errAx,errBx;

  assign errA=^readA_data_ram[64:0] || ^readA_data_ram[64+65:0+65] || ^readA_data_ram[64+130:0+130] || ^readA_data_ram[64+195:195] || 
    ^readA_data_ram[64+260:260] || ^readA_data_ram[64+325:325] || ^readA_data_ram[64+390:390] || ^readA_data_ram[64+455:455] || 
    ^readA_data_ram[64+520:520] || ^readA_data_ram[64+585:585] || ^readA_data_ram[64+650:650] || ^readA_data_ram[64+715:715] || 
    ^readA_data_ram[64+780:780] || ^readA_data_ram[64+845:845] || ^readA_data_ram[64+920:920] || ^readA_data_ram[64+985:985] || errAx;
  assign errB=^readB_data_ram[64:0] || ^readB_data_ram[64+65:0+65] || ^readB_data_ram[64+130:0+130] || ^readB_data_ram[64+195:195] || 
    ^readB_data_ram[64+260:260] || ^readB_data_ram[64+325:325] || ^readB_data_ram[64+390:390] || ^readB_data_ram[64+455:455] || 
    ^readB_data_ram[64+520:520] || ^readB_data_ram[64+585:585] || ^readB_data_ram[64+650:650] || ^readB_data_ram[64+715:715] || 
    ^readB_data_ram[64+780:780] || ^readB_data_ram[64+845:845] || ^readB_data_ram[64+920:920] || ^readB_data_ram[64+985:985] || errBx;

//verilator lint_off WIDTH
  ccTag #(INDEX) tag_mod(
  .clk(clk),
  .rst(rst),
  .read0_clkEn(readA_clkEn),
  .read0_phys_addr(init ? {initCount} : readA_IP[38:2]),
  .read0_hit(readA_hit),
  .read0_err(ErrAx),
  .read1_clkEn(readB_clkEn),
  .read1_phys_addr(init ? {initCount} : readB_IP[38:2]),
  .read1_hit(readB_hit),
  .read1_err(ErrBx),
    .write_phys_addr(init ? {initCount} : write_IP[38:2]),
  .write_wen(write_wen),
  .invalidate(invalidate),
  .hitNRU(read_NRU),
  .hitNRU_in(read_NRU_in),
  .hitNRU_reg(read_NRU_reg),
  .write_hit(write_hit),
  .write_expun_addr({write_addrE0,write_addrO0,bus_expun_addr}),
  .write_exp_en({write_hitE0,write_hitO0,bus_expun_en}),
  .init(init)
  );
  
  
  
//verilator lint_on WIDTH  
  
  adder_inc #(7) initAdd_mod(initCount,initCountNext,1'b1,);
    
  always @* begin
      writeX_data=readA_clkEn_reg ? readXA_data_ram : readXB_data_ram;
      for (k=0;k<4;k=k+1)
          for (j=0;j<15;j=j+1) begin
              writeX_data[k*15+j]=writeX_data[k*15+j]||(readA_set_flag_reg && readA_IP_low_reg==j[3:0] 
                && readA_IP_reg[1:0]==k[1:0])||(readB_set_flag_reg && readB_IP_low_reg==j[3:0]
                && readB_IP_reg[1:0]==k[1:0]);
          end
  end
  
  always @(negedge clk)
  begin
      if (rst) begin
          write_IP_reg<=39'b0;
        //  hitNRU_reg<=3'b0;
          write_data_reg<={DATA_WIDTH{1'B0}};
          readA_clkEn_reg<=1'b0;
          readA_set_flag_reg<=1'b0;
          readA_IP_low_reg<=4'b0;
          readA_IP_reg<=10'b0;
          readB_clkEn_reg<=1'b0;
          readB_set_flag_reg<=1'b0;
          readB_IP_low_reg<=4'b0;
          readB_IP_reg<=10'b0;
      end
      else begin
          write_IP_reg<=write_IP;
        //  hitNRU_reg<=hitNRU;
          write_data_reg<=write_data;
          for(z=0;z<16;z=z+1) begin
              write_data_reg[65*z+64]<=^write_data[65*z+:64];
          end
          readA_clkEn_reg<=readA_clkEn;
          readA_set_flag_reg<=readA_set_flag;
          readA_IP_low_reg<=readA_IP_low;
          readA_IP_reg<=readA_IP[9:0];
          readB_clkEn_reg<=readB_clkEn;
          readB_set_flag_reg<=readB_set_flag;
          readB_IP_low_reg<=readB_IP_low;
          readB_IP_reg<=readB_IP[9:0];
      end
      if (rst) begin
          init<=1'b1;
          initCount<=7'b0;
      end else if (init) begin
         initCount<=initCountNext;
         if (initCount==7'd127)
             init<=1'b0;
      end
  end
    
endmodule



module ccRam_half(
  clk,
  rst,
  readA_clkEn,
  readA_IP,
  readA_set_flag,
  readA_data,
  readA_dataX,
  readB_clkEn,
  readB_IP,
  readB_set_flag,
  readB_data,
  readB_dataX,
  expun_addr,
  readA_hit,readB_hit,expun_hit,
  chkCL_IP,
  chkCL_clkEn,
  chkCL_hit,
  write_IP,
  write_data,
  write_wen,
  invalidate,
  tagErrA,tagErrB,
  write_wen_noins,
  write_addrE0, write_hitE0,
  write_addrO0, write_hitO0,
  write_bankEn0, write_odd0,
  write_begin0,write_end0,
  write_bBen0,write_enBen0,
  write_data0,
  write_addrE1, write_hitE1,
  write_addrO1, write_hitO1,
  write_bankEn1,write_odd1,
  write_begin1,write_end1,
  write_bBen1,write_enBen1
  write_data1
  );

  localparam DATA_WIDTH=72*18;
  localparam ADDR_WIDTH=7;
  localparam IP_WIDTH=44;
  localparam PHYS_WIDTH=44;

  input pwire clk;
  input pwire rst;
  input pwire readA_clkEn;
  input pwire [IP_WIDTH-2:0] readA_IP;
  input pwire readA_set_flag;
  output pwire [DATA_WIDTH-1:0] readA_data;
  output pwire [`wport-1:0] readA_dataX;
  output pwire [7:0] readA_hit_way;
  input pwire readB_clkEn;
  input pwire [IP_WIDTH-2:0] readB_IP;
  input pwire readB_set_flag;
  output pwire [DATA_WIDTH-1:0] readB_data;
  output pwire [`wport-1:0] readB_dataX;
  output pwire [7:0] readB_hit_way;
  output pwire [36:0] expun_addr;
  output pwire readA_hit,readB_hit,expun_hit;
  input pwire [IP_WIDTH-6:0] chkCL_IP;
  input pwire chkCL_clkEn;
  output pwire chkCL_hit;
  input pwire [IP_WIDTH-6:0] write_IP;
  input pwire [DATA_WIDTH-1:0] write_data;
  input pwire write_wen;
  input pwire invalidate;
  output pwire [7:0] tagErrA;
  output pwire [7:0] tagErrB;
  input pwire write_wen_noins;
  input pwire [ADDR_WIDTH-1:0] write_addrE0;
  input pwire write_hitE0; //+1 cycle
  input pwire [ADDR_WIDTH-1:0] write_addrO0;
  input pwire write_hitO0; //+1 cycle
  input pwire write_bankEn0;
  input pwire write_odd0;
  input pwire [4:0] write_begin0;
  input pwire [4:0] write_end0;
  input pwire [3:0] write_bBen0;
  input pwire [3:0] write_enBen0;
  input pwire [ADDR_WIDTH-1:0] write_addrE1;
  input pwire write_hitE1; //+1 cycle
  input pwire [ADDR_WIDTH-1:0] write_addrO1;
  input pwire write_hitO1; //+1 cycle
  input pwire write_bankEn1;
  input pwire write_odd1;
  input pwire [4:0] write_begin1;
  input pwire [4:0] write_end1;
  input pwire [3:0] write_bBen1;
  input pwire [3:0] write_enBen1;
  input pwire [255:0] write_data0;
  input pwire [255:0] write_data1;
  
  pwire [7:0] chkCL_hit_way;
  pwire [7:0] readA_hit_way;
  pwire [7:0] readB_hit_way;
  pwire [7:0] expun_hit_way;
  

  pwire [2:0] read_NRU_reg;
 
  
  generate
      genvar k,b,q;
      for(b=0;b<32;b=b+1) begin : banks_gen
          pwire [7:0] wr0;
          pwire [7:0] wr1;
          for(q=0;q<8;q=q+1) begin
              assign wr0[q]=((b-q)&5'h1f)==write_begin0 && write_clkEn0 && write_bank0[b];
              assign wr1[q]=((b-q)&5'h1f)==write_begin1 && write_clkEn1 && write_bank1[b];
              assign write_new_data[b*32+:32]=wr0[q] ? write_data0[q*32+:32] : 32'BZ;
              assign write_new_data[b*32+:32]=wr1[q] ? write_data1[q*32+:32] : 32'BZ;
          end
          assign  write_new_data[b*32+:32]=(|{wr0,wr1}) ? 32'BZ : 
            write_data[b*32+:32];
          assign write_newx_data[b*36+:36]={^write_new_data[b*32+24+:8],write_new_data[b*32+24+:8],^write_new_data[b*32+16+:8],write_new_data[b*32+16+:8],
              ^write_new_data[b*32+8+:8],write_new_data[b*32+8+:8],^write_new_data[b*32+:8],write_new_data[b*32+:8]};
      end
      for(k=0;k<9;k=k+1) begin : way_gen
          pwire [DATA_WIDTH-1:0] readA_dataP;
          pwire [`wport-1:0] readA_dataXP;
          pwire [DATA_WIDTH-1:0] readB_dataP;
          pwire [`wport-1:0] readB_dataXP;
          pwire [2:0] read_NRUP;
          pwire [36:0] expun_addrP;
          if (k) ccRam_way #(k-1) way_mod(
          .clk(clk),
          .rst(rst),
          .readA_clkEn(readA_clkEn),
          .readA_IP(readA_IP[IP_WIDTH-2:4]),
          .readA_IP_low(readA_IP[3:0]),
          .readA_set_flag(readA_set_flag),
          .readA_data(ways_gen[k].readA_dataP),
          .readA_data_in(ways_gen[k-1].readA_dataP),
          .readAZ_data(ways_gen[k].readAZ_dataP),
          .readAZ_data_in(ways_gen[k-1].readAZ_dataP),
          .readA_dataX(ways_gen[k].readA_dataXP),
          .readAZ_dataX_in(ways_gen[k-1].readAZ_dataXP),
          .readAZ_dataX(ways_gen[k].readAZ_dataXP),
          .readA_dataX_in(ways_gen[k-1].readA_dataXP),
          .readB_clkEn(readB_clkEn),
          .readB_IP(readB_IP[IP_WIDTH-2:4]),
          .readB_IP_low(readB_IP[3:0]),
          .readB_set_flag(readB_set_flag),
          .readB_data(ways_gen[k].readB_dataP),
          .readB_data_in(ways_gen[k-1].readB_dataP),
          .readBZ_data(ways_gen[k].readBZ_dataP),
          .readBZ_data_in(ways_gen[k-1].readBZ_dataP),
          .readB_dataX(ways_gen[k].readB_dataXP),
          .readB_dataX_in(ways_gen[k-1].readB_dataXP),
          .readBZ_dataX(ways_gen[k].readBZ_dataXP),
          .readBZ_dataX_in(ways_gen[k-1].readBZ_dataXP),
          .expun_addr(ways_gen[k].expun_addrP),
          .expun_addr_in(ways_gen[k-1].expun_addrP),
          .readA_hit(readA_hit_way[k-1]),
          .readB_hit(readB_hit_way[k-1]),
	  .expun_hit(expun_hit_way[k-1]),
          .chkCL_IP(chkCL_IP),
          .chkCL_clkEn(chkCL_clkEn),
          .chkCL_hit(chkCL_hit_way[k-1]),
          .read_NRU(read_NRUP[k]),
          .read_NRU_in(read_NRUP[k-1]),
	  .read_NRU_reg(read_NRU_reg),
          .write_IP(write_IP),
          .write_data(write_newx_data),
          .write_wen(write_wen),
          .invalidate(invalidate),
          .ErrA(tagErrA[k-1]),
          .ErrB(tagErrB[k-1])
//	  .read_next_hit()
          );
      end
  endgenerate
  
  assign readA_hit=|readA_hit_way;
  assign readB_hit=|readB_hit_way;
  assign expun_hit=|expun_hit_way;
  assign chkCL_hit=|chkCL_hit_way;

  assign way_mod[0].readA_dataP=0;
  assign way_mod[0].readA_dataXP=0;
  assign way_mod[0].readB_dataP=0;
  assign way_mod[0].readB_dataXP=0;
  assign way_mod[0].read_NRUP=0;
  assign way_mod[0].expun_addrP=0;

  assign readA_data=way_mod[8].readA_dataP;
  assign readA_dataX=way_mod[8].readA_dataXP;
  assign readB_data=way_mod[8].readB_dataP;
  assign readB_dataX=way_mod[8].readB_dataXP;
  assign expun_addr=way_mod[8].expun_addrP;
  

  always @(*) begin
    read_NRU_reg=way_mod[8].read_NRUP;
  end

endmodule


