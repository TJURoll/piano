module decoder(
    input [2:0] iCode,
    output reg [7:0] oSignal
    );
    always @(*) begin
        oSignal=8'b1111_1111;
        oSignal[iCode]=0;//Ê¹ÓÃ×èÈû¸³Öµ
    end
endmodule
