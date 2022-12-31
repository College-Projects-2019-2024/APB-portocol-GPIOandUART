module uart_test();
   reg PCLK;
   reg ENABLE;
   reg PSEL2;
	 reg [7:0]PADDR;
	 reg [7:0]ADDR;
	 reg PWRITE;
	 reg WRITE;
   reg [7:0] tx_parallel; 
   wire      o_Tx_Active;
   wire  o_Tx_Serial;
   wire      o_Tx_Done;
   wire      o_Rx_Done;
   wire[7:0] rx_parallel;
  
  
  initial
  begin
    
    $monitor("%b %b %b %b %b %b",PCLK,PSEL2,ENABLE,o_Tx_Active,o_Tx_Serial,o_Tx_Done);
    PCLK=0;
    
    #12
    PSEL2=1;
    ENABLE=1;
    PWRITE=1;
    WRITE=0;
    PADDR=8'b00000010;
    ADDR=8'b00000001;
    tx_parallel=8'b10101010;
    
  end 
 
   
    uart_transmitter #(.C(2)) test3(PCLK,ENABLE,PSEL2,PADDR,PWRITE,tx_parallel,o_Tx_Active,o_Tx_Serial,o_Tx_Done);
    uart_receiver #(.C(2)) test4(PCLK,o_Tx_Serial,PSEL2,ENABLE,ADDR,WRITE,o_Rx_Done,rx_parallel);
    
    
    
   
 endmodule
   
