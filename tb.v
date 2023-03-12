`timescale 1ns / 1ns
module tb(
    input iClk,
    input iRX,
    output[6:0] oLed,
    output[7:0] oEn,
    output reg light1,
    output reg light2,
    output light3,
    
    
    input DREQ,// sign for input
    output XDCS, // data control
    output XCS, // cmd control 
    output RSET, 
    output SI,  // data input
    output SCLK, // clk for VS1003B 
    output[3:0] curVolume
    );
    wire[7:0] data;
    wire state;
    bluetooth bluetooth_inst(.iClk(iClk),.iRX(iRX),.oData(data),.oState(state));
    display display_inst(.iData(data),.iState(state),.iClk(iClk),.oLed(oLed),.oEn(oEn));
    initial begin
        light1=0;
        light2=0;
    end
    //assign light3=iRX;
    always @(posedge iRX) begin
        light1=1;
    end
        always @(negedge iRX) begin
        light2=1;
    end
    mp3 mp3_inst(.CLK(iClk),.DREQ(DREQ),.RST(1),.iState(state),.vol(16'h7777-data[7:5]*16'h1111),.current(data[4:0]-data[4:0]/8-1),.XDCS(XDCS),.XCS(XCS),.RSET(RSET),.SI(SI),.SCLK(SCLK),
    .comingFlag(light3),
    .curVolume(curVolume));
endmodule
