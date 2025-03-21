
//one "cycle" in four clk cycles; 4 cycles from read to wb; always wb
module nvram(
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
  output [342:0] port_read_data; 
  input [8:0] port_write_addr;
  input [342:0] port_write_data;
  input port_wen_plus3;
  input port_data;
  reg [341:0] data1;
  reg [341:0] data2;
  wire [341:0] data3;
`ifndef synth_edram
  wire [341:0] data3x;
`else
  wire [170:0] data3x;

`endif

  block_ecc_decode corr0_mod(
  data1,
  342'b0,
  ,
  xore1);
  block_ecc_correct corr_mod( 
  data2,
  xore1_reg,
  ,
  data3);

`ifdef synth_edram
  assign data3x=clkREF1 ? data3[170:0] : 'z;
  assign data3x=clkREF2 ? data3[341:171] : 'z;
`else
  assign data3x=data3;
`endif

generate
  genvar k;
  for(k=0;k<16;k=k+1) begin : sel_2stage
`ifned synth_edram
      reg [31:0][341:0] edram;
`else
      reg [31:0][170:0] edram;
`endif

      always @(posedge clk) begin
`ifndef synth_edram
          if (port_en && pos==2'd0 && port_addr_reg[8:5]==k) data1<=edram[port_addr_reg[4:0]];
          else if (port_en && pos!=2'd0) $display("ERROR: misclocked nvram access");
          else if (port_wen_plus3 && pos==2'd3 && port_write_addr[8:5]==k) edram[port_write_addr[4:0]]<=data3;
`else
          if (port_en && pos==2'd0 && port_addr_reg[8:5]==k) begin
               data1[161:0]<=clkREF1 ? edram[port_addr_reg[4:0]] : 'z;
               data1[323:162]<=clkREF2 ? edram[port_addr_reg[4:0]] : 'z;
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
