module GPIO(
  input PCLK,
  input PSEL1,
	input PENABLE,
	input [7:0]PADDR,
	input PWRITE,
	input [7:0]PWDATA,
	input [7:0]gpio_in,
	output reg [7:0]gpio_out,
	output reg [7:0]gpio_dir,
	output reg [7:0]PRDATA,
	output reg PREADY
);
localparam in_adr = 8'b10000001,
           out_adr = 8'b10000010,
           dir_adr = 8'b10000011;
 
 
reg [7:0]INPUT,OUTPUT,DIR;
integer i;
always @(posedge PCLK)
  begin
    gpio_dir=DIR;
 
    for(i=0; i<8; i=i+1)
      begin
        gpio_out[i] <= gpio_dir[i]? OUTPUT[i] : 1'bz;
        INPUT[i] <= gpio_dir[i]? 1'bz : gpio_in[i];
      end
    if(PSEL1 && PADDR[7]==1'b1) PREADY=1'b1;
    if (PENABLE && PSEL1)
      begin
          if(PWRITE)
            begin
              if(PADDR == out_adr)
                begin
                  OUTPUT=PWDATA;
                  PREADY=1'b0;
                end
                else if(PADDR == dir_adr)
                  begin
                    DIR=PWDATA;
                    PREADY=1'b0;
                  end
            end
            else
              begin
                if(PADDR == in_adr)
                  begin
                    PRDATA=INPUT;
                    PREADY=1'b0;
                  end
                if(PADDR == dir_adr)
                  begin
                    PRDATA=DIR;
                    PREADY=1'b0;
                  end
              end
     end
  end
 
endmodule

