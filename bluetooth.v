module bluetooth(
    input iClk,                 //100MHz时钟
	input iRX,                  //RX端收到的电平信号
	output reg [7: 0] oData,   //整合后的一字节数据
	output oState              //数据传输状态
);

	parameter bps = 10417;//根据波特率确定的单帧时间
    reg data_in_dly0, data_in_dly1, data_in_dly2;//使用三个bit实现下降沿判断
    wire negedgeDetect;//下降沿标志
    reg uart_state;//数据传输状态
    reg [15: 0] cnt1;//计数器，为了间隔bps个时钟周期读取一次数据
    reg [3:0] cnt2;//计数器，读到的bit数
        
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