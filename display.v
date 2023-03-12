module display(
    input[7:0] iData,//需要显示的数据
    input iState,
    input iClk,//数码管刷新时钟
    output [6:0] oLed,//数码管LED
    output [7:0] oEn//数码管使能
    );
    

    reg[2:0] cnt;//刷新计数器
    wire[3:0] curShow;

    reg[31:0] show;//数码管显示格式
    initial begin
    show=32'b1111_1111_1111_0000_1111_1111_1011_1011;
    cnt=0;
    end 
    /*将数据转为数码管显示格式*/
    always@(negedge iState) begin
        show[19:16]={1'b0,iData[7:5]};
        show[7:4]<=iData[4:0]/8+4'b1010;
        show[3:0]<=iData[4:0]%8;
    end
    /*数码管刷新*/
    divider #(.Time(200000)) divider_inst(iClk,newClk);
    always @(posedge newClk) begin
        if(cnt!=7)
            cnt<=cnt+1;
        else
            cnt=0;
    end
    decoder decoder_inst(.iCode({cnt}),.oSignal(oEn));    
    
    /*数码管显示*/
    assign curShow = show[((cnt+1)*4-1)-:4];
    display7 display7_inst(.iDigit(curShow),.oLed(oLed));
endmodule
