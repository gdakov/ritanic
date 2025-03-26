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

//read-after-write behaviour: write first
module ght_ram(
    clk,
    read_addr,
    read_data,
    write_addr,
    write_data,
    write_bitEn,
    write_wen
    );

    localparam DATA_WIDTH=512;
    localparam ADDR_WIDTH=5;
    parameter ADDR_COUNT=32;

    input clk;
    input [ADDR_WIDTH-1:0] read_addr;
    output pwire [DATA_WIDTH-1:0] read_data;
    input [ADDR_WIDTH-1:0] write_addr;
    input [DATA_WIDTH-1:0] write_data;
    input [DATA_WIDTH-1:0] write_bitEn;
    input write_wen;

    reg [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
    integer i;
    
    assign read_data=ram[read_addr];

    always @(posedge clk)
    begin
        if (write_wen) 
            for(i=0;i<DATA_WIDTH;i=i+1)
	        if (write_bitEn[i]) ram[write_addr][i]=write_data[i];
    end

endmodule


module ght_bank(
    clk,
    rst,
    read_clkEn,
    fstall,
    except,
    exceptThr,
    IP_BITS,
    GHT,
    jumpMask,
    AbtbPred,
    BbtbPred,
    Abtb_sc0,
    Abtb_sc1,
    Abtb_sc2,
    Abtb_sc3,
    AotherPred0,
    AotherPred1,
    AotherPred2,
    AotherPred3,
    Bbtb_sc0,
    Bbtb_sc1,
    Bbtb_sc2,
    Bbtb_sc3,
    BotherPred0,
    BotherPred1,
    BotherPred2,
    BotherPred3,
//    otherIndex0,
//    otherIndex1,
//    otherIndex2,
//    otherIndex3,
    write_sc,
    write_addr,
    write_wen,
    init
    );
    parameter [2:0] INDEX=3'd0;
    
    input clk;
    input rst;
    input read_clkEn;
    input fstall;
    input except;
    input exceptThr;
    input [15:0] IP_BITS;
    input [7:0] GHT;
    input [3:0] jumpMask;
    input [3:0] AbtbPred;
    input [3:0] BbtbPred;
    
    input [1:0] Abtb_sc0;
    input [1:0] Abtb_sc1;
    input [1:0] Abtb_sc2;
    input [1:0] Abtb_sc3;
    
    output pwire [1:0] AotherPred0;
    output pwire [1:0] AotherPred1;
    output pwire [1:0] AotherPred2;
    output pwire [1:0] AotherPred3;
    
    input [1:0] Bbtb_sc0;
    input [1:0] Bbtb_sc1;
    input [1:0] Bbtb_sc2;
    input [1:0] Bbtb_sc3;
    
    output pwire [1:0] BotherPred0;
    output pwire [1:0] BotherPred1;
    output pwire [1:0] BotherPred2;
    output pwire [1:0] BotherPred3;
//    inout [7:0] otherIndex0;
//    inout [7:0] otherIndex1;
//    inout [7:0] otherIndex2;
//    inout [7:0] otherIndex3;

    input [1:0] write_sc;
    input [15:0] write_addr;
    input write_wen;

    input init;
   

    reg read_clkEn_reg; 

    reg [15:0] IP_BITS_reg;
    reg [7:0] GHT_reg;
    
    pwire [15:0] read_addr;
    pwire [7:0] read1_addr[1:0];
    pwire [7:0] read2_addr[3:0];
    pwire [7:0] read3_addr[3:0];

    pwire [1:0] otherPred0X;
    pwire [1:0] otherPred1X;
    pwire [1:0] otherPred2X;
    pwire [1:0] otherPred3X;

    pwire [1:0] otherPred0W;
    pwire [1:0] otherPred1W;
    pwire [1:0] otherPred2W;
    pwire [1:0] otherPred3W;
    
    pwire [3:0] curJump;
    pwire [3:0] curJumpSh; //shifted by first jump
    
    pwire [1:0] GHT0_sc;
    pwire [1:0] GHT1_sc[1:0];
    pwire [1:0] GHT2_sc[3:0];
    pwire [1:0] GHT3_sc[3:0];
   
    pwire [1:0] GHTx_sc0; 
    pwire [1:0] GHTx_sc1; 
    pwire [1:0] GHTx_sc2; 
    pwire [1:0] GHTx_sc3; 
    pwire [1:0] GHTx_sc;

    pwire GHTx_en;

    pwire upper0,upper1,upper2,upper3;

    pwire [7:0] GHTx_addr0;
    pwire [7:0] GHTx_addr1;
    pwire [7:0] GHTx_addr2;
    pwire [7:0] GHTx_addr3;
    pwire [7:0] GHTx_addr;
    pwire GHTx_upper0,GHTx_upper1,GHTx_upper2,GHTx_upper3;
 
    pwire [511:0] read_data;
    
    pwire [511:0] write_data;
//   pwire [511:0] write_dataW;
    pwire [511:0] write_bitEn;
    
    //wire [1:0] start;
    
    
 //   assign write_data=init ? 512'b0 : write_dataW;
    
    assign read_addr=IP_BITS_reg ^ {GHT,8'b0};

  //  assign start[1]=jumpMask[1:0]==2'b00;
  //  assign start[0]=jumpMask[1:0]==2'b10 || jumpMask==4'b1000;    

    assign curJump[0]=(read_addr[7:6] ^ INDEX[2:1])==2'd0 && read_addr[0]==INDEX[0];
    assign curJump[1]=(read_addr[7:6] ^ INDEX[2:1])==2'd1 && read_addr[0]==INDEX[0];
    assign curJump[2]=(read_addr[7:6] ^ INDEX[2:1])==2'd2 && read_addr[0]==INDEX[0];
    assign curJump[3]=(read_addr[7:6] ^ INDEX[2:1])==2'd3 && read_addr[0]==INDEX[0];
    
    assign otherPred0X=(curJump[0] & ~AbtbPred[0] & jumpMask[0]) ? GHT0_sc : 2'bz;
    assign otherPred0X=(curJump[0] & AbtbPred[0] || ~jumpMask[0]) ? (Abtb_sc0|{GHTx_upper0,1'b0})&{1'b1,jumpMask[0]} : 2'bz;
    
    assign otherPred1X=(curJump[1] & ~AbtbPred[1] && jumpMask[1:0]==2'b10) ? GHT1_sc[1] : 2'bz;
    assign otherPred1X=(curJump[1] & ~AbtbPred[1] && jumpMask[1:0]==2'b11) ? GHT1_sc[0] : 2'bz;
    assign otherPred1X=(curJump[1] & AbtbPred[1] || ~jumpMask[1]) ? (Abtb_sc1|{GHTx_upper1,1'b0})&{1'b1,jumpMask[1]} : 2'bz;
    
    assign otherPred2X=(curJump[2] & ~AbtbPred[2] && jumpMask[2:0]==3'b100) ? GHT2_sc[2] : 2'bz;
    assign otherPred2X=(curJump[2] & ~AbtbPred[2] && jumpMask[2:0]==3'b110) ? GHT2_sc[1] : 2'bz;
    assign otherPred2X=(curJump[2] & ~AbtbPred[2] && jumpMask[2:0]==3'b111) ? GHT2_sc[0] : 2'bz;
    assign otherPred2X=(curJump[2] & AbtbPred[2] || ~jumpMask[2]) ? (Abtb_sc2|{GHTx_upper2,1'b0})&{1'b1,jumpMask[2]} : 2'bz;

    assign otherPred3X=(curJump[3] & ~AbtbPred[3] && jumpMask[3:0]==4'b1000) ? GHT3_sc[3] : 2'bz;
    assign otherPred3X=(curJump[3] & ~AbtbPred[3] && jumpMask[3:0]==4'b1100) ? GHT3_sc[2] : 2'bz;
    assign otherPred3X=(curJump[3] & ~AbtbPred[3] && jumpMask[3:0]==4'b1110) ? GHT3_sc[1] : 2'bz;
    assign otherPred3X=(curJump[3] & ~AbtbPred[3] && jumpMask[3:0]==4'b1111) ? GHT3_sc[0] : 2'bz;
    assign otherPred3X=(curJump[3] & AbtbPred[3]  || ~jumpMask[3]) ? (Abtb_sc3|{GHTx_upper3,1'b0})&{1'b1,jumpMask[3]} : 2'bz;

    assign AotherPred0=curJump[0] ?otherPred0X : 2'bz;
    assign AotherPred1=curJump[1] ?otherPred1X : 2'bz;
    assign AotherPred2=curJump[2] ?otherPred2X : 2'bz;
    assign AotherPred3=curJump[3] ?otherPred3X : 2'bz;
//b way
    assign otherPred0W=(curJump[0] & ~BbtbPred[0] & jumpMask[0]) ? GHT0_sc : 2'bz;
    assign otherPred0W=(curJump[0] & BbtbPred[0] || ~jumpMask[0]) ? (Bbtb_sc0|{GHTx_upper0,1'b0})&{1'b1,jumpMask[0]} : 2'bz;
    
    assign otherPred1W=(curJump[1] & ~BbtbPred[1] && jumpMask[1:0]==2'b10) ? GHT1_sc[1] : 2'bz;
    assign otherPred1W=(curJump[1] & ~BbtbPred[1] && jumpMask[1:0]==2'b11) ? GHT1_sc[0] : 2'bz;
    assign otherPred1W=(curJump[1] & BbtbPred[1] || ~jumpMask[1]) ? (Bbtb_sc1|{GHTx_upper1,1'b0})&{1'b1,jumpMask[1]} : 2'bz;
    
    assign otherPred2W=(curJump[2] & ~BbtbPred[2] && jumpMask[2:0]==3'b100) ? GHT2_sc[2] : 2'bz;
    assign otherPred2W=(curJump[2] & ~BbtbPred[2] && jumpMask[2:0]==3'b110) ? GHT2_sc[1] : 2'bz;
    assign otherPred2W=(curJump[2] & ~BbtbPred[2] && jumpMask[2:0]==3'b111) ? GHT2_sc[0] : 2'bz;
    assign otherPred2W=(curJump[2] & BbtbPred[2] || ~jumpMask[2]) ? (Bbtb_sc2|{GHTx_upper2,1'b0})&{1'b1,jumpMask[2]} : 2'bz;

    assign otherPred3W=(curJump[3] & ~BbtbPred[3] && jumpMask[3:0]==4'b1000) ? GHT3_sc[3] : 2'bz;
    assign otherPred3W=(curJump[3] & ~BbtbPred[3] && jumpMask[3:0]==4'b1100) ? GHT3_sc[2] : 2'bz;
    assign otherPred3W=(curJump[3] & ~BbtbPred[3] && jumpMask[3:0]==4'b1110) ? GHT3_sc[1] : 2'bz;
    assign otherPred3W=(curJump[3] & ~BbtbPred[3] && jumpMask[3:0]==4'b1111) ? GHT3_sc[0] : 2'bz;
    assign otherPred3W=(curJump[3] & BbtbPred[3]  || ~jumpMask[3]) ? (Bbtb_sc3|{GHTx_upper3,1'b0})&{1'b1,jumpMask[3]} : 2'bz;
    
    assign BotherPred0=curJump[0] ?otherPred0W : 2'bz;
    assign BotherPred1=curJump[1] ?otherPred1W : 2'bz;
    assign BotherPred2=curJump[2] ?otherPred2W : 2'bz;
    assign BotherPred3=curJump[3] ?otherPred3W : 2'bz;

    assign GHT1_sc[1]=GHT0_sc;
    assign GHT2_sc[2]=GHT0_sc;
    assign GHT3_sc[3]=GHT0_sc;
    assign GHT2_sc[1]=GHT1_sc[0];
    assign GHT3_sc[2]=GHT1_sc[0];
    assign GHT3_sc[1]=GHT2_sc[0];
    assign GHT2_sc[3]=2'b0;

    assign read1_addr[0]={GHT[6:0],1'b0}^IP_BITS_reg[15:8];
    assign read2_addr[0]={GHT[5:0],2'b0}^IP_BITS_reg[15:8];
    assign read3_addr[0]={GHT[4:0],3'b0}^IP_BITS_reg[15:8];

    assign read1_addr[1]=read_addr[15:8];
    assign read2_addr[2]=read_addr[15:8];
    assign read3_addr[3]=read_addr[15:8];
    assign read2_addr[1]=read1_addr[0];
    assign read3_addr[2]=read1_addr[0];
    assign read3_addr[1]=read2_addr[0];
    assign read2_addr[3]=8'b0;

    assign GHTx_sc0=GHT0_sc;
    assign GHTx_sc1=jumpMask[0] ? GHT1_sc[0] : GHT1_sc[1];
    assign GHTx_sc2=jumpMask[0] ? GHT2_sc[0] : 2'bz;
    assign GHTx_sc2=(jumpMask[1:0]==2'b10) ? GHT2_sc[1] : 2'bz;
    assign GHTx_sc2=(!|jumpMask[1:0]) ? GHT2_sc[2] : 2'bz;
    assign GHTx_sc3=jumpMask[0] ? GHT3_sc[0] : 2'bz;
    assign GHTx_sc3=(jumpMask[1:0]==2'b10) ? GHT3_sc[1] : 2'bz;
    assign GHTx_sc3=(jumpMask[2:0]==3'b100) ? GHT3_sc[2] : 2'bz;
    assign GHTx_sc3=(!|jumpMask[2:0]) ? GHT3_sc[3] : 2'bz;

    assign GHTx_sc=curJump[0] ? GHTx_sc0 : 2'bz;
    assign GHTx_sc=curJump[1] ? GHTx_sc1 : 2'bz;
    assign GHTx_sc=curJump[2] ? GHTx_sc2 : 2'bz;
    assign GHTx_sc=curJump[3] ? GHTx_sc3 : 2'bz;
    assign GHTx_sc=curJump!=0 ? 2'bz : 2'b11;
    
    assign GHTx_addr0=read_addr[15:8];
    assign GHTx_addr1=jumpMask[0] ? read1_addr[0] : read1_addr[1];
    assign GHTx_addr2=jumpMask[0] ? read2_addr[0] : 8'bz;
    assign GHTx_addr2=(jumpMask[1:0]==2'b10) ? read2_addr[1] : 8'bz;
    assign GHTx_addr2=(!|jumpMask[1:0]) ? read2_addr[2] : 8'bz;
    assign GHTx_addr3=jumpMask[0] ? read3_addr[0] : 8'bz;
    assign GHTx_addr3=(jumpMask[1:0]==2'b10) ? read3_addr[1] : 8'bz;
    assign GHTx_addr3=(jumpMask[2:0]==3'b100) ? read3_addr[2] : 8'bz;
    assign GHTx_addr3=(!|jumpMask[2:0]) ? read3_addr[3] : 8'bz;

    assign GHTx_addr=curJump[0] ? GHTx_addr0 : 8'bz;
    assign GHTx_addr=curJump[1] ? GHTx_addr1 : 8'bz;
    assign GHTx_addr=curJump[2] ? GHTx_addr2 : 8'bz;
    assign GHTx_addr=curJump[3] ? GHTx_addr3 : 8'bz;
    assign GHTx_addr=curJump!=0 ? 8'bz : 8'b0;

    assign GHTx_en=curJump[0] ? jumpMask[0] : 1'bz;
    assign GHTx_en=curJump[1] ? (|jumpMask[1:0]) & jumpMask[1] : 1'bz;
    assign GHTx_en=curJump[2] ? (|jumpMask[2:0]) & jumpMask[2] : 1'bz;
    assign GHTx_en=curJump[3] ? (|jumpMask[3:0]) & jumpMask[3] : 1'bz;
    assign GHTx_en=curJump!=0 ? 1'bz : 1'b0;

    assign GHTx_upper0=upper0;
    assign GHTx_upper1=jumpMask[0] ? upper1 : upper0;
    assign GHTx_upper2=jumpMask[0] ? upper2 : 1'bz;
    assign GHTx_upper2=(jumpMask[1:0]==2'b10) ? upper1 : 1'bz;
    assign GHTx_upper2=(!|jumpMask[1:0]) ? upper0 : 1'bz;
    assign GHTx_upper3=jumpMask[0] ? upper3 : 1'bz;
    assign GHTx_upper3=(jumpMask[1:0]==2'b10) ? upper2 : 1'bz;
    assign GHTx_upper3=(jumpMask[2:0]==3'b100) ? upper1 : 1'bz;
    assign GHTx_upper3=(!|jumpMask[2:0]) ? upper0 : 1'bz;

    sel_ght_entry sel_mod(read_data,read_addr[15:8],upper0,GHT0_sc);
    sel_ght_entry sel1_mod(read_data,read1_addr[0],upper1,GHT1_sc[0]);
    sel_ght_entry sel2_mod(read_data,read2_addr[0],upper2,GHT2_sc[0]);
    sel_ght_entry sel3_mod(read_data,read3_addr[0],upper3,GHT3_sc[0]);
 
    
    ght_ram ram_mod(
    clk,
    read_addr[5:1],
    read_data,
    write_addr[5:1],
    write_data,
    write_bitEn,
    write_wen|init
    );
    
  ght_cam cam_mod(
  .clk(clk),
  .rst(rst),
  .read_clkEn(1'b1),
  .read_addr0({read_addr[5:1],read_addr[15:8]}),
  .read_hit0(upper0),
  .read_addr1({read_addr[5:1],read1_addr[0]}),
  .read_hit1(upper1),
  .read_addr2({read_addr[5:1],read2_addr[0]}),
  .read_hit2(upper2),
  .read_addr3({read_addr[5:1],read3_addr[0]}),
  .read_hit3(upper3),
  .write_addr({read_addr[5:1],GHTx_addr}),
  .write_wen(GHTx_en & read_clkEn_reg & ~fstall),
  .write_thread(1'b0),
  .except(except),
  .except_thread(exceptThr)
  );
    generate
        genvar k;
        genvar j;
        for(j=0;j<256;j=j+1) begin : bitEn_gen
            pwire ae0;
            assign ae0=j==write_addr[15:8];
            
            assign write_bitEn[j*2]= ae0 || init;
            assign write_bitEn[j*2+1]=write_bitEn[j*2];
            
            assign write_data[j*2+:2]=write_sc & {2{~init}};
        end
    endgenerate
   
    always @(posedge clk)
    begin
        if (rst) begin
            IP_BITS_reg<=16'b0;
            GHT_reg<=8'b0;
        end else if (read_clkEn) begin
            IP_BITS_reg<=IP_BITS;
            GHT_reg<=GHT;
        end
        if (rst) read_clkEn_reg<=1'b0;
        else if (~fstall) read_clkEn_reg<=read_clkEn;
    end
endmodule


module sel_ght_entry(entry,addr,update,sc);
    input [511:0] entry;
    input [7:0] addr;
    input update;
    output pwire [1:0] sc;
    
    pwire [1:0] sc1;

    assign sc=sc1|{update,1'b0};
    generate
        genvar k,p;
        for (k=0;k<16;k=k+1) begin
            pwire [1:0] sc0;
            for(p=0;p<16;p=p+1) begin
                assign sc0=( p[3:0]==addr[3:0]) ? entry[2*(k*16+p)+:2] : 2'bz;
            end
            assign sc1=(k[3:0]==addr[7:4]) ? sc0 : 2'bz;
        end
    endgenerate
endmodule



module ght(
    clk,
    rst,
    read_clkEn,
    fstall,
    except,
    exceptThr,
    IP_BITS,
    GHT,
    jumpMask,
    AbtbPred,
    BbtbPred,
    Abtb_sc0,
    Abtb_sc1,
    Abtb_sc2,
    Abtb_sc3,
    Bbtb_sc0,
    Bbtb_sc1,
    Bbtb_sc2,
    Bbtb_sc3,
    AotherPred0,
    AotherPred1,
    AotherPred2,
    AotherPred3,
    BotherPred0,
    BotherPred1,
    BotherPred2,
    BotherPred3,
//    otherIndex0,
//    otherIndex1,
//    otherIndex2,
//    otherIndex3,
    write0_sc,
    write0_addr,
    write0_wen,
    write1_sc,
    write1_addr,
    write1_wen
    );
    
    input clk;
    input rst;
    input read_clkEn;
    input fstall;
    input except;
    input exceptThr;
    input [15:0] IP_BITS;
    input [7:0] GHT;
    input [3:0] jumpMask;
    input [3:0] AbtbPred;
    input [3:0] BbtbPred;
    
    input [1:0] Abtb_sc0;
    input [1:0] Abtb_sc1;
    input [1:0] Abtb_sc2;
    input [1:0] Abtb_sc3;
    
    input [1:0] Bbtb_sc0;
    input [1:0] Bbtb_sc1;
    input [1:0] Bbtb_sc2;
    input [1:0] Bbtb_sc3;

    output pwire [1:0] AotherPred0;
    output pwire [1:0] AotherPred1;
    output pwire [1:0] AotherPred2;
    output pwire [1:0] AotherPred3;
    output pwire [1:0] BotherPred0;
    output pwire [1:0] BotherPred1;
    output pwire [1:0] BotherPred2;
    output pwire [1:0] BotherPred3;
    
//    output pwire [7:0] otherIndex0;
//    output pwire [7:0] otherIndex1;
//    output pwire [7:0] otherIndex2;
//    output pwire [7:0] otherIndex3;

    input [1:0] write0_sc;
    input [15:0] write0_addr;
    input write0_wen;

    input [1:0] write1_sc;
    input [15:0] write1_addr;
    input write1_wen;

    pwire [2:0] write0_way;
    pwire [2:0] write1_way;
    pwire [2:0] writeS_way;
    
    reg [1:0] writeS_sc;
    reg [15:0] writeS_addr;
    reg has_saved;
    pwire save0;
    pwire save1;
    
    pwire [7:0][1:0] write_sc;
    pwire [7:0][15:0] write_addr;
    pwire [7:0]write_wen;

    pwire [1:0] otherPred0a;
    pwire [1:0] otherPred1a;
    pwire [1:0] otherPred2a;
    pwire [1:0] otherPred3a;
    
    reg init;
    reg [4:0] initCount;
    pwire [4:0] initCount_d;

    generate
        genvar k;
        for(k=0;k<8;k=k+1) begin : ways_gen
            ght_bank #(k) way_mod(
            clk,
            rst,
            read_clkEn,
            fstall,
            except,
            exceptThr,
            IP_BITS,
            GHT,
            jumpMask,
            AbtbPred,
            BbtbPred,
            Abtb_sc0,
            Abtb_sc1,
            Abtb_sc2,
            Abtb_sc3,
            AotherPred0,
            AotherPred1,
            AotherPred2,
            AotherPred3,
            Bbtb_sc0,
            Bbtb_sc1,
            Bbtb_sc2,
            Bbtb_sc3,
            BotherPred0,
            BotherPred1,
            BotherPred2,
            BotherPred3,
//            otherIndex0,
//            otherIndex1,
//            otherIndex2,
//            otherIndex3,
            write_sc[k],
            write_addr[k],
            write_wen[k],
            init
            );
            assign write_addr[k]=(has_saved && writeS_way==k && ~init) ? writeS_addr : 16'bz;    
            assign write_addr[k]=(~has_saved && write0_way==k && write0_wen && ~init ) ? write0_addr : 16'bz;    
            assign write_addr[k]=(~has_saved && !(write0_way==k) && write1_way==k && write1_wen && ~init ) ? 
                write1_addr : 16'bz;
            assign write_addr[k]=init ? {10'b0,initCount,1'b0} : 16'bz;    

            assign write_sc[k]=(has_saved && writeS_way==k) ? writeS_sc : 2'bz;    
            assign write_sc[k]=(~has_saved && write0_way==k && write0_wen) ? write0_sc : 2'bz;    
            assign write_sc[k]=(~has_saved && !(write0_way==k) && write1_way==k && write1_wen) ? 
                write1_sc : 2'bz;    

            assign write_wen[k]=(has_saved && writeS_way==k) || (~has_saved && write0_way==k && write0_wen) ||
                (~has_saved && !(write0_way==k) && write1_way==k && write1_wen); 
                
            assign write_addr[k]=(write_wen[k]|init) ? 16'bz : 16'b0;
            assign write_sc[k]=write_wen[k] ? 2'bz : 2'b0;
        end
    endgenerate

    assign save1=(~has_saved) ? write1_wen && write0_way==write1_way
      : write1_wen && write0_way!=writeS_way && (write1_way==writeS_way || write1_way==write0_way);
    assign save0=has_saved && write0_wen && write0_way==writeS_way;

    assign write0_way={write0_addr[7:6],write0_addr[0]};    
    assign write1_way={write1_addr[7:6],write1_addr[0]};    
    assign writeS_way={writeS_addr[7:6],writeS_addr[0]};    
    

    adder_inc #(5) initAdd_mod(initCount,initCount_d,1'b1,);
    
    always @(posedge clk) begin
        if (rst) begin
            has_saved<=1'b0;
            writeS_addr<=16'b0;
            writeS_sc<=2'b0;
            init<=1'b1;
            initCount<=5'd0;
        end else begin
            if (save1) begin
                has_saved<=1'b1;
                writeS_addr<=write1_addr;
                writeS_sc<=write1_sc;
            end else if (save0) begin
                has_saved<=1'b1;
                writeS_addr<=write0_addr;
                writeS_sc<=write0_sc;
            end else begin
                has_saved<=1'b0;
                writeS_addr<=16'b0;
                writeS_sc<=2'b0;
            end
            if (init) begin
                initCount<=initCount_d;
                if (initCount==5'h1f) init<=1'b0;
            end
        end
    end

endmodule

