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

//verilator lint_off WIDTH
module reg_alloc(
  clk,
  rst,
  stall,
  doStall,
  except,ethread,eboth,
  thread,
  ret_en,ret_thread,
  ret_rno0,ret_rno1,ret_rno2,
  ret_rno3,ret_rno4,ret_rno5,
  ret_rno6,ret_rno7,ret_rno8,
  newR0,newR1,newR2,
  newR3,newR4,newR5,
  newR6,newR7,newR8,
  rs0i0_en,rs1i0_en,rs2i0_en,
  rs0i1_en,rs1i1_en,rs2i1_en,
  rs0i2_en,rs1i2_en,rs2i2_en
  );
  localparam REG_WIDTH=`reg_addr_width;
 /*verilator hier_block*/ 
  input pwire clk;
  input pwire rst;
  input pwire stall;
  output pwire doStall;
  input pwire except;
  input pwire ethread;
  input pwire eboth;
  input pwire thread;
  input pwire [8:0] ret_en;
  input pwire ret_thread;
  input pwire [4:0] ret_rno0;
  input pwire [4:0] ret_rno1;
  input pwire [4:0] ret_rno2;
  input pwire [4:0] ret_rno3;
  input pwire [4:0] ret_rno4;
  input pwire [4:0] ret_rno5;
  input pwire [4:0] ret_rno6;
  input pwire [4:0] ret_rno7;
  input pwire [4:0] ret_rno8;
  
  output pwire [8:0] newR0;
  output pwire [8:0] newR1;
  output pwire [8:0] newR2;
  output pwire [8:0] newR3;
  output pwire [8:0] newR4;
  output pwire [8:0] newR5;
  output pwire [8:0] newR6;
  output pwire [8:0] newR7;
  output pwire [8:0] newR8;
  
  input pwire rs0i0_en,rs1i0_en,rs2i0_en;
  input pwire rs0i1_en,rs1i1_en,rs2i1_en;
  input pwire rs0i2_en,rs1i2_en,rs2i2_en;
  
  
  reg [1:0] pos;
  reg [4:0] lpos;
  reg [4:0] hpos;
  reg [REG_WIDTH-1:0] new_reg[8:0];
  reg [8:0] new_en;
  reg [8:0] new_enn;

  pwire [3:0] pop3[2:0];
  pwire [3:1] pop3_or_more[2:0];
  pwire [3:0] pop_max;
  pwire [4:0] hhpos;
  pwire step;
  pwire [1:0] pos_d;
  reg [1:0] pos_1;
  reg [1:0] pos_2;
  pwire [4:0] ret_rno[8:0];


  reg [31:0] rAllOc[8:0];
  pwire [8:0][31:0] rAllOc_first;
  pwire [8:0][31:0] rAllOc_free;
  pwire [8:0] rAllOc_has;
  pwire [8:0][3:0] rAllOc_first_b;
  pwire [8:0][4:0] rAllOc_first_r;
  reg [31:0] rThread[8:0];

  integer k;
  
  function [3*REG_WIDTH-1:0] reg_sel;
      input pwire [2:0] sel;
      input pwire [REG_WIDTH-1:0] reg0;
      input pwire [REG_WIDTH-1:0] reg1;
      input pwire [REG_WIDTH-1:0] reg2;
      case (sel)
          3'b000: reg_sel={3*REG_WIDTH{1'B0}};
          3'b001: reg_sel={{2*REG_WIDTH{1'B0}},reg0};
          3'b010: reg_sel={{REG_WIDTH{1'B0}},reg0,{REG_WIDTH{1'B0}}};
          3'b100: reg_sel={reg0,{2*REG_WIDTH{1'B0}}};
          3'b011: reg_sel={{REG_WIDTH{1'B0}},reg1,reg0};
          3'b101: reg_sel={reg1,{REG_WIDTH{1'B0}},reg0};
          3'b110: reg_sel={reg1,reg0,{REG_WIDTH{1'B0}}};
          3'b111: reg_sel={reg2,reg1,reg0};
      endcase
  endfunction

  generate
    genvar l,q,a,b;
    for(l=0;l<9;l=l+1) begin : alloc_gen
        bit_find_first_bit #(32) balloc_mod(rAllOc[l],rAllOc_first[l],rAllOc_has[l]);
        bit_find_first_bit #(4) bballoc_mod({|rAllOc[l][31:24],|rAllOc[l][23:16],
          |rAllOc[l][15:8],|rAllOc[l][7:0]},rAllOc_first_b[l],);
        for(q=0;q<32;q=q+1) begin
	    assign rAllOc_free[l][q]=ret_rno[l]==q && ret_en[l];
	end
        for(a=0;a<4;a=a+1) begin
            pwire [4:0] rAllOc_first_rk;
            for(b=0;b<8;b=b+1) begin
                assign rAllOc_first_rk=rAllOc_first[l][a*8+b] ? a*8+b : 5'bz;
            end
            assign rAllOc_first_rk=(~rAllOc_first_b[l][a]) ? 5'b0 : 5'bz;
            assign rAllOc_first_r[l]=rAllOc_first_b[l][a] ? rAllOc_first_rk : 5'bz;
        end
        assign rAllOc_first_r[l]=rAllOc_has[l] ? 5'bz : 5'b0;
    end
  endgenerate

  assign {newR2,newR1,newR0}=reg_sel({rs0i2_en,rs0i1_en,rs0i0_en},new_reg[0],new_reg[3],new_reg[6]);
  assign {newR5,newR4,newR3}=reg_sel({rs1i2_en,rs1i1_en,rs1i0_en},new_reg[1],new_reg[4],new_reg[7]);
  assign {newR8,newR7,newR6}=reg_sel({rs2i2_en,rs2i1_en,rs2i0_en},new_reg[2],new_reg[5],new_reg[8]);

  assign pop_max[3]=pop3[0][3] | pop3[1][3] | pop3[2][3];
  assign pop_max[2]=(pop3[0][2] | pop3[1][2] | pop3[2][2]) && (~pop3[0][3] & ~pop3[1][3] & ~pop3[2][3]); 
  assign pop_max[1]=(pop3[0][1] | pop3[1][1] | pop3[2][1]) && (!pop3[0][3:2] & !pop3[1][3:2] & !pop3[2][3:2]); 
  assign pop_max[0]=pop3[0][0] & pop3[1][0] & pop3[2][0];
  assign step=pop_max[3] || (pos[thread] && pop_max[2]) || (pos[thread]==3'd2 && pop_max[1]); 
  
  popcnt3 pop0_mod({rs0i0_en,rs0i1_en,rs0i2_en},pop3[0]);
  popcnt3 pop1_mod({rs1i0_en,rs1i1_en,rs1i2_en},pop3[1]);
  popcnt3 pop2_mod({rs2i0_en,rs2i1_en,rs2i2_en},pop3[2]);
  
  adder_inc #(5) hhpos_one(hpos,hhpos,1'b1,);
  
  popcnt3_or_more pop0m_mod({rs0i0_en,rs0i1_en,rs0i2_en},pop3_or_more[0]);
  popcnt3_or_more pop1m_mod({rs1i0_en,rs1i1_en,rs1i2_en},pop3_or_more[1]);
  popcnt3_or_more pop2m_mod({rs2i0_en,rs2i1_en,rs2i2_en},pop3_or_more[2]);
  
  assign pos_d=pop_max[3] ? pos : 2'bz;
  assign pos_d=pop_max[0] ? pos : 2'bz;
  assign pos_d=pop_max[1] ? pos_1 : 2'bz;
  assign pos_d=pop_max[2] ? pos_2 : 2'bz;

  assign ret_rno[0]=ret_rno0;
  assign ret_rno[1]=ret_rno1;
  assign ret_rno[2]=ret_rno2;
  assign ret_rno[3]=ret_rno3;
  assign ret_rno[4]=ret_rno4;
  assign ret_rno[5]=ret_rno5;
  assign ret_rno[6]=ret_rno6;
  assign ret_rno[7]=ret_rno7;
  assign ret_rno[8]=ret_rno8;

  
  //assign doStall=thread_both ? stall2[thread] : stall1[thread];
  assign doStall=rAllOc_has!=9'h1ff;

  always @* begin
      case (pos)
          2'd0: begin
            new_reg[0]={rAllOc_first_r[0],4'd0};
            new_reg[1]={rAllOc_first_r[1],4'd1};
            new_reg[2]={rAllOc_first_r[2],4'd2};
            new_reg[3]={rAllOc_first_r[3],4'd3};
            new_reg[4]={rAllOc_first_r[4],4'd4};
            new_reg[5]={rAllOc_first_r[5],4'd5};
            new_reg[6]={rAllOc_first_r[6],4'd6};
            new_reg[7]={rAllOc_first_r[7],4'd7};
            new_reg[8]={rAllOc_first_r[8],4'd8};
            {new_en[6],new_en[3],new_en[0]}=pop3_or_more[0];
            {new_en[7],new_en[4],new_en[1]}=pop3_or_more[1];
            {new_en[8],new_en[5],new_en[2]}=pop3_or_more[2];
            pos_1=2'd1;
            pos_2=2'd2;
          end
          2'd1: begin
            new_reg[0]={rAllOc_first_r[3],4'd3};
            new_reg[1]={rAllOc_first_r[4],4'd4};
            new_reg[2]={rAllOc_first_r[5],4'd5};
            new_reg[3]={rAllOc_first_r[6],4'd6};
            new_reg[4]={rAllOc_first_r[7],4'd7};
            new_reg[5]={rAllOc_first_r[8],4'd8};
            new_reg[6]={rAllOc_first_r[0],4'd0};
            new_reg[7]={rAllOc_first_r[1],4'd1};
            new_reg[8]={rAllOc_first_r[2],4'd2};
            {new_en[0],new_en[6],new_en[3]}=pop3_or_more[0];
            {new_en[1],new_en[7],new_en[4]}=pop3_or_more[1];
            {new_en[2],new_en[8],new_en[5]}=pop3_or_more[2];
            pos_1=2'd2;
            pos_2=2'd0;
          end
          default: begin
            new_reg[0]={rAllOc_first_r[6],4'd6};
            new_reg[1]={rAllOc_first_r[7],4'd7};
            new_reg[2]={rAllOc_first_r[8],4'd8};
            new_reg[3]={rAllOc_first_r[0],4'd0};
            new_reg[4]={rAllOc_first_r[1],4'd1};
            new_reg[5]={rAllOc_first_r[2],4'd2};
            new_reg[6]={rAllOc_first_r[3],4'd3};
            new_reg[7]={rAllOc_first_r[4],4'd4};
            new_reg[8]={rAllOc_first_r[5],4'd5};
            {new_en[3],new_en[0],new_en[6]}=pop3_or_more[0];
            {new_en[4],new_en[1],new_en[7]}=pop3_or_more[1];
            {new_en[5],new_en[2],new_en[8]}=pop3_or_more[2];
            pos_1=2'd0;
            pos_2=2'd1;
          end
      endcase
  end

  always @(posedge clk) begin
      if (rst) begin
          lpos<=5'd0;
          hpos<=5'd1;
          pos<=2'd0;
      end else begin
          if (~stall & ~doStall) begin
              if (step) begin
                  lpos<=hpos;
                  hpos<=hhpos;
              end
              pos<=pos_d;
          end
      end
      
      if (rst) begin
          for(k=0;k<9;k=k+1) begin
              rAllOc[k]<=32'hffff_ffff;
              rThread[k]<=32'b0;
          end
      end else begin
          for(k=0;k<9;k=k+1) begin
              new_enn[k]=new_en[k] & ~stall & ~doStall;
              rAllOc[k]<=(rAllOc[k] & ~(rAllOc_first[k] & {32{new_enn[k]}})) | rAllOc_free[k] | 
	        ((rThread[k] ^~ {32{ethread}})&{32{except}}) | {32{~eboth & except}};
              if (thread) rThread[k]<=rThread[k] | (rAllOc_first[k] & {32{new_enn[k]}}) ;
              else rThread[k]<=rThread[k]& ~(rAllOc_first[k] & {32{new_enn[k]}}) ;
          end
      end
  end
endmodule

/*
module busy_updown_alloc(
  busy,
  regCnt,
  retCnt,
  busy_new);
  
  input pwire [6:0] busy;
  input pwire [3:0] regCnt;
  input pwire [3:0] retCnt;
  output pwire [6:0] busy_new;
  
  pwire [3:-3] en;
  
  assign en[3]=regCnt[3] && retCnt[0];
  assign en[2]=(regCnt[3] && retCnt[1]) || (regCnt[2] && retCnt[0]);
  assign en[1]=(regCnt[3] && retCnt[2]) || (regCnt[2] && retCnt[1]) || (regCnt[1] && retCnt[0]);
  assign en[0]=(regCnt&retCnt)!=4'b0;  
  assign en[-3]=retCnt[3] && regCnt[0];
  assign en[-2]=(retCnt[3] && regCnt[1]) || (retCnt[2] && regCnt[0]);
  assign en[-1]=(retCnt[3] && regCnt[2]) || (retCnt[2] && regCnt[1]) || (retCnt[1] && regCnt[0]);
  
  generate
      genvar r;
      for (r=-3;r<=3;r=r+1) begin : addres_gen
          adder #(7) add_mod (busy,r[6:0],busy_new,1'b0,en[r]);
      end
  endgenerate
  
endmodule
*/

module get_clear_reg(
  newR0,newR1,newR2,newR3,newR4,newR5,newR6,newR7,newR8,
  newRF0,newRF1,newRF2,newRF3,newRF4,newRF5,newRF6,newRF7,newRF8,
  alloc,clr,
  allocS,clrS,
  clrR0,clrR1,clrR2,
  clrR3,clrR4,clrR5,
  clrR6,clrR7,clrR8,
  clrRS0,clrRS1,clrRS2,
  clrRS3,clrRS4,clrRS5,
  clrRS6,clrRS7,clrRS8
  );

  localparam REG_WIDTH=`reg_addr_width;
  input pwire [REG_WIDTH-1:0] newR0;
  input pwire [REG_WIDTH-1:0] newR1;
  input pwire [REG_WIDTH-1:0] newR2;
  input pwire [REG_WIDTH-1:0] newR3;
  input pwire [REG_WIDTH-1:0] newR4;
  input pwire [REG_WIDTH-1:0] newR5;
  input pwire [REG_WIDTH-1:0] newR6;
  input pwire [REG_WIDTH-1:0] newR7;
  input pwire [REG_WIDTH-1:0] newR8;

  input pwire [REG_WIDTH-1:0] newRF0;
  input pwire [REG_WIDTH-1:0] newRF1;
  input pwire [REG_WIDTH-1:0] newRF2;
  input pwire [REG_WIDTH-1:0] newRF3;
  input pwire [REG_WIDTH-1:0] newRF4;
  input pwire [REG_WIDTH-1:0] newRF5;
  input pwire [REG_WIDTH-1:0] newRF6;
  input pwire [REG_WIDTH-1:0] newRF7;
  input pwire [REG_WIDTH-1:0] newRF8;

  input pwire [8:0] alloc;
  output pwire [8:0] clr;

  input pwire [8:0] allocS;
  output pwire [8:0] clrS;

  output pwire [REG_WIDTH-1:0] clrR0;
  output pwire [REG_WIDTH-1:0] clrR1;
  output pwire [REG_WIDTH-1:0] clrR2;
  output pwire [REG_WIDTH-1:0] clrR3;
  output pwire [REG_WIDTH-1:0] clrR4;
  output pwire [REG_WIDTH-1:0] clrR5;
  output pwire [REG_WIDTH-1:0] clrR6;
  output pwire [REG_WIDTH-1:0] clrR7;
  output pwire [REG_WIDTH-1:0] clrR8;
  
  output pwire [REG_WIDTH-1:0] clrRS0;
  output pwire [REG_WIDTH-1:0] clrRS1;
  output pwire [REG_WIDTH-1:0] clrRS2;
  output pwire [REG_WIDTH-1:0] clrRS3;
  output pwire [REG_WIDTH-1:0] clrRS4;
  output pwire [REG_WIDTH-1:0] clrRS5;
  output pwire [REG_WIDTH-1:0] clrRS6;
  output pwire [REG_WIDTH-1:0] clrRS7;
  output pwire [REG_WIDTH-1:0] clrRS8;
  
  reg [REG_WIDTH-1:0] rs0_newR[2:0];
  reg [REG_WIDTH-1:0] rs1_newR[2:0];
  reg [REG_WIDTH-1:0] rs2_newR[2:0];
  reg [REG_WIDTH-1:0] rs0_newRF[2:0];
  reg [REG_WIDTH-1:0] rs1_newRF[2:0];
  reg [REG_WIDTH-1:0] rs2_newRF[2:0];
  reg [2:0] rs0_hasR;
  reg [2:0] rs1_hasR;
  reg [2:0] rs2_hasR;
  reg [2:0] rs0_hasS;
  reg [2:0] rs1_hasS;
  reg [2:0] rs2_hasS;

  integer k;

  assign clrR0=rs0_newR[0];
  assign clrR3=rs0_newR[1];
  assign clrR6=rs0_newR[2];
  assign clrR1=rs1_newR[0];
  assign clrR4=rs1_newR[1];
  assign clrR7=rs1_newR[2];
  assign clrR2=rs2_newR[0];
  assign clrR5=rs2_newR[1];
  assign clrR8=rs2_newR[2];

  assign clrRS0=rs0_newRF[0];
  assign clrRS3=rs0_newRF[1];
  assign clrRS6=rs0_newRF[2];
  assign clrRS1=rs1_newRF[0];
  assign clrRS4=rs1_newRF[1];
  assign clrRS7=rs1_newRF[2];
  assign clrRS2=rs2_newRF[0];
  assign clrRS5=rs2_newRF[1];
  assign clrRS8=rs2_newRF[2];

  assign clr[0]=rs0_hasR[0];
  assign clr[3]=rs0_hasR[1];
  assign clr[6]=rs0_hasR[2];
  assign clr[1]=rs1_hasR[0];
  assign clr[4]=rs1_hasR[1];
  assign clr[7]=rs1_hasR[2];
  assign clr[2]=rs2_hasR[0];
  assign clr[5]=rs2_hasR[1];
  assign clr[8]=rs2_hasR[2];

  assign clrS[0]=rs0_hasS[0];
  assign clrS[3]=rs0_hasS[1];
  assign clrS[6]=rs0_hasS[2];
  assign clrS[1]=rs1_hasS[0];
  assign clrS[4]=rs1_hasS[1];
  assign clrS[7]=rs1_hasS[2];
  assign clrS[2]=rs2_hasS[0];
  assign clrS[5]=rs2_hasS[1];
  assign clrS[8]=rs2_hasS[2];

  always @* begin
      for (k=0;k<3;k=k+1) begin
          rs0_newR[k]=9'd0;
          if (newR0[3:0]==k*3 && alloc[0]) rs0_newR[k]=newR0;
          if (newR1[3:0]==k*3 && alloc[1]) rs0_newR[k]=newR1;
          if (newR2[3:0]==k*3 && alloc[2]) rs0_newR[k]=newR2;

          rs1_newR[k]=9'd1;
          if (newR3[3:0]==k*3+1 && alloc[3]) rs1_newR[k]=newR3;
          if (newR4[3:0]==k*3+1 && alloc[4]) rs1_newR[k]=newR4;
          if (newR5[3:0]==k*3+1 && alloc[5]) rs1_newR[k]=newR5;
          
          rs2_newR[k]=9'd2;
          if (newR6[3:0]==k*3+2 && alloc[6]) rs2_newR[k]=newR6;
          if (newR7[3:0]==k*3+2 && alloc[7]) rs2_newR[k]=newR7;
          if (newR8[3:0]==k*3+2 && alloc[8]) rs2_newR[k]=newR8;
          
          rs0_hasR[k]=(newR0[3:0]==k*3 && alloc[0]) || (newR1[3:0]==k*3 && alloc[1]) || (newR2[3:0]==k*3 && alloc[2]);
          rs1_hasR[k]=(newR3[3:0]==k*3+1 && alloc[3]) || (newR4[3:0]==k*3+1 && alloc[4]) || (newR5[3:0]==k*3+1 && alloc[5]);
          rs2_hasR[k]=(newR6[3:0]==k*3+2 && alloc[6]) || (newR7[3:0]==k*3+2 && alloc[7]) || (newR8[3:0]==k*3+2 && alloc[8]);

          rs0_hasS[k]=(newRF0[3:0]==k*3 && allocS[0]) || (newRF1[3:0]==k*3 && allocS[1]) || (newRF2[3:0]==k*3 && allocS[2]);
          rs1_hasS[k]=(newRF3[3:0]==k*3+1 && allocS[3]) || (newRF4[3:0]==k*3+1 && allocS[4]) || (newRF5[3:0]==k*3+1 && allocS[5]);
          rs2_hasS[k]=(newRF6[3:0]==k*3+2 && allocS[6]) || (newRF7[3:0]==k*3+2 && allocS[7]) || (newRF8[3:0]==k*3+2 && allocS[8]);
          
	  rs0_newRF[k]=9'd0;
          if (newRF0[3:0]==k*3 && allocS[0]) rs0_newRF[k]=newRF0;
          if (newRF1[3:0]==k*3 && allocS[1]) rs0_newRF[k]=newRF1;
          if (newRF2[3:0]==k*3 && allocS[2]) rs0_newRF[k]=newRF2;

          rs1_newRF[k]=9'd1;
          if (newRF3[3:0]==k*3+1 && allocS[3]) rs1_newRF[k]=newRF3;
          if (newRF4[3:0]==k*3+1 && allocS[4]) rs1_newRF[k]=newRF4;
          if (newRF5[3:0]==k*3+1 && allocS[5]) rs1_newRF[k]=newRF5;
          
          rs2_newRF[k]=9'd2;
          if (newRF6[3:0]==k*3+2 && allocS[6]) rs2_newRF[k]=newRF6;
          if (newRF7[3:0]==k*3+2 && allocS[7]) rs2_newRF[k]=newRF7;
          if (newRF8[3:0]==k*3+2 && allocS[8]) rs2_newRF[k]=newRF8;
      end
  end
