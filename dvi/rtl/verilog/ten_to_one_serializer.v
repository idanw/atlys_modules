module ten_to_one_serializer
  (
   output      out,
   input [9:0] in,
   input       datastrobe,
   input       clk_10x,
   input       clk_2x,
   input       clk,
   input       reset
   );

   reg [9:0]   datain;
   reg         tx_phase;
   
   
   always @(posedge clk_2x) begin
      if(reset) 
        tx_phase <= 1'b0;
      else
        tx_phase <= ~tx_phase;
      
      if(tx_phase == 0)
        datain = in[4:0];
      else
        datain = in[9:5];
   end

   //See UG381 (v1.4) Page 96 for interconnect info
   wire cascade_dataout, cascade_datain, cascade_triout, cascade_triin;

   OSERDES2 
     #(
       .BYPASS_GCLK_FF("FALSE"),     // Bypass CLKDIV syncronization registers (TRUE/FALSE)
       .DATA_RATE_OQ("SDR"),         // Output Data Rate ("SDR" or "DDR")
       .DATA_RATE_OT("SDR"),         // 3-state Data Rate ("SDR" or "DDR")
       .DATA_WIDTH(5),               // Parallel data width (2-8)
       .OUTPUT_MODE("DIFFERENTIAL"), // "SINGLE_ENDED" or "DIFFERENTIAL" 
       .SERDES_MODE("MASTER"),       // "NONE", "MASTER" or "SLAVE" 
       .TRAIN_PATTERN(0)             // Training Pattern (0-15)
       )
   osderdes_master 
     (
      .OQ(out),                      // 1-bit output: Data output to pad or IODELAY2
      .SHIFTOUT1(cascade_dataout),   // 1-bit output: Cascade data output
      .SHIFTOUT2(cascade_triout),    // 1-bit output: Cascade 3-state output
      .SHIFTOUT3(),                  // 1-bit output: Cascade differential data output
      .SHIFTOUT4(),                  // 1-bit output: Cascade differential 3-state output
      .TQ(),                         // 1-bit output: 3-state output to pad or IODELAY2
      .CLK0(clk_10x),                // 1-bit input: I/O clock input
      .CLK1(1'b0),                   // 1-bit input: Secondary I/O clock input
      .CLKDIV(clk_2x),               // 1-bit input: Logic domain clock input
      // D1 - D4: 1-bit (each) input: Parallel data inputs
      .D1(datain[4]),
      .D2(1'b0),
      .D3(1'b0),
      .D4(1'b0),
      .IOCE(datastrobe),       // 1-bit input: Data strobe input
      .OCE(1'b1),              // 1-bit input: Clock enable input
      .RST(reset),             // 1-bit input: Asynchrnous reset input
      .SHIFTIN1(1'b1),         // 1-bit input: Cascade data input
      .SHIFTIN2(1'b1),         // 1-bit input: Cascade 3-state input
      .SHIFTIN3(cascade_datain), // 1-bit input: Cascade differential data input
      .SHIFTIN4(cascade_triin), // 1-bit input: Cascade differential 3-state input
      // T1 - T4: 1-bit (each) input: 3-state control inputs
      .T1(1'b0),
      .T2(1'b0),
      .T3(1'b0),
      .T4(1'b0),
      .TCE(1'b1),        // 1-bit input: 3-state clock enable input
      .TRAIN(1'b0)       // 1-bit input: Training pattern enable input
      );

   OSERDES2 
     #(
       .BYPASS_GCLK_FF("FALSE"),     // Bypass CLKDIV syncronization registers (TRUE/FALSE)
       .DATA_RATE_OQ("SDR"),         // Output Data Rate ("SDR" or "DDR")
       .DATA_RATE_OT("SDR"),         // 3-state Data Rate ("SDR" or "DDR")
       .DATA_WIDTH(5),               // Parallel data width (2-8)
       .OUTPUT_MODE("DIFFERENTIAL"), // "SINGLE_ENDED" or "DIFFERENTIAL" 
       .SERDES_MODE("SLAVE"),       // "NONE", "MASTER" or "SLAVE" 
       .TRAIN_PATTERN(0)             // Training Pattern (0-15)
       )
   oserdes_slave
     (
      .OQ(),                      // 1-bit output: Data output to pad or IODELAY2
      .SHIFTOUT1(),               // 1-bit output: Cascade data output
      .SHIFTOUT2(),               // 1-bit output: Cascade 3-state output
      .SHIFTOUT3(cascade_datain), // 1-bit output: Cascade differential data output
      .SHIFTOUT4(cascade_triin),  // 1-bit output: Cascade differential 3-state output
      .TQ(),                         // 1-bit output: 3-state output to pad or IODELAY2
      .CLK0(clk_10x),                // 1-bit input: I/O clock input
      .CLK1(1'b0),                   // 1-bit input: Secondary I/O clock input
      .CLKDIV(clk_2x),               // 1-bit input: Logic domain clock input
      // D1 - D4: 1-bit (each) input: Parallel data inputs
      .D1(datain[0]),
      .D2(datain[1]),
      .D3(datain[2]),
      .D4(datain[3]),
      .IOCE(datastrobe),       // 1-bit input: Data strobe input
      .OCE(1'b1),              // 1-bit input: Clock enable input
      .RST(reset),             // 1-bit input: Asynchrnous reset input
      .SHIFTIN1(cascade_dataout), // 1-bit input: Cascade data input
      .SHIFTIN2(cascade_triout),  // 1-bit input: Cascade 3-state input
      .SHIFTIN3(1'b1),  // 1-bit input: Cascade differential data input
      .SHIFTIN4(1'b1),  // 1-bit input: Cascade differential 3-state input
      // T1 - T4: 1-bit (each) input: 3-state control inputs
      .T1(1'b0),
      .T2(1'b0),
      .T3(1'b0),
      .T4(1'b0),
      .TCE(1'b1),        // 1-bit input: 3-state clock enable input
      .TRAIN(1'b0)       // 1-bit input: Training pattern enable input
      );


endmodule
