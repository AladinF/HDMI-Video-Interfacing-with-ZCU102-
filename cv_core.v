`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Alaeddine Fennira
	     alaeddine.fennira@etu.sorbonne-universite.fr
// 
// Create Date: 31.07.2022 13:45:08
// Design Name: 
// Module Name: hdmi
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



module core #(
            parameter width = 640*2, //2 Bytes per pixel RGB444
            parameter height = 480,
			parameter hMaxCount = (640 + 16 + 96 + 48)*2,
			parameter vMaxCount = 480 + 10 + 2 + 33,
            
            localparam c_frame = hMaxCount * vMaxCount - 1
            )
            (
			input                         clk24,
			input        [7:0]	          din,
			input                         rst_n,
			
			output       [19:0]	          addr_mem0,
			output       [18:0]	          addr_mem1,
			output  reg [47:0]	          dout, //RGB - 3 bytes
			output  reg                  we,
			
			output                   core_end
			);
            	
	
	reg [18:0]	counter;
    reg [10:0] hor, ver;
    reg [19:0]	address_mem0;
	reg[18:0] address_mem1;
	reg [31:0] red0_c, green0_c, blue0_c,red1_c, green1_c, blue1_c; //before clipping
	reg [7:0] red0, green0, blue0,red1, green1, blue1;
	reg [7:0] u0,y0,v0,y1, c, d, e;
	integer count;
	reg step ;
    reg we_t;
    
    assign addr_mem0 = address_mem0;
    assign addr_mem1 = address_mem1;
    assign core_end = counter == c_frame;
    
    initial begin 
        address_mem1 <= 0;
        address_mem0 <= 0;
        count = 0;
    end
// counter - count per pixel - used for checking one frame processing ends.
    always @ (posedge clk24 or negedge rst_n) begin                                        
        if(~rst_n) begin
            counter <= 0;
        end 
        else begin
            if (counter == c_frame) begin
                counter <= 0;
            end 
            else begin
                counter <= counter + 1;
            end
        end
    end

// address_mem0 - address of pixel of input data

// address for ouput image's pixel - this will be shown on the monitor
    always @(posedge clk24 or negedge rst_n) begin : proc_address_mem0                                   
        if(~rst_n) begin
            address_mem0 <= 0;
        end 
        else begin
            if (hor < width && ver < height) begin
                address_mem0 <= hor + ver * width;
            end
            else begin 
                address_mem0 <= 0;
            end                              
        end
    end

    //assign address_mem0 =  ? (hor + ver * width) * 3 + count : 0;
     
    always @(posedge clk24 or negedge rst_n) begin : proc_hor_ver                                   
        if(~rst_n) begin
            hor <= 0;
            ver <= 0;
        end 
        else begin
            if (counter == c_frame) begin
                hor <= 0;
                ver <= 0;
            end 
            else begin
                    if (hor == hMaxCount - 1) begin
                        hor <= 0;
                        ver <= ver + 1;
                    end 
                    else begin
                        hor <= hor + 1;
                    end
            end
        end
    end    
    
//step - Controlling incrementation of hor and ver and counter
/*always @(posedge clk24 or negedge rst_n) begin : proc_step                                  
        if(~rst_n) begin
            step  <= 0;
        end 
        else begin
                if (count < 3) begin
                    step <= 0;
                end
                else begin
                    step <= 1;
                end
        end
end*/
// address for ouput image's pixel - this will be shown on the monitor
    always @(posedge clk24 or negedge rst_n) begin : proc_address_mem1                                   
        if(~rst_n) begin
            address_mem1 <= 0;
        end 
        else begin
            if (counter == c_frame) begin 
                address_mem1 <= 0;
            end 
            else begin
                if(step == 1) begin
                    address_mem1 <= address_mem1 + 1;
                end                                  
            end
        end
    end
    
// address for ouput image's pixel - this will be shown on the monitor
    always @(posedge clk24 or negedge rst_n) begin : proc_rgb                                   
        if(~rst_n) begin
            u0 = 0;
            y0 = 0;
            v0 = 0;
            y1 = 0;
        end 
        else begin
            if (hor < width && ver < height) begin
                case (count)
                    0:          begin 
                                    u0 = din;
                                    step <= 0; 
                                      
                                end
                    1:          begin 
                                    y0 = din; 
                                end
                    2:          begin 
                                    v0 = din;
                                    c = y0 - 16;
                                    d = u0 - 128; 
                                    e = v0 - 128; 
                                    
                                    red0_c   = (298 * c           + 409 * e + 128)>>8; //without clipping for now
                                    green0_c = (298 * c - 100 * d - 208 * e + 128)>>8;
                                    blue0_c  = (298 * c + 516 * d           + 128)>>8;
                                    // Clip operation
                                    if (red0_c >= 255) begin red0 = 8'b11111111; end else begin red0 = red0_c[7:0]; end
                                    if (green0_c >= 255) begin green0 = 8'b11111111; end else begin green0 = green0_c[7:0]; end
                                    if (blue0_c >= 255) begin blue0 = 8'b11111111; end else begin blue0 = blue0_c[7:0]; end 
                                    
                                end
                    3:          begin 
                                    y1 = din;
                                    c = y1 - 16;
                             
                                    red1_c   = (298 * c           + 409 * e + 128)>>8;
                                    green1_c = (298 * c - 100 * d - 208 * e + 128)>>8;
                                    blue1_c  = (298 * c + 516 * d           + 128)>>8;
                                    
                                    // Clip operation
                                    if (red1_c >= 255) begin red1 = 8'b11111111; end else begin red1 = red1_c[7:0]; end
                                    if (green1_c >= 255) begin green1 = 8'b11111111; end else begin green1 = green1_c[7:0]; end
                                    if (blue1_c >= 255) begin blue1 = 8'b11111111; end else begin blue1 = blue1_c[7:0]; end
                                   // dout = {red1,blue1,green1,red0,blue0,green0};
                                    
                                    step <= 1;
                                end                             
                    
                endcase
                if (count < 3) begin
                    count = count + 1;
                end
                else begin 
                    count = 0;
                end
       end
       /*else begin 
            dout = {8'b11111111,8'b11111111,0,8'b11111111,8'b11111111,0};
       end*/
   end
end 

// hdmi output pixel data
    always @(posedge clk24 or negedge rst_n) begin : proc_dout                                            
        if(~rst_n) begin
            dout <= 0;
        end 
        else begin
            //if (counter == c_frame) begin
            //if (counter >= width*height ) begin
            if (hor >= width || ver >= height) begin
                 //dout = {8'b11111111,8'b11111111,8'b0,8'b11111111,8'b11111111,8'b0};
                 dout = 48'b0;
            end 
            else begin
                if (step == 1) begin 
                    dout <= {red1,blue1,green1,red0,blue0,green0};     
                end 
            end
        end
    end

// write enable of vga output pixel
    always @(posedge clk24 or negedge rst_n) begin : proc_we                                             
        if(~rst_n) begin
            we <= 0;
            we_t <= 0;
        end 
        else begin
            we <= we_t;
            if (hor < width && ver < height) begin
                we_t <= 1'b1;
            end 
            else begin
                we_t <= 1'b0;
            end
        end
    end

    
endmodule // core