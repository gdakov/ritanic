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



module cc_comb (
  clk,
  rst,
  readA_clkEn,
  readA_set_flag,
  readB_clkEn,
  readB_set_flag,
  fstallA,
  exceptA,
  cc_readA_IP,
  cc_readA_hit,
  readA_data,
  readA_dataX,
  errA,
  fstallB,
  exceptB,
  cc_readB_IP,
  cc_readB_hit,
  readB_data,
  readB_dataX,
  errB,
  write_IP,
  cc_write_wen,
  cc_invalidate,
  write_data,
  chkCL_IP,
  chkCL_clkEn,
  chkCL_hit,
  expun_addr,
  expun_wen
  );  
  
  localparam DATA_WIDTH=65*16;
  localparam ADDR_WIDTH=6;
  localparam IP_WIDTH=44;
  localparam PHYS_WIDTH=44;
  localparam LINK_WIDTH=47;

  input clk;
  input rst;
  input readA_clkEn;
  input readA_set_flag;
  input fstallA;
  input exceptA;
  input [IP_WIDTH-1:0] cc_readA_IP;
  output pwire cc_readA_hit;
  output pwire [DATA_WIDTH/4-1:0] readA_data;
  output pwire [14:0] readA_dataX;
  output pwire errA;
  input readB_clkEn;
  input readB_set_flag;
  input fstallB;
  input exceptB;
  input [IP_WIDTH-1:0] cc_readB_IP;
  output pwire cc_readB_hit;
  output pwire [DATA_WIDTH/4-1:0] readB_data;
  output pwire [14:0] readB_dataX;
  output pwire errB;
  input [IP_WIDTH-1:0] write_IP;
  input cc_write_wen;
  input cc_invalidate;

  input [DATA_WIDTH/2-1:0] write_data;
  input [IP_WIDTH-1:0] chkCL_IP;
  input chkCL_clkEn;
  output pwire chkCL_hit;
  output pwire [36:0] expun_addr;
  output pwire expun_wen;
  
  pwire [DATA_WIDTH-1:0] readA_data0;
  pwire [DATA_WIDTH-1:0] cc_readA_data0;
  pwire [DATA_WIDTH-1:0] readB_data0;
  pwire [DATA_WIDTH-1:0] cc_readB_data0;
  
  reg [IP_WIDTH-1:0] write_IP_reg;
  reg [DATA_WIDTH-1:0] write_data_reg;

  pwire [7:0] cc_readA_tagErr;
  pwire [7:0] cc_readA_hit_way;
  pwire [7:0] cc_readB_tagErr;
  pwire [7:0] cc_readB_hit_way;


  reg cc_write_wen_reg;
  reg cc_invalidate_reg;
  reg cc_write_wen_reg2;
  reg cc_invalidate_reg2;

  reg [IP_WIDTH-1:0] write_IP_reg2;
  reg [DATA_WIDTH-1:0] write_data_reg2;

  reg cc_readA_hitP;
  reg cc_readB_hitP;

  reg [DATA_WIDTH-1:0] readA_data0_reg;
  reg [DATA_WIDTH-1:0] readB_data0_reg;
  
  reg [IP_WIDTH-6:0] cc_readA_IP_reg;
  reg [IP_WIDTH-6:0] cc_readB_IP_reg;
  
  
  pwire [`wport-1:0] readA_dataX0;
  pwire [`wport-1:0] cc_readA_dataX0;
  pwire [14:0] readA_dataXP[3:0];
  reg [`wport-1:0] readA_dataX0_reg;
  pwire [`wport-1:0] readB_dataX0;
  pwire [`wport-1:0] cc_readB_dataX0;
  pwire [14:0] readB_dataXP[3:0];
  reg [`wport-1:0] readB_dataX0_reg;
  pwire [36:0] cc_exp_addr0;  
  reg [36:0] cc_exp_addr0_reg;  
