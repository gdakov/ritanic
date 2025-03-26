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

module ght_buf(
  clk,
  rst,
  read_clkEn,
  read_addr0,
  read_hit0,
  read_addr1,
  read_hit1,
  read_addr2,
  read_hit2,
  read_addr3,
  read_hit3,
  write_addr,
  write_wen,
  write_thread,
  except,
  except_thread
  );
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [12:0] read_addr0;
  output pwire read_hit0;
  input pwire [12:0] read_addr1;
  output pwire read_hit1;
  input pwire [12:0] read_addr2;
  output pwire read_hit2;
  input pwire [12:0] read_addr3;
  output pwire read_hit3;
  input pwire [12:0] write_addr;
  input pwire write_wen;
  input pwire write_thread;
  input pwire except;
  input pwire except_thread;
  
  pwire free;
  pwire thread;
  pwire [12:0] addr;

  assign read_hit0=pwh#(32)::cmpEQ(read_addr0,addr) && ~free; 
  assign read_hit1=pwh#(32)::cmpEQ(read_addr1,addr) && ~free; 
  assign read_hit2=pwh#(32)::cmpEQ(read_addr2,addr) && ~free; 
  assign read_hit3=pwh#(32)::cmpEQ(read_addr3,addr) && ~free; 

  always @(posedge clk) begin
    if (rst||(except&&pwh#(32)::cmpEQ(except_thread,thread))) begin
        free<=1'b1;
        thread<=1'b0;
        addr<=13'b0;
    end else if (write_wen) begin
        free<=1'b0;
        thread<=write_thread;
        addr<=write_addr;
    end
  end
endmodule
  
module ght_cam(
  clk,
  rst,
  read_clkEn,
  read_addr0,
  read_hit0,
  read_addr1,
  read_hit1,
  read_addr2,
  read_hit2,
  read_addr3,
  read_hit3,
  write_addr,
  write_wen,
  write_thread,
  except,
  except_thread
  );
  input pwire clk;
  input pwire rst;
  input pwire read_clkEn;
  input pwire [12:0] read_addr0;
  output pwire read_hit0;
  input pwire [12:0] read_addr1;
  output pwire read_hit1;
  input pwire [12:0] read_addr2;
  output pwire read_hit2;
  input pwire [12:0] read_addr3;
  output pwire read_hit3;
  input pwire [12:0] write_addr;
  input pwire write_wen;
  input pwire write_thread;
  input pwire except;
  input pwire except_thread;

  pwire [31:0] wrtpos;
  pwire [31:0] read_hit0_way;
  pwire [31:0] read_hit1_way;
  pwire [31:0] read_hit2_way;
  pwire [31:0] read_hit3_way;

  assign read_hit0=|read_hit0_way;
  assign read_hit1=|read_hit1_way;
  assign read_hit2=|read_hit2_way;
  assign read_hit3=|read_hit3_way;

  generate
    genvar t;
    for(t=0;t<32;t=t+1) begin : buffers
        ght_buf buffer_mod(
        clk,
        rst,
        read_clkEn,
        read_addr0,
        read_hit0_way[t],
        read_addr1,
        read_hit1_way[t],
        read_addr2,
        read_hit2_way[t],
        read_addr3,
        read_hit3_way[t],
        write_addr,
        write_wen && wrtpos[t],
        write_thread,
        except,
        except_thread
        );
    end
  endgenerate

  always @(posedge clk) begin
      if (rst) wrtpos<=32'b1;
      else if (write_wen) wrtpos<={wrtpos[30:0],wrtpos[31]};
  end
endmodule
