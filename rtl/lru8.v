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


module lru_single0(
  lru,
  newLRU,
  LRU_hit,
  init,
  en
  );
  parameter WIDTH=3;
  parameter [WIDTH-1:0] INITVAL=0;
  
  input pwire [WIDTH-1:0] lru;
  output pwire [WIDTH-1:0] newLRU;
  input pwire [WIDTH-1:0] LRU_hit;
  input pwire init;
  input pwire en;
  
  pwire [WIDTH-1:0] newLRU_X;
  assign newLRU=newLRU_X;
  
  pwire hitThis;
  pwire hitThisOrAfter;
  pwire hitBefore;
  pwire hitAfter;
  pwire [WIDTH-1:0] lru_next;
  
  assign hitThis=LRU_hit==lru;
  assign hitAfter=hitThisOrAfter & ~hitThis;
  assign hitBefore=~hitThisOrAfter;
  
  assign newLRU_X=(hitThis & ~init &en) ? {WIDTH{1'B0}} : 'z;
  assign newLRU_X=(hitAfter & ~init &en) ? lru : 'z;
  assign newLRU_X=(hitBefore & ~init &en)? lru_next : 'z;
  assign newLRU_X=init ? INITVAL : 'z;
  assign newLRU_X=(~en & ~init) ? lru : 'z;
  
  generate
      if (WIDTH>1) begin : adders_gen
          get_carry #(WIDTH) cmp_mod (lru,~LRU_hit,1'b1,hitThisOrAfter);   
          adder_inc #(WIDTH) inc_mod (lru,lru_next,1'b1,);
      end else begin
          assign hitThisOrAfter=lru|~LRU_hit;
          assign lru_next=~lru;
      end
  endgenerate
endmodule


module lru_single(
//save gate delay
  lru,
  newLRU,
  LRU_hit,
  init,
  en
  );
  parameter WIDTH=2;
  parameter [WIDTH-1:0] INITVAL=0;
  localparam COUNT=1<<WIDTH;
  
  input pwire [WIDTH-1:0] lru;
  output pwire [WIDTH-1:0] newLRU;
  input pwire [WIDTH-1:0] LRU_hit;
  input pwire init;
  input pwire en;

  pwire [COUNT-1:0][WIDTH-1:0] newLRUa;
  pwire [WIDTH-1:0] newLRU_X;

  assign newLRU=newLRU_X;
  
  genvar k;
  
  generate
    for(k=0;k<COUNT;k=k+1)
	  begin : lru_gen
        lru_single0 #(WIDTH,INITVAL) lru_mod(
        lru,
        newLRUa[k],
        k[WIDTH-1:0],
        init,
        en
        );	
        assign newLRU_X= (LRU_hit==k && ~init)  ? newLRUa[k] : 'z;		
	  end
  endgenerate
  
  assign newLRU_X=init ? INITVAL : 'z;
  
endmodule



module lru_double(
  lru,
  newLRU,
  LRU_hitA,
  LRU_hitB,
  isDouble,
  init,
  en
  );
  parameter WIDTH=3;
  parameter [WIDTH-1:0] INITVAL=0;
  
  input pwire [WIDTH-1:0] lru;
  output pwire [WIDTH-1:0] newLRU;
  input pwire [WIDTH-1:0] LRU_hitA;
  input pwire [WIDTH-1:0] LRU_hitB;
  input pwire isDouble;
  input pwire init;
  input pwire en;
  
  pwire hitThisA;
  pwire hitThisB;
  pwire hitThisOrAfterA;
  pwire hitThisOrAfterB;
  pwire hitBefore1;
  pwire hitBefore2;
  pwire hitAfter;
  pwire [WIDTH-1:0] lru_next;
  pwire [WIDTH-1:0] lru_next2;
  
  assign hitThisA=LRU_hitA==lru;
  assign hitThisB=LRU_hitB==lru;
  assign hitAfter=hitThisOrAfterA & ~hitThisA && (hitThisOrAfterB & ~hitThisB) | ~isDouble;
  assign hitBefore1=~hitThisOrAfterA ^ (~hitThisOrAfterB & isDouble);
  assign hitBefore2=~hitThisOrAfterA & ~hitThisOrAfterB & isDouble;
  
  assign newLRU=(hitThisA & ~init &en) ? {WIDTH{1'B0}} : 'z;
  assign newLRU=(hitThisB & ~init &en & isDouble) ? 1 : 'z;

  assign newLRU=(hitAfter & ~init &en) ? lru : 'z;
  assign newLRU=(hitBefore1 & ~init &en)? lru_next : 'z;
  assign newLRU=(hitBefore2 & ~init &en)? lru_next2 : 'z;
  assign newLRU=init ? INITVAL : 'z;
  assign newLRU=(~en & ~init) ? lru : 'z;
  
  assign lru_next2[0]=lru[0];
  
  get_carry #(WIDTH) cmpA_mod (LRU_hitA,~lru,1'b1,hitThisOrAfterA);   
  get_carry #(WIDTH) cmpB_mod (LRU_hitB,~lru,1'b1,hitThisOrAfterB);   

  adder_inc #(WIDTH) incA_mod (lru,lru_next,1'b1,);
  adder_inc #(WIDTH-1) incB_mod (lru[WIDTH-1:1],lru_next2[WIDTH-1:1],1'b1,);

endmodule

