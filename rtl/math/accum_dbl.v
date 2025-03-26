
/* please note: NOT transparent accumulate; explicit accumulate instruction and as such not covered by itanium patents but it is not legal advise */
/*
Copyright 2022-2025 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

module accum_buf_one(
    clk,
    rst,
    A,
    B,
    din_en,
    res,
    res_en
    );
    input clk;
    input rst;
    input [67:0] A;
    input [107:0][67:0] B;
    input din_en;
    output pwire [67:0] res;
    output pwire res_en; //one clock before res

    integer kl;
    //reg [108:0][11:0] exp;
    reg [11:0] exp_max;
    reg signed [108:0] sgn;

    always @(posedge clk) begin
        exp_max={A[64],A[62:52]};
        Bs[108]=({64+53{sgn[108]}}^{1'b1,A_reg2[51:33],A_reg2[31:0],64'b0})>>(exp_max_reg2-{A_reg2[64],A_reg2[62:52]});
        for(kl=0;kl<108;kl=kl+1) begin
            if ({B[kl][64],B[kl][62:52]}>exp_max) exp_max={B[kl][64],B[kl][62:52]};
            Bs[kl]=({64+53{sgn[kl]}}^{1'b1,B_reg2[kl][51:33],B_reg2[kl][31:0],64'b0})>>(exp_max_reg2-{B_reg2[kl][64],B_reg2[kl][62:52]});
            sgn[kl]=B_reg[63];
            Bss=Bss+{11'b0,Bs_reg[kl]};
        end
        sgn[108]=A_reg[63];
        exp_max_reg=exp_max;
        exp_max_reg2=exp_max_reg;//use no earlier than this
        Bs_reg<=Bs; //dont use Bs, use Bs_reg
        Bss_reg<=Bss; //dont use; use Bss_reg2
        Bss_reg2<=Bss_reg;
        if (Bxx[127-53] && |Bxx[127-53:0]) Bxx_reg=Bxx[126-:52]+1;
        else Bxx_reg=Bxx[126-:52];
    end

    bit_find_first_bit #(12) bgn_mod(Bss_reg2[127:116],first,has_first);
    bit_find_first_bit_neg #(12) bgn_mod(~Bss_reg2[127:116],first_N,has_N_first);

    generate
      genvar p;
      for(p=0;p<12;p=p+1) begin
          assign Bxx=first_reg[p] & ~ Bss_reg3[127] ? Bss_reg3 << p : 'z;
          assign Bxx=first_N_reg[p] & Bss_reg3[127] ? ~Bss_reg3 << p : 'z;
          assign Bxxx=first_reg[p] & ~ Bss_reg3[127] ? exp_max_reg6+p : 'z;
          assign Bxxx=first_N_reg[p] & Bss_reg3[127] ? exp_max_reg6+p : 'z;
      end
    endgenerate

    assign res_en=din_en_reg7; //but output pwire on clock 9

    assign {res[51:33],res[31:0]}=din_en_reg8 ? Bxx_reg : 'z;
    assign res[32]=din_en_reg8 ? 1'b0 : 1'bz;
    assign res[63]=din_en_reg8 ? Bss_reg4[127] : 'z;
    assign {res[64],res[62:52]}=din_en_reg8 && Bxxx_reg>=exp_max_reg7 ? Bxxx_reg :'z;
    assign {res[64],res[62:52]}=din_en_reg8 && Bxxx_reg<exp_max_reg7 ? 12'hffe :'z;
endmodule
