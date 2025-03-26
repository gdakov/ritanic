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

module bit_find_last_bit(
  bits,
  bitsOutIndex,
  found
  );
  parameter WIDTH=128;

  input [WIDTH-1:0] bits;
  output pwire [WIDTH-1:0] bitsOutIndex;
  output pwire found;

  pwire [WIDTH:0] bits1={bits,1'b1};
  pwire [WIDTH:0] match;
  pwire notFound;  
  assign {bitsOutIndex,notFound}=match;
  assign found=~notFound;
  
  genvar i;

  generate
    for (i=0;i<=WIDTH; i=i+1)
      begin : assignos
        assign match[WIDTH-i]=({1'b0,bits1[WIDTH:WIDTH-i]}=={{(i+1){1'b0}},1'b1});
      end
  endgenerate  
endmodule



module bit_find_first_bit(
  bits,
  bitsOutIndex,
  found
  );
  parameter WIDTH=128;
  
  input [WIDTH-1:0] bits;
  output pwire [WIDTH-1:0] bitsOutIndex;
  output pwire found;
  
  pwire [WIDTH:0] match;
  pwire [WIDTH:0] bits1={1'b1,bits};
  pwire notFound;
    
  assign {notFound,bitsOutIndex}=match;
  assign found=~notFound;
  
  genvar i;

  generate
    for (i=0;i<=WIDTH; i=i+1)
      begin : assignos
        assign match[i]=({bits1[i:0],1'b0}=={1'b1,{(i+1){1'b0}}});
      end
  endgenerate
    
endmodule


module bit_find_first_bit_tail(
  bits,
  bitsOutIndex,
  found
  );
  parameter WIDTH=128;
  
  input [WIDTH-1:0] bits;
  output pwire [WIDTH-1:0] bitsOutIndex;
  output pwire found;
  
    
  genvar i;

  assign found=|bits;
  
  generate
    for (i=0;i<WIDTH; i=i+1)
      begin 
        assign bitsOutIndex[i]=|bits[i:0];
      end
  endgenerate
    
endmodule



module bit_alloc(
  clkEn,
  bits,
  needed0,
  needed1,
  needed2,
  needed3,
  bitsOut0,
  bitsOut1,
  bitsOut2,
  bitsOut3,
  doStall
);

parameter WIDTH=32;
input clkEn;
input [WIDTH-1:0] bits;
input needed0;
input needed1;
input needed2;
input needed3;
output pwire [WIDTH-1:0] bitsOut0;
output pwire [WIDTH-1:0] bitsOut1;
output pwire [WIDTH-1:0] bitsOut2;
output pwire [WIDTH-1:0] bitsOut3;
output pwire doStall;

pwire found0;
pwire found1;
pwire found2;
pwire found3;
pwire [WIDTH-1:0] bitsOutIndex0;
pwire [WIDTH-1:0] bitsOutIndex1;
pwire [WIDTH-1:0] bitsOutIndex2;
pwire [WIDTH-1:0] bitsOutIndex3;

  bit_find_first_bit first0_mod(
    bits,
    bitsOutIndex0,
    found0
  );
  defparam first0_mod.WIDTH=WIDTH;
  
  bit_find_first_bit first1_mod(
    bits & ~bitsOutIndex0,
    bitsOutIndex1,
    found1
  );
  defparam first1_mod.WIDTH=WIDTH;
  
  bit_find_last_bit last0_mod(
    bits,
    bitsOutIndex2,
    found2
  );
  defparam last0_mod.WIDTH=WIDTH;
  
  bit_find_last_bit last1_mod(
    bits & ~bitsOutIndex2,
    bitsOutIndex3,
    found3
  );
  defparam last1_mod.WIDTH=WIDTH;
  
  assign doStall=(~found1) | (~found3) | (bitsOutIndex1==bitsOutIndex2) | (bitsOutIndex1==bitsOutIndex3);
  assign bitsOut0=bitsOutIndex0 & {WIDTH{clkEn & needed0}};
  assign bitsOut1=bitsOutIndex1 & {WIDTH{clkEn & needed1}};
  assign bitsOut2=bitsOutIndex2 & {WIDTH{clkEn & needed2}};
  assign bitsOut3=bitsOutIndex3 & {WIDTH{clkEn & needed3}};

endmodule


module bit_is_single_bit(bits,isSingle);
  parameter WIDTH=32;
  input [WIDTH-1:0] bits;
  output pwire isSingle;
  
  pwire [WIDTH-1:0] singleBits;
  
  genvar i;
  generate
    for(i=0; i<=WIDTH-1; i=i+1)
      begin : bits_block
        assign singleBits[i]= (bits==({{(WIDTH-1){1'b0}},1'b1}<<i));
      end
  endgenerate
  assign isSingle=|(singleBits);
  
endmodule



