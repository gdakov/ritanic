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

//exponent in ext is 16'b8011111...exp
module ldD2nativeD(
  A,Ax,
  en,
  to_dbl,to_ext,
  res);
  input pwire [64:0] A;
  input pwire [64:0] Ax;
  input pwire en;
  input pwire to_dbl;
  input pwire to_ext;
  output pwire [80:0] res;

  pwire [51:0] denor;
  pwire [51:0] last;
  pwire [6:0] lastB;
  pwire hasB,has;
  pwire [11:0] exp;
  pwire [64:0] resX;
  pwire [80:0] resY;
  pwire A_z;
  bit_find_last_bit #(52) last_mod(A[51:0],last,has);
  bit_find_last_bit #(7) lastB_mod({|A[51:48],|A[47:40],|A[39:32],|A[31:24],|A[23:16],|A[15:8],|A[7:0]},lastB,hasB);
  generate
      genvar l,l1;
      for(l=0;l<7;l=l+1) begin
              pwire [51:0] denorK;
	      pwire [11:0] expK;
              for(l1=0;l1<((pwh#(32)::cmpEQ(l,6)) ? 4 : 8);l1=l1+1) begin
	          pwire [11:0] natExp=12'h3ff-l*8-l1;
		  //verilator lint_off WIDTH
                  assign denorK=last[l*8+l1] ? A[l*8+l1:0]<<(52-(l*8+l1)) : 52'bz;
		  //verilator lint_on WIDTH
		  assign expK=last[l*8+l1]? natExp : 12'bz;
	      end
	      assign denorK=lastB[l] ? 52'bz :  52'b0;
	      assign denor=lastB[l] ? denorK : 52'bz;
	      assign expK=lastB[l] ? 12'bz :  12'b0;
	      assign exp=lastB[l] ? expK : 12'bz;
      end
      assign denor=has ? 52'bz : 52'b0;
      assign exp=has ? 12'bz : 12'b0;
  endgenerate

  assign A_z=A[51:0]==52'b0;
  assign resX=(A[62:52]==0 && ~A_z) ? {exp[10],A[63],exp[11],exp[9:0],denor} :  65'bz;
  assign resX=(A[62:52]!=0 && A[62:52]!=11'h7ff) ? {A[61],A[63],A[62],~A[61],A[60:0]} : 65'bz;
  assign resX=(A[62:52]==11'h7ff && A_z) ? {A[61],A[63],A[62],A[60:53],~A_z,A[51:0]} : 65'bz;
  assign resX=(A[62:52]==0 && A_z) ? {1'b0,A[63],11'b0,denor} :  65'bz;
  assign resY=(A[62:52]==0 && ~A_z) ? {exp[10],A[63],exp[11],{4{~exp[11]}},exp[9:0],1'b0,denor,11'b0} :  81'bz;
  assign resY=(A[62:52]!=0 && A[62:52]!=11'h7ff) ? {A[61],A[63],A[62],{5{~A[61]}},A[60:52],1'b1,A[51:0],11'b0} : 81'bz;
  assign resY=(A[62:52]==11'h7ff) ? {A[61],A[63],A[62],{5{A[62]}},A[60:53],~A_z,1'b1,A[51:0],11'b0} : 81'bz;
  assign resY=(A[62:52]==0 && A_z) ? {1'b0,A[63],15'b0,1'b0,denor,11'b0} :  81'bz;

  assign res[64:0]=(en&to_dbl) ? resX : 65'bz;
  assign {res[64],res[80:65],res[63:0]}=(en&to_ext) ? resY : 81'bz;
  
endmodule

module ldS2nativeS(
  A,Ax,
  en,
  to_sngl,
  to_dbl,
  to_ext,
  res);
  input pwire [31:0] A;
  input pwire [31:0] Ax;
  input pwire en;
  input pwire to_sngl;
  input pwire to_dbl;
  input pwire to_ext;
  output pwire [81:0] res;

  pwire [22:0] denor;
  pwire [22:0] last;
  pwire [2:0] lastB;
  pwire hasB,has;
  pwire [11:0] exp;
  pwire [32:0] resX;
  pwire [64:0] resY;
  pwire [80:0] resZ;
  pwire A_z;

  bit_find_last_bit #(23) last_mod(A[22:0],last,has);
  bit_find_last_bit #(3) lastB_mod({|A[22:16],|A[15:8],|A[7:0]},lastB,hasB);
  generate
      genvar l,l1;
      for(l=0;l<3;l=l+1) begin
              pwire [22:0] denorK;
	      pwire [11:0] expK;
              for(l1=0;l1<((pwh#(32)::cmpEQ(l,2)) ? 7 : 8);l1=l1+1) begin
	          pwire [11:0] natExp=12'h3ff-l*8-l1;
		  //verilator lint_off WIDTH
                  assign denorK=last[l*8+l1] ? A[l*8+l1:0]<<(23-(l*8+l1)) : 23'bz;
		  //verilator lint_on WIDTH
		  assign expK=last[l*8+l1]? natExp : 12'bz;
	      end
	      assign denorK=lastB[l] ? 23'bz :  23'b0;
	      assign denor=lastB[l] ? denorK : 23'bz;
	      assign expK=lastB[l] ? 12'bz :  12'b0;
	      assign exp=lastB[l] ? expK : 12'bz;
      end
      assign denor=has ? 23'bz : 23'b0;
      assign exp=has ? 12'bz : 12'b0;
  endgenerate

  assign A_z=A[22:0]==23'b0;
  assign resX=(A[30:23]==0 && ~A_z) ? {exp[7],A[31],exp[8],exp[6:0],denor} :  33'bz;
  assign resX=(A[30:23]!=0 && A[30:23]!=8'hff) ? {A[29],A[31],A[30],~A[30],A[28:23],A[22:0]} : 33'bz;
  assign resX=(A[30:23]==8'hff) ? {A[30],A[31],A[30:24],~A_z,A[22:0]} : 33'bz;
  assign resX=(A[30:23]==0 && A_z) ? {1'b0,A[31],8'b0,denor} :  33'bz;
  assign resY=(A[30:23]==0 && ~A_z) ? {exp[7],A[31],exp[8],{3{~exp[8]}},exp[6:0],denor,29'b0} :  65'bz;
  assign resY=(A[30:23]!=0 && A[30:23]!=8'hff) ? {A[29],A[31],A[30],{4{~A[30]}},A[28:23],A[22:0],29'b0} : 65'bz;
  assign resY=(A[30:23]==8'hff) ? {A[30],A[31],{4{A[30]}},A[29:24],~A_z,A[22:0],29'b0} : 65'bz;
  assign resY=(A[30:23]==0 && A_z) ? {1'b0,A[31],11'b0,denor,29'b0} :  65'bz;
  assign resZ=(A[30:23]==0 && ~A_z) ? {exp[7],A[31],exp[8],{7{~exp[8]}},exp[6:0],1'b0,denor,40'b0} :  81'bz;
  assign resZ=(A[30:23]!=0 && A[30:23]!=8'hff)  ? {A[29],A[31],A[30],{8{~A[30]}},A[28:23],1'b1,A[22:0],40'b0} : 81'bz;
  assign resZ=(A[30:23]==8'hff) ? {A[29],A[31],A[30],{8{A[30]}},A[28:24],~A_z,1'b1,A[22:0],40'b0} : 81'bz;
  assign resZ=(A[30:23]==0 && A_z) ? {1'b0,A[31],15'b0,1'b0,denor,40'b0} :  81'bz;
  assign res[32:0]=(en&to_sngl) ? resX : 33'bz;
  assign res[65:0]=(en&to_dbl) ? {resY[64:32],1'b0,resY[31:0]} : 66'bz;
  assign res[81:0]=(en&to_ext) ? {resZ[80:65],resZ[64],resZ[63:32],1'b0,resZ[31:0]} : 82'bz;
endmodule

module stNativeD2D(A,en,from_dbl,from_ext,res);
  localparam DEN=16'he400;
  localparam OVFL=16'h83fe;
  input pwire [80:0] A;
  input pwire en; 
  input pwire from_dbl;
  input pwire from_ext;
  output pwire [64:0] res;

  pwire [15:0] expA=from_dbl ? {A[62],A[64],{4{~A[64]}},A[61:52]} : {A[79],A[64],A[78:65]};
  pwire [15:0] expOff;
  pwire [15:0] expOff1;
  pwire is_den;
  pwire is_zero;
  pwire is_overflow;
  pwire is_nan;
  pwire [51:0] shf0;
  pwire [51:0] shf1;
  pwire [51:0] A_1=from_dbl ? A[51:0] : A[62:11];
  pwire sgn=from_dbl ? A[63] : A[80];

  adder #(16) expAddD_mod(DEN,~expA,expOff,1'b1,1'b1,is_den,,,);
  adder #(16) expAddZ_mod(DEN-16'd51,~expA,expOff1,1'b1,1'b1,is_zero,,,);
  adder #(16) expAddO_mod(expA,~OVFL,,1'b1,1'b1,is_overflow,,,);

  assign is_nan=&expA;
  assign res=(~is_zero && ~ is_overflow && ~is_den && en) ? {sgn,A[64],expA[9:0],A_1[51:0]} : 64'bz;
  assign res=(is_den && ~is_zero && en) ? {sgn,11'b0,shf1} : 64'bz;
  assign res=(is_zero && en) ? {sgn,11'b0,52'b0} : 64'bz;
  assign res=(is_overflow && ~is_nan && en) ? {sgn,11'h7ff,52'b0} : 64'bz; 
  assign res=(is_nan && en) ? {sgn,11'h7ff,A_1[51:0]} : 64'bz;
  generate
    genvar k;
    for(k=0;k<8;k=k+1) begin : shifker_gen
	//verilator lint_off WIDTH
        assign shf0=(expOff[5:3]==k) ? {1'b1,A_1[51:0]}>>(k*8) : 52'bz; 
	//verilator lint_on WIDTH
	assign shf1=(expOff[2:0]==k) ? shf0>>k : 52'bz;
    end
  endgenerate
endmodule

module stNativeS2S(A,en,from_sngl,from_dbl,from_ext,res);
  localparam DEN=16'h4000;
  localparam OVFL=16'h807e;
  input pwire [81:0] A;
  input pwire en;
  input pwire from_sngl;
  input pwire from_dbl;
  input pwire from_ext;
  output pwire [31:0] res;

  pwire [15:0] expA;
  pwire [15:0] expOff;
  pwire [15:0] expOff1;
  pwire sgn;
  pwire is_den;
  pwire is_zero;
  pwire is_overflow;
  pwire is_nan;
  pwire [22:0] A_1;
  pwire [22:0] shf0;
  pwire [22:0] shf1;
  
  
  assign expA=from_dbl ? {A[62],A[64],{4{~A[64]}},A[61:52]} : 16'bz;
  assign expA=from_ext ? {A[79],A[64],A[78:65]} : 16'bz;
  assign expA=from_sngl ? {A[30],A[32],{7{~A[32]}},A[29:23]} : 16'bz;
  
  assign A_1=from_dbl ? A[51:29] : 23'bz;
  assign A_1=from_ext?  A[62:40] : 23'bz;
  assign A_1=from_sngl ? A[22:0] : 23'bz;

  assign sgn=from_dbl ? A[63] : 1'bz;
  assign sgn=from_ext ? A[80] : 1'bz;
  assign sgn=from_sngl? A[31] : 1'bz;

  adder #(16) expAddD_mod(DEN,~expA,expOff,1'b1,1'b1,is_den,,,);
  adder #(16) expAddZ_mod(DEN-16'd22,~expA,expOff1,1'b1,1'b1,is_zero,,,);
  adder #(16) expAddO_mod(expA,~OVFL,,1'b1,1'b1,is_overflow,,,);

  assign is_nan=&expA;
  assign res=(~is_zero && ~ is_overflow && ~is_den && en) ? {sgn,expA[15],expA[6:0],A_1[22:0]} : 32'bz;
  assign res=(is_den && ~is_zero && en) ? {sgn,8'b0,shf1} : 32'bz;
  assign res=(is_zero && en) ? {sgn,8'b0,23'b0} : 32'bz;
  assign res=(is_overflow && ~is_nan && en) ? {sgn,8'hff,23'b0} : 32'bz; 
  assign res=(is_nan && en) ? {sgn,8'hff,A[22:0]|23'b1} : 32'bz;
  generate
    genvar k;
    for(k=0;k<8;k=k+1) begin : shifker_gen
	//verilator lint_off WIDTH
        assign shf0=(expOff[5:3]==k) ? {1'b1,A_1[22:0]}>>(k*8) : 23'bz; 
	//verilator lint_on WIDTH
	assign shf1=(expOff[2:0]==k) ? shf0>>k : 23'bz;
    end
  endgenerate
endmodule

