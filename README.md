# HDMI-Video-Interfacing-with-ZCU102
HDMI Video Interfacing with ZCU102 using Xilinx IPs

This project is based on the ov7670_to_vga project accessible here: https://github.com/ESCA-RISC-V/ov7670_to_vga.
###	FSM : ov7670_capture
![image](https://user-images.githubusercontent.com/58849076/189544568-7a664f5e-d259-4dac-9dd1-b8256a37eca7.png)

### 
#### Video Frame CRC
Cyclic Redundancy Check (CRC) is generally used to detect errors in digital data and is commonly employed in video transmission to detect errors in pixel transmission. Using CRC, data integrity can be checked at various levels namely, pixel level, horizontal line level, frame level of a video.
Note that, CRC is not part of the HDMI core data path requirements but is necessary for validation/compliance requirement
CRC (video_frame_crc) is used HDMI example designs to calculate CRC at frame level, on the data received by DisplayPort RX subsystem and on the data being fed to DisplayPort TX subsystem (in passthrough system). Each color component’s CRC value is calculated separately once per every frame and can be compared with the transmitted video frame’s CRC value to check the data integrity.
![image](https://user-images.githubusercontent.com/58849076/189553525-bc0ff46f-c40c-43c7-ba3e-434790726754.png)
#### 	HDMI Transmitter Subsystem

#### Video PHY Controller
#### Video TPG Subsystem
2 modes : Generation mode (1) and Passthrough mode (2)

### Final Block Design
![image](https://user-images.githubusercontent.com/58849076/189553895-af7207ee-2435-4866-b954-6690848f7068.png)

### Software application using Vitis
- Generate ouput products 
- Run synthesis, implementation and bitstream generation
- Export hardware
- Launch Vitis IDE

#### Test 
![image](https://user-images.githubusercontent.com/58849076/189554341-9c95341b-5dfa-40f8-ad7a-1de6f1c671a0.png)

#### ZCU102 Board configuration 
- Force the JTAG mode through XSCT shell. Type the following commands.
```
>xsct connect 
>xsct targets -set -nocase -filter {name =~ "*PSU*"}
>xsct mwr 0xff5e0200 0x0100
>xsct rst -system
```

### Bibliography
_ZCU102 Evaluation Board User Guide (UG118), v1.6 June 12, 2019, Xilinx, https://www.xilinx.com/support/documents/boards_and_kits/zcu102/ug1182-zcu102-eval-bd.pdf_

_Video Test Pattern Generator v7.0 LogiCORE IP Product Guide (PG103), Xilinx, https://docs.xilinx.com/v/u/7.0-English/pg103-v-tpg_

_Video PHY Controller LogiCORE IP Product Guide (PG230), Xilinx, https://docs.xilinx.com/r/en-US/pg230-vid-phy-controller_ 

_AMBA 4 AXI4-Stream Protocol Specification, ARM https://developer.arm.com/documentation/ihi0051/a/Introduction/About-the-AXI4-Stream-protocol_

_Device Driver Programmer Guide, Xilinx , v1.4, 2007_
