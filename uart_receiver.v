module uart_receiver#(parameter C)(
  input PCLK,
  input rx_serial,
  output rx_done,
  output[7:0] rx_parallel
);
  
reg [2:0] state = 0;
localparam IDLE = 3'b000, START_BIT = 3'b001, DATA_BITS = 3'b010,STOP_BIT = 3'b011;

reg rx_data = 1'b1;
reg[7:0] counter = 0;  
reg[2:0] bit_index = 0;
reg done = 0;
reg[7:0] rx_out = 0;  

always @(posedge PCLK)
  begin
    rx_data = rx_serial;
    case(state)
      
      IDLE:
        begin
          done <=0;
          counter <=0;
          bit_index <=0;
          
          if(rx_data == 1'b0)
            state <= START_BIT;
          else
            state <= IDLE;         
        end
        
      START_BIT:
        begin
          if(counter == C/2)
            begin
              if(rx_data == 1'b0)
                begin
                  counter <=0;
                  state <=DATA_BITS;
                end
              else
                state <=IDLE;
            end
          else
            begin
              counter <= counter + 1;
              state <=START_BIT;
            end
          
        end
        
      DATA_BITS:
          begin
            if(counter < C-1)
              begin
                counter <= counter + 1;
                state <= DATA_BITS;
              end
            else
              begin
                counter <=0;
                rx_out[bit_index] <= rx_data;
                
                if (bit_index < 7)
                  begin
                    bit_index <= bit_index + 1;
                    state <= DATA_BITS;
                  end
                else
                  begin
                    bit_index <= 0;
                    state <= STOP_BIT;
                  end
              end
              
          end
          
      STOP_BIT:
          begin
            if (counter < C-1)
            begin
              counter <= counter + 1;
              state <= STOP_BIT;
            end
          else
            begin
              done <= 1'b1;
              counter <= 0;
              state <= IDLE;
            end
          end
            
      default:
          state <= IDLE;
        
    endcase
    
    
  end  
  
assign rx_done = done;
assign rx_parallel = rx_out;
   
endmodule