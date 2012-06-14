module dvi_controller
  (
   output [3:0] tmds,
   output [3:0] tmdsb,
	input  [7:0] switches,
   input        clk_100mhz,
   input        reset
   );


   wire         h_sync, v_sync, dataenable;
   wire [9:0]   r_enc;
   wire [9:0]   g_enc;
   wire [9:0]   b_enc;

   wire         pixel_clk1x, pixel_clk2x, pixel_clk10x;
   wire         serdesstrobe;

   wire         r10x, g10x, b10x;
   
   dvi_timing_controller timing
     (
      .pixel_x(),
      .pixel_y(),
      .h_blank(),
      .v_blank(),
      .h_sync(h_sync),
      .v_sync(v_sync),
      .dataenable(dataenable),
      .pixel_clk(pixel_clk1x),
      .reset(reset)
      );

   dvi_encoder encoder_r
     (
      .q_out(r_enc),
      .D(switches),
      .C0(h_sync),
      .C1(v_sync),
      .DE(dataenable),
      .clk(pixel_clk1x),
      .reset(reset)
      );

   dvi_encoder encoder_g
     (
      .q_out(g_enc),
      .D(switches ^ 8'b10100000),
      .C0(1'b0),
      .C1(1'b0),
      .DE(dataenable),
      .clk(pixel_clk1x),
      .reset(reset)
      );
   
   dvi_encoder encoder_b
     (
      .q_out(b_enc),
      .D(~switches),
      .C0(1'b0),
      .C1(1'b0),
      .DE(dataenable),
      .clk(pixel_clk1x),
      .reset(reset)
      );
   
   ten_to_one_serializer ser_r
     (
      .out(r10x),
      .in(r_enc),
      .datastrobe(serdesstrobe),
      .clk_10x(pixel_clk10x),
      .clk_2x(pixel_clk2x),
      .clk(pixel_clk1x),
      .reset(reset)
      );
        
   ten_to_one_serializer ser_g
     (
      .out(g10x),
      .in(g_enc),
      .datastrobe(serdesstrobe),
      .clk_10x(pixel_clk10x),
      .clk_2x(pixel_clk2x),
      .clk(pixel_clk1x),
      .reset(reset)
      );
   
   ten_to_one_serializer ser_b
     (
      .out(b10x),
      .in(b_enc),
      .datastrobe(serdesstrobe),
      .clk_10x(pixel_clk10x),
      .clk_2x(pixel_clk2x),
      .clk(pixel_clk1x),
      .reset(reset)
      );
		
   OBUFDS obuf_tmds[3:0](.O(tmds[3:0]), .OB(tmdsb[3:0]), .I({pixel_clk1x, b10x, g10x, r10x}));
   
   dvi_clock_manager clock_manager
     (
      .pixel_clk1x(pixel_clk1x),
      .pixel_clk2x(pixel_clk2x),
      .pixel_clk10x(pixel_clk10x),
      .strobe2x(serdesstrobe),
      .clkin(clk_100mhz),
      .reset(reset)
      );
   
endmodule // dvi_controller

/*
 
NET "TMDS"   LOC = "C7" | IOSTANDARD = TMDS_33 ; # D1
NET "TMDSB"  LOC = "A7" | IOSTANDARD = TMDS_33 ;
NET "TMDS"   LOC = "D8" | IOSTANDARD = TMDS_33 ; # D0
NET "TMDSB"  LOC = "C8" | IOSTANDARD = TMDS_33 ;
NET "TMDS"   LOC = "B8" | IOSTANDARD = TMDS_33 ; # D2
NET "TMDSB"  LOC = "A8" | IOSTANDARD = TMDS_33 ;
NET "TMDS"   LOC = "B6" | IOSTANDARD = TMDS_33 ; # CLock
NET "TMDSB"  LOC = "A6" | IOSTANDARD = TMDS_33 ;

*/
