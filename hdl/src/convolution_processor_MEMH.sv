/******************************************************************
* Description
*
* Single rom 
*
* Parameters: DATAWIDTH  -> Width of data stored/read 
*             ADDR_WIDTH -> Width of the bus address  
*
* Author:
* email :	vidkar.delgado@cinvestav.mx
* Date  :	05/07/2020
******************************************************************/


module convolution_processor_MEMH #(
		parameter DATA_WIDTH= 8,
		parameter ADDR_WIDTH= 4,
		parameter TXT_FILE= "memX.txt"
)(
		input  logic                  clk, 		
		input  logic [ADDR_WIDTH-1:0] read_addr_i,
		output logic [DATA_WIDTH-1:0] read_data_o	   
);

// signal declaration
reg [DATA_WIDTH-1:0] ROM_structure [2**ADDR_WIDTH-1:0]; 

initial begin  //load hexadecimal data in txt
		$readmemh(TXT_FILE, ROM_structure);		
end

//write and read operations
always_ff @ (posedge clk) begin		

		read_data_o <= ROM_structure[read_addr_i];

end

endmodule

