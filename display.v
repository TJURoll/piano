module display(
    input[7:0] iData,//��Ҫ��ʾ������
    input iState,
    input iClk,//�����ˢ��ʱ��
    output [6:0] oLed,//�����LED
    output [7:0] oEn//�����ʹ��
    );
    

    reg[2:0] cnt;//ˢ�¼�����
    wire[3:0] curShow;

    reg[31:0] show;//�������ʾ��ʽ
    initial begin
    show=32'b1111_1111_1111_0000_1111_1111_1011_1011;
    cnt=0;
    end 
    /*������תΪ�������ʾ��ʽ*/
    always@(negedge iState) begin
        show[19:16]={1'b0,iData[7:5]};
        show[7:4]<=iData[4:0]/8+4'b1010;
        show[3:0]<=iData[4:0]%8;
    end
    /*�����ˢ��*/
    divider #(.Time(200000)) divider_inst(iClk,newClk);
    always @(posedge newClk) begin
        if(cnt!=7)
            cnt<=cnt+1;
        else
            cnt=0;
    end
    decoder decoder_inst(.iCode({cnt}),.oSignal(oEn));    
    
    /*�������ʾ*/
    assign curShow = show[((cnt+1)*4-1)-:4];
    display7 display7_inst(.iDigit(curShow),.oLed(oLed));
endmodule
