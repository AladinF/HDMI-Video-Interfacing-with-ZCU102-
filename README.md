# HDMI-Video-Interfacing-with-ZCU102
HDMI Video Interfacing with ZCU102 using Xilinx IPs

This project is based on the *ov7670\_to\_vga* project accessible here: https://github.com/ESCA-RISC-V/ov7670_to_vga.
- A licence is required to use the Xilinx HDMI IP core. 
- This project was developed under Vivado 2020.2 version.
- 
Let's create a 640x480 RGB 24bpp @ 60Hz video signal. The camera will send data coded in YUV422 format. That's 307200 pixels per frame, and since each pixel has 24 bits (8 bits for red, green and blue), at 60Hz, the HDMI link will transport 0.44Gbps of "useful" data. 

###	FSM : ov7670_capture
![image](https://user-images.githubusercontent.com/58849076/189544568-7a664f5e-d259-4dac-9dd1-b8256a37eca7.png)

The *ov7670\_capture* file codes the FSM for data capture. In the *ov7670\_to\_vga* project, we only capture the brightness byte that is written to memory. The result is a black and white image. For this project, the FSM code is modified so that we capture both the chrominance and brightness bytes for each pixel. The result will be a colored image.

### Xilinx Example Design : HDMI Tx Only
Open 
#### Video Frame CRC
Cyclic Redundancy Check (CRC) is generally used to detect errors in digital data and is commonly employed in video transmission to detect errors in pixel transmission. Using CRC, data integrity can be checked at various levels namely, pixel level, horizontal line level, frame level of a video.
Note that, CRC is not part of the HDMI core data path requirements but is necessary for validation/compliance requirement
CRC (video_frame_crc) is used HDMI example designs to calculate CRC at frame level, on the data received by DisplayPort RX subsystem and on the data being fed to DisplayPort TX subsystem (in passthrough system). Each color component’s CRC value is calculated separately once per every frame and can be compared with the transmitted video frame’s CRC value to check the data integrity.
#### 	HDMI Transmitter Subsystem

#### Video PHY Controller
The subsystem converts the video stream and audio stream into an HDMI stream, based on the selected video format set by the processor core through the CPU interface. The subsystem then transmits the HDMI stream to the PHY Layer (Video PHY Controller/HDMI GT Subsystem) which converts the data into electronic signals which are then sent to an HDMI sink through an HDMI cable. 

TMDS Source synchronous clock to HDMI interface (This is the actual clock on the HDMI cable) = 1/10 data rate (for data rates < 3.4 Gb/s)
Link Clock (txoutclk) used for data interface between the Video PHY layer module and subsystem -  For dual pixel video: Clock=data clock/2 

Video Clock used for video interface For dual pixel video clock = pixel clock/2

#### Video TPG Subsystem
The Video Test Pattern Generator has 2 modes : Generation mode (1) and Passthrough mode (2)
![image](https://user-images.githubusercontent.com/58849076/189556212-399f6b6c-5c09-486a-8e97-10563b18b26c.png)
- Double click on the TPG block to re-customize the IP
- Set the maximum number of columns to 680 and maximum number of raws to 480.
- Make sure samples per clock is equal to 2 and maximum data width is equal to 8.
- The first mode will be used to test the platform (by default). Make sure to check all the patterns under _Background Patterns_.
- The second mode will be used to drive the camera output to the HDMI circuit (check _HAS AXI4S SLAVE_)

#### Clocking


![image](https://user-images.githubusercontent.com/58849076/189557644-0d997192-c620-40fd-bc00-4ae6964c0a4e.png)

- Pixel clock = Htotal × Vtotal × Frame Rate = 800 x 525 x 60 =25,200,000 = 25.2 MHz 
The pixel clock represents the total number of pixels that need to be sent every second. This clock is not used in the system. It is only listed to illustrate the clock relations.
- Video clock = (Pixel clock)/PPC=25.2/2 = 12.6 MHz
Video Clock used for video interface For dual pixel video clock = pixel clock/2
- Data clock = Pixel clock x BPC/8=25.2 x 8/8 = 25.2 MHz
This is the actual data rate clock. This clock is not used in the system. It is only listed to illustrate the clock relations. = TMDS clock (for data rates < 3.4 Gb/s) 
- Link clock = (Data clock)/PPC=25.2/2 = 12.6 MHz
Link Clock (txoutclk) used for data interface between the Video PHY layer module and subsystem -  For dual pixel video: Clock=data clock/2 


### Final Block Design
![image](https://user-images.githubusercontent.com/58849076/189553895-af7207ee-2435-4866-b954-6690848f7068.png)

### 

### Software application using Vitis
- Generate ouput products ```Flow Navigator>IP INTEGRATOR>Generate Block Design>Generate```
- Run synthesis, implementation and bitstream generation
- Export hardware ```File>Export>Export Hardware...```
- Launch Vitis IDE ```Tools>Launch Vitis IDE```

#### Test 
**The Video TPG Subsystem is in generation mode.**
Refer to the Adress Map to get the base address for the TPG Subsystem. From this address we can calculate the address of the register *background_pattern_id*. We use XSCT shell to send commands and write values at the register's address to generate different patterns. Each pattern has an id. 

![image](https://user-images.githubusercontent.com/58849076/189558637-faf5799c-065d-4461-8955-12818e47c3d8.png)

Example : This command will generate a color bar pattern.
```
>xsct connect 
>xsct mwr 0x80030000 0x02
```

![image](https://user-images.githubusercontent.com/58849076/189554341-9c95341b-5dfa-40f8-ad7a-1de6f1c671a0.png)

**The Video TPG Subsystem is in passthrough mode.**

![image](https://user-images.githubusercontent.com/58849076/189559260-95de6bbe-b637-4c22-8a72-3b428643fcd8.png)

#### ZCU102 Board configuration 
- Force the JTAG mode through XSCT shell . Type the following commands.
```
>xsct connect 
>xsct targets -set -nocase -filter {name =~ "*PSU*"}
>xsct mwr 0xff5e0200 0x0100
>xsct rst -system
```
- Make sure to always check _skip revision check_ before programming the FPGA or running the application. It is also possible to add the ```-no-revision-check``` option if programming with the XSCD shell.
 
### Bibliography
_ZCU102 Evaluation Board User Guide (UG118), v1.6 June 12, 2019, Xilinx, https://www.xilinx.com/support/documents/boards_and_kits/zcu102/ug1182-zcu102-eval-bd.pdf_

_Video Test Pattern Generator v7.0 LogiCORE IP Product Guide (PG103), Xilinx, https://docs.xilinx.com/v/u/7.0-English/pg103-v-tpg_

_Video PHY Controller LogiCORE IP Product Guide (PG230), Xilinx, https://docs.xilinx.com/r/en-US/pg230-vid-phy-controller_ 

_AMBA 4 AXI4-Stream Protocol Specification, ARM https://developer.arm.com/documentation/ihi0051/a/Introduction/About-the-AXI4-Stream-protocol_

_Device Driver Programmer Guide, Xilinx , v1.4, 2007_
