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
module stq_adata_ram(
  clk,
  rst,
  readA_clkEn,
  readA_addr,
  readA_data,
  writeA_wen,
  writeA_addr,
  writeA_data,
  );
  localparam WIDTH=`lsaddr_width+1;//adata+en
  
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [5:0] read_addr;
  output pwire [WIDTH-1:0] read_data;
  input pwire [2:0] writeA_wen;
  input pwire [2:0] [5:0] writeA_addr;
  input pwire [2:0] [WIDTH-1:0] writeA_data;

  pwire [WIDTH-1:0] ram[63:0];
  pwire [5:0] readA_addr_reg;

  assign readA_data=ram[readA_addr_reg];

  always @(posedge clk) begin
      if (rst) readA_addr_reg<=6'b0;
      else if (readA_clkEn) readA_addr_reg<=readA_addr;
      (* keep *) if (writeA_wen[0]) ram[writeA_addr[0]]<=writeA_data[2];
      (* keep *) if (writeA_wen[1]) ram[writeA_addr[1]]<=writeA_data[0];
      (* keep *) if (writeA_wen[2]) ram[writeA_addr[2]]<=writeA_data[1];
  end
endmodule