endmodule


module get_flag_infl(
  rs0i1_flagDep,
  rs0i2_flagDep,
  rs1i1_flagDep,
  rs1i2_flagDep,
  rs2i1_flagDep,
  rs2i2_flagDep,
  srcFlight,
  infl
  );

  input pwire [3:0] rs0i1_flagDep;
  input pwire [3:0] rs0i2_flagDep;
  input pwire [3:0] rs1i1_flagDep;
  input pwire [3:0] rs1i2_flagDep;
  input pwire [3:0] rs2i1_flagDep;
  input pwire [3:0] rs2i2_flagDep;
  input pwire srcFlight;
  output pwire [8:0] infl;
  
  assign infl[1]=rs0i1_flagDep==4'he && srcFlight || ~rs0i1_flagDep[3] || rs0i1_flagDep==4'h8;
  assign infl[2]=rs0i2_flagDep==4'he && srcFlight || ~rs0i2_flagDep[3] || rs0i2_flagDep==4'h8;
  assign infl[4]=rs1i1_flagDep==4'he && srcFlight || ~rs1i1_flagDep[3] || rs1i1_flagDep==4'h8;
  assign infl[5]=rs1i2_flagDep==4'he && srcFlight || ~rs1i2_flagDep[3] || rs1i2_flagDep==4'h8;
  assign infl[7]=rs2i1_flagDep==4'he && srcFlight || ~rs2i1_flagDep[3] || rs2i1_flagDep==4'h8;
  assign infl[8]=rs2i2_flagDep==4'he && srcFlight || ~rs2i2_flagDep[3] || rs2i2_flagDep==4'h8;
  
  assign infl[0]=1'b0;
  assign infl[3]=1'b0;
  assign infl[6]=1'b0;
  
