`include "../../rtl/common.sv"

module testrs();

  reg clk=0;
  reg dataRst=1;
  reg nonDataRst=1;
  reg rst_thread=0;
  reg stall=1;
  reg [3:0] FUnHit=0;
  reg new_thread=0;
//Input of new data from registeres
  reg [2:0] newANeeded=0;
  reg [2:0] newBNeeded=0;
  reg [2:0] newSNeeded=0;
  reg [2:0] newRsSelect=0;
  reg [2:0] newPort0=3'd0;

  reg [2:0] newPort1=3'd0;  

  reg [2:0] newPort2=3'd0;  

// wire data to functional units

  reg [2:0] outRsSelect=0;
  wire [2:0] portReady;
  wire [2:0] outDataEn;
    
  reg [3:0] fuFwdA=4'hf;
  reg [3:0] fuFwdB=4'hf;

  reg isDataA=0;
  reg isDataB=0;
  reg isDataS=0;

// free wire
  wire bufFree;

  integer rs=2;
  integer mem=0;
    
  rs_buf buf_mod(
  clk,
  dataRst,nonDataRst,rst_thread,
  stall,
  FUnHit[0],FUnHit[1],FUnHit[2],FUnHit[3],
  new_thread,
// wires to store new values in a buffer
  newANeeded[0],newBNeeded[0],newSNeeded[0],newRsSelect[0],newPort0,
  newANeeded[1],newBNeeded[1],newSNeeded[1],newRsSelect[1],newPort1,
  newANeeded[2],newBNeeded[2],newSNeeded[2],newRsSelect[2],newPort2,
// wires to get values out of buffer
  outRsSelect[0],portReady[0],outDataEn[0],//agu
  outRsSelect[1],portReady[1],outDataEn[1],//alu 1
  outRsSelect[2],portReady[2],outDataEn[2],//alu 2
  fuFwdA,fuFwdB,
  isDataA,isDataB,isDataS,
// 1 if buffer is free  
  bufFree
  );  
  always #50 clk=~clk;
  
  initial begin
  #99
    dataRst=0;
    nonDataRst=0;
    stall=0;
    newRsSelect[rs]=1;
    newANeeded[rs]=1;
    newBNeeded[rs]=1;
  #100
    newRsSelect[rs]=1'b0;
    isDataA=1'b1;
  #100
    isDataA=1'b0;
    isDataB=1'b1;
  #100
    isDataB=1'b0;
    outRsSelect[0]=1'b1;
  #100
    outRsSelect[0]=1'b0;
  #100
  newRsSelect[rs]=1;
  newANeeded[rs]=1;
  newBNeeded[rs]=1;
  #100
  newRsSelect[rs]=1'b0;
  isDataA=1'b1;
  #100
  isDataA=1'b0;
  isDataB=1'b1;
  #100
  fuFwdB=mem;
  isDataB=1'b0;
  #100
  fuFwdB=4'hf;
  isDataB=1'b1;
  #100
  isDataB=1'b0;
  fuFwdB=mem;
  outRsSelect[0]=1'b1;
  #100
  fuFwdB=4'hf;
  outRsSelect[0]=1'b0;
  #100
  isDataB=1'b1;
  #100
  isDataB=1'b0;
  outRsSelect[0]=1'b1;
  #100
  outRsSelect[0]=1'b0;
  newRsSelect[rs]=1'b1;
  #100
  newRsSelect[rs]=1'b0;
  isDataA=1'b1;
  isDataB=1'b1;
  #100
  outRsSelect[0]=1'b1;
  isDataA=1'b0;
  isDataB=1'b0;
  fuFwdB=mem;
  FUnHit[mem]=1'b1;
  #100
  outRsSelect[0]=1'b0;
  fuFwdB=4'hf;
  FUnHit[mem]=1'b0;
  #100
  newRsSelect[rs]=1'b1;
  newANeeded[rs]=1'b0;
  newBNeeded[rs]=1'b0;
  #100
  newRsSelect[rs]=1'b0;
  outRsSelect[0]=1'b1;
  #100
  outRsSelect[0]=1'b0;
  #100
  $finish();
  end

endmodule