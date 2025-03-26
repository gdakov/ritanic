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

module fprnd(
  A,
  rbit,tail,
  rndbit,
  rmode,
  isDBL,
  isEXT,
  toDBL,
  toSNG,
  B);
//rnd first, then denormal handling
  input pwire [80:0] A;
  input pwire rbit;
  input pwire tail;
  input pwire rndbit;
  input pwire [2:0] rmode;
  input pwire isDBL;
  input pwire isEXT;
  input pwire toDBL;
  input pwire toSNG;
  output pwire [79:0] B;

  pwire [64:0] Ax;
  pwire do_rnd;
  pwire cout;

  assign Ax={A[63:53]&{11{isEXT}},A[52]|isDBL,A[51:0]};

  adder #(64) rnd_mod(Ax,rbit,res0,1'b0,do_rnd,cout);

  assign res0=~do_rnd ? Ax : 64'bz;
endmodule
