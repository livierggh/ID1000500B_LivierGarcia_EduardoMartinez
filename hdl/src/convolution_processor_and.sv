/******************************************************************
* Description
*
* This module performs the and operation
*
* Author: Mateo Martinez
* email : emms1408@gmail.com	
* Date  : 01/05/2024
	      DD/MM/YYYY	
******************************************************************/
module convolution_processor_and
(
    input logic a_i,  
    input logic b_i,  
    output logic c_o 
); 

assign c_o = a_i & b_i;

endmodule
