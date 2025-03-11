/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

`define fop_addDLZ 0
`define fop_addDH  1
`define fop_addDL  2
`define fop_addDP  3
`define fop_subDLZ 4
`define fop_subDH  5
`define fop_subDL  6
`define fop_subDP  7
`define fop_rsubDLZ 8
`define fop_rsubDH  9
`define fop_rsubDL  10
`define fop_rsubDP  11
`define fop_addsubDP 12
`define fop_addrsubDP 13
`define fop_unk_14    14
`define fop_unk_15    15
`define fop_addE 16
`define fop_addEE 17
`define fop_addED 18
`define fop_addES 19
`define fop_subE 20
`define fop_subEE 21
`define fop_subED 22
`define fop_subES 23
`define fop_addS 32
`define fop_addSP 33
`define fop_subS 34
`define fop_subSP 35
`define fop_cmpDH 32
`define fop_cmpDL 33
`define fop_cmpE 34
`define fop_cmpS 35
`define fop_pcmplt 36
`define fop_pcmpge 37
`define fop_pcmpeq 38
`define fop_pcmpne 39
`define fop_logic 40
`define fop_and 40
`define fop_or 41
`define fop_xor 42
`define fop_andn 43
`define fop_linsrch 44
//4 entries for linsrch

`define fop_mulDLZ 0
`define fop_mulDH  1
`define fop_mulDL  2
`define fop_mulDP  3
`define fop_mulE   4
`define fop_mulES 5
`define fop_mulED 6
`define fop_mulEE 7
`define fop_mulS 32
`define fop_mulSP 33
`define fop_permDS 45 
`define fop_rndES 32
`define fop_rndED 33
`define fop_rndDSP 34

`define fop_sqrtDH 0
`define fop_sqrtDL 1
`define fop_divDH 2
`define fop_divDL 3
`define fop_sqrtE 4
`define fop_sqrtS 34
`define fop_divE 6
`define fop_divS 35

`define fop_cvtD 8
`define fop_cvt32D 9
`define fop_cvtS 36
`define fop_cvt32S 37
`define fop_cvtE   12
`define fop_tblD   13

`define fop_pcvtD 48
`define fop_pcvtS 49
