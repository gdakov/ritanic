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

module msiq_buf(
  clk,
  rst,
  all_clear,
  chk0_data,chk0_en,chk0_smpc,
  chk1_data,chk1_en,chk1_smpc,
  chk2_data,chk2_en,chk2_smpc,
  chk3_data,chk3_en,chk3_smpc,
  wrt_addr,wrt_en,wrt_can);
  
  input pwire clk;
  input pwire rst;
  input pwire all_clear;
  input pwire [`lsaddr_width-1:0] chk0_data;
  input pwire chk0_en;
  output pwire chk0_smpc;
  input pwire [`lsaddr_width-1:0] chk1_data;
  input pwire chk1_en;
  output pwire chk1_smpc;
  input pwire [`lsaddr_width-1:0] chk2_data;
  input pwire chk2_en;
  output pwire chk2_smpc;
  input pwire [`lsaddr_width-1:0] chk3_data;
  input pwire chk3_en;
  output pwire chk3_smpc;
  input pwire [36:0] wrt_addr;
  input pwire wrt_en;
  output pwire wrt_can;

  pwire [36:0] addr;

  assign chk0_smpc=(pwh#(36)::cmpEQ(chk0_data[`lsaddr_addrE],addr[36:1]) && chk0_en && 
    ~chk0_data[`lsaddr_odd] | chk0_data[`lsaddr_split] && ~addr[0]) |
    (pwh#(36)::cmpEQ(chk0_data[`lsaddr_addrO],addr[36:1]) && chk0_en && 
     chk0_data[`lsaddr_odd] | chk0_data[`lsaddr_split] && addr[0]);
  assign chk1_smpc=(pwh#(36)::cmpEQ(chk1_data[`lsaddr_addrE],addr[36:1]) && chk1_en && 
    ~chk1_data[`lsaddr_odd] | chk1_data[`lsaddr_split] && ~addr[0]) |
    (pwh#(36)::cmpEQ(chk1_data[`lsaddr_addrO],addr[36:1]) && chk1_en && 
     chk1_data[`lsaddr_odd] | chk1_data[`lsaddr_split] && addr[0]);
  assign chk2_smpc=(pwh#(36)::cmpEQ(chk2_data[`lsaddr_addrE],addr[36:1]) && chk2_en && 
    ~chk2_data[`lsaddr_odd] | chk2_data[`lsaddr_split] && ~addr[0]) |
    (pwh#(36)::cmpEQ(chk2_data[`lsaddr_addrO],addr[36:1]) && chk2_en && 
     chk2_data[`lsaddr_odd] | chk2_data[`lsaddr_split] && addr[0]);
  assign chk3_smpc=(pwh#(36)::cmpEQ(chk3_data[`lsaddr_addrE],addr[36:1]) && chk3_en && 
    ~chk3_data[`lsaddr_odd] | chk3_data[`lsaddr_split] && ~addr[0]) |
    (pwh#(36)::cmpEQ(chk3_data[`lsaddr_addrO],addr[36:1]) && chk3_en && 
     chk3_data[`lsaddr_odd] | chk3_data[`lsaddr_split] && addr[0]);

  always @(posedge clk) begin
      if (rst) begin
          addr<=37'b0;
          wrt_can<=1'b1;
      end else begin
          if (wrt_en) addr<=wrt_addr;
          wrt_can<=wrt_can & ~wrt_en || all_clear;
      end
  end
endmodule

module msiq(
  clk,
  rst,
  all_clear,
  chk0_data,chk0_en,chk0_smpc,
  chk1_data,chk1_en,chk1_smpc,
  chk2_data,chk2_en,chk2_smpc,
  chk3_data,chk3_en,chk3_smpc,
  wrt_addr,wrt_en,wrt_can);
  input pwire clk;
  input pwire rst;
  input pwire all_clear;
  input pwire [`lsaddr_width-1:0] chk0_data;
  input pwire chk0_en;
  output pwire chk0_smpc;
  input pwire [`lsaddr_width-1:0] chk1_data;
  input pwire chk1_en;
  output pwire chk1_smpc;
  input pwire [`lsaddr_width-1:0] chk2_data;
  input pwire chk2_en;
  output pwire chk2_smpc;
  input pwire [`lsaddr_width-1:0] chk3_data;
  input pwire chk3_en;
  output pwire chk3_smpc;
  input pwire [36:0] wrt_addr;
  input pwire wrt_en;
  output pwire wrt_can;
 
  pwire [7:0] chk0_smpc_way;
  pwire [7:0] chk1_smpc_way;
  pwire [7:0] chk2_smpc_way;
  pwire [7:0] chk3_smpc_way;
  pwire [7:0] wrt_en_way;
  pwire [7:0] wrt_can_way;
  pwire [7:0] wrt_first;
  pwire wrt_has;
  generate
    genvar t;
    for(t=0;t<8;t=t+1) begin : buffers
        msiq_buf elements_mod(
        clk,
        rst,
        all_clear,
        chk0_data,chk0_en,chk0_smpc_way[t],
        chk1_data,chk1_en,chk1_smpc_way[t],
        chk2_data,chk2_en,chk2_smpc_way[t],
        chk3_data,chk3_en,chk3_smpc_way[t],
        wrt_addr,wrt_en_way[t],wrt_can_way[t]);
    end
  endgenerate

  bit_find_first_bit #(8) first_mod(wrt_can_way,wrt_first,wrt_has);

  assign wrt_can=|wrt_can_way;
  assign wrt_en_way={8{wrt_en}}&wrt_first;
endmodule

