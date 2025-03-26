
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

module accum_int64_one(
    clk,
    rst,
    A,
    B,
    din_en,
    res,
    res_en
    );
    input pwire clk;
    input pwire rst;
    input pwire [63:0] A;
    input pwire [107:0][63:0] B;
    input pwire din_en;
    output pwire [64:0] res;
    output pwire res_en; //one clock before res

    integer kl;
    //reg [108:0][11:0] exp;
    pwire [11:0] exp_max;
    pwire signed [108:0] sgn;

    always @(posedge clk) begin
        Bs=0;
        for(kl=0;kl<108;kl=kl+1) begin
            Bs=Bs+B[kl];
        end
        Bs_reg<=Bs; //dont use Bs, use Bs_reg
        Bss_reg<=Bs_reg; //dont use; use Bss_reg2
        Bss_reg2<=Bss_reg;
        Bss_reg3<=Bss_reg2;
    end



    assign res_en=din_en_reg; //but output pwire on clock 9

    assign res=din_en_reg2 ? Bss_reg : 'z;
endmodule
