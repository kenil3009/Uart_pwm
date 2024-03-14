`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.03.2024 13:57:01
// Design Name: 
// Module Name: PWM_Generator
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


module PWM_Generator(
    input wire clk,
    input wire rst,
    input wire [7:0] duty_cycle, // Duty cycle in percentage (0 to 100)
    output reg pwm
);

reg [31:0] counter;
reg [7:0] threshold;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 32'b0;
        pwm <= 1'b0;
    end else begin
        counter <= counter + 1;
        if (counter == 32'd255) begin
            counter <= 32'b0;
            threshold <= duty_cycle;
        end
        pwm <= (counter < threshold);
    end
end

endmodule

