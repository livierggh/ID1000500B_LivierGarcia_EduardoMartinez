/******************************************************************
* Description
*
* This module performs a structural description where, through minimal blocks, 
* a convolution is carried out between the data stored in a ROM memory and an external RAM memory.
*
* Reset: Async active low
*
* Author: Mateo Martinez
* email : emms1408@gmail.com	
* Date  : 01/05/2024
	      DD/MM/YYYY	
******************************************************************/
module convolution_processor 
#(parameter DATA_Y_WIDTH = 8,
  parameter SIZE_Y_WIDTH = 5, 
  parameter MEMY_ADDR_WIDTH = 5, 
  parameter DATA_Z_WIDTH = 16, 
  parameter MEMZ_ADDR_WIDTH = 6)
(
	input  logic        clk,
	input  logic        rstn,
	input logic [DATA_Y_WIDTH-1:0] dataY_i,
	input logic [SIZE_Y_WIDTH-1:0] sizeY_i,
	input logic start_i, 
	
	output logic [MEMY_ADDR_WIDTH-1:0] memY_addr_o, 
	output logic [DATA_Z_WIDTH-1:0] dataZ_o,  
	output logic [MEMZ_ADDR_WIDTH-1:0] memZ_addr_o,
	output logic writeZ_o, 
	output logic busy_o, 
	output logic done_o
);

parameter DATA_H_WIDTH = 8; 
parameter ADDR_H_WITH = 6;
wire [DATA_H_WIDTH-1:0]dataH;

//******************************************
//			FSM wires
//******************************************

wire	comp_HZ_wire;         
wire	comp_YY_wire;        
wire	comp_shift_wire;       
    
wire	init_ctrl_wire; 	       
wire	done_ctrl_wire;        
wire	writeZ_ctrl_wire;      	
wire	clr_ctrl_wire; 
wire	shift_ctrl_wire;      	 
wire	convo_ctrl_wire;      	
wire	count_Y_ctrl_wire;      
wire	out_Z_ctrl_wire;  
wire	count_H_ctrl_wire;      
wire 	busy_ctrl_wire; 


//******************************************
//			sizeZ wires 
//******************************************
wire [4:0] sizeH;
assign sizeH = 5'd10;
wire [4:0]add_sizeZ_wire;  
wire [4:0]sub_sizeZ_wire; 
wire [4:0]sizeZ_wire;  
	
//******************************************
//			count H wires 
//******************************************
wire [5:0]add_memH_count_wire;  
wire [5:0] memH_count_wire; 

//******************************************
//			count Y wires 
//******************************************
wire [4:0]add_memY_count_wire;  
wire [4:0] memY_count_wire; 

//******************************************
//			shifted wires 
//******************************************
wire [5:0]sub_counts_wire;  
wire [5:0] shifted_wire; 

//******************************************
//comparator shifted>=0 && shifted < sizeH
//******************************************
wire comp_1_wire;  
wire comp_2_wire; 

//******************************************
//			convolution wires 
//******************************************
wire [DATA_Z_WIDTH-1:0] multi_wire;  
wire [DATA_Z_WIDTH-1:0] adder_convo_wire; 
wire [DATA_Z_WIDTH-1:0] dataZ_aux_wire;  


//******************************************
//			FSM instance 
//******************************************
convolution_processor_fsm FSM
(
	.clk			(clk), 
	.rstn			(rstn),
	.start_i		(start_i),
	
    .comp_HZ_i		(comp_HZ_wire), 
    .comp_YY_i		(comp_YY_wire),
    .comp_shift_i	(comp_shift_wire),   
    .init_ctrl_o	(init_ctrl_wire),	
    .done_ctrl_o    (done_o),    
    .writeZ_ctrl_o  (writeZ_o),
    .clr_ctrl_o     (clr_ctrl_wire),
    .shift_ctrl_o   (shift_ctrl_wire),
    .convo_ctrl_o   (convo_ctrl_wire), 
    .count_Y_ctrl_o (count_Y_ctrl_wire),
    .out_Z_ctrl_o   (out_Z_ctrl_wire),
    .count_H_ctrl_o (count_H_ctrl_wire),  
    .busy_ctrl_o    (busy_o)
); 

