`include "../../rtl/common.sv"

module testrs_s;

  reg clk=0;
  reg dataRst=1;
  reg nonDataRst=1;
  reg rst_thread=0;
  reg stall=0;
  reg FU0Hit=0;
  reg FU1Hit=0;
  reg FU2Hit=0;
  reg FU3Hit=0;
  reg new_thread=0;
//reg of new data from registeres
  reg newANeeded0=0;
  reg newBNeeded0=0;
  reg newRsSelect0=0;
  reg [4:0] newPort0=4'b0;

  reg newANeeded1=0;
  reg newBNeeded1=0;
  reg newRsSelect1=0;
  reg [4:0] newPort1=4'b0;  

  reg newANeeded2=0;
  reg newBNeeded2=0;
  reg newRsSelect2=0;
  reg [4:0] newPort2=4'b0;  

// wire data to functional units

  reg outRsSelect0=0;
  wire portReady0;
  wire [3:0] outDataEn0;
  wire outThread0;
    
  reg outRsSelect1=0;
  wire portReady1;
  wire [3:0] outDataEn1;
  wire outThread1;

  reg outRsSelect2=0;
  wire portReady2;
  wire [3:0] outDataEn2;
  wire outThread2;

  reg outRsSelect3=0;
  wire portReady3;
  wire [3:0] outDataEn3;
  wire outThread3;

  reg [3:0] fuFwdA=0;
  reg [3:0] fuFwdB=0;

  reg isDataA=0;
  reg isDataB=0;
  reg isDataS=0;

// free wire
  wire bufFree;

  rss_buf buf_mod(
  clk,
  dataRst,nonDataRst,rst_thread,
  stall,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  new_thread,
// wires to store new values in a buffer
  newANeeded0,newBNeeded0,newRsSelect0,newPort0,
  newANeeded1,newBNeeded1,newRsSelect1,newPort1,
  newANeeded2,newBNeeded2,newRsSelect2,newPort2,
// wires to get values out of buffer
  outRsSelect0,portReady0,outDataEn0,outThread0,//agu
  outRsSelect1,portReady1,outDataEn1,outThread1,//data
  outRsSelect2,portReady2,outDataEn2,outThread2,//agu
  outRsSelect3,portReady3,outDataEn3,outThread3,//data
  fuFwdA,fuFwdB,
  isDataA,isDataB,
// 1 if buffer is free  
  bufFree
  );
  
endmodule
