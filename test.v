`timescale 1ns / 1ps

module dual_counter_tb;

    reg clk;
    reg rst;
    wire [30:0] count1;
    wire [3:0] count2;

    ClockControl uut (
        .clk(clk),
        .rst(rst),
        .count1(count1),
        .count2(count2)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    initial begin
        rst = 1;
        #100;
        rst = 0;

        #1000;

        $finish;
    end

endmodule