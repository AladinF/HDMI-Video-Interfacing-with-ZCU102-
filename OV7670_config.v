`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25/08/2021 18:04:03 AM
// Design Name: 
// Module Name: SCCB_interface
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


module OV7670_config #(
	parameter CLK_FREQ = 25000000
	)(
	input clk,    // Clock
	input clk_en, // Clock Enable
	input rst_n,  // Asynchronous reset active low
	input SCCB_interface_ready,
	input [15:0] rom_data,
	input start,
	output reg [7:0] rom_addr,
	output reg done,
	output reg [7:0] SCCB_interface_addr,
	output reg [7:0] SCCB_interface_data,
	output reg SCCB_interface_start
);

	//typedef enum bit[1:0] {IDLE, SEND_CMD, DONE, TIMER} fsm_state;
    localparam IDLE ='b00;
    localparam SEND_CMD ='b01;
    localparam DONE ='b10;
    localparam TIMER ='b11;
    
	reg [1:0] state;
	reg [1:0] return_state;
	reg [31:0] timert;

	always @(posedge clk or negedge rst_n) begin : proc_state
		if(~rst_n) begin
			state <= IDLE;
		end 
		else if(clk_en) begin
			case (state)
				IDLE:   
				    begin
                       state <= start ? SEND_CMD : IDLE;
                    end
				SEND_CMD: 
				    begin
					    case (rom_data)
                            16'hFFFF: 
                                begin
                                    state <= DONE;
                                end
                            16'hFFF0: 
                                begin
                                    state <= TIMER;
                                end
                            default: 
                                begin
                                    if (SCCB_interface_ready) begin
                                        state <= TIMER;
                                    end
                                end 
					    endcase
				    end
				DONE: 
                    begin
                        state <= IDLE;
                    end
				TIMER: 
                    begin
                        state <= (timert == 0) ? return_state : TIMER;
                    end
				default : 
                    begin
                        // do nothing
                    end
			endcase
		end
	end


	always @(posedge clk or negedge rst_n) begin : proc_return_state
		if(~rst_n) begin
			return_state <= IDLE;
		end 
		else if(clk_en) begin
			case (state)
				IDLE: 
                    begin
                        // do nothing
                    end
				SEND_CMD: 
                    begin
                        case (rom_data)
                            16'hFFFF: 
                                begin
                                    // do nothing
                                end
                            16'hFFF0: 
                                begin
                                    return_state <= SEND_CMD;
                                end
                            default: 
                                begin
                                    if (SCCB_interface_ready) begin
                                        return_state <= SEND_CMD;
                                    end
                                end 
                        endcase
                    end
				DONE: 
                    begin
                        // do nothing
                    end
				TIMER: 
                    begin
                        // do nothing
                    end
				default : 
                    begin
                        // do nothing
                    end
			endcase
		end
	end


	always @(posedge clk or negedge rst_n) begin : proc_rom_addr
		if(~rst_n) begin
			rom_addr <= 0;
		end 
		else if(clk_en) begin
			case (state)
				IDLE: 
                    begin
                        rom_addr <= 0;
                    end
				SEND_CMD: 
                    begin
                        case (rom_data)
                            16'hFFFF: 
                                begin
                                    // do nothing
                                end
                            16'hFFF0: 
                                begin
                                    rom_addr <= rom_addr + 1;
                                end
                            default: 
                                begin
                                    if (SCCB_interface_ready) begin
                                        rom_addr <= rom_addr + 1;
                                    end
                                end 
                        endcase
                    end
				DONE: 
                    begin
                        // do nothing
                    end
				TIMER: 
                    begin
                        // do nothing
                    end
				default: 
                    begin
                        // do nothing
                    end
			endcase
		end
	end


	always @(posedge clk or negedge rst_n) begin : proc_done
		if(~rst_n) begin
			done <= 0;
		end 
		else if(clk_en) begin
			case (state)
				IDLE: 
                    begin
                        done <= start ? 0 : done;
                    end
				SEND_CMD: 
                    begin
                        // do nothing
                    end
				DONE: 
                    begin
                        done <= 1;
                    end
				TIMER: 
                    begin
                        // do nothing
                    end
				default : 
                    begin
                        // do nothing
                    end
			endcase
		end
	end


	always @(posedge clk or negedge rst_n) begin : proc_SCCB_interface_addr
		if(~rst_n) begin
			SCCB_interface_addr <= 0;
		end 
		else if(clk_en) begin
			case (state)
				IDLE: 
                    begin
                        // do nothing
                    end
				SEND_CMD: 
                    begin
                        case (rom_data)
                            16'hFFFF: 
                                begin
                                    // do nothing
                                end
                            16'hFFF0: 
                                begin
                                    // do nothing
                                end
                            default: 
                                begin
                                    if (SCCB_interface_ready) begin
                                        SCCB_interface_addr <= rom_data[15:8];
                                    end
                                end 
                        endcase
                    end
				DONE: 
                    begin
                        // do nothing
                    end
				TIMER: 
                    begin
                        // do nothing
                    end
				default : 
                    begin
                        // do nothing
                    end
			endcase
		end
	end


	always @(posedge clk or negedge rst_n) begin : proc_SCCB_interface_data
		if(~rst_n) begin
			SCCB_interface_data <= 0;
		end 
		else if(clk_en) begin
			case (state)
				IDLE: 
                    begin
                        // do nothing
                    end
				SEND_CMD: 
                    begin
                        case (rom_data)
                            16'hFFFF: 
                                begin
                                    // do nothing
                                end
                            16'hFFF0: 
                                begin
                                    // do nothing
                                end
                            default: 
                                begin
                                    if (SCCB_interface_ready) begin
                                        SCCB_interface_data <= rom_data[7:0];
                                    end
                                end 
                        endcase
                    end
				DONE: 
                    begin
                        // do nothing
                    end
				TIMER: 
                    begin
                        // do nothing
                    end
				default : 
                    begin
                        // do nothing
                    end
			endcase
		end
	end

	always @(posedge clk or negedge rst_n) begin : proc_SCCB_interface_start
		if(~rst_n) begin
			SCCB_interface_start <= 0;
		end 
		else if(clk_en) begin
			case (state)
				IDLE: 
                    begin
                        // do nothing
                    end
				SEND_CMD: 
                    begin
                        case (rom_data)
                            16'hFFFF: 
                                begin
                                    // do nothing
                                end
                            16'hFFF0:
                                begin
                                    // do nothing
                                end
                            default: 
                                begin
                                    if (SCCB_interface_ready) begin
                                        SCCB_interface_start <= 1;
                                    end
                                end 
                        endcase
                    end
				DONE: 
                    begin
                        // do nothing
                    end
				TIMER: 
                    begin
                        SCCB_interface_start <= 0;
                    end
				default : 
                    begin
                        // do nothing
                    end
			endcase
		end
	end


	always @(posedge clk or negedge rst_n) begin : proc_timert
		if(~rst_n) begin
			timert <= 0;
		end 
		else if(clk_en) begin
			case (state)
				IDLE: 
                    begin
                        // do nothing
                    end
				SEND_CMD: 
                    begin
                        case (rom_data)
                            16'hFFFF: 
                                begin
                                    // do nothing
                                end
                            16'hFFF0: 
                                begin
                                    timert <= (CLK_FREQ/100);
                                end
                            default: 
                                begin
                                    if (SCCB_interface_ready) begin
                                        timert <= 0;
                                    end
                                end 
                        endcase
                    end
				DONE: 
                    begin
                        // do nothing
                    end
				TIMER: 
                    begin
                        timert <= (timert == 0) ? 0 : timert - 1;
                    end
				default : 
                    begin
                        // do nothing
                    end
			endcase
		end
	end

	
endmodule : OV7670_config