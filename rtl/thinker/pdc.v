
module pdc_ram(
  clk,
  rst,
  read_addr,
  read_clkEn,
  read_data,
  write_addr,
  write_data,
  write_wen);
  input pwire clk;
  input pwire rst;
  input pwire [2:0][10:0] read_addr;
  input pwire [2:0] read_clkEn;
  output pwire reg [2:0][`pdc_width-1:0] read_data;
  input pwire [10:0] write_addr;
  input pwire write_wen;
  input pwire [`pdc_width-1:0] write_data;

  reg [2:0][`pdc_width-1:0] read_data0;
  reg [2:0][10:0] read_addr0;
  integer k;
  reg [`pdc_width-1:0] ram[2047:0];

  always @(posedge clk) begin
    if (rst) begin
        read_addr<=0;
        ram<=0;
    end else begin
        for (k=0;k<3;k=k+1) begin
            if (read_clkEn[k]) read_addr0[k]<=read_addr[k];
            read_data[k]<=ram[read_addr0[k]];
        end
        if (write_wen) ram[write_addr]<=write_data;
    end
  end
endmodule
