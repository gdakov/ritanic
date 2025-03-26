
typedef logic [9:0] pwire;

class pwh #(WIDTH w);
  static pwire function cmpEQ(input pwire [w-1:0] A; input [w-1:0] B);
    integer a;
    begin
      cmpEQ=10'h3ff;
      for(a=0;a<w;a=a+1) cmpEQ=cmpEQ&~(A[a]^{10{B[a]}});
    end
  endfunction
  static pwire function cmpNEQ(input pwire [w-1:0] A; input [w-1:0] B);
    integer a;
    begin
      cmpNEQ=10'b0;
      for(a=0;a<w;a=a+1) cmpNEQ=cmpNEQ|(A[a]^{10{B[a]}});
    end
  endfunction
  static pwire[w-1:0] function RPL (input [w-1:0] A);
    integer a;
    begin
      RPL=0;
      for(a=0;a<w;a=a+1) RPL[a]={10{A[a]}};
    end
  endfunction
  static pwire[w-1:0] function pick (input pwire[w-1:0] A,input [3:0] sel);
    integer a;
    begin
      assert(sel<=9);
      for(a=0;a<w;a=a+1) pick[a]={10{A[a][sel]}};
    end
  endfunction

  static pwire[w-1:0] function pmul ( input [7:0] mulbgn; input [1:0] val; );
    integer a,b;
    logic [w-1:0] tmp;
    begin
      for(a=0;a<10;a=a+1) begin
          tmp=val*(mulbgn+a);
          for(b=0;b<w;b=b+1) pmul[b][a]=tmp[b];
      end
    end
  endfunction
endclass
