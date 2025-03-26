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

//compile stq to hard macro with 1x horizontal x2 pwire and 1x vertical x2 wire
//do not delete redundant outputs
//store queue for disambiguiating strong model load-store queue unit
module stq(
  clk,
  rst,
  excpt,
  stall,
  doStall,
  aStall,
  aDoStall,
  st_stall,
  rsStall,
  rsDoStall,//needs to get registered again outside module
  do_retire,
  ret_xbreak,
  ret_II,
  ret_II_out,
  chk0_adata,chk0_en,chk0_enD,
  chk1_adata,chk1_en,chk1_enD,
  chk2_adata,chk2_en,chk2_enD,
  chk3_adata,chk3_en,chk3_enD,
  chk_rdy,
  chk_LSQ,chk_LSQu,
  LSQ_shr_data, 
  wrt0_adata,wrt0_en,wrt0_LSQ,
  confl,confl_SMP,confl_X,
  confl_out,
  upd0_WQ,upd0_en,
  pse0_en,
  pse1_en,
  wb1_adata,wb1_LSQ,wb1_bnkEn,wb1_bnkEnS,wb1_en,wb1_chk,wb1_way,
  wb0_adata,wb0_LSQ,wb0_bnkEn,wb0_bnkEnS,wb0_en,wb0_chk,wb0_way,
  WLN0_en,WLN0_adata,WLN0_data,WLN0_dataN,WLN0_pbit,
  WLN1_en,WLN1_adata,WLN1_data,WLN1_dataN,WLN1_pbit
  );
  input pwire clk;

  input pwire rst;

  input pwire excpt;

  input pwire stall;
  output pwire doStall;

  input pwire aStall;

  output pwire aDoStall;

  input pwire st_stall;

  input pwire rsStall;
  output pwire [3:0] rsDoStall;

  input pwire do_retire;
  input pwire [15:0] ret_xbreak;
  input pwire [5:0] ret_II;
  output pwire [5:0] ret_II_out;

  input pwire [`lsaddr_width-1:0] chk0_adata;
  input pwire chk0_en;
  input pwire [1:0] chk0_enD;

  input pwire [`lsaddr_width-1:0] chk1_adata;
  input pwire chk1_en;
  input pwire [1:0] chk1_enD;

  input pwire [`lsaddr_width-1:0] chk2_adata;
  input pwire chk2_en;
  input pwire [1:0] chk2_enD;

  input pwire [`lsaddr_width-1:0] chk3_adata;
  input pwire chk3_en;
  input pwire [1:0] chk3_enD;

  input pwire chk_rdy;

  input pwire [5:0] chk_LSQ;
  input pwire [5:0] chk_LSQu;

  input pwire [`lsqshare_width-1:0] LSQ_shr_data;
  
  input pwire [59:0][`lsaddr_width-1:0] wrt0_adata;
  input pwire [59:0]wrt0_en;
  input pwire [59:0][8:0] wrt0_LSQ;


  input pwire [5:0] confl;
  input pwire [5:0] confl_SMP;
  input pwire [5:0] confl_X;
  output pwire [5:0] confl_out;

  input pwire [59:0][5:0] upd0_WQ;
  input pwire [59:0]upd0_en;
  input pwire [59:0][1:0] upd0_pbit;



  output pwire [`lsaddr_width-1:0] wb1_adata;
  output pwire [8:0] wb1_LSQ;
  output pwire [16:0] wb1_bnkEn;
  output pwire [16:0] wb1_bnkEnS;
  output pwire wb1_en;
  output pwire [5:0] wb1_chk;
  output pwire [0:0] wb1_way;

  output pwire [`lsaddr_width-1:0] wb0_adata;
  output pwire [8:0] wb0_LSQ;
  output pwire [16:0] wb0_bnkEn;
  output pwire [16:0] wb0_bnkEnS;
  output pwire wb0_en;
  output pwire [5:0] wb0_chk;
  output pwire [0:0] wb0_way;
  
  output pwire WLN0_en;
  output pwire [`lsaddr_width-1:0] WLN0_adata;
  output pwire [135:0] WLN0_data;
  output pwire [135:0] WLN0_dataN;
  output pwire [1:0] WLN0_pbit;
  
  pwire [5:0] pse0_WQ;
  pwire [5:0] pse0_WQ_inc;
  
  pwire [5:0] confl0;

  pwire [5:0] WLN0_WQ;
  pwire [5:0] W_NL0_WQ;
  pwire [`lsaddr_width-1:0] WLN0_adata0;
  pwire WLN0_en0;
  pwire [`lsaddr_width-1:0] W_NL0_adata;
  pwire W_NL0_en;
  pwire W_NL1_en;
	  
  pwire [5:0] chk_wb0_reg;
  pwire [5:0] chk_wb0_reg2;
  pwire  chk_wb0_has_reg;
  pwire  chk_wb0_has_reg2;
  pwire [5:0][16:0] chk_bytes_reg;
  pwire [5:0][16:0] chk_bytes_reg2;
  pwire [5:0] chk_wb1_reg;
  pwire [5:0] chk_wb1_reg2;
  pwire  chk_wb1_has_reg;
  pwire  chk_wb1_has_reg2;

  pwire puffy_baff;
  
  pwire [7:0] chk0_subBNK;
  pwire [7:0] chk1_subBNK;
  pwire [7:0] chk2_subBNK;
  pwire [7:0] chk3_subBNK;
  pwire [7:0] chk4_subBNK;
  pwire [7:0] chk5_subBNK;
  pwire [7:0] W_NL0_subBNK;
  pwire [7:0] W_NL1_subBNK;
  pwire [7:0] chk0_subBNK2;
  pwire [7:0] chk1_subBNK2;
  pwire [7:0] chk2_subBNK2;
  pwire [7:0] chk3_subBNK2;
  pwire [7:0] chk4_subBNK2;
  pwire [7:0] chk5_subBNK2;
  pwire [7:0] W_NL0_subBNK2;
  pwire [7:0] W_NL1_subBNK2;
  pwire [3:0] chk0_odd0;
  pwire [3:0] chk1_odd0;
  pwire [3:0] chk2_odd0;
  pwire [3:0] chk3_odd0;
  pwire [3:0] chk4_odd0;
  pwire [3:0] chk5_odd0;
  pwire [3:0] W_NL0_odd0;
  pwire [3:0] W_NL1_odd0;
  pwire [7:0][3:0] chk0_odd1;
  pwire [7:0][3:0] chk1_odd1;
  pwire [7:0][3:0] chk2_odd1;
  pwire [7:0][3:0] chk3_odd1;
  pwire [7:0][3:0] chk4_odd1;
  pwire [7:0][3:0] chk5_odd1;
  pwire [7:0][3:0] W_NL0_odd1;
  pwire [7:0][3:0] W_NL1_odd1;
  pwire [63:0][1:0] chk0_addrOE;
  pwire [63:0][1:0] chk1_addrOE;
  pwire [63:0][1:0] chk2_addrOE;
  pwire [63:0][1:0] chk3_addrOE;
  pwire [63:0][1:0] chk4_addrOE;
  pwire [63:0][1:0] chk5_addrOE;
  pwire [31:0] chk0_banks;
  pwire [31:0] chk1_banks;
  pwire [31:0] chk2_banks;
  pwire [31:0] chk3_banks;
  pwire [31:0] chk4_banks;
  pwire [31:0] chk5_banks;
  pwire [31:0] W_NL0_banks;
  pwire [31:0] W_NL1_banks;
  pwire [31:0] chk0_banks2;
  pwire [31:0] chk1_banks2;
  pwire [31:0] chk2_banks2;
  pwire [31:0] chk3_banks2;
  pwire [31:0] chk4_banks2;
  pwire [31:0] chk5_banks2;
  pwire [31:0] W_NL0_banks2;
  pwire [31:0] W_NL1_banks2;
  pwire [64:0] WLN0_match;
  pwire [64:0] WLN1_match;
  pwire [64:0] W_NL0_en0;
  pwire [64:0] W_NL1_en0;
  pwire [64:0] wrt0_en0;
  pwire [64:0] wrt1_en0;
  pwire [64:0] upd0_en0;
  pwire [64:0] upd1_en0;
  pwire [64:0] passe_en;
  pwire [64:0] passe;
  pwire [64:0] free;
  pwire [64:0] upd;

  
  pwire [5:0][139:0] chk_data;
  pwire [5:0][139:0] chk_dataM;
  pwire [5:0][1:0] chk_pbit;
  pwire [5:0][16:0] chk_bytes;
  pwire [5:0][16:0] chk_bytesX;
  pwire [135:0] wb0_dataW;
  pwire [1:0]  wb0_pbitW;
  pwire [16:0] wb0_bytesW;
  pwire [16:0] wb0_bytesX;
  pwire [135:0] wb1_dataW;
  pwire [1:0]  wb1_pbitW;
  pwire [16:0] wb1_bytesW;
  pwire [16:0] wb1_bytesX;
  pwire [135:0] WLN0_data;
  pwire [135:0] WLN1_data;

  pwire [5:0][`lsaddr_width-1:0] chk_adata;
  pwire [`lsaddr_width-1:0] wb0_adataW;
  pwire [`lsaddr_width-1:0] wb1_adataW;
  pwire  [`lsaddr_width-1:0] wb0_adataW_reg;
  pwire  [`lsaddr_width-1:0] wb1_adataW_reg;
  pwire [135:0] wb0_dataW;
  pwire [135:0] wb1_dataW;
  pwire [135:0] wb0_dataW_reg;
  pwire [135:0] wb1_dataW_reg;


  pwire [4:0] upd0_begin0;
  pwire [4:0] upd1_begin0;

  pwire chk0_pre0,chk0_pre1;
  pwire chk1_pre0,chk1_pre1;
  pwire chk2_pre0,chk2_pre1;
  pwire chk3_pre0,chk3_pre1;
  pwire chk4_pre0,chk4_pre1;
  pwire chk5_pre0,chk5_pre1;

  pwire [7:0] chk0_match_has;
  pwire [7:0] chk1_match_has;
  pwire [7:0] chk2_match_has;
  pwire [7:0] chk3_match_has;
  pwire [7:0] chk4_match_has;
  pwire [7:0] chk5_match_has;

  pwire [5:0][1:0] chk_enD;

  pwire [7:0][63:0] chk0_match;
  pwire [7:0][63:0] chk1_match;
  pwire [7:0][63:0] chk2_match;
  pwire [7:0][63:0] chk3_match;
  pwire [7:0][63:0] chk4_match;
  pwire [7:0][63:0] chk5_match;
  pwire [7:0][63:0] chk0_partial;
  pwire [7:0][63:0] chk1_partial;
  pwire [7:0][63:0] chk2_partial;
  pwire [7:0][63:0] chk3_partial;
  pwire [7:0][63:0] chk4_partial;
  pwire [7:0][63:0] chk5_partial;
  pwire [3:0][63:0] chk0_match_first;
  pwire [3:0][63:0] chk1_match_first;
  pwire [3:0][63:0] chk2_match_first;
  pwire [3:0][63:0] chk3_match_first;
  pwire [3:0][63:0] chk4_match_first;
  pwire [3:0][63:0] chk5_match_first;
  pwire [7:0][1:0] chk0_matchW;
  pwire [7:0][1:0] chk1_matchW;
  pwire [7:0][1:0] chk2_matchW;
  pwire [7:0][1:0] chk3_matchW;
  pwire [7:0][1:0] chk4_matchW;
  pwire [7:0][1:0] chk5_matchW;
  pwire [7:0][1:0] chk0_partialW;
  pwire [7:0][1:0] chk1_partialW;
  pwire [7:0][1:0] chk2_partialW;
  pwire [7:0][1:0] chk3_partialW;
  pwire [7:0][1:0] chk4_partialW;
  pwire [7:0][1:0] chk5_partialW;
  pwire [7:0][1:0] chk0_matchW2;
  pwire [7:0][1:0] chk1_matchW2;
  pwire [7:0][1:0] chk2_matchW2;
  pwire [7:0][1:0] chk3_matchW2;
  pwire [7:0][1:0] chk4_matchW2;
  pwire [7:0][1:0] chk5_matchW2;
  pwire [7:0][1:0] chk0_partialW2;
  pwire [7:0][1:0] chk1_partialW2;
  pwire [7:0][1:0] chk2_partialW2;
  pwire [7:0][1:0] chk3_partialW2;
  pwire [7:0][1:0] chk4_partialW2;
  pwire [7:0][1:0] chk5_partialW2;

  pwire [3:0][1:0] chk0_b;
  pwire [3:0][1:0] chk1_b;
  pwire [3:0][1:0] chk2_b;
  pwire [3:0][1:0] chk3_b;
  pwire [3:0][1:0] chk4_b;
  pwire [3:0][1:0] chk5_b;
  pwire [3:0][1:0] WLN0_b;
  pwire [3:0][1:0] WLN1_b;
  pwire [3:0][1:0] upd0_b;
  pwire [3:0][1:0] upd1_b;
  pwire [3:0][1:0] Rupd0_b;
  pwire [3:0][1:0] Rupd1_b;

  pwire chk0_odd;
  pwire chk1_odd;
  pwire chk2_odd;
  pwire chk3_odd;
  pwire chk4_odd;
  pwire chk5_odd;
  pwire W_NL0_odd;
  pwire W_NL1_odd;

  pwire [7:0][3:0] chk0_bytes;
  pwire [7:0][3:0] chk1_bytes;
  pwire [7:0][3:0] chk2_bytes;
  pwire [7:0][3:0] chk3_bytes;
  pwire [7:0][3:0] chk4_bytes;
  pwire [7:0][3:0] chk5_bytes;
  pwire [7:0][3:0] W_NL0_bytes;
  pwire [7:0][3:0] W_NL1_bytes;

  pwire [63:0][1:0] chk0_addrEO;
  pwire [63:0][1:0] chk1_addrEO;
  pwire [63:0][1:0] chk2_addrEO;
  pwire [63:0][1:0] chk3_addrEO;
  pwire [63:0][1:0] chk4_addrEO;
  pwire [63:0][1:0] chk5_addrEO;

  pwire [3:0][63:0] chk0_firstA;
  pwire [3:0][63:0] chk1_firstA;
  pwire [3:0][63:0] chk2_firstA;
  pwire [3:0][63:0] chk3_firstA;
  pwire [3:0][63:0] chk4_firstA;
  pwire [3:0][63:0] chk5_firstA;
  pwire [3:0][63:0] chk0_firstB;
  pwire [3:0][63:0] chk1_firstB;
  pwire [3:0][63:0] chk2_firstB;
  pwire [3:0][63:0] chk3_firstB;
  pwire [3:0][63:0] chk4_firstB;
  pwire [3:0][63:0] chk5_firstB;
  pwire [3:0] chk0_hasA;
  pwire [3:0] chk1_hasA;
  pwire [3:0] chk2_hasA;
  pwire [3:0] chk3_hasA;
  pwire [3:0] chk4_hasA;
  pwire [3:0] chk5_hasA;
  pwire [3:0] chk0_hasB;
  pwire [3:0] chk1_hasB;
  pwire [3:0] chk2_hasB;
  pwire [3:0] chk3_hasB;
  pwire [3:0] chk4_hasB;
  pwire [3:0] chk5_hasB;

  pwire [64:0] free_en;
  pwire [64:0] free;

  assign wrt2_LSQu=pse0_en ? wrt0_LSQ : wrt1_LSQ;

  pwire [5:0] rdy={chk5_en,chk4_en,chk3_en,chk2_en,chk1_en,chk0_en};
  pwire [5:0] chk_wb={chk5_adata[`lsaddr_flag] & chk5_en,chk4_adata[`lsaddr_flag] & chk4_en,chk3_adata[`lsaddr_flag] & chk3_en,
      chk2_adata[`lsaddr_flag] & chk2_en,chk1_adata[`lsaddr_flag] & chk1_en,chk0_adata[`lsaddr_flag] & chk0_en};
  pwire [5:0] chk_wb0;
  pwire [5:0] chk_wb1;
  pwire chk_wb0_has,chk_wb1_has,chk_wb2_has;
  pwire [5:0] chk_mask;
  pwire [64:0] mask;
  pwire [64:0] nmask;
  pwire [64:0] mask2;
  
  function [31:0] lowt;
      input pwire [31:0] data;
      begin
          lowt=data&{data[0],data[31:1]};
      end
  endfunction
  function [3:0] get_ld_bytes;
      input pwire [4:0] sz;
      input pwire [7:0] banks;
      input pwire [2:0] index;
      input pwire [1:0] low;
      pwire [7:0] first;
      pwire [7:0] last;
      begin
          first=banks&~{banks[6:0],banks[7]};
          last=banks&~{banks[0],banks[7:1]};
	  get_ld_bytes=4'b0;
	  if (first[index]) begin
	      case(sz)
		  5'h10:get_ld_bytes[low]=1'b1;
		  5'h11:begin
			  get_ld_bytes[low]=1'b1;
			  if (low!=2'b11) get_ld_bytes[low+1]=1'b1;
		  end
	          default:get_ld_bytes=4'b1111;
	      endcase
	  end else if (last[index]) begin
	      case(sz)
		  5'h11:begin
			  if (low==2'b11) get_ld_bytes[0]=1'b1;
		  end
	          5'h3: get_ld_bytes=4'b11;
	          default:get_ld_bytes=4'b1111;
	      endcase
      end else begin
	      get_ld_bytes=4'hf;
      end
      end
  endfunction
  function [3:0] get_st_bytes;
      input pwire [4:0] sz;
      input pwire [7:0] banks;
      input pwire [2:0] index;
      input pwire [1:0] low;
      pwire [7:0] first;
      pwire [7:0] last;
      begin
          first=banks&~{banks[6:0],banks[7]};
          last=banks&~{banks[0],banks[7:1]};
	  get_st_bytes=4'b0;
	  if (first[index]) begin
	      case(sz)
		  5'h10:get_st_bytes[low]=1'b1;
		  5'h11:begin
			  get_st_bytes[low]=1'b1;
			  if (low!=2'b11) get_st_bytes[low+1]=1'b1;
		  end
	          default:get_st_bytes=4'b1111;
	      endcase
	  end else if (last[index]) begin
	      case(sz)
		  5'h11:begin
			  if (low==2'b11) get_st_bytes[0]=1'b1;
		  end
	          5'h3: get_st_bytes=4'b11;
	          default:get_st_bytes=4'b1111;
	      endcase
      end else begin
	      get_st_bytes=4'hf;
      end
      end
  endfunction
      pwire [3:0][32:0] WLN0_dataX0;
      pwire [3:0][32:0] WLN1_dataX0;
      pwire [3:0][32:0] WLN0_dataXN0;
      pwire [3:0][32:0] WLN1_dataXN0;
      pwire [3:0][32:0] chk0_data0;
      pwire [3:0][32:0] chk1_data0;
      pwire [3:0][32:0] chk2_data0;
      pwire [3:0][32:0] chk3_data0;
      pwire [3:0][32:0] chk4_data0;
      pwire [3:0][32:0] chk5_data0;
      pwire [3:0][32:0] chk0_dataM0;
      pwire [3:0][32:0] chk1_dataM0;
      pwire [3:0][32:0] chk2_dataM0;
      pwire [3:0][32:0] chk3_dataM0;
      pwire [3:0][32:0] chk4_dataM0;
      pwire [3:0][32:0] chk5_dataM0;
  generate
      genvar a,b,x;
      for(b=0;b<8;b=b+1) begin : L
          assign chk0_subBNK[b]=|{chk0_banks[24+b],chk0_banks[16+b],chk0_banks[8+b],chk0_banks[0+b]};
          assign chk0_odd1[b]=chk0_banks[24+b] && |chk0_banks[3:0] ? chk0_odd0^4'b1 : chk0_odd0;

          assign chk1_subBNK[b]=|{chk1_banks[24+b],chk1_banks[16+b],chk1_banks[8+b],chk1_banks[0+b]};
          assign chk1_odd1[b]=chk1_banks[24+b] && |chk1_banks[3:0] ? chk1_odd0^4'b1 : chk1_odd0;

          assign chk2_subBNK[b]=|{chk2_banks[24+b],chk2_banks[16+b],chk2_banks[8+b],chk2_banks[0+b]};
          assign chk2_odd1[b]=chk2_banks[24+b] && |chk2_banks[3:0] ? chk2_odd0^4'b1 : chk2_odd0;

          assign chk3_subBNK[b]=|{chk3_banks[24+b],chk3_banks[16+b],chk3_banks[8+b],chk3_banks[0+b]};
          assign chk3_odd1[b]=chk3_banks[24+b] && |chk3_banks[3:0] ? chk3_odd0^4'b1 : chk3_odd0;

          assign chk4_subBNK[b]=|{chk4_banks[24+b],chk4_banks[16+b],chk4_banks[8+b],chk4_banks[0+b]};
          assign chk4_odd1[b]=chk4_banks[24+b] && |chk4_banks[3:0] ? chk4_odd0^4'b1 : chk4_odd0;

          assign chk5_subBNK[b]=|{chk5_banks[24+b],chk5_banks[16+b],chk5_banks[8+b],chk5_banks[0+b]};
          assign chk5_odd1[b]=chk5_banks[24+b] && |chk5_banks[3:0] ? chk5_odd0^4'b1 : chk5_odd0;
          
          assign W_NL0_subBNK[b]=|{W_NL0_banks[24+b],W_NL0_banks[16+b],W_NL0_banks[8+b],W_NL0_banks[0+b]};
          assign W_NL0_odd1[b]=W_NL0_banks[24+b] && |W_NL0_banks[3:0] ? W_NL0_odd0^4'b1 : W_NL0_odd0;

          assign W_NL1_subBNK[b]=|{W_NL1_banks[24+b],W_NL1_banks[16+b],W_NL1_banks[8+b],W_NL1_banks[0+b]};
          assign W_NL1_odd1[b]=W_NL1_banks[24+b] && |W_NL1_banks[3:0] ? W_NL1_odd0^4'b1 : W_NL1_odd0;

          assign chk0_subBNK2[b]=|{chk0_banks2[24+b],chk0_banks2[16+b],chk0_banks2[8+b],chk0_banks2[0+b]};
          assign chk1_subBNK2[b]=|{chk1_banks2[24+b],chk1_banks2[16+b],chk1_banks2[8+b],chk1_banks2[0+b]};
          assign chk2_subBNK2[b]=|{chk2_banks2[24+b],chk2_banks2[16+b],chk2_banks2[8+b],chk2_banks2[0+b]};
          assign chk3_subBNK2[b]=|{chk3_banks2[24+b],chk3_banks2[16+b],chk3_banks2[8+b],chk3_banks2[0+b]};
          assign chk4_subBNK2[b]=|{chk4_banks2[24+b],chk4_banks2[16+b],chk4_banks2[8+b],chk4_banks2[0+b]};
          assign chk5_subBNK2[b]=|{chk5_banks2[24+b],chk5_banks2[16+b],chk5_banks2[8+b],chk5_banks2[0+b]};
          assign W_NL0_subBNK2[b]=|{W_NL0_banks2[24+b],W_NL0_banks2[16+b],W_NL0_banks2[8+b],W_NL0_banks2[0+b]};
          assign W_NL1_subBNK2[b]=|{W_NL1_banks2[24+b],W_NL1_banks2[16+b],W_NL1_banks2[8+b],W_NL1_banks2[0+b]};

	  assign chk0_bytes[b]=get_ld_bytes(chk0_adata[`lsaddr_sz],chk0_subBNK,b[2:0],chk0_adata[`lsaddr_low]);
	  assign chk1_bytes[b]=get_ld_bytes(chk1_adata[`lsaddr_sz],chk1_subBNK,b[2:0],chk1_adata[`lsaddr_low]);
	  assign chk2_bytes[b]=get_ld_bytes(chk2_adata[`lsaddr_sz],chk2_subBNK,b[2:0],chk2_adata[`lsaddr_low]);
	  assign chk3_bytes[b]=get_ld_bytes(chk3_adata[`lsaddr_sz],chk3_subBNK,b[2:0],chk3_adata[`lsaddr_low]);
	  assign chk4_bytes[b]=get_ld_bytes(chk4_adata[`lsaddr_sz],chk4_subBNK,b[2:0],chk4_adata[`lsaddr_low]);
	  assign chk5_bytes[b]=get_ld_bytes(chk5_adata[`lsaddr_sz],chk5_subBNK,b[2:0],chk5_adata[`lsaddr_low]);
	  assign W_NL0_bytes[b]=get_st_bytes(W_NL0_adata[`lsaddr_sz],W_NL0_subBNK,b[2:0],W_NL0_adata[`lsaddr_low]);
	  assign W_NL1_bytes[b]=get_st_bytes(W_NL1_adata[`lsaddr_sz],W_NL1_subBNK,b[2:0],W_NL1_adata[`lsaddr_low]);

          bit_find_last_bit #(64) chkBit0A(chk0_match[b]&mask,chk0_firstA[b],chk0_hasA[b]);
          bit_find_last_bit #(64) chkBit0B(chk0_match[b]&~mask,chk0_firstB[b],chk0_hasB[b]);
          assign chk0_match_first[b]=chk0_hasA[b] ? chk0_firstA[b] : chk0_firstB[b];
          assign chk0_match_has[b]=chk0_hasA[b] | chk0_hasB[b];
          bit_find_last_bit #(64) chkBit1A(chk1_match[b]&mask,chk1_firstA[b],chk1_hasA[b]);
          bit_find_last_bit #(64) chkBit1B(chk1_match[b]&~mask,chk1_firstB[b],chk1_hasB[b]);
          assign chk1_match_first[b]=chk1_hasA[b] ? chk1_firstA[b] : chk1_firstB[b];
	  assign chk1_match_has[b]=chk1_hasA[b] | chk1_hasB[b];
          bit_find_last_bit #(64) chkBit2A(chk2_match[b]&mask,chk2_firstA[b],chk2_hasA[b]);
          bit_find_last_bit #(64) chkBit2B(chk2_match[b]&~mask,chk2_firstB[b],chk2_hasB[b]);
          assign chk2_match_first[b]=chk2_hasA[b] ? chk2_firstA[b] : chk2_firstB[b];
	  assign chk2_match_has[b]=chk2_hasA[b] | chk2_hasB[b];
          bit_find_last_bit #(64) chkBit3A(chk3_match[b]&mask,chk3_firstA[b],chk3_hasA[b]);
          bit_find_last_bit #(64) chkBit3B(chk3_match[b]&~mask,chk3_firstB[b],chk3_hasB[b]);
          assign chk3_match_first[b]=chk3_hasA[b] ? chk3_firstA[b] : chk3_firstB[b];
	  assign chk3_match_has[b]=chk3_hasA[b] | chk3_hasB[b];
          bit_find_last_bit #(64) chkBit4A(chk4_match[b]&mask,chk4_firstA[b],chk4_hasA[b]);
          bit_find_last_bit #(64) chkBit4B(chk4_match[b]&~mask,chk4_firstB[b],chk4_hasB[b]);
          assign chk4_match_first[b]=chk4_hasA[b] ? chk4_firstA[b] : chk4_firstB[b];
	  assign chk4_match_has[b]=chk4_hasA[b] | chk4_hasB[b];
          bit_find_last_bit #(64) chkBit5A(chk5_match[b]&mask,chk5_firstA[b],chk5_hasA[b]);
          bit_find_last_bit #(64) chkBit5B(chk5_match[b]&~mask,chk5_firstB[b],chk5_hasB[b]);
          assign chk5_match_first[b]=chk5_hasA[b] ? chk5_firstA[b] : chk5_firstB[b];
	  assign chk5_match_has[b]=chk5_hasA[b] | chk5_hasB[b] | chk5_hasA[b+4] | chk5_hasB[b+4];

	  if (b==0) begin : with_free
              stq_buf_L_array arr0_mod(
              clk,
              rst,
              aStall|aDoStall,
              excpt,
              W_NL0_en0, W_NL0_en, W_NL0_WQ, W_NL0_odd1[b], W_NL0_bytes[b], W_NL0_subBNK[b], W_NL0_subBNK2[b],
              chk0_en, chk0_addrEO, chk0_odd1[b], chk0_bytes[b], chk0_subBNK[b], chk0_subBNK2[b], chk0_match[b], chk0_partial[b],
	      chk0_matchW[b],chk0_partialW[b],chk0_pre0,chk0_pre1,
              chk1_en, chk1_addrEO, chk1_odd1[b], chk1_bytes[b], chk1_subBNK[b], chk1_subBNK2[b], chk1_match[b], chk1_partial[b],
	      chk1_matchW[b],chk1_partialW[b],chk1_pre0,chk1_pre1,
              chk2_en, chk2_addrEO, chk2_odd1[b], chk2_bytes[b], chk2_subBNK[b], chk2_subBNK2[b], chk2_match[b], chk2_partial[b],
	      chk2_matchW[b],chk2_partialW[b],chk2_pre0,chk2_pre1,
              chk3_en, chk3_addrEO, chk3_odd1[b], chk3_bytes[b], chk3_subBNK[b], chk3_subBNK2[b], chk3_match[b], chk3_partial[b],
	      chk3_matchW[b],chk3_partialW[b],chk3_pre0,chk3_pre1,
              chkWB0_en, chkWB0_addrEO, chkWB0_odd1[b], chkWB0_bytes[b], chkWB0_subBNK[b], chkWB0_subBNK2[b], chkWB0_match[b], chkWB0_partial[b],
	      chkWB0_matchW[b],chkWB0_partialW[b],chkWB0_pre0,chkWB0_pre1,
              chkWB1_en, chkWB1_addrEO, chkWB1_odd1[b], chkWB1_bytes[b], chkWB1_subBNK[b], chkWB1_subBNK2[b], chkWB1_match[b], chkWB1_partial[b],
	      chkWB1_matchW[b],chkWB1_partialW[b],chkWB1_pre0,chkWB1_pre1,
              upd0_en0, 
              free_en,free,upd,passe,passe_en);

          end else begin : wout_free
              stq_buf_L_array arr0_mod(
              clk,
              rst,
              aStall|aDoStall,
              excpt,
              W_NL0_en0, W_NL0_en, W_NL0_WQ, W_NL0_odd1[b], W_NL0_bytes[b], W_NL0_subBNK[b], W_NL0_subBNK2[b],
              chk0_en, chk0_addrEO, chk0_odd1[b], chk0_bytes[b], chk0_subBNK[b], chk0_subBNK2[b], chk0_match[b], chk0_partial[b],
	      chk0_matchW[b],chk0_partialW[b],chk0_pre0,chk0_pre1,
              chk1_en, chk1_addrEO, chk1_odd1[b], chk1_bytes[b], chk1_subBNK[b], chk1_subBNK2[b], chk1_match[b], chk1_partial[b],
	      chk1_matchW[b],chk1_partialW[b],chk1_pre0,chk1_pre1,
              chk2_en, chk2_addrEO, chk2_odd1[b], chk2_bytes[b], chk2_subBNK[b], chk2_subBNK2[b], chk2_match[b], chk2_partial[b],
	      chk2_matchW[b],chk2_partialW[b],chk2_pre0,chk2_pre1,
              chk3_en, chk3_addrEO, chk3_odd1[b], chk3_bytes[b], chk3_subBNK[b], chk3_subBNK2[b], chk3_match[b], chk3_partial[b],
	      chk3_matchW[b],chk3_partialW[b],chk3_pre0,chk3_pre1,
              chkWB0_en, chkWB0_addrEO, chkWB0_odd1[b], chkWB0_bytes[b], chkWB0_subBNK[b], chkWB0_subBNK2[b], chkWB0_match[b], chkWB0_partial[b],
	      chkWB0_matchW[b],chkWB0_partialW[b],chkWB0_pre0,chkWB0_pre1,
              chkWB1_en, chkWB1_addrEO, chkWB1_odd1[b], chkWB1_bytes[b], chkWB1_subBNK[b], chkWB1_subBNK2[b], chkWB1_match[b], chkWB1_partial[b],
	      chkWB1_matchW[b],chkWB1_partialW[b],chkWB1_pre0,chkWB1_pre1,
              upd0_en0, 
              upd1_en0, 
              free_en,,,,passe_en);
	  end
          
          if (b<4) begin
	      assign chk_bytes[0][4*b+:4]=chk0_bytes[chk0_b[b]] & {4{chk0_match_has[chk0_b[b]]}};
	      assign chk_bytes[1][4*b+:4]=chk1_bytes[chk1_b[b]] & {4{chk1_match_has[chk1_b[b]]}};
	      assign chk_bytes[2][4*b+:4]=chk2_bytes[chk2_b[b]] & {4{chk2_match_has[chk2_b[b]]}};
	      assign chk_bytes[3][4*b+:4]=chk3_bytes[chk3_b[b]] & {4{chk3_match_has[chk3_b[b]]}};
	      assign chk_bytes[4][4*b+:4]=chk4_bytes[chk4_b[b]] & {4{chk4_match_has[chk4_b[b]]}};
	      assign chk_bytes[5][4*b+:4]=chk5_bytes[chk5_b[b]] & {4{chk5_match_has[chk5_b[b]]}};
	      assign chk_bytesX[0][4*b+:4]=chk0_bytes[4+b] & {4{chk0_match_has[4+b]}};
	      assign chk_bytesX[1][4*b+:4]=chk1_bytes[4+b] & {4{chk1_match_has[4+b]}};
	      assign chk_bytesX[2][4*b+:4]=chk2_bytes[4+b] & {4{chk2_match_has[4+b]}};
	      assign chk_bytesX[3][4*b+:4]=chk3_bytes[4+b] & {4{chk3_match_has[4+b]}};
	      assign chk_bytesX[4][4*b+:4]=chk4_bytes[4+b] & {4{chk4_match_has[4+b]}};
	      assign chk_bytesX[5][4*b+:4]=chk5_bytes[4+b] & {4{chk5_match_has[4+b]}};
	      //verilator lint_off WIDTH
              assign WLN0_b[b]=-(WLN0_adata[`lsaddr_bank0]&3)+b[1:0]; 
              assign WLN1_b[b]=-(WLN1_adata[`lsaddr_bank0]&3)+b[1:0]; 
              assign chk0_b[b]=-(chk0_adata[`lsaddr_bank0]&7)+b[1:0]; 
              assign chk1_b[b]=-(chk1_adata[`lsaddr_bank0]&7)+b[2:0]; 
              assign chk2_b[b]=-(chk2_adata[`lsaddr_bank0]&7)+b[2:0]; 
              assign chk3_b[b]=-(chk3_adata[`lsaddr_bank0]&7)+b[2:0]; 
              assign chk4_b[b]=-(chk4_adata[`lsaddr_bank0]&7)+b[2:0]; 
              assign chk5_b[b]=-(chk5_adata[`lsaddr_bank0]&7)+b[2:0]; 
	      //verilator lint_on WIDTH
              assign upd0_b[b]=-(upd0_begin0[1:0]&3)+b[1:0]; 
              assign upd1_b[b]=-(upd1_begin0[1:0]&3)+b[1:0]; 
              assign Rupd0_b[b]=(upd0_begin0[1:0]&3)+b[1:0]; 
              assign Rupd1_b[b]=(upd1_begin0[1:0]&3)+b[1:0]; 
          end

      end
      for(x=0;x<64;x=x+1) begin : X
          assign WLN0_match[x]=pwh#(32)::cmpEQ(WLN0_WQ,x) && WLN0_en;
          assign WLN1_match[x]=pwh#(32)::cmpEQ(WLN1_WQ,x) && WLN1_en;
          assign W_NL0_en0[x]=pwh#(32)::cmpEQ(W_NL0_WQ,x) && W_NL0_en;
          assign W_NL1_en0[x]=pwh#(32)::cmpEQ(W_NL1_WQ,x) && W_NL1_en;
          assign wrt0_en0[x]=wrt0_adata[`lsaddr_WQ]==x && wrt0_en;
          assign wrt1_en0[x]=wrt1_adata[`lsaddr_WQ]==x && wrt1_en;
          assign upd0_en0[x]=pwh#(32)::cmpEQ(upd0_WQ,x) && upd0_en;
          assign upd1_en0[x]=pwh#(32)::cmpEQ(upd1_WQ,x) && upd1_en;
          assign passe_en[x]=(pwh#(32)::cmpEQ(W_NL0_WQ,x) && W_NL0_en) || (pwh#(32)::cmpEQ(W_NL1_WQ,x) && W_NL1_en);
	  assign free_en[x]=(pwh#(32)::cmpEQ(WLN0_WQ,x) && WLN0_en && !st_stall) || (pwh#(32)::cmpEQ(WLN1_WQ,x) && WLN1_en && !st_stall);
      end
      for(a=0;a<6;a=a+1) begin : wrt
          assign W_NL0_en=LSQ_shr_data[`lsqshare_wrt0]==a ? &rdy[a:0] & chk_rdy : 1'bz;
          assign W_NL1_en=LSQ_shr_data[`lsqshare_wrt1]==a ? &rdy[a:0] & chk_rdy : 1'bz;
          assign W_NL0_adata=LSQ_shr_data[`lsqshare_wrt0]==a ? chk_adata[a] : {`lsaddr_width{1'bz}};
          assign W_NL1_adata=LSQ_shr_data[`lsqshare_wrt1]==a ? chk_adata[a] : {`lsaddr_width{1'bz}};
          assign W_NL0_WQ=LSQ_shr_data[`lsqshare_wrt0]==a ? chk_adata[a][`lsaddr_WQ] : 'z;
          assign W_NL1_WQ=LSQ_shr_data[`lsqshare_wrt1]==a ? chk_adata[a][`lsaddr_WQ] : 'z;
	  assign wb0_adataW=chk_wb[a] ? chk_adata[a] : {`lsaddr_width{1'bz}};
	  assign wb1_adataW=chk_wb1[a] ? chk_adata[a] : {`lsaddr_width{1'bz}};
      end
  endgenerate
  assign wb0_adataW=chk_wb0_has ? {`lsaddr_width{1'bz}} : {`lsaddr_width{1'b0}};
  assign wb1_adataW=chk_wb1_has ? {`lsaddr_width{1'bz}} : {`lsaddr_width{1'b0}};
  assign wb0_bnkEn=chk_wb0_has_reg2 ? 17'bz : 17'b0;
  assign wb1_bnkEn=chk_wb1_has_reg2 ? 17'bz : 17'b0;
  assign wb0_bnkEnS=chk_wb0_has_reg2 ? 17'bz : 17'b0;
  assign wb1_bnkEnS=chk_wb1_has_reg2 ? 17'bz : 17'b0;



  assign wb0_en=chk_wb0_has;
  assign wb1_en=chk_wb1_has;

  assign wb0_chk=chk_wb0;
  assign wb1_chk=chk_wb1;

  //puffy_bafff=how many clocks to wait for first load-store forwarding
  assign puffy_bafff=(chk_LSQ-chk_LSQu)>31 ? 32+(chk_LSQ-chk_LSQu) : 32+(chk_LSQu-chk_LSQ);

  assign W_NL0_odd=W_NL0_adata[`lsaddr_odd];
  assign W_NL1_odd=W_NL1_adata[`lsaddr_odd];
  assign chk0_odd=chk0_adata[`lsaddr_odd];
  assign chk1_odd=chk1_adata[`lsaddr_odd];
  assign chk2_odd=chk2_adata[`lsaddr_odd];
  assign chk3_odd=chk3_adata[`lsaddr_odd];
  assign chk4_odd=chk4_adata[`lsaddr_odd];
  assign chk5_odd=chk5_adata[`lsaddr_odd];

  assign chk0_pre0=1'b0;
  assign chk0_pre1=1'b0;

  assign chk1_pre0=LSQ_shr_data[`lsqshare_wrt0]==3'd0;
  assign chk1_pre1=1'b0;

  assign chk2_pre0=LSQ_shr_data[`lsqshare_wrt0+1]==2'b0;
  assign chk2_pre1=LSQ_shr_data[`lsqshare_wrt1+1]==2'b0;

  assign chk3_pre0=LSQ_shr_data[`lsqshare_wrt0+1]==2'b0 || LSQ_shr_data[`lsqshare_wrt0]==3'd2;
  assign chk3_pre1=LSQ_shr_data[`lsqshare_wrt1+1]==2'b0 || LSQ_shr_data[`lsqshare_wrt1]==3'd2;
 
  assign chk4_pre0=LSQ_shr_data[`lsqshare_wrt0+2]==1'b0;
  assign chk4_pre1=LSQ_shr_data[`lsqshare_wrt1+2]==1'b0;

  assign chk5_pre0=LSQ_shr_data[`lsqshare_wrt0+2]==1'b0 || LSQ_shr_data[`lsqshare_wrt0]==3'd4;
  assign chk5_pre1=LSQ_shr_data[`lsqshare_wrt1+2]==1'b0 || LSQ_shr_data[`lsqshare_wrt1]==3'd4;
 


  assign aDoStall=(|chk0_partial | |chk0_partialW && chk_adata[0][`lsaddr_flag]) || (|chk1_partial | |chk1_partialW && chk_adata[1][`lsaddr_flag]) ||
	  (|chk2_partial | |chk2_partialW && chk_adata[2][`lsaddr_flag]) || (|chk3_partial | |chk3_partialW && chk_adata[3][`lsaddr_flag]) ||
	  (|chk4_partial | |chk4_partialW && chk_adata[4][`lsaddr_flag]) || (|chk5_partial | |chk5_partialW && chk_adata[5][`lsaddr_flag]) ||
	  chk_wb2_has ||  |rsDoStall | rsStall;
  assign confl0[0]=(|chk0_partial | |chk0_partialW || |chk0_match | |chk0_matchW) && chk0_en && !chk_adata[0][`lsaddr_flag] &&
	  !chk_adata[0][`lsaddr_st];
  assign confl0[1]=(|chk1_partial | |chk1_partialW || |chk1_match | |chk0_matchW) && chk1_en && !chk_adata[1][`lsaddr_flag] &&
	  !chk_adata[1][`lsaddr_st];
  assign confl0[2]=(|chk2_partial | |chk2_partialW || |chk2_match | |chk0_matchW) && chk2_en && !chk_adata[2][`lsaddr_flag] &&
	  !chk_adata[2][`lsaddr_st];
  assign confl0[3]=(|chk3_partial | |chk3_partialW || |chk3_match | |chk0_matchW) && chk3_en && !chk_adata[3][`lsaddr_flag] &&
	  !chk_adata[3][`lsaddr_st];
  assign confl0[4]=(|chk4_partial | |chk4_partialW || |chk4_match | |chk0_matchW) && chk4_en && !chk_adata[4][`lsaddr_flag] &&
	  !chk_adata[4][`lsaddr_st];
  assign confl0[5]=(|chk5_partial | |chk5_partialW || |chk5_match | |chk0_matchW) && chk5_en && !chk_adata[5][`lsaddr_flag] &&
	  !chk_adata[5][`lsaddr_st];
  
  assign W_NL0_en=LSQ_shr_data[`lsqshare_wrt0]==3'd7 ? 1'b0 : 1'bz;
  assign W_NL1_en=LSQ_shr_data[`lsqshare_wrt1]==3'd7 ? 1'b0 : 1'bz;
  assign W_NL0_adata=LSQ_shr_data[`lsqshare_wrt0]==3'd7 ? {`lsaddr_width{1'b0}} : {`lsaddr_width{1'bz}};
  assign W_NL1_adata=LSQ_shr_data[`lsqshare_wrt1]==3'd7 ? {`lsaddr_width{1'b0}} : {`lsaddr_width{1'bz}};
  assign W_NL0_WQ=LSQ_shr_data[`lsqshare_wrt0]==3'd7 ? 6'b0 : 6'bz;
  assign W_NL1_WQ=LSQ_shr_data[`lsqshare_wrt1]==3'd7 ? 6'b0 : 6'bz;
 
  assign ret_II_out=WLN0_adata[`lsaddr_II+4];

  assign chk0_banks=(chk0_adata[`lsaddr_sz]==5'h11 || chk0_adata[`lsaddr_sz]==5'h10 || chk0_adata[`lsaddr_low]==2'b0) ?
    chk0_adata[`lsaddr_banks] : lowt(chk0_adata[`lsaddr_banks]);
  assign chk0_odd0[2:0]=(chk0_adata[`lsaddr_sz]==5'h11 || chk0_adata[`lsaddr_sz]==5'h10) ? {2'b0,chk0_odd} : {chk0_adata[`lsaddr_low],chk0_odd}; 
  assign chk0_odd0[3]=chk0_adata[`lsaddr_sz]==5'hf;

  assign chk1_banks=(chk1_adata[`lsaddr_sz]==5'h11 || chk1_adata[`lsaddr_sz]==5'h10 || chk1_adata[`lsaddr_low]==2'b0) ?
    chk1_adata[`lsaddr_banks] : lowt(chk1_adata[`lsaddr_banks]);
  assign chk1_odd0[2:0]=(chk1_adata[`lsaddr_sz]==5'h11 || chk1_adata[`lsaddr_sz]==5'h10) ? {2'b0,chk1_odd} : {chk1_adata[`lsaddr_low],chk1_odd}; 
  assign chk1_odd0[3]=chk1_adata[`lsaddr_sz]==5'hf;

  assign chk2_banks=(chk2_adata[`lsaddr_sz]==5'h11 || chk2_adata[`lsaddr_sz]==5'h10 || chk2_adata[`lsaddr_low]==2'b0) ?
    chk2_adata[`lsaddr_banks] : lowt(chk2_adata[`lsaddr_banks]);
  assign chk2_odd0[2:0]=(chk2_adata[`lsaddr_sz]==5'h11 || chk2_adata[`lsaddr_sz]==5'h10) ? {2'b0,chk2_odd} : {chk2_adata[`lsaddr_low],chk2_odd}; 
  assign chk2_odd0[3]=chk2_adata[`lsaddr_sz]==5'hf;

  assign chk3_banks=(chk3_adata[`lsaddr_sz]==5'h11 || chk3_adata[`lsaddr_sz]==5'h10 || chk3_adata[`lsaddr_low]==2'b0) ?
    chk3_adata[`lsaddr_banks] : lowt(chk3_adata[`lsaddr_banks]);
  assign chk3_odd0[2:0]=(chk3_adata[`lsaddr_sz]==5'h11 || chk3_adata[`lsaddr_sz]==5'h10) ? {2'b0,chk3_odd} : {chk3_adata[`lsaddr_low],chk3_odd}; 
  assign chk3_odd0[3]=chk3_adata[`lsaddr_sz]==5'hf;

  assign W_NL0_banks=(W_NL0_adata[`lsaddr_sz]==5'h11 || W_NL0_adata[`lsaddr_sz]==5'h10 || W_NL0_adata[`lsaddr_low]==2'b0) ?
    W_NL0_adata[`lsaddr_banks] : lowt(W_NL0_adata[`lsaddr_banks]);
  assign W_NL0_odd0[2:0]=(W_NL0_adata[`lsaddr_sz]==5'h11 || W_NL0_adata[`lsaddr_sz]==5'h10) ? {2'b0,W_NL0_odd} : {W_NL0_adata[`lsaddr_low],W_NL0_odd}; 
  assign W_NL0_odd0[3]=W_NL0_adata[`lsaddr_sz]==5'hf;

  assign W_NL1_banks=(W_NL1_adata[`lsaddr_sz]==5'h11 || W_NL1_adata[`lsaddr_sz]==5'h10 || W_NL1_adata[`lsaddr_low]==2'b0) ?
    W_NL1_adata[`lsaddr_banks] : lowt(W_NL1_adata[`lsaddr_banks]);
  assign W_NL1_odd0[2:0]=(W_NL1_adata[`lsaddr_sz]==5'h11 || W_NL1_adata[`lsaddr_sz]==5'h10) ? {2'b0,W_NL1_odd} : {W_NL1_adata[`lsaddr_low],W_NL1_odd}; 
  assign W_NL1_odd0[3]=W_NL1_adata[`lsaddr_sz]==5'hf;
  
  assign chk0_banks=chk0_adata[`lsaddr_banks];
  assign chk1_banks=chk1_adata[`lsaddr_banks];
  assign chk2_banks=chk2_adata[`lsaddr_banks];
  assign chk3_banks=chk3_adata[`lsaddr_banks];
  assign W_NL0_banks=W_NL0_adata[`lsaddr_banks];
  assign W_NL1_banks=W_NL1_adata[`lsaddr_banks];

  assign chk_adata[0]=chk0_adata;
  assign chk_adata[1]=chk1_adata;
  assign chk_adata[2]=chk2_adata;
  assign chk_adata[3]=chk3_adata;

  bit_find_first_bit #(6) first_wb_mod(chk_wb&~chk_mask&
	  ~{chk5_enD[1],chk4_enD[1],chk3_enD[1],chk2_enD[1],chk1_enD[1],chk0_enD[1]},chk_wb0,chk_wb0_has);
  bit_find_first_bit #(6) first_wb1_mod(chk_wb&~chk_wb0&~chk_mask,chk_wb1,chk_wb1_has);

  assign chk_wb2_has=(chk_wb&~chk_wb0&~chk_mask&~chk_wb1)!=6'd0;
  
  stq_buf_A_array A0_mod(
  clk,
  rst,
  aStall|aDoStall,
  excpt,
  wrt0_en0, wrt0_adata[`lsaddr_addrE], wrt0_adata[`lsaddr_addrO], 
  chk0_en, chk0_addrEO, chk0_adata[`lsaddr_addrE], chk0_adata[`lsaddr_addrO],
  chk1_en, chk1_addrEO, chk1_adata[`lsaddr_addrE], chk1_adata[`lsaddr_addrO],
  chk2_en, chk2_addrEO, chk2_adata[`lsaddr_addrE], chk2_adata[`lsaddr_addrO],
  chk3_en, chk3_addrEO, chk3_adata[`lsaddr_addrE], chk3_adata[`lsaddr_addrO],
  chkWB0_en, chkWB0_addrEO, chkWB0_adata[`lsaddr_addrE], chkWB0_adata[`lsaddr_addrO],
  chkWB1_en, chkWB1_addrEO, chkWB1_adata[`lsaddr_addrE], chkWB1_adata[`lsaddr_addrO],
  upd0_en0, 
  free_en,,,,passe_en);

  stq_adata_ram ramA_mod(
  clk,
  rst,
  ~st_stall & WLN0_en,  WLN0_LSQ[5:0], {WLN0_adata,WLN0_en0},//first point store; greater priority
  ~st_stall & WLN1_en,  WLN1_LSQ[5:0], {WLN1_adata,WLN1_en0},//second point store and store finalize
  wrt0_en,  {wrt0_adata,wrt0_en}
  );


  assign WLN0_en=WLN0_en0 && pwh#(32)::cmpEQ(ret_II,WLN0_adata)[`lsaddr_II+4] && 
	  ~ret_xbreak[WLN0_adata[-6+`lsaddr_II]];
  
  assign WLN0_LSQ=chk0_LSQ+24;
  assign WLN1_LSQ=chk0_LSQ+48;
  assign wbRADDR0=chk0_LSQ+24;
  assign wbRADDR1=chk0_LSQ+24;

  stq_adata bgn_mod(
  clk,
  rst,
  wrt0_en,wrt0_adata[`lsaddr_WQ],wrt0_adata[`lsaddr_bank0],
  upd0_WQ,upd0_begin0);

  stq_adata_wb adataWB_mod(
  clk,
  rst,
  wbADDR0,chk0_adata,chk0_adata[`lsaddr_flag] && chk0_en,
  wbADDR1,chk1_adata,chk1_adata[`lsaddr_flag] && chk1_en,
  wbADDR2,chk2_adata,chk2_adata[`lsaddr_flag] && chk2_en,
  wbADDR3,chk3_adata,chk3_adata[`lsaddr_flag] && chk3_en,
  wbRADDR0,chkWB0_adata,chkWB0_en_input,chkWB0_en,
  wbRADDR1,chkWB1_adata,chkWB1_en_input,chkWB1_en);

  stq_adata_wb #(20) adataWBWQ_mod(
  clk,
  rst,
  wbADDR0,{chk0_LSQ,pse0_LSQ},chk0_adata[`lsaddr_flag] && chk0_en,
  wbADDR1,{chk1_LSQ,pse0_LSQ},chk0_adata[`lsaddr_flag] && chk1_en,
  wbADDR2,{chk2_LSQ,pse0_LSQ},chk0_adata[`lsaddr_flag] && chk2_en,
  wbADDR3,{chk3_LSQ,pse0_LSQ},chk0_adata[`lsaddr_flag] && chk3_en,
  wbRADDR0,chkWB0_LSQdata,chkWB0_en_input,,
  wbRADDR1,chkWB1_LSQdata,chkWB1_en_input,);

  assign chkWB0_en_input=chkWB0_en && ~chkWB0_conflict && LSQDET(chkWB0_LSQdata,chkWB0_match);
  assign chkWB1_en_input=chkWB0_en_input && chkWB1_en && ~chkWB1_conflict && LSQDET(chkWB1_LSQdata,chkWB1_match); 

  adder_inc #(6) inc_pseA_mod(pse1_WQ,pse1_WQ_inc,1'b1,);
  adder_inc #(5) inc_pseB_mod(pse1_WQ[5:1],pse1_WQ_inc2[5:1],1'b1,);
  assign pse1_WQ_inc2[0]=pse1_WQ[0];
  adder_inc #(6) inc_WLNA_mod(WLN1_WQ,WLN1_WQ_inc,1'b1,);
  adder_inc #(5) inc_WLNB_mod(WLN1_WQ[5:1],WLN1_WQ_inc2[5:1],1'b1,);
  assign WLN1_WQ_inc2[0]=WLN1_WQ[0];
 // always @(free) $display("stq_free: %x,%x",free,upd);
  always @(posedge clk) begin
      if (rst) begin
	  confl_out<=6'b0;
	  pse0_WQ<=6'd0;
	  pse1_WQ<=6'd0;
	  WLN0_WQ<=6'd0;
	  WLN1_WQ<=6'd1;
	  chk_mask<=6'd0;
	  mask=64'b0;
	  mask2=64'b0;
	  nmask=64'b0;
	  rsDoStall<=4'b0000;
	  wb0_adata<=0;
	  wb1_adata<=0;
	  chk_wb0_reg<=0;
	  chk_wb0_reg2<=0;
	  chk_wb0_has_reg<=0;
	  chk_wb0_has_reg2<=0;
	  chk_bytes_reg<=0;
	  chk_bytes_reg2<=0;
	  chk_wb1_reg<=0;
	  chk_wb1_reg2<=0;
	  chk_wb1_has_reg<=0;
	  chk_wb1_has_reg2<=0;
      end else begin
	  confl_out<=confl0;
	  wb0_adata<=wb0_adataW;
	  wb1_adata<=wb1_adataW;
	  if (!stall && !doStall && pse0_en && ~pse1_en & ~excpt) begin
	      pse0_WQ<=pse1_WQ;
	      pse1_WQ<=pse1_WQ_inc;
	      if (!mask[63]) mask[pse0_WQ]=1'b1; else nmask[pse0_WQ]=1'b1;
	  end else if (!stall && !doStall && pse0_en && ~excpt) begin
	      pse0_WQ<=pse1_WQ_inc;
	      pse1_WQ<=pse1_WQ_inc2;
	      if (!mask[63]) mask[pse0_WQ]=1'b1; else nmask[pse0_WQ]=1'b1;
	      if (!mask[62]) mask[pse1_WQ]=1'b1; else nmask[pse1_WQ]=1'b1;
	  end
	  if (!aStall && !aDoStall && W_NL0_en && ~W_NL1_en & ~excpt) begin
	      mask2[W_NL0_WQ]=1'b1;
	  end else if (!aStall && !aDoStall && W_NL0_en && ~excpt) begin
	      mask2[W_NL0_WQ]=1'b1;
	      mask2[W_NL1_WQ]=1'b1;
	  end
	  if (!st_stall &&  WLN0_en && ~WLN1_en) begin
	      WLN0_WQ<=WLN1_WQ;
	      WLN1_WQ<=WLN1_WQ_inc;
	      mask2[WLN0_WQ]=1'b0;
	      mask[WLN0_WQ]=1'b0;
	      if (WLN0_WQ==63) begin mask=nmask; nmask=64'b0; end
	  end else if (!st_stall && WLN0_en) begin
	      WLN0_WQ<=WLN1_WQ_inc;
	      WLN1_WQ<=WLN1_WQ_inc2;
	      mask2[WLN0_WQ]=1'b0;
	      mask2[WLN1_WQ]=1'b0;
	      mask[WLN0_WQ]=1'b0;
	      mask[WLN1_WQ]=1'b0;
	      if (WLN0_WQ==63 || WLN1_WQ==63) begin mask=nmask; nmask=64'b0; end
	  end
	  if (excpt) begin
	      mask=64'b0;
	      mask2=64'b0;
	      nmask=64'b0;
	      WLN0_WQ<=pse0_WQ;
	      WLN1_WQ<=pse1_WQ;
	  end
	  if (!aStall && !aDoStall && chk_rdy) begin
	      chk_mask<=6'd0;
	  end else if (!(|rsDoStall & rsStall)) begin
	      chk_mask<=chk_mask|chk_wb0|chk_wb1;
	  end
	  if (!(|rsDoStall & rsStall)) begin
	      rsDoStall[0]<=wb1_en && wb0_way==2'd0;
	      rsDoStall[1]<=wb1_en && wb0_way==2'd1;
	      rsDoStall[2]<=wb1_en && wb0_way==2'd2;
	      rsDoStall[3]<=wb1_en;
          end
	  chk_wb0_reg<=chk_wb0;
	  chk_wb0_reg2<=chk_wb0_reg;
	  chk_wb0_has_reg<=chk_wb0_has;
	  chk_wb0_has_reg2<=chk_wb0_has_reg;
	  chk_bytes_reg<=chk_bytes;
	  chk_bytes_reg2<=chk_bytes_reg;
	  chk_wb1_reg<=chk_wb1;
	  chk_wb1_reg2<=chk_wb1_reg;
	  chk_wb1_has_reg<=chk_wb1_has;
	  chk_wb1_has_reg2<=chk_wb1_has_reg;
      end
      wb0_dataW_reg<=wb0_dataW;
      wb1_dataW_reg<=wb1_dataW;
      wb0_pbit<=wb0_pbitW;
      wb1_pbit<=wb1_pbitW;
  end
endmodule
