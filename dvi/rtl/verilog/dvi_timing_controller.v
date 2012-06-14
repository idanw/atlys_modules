/* # 800x600 59.86 Hz (CVT 0.48M3) hsync: 37.35 kHz; pclk: 38.25 MHz
 * Modeline "800x600_60.00"   38.25  800 832 912 1024  600 603 607 624 -hsync +vsync
 * 
 * We can only generate a ~40Mhz Pixel Clock easily for SVGA
 * Let's extend as follows:
 * | Horizontal Front Porch |  40 |
 * | Horizontal HSYNC       | 128 |
 * | Horizontal Back Porch  |  88 |
 * | Veritcle Front Porch   |   3 | 
 * | Veritcle VSYNC         |   4 |
 * | Veritcle Back Porch    |  23 |
 * 
 * 40000000/((800+40+128+88)+(600+3+4+23))
 * = 60.12Hz == close enough
 */

module dvi_timing_controller
  (
   output pixel_x,
   output pixel_y,
   output h_blank,
   output v_blank,
   output h_sync,
   output v_sync,
   output dataenable,
   input  pixel_clk,
   input  reset
   );

   reg [10:0] h_count;
   reg [10:0] v_count;

   assign h_blank = h_count > 800;
   assign v_blank = v_count > 600;
   assign h_sync = (h_count > (800 + 40 - 1)) & (h_count < (800 + 40 + 128));
   assign v_sync = (v_count > (600 + 3 - 1)) & (v_count < (600 + 3 + 4));
   assign dataenable = ~h_blank & ~v_blank;

   
   always @(posedge pixel_clk) begin
      if(h_count >= (800 + 40 + 128 + 88 - 1)) begin
         h_count <= 11'd0;

         if(v_count >= (600 + 3 + 4 + 23 - 1)) begin
            v_count <= 11'd0;
         end else begin
            v_count <= v_count + 11'd1;
         end
      end else begin
         h_count <= h_count + 11'd1;
      end
   end

endmodule // dvi_timing_controller
         
