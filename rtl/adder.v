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


module aoi21_array(a11,a12,a2,b);
  parameter WIDTH=1;
  input [WIDTH-1:0] a11;
  input [WIDTH-1:0] a12;
  input [WIDTH-1:0] a2;
  output [WIDTH-1:0] b;

  assign b=((a11 & a12)|a2);

endmodule

module oai21_array(a11,a12,a2,b);
  parameter WIDTH=1;
  input [WIDTH-1:0] a11;
  input [WIDTH-1:0] a12;
  input [WIDTH-1:0] a2;
  output [WIDTH-1:0] b;

  assign b=((a11 & a12)|a2);

endmodule

module nor_array(a1,a2,b);
  parameter WIDTH=1;
  input [WIDTH-1:0] a1;
  input [WIDTH-1:0] a2;
  output [WIDTH-1:0] b;

  assign b=~(a1 | a2);

endmodule

module nand_array(a1,a2,b);
  parameter WIDTH=1;
  input [WIDTH-1:0] a1;
  input [WIDTH-1:0] a2;
  output [WIDTH-1:0] b;

  assign b=~(a1 & a2);

endmodule

module xor_array(a1,a2,b);
  parameter WIDTH=1;
  input [WIDTH-1:0] a1;
  input [WIDTH-1:0] a2;
  output [WIDTH-1:0] b;

  assign b=a1 ^ a2;

endmodule

module nxor_array(a1,a2,b);
  parameter WIDTH=1;
  input [WIDTH-1:0] a1;
  input [WIDTH-1:0] a2;
  output [WIDTH-1:0] b;

  assign b=a1 ~^ a2;

endmodule

module not_array(a,b);
  parameter WIDTH=1;
  input [WIDTH-1:0] a;
  output [WIDTH-1:0] b;

  assign b=a;

endmodule

