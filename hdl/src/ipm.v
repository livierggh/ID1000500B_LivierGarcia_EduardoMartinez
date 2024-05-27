module ipm
#(
    // Parameter Declarations
    parameter NUM_IPS = 1,
    parameter DATA_WIDTH_MCU = 8,
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH_IP = 32,
    parameter CTRL_WIDTH = 3,
    parameter CONF_WIDTH = 5
)
(
    input                           clk_n_Hz,
    input                           ipm_RstIn,
    
    // MCU
    inout   [DATA_WIDTH_MCU-1:0]    ipmMCUDataInout,
    input   [ADDR_WIDTH-1:0]        ipmMCUAddrsIn,
    input                           ipmMCURdIn,
    input                           ipmMCUWrIn,
    output                          ipmMCUINTOut,
    
    // IP
    input   [DATA_WIDTH_IP-1:0]     ipmPIPDataIn,
    output  [CONF_WIDTH-1:0]        ipmPIPConfOut,
    output                          ipmPIPReadOut,
    output                          ipmPIPWriteOut,
    output                          ipmPIPStartOut,
    output  [DATA_WIDTH_IP-1:0]     ipmPIPDataOut,
    input                           ipmPIPINTIn
);

    wire    [DATA_WIDTH_MCU-1:0]    wireDataIn;
    wire    [DATA_WIDTH_MCU-1:0]    wireDataOut;
    
    assign ipmMCUDataInout = (ipmMCURdIn && !ipmMCUWrIn) ? wireDataOut : {DATA_WIDTH_MCU{1'bz}};
    assign wireDataIn = ipmMCUDataInout;
    assign ipmMCUINTOut = ipmPIPINTIn;
    

    // Module Item(s)
    ipm_register
    #(
        .DATA_WIDTH_MCU(DATA_WIDTH_MCU),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH_IP(DATA_WIDTH_IP),
        .CONF_WIDTH(CONF_WIDTH),
        .CTRL_WIDTH(CTRL_WIDTH)
    )
    IPM_REG
    (
        .clk_n_Hz       (clk_n_Hz),
        .rst_async_low  (ipm_RstIn),
        // MCU
        .dataMCUOut     (wireDataOut),
        .dataMCUIn      (wireDataIn),
        .wr             (ipmMCUWrIn),
        .address        (ipmMCUAddrsIn),
        // IP
        .dataInIPo      (ipmPIPDataOut),
        .configIPo      (ipmPIPConfOut),
        .readIPo        (ipmPIPReadOut),
        .writeIPo       (ipmPIPWriteOut),
        .startIPo       (ipmPIPStartOut),
        .dataOutIPi     (ipmPIPDataIn)
        //.INTstatusIPi   (ipmTolINTstatus)
    );
    
endmodule
