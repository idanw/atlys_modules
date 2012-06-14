module dvi_clock_manager
  (
   output pixel_clk1x,
   output pixel_clk2x,
   output pixel_clk10x,
   output strobe2x,
   input  clkin,
   input  reset
   );


   //Why both DCM_CLKGEN and PLL_BASE? Would exceed Multiply value for
   //PLL_ADV in higher pixel clocks. Plus PLL_ADV is complex to program...
   
   wire dcm_clkgen;
   wire dcm_locked;
   
   //100Mhz Clock Input, we want to generate a 10x pixel clock for
   //SVGA = 40Mhz Pixel Clock => M=2, D=5
   DCM_CLKGEN #(
      .CLKFXDV_DIVIDE(2),       // CLKFXDV divide value (2, 4, 8, 16, 32)
      .CLKFX_DIVIDE(5),         // Divide value - D - (1-256)
      .CLKFX_MD_MAX(0.0),       // Specify maximum M/D ratio for timing anlysis
      .CLKFX_MULTIPLY(2),       // Multiply value - M - (2-256)
      .CLKIN_PERIOD(20.0),      // Input clock period specified in nS
      .SPREAD_SPECTRUM("NONE"), // Spread Spectrum mode "NONE", "CENTER_LOW_SPREAD", "CENTER_HIGH_SPREAD",
                                // "VIDEO_LINK_M0", "VIDEO_LINK_M1" or "VIDEO_LINK_M2" 
      .STARTUP_WAIT("FALSE")    // Delay config DONE until DCM_CLKGEN LOCKED (TRUE/FALSE)
   ) DCM_CLKGEN_inst (
      .CLKFX(dcm_clkgen),    // 1-bit output: Generated clock output
      .CLKFX180(),           // 1-bit output: Generated clock output 180 degree out of phase from CLKFX.
      .CLKFXDV(),            // 1-bit output: Divided clock output
      .LOCKED(dcm_locked),   // 1-bit output: Locked output
      .PROGDONE(),           // 1-bit output: Active high output to indicate the successful re-programming
      .STATUS(),             // 2-bit output: DCM_CLKGEN status
      .CLKIN(clkin),         // 1-bit input: Input clock
      .FREEZEDCM(1'b0),      // 1-bit input: Prevents frequency adjustments to input clock
      .PROGCLK(1'b0),        // 1-bit input: Clock input for M/D reconfiguration
      .PROGDATA(1'b0),       // 1-bit input: Serial data input for M/D reconfiguration
      .PROGEN(1'b0),         // 1-bit input: Active high program enable
      .RST(reset)            // 1-bit input: Reset input pin
   );


   wire pll_clk10x, pll_clk2x, pll_clk1x, clkfbout, pll_locked;
   
   PLL_BASE #(
      .BANDWIDTH("OPTIMIZED"),             // "HIGH", "LOW" or "OPTIMIZED" 
      .CLKFBOUT_MULT(10),                  // Multiply value for all CLKOUT clock outputs (1-64)
      .CLKFBOUT_PHASE(0.0),                // Phase offset in degrees of the clock feedback output (0.0-360.0).
      .CLKIN_PERIOD(0.0),                  // Input clock period in ns to ps resolution (i.e. 33.333 is 30
                                           // MHz).
      // CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
      .CLKOUT0_DIVIDE(1),
      .CLKOUT1_DIVIDE(5),
      .CLKOUT2_DIVIDE(10),
      // CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
      .CLKOUT0_DUTY_CYCLE(0.5),
      .CLKOUT1_DUTY_CYCLE(0.5),
      .CLKOUT2_DUTY_CYCLE(0.5),
      // CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
      .CLKOUT0_PHASE(0.0),
      .CLKOUT1_PHASE(0.0),
      .CLKOUT2_PHASE(0.0),
      .CLK_FEEDBACK("CLKFBOUT"),           // Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
      .COMPENSATION("INTERNAL"), // "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL" 
      .DIVCLK_DIVIDE(1),                   // Division value for all output clocks (1-52)
      .REF_JITTER(0.1),                    // Reference Clock Jitter in UI (0.000-0.999).
      .RESET_ON_LOSS_OF_LOCK("FALSE")      // Must be set to FALSE
   )
   PLL_BASE_inst (
      .CLKFBOUT(clkfbout), // 1-bit output: PLL_BASE feedback output
      // CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
      .CLKOUT0(pll_clk10x),
      .CLKOUT1(pll_clk2x),
      .CLKOUT2(pll_clk1x),
		.CLKOUT3(),
		.CLKOUT4(),
		.CLKOUT5(),
      .LOCKED(pll_locked),     // 1-bit output: PLL_BASE lock status output
      .CLKFBIN(clkfbout),   // 1-bit input: Feedback clock input
      .CLKIN(dcm_clkgen),       // 1-bit input: Clock input
      .RST(reset)            // 1-bit input: Reset input
   );


   //We want to fan these out using the high speed clock lines in the FPGA
   BUFG pixel_clock1x_bufg(.O(pixel_clk1x), .I(pll_clk1x));
   BUFG pixel_clock2x_bufg(.O(pixel_clk2x), .I(pll_clk2x));


   wire buffpll_lock, strobe;
   BUFPLL plloutbuf (.IOCLK(pixel_clk10x), .LOCK(bufpll_lock), .SERDESSTROBE(strobe2x),
                     .GCLK(pixel_clk2x), .PLLIN(pll_clk10x), .LOCKED(pll_locked));
endmodule
