module uart_transmitter 
  #(parameter C)
  (
   input PCLK,
   input ENABLE,
   input PSEL2,
	 input [7:0]PADDR,
	 input PWRITE,
   input [7:0] tx_parallel, 
   output reg  PREADY,
   output reg  o_Tx_Serial,
   output      o_Tx_Done
   );
 
  localparam IDLE = 3'b000, START_BIT = 3'b001, DATA_BITS = 3'b010,STOP_BIT = 3'b011;
  parameter adr = 8'b00000010;
 
 
  reg [2:0]    state     = 0;
  reg [7:0]    counter = 0;
  reg [2:0]    r_Bit_Index   = 0;
  reg [7:0]    r_Tx_Data     = 0;
  reg          r_Tx_Done     = 0;
 
  always @(posedge PCLK)
    begin
 
      case (state)
        IDLE :
          begin
            o_Tx_Serial   <= 1'b1;         // Drive Line High for Idle
            r_Tx_Done     <= 1'b0;
            counter <= 0;
            r_Bit_Index   <= 0;
            if(PSEL2 && PADDR[7]==1'b0 && PWRITE) PREADY=1'b1;
            if (ENABLE && PSEL2 && PWRITE)
              begin
                r_Tx_Data   <= tx_parallel;
                state   <= START_BIT;
              end
            else
              state <= IDLE;
          end // case: s_IDLE
 
 
        // Send out Start Bit. Start bit = 0
        START_BIT :
          begin
            o_Tx_Serial <= 1'b0;
            
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (counter < C-1)
              begin
                counter <= counter + 1;
                state     <= START_BIT;
              end
            else
              begin
                counter <= 0;
                state     <= DATA_BITS;
              end
          end // case: s_TX_START_BIT
 
 
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        DATA_BITS :
          begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index];
 
            if (counter < C-1)
              begin
                counter <= counter + 1;
                state     <= DATA_BITS;
              end
            else
              begin
                counter <= 0;
 
                // Check if we have sent out all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    state   <= DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    state   <= STOP_BIT;
                  end
              end
          end // case: s_TX_DATA_BITS
 
 
        // Send out Stop bit.  Stop bit = 1
        STOP_BIT :
          begin
            o_Tx_Serial <= 1'b1;
 
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (counter < C-1)
              begin
                counter <= counter + 1;
                state     <= STOP_BIT;
              end
            else
              begin
                r_Tx_Done <= 1'b1;
                counter <= 1'b0;
                PREADY <= 1'b0;  
              end
          end // case: s_Tx_STOP_BIT
 
 
        // Stay here 1 clock
 
        default:
          state <= IDLE;
 
      endcase
    end
 
//  assign o_Tx_Active = r_Tx_Active;
  assign o_Tx_Done   = r_Tx_Done;
 
endmodule
