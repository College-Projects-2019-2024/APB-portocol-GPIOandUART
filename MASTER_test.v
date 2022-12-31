module Master_test();
   reg [7:0] tb_addr;
   reg [7:0] tb_write_data;
   wire [7:0] PRDATA;
   wire [7:0] PWDATA;
   reg PCLK;
   wire ENABLE;
   wire PSEL2;
   wire PSEL1;
   reg PRESETn;
   reg READ_WRITE;
   wire [7:0]PADDR;
   wire      PWRITE;
   wire      PREADY;
   wire      PREADY1;
   wire      PREADY2;
   reg [7:0] tx_parallel; 
   wire      Tx_Serial;
   wire      Tx_Done;
   wire      Rx_Done;
   wire[7:0] rx_parallel;
   reg Rx_Serial;
   wire[7:0] tb_read_data;
   reg [7:0] gpio_in;
   wire[7:0] gpio_out;
	 wire[7:0] gpio_dir;
	 wire[7:0] gpio_temp;
 
 
 
reg[7:0]i_data;
integer i;
initial
    begin
 
 
    //in_adr = 8'b10000001,
    //out_adr = 8'b10000010,
    //dir_adr = 8'b10000011;
    //transmitter adr = 8'00000010;
    //receiver adr = 8'b01000001;
 
 
    #300
    PRESETn =1'b1;
    //write on gpio_dir
    tb_addr =8'b10000011;
    tb_write_data =8'b11111001;
 
    READ_WRITE = 1'b0;
 
    #30000
    tb_addr =8'bzzzzzzzz;
    #30000
    //write on gpio_out
    tb_addr =8'b10000010;
    tb_write_data =8'b11110000;
    #30000
    tb_addr =8'bzzzzzzzz;
    #30000
    //read from gpio_in
    tb_addr = 8'b10000001;
    READ_WRITE = 1'b1;
    gpio_in = 8'b11111111;
    #30000
    tb_addr =8'bzzzzzzzz;
    #30000
 
    //transmit data
    READ_WRITE = 1'b0;
    tb_addr =8'b00000010;
    tb_write_data =8'b10101010;
    #30000
    tb_addr =8'bzzzzzzzz;
    #200000
 
 
    //receive data
    i_data = 8'b11000101;
    tb_addr =8'b01000001;
    READ_WRITE = 1'b1;
    #40000
    Rx_Serial = 1'b0;
    #20000
 
    for (i=0; i<8; i=i+1)
      begin
        #20000
        Rx_Serial = i_data[i];
 
      end
    #20000
    Rx_Serial = 1'b1;
    #30000
    tb_addr =8'bzzzzzzzz;
 
 
 
    end 
 
    assign PREADY= PREADY1 | PREADY2;
    assign PRDATA = (PSEL2)?((Rx_Done)?rx_parallel:8'bzzzzzzzz):gpio_temp;
    assign tb_read_data = PRDATA;
 
    apb_master mast (tb_addr,tb_write_data,PRDATA,PRESETn,PCLK,READ_WRITE,PREADY,
    PSEL1,PSEL2,ENABLE,PADDR,PWRITE,PWDATA,tb_read_data);
 
    GPIO tt( PCLK,PSEL1, ENABLE, PADDR,PWRITE,PWDATA,gpio_in,gpio_out,gpio_dir,	gpio_temp,	PREADY1);
 
    uart_transmitter #(.C(2)) trans(PCLK,ENABLE,PSEL2,PADDR,PWRITE,PWDATA,PREADY2,Tx_Serial,Tx_Done);
    uart_receiver #(.C(2)) rec(PCLK,Rx_Serial,PSEL2,ENABLE,PADDR,PWRITE,Rx_Done,rx_parallel);
 
 
endmodule