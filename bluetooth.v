module bluetooth(
    input iClk,                 //100MHzʱ��
	input iRX,                  //RX���յ��ĵ�ƽ�ź�
	output reg [7: 0] oData,   //���Ϻ��һ�ֽ�����
	output oState              //���ݴ���״̬
);

	parameter bps = 10417;//���ݲ�����ȷ���ĵ�֡ʱ��
    reg data_in_dly0, data_in_dly1, data_in_dly2;//ʹ������bitʵ���½����ж�
    wire negedgeDetect;//�½��ر�־
    reg uart_state;//���ݴ���״̬
    reg [15: 0] cnt1;//��������Ϊ�˼��bps��ʱ�����ڶ�ȡһ������
    reg [3:0] cnt2;//��������������bit��
        
    initial begin
        uart_state=1'b0;
        cnt1=16'h0000;
        cnt2=4'b0000;
        data_in_dly0 = 1'b1;
        data_in_dly1 = 1'b1;
        data_in_dly2 = 1'b1;
        oData=8'h00;
    end
        
        // asynchronous data in 
        always @ (posedge iClk) begin
                data_in_dly0 <= iRX;
                data_in_dly1 <= data_in_dly0;
                data_in_dly2 <= data_in_dly1;
            end
        
        // detect posedge
        assign negedgeDetect = ~data_in_dly1 & data_in_dly2;
        
        // bps cycle count
        always @ (posedge iClk) begin 
            if(uart_state) begin 
                if(cnt1 == bps-1) begin 
                    cnt1 <= 0;
                end
                else begin 
                    cnt1 <= cnt1+1;
                end
            end
        end
        
        // receive data bits count
        always @ (posedge iClk) begin 
            if(uart_state && cnt1==bps-1) begin
                if(cnt2 == 8) begin 
                    cnt2 <= 0;
                end
                else begin 
                    cnt2 <= cnt2+1;
                end
            end
        end
        
        // uart_state sign generate
        always @ (posedge iClk) begin 
            if(negedgeDetect) begin 
                uart_state <= 1;
            end
            else if(uart_state && cnt2==8 && cnt1==bps-1) begin
                uart_state <= 0;
            end
        end
        
        // data in 
        always @ (posedge iClk) begin 
            if(uart_state && cnt1==bps/2-1 && cnt2!=0) begin
                oData[cnt2-1] <= iRX;
            end
        end
        
        assign oState=uart_state;
        
    endmodule