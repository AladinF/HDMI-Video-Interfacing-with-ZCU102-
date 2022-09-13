# HDMI-Video-Interfacing-with-ZCU102
HDMI Video Interfacing with ZCU102 using Xilinx IPs

This project is based on the *ov7670\_to\_vga* project accessible here: https://github.com/ESCA-RISC-V/ov7670_to_vga.
- A licence is required to use the Xilinx HDMI IP core. 
- This project was developed under Vivado 2020.2 version.
- Files from original project *ov7670\_to\_vga* have been translated from SystemVerilog to Verilog for this project in order to allow adding RTL modules to the block design (Only VHDL and Verilog modules can be added as RTL modules to a block design).
- Some ports from the original project *ov7670\_to\_vga* are not used in this new project ()

###	FSM : ov7670_capture
![image](https://user-images.githubusercontent.com/58849076/189544568-7a664f5e-d259-4dac-9dd1-b8256a37eca7.png)

The *ov7670\_capture* file codes the FSM for data capture. In the *ov7670\_to\_vga* project, we only capture the brightness byte that is written to memory. The result is a black and white image. For this project, the FSM code is modified so that we capture both the chrominance and brightness bytes for each pixel. The result will be a colored image.

### Xilinx Example Design : HDMI Tx Only
- When creating a new project on Vivado, select the target board ZCU102.
- Open IP catalog ```Flow Navigator>PROJECT MANAGER>IP Catalog``` and search _HDMI 1.4/2.0 Transmitter Subsystem_, then double click on it.
- Customize the IP then click OK:
   - Toplevel : Video Interface -> Axi4-Stream / Max bits per component -> 8 / Number of pixels per clock on Video Interface -> 2
   - Example Design : Design Topology -> Tx Only (further details on every IP of the example design can be found below)
- Right click on ```Sources->v_hdmi_tx_ss_0``` then click on _Open IP Example Design..._
- The new example design project will be created at the specified directory.
- Import the Verilog sources
- Right click on the block design then click on *Add Module* to add one by one the Verilog RTL modules.
- Right click on the block design then click on *Add IP* to add two Block Memory Generator (0) and (1)
- Customize the Block Memory Generator (0) - blk_mem_gen_0
   - Basic : Mode -> Stand Alone / Memory Type -> Simple Dual Port RAM
   - Port A Options : Port A Width -> 8 / Port A Depth -> 614400 / Enable Port Type -> Always Enabled
   - Port B Options : Port B Width -> 8 / Port B Depth -> 614400 / Enable Port Type -> Always Enabled / Uncheck Primitives Output Register
- Customize the Block Memory Generator (1) - blk_mem_gen_1
   - Basic : Mode -> Stand Alone / Memory Type -> Simple Dual Port RAM
   - Port A Options : Port A Width -> 48 / Port A Depth -> / Enable Port Type -> Always Enabled
   - Port B Options : Port B Width -> 48 / Port B Depth -> / Enable Port Type -> Always Enabled / Uncheck Primitives Output Register
- Right click on the block design then click on *Add IP* to add Video In to AXI4-Stream
   - Customize the IP by setting Pixels per Clock to 2
- Right click on the pins we want to make extenal and click on *Make External* (or Ctrl + T). Customize the names so that they match the ones given in the constraints file. The connexions to/from external pins are : 
   - ov7670_capture_0 : *OV7670_PCLK* -> pclk / *V7670_VSYNC* -> vsync / *OV7670_HREF* -> href / *SW7* -> sw / *OV7670_D* -> din
   - camera_configure_0 : pwdn -> *OV7670_PWDN* / reset -> *OV7670_RESET* / xclk -> *OV7670_XCLK* / sioc -> *OV7670_SIOC* / siod <-> *OV7670_SIOD*
- Right click on the block design then click on *Add IP* to add a Utility Vector Logic. Customize it : C_SIZE -> 1 / C_OPERATION -> not. The input of the IP should be connected to the external port _PAD_RESET_ and the output of the IP the *rst_n* pins of the RTL modules 
- Right click on the block design then click on *Add IP* to add a Clocking Wizard
   - Customize the IP : 
- Right click on the block design then click on *Add IP* to add a Constant
   - Customize the IP : Const Width -> 1 / Const Val -> 1
   - Connect the dout pin to *clk_en* of camera_configure_0 
   - Connect the dout pin to *vid_io_in_ce*, *aclken* and *axis_enable* of Video In to AXI4-Stream
- Generate output products : ```Flow Navigator>IP INTEGRATOR>Generate Block Design```. The wrapper file (Top file) will be updated automatically by Vivado.

#### Video Frame CRC
Cyclic Redundancy Check (CRC) is generally used to detect errors in digital data and is commonly employed in video transmission to detect errors in pixel transmission. Using CRC, data integrity can be checked at various levels namely, pixel level, horizontal line level, frame level of a video.
The Video Frame CRC IP is not part of the HDMI core data path requirements but is necessary for validation/compliance requirement

#### 	HDMI Transmitter Subsystem

![image](https://user-images.githubusercontent.com/58849076/189784173-e8c0c6f2-3a70-43ba-afe9-e722220fd6b0.png)

"A valid transfer occurs whenever READY, VALID, and AP_RST_N are High at the rising edge of AP_CLK, as seen in Figure 2-7. During valid transfers, DATA only carries active video data. Blank periods and ancillary data packets are not transferred through the AXI4-Stream video protocol."

"The Start-Of-Frame (SOF) signal, physically transmitted over the AXI4-Stream TUSER0 signal, marks the first pixel of a video frame. The SOF pulse is 1 valid transaction wide, and must coincide with the first pixel of the frame, as seen in Figure 2-7. The SOF signal serves as a frame synchronization signal, which allows downstream cores to re-initialize, and detect the first pixel of a frame."

"The End-Of-Line (EOL) signal, physically transmitted over the AXI4-Stream TLAST signal, marks the last pixel of a line. The EOL pulse is 1 valid transaction wide, and must coincide with the last pixel of a scanline."

#### Video PHY Controller
The HDMI stream (video stream + audio stream) is transmitted to the Video PHY Controller which converts the data into electronic signals (TMDs) which are then sent to an HDMI sink through an HDMI cable. 

#### Video TPG Subsystem
The Video Test Pattern Generator has 2 modes : Generation mode (1) and Passthrough mode (2).

![image](https://user-images.githubusercontent.com/58849076/189556212-399f6b6c-5c09-486a-8e97-10563b18b26c.png)

- Double click on the TPG block to re-customize the IP
- Set the maximum number of columns to 680 and maximum number of rows to 480.
- Make sure samples per clock is equal to 2 and maximum data width is equal to 8.
- The first mode will be used to test the platform (by default). Make sure to check all the patterns under _Background Patterns_.
- The second mode will be used to drive the camera output to the HDMI circuit (check _HAS AXI4S SLAVE_)

#### Clocking
Let's create a 640x480 RGB 24bpp @ 60Hz video signal. The camera will send data coded in YUV422 format. That's 307200 pixels per frame, each pixel will be converted from YUV422 to RGB by the core module. Each pixel now has 24 bits (8 bits for red, green and blue), at 60Hz, the HDMI link will transport 0.44Gbps of useful data. 

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
- Export hardware ```File>Export>Export Hardware...``` (Make sure to include bitstream)
- Launch Vitis IDE ```Tools>Launch Vitis IDE```
- Create a new platform project ```File>New>Platform Project``` and use the exported hardware file as an XSA File for the platform
- 

#### Test 
**The Video TPG Subsystem is in generation mode**

Refer to the Address Map to get the base address for the TPG Subsystem. From this address we can calculate the address of the register *background_pattern_id*. We use XSCT shell to send commands and write values at the register's address to generate different patterns. Each pattern has an id (Check the TPG product guide for the the list of values) 

![image](https://user-images.githubusercontent.com/58849076/189558637-faf5799c-065d-4461-8955-12818e47c3d8.png)

Examples : 
- This command will generate a color bar pattern.
```
>xsct% connect 
>xsct% mwr 0x80030000 0x09
```
- This command will generate a solid red output.
```
>xsct% mwr 0x80030000 0x04
```

![image](https://user-images.githubusercontent.com/58849076/189554341-9c95341b-5dfa-40f8-ad7a-1de6f1c671a0.png)

**The Video TPG Subsystem is in passthrough mode**

![image](https://user-images.githubusercontent.com/58849076/189559260-95de6bbe-b637-4c22-8a72-3b428643fcd8.png)

- Open the hdmi_example.c file on Vitis.
- Set the variable _IsPassthrough_ to TRUE in the main() function.
- Adapt the rest of the C code for the passthrough mode.
- re-Build the application 
#### ZCU102 Board configuration 
- Force the JTAG mode through XSCT shell . Type the following commands.
```
>xsct% connect 
>xsct% targets -set -nocase -filter {name =~ "*PSU*"}
>xsct% mwr 0xff5e0200 0x0100
>xsct% rst -system
```
- Make sure to always check _skip revision check_ before programming the FPGA or running the application. It is also possible to add the ```-no-revision-check``` option if programming with the XSCD shell.
 
### Bibliography
_ZCU102 Evaluation Board User Guide (UG118), v1.6 June 12, 2019, Xilinx, https://www.xilinx.com/support/documents/boards_and_kits/zcu102/ug1182-zcu102-eval-bd.pdf_

_Video Test Pattern Generator v7.0 LogiCORE IP Product Guide (PG103), Xilinx, https://docs.xilinx.com/v/u/7.0-English/pg103-v-tpg_

_Video PHY Controller LogiCORE IP Product Guide (PG230), Xilinx, https://docs.xilinx.com/r/en-US/pg230-vid-phy-controller_ 

_HDMI 1.4/2.0 Transmitter Subsystem v3.1 Product Guide (PG230), Xilinx, https://www.mouser.cn/datasheet/2/903/pg235_v_hdmi_tx_ss-1596308.pdf_

_AMBA 4 AXI4-Stream Protocol Specification, ARM https://developer.arm.com/documentation/ihi0051/a/Introduction/About-the-AXI4-Stream-protocol_

_Device Driver Programmer Guide, Xilinx , v1.4, 2007_
