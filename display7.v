module display7(
    input [3:0] iDigit,
    output reg[6:0] oLed
    );
    always @(*)
    begin
      case(iDigit)
            4'b0000: oLed<=7'b1000000;
            4'b0001: oLed<=7'b1111001;
            4'b0010: oLed<=7'b0100100;
            4'b0011: oLed<=7'b0110000;
            4'b0100: oLed<=7'b0011001;
            4'b0101: oLed<=7'b0010010;
            4'b0110: oLed<=7'b0000010;
            4'b0111: oLed<=7'b1111000;
            4'b1000: oLed<=7'b0000000;
            4'b1001: oLed<=7'b0010000;
            4'b1010: oLed<=7'b1110111;//����
            4'b1011: oLed<=7'b0111111;//����
            4'b1100: oLed<=7'b1111110;//����
            default: oLed<=7'b1111111;
        endcase
    end
endmodule
