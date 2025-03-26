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


module dc1_xbit_ram(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  readB_clkEn,
  readB_addr,
  readB_data,
  writeA_clkEn,
  writeA_addr,
  writeA_data,
  writeB_clkEn,
  writeB_addr,
  writeB_data);
  localparam ADDR_WIDTH=5;
  localparam ADDR_COUNT=32;

  input pwire clk;
  input pwire rst;
  input pwire                  readA_clkEn;
  input pwire [ADDR_WIDTH-1:0] readA_addr;
  output pwire [35:0]          readA_data;
  input pwire                  readB_clkEn;
  input pwire [ADDR_WIDTH-1:0] readB_addr;
  output pwire [35:0]          readB_data;
  input pwire                  writeA_clkEn;
  input pwire [ADDR_WIDTH-1:0] writeA_addr;
  input pwire  [35:0]          writeA_data;
  input pwire                  writeB_clkEn;
  input pwire [ADDR_WIDTH-1:0] writeB_addr;
  input pwire  [35:0]          writeB_data;

  pwire [35:0] RAM[ADDR_COUNT-1:0];
  pwire [ADDR_WIDTH-1:0] readA_addr_reg;
  pwire [ADDR_WIDTH-1:0] readB_addr_reg;

  assign readA_data=RAM[readA_addr_reg];
  assign readB_data=RAM[readB_addr_reg];

  always @(posedge clk) begin
      readA_addr_reg<=readA_addr;
      readB_addr_reg<=readB_addr;
      if (writeA_clkEn) RAM[writeA_addr]<=writeA_data;
      if (writeB_clkEn) RAM[writeB_addr]<=writeB_data;
  end
endmodule

