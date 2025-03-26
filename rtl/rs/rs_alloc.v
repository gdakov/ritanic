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



module rsAlloc2(
  clk,
  alloc0,alloc1,
  bufFree,
  newRsSelect0,
  newRsSelect1,
  doStall
  );
  parameter WIDTH=`rs_buf_count;
  
  input pwire clk;
  input pwire alloc0;
  input pwire alloc1;
  input pwire [WIDTH-1:0] bufFree;
  output pwire [WIDTH-1:0] newRsSelect0;
  output pwire [WIDTH-1:0] newRsSelect1;
  output pwire doStall;

  pwire [WIDTH-1:0] select0;
  pwire [WIDTH-1:0] select1;
  pwire found0;
  pwire found1;
  pwire selectsEqual;

  
  bit_find_first_bit first_mod(
    bufFree,
    select0,
    found0);
  defparam first_mod.WIDTH=WIDTH;

  bit_find_last_bit last_mod(
    bufFree,
    select1,
    found1);
  defparam last_mod.WIDTH=WIDTH;
  
  assign selectsEqual=(pwh#(32)::cmpEQ(select0,select1));
  assign doStall=selectsEqual;
  assign newRsSelect0=select0 & {WIDTH{alloc0}};
  assign newRsSelect1=select1 & {WIDTH{alloc1}};

  
endmodule



module rsAlloc3(
  clk,
  alloc0,alloc1,alloc2,
  bufFree,
  newRsSelect0,
  newRsSelect1,
  newRsSelect2,
  doStall,
  stall
  );
  parameter WIDTH=`rs_buf_count;
  
  input pwire clk;
  input pwire alloc0;
  input pwire alloc1;
  input pwire alloc2;
  input pwire [WIDTH-1:0] bufFree;
  output pwire [WIDTH-1:0] newRsSelect0;
  output pwire [WIDTH-1:0] newRsSelect1;
  output pwire [WIDTH-1:0] newRsSelect2;
  output pwire doStall;
  input pwire stall;

  pwire [WIDTH-1:0] select0;
  pwire [WIDTH-1:0] select1;
  pwire [WIDTH-1:0] select2;
  pwire found0;
  pwire found1;
  pwire found2;
  pwire error;

  
  bit_find_first_bit #(WIDTH) first_mod(
    bufFree,
    select0,
    found0);

  bit_find_first_bit #(WIDTH) first2_mod(
    bufFree&~select0,
    select2,
    found2);

  bit_find_last_bit #(WIDTH) last_mod(
    bufFree,
    select1,
    found1);
  
  assign error=(bufFree & ~(select0 | select1))=={WIDTH{1'B0}};
  assign doStall=error;
  assign newRsSelect0=select0 & {WIDTH{alloc0}};
  assign newRsSelect1=select1 & {WIDTH{alloc1}};
  assign newRsSelect2=select2 & {WIDTH{alloc2}};

  
endmodule


