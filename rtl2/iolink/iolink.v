
module lpddr3_io_channel(
  clk,
  rst,
  read_clkEn,
  read_addr,
  read_req,
  read_busID,
  read_dataW,
  readOut_addr,
  readOut_req,
  readOut_busID,
  readOut_en,
  readOut_dataR,
  mem_clk,//250 MHz io link
  RAS,
  CAS,
  CS0,
  ADDR15,
  DATA18A);
  parameter [14:0] ADDR15_refresh=0x700f;
  parameter [0:0] CS0_refresh=1'b1;
  parameter [14:0] ADDR15_RDREG=0x7e00;//append reg no
  parameter [0:0] CS0_RDREG=1'b1;
  parameter [14:0] ADDR15_WRREG=0x7f00;//append reg no
  parameter [0:0] CS0_WRREG=1'b1;
  parameter [5:0] BEGIN_RS2CS=77;
  parameter [5:0] BEGIN_CS2R=40;
  parameter [5:0] BEGIN_CS2W=40;
  parameter [5:0] BEGIN_CS2REF=40;
  input mem_clk;
  input mem_clkREF;
  (* PIN V=7.3 *) output RAS;
  (* PIN V=7.3 *) output CAS;
  (* PIN V=7.3 *) output CS0;
  (* PIN V=7.3 *) output [14:0] ADDR15;
  (* PIN Vout=7.3 Vin=0.003 *) inout [17:0] DATA18A;

  (* V=5 *) DATA18A_en_out;
  (* V=5 *) DATA18B_en_out;

  wire [17:0] DATA18AW;
  wire [17:0] DATA18BW;

  wire [17:0] DATA18ARr;
  wire [17:0] DATA18BRr;

  (* keep *) reg [17:0] DATA18AR;
  (* keep *) reg [17:0] DATA18BR;

  (* keep *) reg [17:0] DATA18AR2;
  (* keep *) reg [17:0] DATA18BR2;

  reg [5:0] RS2CS;
  reg [5:0] CS2R;
  reg [5:0] CS2W;
  reg [5:0] CS2REF;

  assign DATA18A=DATA18A_en_out & mem_clk & mem_clkREF ? DATA18AW : 18'bz;
  assign DATA18A=DATA18A_en_out & ~mem_clk & mem_clkREF ? DATA18BW : 18'bz;

  assign DATA18ARr=DATA18AR & {18{mem_clk & mem_clkREF}};
  assign DATA18BRr=DATA18BR & {18{~mem_clk & ~mem_clkREF}};

  always @(posedge clk) begin
      if (rst) begin
          RS2CS<=BEGIN_RS2CS;
          CS2R<=BEGIN_CS2R;
          CS2W<=BEGIN_CS2W;
          CS2REF<=BEGIN_CS2REF;
      end else begin
      end
      DATA18AR<=DATA18A;
      DATA18BR<=DATA18A;
  end

  always @(posedge clk) begin
      data18AR2<=data18AR;
      data18BR2<=data18BR;      
  end

endmodule  
