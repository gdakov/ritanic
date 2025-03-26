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

module addrcalcsec_check_upper3(
  input pwire [64:0] ptr,
  input pwire [32:0] A,
  input pwire [32:0] B,
  output pwire [3:0] pos_ack,
  output pwire [3:0] neg_ack,
  output pwire [2:0] pos_nack,
  output pwire [2:0] neg_nack,
  output pwire nhi_less
  );
  parameter [0:0] AGU=0;
  pwire [4:0] exp=ptr[`ptr_exp];

  pwire [3:0] posx;
  pwire do_pos,do_pos2,do_neg,do_neg2,do_neg1;
  pwire do_pos3,do_neg3;
  pwire do_pos1,do_negP;
  pwire [7:0] msk;
  pwire [7:0] msk0;
  pwire [40:0] O={1'b0,A|B};
  pwire [40:0] X={1'b1,A^B};
  pwire [40:0] And={1'b1,A&B};
  pwire diff=~nhi_less;
  pwire on_hi=ptr[`ptr_on_low]!=ptr[12+exp];
  pwire hiff=~AGU && ptr[`ptr_hi]==7'h7f;
  pwire max=pwh#(5)::cmpEQ(exp,5'h1f);

  function [0:0] redand8;
      input pwire [7:0] din;
      begin
	  redand8=din[0] & din[1] & din[2] & din[3] &
	      din[4] & din[5] & din[6] & din[7];
      end
  endfunction
  function [0:0] redor8;
      input pwire [7:0] din;
      begin
	  redor8=din[0] | din[1] | din[2] | din[3] |
	      din[4] | din[5] | din[6] | din[7];
      end
  endfunction
  assign posx[3]=~&exp[4:3];
  assign posx[2]=~exp[4];
  assign posx[1]=~|exp[4:3];
  assign posx[0]=1'b0;
  
  assign msk=8'hff << exp[2:0];


  assign pos_ack[2]=((do_pos) && ~on_hi& &ptr[`ptr_hi] && diff && &ptr[`ptr_hi]) || max ; //c==2
  assign pos_ack[1]=((do_pos) && ~on_hi|&ptr[`ptr_hi] && diff|&ptr[`ptr_hi]) || max ; //c==1
  assign pos_ack[0]=do_pos&~(on_hi&~diff) || (do_pos2) & (~on_hi|&ptr[`ptr_hi]) & (diff|&ptr[`ptr_hi]) || max; //c==0
  assign pos_ack[3]=do_pos3 | max;
  assign neg_ack[0]=(do_neg) && on_hi| ~|ptr[`ptr_low] && diff| ~|ptr[`ptr_low]; //c==0
  assign neg_ack[1]=do_neg&~(on_hi&~diff) || (do_neg2|do_neg1) & (on_hi| ~|ptr[`ptr_low]) & (diff | ~|ptr[`ptr_low]); //c==1
  assign neg_ack[2]=do_neg&~(on_hi|~diff) || (do_neg2|do_neg1) & (on_hi & ~|ptr[`ptr_low]) & (diff & ~|ptr[`ptr_low]); //c==2
  assign neg_ack[3]=do_neg3 | max;

  assign pos_nack[2]=((do_pos) && ~on_hi& &ptr[`ptr_hi]) || max ; //c==2
  assign pos_nack[1]=((do_pos) && on_hi& &ptr[`ptr_hi]) || max ; //c==1
  assign pos_nack[0]=(do_pos2) & on_hi & &ptr[`ptr_hi] || max; //c==0
  assign neg_nack[0]=(do_neg) && ~on_hi& ~|ptr[`ptr_low]; //c==0
  assign neg_nack[1]=(do_neg2|do_neg1) & ~on_hi& ~|ptr[`ptr_low]; //c==1
  assign neg_nack[2]=(do_neg2|do_neg1) & on_hi& ~|ptr[`ptr_low]; //c==2


  get_carry #(7) cmp_mod(ptr[`ptr_hi],~ptr[`ptr_low],1'b1,nhi_less);
  generate
    genvar p;
    pwire [3:0] pos0;
    pwire [3:0] pos1;
    pwire [3:0] pos2;
    pwire [3:0] pos3;
    pwire [3:0] posP;
    pwire [3:0] neg2;
    pwire [3:0] neg1;
    pwire [3:0] neg0;
    pwire [3:0] neg3;
    pwire [3:0] xpos0;
    pwire [3:0] xpos1;
    pwire [3:0] xpos2;
    pwire [3:0] xpos3;
    pwire [3:0] xposP;
    pwire [3:0] xneg2;
    pwire [3:0] xneg1;
    pwire [3:0] xneg0;
    pwire [3:0] xneg3;
    for(p=0;p<4;p=p+1) begin : offs
       
        assign pos0[p]= ~posx[p] ||  ~redor8(O[p*8+:8+&p[1:0]);
        assign pos2[p]= ~posx[p] ||  ~redor8(O[p*8+1+:8]);
        assign neg0[p]= ~posx[p] ||  redand8(X[p*8+:8+&p[1:0]]);
        assign neg1[p]= ~posx[p] ||  redand8(And[p*8+:8+&p[1:0]]);
        assign neg2[p]= ~posx[p] ||  redand8(X[p*8+1+:8]);
       
        
        assign xpos0[p]= p!=exp[4:3] ||  ~redor8(O[p*8+:8+&p[1:0]]&msk);
        assign xpos2[p]= p!=exp[4:3] ||  (~redor8(O[p*8+1+:8]&msk)&~redor8(And[p*8+1+:8]&msk));
        assign xneg0[p]= p!=exp[4:3] ||  redand8(X[p*8+:8+&p[1:0]]|~msk);
        assign xneg1[p]= p!=exp[4:3] ||  redand8(And[p*8+:8+&p[1:0]]|~msk);
        assign xneg2[p]= p!=exp[4:3] ||  (redand8(X[p*8+1+:8]|~msk)&~redor8(And[p*8+1+:8]&msk0));
    end
    assign do_pos=redand8({pos0,xpos0});
    assign do_pos1=redor8({pos1,xpos1});
    assign do_pos2=redand8({pos2,xpos2});// && exp!=5'h1e;
    assign do_pos3=redand8({pos0,xpos0});
    assign do_neg=redand8({neg0,xneg0});
    assign do_neg2=redand8({neg2,xneg2});// && exp!=5'h1e;
    assign do_neg1=redand8({neg1,xneg1});// && exp!=5'h1e;
    assign do_neg3=redand8({neg0,xneg0});
  endgenerate

endmodule

module addrcalcsec_range(
  input pwire [64:0] ptr,
  input pwire cin_secq,
  input pwire diff,
  output pwire cout_secq);

  pwire [7:0] low={ptr[`ptr_low],1'b0};
  pwire [7:0] high={ptr[`ptr_hi],1'b1};
  //wire diff=ptr[`ptr_hi_less];
  pwire hi_pass=diff && ptr[`ptr_on_low]==ptr[12+ptr[`ptr_exp]];
  pwire lo_lass=diff && ptr[`ptr_on_low]!=ptr[12+ptr[`ptr_exp]];
  pwire [7:0] bits;
  pwire cout_low,cout_hio;

  get_carry #(8) cmpLow_mod(~low,bits,1'b1,cout_low);
  get_carry #(8) cmpHio_mod(high,~bits,1'b1,cout_hio);
  addrcalcsec_shift8  sh_mod(ptr[`ptr_exp],ptr[43:4],bits);
  assign cout_secq=cin_secq && cout_low|lo_lass && cout_hio|hi_pass && (|low || ~&high);
endmodule
