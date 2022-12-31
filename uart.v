module UART(
  input PCLK,
  input PSEL2,
	input PENABLE,
	input [7:0]PADDR,
	input PWRITE,
	input [7:0]PWDATA,
	output reg [7:0]PRDATA,
	output reg done,
	output reg tx_active,
	input rx,
	output tx
 
);
 
parameter final_value = 87;
 
uart_receiver #(final_value) R1 (PCLK,rx,PSEL2,PENABLE,PADDR,PWRITE,done,PRDATA);
uart_transmitter #(final_value) T1 (PCLK,PENABLE,PSEL2,PADDR,PWRITE,PWDATA,tx_active,tx,done);
 
endmodule