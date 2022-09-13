#CLOCKS
#PS_REF_CLK 33 MHz U69 SI5341B
#Other net PACKAGE_PIN U24 - PS_REF_CLK Bank 503
#CLK_125 125 MHz U69 SI5341B

#CLK_125 125 MHz U69 SI5341B

#set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
#set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

#set_property PACKAGE_PIN T30 [get_ports {TMDSn[0]}]
#set_property PACKAGE_PIN T29 [get_ports {TMDSp[0]}]
#set_property PACKAGE_PIN R32 [get_ports {TMDSn[1]}]
#set_property PACKAGE_PIN R31 [get_ports {TMDSp[1]}]
#set_property PACKAGE_PIN P30 [get_ports {TMDSn[2]}]
#set_property PACKAGE_PIN P29 [get_ports {TMDSp[2]}]

#set_property LOC GTHE4_CHANNEL_X0Y4 [get_cells {TMDSp[0]}]
#set_property LOC GTHE4_CHANNEL_X0Y4 [get_cells {TMDSn[0]}]
#set_property LOC GTHE4_CHANNEL_X0Y5 [get_cells {TMDSp[1]}]
#set_property LOC GTHE4_CHANNEL_X0Y5 [get_cells {TMDSn[1]}]
#set_property LOC GTHE4_CHANNEL_X0Y6 [get_cells {TMDSp[2]}]
#set_property LOC GTHE4_CHANNEL_X0Y6 [get_cells {TMDSn[2]}]


#set_property IOSTANDARD LVDS [get_ports {TMDSn[0]}]
#set_property IOSTANDARD LVDS [get_ports {TMDSn[1]}]
#set_property IOSTANDARD LVDS [get_ports {TMDSn[2]}]
#set_property IOSTANDARD LVDS [get_ports {TMDSp[0]}]
#set_property IOSTANDARD LVDS [get_ports {TMDSp[1]}]
#set_property IOSTANDARD LVDS [get_ports {TMDSp[2]}]

#USER_SI570 300 MHz
#set_property PACKAGE_PIN AG6 [get_ports {TMDSn_clock}]
#set_property IOSTANDARD LVDS [get_ports {TMDSn_clock}]
#set_property PACKAGE_PIN AF6 [get_ports {TMDSp_clock}]
#set_property IOSTANDARD LVDS [get_ports {TMDSp_clock}]

set_property PACKAGE_PIN AG13 [get_ports {PAD_RESET}	]
set_property IOSTANDARD LVTTL [get_ports PAD_RESET]

#set_property PACKAGE_PIN B15 [get_ports TX_EN_OUT]
#set_property IOSTANDARD LVCMOS33 [get_ports TX_EN_OUT]
#set_property IOSTANDARD LVCMOS33 [get_ports TX_DDC_OUT_scl_io]
#set_property IOSTANDARD LVCMOS33 [get_ports TX_DDC_OUT_sda_io]
#set_property PACKAGE_PIN C16 [get_ports TX_DDC_OUT_scl_io]       
#set_property PACKAGE_PIN D16 [get_ports TX_DDC_OUT_sda_io]

#GTR 505 FIXED CLOCKS SOURCED FROM U69 SI5341B
#Other net PACKAGE_PIN AA27 - GTR_REF_CLK_PCIE_C_P
#Other net PACKAGE_PIN AA28 - GTR_REF_CLK_PCIE_C_N
#Other net PACKAGE_PIN W27 - GTR_REF_CLK_SATA_C_P
#Other net PACKAGE_PIN W28 - GTR_REF_CLK_SATA_C_N
#Other net PACKAGE_PIN U27 - GTR_REF_CLK_USB3_C_P
#Other net PACKAGE_PIN U28 - GTR_REF_CLK_USB3_C_N
#Other net PACKAGE_PIN U31 - GTR_REF_CLK_DP_C_P
#Other net PACKAGE_PIN U32 - GTR_REF_CLK_DP_C_N


#DIP SWITCH 8-POLE
#set_property PACKAGE_PIN AK13 [get_ports {SW[7]}]
#set_property PACKAGE_PIN AL13 [get_ports {SW[6]}]
#set_property PACKAGE_PIN AP12 [get_ports {SW[5]}]
#set_property PACKAGE_PIN AN12 [get_ports {SW[4]}]
#set_property PACKAGE_PIN AN13 [get_ports {SW[3]}]
#set_property PACKAGE_PIN AM14 [get_ports {SW[2]}]
#set_property PACKAGE_PIN AP14 [get_ports {SW[1]}]
#set_property PACKAGE_PIN AN14 [get_ports {SW[0]}]
set_property PACKAGE_PIN AK13 [get_ports {SW7}]
set_property IOSTANDARD LVCMOS33 [get_ports {SW7}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SW[*]}]


#set_property PACKAGE_PIN AG14 [get_ports {LED[0]}]           
#set_property PACKAGE_PIN AF13 [get_ports {LED[1]}]
#set_property PACKAGE_PIN AE13 [get_ports {LED[2]}]
#set_property PACKAGE_PIN AJ14 [get_ports {LED[3]}]           
#set_property PACKAGE_PIN AJ15 [get_ports {LED[4]}]           
#set_property PACKAGE_PIN AH13 [get_ports {LED[5]}]           
#set_property PACKAGE_PIN AH14 [get_ports {LED[6]}]           
#set_property PACKAGE_PIN AL12 [get_ports {LED[7]}]  
#set_property IOSTANDARD LVCMOS33 [get_ports {LED[*]}]

set_property PACKAGE_PIN A20      [get_ports {  OV7670_D[7] }   ] 
set_property PACKAGE_PIN B21      [get_ports {  OV7670_D[6] }   ] 
set_property PACKAGE_PIN B20      [get_ports {  OV7670_D[5] }   ] 
set_property PACKAGE_PIN C21      [get_ports {  OV7670_D[4] }   ] 
set_property PACKAGE_PIN A22      [get_ports {  OV7670_D[3] }   ] 
set_property PACKAGE_PIN C22      [get_ports {  OV7670_D[2] }   ] 
set_property PACKAGE_PIN A21      [get_ports {  OV7670_D[1] }   ] 
set_property PACKAGE_PIN D21      [get_ports {  OV7670_D[0] }   ] 
set_property IOSTANDARD  LVCMOS33 [get_ports {  OV7670_D[*] }   ]

set_property PACKAGE_PIN D20      [get_ports {	OV7670_SIOC	}	] 
set_property PACKAGE_PIN E20      [get_ports {	OV7670_VSYNC }	] 
set_property PACKAGE_PIN D22      [get_ports {	OV7670_PCLK	}	] 
set_property PACKAGE_PIN E22      [get_ports {	OV7670_RESET }  ] 
set_property PACKAGE_PIN F20      [get_ports {	OV7670_SIOD	}	] 
set_property PACKAGE_PIN G20      [get_ports {   OV7670_HREF }	]
set_property PACKAGE_PIN J20      [get_ports {	OV7670_XCLK	}	]
set_property PACKAGE_PIN J19      [get_ports {	OV7670_PWDN	}	] 

set_property IOSTANDARD LVCMOS33 [get_ports OV7670_PCLK]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_SIOC]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_VSYNC]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_RESET]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_PWDN]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_HREF]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_XCLK]
set_property IOSTANDARD LVCMOS33 [get_ports OV7670_SIOD]


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {OV7670_PCLK_IBUF_inst/O}]