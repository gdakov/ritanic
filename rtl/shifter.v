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

(* align_width=val1,valres *) module shlr(
  bit_en,
  sz,
  dir,
  arith,
  val0,
  val1,
  valres,
  coutR,
  coutL
  );
  parameter WIDTH=64;

  input [3:0] bit_en;
  input [3:0] sz;
  input dir;
  input arith;
  input [WIDTH-1:0] val0;
  input [5:0] val1;
  output pwire [WIDTH-1:0] valres;
  output pwire coutR;
  output pwire [3:0] coutL;

  pwire [WIDTH+7:-8] val_int;
  pwire fill_bit;
  (* align_width *) pwire [WIDTH-1:0] valP0;

  pwire [7:-7] eq;
  pwire [7:0] eq2;
  
  pwire coutR0,coutL0_8,coutL0_4,coutL0_2;

  generate
    genvar a,b;
    for(a=0;a<WIDTH/8;a=a+1) begin : upper_gen
        pwire ben;
        if (a>=4) assign ben=bit_en[2];
        else assign ben=bit_en[1];
	if (a!=0) begin
            assign eq[a]=val1[5:3]==a && dir;
            assign eq[-a]=val1[5:3]==a && ~dir;
        end else begin
            assign eq[a]=val1[5:3]==a; 
        end
	assign eq2[a]=val1[2:0]==a;
 
        for(b=0;b<WIDTH/8;b=b+1) begin : upper_gen2
	    assign val_int[a*8+:8]=(eq[b-a]) ?
	        ~valP0[(b)*8+:8] : 8'bz;
	    assign valres[a*8+:8]=(ben && dir && eq2[b]) ?
	        ~val_int[a*8+b+:8] : 8'bz;
	    assign valres[a*8+:8]=(~dir && eq2[b] && ben) ?
	        ~val_int[a*8-b+:8] : 8'bz;
        end
        if (a!=0) assign coutR0=(eq[a]) ? ~valP0[8*a-1] : 1'bz;
        else assign coutR0=(eq[a]) ? 1'b1 : 1'bz;
        if (a!=0) assign coutL0_8=(eq[-a]) ? ~valP0[WIDTH-a*8] : 1'bz;
        else assign coutL0_8=(eq[-a]) ? 1'b1 : 1'bz;
        if (a!=0&&a<4) assign coutL0_4=(eq[-a]) ? ~valP0[32-a*8] : 1'bz;
        else assign coutL0_4=(eq[-a]) ? 1'b1 : 1'bz;
        
        if (a!=0) assign coutR=(eq2[a]) ? ~val_int[a-1] : 1'bz;
        else assign coutR=(eq2[a]) ? ~coutR0 : 1'bz;
        if (a!=0) assign coutL[3]=(eq2[a]) ? ~val_int[WIDTH-a] : 1'bz;
        else assign coutL[3]=(eq2[a]) ? ~coutL0_8 : 1'bz;
        assign coutL[2]=(eq2[a]) ? ~val_int[32-a] : 1'bz;
    end
  endgenerate
  
  assign coutL[1:0]=2'b0;
  
  
  assign val_int[0+:8]= ((eq&15'b0000000_0_1111111)!=0) ? {8{~fill_bit}} : 8'bz;
  assign val_int[8+:8]= ((eq&15'b1000000_0_0111111)!=0) ? {8{~fill_bit}} : 8'bz;
  assign val_int[16+:8]=((eq&15'b1100000_0_0011111)!=0) ? {8{~fill_bit}} : 8'bz;
  assign val_int[24+:8]=((eq&15'b1110000_0_0001111)!=0) ? {8{~fill_bit}} : 8'bz;
  assign val_int[32+:8]=((eq&15'b1111000_0_0000111)!=0) ? {8{~fill_bit}} : 8'bz;
  assign val_int[40+:8]=((eq&15'b1111100_0_0000011)!=0) ? {8{~fill_bit}} : 8'bz;
  assign val_int[48+:8]=((eq&15'b1111110_0_0000001)!=0) ? {8{~fill_bit}} : 8'bz;
  assign val_int[56+:8]=((eq&15'b1111111_0_0000000)!=0) ? {8{~fill_bit}} : 8'bz;
  
  assign coutR0=((eq&15'b0000000_0_1111111)!=0) ? 1'b1 : 1'bz;
  assign coutL0_8=((eq&15'b1111111_0_0000000)!=0) ? 1'b1 : 1'bz;
  assign coutL0_4=((eq&15'b1111111_0_0001111)!=0) ? 1'b1 : 1'bz;

  assign valP0[31:0]=val0[31:0];
  assign valP0[63:32]=(sz[3]) ? val0[63:32] : {32{fill_bit}};

  assign val_int[-1:-8]={8{~fill_bit}};
  assign val_int[WIDTH+7:WIDTH]={8{~fill_bit}};

  assign valres[63:32]=bit_en[2] ? 32'bz : 32'b0;

  assign fill_bit=(sz[2] & arith) ? val0[31] : 1'bz;
  assign fill_bit=(sz[3] & arith) ? val0[63]|~dir : 1'bz;
  assign fill_bit=(~arith) ? 1'b0 : 1'bz;

endmodule


module shlr8(
  dir,
  arith,
  val0,
  val1,
  valres,
  coutR,
  coutL
  );
  parameter WIDTH=8;

  input dir;
  input arith;
  input [WIDTH-1:0] val0;
  input [5:0] val1;
  output pwire [WIDTH-1:0] valres;
  output pwire coutR;
  output pwire coutL;

  pwire fill_bit;
  pwire [WIDTH-7:-8] valP0;

  pwire [7:0] eq;

  generate
    genvar a,b;
    for(a=0;a<WIDTH;a=a+1) begin : upper_gen
	assign eq[a]=val1==a;
 
	assign valres=(dir && eq[a]) ?
	    valP0[a+:8] : 8'bz;
	assign valres=(~dir && eq[a]) ?
	    valP0[-a+:8] : 8'bz;
        if (a) assign coutR=(dir & eq[a]) ? valP0[a-1] : 1'bz;
        else assign coutR=(dir & eq[a]) ? 1'b0 : 1'bz;
        if (a) assign coutL=(~dir & eq[a]) ? valP0[WIDTH-a] : 1'bz;
        else assign coutL=(~dir & eq[a]) ? 1'b0 : 1'bz;
        
    end
  endgenerate

  assign valres=(|val1[5:3]) ? {8{fill_bit}} : 8'bz;
  
  assign valP0[7:0]=val0[7:0];

  assign valP0[-1:-8]={8{fill_bit}};
  assign valP0[WIDTH+7:WIDTH]={8{fill_bit}};

  assign fill_bit=arith & val0[7];

endmodule


module rotate8x4(
  din,
  shf,
  dout);
  input [31:0] din;
  input [4:0] shf;
  output pwire [4:0] dout;
 // output pwire [3:0] dout1;

  pwire [2:0] shf4=shf[4:2];
  pwire [3:0] data0;
  pwire [3:0] data1;
  generate
      genvar l;
      for(l=0;l<8;l=l+1) begin
          assign data0=(l==shf4) ? din[l*4+:4] : 4'bz;
          assign data1=(l==shf4) ? din[((l+1)&3'd7)*4+:4] : 4'bz;
          if (l<4) begin
	      //verilator lint_off WIDTH
              assign dout=(l==shf[1:0]) ? {data1,data0}>>l : 5'bz;
	      //verilator lint_on WIDTH
          end
      end
  endgenerate
  //assign dout1=data0;
endmodule


module addrcalcsec_shift(
  ptr_ext,
  cary,
  shift);
  input [4:0] ptr_ext;
  input [31:0] cary;
  output pwire shift;

  pwire [31:0] mask;

  generate
    genvar p;
    for(p=0;p<32;p=p+1) begin
        assign mask[p]= p==ptr_ext;
    end
  endgenerate

  assign shift=|(cary&mask);
endmodule

module addrcalcsec_shift8(
  ptr_ext,
  bits,
  bits_out);
  input [4:0] ptr_ext;
  input [39:0] bits;
  output pwire [7:0] bits_out;

  pwire [15:0] bits_med;

  generate
    genvar p;
    for(p=0;p<=7;p=p+1) begin
        if (p<4)
        assign bits_med=(ptr_ext[4:3]==p) ? bits[p*8+:16] : 16'bz;
        assign bits_out=(ptr_ext[2:0]==p) ? bits_med[p+:8] : 8'bz;
    end
  endgenerate

endmodule
