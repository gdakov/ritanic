
module anticipator_ram(
  clk,
  rst,
  read0_addr,read0_data,
  read1_addr,read1_data,
  read2_addr,read2_data,
  read3_addr,read3_data);
  input pwire clk;
  input pwire rst;
  input pwire [11:0] read0_addr;
  output pwire [1:0] read0_data;
  input pwire [11:0] read1_addr;
  output pwire [1:0] read1_data;
  input pwire [11:0] read2_addr;
  output pwire [1:0] read2_data;
  input pwire [11:0] read3_addr;
  output pwire [1:0] read3_data;

  reg [1:0] ram[4095:0];

  reg [11:0] read0_addr_reg;
  reg [11:0] read1_addr_reg;
  reg [11:0] read2_addr_reg;
  reg [11:0] read3_addr_reg;

  reg can_loop;

  integer k;
  assign read0_data=ram[read0_addr];
  assign read1_data=ram[read1_addr];
  assign read2_data=ram[read2_addr];
  assign read3_data=ram[read3_addr];

  always @* begin
    for(k=0;k<4096;k=k+1) begin
        can_loop=k[7:4]==`jump_nZ || k[7:4]==`jump_nS || k[7:6]==2'b10 || k[7:6]==2'b01; 
        if ((k[11:8]+k[3:0])==4'd1 && can_loop) ram[k]=2'b11;
        else if ((k[11:8]+k[3:0])==4'd2 && can_loop) ram[k]=2'b11;
        else if ((k[11:8]+k[3:0])==4'd3 && can_loop) ram[k]=2'b11;
        else if ((k[11:8]+k[3:0])==4'h8 && can_loop) ram[k]=2'b11;
        else if ((k[11:8]+k[3:0])==4'h9 && can_loop) ram[k]=2'b11;
        else if ((k[11:8]+k[3:0])==4'ha && can_loop) ram[k]=2'b11;
        else ram[k]=2'b00;       
    end
  end

endmodule