module dc1_xbit(
  clk,
  rst,
  read0_clkEn,read0_addrE,read0_addrO,read0_odd,read0_pbit,
  read1_clkEn,read1_addrE,read1_addrO,read1_odd,read1_pbit,
  read2_clkEn,read2_addrE,read2_addrO,read2_odd,read2_pbit,
  read3_clkEn,read3_addrE,read3_addrO,read3_odd,read3_pbit,
  write0_clkEn,write0_addrE,write0_addrO,write0_odd,write0_pbit,write0_d128,
  write1_clkEn,write1_addrE,write1_addrO,write1_odd,write1_pbit,write1_d128,
  write_ins,write_data);
  localparam ADDR_WIDTH=5;
  localparam ADDR_COUNT=32;
  input pwire clk;
  input pwire rst;
  input pwire read0_clkEn;
  input pwire [ADDR_WIDTH+4:0] read0_addrE;
  input pwire [ADDR_WIDTH+4:0] read0_addrO;
  input pwire read0_odd;
  output pwire [1:0] read0_pbit;
  input pwire read1_clkEn;
  input pwire [ADDR_WIDTH+4:0] read1_addrE;
  input pwire [ADDR_WIDTH+4:0] read1_addrO;
  input pwire read1_odd;
  output pwire [1:0] read1_pbit;
  input pwire read2_clkEn;
  input pwire [ADDR_WIDTH+4:0] read2_addrE;
  input pwire [ADDR_WIDTH+4:0] read2_addrO;
  input pwire read2_odd;
  output pwire [1:0] read2_pbit;
  input pwire read3_clkEn;
  input pwire [ADDR_WIDTH+4:0] read3_addrE;
  input pwire [ADDR_WIDTH+4:0] read3_addrO;
  input pwire read3_odd;
  output pwire [1:0] read3_pbit;
  input pwire write0_clkEn;
  input pwire [ADDR_WIDTH+4:0] write0_addrE;
  input pwire [ADDR_WIDTH+4:0] write0_addrO;
  input pwire write0_odd;
  input pwire [1:0] write0_pbit;
  input pwire write0_d128;
  input pwire write1_clkEn;
  input pwire [ADDR_WIDTH+4:0] write1_addrE;
  input pwire [ADDR_WIDTH+4:0] write1_addrO;
  input pwire write1_odd;
  input pwire [1:0] write1_pbit;
  input pwire write1_d128;
  input pwire [1:0] write_ins;
  input pwire [15:0] write_data;

  pwire [35:0] read0_data_ram[1:0];
  pwire [35:0] read1_data_ram[1:0];
  pwire [35:0] read2_data_ram[1:0];
  pwire [35:0] read3_data_ram[1:0];
  pwire [35:0] readA_data_ram[1:0];
  pwire [35:0] readB_data_ram[1:0];
  pwire [35:0] write_dataA[1:0];
  pwire [35:0] write_dataB[1:0];
  
  pwire [32:0] read0_data_ramx[1:0];
  pwire [32:0] read1_data_ramx[1:0];
  pwire [32:0] read2_data_ramx[1:0];
  pwire [32:0] read3_data_ramx[1:0];
  pwire [31:0] readA_data_ramx[1:0];
  pwire [31:0] readB_data_ramx[1:0];
  pwire [31:0] write_dataAx[1:0];
  pwire [31:0] write_dataBx[1:0];

  pwire [15:0] write_data_reg;

  pwire [1:0] write0_clkEn_reg;
  pwire [1:0] write1_clkEn_reg;
  pwire [1:0] write_ins_reg;
  
  pwire [ADDR_WIDTH+4:0] write1_addr_reg;
  pwire [ADDR_WIDTH+4:0] write0_addr_reg;
  pwire [ADDR_WIDTH+4:0] write1_addrEO_reg[1:0];
  pwire [ADDR_WIDTH+4:0] write0_addrEO_reg[1:0];
  pwire [ADDR_WIDTH+4:0] read0_addrEO[1:0];
  pwire [ADDR_WIDTH+4:0] read1_addrEO[1:0];
  pwire [ADDR_WIDTH+4:0] read2_addrEO[1:0];
  pwire [ADDR_WIDTH+4:0] read3_addrEO[1:0];
  pwire [ADDR_WIDTH+4:0] write0_addrEO[1:0];
  pwire [ADDR_WIDTH+4:0] write1_addrEO[1:0];
  pwire  [ADDR_WIDTH+4:0] read0_addrEO_reg[1:0];
  pwire  [ADDR_WIDTH+4:0] read1_addrEO_reg[1:0];
  pwire  [ADDR_WIDTH+4:0] read2_addrEO_reg[1:0];
  pwire  [ADDR_WIDTH+4:0] read3_addrEO_reg[1:0];
  pwire  [ADDR_WIDTH+4:0] read0_addr_reg;
  pwire  [ADDR_WIDTH+4:0] read1_addr_reg;
  pwire  [ADDR_WIDTH+4:0] read2_addr_reg;
  pwire  [ADDR_WIDTH+4:0] read3_addr_reg;
  pwire read0_odd_reg;
  pwire read1_odd_reg;
  pwire read2_odd_reg;
  pwire read3_odd_reg;
  integer k;
  pwire write0_d128_reg;
  pwire write1_d128_reg;
  pwire [1:0] write0_pbit_reg;
  pwire [1:0] write1_pbit_reg;
  pwire write0_odd_reg;
  pwire write1_odd_reg;
  pwire [17:0] dummy0;
  pwire [17:0] dummy1;
  pwire [17:0] dummy2;
  pwire [17:0] dummy3;

function [35:0] en_ECC;
  input pwire [31:0] data;
  en_ECC={^data[31:24],data[31:24],^data[23:16],data[23:16],^data[15:8],data[15:8],^data[7:0],data[7:0]};
endfunction
function [31:0] un_ECC;
  input pwire [35:0] data;
  un_ECC={data[34:27],data[25:18],data[16:9],data[7:0]};
