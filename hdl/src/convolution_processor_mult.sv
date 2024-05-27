/******************************************************************
* Description
*
* This module performs the multiplication of two parameterizable registers
*
*
* Author: Mateo Martinez
* email : emms1408@gmail.com	
* Date  : 01/05/2024
	      DD/MM/YYYY	
******************************************************************/
module convolution_processor_mult
#(
   parameter DATA_WIDTH = 22)
(
	input  logic [DATA_WIDTH-1 : 0] re_A,
	input  logic [DATA_WIDTH-1 : 0] re_B,
    	output logic [15 : 0] re_out
);
	
	assign re_out = re_A * re_B;
endmodule
