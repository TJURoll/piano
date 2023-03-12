module divider #(parameter Time=20)
(
    input I_CLK,
    output reg O_CLK
);
    integer counter=0;
    initial O_CLK = 0;
    always @ (posedge I_CLK)
    begin
        if((counter+1)==Time/2)
        begin
            counter <= 0;
            O_CLK <= ~O_CLK;
        end
        else
            counter <= counter+1;
    end
endmodule