//  pwire [71:0] read_dataY0;
//  pwire [17:0] read_dataYP;
//  reg [71:0] read_dataY0_reg;

  pwire [7:0] writeIP_next;
  
  pwire cc_readA_hit0;
  pwire cc_readB_hit0;
  pwire [7:0] cc_tagErrA;
  pwire [7:0] cc_tagErrB;
  pwire cc_expun_hit0;
  reg cc_expun_hitP; 

  reg readA_hit0A;
  reg readA_hit1A;
  reg readA_hit0B;
  reg readA_hit1B;
  reg readA_hitP;
  reg readB_hit0A;
  reg readB_hit1A;
  reg readB_hit0B;
  reg readB_hit1B;
  reg readB_hitP;

  pwire [DATA_WIDTH/4-1:0] readA_dataP[3:0];
  
  reg [7:0] cc_readA_tagErrP;
  pwire [DATA_WIDTH/4-1:0] readB_dataP[3:0];
  
  reg [7:0] cc_readB_tagErrP;
  
  reg readA_clkEn_reg;
  reg readB_clkEn_reg;
  reg chkCL_clkEn_reg;
  
  reg [1:0] cc_wen_step;
  
  
  integer a,b;
  

  assign readA_data0=cc_readA_data0;
  assign readA_dataX0=cc_readA_dataX0;
  
  assign readB_data0=cc_readB_data0;
  assign readB_dataX0=cc_readB_dataX0;
  
  assign readA_dataP[0]=~(({260{~readA_hit0A}} | ~readA_data0_reg[DATA_WIDTH/4-1:0]) & readA_dataP[1]); 
  assign readA_dataP[1]=~(({260{readA_hit1A}} &  readA_data0_reg[DATA_WIDTH/2-1:DATA_WIDTH/4]) | readA_dataP[2]); 
  assign readA_dataP[2]=~(({260{~readA_hit0B}} | ~readA_data0_reg[DATA_WIDTH/4*3-1:DATA_WIDTH/2]) & readA_dataP[3]); 
  assign readA_dataP[3]=~(({260{readA_hit1B}} & readA_data0_reg[DATA_WIDTH-1:DATA_WIDTH/4*3])); 
  
  assign readB_dataP[0]=~(({260{~readB_hit0A}} | ~readB_data0_reg[DATA_WIDTH/4-1:0]) & readB_dataP[1]); 
  assign readB_dataP[1]=~(({260{readB_hit1A}} &  readB_data0_reg[DATA_WIDTH/2-1:DATA_WIDTH/4]) | readB_dataP[2]); 
  assign readB_dataP[2]=~(({260{~readB_hit0B}} | ~readB_data0_reg[DATA_WIDTH/4*3-1:DATA_WIDTH/2]) & readB_dataP[3]); 
  assign readB_dataP[3]=~(({260{readB_hit1B}} & readB_data0_reg[DATA_WIDTH-1:DATA_WIDTH/4*3])); 
  
  assign readA_dataXP[0]=~(({15{~readA_hit0A}} | ~readA_dataX0_reg[14:0]) & readA_dataXP[1]); 
  assign readA_dataXP[1]=~(({15{readA_hit1A}} & readA_dataX0_reg[29:15]) | readA_dataXP[2]); 
  assign readA_dataXP[2]=~(({15{~readA_hit0B}} | ~readA_dataX0_reg[44:30]) & readA_dataXP[3]); 
  assign readA_dataXP[3]=~({15{readA_hit1B}} & readA_dataX0_reg[59:45]); 

  assign readB_dataXP[0]=~(({15{~readB_hit0A}} | ~readB_dataX0_reg[14:0]) & readB_dataXP[1]); 
  assign readB_dataXP[1]=~(({15{readB_hit1A}} & readB_dataX0_reg[29:15]) | readB_dataXP[2]); 
  assign readB_dataXP[2]=~(({15{~readB_hit0B}} | ~readB_dataX0_reg[44:30]) & readB_dataXP[3]); 
  assign readB_dataXP[3]=~({15{readB_hit1B}} & readB_dataX0_reg[59:45]); 



  ccRam_half cc_mod(
  .clk(clk),
  .rst(rst),
  .readA_clkEn(readA_clkEn_reg),
  .readA_IP(cc_readA_IP[43:1]),
  .readA_set_flag(readA_set_flag),
  .readA_data(cc_readA_data0),
  .readA_dataX(cc_readA_dataX0),
  .readA_hit(cc_readA_hit0),
  .readB_clkEn(readB_clkEn_reg),
  .readB_IP(cc_readB_IP[43:1]),
  .readB_set_flag(readB_set_flag),
  .readB_data(cc_readB_data0),
  .readB_dataX(cc_readB_dataX0),
  .readB_hit(cc_readB_hit0),
  .expun_hit(cc_expun_hit0),
  .chkCL_IP(chkCL_IP[43:5]),
  .chkCL_clkEn(chkCL_clkEn),
  .chkCL_hit(chkCL_hit),
  .write_IP(write_IP_reg2[IP_WIDTH-1:5]),
  .write_data(write_data_reg2),
  .write_wen(cc_write_wen_reg2),
  .expun_addr(cc_exp_addr0),
  .invalidate(cc_invalidate_reg2),
  .tagErrA(cc_tagErrA),
  .tagErrB(cc_tagErrB),
  .readA_hit_way(cc_readA_hit_way),
  .readB_hit_way(cc_readB_hit_way)
  );
  
  cc_fstalle #(4*65) stDat_mod (
  .clk(clk),
  .rst(rst),
  .except(exceptA),
  .fstall(fstallA),
  .en(cc_readA_hitP),
  .write_data(readA_dataP[0]),
  .read_data(readA_data)
  );
  cc_fstalle #(4*65) stDatB_mod (
  .clk(clk),
  .rst(rst),
  .except(exceptB),
  .fstall(fstallB),
  .en(cc_readB_hitP),
  .write_data(readB_dataP[0]),
  .read_data(readB_data)
  );

  cc_fstalle #(15) stDatFl_mod (
  .clk(clk),
  .rst(rst),
  .en(cc_readA_hitP),
  .except(exceptA),
  .fstall(fstallA),
  .write_data(readA_dataXP[0]),
  .read_data(readA_dataX)
  );
  cc_fstalle #(15) stDatFlB_mod (
  .clk(clk),
  .rst(rst),
  .en(cc_readB_hitP),
  .except(exceptB),
  .fstall(fstallB),
  .write_data(readB_dataXP[0]),
  .read_data(readB_dataX)
  );

  cc_fstalle #(37) stAddrExp_mod (
  .clk(clk),
  .rst(rst),
  .en(1'b1),
  .except(exceptA|exceptB),
  .fstall(fstallA|fstallB),
  .write_data(cc_exp_addr0_reg),
  .read_data(expun_addr)
  );



  cc_fstalle #(2) stHitA_mod (
  .clk(clk),
  .rst(rst),
  .en(1'b1),
  .except(exceptA),
  .fstall(fstallA),
  .write_data({cc_readA_hitP,errAP}),
  .read_data({cc_readA_hit,errA})
  );
  cc_fstalle #(2) stHitB_mod (
  .clk(clk),
  .rst(rst),
  .en(1'b1),
  .except(exceptB),
  .fstall(fstallB),
  .write_data({cc_readB_hitP,errBP}),
  .read_data({cc_readB_hit,errB})
  );

  cc_fstalle #(1) stHitAE_mod (
  .clk(clk),
  .rst(rst),
  .en(1'b1),
  .except(1'b0),
  .fstall(1'b0),
  .write_data(cc_expun_hitP),
  .read_data(expun_wen)
  );

  always @(negedge clk)
  begin
      if (rst) begin
          write_IP_reg2<=44'b0;
//          write_phys_reg2<=32'b0;
          readA_hitP<=1'b0;
          cc_readA_hitP<=1'b0;
          readA_hitP<=1'b0;
          cc_readA_hitP<=1'b0;
          cc_expun_hitP<=1'b0;
   //       cc_read_hitNP<=1'b0;
          readA_data0_reg<={DATA_WIDTH{1'b0}};
          readA_dataX0_reg<=60'b0;
          readB_data0_reg<={DATA_WIDTH{1'b0}};
          readB_dataX0_reg<=60'b0;
          write_data_reg2<={DATA_WIDTH{1'B0}};
          cc_readA_tagErrP<=8'b0;
          cc_readB_tagErrP<=8'b0;
	  cc_exp_addr0_reg<=37'b0;
     //     cc_read_tagErrNP<=8'b0;
          readA_hit0A<=1'b0;
          readA_hit1A<=1'b0;
          readA_hit0B<=1'b0;
          readA_hit1B<=1'b0;
          readB_hit0A<=1'b0;
          readB_hit1A<=1'b0;
          readB_hit0B<=1'b0;
          readB_hit1B<=1'b0;
  //        read_physOut0_reg<={PHYS_WIDTH-12{1'B0}};
          cc_write_wen_reg2<=1'b0;
          cc_invalidate_reg2<=1'b0;
          cc_readA_IP_reg<=39'b0;
          cc_readB_IP_reg<=39'b0;
          errAP<=0;
          errBP<=0;
      end
      else begin
          write_IP_reg2<=write_IP_reg;
    //      write_phys_reg2<=write_phys_reg;
          readA_hitP<=cc_readA_hit0;
          cc_readA_hitP<=cc_readA_hit0;
          readB_hitP<=cc_readB_hit0;
          cc_readB_hitP<=cc_readB_hit0;
          cc_expun_hitP<=cc_expun_hit0;
          errAP<=(cc_tagErrA&cc_readA_hit_way)!=0;
          errBP<=(cc_tagErrB&cc_readB_hit_way)!=0;
       //   cc_read_hitNP<=cc_read_hitN0;
          readA_data0_reg<=readA_data0;
          readA_dataX0_reg<=readA_dataX0;
          readB_data0_reg<=readB_data0;
          readB_dataX0_reg<=readB_dataX0;
          if (cc_wen_step[0])
              write_data_reg2[DATA_WIDTH/2-1:0]<=write_data_reg[DATA_WIDTH/2-1:0];
          if (cc_wen_step[1])
              write_data_reg2[DATA_WIDTH-1:DATA_WIDTH/2]<=write_data_reg[DATA_WIDTH-1:DATA_WIDTH/2];
          cc_readA_tagErrP<=cc_tagErrA;
          cc_readB_tagErrP<=cc_tagErrB;
	  cc_exp_addr0_reg<=cc_exp_addr0;
          readA_hit0A<=cc_readA_hit0 & ~cc_readA_IP_reg[1] & ~cc_readA_IP_reg[0];
          readA_hit1A<=cc_readA_hit0 & ~cc_readA_IP_reg[1] & cc_readA_IP_reg[0];
          readA_hit0B<=cc_readA_hit0 & cc_readA_IP_reg[1] & ~cc_readA_IP_reg[0];
          readA_hit1B<=cc_readA_hit0 & cc_readA_IP_reg[1] & cc_readA_IP_reg[0];
          readB_hit0A<=cc_readB_hit0 & ~cc_readB_IP_reg[1] & ~cc_readB_IP_reg[0];
          readB_hit1A<=cc_readB_hit0 & ~cc_readB_IP_reg[1] & cc_readB_IP_reg[0];
          readB_hit0B<=cc_readB_hit0 & cc_readB_IP_reg[1] & ~cc_readB_IP_reg[0];
          readB_hit1B<=cc_readB_hit0 & cc_readB_IP_reg[1] & cc_readB_IP_reg[0];
      //    read_physOut0_reg<=read_physOut0;
          cc_write_wen_reg2<=cc_write_wen_reg;
          cc_invalidate_reg2<=cc_invalidate_reg;
          cc_readA_IP_reg<=cc_readA_IP[43:5];
          cc_readB_IP_reg<=cc_readB_IP[43:5];
      end
  end
  
  always @(posedge clk)
  begin
      if (rst) begin
          write_IP_reg<=44'b0;
        //  write_phys_reg<=32'b0;
          write_data_reg<={DATA_WIDTH{1'B0}};
          cc_write_wen_reg<=1'b0;
          cc_invalidate_reg<=1'b0;
          readA_clkEn_reg<=1'b0;
          readB_clkEn_reg<=1'b0;
	  chkCL_clkEn_reg<=1'b0;
          cc_wen_step<=2'b0;
      end
      else begin
          if (cc_write_wen || cc_invalidate) begin
              write_IP_reg<=write_IP;
          //    write_phys_reg<=write_phys;
          end
          write_data_reg<={2{write_data}};
          cc_write_wen_reg<=cc_wen_step[0];
          cc_invalidate_reg<=cc_invalidate;
          readA_clkEn_reg<=readA_clkEn;
          readB_clkEn_reg<=readB_clkEn;
	  chkCL_clkEn_reg<=chkCL_clkEn;
          cc_wen_step<={cc_wen_step[0],cc_write_wen};
      end
  end
  
endmodule

