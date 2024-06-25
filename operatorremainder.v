`timescale 1ns / 1ps

module operatorremainder(
    input [35:0] n,
    output reg is_multiple
);
	parameter DIVISOR = 20000000;
	reg [35:0] temp;
	reg [35:0] quotient;
	reg [35:0] remainder;
	integer i;
	always @(*) begin

 

        temp = n;
        quotient = 0;
        remainder = 0;

        // temp를 DIVISOR와 비교하여 bitwise로 나누기 연산
        for (i = 35; i >= 0; i = i - 1) begin
            quotient = (quotient << 1) | (temp[i] ? 1'b1 : 1'b0);
            if (quotient >= DIVISOR) begin
                quotient = quotient - DIVISOR;
                remainder = (remainder << 1) | 1'b1;
            end else begin
                remainder = (remainder << 1);
            end
        end

        // 나머지가 0인지 확인
        is_multiple = (quotient == 0);
    end
endmodule
