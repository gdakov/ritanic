/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


`include "../struct.sv"

 

module rs_wakeUp_logic(
  clk,rst,stall,
  isData,
  outEq,
  buffree,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  FUreg0,FU0wen,
  FUreg1,FU1wen,
  FUreg2,FU2wen,
  FUreg3,FU3wen,
  FUreg4,FU4wen,
  FUreg5,FU5wen,
  FUreg6,FU6wen,
  FUreg7,FU7wen,
  FUreg8,FU8wen,
  FUreg9,FU9wen,
  FUreg4_reg,FU4wen_reg,
  FUreg5_reg,FU5wen_reg,
  FUreg6_reg,FU6wen_reg,
  FUreg4_reg2,FU4wen_reg2,
  FUreg5_reg2,FU5wen_reg2,
  FUreg6_reg2,FU6wen_reg2,
  FUreg7_reg,FU7wen_reg,
  FUreg8_reg,FU8wen_reg,
  FUreg9_reg,FU9wen_reg,
  FUreg7_reg2,FU7wen_reg2,
  FUreg8_reg2,FU8wen_reg2,
  FUreg9_reg2,FU9wen_reg2,
  newRsSelect0,newReg0,newFunit0,newGazump0,newIsFP0,newIsV0,newEQ0,
  newRsSelect1,newReg1,newFunit1,newGazump1,newIsFP1,newIsV1,newEQ1,
  newRsSelect2,newReg2,newFunit2,newGazump2,newIsFP2,newIsV2,newEQ2,
  fuFwd,
  outRsSelect0,outDataEn0,outFuFwd0,outFuuFwd0,
  outRsSelect1,outDataEn1,outFuFwd1,outFuuFwd1,
  outRsSelect2,outDataEn2,outFuFwd2,outFuuFwd2
  );
  parameter DATA_WIDTH=`alu_width+1;
  localparam REG_WIDTH=`reg_addr_width;
  localparam FN_WIDTH=10;

  input pwire clk;
  input pwire rst;
  input pwire stall;
  output pwire isData;
  (* horizontal *) output pwire [5:0] outEq;
  input pwire buffree;
  input pwire FU0Hit;
  input pwire FU1Hit;
  input pwire FU2Hit;
  input pwire FU3Hit;
//functional units inputs/outputs
  input pwire [REG_WIDTH-1:0] FUreg0;
  input pwire FU0wen;
  
  input pwire [REG_WIDTH-1:0] FUreg1;
  input pwire FU1wen;

  input pwire [REG_WIDTH-1:0] FUreg2;
  input pwire FU2wen;

  input pwire [REG_WIDTH-1:0] FUreg3;
  input pwire FU3wen;

  input pwire [REG_WIDTH-1:0] FUreg4;
  input pwire FU4wen;

  input pwire [REG_WIDTH-1:0] FUreg5;
  input pwire FU5wen;

  input pwire [REG_WIDTH-1:0] FUreg6;
  input pwire FU6wen;

  input pwire [REG_WIDTH-1:0] FUreg7;
  input pwire FU7wen;

  input pwire [REG_WIDTH-1:0] FUreg8;
  input pwire FU8wen;

  input pwire [REG_WIDTH-1:0] FUreg9;
  input pwire FU9wen;

  input pwire [REG_WIDTH-1:0] FUreg4_reg;
  input pwire FU4wen_reg;

  input pwire [REG_WIDTH-1:0] FUreg5_reg;
  input pwire FU5wen_reg;

  input pwire [REG_WIDTH-1:0] FUreg6_reg;
  input pwire FU6wen_reg;

  input pwire [REG_WIDTH-1:0] FUreg4_reg2;
  input pwire FU4wen_reg2;

  input pwire [REG_WIDTH-1:0] FUreg5_reg2;
  input pwire FU5wen_reg2;

  input pwire [REG_WIDTH-1:0] FUreg6_reg2;
  input pwire FU6wen_reg2;

  input pwire [REG_WIDTH-1:0] FUreg7_reg;
  input pwire FU7wen_reg;

  input pwire [REG_WIDTH-1:0] FUreg8_reg;
  input pwire FU8wen_reg;

  input pwire [REG_WIDTH-1:0] FUreg9_reg;
  input pwire FU9wen_reg;

  input pwire [REG_WIDTH-1:0] FUreg7_reg2;
  input pwire FU7wen_reg2;

  input pwire [REG_WIDTH-1:0] FUreg8_reg2;
  input pwire FU8wen_reg2;

  input pwire [REG_WIDTH-1:0] FUreg9_reg2;
  input pwire FU9wen_reg2;

  input pwire newRsSelect0;
  input pwire [REG_WIDTH-1:0] newReg0;
  input pwire [FN_WIDTH-1:0] newFunit0;
  input pwire [10:0] newGazump0;
  input pwire newIsFP0,newIsV0;
  input pwire [1:0] newEQ0;

  input pwire newRsSelect1;
  input pwire [REG_WIDTH-1:0] newReg1;
  input pwire [FN_WIDTH-1:0] newFunit1;
  input pwire [10:0] newGazump1;
  input pwire newIsFP1,newIsV1;
  input pwire [1:0] newEQ1;

  input pwire newRsSelect2;
  input pwire [REG_WIDTH-1:0] newReg2;
  input pwire [FN_WIDTH-1:0] newFunit2;
  input pwire [10:0] newGazump2;
  input pwire newIsFP2,newIsV2;
  input pwire [1:0] newEQ2;
  
  output pwire [3:0] fuFwd;
  
  input pwire outRsSelect0;
  input pwire outDataEn0;
  output pwire [3:0] outFuFwd0;
  output pwire [3:0] outFuuFwd0;
  input pwire outRsSelect1;
  input pwire outDataEn1;
  output pwire [3:0] outFuFwd1;
  output pwire [3:0] outFuuFwd1;
  input pwire outRsSelect2;
  input pwire outDataEn2;
  output pwire [3:0] outFuFwd2;
  output pwire [3:0] outFuuFwd2;
  
  pwire [3:0] fuFwd_d;
// equals wires
  pwire [1:0] eq;

  pwire [1:0] eq_new;

  pwire [1:0] eq_reg;
//  pwire [1:0] eq_reg2;
//  pwire [1:0] eq_reg3;
//  pwire [1:0] eq_reg4;
//  pwire [1:0] eq_reg5;
  
  pwire [1:0] eq_mask;

  pwire [9:0] outEq0;

  pwire [REG_WIDTH-1:0] register_d;
  pwire [REG_WIDTH-1:0] register;

  pwire [FN_WIDTH-1:0] funit_d;
  pwire [FN_WIDTH-1:0] funit;
  pwire [18:0] funit0;

  pwire [3:0] fuuFwd;
  
  pwire [10:0] gazump;
  pwire [3:0] gzFwd;

  pwire [8:0] Treg0;
  pwire Twen0;
  pwire [8:0] Treg1;
  pwire Twen1;

  pwire [8:0] FUreg[21:0];
  pwire [21:0] FUwen;

  pwire isFP;
  pwire isFP_d;
  pwire isV;
  pwire isV_d;
  
//  pwire isDataF,isDataI,isDataV;
  pwire sel;

  assign sel=outRsSelect0&outDataEn0||outRsSelect1&outDataEn1||outRsSelect2&outDataEn2||buffree&~newRsSelect0&~newRsSelect1&~newRsSelect2;

  assign FUreg[0]=FUreg0;
  assign FUreg[1]=FUreg1;
  assign FUreg[2]=FUreg2;
  assign FUreg[3]=FUreg3;
  assign FUreg[4]=FUreg4;
  assign FUreg[5]=FUreg5;
  assign FUreg[6]=FUreg6;
  assign FUreg[7]=FUreg7;
  assign FUreg[8]=FUreg8;
  assign FUreg[9]=FUreg9;
  assign FUreg[10]=FUreg4_reg;
  assign FUreg[11]=FUreg5_reg;
  assign FUreg[12]=FUreg6_reg;
  assign FUreg[13]=FUreg4_reg2;
  assign FUreg[14]=FUreg5_reg2;
  assign FUreg[15]=FUreg6_reg2;
  assign FUreg[16]=FUreg7_reg;
  assign FUreg[17]=FUreg8_reg;
  assign FUreg[18]=FUreg9_reg;
  assign FUreg[19]=FUreg7_reg2;
  assign FUreg[20]=FUreg8_reg2;
  assign FUreg[21]=FUreg9_reg2;

  assign FUwen[0]=FU0wen;
  assign FUwen[1]=FU1wen;
  assign FUwen[2]=FU2wen;
  assign FUwen[3]=FU3wen;
  assign FUwen[4]=FU4wen;
  assign FUwen[5]=FU5wen;
  assign FUwen[6]=FU6wen;
  assign FUwen[7]=FU7wen;
  assign FUwen[8]=FU8wen;
  assign FUwen[9]=FU9wen;
  assign FUwen[10]=FU4wen_reg;
  assign FUwen[11]=FU5wen_reg;
  assign FUwen[12]=FU6wen_reg;
  assign FUwen[13]=FU4wen_reg2;
  assign FUwen[14]=FU5wen_reg2;
  assign FUwen[15]=FU6wen_reg2;
  assign FUwen[16]=FU7wen_reg;
  assign FUwen[17]=FU8wen_reg;
  assign FUwen[18]=FU9wen_reg;
  assign FUwen[19]=FU7wen_reg2;
  assign FUwen[20]=FU8wen_reg2;
  assign FUwen[21]=FU9wen_reg2;

//  assign funM=|funit_d[2:0];
//  assign funAdd=|funit_d[6:4];
//  assign funMul=|funit_d[9:7];

  assign funit0[3:0]=funit_d[3:0];
  assign funit0[6:4]=funit_d[6:4] & {3{~isFP_d & ~isV_d}};
  assign funit0[9:7]=funit_d[9:7] & {3{~isFP_d & ~isV_d}};
  assign funit0[15:10]=funit_d[9:4] & {6{isV_d}};
  assign funit0[21:16]=funit_d[9:4] & {6{isV_d}};
  
  assign gazump=(newRsSelect0 & ~stall) ? newGazump0 : 11'bz;
  assign gazump=(newRsSelect1 & ~stall) ? newGazump1 : 11'bz;
  assign gazump=(newRsSelect2 & ~stall) ? newGazump2 : 11'bz;
  assign gazump=(~newRsSelect0 & ~newRsSelect1 & ~newRsSelect2 || stall) ? 11'b10000000000 : 11'bz;

  assign isFP_d=(newRsSelect0 & ~stall) ? newIsFP0 : 1'bz;
  assign isFP_d=(newRsSelect1 & ~stall) ? newIsFP1 : 1'bz;
  assign isFP_d=(newRsSelect2 & ~stall) ? newIsFP2 : 1'bz;
  assign isFP_d=(~newRsSelect0 & ~newRsSelect1 & ~newRsSelect2 || stall) ? isFP : 1'bz;

  assign isV_d=(newRsSelect0 & ~stall) ? newIsV0 : 1'bz;
  assign isV_d=(newRsSelect1 & ~stall) ? newIsV1 : 1'bz;
  assign isV_d=(newRsSelect2 & ~stall) ? newIsV2 : 1'bz;
  assign isV_d=(~newRsSelect0 & ~newRsSelect1 & ~newRsSelect2 || stall) ? isV : 1'bz;
  
  assign eq[0]=(pwh#(32)::cmpEQ(register,Treg0)) & Twen0 & ~newRsSelect0 & ~newRsSelect1 & ~newRsSelect2 & eq_mask[0];
  assign eq[1]=(pwh#(32)::cmpEQ(register,Treg1)) & Twen1 & ~newRsSelect0 & ~newRsSelect1 & ~newRsSelect2 & eq_mask[1];

  assign eq_new=eq|({2{newRsSelect0&~stall}}&newEQ0)|({2{newRsSelect1&~stall}}&newEQ1)|
    ({2{newRsSelect2&~stall}}&newEQ2);

  assign isData=|eq_new;

  assign fuFwd_d=(eq_new[0] & funit_d[0]) ? 4'd0 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[1]) ? 4'd1 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[2]) ? 4'd2 : 4'bz;
  assign fuFwd_d=(eq_new[1] & funit_d[3]) ? 4'd3 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[4]) ? 4'd4 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[5]) ? 4'd5 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[6]) ? 4'd6 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[7]) ? 4'd7 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[8]) ? 4'd8 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[9]) ? 4'd9 : 4'bz;
  assign fuFwd_d=(eq_new[0]|(eq_new[1]&funit_d[3])&&~rst) ? 4'bz : 4'd15;

  assign gzFwd=gazump[0] ? 4'd0 : 4'bz;
  assign gzFwd=gazump[1] ? 4'd1 : 4'bz;
  assign gzFwd=gazump[2] ? 4'd2 : 4'bz;
  assign gzFwd=gazump[3] ? 4'd3 : 4'bz;
  assign gzFwd=gazump[4] ? 4'd4 : 4'bz;
  assign gzFwd=gazump[5] ? 4'd5 : 4'bz;
  assign gzFwd=gazump[6] ? 4'd6 : 4'bz;
  assign gzFwd=gazump[7] ? 4'd7 : 4'bz;
  assign gzFwd=gazump[8] ? 4'd8 : 4'bz;
  assign gzFwd=gazump[9] ? 4'd9 : 4'bz;
  assign gzFwd=gazump[10] ? 4'd15 : 4'bz;

  assign outEq={|outEq0[9:5],outEq0[9:5]|outEq0[4:0]};

  assign outFuFwd0=outRsSelect0 ? fuFwd : 'z;
  assign outFuFwd1=outRsSelect1 ? fuFwd : 'z;
  assign outFuFwd2=outRsSelect2 ? fuFwd : 'z;

  assign outFuuFwd0=outRsSelect0 ? fuuFwd : 'z;
  assign outFuuFwd1=outRsSelect1 ? fuuFwd : 'z;
  assign outFuuFwd2=outRsSelect2 ? fuuFwd : 'z;

  assign register_d=(newRsSelect0 & ~rst & ~stall) ? newReg0 : 'z;
  assign register_d=(newRsSelect1 & ~rst & ~stall) ? newReg1 : 'z;
  assign register_d=(newRsSelect2 & ~rst & ~stall) ? newReg2 : 'z;
  assign register_d=rst ? {REG_WIDTH{1'b1}} : 'z;
  assign register_d=(~newRsSelect0 & ~newRsSelect1 & ~newRsSelect2 & ~rst || stall &~rst) ? register : 'z;

  assign funit_d=(newRsSelect0 & ~rst & ~stall) ? newFunit0 : 'z;
  assign funit_d=(newRsSelect1 & ~rst & ~stall) ? newFunit1 : 'z;
  assign funit_d=(newRsSelect2 & ~rst & ~stall) ? newFunit2 : 'z;
  assign funit_d=rst ? 10'b1001 : 'z;
  assign funit_d=(~newRsSelect0 & ~newRsSelect1 & ~newRsSelect2 & ~rst || stall &~rst) ? funit : 'z;

  generate
    genvar n;
    for(n=0;n<=21;n=n+1) begin : treg_gen
	if (n!=3) assign Treg0=funit0[n] ? FUreg[n] : 9'bz;
	else assign Treg1=FUreg[3];
	if (n!=3) assign Twen0=funit0[n] ? FUwen[n] : 1'bz;
	else assign Twen1=FUwen[3] & funit[3];
    end
  endgenerate
  
  always @(posedge clk)
    begin
	  if (rst)
	    begin
		  fuFwd<=4'b0;
		  fuuFwd<=4'b0;
		  isFP<=1'b0;
		  isV<=1'b0;
		  outEq0<=10'b0;
		  eq_mask<=2'b0;
		  eq_reg<=2'b0;
	    end
          else
	    begin
	      if (newRsSelect0|newRsSelect1|newRsSelect2 && ~stall) begin
              eq_mask<=2'h3 & ~eq_new;
          end else begin
              eq_mask<=(eq_mask & ~eq_new) | {eq_reg[1]&~FU3Hit&funit[3], eq_reg[0]&~FU2Hit&funit[2] || 
		  eq_reg[0]&~FU1Hit&funit[1] || eq_reg[0]&~FU0Hit&funit[0]};
          end
		  fuFwd<=fuFwd_d;
		  fuuFwd<=gazump[10] ? fuFwd|{4{newRsSelect0|newRsSelect1|newRsSelect2}} : gzFwd;
		  isFP<=isFP_d;
		  isV<=isV_d;
		  eq_reg<=eq_new&(eq_mask|{2{newRsSelect0|newRsSelect1|newRsSelect2 && ~stall}})&{2{~sel}};
		  
		  outEq0[0]<=(eq_reg[0]&funit[0]||gazump[0])&FU0Hit&~sel;
		  outEq0[1]<=(eq_reg[0]&funit[1]||gazump[1])&FU1Hit&~sel;
		  outEq0[2]<=(eq_reg[0]&funit[2]||gazump[2])&FU2Hit&~sel;
		  outEq0[3]<=(eq_reg[1]&funit[3]||gazump[3])&FU3Hit&~sel;
		  outEq0[4]<=(eq_reg[0]&funit[4])|gazump[4]&&~sel;
		  outEq0[5]<=(eq_reg[0]&funit[5])|gazump[5]&&~sel;
		  outEq0[6]<=(eq_reg[0]&funit[6])|gazump[6]&&~sel;
		  outEq0[7]<=(eq_reg[0]&funit[7])|gazump[7]&&~sel;
		  outEq0[8]<=(eq_reg[0]&funit[8])|gazump[8]&&~sel;
		  outEq0[9]<=(eq_reg[0]&funit[9])|gazump[9]&&~sel;
		  
		end
	  register<=register_d;
	  funit<=funit_d;
    end
 
endmodule


module rs_wakeUp_logic_array(
  clk,rst,stall,
  isData,
  outEq,
  buffree,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  FUreg0,FU0wen,
  FUreg1,FU1wen,
  FUreg2,FU2wen,
  FUreg3,FU3wen,
  FUreg4,FU4wen,
  FUreg5,FU5wen,
  FUreg6,FU6wen,
  FUreg7,FU7wen,
  FUreg8,FU8wen,
  FUreg9,FU9wen,
  newRsSelect0,newReg0,newFunit0,newGazump0,newIsFP0,newIsV0,
  newRsSelect1,newReg1,newFunit1,newGazump1,newIsFP1,newIsV1,
  newRsSelect2,newReg2,newFunit2,newGazump2,newIsFP2,newIsV2,
  fuFwd,
  outRsSelect0,outDataEn0,outBank0,outFound0,outFuFwd0,outFuuFwd0,
  outRsSelect1,outDataEn1,outBank1,outFound1,outFuFwd1,outFuuFwd1,
  outRsSelect2,outDataEn2,outBank2,outFound2,outFuFwd2,outFuuFwd2
  );
  parameter DATA_WIDTH=`alu_width+1;
  localparam REG_WIDTH=`reg_addr_width;
  localparam BUF_COUNT=32;
  localparam FN_WIDTH=10;
   
  input pwire clk;
  input pwire rst;
  input pwire stall;
  output pwire [BUF_COUNT-1:0] isData;
  (* horizontal *) output pwire [BUF_COUNT*6-1:0] outEq;
  input pwire [BUF_COUNT-1:0] buffree;
  
//functional units inputs/outputs
  input pwire FU0Hit;
  input pwire FU1Hit;
  input pwire FU2Hit;
  input pwire FU3Hit;

  input pwire [REG_WIDTH-1:0] FUreg0;
  input pwire FU0wen;
  
  input pwire [REG_WIDTH-1:0] FUreg1;
  input pwire FU1wen;

  input pwire [REG_WIDTH-1:0] FUreg2;
  input pwire FU2wen;

  input pwire [REG_WIDTH-1:0] FUreg3;
  input pwire FU3wen;

  input pwire [REG_WIDTH-1:0] FUreg4;
  input pwire FU4wen;

  input pwire [REG_WIDTH-1:0] FUreg5;
  input pwire FU5wen;

  input pwire [REG_WIDTH-1:0] FUreg6;
  input pwire FU6wen;

  input pwire [REG_WIDTH-1:0] FUreg7;
  input pwire FU7wen;

  input pwire [REG_WIDTH-1:0] FUreg8;
  input pwire FU8wen;

  input pwire [REG_WIDTH-1:0] FUreg9;
  input pwire FU9wen;


  input pwire [BUF_COUNT-1:0] newRsSelect0;
  input pwire [REG_WIDTH-1:0] newReg0;
  input pwire [FN_WIDTH-1:0] newFunit0;
  input pwire [10:0] newGazump0;
  input pwire newIsFP0,newIsV0;

  input pwire [BUF_COUNT-1:0] newRsSelect1;
  input pwire [REG_WIDTH-1:0] newReg1;
  input pwire [FN_WIDTH-1:0] newFunit1;
  input pwire [10:0] newGazump1;
  input pwire newIsFP1,newIsV1;

  input pwire [BUF_COUNT-1:0] newRsSelect2;
  input pwire [REG_WIDTH-1:0] newReg2;
  input pwire [FN_WIDTH-1:0] newFunit2;
  input pwire [10:0] newGazump2;
  input pwire newIsFP2,newIsV2;
  
  output pwire [BUF_COUNT*4-1:0] fuFwd;
  
  input pwire [BUF_COUNT-1:0] outRsSelect0;
  input pwire outDataEn0;
  input pwire [3:0] outBank0;
  input pwire outFound0;
  output pwire [3:0] outFuFwd0;
  output pwire [3:0] outFuuFwd0;
  input pwire [BUF_COUNT-1:0] outRsSelect1;
  input pwire outDataEn1;
  input pwire [3:0] outBank1;
  input pwire outFound1;
  output pwire [3:0] outFuFwd1;
  output pwire [3:0] outFuuFwd1;
  input pwire [BUF_COUNT-1:0] outRsSelect2;
  input pwire outDataEn2;
  input pwire [3:0] outBank2;
  input pwire outFound2;
  output pwire [3:0] outFuFwd2;
  output pwire [3:0] outFuuFwd2;

  pwire [1:0] newEQ[2:0];
  pwire [8:0] register[2:0];
  pwire [9:0] funit[2:0];
  
  pwire [2:0][8:0] Treg0;
  pwire [2:0] Twen0;
  pwire [2:0][8:0] Treg1;
  pwire [2:0] Twen1;

  pwire [8:0] FUreg[21:0];
  pwire [21:0] FUwen;
  
  pwire [REG_WIDTH-1:0] FUreg4_reg;
  pwire FU4wen_reg;

  pwire [REG_WIDTH-1:0] FUreg5_reg;
  pwire FU5wen_reg;

  pwire [REG_WIDTH-1:0] FUreg6_reg;
  pwire FU6wen_reg;

  pwire [REG_WIDTH-1:0] FUreg7_reg;
  pwire FU7wen_reg;

  pwire [REG_WIDTH-1:0] FUreg8_reg;
  pwire FU8wen_reg;

  pwire [REG_WIDTH-1:0] FUreg9_reg;
  pwire FU9wen_reg;

  pwire [REG_WIDTH-1:0] FUreg4_reg2;
  pwire FU4wen_reg2;

  pwire [REG_WIDTH-1:0] FUreg5_reg2;
  pwire FU5wen_reg2;

  pwire [REG_WIDTH-1:0] FUreg6_reg2;
  pwire FU6wen_reg2;

  pwire [REG_WIDTH-1:0] FUreg7_reg2;
  pwire FU7wen_reg2;

  pwire [REG_WIDTH-1:0] FUreg8_reg2;
  pwire FU8wen_reg2;

  pwire [REG_WIDTH-1:0] FUreg9_reg2;
  pwire FU9wen_reg2;

  pwire [21:0] funit0[2:0];
  pwire [2:0] isFP;
  pwire [2:0] isV;

  assign register[0]=newReg0;
  assign register[1]=newReg1;
  assign register[2]=newReg2;

  assign funit[0]=newFunit0;
  assign funit[1]=newFunit1;
  assign funit[2]=newFunit2;

  assign isFP[0]=newIsFP0;
  assign isFP[1]=newIsFP1;
  assign isFP[2]=newIsFP2;
  
  assign isV[0]=newIsV0;
  assign isV[1]=newIsV1;
  assign isV[2]=newIsV2;
  
  assign FUreg[0]=FUreg0;
  assign FUreg[1]=FUreg1;
  assign FUreg[2]=FUreg2;
  assign FUreg[3]=FUreg3;
  assign FUreg[4]=FUreg4;
  assign FUreg[5]=FUreg5;
  assign FUreg[6]=FUreg6;
  assign FUreg[7]=FUreg7;
  assign FUreg[8]=FUreg8;
  assign FUreg[9]=FUreg9;
  assign FUreg[10]=FUreg4_reg;
  assign FUreg[11]=FUreg5_reg;
  assign FUreg[12]=FUreg6_reg;
  assign FUreg[13]=FUreg4_reg2;
  assign FUreg[14]=FUreg5_reg2;
  assign FUreg[15]=FUreg6_reg2;
  assign FUreg[16]=FUreg7_reg;
  assign FUreg[17]=FUreg8_reg;
  assign FUreg[18]=FUreg9_reg;
  assign FUreg[19]=FUreg7_reg2;
  assign FUreg[20]=FUreg8_reg2;
  assign FUreg[21]=FUreg9_reg2;

  assign FUwen[0]=FU0wen;
  assign FUwen[1]=FU1wen;
  assign FUwen[2]=FU2wen;
  assign FUwen[3]=FU3wen;
  assign FUwen[4]=FU4wen;
  assign FUwen[5]=FU5wen;
  assign FUwen[6]=FU6wen;
  assign FUwen[7]=FU7wen;
  assign FUwen[8]=FU8wen;
  assign FUwen[9]=FU9wen;
  assign FUwen[10]=FU4wen_reg;
  assign FUwen[11]=FU5wen_reg;
  assign FUwen[12]=FU6wen_reg;
  assign FUwen[13]=FU4wen_reg2;
  assign FUwen[14]=FU5wen_reg2;
  assign FUwen[15]=FU6wen_reg2;
  assign FUwen[16]=FU7wen_reg;
  assign FUwen[17]=FU8wen_reg;
  assign FUwen[18]=FU9wen_reg;
  assign FUwen[19]=FU7wen_reg2;
  assign FUwen[20]=FU8wen_reg2;
  assign FUwen[21]=FU9wen_reg2;
  
  generate
      genvar j,k,p,q;
      for (j=0;j<4;j=j+1) begin : banks_gen
          pwire [3:0] fuFwdk;
          pwire [3:0] fuuFwdk;
          
          pwire [3:0] outFuFwd0k;
          pwire [3:0] outFuuFwd0k;
          pwire [3:0] outFuFwd1k;
          pwire [3:0] outFuuFwd1k;
          pwire [3:0] outFuFwd2k;
          pwire [3:0] outFuuFwd2k;
          for (k=0;k<8;k=k+1) begin : bufs_gen
              rs_wakeUp_logic #(DATA_WIDTH) buf_mod(
              clk,rst,stall,
              isData[k+8*j],
              outEq[(k+8*j)*6+:6],
              buffree[k+8*j],
              FU0Hit,FU1Hit,FU2Hit,FU3Hit,
              FUreg0,FU0wen,
              FUreg1,FU1wen,
              FUreg2,FU2wen,
              FUreg3,FU3wen,
              FUreg4,FU4wen,
              FUreg5,FU5wen,
              FUreg6,FU6wen,
              FUreg7,FU7wen,
              FUreg8,FU8wen,
              FUreg9,FU9wen,
              FUreg4_reg,FU4wen_reg,
              FUreg5_reg,FU5wen_reg,
              FUreg6_reg,FU6wen_reg,
              FUreg4_reg2,FU4wen_reg2,
              FUreg5_reg2,FU5wen_reg2,
              FUreg6_reg2,FU6wen_reg2,
              FUreg7_reg,FU7wen_reg,
              FUreg8_reg,FU8wen_reg,
              FUreg9_reg,FU9wen_reg,
              FUreg7_reg2,FU7wen_reg2,
              FUreg8_reg2,FU8wen_reg2,
              FUreg9_reg2,FU9wen_reg2,
              newRsSelect0[k+8*j],newReg0,newFunit0,newGazump0,newIsFP0,newIsV0,newEQ[0],
              newRsSelect1[k+8*j],newReg1,newFunit1,newGazump1,newIsFP1,newIsV1,newEQ[1],
              newRsSelect2[k+8*j],newReg2,newFunit2,newGazump2,newIsFP2,newIsV2,newEQ[2],
              fuFwd[(k+8*j)*4+:4],
              outRsSelect0[k+8*j],outDataEn0,outFuFwd0k,outFuuFwd0k,
              outRsSelect1[k+8*j],outDataEn1,outFuFwd1k,outFuuFwd1k,
              outRsSelect2[k+8*j],outDataEn2,outFuFwd2k,outFuuFwd2k
              );
          end
          
          
          assign outFuFwd0=outBank0[j] ? outFuFwd0k : 4'bz;
          assign outFuFwd1=outBank1[j] ? outFuFwd1k : 4'bz;
          assign outFuFwd2=outBank2[j] ? outFuFwd2k : 4'bz;

          assign outFuuFwd0=outBank0[j] ? outFuuFwd0k : 4'bz;
          assign outFuuFwd1=outBank1[j] ? outFuuFwd1k : 4'bz;
          assign outFuuFwd2=outBank2[j] ? outFuuFwd2k : 4'bz;

          
          assign outFuFwd0k=outBank0[j] ? 4'bz : 4'hf;
          assign outFuFwd1k=outBank1[j] ? 4'bz : 4'hf;
          assign outFuFwd2k=outBank2[j] ? 4'bz : 4'hf;

          assign outFuuFwd0k=outBank0[j] ? 4'bz : 4'hf;
          assign outFuuFwd1k=outBank1[j] ? 4'bz : 4'hf;
          assign outFuuFwd2k=outBank2[j] ? 4'bz : 4'hf;
      end
      for(p=0;p<3;p=p+1) begin : newEQ_gen
          assign newEQ[p][0]=(register[p]==Treg0[p]) & Twen0[p];
          assign newEQ[p][1]=(register[p]==Treg1[p]) & Twen1[p];
        
	  assign funit0[p][3:0]=funit[p][3:0];
          assign funit0[p][6:4]=funit[p][6:4] & {3{~isFP[p]}};
          assign funit0[p][9:7]=funit[p][9:7] & {3{~isFP[p] & ~isV[p]}};
          assign funit0[p][15:10]=funit[p][9:4] & {6{isV[p]}};
          assign funit0[p][21:16]=funit[p][9:4] & {6{isFP[p]}};

	  for(q=0;q<22;q=q+1) begin : funit_gen
	      if (q!=3) assign Treg0[p]=funit0[p][q] ? FUreg[q] : 9'bz;
	      else assign Treg1[p]=FUreg[3];
	      if (q!=3) assign Twen0[p]=funit0[p][q] ? FUwen[q] : 1'bz;
	      else assign Twen1[p]=FUwen[3] & funit[p][3];
	  end
      end
  endgenerate

         
  assign outFuFwd0=outFound0 ? 4'bz : 4'hf;
  assign outFuFwd1=outFound1 ? 4'bz : 4'hf;
  assign outFuFwd2=outFound2 ? 4'bz : 4'hf;

  assign outFuuFwd0=outFound0 ? 4'bz : 4'hf;
  assign outFuuFwd1=outFound1 ? 4'bz : 4'hf;
  assign outFuuFwd2=outFound2 ? 4'bz : 4'hf;
 
  always @(posedge clk) begin
    if (rst) begin
	FUreg4_reg<=9'h1ff;
	FU4wen_reg<=1'b0;
	FUreg5_reg<=9'h1ff;
	FU5wen_reg<=1'b0;
	FUreg6_reg<=9'h1ff;
	FU6wen_reg<=1'b0;
	FUreg7_reg<=9'h1ff;
	FU7wen_reg<=1'b0;
	FUreg8_reg<=9'h1ff;
	FU8wen_reg<=1'b0;
	FUreg9_reg<=9'h1ff;
	FU9wen_reg<=1'b0;
	FUreg4_reg2<=9'h1ff;
	FU4wen_reg2<=1'b0;
	FUreg5_reg2<=9'h1ff;
	FU5wen_reg2<=1'b0;
	FUreg6_reg2<=9'h1ff;
	FU6wen_reg2<=1'b0;
	FUreg7_reg2<=9'h1ff;
	FU7wen_reg2<=1'b0;
	FUreg8_reg2<=9'h1ff;
	FU8wen_reg2<=1'b0;
	FUreg9_reg2<=9'h1ff;
	FU9wen_reg2<=1'b0;
	FUreg4_reg3<=9'h1ff;
    end else begin
	FUreg4_reg<=FUreg4;
	FU4wen_reg<=FU4wen;
	FUreg5_reg<=FUreg5;
	FU5wen_reg<=FU5wen;
	FUreg6_reg<=FUreg6;
	FU6wen_reg<=FU6wen;
	FUreg7_reg<=FUreg7;
	FU7wen_reg<=FU7wen;
	FUreg8_reg<=FUreg8;
	FU8wen_reg<=FU8wen;
	FUreg9_reg<=FUreg9;
	FU9wen_reg<=FU9wen;
	FUreg4_reg2<=FUreg4_reg;
	FU4wen_reg2<=FU4wen_reg;
	FUreg5_reg2<=FUreg5_reg;
	FU5wen_reg2<=FU5wen_reg;
	FUreg6_reg2<=FUreg6_reg;
	FU6wen_reg2<=FU6wen_reg;
	FUreg7_reg2<=FUreg7_reg;
	FU7wen_reg2<=FU7wen_reg;
	FUreg8_reg2<=FUreg8_reg;
	FU8wen_reg2<=FU8wen_reg;
	FUreg9_reg2<=FUreg9_reg;
	FU9wen_reg2<=FU9wen_reg;
	FU4wen_reg3<=FU4wen_reg2;
	FUreg4_reg3<=FUreg4_reg2;
	FU5wen_reg3<=FU5wen_reg2;
	FUreg5_reg3<=FUreg5_reg2;
	FU6wen_reg3<=FU6wen_reg2;
	FUreg6_reg3<=FUreg6_reg2;
	FU7wen_reg4<=FU7wen_reg2;
	FUreg8_reg4<=FUreg8_reg2;
	FU8wen_reg4<=FU8wen_reg2;
	FUreg9_reg4<=FUreg9_reg2;
	FU9wen_reg4<=FU9wen_reg2;
    end
  end 
endmodule

module rs_wakeUp_data(
  clk,rst,stall,
  newRsSelect0,newData0,
  newRsSelect1,newData1,
  newRsSelect2,newData2,
  outEq,
  FU0,FU1,FU2,FU3,
  FU4,FU5,FU6,
  FU7,FU8,FU9,
  outRsSelect0,outData0,
  outRsSelect1,outData1,
  outRsSelect2,outData2
  );

  parameter WIDTH=`alu_width;
  
  input pwire clk;
  input pwire rst;
  input pwire stall;
  (* horizontal *) input pwire newRsSelect0;
  input pwire [WIDTH-1:0] newData0;
  (* horizontal *) input pwire newRsSelect1;
  input pwire [WIDTH-1:0] newData1;
  input pwire newRsSelect2;
  input pwire [WIDTH-1:0] newData2;
  (* horizontal *) input pwire outRsSelect0;
  
  (* horizontal *) input pwire [5:0] outEq;
  input pwire [WIDTH-1:0] FU0;
  input pwire [WIDTH-1:0] FU1;
  input pwire [WIDTH-1:0] FU2;
  input pwire [WIDTH-1:0] FU3;
  input pwire [WIDTH-1:0] FU4;
  input pwire [WIDTH-1:0] FU5;
  input pwire [WIDTH-1:0] FU6;
  input pwire [WIDTH-1:0] FU7;
  input pwire [WIDTH-1:0] FU8;
  input pwire [WIDTH-1:0] FU9;
  
  output pwire [WIDTH-1:0] outData0;
  (* horizontal *) input pwire outRsSelect1;
  output pwire [WIDTH-1:0] outData1;
  (* horizontal *) input pwire outRsSelect2;
  output pwire [WIDTH-1:0] outData2;
  
  pwire data_en;
  pwire [WIDTH-1:0] data_d;
  pwire [WIDTH-1:0] data_d0;
  pwire [WIDTH-1:0] data_d1;
  pwire [WIDTH-1:0] data_q;


  assign data_en=|{outEq,newRsSelect0,newRsSelect1,newRsSelect2};

  assign data_d0=outEq[0] ? FU0 : 'z;
  assign data_d0=outEq[1] ? FU1 : 'z;
  assign data_d0=outEq[2] ? FU2 : 'z;
  assign data_d0=outEq[3] ? FU3 : 'z;
  assign data_d0=outEq[4] ? FU4 : 'z;
  assign data_d0=|outEq[4:0] ? 'z : {WIDTH{1'B0}};
  assign data_d1=outEq[0] ? FU5 : 'z;
  assign data_d1=outEq[1] ? FU6 : 'z;
  assign data_d1=outEq[2] ? FU7 : 'z;
  assign data_d1=outEq[3] ? FU8 : 'z;
  assign data_d1=outEq[4] ? FU9 : 'z;
  assign data_d1=|outEq[4:0] ? 'z : {WIDTH{1'B0}};
  assign data_d=(newRsSelect0 & ~rst & ~stall) ? newData0 : 'z;
  assign data_d=(newRsSelect1 & ~rst & ~stall) ? newData1 : 'z;
  assign data_d=(newRsSelect2 & ~rst & ~stall) ? newData2 : 'z;

  assign data_d=rst ? {WIDTH{1'b0}} : 'z;

  assign data_d=(data_en & ~(stall && newRsSelect0|newRsSelect1|newRsSelect2) || rst) ? 'z : data_q;
  assign data_d=(|outEq[4:0] && outEq[5]) ? data_d1 : 'z;
  assign data_d=(|outEq[4:0] && ~outEq[5]) ? data_d0 : 'z;
  assign outData0=outRsSelect0 ? data_q : 'z;
  assign outData1=outRsSelect1 ? data_q : 'z;
  assign outData2=outRsSelect2 ? data_q : 'z;

  always @(posedge clk)
    begin
      data_q<=data_d;
    end
    
endmodule

//insturct compiler not to delete the redundant outputs of
//rs_wakeUp_data_array
//route outputs with x1 pwire layers
module rs_wakeUp_data_array(
  clk,rst,stall,
  newRsSelect0,newData0,
  newRsSelect1,newData1,
  newRsSelect2,newData2,
  outEq,
  FU0,FU1,FU2,FU3,
  FU4,FU5,FU6,
  FU7,FU8,FU9,
  outRsSelect0,outBank0,outFound0,outData0,
  outRsSelect1,outBank1,outFound1,outData1,
  outRsSelect2,outBank2,outFound2,outData2
  );

  parameter WIDTH=`alu_width+1;
  localparam BUF_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire stall;
  input pwire [BUF_COUNT-1:0] newRsSelect0;
  input pwire [WIDTH-1:0] newData0;
  input pwire [BUF_COUNT-1:0] newRsSelect1;
  input pwire [WIDTH-1:0] newData1;
  input pwire [BUF_COUNT-1:0] newRsSelect2;
  input pwire [WIDTH-1:0] newData2;
  
  (* horizontal *) input pwire [6*BUF_COUNT-1:0] outEq;
  input pwire [WIDTH-1:0] FU0;
  input pwire [WIDTH-1:0] FU1;
  input pwire [WIDTH-1:0] FU2;
  input pwire [WIDTH-1:0] FU3;
  input pwire [WIDTH-1:0] FU4;
  input pwire [WIDTH-1:0] FU5;
  input pwire [WIDTH-1:0] FU6;
  input pwire [WIDTH-1:0] FU7;
  input pwire [WIDTH-1:0] FU8;
  input pwire [WIDTH-1:0] FU9;
  
  input pwire [BUF_COUNT-1:0] outRsSelect0;
  input pwire [3:0] outBank0;
  input pwire outFound0;
  output pwire [WIDTH-1:0] outData0;
  input pwire [BUF_COUNT-1:0] outRsSelect1;
  input pwire [3:0] outBank1;
  input pwire outFound1;
  output pwire [WIDTH-1:0] outData1;
  input pwire [BUF_COUNT-1:0] outRsSelect2;
  input pwire [3:0] outBank2;
  input pwire outFound2;
  output pwire [WIDTH-1:0] outData2;

  generate
      genvar j,k;
      for (j=0;j<4;j=j+1) begin : tile_gen
          pwire [WIDTH-1:0] outData0k;
          pwire [WIDTH-1:0] outData1k;
          pwire [WIDTH-1:0] outData2k;
          
          for (k=0;k<8;k=k+1) begin : buf_gen
              rs_wakeUp_data #(WIDTH) buf_mod(
              clk,rst,stall,
              newRsSelect0[k+8*j],newData0,
              newRsSelect1[k+8*j],newData1,
              newRsSelect2[k+8*j],newData2,
              outEq[(k+8*j)*6+:6],
              FU0,FU1,FU2,FU3,
              FU4,FU5,FU6,
              FU7,FU8,FU9,              
              outRsSelect0[k+8*j],outData0k,
              outRsSelect1[k+8*j],outData1k,
              outRsSelect2[k+8*j],outData2k
              );
          end
          assign outData0=outBank0[j] ? outData0k : 'z;
          assign outData1=outBank1[j] ? outData1k : 'z;
          assign outData2=outBank2[j] ? outData2k : 'z;

          assign outData0k=outBank0[j] ? 'z : {WIDTH{1'B0}};
          assign outData1k=outBank1[j] ? 'z : {WIDTH{1'B0}};
          assign outData2k=outBank2[j] ? 'z : {WIDTH{1'B0}};
      end
  endgenerate

  assign outData0=outFound0 ? 'z : {WIDTH{1'B0}};
  assign outData1=outFound1 ? 'z : {WIDTH{1'B0}};
  assign outData2=outFound2 ? 'z : {WIDTH{1'B0}};

  
endmodule

module rs_wakeUp_data3(
  clk,rst,stall,
  newRsSelect0,newDataA0,newDataB0,
  newRsSelect1,newDataA1,newDataB1,
  outEqA,outEqB,
  FU0,FU1,FU2,FU3,
  FU4,FU5,FU6,
  outRsSelect0,outDataA0,outDataB0
  );

  parameter WIDTH=`alu_width;
  
  input pwire clk;
  input pwire rst;
  input pwire stall;
  input pwire newRsSelect0;
  input pwire [WIDTH-1:0] newDataA0;
  input pwire [WIDTH-1:0] newDataB0;
  input pwire newRsSelect1;
  input pwire [WIDTH-1:0] newDataA1;
  input pwire [WIDTH-1:0] newDataB1;
  
  input pwire [4:0] outEqA;
  input pwire [4:0] outEqB;

  input pwire [WIDTH-1:0] FU0;
  input pwire [WIDTH-1:0] FU1;
  input pwire [WIDTH-1:0] FU2;
  input pwire [WIDTH-1:0] FU3;
  input pwire [WIDTH-1:0] FU4;
  input pwire [WIDTH-1:0] FU5;
  input pwire [WIDTH-1:0] FU6;
  
  output pwire [WIDTH-1:0] outDataA0;
  output pwire [WIDTH-1:0] outDataB0;
  input pwire outRsSelect0;

  pwire [1:0] data_en;
  pwire [1:0] [WIDTH-1:0] data_d;
  pwire [1:0] [WIDTH-1:0] data_d0;
  pwire [1:0] [WIDTH-1:0] data_d1;
  pwire [1:0] [WIDTH-1:0] data_q;


  assign data_en[0]=|{outEqA,newRsSelect0,newRsSelect1};

  assign data_d0[0]=outEqA[0] ? FU0 : 'z;
  assign data_d0[0]=outEqA[1] ? FU1 : 'z;
  assign data_d0[0]=outEqA[2] ? FU2 : 'z;
  assign data_d0[0]=outEqA[3] ? FU3 : 'z;
  assign data_d0[0]=|outEqA[3:0] ? 'z : {WIDTH{1'B0}};
  assign data_d1[0]=outEqA[0] ? FU4 : 'z;
  assign data_d1[0]=outEqA[1] ? FU5 : 'z;
  assign data_d1[0]=outEqA[2] ? FU6 : 'z;
  assign data_d1[0]=outEqA[3] ? '0 : 'z;
  assign data_d1[0]=|outEqA[4:0] ? 'z : {WIDTH{1'B0}};
  assign data_d[0]=(newRsSelect0 & ~rst & ~stall) ? newDataA0 : 'z;
  assign data_d[0]=(newRsSelect1 & ~rst & ~stall) ? newDataA1 : 'z;

  assign data_d[0]=rst ? {WIDTH{1'b0}} : 'z;

  assign data_d[0]=(data_en[0] & ~(stall && newRsSelect0|newRsSelect1) || rst) ? 'z : data_q[0];
  assign data_d[0]=(|outEqA[3:0] && outEqA[4]) ? data_d1[0] : 'z;
  assign data_d[0]=(|outEqA[3:0] && ~outEqA[4]) ? data_d0[0] : 'z;
  assign outDataA0=outRsSelect0 ? data_q[0] : 'z;

  assign data_en[1]=|{outEqB,newRsSelect0,newRsSelect1};

  assign data_d0[1]=outEqB[0] ? FU0 : 'z;
  assign data_d0[1]=outEqB[1] ? FU1 : 'z;
  assign data_d0[1]=outEqB[2] ? FU2 : 'z;
  assign data_d0[1]=outEqB[3] ? FU3 : 'z;
  assign data_d0[1]=|outEqB[3:0] ? 'z : {WIDTH{1'B0}};
  assign data_d1[1]=outEqB[0] ? FU4 : 'z;
  assign data_d1[1]=outEqB[1] ? FU5 : 'z;
  assign data_d1[1]=outEqB[2] ? FU6 : 'z;
  assign data_d1[1]=outEqB[3] ? '0 : 'z;
  assign data_d1[1]=|outEqB[4:0] ? 'z : {WIDTH{1'B0}};
  assign data_d[1]=(newRsSelect0 & ~rst & ~stall) ? newDataB0 : 'z;
  assign data_d[1]=(newRsSelect1 & ~rst & ~stall) ? newDataB1 : 'z;

  assign data_d[1]=rst ? {WIDTH{1'b0}} : 'z;

  assign data_d[1]=(data_en[1] & ~(stall && newRsSelect0|newRsSelect1) || rst) ? 'z : data_q[1];
  assign data_d[1]=(|outEqB[3:0] && outEqB[4]) ? data_d1[1] : 'z;
  assign data_d[1]=(|outEqB[3:0] && ~outEqB[4]) ? data_d0[1] : 'z;
  assign outDataB0=outRsSelect0 ? data_q[1] : 'z;

  always @(posedge clk)
    begin
      data_q[0]<=data_d[0];
      data_q[1]<=data_d[1];
    end
    
endmodule

//insturct compiler not to delete the redundant outputs of
//rs_wakeUp_data_array
//route outputs with x1 pwire layers
module rs_wakeUp_data4_array(
  clk,rst,stall,
  newRsSelect0,newData0,newDataA0,
  newRsSelect1,newData1,newDataB0,
  outEqA,outEqB,
  FU0,FU1,FU2,FU3,
  FU4,FU5,FU6,
  outRsSelect0,outBank0,outFound0,outDataA0,outDataB0
  );

  parameter WIDTH=`alu_width+1;
  localparam BUF_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire stall;
  input pwire [BUF_COUNT-1:0] newRsSelect0;
  input pwire [WIDTH-1:0] newDataA0;
  input pwire [WIDTH-1:0] newDataB0;
  input pwire [BUF_COUNT-1:0] newRsSelect1;
  input pwire [WIDTH-1:0] newDataA1;
  input pwire [WIDTH-1:0] newDataB1;
  
  input pwire [6*BUF_COUNT-1:0] outEqA;
  input pwire [6*BUF_COUNT-1:0] outEqB;

  input pwire [WIDTH-1:0] FU0;
  input pwire [WIDTH-1:0] FU1;
  input pwire [WIDTH-1:0] FU2;
  input pwire [WIDTH-1:0] FU3;
  input pwire [WIDTH-1:0] FU4;
  input pwire [WIDTH-1:0] FU5;
  input pwire [WIDTH-1:0] FU6;
  
  input pwire [BUF_COUNT-1:0] outRsSelect0;
  input pwire [3:0] outBank0;
  input pwire outFound0;
  output pwire [WIDTH-1:0] outDataA0;
  output pwire [WIDTH-1:0] outDataB0;

  generate
      genvar j,k;
      for (j=0;j<4;j=j+1) begin : tile_gen
          pwire [WIDTH-1:0] outData0k;
          pwire [WIDTH-1:0] outData1k;
          
          for (k=0;k<8;k=k+1) begin : buf_gen
              rs_wakeUp_data3 #(WIDTH) buf_mod(
              clk,rst,stall,
              newRsSelect0[k+8*j],newDataA0,newDataB0,
              newRsSelect1[k+8*j],newDataA1,newDataB1,
              outEq[(k+8*j)*5+:5],
              outEq[(k+8*j)*5+:5],
              FU0,FU1,FU2,FU3,
              FU4,FU5,FU6,
              outRsSelect0[k+8*j],outData0k,outData1k
              );
          end
          assign outDataA0=outBank0[j] ? outData0k : 'z;
          assign outDataB0=outBank0[j] ? outData1k : 'z;

          assign outData0k=outBank0[j] ? 'z : {WIDTH{1'B0}};
          assign outData1k=outBank0[j] ? 'z : {WIDTH{1'B0}};
      end
  endgenerate

  assign outDataA0=outFound0 ? 'z : {WIDTH{1'B0}};
  assign outDataB0=outFound1 ? 'z : {WIDTH{1'B0}};

  
endmodule


module rs_wakeUpS_logic(
  clk,rst,stall,
  isData,
  outEq,
  buffree,
  FUreg4,FU4wen,
  FUreg5,FU5wen,
  FUreg6,FU6wen,
  FUreg7,FU7wen,
  FUreg8,FU8wen,
  FUreg9,FU9wen,
  FUreg4_reg4,FU4wen_reg4,
  FUreg5_reg4,FU5wen_reg4,
  FUreg6_reg4,FU6wen_reg4,
  newRsSelect1,newReg1,newFunit1,newGazump1,newIsFP1,newEQ1,
  newRsSelect2,newReg2,newFunit2,newGazump2,newIsFP2,newEQ2,
  fuFwd,
  outRsSelect1,outDataEn1,outFuFwd1,outFuuFwd1,
  outRsSelect2,outDataEn2,outFuFwd2,outFuuFwd2
  );
  parameter DATA_WIDTH=`alu_width+1;
  localparam REG_WIDTH=`reg_addr_width;
  localparam FN_WIDTH=10;

  input pwire clk;
  input pwire rst;
  input pwire stall;
  output pwire isData;
  output pwire [5:0] outEq;

  input pwire buffree;

  input pwire [REG_WIDTH-1:0] FUreg4;
  input pwire FU4wen;

  input pwire [REG_WIDTH-1:0] FUreg5;
  input pwire FU5wen;

  input pwire [REG_WIDTH-1:0] FUreg6;
  input pwire FU6wen;

  input pwire [REG_WIDTH-1:0] FUreg7;
  input pwire FU7wen;

  input pwire [REG_WIDTH-1:0] FUreg8;
  input pwire FU8wen;

  input pwire [REG_WIDTH-1:0] FUreg9;
  input pwire FU9wen;

  input pwire [REG_WIDTH-1:0] FUreg4_reg4;
  input pwire FU4wen_reg4;

  input pwire [REG_WIDTH-1:0] FUreg5_reg4;
  input pwire FU5wen_reg4;

  input pwire [REG_WIDTH-1:0] FUreg6_reg4;
  input pwire FU6wen_reg4;



  input pwire newRsSelect1;
  input pwire [REG_WIDTH-1:0] newReg1;
  input pwire [FN_WIDTH-1:0] newFunit1;
  input pwire [10:0] newGazump1;
  input pwire newIsFP1;
  input pwire [1:0] newEQ1;

  input pwire newRsSelect2;
  input pwire [REG_WIDTH-1:0] newReg2;
  input pwire [FN_WIDTH-1:0] newFunit2;
  input pwire [10:0] newGazump2;
  input pwire newIsFP2;
  input pwire [1:0] newEQ2;
  
  output pwire [3:0] fuFwd;
  
  input pwire outRsSelect1;
  input pwire outDataEn1;
  output pwire [3:0] outFuFwd1;
  output pwire [3:0] outFuuFwd1;
  input pwire outRsSelect2;
  input pwire outDataEn2;
  output pwire [3:0] outFuFwd2;
  output pwire [3:0] outFuuFwd2;
  
  pwire [3:0] fuFwd_d;
// equals wires
  pwire [1:0] eq;
  pwire [1:0] eq_new;


  pwire [1:0] eq_reg;

  pwire [1:0] eq_mask;
   
  pwire [REG_WIDTH-1:0] register_d;
  pwire [REG_WIDTH-1:0] register;

  pwire [FN_WIDTH-1:0] funit_d;
  pwire [FN_WIDTH-1:0] funit;

  pwire [3:0] fuuFwd;
  
  pwire [10:0] gazump;
  pwire [3:0] gzFwd;
  
  pwire [8:0] Treg0;
  pwire Twen0;
  pwire [8:0] Treg1;
  pwire Twen1;

  pwire [8:0] FUreg[9:0];
  pwire [9:0] FUwen;

  pwire isFP;
  pwire isFP_d;
  
  pwire isDataF,isDataI;

  pwire sel;

  pwire funM,funAdd,funMul;
  
  pwire [9:1] outEq0;
  
  assign sel=outRsSelect1&outDataEn1||outRsSelect2&outDataEn2||buffree&~newRsSelect1&~newRsSelect2;

  assign FUreg[3]=9'b0;
  assign FUreg[0]=FUreg4_reg4;
  assign FUreg[1]=FUreg5_reg4;
  assign FUreg[2]=FUreg6_reg4;
  assign FUreg[4]=FUreg4;
  assign FUreg[5]=FUreg5;
  assign FUreg[6]=FUreg6;
  assign FUreg[7]=FUreg7;
  assign FUreg[8]=FUreg8;
  assign FUreg[9]=FUreg9;

  assign FUwen[3]=1'b0;
  assign FUwen[0]=FU4wen_reg4;
  assign FUwen[1]=FU5wen_reg4;
  assign FUwen[2]=FU6wen_reg4;
  assign FUwen[4]=FU4wen;
  assign FUwen[5]=FU5wen;
  assign FUwen[6]=FU6wen;
  assign FUwen[7]=FU7wen;
  assign FUwen[8]=FU8wen;
  assign FUwen[9]=FU9wen;

  assign funM=|funit_d[2:0];
  assign funAdd=|funit_d[6:4];
  assign funMul=|funit_d[9:7];
  
  assign gazump=(newRsSelect1 & ~stall) ? newGazump1 : 11'bz;
  assign gazump=(newRsSelect2  & ~stall) ? newGazump2 : 11'bz;
  assign gazump=(~newRsSelect1 & ~newRsSelect2 || stall) ? 11'b10000000000 : 11'bz;

  assign isFP_d=(newRsSelect1 & ~stall) ? newIsFP1 : 1'bz;
  assign isFP_d=(newRsSelect2 & ~stall) ? newIsFP2 : 1'bz;
  assign isFP_d=(~newRsSelect1 & ~newRsSelect2 || stall) ? isFP : 1'bz;

  assign eq[0]=(pwh#(32)::cmpEQ(register,Treg0)) & Twen0 & ~newRsSelect1 & ~newRsSelect2 &eq_mask[0];
  assign eq[1]=(pwh#(32)::cmpEQ(register,Treg1)) & Twen1 & ~newRsSelect1 & ~newRsSelect2 &eq_mask[1];

  assign eq_new=eq|({2{newRsSelect1&~stall}}&newEQ1)|({2{newRsSelect2&~stall}}&newEQ2);

  assign isDataI=|eq_new;
  assign isData=isDataI;

  assign fuFwd_d=(eq_new[0] & funit_d[0]) ? 4'd0 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[1]) ? 4'd1 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[2]) ? 4'd2 : 4'bz;
 // assign fuFwd_d=(eq_new[1] & funit[3]) ? 4'd3 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[4]) ? 4'd4 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[5]) ? 4'd5 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[6]) ? 4'd6 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[7]) ? 4'd7 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[8]) ? 4'd8 : 4'bz;
  assign fuFwd_d=(eq_new[0] & funit_d[9]) ? 4'd9 : 4'bz;
  assign fuFwd_d=(eq_new[0]&~rst) ? 4'bz : 4'd15;

  assign gzFwd=gazump[0] ? 4'd0 : 4'bz;
  assign gzFwd=gazump[1] ? 4'd1 : 4'bz;
  assign gzFwd=gazump[2] ? 4'd2 : 4'bz;
  assign gzFwd=gazump[3] ? 4'd3 : 4'bz;
  assign gzFwd=gazump[4] ? 4'd4 : 4'bz;
  assign gzFwd=gazump[5] ? 4'd5 : 4'bz;
  assign gzFwd=gazump[6] ? 4'd6 : 4'bz;
  assign gzFwd=gazump[7] ? 4'd7 : 4'bz;
  assign gzFwd=gazump[8] ? 4'd8 : 4'bz;
  assign gzFwd=gazump[9] ? 4'd9 : 4'bz;
  assign gzFwd=gazump[10] ? 4'd15 : 4'bz;

  assign outEq={|outEq0[9:5],outEq0[9:5]|{outEq0[4:1],1'b0}};

  assign outFuFwd1=outRsSelect1 ? fuFwd : 'z;
  assign outFuFwd2=outRsSelect2 ? fuFwd : 'z;

  assign outFuuFwd1=outRsSelect1 ? fuuFwd : 'z;
  assign outFuuFwd2=outRsSelect2 ? fuuFwd : 'z;

  assign register_d=(newRsSelect1 & ~rst & ~stall) ? newReg1 : 'z;
  assign register_d=(newRsSelect2 & ~rst & ~stall) ? newReg2 : 'z;
  assign register_d=rst ? {REG_WIDTH{1'b1}} : 'z;
  assign register_d=(~newRsSelect1 & ~newRsSelect2 & ~rst || stall &~rst) ? register : 'z;

  assign funit_d=(newRsSelect1 & ~rst & ~stall) ? newFunit1 : 'z;
  assign funit_d=(newRsSelect2 & ~rst & ~stall) ? newFunit2 : 'z;
  assign funit_d=rst ? 10'b1 : 'z;
  assign funit_d=(~newRsSelect1 & ~newRsSelect2 & ~rst || stall &~rst) ? funit : 'z;
  
  generate
    genvar n;
    for(n=0;n<10;n=n+1) begin : treg_gen
	if (n!=3) assign Treg0=funit[n] ? FUreg[n] : 9'bz;
	else assign Treg1=FUreg[3];
	if (n!=3) assign Twen0=funit[n] ? FUwen[n] : 1'bz;
	else assign Twen1=FUwen[3] & funit[3];
    end
  endgenerate
  
  always @(posedge clk)
    begin
//      data_q<=data_d;
       if (rst) begin
		  fuFwd<=4'b0;
		  fuuFwd<=4'b0;
		  isFP<=1'b0;
		  eq_reg<=2'b0;
		  outEq0<=9'b0;
		  eq_mask<=2'b0;
       end else begin
          if (newRsSelect1|newRsSelect2 && ~stall) begin
              eq_mask<=2'h3 & ~eq_new;
          end else begin
              eq_mask<=eq_mask & ~eq_new;
          end
	  fuFwd<=fuFwd_d;
	  fuuFwd<=gazump[10] ? fuFwd|{4{newRsSelect1|newRsSelect2}} : gzFwd;
	  isFP<=isFP_d;
	  eq_reg<=eq_new&(eq_mask|{2{newRsSelect1|newRsSelect2 & ~stall}})&{2{~sel}};
		  
	  outEq0[4]<=(~isFP & eq_reg[0]&funit[4])|gazump[0]&&~sel;
          outEq0[5]<=(~isFP & eq_reg[0]&funit[5])|gazump[1]&&~sel;
          outEq0[6]<=(~isFP & eq_reg[0]&funit[6])|gazump[2]&&~sel;
	  outEq0[1]<=(isFP & eq_reg[0]&funit[0])|gazump[6]&&~sel;
	  outEq0[2]<=(isFP & eq_reg[0]&funit[1])|gazump[7]&&~sel;
	  outEq0[3]<=(isFP & eq_reg[0]&funit[2])|gazump[8]&&~sel;
	  outEq0[7]<=(~isFP & eq_reg[0]&funit[7])|gazump[3]&&~sel;
	  outEq0[8]<=(~isFP & eq_reg[0]&funit[8])|gazump[4]&&~sel;
	  outEq0[9]<=(~isFP & eq_reg[0]&funit[9])|gazump[5]&&~sel;
       end
       register<=register_d;
       funit<=funit_d;
    end
 
endmodule


module rs_wakeUpS_logic_array(
  clk,rst,stall,
  isData,
  outEq,
  buffree,
  FUreg0,FU0wen,
  FUreg1,FU1wen,
  FUreg2,FU2wen,
  FUreg3,FU3wen,
  FUreg4,FU4wen,
  FUreg5,FU5wen,
  FU6wen,FU7wen,FU8wen,
  newRsSelect1,newReg1,newFunit1,newGazump1,newIsFP1,
  newRsSelect2,newReg2,newFunit2,newGazump2,newIsFP2,
  fuFwd,
  outRsSelect1,outDataEn1,outBank1,outFound1,outFuFwd1,outFuuFwd1,
  outRsSelect2,outDataEn2,outBank2,outFound2,outFuFwd2,outFuuFwd2
  );
  parameter DATA_WIDTH=`alu_width+1;
  localparam REG_WIDTH=`reg_addr_width;
  localparam BUF_COUNT=32;
  localparam FN_WIDTH=10;
  
  input pwire clk;
  input pwire rst;
  input pwire stall;
  output pwire [BUF_COUNT-1:0] isData;
  output pwire [BUF_COUNT*6-1:0] outEq;
  
  input pwire [BUF_COUNT-1:0] buffree;
  
//functional units inputs/outputs

  input pwire [REG_WIDTH-1:0] FUreg0;
  input pwire FU0wen;
  
  input pwire [REG_WIDTH-1:0] FUreg1;
  input pwire FU1wen;

  input pwire [REG_WIDTH-1:0] FUreg2;
  input pwire FU2wen;

  input pwire [REG_WIDTH-1:0] FUreg3;
  input pwire FU3wen;

  input pwire [REG_WIDTH-1:0] FUreg4;
  input pwire FU4wen;

  input pwire [REG_WIDTH-1:0] FUreg5;
  input pwire FU5wen;

  input pwire FU6wen;
  input pwire FU7wen;
  input pwire FU8wen;



  input pwire [BUF_COUNT-1:0] newRsSelect1;
  input pwire [REG_WIDTH-1:0] newReg1;
  input pwire [FN_WIDTH-1:0] newFunit1;
  input pwire [10:0] newGazump1;
  input pwire newIsFP1;

  input pwire [BUF_COUNT-1:0] newRsSelect2;
  input pwire [REG_WIDTH-1:0] newReg2;
  input pwire [FN_WIDTH-1:0] newFunit2;
  input pwire [10:0] newGazump2;
  input pwire newIsFP2;
  
  output pwire [BUF_COUNT*4-1:0] fuFwd;
  
  input pwire [BUF_COUNT-1:0] outRsSelect1;
  input pwire outDataEn1;
  input pwire [3:0] outBank1;
  input pwire outFound1;
  output pwire [3:0] outFuFwd1;
  output pwire [3:0] outFuuFwd1;
  input pwire [BUF_COUNT-1:0] outRsSelect2;
  input pwire outDataEn2;
  input pwire [3:0] outBank2;
  input pwire outFound2;
  output pwire [3:0] outFuFwd2;
  output pwire [3:0] outFuuFwd2;

  pwire [1:0] newEQ[2:1];
  pwire [8:0] register[2:1];
  pwire [9:0] funit[2:1];

  pwire [2:1][8:0] Treg0;
  pwire [2:1] Twen0;
  pwire [2:1][8:0] Treg1;
  pwire [2:1] Twen1;

  pwire [8:0] FUreg[9:0];
  pwire [9:0] FUwen;
  
  
  pwire [REG_WIDTH-1:0] FUreg0_reg;
  pwire FU0wen_reg;
  pwire [REG_WIDTH-1:0] FUreg1_reg;
  pwire FU1wen_reg;
  pwire [REG_WIDTH-1:0] FUreg2_reg;
  pwire FU2wen_reg;

  pwire [REG_WIDTH-1:0] FUreg3_reg;
  pwire FU3wen_reg;
  pwire [REG_WIDTH-1:0] FUreg4_reg;
  pwire FU4wen_reg;
  pwire [REG_WIDTH-1:0] FUreg5_reg;
  pwire FU5wen_reg;

  pwire [REG_WIDTH-1:0] FUreg0_reg2;
  pwire FU0wen_reg2;
  pwire [REG_WIDTH-1:0] FUreg1_reg2;
  pwire FU1wen_reg2;
  pwire [REG_WIDTH-1:0] FUreg2_reg2;
  pwire FU2wen_reg2;

  pwire [REG_WIDTH-1:0] FUreg0_reg3;
  pwire FU0wen_reg3;
  pwire [REG_WIDTH-1:0] FUreg1_reg3;
  pwire FU1wen_reg3;
  pwire [REG_WIDTH-1:0] FUreg2_reg3;
  pwire FU2wen_reg3;

  pwire [REG_WIDTH-1:0] FUreg0_reg4;
  pwire FU0wen_reg4;
  pwire [REG_WIDTH-1:0] FUreg1_reg4;
  pwire FU1wen_reg4;
  pwire [REG_WIDTH-1:0] FUreg2_reg4;
  pwire FU2wen_reg4;

  pwire FU6wen_reg;
  pwire FU7wen_reg;
  pwire FU8wen_reg;

  assign register[1]=newReg1;
  assign register[2]=newReg2;

  assign funit[1]=newFunit1;
  assign funit[2]=newFunit2;

  assign FUreg[3]=9'b0;
  assign FUreg[0]=FUreg0_reg3;
  assign FUreg[1]=FUreg1_reg3;
  assign FUreg[2]=FUreg2_reg3;
  assign FUreg[4]=FUreg0;
  assign FUreg[5]=FUreg1;
  assign FUreg[6]=FUreg2;
  assign FUreg[7]=FUreg3;
  assign FUreg[8]=FUreg4;
  assign FUreg[9]=FUreg5;

  assign FUwen[3]=1'b0;
  assign FUwen[0]=FU0wen_reg3;
  assign FUwen[1]=FU1wen_reg3;
  assign FUwen[2]=FU2wen_reg3;
  assign FUwen[4]=FU0wen;
  assign FUwen[5]=FU1wen;
  assign FUwen[6]=FU2wen;
  assign FUwen[7]=FU3wen;
  assign FUwen[8]=FU4wen;
  assign FUwen[9]=FU5wen;
  generate
      genvar j,k,p,q;
      for (j=0;j<4;j=j+1) begin : banks_gen
          pwire [3:0] fuFwdk;
          pwire [3:0] fuuFwdk;
          
          pwire [3:0] outFuFwd0k;
          pwire [3:0] outFuuFwd0k;
          pwire [3:0] outFuFwd1k;
          pwire [3:0] outFuuFwd1k;
          pwire [3:0] outFuFwd2k;
          pwire [3:0] outFuuFwd2k;
          
          for (k=0;k<8;k=k+1) begin : bufs_gen
              rs_wakeUpS_logic #(DATA_WIDTH) buf_mod(
              clk,rst,stall,
              isData[k+8*j],
              outEq[(k+8*j)*6+:6],
              buffree[k+8*j],
              FUreg0,FU0wen,
              FUreg1,FU1wen,
              FUreg2,FU2wen,
              FUreg3,FU3wen,
              FUreg4,FU4wen,
              FUreg5,FU5wen,
              FUreg0_reg3,FU0wen_reg3,
              FUreg1_reg3,FU1wen_reg3,
              FUreg2_reg3,FU2wen_reg3,
              newRsSelect1[k+8*j],newReg1,newFunit1,newGazump1,newIsFP1,newEQ[1],
              newRsSelect2[k+8*j],newReg2,newFunit2,newGazump2,newIsFP2,newEQ[2],
              fuFwd[(k+8*j)*4+:4],
              outRsSelect1[k+8*j],outDataEn1,outFuFwd1k,outFuuFwd1k,
              outRsSelect2[k+8*j],outDataEn2,outFuFwd2k,outFuuFwd2k
              );
          end
          
          
          assign outFuFwd1=outBank1[j] ? outFuFwd1k : 4'bz;
          assign outFuFwd2=outBank2[j] ? outFuFwd2k : 4'bz;

          assign outFuuFwd1=outBank1[j] ? outFuuFwd1k : 4'bz;
          assign outFuuFwd2=outBank2[j] ? outFuuFwd2k : 4'bz;

          
          assign outFuFwd1k=outBank1[j] ? 4'bz : 4'hf;
          assign outFuFwd2k=outBank2[j] ? 4'bz : 4'hf;

          assign outFuuFwd1k=outBank1[j] ? 4'bz : 4'hf;
          assign outFuuFwd2k=outBank2[j] ? 4'bz : 4'hf;
      end
      for(p=1;p<3;p=p+1) begin : newEQ_gen
          assign newEQ[p][0]=(register[p]==Treg0[p]) & Twen0[p];
          assign newEQ[p][1]=(register[p]==Treg1[p]) & Twen1[p];
	  for(q=0;q<10;q=q+1) begin : funit_gen
	      if (q!=3) assign Treg0[p]=funit[p][q] ? FUreg[q] : 9'bz;
	      else assign Treg1[p]=FUreg[3];
	      if (q!=3) assign Twen0[p]=funit[p][q] ? FUwen[q] : 1'bz;
	      else assign Twen1[p]=FUwen[3] & funit[p][3];
	  end
      end
  endgenerate

         
  assign outFuFwd1=outFound1 ? 4'bz : 4'hf;
  assign outFuFwd2=outFound2 ? 4'bz : 4'hf;

  assign outFuuFwd1=outFound1 ? 4'bz : 4'hf;
  assign outFuuFwd2=outFound2 ? 4'bz : 4'hf;
 
  always @(posedge clk) begin
    FUreg0_reg<=FUreg0;
    FU0wen_reg<=FU0wen;
    FUreg1_reg<=FUreg1;
    FU1wen_reg<=FU1wen;
    FUreg2_reg<=FUreg2;
    FU2wen_reg<=FU2wen;
    FUreg3_reg<=FUreg3;
    FU3wen_reg<=FU3wen;
    FUreg4_reg<=FUreg4;
    FU4wen_reg<=FU4wen;
    FUreg5_reg<=FUreg5;
    FU5wen_reg<=FU5wen;
    FU6wen_reg<=FU6wen;
    FU7wen_reg<=FU7wen;
    FU8wen_reg<=FU8wen;
    FUreg0_reg2<=FUreg0_reg;
    FU0wen_reg2<=FU6wen_reg;
    FUreg1_reg2<=FUreg1_reg;
    FU1wen_reg2<=FU7wen_reg;
    FUreg2_reg2<=FUreg2_reg;
    FU2wen_reg2<=FU8wen_reg;
    FUreg0_reg3<=FUreg0_reg2;
    FU0wen_reg3<=FU0wen_reg2;
    FUreg1_reg3<=FUreg1_reg2;
    FU1wen_reg3<=FU1wen_reg2;
    FUreg2_reg3<=FUreg2_reg2;
    FU2wen_reg3<=FU2wen_reg2;
    FUreg0_reg4<=FUreg0_reg3;
    FU0wen_reg4<=FU0wen_reg3;
    FUreg1_reg4<=FUreg1_reg3;
    FU1wen_reg4<=FU1wen_reg3;
    FUreg2_reg4<=FUreg2_reg3;
    FU2wen_reg4<=FU2wen_reg3;
  end 
endmodule

module rs_nonWakeUp_DFF(
  clk,rst,stall,
  newRsSelect0,newData0,
  newRsSelect1,newData1,
  newRsSelect2,newData2,
  
  outRsSelect0,outData0,
  outRsSelect1,outData1,
  outRsSelect2,outData2
  );

  parameter WIDTH=`alu_width;
  
  input pwire clk;
  input pwire rst;
  input pwire stall;
  (* horizontal *) input pwire newRsSelect0;
  input pwire [WIDTH-1:0] newData0;
  (* horizontal *) input pwire newRsSelect1;
  input pwire [WIDTH-1:0] newData1;
  (* horizontal *) input pwire newRsSelect2;
  input pwire [WIDTH-1:0] newData2;
  (* horizontal *) input pwire outRsSelect0;
  output pwire [WIDTH-1:0] outData0;
  (* horizontal *) input pwire outRsSelect1;
  output pwire [WIDTH-1:0] outData1;
  (* horizontal *) input pwire outRsSelect2;
  output pwire [WIDTH-1:0] outData2;
  

  pwire data_en;
  pwire [WIDTH-1:0] data_d;
  pwire [WIDTH-1:0] data_q;


  assign data_en=|{newRsSelect0,newRsSelect1,newRsSelect2,rst};

  assign data_d=(newRsSelect0 & ~rst & ~stall) ? newData0 : 'z;
  assign data_d=(newRsSelect1 & ~rst & ~stall) ? newData1 : 'z;
  assign data_d=(newRsSelect2 & ~rst & ~stall) ? newData2 : 'z;

  assign data_d=rst ? {WIDTH{1'b0}} : 'z;

  assign data_d=(data_en & ~stall) ? 'z : data_q;
  
  assign outData0=(outRsSelect0) ? data_q : 'z;
  assign outData1=(outRsSelect1) ? data_q : 'z;
  assign outData2=(outRsSelect2) ? data_q : 'z;

  always @(posedge clk)
    begin
      data_q<=data_d;
    end
    
endmodule


module rs_nonWakeUp_array(
  clk,rst,stall,
  newRsSelect0,newData0,
  newRsSelect1,newData1,
  newRsSelect2,newData2,
  
  outRsSelect0,outBank0,outFound0,outData0,
  outRsSelect1,outBank1,outFound1,outData1,
  outRsSelect2,outBank2,outFound2,outData2
  );

  parameter WIDTH=32;
  localparam BUF_COUNT=32;
  
  input pwire clk;
  input pwire rst;
  input pwire stall;
  input pwire [BUF_COUNT-1:0] newRsSelect0;
  input pwire [WIDTH-1:0] newData0;
  input pwire [BUF_COUNT-1:0] newRsSelect1;
  input pwire [WIDTH-1:0] newData1;
  input pwire [BUF_COUNT-1:0] newRsSelect2;
  input pwire [WIDTH-1:0] newData2;
  input pwire [BUF_COUNT-1:0] outRsSelect0;
  input pwire [3:0] outBank0;
  input pwire outFound0;
  output pwire [WIDTH-1:0] outData0;
  input pwire [BUF_COUNT-1:0] outRsSelect1;
  input pwire [3:0] outBank1;
  input pwire outFound1;
  output pwire [WIDTH-1:0] outData1;
  input pwire [BUF_COUNT-1:0] outRsSelect2;
  input pwire [3:0] outBank2;
  input pwire outFound2;
  output pwire [WIDTH-1:0] outData2;
  
  generate
      genvar j,k;
      for (j=0;j<4;j=j+1) begin : tile_gen
          pwire [WIDTH-1:0] outData0k;
          pwire [WIDTH-1:0] outData1k;
          pwire [WIDTH-1:0] outData2k;
          
          for (k=0;k<8;k=k+1) begin : buf_gen
              rs_nonWakeUp_DFF #(WIDTH) buf_mod(
              clk,rst,stall,
              newRsSelect0[k+8*j],newData0,
              newRsSelect1[k+8*j],newData1,
              newRsSelect2[k+8*j],newData2,
              
              outRsSelect0[k+8*j],outData0k,
              outRsSelect1[k+8*j],outData1k,
              outRsSelect2[k+8*j],outData2k
              );
          end
          assign outData0=outBank0[j] ? outData0k : 'z;
          assign outData1=outBank1[j] ? outData1k : 'z;
          assign outData2=outBank2[j] ? outData2k : 'z;

          assign outData0k=outBank0[j] ? 'z : {WIDTH{1'B0}};
          assign outData1k=outBank1[j] ? 'z : {WIDTH{1'B0}};
          assign outData2k=outBank2[j] ? 'z : {WIDTH{1'B0}};
      end
  endgenerate

  assign outData0=outFound0 ? 'z : {WIDTH{1'B0}};
  assign outData1=outFound1 ? 'z : {WIDTH{1'B0}};
  assign outData2=outFound2 ? 'z : {WIDTH{1'B0}};
  
