`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/09/10 13:40:35
// Design Name: 
// Module Name: sccb_sender
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

module sccb_interface #(
	parameter CAMERA_ADDR = 'h42,
	parameter CLK_FREQ = 25000000,
	parameter SCCB_FREQ = 100000
	)(
	input clk,    // Clock
	input clk_en, // Clock Enable
	input rst_n,  // Asynchronous reset active low
	input start,
	input [7:0] address,
	input [7:0] data,
	output reg ready,
	output reg read_done,
	output reg sioc_signal,
	
	output reg [7:0] read_data,
	inout  siod_signal
);

    //typedef enum {IDLE, START_SIGNAL, LOAD_BYTE, TX_BYTE_1, TX_BYTE_2, TX_BYTE_3, TX_BYTE_4, RX_BYTE_1, RX_BYTE_2, RX_BYTE_3, RX_BYTE_4, END_SIGNAL_1, END_SIGNAL_2, END_SIGNAL_3, END_SIGNAL_4, ALL_DONE, TIMER} FSM_STATE;
    localparam IDLE ='d0, SEND_CMD ='d1, START_SIGNAL='d2, LOAD_BYTE='d3, TX_BYTE_1='d4, TX_BYTE_2='d5, TX_BYTE_3='d6, TX_BYTE_4='d7, RX_BYTE_1='d8, RX_BYTE_2='d9, RX_BYTE_3='d10, RX_BYTE_4='d11, END_SIGNAL_1='d12, END_SIGNAL_2='d13, END_SIGNAL_3='d14, END_SIGNAL_4='d15, ALL_DONE='d16, TIMER='d17;
    
    //typedef enum {WRITE, READ} FSM_ACTION;
    //typedef enum {FIRST_WRITE, SECOND_READ} READ_ORDER;
    localparam WRITE='d0, READ='d1;
    localparam FIRST_WRITE='d0, SECOND_READ='d1;
    
    reg [0:0] state;
	reg [0:0] return_state;
    wire [0:0] action;
    reg [0:0] order;
    
	reg [31:0] timer;
	reg [7:0] latched_address;
	reg [7:0] latched_data;
	reg [1:0] byte_counter;
	reg [7:0] tx_byte;
	reg [7:0] rx_byte;
	reg [3:0] byte_index;
    reg SIOD_oe;
    reg siod_temp;
    reg former_two_phase_write;

    assign siod_signal = SIOD_oe?1'bz:siod_temp;
    pullup p (siod_signal);

	assign action = address == 'hFE ? READ : WRITE;

	always @(posedge clk or negedge rst_n) begin : proc_state
    	if(~rst_n) begin
    		state <= IDLE;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
                        case (state)
                            IDLE: 
                                begin
                                    if (start || !former_two_phase_write) begin
                                        state <= TIMER;
                                    end
                                end
                            START_SIGNAL: 
                                begin
                                    state <= TIMER;
                                end
                            LOAD_BYTE: 
                                begin
                                    if (byte_counter == 2) begin
                                        state <= END_SIGNAL_1;
                                    end 
                                    else if(byte_counter == 1 && !former_two_phase_write) begin
                                        state <= RX_BYTE_1;
                                    end 
                                    else begin
                                        state <= TX_BYTE_1;
                                    end
                                end
                            TX_BYTE_1: 
                                begin
                                    state <= TIMER;
                                end
                            TX_BYTE_2: 
                                begin
                                    state <= TIMER;
                                end
                            TX_BYTE_3: 
                                begin
                                    state <= TIMER;
                                end
                            TX_BYTE_4: 
                                begin
                                    state <= (byte_index == 8) ? LOAD_BYTE : TX_BYTE_1;
                                end
                            RX_BYTE_1:
                                begin
                                    state <= TIMER;
                                end 
                            RX_BYTE_2:
                                begin
                                    state <= TIMER;
                                end 
                            RX_BYTE_3:
                                begin
                                    state <= TIMER;
                                end 
                            RX_BYTE_4:
                                begin
                                    state <= (byte_index == 8) ? END_SIGNAL_1 : RX_BYTE_1;
                                end 
                            END_SIGNAL_1: 
                                begin
                                    state <= TIMER;
                                end
                            END_SIGNAL_2: 
                                begin
                                    state <= TIMER;
                                end
                            END_SIGNAL_3: 
                                begin
                                    state <= TIMER;
                                end
                            END_SIGNAL_4: 
                                begin
                                    state <= TIMER;
                                end
                            ALL_DONE: 
                                begin
                                    state <= TIMER;
                                end
                            TIMER: 
                                begin
                                    state <= (timer == 0) ? return_state : TIMER;
                                end
                            default : 
                                begin
                                    state <= IDLE;
                                end
                        endcase
                    end
    			WRITE:
                    begin
                        case (state)
                            IDLE: 
                                begin
                                    if (start) begin
                                        state <= TIMER;
                                    end
                                end
                            START_SIGNAL: 
                                begin
                                    state <= TIMER;
                                end
                            LOAD_BYTE: 
                                begin
                                    state <= (byte_counter == 3) ? END_SIGNAL_1 : TX_BYTE_1;
                                end
                            TX_BYTE_1: 
                                begin
                                    state <= TIMER;
                                end
                            TX_BYTE_2: 
                                begin
                                    state <= TIMER;
                                end
                            TX_BYTE_3: 
                                begin
                                    state <= TIMER;
                                end
                            TX_BYTE_4: 
                                begin
                                    state <= (byte_index == 8) ? LOAD_BYTE : TX_BYTE_1;
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1: 
                                begin
                                    state <= TIMER;
                                end
                            END_SIGNAL_2: 
                                begin
                                    state <= TIMER;
                                end
                            END_SIGNAL_3: 
                                begin
                                    state <= TIMER;
                                end
                            END_SIGNAL_4: 
                                begin
                                    state <= TIMER;
                                end
                            ALL_DONE: 
                                begin
                                    state <= TIMER;
                                end
                            TIMER: 
                                begin
                                    state <= (timer == 0) ? return_state : TIMER;
                                end
                            default : 
                                begin
                                    state <= IDLE;
                                end
                        endcase   					
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
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE: 
                                begin
                                    return_state <= START_SIGNAL;
                                end
    						START_SIGNAL: 
                                begin
                                    return_state <= LOAD_BYTE;
                                end
    						LOAD_BYTE: 
                                begin
                                    // do nothing
                                end
    						TX_BYTE_1: 
                                begin
                                    return_state <= TX_BYTE_2;
                                end
    						TX_BYTE_2: 
                                begin
                                    return_state <= TX_BYTE_3;
                                end
    						TX_BYTE_3: 
                                begin
                                    return_state <= TX_BYTE_4;
                                end
    						TX_BYTE_4: 
                                begin
                                    // do nothing
                                end
        					RX_BYTE_1:
                                begin
                                    return_state <= RX_BYTE_2;
                                end 
        					RX_BYTE_2:
                                begin
                                    return_state <= RX_BYTE_3;
                                end 
        					RX_BYTE_3:
                                begin
                                    return_state <= RX_BYTE_4;
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1: 
                                begin
                                    return_state <= END_SIGNAL_2;
                                end
    						END_SIGNAL_2: 
                                begin
                                    return_state <= END_SIGNAL_3;
                                end
    						END_SIGNAL_3: 
                                begin
                                    return_state <= END_SIGNAL_4;
                                end
    						END_SIGNAL_4: 
                                begin
                                    return_state <= ALL_DONE;
                                end
    						ALL_DONE: 
                                begin
                                    return_state <= IDLE;
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
    			WRITE:
                    begin
    					case (state)
    						IDLE: 
                                begin
                                    return_state <= START_SIGNAL;
                                end
    						START_SIGNAL: 
                                begin
                                    return_state <= LOAD_BYTE;
                                end
    						LOAD_BYTE: 
                                begin
                                    //do nothing
                                end
    						TX_BYTE_1: 
                                begin
                                    return_state <= TX_BYTE_2;
                                end
    						TX_BYTE_2: 
                                begin
                                    return_state <= TX_BYTE_3;
                                end
    						TX_BYTE_3: 
                                begin
                                    return_state <= TX_BYTE_4;
                                end
    						TX_BYTE_4: 
                                begin
                                    // do nothing
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1: 
                                begin
                                    return_state <= END_SIGNAL_2;
                                end
    						END_SIGNAL_2: 
                                begin
                                    return_state <= END_SIGNAL_3;
                                end
    						END_SIGNAL_3: 
                                begin
                                    return_state <= END_SIGNAL_4;
                                end
    						END_SIGNAL_4: 
                                begin
                                    return_state <= ALL_DONE;
                                end
    						ALL_DONE: 
                                begin
                                    return_state <= IDLE;
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
    			default : 
                    begin
                        // do nothing
                    end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_timer
    	if(~rst_n) begin
    		timer <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
                        case (state)
                            IDLE: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            START_SIGNAL: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            LOAD_BYTE: 
                                begin
                                    // do nothing
                                end
                            TX_BYTE_1: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            TX_BYTE_2: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            TX_BYTE_3: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            TX_BYTE_4: 
                                begin
                                    // do nothing
                                end
                            RX_BYTE_1:
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end 
                            RX_BYTE_2:
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end 
                            RX_BYTE_3:
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            END_SIGNAL_2: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            END_SIGNAL_3: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            END_SIGNAL_4: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            ALL_DONE: 
                                begin
                                    timer <= (10*CLK_FREQ/SCCB_FREQ);
                                end
                            TIMER: 
                                begin
                                    timer <= (timer==0)?0:timer-1;
                                end
                            default : 
                                begin
                                    // do nothing
                                end
                        endcase
                    end
    			WRITE:
                    begin
                        case (state)
                            IDLE: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            START_SIGNAL: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            LOAD_BYTE: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            TX_BYTE_1: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            TX_BYTE_2: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            TX_BYTE_3: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            TX_BYTE_4: 
                                begin
                                    // do nothing
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            END_SIGNAL_2: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            END_SIGNAL_3: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            END_SIGNAL_4: 
                                begin
                                    timer <= (CLK_FREQ/(4*SCCB_FREQ));
                                end
                            ALL_DONE: 
                                begin
                                    timer <= (10*CLK_FREQ/SCCB_FREQ);
                                end
                            TIMER: 
                                begin
                                    timer <= (timer==0)?0:timer-1;
                                end
                            default : 
                                begin
                                    // do nothing
                                end
                        endcase   					
                    end
    			default : 
                    begin
                        // do nothing
                    end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_latched_address
    	if(~rst_n) begin
    		latched_address <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
    			    begin
                        case (state)
                            IDLE:
                                begin
                                    if (start) begin
                                        latched_address <= data;
                                    end
                                end
                            START_SIGNAL:
                                begin
                                    // do nothing
                                end
                            LOAD_BYTE:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_1:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_2:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_3:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_4:
                                begin
                                    // do nothing
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
                            ALL_DONE:
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
    			WRITE:
                    begin
                        case (state)
                            IDLE:
                                begin
                                    if (start) begin
                                        latched_address <= address;
                                    end
                                end
                            START_SIGNAL:
                                begin
                                    // do nothing
                                end
                            LOAD_BYTE:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_1:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_2:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_3:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_4:
                                begin
                                    // do nothing
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
                            ALL_DONE:
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
    			default :
                    begin
                        // do nothing
                    end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_latched_data
    	if(~rst_n) begin
    		latched_data <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                    
                                end 
        					RX_BYTE_2:
                                begin
                                    
                                end 
        					RX_BYTE_3:
                                begin
                                        
                                end 
        					RX_BYTE_4:
        					    begin
                                    
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    
                                end
    						TIMER:
                                begin
    							
    						    end
    						default :
                                begin
                                    
                                end
        				endcase
        			end
    			WRITE:
    			    begin
                        case (state)
                            IDLE:
                                begin
                                    if (start) begin								
                                        latched_data <= data;
                                    end
                                end
                            START_SIGNAL:
                                begin
                                    
                                end
                            LOAD_BYTE:
                                begin
                                    
                                end
                            TX_BYTE_1:
                                begin
                                    
                                end
                            TX_BYTE_2:
                                begin
                                    
                                end
                            TX_BYTE_3:
                                begin
                                    
                                end
                            TX_BYTE_4:
                                begin
                                    
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                
                                end
                            END_SIGNAL_2:
                                begin
                                
                                end
                            END_SIGNAL_3:
                                begin
                                    
                                end
                            END_SIGNAL_4:
                                begin
                                    
                                end
                            ALL_DONE:
                                begin
                                    
                                end
                            TIMER:
                                begin
                                    
                                end
                            default :
                                begin
                                    
                                end
                        endcase   					
                    end
    			default :
                    begin
                        // do nothing
                    end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_byte_counter
    	if(~rst_n) begin
    		byte_counter <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
                        case (state)
                            IDLE:
                                begin
                                    byte_counter <= 0;
                                end
                            START_SIGNAL:
                                begin
                                    // do nothing
                                end
                            LOAD_BYTE:
                                begin
                                    byte_counter <= byte_counter + 1;
                                end
                            TX_BYTE_1:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_2:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_3:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_4:
                                begin
                                    // do nothing
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
                            ALL_DONE:
                                begin
                                    byte_counter <= 0;
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
    			WRITE:
                    begin
                        case (state)
                            IDLE:
                                begin
                                    byte_counter <= 0;
                                end
                            START_SIGNAL:
                                begin
                                    // do nothing
                                end
                            LOAD_BYTE:
                                begin
                                    byte_counter <= byte_counter + 1;
                                end
                            TX_BYTE_1:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_2:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_3:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_4:
                                begin
                                    // do nothing
                                end
                            RX_BYTE_1:
                            begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                            begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                            begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                            begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
                            ALL_DONE:
                                begin
                                    byte_counter <= 0;
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
    			default :
                    begin
                        // do nothing
                    end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_tx_byte
    	if(~rst_n) begin
    		tx_byte <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
                        case (state)
                            IDLE:
                                begin
                                    // do nothing
                                end
                            START_SIGNAL:
                                begin
                                    // do nothing
                                end
                            LOAD_BYTE:
                                begin
                                    case (byte_counter)
                                        0: tx_byte <= CAMERA_ADDR + !former_two_phase_write;
                                        1: tx_byte <= latched_address;
                                        2: // do nothing
                                        ;
                                        default : // do nothing
                                        ;
                                    endcase
                                end
                            TX_BYTE_1:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_2:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_3:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_4:
                                begin
                                    tx_byte <= tx_byte<<1;
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
                            ALL_DONE:
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
    			WRITE:
                    begin
                        case (state)
                            IDLE:
                                begin
                                    if (start) begin
                                        // do nothing
                                    end
                                end
                            START_SIGNAL:
                                begin
                                    // do nothing
                                end
                            LOAD_BYTE:
                                begin
                                    case (byte_counter)
                                        0: tx_byte <= CAMERA_ADDR;
                                        1: tx_byte <= latched_address;
                                        2: tx_byte <= latched_data;
                                        default : // do nothing
                                        ;
                                    endcase
                                end
                            TX_BYTE_1:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_2:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_3:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_4:
                                begin
                                    tx_byte <= tx_byte<<1;
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
                            ALL_DONE:
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
    			default :
                    begin
                        // do nothing
                    end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_rx_byte
    	if(~rst_n) begin
    		rx_byte <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
                        case (state)
                            IDLE:
                                begin
                                    if (start) begin
                                        // do nothing
                                    end
                                end
                            START_SIGNAL:
                                begin
                                    // do nothing
                                end
                            LOAD_BYTE:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_1:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_2:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_3:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_4:
                                begin
                                    // do nothing
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    if (byte_index != 8) begin
                                        rx_byte[0] <= siod_signal;
                                    end
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    rx_byte <= rx_byte << 1;
                                end 
                            END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
                            ALL_DONE:
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
    			WRITE:
                    begin
                        case (state)
                            IDLE:
                                begin
                                    if (start) begin
                                        // do nothing
                                    end
                                end
                            START_SIGNAL:
                                begin
                                    // do nothing
                                end
                            LOAD_BYTE:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_1:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_2:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_3:
                                begin
                                    // do nothing
                                end
                            TX_BYTE_4:
                                begin
                                    // do nothing
                                end
                            RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
                            RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
                            END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
                            END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
                            ALL_DONE:
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
    			default :
                    begin
                        // do nothing
                    end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_byte_index
    	if(~rst_n) begin
    		byte_index <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    byte_index <= 0;
                                end
    						START_SIGNAL:
                                begin
                                    // do nothing
                                end
    						LOAD_BYTE:
                                begin
                                    byte_index <= 0;
                                end
    						TX_BYTE_1:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_2:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_3:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_4:
                                begin
                                    byte_index <= byte_index + 1;
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    byte_index <= byte_index + 1;
                                end 
    						END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
    						ALL_DONE:
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
    			WRITE:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    byte_index <= 0;
                                end
    						START_SIGNAL:
                                begin
                                    // do nothing
                                end
    						LOAD_BYTE:
                                begin
                                    byte_index <= 0;
                                end
    						TX_BYTE_1:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_2:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_3:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_4:
                                begin
                                    byte_index <= byte_index + 1;
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
    						ALL_DONE:
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
    			default :
                    begin
        				// do nothing
        			end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_sioc_signal
    	if(~rst_n) begin
    		sioc_signal <= 1;
    	end 
        else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    // do nothing
                                end
    						START_SIGNAL:
                                begin
                                    sioc_signal <= 1;
                                end
    						LOAD_BYTE:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_1:
                                begin
                                    sioc_signal <= 0;
                                end
    						TX_BYTE_2:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_3:
                                begin
                                    sioc_signal <= 1;
                                end
    						TX_BYTE_4:
                                begin
                                    // do nothing
                                end
        					RX_BYTE_1:
                                begin
                                    sioc_signal <= 0;
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    sioc_signal <= 1;
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    sioc_signal <= 0;
                                end
    						END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_3:
                                begin
                                    sioc_signal <= 1;
                                end
    						END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
    						ALL_DONE:
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
    			WRITE:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    // do nothing
                                end
    						START_SIGNAL:
                                begin
                                    sioc_signal <= 1;
                                end
    						LOAD_BYTE:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_1:
                                begin
                                    sioc_signal <= 0;
                                end
    						TX_BYTE_2:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_3:
                                begin
                                    sioc_signal <= 1;
                                end
    						TX_BYTE_4:
                                begin
                                    // do nothing
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    sioc_signal <= 0;
                                end
    						END_SIGNAL_2:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_3:
                                begin
                                    sioc_signal <= 1;
                                end
    						END_SIGNAL_4:
                                begin
                                    // do nothing
                                end
    						ALL_DONE:
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
    			default :
                    begin
                        // do nothing
                    end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_SIOD_oe
    	if(~rst_n) begin
    		SIOD_oe <= 1;
    	end 
        else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    if (start || !former_two_phase_write) begin
                                        SIOD_oe <= 0;
                                    end
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_1:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_2:
                                begin
                                    SIOD_oe <= byte_index == 8;
                                end
    						TX_BYTE_3:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_4:
                                begin
                                    // do nothing
                                end
        					RX_BYTE_1:
                                begin
                                    
                                end 
        					RX_BYTE_2:
                                begin
                                    SIOD_oe <= byte_index != 8;
                                end 
        					RX_BYTE_3:
                                begin
                                    
                                end 
        					RX_BYTE_4:
                                begin
                                    
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    SIOD_oe <= 0;
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                
                                end
    						ALL_DONE:
                                begin
                                    SIOD_oe <= 1;
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase
        			end
    			WRITE:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    if (start) begin
                                        SIOD_oe <= 0;
                                    end
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    SIOD_oe <= byte_index == 8;
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    SIOD_oe <= 0;
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    SIOD_oe <= 1;
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase   					
        			end
    			default :
                    begin
        				// do nothing
        			end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_siod_temp
    	if(~rst_n) begin
    		siod_temp <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    if (start || !former_two_phase_write) begin
                                        siod_temp <= 1;
                                    end
                                end
    						START_SIGNAL:
                                begin
                                    siod_temp <= 0;
                                end
    						LOAD_BYTE:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_1:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_2:
                                begin
                                    siod_temp <= tx_byte[7];
                                end
    						TX_BYTE_3:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_4:
                                begin
                                    // do nothing
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    if (byte_index == 8) begin
                                      siod_temp <= 1'b1;
                                    end
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_2:
                                begin
                                    siod_temp <= 1'b0;
                                end
    						END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_4:
                                begin
                                    siod_temp <= 1'b1;
                                end
    						ALL_DONE:
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
    			WRITE:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    if (start) begin
                                        siod_temp <= 1;
                                    end
                                end
    						START_SIGNAL:
                                begin
                                    siod_temp <= 0;
                                end
    						LOAD_BYTE:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_1:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_2:
                                begin
                                    siod_temp <= tx_byte[7];
                                end
    						TX_BYTE_3:
                                begin
                                    // do nothing
                                end
    						TX_BYTE_4:
                                begin
                                    // do nothing
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_2:
                                begin
                                    siod_temp <= 1'b0;
                                end
    						END_SIGNAL_3:
                                begin
                                    // do nothing
                                end
    						END_SIGNAL_4:
                                begin
                                    siod_temp <= 1'b1;
                                end
    						ALL_DONE:
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
    			default :
                    begin
        				// do nothing
        			end
    		endcase
    	end
    end

    always @(posedge clk or negedge rst_n) begin : proc_read_data
    	if(~rst_n) begin
    		read_data <= 0;
    	end 
        else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
    
                                end 
        					RX_BYTE_2:
                                begin
                                    
                                end 
        					RX_BYTE_3:
                                begin
                                    if (byte_index == 7) begin
                                        read_data <= rx_byte;
                                    end
                                end 
        					RX_BYTE_4:
                                begin
                                    
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase
        			end
    			WRITE:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase   					
        			end
    			default :
                    begin
        				// do nothing
        			end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_read_done
    	if(~rst_n) begin
    		read_done <= 0;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                        
                                end 
        					RX_BYTE_2:
                                begin
                                    
                                end 
        					RX_BYTE_3:
                                begin
                                    
                                end 
        					RX_BYTE_4:
                                begin
                                    
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    read_done <= 1;
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    
                                end
    						TIMER:
                                begin
                                    read_done <= 0;
                                end
    						default :
                                begin
                                    
                                end
        				endcase
        			end
    			WRITE:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    if (start) begin
                                        
                                    end
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase   					
        			end
    			default :
                    begin
        				// do nothing
        			end
    		endcase
    	end
    end

	always @(posedge clk or negedge rst_n) begin : proc_ready
    	if(~rst_n) begin
    		ready <= 1;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    if (start || !former_two_phase_write) begin
                                        ready <= 0;
                                    end 
                                    else begin
                                        ready <= 1;
                                    end
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                    
                                end 
        					RX_BYTE_2:
                                begin
                                    
                                end 
        					RX_BYTE_3:
                                begin
                                    
                                end 
        					RX_BYTE_4:
                                begin
                                    
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase
        			end
    			WRITE:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    if (start) begin
                                        ready <= 0;
                                    end 
                                    else begin
                                        ready <= 1;
                                    end
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase   					
        			end
    			default :
                    begin
        				// do nothing
        			end
    		endcase
    	end
    end

    always @(posedge clk or negedge rst_n) begin : proc_order
    	if(~rst_n) begin
    		order <= FIRST_WRITE;
    	end 
    	else if(clk_en) begin
    		case (action)
    			READ:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                    
                                end 
        					RX_BYTE_2:
                                begin
                                    
                                end 
        					RX_BYTE_3:
                                begin
                                    
                                end 
        					RX_BYTE_4:
                                begin
                                    
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    case (order)
                                        FIRST_WRITE: order <= SECOND_READ;
                                        SECOND_READ: order <= FIRST_WRITE;
                                        default:order <= FIRST_WRITE;
                                    endcase
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase
        			end
    			WRITE:
                    begin
    					case (state)
    						IDLE:
                                begin
                                    
                                end
    						START_SIGNAL:
                                begin
                                    
                                end
    						LOAD_BYTE:
                                begin
                                    
                                end
    						TX_BYTE_1:
                                begin
                                    
                                end
    						TX_BYTE_2:
                                begin
                                    
                                end
    						TX_BYTE_3:
                                begin
                                    
                                end
    						TX_BYTE_4:
                                begin
                                    
                                end
        					RX_BYTE_1:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_2:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_3:
                                begin
                                    // do nothing
                                end 
        					RX_BYTE_4:
                                begin
                                    // do nothing
                                end 
    						END_SIGNAL_1:
                                begin
                                    
                                end
    						END_SIGNAL_2:
                                begin
                                    
                                end
    						END_SIGNAL_3:
                                begin
                                    
                                end
    						END_SIGNAL_4:
                                begin
                                    
                                end
    						ALL_DONE:
                                begin
                                    
                                end
    						TIMER:
                                begin
                                    
                                end
    						default :
                                begin
                                    
                                end
        				endcase   					
        			end
    			default :
                    begin
        				// do nothing
        			end
    		endcase
    	end
    end

endmodule : sccb_interface