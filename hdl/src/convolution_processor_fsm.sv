/******************************************************************
* Description
*
* SystemVerilog FSM for convolution processor
*
* Reset: Async active low
*
* Author: Mateo Martinez
* email : emms1408@gmail.com	
* Date  : 01/05/2024
	      DD/MM/YYYY	
******************************************************************/

module convolution_processor_fsm (
	input  logic	clk,
	input  logic   	rstn,

	input  logic	start_i,
	input  logic	comp_HZ_i,        
	input  logic	comp_YY_i,       
	input  logic	comp_shift_i,       
                    
	output logic	init_ctrl_o,	       
	output logic	done_ctrl_o,         
	output logic	writeZ_ctrl_o,       	
	output logic	clr_ctrl_o,       
	output logic	shift_ctrl_o,       	 
	output logic	convo_ctrl_o,        	
	output logic	count_Y_ctrl_o,       
	output logic	out_Z_ctrl_o,       
	output logic	count_H_ctrl_o,       
	output logic	busy_ctrl_o       

);

enum {S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7, S8=8, S9=9, S10=10, S11=11, S12=12, S13=13, S14=14, S15=15, S16=16, S17=17, S18=18, S19=19} state_t; //For FSM states

 logic [4:0]  state;
 logic [4:0]  next;
 
 //(1)State register
 always_ff@(posedge clk or negedge rstn)
     if(!rstn) state <= S0;                                            
     else      state <= next;

 //(2)Combinational next state logic
 always_comb begin
     next = state;
     unique case(state)
		S0: begin
			if(start_i) next = S1; 
			else	next = S0; 
		end
		S1: begin
			next = S2; 
		end
		S2: begin
			next = S3; 
		end
		S3: begin
			if(comp_HZ_i) next = S4; 
			else	next = S14; 
		end
		S4: begin
			next = S5; 
		end
		S5: begin
			if(comp_YY_i)	next = S6; 
			else	next = S10; 
		end
		S6: begin
			next = S7; 
			 
		end
		S7: begin
			if(comp_shift_i)	next = S8; 
			else	next = S9; 
		end
		S8: begin
			next = S9; 
		end
		S9: begin
			next = S5; 
		end
		S10: begin
			next = S11;  
		end
		S11: begin
			next = S12; 
		end
		S12: begin
			next = S13;
		end
		S13: begin
			next = S3;
		end
		S14: begin
			next = S15;
		end
		S15: begin
			next = S0;
		end
         default:        next = state;
     endcase
 end

 //(3)Registered output logic (Moore outputs)
 always_ff @(posedge clk or negedge rstn) begin
     if(!rstn) begin
		init_ctrl_o			<= 1'b0;
		done_ctrl_o         <= 1'b0;
		writeZ_ctrl_o       <= 1'b0;
		clr_ctrl_o          <= 1'b0;
		shift_ctrl_o        <= 1'b0;
		convo_ctrl_o        <= 1'b0;
		count_Y_ctrl_o      <= 1'b0;
		out_Z_ctrl_o        <= 1'b0;
		count_H_ctrl_o      <= 1'b0;
		busy_ctrl_o         <= 1'b0;
		                   
     end                    
     else begin             
         //First default values
		init_ctrl_o			<= 1'b0;
		done_ctrl_o         <= 1'b0;
		writeZ_ctrl_o       <= 1'b0;
		clr_ctrl_o          <= 1'b0;
		shift_ctrl_o        <= 1'b0;
		convo_ctrl_o        <= 1'b0;
		count_Y_ctrl_o      <= 1'b0;
		out_Z_ctrl_o        <= 1'b0;
		count_H_ctrl_o      <= 1'b0;
		busy_ctrl_o         <= 1'b1;
		
             unique case(next)
				S0: busy_ctrl_o		<= 1'b0;  								
				S1: ;    
				S2: init_ctrl_o 	<= 1'b1;  
				S3: ; 		   
				S4: clr_ctrl_o		<= 1'b1; 			   
				S5: ; 		
				S6:	shift_ctrl_o	<= 1'b1; 	
				S7:; 
				S8: convo_ctrl_o	<= 1'b1; 			   
				S9: count_Y_ctrl_o	<= 1'b1; 			   
				S10:out_Z_ctrl_o	<= 1'b1; 		    
				S11:writeZ_ctrl_o	<= 1'b1; 		   
				S12:writeZ_ctrl_o	<= 1'b0;
				S13:count_H_ctrl_o	<= 1'b1; 		    
				S14:begin
						busy_ctrl_o	<= 1'b0;  
						done_ctrl_o <= 1'b1; 
					end
				S15:begin
						busy_ctrl_o	<= 1'b0;  
						done_ctrl_o <= 1'b0; 
					end
                
             endcase
     end
 end
endmodule