endfunction
generate
  genvar x;
  for(x=0;x<2;x=x+1)begin : ramset
  dc1_xbit_ram ramA0(
  clk,
  rst,
  read0_clkEn,
  read0_addrEO[x][ADDR_WIDTH+3:4],
  read0_data_ram[x],
  read1_clkEn,
  read1_addrEO[x][ADDR_WIDTH+3:4],
  read1_data_ram[x],
  write0_clkEn_reg[x]|write_ins[x],
  write0_addrEO_reg[x][ADDR_WIDTH+3:4],
  write_dataA[x],
  write1_clkEn_reg[x]&~write_ins_reg[x],
  write1_addrEO_reg[x][ADDR_WIDTH+3:4],
  write_dataB[x]);

  dc1_xbit_ram ramB0(
  clk,
  rst,
  read2_clkEn,
  read2_addrEO[x][ADDR_WIDTH+3:4],
  read2_data_ram[x],
  read3_clkEn,
  read3_addrEO[x][ADDR_WIDTH+3:4],
  read3_data_ram[x],
  write0_clkEn_reg[x]|write_ins_reg[x],
  write0_addrEO_reg[x][ADDR_WIDTH+3:4],
  write_dataA[x],
  write1_clkEn_reg[x]&~write_ins[x],
  write1_addrEO_reg[x][ADDR_WIDTH+3:4],
  write_dataB[x]);


  dc1_xbit_ram ramC0(
  clk,
  rst,
  write0_clkEn,
  write0_addrEO[x][ADDR_WIDTH+3:4],
  readA_data_ram[x],
  write1_clkEn,
  write1_addrEO[x][ADDR_WIDTH+3:4],
  readB_data_ram[x],
  write0_clkEn_reg[x]|write_ins_reg[x],
  write0_addrEO_reg[x][ADDR_WIDTH+3:4],
  write_dataA[x],
  write1_clkEn_reg[x]&~write_ins_reg[x],
  write1_addrEO_reg[x][ADDR_WIDTH+3:4],
  write_dataB[x]);

  end
endgenerate

assign read0_addrEO[0]=read0_addrE;
assign read0_addrEO[1]=read0_addrO;
assign read1_addrEO[0]=read1_addrE;
assign read1_addrEO[1]=read1_addrO;
assign read2_addrEO[0]=read2_addrE;
assign read2_addrEO[1]=read2_addrO;
assign read3_addrEO[0]=read3_addrE;
assign read3_addrEO[1]=read3_addrO;

assign write0_addrEO[0]=write0_addrE;
assign write0_addrEO[1]=write0_addrO;
assign write1_addrEO[0]=write1_addrE;
assign write1_addrEO[1]=write1_addrO;