endmodule

module rs_nonWakeUp_datad_DFF(
  clk,rst,stall,
  data_q,
  data_d,
  newRsSelect0,newData0,
  newRsSelect1,newData1,
  newRsSelect2,newData2
  );

  parameter WIDTH=32;
  
  input pwire clk;
  input pwire rst;
  input pwire stall;
  output pwire [WIDTH-1:0] data_q;
  output pwire [WIDTH-1:0] data_d;
  (* horizontal *) input pwire newRsSelect0;
  input pwire [WIDTH-1:0] newData0;
  (* horizontal *) input pwire newRsSelect1;
  input pwire [WIDTH-1:0] newData1;
  (* horizontal *) input pwire newRsSelect2;
  input pwire [WIDTH-1:0] newData2;

  pwire data_en;


  assign data_en=|{newRsSelect0,newRsSelect1,newRsSelect2,rst};

  assign data_d=(newRsSelect0 & ~rst & ~stall) ? ~newData0 : 'z;
  assign data_d=(newRsSelect1 & ~rst & ~stall) ? ~newData1 : 'z;
  assign data_d=(newRsSelect2 & ~rst & ~stall) ? ~newData2 : 'z;

  assign data_d=rst ? {WIDTH{1'b1}} : 'z;

  assign data_d=(data_en & ~stall) ? 'z : data_q;

  always @(posedge clk)
    begin
      data_q<=data_d;
    end
    
endmodule




module rs_buf(
  clk,
  dataRst,nonDataRst,rst_thread,
  stall,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  new_thread,
// wires to store new values in a buffer
  newABSNeeded0,newRsSelect0,newPort0,
// wires to get values out of buffer
  outRsSelect0,portReady0,outDataEn0,outThread0,
  fuFwdA,fuFwdB,
  isDataABS,
// 1 if buffer is free  
  bufFree
);
  localparam DATA_WIDTH=`alu_width+1;
  localparam REG_WIDTH=`reg_addr_width;
  localparam OPERATION_WIDTH=`operation_width;
  localparam LSQ_WIDTH=`lsqRsNo_width;
  localparam CONST_WIDTH=64;
  localparam FLAGS_WIDTH=`flags_width;
  localparam ROB_WIDTH=10;  
  
  input pwire clk;
  input pwire dataRst;
  input pwire nonDataRst;
  input pwire rst_thread;
  input pwire stall;
  input pwire FU0Hit;
  input pwire FU1Hit;
  input pwire FU2Hit;
  input pwire FU3Hit;
  input pwire new_thread;
//Input of new data from registeres
  input pwire [2:0][2:0] newABSNeeded0;
  input pwire [2:0] newRsSelect0;
  input pwire [2:0] [3:0] newPort0;

// output pwire data to functional units

  input pwire [2:0]outRsSelect0;
  output pwire [2:0] portReady0;
  output pwire [2:0] [3:0] outDataEn0;
  output pwire [2:0] outThread0;
    
  input pwire [3:0] fuFwdA;
  input pwire [3:0] fuFwdB;

  input pwire [2:0] isDataABS;

// free output
  output pwire bufFree;
// wires
// wires - new data
  

  pwire [2:0] portReady0_d;
  pwire [2:0] portReady0_q;


  pwire [3:0] portNo_new;

  pwire [2:0] port0_d;
  pwire [2:0] port0_en;
  pwire [2:0] port0_q;


  pwire [2:0] [REG_WIDTH-1:0] regA_q;
  pwire [2:0] [REG_WIDTH-1:0] regA_d;

  pwire newRsSelectAny=|newRsSelect0;

  pwire [2:0] dataAPending_en;
  pwire [2:0] dataAPending_d;
  pwire [2:0] dataAPending_q;
  pwire [2:0] dataAPending_gather;
  pwire [2:0] dataAPending_new;
 
// wires - gather data
  pwire isReady;
// wires - free bit
  pwire bufFree_d;
  pwire bufFree_en;
  
  pwire stall_n;
  
  
  pwire unFwdCheck;
  pwire [3:0] fwdCheck0;

  pwire unCheckA;
  pwire unCheckB;

  pwire forgetUpdate;
  
  pwire thread_q;
  pwire FP_q;
  pwire Vec_q;
  
  pwire nonDataRst0;
  
  pwire new_stall_n;
    
  assign stall_n=~stall;  
  assign nonDataRst0=(rst_thread) ? nonDataRst & thread_q || dataRst : nonDataRst &~thread_q || dataRst;
//new data input pwire into buffer 
  assign new_stall_n=~(newRsSelectAny & stall);


  DFF thread_mod(clk,newRsSelectAny|dataRst,new_thread&~dataRst,thread_q);
  DFF FP_mod(clk,newRsSelectAny|dataRst,portNo_new[3]&~dataRst,FP_q);
  DFF Vec_mod(clk,newRsSelectAny|dataRst,portNo_new[2]&~dataRst,Vec_q);
  
  generate
      genvar regno,loadno,subloop;
      for(regno=0;regno<3;regno=regno+1) begin : reg_gen
          DFF dataAPending_mod(clk,dataABSPending_en[regno],dataABSPending_d[regno],dataABSPending_q[regno]);
          DFF port0_mod(clk,port0_en[regno],port0_d[regno],port0_q[regno]);
          DFF portReady0_mod(clk,1'b1,portReady0_d[regno],portReady0_q[regno]);
          assign dataABSPending_gather[regno]=isDataABS[regno];
          assign portReady0[regno]=portReady0_q[regno];
  
          assign dataAPending_en=newRsSelectAny | nonDataRst0 | unCheckA || dataAPending_gather ;
          assign dataAPending_d[regno]=newRsSelectAny ? dataAPending_new[regno] & ~nonDataRst0 & stall_n & ~dataAPending_gather[regno]:
               (~dataAPending_gather[regno] & dataAPending_q[regno] || unCheckA) & ~nonDataRst0;
          //here regno is "new" port index 
          assign portNo_new=(newRsSelect0[regno] & ~stall) ? newPort0[regno] : 4'bz;
          for(subloop=0;subloop<3;subloop=subloop+1) begin : sub_gen
              assign dataABSPending_new[regno]=(newRsSelect0[subloop] & ~stall) ? newABSNeeded0[regno][subloop] : 1'bz;
          //here regno is "output" port number
          assign port0_en[regno]=stall_n & newRsSelectAny || outRsSelect0[regno] &~unFwdCheck || nonDataRst0;
          assign port0_d=newRsSelectAny ? (portNo_new[1:0]==regno[1:0]) & ~nonDataRst0 :
              port0_q[regno] & (~outRsSelect0[regno]  | unFwdCheck)  & ~nonDataRst0;
          assign portReady0_d[regno]=isReady & port0_d[regno] & ~unFwdCheck & new_stall_n;
          assign outDataEn0[regno]=outRsSelect0[regno] ? {4{~unFwdCheck}} &{FP_q,Vec_q,~FP_q&~Vec_q,1'b1} : 4'bz;
          assign outThread0[regno]=outRsSelect0[regno] ? thread_q : 1'bz;
      for(loadno=0;loadno<4;loadno=loadno+1) begin : ld_gen
         assign fwdCheck0[loadno]=pwh#(32)::cmpEQ(fuFwdA,loadno) || pwh#(32)::cmpEQ(fuFwdB,loadno); 
      end
  engenerate    

  assign unFwdCheck=fwdCheck0[0] & ~FU0Hit || fwdCheck0[1] & ~FU1Hit || fwdCheck0[2] & ~FU2Hit || fwdCheck0[3] & ~FU3Hit;

  assign unCheckA=(pwh#(4)::cmpEQ(fuFwdA,4'd0) && ~FU0Hit) | (pwh#(4)::cmpEQ(fuFwdA,4'd1) && ~FU1Hit) | (pwh#(4)::cmpEQ(fuFwdA,4'd2) && ~FU2Hit) | (pwh#(4)::cmpEQ(fuFwdA,4'd3) && ~FU3Hit);
  assign unCheckB=(pwh#(4)::cmpEQ(fuFwdB,4'd0) && ~FU0Hit) | (pwh#(4)::cmpEQ(fuFwdB,4'd1) && ~FU1Hit) | (pwh#(4)::cmpEQ(fuFwdB,4'd2) && ~FU2Hit) | (pwh#(4)::cmpEQ(fuFwdB,4'd3) && ~FU3Hit);

// end new data input pwire into buffer

// output pwire from buffer

// issue port 0 -addrcalc
  
// issue port 1 - alu 1
 
  
// issue port 2 - alu 2


// end data output


  assign isReady=dataAPending_gather[0] | ~dataAPending_d[0] && dataAPending_gather[1] | ~dataAPending_d[1] && 
    dataAPending_gather[2] | ~dataAPending_d[2];
  

// free bit
  DFF bufFree_mod(clk,bufFree_en,bufFree_d,bufFree);
  
  assign bufFree_en=stall_n & newRsSelectAny || (outRsSelect0 | (outRsSelect1 & ~port2_q)  | (outRsSelect2 & 
~port1_q) | (outRsSelect1 & outRsSelect2)    && ~unFwdCheck) || nonDataRst0;
  assign bufFree_d=~newRsSelectAny || nonDataRst0;
  
endmodule





module rs_array(
  clk,
  dataRst,nonDataRst,rst_thread,
  stall,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  new_thread,
// wires to store new values in a buffer
  newANeeded0,newBNeeded0,newSNeeded0,newRsSelect0,newPort0,
  newANeeded1,newBNeeded1,newSNeeded1,newRsSelect1,newPort1,
  newANeeded2,newBNeeded2,newSNeeded2,newRsSelect2,newPort2,
// wires to get values out of buffer
  outRsSelect0,outRsBank0,outFound0,portReady0,outDataEn0,outThread0,//addrcalc
  outRsSelect1,outRsBank1,outFound1,portReady1,outDataEn1,outThread1,//alu 1
  outRsSelect2,outRsBank2,outFound2,portReady2,outDataEn2,outThread2,//alu 2
  fuFwdA,fuFwdB,
  isDataA,isDataB,isDataS,
// 1 if buffer is free  
  bufFree
);
  localparam DATA_WIDTH=`alu_width+1;
  localparam REG_WIDTH=`reg_addr_width;
  localparam OPERATION_WIDTH=`operation_width;
  localparam LSQ_WIDTH=`lsqRsNo_width;
  localparam CONST_WIDTH=64;
  localparam FLAGS_WIDTH=`flags_width;
  localparam ROB_WIDTH=10;  
  localparam BUF_COUNT=32;
  
  input pwire clk;
  input pwire dataRst;
  input pwire nonDataRst;
  input pwire rst_thread;
  input pwire stall;
  input pwire FU0Hit;
  input pwire FU1Hit;
  input pwire FU2Hit;
  input pwire FU3Hit;
  input pwire new_thread;
//Input of new data from registeres
  input pwire [2:0][2:0] newABSNeeded0;
  input pwire [2:0][BUF_COUNT-1:0] newRsSelect0;
  input pwire [2:0][3:0] newPort0;

// output pwire data to functional units

  input pwire [2:0][BUF_COUNT-1:0] outRsSelect0;
  input pwire [2:0][3:0] outRsBank0;
  input pwire [2:0]outFound0;
  output pwire [2:0][BUF_COUNT-1:0] portReady0;
  output pwire [2:0][3:0] outDataEn0;
  output pwire [2:0]outThread0;
    
  input pwire [BUF_COUNT*4-1:0] fuFwdA;
  input pwire [BUF_COUNT*4-1:0] fuFwdB;

  input pwire [2:0][BUF_COUNT-1:0] isDataA;

// free output
  output pwire [BUF_COUNT-1:0]  bufFree;
// wires
// wires - new data

  generate
      genvar k,j;
      for (j=0;j<4;j=j+1) begin : banks_gen
          pwire [2:0][3:0] outDataEn0a;
          pwire [2:0] outThread0a;
      for(k=0;k<8;k=k+1) begin : buffers_gen
          rs_buf buf_mod(
          clk,
          dataRst,nonDataRst,rst_thread,
          stall,
          FU0Hit,FU1Hit,FU2Hit,FU3Hit,
          new_thread,
// wires to store new values in a buffer
          newANeeded0,newBNeeded0,newSNeeded0,newRsSelect0[j*8+k],newPort0,
// wires to get values out of buffer
          {outRsSelect0[2][j*8+k],outRsSelect0[1][j*8+k],outRsSelect0[0][j*8+k]},
          {portReady0[2][j*8+k],portReady0[1][j*8+k],portReady0[0][j*8+k]},
          outDataEn0a,outThread0a,
          fuFwdA[(j*8+k)*4+:4],fuFwdB[(j*8+k)*4+:4],
          {isDataA[2][j*8+k],isDataA[1][j*8+k],isDataA[0][j*8+k]},
// 1 if buffer is free  
          bufFree[j*8+k]
          );
      end
      genvar subloop;
      for(subloop=0;subloop<3;subloop=subloop+1) begin : sub_gen
          assign outDataEn0a[subloop]=outRsBank0[subloop][j] ? 4'bz : 4'b0;
          assign outDataEn0[subloop]=outRsBank0[subloop][j] ? outDataEn0a[subloop] : 4'bz;
          assign outThread0a[subloop]=outRsBank0[subloop][j] ? 1'bz : 1'b0;
          assign outThread0[subloop]=outRsBank0[subloop][j] ? outThread0a[subloop] : 1'bz;
      end
      if (j<3) begin : j_lt_3
          assign outDataEn0[j]=outFound0[j] ? 4'bz : 4'b0;
          assign outThread0[j]=outFound0[j] ? 1'bz : 1'b0;
      end
  endgenerate


endmodule




module rs(
  clk,clkREF,clkREF2,
  dataRst,nonDataRst,rst_thread,
  stall,
  doStall,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  new_thread,
// wires to store new values in a buffer
  newDataA0,newDataB0,newDataC0,newRegA0,newRegB0,
    newANeeded0,newBNeeded0,newReg0,newOp0,newPort0,newInstrIndex0,newLSQ0,
    rsAlloc0,newGazumpA0,newGazumpB0,newFunitA0,newFunitB0,newWQ0,newLSFlag0,
    newAttr0,
  newDataA1,newDataB1,newDataC1,newDataS1,newRegA1,newRegB1,newRegS1,
    newANeeded1,newBNeeded1,newSNeeded1,newReg1,newRegSimd1,newOp1,newPort1,
    newInstrIndex1,newLSQ1,rsAlloc1,newGazumpA1,newGazumpB1,newGazumpS1,
    newFunitA1,newFunitB1,newFunitS1,newLSFlag1,newAttr1,newXPort1,
  newDataA2,newDataB2,newDataC2,newDataS2,newRegA2,newRegB2,newRegS2,
    newANeeded2,newBNeeded2,newSNeeded2,newReg2,newRegSimd2,newOp2,newPort2,
    newInstrIndex2,rsAlloc2,newGazumpA2,newGazumpB2,newGazumpS2,
    newFunitA2,newFunitB2,newFunitS2,newAttr2,newXPort2,
// wires to get values out of buffer
  outDataA0,outDataB0,outDataC0,outReg0,outOp0,outInstrIndex0,outWQ0,outLSFlag0,
    outFuFwdA0,outFuFwdB0,outFuuFwdA0,outFuuFwdB0,outLSQ0,outDataEn0,outThread0,//addrcalc
    outAttr0,
  outDataA1,outDataB1,outDataC1,outDataS1,outReg1,outRegSimd1,outOp1,outInstrIndex1,
    outFuFwdA1,outFuFwdB1,outFuFwdS1,outFuuFwdA1,outFuuFwdB1,
    outFuuFwdS1,outDataEn1,outThread1,outAttr1,outXPort1,//alu 1
  outDataA2,outDataB2,outDataS2,outReg2,outRegSimd2,outOp2,outInstrIndex2,
    outFuFwdA2,outFuFwdB2,outFuFwdS2,outFuuFwdA2,outFuuFwdB2,
    outFuuFwdS2,outDataEn2,outThread2,outAttr2,outXPort2,//alu 2
// wires from functional units  
  FU0,FUreg0,FUwen0,
  FU1,FUreg1,FUwen1,
  FU2,FUreg2,FUwen2,
  FU3,FUreg3,FUwen3,
  FU4,FUreg4,FUwen4,
  FU5,FUreg5,FUwen5,
  FU6,FUreg6,FUwen6,
  FU7,FUreg7,FUwen7,
  FU8,FUreg8,FUwen8,
  FU9,FUreg9,FUwen9,
  
  newDataVA1H,newDataVB1H,newDataVA1L,newDataVB1L,
  newDataVA2H,newDataVB2H,newDataVA2L,newDataVB2L,

  newDataFA1H,newDataFB1H,newDataFA1L,newDataFB1L,
  newDataFA2H,newDataFB2H,newDataFA2L,newDataFB2L,

  outDataVA1H,outDataVB1H,outDataVA1L,outDataVB1L,
  outDataVA2H,outDataVB2H,outDataVA2L,outDataVB2L,

  outDataFA1H,outDataFB1H,outDataFA1L,outDataFB1L,
  outDataFA2H,outDataFB2H,outDataFA2L,outDataFB2L,

  FUV0H,FUV0L,
  FUV1H,FUV1L,
  FUV2H,FUV2L,
  FUV3H,FUV3L,
  FUV4H,FUV4L,
  FUV5H,FUV5L,
  FUV6H,FUV6L,
  FUV7H,FUV7L,
  FUV8H,FUV8L,
  FUV9H,FUV9L,

  FUVX4H,FUVX4L,
  FUVX5H,FUVX5L,
  FUVX6H,FUVX6L,
  
  FUF0H,FUF0L,
  FUF1H,FUF1L,
  FUF2H,FUF2L,
  FUF3H,FUF3L,
  FUF4H,FUF4L,
  FUF5H,FUF5L,
  FUF6H,FUF6L,
  FUF7H,FUF7L,
  FUF8H,FUF8L,
  FUF9H,FUF9L,

  FUFX4H,FUFX4L,
  FUFX5H,FUFX5L,
  FUFX6H,FUFX6L,


  FUS0,FUS1,FUS2,
  FUS3,FUS4,FUS5,
  FUS6,FUS7,FUS8,
  FUSreg0,FUSwen0,
  FUSreg1,FUSwen1,
  FUSreg2,FUSwen2,
  FUSreg3,FUSwen3,
  FUSreg4,FUSwen4,
  FUSreg5,FUSwen5,
  FUSreg6,FUSwen6,
  FUSreg7,FUSwen7,
  FUSreg8,FUSwen8,
// 1 if buffer is free  
  pause0,foundAlt1,foundAlt2
);
  localparam DATA_WIDTH=`alu_width+1;
  localparam SIMD_WIDTH=68;//half-width
  localparam REG_WIDTH=`reg_addr_width;
  localparam OPERATION_WIDTH=`operation_width+5+3;
  localparam LSQ_WIDTH=`lsqRsNo_width;
  localparam CONST_WIDTH=33;
  localparam FLAGS_WIDTH=6;  
  localparam BUF_COUNT=`rs_buf_count;
  localparam II_WIDTH=10;  
  localparam FN_WIDTH=10;
  localparam WQ_WIDTH=6;
  localparam ATTR_WIDTH=4;
/*verilator hier_block*/ 
  
  input pwire clk;
  input pwire clkREF;
  input pwire clkREF2;
  input pwire dataRst;
  input pwire nonDataRst;
  input pwire rst_thread;
  input pwire stall;
  output pwire doStall;
  input pwire FU0Hit;
  input pwire FU1Hit;
  input pwire FU2Hit;
  input pwire FU3Hit;
//Input of new data from registeres
  input pwire new_thread;
  input pwire [DATA_WIDTH-1:0]       newDataA0;
  input pwire [DATA_WIDTH-1:0]       newDataB0;
  input pwire [CONST_WIDTH-1:0]       newDataC0;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] newRegA0; 
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] newRegB0; 
  input pwire newANeeded0;
  input pwire newBNeeded0;
  input pwire [REG_WIDTH-1:0] newReg0;
  input pwire [OPERATION_WIDTH-1:0]   newOp0;
  input pwire [3:0] newPort0;
  input pwire [II_WIDTH-1:0] newInstrIndex0;  
  input pwire [LSQ_WIDTH-1:0] newLSQ0;
  input pwire rsAlloc0;
  input pwire [10:0] newGazumpA0;
  input pwire [10:0] newGazumpB0;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [FN_WIDTH-1:0] newFunitA0;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [FN_WIDTH-1:0] newFunitB0;
  input pwire [WQ_WIDTH-1:0] newWQ0;
  input pwire newLSFlag0;
  input pwire [ATTR_WIDTH-1:0] newAttr0;

  input pwire [DATA_WIDTH-1:0]       newDataA1;
  input pwire [DATA_WIDTH-1:0]       newDataB1;
  input pwire [CONST_WIDTH-1:0]       newDataC1;
  input pwire [FLAGS_WIDTH-1:0]       newDataS1;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] newRegA1; 
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] newRegB1; 
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] newRegS1; 
  input pwire newANeeded1;
  input pwire newBNeeded1;
  input pwire newSNeeded1;
  input pwire [REG_WIDTH-1:0] newReg1;
  input pwire [REG_WIDTH-1:0] newRegSimd1;
  input pwire [OPERATION_WIDTH-1:0]   newOp1;
  input pwire [3:0] newPort1;  
  input pwire [II_WIDTH-1:0] newInstrIndex1;
  input pwire [LSQ_WIDTH-1:0] newLSQ1;
  input pwire rsAlloc1;
  input pwire [10:0] newGazumpA1;
  input pwire [10:0] newGazumpB1;
  input pwire [10:0] newGazumpS1;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [FN_WIDTH-1:0] newFunitA1;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [FN_WIDTH-1:0] newFunitB1;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [FN_WIDTH-1:0] newFunitS1;
  input pwire newLSFlag1;
  input pwire [ATTR_WIDTH-1:0] newAttr1;
  input pwire newXPort1;

  input pwire [DATA_WIDTH-1:0]       newDataA2;
  input pwire [DATA_WIDTH-1:0]       newDataB2;
  input pwire [FLAGS_WIDTH-1:0]       newDataS2;
  input pwire [CONST_WIDTH-1:0]       newDataC2;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] newRegA2; 
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] newRegB2; 
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] newRegS2; 
  input pwire newANeeded2;
  input pwire newBNeeded2;
  input pwire newSNeeded2;
  input pwire [REG_WIDTH-1:0] newReg2;
  input pwire [REG_WIDTH-1:0] newRegSimd2;
  input pwire [OPERATION_WIDTH-1:0]   newOp2;
  input pwire [3:0] newPort2;  
  input pwire [II_WIDTH-1:0] newInstrIndex2;
  input pwire rsAlloc2;
  input pwire [10:0] newGazumpA2;
  input pwire [10:0] newGazumpB2;
  input pwire [10:0] newGazumpS2;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [FN_WIDTH-1:0] newFunitA2;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [FN_WIDTH-1:0] newFunitB2;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [FN_WIDTH-1:0] newFunitS2;
  input pwire [ATTR_WIDTH-1:0] newAttr2;
  input pwire newXPort2;
  
// output pwire data to functional units

  output pwire [DATA_WIDTH-1:0]       outDataA0;
  output pwire [DATA_WIDTH-1:0]       outDataB0;//b USED AS BASE REG
  output pwire [CONST_WIDTH-1:0]       outDataC0;
  output pwire [REG_WIDTH-1:0] outReg0;
  output pwire [OPERATION_WIDTH-1:0]   outOp0;
  output pwire [II_WIDTH-1:0] outInstrIndex0;
  output pwire [WQ_WIDTH-1:0] outWQ0;
  output pwire outLSFlag0;
  output pwire [3:0] outFuFwdA0;
  output pwire [3:0] outFuFwdB0;
  output pwire [3:0] outFuuFwdA0;
  output pwire [3:0] outFuuFwdB0;
  output pwire [LSQ_WIDTH-1:0] outLSQ0;
  output pwire [3:0] outDataEn0;
  output pwire outThread0;
  output pwire [ATTR_WIDTH-1:0] outAttr0;
    
  output pwire [DATA_WIDTH-1:0]       outDataA1;
  output pwire [DATA_WIDTH-1:0]       outDataB1;
  output pwire [CONST_WIDTH-1:0]       outDataC1;
  output pwire [FLAGS_WIDTH-1:0]       outDataS1;
  output pwire [REG_WIDTH-1:0] outReg1;
  output pwire [REG_WIDTH-1:0] outRegSimd1;
  output pwire [OPERATION_WIDTH-1:0]   outOp1;
  output pwire [II_WIDTH-1:0] outInstrIndex1;
  output pwire [3:0] outFuFwdA1;
  output pwire [3:0] outFuFwdB1;
  output pwire [3:0] outFuFwdS1;
  output pwire [3:0] outFuuFwdA1;
  output pwire [3:0] outFuuFwdB1;
  output pwire [3:0] outFuuFwdS1;
  output pwire [3:0] outDataEn1;
  output pwire outThread1;
  output pwire [ATTR_WIDTH-1:0] outAttr1;
  output pwire outXPort1;

  output pwire [DATA_WIDTH-1:0]       outDataA2;
  output pwire [DATA_WIDTH-1:0]       outDataB2;
  output pwire [FLAGS_WIDTH-1:0]       outDataS2;
  output pwire [REG_WIDTH-1:0] outReg2;
  output pwire [REG_WIDTH-1:0] outRegSimd2;
  output pwire [OPERATION_WIDTH-1:0]   outOp2;
  output pwire [II_WIDTH-1:0] outInstrIndex2;
  output pwire [3:0] outFuFwdA2;
  output pwire [3:0] outFuFwdB2;
  output pwire [3:0] outFuFwdS2;
  output pwire [3:0] outFuuFwdA2;
  output pwire [3:0] outFuuFwdB2;
  output pwire [3:0] outFuuFwdS2;
  output pwire [3:0] outDataEn2;
  output pwire outThread2;
  output pwire [ATTR_WIDTH-1:0] outAttr2;
  output pwire outXPort2;

  

//functional units inputs/outputs
  input pwire [DATA_WIDTH-1:0] FU0;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg0;
  input pwire FUwen0;
  
  input pwire [DATA_WIDTH-1:0] FU1;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg1;
  input pwire FUwen1;

  input pwire [DATA_WIDTH-1:0] FU2;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg2;
  input pwire FUwen2;

  input pwire [DATA_WIDTH-1:0] FU3;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg3;
  input pwire FUwen3;

  input pwire [DATA_WIDTH-1:0] FU4;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg4;
  input pwire FUwen4;

  input pwire [DATA_WIDTH-1:0] FU5;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg5;
  input pwire FUwen5;

  input pwire [DATA_WIDTH-1:0] FU6;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg6;
  input pwire FUwen6;

  input pwire [DATA_WIDTH-1:0] FU7;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg7;
  input pwire FUwen7;

  input pwire [DATA_WIDTH-1:0] FU8;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg8;
  input pwire FUwen8;

  input pwire [DATA_WIDTH-1:0] FU9;
  (* bus=WBREG bus_rpl=6 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUreg9;
  input pwire FUwen9;
  
//SIMD
  input pwire [SIMD_WIDTH-1:0] newDataVA1H;
  input pwire [SIMD_WIDTH-1:0] newDataVB1H;
  input pwire [SIMD_WIDTH-1:0] newDataVA1L;
  input pwire [SIMD_WIDTH-1:0] newDataVB1L;
  
  input pwire [SIMD_WIDTH-1:0] newDataVA2H;
  input pwire [SIMD_WIDTH-1:0] newDataVB2H;
  input pwire [SIMD_WIDTH-1:0] newDataVA2L;
  input pwire [SIMD_WIDTH-1:0] newDataVB2L;
  
  input pwire [SIMD_WIDTH-1:0] newDataFA1H;
  input pwire [SIMD_WIDTH-1:0] newDataFB1H;
  input pwire [16+SIMD_WIDTH-1:0] newDataFA1L;
  input pwire [16+SIMD_WIDTH-1:0] newDataFB1L;
  
  input pwire [SIMD_WIDTH-1:0] newDataFA2H;
  input pwire [SIMD_WIDTH-1:0] newDataFB2H;
  input pwire [16+SIMD_WIDTH-1:0] newDataFA2L;
  input pwire [16+SIMD_WIDTH-1:0] newDataFB2L;
  
  output pwire [SIMD_WIDTH-1:0] outDataVA1H;
  output pwire [SIMD_WIDTH-1:0] outDataVB1H;
  output pwire [SIMD_WIDTH-1:0] outDataVA1L;
  output pwire [SIMD_WIDTH-1:0] outDataVB1L;
  
  output pwire [SIMD_WIDTH-1:0] outDataVA2H;
  output pwire [SIMD_WIDTH-1:0] outDataVB2H;
  output pwire [SIMD_WIDTH-1:0] outDataVA2L;
  output pwire [SIMD_WIDTH-1:0] outDataVB2L;
  
  output pwire [SIMD_WIDTH-1:0] outDataFA1H;
  output pwire [SIMD_WIDTH-1:0] outDataFB1H;
  output pwire [16+SIMD_WIDTH-1:0] outDataFA1L;
  output pwire [16+SIMD_WIDTH-1:0] outDataFB1L;
  
  output pwire [SIMD_WIDTH-1:0] outDataFA2H;
  output pwire [SIMD_WIDTH-1:0] outDataFB2H;
  output pwire [16+SIMD_WIDTH-1:0] outDataFA2L;
  output pwire [16+SIMD_WIDTH-1:0] outDataFB2L;
  
  input pwire [SIMD_WIDTH-1:0] FUV0H;
  input pwire [SIMD_WIDTH-1:0] FUV0L;
  
  input pwire [SIMD_WIDTH-1:0] FUV1H;
  input pwire [SIMD_WIDTH-1:0] FUV1L;
  
  input pwire [SIMD_WIDTH-1:0] FUV2H;
  input pwire [SIMD_WIDTH-1:0] FUV2L;
  
  input pwire [SIMD_WIDTH-1:0] FUV3H;
  input pwire [SIMD_WIDTH-1:0] FUV3L;
  
  input pwire [SIMD_WIDTH-1:0] FUV4H;
  input pwire [SIMD_WIDTH-1:0] FUV4L;
  
  input pwire [SIMD_WIDTH-1:0] FUV5H;
  input pwire [SIMD_WIDTH-1:0] FUV5L;
  
  input pwire [SIMD_WIDTH-1:0] FUV6H;
  input pwire [SIMD_WIDTH-1:0] FUV6L;
  
  input pwire [SIMD_WIDTH-1:0] FUV7H;
  input pwire [SIMD_WIDTH-1:0] FUV7L;
  
  input pwire [SIMD_WIDTH-1:0] FUV8H;
  input pwire [SIMD_WIDTH-1:0] FUV8L;
  
  input pwire [SIMD_WIDTH-1:0] FUV9H;
  input pwire [SIMD_WIDTH-1:0] FUV9L;
  
  input pwire [SIMD_WIDTH-1:0] FUVX4H;
  input pwire [SIMD_WIDTH-1:0] FUVX4L;
  
  input pwire [SIMD_WIDTH-1:0] FUVX5H;
  input pwire [SIMD_WIDTH-1:0] FUVX5L;
  
  input pwire [SIMD_WIDTH-1:0] FUVX6H;
  input pwire [SIMD_WIDTH-1:0] FUVX6L;
  
  input pwire [SIMD_WIDTH-1:0] FUF0H;
  input pwire [16+SIMD_WIDTH-1:0] FUF0L;
  
  input pwire [SIMD_WIDTH-1:0] FUF1H;
  input pwire [16+SIMD_WIDTH-1:0] FUF1L;
  
  input pwire [SIMD_WIDTH-1:0] FUF2H;
  input pwire [16+SIMD_WIDTH-1:0] FUF2L;
  
  input pwire [SIMD_WIDTH-1:0] FUF3H;
  input pwire [16+SIMD_WIDTH-1:0] FUF3L;
  
  input pwire [SIMD_WIDTH-1:0] FUF4H;
  input pwire [16+SIMD_WIDTH-1:0] FUF4L;
  
  input pwire [SIMD_WIDTH-1:0] FUF5H;
  input pwire [16+SIMD_WIDTH-1:0] FUF5L;
  
  input pwire [SIMD_WIDTH-1:0] FUF6H;
  input pwire [16+SIMD_WIDTH-1:0] FUF6L;
  
  input pwire [SIMD_WIDTH-1:0] FUF7H;
  input pwire [16+SIMD_WIDTH-1:0] FUF7L;
  
  input pwire [SIMD_WIDTH-1:0] FUF8H;
  input pwire [16+SIMD_WIDTH-1:0] FUF8L;
  
  input pwire [SIMD_WIDTH-1:0] FUF9H;
  input pwire [16+SIMD_WIDTH-1:0] FUF9L;
  
  input pwire [SIMD_WIDTH-1:0] FUFX4H;
  input pwire [16+SIMD_WIDTH-1:0] FUFX4L;
  
  input pwire [SIMD_WIDTH-1:0] FUFX5H;
  input pwire [16+SIMD_WIDTH-1:0] FUFX5L;
  
  input pwire [SIMD_WIDTH-1:0] FUFX6H;
  input pwire [16+SIMD_WIDTH-1:0] FUFX6L;
  
  
  
//FLAGS FU*
  input pwire [FLAGS_WIDTH-1:0] FUS0;
  input pwire [FLAGS_WIDTH-1:0] FUS1;
  input pwire [FLAGS_WIDTH-1:0] FUS2;
  input pwire [FLAGS_WIDTH-1:0] FUS3;
  input pwire [FLAGS_WIDTH-1:0] FUS4;
  input pwire [FLAGS_WIDTH-1:0] FUS5;
  input pwire [FLAGS_WIDTH-1:0] FUS6;
  input pwire [FLAGS_WIDTH-1:0] FUS7;
  input pwire [FLAGS_WIDTH-1:0] FUS8;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg0;
  input pwire FUSwen0;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg1;
  input pwire FUSwen1;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg2;
  input pwire FUSwen2;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg3;
  input pwire FUSwen3;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg4;
  input pwire FUSwen4;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg5;
  input pwire FUSwen5;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg6;
  input pwire FUSwen6;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg7;
  input pwire FUSwen7;
  (* bus=WBSREG bus_rpl=3 bus_spacing=11 *) input pwire [REG_WIDTH-1:0] FUSreg8;
  input pwire FUSwen8;

  
  input pwire pause0;
  input pwire foundAlt1;
  input pwire foundAlt2;

  pwire [BUF_COUNT-1:0] bufFree;
  
  pwire [BUF_COUNT-1:0] newRsSelect0;
  pwire [BUF_COUNT-1:0] newRsSelect1;
  pwire [BUF_COUNT-1:0] newRsSelect2;
  
  pwire [2:0][BUF_COUNT-1:0] outRsSelect;
  pwire [BUF_COUNT-1:0] portReady[2:0];
  pwire [2:0][3:0] outBank;
  pwire [2:0] portEn;
  pwire [2:0] rsFound;
  pwire [2:0] rsFoundNZ;
  
  pwire [127:0] fuFwdA;
  pwire [127:0] fuFwdB;
  pwire [BUF_COUNT-1:0] isDataA;
  pwire [BUF_COUNT-1:0] isDataB;
  pwire [BUF_COUNT-1:0] isDataS;

  pwire [FLAGS_WIDTH-1:0] outDataS0;
  pwire [3:0] outFuFwdS0;
  pwire [3:0] outFuuFwdS0;
  pwire [127:0] fuFwdS;

  pwire [SIMD_WIDTH-1:0] outDataFA1HP;
  pwire [SIMD_WIDTH-1:0] outDataFB1HP;
//  pwire [SIMD_WIDTH-1:0] outDataFA1UHP;
//  pwire [SIMD_WIDTH-1:0] outDataFB1UHP;
  
  pwire [6*BUF_COUNT-1:0] outEqA;
  pwire [6*BUF_COUNT-1:0] outEqB;
  pwire [6*BUF_COUNT-1:0]  outEqS;
  pwire [6*BUF_COUNT-1:0]  outEqS_reg;
  pwire [6*BUF_COUNT-1:0] outEqA_reg;
  pwire [6*BUF_COUNT-1:0] outEqB_reg;
  pwire [6*BUF_COUNT-1:0] outEqA_reg2;
  pwire [6*BUF_COUNT-1:0] outEqB_reg2;
  pwire [6*BUF_COUNT-1:0] outEqA_reg3;
  pwire [6*BUF_COUNT-1:0] outEqB_reg3;
  pwire [BUF_COUNT-1:0] newRsSelect0_reg;
  pwire [BUF_COUNT-1:0] newRsSelect1_reg;
  pwire [BUF_COUNT-1:0] newRsSelect2_reg;
  pwire [BUF_COUNT-1:0] outRsSelect_reg[2:1];
  pwire [3:0] outBank_reg[2:1];
  pwire [2:1] rsFound_reg;
  pwire [2:1] rsFoundNZ_reg;
  pwire [BUF_COUNT-1:0] newRsSelect0_reg2;
  pwire [BUF_COUNT-1:0] newRsSelect1_reg2;
  pwire [BUF_COUNT-1:0] newRsSelect2_reg2;
  pwire [BUF_COUNT-1:0] outRsSelect_reg2[2:1];
  pwire [3:0] outBank_reg2[2:1];
  pwire [2:1] rsFound_reg2;
  pwire [2:1] rsFoundNZ_reg2;

  
  pwire [3:0] outFuFwdA1_reg;
  pwire [3:0] outFuFwdB1_reg;
  pwire [3:0] outFuuFwdA1_reg;
  pwire [3:0] outFuuFwdB1_reg;

  pwire op_swp,op_swp_reg,op_swp_reg2,op_swp_reg3;
 
  function op_fpswap;
      input pwire [OPERATION_WIDTH-1:0] op;
      op_fpswap=op[12] && op[7:4]==4'b0;
  endfunction 
`ifdef simulation
  rs_array rs_mod(
  clk,
  dataRst,nonDataRst,rst_thread,
  stall|doStall,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  new_thread,
// wires to store new values in a buffer
  newANeeded0,newBNeeded0,1'b0,newRsSelect0,newPort0,
  newANeeded1,newBNeeded1,newSNeeded1,newRsSelect1,newPort1,
  newANeeded2,newBNeeded2,newSNeeded2,newRsSelect2,newPort2,
// wires to get values out of buffer
  outRsSelect[0],outBank[0],rsFoundNZ[0],portReady[0],outDataEn0,outThread0,//addrcalc
  outRsSelect[1],outBank[1],rsFound[1],portReady[1],outDataEn1,outThread1,//alu 1
  outRsSelect[2],outBank[2],rsFoundNZ[2],portReady[2],outDataEn2,outThread2,//alu 2
  fuFwdA,fuFwdB,
  isDataA,isDataB,isDataS,
// 1 if buffer is free  
  bufFree
  );
`else
  rs_array rs_mod(
  clk,
  dataRst,nonDataRst,rst_thread,
  stall|doStall,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  new_thread,
// wires to store new values in a buffer
  newANeeded0&clkREF,newANeeded0&clkREF2,1'b0,newRsSelect0,newPort0,
  newANeeded1&clkREF,newANeeded1&clkREF2,newSNeeded1,newRsSelect1,newPort1,
  newANeeded2&clkREF,newANeeded2&clkREF2,newSNeeded2,newRsSelect2,newPort2,
// wires to get values out of buffer
  outRsSelect[0],outBank[0],rsFoundNZ[0],portReady[0],outDataEn0,outThread0,//addrcalc
  outRsSelect[1],outBank[1],rsFound[1],portReady[1],outDataEn1,outThread1,//alu 1
  outRsSelect[2],outBank[2],rsFoundNZ[2],portReady[2],outDataEn2,outThread2,//alu 2
  fuFwdA&{4{clkREF}},fuFwdA&{4{clkREF2}},
  isDataA&{32{clkREF}},isDataA&{32{clkREF2}},isDataS,
// 1 if buffer is free
  bufFree
  );
`endif
 
//  assign op_swp=op_fpswap(outOp1); 

 // assign outDataFA1H=op_swp_reg2 ? outDataFB1HP : outDataFA1HP;
 // assign outDataFB1H=op_swp_reg2 ? outDataFA1HP : outDataFB1HP;

//  assign outFuFwdAH1=op_swp_reg ? outFuFwdB1_reg : outFuFwdA1_reg;
//  assign outFuFwdBH1=op_swp_reg ? outFuFwdA1_reg : outFuFwdB1_reg;
//  assign outFuuFwdAH1=op_swp_reg ? outFuuFwdB1_reg : outFuuFwdA1_reg;
//  assign outFuuFwdBH1=op_swp_reg ? outFuuFwdA1_reg : outFuuFwdB1_reg;

  DFF2 #(1) outSwp_mod(clk,dataRst,1'b1,op_swp,op_swp_reg);
  DFF2 #(1) out2Swp_mod(clk,dataRst,1'b1,op_swp_reg,op_swp_reg2);
  //DFF2 #(1) out3Swp_mod(clk,dataRst,1'b1,op_swp_reg2,op_swp_reg3);
  
  DFF2 #(4) outFuA1_mod(clk,dataRst,1'b1,outFuFwdA1,outFuFwdA1_reg);
  DFF2 #(4) outFuB1_mod(clk,dataRst,1'b1,outFuFwdB1,outFuFwdB1_reg);
  DFF2 #(4) outFuuA1_mod(clk,dataRst,1'b1,outFuuFwdA1,outFuuFwdA1_reg);
  DFF2 #(4) outFuuB1_mod(clk,dataRst,1'b1,outFuuFwdB1,outFuuFwdB1_reg);
  
  DFF2 #(32*6) outEqA_mod(clk,dataRst,1'b1,outEqA,outEqA_reg);
  DFF2 #(32*6) outEqB_mod(clk,dataRst,1'b1,outEqB,outEqB_reg);
  DFF2 #(32*6) outEqS_mod(clk,dataRst,1'b1,outEqS,outEqS_reg);

  DFF2 #(32) outNew0_mod(clk,dataRst,1'b1,newRsSelect0,newRsSelect0_reg);
  DFF2 #(32) outNew1_mod(clk,dataRst,1'b1,newRsSelect1,newRsSelect1_reg);
  DFF2 #(32) outNew2_mod(clk,dataRst,1'b1,newRsSelect2,newRsSelect2_reg);
  DFF2 #(32) outSel1_mod(clk,dataRst,1'b1,outRsSelect[1],outRsSelect_reg[1]);
  DFF2 #(32) outSel2_mod(clk,dataRst,1'b1,outRsSelect[2],outRsSelect_reg[2]);
  DFF2 #(4) outBnk1_mod(clk,dataRst,1'b1,outBank[1],outBank_reg[1]);
  DFF2 #(4) outBnk2_mod(clk,dataRst,1'b1,outBank[2],outBank_reg[2]);
  DFF2 #(1) outFnd1_mod(clk,dataRst,1'b1,rsFound[1],rsFound_reg[1]);
  DFF2 #(1) outFnd2_mod(clk,dataRst,1'b1,rsFound[2],rsFound_reg[2]);
  DFF2 #(1) outFndX1_mod(clk,dataRst,1'b1,rsFoundNZ[1],rsFoundNZ_reg[1]);
  DFF2 #(1) outFndX2_mod(clk,dataRst,1'b1,rsFoundNZ[2],rsFoundNZ_reg[2]);

  DFF2 #(32*6) outEqA2_mod(clk,dataRst,1'b1,outEqA_reg,outEqA_reg2);
  DFF2 #(32*6) outEqB2_mod(clk,dataRst,1'b1,outEqB_reg,outEqB_reg2);
//  DFF2 #(32*6) outEqS2_mod(clk,dataRst,1'b1,outEqS_reg,outEqS_reg2);

  DFF2 #(32) outNew02_mod(clk,dataRst,1'b1,newRsSelect0_reg,newRsSelect0_reg2);
  DFF2 #(32) outNew12_mod(clk,dataRst,1'b1,newRsSelect1_reg,newRsSelect1_reg2);
  DFF2 #(32) outNew22_mod(clk,dataRst,1'b1,newRsSelect2_reg,newRsSelect2_reg2);
  DFF2 #(32) outSel12_mod(clk,dataRst,1'b1,outRsSelect_reg[1],outRsSelect_reg2[1]);
  DFF2 #(32) outSel22_mod(clk,dataRst,1'b1,outRsSelect_reg[2],outRsSelect_reg2[2]);
  DFF2 #(4) outBnk12_mod(clk,dataRst,1'b1,outBank_reg[1],outBank_reg2[1]);
  DFF2 #(4) outBnk22_mod(clk,dataRst,1'b1,outBank_reg[2],outBank_reg2[2]);
  DFF2 #(1) outFnd12_mod(clk,dataRst,1'b1,rsFound_reg[1],rsFound_reg2[1]);
  DFF2 #(1) outFnd22_mod(clk,dataRst,1'b1,rsFound_reg[2],rsFound_reg2[2]);
  DFF2 #(1) outFndX12_mod(clk,dataRst,1'b1,rsFoundNZ_reg[1],rsFoundNZ_reg2[1]);
  DFF2 #(1) outFndX22_mod(clk,dataRst,1'b1,rsFoundNZ_reg[2],rsFoundNZ_reg2[2]);

  generate
      genvar k;
      for (k=0;k<3;k=k+1) begin : sel_gen
          rsSelectFifo #(k!=0) sel0_mod(
          clk,
          dataRst,
          nonDataRst,
          portReady[k],
          portEn[k],
          rsFound[k],
	  rsFoundNZ[k],
          outRsSelect[k],
          outBank[k]
          );
      end
  
  endgenerate

  rsAlloc3 alloc_mod(
  clk,
  rsAlloc0,rsAlloc1,rsAlloc2,
  bufFree,
  newRsSelect0,
  newRsSelect1,
  newRsSelect2,
  doStall,
  stall
  );
  
  rs_wakeUp_logic_array #(DATA_WIDTH) dataA_L_mod(
  clk,dataRst,stall|doStall,
  isDataA,
  outEqA,
  bufFree,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  FUreg0,FUwen0,
  FUreg1,FUwen1,
  FUreg2,FUwen2,
  FUreg3,FUwen3,
  FUreg4,FUwen4,
  FUreg5,FUwen5,
  FUreg6,FUwen6,
  FUreg7,FUwen7,
  FUreg8,FUwen8,
  FUreg9,FUwen9,
  newRsSelect0,newRegA0,newFunitA0,newGazumpA0,newPort0[3],newPort0[2],
  newRsSelect1,newRegA1,newFunitA1,newGazumpA1,newPort1[3],newPort1[2],
  newRsSelect2,newRegA2,newFunitA2,newGazumpA2,newPort2[3],newPort2[2],
  fuFwdA,
  outRsSelect[0],outDataEn0[0],outBank[0],rsFoundNZ[0],outFuFwdA0,outFuuFwdA0,
  outRsSelect[1],outDataEn1[0],outBank[1],rsFoundNZ[1],outFuFwdA1,outFuuFwdA1,
  outRsSelect[2],outDataEn2[0],outBank[2],rsFoundNZ[2],outFuFwdA2,outFuuFwdA2
  );
