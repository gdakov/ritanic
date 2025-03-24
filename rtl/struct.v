/*
Copyright 2022-2024 Goran Dakov, D.O.B. 11 January 1983, lives in Bristol UK in 2024

Licensed under GPL v3 or commercial license.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

`timescale 10ps/1ps
`include "../config.v"

`define b3i


`define operation_width 13
`define fpu_op_width 12
`define rat_addr_width 5

`define phys_addr_width 44
`define reg_addr_width 9
`define fpu_width 82
`define alu_width 64
`define vint_width 64
`define rat_count 32
`define fpu_rat_count 48 
`define rrf_count `rat_count
`define rrf_addr_width `rat_addr_width
`define reg_small_count 32
`define reg_small_addr_width 5
`define rs_buf_count 32
`define rs_buf_count2 26
`define instr_width 32
`define extraconst_width 19
`define lsqRsNo_width 9
`define lsq_width 7
`define bob_count 64
`define bob_addr_width 6
`define addrcalc_queue_depth 16

`define except_width 15
`define except_status 1:0
`define except_setsFlags 2
`define except_flags 8:3
`define except_fperr 8:3
`define except_fpflags 12:9

`define except_readSuccess 9'b0

`define dcache1_addr_width 7
`define dcache1_addr_count 128
`define dcache1_data_width 36

`define dcache1_bank_count 32 
`define dcache1_way_count 8

`define dcache2_addr_width 10
`define dcache2_addr_count 1024
`define dcache2_data_width 39
`define dcache2_way_count 12

`define page_global 8
`define page_huge 7
`define page_semaphore 6
`define page_mtype 5:4
`define page_user 13
`define page_wr 12:9
`define page_na 3:0
`define page_ne 59
`define page_COW_ignored 58
`define page_rd_perm_ignored 63
`define page_wr_perm_ignored 62
`define page_acc_ignored 61
`define page_dirty_ignored 60

`define page16_addr0 39:0
`define page16_addr1 79:40
`define page16_perm_wr 95:80
`define page16_perm_ne 96
`define page16_perm_rd 127:112
`define page16_wc 97
`define page16_wt 98
`define page16_nc 99
`define page16_sys 100
`define page16_na 101
`define page16_dirty 102
`define page16_accessed 103
`define page16_global 104
`define page16_huge 105

`define bob_ipOff0_9 89:0
`define bob_j0GHT2 105:90
`define bob_j1GHT2 121:106
`define bob_j0Val 122
`define bob_j1Val 123
`define bob_j0cloop 124
`define bob_j1cloop 125
`define bob_reserved 129:126
`define bob_ret0_8 165:130
`define bob_jump0Type 170:166
`define bob_jump1Type 175:171
`define bob_jump0Pos 179:176
`define bob_jump1Pos 183:180
`define bob_jump0IP 226:184
`define bob_jump1IP 269:227
`define bob_afterTk 279:270
`define bob_pred 281:280
`define bob_regs 341:282
`define bob_rgen 351:342
`define bob_rvec 361:352
`define bob_magicO 391:362
`define bob_last 401:392
`define bob_Fsimd 411:402
`define bob_freeregs 456:412
`define bob_j0GHT 464:457
`define bob_j1GHT 472:465
`define bob_j0Ind 474:473
`define bob_j1Ind 476:475
`define bob_j0Way 477:477
`define bob_j1Way 478:478
`define bob_j0sc 480:479
`define bob_j1sc 482:481
`define bob_j0BtbOnly 483
`define bob_j1BtbOnly 484
`define bob_j0Miss 485
`define bob_j1Miss 486
`define bob_frr 495:487
`define bob_jump0Mask 499:496
`define bob_jump1Mask 503:500
`define bob_aspl 513:504
`define bob_attr 517:514
`define bob_attrJ0 521:518
`define bob_attrJ1 525:522
`define bob_freeregsS 570:526
`define bob_width 571

`define attr_um 0
`define attr_vm 1
`define attr_vec 2
`define attr_sec 3

`define bobJmp_satCount 1:0
`define bobJmp_hist 7:2
`define bobJmp_camIndex 14:8
`define bobJmp_freq 21:15
`define bobJmp_width 22

`define pbob_jump0Type 4:0
`define pbob_jump1Type 9:5
`define pbob_jump0Pos 13:10
`define pbob_jump1Pos 17:14
`define pbob_pred 19:18
`define pbob_j0Miss 20
`define pbob_j1Miss 21
`define pbob_indir 68:22
`define pbob_width 69

`define addrcalc_op_32bit 11
`define addrcalc_op_store 10

`define flags_width 6

`define jump_Z 0
`define jump_nZ 1
`define jump_S 2
`define jump_nS 3
`define jump_uGT 4
`define jump_uLE 5
`define jump_uGE 6
`define jump_uLT 7
`define jump_sGT 8
`define jump_sLE 9
`define jump_sGE 10
`define jump_sLT 11
`define jump_O 12
`define jump_nO 13
`define jump_P 14
`define jump_nP 15

`define btb_src_IP 28:0
`define btb_tgt_IP0 91:29
`define btb_tgt_IP1 154:92
`define btb_tgt_IP2 217:155
`define btb_tgt_IP3 280:218
`define btb_valid 281
`define btb_off0 285:282
`define btb_off1 289:286
`define btb_off2 293:290
`define btb_off3 297:294
`define btb_cond 301:298
`define btb_indir 305:302
`define btb_link0 310:306
`define btb_link1 315:311
`define btb_link2 320:316
`define btb_link3 325:321
`define btb_lnkoff0 330:326
`define btb_lnkoff1 335:331
`define btb_lnkoff2 340:336
`define btb_lnkoff3 345:341
`define btb_tgt_jmask0 349:346
`define btb_tgt_jmask1 353:350
`define btb_tgt_jmask2 357:354
`define btb_tgt_jmask3 361:358
`define btb_attr0 364:362
`define btb_attr1 367:365
`define btb_attr2 370:368
`define btb_attr3 373:371
`define btb_LRU 374
//lru needs to be kept at highest 2 bits

`define btb_width 375

`define btb_addr_width 8
`define btb_addr_count 256
//4 way odd-even bundle btbs 2x4x256=2048 entries

`define btbExtra_satCount0 1:0 
`define btbExtra_satCount1 3:2
`define btbExtra_satCount2 5:4
`define btbExtra_satCount3 7:6
`define btbExtra_freq0 14:8
`define btbExtra_freq1 21:15
`define btbExtra_freq2 28:22
`define btbExtra_freq3 35:29

`define btbExtra_width 36




`define brcam_buf_count 32

`define btb_hitory_width 6
`define btb_patternTable_width 64





//dirty & LRU bits in separate module
`define dc1Tag_addr_43_14 29:0
`define dc1Tag_valid 30
`define dc1Tag_exclusive 31
`define dc1Tag_recent 32
`define dc1Tag_parity 33

`define dc1Tag_width 34

`define cc1Tag_paddr 36:0
`define cc1Tag_valid 37
`define cc1Tag_parity 38

`define cc1Tag_width 39

//dirty & lru bits for l1
`define dc1Extra_exclusive 0
`define dc1Extra_dirty 1
`define dc1Extra_LRU 4:2
`define dc1Extra_valid 5 

`define dc1Extra_width 6

`define dc2Tag_addr_43_16 27:0
`define dc2Tag_valid 28
`define dc2Tag_exclusive 29
`define dc2Tag_ins_dirty 30
`define dc2Tag_parity 31

`define dc2Tag_width 32

`define iclass_indir 0
`define iclass_jump 1
`define iclass_ALU 2
`define iclass_shift 3
`define iclass_mul 4
`define iclass_load 5
`define iclass_store 6
`define iclass_store2 7
`define iclass_FPU 8
`define iclass_loadFPU 9
`define iclass_sys 10
`define iclass_flag 11
`define iclass_pos0 12
`define iclass_width 13

`define instrQ_magic 3:0
`define instrQ_srcIPOff 11:4
`define instrQ_btbMiss 12
`define instrQ_taken 13
`define instrQ_srcTick 14
`define instrQ_class 27:15
`define instrQ_btb_way 28
`define instrQ_jmp_ind 30:29
`define instrQ_ght_addr 38:31
`define instrQ_sc 40:39
`define instrQ_btb_only 41
`define instrQ_lastInstr 42
`define instrQ_ght2_addr 58:43
`define instrQ_jval 59
`define instrQ_nop 60
`define instrQ_attr 64:61
`define instrQ_width 65


`define instrQ_addr_count 36
`define instrQ_addr_width 6

`define instrQExtra_attr 3:0
`define instrQExtra_IP 66:4
`define instrQExtra_jmask 70:67
`define instrQExtra_cloop 71
`define instrQExtra_width 72



`define dmlbData_phys 39:0
`define dmlbData_user 40
`define dmlbData_wp 41
`define dmlbData_na 57:42
`define dmlbData_type 59:58
`define dmlbData_glo 60
`define dmlbData_semaphore_area 61
`define dmlbData_semaphore 61
`define dmlbData_subpage 62
`define dmlbData_ne 63
`define dmlbData_width 64


`define dmlb_vaddr 49:0
`define dmlb_valid 50
`define dmlb_shr   51
`define dmlb_data1 95:52
`define dmlb_data2 138:96
`define dmlb_data3 181:139
`define dmlb_width 182



`define cmlbData_phys 29:0
`define cmlbData_user 30
`define cmlbData_na 31
`define cmlbData_ne 32
`define cmlbData_global 33
`define cmlbData_width 34

`define cmlb_ip 64:0
`define cmlb_valid 65
`define cmlb_validN 66
`define cmlb_lru 68:67 
`define cmlb_data 103:69
`define cmlb_width 104



`define mOp_addrMain 43:0
`define mOp_sz 48:44
`define mOp_st 49
`define mOp_bank0 54:50
`define mOp_split 55
`define mOp_reg 64:56
`define mOp_LSQ 73:65
`define mOp_II 83:74
`define mOp_thread 84
`define mOp_lsflag 85
`define mOp_WQ 91:86
`define mOp_type 94:92
`define mOp_attr 98:95
`define mOp_width 99

`define mOpX_addrEven 35:0
`define mOpX_addrOdd 71:36
`define mOpX_sz 76:72
`define mOpX_st 77
`define mOpX_split 78
`define mOpX_odd 79
`define mOpX_low 81:80
`define mOpX_bank0 86:82
`define mOpX_regNo 95:87
`define mOpX_II 105:96
`define mOpX_WQ 111:106
`define mOpX_bread 116:112
`define mOpX_mtype 119:117
`define mOpX_pbit 121:120
`define mOpX_dummy 122
`define mOpX_width 123


`define mOpC_addrEven 35:0
`define mOpC_addrOdd 71:36
`define mOpC_banks 103:72
`define mOpC_begin 108:104
`define mOpC_end 113:109
`define mOpC_bben 117:114
`define mOpC_endben 121:118
`define mOpC_req 124:122
`define mOpC_odd 125
`define mOpC_split 126
`define mOpC_pbit 128:127
`define mOpC_d128 129
`define mOpC_width 130

`define mOp1_addrEven 35:0
`define mOp1_addrOdd 71:36
`define mOp1_sz 76:72
`define mOp1_st 77
`define mOp1_split 78
`define mOp1_odd 79
`define mOp1_low 81:80
`define mOp1_bank0 86:82
`define mOp1_clHit 88:87
`define mOp1_banks 120:89
`define mOp1_regNo 129:121
`define mOp1_LSQ 138:130
`define mOp1_II 148:139
`define mOp1_thr 149
`define mOp1_lsf 150
`define mOp1_WQ 158:151
`define mOp1_lsfwd 159
`define mOp1_type 162:160
`define mOp1_width 163

`define mOp2_addrMain 43:0
`define mOp2_sz 48:44
`define mOp2_bank0 53:49
`define mOp2_split 54
`define mOp2_LSQ 63:55
`define mOp2_II 73:64
`define mOp2_thread 74
`define mOp2_lsflag 75
`define mOp2_WQ 81:76
`define mOp2_banks 113:82
`define mOp2_odd 114
`define mOp2_addr_low 116:115
`define mOp2_type 119:117
`define mOp2_attr 123:120
`define mOp2_width 124

`define lsaddr_addrE 35:0
`define lsaddr_addrO 71:36
`define lsaddr_banks 103:72
`define lsaddr_OH 104
`define lsaddr_EH 105
`define lsaddr_EL 106
`define lsaddr_GOR 107
`define lsaddr_II 117:108
`define lsaddr_odd_round 118 
`define lsaddr_bank0 123:119
`define lsaddr_reg_hi 128:124
`define lsaddr_low 130:129
`define lsaddr_odd 131
`define lsaddr_split 132
`define lsaddr_st 133
`define lsaddr_sz 138:134
`define lsaddr_reg_low 142:139
`define lsaddr_flag 143
`define lsaddr_pconfl 144
`define lsaddr_except 145
`define lsaddr_mtype 148:146
`define lsaddr_WQ 154:149
`define lsaddr_blow 158:155
`define lsaddr_etype 162:159
`define lsaddr_width 163
`define lsaddr_II_low 111:108

`define lsqshare_wrt0 2:0
`define lsqshare_wrt1 5:3
`define lsqshare_wrt2 8:6
`define lsqshare_used 14:9
`define lsqshare_II 20:15
`define lsqshare_wrtII0 24:21
`define lsqshare_wrtII1 28:25
`define lsqshare_wrtII2 32:29
`define lsqshare_usedB 38:33
`define lsqshare_width 39

`define lsqpend_retire 5:0
`define lsqpend_ldconfl 11:6
`define lsqpend_smpconfl 17:12
`define lsqpend_pconfl 23:18
`define lsqpend_odd_round 24
`define lsqpend_odd_rnd_partial 25
`define lsqpend_width 26

`define lsqxcept_code 5:0
`define lsqxcept_xcept 6
`define lsqxcept_II 16:7
`define lsqxcept_smpdep 17
`define lsqxcept_odd_round 18

`define lsqxcept_width 19




`define lsfxdata_byBank 0
`define lsfxdata_Mexact 1
`define lsfxdata_banks 5:2
`define lsfxdata_Mshift 10:6
`define lsfxdata_has 11
`define lsfxdata_width 12

`define fpcfg_prec 1:0
`define fpcfg_rmod 4:2
`define fpcfg_maskI 10:5
`define fpcfg_hasI 16:11
//`define fpcfg_cflags 17:15
`define fpcfg_unused 31:17



`define rbus_used 0
`define rbus_second 1
`define rbus_bcast 2
`define rbus_mreq 3
`define rbus_creq 4
`define rbus_want_excl 5
`define rbus_code 6
`define rbus_dupl 7
`define rbus_ior 8
`define rbus_width 9

`define rbusM_used 0
`define rbusM_second 1
`define rbusM_bcast 2
`define rbusM_mem_reply 3
`define rbusM_cc_reply 4
`define rbusM_write_back 5
`define rbusM_excl 6
`define rbusM_dirty 7
`define rbusM_iorpl 8
`define rbusM_expun 9
`define rbusM_pook 10
`define rbusM_width 11


`define ttag_IP_upper 29:0
`define ttag_IP_lower 36:30
`define ttag_valid 37
`define ttag_br 43:38
`define ttag_width 44

`define ptype_int 0
`define ptype_ext 1
`define ptype_dbl 2
`define ptype_sngl 3


`define ptr_low 63:56
`define ptr_hi  55:49
`define ptr_exp 48:44
`define ptr_usrmode 43


