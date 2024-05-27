`timescale 1ns/1ns

module ID1000500B_CONVOLUTION_PROCESSOR_TB();

            //----------------------------------------------------------
            //.......MANDATORY TB PARAMETERS............................
            //----------------------------------------------------------
localparam	CYCLE		    = 'd20, // Define the clock work cycle in ns (user)
            DATAWIDTH    = 'd32, // AIP BITWIDTH
            MAX_SIZE_MEM = 'd64,  // MAX MEMORY SIZE AMONG ALL AIP MEMORIES (Defined by the user)
            //------------------------------------------------------------
            //..................CONFIG VALUES.............................
            //------------------------------------------------------------           
            STATUS   = 5'd30,//Mandatory config
            IP_ID    = 5'd31,//Mandatory config


			// Config values defined in the CSV file
			MMEM_Y_IN  = 5'd0, 
			MMEM_Z_OUT = 5'd2,
			AMEM_Y_IN = 5'd1,
			AMEM_Z_OUT= 5'd3, 
			CREG_CONF_SIZEY = 5'd4, 
			AREG_CONF_SIZEY = 5'd5, 

            //------------------------------------------------------------
            //..................PARAMETERS DEFINED BY THE USER............
            //------------------------------------------------------------
			SIZE_MEM_Z     = 'd14,  //size mem Z with 10 and 5 values 
			INT_BIT_DONE = 'd0,
			sizeY = 5'd5;  

//AIP Interface signals
reg			 readAIP;
reg			 writeAIP;
reg			 startAIP;
reg	[ 4:0] configAIP;
reg	[DATAWIDTH-1:0] dataInAIP;

wire		    intAIP;
wire	[DATAWIDTH-1:0] dataOutAIP;

reg   clk, rst_a;  
reg en_s;

 //Auxiliar variables
reg [DATAWIDTH-1:0] dataSet [DATAWIDTH-1:0];
reg [DATAWIDTH-1:0] goldel_model_result [MAX_SIZE_MEM-1:0];

//Clock source procedural block
always #(CYCLE/2) clk = !clk;


//DUT instance
ID1000500B_CONVOLUTION_PROCESSOR
DUT
(
    .clk		(clk),
    .rst_a		(rst_a),
    .en_s		(en_s),
    .data_in	(dataInAIP),      //different data in information types
    .data_out	(dataOutAIP),     //different data out information types
    .write		(writeAIP),       //Used for protocol to write different information types
    .read		(readAIP),        //Used for protocol to read different information types
    .start		(startAIP),       //Used to start the IP core
    .conf_dbus	(configAIP),      //Used for protocol to determine different actions types
    .int_req	(intAIP)          //Interruption request
);

initial 
	begin
		$readmemh("/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_Y", dataSet);  //external memory address
		$readmemh("/home/ingemtz/project_SoC/IP_MODULE/Memorias/MEMORY_Z", goldel_model_result);  //memory with gold model result
	end


//Testbench stimulus
initial
   begin
      $display($time, " << Start Simulation >>");
      	aipReset();  
		convolution_task();
		#(CYCLE*400);
		$display($time, " << End Simulation >>");
		$stop;      
   end

task convolution_task;
   //Auxiliar variables

	reg [DATAWIDTH-1:0] tb_data;
	reg [DATAWIDTH*DATAWIDTH-1:0] dataSet_packed;

   reg [DATAWIDTH-1:0] result [MAX_SIZE_MEM-1:0];
   reg [DATAWIDTH*MAX_SIZE_MEM-1:0] result_packed;

 
	integer i;
	begin
        
		// READ IP_ID
        getID(tb_data);
        $display ("%7T Read ID %h", $time, tb_data);
        
        // READ STATUS
        getStatus(tb_data);
        $display ("%7T Read STATUS %h", $time, tb_data);

        //FOR ENABLING INTERRUPTIONS
        enableINT(INT_BIT_DONE);

        //**CONVERTION TO A SINGLE ARRAY
        for (i = 0; i < (DATAWIDTH) ; i=i+1) begin 
            dataSet_packed[DATAWIDTH*i+:DATAWIDTH] = dataSet[i]; 
        end        
        
        writeMem(MMEM_Y_IN, dataSet_packed, DATAWIDTH,0);
        
        //CONFIGURATION reg
        tb_data[4:0] = sizeY; 
        tb_data[DATAWIDTH-1:5] = 27'd0; 
        
        writeConfReg(CREG_CONF_SIZEY,tb_data,1,0);

        // START PROCESS
        $display("%7T Sending start", $time);
        start();

        // WAIT FOR DONE FLAG WITH INTERRUPTIONS ENABLED     
        while (intAIP) begin//checking intAIP signal
            #(CYCLE*10);
        end
        
        $display("%7T Done flag detected!", $time);
        
        // READ STATUS
        getStatus(tb_data);
        $display ("%7T Read STATUS %h", $time, tb_data);
       
        //CLEAR INT DONE FLAG
        clearINT(INT_BIT_DONE);
		
		// DISABLE INTERRUPTIONS
        disableINT(INT_BIT_DONE);
		
        // READ STATUS
        getStatus(tb_data);
        $display ("%7T Read STATUS %h", $time, tb_data);     


        // READ MEM OUT
        readMem(MMEM_Z_OUT, result_packed, DATAWIDTH, 0);
        //***CONVERTION TO A 2D ARRAY
        for (i = 0; i < (MAX_SIZE_MEM) ; i=i+1) begin 
            result[i]= result_packed[DATAWIDTH*i+:DATAWIDTH]; 
        end
        
		
		//comparison between the results of the golden model and the TB
        $display ("\t\tResult_TB \t\tRes_Golden_model \t\tCOMPARATION");
        for (i = 0; i < SIZE_MEM_Z; i=i+1) begin
            $display ("Read data %2d \t%8h \t\t\t%8h \t\t\t%s", i, goldel_model_result[i], result[i], (goldel_model_result[i] === result[i] ? "OK": "ERROR"));
        end

        #(CYCLE*15);
   
   end

endtask

//*********
//***AIP TASKS DEFINITION****
//*********

task aipReset;
   begin
      clk		= 1'b1;
      en_s		= 1'b1;
      readAIP	= 1'b0;
      writeAIP	= 1'b0;
      startAIP	= 1'b0;
      configAIP= 5'd0;
      dataInAIP= 32'd0;
      
      rst_a		= 1'b0;	// reset is active
      #3 rst_a	= 1'b1;	// at time #n release reset
      #37;
   end
endtask


task getID;
   output [DATAWIDTH-1:0] read_ID;
      
      begin
         single_read(IP_ID,read_ID);
      end
endtask

task getStatus;
   output [DATAWIDTH-1:0] read_status;
      
      begin
         single_read(STATUS,read_status);
      end
endtask

task writeMem;
        input [                         4:0] config_value;
        input [(DATAWIDTH*MAX_SIZE_MEM)-1:0] write_data;
        input [               DATAWIDTH-1:0] length;
        input [               DATAWIDTH-1:0] offset;

      integer i;
        begin        
            //SET POINTER
            single_write(config_value+1, offset);
            
            //WRITE MEMORY
            configAIP = config_value;
            #(CYCLE)
            for(i=0; i < length ; i= i+1) begin
               dataInAIP = write_data[(i*DATAWIDTH)+:DATAWIDTH];
               writeAIP = 1'b1;
               #(CYCLE);
            end
            writeAIP = 1'b0;
            #(CYCLE);
        end
endtask

task writeConfReg;
        input [                         4:0] config_value;
        input [(DATAWIDTH*MAX_SIZE_MEM)-1:0] write_data;
        input [               DATAWIDTH-1:0] length;
        input [               DATAWIDTH-1:0] offset;
        
        integer i;
        begin        
            //SET POINTER
            single_write(config_value+1, offset);
            
            //WRITE MEMORY
            configAIP = config_value;
            #(CYCLE)
            for(i=0; i < length ; i= i+1) begin
               dataInAIP = write_data[(i*DATAWIDTH)+:DATAWIDTH];
               writeAIP = 1'b1;
               #(CYCLE);
            end
            writeAIP = 1'b0;
            #(CYCLE);
        end
endtask



task readMem;
        input [                         4:0] config_value;   
        output[(DATAWIDTH*MAX_SIZE_MEM)-1:0] read_data;     
        input [               DATAWIDTH-1:0] length;
        input [               DATAWIDTH-1:0] offset;        
        
        integer i;
        begin
            //SET POINTER
            single_write(config_value+1, offset);
        
            configAIP = config_value;
            #(CYCLE)
            for(i=0; i < length ; i= i+1) begin               
               readAIP = 1'b1;
               #(CYCLE);
               read_data[(i*DATAWIDTH)+:DATAWIDTH]=dataOutAIP;
            end
            readAIP = 1'b0;
            #(CYCLE);
        end
endtask

task enableINT;
      input [3:0] idxInt;   
      
       reg [DATAWIDTH-1:0] read_status;
       reg [7:0] mask;
       
  begin

       getStatus(read_status);
       
       mask = read_status[23:16]; //previous stored mask
       mask[idxInt] = 1'b1; //enabling INT bit

       single_write(STATUS, {8'd0,mask,16'd0});//write status reg
  end
endtask

task disableINT;
      input [3:0] idxInt;   
      
       reg [DATAWIDTH-1:0] read_status;
       reg [7:0] mask;
  begin
   
       getStatus(read_status);
       
       mask = read_status[23:16]; //previous stored mask
       mask[idxInt] = 1'b0; //disabling INT bit

       single_write(STATUS, {8'd0,mask,16'd0});//write status reg
  end
endtask

task clearINT;
      input [3:0] idxInt;   
      
       reg [DATAWIDTH-1:0] read_status;
       reg [7:0] clear_value;
       reg [7:0] mask;
    
  begin
    
       getStatus(read_status);
       
       mask = read_status[23:16]; //previous stored mask
       clear_value = 7'd1 <<  idxInt;

       single_write(STATUS, {8'd0,mask,8'd0,clear_value});//write status reg
  end
endtask

task start;
  begin
      startAIP = 1'b1;
      #(CYCLE);
      startAIP = 1'b0;
      #(CYCLE);
  end
endtask

task single_write;
        input [          4:0] config_value;
        input [DATAWIDTH-1:0] write_data;
        begin
            configAIP = config_value;
            dataInAIP = write_data;
            #(CYCLE)
            writeAIP = 1'b1;
            #(CYCLE)
            writeAIP = 1'b0;
            #(CYCLE);
        end
endtask

task single_read;
  input  [          4:0] config_value;
  output [DATAWIDTH-1:0] read_data;
  begin
      configAIP = config_value;
      #(CYCLE);
      readAIP = 1'b1;
      #(CYCLE);
      read_data = dataOutAIP;
      readAIP = 1'b0;
      #(CYCLE);
  end
endtask

endmodule