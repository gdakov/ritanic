module vbox_hbox_edram(
  clk,
  clkREF1,
  clkREF2,
  rst,
  pos,
  port_en,
  port_read_addr,
  port_read_data,
  port_write_addr,
  port_write_data
  );

  input clk;
  input clkREF1;
  input clkREF2;
  input rst;
  output [3:0] pos;
  input port_en;
  input port_ref_plus2;
  input [18:0] port_read_addr;
  output [342:0] port_read_data; 
  input [18:0] port_write_addr;
  input [342:0] port_write_data;
 




  generate
    genvar hpos,vpos;
    for(hpos=0;hpos<32;hpos=hpos+1) begin : vbox_512K
        wire [342:0] port_read_dataX1; 
        wire [342:0] port_read_dataX2;
        for(vpos=0;vpos<32;vpos=vpos+1) begin : box_12M
            wire [342:0] port_read_dataX; 
            wire [342:0] port_read_dataX0; 
            reg [342:0]  port_read_dataX0_reg; 
            nvram mem_mod(
            clk,
            clkREF1,
            clkREF2,
            rst,
            pos,
            port_en_reg && port_addr_reg[13:9]==hpos && port_addr_reg[18:14]==vpos,
            port_read_addr_reg[8:0],
            port_read_dataX,
            port_write_addr_reg[8:0],
            port_write_data,
            port_wen_plus3_reg && write_addr_reg[13:9]==hpos && write_addr_reg[18:14]==vpos);

            assign vbox_512K[hpos].box_12M[vpos & 5'h18].read_dataX0=port_en_reg2 && 
                port_addr_reg2[13:9]==hpos && port_addr_reg2[18:14]==vpos ?
                port_read_dataX : 'z;
            always @(posedge clk) begin
                read_dataX0_reg<=read_dataX0;
            end
        end
        assign vbox_512K[hpos].read_dataX1=port_en_reg3 && 
                port_addr_reg3[13:9]==hpos  ?
                vbox_512K[hpos].box_12M[5'h18].read_dataX0_reg : 'z;
        assign vbox_512K[hpos&5'h18].read_dataX2=port_en_reg3 && 
                port_addr_reg3[13:9]==hpos  ?
                vbox_512K[hpos].read_dataX1 : 'z;
    end
  endgenerate
  wire [342:0] port_read_dataX3;
  assign read_dataX2=port_en_reg3 && 
    port_addr_reg3[13:9]==hpos  ?
    vbox_512K[5'h18].read_dataX2 : 'z;

endmodule
