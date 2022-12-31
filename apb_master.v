module apb_master(
  input [7:0]apb_write_paddr,
	input [7:0] apb_write_data,PRDATA,         
	input PRESETn,PCLK,READ_WRITE,PREADY,
	output reg PSEL1,PSEL2,
	output reg PENABLE,
	output reg [7:0]PADDR,
	output reg PWRITE,
	output reg [7:0]PWDATA,apb_read_data_out
);
 
reg [2:0] state, next_state;
localparam IDLE = 3'b001, SETUP = 3'b010, ACCESS = 3'b100 ;
reg check=1'b0;

 
always @(posedge PCLK)
  begin
    if(apb_write_paddr[7] == 1'b0) 
      begin
        PSEL2 = 1'b1;
        PSEL1 = 1'b0;
      end
		if(apb_write_paddr[7] == 1'b1) 
		begin
		PSEL1 = 1'b1;
		PSEL2 = 1'b0;
		end
		  
  end
 
 
 
always @(posedge PCLK)

  begin
     PWRITE = ~READ_WRITE; 
	   if(!PRESETn) state = IDLE;
	   else
       begin
	      case(state)
 
		      IDLE:
		       begin 
		         PENABLE =0;
		         if(!PSEL1 && !PSEL2)state =  IDLE;
	           else state = SETUP;
	         end
 
 
	        SETUP:
	         begin
			       PENABLE =0;
			       if(READ_WRITE)
			         begin
			           PADDR = apb_write_paddr;
			         end  
			       else 
			        begin   
                PADDR = apb_write_paddr;
				        PWDATA = apb_write_data;
				      end
			      if(PSEL1 || PSEL2) state = ACCESS;	 
			      else state = IDLE;
		       end
 
		      ACCESS:
		       begin
		         if(PSEL1 || PSEL2)
		           begin
		             PENABLE =1;
		             if(PREADY)
		               begin
		                 if(!READ_WRITE)
		                 begin
		                  state = SETUP;
		                  PSEL1 =0;
                      PSEL2 =0;
		                  end
		                 else 
					            begin
					              state = SETUP; 
                        apb_read_data_out = PRDATA; 
                        PSEL1 =0;
                        PSEL2 =0;
                       
					            end
		               end
		             else 
		             begin
		              state = ACCESS;
		             end
		            end
		         else state = IDLE;
		        end
		        
			    default: state = IDLE; 
			  endcase
			end
 end 
endmodule
