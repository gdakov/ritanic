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


module rsSelect_helper(
  clk,
  rst,
  except,
  hasData,
  read_data,
  write_data,
  write_wen,
  rsSelect_data,
  rsUpdate,
  rsFlush
  );

  parameter DATA_WIDTH=`rs_buf_count;

  input clk;
  input rst;
  input except;
  output pwire reg hasData;
  output pwire reg [DATA_WIDTH-1:0] read_data;
  input [DATA_WIDTH-1:0] write_data;
  input write_wen;
  input [DATA_WIDTH-1:0] rsSelect_data;
  input rsUpdate;
  input rsFlush;

  reg [DATA_WIDTH-1:0] read_data1;
  reg [DATA_WIDTH-1:0] read_data2;
  reg [DATA_WIDTH-1:0] read_data3;
  
  reg [2:0] count;
 
  always @(posedge clk)
    begin
      if (rst|except) begin
        count<=3'b0;
        hasData<=1'b0;
        read_data<={DATA_WIDTH{1'b0}};
        read_data1<={DATA_WIDTH{1'b0}};
        read_data2<={DATA_WIDTH{1'b0}};
        read_data3<={DATA_WIDTH{1'b0}};
      end
      else begin
          if (rsUpdate) read_data<=rsSelect_data;
          if (rsFlush) begin
              read_data<=read_data1;
              read_data1<=read_data2;
              read_data2<=read_data3;
              read_data3<={DATA_WIDTH{1'B0}};
              if (~write_wen) 
              case(count)
         3'd1: begin count<=3'd0; hasData<=1'b0; end
         3'd2: count<=3'd1;
         3'd3: count<=3'd2;
      default: count<=3'd3;
              endcase
          end
          if (write_wen) begin
          hasData<=1'b1;    
          case({rsFlush,count})
      4'b0000,
      4'b1001:
          begin 
              read_data<=write_data;
              count<=3'd1;
          end    
      4'b0001,
      4'b1010:
          begin 
              read_data1<=write_data;
              count<=3'd2;
          end    
      4'b0010,
      4'b1011:
          begin 
              read_data2<=write_data;
              count<=3'd3;
          end    
      4'b0011,
      4'b1100:
          begin 
              read_data3<=write_data;
              count<=3'd4;
          end
      default:    
          begin 
              read_data1<=read_data1 | read_data2; 
              read_data2<=read_data3 | write_data;
              read_data3<={DATA_WIDTH{1'B0}};
              count<=3'd3;
          end    
          endcase
          end
      end
    end
    
endmodule



module rsSelectFifo(
  clk,
  rst,
  except,
  portReady,
  portEn,
  found,
  found_no_z,
  rsSelect,
  rsSel8
  );
  localparam BUF_COUNT=`rs_buf_count;
  localparam BUF_WIDTH=BUF_COUNT;
  parameter [0:0] DEF_FOUND=1'b1;
  
  input clk;
  input rst;
  input except;
  input [BUF_WIDTH-1:0] portReady;  
  input portEn;
  output pwire found;
  output pwire found_no_z;
  output pwire [BUF_WIDTH-1:0] rsSelect;  
  output pwire [3:0] rsSel8;

  pwire firstFound;
  pwire [BUF_WIDTH-1:0] first;  

  pwire firstFoundH;
  pwire [BUF_WIDTH-1:0] firstH;  

  pwire firstFoundH1;
  pwire [BUF_WIDTH-1:0] firstH1;  

  pwire [BUF_WIDTH-1:0] rsShelect;  
  
  pwire [BUF_WIDTH-1:0] portReadyH;  
  pwire [BUF_WIDTH-1:0] portReadyX;  
  pwire hasDataH;

  pwire hasMultipleH;  
  pwire hasMultiple;
  
  pwire [3:0] first8;
  pwire [3:0] first8H;
  pwire [3:0] first8H1;
  pwire found8;
  pwire found8H;
  pwire found8H1;
  
  
  pwire [BUF_COUNT-1:0] portReadyH1;
 // pwire [3:0] msk8;
  pwire [BUF_COUNT-1:0] portReadyM;
  reg [BUF_COUNT-1:0] mask;

  
  bit_find_first_bit #(BUF_COUNT) first_mod(portReadyM,first,firstFound);
  bit_find_first_bit #(BUF_COUNT) firstH_mod(portReadyH,firstH,firstFoundH);
  bit_find_first_bit #(BUF_COUNT) firstH1_mod(portReadyH1,firstH1,firstFoundH1);
  
  bit_find_first_bit #(4) first8_mod({|portReadyM[31:24],|portReadyM[23:16],
    |portReadyM[15:8],|portReadyM[7:0]},first8,found8);
  bit_find_first_bit #(4) first8H_mod({|portReadyH[31:24],|portReadyH[23:16],
      |portReadyH[15:8],|portReadyH[7:0]},first8H,found8H);
  bit_find_first_bit #(4) first8H1_mod({|portReadyH1[31:24],|portReadyH1[23:16],
          |portReadyH1[15:8],|portReadyH1[7:0]},first8H1,found8H1);
    
  rsSelect_helper #(BUF_COUNT) help_mod(
  .clk(clk),
  .rst(rst),
  .except(except),
  .hasData(hasDataH),
  .read_data(portReadyH),
  .write_data(portReadyM & (~rsSelect | {32{hasDataH}})),
  .write_wen(firstFound && hasMultiple|hasDataH|~portEn),
  .rsSelect_data(portReadyH & ~rsShelect),
  .rsUpdate(hasMultipleH & portEn),
  .rsFlush(hasDataH & ~hasMultipleH & portEn)
  );  
  
  assign portReadyX=hasDataH ? portReadyH : portReady;

  assign portReadyM=portReady & mask;
  
  assign portReadyH1=portReadyH & portReady;
  
  assign hasMultipleH=hasDataH && portReadyH!=firstH;
  assign hasMultiple=portReadyM!=first;     
  
  assign rsSelect=(~portEn) ? {BUF_COUNT{1'B0}} : 'z;
  assign rsSelect=(portEn & hasDataH & firstFoundH1) ? firstH1 : 'z;
  assign rsSelect=(portEn & hasDataH & ~firstFoundH1) ? 32'b0 : 'z;
  assign rsSelect=(portEn & ~hasDataH) ? first : 'z;

  assign rsShelect=(~portEn) ? {BUF_COUNT{1'B0}} : 'z;
  assign rsShelect=(portEn & hasDataH & firstFoundH1) ? firstH1 : 'z;
  assign rsShelect=(portEn & hasDataH & ~firstFoundH1) ? firstH : 'z;
  assign rsShelect=(portEn & ~hasDataH) ? first : 'z;

  assign rsSel8=(~portEn) ? 4'B0 : 4'BZ;
  assign rsSel8=(portEn & hasDataH & firstFoundH1) ? first8H1 : 4'BZ;
  assign rsSel8=(portEn & hasDataH & ~firstFoundH1) ? 4'b0 : 4'BZ;
  assign rsSel8=(portEn & ~hasDataH) ? first8 : 4'BZ;

  assign found=(~portEn) ? DEF_FOUND : 1'BZ;
  assign found=(portEn & hasDataH) ? |(portReadyH & portReady) : 1'BZ;
  assign found=(portEn & ~hasDataH) ? firstFound : 1'BZ;

  assign found_no_z=(~portEn) ? 1'b0 : 1'BZ;
  assign found_no_z=(portEn & hasDataH) ? |(portReadyH & portReady) : 1'BZ;
  assign found_no_z=(portEn & ~hasDataH) ? firstFound : 1'BZ;
    
  always @(posedge clk)
  begin
    if (rst|except) mask<=32'hffff_ffff;
    else 
        mask<=(mask & ~portReadyM) | rsShelect;
  end
  
endmodule


module rsSelectFifo48(
  clk,
  rst,
  except,
  portReady,
  portEn,
  found,
  rsSelect,
  rsSel8
  );
  localparam BUF_COUNT=48;
  localparam BUF_WIDTH=BUF_COUNT;
  
  input clk;
  input rst;
  input except;
  input [BUF_WIDTH-1:0] portReady;  
  input portEn;
  output pwire found;
  output pwire [BUF_WIDTH-1:0] rsSelect;  
  output pwire [5:0] rsSel8;

  pwire firstFound;
  pwire [BUF_WIDTH-1:0] first;  

  pwire firstFoundH;
  pwire [BUF_WIDTH-1:0] firstH;  

  pwire firstFoundH1;
  pwire [BUF_WIDTH-1:0] firstH1;  

  pwire [BUF_WIDTH-1:0] rsShelect;  
  
  pwire [BUF_WIDTH-1:0] portReadyH;  
  pwire [BUF_WIDTH-1:0] portReadyX;  
  pwire hasDataH;

  pwire hasMultipleH;  
  pwire hasMultiple;
  
  pwire [5:0] first8;
  pwire [5:0] first8H;
  pwire [5:0] first8H1;
  pwire found8;
  pwire found8H;
  pwire found8H1;
  
  
  pwire [BUF_COUNT-1:0] portReadyH1;
 // pwire [3:0] msk8;
  pwire [BUF_COUNT-1:0] portReadyM;
  reg [BUF_COUNT-1:0] mask;

  
  bit_find_first_bit #(BUF_COUNT) first_mod(portReadyM,first,firstFound);
  bit_find_first_bit #(BUF_COUNT) firstH_mod(portReadyH,firstH,firstFoundH);
  bit_find_first_bit #(BUF_COUNT) firstH1_mod(portReadyH1,firstH1,firstFoundH1);
  
  bit_find_first_bit #(6) first8_mod({|portReadyM[47:40],|portReadyM[39:32],|portReadyM[31:24],|portReadyM[23:16],
    |portReadyM[15:8],|portReadyM[7:0]},first8,found8);
  bit_find_first_bit #(6) first8H_mod({|portReadyH[47:40],|portReadyH[39:32],|portReadyH[31:24],|portReadyH[23:16],
      |portReadyH[15:8],|portReadyH[7:0]},first8H,found8H);
  bit_find_first_bit #(6) first8H1_mod({|portReadyH1[47:40],|portReadyH1[39:32],|portReadyH1[31:24],|portReadyH1[23:16],
          |portReadyH1[15:8],|portReadyH1[7:0]},first8H1,found8H1);
    
  rsSelect_helper #(BUF_COUNT) help_mod(
  .clk(clk),
  .rst(rst),
  .except(except),
  .hasData(hasDataH),
  .read_data(portReadyH),
  .write_data(portReadyM & (~rsSelect | {48{hasDataH}})),
  .write_wen(firstFound && hasMultiple|hasDataH|~portEn),
  .rsSelect_data(portReadyH & ~rsShelect),
  .rsUpdate(hasMultipleH & portEn),
  .rsFlush(hasDataH & ~hasMultipleH & portEn)
  );  
  
  assign portReadyX=hasDataH ? portReadyH : portReady;

  assign portReadyM=portReady & mask;
  
  assign portReadyH1=portReadyH & portReady;
  
  assign hasMultipleH=hasDataH && portReadyH!=firstH;
  assign hasMultiple=portReadyM!=first;     
  
  assign rsSelect=(~portEn) ? {BUF_COUNT{1'B0}} : 'z;
  assign rsSelect=(portEn & hasDataH & firstFoundH1) ? firstH1 : 'z;
  assign rsSelect=(portEn & hasDataH & ~firstFoundH1) ? 48'b0 : 'z;
  assign rsSelect=(portEn & ~hasDataH) ? first : 'z;

  assign rsShelect=(~portEn) ? {BUF_COUNT{1'B0}} : 'z;
  assign rsShelect=(portEn & hasDataH & firstFoundH1) ? firstH1 : 'z;
  assign rsShelect=(portEn & hasDataH & ~firstFoundH1) ? firstH : 'z;
  assign rsShelect=(portEn & ~hasDataH) ? first : 'z;

  assign rsSel8=(~portEn) ? 6'B0 : 6'BZ;
  assign rsSel8=(portEn & hasDataH & firstFoundH1) ? first8H1 : 6'BZ;
  assign rsSel8=(portEn & hasDataH & ~firstFoundH1) ? 6'b0 : 6'BZ;
  assign rsSel8=(portEn & ~hasDataH) ? first8 : 6'BZ;

  assign found=(~portEn) ? 1'b0 : 1'BZ;
  assign found=(portEn & hasDataH) ? |(portReadyH & portReady) : 1'BZ;
  assign found=(portEn & ~hasDataH) ? firstFound : 1'BZ;

    
  always @(posedge clk)
  begin
    if (rst|except) mask<=48'hffff_ffff_ffff;
    else 
        mask<=(mask & ~portReadyM) | rsShelect;
  end
  
endmodule