//******************************************
//			sizeZ instance
//******************************************
   convolution_processor_adder
   #(.DATA_WIDTH    (5)) ADD_SIZE_YH
   (
       .re_A      (sizeY_i),
       .re_B      (sizeH), 
       .re_out    (add_sizeZ_wire)
   );
   
    convolution_processor_adder
   #(.DATA_WIDTH    (5)) SUB_SIZE_YH
   (
       .re_A      (add_sizeZ_wire),
       .re_B      (5'b11111), //-1
       .re_out    (sub_sizeZ_wire)
   );
   
   	convolution_processor_register 
	#(.DATA_WIDTH(5)) SIZEZ_REG
	(
		.clk    (clk),     
		.rstn   (rstn),        
		.clrh   (1'b0),        
		.enh    (init_ctrl_wire),       
		.data_i (sub_sizeZ_wire),     
		.data_o (sizeZ_wire)     
	);


//******************************************
//			count H instance 
//******************************************
   convolution_processor_adder
   #(.DATA_WIDTH    (6)) ADD_MEMH_COUNT
   (
       .re_A      (6'b000001),
       .re_B      (memH_count_wire), 
       .re_out    (add_memH_count_wire)
   );
   
   	convolution_processor_register 
	#(.DATA_WIDTH(6)) MEMH_COUNT_REG
	(
		.clk    (clk),     
		.rstn   (rstn),        
		.clrh   (init_ctrl_wire),        
		.enh    (count_H_ctrl_wire),       
		.data_i (add_memH_count_wire),     
		.data_o (memH_count_wire)     
	);


//******************************************
//comparator memH_count < sizeZ instance
//******************************************
   convolution_processor_compLessThan
   #(.DATA_WIDTH    (6)) COMP_HZ_
   (
       .A_i      (memH_count_wire),
       .B_i      ({1'b0, sizeZ_wire}), 
       .A_less_than_B_o    (comp_HZ_wire)
   );


//******************************************
//comparator memY_count < sizeY instance 
//******************************************
   convolution_processor_compLessThan
   #(.DATA_WIDTH    (5)) COMP_YY_
   (
       .A_i      (memY_count_wire),
       .B_i      (sizeY_i), 
       .A_less_than_B_o    (comp_YY_wire)
   );


//******************************************
//			count Y instance 
//******************************************
   convolution_processor_adder
   #(.DATA_WIDTH    (5)) ADD_MEMY_COUNT
   (
       .re_A      (5'b00001),
       .re_B      (memY_count_wire), 
       .re_out    (add_memY_count_wire)
   );
   
   	convolution_processor_register 
	#(.DATA_WIDTH(5)) MEMY_COUNT_REG
	(
		.clk    (clk),     
		.rstn   (rstn),        
		.clrh   (clr_ctrl_wire),        
		.enh    (count_Y_ctrl_wire),       
		.data_i (add_memY_count_wire),     
		.data_o (memY_count_wire)     
	);


//******************************************
//			shifted instance 
//******************************************
    convolution_processor_sub
   #(.DATA_WIDTH    (6)) SUB_SHIFTED
   (
       .re_A      (memH_count_wire),
       .re_B      ({1'b0, memY_count_wire}), 
       .re_out    (sub_counts_wire) 
   );
   
   	convolution_processor_register 
	#(.DATA_WIDTH(6)) SHIFTED_REG
	(
		.clk    (clk),     
		.rstn   (rstn),        
		.clrh   (init_ctrl_wire),        
		.enh    (shift_ctrl_wire),       
		.data_i (sub_counts_wire),     
		.data_o (shifted_wire)     
	);


//******************************************
//comparator shifted>=0 && shifted < sizeH instance
//******************************************
   convolution_processor_compLessThan
   #(.DATA_WIDTH    (6)) COMP_SH_
   (
       .A_i      (shifted_wire),
       .B_i      ({1'b0, sizeH}), 
       .A_less_than_B_o    (comp_1_wire)
   );
   
      convolution_processor_compGreaterThan_Equal_zero
   #(.DATA_WIDTH    (6)) COMP_SZERO_
   (
       .A_i      (shifted_wire), 
       .A_less_than_B_o    (comp_2_wire)
   );
	
	convolution_processor_and AND_COMPS
	(
		.a_i	(comp_1_wire), 
		.b_i	(comp_2_wire), 
		.c_o	(comp_shift_wire)
	); 
	
//******************************************
//	    Memory H (ROM) instance
//******************************************
   	convolution_processor_MEMH 
	#(.DATA_WIDTH(DATA_H_WIDTH), 
	  .ADDR_WIDTH(ADDR_H_WITH), 
	  .TXT_FILE("/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_H")) MEMH_ROM
	(
		.clk    (clk), 
		.read_addr_i   (shifted_wire ),    
		.read_data_o   (dataH)        
	);

//******************************************
//    assign output memY_addr_o
//******************************************
assign memY_addr_o = memY_count_wire; 


//******************************************
//    convolution instance
//******************************************
	convolution_processor_mult
	#(.DATA_WIDTH(8)) MULTI_
	(
		.re_A 	(dataY_i), 
		.re_B	(dataH), 
		.re_out	(multi_wire)
	); 
	
	 convolution_processor_adder
   #(.DATA_WIDTH    (16)) ADD_CONVO_
   (
       .re_A      (multi_wire),
       .re_B      (dataZ_aux_wire), 
       .re_out    (adder_convo_wire)
   );
   
	convolution_processor_register 
	#(.DATA_WIDTH(16)) DATAZ_REG_AUX
	(
		.clk    (clk),     
		.rstn   (rstn),        
		.clrh   (clr_ctrl_wire),        
		.enh    (convo_ctrl_wire),       
		.data_i (adder_convo_wire),     
		.data_o (dataZ_aux_wire)     
	);

//******************************************
//    register Memory Z instance
//******************************************
   	convolution_processor_register 
	#(.DATA_WIDTH(16)) DATA_Z_OUT
	(
		.clk    (clk),     
		.rstn   (rstn),        
		.clrh   (1'b0),        
		.enh    (out_Z_ctrl_wire),       
		.data_i (dataZ_aux_wire),     
		.data_o (dataZ_o)     
	);
	
	   	convolution_processor_register 
	#(.DATA_WIDTH(6)) ADDR_Z_OUT
	(
		.clk    (clk),     
		.rstn   (rstn),        
		.clrh   (1'b0),        
		.enh    (out_Z_ctrl_wire),       
		.data_i (memH_count_wire),     
		.data_o (memZ_addr_o)     
	);
endmodule

