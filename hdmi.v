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
//////////////////////////////////////////////////////////////////////////////////


module hdmi#(
			parameter hRez = 640/2,
			parameter hStartSync = (640 + 16)/2,
			parameter hEndSync = (640 + 16 + 96)/2,
			parameter hMaxCount = (640 + 16 + 96 + 48)/2,

			parameter vRez = 480,
			parameter vStartSync = 480 + 10,
			parameter vEndSync = 480 + 10 + 2,
			parameter vMaxCount = 480 + 10 + 2 + 33,

			parameter hsync_active = 1'b0,
			parameter vsync_active = 1'b0
			/*parameter hRez = 4096,
			parameter hStartSync = 4096 + 16,
			parameter hEndSync = 4096 + 16 + 96,
			parameter hMaxCount = 4400,

			parameter vRez = 2160,
			parameter vStartSync = 2160 + 10,
			parameter vEndSync = 2160 + 10 + 2,
			parameter vMaxCount = 2250*/
			)
			(
			input                clk24,
			input        [47:0]  frame_pixel,
			input                rst_n,
			output       [17:0]	 frame_addr,
			output reg   [47:0]	 hdmi_data,
			output reg 		 hdmi_hsync,
			output reg		 hdmi_vsync,
			output  		 hdmi_hblank,
			output 		     hdmi_vblank,
			output reg 		 hdmi_active_video
			);



	reg [9:0]	   hCounter; //9
	reg [9:0]	   vCounter; //9
	reg [17:0]         address;
	reg 		   vblank, hblank;
	
	assign hdmi_vblank = vblank;
	assign hdmi_hblank = hblank;
	
	assign frame_addr = hCounter < hRez && address < 640 * 480 /2 ? address : 0;
    //assign frame_addr = hCounter < hRez && address < 4096 * 2160 / 2 ? address : 0;
// horizontal counter of vga output
	always @(posedge clk24 or negedge rst_n) begin : proc_hCounter                  
		if(~rst_n) begin
			hCounter <= 0;
		end 
		else begin
			if (hCounter == hMaxCount - 1) begin
				hCounter <= 10'b0;
			end 
			else begin
				hCounter <= hCounter + 1; //2 pixels per cycle
			end
		end
	end

// vertical counter of vga output
	always @(posedge clk24 or negedge rst_n) begin : proc_vCounter                  
		if(~rst_n) begin
			vCounter <= 0;
		end 
		else begin
			if (hCounter == hMaxCount - 1) begin
				if (vCounter == vMaxCount - 1) begin
					vCounter <= 10'b0;
				end 
				else begin
					vCounter <= vCounter + 1;
				end
			end
		end
	end

// address of vga output pixel
	always @(posedge clk24 or negedge rst_n) begin : proc_address                   
		if(~rst_n) begin
			address <= 0;
		end 
		else begin
			if (vCounter >= vRez) begin
				address <= 18'b0; //18
			end 
			else begin
				if (hCounter < hRez) begin
					address <= address + 1;
				end
			end
		end
	end

// whether send pixel value or not
	always @(posedge clk24 or negedge rst_n) begin : proc_blank                     
		if(~rst_n) begin
			vblank <= 1'b1;
			hblank <= 1'b1;
		end 
		else begin
			if (vCounter >= vRez) begin
				vblank <= 1'b1;
			end 
			else begin
				if (hCounter < hRez) begin
				    vblank <= 1'b0;
					hblank <= 1'b0;
				end 
				else begin
				    vblank <= 1'b0;
					hblank <= 1'b1;
				end
			end
		end
	end

// vga_rgb value
	always @(posedge clk24 or negedge rst_n) begin : proc_hdmi_rgb                   
		if(~rst_n) begin
			hdmi_data <= 0;
		end 
		else begin
			//if (blank == 1'b0) begin
		    if (address < hRez*vRez) begin
                hdmi_data <= frame_pixel;
            end
            else begin
                hdmi_data <= 48'b0;
            end
		end
	end

// vga horizontal sync
	always @(posedge clk24 or negedge rst_n) begin : proc_hdmi_hsync                 
		if(~rst_n) begin
			hdmi_hsync <= ~hsync_active;
		end 
		else begin
			if (hCounter > hStartSync && hCounter <= hEndSync) begin
				hdmi_hsync <= hsync_active;
			end 
			else begin
				hdmi_hsync <= ~hsync_active;
			end
		end
	end

// vga vertical sync
	always @(posedge clk24 or negedge rst_n) begin : proc_hdmi_vsync                 
		if(~rst_n) begin
			hdmi_vsync <= ~vsync_active;
		end 
		else begin
			if (vCounter >= vStartSync && vCounter < vEndSync) begin
				hdmi_vsync <= vsync_active;
			end 
			else begin
				hdmi_vsync <= ~vsync_active;
			end
		end
	end

always @(posedge clk24 or negedge rst_n) begin : proc_hdmi_active_video                
		if(~rst_n) begin
			hdmi_active_video <= 0;
		end 
		else begin
			if (hCounter >= hRez || vCounter >= vRez) begin
				hdmi_active_video <= 0;
			end 
			else begin
				hdmi_active_video <= 1;
			end
		end
	end

endmodule