`ifdef simulation
  rs_wakeUp_logic_array #(DATA_WIDTH) dataB_L_mod(
  clk,dataRst,stall|doStall,
  isDataB,
  outEqB,
  bufFree,
  FU0Hit,FU1Hit,FU2Hit,FU3Hit,
  FUreg0,FUwen0,
  FUreg1,FUwen1,
  FUreg2,FUwen2,
  FUreg3,FUwen3,
  FUreg4,FUwen4,
  FUreg5,FUwen5,
  FUreg6,FUwen6,
  FUreg7,FUwen7,
  FUreg8,FUwen8,
  FUreg9,FUwen9,
  newRsSelect0,newRegB0,newFunitB0,newGazumpB0,newPort0[3],newPort0[2],
  newRsSelect1,newRegB1,newFunitB1,newGazumpB1,newPort1[3],newPort1[2],
  newRsSelect2,newRegB2,newFunitB2,newGazumpB2,newPort2[3],newPort2[2],
  fuFwdB,
  outRsSelect[0],outDataEn0[0],outBank[0],rsFoundNZ[0],outFuFwdB0,outFuuFwdB0,
  outRsSelect[1],outDataEn1[0],outBank[1],rsFoundNZ[1],outFuFwdB1,outFuuFwdB1,
  outRsSelect[2],outDataEn2[0],outBank[2],rsFoundNZ[2],outFuFwdB2,outFuuFwdB2
  );
`endif
  rs_wakeUpS_logic_array #(FLAGS_WIDTH) dataS_L_mod(
  clk,dataRst,stall|doStall,
  isDataS,
  outEqS,
  bufFree,
  FUSreg3,FUSwen3,
  FUSreg4,FUSwen4,
  FUSreg5,FUSwen5,
  FUSreg6,FUSwen6,
  FUSreg7,FUSwen7,
  FUSreg8,FUSwen8,
  FUSwen0,FUSwen1,FUSwen2,
  newRsSelect1,newRegS1,{newFunitS1[9:3],newFunitS1[6:4]&{3{|newPort1[3:2]}}},newGazumpS1,|newPort1[3:2],
  newRsSelect2,newRegS2,{newFunitS2[9:3],newFunitS2[6:4]&{3{|newPort2[3:2]}}},newGazumpS2,|newPort2[3:2],
  fuFwdS,
  outRsSelect[1],outDataEn1[0],outBank[1],rsFoundNZ[1],outFuFwdS1,outFuuFwdS1,
  outRsSelect[2],outDataEn2[0],outBank[2],rsFoundNZ[2],outFuFwdS2,outFuuFwdS2
  );

  rs_wakeUp_data_array genA_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newDataA0,
  newRsSelect1,newDataA1,
  newRsSelect2,newDataA2,
  outEqA,
  FU0,FU1,FU2,FU3,
  FU4,FU5,FU6,
  FU7,FU8,FU9,
  outRsSelect[0],outBank[0],rsFoundNZ[0],outDataA0,
  outRsSelect[1],outBank[1],rsFoundNZ[1],outDataA1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outDataA2
  );
