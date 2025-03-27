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
module ght2_ram(
    clk,
    read_addr,
    read_data,
    write_addr,
    write_data,
    write_bitEn,
    write_wen
    );

    localparam DATA_WIDTH=256;
    localparam ADDR_WIDTH=5;
    parameter ADDR_COUNT=32;

    input pwire clk;
    input pwire [ADDR_WIDTH-1:0] read_addr;
    output pwire [DATA_WIDTH-1:0] read_data;
    input pwire [ADDR_WIDTH-1:0] write_addr;
    input pwire [DATA_WIDTH-1:0] write_data;
    input pwire [DATA_WIDTH-1:0] write_bitEn;
    input pwire write_wen;

    pwire [DATA_WIDTH-1:0] ram [ADDR_COUNT-1:0];
    integer i;
    
    assign read_data=ram[read_addr];

    always @(posedge clk)
    begin
        if (write_wen) 
            for(i=0;i<DATA_WIDTH;i=i+1)
	        if (write_bitEn[i]) ram[write_addr][i]=write_data[i];
    end

endmodule


module ght3_bank(
    clk,
    rst,
    read_clkEn,
    fstall,
    except,
    exceptThr,
    IP_BITS,
    GHT_mispred,
    jumpMask,
    AbtbPred,
    BbtbPred,
    AotherPred0,
    AotherPred1,
    AotherPred2,
    AotherPred3,
    BotherPred0,
    BotherPred1,
    BotherPred2,
    BotherPred3,
    write_sc,
    write_addr,
    write_wen,
    init
    );
    parameter [2:0] INDEX=3'd0;
    
    input pwire clk;
    input pwire rst;
    input pwire read_clkEn;
    input pwire fstall;
    input pwire except;
    input pwire exceptThr;
    input pwire [15:0] IP_BITS;
    input pwire [15:0] GHT_mispred;
    input pwire [3:0] jumpMask;
    input pwire [3:0] AbtbPred;
    input pwire [3:0] BbtbPred;
    
    output pwire  AotherPred0;
    output pwire  AotherPred1;
    output pwire  AotherPred2;
    output pwire  AotherPred3;
    
    output pwire  BotherPred0;
    output pwire  BotherPred1;
    output pwire  BotherPred2;
    output pwire  BotherPred3;

    input pwire  write_val;
    input pwire [15:0] write_addr;
    input pwire write_wen;

    input pwire init;
   

    pwire read_clkEn_reg; 

    pwire [15:0] IP_BITS_reg;
    pwire [15:0] GHT_mispred_reg;
    
    pwire [15:0] read_addr;
    pwire [7:0] read1_addr[1:0];
    pwire [7:0] read2_addr[3:0];
    pwire [7:0] read3_addr[3:0];

    pwire otherPred0X;
    pwire otherPred1X;
    pwire otherPred2X;
    pwire otherPred3X;

    pwire otherPred0W;
    pwire otherPred1W;
    pwire otherPred2W;
    pwire otherPred3W;
    
    pwire [3:0] curJump;
    pwire [3:0] curJumpSh; //shifted by first jump
    
    pwire GHT0_sc;
    pwire GHT1_sc[1:0];
    pwire GHT2_sc[3:0];
    pwire GHT3_sc[3:0];
   
    pwire GHTx_sc0; 
    pwire GHTx_sc1; 
    pwire GHTx_sc2; 
    pwire GHTx_sc3; 
    pwire GHTx_sc;

    pwire GHTx_en;

    pwire upper0,upper1,upper2,upper3;

    pwire [7:0] GHTx_addr0;
    pwire [7:0] GHTx_addr1;
    pwire [7:0] GHTx_addr2;
    pwire [7:0] GHTx_addr3;
    pwire [7:0] GHTx_addr;
    pwire GHTx_upper0,GHTx_upper1,GHTx_upper2,GHTx_upper3;
 
    pwire [255:0] read_data;
    
    pwire [255:0] write_data;