always @* begin
  write_dataAx[write0_odd_reg]={30'b0,write0_pbit_reg}<<{write0_addr_reg[ADDR_WIDTH+4],write0_addr_reg[3:0]};
  write_dataBx[write1_odd_reg]={30'b0,write1_pbit_reg}<<{write1_addr_reg[ADDR_WIDTH+4],write1_addr_reg[3:0]};
  write_dataAx[~write0_odd_reg]=readA_data_ramx[~write0_odd_reg];
  write_dataBx[~write1_odd_reg]=readB_data_ramx[~write1_odd_reg];
  for(k=0;k<16;k=k+1) begin
      if (write0_addr_reg[ADDR_WIDTH+4] && k[3:0]!=write0_addr_reg[3:0] && ((k[4:0]-5'd1)!={1'b0,write0_addr_reg[3:0]} || ~write0_d128_reg))
          write_dataAx[1][k+16]=readA_data_ramx[1][k+16];
      if (~write0_addr_reg[ADDR_WIDTH+4] && k[3:0]!=write0_addr_reg[3:0] && ((k[4:0]-5'd1)!={1'b0,write0_addr_reg[3:0]} || ~write0_d128_reg))
          write_dataAx[0][k]=readA_data_ramx[0][k];
      if (write1_addr_reg[ADDR_WIDTH+4] && k[3:0]!=write1_addr_reg[3:0] && ((k[4:0]-5'd1)!={1'b0,write1_addr_reg[3:0]} || ~write1_d128_reg))
          write_dataBx[1][k+16]=readB_data_ramx[1][k+16];
      if (~write1_addr_reg[ADDR_WIDTH+4] && k[3:0]!=write1_addr_reg[3:0] && ((k[4:0]-5'd1)!={1'b0,write1_addr_reg[3:0]} || ~write1_d128_reg))
          write_dataBx[0][k]=readB_data_ramx[0][k];
  end
  if (write0_odd_reg && pwh#(4)::cmpEQ(write0_addr_reg[3:0],4'hf) && ~|write_ins_reg) write_dataAx[0][0]=write0_pbit_reg[1];
  if (write1_odd_reg && pwh#(4)::cmpEQ(write1_addr_reg[3:0],4'hf) && ~|write_ins_reg) write_dataBx[0][0]=write1_pbit_reg[1];
  if (~write0_odd_reg && pwh#(4)::cmpEQ(write0_addr_reg[3:0],4'hf) && ~|write_ins_reg) write_dataAx[1][0]=write0_pbit_reg[1];
  if (~write1_odd_reg && pwh#(4)::cmpEQ(write1_addr_reg3[3:0],4'hf) && ~|write_ins_reg) write_dataBx[1][0]=write1_pbit_reg[1];
  if (write_ins_reg[0]) write_dataAx[0][15+16*write0_addr_reg[ADDR_WIDTH+4]+:16]= write_data_reg; 
  if (write_ins_reg[1]) write_dataAx[1][15+16*write0_addr_reg[ADDR_WIDTH+4]+:16]= write_data_reg; 
end
 
assign write_dataA[0]=en_ECC(write_dataAx[0]);
assign write_dataA[1]=en_ECC(write_dataAx[1]);
assign write_dataB[0]=en_ECC(write_dataBx[0]);
assign write_dataB[1]=en_ECC(write_dataBx[1]);

assign read0_data_ramx[0]={1'b0,un_ECC(read0_data_ram[0])};
assign read1_data_ramx[0]={1'b0,un_ECC(read1_data_ram[0])};
assign read2_data_ramx[0]={1'b0,un_ECC(read2_data_ram[0])};
assign read3_data_ramx[0]={1'b0,un_ECC(read3_data_ram[0])};
assign readA_data_ramx[0]=un_ECC(readA_data_ram[0]);
assign readB_data_ramx[0]=un_ECC(readB_data_ram[0]);
assign read0_data_ramx[1]={1'b0,un_ECC(read0_data_ram[1])};
assign read1_data_ramx[1]={1'b0,un_ECC(read1_data_ram[1])};
assign read2_data_ramx[1]={1'b0,un_ECC(read2_data_ram[1])};
assign read3_data_ramx[1]={1'b0,un_ECC(read3_data_ram[1])};
assign readA_data_ramx[1]=un_ECC(readA_data_ram[1]);
assign readB_data_ramx[1]=un_ECC(readB_data_ram[1]);

always @* begin
  read0_pbit=read0_data_ramx[read0_odd_reg][{1'b0,read0_addrEO_reg[read0_odd_reg][ADDR_WIDTH+4],read0_addr_reg[3:0]}+:2];
  read1_pbit=read1_data_ramx[read1_odd_reg][{1'b0,read1_addrEO_reg[read1_odd_reg][ADDR_WIDTH+4],read1_addr_reg[3:0]}+:2];
  read2_pbit=read2_data_ramx[read2_odd_reg][{1'b0,read2_addrEO_reg[read2_odd_reg][ADDR_WIDTH+4],read2_addr_reg[3:0]}+:2];
  read3_pbit=read3_data_ramx[read3_odd_reg][{1'b0,read3_addrEO_reg[read3_odd_reg][ADDR_WIDTH+4],read3_addr_reg[3:0]}+:2];
  if (pwh#(4)::cmpEQ(read0_addr_reg[3:0],4'hf)) read0_pbit[1]=read0_data_ramx[~read0_odd_reg][0];
  if (pwh#(4)::cmpEQ(read1_addr_reg[3:0],4'hf)) read1_pbit[1]=read1_data_ramx[~read1_odd_reg][0];
  if (pwh#(4)::cmpEQ(read2_addr_reg[3:0],4'hf)) read2_pbit[1]=read2_data_ramx[~read2_odd_reg][0];
  if (pwh#(4)::cmpEQ(read3_addr_reg[3:0],4'hf)) read3_pbit[1]=read3_data_ramx[~read3_odd_reg][0];
end
always @(posedge clk) begin
  if (rst) begin
      write0_clkEn_reg<=2'b0;
      write1_clkEn_reg<=2'b0;
      write_ins_reg<=2'b0;
      write_data_reg<=0;
      write0_addr_reg<=0;
      write1_addr_reg<=0;
      write0_addrEO_reg[0]<=0;
      write1_addrEO_reg[0]<=0;
      write0_addrEO_reg[1]<=0;
      write1_addrEO_reg[1]<=0;
      read0_addr_reg<=0;// NOT AN ERROR!
      read1_addr_reg<=0;
      read2_addr_reg<=0;
      read3_addr_reg<=0;
      read0_addrEO_reg[0]<=0;
      read1_addrEO_reg[0]<=0;
      read2_addrEO_reg[0]<=0;
      read3_addrEO_reg[0]<=0;
      read0_addrEO_reg[1]<=0;
      read1_addrEO_reg[1]<=0;
      read2_addrEO_reg[1]<=0;
      read3_addrEO_reg[1]<=0;
      read0_odd_reg<=1'b0;
      read1_odd_reg<=1'b0;
      read2_odd_reg<=1'b0;
      read3_odd_reg<=1'b0;
      write0_odd_reg<=1'b0;
      write1_odd_reg<=1'b0;
      write0_d128_reg<=1'b0;
      write1_d128_reg<=1'b0;
      write0_pbit_reg<=2'b0;
      write1_pbit_reg<=2'b0;
  end else begin
      write0_clkEn_reg<={write0_odd,~write0_odd}&{2{write0_clkEn}};
      write1_clkEn_reg<={write1_odd,~write1_odd}&{2{write1_clkEn}};
      write_ins_reg<=write_ins;
      write_data_reg<=write_data;
      write0_addr_reg<=write0_odd ? write0_addrO : write0_addrE;
      write1_addr_reg<=write1_odd ? write1_addrO : write1_addrE;
      write0_addrEO_reg[0]<=write0_addrE;
      write1_addrEO_reg[0]<=write1_addrE;
      write0_addrEO_reg[1]<=write0_addrO;
      write1_addrEO_reg[1]<=write1_addrO;
      read0_addr_reg<=read0_addrE;
      read1_addr_reg<=read1_addrE;
      read2_addr_reg<=read2_addrE;
      read3_addr_reg<=read3_addrE;
      read0_addrEO_reg[0]<=read0_addrEO[0];
      read1_addrEO_reg[0]<=read1_addrEO[0];
      read2_addrEO_reg[0]<=read2_addrEO[0];
      read3_addrEO_reg[0]<=read3_addrEO[0];
      read0_addrEO_reg[1]<=read0_addrEO[1];
      read1_addrEO_reg[1]<=read1_addrEO[1];
      read2_addrEO_reg[1]<=read2_addrEO[1];
      read3_addrEO_reg[1]<=read3_addrEO[1];
      read0_odd_reg<=read0_odd;
      read1_odd_reg<=read1_odd;
      read2_odd_reg<=read2_odd;
      read3_odd_reg<=read3_odd;
      write0_odd_reg<=write0_odd;
      write1_odd_reg<=write1_odd;
      write0_d128_reg<=write0_d128;
      write1_d128_reg<=write1_d128;
      write0_pbit_reg<=write0_pbit;
      write1_pbit_reg<=write1_pbit;
      
  end
end
endmodule