`ifdef simulation
  rs_wakeUp_data_array genB_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newDataB0,
  newRsSelect1,newDataB1,
  newRsSelect2,newDataB2,
  outEqB,
  FU0,FU1,FU2,FU3,
  FU4,FU5,FU6,
  FU7,FU8,FU9,
  outRsSelect[0],outBank[0],rsFoundNZ[0],outDataB0,
  outRsSelect[1],outBank[1],rsFoundNZ[1],outDataB1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outDataB2
  );
`endif
  rs_wakeUp_data_array #(6) genC(
  clk,dataRst,stall,
  32'b0,6'b0,
  newRsSelect1,newDataS1,
  newRsSelect2,newDataS2,
  outEqS,
  FUS0,FUS1,FUS2,6'b0,
  FUS3,FUS4,FUS5,
  FUS6,FUS7,FUS8,
  32'b0,4'b0,1'b0,,
  outRsSelect[1],outBank[1],rsFoundNZ[1],outDataS1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outDataS2
  );

  rs_wakeUp_data_array #(SIMD_WIDTH) dataA_VH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVA1H,
  newRsSelect2_reg,newDataVA2H,
  outEqA_reg,
  FUV0H,FUV1H,FUV2H,FUV3H,
  FUV4H,FUV5H,FUV6H,
  FUV7H,FUV8H,FUV9H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVA1H,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVA2H
  );
  
  rs_wakeUp_data_array #(SIMD_WIDTH) dataA_VL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVA1L,
  newRsSelect2_reg,newDataVA2L,
  outEqA_reg,
  FUV0L,FUV1L,FUV2L,FUV3L,
  FUV4L,FUV5L,FUV6L,
  FUV7L,FUV8L,FUV9L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVA1L,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVA2L
  );
  
