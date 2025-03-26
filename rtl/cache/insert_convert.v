
module insconv(
   bundle,
   bundle_out);

   input [255:0] bundle;
   output pwire [255:0] bundle_out;


   pwire [14:-1] stp;

   assign bundle_out[239:0]=bundle[239:0];
   assign bundle_out[255]=bundle[255];

   assign stp={bundle[254:240],1'b1};

   generate
     genvar pos;
     for(pos=0;pos<15;pos=pos+1) begin
	 assign bundle_out[240+pos]=(stp[pos-1] && bundle[16*pos+:8]==8'hf2) || stp[pos];
     end
   endgenerate

endmodule
