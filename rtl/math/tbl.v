

module tblD(
  clk,
  rst,
  A,
  B,
  xtra,
  is_read,
  is_write,
  res);

  input pwire clk;
  input pwire rst;
  input pwire [67:0] A;
  input pwire [67:0] B;
  input pwire [2:0] xtra;
  input pwire is_read;
  input pwire is_write;
  output pwire [67:0] res;

  pwire [255+64:0][67:0] ram;

  pwire [5:0] bits;
  pwire [5:0] bits0;
  pwire [5:0] bits1;
  pwire [5:0] bits2;

  pwire [5:0] mask;
  pwire [5:0] mask0;
  pwire [5:0] mask1;


  assign res=is_read && ~xtra[2] | ~|xtra[1:0] ? ram[(xtra[1:0]&{2{~xtra[2]}})+bits*4+xtra[2]*256]^{3'b0,A[64]&&(pwh#(3)::cmpEQ(xtra,3'b10)||pwh#(3)::cmpEQ(xtra,3'b0)),64'b0} : 68'bz;
  assign res=is_read && pwh#(3)::cmpEQ(xtra,3'd5) ? {A[67:66],A[65:53],A[52:0]}&{mask0<<1,47'b0} : 68'bz;
  assign res=is_read && pwh#(3)::cmpEQ(xtra,3'd6) ? {A[67:66],A[65:53],A[52:0]}&{mask0<<2,47'b0} : 68'bz;
  assign res=is_read && pwh#(3)::cmpEQ(xtra,3'd7) ? {A[67:66],A[65:53],A[52:0]}&{mask1<<1,47'b0} : 68'bz;


  always @* begin
      bits=6'd0;
      mask=6'd0;
      bits0=0;
      if (pwh#(2)::cmpEQ(xtra[1:0],2'd0) && A[65:54]==2040) bits0= {6'b0};  
      if (pwh#(2)::cmpEQ(xtra[1:0],2'd0) && A[65:54]==2041) bits0= {1'b1,5'b0};  
      if (pwh#(2)::cmpEQ(xtra[1:0],2'd0) && A[65:54]==2042) bits0= {1'b1,4'b0,A[53]};  
      if (pwh#(2)::cmpEQ(xtra[1:0],2'd0) && A[65:54]==2043) bits0= {1'b1,3'b0,A[53:52]};  
      if (pwh#(2)::cmpEQ(xtra[1:0],2'd0) && A[65:54]==2044) bits0= {1'b1,2'b0,A[53:51]};  
      if (pwh#(2)::cmpEQ(xtra[1:0],2'd0) && A[65:54]==2045) bits0= {1'b1,1'b0,A[53:50]};  
      if (pwh#(2)::cmpEQ(xtra[1:0],2'd0) && A[65:54]==2046) bits0= {1'b1,A[53:49]};

      bits1=0;
      if (pwh#(3)::cmpEQ(xtra,3'd1) && A[65:54]==2041) bits1= {A[54],5'b0};  
      if (pwh#(3)::cmpEQ(xtra,3'd1) && A[65:54]==2042) bits1= {A[54],1'b1,4'b0};  
      if (pwh#(3)::cmpEQ(xtra,3'd1) && A[65:54]==2043) bits1= {A[54],1'b1,3'b0,A[53]};  
      if (pwh#(3)::cmpEQ(xtra,3'd1) && A[65:54]==2044) bits1= {A[54],1'b1,2'b0,A[53:52]};  
      if (pwh#(3)::cmpEQ(xtra,3'd1) && A[65:54]==2045) bits1= {A[54],1'b1,1'b0,A[53:51]};  
      if (pwh#(3)::cmpEQ(xtra,3'd1) && A[65:54]==2046) bits1= {A[54],1'b1,A[53:50]};

      bits2=0;
      if (|xtra[2:1] && A[65:54]==2045) bits2= {1'b1,5'b0};  
      if (|xtra[2:1] && A[65:54]==2046) bits2= {1'b1,4'b0,A[53]};  
      if (|xtra[2:1] && A[65:54]==2047) bits2= {1'b1,3'b0,A[53:52]};  
      if (|xtra[2:1] && A[65:54]==2048) bits2= {1'b1,2'b0,A[53:51]};  
      if (|xtra[2:1] && A[65:54]==2049) bits2= {1'b1,1'b0,A[53:50]};  
      if (|xtra[2:1] && A[65:54]==2050) bits2= {1'b1,A[53:49]};

      if (pwh#(3)::cmpEQ(xtra,3'd0)) bits=bits0;
      else if (pwh#(3)::cmpEQ(xtra,3'd1)) bits=bits1;
      else bits=bits2;

      mask0=0;
      if (pwh#(1)::cmpEQ(xtra[1],1'd0) && A[65:54]==2041) mask0= {5'b0,1'b1};  
      if (pwh#(1)::cmpEQ(xtra[1],1'd0) && A[65:54]==2042) mask0= {4'b0,2'b11};  
      if (pwh#(1)::cmpEQ(xtra[1],1'd0) && A[65:54]==2043) mask0= {3'b0,3'b111};  
      if (pwh#(1)::cmpEQ(xtra[1],1'd0) && A[65:54]==2044) mask0= {2'b0,4'b1111};  
      if (pwh#(1)::cmpEQ(xtra[1],1'd0) && A[65:54]==2045) mask0= {1'b0,5'b11111};  
      if (pwh#(1)::cmpEQ(xtra[1],1'd0) && A[65:54]==2046) mask0= 6'b111111;

      mask1=0;
      if (xtra[1]!=1'd0 && A[65:54]==2045) mask1= {5'b0,1'b1};  
      if (xtra[1]!=1'd0 && A[65:54]==2046) mask1= {4'b0,2'b11};  
      if (xtra[1]!=1'd0 && A[65:54]==2047) mask1= {3'b0,3'b111};  
      if (xtra[1]!=1'd0 && A[65:54]==2048) mask1= {2'b0,4'b1111};  
      if (xtra[1]!=1'd0 && A[65:54]==2049) mask1= {1'b0,5'b11111};  
      if (xtra[1]!=1'd0 && A[65:54]==2050) mask1= 6'b111111;
  end  

  always @(posedge clk) begin
     if (is_write) ram[B[53:45]]=A;
  end
endmodule
