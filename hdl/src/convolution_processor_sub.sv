`timescale 1ns / 1ps
/*	
   ===================================================================
   Module Name  : complex subtractor
      
   Filename     : complexSubtractor.v
   Type         : Verilog Module
   
   Description  : 
                  Complex subtractor with independent buses for real and imaginary parts.
                  Input    :  "DATA_WIDTH" length word in 2's complement representation.
                  Output   :  "DATA_WIDTH" length word in 2's complement representation.
                  
                  Designer must take care of overflow. 
                  We recommend to instantiate a "DATA WIDTH" length subtractor for "DATA WIDTH-1" length inputs.
                  
   -----------------------------------------------------------------------------
   Clocks      : -
   Reset       : -
   Parameters  :   
         NAME                         Comments                                            Default
         -------------------------------------------------------------------------------------------
         DATA_WIDTH              Number of data bits for inputs and outputs               18 
         -------------------------------------------------------------------------------------------
   Version     : 1.0
   Data        : 14 Nov 2018
   Revision    : -
   Reviser     : -		
   ------------------------------------------------------------------------------
      Modification Log "please register all the modifications in this area"
      (D/M/Y)  
      
   ----------------------
   // Instance template
   ----------------------
   complexSubtractor
   #(
      .DATA_WIDTH    ()
   )
   "MODULE_NAME"
   (
       .re_A      (),
       .im_A      (),
       .re_B      (),
       .im_B      (),
       .re_out    (),
       .im_out    ()
   );
*/
module convolution_processor_sub
#(parameter DATA_WIDTH = 18)
(
    input  [DATA_WIDTH-1 : 0] re_A,
	 input  [DATA_WIDTH-1 : 0] re_B,
    output [DATA_WIDTH-1 : 0] re_out
);
	
	reg signed [DATA_WIDTH -1: 0] temp_RA;
	reg signed [DATA_WIDTH -1: 0] temp_RB;
	
	wire signed [DATA_WIDTH -1: 0] temp_RE;
	
	always@(re_A, re_B)
	begin
		temp_RA = re_A;
		temp_RB = re_B;
	end 
	
	assign temp_RE = temp_RA - temp_RB;
	
	assign re_out = temp_RE;
endmodule

