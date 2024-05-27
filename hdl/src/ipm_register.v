//  | Registers    | Addrs     | Size (bits)   |       
//  --------------------------------------------
//  | regDataIn    | 0 - 3     | 8             |
//  | regDataOut   | 0 - 3     | 8             |
//  | regConf      | 4         | 5             |
//  | regCtrl      | 5         | 3             |

//  | regCtrl               |
//  -------------------------
//  |   2   |   1   |   0   |
//  | START | WRITE | READ  |

module ipm_register
#(
    parameter DATA_WIDTH_MCU = 8,
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH_IP = 32,
    parameter CTRL_WIDTH = 3,
    parameter CONF_WIDTH = 5
)

(
    input                                   clk_n_Hz,
    input                                   rst_async_low,
    
    // MCU
    output  [DATA_WIDTH_MCU-1:0]            dataMCUOut,
    input   [DATA_WIDTH_MCU-1:0]            dataMCUIn,
    input                                   wr,
    input   [ADDR_WIDTH-1:0]                address,
    
    // IP
    output  [DATA_WIDTH_IP-1:0]             dataInIPo,
    output  [CONF_WIDTH-1:0]                configIPo,
    output                                  readIPo,
    output                                  writeIPo,
    output                                  startIPo,
    
    input   [DATA_WIDTH_IP-1:0]             dataOutIPi
    //input                                       INTstatusIPi
);

    reg     [DATA_WIDTH_MCU-1:0]            regDataIn   [0:3];
    reg     [DATA_WIDTH_MCU-1:0]            regDataOut  [0:3];
    reg     [CONF_WIDTH-1:0]                regConf;
    reg     [CTRL_WIDTH-1:0]                regCtrl;
    reg                                     enCtrl;
    reg     [2:0]                           edge_mem_wr;
    reg                                     regWRIP;
    reg     [2:0]                           edge_mem_rd;
    reg                                     regRDIP;
    reg     [2:0]                           edge_mem_st;
    reg                                     regSTIP;
    
    assign dataMCUOut = (address < 'd4)     ? regDataOut[address] :
                        (address == 'd4)    ? regConf   :
                        (address == 'd5)    ? regCtrl   : {DATA_WIDTH_MCU{1'b0}};

    // Dato del MCU hacia el IP
    always@(posedge clk_n_Hz or negedge rst_async_low) begin
        if (!rst_async_low) begin
            regDataIn [0] <= {DATA_WIDTH_MCU{1'b0}};
            regDataIn [1] <= {DATA_WIDTH_MCU{1'b0}};
            regDataIn [2] <= {DATA_WIDTH_MCU{1'b0}};
            regDataIn [3] <= {DATA_WIDTH_MCU{1'b0}};
        end
        else if(wr && address < 'd4)
            regDataIn [address] <= dataMCUIn;
    end
    
    assign dataInIPo = {regDataIn[3], regDataIn[2], regDataIn[1], regDataIn[0]};
    
    // Dato de la IP hacia el MCU
    always@(posedge clk_n_Hz or negedge rst_async_low) begin
        if (!rst_async_low) begin
            regDataOut [0] <= {DATA_WIDTH_MCU{1'b0}};
            regDataOut [1] <= {DATA_WIDTH_MCU{1'b0}};
            regDataOut [2] <= {DATA_WIDTH_MCU{1'b0}};
            regDataOut [3] <= {DATA_WIDTH_MCU{1'b0}};
        end
        else if(readIPo) begin
            regDataOut [0] <= dataOutIPi[7:0];
            regDataOut [1] <= dataOutIPi[15:8];
            regDataOut [2] <= dataOutIPi[23:16];
            regDataOut [3] <= dataOutIPi[31:24];
        end
    end

    // Config 
    always@(posedge clk_n_Hz or negedge rst_async_low) begin
        if (!rst_async_low)
            regConf <= {CONF_WIDTH{1'b0}};
        else if(wr && address == 'd4)
            regConf <= dataMCUIn[CONF_WIDTH-1:0];
    end
    
    assign configIPo = regConf;

    // Señales de control (RD, WR, START)
    always@(posedge clk_n_Hz or negedge rst_async_low) begin
        if (!rst_async_low) begin
            regCtrl <= {CTRL_WIDTH{1'b0}};
        end
        else if(wr && address == 'd5) begin
            regCtrl <= dataMCUIn[CTRL_WIDTH-1:0];
        end
    end
    
    always@(posedge clk_n_Hz or negedge rst_async_low) begin
        if(!rst_async_low) begin
            edge_mem_wr <= 3'b0;
            regWRIP <= 1'b0; 
        end
        else begin
            edge_mem_wr <= {edge_mem_wr[1:0],regCtrl[1]};
            regWRIP <= edge_mem_wr[1] && !edge_mem_wr[2]; 
        end
    end
    
    always@(posedge clk_n_Hz or negedge rst_async_low) begin
        if(!rst_async_low) begin
            edge_mem_rd <= 3'b0;
            regRDIP <= 1'b0; 
        end
        else begin
            edge_mem_rd <= {edge_mem_rd[1:0],regCtrl[0]};
            regRDIP <= edge_mem_rd[1] && !edge_mem_rd[2]; 
        end
    end
        
    always@(posedge clk_n_Hz or negedge rst_async_low) begin
        if(!rst_async_low) begin
            edge_mem_st <= 3'b0;
            regSTIP <= 1'b0; 
        end
        else begin
            edge_mem_st <= {edge_mem_st[1:0],regCtrl[2]}; //new_data es la señal de entrada
            regSTIP <= edge_mem_st[1] && !edge_mem_st[2]; 
        end
    end
    
    assign readIPo  = regRDIP;
    assign writeIPo = regWRIP;
    assign startIPo = regSTIP;

endmodule
