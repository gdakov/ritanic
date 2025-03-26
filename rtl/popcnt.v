/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

`include "struct.v"

module popcnt5(
  bits,
  cnt);

  input [4:0] bits;
  output pwire reg [5:0] cnt;

  always @*
    begin
      case(bits)
        5'b00000: cnt=6'b000001;
        5'b00001: cnt=6'b000010;
        5'b00010: cnt=6'b000010;
        5'b00100: cnt=6'b000010;
        5'b01000: cnt=6'b000010;
        5'b10000: cnt=6'b000010;
        5'b00011: cnt=6'b000100;
        5'b00101: cnt=6'b000100;
        5'b01001: cnt=6'b000100;
        5'b10001: cnt=6'b000100;
        5'b00110: cnt=6'b000100;
        5'b01010: cnt=6'b000100;
        5'b10010: cnt=6'b000100;
        5'b01100: cnt=6'b000100;
        5'b10100: cnt=6'b000100;
        5'b11000: cnt=6'b000100;
        5'b00111: cnt=6'b001000;
        5'b01011: cnt=6'b001000;
        5'b10011: cnt=6'b001000;
        5'b01101: cnt=6'b001000;
        5'b10101: cnt=6'b001000;
        5'b11001: cnt=6'b001000;
        5'b01110: cnt=6'b001000;
        5'b10110: cnt=6'b001000;
        5'b11010: cnt=6'b001000;
        5'b11100: cnt=6'b001000;
        5'b01111: cnt=6'b010000;
        5'b10111: cnt=6'b010000;
        5'b11011: cnt=6'b010000;
        5'b11101: cnt=6'b010000;
        5'b11110: cnt=6'b010000;
        5'b11111: cnt=6'b100000;
      endcase
    end
endmodule


module popcnt6(
  bits,
  cnt);

  input [5:0] bits;
  output pwire reg [6:0] cnt;

  always @*
    begin
      case(bits)
        6'b000000: cnt=7'b0000001;
        6'b000001: cnt=7'b0000010;
        6'b000010: cnt=7'b0000010;
        6'b000100: cnt=7'b0000010;
        6'b001000: cnt=7'b0000010;
        6'b010000: cnt=7'b0000010;
        6'b000011: cnt=7'b0000100;
        6'b000101: cnt=7'b0000100;
        6'b001001: cnt=7'b0000100;
        6'b010001: cnt=7'b0000100;
        6'b000110: cnt=7'b0000100;
        6'b001010: cnt=7'b0000100;
        6'b010010: cnt=7'b0000100;
        6'b001100: cnt=7'b0000100;
        6'b010100: cnt=7'b0000100;
        6'b011000: cnt=7'b0000100;
        6'b000111: cnt=7'b0001000;
        6'b001011: cnt=7'b0001000;
        6'b010011: cnt=7'b0001000;
        6'b001101: cnt=7'b0001000;
        6'b010101: cnt=7'b0001000;
        6'b011001: cnt=7'b0001000;
        6'b001110: cnt=7'b0001000;
        6'b010110: cnt=7'b0001000;
        6'b011010: cnt=7'b0001000;
        6'b011100: cnt=7'b0001000;
        6'b001111: cnt=7'b0010000;
        6'b010111: cnt=7'b0010000;
        6'b011011: cnt=7'b0010000;
        6'b011101: cnt=7'b0010000;
        6'b011110: cnt=7'b0010000;
        6'b011111: cnt=7'b0100000;

        6'b100000: cnt=7'b0000010;
        6'b100001: cnt=7'b0000100;
        6'b100010: cnt=7'b0000100;
        6'b100100: cnt=7'b0000100;
        6'b101000: cnt=7'b0000100;
        6'b110000: cnt=7'b0000100;
        6'b100011: cnt=7'b0001000;
        6'b100101: cnt=7'b0001000;
        6'b101001: cnt=7'b0001000;
        6'b110001: cnt=7'b0001000;
        6'b100110: cnt=7'b0001000;
        6'b101010: cnt=7'b0001000;
        6'b110010: cnt=7'b0001000;
        6'b101100: cnt=7'b0001000;
        6'b110100: cnt=7'b0001000;
        6'b111000: cnt=7'b0001000;
        6'b100111: cnt=7'b0010000;
        6'b101011: cnt=7'b0010000;
        6'b110011: cnt=7'b0010000;
        6'b101101: cnt=7'b0010000;
        6'b110101: cnt=7'b0010000;
        6'b111001: cnt=7'b0010000;
        6'b101110: cnt=7'b0010000;
        6'b110110: cnt=7'b0010000;
        6'b111010: cnt=7'b0010000;
        6'b111100: cnt=7'b0010000;
        6'b101111: cnt=7'b0100000;
        6'b110111: cnt=7'b0100000;
        6'b111011: cnt=7'b0100000;
        6'b111101: cnt=7'b0100000;
        6'b111110: cnt=7'b0100000;
        6'b111111: cnt=7'b1000000;
      endcase
    end
endmodule


module popcnt3(
  bits,
  cnt);

  input [2:0] bits;
  output pwire reg [3:0] cnt;
  
  always @* begin
      case(bits)
          3'b000: cnt=4'b1;
          3'b001,3'b010,3'b100: cnt=4'b10;
          3'b110,3'b101,3'b011: cnt=4'b100;
          3'b111: cnt=4'b1000;
      endcase
  end
endmodule

module popcnt3_or_more(
  bits,
  cnt);

  input [2:0] bits;
  output pwire reg [3:1] cnt;
  
  always @* begin
      case(bits)
          3'b000: cnt=3'b0;
          3'b001,3'b010,3'b100: cnt=3'b1;
          3'b110,3'b101,3'b011: cnt=3'b11;
          3'b111: cnt=3'b111;
      endcase
  end
endmodule


module popcnt10(
  bits,
  cnt);

  input [9:0] bits;
  output pwire [10:0] cnt;

  pwire [5:0] cntA;
  pwire [5:0] cntB;
  
  pwire [10:0] cnt_X;

  assign cnt=cnt_X;

  popcnt5 cntA_mod(bits[4:0],cntA);
  popcnt5 cntB_mod(bits[9:5],cntB);


  assign cnt_X=cntA[0] ? {5'b0,cntB} : 11'bz;
  assign cnt_X=cntA[1] ? {4'b0,cntB,1'b0} : 11'bz;
  assign cnt_X=cntA[2] ? {3'b0,cntB,2'b0} : 11'bz;
  assign cnt_X=cntA[3] ? {2'b0,cntB,3'b0} : 11'bz;
  assign cnt_X=cntA[4] ? {1'b0,cntB,4'b0} : 11'bz;
  assign cnt_X=cntA[5] ? {cntB,5'b0} : 11'bz;
  
endmodule


module popcnt15(
  bits,
  cnt);

  input [14:0] bits;
  output pwire [15:0] cnt;

  pwire [5:0] cntA;
  pwire [10:0] cntB;

  pwire [15:0] cnt_X;

  assign cnt=cnt_X;
  popcnt5 cntA_mod(bits[4:0],cntA);
  popcnt10 cntB_mod(bits[14:5],cntB);


  assign cnt_X=cntA[0] ? {5'b0,cntB} : 16'bz;
  assign cnt_X=cntA[1] ? {4'b0,cntB,1'b0} : 16'bz;
  assign cnt_X=cntA[2] ? {3'b0,cntB,2'b0} : 16'bz;
  assign cnt_X=cntA[3] ? {2'b0,cntB,3'b0} : 16'bz;
  assign cnt_X=cntA[4] ? {1'b0,cntB,4'b0} : 16'bz;
  assign cnt_X=cntA[5] ? {cntB,5'b0} : 16'bz;
  
endmodule

module popcnt20(
  bits,
  cnt);

  input [19:0] bits;
  output pwire [20:0] cnt;

  pwire [10:0] cntA;
  pwire [10:0] cntB;

  popcnt10 cntA_mod(bits[9:0],cntA);
  popcnt10 cntB_mod(bits[19:10],cntB);


  assign cnt=cntA[0] ? {10'b0,cntB} : 21'bz;
  assign cnt=cntA[1] ? {9'b0,cntB,1'b0} : 21'bz;
  assign cnt=cntA[2] ? {8'b0,cntB,2'b0} : 21'bz;
  assign cnt=cntA[3] ? {7'b0,cntB,3'b0} : 21'bz;
  assign cnt=cntA[4] ? {6'b0,cntB,4'b0} : 21'bz;
  assign cnt=cntA[5] ? {5'b0,cntB,5'b0} : 21'bz;
  assign cnt=cntA[6] ? {4'b0,cntB,6'b0} : 21'bz;
  assign cnt=cntA[7] ? {3'b0,cntB,7'b0} : 21'bz;
  assign cnt=cntA[8] ? {2'b0,cntB,8'b0} : 21'bz;
  assign cnt=cntA[9] ? {1'b0,cntB,9'b0} : 21'bz;
  assign cnt=cntA[10] ? {cntB,10'b0} : 21'bz;
  
endmodule

module popcnt16(
  bits,
  cnt);

  input [15:0] bits;
  output pwire [16:0] cnt;

  pwire [6:0] cntA;
  pwire [10:0] cntB;

  pwire [16:0] cnt_X;

  assign cnt=cnt_X;
  popcnt6 cntA_mod(bits[5:0],cntA);
  popcnt10 cntB_mod(bits[15:6],cntB);


  assign cnt_X=cntA[0] ? {6'b0,cntB} : 17'bz;
  assign cnt_X=cntA[1] ? {5'b0,cntB,1'b0} : 17'bz;
  assign cnt_X=cntA[2] ? {4'b0,cntB,2'b0} : 17'bz;
  assign cnt_X=cntA[3] ? {3'b0,cntB,3'b0} : 17'bz;
  assign cnt_X=cntA[4] ? {2'b0,cntB,4'b0} : 17'bz;
  assign cnt_X=cntA[5] ? {1'b0,cntB,5'b0} : 17'bz;
  assign cnt_X=cntA[6] ? {cntB,6'b0} : 17'bz;
  
endmodule



module popcnt5_or_less(
  bits,
  cnt);

  input [4:0] bits;
  output pwire reg [4:0] cnt;

  always @*
    begin
      case(bits)
        5'b00000: cnt=5'b11111;
        5'b00001: cnt=5'b11110;
        5'b00010: cnt=5'b11110;
        5'b00100: cnt=5'b11110;
        5'b01000: cnt=5'b11110;
        5'b10000: cnt=5'b11110;
        5'b00011: cnt=5'b11100;
        5'b00101: cnt=5'b11100;
        5'b01001: cnt=5'b11100;
        5'b10001: cnt=5'b11100;
        5'b00110: cnt=5'b11100;
        5'b01010: cnt=5'b11100;
        5'b10010: cnt=5'b11100;
        5'b01100: cnt=5'b11100;
        5'b10100: cnt=5'b11100;
        5'b11000: cnt=5'b11100;
        5'b00111: cnt=5'b11000;
        5'b01011: cnt=5'b11000;
        5'b10011: cnt=5'b11000;
        5'b01101: cnt=5'b11000;
        5'b10101: cnt=5'b11000;
        5'b11001: cnt=5'b11000;
        5'b01110: cnt=5'b11000;
        5'b10110: cnt=5'b11000;
        5'b11010: cnt=5'b11000;
        5'b11100: cnt=5'b11000;
        5'b01111: cnt=5'b10000;
        5'b10111: cnt=5'b10000;
        5'b11011: cnt=5'b10000;
        5'b11101: cnt=5'b10000;
        5'b11110: cnt=5'b10000;
        5'b11111: cnt=5'b00000;
      endcase
    end
endmodule



module popcnt10_or_less(
  bits,
  cnt);

  input [9:0] bits;
  output pwire [9:0] cnt;

  pwire [5:0] cntA;
  pwire [4:0] cntB;
  pwire [9:0] cnt_X;

  assign cnt=cnt_X;

  popcnt5 cntA_mod(bits[4:0],cntA);
  popcnt5_or_less cntB_mod(bits[9:5],cntB);


  assign cnt_X=cntA[0] ? {5'b11111,cntB} : 10'bz;
  assign cnt_X=cntA[1] ? {4'b1111,cntB,1'b0} : 10'bz;
  assign cnt_X=cntA[2] ? {3'b111,cntB,2'b0} : 10'bz;
  assign cnt_X=cntA[3] ? {2'b11,cntB,3'b0} : 10'bz;
  assign cnt_X=cntA[4] ? {1'b1,cntB,4'b0} : 10'bz;
  assign cnt_X=cntA[5] ? {cntB,5'b0} : 10'bz;
  
endmodule



module popcnt15_or_less(
  bits,
  cnt);

  input [14:0] bits;
  output pwire [14:0] cnt;

  pwire [5:0] cntA;
  pwire [9:0] cntB;
  pwire [14:0] cnt_X;

  assign cnt=cnt_X;

  popcnt5 cntA_mod(bits[4:0],cntA);
  popcnt10_or_less cntB_mod(bits[14:5],cntB);


  assign cnt_X=cntA[0] ? {5'b11111,cntB} : 15'bz;
  assign cnt_X=cntA[1] ? {4'b1111,cntB,1'b0} : 15'bz;
  assign cnt_X=cntA[2] ? {3'b111,cntB,2'b0} : 15'bz;
  assign cnt_X=cntA[3] ? {2'b11,cntB,3'b0} : 15'bz;
  assign cnt_X=cntA[4] ? {1'b1,cntB,4'b0} : 15'bz;
  assign cnt_X=cntA[5] ? {cntB,5'b0} : 15'bz;
  
endmodule

module popcnt20_or_less(
  bits,
  cnt);

  input [19:0] bits;
  output pwire [19:0] cnt;

  pwire [9:0] cntA;
  pwire [9:0] cntB;

  popcnt10 cntA_mod(bits[9:0],cntA);
  popcnt10_or_less cntB_mod(bits[19:10],cntB);


  assign cnt=cntA[0] ? {10'b1111111111,cntB} : 20'bz;
  assign cnt=cntA[1] ? {9'b111111111 ,cntB,1'b0} : 20'bz;
  assign cnt=cntA[2] ? {8'b11111111,cntB,2'b0} : 20'bz;
  assign cnt=cntA[3] ? {7'b1111111,cntB,3'b0} : 20'bz;
  assign cnt=cntA[4] ? {6'b111111,cntB,4'b0} : 20'bz;
  assign cnt=cntA[5] ? {5'b11111,cntB,5'b0} : 20'bz;
  assign cnt=cntA[6] ? {4'b1111,cntB,6'b0} : 20'bz;
  assign cnt=cntA[7] ? {3'b111,cntB,7'b0} : 20'bz;
  assign cnt=cntA[8] ? {2'b11,cntB,8'b0} : 20'bz;
  assign cnt=cntA[9] ? {1'b1,cntB,9'b0} : 20'bz;
  assign cnt=cntA[10] ? {cntB,10'b0} : 20'bz;
  
endmodule

module popcnt16_or_less(
  bits,
  cnt);

  input [15:0] bits;
  output pwire [15:0] cnt;

  pwire [6:0] cntA;
  pwire [9:0] cntB;
  pwire [15:0] cnt_X;

  assign cnt=cnt_X;

  popcnt6 cntA_mod(bits[5:0],cntA);
  popcnt10_or_less cntB_mod(bits[15:6],cntB);


  assign cnt_X=cntA[0] ? {6'b111111,cntB} : 16'bz;
  assign cnt_X=cntA[1] ? {5'b11111,cntB,1'b0} : 16'bz;
  assign cnt_X=cntA[2] ? {4'b1111,cntB,2'b0} : 16'bz;
  assign cnt_X=cntA[3] ? {3'b111,cntB,3'b0} : 16'bz;
  assign cnt_X=cntA[4] ? {2'b11,cntB,4'b0} : 16'bz;
  assign cnt_X=cntA[5] ? {1'b1,cntB,5'b0} : 16'bz;
  assign cnt_X=cntA[6] ? {cntB,6'b0} : 16'bz;
  
endmodule


module popcnt5_or_more(
  bits,
  cnt);

  input [4:0] bits;
  output pwire reg [5:1] cnt;

  always @*
    begin
      case(bits)
        5'b00000: cnt=5'b00000;
        5'b00001: cnt=5'b00001;
        5'b00010: cnt=5'b00001;
        5'b00100: cnt=5'b00001;
        5'b01000: cnt=5'b00001;
        5'b10000: cnt=5'b00001;
        5'b00011: cnt=5'b00011;
        5'b00101: cnt=5'b00011;
        5'b01001: cnt=5'b00011;
        5'b10001: cnt=5'b00011;
        5'b00110: cnt=5'b00011;
        5'b01010: cnt=5'b00011;
        5'b10010: cnt=5'b00011;
        5'b01100: cnt=5'b00011;
        5'b10100: cnt=5'b00011;
        5'b11000: cnt=5'b00011;
        5'b00111: cnt=5'b00111;
        5'b01011: cnt=5'b00111;
        5'b10011: cnt=5'b00111;
        5'b01101: cnt=5'b00111;
        5'b10101: cnt=5'b00111;
        5'b11001: cnt=5'b00111;
        5'b01110: cnt=5'b00111;
        5'b10110: cnt=5'b00111;
        5'b11010: cnt=5'b00111;
        5'b11100: cnt=5'b00111;
        5'b01111: cnt=5'b01111;
        5'b10111: cnt=5'b01111;
        5'b11011: cnt=5'b01111;
        5'b11101: cnt=5'b01111;
        5'b11110: cnt=5'b01111;
        5'b11111: cnt=5'b11111;
      endcase
    end
endmodule



module popcnt10_or_more(
  bits,
  cnt);

  input [9:0] bits;
  output pwire [9:0] cnt;

  pwire [5:0] cntA;
  pwire [5:1] cntB;
  pwire [9:0] cnt_X;

  assign cnt=cnt_X;

  popcnt5 cntA_mod(bits[4:0],cntA);
  popcnt5_or_more cntB_mod(bits[9:5],cntB);


  assign cnt_X=cntA[0] ? {5'b0,cntB} : 10'bz;
  assign cnt_X=cntA[1] ? {4'b0,cntB,1'b1} : 10'bz;
  assign cnt_X=cntA[2] ? {3'b0,cntB,2'b11} : 10'bz;
  assign cnt_X=cntA[3] ? {2'b0,cntB,3'b111} : 10'bz;
  assign cnt_X=cntA[4] ? {1'b0,cntB,4'b1111} : 10'bz;
  assign cnt_X=cntA[5] ? {cntB,5'b11111} : 10'bz;
  
endmodule



module popcnt15_or_more(
  bits,
  cnt);

  input [14:0] bits;
  output pwire [14:0] cnt;

  pwire [5:0] cntA;
  pwire [10:1] cntB;
  pwire [14:0] cnt_X;

  assign cnt=cnt_X;

  popcnt5 cntA_mod(bits[4:0],cntA);
  popcnt10_or_more cntB_mod(bits[14:5],cntB);


  assign cnt_X=cntA[0] ? {5'b0,cntB} : 15'bz;
  assign cnt_X=cntA[1] ? {4'b0,cntB,1'b1} : 15'bz;
  assign cnt_X=cntA[2] ? {3'b0,cntB,2'b11} : 15'bz;
  assign cnt_X=cntA[3] ? {2'b0,cntB,3'b111} : 15'bz;
  assign cnt_X=cntA[4] ? {1'b0,cntB,4'b1111} : 15'bz;
  assign cnt_X=cntA[5] ? {cntB,5'b11111} : 15'bz;
  
endmodule


module popcnt20_or_more(
  bits,
  cnt);

  input [19:0] bits;
  output pwire [19:0] cnt;

  pwire [10:0] cntA;
  pwire [10:1] cntB;

  popcnt10 cntA_mod(bits[9:0],cntA);
  popcnt10_or_more cntB_mod(bits[19:10],cntB);


  assign cnt=cntA[0] ? {10'b0,cntB} : 20'bz;
  assign cnt=cntA[1] ? {9'b0,cntB,1'b1} : 20'bz;
  assign cnt=cntA[2] ? {8'b0,cntB,2'b11} : 20'bz;
  assign cnt=cntA[3] ? {7'b0,cntB,3'b111} : 20'bz;
  assign cnt=cntA[4] ? {6'b0,cntB,4'b1111} : 20'bz;
  assign cnt=cntA[5] ? {5'b0,cntB,5'b11111} : 20'bz;
  assign cnt=cntA[6] ? {4'b0,cntB,6'b111111} : 20'bz;
  assign cnt=cntA[7] ? {3'b0,cntB,7'b1111111} : 20'bz;
  assign cnt=cntA[8] ? {2'b0,cntB,8'b11111111} : 20'bz;
  assign cnt=cntA[9] ? {1'b0,cntB,9'b111111111} : 20'bz;
  assign cnt=cntA[10] ? {cntB,10'b1111111111} : 20'bz;
  
endmodule


module popcnt16_or_more(
  bits,
  cnt);

  input [15:0] bits;
  output pwire [15:0] cnt;

  pwire [6:0] cntA;
  pwire [10:1] cntB;
  pwire [15:0] cnt_X;

  assign cnt=cnt_X;

  popcnt6 cntA_mod(bits[5:0],cntA);
  popcnt10_or_more cntB_mod(bits[15:6],cntB);


  assign cnt_X=cntA[0] ? {6'b0,cntB} : 16'bz;
  assign cnt_X=cntA[1] ? {5'b0,cntB,1'b1} : 16'bz;
  assign cnt_X=cntA[2] ? {4'b0,cntB,2'b11} : 16'bz;
  assign cnt_X=cntA[3] ? {3'b0,cntB,3'b111} : 16'bz;
  assign cnt_X=cntA[4] ? {2'b0,cntB,4'b1111} : 16'bz;
  assign cnt_X=cntA[5] ? {1'b0,cntB,5'b11111} : 16'bz;
  assign cnt_X=cntA[6] ? {cntB,6'b111111} : 16'bz;
  
endmodule