(* align_width="a,b,nP0,nG0,out" *) module adder_seq(a,b,nP0,nG0,out,c_s,cin,en,cout,cout8,cout16,cout32);
  parameter WIDTH=44;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out;
  output [43:0] c_s;
  input cin;
  input en;
  output cout;
  output cout8;
  output cout16;
  output cout32;
  
  input [WIDTH-1:0] nP0;
  input [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;

  assign c_s=C[43:0];
 
  
  genvar i;
  
  
  xor_array #(WIDTH) x_mod(a,b,X);
  nxor_array #(WIDTH) nx_mod(a,b,nX);

  assign C1={C[WIDTH-2:0],cin};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (cin,nC1[0]);
  
  assign cout=C[WIDTH-1];
  
  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out[i]=(X[i] & en) ? ~C1[i] : 1'bz;
        assign out[i]=(nX[i] & en) ? ~nC1[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nC_mod(P7,{WIDTH{cin}},G7,nC[WIDTH-1:0]);
        not_array #(WIDTH) C_mod(nC,C);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end
      
    if (WIDTH>=8) assign cout8=C[7];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
    
  endgenerate
  
     
endmodule

(* align_width="a,b,out" *) module adder(a,b,out,cin,en,cout,cout8,cout16,cout32);
  parameter WIDTH=32;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out;
  input cin;
  input en;
  output cout;
  output cout8;
  output cout16;
  output cout32;


  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;

  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;


  genvar i;

  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);

  xor_array #(WIDTH) x_mod(a,b,X);
  nxor_array #(WIDTH) nx_mod(a,b,nX);

  assign C1={C[WIDTH-2:0],cin};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (cin,nC1[0]);

  assign cout=C[WIDTH-1];


  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out[i]=(X[i] & en) ? ~C1[i] : 1'bz;
        assign out[i]=(nX[i] & en) ? ~nC1[i] : 1'bz;
      end
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        //nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        //not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        //oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        //not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        oai21_array #(64) nC_mod(nP6[63:0],{64{~cin}},nG6[63:0],C[63:0]);
        not_array #(64) C_mod(C[63:0],nC[63:0]);
        oai21_array #(WIDTH-64) nCx_mod(nP6[WIDTH-1:64],{WIDTH-64{nC[63]}},nG6[WIDTH-1:64],C[WIDTH-1:64]);
        not_array #(WIDTH-64) Cx_mod(C[WIDTH-1:64],nC[WIDTH-1:64]);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end

    if (WIDTH>=8) assign cout8=C[7];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;

  endgenerate


endmodule


(* align_width="a,b,out" *) module adder_15_11(a,b,out,cin,en,cout,cout11,cout16,cout32);
  parameter WIDTH=32;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out;
  input cin;
  input en;
  output cout;
  output cout11;
  output cout16;
  output cout32;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;
 
  
  genvar i;
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  
  xor_array #(WIDTH) x_mod(a,b,X);
  nxor_array #(WIDTH) nx_mod(a,b,nX);

  assign C1={C[WIDTH-2:0],cin};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (cin,nC1[0]);
  
  assign cout=C[WIDTH-1];

  
  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out[i]=(X[i] & en) ? ~C1[i] : 1'bz;
        assign out[i]=(nX[i] & en) ? ~nC1[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        //nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        //not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        //oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        //not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        oai21_array #(64) nC_mod(nP6[63:0],{64{~cin}},nG6[63:0],C[63:0]);
        not_array #(64) C_mod(C[63:0],nC[63:0]);
        oai21_array #(WIDTH-64) nCx_mod(nP6[WIDTH-1:64],{WIDTH-64{nC[63]}},nG6[WIDTH-1:64],C[WIDTH-1:64]);
        not_array #(WIDTH-64) Cx_mod(C[WIDTH-1:64],nC[WIDTH-1:64]);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end
      
    if (WIDTH>=11) assign cout8=C[10];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
    
  endgenerate
  
     
endmodule

(* align_width="a,b,out" *) module addsub_alu0(a,b,out,sub,en,ben,cout,cout4,cout8,cout16,cout32);
  parameter WIDTH=64;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out;
  input sub;
  input en;
  input [3:0] ben;
  output cout;
  output cout4;
  output cout8;
  output cout16;
  output cout32;
  
  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1;//carry in
  wire [WIDTH-1:0] nC1;
 
  wire [WIDTH-1:0] xb;

  wire [WIDTH-1:0] bitEn;

  wire exp;
  
  wire cin;
  
  genvar i;
  
  assign bitEn={{32{ben[3]&en}},{16{ben[2]&en}},{8{ben[1]&en}},{8{ben[0]&en}}};
  
  
  assign cin=sub;
  
  nand_array #(WIDTH) nG0_mod(a,xb,nG0);
  nor_array #(WIDTH)  nP0_mod(a,xb,nP0);
  
  xor_array #(WIDTH) X_mod (a,xb,X);
  nxor_array #(WIDTH) nX_mod (a,xb,nX);

  assign C1={C[WIDTH-2:0],sub};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (sub,nC1[0]);
  
  assign cout=C[WIDTH-1];
  xor_array #(WIDTH) sub_mod (b,{WIDTH{sub}},xb);
  
  generate
        
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out[i]=(X[i] & bitEn[i]) ? ~C1[i] : 1'bz;
        assign out[i]=(nX[i] & bitEn[i]) ? ~nC1[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nC_mod(P7,{WIDTH{cin}},G7,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end
    else if (WIDTH>32)
      begin
        oai21_array #(32) C_mod(nP6[31:0],{32{~cin}},nG6[31:0],C[31:0]);
        not_array #(32) nC_mod(C[31:0],nC[31:0]);
        oai21_array #(WIDTH-32) Cx_mod(nP6[WIDTH-1:32],{32{nC[31]}},nG6[WIDTH-1:32],C[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(C[WIDTH-1:32],nC[WIDTH-1:32]);
      end
      
    if (WIDTH>=4) assign cout4=C[3];
    else assign cout4=1'b0;

    if (WIDTH>=8) assign cout8=C[7];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
	
	if (WIDTH==64)
	  begin
	    assign out[63:32]=(en&~ben[3]&ben[2]) ? 32'b0:32'bz; 
	    assign out[63:32]=(en&~ben[3]&~ben[2]) ? a[63:32]:32'bz; 
	    assign out[31:16]=(en&~ben[3]&~ben[2]) ? a[31:16]:16'bz; 
	    assign out[15:8]=(en&~ben[2]&~ben[1]) ? a[15:8]:8'bz; 
	  end
    
  endgenerate
  
     
endmodule





(* align_width="a,b,out" *) module addsub_alu(a,b,out,sub,cin,en,sxtEn,pooh,ben,cout,cout4,cout8LL,cout16,cout32,cout_sec,ndiff,cout44);
  parameter WIDTH=64;
  input [64:0] a;
  input [64:0] b;
  output [65:0] out;
  input [5:0] sub;
  input cin;
  input en;
  input sxtEn;
  input pooh;
  input [1:0] ben;
  output cout;
  output cout4;
  output cout8LL;
  output cout16;
  output cout32;
  output [2:0] cout_sec;
  output ndiff;
  output cout44;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  wire [WIDTH-1:0] X1;
  wire [WIDTH-1:0] nX1;
  
  wire [WIDTH-1:0] C1;//carry in
  wire [WIDTH-1:0] nC1;
 
  wire [WIDTH-1:0] xb;
  wire [WIDTH-1:0] xa;

  wire [WIDTH-1:0] bitEn;

  wire [39:0] unptr;
  wire [64:0] ptr;
  wire [3:0] pos_ack;
  wire [3:0] neg_ack;
  wire [2:0] pos_flip;
  wire [2:0] neg_flip;
  wire cout_sec0;
  wire [19:0] exbits;
  wire [11:0] exbits2;
  wire is_ptr;
  wire err;

  wire [2:0] pos_flip;
  wire [2:0] neg_flip;

  wire exp;
  wire ndiff;
  
  wire cin;
  
  genvar i;
  
  assign bitEn={{21{ben[1]&en}},{11{ben[0]&en}},{16{en}},{8{ben[-1]&en}},{8{ben[-2]&en}}};
  
  

  assign ptr=b[64] && ~sub[1] ? b[63:0] : a[63:0];
  assign unptr=b[64] && ~sub[1] ? xa[43:4] : xb[43:4];
  
  assign cout_sec[0]=pos_ack[{1'b0,cout_sec0}] | neg_ack[{1'b0,cout_sec0}] && ~err;
  assign cout_sec[1]=pos_ack[3] & ~err;
  assign cout_sec[2]=neg_ack[3] & ~err;

  assign err=a[64] & b[64] & ~sub[1] || ~a[64] & b[64] & sub[1] || a[64] & ~sub[3] || b[64] & ~sub[0];

  assign is_ptr=a[64]|b[64] && ~(a[64]&b[64]&sub[1]) && ben==2'b01;

  assign out[64]=en ? is_ptr : 1'bz;
  assign out[65]=en ? ^out[64:0] : 1'bz;
//65th bit offset by 4 phases in regfile and alu!
  /* magic voodo adder trickery to get sign extend with no extra delay.
     forwarder does set upper bits A=all0 B=all1 to make it all carry propagate.
     Then we only need to boost and shift the X and nX values which takes no extra delay.
     Not completely free- probably one row of cells increase.
  */

  assign X1=sxtEn ? {{32{X[31]}},X[31:0]} : X;
  assign nX1=sxtEn ? {{32{nX[31]}},nX[31:0]} : nX;

  assign exbits=is_ptr ? ptr[63:44]: ~&ben[-1:-2] ? a[63:44] : 20'b0;

  assign exbits2=~&ben[-1:2] ? a[43:32] : 12'b0;;

  addrcalcsec_shift nih_mod(ptr[`ptr_exp],C[41:10],cout_sec0);
  addrcalcsec_check_upper3 hin_mod(ptr,{unptr[43:11],1'b0},33'b0,pos_ack,neg_ack,pos_flip,neg_flip,
    ndiff);
  
  nand_array #(WIDTH) nG0_mod(xa[63:0],xb,nG0);
  nor_array #(WIDTH)  nP0_mod(xa[63:0],xb,nP0);
  
  xor_array #(WIDTH) X_mod (xa[63:0],xb,X);
  nxor_array #(WIDTH) nX_mod (xa[63:0],xb,nX);

  assign C1={C[WIDTH-2:0],sub[1]};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (sub[1],nC1[0]);
  
  assign cout=C[WIDTH-1];
 
  assign xb=sub[0] ? b[63:0] : 64'bz; 
  assign xb=sub[1] ? ~b[63:0] : 64'bz; 
  assign xb=sub[2] ? {b[62:0],1'b0} : 64'bz; 
  assign xa=sub[3] ? a[63:0] : 64'bz;
  assign xa=sub[4] ? {a[61:0],2'b0} : 64'bz;
  assign xa=sub[5] ? {a[60:0],3'b0} : 64'bz;



  generate
        
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out[i]=(X1[i] & bitEn[i]) ? ~C1[i] : 1'bz;
        assign out[i]=(nX1[i] & bitEn[i]) ? ~nC1[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(32) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(32) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nC_mod(P7,{WIDTH{cin}},G7,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end
      
    if (WIDTH>=4) assign cout4=C[3];
    else assign cout4=1'b0;

    if (WIDTH>=8) assign cout8LL=C[7];
    else assign cout8LL=1'b0;
    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;
    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
    if (WIDTH>=44) assign cout44=C[43];
    else assign cout44=1'b0;
	
	if (1)
	  begin
	    assign out[63:44]=(en&~ben[1]&!pooh) ? exbits : 21'bz; 
	    assign out[42:32]=(en&~ben[0]) ? exbits2 : 12'bz; 
            assign out[31:16]=(en&~ben[-1]) ? a[31:16] : 16'bz;
            assign out[15:8]=(en&~ben[-2]) ? a[15:8] : 8'bz;
	  end
    
  endgenerate
  
     
endmodule



(* align_width="a,out" *) module adder_inc(a,out,en,cout);
  parameter WIDTH=32;
  input [WIDTH-1:0] a;
  output [WIDTH-1:0] out;
  input en;
  output cout;
  

  (* align_width *) wire [WIDTH-1:0] P0;
  (* align_width *) wire [WIDTH-1:0] nP1;
  (* align_width *) wire [WIDTH-1:0] P2;
  (* align_width *) wire [WIDTH-1:0] nP3;
  (* align_width *) wire [WIDTH-1:0] P4;
  (* align_width *) wire [WIDTH-1:0] nP5;
  (* align_width *) wire [WIDTH-1:0] P6;

  wire [WIDTH-1:0] P;
  wire [WIDTH-1:0] nP;
    
  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;
 
  
  genvar i;
  
  assign P0=a;
  
  assign C1={P[WIDTH-2:0],1'b1};
  assign nC1={nP[WIDTH-2:0],1'b0};
  
  assign cout=P[WIDTH-1];

  
  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out[i]=(a[i] & en) ? ~C1[i] : 1'bz;
        assign out[i]=(~a[i] & en) ? ~nC1[i] : 1'bz;
      end 

    if (WIDTH>1)
      begin
        nand_array #(WIDTH-1) nP1_mod(P0[WIDTH-1:1],P0[WIDTH-2:0],nP1[WIDTH-1:1]);
        not_array #(1) nP1_tail_mod(P0[0],nP1[0]);
      end
    else
      begin
        assign P=P0;
        not_array #(WIDTH) nP_mod(P0,nP);
      end
    if (WIDTH>2)
      begin
        nor_array #(WIDTH-2) P2_mod(nP1[WIDTH-1:2],nP1[WIDTH-3:0],P2[WIDTH-1:2]);
        not_array #(2) P2_tail_mod(nP1[1:0],P2[1:0]);
      end
    else if (WIDTH>1)
      begin
        assign nP=nP1;
        not_array #(WIDTH) P_mod(nP1,P);
      end
    

    if (WIDTH>4)
      begin
        nand_array #(WIDTH-4) nP3_mod(P2[WIDTH-1:4],P2[WIDTH-5:0],nP3[WIDTH-1:4]);
        not_array #(4) nP3_tail_mod(P2[3:0],nP3[3:0]);
      end
    else if (WIDTH>2)
      begin
        assign P=P2;
        not_array #(WIDTH) nP_mod(P2,nP);
      end
    if (WIDTH>8)
      begin
        nor_array #(WIDTH-8) P4_mod(nP3[WIDTH-1:8],nP3[WIDTH-9:0],P4[WIDTH-1:8]);
        not_array #(8) P4_tail_mod(nP3[7:0],P4[7:0]);
      end
    else if (WIDTH>4)
      begin
        assign nP=nP3;
        not_array #(WIDTH) P_mod(nP3,P);
      end
    

    if (WIDTH>16)
      begin
        nand_array #(WIDTH-16) nP5_mod(P4[WIDTH-1:16],P4[WIDTH-17:0],nP5[WIDTH-1:16]);
        not_array #(16) nP5_tail_mod(P4[15:0],nP5[15:0]);
      end
    else if (WIDTH>8)
      begin
        assign P=P4;
        not_array #(WIDTH) nP_mod(P4,nP);
      end
    if (WIDTH>32)
      begin
        nor_array #(WIDTH-32) P6_mod(nP5[WIDTH-1:32],nP5[WIDTH-33:0],P6[WIDTH-1:32]);
        not_array #(32) P6_tail_mod(nP5[31:0],P6[31:0]);

        assign P=P6;
        not_array #(WIDTH) nP_mod(P6,nP);
      end
    else if (WIDTH>16)
      begin
        assign nP=nP5;
        not_array #(WIDTH) P_mod(nP5,P);
      end
    
  endgenerate
  
     
endmodule





module adder_FA1(a,b,out,cout);
  input a;
  input b;
  output out;
  output cout;
  
  assign out=a~^b;
  assign cout=a|b;
endmodule

module adder_FA0(a,b,out,cout);
  input a;
  input b;
  output out;
  output cout;
  
  assign out=a^b;
  assign cout=a&b;
endmodule


module adder_constCSA(a,b,out1,out2);
  parameter WIDTH=32;
  parameter [WIDTH-1:0] CONST=0;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH:0] out1;
  output [WIDTH:0] out2;
  
  genvar i;
  
  assign out2[0]=1'b0;
  assign out1[WIDTH]=1'b0;
  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_mod
        if (CONST[i]) adder_FA1 CSA_mod (a[i],b[i],out1[i],out2[i+1]);
        else adder_FA0 CSA_mod (a[i],b[i],out1[i],out2[i+1]);
      end
  endgenerate
endmodule

module adder_CSA(a1,a2,a3,out1,out2);

  parameter WIDTH=32;

  input [WIDTH-1:0] a1;
  input [WIDTH-1:0] a2;
  input [WIDTH-1:0] a3;
  output reg [WIDTH:0] out1;
  output reg [WIDTH:0] out2;
  
  integer i;
  
  always @(*)
    begin
      for(i=0;i<WIDTH;i=i+1)
        begin
          {out2[i+1],out1[i]}=a1[i]+a2[i]+a3[i];
        end
      out1[WIDTH]=1'b0;
      out2[0]=1'b0;
    end
  
endmodule







module get_carry(a,b,cin,cout); //cout=a bigger or equal than b if b inv, cin=1
  parameter WIDTH=32;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  input cin;
  output cout;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;
 
  
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  

  assign C1={C[WIDTH-2:0],cin};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1s_mod (cin,nC1[0]);
  
  assign cout=C[WIDTH-1];
  
  generate
    if (WIDTH>1)
      begin : in1
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin : out1
        oai21_array #(WIDTH) C1_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC1_mod(C,nC);
      end
    if (WIDTH>2)
      begin : in2
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin : out2
        aoi21_array #(WIDTH) nC2_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C2_mod(nC,C);
      end

    if (WIDTH>4)
      begin : in3
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin : out3
        oai21_array #(WIDTH) C3_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC3_mod(C,nC);
      end
    if (WIDTH>8)
      begin : in4
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin : out4
        aoi21_array #(WIDTH) nC4_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C4_mod(nC,C);
      end

    if (WIDTH>16)
      begin : in5
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin : out5
        oai21_array #(WIDTH) C5_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC5_mod(C,nC);
      end
    if (WIDTH>32)
      begin :in6
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin : out6
        aoi21_array #(WIDTH) nC6_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C6_mod(nC,C);
      end

    if (WIDTH>64)
      begin :in7
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nC7_mod(P7,{WIDTH{cin}},G7,nC);
        not_array #(WIDTH) C7_mod(nC,C);
      end
    else if (WIDTH>32)
      begin :out7
        oai21_array #(32) C7b_mod(nP6[31:0],{32{~cin}},nG6[31:0],C[31:0]);
        not_array #(32) nC7b_mod(C[31:0],nC[31:0]);
        oai21_array #(WIDTH-32) Cx_mod(nP6[WIDTH-1:32],{32{nC[31]}},nG6[WIDTH-1:32],C[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(C[WIDTH-1:32],nC[WIDTH-1:32]);
      end
      
    
  endgenerate
  
     
endmodule


(* align_width="a,b,c,out" *) module add_addrcalc(
  a,b,c,
  out,
  cout_sec,
  ndiff,
  en,
  shift,
  sh2,
  swppr
  );
  parameter WIDTH=44;
  parameter PTRBIT=0;
  input [64:0] a;//base
  input [64:0] b;
  input [64:0] c; //index
  //output [64:0] ptr;
  output [63+PTRBIT:0] out;
  output cout_sec;
  output ndiff;
  input en;  
  input [3:0] shift;
  input [1:0] sh2;
  inpu swppr;

  wire [WIDTH-1:0] tmp1;
  wire [WIDTH:0] tmp2;
  wire [WIDTH-1:0] c1;
  wire [WIDTH-1:0] c2;
  wire [WIDTH-1:0] c3;

  wire dummy1;
  wire dummy2;
  
  wire [WIDTH-1:0] xorab;
  wire [WIDTH-1:0] nxorab;
  wire [WIDTH-1:0] andab;
  wire [WIDTH-1:0] orab;
  wire cout_sec0,cout_sec1;
  wire [3:0] pos_ack;
  wire [3:0] neg_ack;
  wire err=a[64] ~^ c[64] || c[64] & ~shift[0];

  wire [43:0] c_s;

  wire [63+PTRBIT:0] ptr=(c[64] & shift==4'b1) ? c[63+PTRBIT:0] : a[63+PTRBIT:0]|{c[63+PTRBIT:44]&~{21{swppr}},44'b0};
  wire [64:0] unptr=(c[64] & shift==4'b1) ? a[63:0] : {32'b0,c[31:0]};

  genvar k;
  
  assign xorab=a[43:0]^b[43:0];
  assign nxorab=a[43:0]~^b[43:0];
  assign andab=a[43:0]&b[43:0];
  assign orab=a[43:0]|b[43:0];
  assign c1={c[43:0]} & {44{shift[0]}};
  assign c2={c[42:0],1'b0} & {44{shift[1]}};
  assign c3={c[41:0],2'b0} & {44{shift[2]}};
  assign c4={c[40:0],3'b0} & {44{shift[3]}};
  
  assign tmp2[0]=1'b0;

  assign cout_sec=~ cout_sec0 & ~ cout_sec1 ? pos_ack[2'b0] | neg_ack[2'b0] && ~err : 1'bz;
  assign cout_sec=cout_sec0 & ~ cout_sec1 ? pos_ack[2'b1] | neg_ack[2'b1] && ~err : 1'bz;
  assign cout_sec=cout_sec1 & ~ cout_sec0 ? pos_ack[2'b1] | neg_ack[2'b1] && ~err : 1'bz;
  assign cout_sec=cout_sec0 &  cout_sec1 ? pos_ack[2'd2] | neg_ack[2'd2] && ~err : 1'bz;
  adder_CSA #44 csaA(c1,c2,c3,tmp1,tmp2);
  adder_CSA #44 csaB(c4,b,tmp1,tmp3,tmp4);
  adder_CSA #44 csaC(a,tmp3,tmp4,tmpa,tmpb);
  
  adder #(WIDTH) add_mod(tmpa,tmpb[WIDTH-1:0],out[43:0],c_s,1'b0,en,,,,);
  assign out[63+PTRBIT:44]=en ? ptr[63+PTRBIT:44] : 'z;
  addrcalcsec_shift ssh_mod(ptr[`ptr_exp],c_s[41:10],cout_sec0);
  addrcalcsec_shift ssh_mod(ptr[`ptr_exp],ptr[41:10],cout_sec1);
  addrcalcsec_check_upper3 #(1'b1) chk_mod(ptr,tmp3[43:11],tmp4[43:11],pos_ack,neg_ack,,,ndiff);
endmodule





(* align_width="a,b,out0,out1" *) module adder_pipe2o(clk,a,b,out1,out2,cin,en1,en2,cout,cout8,cout16,cout32);
  parameter WIDTH=128;
  input clk;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out1;
  output [WIDTH-1:0] out2;
  input cin;
  input en1,en2;
  output cout;
  output cout8;
  output cout16;
  output cout32;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  reg [WIDTH-1:0] nP4_reg;
  reg [WIDTH-1:0] nG4_reg;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;
 
  
  genvar i;
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  
  xor_array #(WIDTH) x_mod (a,b,X);
  nxor_array #(WIDTH) nX_mod (a,b,nX);

  assign C1={C[WIDTH-2:0],cin};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (cin,nC1[0]);
  
  assign cout=C[WIDTH-1];
  
  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out1[i]=(X[i] & en1) ? ~C1[i] : 1'bz;
        assign out1[i]=(nX[i] & en1) ? ~nC1[i] : 1'bz;
        assign out2[i]=(X[i] & en2) ? ~C1[i] : 1'bz;
        assign out2[i]=(nX[i] & en2) ? ~nC1[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4_reg[WIDTH-1:16],nP4_reg[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4_reg[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4_reg[WIDTH-1:16],nG4_reg[WIDTH-17:0],nG4_reg[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4_reg[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4_reg,{WIDTH{~cin}},nG4_reg,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nC_mod(P7,{WIDTH{cin}},G7,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end
      
    if (WIDTH>=8) assign cout8=C[7];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
    
  endgenerate
  
  always @(posedge clk)
  begin
      nP4_reg<=nP4;
      nG4_reg<=nG4;
  end
  
endmodule


(* align_width="a,b,out0,out1" *) module adder2oM(a,b,out0,out1,out2,cin,en0,en1,low32,cout,cout8,cout16,cout32);
  parameter WIDTH=32;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out0;
  output [WIDTH-1:0] out1;
  output [31:0] out2;
  input cin;
  input en0;
  input en1;
  input low32;
  output cout;
  output cout8;
  output cout16;
  output cout32;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;
 
  
  genvar i;
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  
  xor_array #(WIDTH) x_mod (a,b,X);
  nxor_array #(WIDTH) nX_mod(a,b,nX);

  assign C1={C[WIDTH-2:0],cin};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (cin,nC1[0]);
  
  assign cout=C[WIDTH-1];
  
  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
	  if (~i[5]) begin
              assign out0[i]=(X[i] & en0) ? ~C1[i] : 1'bz;
              assign out0[i]=(nX[i] & en0) ? ~nC1[i] : 1'bz;
              assign out1[i]=(X[i] & en1) ? ~C1[i] : 1'bz;
              assign out1[i]=(nX[i] & en1) ? ~nC1[i] : 1'bz;
          end else begin
              assign out0[i]=(X[i] & en0 & ~low32) ? ~C1[i] : 1'bz;
              assign out0[i]=(nX[i] & en0 & ~low32) ? ~nC1[i] : 1'bz;
	      assign out0[i]=(en0 & low32) ? 1'b0 : 1'bz;
              assign out1[i]=(X[i] & en1 & ~low32) ? ~C1[i] : 1'bz;
              assign out1[i]=(nX[i] & en1 & ~low32) ? ~nC1[i] : 1'bz;
	      assign out1[i]=(en1 & low32) ? 1'b0 : 1'bz;
	  end
          if (i>=32 && i<64) begin
              assign out2[i-32]=(X[i] & en0) ? ~C1[i] : 1'bz;
              assign out2[i-32]=(nX[i] & en0) ? ~nC1[i] : 1'bz;
          end
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        //nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        //not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        //oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        //not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        oai21_array #(64) nC_mod(nP6[63:0],{64{~cin}},nG6[63:0],C[63:0]);
        not_array #(64) C_mod(C[63:0],nC[63:0]);
        oai21_array #(WIDTH-64) nCx_mod(nP6[WIDTH-1:64],{WIDTH-64{nC[63]}},nG6[WIDTH-1:64],C[WIDTH-1:64]);
        not_array #(WIDTH-64) Cx_mod(C[WIDTH-1:64],nC[WIDTH-1:64]);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end
      
    if (WIDTH>=8) assign cout8=C[7];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
    
  endgenerate
  
     
endmodule


(* align_width="a,b,out0,out1" *) module adder2oi(biten,a,b,out0,out1,cin,en0,en1,cout,cout8,cout16,cout32);
  parameter WIDTH=32;
  input [WIDTH-1:0] biten;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out0;
  output [WIDTH-1:0] out1;
  input cin;
  input en0;
  input en1;
  output cout;
  output cout8;
  output cout16;
  output cout32;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;
 
  
  genvar i;
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  
  xor_array #(WIDTH) x_mod (a,b,X);
  nxor_array #(WIDTH) nX_mod(a,b,nX);

  assign C1={C[WIDTH-2:0],cin};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (cin,nC1[0]);
  
  assign cout=C[WIDTH-1];
  
  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out0[i]=(X[i] & en0 & biten[i]) ? ~C1[i] : 1'bz;
        assign out0[i]=(nX[i] & en0 & biten[i]) ? ~nC1[i] : 1'bz;
	assign out0[i]=(~biten[i]) ? 1'b0 : 1'bz;
	assign out1[i]=(~biten[i]) ? 1'b0 : 1'bz;
        assign out1[i]=(X[i] & en1 & biten[i]) ? ~C1[i] : 1'bz;
        assign out1[i]=(nX[i] & en1 & biten[i]) ? ~nC1[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nC_mod(P7,{WIDTH{cin}},G7,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end
      
    if (WIDTH>=8) assign cout8=C[7];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
    
  endgenerate
  
endmodule

(* align_width="a,b,out0,out1" *) module adder2o(a,b,out0,out1,cin,en0,en1,cout,cout8,cout16,cout32);
  parameter WIDTH=32;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out0;
  output [WIDTH-1:0] out1;
  input cin;
  input en0;
  input en1;
  output cout;
  output cout8;
  output cout16;
  output cout32;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1;
  wire [WIDTH-1:0] nC1;
 
  
  genvar i;
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  
  xor_array #(WIDTH) x_mod (a,b,X);
  nxor_array #(WIDTH) nX_mod(a,b,nX);

  assign C1={C[WIDTH-2:0],cin};
  assign nC1[WIDTH-1:1]=nC[WIDTH-2:0];
  not_array #(1) C1_mod (cin,nC1[0]);
  
  assign cout=C[WIDTH-1];
  
  generate
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out0[i]=(X[i] & en0) ? ~C1[i] : 1'bz;
        assign out0[i]=(nX[i] & en0) ? ~nC1[i] : 1'bz;
        assign out1[i]=(X[i] & en1) ? ~C1[i] : 1'bz;
        assign out1[i]=(nX[i] & en1) ? ~nC1[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        //nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        //not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        //oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        //not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        oai21_array #(64) nC_mod(nP6[63:0],{64{~cin}},nG6[63:0],C[63:0]);
        not_array #(64) C_mod(C[63:0],nC[63:0]);
        oai21_array #(WIDTH-64) nCx_mod(nP6[WIDTH-1:64],{WIDTH-64{nC[63]}},nG6[WIDTH-1:64],C[WIDTH-1:64]);
        not_array #(WIDTH-64) Cx_mod(C[WIDTH-1:64],nC[WIDTH-1:64]);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end
      
    if (WIDTH>=8) assign cout8=C[7];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
    
  endgenerate
  
     
endmodule

(* align_width="a,b,out0,out1" *) module adder2c(a,b,out0,out1,cin0,cin1,en0,en1,cout0,cout1,cout0_53,cout1_53);
  parameter WIDTH=32;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out0;
  output [WIDTH-1:0] out1;
  input cin0,cin1;
  input en0,en1;
  output cout0,cout1;
  output cout0_53,cout1_53;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] Ca;
  wire [WIDTH-1:0] nCa;
  wire [WIDTH-1:0] Cb;
  wire [WIDTH-1:0] nCb;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1a;
  wire [WIDTH-1:0] nC1a;
  wire [WIDTH-1:0] C1b;
  wire [WIDTH-1:0] nC1b;
 
  
  genvar i;
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  
  xor_array #(WIDTH) x_mod(a,b,X);
  nxor_array #(WIDTH) nx_mod(a,b,nX);

  assign C1a={Ca[WIDTH-2:0],cin0};
  assign nC1a[WIDTH-1:1]=nCa[WIDTH-2:0];
  not_array #(1) C1a_mod (cin0,nC1a[0]);
  
  assign C1b={Cb[WIDTH-2:0],cin1};
  assign nC1b[WIDTH-1:1]=nCb[WIDTH-2:0];
  not_array #(1) C1b_mod (cin1,nC1b[0]);

  assign cout0=Ca[WIDTH-1];
  assign cout1=Cb[WIDTH-1];
  
  generate
    if (WIDTH>=53) begin : c53
        assign cout0_53=Ca[52];
        assign cout1_53=Cb[52];
    end
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out0[i]=(X[i] & en0) ? ~C1a[i] : 1'bz;
        assign out0[i]=(nX[i] & en0) ? ~nC1a[i] : 1'bz;
        assign out1[i]=(X[i] & en1) ? ~C1b[i] : 1'bz;
        assign out1[i]=(nX[i] & en1) ? ~nC1b[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) Ca1_mod(nP0,{WIDTH{~cin0}},nG0,Ca);
        not_array #(WIDTH) nCa1_mod(Ca,nCa);
        oai21_array #(WIDTH) Cb1_mod(nP0,{WIDTH{~cin1}},nG0,Cb);
        not_array #(WIDTH) nCb1_mod(Cb,nCb);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nCa2_mod(P1,{WIDTH{cin0}},G1,nCa);
        not_array #(WIDTH) Ca2_mod(nCa,Ca);
        aoi21_array #(WIDTH) nCb2_mod(P1,{WIDTH{cin1}},G1,nCb);
        not_array #(WIDTH) Cb2_mod(nCb,Cb);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) Ca3_mod(nP2,{WIDTH{~cin0}},nG2,Ca);
        not_array #(WIDTH) nCa3_mod(Ca,nCa);
        oai21_array #(WIDTH) Cb3_mod(nP2,{WIDTH{~cin1}},nG2,Cb);
        not_array #(WIDTH) nCb3_mod(Cb,nCb);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nCa4_mod(P3,{WIDTH{cin0}},G3,nCa);
        not_array #(WIDTH) Ca4_mod(nCa,Ca);
        aoi21_array #(WIDTH) nCb4_mod(P3,{WIDTH{cin1}},G3,nCb);
        not_array #(WIDTH) Cb4_mod(nCb,Cb);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) Ca5_mod(nP4,{WIDTH{~cin0}},nG4,Ca);
        not_array #(WIDTH) nCa5_mod(Ca,nCa);
        oai21_array #(WIDTH) Cb5_mod(nP4,{WIDTH{~cin1}},nG4,Cb);
        not_array #(WIDTH) nCb5_mod(Cb,nCb);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nCa6_mod(P5,{WIDTH{cin0}},G5,nCa);
        not_array #(WIDTH) Ca6_mod(nCa,Ca);
        aoi21_array #(WIDTH) nCb6_mod(P5,{WIDTH{cin1}},G5,nCb);
        not_array #(WIDTH) Cb6_mod(nCb,Cb);
      end

    if (WIDTH>64)
      begin
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nCa7_mod(P7,{WIDTH{cin0}},G7,nCa[WIDTH-1:0]);
        not_array #(WIDTH) Ca7_mod(nCa,Ca);
        aoi21_array #(WIDTH) nCb7_mod(P7,{WIDTH{cin1}},G7,nCb[WIDTH-1:0]);
        not_array #(WIDTH) Cb7_mod(nCb,Cb);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) Ca7b_mod(P5[31:0],{32{cin0}},G5[31:0],nCa[31:0]);
        not_array #(32) nCa7b_mod(nCa[31:0],Ca[31:0]);
        aoi21_array #(WIDTH-32) Cax_mod(P5[WIDTH-1:32],{WIDTH-32{Ca[31]}},G5[WIDTH-1:32],nCa[WIDTH-1:32]);
        not_array #(WIDTH-32) nCax_mod(nCa[WIDTH-1:32],Ca[WIDTH-1:32]);
        aoi21_array #(32) Cb7b_mod(P5[31:0],{32{cin1}},G5[31:0],nCb[31:0]);
        not_array #(32) nCb7b_mod(nCb[31:0],Cb[31:0]);
        aoi21_array #(WIDTH-32) Cbx_mod(P5[WIDTH-1:32],{WIDTH-32{Cb[31]}},G5[WIDTH-1:32],nCb[WIDTH-1:32]);
        not_array #(WIDTH-32) nCbx_mod(nCb[WIDTH-1:32],Cb[WIDTH-1:32]);
      end
      

    if (WIDTH>=53) assign cout0_53=Ca[52];
    else assign cout0_53=1'b0;
    if (WIDTH>=53) assign cout1_53=Cb[52];
    else assign cout1_53=1'b0;
    
  endgenerate
  
     
endmodule


(* align_width="a,b,out0,out1" *) module adder2ox(a,b,out0,out1,cin,en0,en1,cout,cout8,cout16,cout32);
  parameter WIDTH=32;
  input [WIDTH:0] a;
  input [WIDTH:0] b;
  output [WIDTH:0] out0;
  output [WIDTH:0] out1;
  input cin;
  input en0;
  input en1;
  output cout;
  output cout8;
  output cout16;
  output cout32;
  
  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] C;
  wire [WIDTH-1:0] nC;

  wire [WIDTH:0] X;
  wire [WIDTH:0] nX;
  
  wire [WIDTH:0] C1;
  wire [WIDTH:0] nC1;
 
  
  genvar i;
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  
  xor_array #(WIDTH+1) x_mod (a,b,X);
  nxor_array #(WIDTH+1) nX_mod(a,b,nX);

  assign C1={C[WIDTH-1:0],cin};
  assign nC1[WIDTH:1]=nC[WIDTH-1:0];
  not_array #(1) C1_mod (cin,nC1[0]);
  
  assign cout=C[WIDTH-1];
  
  generate
    for (i=0;i<WIDTH+1;i=i+1)
      begin : out_gen
        assign out0[i]=(X[i] & en0) ? ~C1[i] : 1'bz;
        assign out0[i]=(nX[i] & en0) ? ~nC1[i] : 1'bz;
        assign out1[i]=(X[i] & en1) ? ~C1[i] : 1'bz;
        assign out1[i]=(nX[i] & en1) ? ~nC1[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) C_mod(nP0,{WIDTH{~cin}},nG0,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nC_mod(P1,{WIDTH{cin}},G1,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) C_mod(nP2,{WIDTH{~cin}},nG2,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nC_mod(P3,{WIDTH{cin}},G3,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4[WIDTH-1:16],nP4[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4[WIDTH-1:16],nG4[WIDTH-17:0],nG4[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) C_mod(nP4,{WIDTH{~cin}},nG4,C);
        not_array #(WIDTH) nC_mod(C,nC);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nC_mod(P5,{WIDTH{cin}},G5,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end

    if (WIDTH>64)
      begin
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nC_mod(P7,{WIDTH{cin}},G7,nC);
        not_array #(WIDTH) C_mod(nC,C);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) C_mod(P5[31:0],{32{cin}},G5[31:0],nC[31:0]);
        not_array #(32) nC_mod(nC[31:0],C[31:0]);
        aoi21_array #(WIDTH-32) Cx_mod(P5[WIDTH-1:32],{WIDTH-32{C[31]}},G5[WIDTH-1:32],nC[WIDTH-1:32]);
        not_array #(WIDTH-32) nCx_mod(nC[WIDTH-1:32],C[WIDTH-1:32]);
      end
      
    if (WIDTH>=8) assign cout8=C[7];
    else assign cout8=1'b0;

    if (WIDTH>=16) assign cout16=C[15];
    else assign cout16=1'b0;

    if (WIDTH>=32) assign cout32=C[31];
    else assign cout32=1'b0;
    
  endgenerate
  
     
endmodule



(* align_width="a,b,out0,out1" *) module adder2c_pipe(clk,a,b,out0,out1,cin0,cin1,en0,en1,cout0,cout1,cout0_53,cout1_53);
  parameter WIDTH=32;
  input clk;
  input [WIDTH-1:0] a;
  input [WIDTH-1:0] b;
  output [WIDTH-1:0] out0;
  output [WIDTH-1:0] out1;
  input cin0,cin1;
  input en0,en1;
  output cout0,cout1;
  output cout0_53,cout1_53;
  

  (* align_width *) wire [WIDTH-1:0] nP0;
  (* align_width *) wire [WIDTH-1:0] nG0;

  (* align_width *) wire [WIDTH-1:0] P1;
  (* align_width *) wire [WIDTH-1:0] G1;

  (* align_width *) wire [WIDTH-1:0] nP2;
  (* align_width *) wire [WIDTH-1:0] nG2;

  (* align_width *) wire [WIDTH-1:0] P3;
  (* align_width *) wire [WIDTH-1:0] G3;

  (* align_width *) wire [WIDTH-1:0] nP4;
  (* align_width *) wire [WIDTH-1:0] nG4;

  reg [WIDTH-1:0] nP4_reg;
  reg [WIDTH-1:0] nG4_reg;
  
  (* align_width *) wire [WIDTH-1:0] P5;
  (* align_width *) wire [WIDTH-1:0] G5;

  (* align_width *) wire [WIDTH-1:0] nP6;
  (* align_width *) wire [WIDTH-1:0] nG6;

  (* align_width *) wire [WIDTH-1:0] P7;
  (* align_width *) wire [WIDTH-1:0] G7;

  wire [WIDTH-1:0] Ca;
  wire [WIDTH-1:0] nCa;
  wire [WIDTH-1:0] Cb;
  wire [WIDTH-1:0] nCb;

  wire [WIDTH-1:0] X;
  wire [WIDTH-1:0] nX;
  
  wire [WIDTH-1:0] C1a;
  wire [WIDTH-1:0] nC1a;
  wire [WIDTH-1:0] C1b;
  wire [WIDTH-1:0] nC1b;
 
  
  genvar i;
  
  nand_array #(WIDTH) nG0_mod(a,b,nG0);
  nor_array #(WIDTH)  nP0_mod(a,b,nP0);
  
  xor_array #(WIDTH) x_mod(a,b,X);
  nxor_array #(WIDTH) nx_mod(a,b,nX);

  assign C1a={Ca[WIDTH-2:0],cin0};
  assign nC1a[WIDTH-1:1]=nCa[WIDTH-2:0];
  not_array #(1) C1a_mod (cin0,nC1a[0]);
  
  assign C1b={Cb[WIDTH-2:0],cin1};
  assign nC1b[WIDTH-1:1]=nCb[WIDTH-2:0];
  not_array #(1) C1b_mod (cin1,nC1b[0]);

  assign cout0=Ca[WIDTH-1];
  assign cout1=Ca[WIDTH-1];
  
  generate
    if (WIDTH>=53) begin
        assign cout0_53=Ca[52];
        assign cout1_53=Cb[52];
    end
    for (i=0;i<WIDTH;i=i+1)
      begin : out_gen
        assign out0[i]=(X[i] & en0) ? ~C1a[i] : 1'bz;
        assign out0[i]=(nX[i] & en0) ? ~nC1a[i] : 1'bz;
        assign out1[i]=(X[i] & en1) ? ~C1b[i] : 1'bz;
        assign out1[i]=(nX[i] & en1) ? ~nC1b[i] : 1'bz;
      end 
    if (WIDTH>1)
      begin
        nor_array #(WIDTH-1)  P1_mod(nP0[WIDTH-1:1],nP0[WIDTH-2:0],P1[WIDTH-1:1]);
        not_array #(1) P1_tail_mod(nP0[0],P1[0]);
        oai21_array #(WIDTH-1) G1_mod(nP0[WIDTH-1:1],nG0[WIDTH-2:0],nG0[WIDTH-1:1],G1[WIDTH-1:1]);
        not_array #(1) G1_tail_mod(nG0[0],G1[0]);
      end
    else
      begin
        oai21_array #(WIDTH) Ca_mod(nP0,{WIDTH{~cin0}},nG0,Ca);
        not_array #(WIDTH) nCa_mod(Ca,nCa);
        oai21_array #(WIDTH) Cb_mod(nP0,{WIDTH{~cin1}},nG0,Cb);
        not_array #(WIDTH) nCb_mod(Cb,nCb);
      end
    if (WIDTH>2)
      begin
        nand_array #(WIDTH-2)  nP2_mod(P1[WIDTH-1:2],P1[WIDTH-3:0],nP2[WIDTH-1:2]);
        not_array #(2) nP2_tail_mod(P1[1:0],nP2[1:0]);
        aoi21_array #(WIDTH-2) nG2_mod(P1[WIDTH-1:2],G1[WIDTH-3:0],G1[WIDTH-1:2],nG2[WIDTH-1:2]);
        not_array #(2) nG2_tail_mod(G1[1:0],nG2[1:0]);
      end
    else if (WIDTH>1)
      begin
        aoi21_array #(WIDTH) nCa_mod(P1,{WIDTH{cin0}},G1,nCa);
        not_array #(WIDTH) Ca_mod(nCa,Ca);
        aoi21_array #(WIDTH) nCb_mod(P1,{WIDTH{cin1}},G1,nCb);
        not_array #(WIDTH) Cb_mod(nCb,Cb);
      end

    if (WIDTH>4)
      begin
        nor_array #(WIDTH-4)  P3_mod(nP2[WIDTH-1:4],nP2[WIDTH-5:0],P3[WIDTH-1:4]);
        not_array #(4) P3_tail_mod(nP2[3:0],P3[3:0]);
        oai21_array #(WIDTH-4) G3_mod(nP2[WIDTH-1:4],nG2[WIDTH-5:0],nG2[WIDTH-1:4],G3[WIDTH-1:4]);
        not_array #(4) G3_tail_mod(nG2[3:0],G3[3:0]);
      end
    else if (WIDTH>2)
      begin
        oai21_array #(WIDTH) Ca_mod(nP2,{WIDTH{~cin0}},nG2,Ca);
        not_array #(WIDTH) nCa_mod(Ca,nCa);
        oai21_array #(WIDTH) Cb_mod(nP2,{WIDTH{~cin1}},nG2,Cb);
        not_array #(WIDTH) nCb_mod(Cb,nCb);
      end
    if (WIDTH>8)
      begin
        nand_array #(WIDTH-8)  nP4_mod(P3[WIDTH-1:8],P3[WIDTH-9:0],nP4[WIDTH-1:8]);
        not_array #(8) nP4_tail_mod(P3[7:0],nP4[7:0]);
        aoi21_array #(WIDTH-8) nG4_mod(P3[WIDTH-1:8],G3[WIDTH-9:0],G3[WIDTH-1:8],nG4[WIDTH-1:8]);
        not_array #(8) nG4_tail_mod(G3[7:0],nG4[7:0]);
      end
    else if (WIDTH>4)
      begin
        aoi21_array #(WIDTH) nCa_mod(P3,{WIDTH{cin0}},G3,nCa);
        not_array #(WIDTH) Ca_mod(nCa,Ca);
        aoi21_array #(WIDTH) nCb_mod(P3,{WIDTH{cin1}},G3,nCb);
        not_array #(WIDTH) Cb_mod(nCb,Cb);
      end

    if (WIDTH>16)
      begin
        nor_array #(WIDTH-16)  P5_mod(nP4_reg[WIDTH-1:16],nP4_reg[WIDTH-17:0],P5[WIDTH-1:16]);
        not_array #(16) P5_tail_mod(nP4_reg[15:0],P5[15:0]);
        oai21_array #(WIDTH-16) G5_mod(nP4_reg[WIDTH-1:16],nG4_reg[WIDTH-17:0],nG4_reg[WIDTH-1:16],G5[WIDTH-1:16]);
        not_array #(16) G5_tail_mod(nG4_reg[15:0],G5[15:0]);
      end
    else if (WIDTH>8)
      begin
        oai21_array #(WIDTH) Ca_mod(nP4_reg,{WIDTH{~cin0}},nG4_reg,Ca);
        not_array #(WIDTH) nCa_mod(Ca,nCa);
        oai21_array #(WIDTH) Cb_mod(nP4_reg,{WIDTH{~cin1}},nG4_reg,Cb);
        not_array #(WIDTH) nCb_mod(Cb,nCb);
      end
    if (WIDTH>32)
      begin
        nand_array #(WIDTH-32)  nP6_mod(P5[WIDTH-1:32],P5[WIDTH-33:0],nP6[WIDTH-1:32]);
        not_array #(32) nP6_tail_mod(P5[31:0],nP6[31:0]);
        aoi21_array #(WIDTH-32) nG6_mod(P5[WIDTH-1:32],G5[WIDTH-33:0],G5[WIDTH-1:32],nG6[WIDTH-1:32]);
        not_array #(32) nG6_tail_mod(G5[31:0],nG6[31:0]);
      end
    else if (WIDTH>16)
      begin
        aoi21_array #(WIDTH) nCa_mod(P5,{WIDTH{cin0}},G5,nCa);
        not_array #(WIDTH) Ca_mod(nCa,Ca);
        aoi21_array #(WIDTH) nCb_mod(P5,{WIDTH{cin1}},G5,nCb);
        not_array #(WIDTH) Cb_mod(nCb,Cb);
      end

    if (WIDTH>64)
      begin
        nor_array #(WIDTH-64)  P7_mod(nP6[WIDTH-1:64],nP6[WIDTH-65:0],P7[WIDTH-1:64]);
        not_array #(64) P7_tail_mod(nP6[63:0],P7[63:0]);
        oai21_array #(WIDTH-64) G7_mod(nP6[WIDTH-1:64],nG6[WIDTH-65:0],nG6[WIDTH-1:64],G7[WIDTH-1:64]);
        not_array #(64) G7_tail_mod(nG6[63:0],G7[63:0]);

        aoi21_array #(WIDTH) nCa_mod(P7,{WIDTH{cin0}},G7,nCa[WIDTH-1:0]);
        not_array #(WIDTH) Ca_mod(nCa,Ca);
        aoi21_array #(WIDTH) nCb_mod(P7,{WIDTH{cin1}},G7,nCb[WIDTH-1:0]);
        not_array #(WIDTH) Cb_mod(nCb,Cb);
      end
    else if (WIDTH>32)
      begin
        aoi21_array #(32) Ca_mod(P5[31:0],{32{cin0}},G5[31:0],nCa[31:0]);
        not_array #(32) nCa_mod(nCa[31:0],Ca[31:0]);
        aoi21_array #(WIDTH-32) Cax_mod(P5[WIDTH-1:32],{WIDTH-32{Ca[31]}},G5[WIDTH-1:32],nCa[WIDTH-1:32]);
        not_array #(WIDTH-32) nCax_mod(nCa[WIDTH-1:32],Ca[WIDTH-1:32]);
        aoi21_array #(32) Cb_mod(P5[31:0],{32{cin1}},G5[31:0],nCb[31:0]);
        not_array #(32) nCb_mod(nCb[31:0],Cb[31:0]);
        aoi21_array #(WIDTH-32) Cbx_mod(P5[WIDTH-1:32],{WIDTH-32{Cb[31]}},G5[WIDTH-1:32],nCb[WIDTH-1:32]);
        not_array #(WIDTH-32) nCbx_mod(nCb[WIDTH-1:32],Cb[WIDTH-1:32]);
      end
      

    if (WIDTH>=53) assign cout0_53=Ca[52];
    else assign cout0_53=1'b0;
    if (WIDTH>=53) assign cout1_53=Cb[52];
    else assign cout1_53=1'b0;
    
  endgenerate
  
  always @(posedge clk) begin
    nG4_reg<=nG4;
    nP4_reg<=nP4;
  end
     
endmodule


