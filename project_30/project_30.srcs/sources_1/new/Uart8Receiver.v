`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2024 13:56:20
// Design Name: 
// Module Name: Uart8Receiver
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


module Uart8Receiver (
    input  wire       clk,  // baud rate
    input  wire       en,
    input  wire       in,   // rx
    output reg        pwm_out, // PWM output
    output reg        done, // end on transaction
    output reg        busy, // transaction is in process
    output reg        err   // error while receiving data
);

    // states of state machine
    reg [1:0] RESET = 2'b00;
    reg [1:0] IDLE = 2'b01;
    reg [1:0] DATA_BITS = 2'b10;
    reg [1:0] STOP_BIT = 2'b11;

    reg [2:0] state;
    reg [2:0] bitIdx = 3'b0; // for 8-bit data
    reg [1:0] inputSw = 2'b0; // shift reg for input signal state
    reg [3:0] clockCount = 4'b0; // count clocks for 16x oversample
    reg [7:0] receivedData = 8'b0; // temporary storage for input data
    reg [7:0] heldData; // hold received data until the next start bit

    initial begin
        pwm_out <= 1'b0;
        err <= 1'b0;
        done <= 1'b0;
        busy <= 1'b0;
    end

    always @(posedge clk) begin
        inputSw = { inputSw[0], in };

        if (!en) begin
            state <= RESET;
        end

        case (state)
            RESET: begin
                pwm_out <= 1'b0;
                err <= 1'b0;
                done <= 1'b0;
                busy <= 1'b0;
                bitIdx <= 3'b0;
                clockCount <= 4'b0;
                receivedData <= 8'b0;
                heldData <= 8'b0;
                if (en) begin
                    state <= IDLE;
                end
            end

            IDLE: begin
                done <= 1'b0;
                if (&clockCount) begin
                    state <= DATA_BITS;
                    pwm_out <= receivedData[7]; // Convert MSB of received data to PWM
                    bitIdx <= 3'b0;
                    clockCount <= 4'b0;
                    receivedData <= 8'b0;
                    busy <= 1'b1;
                    err <= 1'b0;
                end else if (!(&inputSw) || |clockCount) begin
                    // Check bit to make sure it's still low
                    if (&inputSw) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                    clockCount <= clockCount + 4'b1;
                end
            end

            // Wait 8 full cycles to receive serial data
            DATA_BITS: begin
                if (&clockCount) begin // save one bit of received data
                    clockCount <= 4'b0;
                    // TODO: check the most popular value
                    receivedData[bitIdx] <= inputSw[0];
                    if (&bitIdx) begin
                        bitIdx <= 3'b0;
                        state <= STOP_BIT;
                    end else begin
                        bitIdx <= bitIdx + 3'b1;
                    end
                end else begin
                    clockCount <= clockCount + 4'b1;
                end
            end

            /*
            * Baud clock may not be running at exactly the same rate as the
            * transmitter. Next start bit is allowed on at least half of stop bit.
            */
            STOP_BIT: begin
                if (&clockCount || (clockCount >= 4'h8 && !(|inputSw))) begin
                    state <= IDLE;
                    done <= 1'b1;
                    busy <= 1'b0;
                    pwm_out <= heldData[7]; // Convert MSB of held data to PWM
                    heldData <= receivedData; // Store received data to hold for next iteration
                    clockCount <= 4'b0;
                end else begin
                    clockCount <= clockCount + 1;
                    // Check bit to make sure it's still high
                    if (!(|inputSw)) begin
                        err <= 1'b1;
                        state <= RESET;
                    end
                end
            end

            default: state <= IDLE;
        endcase
    end

endmodule

