module dvi_encoder
  (
   output reg [9:0] q_out,
   input [7:0]      D,
   input            C0,
   input            C1,
   input            DE,
   input            clk,
   input            reset
   );
   
                   
   reg [3:0]        n1_D;
   reg [7:0]        D_delay1;
   reg [3:0]        cnt; //XXX: SHOULD THIS BE 1:0?
   

   //Stage 1: Calculate number of 1s
   always @(posedge clk) begin
      n1_D <= D[0] + D[1] + D[2] + D[3] + D[4] + D[5] + D[6] + D[7];
      D_delay1 <= D;
   end

   //Stage 2: Calculate q_m
   reg [8:0] q_m;
   always @(posedge clk) begin
      q_m[0] <= D_delay1[0];
      
      if(n1_D > 4 || (n1_D == 4 && D_delay1[0] == 0)) begin
         q_m[7:1] <= q_m[6:0] ^ D_delay1[7:1];
         q_m[8]   <= 1;
      end else begin
         q_m[7:1] <= q_m[6:0] ~^ D_delay1[7:1];
         q_m[8]   <= 0;
      end
   end


   //number of 1's or 0's calculation. n0_q_m could probably be
   //optimized to `m0_q_m = 4'b8 - n1_q_m`
   wire [3:0] n1_q_m;
   wire [3:0] n0_q_m;
   assign n1_q_m = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7];
   assign n0_q_m = ~q_m[0] + ~q_m[1] + ~q_m[2] + ~q_m[3] + ~q_m[4] + ~q_m[5] + ~q_m[6] + ~q_m[7];
   

   //Stage 3: Output Encoded Algorithm
   always @(posedge clk) begin
      if(DE) begin
         if(cnt == 0 || (n1_q_m == n0_q_m)) begin
            q_out[9] <= ~q_m[8];
            q_out[8] <=  q_m[8];
            
            if(q_m[8] == 0) begin
               q_out[7:0] <= ~q_m[7:0];
               cnt <= cnt + (n0_q_m - n1_q_m);
            end else begin
               q_out[7:0] <= q_m[7:0];
               cnt <= cnt + (n1_q_m - n0_q_m);
            end
            
         end else begin
            if((cnt > 0 && (n1_q_m > n0_q_m)) || (cnt < 0 && (n0_q_m > n1_q_m))) begin
               q_out[9] <= 1;
               q_out[8:0] <= {q_m[8], ~q_m[7:0]};

               cnt <= cnt + q_m[8] + q_m[8] + (n0_q_m - n1_q_m);
            end else begin
               q_out[9] <= 0;
               q_out[8:0] <= {q_m[8], q_m[7:0]};

               cnt <= cnt + ~q_m[8] + ~q_m[8] + (n1_q_m - n0_q_m);
            end            
         end
          
      end else begin
         cnt <= 4'd0;
         case({C1, C0})
           00: q_out[9:0] <= 10'b1101010100;
           01: q_out[9:0] <= 10'b0010101011;
           10: q_out[9:0] <= 10'b0101010100;
           11: q_out[9:0] <= 10'b1010101011;
         endcase
      end
   end
   
endmodule // dvi_encoder
