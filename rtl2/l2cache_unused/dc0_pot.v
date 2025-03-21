

module dc0_pot(
  clk,
  rst,
  canwr,
  write0_wen,
  write0_addr_odd,
  write0_addr_even,
  write0_odd,
  write0_sz;
  write1_wen,
  write1_addr_odd,
  write1_addr_even,
  read_clkEn,
  read_avail,
  read_addr_even_or_odd
  );

  dc0_cntrlC2w_data memEven(
  clk,
  rst,
  read_clkEn,
  read_pos,
  read_addr_even,
  write_pos,
  write_pos2,
  write0_addr_even,
  write0_wen,
  write1_addr_even,
  write1_wen
  );

  dc0_cntrlC2w_data memOdd(
  clk,
  rst,
  read_clkEn,
  read_pos,
  read_addr_odd,
  write_pos,
  write_pos2,
  write0_addr_odd,
  write0_wen,
  write1_addr_odd,
  write1_wen
  );

  reg [7:0] avail;
  wire [10:1] cnt_or_less;
  popcnt_10_or_less({avail,2'b0},cnt_or_less);

  assign canwr=cnt_or_less[6];
endmodule