endmodule
  
  
  /*
module get_funit(
  rs0i0_index,rs0i0_port,rs0i0_en,
  rs0i1_index,rs0i1_port,rs0i1_en,
  rs0i2_index,rs0i2_port,rs0i2_en,
  rs1i0_index,rs1i0_port,rs1i0_en,
  rs1i1_index,rs1i1_port,rs1i1_en,
  rs1i2_index,rs1i2_port,rs1i2_en,
  rs2i0_index,rs2i0_port,rs2i0_en,
  rs2i1_index,rs2i1_port,rs2i1_en,
  rs2i2_index,rs2i2_port,rs2i2_en,
  funit0,funit1,funit2,
  funit3,funit4,funit5,
  funit6,funit7,funit8,
  funit9
  );

  localparam PORT_WIDTH=3;

  localparam PORT_LOAD=3'd1;
  localparam PORT_STORE=3'd2;
  localparam PORT_SHIFT=3'd3;
  localparam PORT_ALU=3'd4;
  localparam PORT_MUL=3'd5;
  
  localparam FN_WIDTH=10;
  
  input pwire [3:0] rs0i0_index;
  input pwire [PORT_WIDTH-1:0] rs0i0_port;
  input pwire rs0i0_en;

  input pwire [3:0] rs0i1_index;
  input pwire [PORT_WIDTH-1:0] rs0i1_port;
  input pwire rs0i1_en;

  input pwire [3:0] rs0i2_index;
  input pwire [PORT_WIDTH-1:0] rs0i2_port;
  input pwire rs0i2_en;


  input pwire [3:0] rs1i0_index;
  input pwire [PORT_WIDTH-1:0] rs1i0_port;
  input pwire rs1i0_en;

  input pwire [3:0] rs1i1_index;
  input pwire [PORT_WIDTH-1:0] rs1i1_port;
  input pwire rs1i1_en;

  input pwire [3:0] rs1i2_index;
  input pwire [PORT_WIDTH-1:0] rs1i2_port;
  input pwire rs1i2_en;


  input pwire [3:0] rs2i0_index;
  input pwire [PORT_WIDTH-1:0] rs2i0_port;
  input pwire rs2i0_en;

  input pwire [3:0] rs2i1_index;
  input pwire [PORT_WIDTH-1:0] rs2i1_port;
  input pwire rs2i1_en;

  input pwire [3:0] rs2i2_index;
  input pwire [PORT_WIDTH-1:0] rs2i2_port;
  input pwire rs2i2_en;
  
  output pwire [9:0] funit0;
  output pwire [9:0] funit1;
  output pwire [9:0] funit2;
  output pwire [9:0] funit3;
  output pwire [9:0] funit4;
  output pwire [9:0] funit5;
  output pwire [9:0] funit6;
  output pwire [9:0] funit7;
  output pwire [9:0] funit8;
  output pwire [9:0] funit9;

  pwire [9:0] funt[9:0];

  assign funit0=funt[0];  
  assign funit1=funt[1];  
  assign funit2=funt[2];  
  assign funit3=funt[3];  
  assign funit4=funt[4];  
  assign funit5=funt[5];  
  assign funit6=funt[6];  
  assign funit7=funt[7];  
  assign funit8=funt[8];  
  assign funit9=funt[9];  
  generate
      genvar k;
      for(k=0;k<10;k=k+1) begin
          pwire [8:0] rs_eq;
          assign rs_eq[0]= k==rs0i0_index;
          assign rs_eq[1]= k==rs1i0_index;
          assign rs_eq[2]= k==rs2i0_index;
          assign rs_eq[3]= k==rs0i1_index;
          assign rs_eq[4]= k==rs1i1_index;
          assign rs_eq[5]= k==rs2i1_index;
          assign rs_eq[6]= k==rs0i2_index;
          assign rs_eq[7]= k==rs1i2_index;
          assign rs_eq[8]= k==rs2i2_index;
          
          assign funt[k][0]=rs_eq[0] & (rs0i0_port=PORT_LOAD || rs0i0_port==PORT_STORE) ||
            rs_eq[3] & (rs0i1_port=PORT_LOAD || rs0i1_port==PORT_STORE);
          assign funt[k][1]=rs_eq[1] & (rs1i0_port=PORT_LOAD || rs1i0_port==PORT_STORE) ||
            rs_eq[4] & (rs1i1_port=PORT_LOAD || rs1i1_port==PORT_STORE);
          assign funt[k][2]=rs_eq[2] & (rs2i0_port=PORT_LOAD || rs2i0_port==PORT_STORE) ||
            rs_eq[5] & (rs2i1_port=PORT_LOAD || rs2i1_port==PORT_STORE);
          assign funt[k][3]=|funt[k][2:0];
          
          assign funt[k][4]=rs_eq[3] && rs0i1_port==PORT_ALU;
          assign funt[k][5]=rs_eq[4] && rs1i1_port==PORT_ALU;
          assign funt[k][6]=(rs_eq[5] && rs2i1_port==PORT_ALU) ||
             (rs_eq[8] && rs2i2_port==PORT_MUL);
          
          assign funt[k][7]=(rs_eq[6] && rs0i2_port!=PORT_MUL) ||
            (rs_eq[3]&& rs0i1_port==PORT_SHIFT);
          assign funt[k][8]=(rs_eq[7] && rs1i2_port!=PORT_MUL) ||
            (rs_eq[4]&& rs1i1_port==PORT_SHIFT);
          assign funt[k][9]=(rs_eq[8] && rs2i2_port!=PORT_MUL) ||
            (rs_eq[5]&& rs2i1_port==PORT_SHIFT);
      end
  endgenerate  
endmodule
*/      
  
  
  
