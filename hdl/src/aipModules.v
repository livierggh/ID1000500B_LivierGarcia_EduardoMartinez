
/*
-------------------------------------------------------------------------------------------------
|                                   STATUS/INTERRUPTION FLAGS                                   |
-------------------------------------------------------------------------------------------------
|     7     |     6     |     5     |     4     |     3     |     2     |     1     |     0     |
-------------------------------------------------------------------------------------------------
|     UD    |     UD    |     UD    |     UD    |     UD    |     UD    |     UD    |   Done    |
-------------------------------------------------------------------------------------------------
|     15    |     14    |     13    |     12    |     11    |     10    |     9     |     8     |
-------------------------------------------------------------------------------------------------
|     UD    |     UD    |     UD    |     UD    |     UD    |     UD    |     UD    |   Busy    |
-------------------------------------------------------------------------------------------------
UD = User Define
*/

module aipStatus
(
  clk,
  rst,
  enSet,
  dataIn,
  intIP,
  statusIP,
  dataStatus,
  intReq
);

  localparam REGWIDTH = 'd32;
  localparam STATUSFLAGS = 'd8;
  localparam INTFLAGS = 'd8;

  input clk;
  input rst;
  input enSet;
  input [REGWIDTH-1:0] dataIn;
  input [INTFLAGS-1:0] intIP;
  input [STATUSFLAGS-1:0] statusIP;
  output [REGWIDTH-1:0] dataStatus;
  output intReq;

  reg [STATUSFLAGS-1:0] regStatus;
  reg [INTFLAGS-1:0] regInt;
  wire [INTFLAGS-1:0] wireInt;
  reg [INTFLAGS-1:0] regMaskInt;
  wire [INTFLAGS-1:0] wireMaskInt;

  assign dataStatus = {8'h00, regMaskInt,regStatus, regInt};
  assign intReq = ~|(regInt & regMaskInt);
  assign wireInt = dataIn[7:0];
  assign wireMaskInt = dataIn[23:16];

  genvar i;
  generate
    for (i=0; i<STATUSFLAGS; i=i+1) begin : buff
      always @ (posedge clk or negedge rst) begin
        if(!rst)
          regStatus[i] <= 1'b0;
        else begin
          regStatus[i] <= statusIP[i];
        end
      end
      always @ (posedge clk or negedge rst) begin
        if(!rst)
          regInt[i] <= 1'b0;
        else begin
          if (wireInt[i] & enSet)
            regInt[i] <= 1'b0;
          else if (intIP[i])
            regInt[i] <= 1'b1;
          else
            regInt[i] <= regInt[i];
        end
      end
    end
  endgenerate

  always @(posedge clk or negedge rst) begin
    if(!rst)
      regMaskInt <= {INTFLAGS{1'b0}};
    else if(enSet)
      regMaskInt <= wireMaskInt;
  end
endmodule

module aipParametricMux
(
  data_in,
  sel,
  data_out
);

  parameter DATAWIDTH = 32;
  parameter SELBITS = 2;

  input [((2**SELBITS)*DATAWIDTH)-1:0] data_in;
  input [SELBITS-1:0] sel;
  output [DATAWIDTH-1:0] data_out;

  wire [DATAWIDTH-1:0] data_mux [0:((2**SELBITS)-1)];

  genvar index;
  generate
    for (index = 0; index < (2**SELBITS); index = index + 1) begin : MUX
      assign data_mux[index][DATAWIDTH-1:0] = data_in[(DATAWIDTH*index)+(DATAWIDTH-1):DATAWIDTH*index];
    end
  endgenerate

  assign data_out = data_mux[sel];
endmodule

module aipId
(
  clk,
  data_IP_ID
);

  parameter SIZE_REG = 'd32;
  parameter ID = 32'h00001001;

  input wire clk;
  output reg [SIZE_REG-1:0] data_IP_ID;

  always @(posedge clk)
      data_IP_ID <= ID;
endmodule

module aipConfigurationRegister
(
  reset,
  writeClock,
  writeEnable,
  writeAddress,
  dataInput,
  dataOutput
);
  parameter DATAWIDTH = 32;
  parameter REGISTERS = 4; // MAX 4

  localparam ADDRWIDTH = 3;

  input reset;
  input writeClock;
  input writeEnable;
  input [(ADDRWIDTH-1):0] writeAddress;
  input [(DATAWIDTH-1):0] dataInput;
  output wire [(((REGISTERS+1)*DATAWIDTH)-1):0] dataOutput;

  reg [(DATAWIDTH-1):0] regConfig [0:REGISTERS];
  reg [(DATAWIDTH-1):0] regConfigStreaming;

  assign dataOutput[(DATAWIDTH*REGISTERS) +: DATAWIDTH] = regConfigStreaming;

  genvar i;
  generate
  for (i=0; i<REGISTERS; i=i+1) begin: OUTPUTCONF
      assign dataOutput[(DATAWIDTH*i) +: DATAWIDTH] = regConfig[i];
  end
  endgenerate

  always @(posedge writeClock or negedge reset) begin
    if(!reset) begin : RESETREGCONF
      integer j;
      for (j=0; j<REGISTERS; j=j+1) begin
        regConfig[j] <= 'd0;
      end
      regConfigStreaming <= 'd0;
    end
    else begin
      if (writeEnable) begin
        if ('d4==writeAddress) begin
          regConfigStreaming <= dataInput;
        end
        else begin
          regConfig[writeAddress] <= dataInput;
        end
      end
    end
  end
endmodule