`ifdef simulation  
  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_VH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVB1H,
  newRsSelect2_reg,newDataVB2H,
  outEqB_reg,
  FUV0H,FUV1H,FUV2H,FUV3H,
  FUV4H,FUV5H,FUV6H,
  FUV7H,FUV8H,FUV9H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVYB1H,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVYB2H
  );

  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_VL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVB1L,
  newRsSelect2_reg,newDataVB2L,
  outEqB_reg,
  FUV0L,FUV1L,FUV2L,FUV3L,
  FUV4L,FUV5L,FUV6L,
  FUV7L,FUV8L,FUV9L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVYB1L,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVYB2L
  );

  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_VxH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVB1H,
  newRsSelect2_reg,newDataVB2H,
  outEqB_reg,
  FUV0H,FUV1H,FUV2H,FUV3H,
  FUV4H,FUV5H,FUV6H,
  FUVX4H,FUVX5H,FUVX6H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVXB1H,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVXB2H
  );

  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_VyL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVB1L,
  newRsSelect2_reg,newDataVB2L,
  outEqB_reg,
  FUV0L,FUV1L,FUV2L,FUV3L,
  FUV4L,FUV5L,FUV6L,
  FUVX4L,FUVX5L,FUVX6L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVXB1L,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVXB2L
  );
`else
  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_VH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVA1H,
  newRsSelect2_reg,newDataVA2H,
  outEqA_reg,
  FUV0H,FUV1H,FUV2H,FUV3H,
  FUV4H,FUV5H,FUV6H,
  FUV7H,FUV8H,FUV9H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVYB1H,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVYB2H
  );
  
  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_VL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVB1L,
  newRsSelect2_reg,newDataVB2L,
  outEqA_reg,
  FUV0L,FUV1L,FUV2L,FUV3L,
  FUV4L,FUV5L,FUV6L,
  FUV7L,FUV8L,FUV9L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVYB1L,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVYB2L
  );
  
  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_VxH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVA1H,
  newRsSelect2_reg,newDataVA2H,
  outEqA_reg,
  FUV0H,FUV1H,FUV2H,FUV3H,
  FUV4H,FUV5H,FUV6H,
  FUVX4H,FUVX5H,FUVX6H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVXB1H,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVXB2H
  );
  
  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_VyL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg,newDataVA1L,
  newRsSelect2_reg,newDataVA2L,
  outEqA_reg,
  FUV0L,FUV1L,FUV2L,FUV3L,
  FUV4L,FUV5L,FUV6L,
  FUVX4L,FUVX5L,FUVX6L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg[1],outBank_reg[1],rsFoundNZ_reg[1],outDataVXB1L,
  outRsSelect_reg[2],outBank_reg[2],rsFoundNZ_reg[2],outDataVXB2L
  );