module get_funit(
  rs0i0_index,rs0i0_port,
  rs0i1_index,rs0i1_port,
  rs0i2_index,rs0i2_port,
  rs1i0_index,rs1i0_port,
  rs1i1_index,rs1i1_port,
  rs1i2_index,rs1i2_port,
  rs2i0_index,rs2i0_port,
  rs2i1_index,rs2i1_port,
  rs2i2_index,rs2i2_port,mul,
  funit0,funit1,funit2,
  funit3,funit4,funit5,
  funit6,funit7,funit8
  );

  localparam PORT_WIDTH=4;

  localparam PORT_LOAD=4'd1;
  localparam PORT_STORE=4'd2;
  localparam PORT_SHIFT=4'd3;
  localparam PORT_ALU=4'd4;
  localparam PORT_MUL=4'd5;
  localparam PORT_FADD=4'd6;
  localparam PORT_FMUL=4'd7;
  localparam PORT_FANY=4'd8;
  localparam PORT_VADD=4'd9;
  localparam PORT_VCMP=4'd10;
  localparam PORT_VANY=4'd11;
  
  localparam FN_WIDTH=10;
  
  input pwire [3:0] rs0i0_index;
  input pwire [PORT_WIDTH-1:0] rs0i0_port;

  input pwire [3:0] rs0i1_index;
  input pwire [PORT_WIDTH-1:0] rs0i1_port;

  input pwire [3:0] rs0i2_index;
  input pwire [PORT_WIDTH-1:0] rs0i2_port;


  input pwire [3:0] rs1i0_index;
  input pwire [PORT_WIDTH-1:0] rs1i0_port;

  input pwire [3:0] rs1i1_index;
  input pwire [PORT_WIDTH-1:0] rs1i1_port;

  input pwire [3:0] rs1i2_index;
  input pwire [PORT_WIDTH-1:0] rs1i2_port;


  input pwire [3:0] rs2i0_index;
  input pwire [PORT_WIDTH-1:0] rs2i0_port;

  input pwire [3:0] rs2i1_index;
  input pwire [PORT_WIDTH-1:0] rs2i1_port;

  input pwire [3:0] rs2i2_index;
  input pwire [PORT_WIDTH-1:0] rs2i2_port;
  input pwire mul;

  output pwire [9:0] funit0;
  output pwire [9:0] funit1;
  output pwire [9:0] funit2;
  output pwire [9:0] funit3;
  output pwire [9:0] funit4;
  output pwire [9:0] funit5;
  output pwire [9:0] funit6;
  output pwire [9:0] funit7;
  output pwire [9:0] funit8;

  reg [9:0] funit[9:0];
  integer k;

  assign funit0=funit[0];  
  assign funit1=funit[1];  
  assign funit2=funit[2];  
  assign funit3=funit[3];  
  assign funit4=funit[4];  
  assign funit5=funit[5];  
  assign funit6=funit[6];  
  assign funit7=funit[7];  
  assign funit8=funit[8];  

  always @* begin

      for(k=0;k<10;k=k+1) funit[k]=10'b0;
      
      funit[0][0]=rs0i0_port!=PORT_STORE;
      funit[3][1]=rs1i0_port!=PORT_STORE;
      funit[6][2]=rs2i0_port!=PORT_STORE;
      
      funit[1][0]=rs0i1_port==PORT_LOAD;
      funit[4][1]=rs1i1_port==PORT_LOAD;
      funit[7][2]=rs2i1_port==PORT_LOAD;

      funit[0][3]=rs0i0_port!=PORT_STORE;
      funit[3][3]=rs1i0_port!=PORT_STORE;
      funit[6][3]=rs2i0_port!=PORT_STORE;
      
      funit[1][3]=rs0i1_port==PORT_LOAD;
      funit[4][3]=rs1i1_port==PORT_LOAD;
      funit[7][3]=rs2i1_port==PORT_LOAD;
      
      funit[1][4]=rs0i1_port==PORT_ALU || rs0i1_port==PORT_FADD || rs0i1_port==PORT_FANY 
        || rs0i1_port==PORT_VADD || rs0i1_port==PORT_VANY;
      if (rs0i1_port==PORT_ALU && (rs0i2_port==PORT_VADD || rs0i2_port==PORT_FADD)) funit[1][4]=0;
      funit[4][5]=rs1i1_port==PORT_ALU || rs1i1_port==PORT_FADD || rs1i1_port==PORT_FANY 
        || rs1i1_port==PORT_VADD || rs1i1_port==PORT_VANY;
      if (rs1i1_port==PORT_ALU && (rs1i2_port==PORT_VADD || rs1i2_port==PORT_FADD)) funit[4][5]=0;
      funit[7][6]=rs2i1_port==PORT_ALU || rs2i1_port==PORT_FADD || rs2i1_port==PORT_FANY 
        || rs2i1_port==PORT_VADD || rs2i1_port==PORT_VANY;
      if (rs2i1_port==PORT_ALU && (rs2i2_port==PORT_VADD || rs2i2_port==PORT_FADD)) funit[7][6]=0;

      funit[1][7]=rs0i1_port==PORT_SHIFT || rs0i1_port==PORT_VCMP || rs0i1_port==PORT_FMUL;
      if (rs0i1_port==PORT_ALU && (rs0i2_port==PORT_VADD || rs0i2_port==PORT_FADD)) funit[1][7]=1;
      funit[4][8]=rs1i1_port==PORT_SHIFT || rs1i1_port==PORT_VCMP || rs1i1_port==PORT_FMUL;
      if (rs1i1_port==PORT_ALU && (rs1i2_port==PORT_VADD || rs1i2_port==PORT_FADD)) funit[4][8]=1;
      funit[7][9]=rs2i1_port==PORT_SHIFT || rs2i1_port==PORT_VCMP || rs2i1_port==PORT_FMUL;
      if (rs2i1_port==PORT_ALU && (rs2i2_port==PORT_VADD || rs2i2_port==PORT_FADD)) funit[7][9]=1;
      
      funit[2][7]=rs0i2_port!=PORT_FADD && rs0i2_port!=PORT_VADD;      
      funit[5][8]=(rs1i2_port!=PORT_FADD && rs1i2_port!=PORT_VADD) || rs2i2_port==PORT_MUL;      
      funit[8][9]=rs2i2_port!=PORT_FADD && rs2i2_port!=PORT_VADD && ~mul; 
      
      funit[2][4]=rs0i2_port==PORT_FADD || rs0i2_port==PORT_VADD;
      funit[5][5]=rs1i2_port==PORT_FADD || rs1i2_port==PORT_VADD;
      funit[8][6]=rs2i2_port==PORT_FADD || rs2i2_port==PORT_VADD || mul;     

  end
