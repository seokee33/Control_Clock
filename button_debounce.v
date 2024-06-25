`timescale 1ns / 1ps
module button_debounce (
    input clk,        
    input rst,        
    input button_in,  
    output reg button_out  
);

    parameter integer DEBOUNCE_TIME = 200000; 

    reg [19:0] counter;
    reg button_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            button_state <= 0;
            button_out <= 0;
        end else begin
            if (button_in != button_state) begin
                counter <= counter + 1;
                if (counter >= DEBOUNCE_TIME) begin
                    button_state <= button_in;
                    button_out <= button_in;
                    counter <= 0;
                end
            end else begin
                counter <= 0;
            end
        end
    end

endmodule