`endif
  assign outDataVB1L=outOp1_reg[10] ? outDataVXB1L : outDataVYB1L;
  assign outDataVB2L=outOp2_reg[10] ? outDataVXB2L : outDataVYB2L;
  assign outDataVB1H=outOp1_reg[10] ? outDataVXB1H : outDataVYB1H;
  assign outDataVB2H=outOp2_reg[10] ? outDataVXB2H : outDataVYB2H;

  rs_wakeUp_data_array #(SIMD_WIDTH) dataA_FH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFA1H,
  newRsSelect2_reg2,newDataFA2H,
  outEqA_reg,
  FUF0H,FUF1H,FUF2H,FUF3H,
  FUF4H,FUF5H,FUF6H,
  FUF7H,FUF8H,FUF9H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFA1H,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFA2H
  );
  
  rs_wakeUp_data_array #(16+SIMD_WIDTH) dataA_FL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{16+SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFA1L,
  newRsSelect2_reg2,newDataFA2L,
  outEqA_reg,
  FUF0L,FUF1L,FUF2L,FUF3L,
  FUF4L,FUF5L,FUF6L,
  FUF7L,FUF8L,FUF9L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFA1L,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFA2L
  );
  
`ifdef simulation  
  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_FH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFB1H,
  newRsSelect2_reg2,newDataFB2H,
  outEqB_reg,
  FUF0H,FUF1H,FUF2H,FUF3H,
  FUF4H,FUF5H,FUF6H,
  FUF7H,FUF8H,FUF9H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFYB1H,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFYB2H
  );

  rs_wakeUp_data_array #(16+SIMD_WIDTH) dataB_FL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{16+SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFB1L,
  newRsSelect2_reg2,newDataFB2L,
  outEqB_reg,
  FUF0L,FUF1L,FUF2L,FUF3L,
  FUF4L,FUF5L,FUF6L,
  FUF7L,FUF8L,FUF9L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFYB1L,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFYB2L
  );

  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_FxH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFB1H,
  newRsSelect2_reg2,newDataFB2H,
  outEqB_reg,
  FUF0H,FUF1H,FUF2H,FUF3H,
  FUF4H,FUF5H,FUF6H,
  FUFX4H,FUFX5H,FUFX6H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFXB1H,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFXB2H
  );

  rs_wakeUp_data_array #(16+SIMD_WIDTH) dataB_FyL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{16+SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFB1L,
  newRsSelect2_reg2,newDataFB2L,
  outEqB_reg,
  FUF0L,FUF1L,FUF2L,FUF3L,
  FUF4L,FUF5L,FUF6L,
  FUFX4L,FUFX5L,FUFX6L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFXB1L,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFXB2L
  );
