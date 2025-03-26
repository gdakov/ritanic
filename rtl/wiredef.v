
typedef logic [9:0] pwire;

class pwh #(WIDTH w);
  static pwire function cmpEQ(input pwire [w-1:0] A; input pwire [w-1:0] B);
    integer a;
    begin
      cmpEQ=10'h3ff;
      for(a=0;a<w;a=a+1) cmpEQ=cmpEQ&~(A[a]^B[a]);
    end
  endfunction
  static pwire function cmpNEQ(input pwire [w-1:0] A; input pwire [w-1:0] B);
    integer a;
    begin
      cmpNEQ=10'b0;
      for(a=0;a<w;a=a+1) cmpNEQ=cmpNEQ|(A[a]^B[a]);
    end
  endfunction
  static pwire[w-1:0] function RPL (input [w-1:0] A);
    integer a;
    begin
      RPL=0;
      for(a=0;a<w;a=a+1) RPL[a]={10{A[a]}};
    end
  endfunction
endclass
