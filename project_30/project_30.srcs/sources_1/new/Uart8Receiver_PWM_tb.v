`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2024 13:57:41
// Design Name: 
// Module Name: Uart8Receiver_PWM_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Uart8Receiver_PWM_tb;

    reg clk;
    reg en;
    reg in;
    wire pwm_out;
    wire done;
    wire busy;
    wire err;

    // instantiate the UART module
    Uart8Receiver uart (
        .clk(clk),
        .en(en),
        .in(in),
        .pwm_out(pwm_out),
        .done(done),
        .busy(busy),
        .err(err)
    );

    // instantiate the PWM module
    reg [7:0] duty_cycle = 8'd75; // 75% duty cycle
    PWM_Generator pwm_gen (
        .clk(clk),
        .rst(1'b0), // No reset in testbench
        .duty_cycle(duty_cycle),
        .pwm(pwm_out)
    );

    initial begin
        clk = 0;
        en = 0;
        in = 0;

        // Test case 1: enable the receiver
        #10 en = 1;

        // Test case 2: send data byte 0xAA (10101010 in binary)
        // Assuming a clock frequency sufficient for UART baud rate
        // Adjust the timing and input accordingly for your specific baud rate
        #10 in = 1;
        #10 in = 0;
        #10 in = 1;
        #10 in = 0;
        #10 in = 1;
        #10 in = 0;
        #10 in = 1;
        #10 in = 0;

        // Stop the simulation after some delay
        #100 $finish;
    end

    // Clock generation
    always #5 clk = ~clk;

endmodule