endmodule
      
  
module get_wSwp(
  clk,rst,
  lsi0,st0,
  lsi1,st1,
  lsi2,st2,
  Wswp,
  lsiA,
  lsiB,
  port0,port1,port2,
  domA0,domB0,
  domA1,domB1,
  domA2,domB2,
  rA_useF0,rB_useF0,
  rA_useF1,rB_useF1,
  rA_useF2,rB_useF2,
  op0,op1,op2,
  opA,opB,
  ind0,ind1,ind2,
  indA,indB,
  wq0,wq1,wq2,
  wqA,wqB
  );
  
  localparam PORT_STOREL=2;
  localparam PORT_AB=1;
  localparam PORT_AGU_ONLY=0;
  localparam OP_WIDTH=13;

  input pwire clk;
  input pwire rst;
  input pwire [2:0] lsi0;
  input pwire st0;
  input pwire [2:0] lsi1;
  input pwire st1;
  input pwire [2:0] lsi2;
  input pwire st2;
  output pwire reg [2:0] Wswp;
  output pwire [2:0] lsiA;
  output pwire [2:0] lsiB;
  output pwire [6:0] port0;
  output pwire [6:0] port1;
  output pwire [6:0] port2;
  input pwire  [0:0] domA0;
  input pwire  [0:0] domB0;
  input pwire  [0:0] domA1;
  input pwire  [0:0] domB1;
  input pwire  [0:0] domA2;
  input pwire  [0:0] domB2;
  input pwire rA_useF0,rB_useF0;
  input pwire rA_useF1,rB_useF1;
  input pwire rA_useF2,rB_useF2;
  input pwire  [OP_WIDTH-1:0] op0;
  input pwire  [OP_WIDTH-1:0] op1;
  input pwire  [OP_WIDTH-1:0] op2;
  output pwire [OP_WIDTH-1:0] opA;
  output pwire [OP_WIDTH-1:0] opB;
  input pwire [3:0] ind0;
  input pwire [3:0] ind1;
  input pwire [3:0] ind2;
  output pwire [3:0] indA;
  output pwire [3:0] indB;
  input pwire [5:0] wq0;
  input pwire [5:0] wq1;
  input pwire [5:0] wq2;
  output pwire [5:0] wqA;
  output pwire [5:0] wqB;
  
  
  pwire [2:0] lsiA_;
  pwire [2:0] lsiB_;
  pwire [2:0] stol;

  pwire [7:0] wqA_;
  pwire [7:0] wqB_;
  
  pwire [OP_WIDTH-1:0] opA_;
  pwire [OP_WIDTH-1:0] opB_;

  pwire [3:0] indA_;
  pwire [3:0] indB_;

  pwire [3:0] stCnt;
  pwire [2:0] first;
  pwire [2:0] second;
  pwire [2:0] third;  
  reg isOdd;
 
  reg [2:0] Wswp0;
  pwire stol_swp;

  assign stol[0]=lsi0==3'd7;
  assign stol[1]=lsi1==3'd7;
  assign stol[2]=lsi2==3'd7;
  
  assign stol_swp=stol[0] ? Wswp0[1] : 1'bz;
  assign stol_swp=stol[1] ? Wswp0[2] : 1'bz;
  assign stol_swp=stol[2] ? Wswp0[0] : 1'bz;
  assign stol_swp=stol ? 1'bz : 1'b0;
  
  assign {lsiA_,lsiB_}=stol[0] ? {lsi1,lsi2} : 6'bz;
  assign {lsiA_,lsiB_}=stol[1] ? {lsi2,lsi0} : 6'bz;
  assign {lsiA_,lsiB_}=stol[2] ? {lsi0,lsi1} : 6'bz;
  assign {lsiA_,lsiB_}=(!stol) ? {lsi0,lsi1} : 6'bz;
  
  assign lsiA=stol_swp ? lsiB_ : lsiA_;
  assign lsiB=stol_swp ? lsiA_ : lsiB_;

  assign {opA_,opB_}=stol[0] ? {op1,op2} : 26'bz;
  assign {opA_,opB_}=stol[1] ? {op2,op0} : 26'bz;
  assign {opA_,opB_}=stol[2] ? {op0,op1} : 26'bz;
  assign {opA_,opB_}=(!stol) ? {op0,op1} : 26'bz;
  
  assign opA=stol_swp ? opB_ : opA_;
  assign opB=stol_swp ? opA_ : opB_;

  assign {indA_,indB_}=stol[0] ? {ind1,ind2} : 8'bz;
  assign {indA_,indB_}=stol[1] ? {ind2,ind0} : 8'bz;
  assign {indA_,indB_}=stol[2] ? {ind0,ind1} : 8'bz;
  assign {indA_,indB_}=(!stol) ? {ind0,ind1} : 8'bz;
  
  assign indA=stol_swp ? indB_ : indA_;
  assign indB=stol_swp ? indA_ : indB_;
  
  assign {wqA_,wqB_}=stol[0] ? {wq1,wq2} : 12'bz;
  assign {wqA_,wqB_}=stol[1] ? {wq2,wq0} : 12'bz;
  assign {wqA_,wqB_}=stol[2] ? {wq0,wq1} : 12'bz;
  assign {wqA_,wqB_}=(!stol) ? {wq0,wq1} : 12'bz;
  
  assign wqA=stol_swp ? wqB_ : wqA_;
  assign wqB=stol_swp ? wqA_ : wqB_;
  
  assign port0[PORT_AB]=~Wswp[0];
  assign port1[PORT_AB]=~Wswp[1];
  assign port2[PORT_AB]=~Wswp[2];
  
  assign port0[PORT_STOREL]=stol[0];
  assign port1[PORT_STOREL]=stol[1];
  assign port2[PORT_STOREL]=stol[2];

  assign port0[PORT_AGU_ONLY]=st0 && stol;
  assign port1[PORT_AGU_ONLY]=st1 && stol;
  assign port2[PORT_AGU_ONLY]=st2 && stol;
  
  assign port0[3]=port0[PORT_AB] ? rA_useF0 &&  ~domA0[0] : rB_useF0 && ~domB0[0];
  assign port0[4]=port0[PORT_AB] ? rA_useF0 &&   domA0[0] : rB_useF0 &&  domB0[0];
  assign port0[5]=(~port0[PORT_AB]) ? rA_useF0 &&  ~domA0[0] : rB_useF0 && ~domB0[0];
  assign port0[6]=(~port0[PORT_AB]) ? rA_useF0 &&   domA0[0] : rB_useF0 &&  domB0[0];

  assign port1[3]=port1[PORT_AB] ? rA_useF1 &&  ~domA1[0] : rB_useF1 && ~domB1[0];
  assign port1[4]=port1[PORT_AB] ? rA_useF1 &&   domA1[0] : rB_useF1 &&  domB1[0];
  assign port1[5]=(~port1[PORT_AB]) ? rA_useF1 &&  ~domA1[0] : rB_useF1 && ~domB1[0];
  assign port1[6]=(~port1[PORT_AB]) ? rA_useF1 &&   domA1[0] : rB_useF1 &&  domB1[0];

  assign port2[3]=port2[PORT_AB] ? rA_useF2 &&  ~domA2[0] : rB_useF2 && ~domB2[0];
  assign port2[4]=port2[PORT_AB] ? rA_useF2 &&   domA2[0] : rB_useF2 &&  domB2[0];
  assign port2[5]=(~port2[PORT_AB]) ? rA_useF2 &&  ~domA2[0] : rB_useF2 && ~domB2[0];
  assign port2[6]=(~port2[PORT_AB]) ? rA_useF2 &&   domA2[0] : rB_useF2 &&  domB2[0];

  always @* begin
    Wswp0=(first & {3{isOdd}}) | (second & {3{~isOdd}}) | (third & {3{isOdd}});
    Wswp=(Wswp0&~stol)|({3{stol_swp}}&stol);
  end
  
  popcnt3 cnt_mod({st2,st1,st0},stCnt);
  bit_find_first_bit #(3) first_mod({st2,st1,st0},first,);
  bit_find_first_bit #(3) second_mod({st2,st1,st0} & ~first,second,);
  bit_find_first_bit #(3) third_mod({st2,st1,st0} &~(first|second),third,);
  
  always @(posedge clk) begin
    if (rst) begin
      isOdd<=1'b0;
    end else begin
      if (stCnt[1] || stCnt[3]) isOdd<=~isOdd;
    end
  end
endmodule

