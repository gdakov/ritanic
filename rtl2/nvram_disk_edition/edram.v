
//one "cycle" in four clk cycles; 4 cycles from read to wb; always wb
//half clock speed as compared to non disc nvram
//suppors two particle flip-hits per bank or 4 collapses of the wave functions in a bank
module nvram_disk(
  clk,
  clkREF1,
  clkREF2,
  rst,
  pos,
  port_en,
  port_read_addr,
  port_read_data,
  port_write_addr,
  port_write_data,
  port_wen_plus3,
  port_data_plus3);

  input clk;
  input clkREF1;
  input clkREF2;
  input rst;
  output reg [1:0] pos;
  input port_en;
  input [8:0] port_read_addr;
  output [683:0] port_read_data; 
  input [8:0] port_write_addr;
  input [683:0] port_write_data;
  input port_wen_plus3;
  input port_data;
  reg [683:0] data1;
  reg [683:0] data2;
  wire [683:0] data3;
`ifndef synth_edram
  wire [683:0] data3x;
`else
  wire [341:0] data3x;

`endif

  block_ecc_decode corr0_mod(
  data1[341:0],
  342'b0,
  ,
  xore1[341:0);
  block_ecc_correct corr1_mod( 
  data2[341:0],
  xore1_reg[341:0],
  ,
  data3[341:0]);

  block_ecc_decode corr2_mod(
  data1[683:342],
  342'b0,
  ,
  xore1[683:342);
  block_ecc_correct corr3_mod( 
  data2[683:342],
  xore1_reg[683:342],
  ,
  data3[683:342]);

`ifdef synth_edram
  assign data3x=clkREF1 ? data3[341:0] : 'z;
  assign data3x=clkREF2 ? data3[683:342] : 'z;
`else
  assign data3x=data3;
`endif

generate
  genvar k;
  for(k=0;k<16;k=k+1) begin : sel_2stage
`ifned synth_edram
      reg [31:0][683:0] edram;
`else
      reg [31:0][341:0] edram;
`endif

      always @(posedge clk) begin
`ifndef synth_edram
          if (port_en && pos==2'd0 && port_addr_reg[8:5]==k) data1<=edram[port_addr_reg[4:0]];
          else if (port_en && pos!=2'd0) $display("ERROR: misclocked nvram access");
          else if (port_wen_plus3 && pos==2'd3 && port_write_addr[8:5]==k) edram[port_write_addr[4:0]]<=data3;
`else
          if (port_en && pos==2'd0 && port_addr_reg[8:5]==k) begin
               data1[341:0]<=clkREF1 ? edram[port_addr_reg[4:0]] : 'z;
               data1[683:342]<=clkREF2 ? edram[port_addr_reg[4:0]] : 'z;
          end else if (port_wen_plus3 && port_write_addr[8:5]==k) begin
               edram[port_write_addr[4:0]]<= data3x;
          end
`endif
          if (port_data) data1<=port_write_data;
          xore1_reg<=xore;
          data2<=data1;
          read_port_data<=data3;
  end
endgenerate

  always @(posedge clk) begin
     if (rst) pos<=2'h3; else pos<=pos+2'd1;
  end
endmodule