`else
  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_FH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFA1H,
  newRsSelect2_reg2,newDataFA2H,
  outEqA_reg,
  FUF0H,FUF1H,FUF2H,FUF3H,
  FUF4H,FUF5H,FUF6H,
  FUF7H,FUF8H,FUF9H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFYB1H,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFYB2H
  );
  
  rs_wakeUp_data_array #(16+SIMD_WIDTH) dataB_FL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{16+SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFA1L,
  newRsSelect2_reg2,newDataFA2L,
  outEqA_reg,
  FUF0L,FUF1L,FUF2L,FUF3L,
  FUF4L,FUF5L,FUF6L,
  FUF7L,FUF8L,FUF9L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFYB1L,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFYB2L
  );
  
  rs_wakeUp_data_array #(SIMD_WIDTH) dataB_FxH_mod(
  clk,dataRst,stall|doStall,
  32'b0,{SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFA1H,
  newRsSelect2_reg2,newDataFA2H,
  outEqA_reg,
  FUF0H,FUF1H,FUF2H,FUF3H,
  FUF4H,FUF5H,FUF6H,
  FUFX4H,FUFX5H,FUFX6H,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFXB1H,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFXB2H
  );
  
  rs_wakeUp_data_array #(16+SIMD_WIDTH) dataB_FyL_mod(
  clk,dataRst,stall|doStall,
  32'b0,{16+SIMD_WIDTH{1'b0}},
  newRsSelect1_reg2,newDataFA1L,
  newRsSelect2_reg2,newDataFA2L,
  outEqA_reg,
  FUF0L,FUF1L,FUF2L,FUF3L,
  FUF4L,FUF5L,FUF6L,
  FUFX4L,FUFX5L,FUFX6L,
  32'b0,4'b0,1'b0,,
  outRsSelect_reg2[1],outBank_reg2[1],rsFoundNZ_reg2[1],outDataFXB1L,
  outRsSelect_reg2[2],outBank_reg2[2],rsFoundNZ_reg2[2],outDataFXB2L
  );
`endif  

  assign outDataFB1L=outOp1_reg2[10] ? outDataFXB1L : outDataFYB1L;
  assign outDataFB2L=outOp2_reg2[10] ? outDataFXB2L : outDataFYB2L;
  assign outDataFB1H=outOp1_reg2[10] ? outDataFXB1H : outDataFYB1H;
  assign outDataFB2H=outOp2_reg2[10] ? outDataFXB2H : outDataFYB2H;
  
  rs_nonWakeUp_array #(CONST_WIDTH) dataC_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newDataC0,
  newRsSelect1,newDataC1,
  newRsSelect2,newDataC2,
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],outDataC0,
  outRsSelect[1],outBank[1],rsFoundNZ[1],outDataC1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],
  );
  
  rs_nonWakeUp_array #(OPERATION_WIDTH) op_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newOp0,
  newRsSelect1,newOp1,
  newRsSelect2,newOp2,
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],outOp0,
  outRsSelect[1],outBank[1],rsFound[1],outOp1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outOp2
  );
  
  rs_nonWakeUp_array #(ATTR_WIDTH) attr_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newAttr0,
  newRsSelect1,newAttr1,
  newRsSelect2,newAttr2,
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],outAttr0,
  outRsSelect[1],outBank[1],rsFound[1],outAttr1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outAttr2
  );
  
  rs_nonWakeUp_array #(1) xattr_mod(
  clk,dataRst,stall|doStall,
  32'b0,1'b0,
  newRsSelect1,newXPort1,
  newRsSelect2,newXPort2,
  
  32'b0,4'b0,1'b0,,
  outRsSelect[1],outBank[1],rsFound[1],outXPort1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outXPort2
  );
  
  rs_nonWakeUp_array #(1) LSF_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newLSFlag0,
  newRsSelect1,newLSFlag1,
  32'b0,1'b0,
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],outLSFlag0,
  32'b0,4'B0,1'b1,,
  32'b0,4'B0,1'b1,
  );
  
  rs_nonWakeUp_array #(REG_WIDTH) reg_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newReg0,
  newRsSelect1,newReg1,
  newRsSelect2,newReg2,
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],outReg0,
  outRsSelect[1],outBank[1],rsFound[1],outReg1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outReg2
  );


  rs_nonWakeUp_array #(REG_WIDTH) regSIMD_mod(
  clk,dataRst,stall|doStall,
  32'b0,9'b0,
  newRsSelect1,newRegSimd1,
  newRsSelect2,newRegSimd2,
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],,
  outRsSelect[1],outBank[1],rsFoundNZ[1],outRegSimd1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outRegSimd2
  );

  rs_nonWakeUp_array #(LSQ_WIDTH) LSQ_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newLSQ0,
  newRsSelect1,newLSQ1,
  32'b0,{LSQ_WIDTH{1'B0}},
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],outLSQ0,
  32'b0,4'B0,1'b1,,
  32'b0,4'B0,1'b1,
  );

  rs_nonWakeUp_array #(WQ_WIDTH) WQ_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newWQ0,
  newRsSelect1,{WQ_WIDTH{1'B0}},
  32'b0,{WQ_WIDTH{1'B0}},
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],outWQ0,
  32'b0,4'B0,1'b1,,
  32'b0,4'B0,1'b1,
  );

  rs_nonWakeUp_array #(II_WIDTH) ii_mod(
  clk,dataRst,stall|doStall,
  newRsSelect0,newInstrIndex0,
  newRsSelect1,newInstrIndex1,
  newRsSelect2,newInstrIndex2,
  
  outRsSelect[0],outBank[0],rsFoundNZ[0],outInstrIndex0,
  outRsSelect[1],outBank[1],rsFound[1],outInstrIndex1,
  outRsSelect[2],outBank[2],rsFoundNZ[2],outInstrIndex2
  );

  
  assign portEn[0]=~pause0;
  assign portEn[1]=~foundAlt1;
  assign portEn[2]=~foundAlt2;
  
  
endmodule