module backend_get_ret(
  newR0,newR1,newR2,newR3,newR4,newR5,newR6,newR7,newR8,
  en0,en1,en2,en3,en4,en5,en6,en7,en8, 
  rs_index0,rs_index1,rs_index2,rs_index3,
  rs_index4,rs_index5,rs_index6,rs_index7,
  rs_index8,
  ret0,ret1,ret2,
  ret3,ret4,ret5,
  ret6,ret7,ret8
  );
  localparam REG_WIDTH=`reg_addr_width;

  input pwire [REG_WIDTH-1:0] newR0;
  input pwire [REG_WIDTH-1:0] newR1;
  input pwire [REG_WIDTH-1:0] newR2;
  input pwire [REG_WIDTH-1:0] newR3;
  input pwire [REG_WIDTH-1:0] newR4;
  input pwire [REG_WIDTH-1:0] newR5;
  input pwire [REG_WIDTH-1:0] newR6;
  input pwire [REG_WIDTH-1:0] newR7;
  input pwire [REG_WIDTH-1:0] newR8;
  
  input pwire en0,en1,en2,en3,en4,en5,en6,en7,en8; 

  input pwire [3:0] rs_index0;
  input pwire [3:0] rs_index1;
  input pwire [3:0] rs_index2;
  input pwire [3:0] rs_index3;
  input pwire [3:0] rs_index4;
  input pwire [3:0] rs_index5;
  input pwire [3:0] rs_index6;
  input pwire [3:0] rs_index7;
  input pwire [3:0] rs_index8;

  output pwire reg [3:0] ret0;
  output pwire reg [3:0] ret1;
  output pwire reg [3:0] ret2;
  output pwire reg [3:0] ret3;
  output pwire reg [3:0] ret4;
  output pwire reg [3:0] ret5;
  output pwire reg [3:0] ret6;
  output pwire reg [3:0] ret7;
  output pwire reg [3:0] ret8;

  reg [3:0] ret[8:0];
  reg [3:0] rs_newR[8:0];
  reg [3:0] rs_index[9:0];
  reg [8:0] rs_ret_en;
  
  integer k,j;
  
  always @* begin
      for (k=0;k<3;k=k+1) begin
          rs_newR[k]=4'd9;
          if (newR0[3:0]==k*3 && en0) rs_newR[k]=4'd0;
          if (newR1[3:0]==k*3 && en1) rs_newR[k]=4'd1;
          if (newR2[3:0]==k*3 && en2) rs_newR[k]=4'd2;

          rs_newR[3+k]=4'd9;
          if (newR3[3:0]==k*3+1 && en3) rs_newR[3+k]=4'd3;
          if (newR4[3:0]==k*3+1 && en4) rs_newR[3+k]=4'd4;
          if (newR5[3:0]==k*3+1 && en5) rs_newR[3+k]=4'd5;
          
          rs_newR[6+k]=4'd9;
          if (newR6[3:0]==k*3+2 && en6) rs_newR[6+k]=4'd6;
          if (newR7[3:0]==k*3+2 && en7) rs_newR[6+k]=4'd7;
          if (newR8[3:0]==k*3+2 && en8) rs_newR[6+k]=4'd8;
          

      end
  end

  always @* begin
      rs_ret_en={en8,en7,en6,en5,en4,en3,en2,en1,en0};
      
      for(j=0;j<9;j=j+1) begin
          ret[j]=rs_index[rs_newR[j]];
      end
  end
  always @* begin
      rs_index[0]=rs_index0;
      rs_index[1]=rs_index1;
      rs_index[2]=rs_index2;
      rs_index[3]=rs_index3;
      rs_index[4]=rs_index4;
      rs_index[5]=rs_index5;
      rs_index[6]=rs_index6;
      rs_index[7]=rs_index7;
      rs_index[8]=rs_index8;
      rs_index[9]=4'hf;
  end
  always @* begin
      ret0=ret[0];
      ret1=ret[3];
      ret2=ret[6];
      ret3=ret[1];
      ret4=ret[4];
      ret5=ret[7];
      ret6=ret[2];
      ret7=ret[5];
      ret8=ret[8];
  end

endmodule


module backend_reorder_free_regs(
  rs_reg0,rs_reg1,rs_reg2,
  rs_reg3,rs_reg4,rs_reg5,
  rs_reg6,rs_reg7,rs_reg8,
  rs_index0,rs_index1,rs_index2,
  rs_index3,rs_index4,rs_index5,
  rs_index6,rs_index7,rs_index8,
  instr_reg0,instr_reg1,instr_reg2,
  instr_reg3,instr_reg4,instr_reg5,
  instr_reg6,instr_reg7,instr_reg8,
  instr_reg9
  );
  input pwire [8:0] rs_reg0;
  input pwire [8:0] rs_reg1;
  input pwire [8:0] rs_reg2;
  input pwire [8:0] rs_reg3;
  input pwire [8:0] rs_reg4;
  input pwire [8:0] rs_reg5;
  input pwire [8:0] rs_reg6;
  input pwire [8:0] rs_reg7;
  input pwire [8:0] rs_reg8;

  input pwire [3:0] rs_index0;
  input pwire [3:0] rs_index1;
  input pwire [3:0] rs_index2;
  input pwire [3:0] rs_index3;
  input pwire [3:0] rs_index4;
  input pwire [3:0] rs_index5;
  input pwire [3:0] rs_index6;
  input pwire [3:0] rs_index7;
  input pwire [3:0] rs_index8;

  output pwire [8:0] instr_reg0;
  output pwire [8:0] instr_reg1;
  output pwire [8:0] instr_reg2;
  output pwire [8:0] instr_reg3;
  output pwire [8:0] instr_reg4;
  output pwire [8:0] instr_reg5;
  output pwire [8:0] instr_reg6;
  output pwire [8:0] instr_reg7;
  output pwire [8:0] instr_reg8;
  output pwire [8:0] instr_reg9;

  pwire [8:0] rs_reg[8:0];
  pwire [3:0] rs_index[8:0];
  pwire [8:0] instr_reg[9:0];

  assign rs_reg[0]=rs_reg0;
  assign rs_reg[1]=rs_reg1;
  assign rs_reg[2]=rs_reg2;
  assign rs_reg[3]=rs_reg3;
  assign rs_reg[4]=rs_reg4;
  assign rs_reg[5]=rs_reg5;
  assign rs_reg[6]=rs_reg6;
  assign rs_reg[7]=rs_reg7;
  assign rs_reg[8]=rs_reg8;

  assign rs_index[0]=rs_index0;
  assign rs_index[1]=rs_index1;
  assign rs_index[2]=rs_index2;
  assign rs_index[3]=rs_index3;
  assign rs_index[4]=rs_index4;
  assign rs_index[5]=rs_index5;
  assign rs_index[6]=rs_index6;
  assign rs_index[7]=rs_index7;
  assign rs_index[8]=rs_index8;

  assign instr_reg0=instr_reg[0];
  assign instr_reg1=instr_reg[1];
  assign instr_reg2=instr_reg[2];
  assign instr_reg3=instr_reg[3];
  assign instr_reg4=instr_reg[4];
  assign instr_reg5=instr_reg[5];
  assign instr_reg6=instr_reg[6];
  assign instr_reg7=instr_reg[7];
  assign instr_reg8=instr_reg[8];
  assign instr_reg9=instr_reg[9];

  generate
      genvar k,j;
      for(j=0;j<10;j=j+1) begin
	  pwire [8:0] instr_eq;
	  for(k=0;k<8;k=k+1) begin
	      assign instr_eq[k]=rs_index[k]==j;
	      assign instr_reg[j]=instr_eq[k] ? rs_reg[k] : 9'bz;
          end
	  assign instr_reg[j]=instr_eq ? 9'bz : 9'h000;
      end
  endgenerate
endmodule
 
 
module get_LDQ_new_en(
  rs0i0_port,rs0i0_ldst_flg, 
  rs1i0_port,rs1i0_ldst_flg, 
  rs2i0_port,rs2i0_ldst_flg, 
  rs0i1_port,rs0i1_ldst_flg, 
  rs1i1_port,rs1i1_ldst_flg, 
  rs2i1_port,rs2i1_ldst_flg,
  new_mask);

  localparam PORT_WIDTH=4;
  localparam PORT_LOAD=4'd1;
  
  input pwire [PORT_WIDTH-1:0] rs0i0_port;
  input pwire rs0i0_ldst_flg;
  input pwire [PORT_WIDTH-1:0] rs1i0_port;
  input pwire rs1i0_ldst_flg;
  input pwire [PORT_WIDTH-1:0] rs2i0_port;
  input pwire rs2i0_ldst_flg;
  input pwire [PORT_WIDTH-1:0] rs0i1_port;
  input pwire rs0i1_ldst_flg;
  input pwire [PORT_WIDTH-1:0] rs1i1_port;
  input pwire rs1i1_ldst_flg;
  input pwire [PORT_WIDTH-1:0] rs2i1_port;
  input pwire rs2i1_ldst_flg;

  output pwire [5:0] new_mask;

  pwire [5:0] in_inc;

  assign in_inc[0]=rs0i0_port==PORT_LOAD && ~rs0i0_ldst_flg;
  assign in_inc[1]=rs1i0_port==PORT_LOAD && ~rs1i0_ldst_flg;
  assign in_inc[2]=rs2i0_port==PORT_LOAD && ~rs2i0_ldst_flg;
  assign in_inc[3]=rs0i1_port==PORT_LOAD && ~rs0i1_ldst_flg;
  assign in_inc[4]=rs1i1_port==PORT_LOAD && ~rs1i1_ldst_flg;
  assign in_inc[5]=rs2i1_port==PORT_LOAD && ~rs2i1_ldst_flg;

  assign new_mask=in_inc;

endmodule 

module get_wrtII(
  wrt0,wrt1,wrt2,
  lsi0,lsi1,lsi2,
  II0,II1,II2,
  wrtII0,wrtII1,wrtII2,
  wrtO0,wrtO1,wrtO2
  );

  input pwire [5:0] wrt0;
  input pwire [5:0] wrt1;
  input pwire [5:0] wrt2;
  input pwire [5:0] lsi0;
  input pwire [5:0] lsi1;
  input pwire [5:0] lsi2;
  input pwire [3:0] II0;
  input pwire [3:0] II1;
  input pwire [3:0] II2;
  output pwire [3:0] wrtII0;
  output pwire [3:0] wrtII1;
  output pwire [3:0] wrtII2;
  output pwire [2:0] wrtO0; 
  output pwire [2:0] wrtO1; 
  output pwire [2:0] wrtO2; 

  pwire [5:0] lsi[3:0];
  pwire [3:0] II[3:0];
  
  generate
    genvar p,q;
    for(p=0;p<6;p=p+1) begin
        for(q=0;q<3;q=q+1) begin
            assign wrtII0=(wrt0[p] && ~wrt0[p^1] && lsi[q][p] && ~(&lsi[q][1:0])) ? II[q] : 4'bz;
            assign wrtII1=(wrt1[p] && ~wrt1[p^1] && lsi[q][p] && ~(&lsi[q][1:0])) ? II[q] : 4'bz;
            assign wrtII2=(wrt2[p] && ~wrt2[p^1] && lsi[q][p] && ~(&lsi[q][1:0])) ? II[q] : 4'bz;
	end
        assign wrtO0=(wrt0[p] && ~wrt0[p^1]) ? p[2:0] : 3'bz;
        assign wrtO1=(wrt1[p] && ~wrt1[p^1]) ? p[2:0] : 3'bz;
        assign wrtO2=(wrt2[p] && ~wrt2[p^1]) ? p[2:0] : 3'bz;
    end
  endgenerate
  assign wrtII0=(&wrt0[1:0]) ? 4'hf : 4'bz;
  assign wrtII1=(&wrt1[1:0]) ? 4'hf : 4'bz;
  assign wrtII2=(&wrt2[1:0]) ? 4'hf : 4'bz;

  assign wrtO0=(&wrt0[1:0]) ? 3'd7 : 3'bz;
  assign wrtO1=(&wrt1[1:0]) ? 3'd7 : 3'bz;
  assign wrtO2=(&wrt2[1:0]) ? 3'd7 : 3'bz;

  assign lsi[0]=lsi0;
  assign lsi[1]=lsi1;
  assign lsi[2]=lsi2;
  
  assign II[0]=II0;
  assign II[1]=II1;
  assign II[2]=II2;
endmodule

module alloc_WQ(
  clk,
  rst,
  stall,
  doStall,
  except,
  except_thread,
  except_both,
  newEn,
  newThr,
  wrt0,wrt1,wrt2,
  lsi0,lsi1,lsi2,
  WQr0,WQr1,WQr2,
  WQs0,WQs1,WQs2,
  free0,freeWQ0,
  free1,freeWQ1
  );
 /*verilator hier_block*/ 

  input pwire clk;
  input pwire rst;
  input pwire stall;
  output pwire doStall;
  input pwire except;
  input pwire except_thread;
  input pwire except_both;
  input pwire newEn;
  input pwire newThr;
  input pwire [5:0] wrt0;
  input pwire [5:0] wrt1;
  input pwire [5:0] wrt2;
  input pwire [5:0] lsi0;
  input pwire [5:0] lsi1;
  input pwire [5:0] lsi2;
  output pwire [5:0] WQr0;
  output pwire [5:0] WQr1;
  output pwire [5:0] WQr2;
  output pwire [5:0] WQs0;
  output pwire [5:0] WQs1;
  output pwire [5:0] WQs2;
  input pwire free0;
  input pwire [5:0] freeWQ0;
  input pwire free1;
  input pwire [5:0] freeWQ1;

  pwire [5:0] wrt[2:0];
  pwire [5:0] WQ[2:0];
  reg [6:0] addr_low;
  reg [6:0] addr_hi;
  pwire [6:0] addr_low1;
  pwire [6:0] addr_hi1;
  pwire [6:0] addr_low2;
  pwire [6:0] addr_hi2;
  reg [6:0] xaddr_low;
  reg [6:0] xaddr_hi;
  pwire [6:0] xaddr_low1;
  pwire [6:0] xaddr_hi1;
  pwire [6:0] xaddr_low2;
  pwire [6:0] xaddr_hi2;
//  reg  [6:0] cnt;
//  pwire [6:0] cnt_d;
  reg pos;
  pwire [3:0] wrcnt;
//  pwire [3:-2] cncnt;


  integer k;
 
  generate
    genvar p,q;
    for(p=0;p<6;p=p+1) begin
        for(q=0;q<3;q=q+1) begin
	    assign WQr0=(wrt[q][p] && lsi0[p] && !(&lsi0[1:0]) & !(&wrt[q][1:0])) ? WQ[q] : 6'bz;
	    assign WQr1=(wrt[q][p] && lsi1[p] && !(&lsi1[1:0]) & !(&wrt[q][1:0])) ? WQ[q] : 6'bz;
	    assign WQr2=(wrt[q][p] && lsi2[p] && !(&lsi2[1:0]) & !(&wrt[q][1:0])) ? WQ[q] : 6'bz;
	end
    end
  endgenerate

//  assign cncnt=(~free0) ? {wrcnt,2'b0} : 6'bz;
//  assign cncnt=(free0 & ~free1) ? {1'b0,wrcnt,1'b0} : 6'bz;
//  assign cncnt=(free0 & free1) ? {2'b0,wrcnt} : 6'bz;

  assign wrt[0]=wrt0;
  assign wrt[1]=wrt1;
  assign wrt[2]=wrt2;
  
  assign WQr0=((lsi0!=wrt0 && lsi0!=wrt1 && lsi0!=wrt2) || lsi0[4:0]==5'h1f) ? 6'h1f  : 6'bz;
  assign WQr1=((lsi1!=wrt0 && lsi1!=wrt1 && lsi1!=wrt2) || lsi1[4:0]==5'h1f) ? 6'h1f  : 6'bz;
  assign WQr2=((lsi2!=wrt0 && lsi2!=wrt1 && lsi2!=wrt2) || lsi2[4:0]==5'h1f) ? 6'h1f  : 6'bz;

  assign WQ[0]=pos ? {addr_low,1'b1} : {addr_low,1'b0};
  assign WQ[1]=pos ? {addr_hi,1'b0} : {addr_low,1'b1};
  assign WQ[2]=pos ? {addr_hi,1'b1} : {addr_hi,1'b0};

  assign WQs0=WQ[0];
  assign WQs1=WQ[1];
  assign WQs2=WQ[2];

  assign doStall=1'b0;//newEn&&busyA[xaddr_low]|busyB[xaddr_low]|busyA[xaddr_hi]|busyB[xaddr_hi];

  assign addr_hi2[0]=addr_hi[0];
  assign addr_low2[0]=addr_low[0];

  assign addr_hi1=(addr_hi==7'd63) ? 7'b0 : 7'bz;
  assign addr_low1=(addr_low==7'd63) ? 7'b0 : 7'bz;
  assign addr_hi2[6:1]=(addr_hi[6:1]==6'd31) ? 6'b0 : 6'bz;
  assign addr_low2[6:1]=(addr_low[6:1]==6'd31) ? 6'b0 : 6'bz;

  assign xaddr_hi2[0]=xaddr_hi[0];
  assign xaddr_low2[0]=xaddr_low[0];

  assign xaddr_hi1=(xaddr_hi==7'd63) ? 7'b0 : 7'bz;
  assign xaddr_low1=(xaddr_low==7'd63) ? 7'b0 : 7'bz;
  assign xaddr_hi2[6:1]=(xaddr_hi[6:1]==6'd31) ? 6'b0 : 6'bz;
  assign xaddr_low2[6:1]=(xaddr_low[6:1]==6'd31) ? 6'b0 : 6'bz;
  adder_inc #(7) hiAdd1_mod(addr_hi,addr_hi1,addr_hi!=7'd63,);
  adder_inc #(7) lowAdd1_mod(addr_low,addr_low1,addr_low!=7'd63,);
  adder_inc #(6) hiAdd2_mod(addr_hi[6:1],addr_hi2[6:1],addr_hi[6:1]!=6'd31,);
  adder_inc #(6) lowAdd2_mod(addr_low[6:1],addr_low2[6:1],addr_low[6:1]!=6'd31,);
  adder_inc #(7) hiAddx1_mod(xaddr_hi,xaddr_hi1,xaddr_hi!=7'd63,);
  adder_inc #(7) lowAddx1_mod(xaddr_low,xaddr_low1,xaddr_low!=7'd63,);
  adder_inc #(6) hiAddx2_mod(xaddr_hi[6:1],xaddr_hi2[6:1],xaddr_hi[6:1]!=6'd31,);
  adder_inc #(6) lowAddx2_mod(xaddr_low[6:1],xaddr_low2[6:1],xaddr_low[6:1]!=6'd31,);
  popcnt3 cpop_mod(~{&wrt0[1:0],&wrt1[1:0],&wrt2[1:0]}&{3{~stall&~doStall&newEn}},wrcnt);
  always @(posedge clk) begin
      if (rst) begin
          addr_low<=7'd0;
          addr_hi<=7'd1;
          xaddr_low<=7'd48;
          xaddr_hi<=7'd49;
          pos<=1'b0;
      end else if (~stall & ~doStall & newEn) begin
       //verilator lint_off CASEINCOMPLETE
          casex({~{&wrt0[1:0],&wrt1[1:0],&wrt2[1:0]},pos})
              4'b1x01,4'b11x0: begin
              addr_low<=addr_low1;
              addr_hi<=addr_hi1;
              xaddr_low<=xaddr_low1;
              xaddr_hi<=xaddr_hi1;
              end
              4'b1111: begin
              addr_low<=addr_low2;
              addr_hi<=addr_hi2;
              xaddr_low<=xaddr_low2;
              xaddr_hi<=xaddr_hi2;
              end
          endcase
       //verilator lint_on CASEINCOMPLETE
          if (wrcnt[1] | wrcnt[3]) pos<=~pos;
      end
  end
endmodule



module wrtdata_combine(data,dataN,pdata,en,odata,odataN,opdata,low,sz,etype);
  input pwire [135:0] data;
  input pwire [135:0] dataN;
  input pwire [1:0] pdata;
  input pwire en;
  output pwire [127:0] odata;
  output pwire [127:0] odataN;
  output pwire [1:0] opdata;
  input pwire [1:0] low;
  input pwire [4:0] sz;
  input pwire [3:0] etype;

  pwire is_stack;

  assign is_stack=pdata[0] && &data[42:41];

  assign noptr=(is_stack && ~|etype[3:2] && etype[0]) || |low || etype[1] ;

  generate
      genvar c,d;
      for(c=0;c<4;c=c+1) begin : low_gen
	  //verilator lint_off WIDTH
          if (c) assign {odataN,odata}=(en && low==c) ? {dataN[127:8],sz==0 || sz==1 || sz==2 ? data[135:128] : dataN[7:0],
              data[127:0],{c{8'b0}}} : 256'bz;
          else assign {odataN,odata}=(en && low==c) ? {dataN[127:8],sz==0 || sz==1 || sz==2 ? data[135:128] : dataN[7:0],
              data[127:0]} : 256'bz;
	  //verilator lint_on WIDTH
      end
  endgenerate
  assign opdata=pdata&{1'b1,~noptr};

endmodule

module get_ben_een(
  low,
  sz,
  bgn0,
  end0,
  bgnBen,
  endBen
  );
  input pwire [1:0] low;
  input pwire [4:0] sz;
  input pwire [4:0] bgn0;
  output pwire reg [4:0] end0;
  output pwire reg [3:0] bgnBen;
  output pwire reg [3:0] endBen;

  pwire [4:0] bgn1;
  pwire [4:0] bgn2;
  pwire [4:0] bgn3;
  pwire [4:0] bgn4;
  reg [1:0] low2;
  reg stepOver;
  reg stepOver2;
 
  adder_inc #(5) add1_mod(bgn0,bgn1,1'b1,);
  adder #(5) add2_mod(bgn0,5'd2,bgn2,1'b0,1'b1,,,,);
  adder #(5) add3_mod(bgn0,5'd3,bgn3,1'b0,1'b1,,,,);
  adder #(5) add4_mod(bgn0,5'd4,bgn4,1'b0,1'b1,,,,);
  
  always @* begin
      case(low)
      0: low2=1;
      1: low2=2;
      2: low2=3;
      3: low2=0;
      endcase
      case(sz)
      5'd16: end0=bgn0;
      5'd17: end0=stepOver2 ? bgn1 : bgn0;
      5'd18,5'd6,5'd7,5'd8: 
             end0=stepOver ? bgn1 : bgn0;
      default: end0=stepOver ? bgn2 : bgn1; //5'd19
      5'd3: end0=stepOver2 ? bgn3 : bgn2;
      5'd0,5'd1,5'd2,5'ha,5'hb,5'hc:
            end0=stepOver ? bgn4 : bgn3;
      5'hf: end0=bgn4;
      endcase
  end
  always @* begin
      stepOver=low!=2'd0;
      stepOver2=low==2'd3;
      bgnBen=0;
      endBen=0;
      case(sz)
      5'd16: begin
              bgnBen[low]=1;
              endBen[low]=1;
          end
      5'd17: begin
              bgnBen[low]=1;
              if (stepOver2) begin
                  endBen[low2]=1; 
              end else begin
                  bgnBen[low2]=1;
                  endBen[low]=1;
                  endBen[low2]=1;
              end
          end
      5'd3: begin
            if (!stepOver2) begin endBen[low]=1; endBen[low2]=1; end
            else begin endBen[low2]=1; end
            case(low)
            0: begin bgnBen=4'hf; end
            1: begin bgnBen=4'he; end
            3: begin bgnBen=4'h8; end
            2: begin bgnBen=4'hc; end
            endcase
        end
      5'hf: begin
	  bgnBen=4'hf;
          endBen=4'hf;
      end
      default: case(low)
          0: begin bgnBen=4'hf; endBen=4'hf; end
          1: begin bgnBen=4'he; endBen=4'h1; end
          3: begin bgnBen=4'h8; endBen=4'h7; end
          2: begin bgnBen=4'hc; endBen=4'h3; end
          endcase
      endcase
  end
endmodule

module get_lsi_en(
  lsi0,flag0,
  lsi1,flag1,
  lsi2,flag2,
  lsi3,flag3,
  lsi4,flag4,
  lsi5,flag5,
  lsi_en);

  input pwire [2:0] lsi0;
  input pwire flag0;
  input pwire [2:0] lsi1;
  input pwire flag1;
  input pwire [2:0] lsi2;
  input pwire flag2;
  input pwire [2:0] lsi3;
  input pwire flag3;
  input pwire [2:0] lsi4;
  input pwire flag4;
  input pwire [2:0] lsi5;
  input pwire flag5;
  output pwire [5:0] lsi_en;

  generate
      genvar k;
      for(k=0;k<6;k=k+1) begin 
          assign lsi_en[k]=~(
            lsi0==k && flag0 ||
            lsi1==k && flag1 ||
            lsi2==k && flag2 ||
            lsi3==k && flag3 ||
            lsi4==k && flag4 ||
            lsi5==k && flag5);
      end
  endgenerate
endmodule

module msrss_watch(
  clk,
  rst,
  msrss_addr,
  msrss_data,
  msrss_en,
  data_out);
  parameter [15:0] ADDR=16'b0;
  parameter [64:0] INITVAL=64'b0;
  input pwire clk;
  input pwire rst;
  input pwire [15:0] msrss_addr;
  input pwire [64:0] msrss_data;
  input pwire msrss_en;
  output pwire reg [1:0][63:0] data_out;

  always @(posedge clk) begin
    if (rst) begin
	data_out[0]<=INITVAL;
	data_out[1]<=INITVAL;
    end else if (msrss_en) begin
	if (ADDR[14:0]==msrss_addr[14:0]) data_out[msrss_addr[15]]<=msrss_data;
    end
  end
endmodule


module fexcpt(
  mask,
  in,
  in_mask,
  in_en,
  no,
  en);

  input pwire [10:0] mask;
  input pwire [8:0] in;
  input pwire [10:0] in_mask;
  input pwire in_en;
  output pwire [13:0] no;
  output pwire en;

  pwire [13:0] msk1;
  pwire [10:0] first;
  pwire en0;
  pwire [13:0] no0;
  pwire [13:0] no_X;

  assign no=no_X;
  

  bit_find_first_bit #(11) first_mod(mask,first,en0);

  generate
    genvar t;
    for(t=0;t<11;t=t+1) begin
        assign no0=first[t] ? {t[10:0],3'd3} : 14'bz;
    end
  endgenerate

  assign no_X=in_en & ~en0 ? {in_mask,3'd3} : 14'bz;
  assign no_X=in_en & en0 ? no0 : 14'bz;
  assign no_X=~in_en ? {5'b0,in} : 14'bz;
  assign no0=en0 ? 14'bz : 14'b0;
  assign en=in_en | (in[1:0]!=2'd0);
endmodule
//verilator lint_on WIDTH
