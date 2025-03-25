/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

//opcodes for reservation stations alus


//3-op basic instructions
`define op_add64 0
`define op_add32 1
`define op_add16 2
`define op_add8 3
`define op_cloop_even 46
`define op_cloop_odd  47

`define op_sub64 4
`define op_sub32 5
`define op_cmp16 6
`define op_cmp8  7 

`define op_and64 8
`define op_and32 9
`define op_and16 10
`define op_and8  11

`define op_or64 12
`define op_or32 13
`define op_or16 14
`define op_or8  15

`define op_xor64 16
`define op_xor32 17
`define op_nxor64 18
`define op_nxor32  19

`define op_shl64 20
`define op_shl32 21
`define op_shl16 22
`define op_shl8  23

`define op_shr64 24
`define op_shr32 25
`define op_shr16 26
`define op_shr8  27

`define op_sar64 28
`define op_sar32 29
`define op_sar16 30
`define op_sar8  31


//less basic 2-op and 1-op instructions
`define op_mov64 32
`define op_mov32 33
`define op_mov16 34
`define op_mov8 35

`define op_zxt8_64 36
`define op_zxt16_64 37
`define op_zxt8_16 38

`define op_sxt8_64 39
`define op_sxt16_64 40
`define op_sxt32_64 41

`define op_sxt8_32 42
`define op_sxt16_32 43
`define op_sxt8_16 44

`define op_inc8 45

`define op_cmov64 48
`define op_cmovn64 49

`define op_cmov32 50
`define op_cmovn32 51

`define op_clahf 52
`define op_clahfn 53

`define op_cset 54
`define op_csetn 55

`define op_sahf 56
`define op_lahf 57

`define op_enptr 58
`define op_unptr 59

`define op_sadd_even 60
`define op_sadd_odd 61

`define op_cax 62

//these are even more complicated instructions
`define op_multiclk 2048
`define op_nflagset 4096
`define op_tgt8 256
`define op_ra8 512
`define op_rb8 1024 

//`define op_mul8  (0|`op_multiclk)
`define op_mul32_64 (1|`op_multiclk)
`define op_mul32 (2|`op_multiclk)
`define op_mul64 (3|`op_multiclk)

//`define op_lmul8  (4|`op_multiclk)
`define op_limul64 (5|`op_multiclk)
//`define op_lmul32 (6|`op_multiclk)
`define op_lmul64 (7|`op_multiclk)
`define op_swp64  (6|`op_multiclk)
`define op_swp32  (4|`op_multiclk)

`define op_sec64  (8|`op_multiclk)
`define op_imul32_64 (9|`op_multiclk)
`define op_imul32 (10|`op_multiclk)
`define op_imul64 (11|`op_multiclk)

`define op_cvtE 12
`define op_cvtD 13
`define op_cvtS 14

`define op_dec (15|`op_multiclk)
`define op_gather (16|`op_multiclk)
