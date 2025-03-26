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

//memory retire unit; feeds data to the control unit; gets data from the disambiguiate-align module
module lsq_decide_ret(
  clk,
  rst,
  bStall,
//  storq_II_upper,
//  storq_en,
  dataB_ret_mask,
//  dataB_en_mask,
//  dataB_pre_confl,
  dataB_ld_confl,
  dataB_wait_confl,
  dataB_excpt,
  dataB_exbits,
  dataB_thread,
  dataB_II,
  dataB_data_shr,
  dataB_II0,dataB_II1,dataB_II2,
  dataB_II3,dataB_II4,dataB_II5,
  dataB_ready,
  dataB_enOut,
  cntrl_II,out_II,
  retire_enOut,  retire_fine, retire_ldconfl,retire_except,
  retire_exbitsx6, retire_waitconfl, 
  dataB_shr_out,
  doRetire,
  except,
  except_thread
  );
  input clk,rst;
  input bStall;
  input [5:0] dataB_ret_mask;
//  input [5:0] dataB_pre_confl;
  input [5:0] dataB_ld_confl;
  input [5:0] dataB_wait_confl;
  input [5:0] dataB_excpt;
  input [23:0] dataB_exbits;
  input dataB_thread;
  input [5:0] dataB_II;
  input [`lsqshare_width-1:0] dataB_data_shr;
  input [3:0] dataB_II0;
  input [3:0] dataB_II1;
  input [3:0] dataB_II2;
  input [3:0] dataB_II3;
  input [3:0] dataB_II4;
  input [3:0] dataB_II5;
  input dataB_ready;
  output pwire dataB_enOut;
  input [5:0] cntrl_II;
  output pwire [5:0] out_II;
  output pwire [9:0] retire_enOut;  
  output pwire reg [9:0] retire_fine; 
  output pwire reg [9:0] retire_ldconfl; 
  output pwire reg [9:0] retire_except;
  output pwire reg [39:0] retire_exbitsx6;
  output pwire reg [9:0] retire_waitconfl; 
  output pwire reg [`lsqshare_width-1:0] dataB_shr_out;
  input doRetire;
  input except;
  input except_thread;

//  reg non_ret;
  pwire [9:0] dataB_ret_mask2;
  pwire [9:0] dataB_err_mask2;
  pwire [9:0] dataB_err_mask3;
  pwire [9:0] dataB_err_mask4;
  pwire [3:0] dataB_ebits_item[9:0];
  reg ret_ret;
  reg [5:0] dataB_II_reg;
  reg [9:0] retire_enOutP;  
  integer t;

  generate
    genvar k;
    for(k=0;k<10;k=k+1) begin
        assign dataB_ret_mask2[k]=(dataB_ret_mask[0] && dataB_II0[3:0]==k) ||
	  (dataB_ret_mask[1] && dataB_II1[3:0]==k) ||
	  (dataB_ret_mask[2] && dataB_II2[3:0]==k) ||
	  (dataB_ret_mask[3] && dataB_II3[3:0]==k) ||
	  (dataB_ret_mask[4] && dataB_II4[3:0]==k) ||
	  (dataB_ret_mask[5] && dataB_II5[3:0]==k);
        assign dataB_err_mask2[k]=(dataB_excpt[0] && dataB_ret_mask[0] && dataB_II0[3:0]==k) ||
	  (dataB_excpt[1] && dataB_ret_mask[1] && dataB_II1[3:0]==k) ||
	  (dataB_excpt[2] && dataB_ret_mask[2] && dataB_II2[3:0]==k) ||
	  (dataB_excpt[3] && dataB_ret_mask[3] && dataB_II3[3:0]==k) ||
	  (dataB_excpt[4] && dataB_ret_mask[4] && dataB_II4[3:0]==k) ||
	  (dataB_excpt[5] && dataB_ret_mask[5] && dataB_II5[3:0]==k);
        assign dataB_err_mask3[k]=(dataB_ld_confl[0] && dataB_ret_mask[0] && dataB_II0[3:0]==k) ||
	  (dataB_ld_confl[1] && dataB_ret_mask[1] && dataB_II1[3:0]==k) ||
	  (dataB_ld_confl[2] && dataB_ret_mask[2] && dataB_II2[3:0]==k) ||
	  (dataB_ld_confl[3] && dataB_ret_mask[3] && dataB_II3[3:0]==k) ||
	  (dataB_ld_confl[4] && dataB_ret_mask[4] && dataB_II4[3:0]==k) ||
	  (dataB_ld_confl[5] && dataB_ret_mask[5] && dataB_II5[3:0]==k);
        assign dataB_err_mask4[k]=(dataB_wait_confl[0] && dataB_ret_mask[0] && dataB_II0[3:0]==k) ||
	  (dataB_wait_confl[1] && dataB_ret_mask[1] && dataB_II1[3:0]==k) ||
	  (dataB_wait_confl[2] && dataB_ret_mask[2] && dataB_II2[3:0]==k) ||
	  (dataB_wait_confl[3] && dataB_ret_mask[3] && dataB_II3[3:0]==k) ||
	  (dataB_wait_confl[4] && dataB_ret_mask[4] && dataB_II4[3:0]==k) ||
	  (dataB_wait_confl[5] && dataB_ret_mask[5] && dataB_II5[3:0]==k);
        assign dataB_ebits_item[k]=(dataB_exbits[3:0] & {4{dataB_ret_mask[0] && dataB_II0[3:0]==k}})|
        (dataB_exbits[7:4] & {4{dataB_ret_mask[1] && dataB_II1[3:0]==k}})|
        (dataB_exbits[11:8] & {4{dataB_ret_mask[2] && dataB_II2[3:0]==k}})|
        (dataB_exbits[15:12] & {4{dataB_ret_mask[3] && dataB_II3[3:0]==k}})|
        (dataB_exbits[19:16] & {4{dataB_ret_mask[4] && dataB_II4[3:0]==k}})|
        (dataB_exbits[23:20] & {4{dataB_ret_mask[5] && dataB_II5[3:0]==k}});
    end
  endgenerate

//  assign dataB_enOut0=dataB_ready && (doRetire && cntrl_II==dataB_II0_reg[9:4]) | 
//    (ret_ret && cntrl_II==dataB_II0[9:4]);
  assign dataB_enOut=dataB_ready && (doRetire && cntrl_II==dataB_II && ~bStall);
  assign retire_enOut=retire_enOutP & {10{ cntrl_II==dataB_II}};
  assign out_II=dataB_II;
  //assign out_II=ret_ret ? dataB_II : dataB_II_reg;
  always @(*) begin
	//$display("dd ",dataB_II," ",dataB_II_reg," ",cntrl_II);
        for(t=0;t<10;t=t+1) begin
            retire_enOutP[t]=  dataB_ret_mask2[t];
	    retire_fine[t]=  ~dataB_err_mask2[t] && ~dataB_err_mask3[t]
            && ~dataB_err_mask4[t];
	    retire_ldconfl[t]=dataB_err_mask3[t];
	    retire_waitconfl[t]=dataB_err_mask4[t];
	    retire_except[t]= dataB_err_mask2[t];
            retire_exbitsx6[4*t+:4]=dataB_ebits_item[t];
	    dataB_II_reg=dataB_II;
	    dataB_shr_out=dataB_data_shr;
	end 
  end
endmodule
  
