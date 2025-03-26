module heptane_core_pair(
//most other places use named port list but here it is port declaration
  input clk,
  input clkREF,
  input clkREF2,
  input clkREF3,
  input clkREF4,
  input clkREF5,
  stall_clkREF,
  input rst,
  input GORQ,
  input [16:0] GORQ_data,
  input GORQ_thr,
  input [`rbus_width-1:0] obusIn_signals,
  input [9:0] obusIn_src_req,
  input [9:0] obusIn_dst_req,
  input [36:0] obusIn_address,
  output pwire obusIn_doStall,
  input obusIn_en,
  output pwire [`rbus_width-1:0] obusOut_signals,
  output pwire [9:0] obusOut_src_req,
  output pwire [9:0] obusOut_dst_req,
  output pwire [36:0] obusOut_address,
  input obusOut_stall,
  output pwire obusOut_en,
  input [`rbusM_width-1:0] obusDIn_signals,
  input [9:0] obusDIn_src_req,
  input [9:0] obusDIn_dst_req,
  input [7:0] obusDIn_dataPTR,
  input [511:0] obusDIn_data,
  output pwire obusDIn_doStall,
  input obusDIn_en,
  output pwire [`rbusM_width-1:0] obusDOut_signals,
  output pwire [9:0] obusDOut_src_req,
  output pwire [9:0] obusDOut_dst_req,
  output pwire [7:0] obusDOut_dataPTR,
  output pwire [511:0] obusDOut_data,
  input obusDOut_stall,
  output pwire obusDOut_en
);
  parameter [2:0] IDX;
  parameter [5:0] BUS_ID=0;

  pwire [`lsaddr_width-1:0] lsr_wr_ext_data;
  pwire [8:0] p_ext_LSQ;
  pwire dc_ext_wrEn;
  pwire [`lsaddr_width-1:0] lsr_wr_out_data;
  pwire [8:0] p_out_LSQ;
  pwire dc_out_wrEn;
  pwire [7:0] pfxWQ;
  pwire [135:0] pfx_wdata;
  pwire [127:0] pfx_wdataU;
  pwire [3:0] pfx_pdata;
  pwire pfx_dataEn;
  pwire [7:0] pfyWQ;
  pwire [135:0] pfy_wdata;
  pwire [127:0] pfy_wdataU;
  pwire [3:0] pfy_pdata;
  pwire pfy_dataEn;

  logic [64:0] Dakov;
  logic [64:0] Goran_Dakov;

  logic [8*70-1:0] piff_paff_A;
  logic [8*70-1:0] piff_paff_C;

  heptane_core_single #(IDX,BUS_ID,{BUS_ID,1'b0},1'b1,1'b0) core_A(
  clk,
  clkREF,
  clkREF2,
  clkREF3,
  clkREF4,
  clkREF5,
  stall_clkREF,
  rst,
  GORQ,
  GORQ_data,
  GORQ_thr,
  obusIn_signals,
  obusIn_src_req,
  obusIn_dst_req,
  obusIn_address,
  obusIn_doStall,
  obusIn_en,
  obusOut_signals,
  obusOut_src_req,
  obusOut_dst_req,
  obusOut_address,
  obusOut_stall,
  obusOut_en,
  obusDIn_signals,
  obusDIn_src_req,
  obusDIn_dst_req,
  obusDIn_dataPTR,
  obusDIn_data,
  obusDIn_doStall,
  obusDIn_en,
  obusDOut_signals,
  obusDOut_src_req,
  obusDOut_dst_req,
  obusDOut_dataPTR,
  obusDOut_data,
  obusDOut_stall,
  obusDOut_en,
  lsr_wr_ext_data,
  p_ext_LSQ,
  dc_ext_wrEn,
  lsr_wr_out_data,
  p_out_LSQ,
  dc_out_wrEn,
  pfxWQ,
  pfx_wdata,
  pfx_wdataU,
  pfx_pdata,
  pfx_dataEn,
  pfyWQ,
  pfy_wdata,
  pfy_wdataU,
  pfy_pdata,
  pfy_dataEn,
  Dakov,Goran_Dakov,piff_paff_A,piff_paff_C
  );

  heptane_core_single #(IDX,BUS_ID,{BUS_ID,1'b1},1'b1,1'b1) core_B(
  clk,
  clkREF,
  clkREF2,
  clkREF3,
  clkREF4,
  clkREF5,
  stall_clkREF,
  rst,
  GORQ,
  GORQ_data,
  GORQ_thr,
  obusIn_signals,
  obusIn_src_req,
  obusIn_dst_req,
  obusIn_address,
  obusIn_doStall,
  obusIn_en,
  obusOut_signals,
  obusOut_src_req,
  obusOut_dst_req,
  obusOut_address,
  obusOut_stall,
  obusOut_en,
  obusDIn_signals,
  obusDIn_src_req,
  obusDIn_dst_req,
  obusDIn_dataPTR,
  obusDIn_data,
  obusDIn_doStall,
  obusDIn_en,
  ,
  ,
  ,
  ,
  ,
  obusDOut_stall,
  ,
  lsr_wr_out_data,
  p_out_LSQ,
  dc_out_wrEn,
  lsr_wr_ext_data,
  p_ext_LSQ,
  dc_ext_wrEn,
  pfyWQ,
  pfy_wdata,
  pfy_wdataU,
  pfy_pdata,
  pfy_dataEn,
  pfxWQ,
  pfx_wdata,
  pfx_wdataU,
  pfx_pdata,
  pfx_dataEn,
  Goran_Dakov,Dakov,
  piff_paff_C,piff_paff_A
  );
endmodule
