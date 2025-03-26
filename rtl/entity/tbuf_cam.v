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


module tbufcam_buf(
  clk,
  rst,
  except,
  except_thread,
  new_addr,
  new_thread,
  new_en,
  chk_addr0,
  chk_match0,
  chk_addr1,
  chk_match1,
  free
  );
  
  localparam WIDTH=11;
  
  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire except_thread;
  input pwire [WIDTH-1:0] new_addr;
  input pwire new_thread;
  input pwire new_en;
  input pwire [WIDTH-1:0] chk_addr0;
  output pwire chk_match0;
  input pwire [WIDTH-1:0] chk_addr1;
  output pwire chk_match1;
  output pwire free;
  
  pwire [WIDTH-1:0] addr;
  pwire thread;
  
  assign chk_match0=pwh#(32)::cmpEQ(chk_addr0,addr) && ~free;
  assign chk_match1=pwh#(32)::cmpEQ(chk_addr1,addr) && ~free;
  
  always @(posedge clk) begin
      if (rst) begin
          thread<=1'b0;
          addr<={WIDTH{1'B0}};
          free<=1'b1;
      end else begin
          if (new_en) begin
              thread<=new_thread;
              addr<=new_addr;
              free<=1'b0;
          end 
          if (except && pwh#(32)::cmpEQ(except_thread,thread)) free<=1'b1;
      end
  end

  
endmodule


module tbufcam(
  clk,
  rst,
  except,
  except_thread,
  new_addr,
  new_thread,
  new_en,
  chk_addr0,
  chk_match0,
  chk_addr1,
  chk_match1,
  free
  );
  
  localparam WIDTH=11;
  localparam BUF_COUNT=4;
  
  input pwire clk;
  input pwire rst;
  input pwire except;
  input pwire except_thread;
  input pwire [WIDTH-1:0] new_addr;
  input pwire new_thread;
  input pwire new_en;
  input pwire [WIDTH-1:0] chk_addr0;
  output pwire chk_match0;
  input pwire [WIDTH-1:0] chk_addr1;
  output pwire chk_match1;
  output pwire free;

  pwire [BUF_COUNT-1:0] new_en_buf[1:0];
  pwire [BUF_COUNT*2-1:0] chk_match0_buf;
  pwire [BUF_COUNT*2-1:0] chk_match1_buf;
  pwire [BUF_COUNT-1:0] free_buf[1:0];
  pwire [BUF_COUNT-1:0] first[1:0];
  pwire freeA,freeB;
  
  generate
      genvar k;
      for (k=0;k<BUF_COUNT;k=k+1) begin : buffers_gen
          tbufcam_buf bufA_mod(
          clk,
          rst,
          except,
          except_thread,
          new_addr,
          new_thread,
          new_en_buf[0][k],
          chk_addr0,
          chk_match0_buf[k],
          chk_addr1,
          chk_match1_buf[k],
          free_buf[0][k]
          );
          
	  tbufcam_buf bufB_mod(
          clk,
          rst,
          except,
          except_thread,
          new_addr,
          new_thread,
          new_en_buf[1][k],
          chk_addr0,
          chk_match0_buf[k+BUF_COUNT],
          chk_addr1,
          chk_match1_buf[k+BUF_COUNT],
          free_buf[1][k]
          );
      end
  endgenerate
  
  assign chk_match0=|chk_match0_buf;
  assign chk_match1=|chk_match1_buf;
//  assign free=|free_buf;
  assign new_en_buf[0]=first[0] & {BUF_COUNT{new_en&~new_thread}};
  bit_find_first_bit #(BUF_COUNT) firstFreeA_mod(free_buf[0],first[0],freeA);
  assign new_en_buf[1]=first[1] & {BUF_COUNT{new_en&new_thread}};
  bit_find_first_bit #(BUF_COUNT) firstFreeB_mod(free_buf[1],first[1],freeB);

  assign free=new_thread ? freeB : freeA;
  
endmodule

