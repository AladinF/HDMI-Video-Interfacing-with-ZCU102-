`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/10/2022 04:39:48 PM
// Design Name: 
// Module Name: imageTest
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


/*module imageTest(
            input                         clk24,
			input                         rst_n,
			input        [19:0]	          addr, //unused 
			//input       [7:0]	          din , //unused 
			input            	          w , //unused 
			//output       [19:0]	          addr_mem0,			
			//output       [7:0]	          dout, //RGB - 3 bytes
			//output                    we
			output reg[19:0]	addr_mem0,
			output reg[7:0]	dout,
			output reg 		we
			);

    reg [19:0] address_mem0;
   
    reg [7:0] d;
    initial begin 
         address_mem0 <= 0;
         d <= 0;
         //counter <= 0;
    end

     
    always @(posedge clk24 or negedge rst_n) begin 
        if(~rst_n) begin
            d <= 0;
            dout <= 0;
            address_mem0 <= 0;
            we <= 1'b0;
        end else begin
            we <= 1'b1;
            if (address_mem0 < 640*480*3) begin
                if (d <= 240) begin //generate test pattern 
                    d = d + 10;
                    dout <= d;
                end
                else begin
                    d = 0;
                    dout <= d;
                end 
                address_mem0 <= address_mem0 + 1 ;  
                addr_mem0 <= address_mem0;   
            end
            else begin 
                address_mem0 <= 0;
                addr_mem0 <= address_mem0;
            end
        end
    end


    */
    

module imageTest#(
           	parameter width = 640/2, //2 Bytes per pixel RGB444
            parameter height = 480,
			parameter hMaxCount = 640/2 + 16 + 96 + 48,
			parameter vMaxCount = 480 + 10 + 2 + 33,
            /*parameter width = 4096, //2 Bytes per pixel RGB444
            parameter height = 2160,
			parameter hMaxCount = 4400,
			parameter vMaxCount = 2250,*/
            localparam c_frame = hMaxCount * vMaxCount/2 - 1
            )(
            input                         clk24,
			input                         rst_n,
			//input        [19:0]	          addr, //unused 
			//input       [7:0]	          din , //unused 
			//input            	          w , //unused 
			//output       [19:0]	          addr_mem0,			
			//output       [7:0]	          dout, //RGB - 3 bytes
			//output                    we
			output [18:0]	addr_mem0,
			output reg[47:0]	dout,
			output reg 		we
			);

    reg [18:0] address_mem0;
    reg [31:0]	counter;
    reg step;
    reg [7:0] red0, green0, blue0,red1, green1, blue1;
    reg [7:0] u0,y0,v0,y1, c, d, e;
    reg [31:0] hor, ver, pix;
   // reg [7:0] testvector [0:4096*2160*2-1];
    integer i,j;
    reg 		we_t;
    
    assign addr_mem0 = address_mem0;

    initial begin 
        address_mem0 <= 0;
        step <= 0;
        pix <= 0;
        hor <= 0;
        ver <= 0;
       /* for (i = 0; i < 4096*2 ; i = i + 2) begin
            for (j = 0; j < 2160 ; j = j + 1) begin 
                if (i > 4096) begin 
                    testvector[i + j*4096*2] <= 8'd218; //U, V
                    testvector[i+1 + j*4096*2] <= 8'd50; //Y
                    
                end
                else begin 
                   testvector[i + j*4096*2] <= 8'd128; //U, V
                    testvector[i+1 + j*4096*2] <= 8'd255; //Y
                end
            end 
        end*/
    end

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

     always @(posedge clk24 or negedge rst_n) begin : proc_address_mem1                                   
        if(~rst_n) begin
            address_mem0 <= 0;
        end 
        else begin
            if (counter == c_frame) begin 
                address_mem0 <= 0;
            end 
            else begin
                if(step == 1) begin
                    address_mem0 <= address_mem0 + 1;
                end                                  
            end
        end
    end
        
   /* always @(posedge clk24 or negedge rst_n) begin 
        if(~rst_n) begin
            d <= 0;
            dout <= 0;
            //address_mem0 <= 0;
            we <= 1'b0;
        end else begin
            we <= 1'b1;
            if (address_mem0 < 640*480*3) begin
                if (d <= 240) begin //generate test pattern 
                    d = d + 10;
                    dout <= d;
                end
                else begin
                    d = 0;
                    dout <= d;
                end 
                address_mem0 <= address_mem0 + 1 ;  
                addr_mem0 <= address_mem0;   
            end
            else begin 
                address_mem0 <= 0;
                addr_mem0 <= address_mem0;
            end
        end
    end
    */

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
                        if (hor > width/2) begin 
                            dout <= {8'd0,8'd0,8'd255,8'd0,8'd0,8'd255};
                        end
                        else begin 
                            dout <= {8'd255,8'd255,8'd255,8'd255,8'd255,8'd255};
                        end
                    end
            end
        end
    end

 /*always @(posedge clk24 or negedge rst_n) begin : proc_rgb                                   
        if(~rst_n) begin
            u0 = 0;
            y0 = 0;
            v0 = 0;
            y1 = 0;
        end 
        else begin
		if (hor < width && ver < height) begin
        	u0 = testvector[pix];
			y0 = testvector[pix+1];
			v0 = testvector[pix+2];
			y1 = testvector[pix+3];
			pix <= pix + 4;
	        c = y0 - 16;
        	d = u0 - 128; 
            e = v0 - 128;                     
 	        red0 = (298 * c             + 409 * e + 128)>>8; //without clipping for now
        	green0 = (298 * c - 100 * d - 208 * e + 128)>>8;
			blue0 = (298 * c + 516 * d            + 128)>>8;
			c = y1 - 16;                       
            red1 = (298 * c             + 409 * e + 128)>>8;
  		    green1 = (298 * c - 100 * d - 208 * e + 128)>>8;
            blue1 = (298 * c + 516 * d            + 128)>>8;              
            dout = {red1,blue1,green1,red0,blue0,green0};	
			step <= 1;
		end
		else begin
			step <= 0;
			pix <= 0;
		end
	end
end */

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
endmodule