//   pwire [511:0] write_dataW;
    pwire [255:0] write_bitEn;
    
    //wire [1:0] start;
    
    
 //   assign write_data=init ? 512'b0 : write_dataW;
    
    assign read_addr=IP_BITS_reg ^ {GHT_mispred};

  //  assign start[1]=pwh#(2)::cmpEQ(jumpMask[1:0],2'b00);
  //  assign start[0]=pwh#(2)::cmpEQ(jumpMask[1:0],2'b10) || pwh#(4)::cmpEQ(jumpMask,4'b1000);    

    assign curJump[0]=pwh#(2)::cmpEQ((read_addr[7:6] ^ INDEX[2:1]),2'd0) && read_addr[0]==INDEX[0];
    assign curJump[1]=pwh#(2)::cmpEQ((read_addr[7:6] ^ INDEX[2:1]),2'd1) && read_addr[0]==INDEX[0];
    assign curJump[2]=pwh#(2)::cmpEQ((read_addr[7:6] ^ INDEX[2:1]),2'd2) && read_addr[0]==INDEX[0];
    assign curJump[3]=pwh#(2)::cmpEQ((read_addr[7:6] ^ INDEX[2:1]),2'd3) && read_addr[0]==INDEX[0];
    
    assign otherPred0X=(curJump[0] & ~AbtbPred[0] & jumpMask[0]) ? GHT0_sc : 2'bz;
    assign otherPred0X=(curJump[0] & AbtbPred[0] || ~jumpMask[0]) ? (1'b0)&{jumpMask[0]} : 1'bz;
    
    assign otherPred1X=(curJump[1] & ~AbtbPred[1] && pwh#(2)::cmpEQ(jumpMask[1:0],2'b10)) ? GHT1_sc[1] : 1'bz;
    assign otherPred1X=(curJump[1] & ~AbtbPred[1] && pwh#(2)::cmpEQ(jumpMask[1:0],2'b11)) ? GHT1_sc[0] : 1'bz;
    assign otherPred1X=(curJump[1] & AbtbPred[1] || ~jumpMask[1]) ? (1'b0)&{jumpMask[1]} : 1'bz;
    
    assign otherPred2X=(curJump[2] & ~AbtbPred[2] && pwh#(3)::cmpEQ(jumpMask[2:0],3'b100)) ? GHT2_sc[2] : 1'bz;
    assign otherPred2X=(curJump[2] & ~AbtbPred[2] && pwh#(3)::cmpEQ(jumpMask[2:0],3'b110)) ? GHT2_sc[1] : 1'bz;
    assign otherPred2X=(curJump[2] & ~AbtbPred[2] && pwh#(3)::cmpEQ(jumpMask[2:0],3'b111)) ? GHT2_sc[0] : 1'bz;
    assign otherPred2X=(curJump[2] & AbtbPred[2] || ~jumpMask[2]) ? (1'b0)&{jumpMask[2]} : 1'bz;

    assign otherPred3X=(curJump[3] & ~AbtbPred[3] && pwh#(4)::cmpEQ(jumpMask[3:0],4'b1000)) ? GHT3_sc[3] : 1'bz;
    assign otherPred3X=(curJump[3] & ~AbtbPred[3] && pwh#(4)::cmpEQ(jumpMask[3:0],4'b1100)) ? GHT3_sc[2] : 1'bz;
    assign otherPred3X=(curJump[3] & ~AbtbPred[3] && pwh#(4)::cmpEQ(jumpMask[3:0],4'b1110)) ? GHT3_sc[1] : 1'bz;
    assign otherPred3X=(curJump[3] & ~AbtbPred[3] && pwh#(4)::cmpEQ(jumpMask[3:0],4'b1111)) ? GHT3_sc[0] : 1'bz;
    assign otherPred3X=(curJump[3] & AbtbPred[3]  || ~jumpMask[3]) ? (1'b0)&{jumpMask[3]} : 1'bz;

    assign AotherPred0=curJump[0] ?otherPred0X : 1'bz;
    assign AotherPred1=curJump[1] ?otherPred1X : 1'bz;
    assign AotherPred2=curJump[2] ?otherPred2X : 1'bz;
    assign AotherPred3=curJump[3] ?otherPred3X : 1'bz;
//b way
    assign otherPred0W=(curJump[0] & ~BbtbPred[0] & jumpMask[0]) ? GHT0_sc : 1'bz;
    assign otherPred0W=(curJump[0] & BbtbPred[0] || ~jumpMask[0]) ? (1'b0)&{jumpMask[0]} : 1'bz;
    
    assign otherPred1W=(curJump[1] & ~BbtbPred[1] && pwh#(2)::cmpEQ(jumpMask[1:0],2'b10)) ? GHT1_sc[1] : 1'bz;
    assign otherPred1W=(curJump[1] & ~BbtbPred[1] && pwh#(2)::cmpEQ(jumpMask[1:0],2'b11)) ? GHT1_sc[0] : 1'bz;
    assign otherPred1W=(curJump[1] & BbtbPred[1] || ~jumpMask[1]) ? (1'b0)&{jumpMask[1]} : 1'bz;
    
    assign otherPred2W=(curJump[2] & ~BbtbPred[2] && pwh#(3)::cmpEQ(jumpMask[2:0],3'b100)) ? GHT2_sc[2] : 1'bz;
    assign otherPred2W=(curJump[2] & ~BbtbPred[2] && pwh#(3)::cmpEQ(jumpMask[2:0],3'b110)) ? GHT2_sc[1] : 1'bz;
    assign otherPred2W=(curJump[2] & ~BbtbPred[2] && pwh#(3)::cmpEQ(jumpMask[2:0],3'b111)) ? GHT2_sc[0] : 1'bz;
    assign otherPred2W=(curJump[2] & BbtbPred[2] || ~jumpMask[2]) ? (1'b0)&{jumpMask[2]} : 1'bz;

    assign otherPred3W=(curJump[3] & ~BbtbPred[3] && pwh#(4)::cmpEQ(jumpMask[3:0],4'b1000)) ? GHT3_sc[3] : 1'bz;
    assign otherPred3W=(curJump[3] & ~BbtbPred[3] && pwh#(4)::cmpEQ(jumpMask[3:0],4'b1100)) ? GHT3_sc[2] : 1'bz;
    assign otherPred3W=(curJump[3] & ~BbtbPred[3] && pwh#(4)::cmpEQ(jumpMask[3:0],4'b1110)) ? GHT3_sc[1] : 1'bz;
    assign otherPred3W=(curJump[3] & ~BbtbPred[3] && pwh#(4)::cmpEQ(jumpMask[3:0],4'b1111)) ? GHT3_sc[0] : 1'bz;
    assign otherPred3W=(curJump[3] & BbtbPred[3]  || ~jumpMask[3]) ? (1'b0)&{jumpMask[3]} : 1'bz;
    
    assign BotherPred0=curJump[0] ?otherPred0W : 1'bz;
    assign BotherPred1=curJump[1] ?otherPred1W : 1'bz;
    assign BotherPred2=curJump[2] ?otherPred2W : 1'bz;
    assign BotherPred3=curJump[3] ?otherPred3W : 1'bz;

    assign GHT1_sc[1]=GHT0_sc;
    assign GHT2_sc[2]=GHT0_sc;
    assign GHT3_sc[3]=GHT0_sc;
    assign GHT2_sc[1]=GHT1_sc[0];
    assign GHT3_sc[2]=GHT1_sc[0];
    assign GHT3_sc[1]=GHT2_sc[0];
    assign GHT2_sc[3]=1'b0;

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
    assign GHTx_sc2=jumpMask[0] ? GHT2_sc[0] : 1'bz;
    assign GHTx_sc2=(pwh#(2)::cmpEQ(jumpMask[1:0],2'b10)) ? GHT2_sc[1] : 1'bz;
    assign GHTx_sc2=(!|jumpMask[1:0]) ? GHT2_sc[2] : 1'bz;
    assign GHTx_sc3=jumpMask[0] ? GHT3_sc[0] : 1'bz;
    assign GHTx_sc3=(pwh#(2)::cmpEQ(jumpMask[1:0],2'b10)) ? GHT3_sc[1] : 1'bz;
    assign GHTx_sc3=(pwh#(3)::cmpEQ(jumpMask[2:0],3'b100)) ? GHT3_sc[2] : 1'bz;
    assign GHTx_sc3=(!|jumpMask[2:0]) ? GHT3_sc[3] : 1'bz;

    assign GHTx_sc=curJump[0] ? GHTx_sc0 : 1'bz;
    assign GHTx_sc=curJump[1] ? GHTx_sc1 : 1'bz;
    assign GHTx_sc=curJump[2] ? GHTx_sc2 : 1'bz;
    assign GHTx_sc=curJump[3] ? GHTx_sc3 : 1'bz;
    assign GHTx_sc=curJump!=0 ? 1'bz : 1'b1;
    
    assign GHTx_addr0=read_addr[15:8];
    assign GHTx_addr1=jumpMask[0] ? read1_addr[0] : read1_addr[1];
    assign GHTx_addr2=jumpMask[0] ? read2_addr[0] : 8'bz;
    assign GHTx_addr2=(pwh#(2)::cmpEQ(jumpMask[1:0],2'b10)) ? read2_addr[1] : 8'bz;
    assign GHTx_addr2=(!|jumpMask[1:0]) ? read2_addr[2] : 8'bz;
    assign GHTx_addr3=jumpMask[0] ? read3_addr[0] : 8'bz;
    assign GHTx_addr3=(pwh#(2)::cmpEQ(jumpMask[1:0],2'b10)) ? read3_addr[1] : 8'bz;
    assign GHTx_addr3=(pwh#(3)::cmpEQ(jumpMask[2:0],3'b100)) ? read3_addr[2] : 8'bz;
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


    sel2_ght_entry sel_mod(read_data,read_addr[15:8],GHT0_sc);
    sel2_ght_entry sel1_mod(read_data,read1_addr[0],GHT1_sc[0]);
    sel2_ght_entry sel2_mod(read_data,read2_addr[0],GHT2_sc[0]);
    sel2_ght_entry sel3_mod(read_data,read3_addr[0],GHT3_sc[0]);
 
    
    ght_ram ram_mod(
    clk,
    read_addr[5:1],
    read_data,
    write_addr[5:1],
    write_data,
    write_bitEn,
    write_wen|init
    );
    
    generate
        genvar k;
        genvar j;
        for(j=0;j<256;j=j+1) begin : bitEn_gen
            pwire ae0;
            assign ae0=pwh#(32)::cmpEQ(j,write_addr[15:8]);
            
            assign write_bitEn[j]= ae0 || init;
            
            assign write_data[j]=write_val & {1{~init}};
        end
    endgenerate
   
    always @(posedge clk)
    begin
        if (rst) begin
            IP_BITS_reg<=16'b0;
            GHT_mispred_reg<=16'b0;
        end else if (read_clkEn) begin
            IP_BITS_reg<=IP_BITS;
            GHT_mispred_reg<=GHT_mispred;
        end
        if (rst) read_clkEn_reg<=1'b0;
        else if (~fstall) read_clkEn_reg<=read_clkEn;
    end
endmodule


module sel2_ght_entry(entry,addr,sc);
    input pwire [255:0] entry;
    input pwire [7:0] addr;
    output pwire [1:0] sc;
    
    pwire [1:0] sc1;

    generate
        genvar k,p;
        for (k=0;k<16;k=k+1) begin
            pwire sc0;
            for(p=0;p<16;p=p+1) begin
                assign sc0=( pwh#(4)::cmpEQ(p[3:0],addr[3:0])) ? entry[(k*16+p)] : 1'bz;
            end
            assign sc=(pwh#(4)::cmpEQ(k[3:0],addr[7:4])) ? sc0 : 1'bz;
        end
    endgenerate
endmodule



module ght2(
    clk,
    rst,
    read_clkEn,
    fstall,
    except,
    exceptThr,
    IP_BITS,
    GHT_mispred,
    jumpMask,
    AbtbPred,
    BbtbPred,
    AotherPred0,
    AotherPred1,
    AotherPred2,
    AotherPred3,
    BotherPred0,
    BotherPred1,
    BotherPred2,
    BotherPred3,
    write0_val,
    write0_addr,
    write0_wen,
    write1_val,
    write1_addr,
    write1_wen
    );
    
    input pwire clk;
    input pwire rst;
    input pwire read_clkEn;
    input pwire fstall;
    input pwire except;
    input pwire exceptThr;
    input pwire [15:0] IP_BITS;
    input pwire [15:0] GHT_mispred;
    input pwire [3:0] jumpMask;
    input pwire [3:0] AbtbPred;
    input pwire [3:0] BbtbPred;
    
    output pwire  AotherPred0;
    output pwire  AotherPred1;
    output pwire  AotherPred2;
    output pwire  AotherPred3;
    output pwire  BotherPred0;
    output pwire  BotherPred1;
    output pwire  BotherPred2;
    output pwire  BotherPred3;
    
//    output pwire [7:0] otherIndex0;
//    output pwire [7:0] otherIndex1;
//    output pwire [7:0] otherIndex2;
//    output pwire [7:0] otherIndex3;

    input pwire  write0_val;
    input pwire [15:0] write0_addr;
    input pwire write0_wen;

    input pwire  write1_val;
    input pwire [15:0] write1_addr;
    input pwire write1_wen;

    pwire [2:0] write0_way;
    pwire [2:0] write1_way;
    pwire [2:0] writeS_way;
    
    pwire  writeS_val;
    pwire [15:0] writeS_addr;
    pwire has_saved;
    pwire save0;
    pwire save1;
    
    pwire [7:0] write_val;
    pwire [7:0][15:0] write_addr;
    pwire [7:0]write_wen;

    pwire  otherPred0a;
    pwire  otherPred1a;
    pwire  otherPred2a;
    pwire  otherPred3a;
    
    pwire init;
    pwire [4:0] initCount;
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
            AotherPred0,
            AotherPred1,
            AotherPred2,
            AotherPred3,
            BotherPred0,
            BotherPred1,
            BotherPred2,
            BotherPred3,
            write_sc[k],
            write_addr[k],
            write_wen[k],
            init
            );
            assign write_addr[k]=(has_saved && pwh#(32)::cmpEQ(writeS_way,k) && ~init) ? writeS_addr : 16'bz;    
            assign write_addr[k]=(~has_saved && pwh#(32)::cmpEQ(write0_way,k) && write0_wen && ~init ) ? write0_addr : 16'bz;    
            assign write_addr[k]=(~has_saved && !(pwh#(32)::cmpEQ(write0_way,k)) && pwh#(32)::cmpEQ(write1_way,k) && write1_wen && ~init ) ? 
                write1_addr : 16'bz;
            assign write_addr[k]=init ? {10'b0,initCount,1'b0} : 16'bz;    

            assign write_val[k]=(has_saved && pwh#(32)::cmpEQ(writeS_way,k)) ? writeS_val : 1'bz;    
            assign write_val[k]=(~has_saved && pwh#(32)::cmpEQ(write0_way,k) && write0_wen) ? write0_val : 1'bz;    
            assign write_val[k]=(~has_saved && !(pwh#(32)::cmpEQ(write0_way,k)) && pwh#(32)::cmpEQ(write1_way,k) && write1_wen) ? 
                write1_val : 1'bz;    

            assign write_wen[k]=(has_saved && pwh#(32)::cmpEQ(writeS_way,k)) || (~has_saved && pwh#(32)::cmpEQ(write0_way,k) && write0_wen) ||
                (~has_saved && !(pwh#(32)::cmpEQ(write0_way,k)) && pwh#(32)::cmpEQ(write1_way,k) && write1_wen); 
                
            assign write_addr[k]=(write_wen[k]|init) ? 16'bz : 16'b0;
            assign write_val[k]=write_wen[k] ? 1'bz : 1'b0;
        end
    endgenerate

    assign save1=(~has_saved) ? write1_wen && pwh#(32)::cmpEQ(write0_way,write1_way)
      : write1_wen && write0_way!=writeS_way && (pwh#(32)::cmpEQ(write1_way,writeS_way) || pwh#(32)::cmpEQ(write1_way,write0_way));
    assign save0=has_saved && write0_wen && pwh#(32)::cmpEQ(write0_way,writeS_way);

    assign write0_way={write0_addr[7:6],write0_addr[0]};    
    assign write1_way={write1_addr[7:6],write1_addr[0]};    
    assign writeS_way={writeS_addr[7:6],writeS_addr[0]};    
    

    adder_inc #(5) initAdd_mod(initCount,initCount_d,1'b1,);
    
    always @(posedge clk) begin
        if (rst) begin
            has_saved<=1'b0;
            writeS_addr<=16'b0;
            writeS_val<=1'b0;
            init<=1'b1;
            initCount<=5'd0;
        end else begin
            if (save1) begin
                has_saved<=1'b1;
                writeS_addr<=write1_addr;
                writeS_val<=write1_val;
            end else if (save0) begin
                has_saved<=1'b1;
                writeS_addr<=write0_addr;
                writeS_val<=write0_val;
            end else begin
                has_saved<=1'b0;
                writeS_addr<=16'b0;
                writeS_val<=1'b0;
            end
            if (init) begin
                initCount<=initCount_d;
                if (pwh#(5)::cmpEQ(initCount,5'h1f)) init<=1'b0;
            end
        end
    end

endmodule

