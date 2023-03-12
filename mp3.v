module mp3(
	input CLK, // out clk 
	input DREQ,// sign for input
	input RST, // active low 
	input iState,
	input [15:0] vol,// vol control
	input [4: 0] current, // song choose
	output reg XDCS, // data control
	output reg XCS,  // cmd control 
	output reg RSET, 
	output reg SI,  // data input
	output reg SCLK, // clk for VS1003B 
	output reg comingFlag,
	output[3:0] curVolume
);

	// states 
	//_PRE states used to waite for DREQ 
	parameter CMD_PRE = 0;
	parameter WRITE_CMD = 1;
	parameter DATA_PRE = 2;
	parameter WRITE_DATA = 3;
	parameter DELAY = 4;
	parameter VOL_PRE = 5;
	parameter VOL_CHANGE = 6;
	parameter WAIT = 7;
	reg [2: 0] state=WAIT;
	
	// basic parameters
	parameter DELAY_TIME = 1;
	parameter CMD_NUM = 2;
	parameter ADDR_END=19;
	// 1M clk for mp3 
	wire clk_div;
	divider #(.Time(100)) CLKDIV(CLK, clk_div);
	
	// song select
	//reg[4: 0] pre=5'b00000;
	reg[4:0] addr;
	
	// ip core ROM
	//wire [15: 0] data0;
	wire [15: 0] data;
	reg [15: 0] _Data;
	
	//blk_mem_gen_0 your_instance_name(.clka(CLK),.ena(1),.addra(addr),.douta(data0));
	blk_mem_gen_1 your_instance_name1(.clka(CLK),.ena(1),.addra({current,addr}),.douta(data));
	/*blk_mem_gen_2 your_instance_name2(.clka(CLK),.ena(1),.addra(addr),.douta(data[1]));
	blk_mem_gen_3 your_instance_name3(.clka(CLK),.ena(1),.addra(addr),.douta(data[2]));
	blk_mem_gen_4 your_instance_name4(.clka(CLK),.ena(1),.addra(addr),.douta(data[3]));*/
	/*blk_mem_gen_5 your_instance_name5(.clka(CLK),.ena(1),.addra(addr),.douta(data[4]));
	blk_mem_gen_6 your_instance_name6(.clka(CLK),.ena(1),.addra(addr),.douta(data[5]));
	blk_mem_gen_7 your_instance_name7(.clka(CLK),.ena(1),.addra(addr),.douta(data[6]));*/
	// cmd register  {soft reset, vol}
	reg [63: 0] cmd = {32'h02000804, 32'h020BFFFF};
	reg [2: 0] cmd_cnt = 0;
	assign curVolume=cmd[3:0];
	// vars
	integer delay_cnt = 0;
	integer cnt = 0;
	reg [31: 0] cmd_vol;
	

	always@(negedge iState)
	   comingFlag<=~comingFlag;
    reg curFlag;
    initial begin
    comingFlag<=0;
    curFlag<=0;
    end
// ------------------------State Machine------------------------
	always @ (posedge clk_div) begin
		curFlag <= comingFlag;
		if(!RST || curFlag!=comingFlag) begin
		    cmd[15:0]<=vol;
			RSET <= 0;
			SCLK <= 0;
			XCS <= 1;
			XDCS <= 1;
			delay_cnt <= 0;
			state <= DELAY;
			cmd_cnt <= 0;
			addr <= 0;
			//pause_pre <= 0;
		end 
		else begin 
			case (state)
				CMD_PRE: begin 
						SCLK <= 0;
						if(cmd_cnt == CMD_NUM) begin
							state <= DATA_PRE;
						end
						else if(DREQ) begin 
							state <= WRITE_CMD;
							cnt <= 0;
						end 
					end
					
				WRITE_CMD: begin 
						if(DREQ) begin
							if(SCLK) begin 
								if(cnt==32) begin
									cmd_cnt <= cmd_cnt+1;
									XCS <= 1;
									state <= CMD_PRE;
									cnt <= 0;
								end 
								else begin
									XCS <= 0;
									SI <= cmd[63];
									cmd <= {cmd[62: 0], cmd[63]};
									cnt <= cnt+1;
								end 
							end 
							SCLK <= ~SCLK;
						end 
					end 
					
				DATA_PRE: begin
						// detect vol change 
						/*if(vol[15:0] != cmd[15: 0]) begin 
							state <= VOL_PRE;
							cmd_vol <= {16'h020B, vol};
							cmd[15: 0] <= vol[15: 0];
						end */
						//else
						 if(DREQ) begin 
							SCLK <= 0;
							state <= WRITE_DATA;
							_Data <= data;
							cnt <= 0;
						end 
					end 
					
				WRITE_DATA: begin 
						if(SCLK) begin 
							// 16 bits one process
							if(cnt == 16) begin 
								XDCS <= 1;
								if(addr!=ADDR_END) begin
								    addr <= addr+1;
								    state <= DATA_PRE;
								end
								else
								    state<=WAIT;
							end 
							else begin 
								XDCS <= 0;
								SI <= _Data[15];
								_Data <= {_Data[14:0], _Data[15]};
								cnt <= cnt+1;
							end 
						end 
						SCLK = ~SCLK;
					end 
				
				VOL_PRE: begin 
						if(DREQ) begin
							state <= VOL_CHANGE;
							cnt <= 0;
						end 
					end
					
				VOL_CHANGE: begin 
						if(DREQ) begin
							if(SCLK) begin 
								if(cnt==32) begin
									XCS <= 1;
									state <= DATA_PRE;
									cnt <= 0;
								end 
								else begin
									XCS <= 0;
									SI <= cmd_vol[31];
									cmd_vol <= {cmd_vol[30: 0], cmd_vol[31]};
									cnt <= cnt+1;
								end 
							end 
							SCLK <= ~SCLK;
						end 
					end 
					
				DELAY: begin 
						if(delay_cnt == DELAY_TIME) begin 
							delay_cnt <= 0;
							state <= CMD_PRE;
							RSET <= 1;
						end 
						else delay_cnt <= delay_cnt+1;
					end 
				default:;
				
			endcase
		end
	end 
endmodule