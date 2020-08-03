# (c) Copyright 2012 Xilinx, Inc. All rights reserved.
#
# This file contains confidential and proprietary information
# of Xilinx, Inc. and is protected under U.S. and 
# international copyright and other intellectual property
# laws.
#
# DISCLAIMER
# This disclaimer is not a license and does not grant any
# rights to the materials distributed herewith. Except as
# otherwise provided in a valid license issued to you by
# Xilinx, and to the maximum extent permitted by applicable
# law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
# WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
# AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
# BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
# INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
# (2) Xilinx shall not be liable (whether in contract or tort,
# including negligence, or under any other theory of
# liability) for any loss or damage of any kind or nature
# related to, arising under or in connection with these
# materials, including for any direct, or any indirect,
# special, incidental, or consequential loss or damage
# (including loss of data, profits, goodwill, or any type of
# loss or damage suffered as a result of any action brought
# by a third party) even if such damage or loss was
# reasonably foreseeable or Xilinx had been advised of the
# possibility of the same.
#
# CRITICAL APPLICATIONS
# Xilinx products are not designed or intended to be fail-
# safe, or for use in any application requiring fail-safe
# performance, such as life-support or safety devices or
# systems, Class III medical devices, nuclear facilities,
# applications related to the deployment of airbags, or any
# other applications that could lead to death, personal
# injury, or severe property or environmental damage
# (individually and collectively, "Critical
# Applications"). Customer assumes the sole risk and
# liability of any use of Xilinx products in Critical
# Applications, subject only to applicable laws and
# regulations governing limitations on product liability.
#
# THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
# PART OF THIS FILE AT ALL TIMES.
#--------------------------------------------------------------------------
#
# KCU105 XDC constraints for IPI Example Design
#
set_property PACKAGE_PIN AK16 [get_ports CLK_IN1_D_clk_n]
set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_clk_n]

set_property PACKAGE_PIN AK17 [get_ports CLK_IN1_D_clk_p]
set_property IOSTANDARD LVDS [get_ports CLK_IN1_D_clk_p]

create_clock -period "3.333" -name CLK_IN1_D_clk_pin [get_ports CLK_IN1_D_clk_p]

set_property PACKAGE_PIN AN8 [get_ports reset]
set_property IOSTANDARD LVCMOS18 [get_ports reset]

set_property PACKAGE_PIN G25 [get_ports UART_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports UART_rxd]

set_property PACKAGE_PIN K26 [get_ports UART_txd]
set_property IOSTANDARD LVCMOS18 [get_ports UART_txd]
#################################################################################
#set_property PACKAGE_PIN M20 [get_ports spi_0_io0_io]
#set_property IOSTANDARD LVCMOS18 [get_ports spi_0_io0_io]

#set_property PACKAGE_PIN L20 [get_ports spi_0_io1_io]
#set_property IOSTANDARD LVCMOS18 [get_ports spi_0_io1_io]

#set_property PACKAGE_PIN R22 [get_ports spi_0_io2_io]
#set_property IOSTANDARD LVCMOS18 [get_ports spi_0_io2_io]

#set_property PACKAGE_PIN R21 [get_ports spi_0_io3_io]
#set_property IOSTANDARD LVCMOS18 [get_ports spi_0_io3_io]

#set_property PACKAGE_PIN G26 [get_ports {spi_0_ss_io[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {spi_0_ss_io[0]}]

#################################################################################s
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CFGBVS GND [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
#################################################################################
# Bank  84 VCCO -          - IO_L22N_T3U_N7_DBC_AD0N_64
set_property PACKAGE_PIN AP8      [get_ports "GPIO_LED_0_LS"] 
set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_LED_0_LS"] 
# Bank  95 VCCO -          - IO_T0U_N12_A28_65
set_property PACKAGE_PIN H23      [get_ports "GPIO_LED_1_LS"] 
set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_LED_1_LS"] 
# Bank  85 VCCO -          - IO_L20P_T3L_N2_AD1P_D08_65
set_property PACKAGE_PIN P20      [get_ports "GPIO_LED_2_LS"] 
set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_LED_2_LS"] 
# Bank  85 VCCO -          - IO_L20N_T3L_N3_AD1N_D09_65
set_property PACKAGE_PIN P21      [get_ports "GPIO_LED_3_LS"] 
set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_LED_3_LS"] 
# Bank  85 VCCO -          - IO_L19P_T3L_N0_DBC_AD9P_D10_65
set_property PACKAGE_PIN N22      [get_ports "GPIO_LED_4_LS"] 
set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_LED_4_LS"] 
## Bank  85 VCCO -          - IO_L19N_T3L_N1_DBC_AD9N_D11_65
set_property PACKAGE_PIN M22      [get_ports "GPIO_LED_5_LS"] 
set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_LED_5_LS"] 
## Bank  85 VCCO -          - IO_L18P_T2U_N10_AD2P_D12_65
set_property PACKAGE_PIN R23      [get_ports "GPIO_LED_6_LS"] 
set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_LED_6_LS"] 
## Bank  85 VCCO -          - IO_L18N_T2U_N11_AD2N_D13_65
set_property PACKAGE_PIN P23      [get_ports "GPIO_LED_7_LS"] 
set_property IOSTANDARD  LVCMOS18 [get_ports "GPIO_LED_7_LS"] 

#################################################################################
# All the delay numbers have to provided by the user
# CCLK delay is 0.5, 6.7 ns min/max for K7-2; refer Datasheet
# We need to consider the max delay for worst case analysis

set cclk_delay 6.7
# Following are the SPI device parameters
# Max Tco
set tco_max 7
# Min Tco
set tco_min 1

# Setup time requirement
set tsu 2

# Hold time requirement
set th 3

# Following are the board/trace delay numbers
# Assumption is that all Data lines are matched
set tdata_trace_delay_max 0.25
set tdata_trace_delay_min 0.25
set tclk_trace_delay_max 0.2
set tclk_trace_delay_min 0.2

### End of user provided delay numbers


# This is to ensure min routing delay from SCK generation to STARTUP input
# User should change this value based on the results
# Having more delay on this net reduces the Fmax


# Following command creates a divide by 2 clock
# It also takes into account the delay added by STARTUP block to route the CCLK
# This constraint is not needed when STARTUP block is disabled 

create_generated_clock  -name clk_sck -source [get_pins -hierarchical *axi_quad_spi_0/ext_spi_clk] [get_pins -hierarchical *USRCCLKO] -edges {3 5 7} -edge_shift [list $cclk_delay $cclk_delay $cclk_delay]

# Data is captured into FPGA on the second rising edge of ext_spi_clk after the SCK falling edge 
# Data is driven by the FPGA on every alternate rising_edge of ext_spi_clk

set_input_delay -clock clk_sck -max [expr $tco_max + $tdata_trace_delay_max + $tclk_trace_delay_max] [get_ports spi_0*io] -clock_fall;

set_input_delay -clock clk_sck -min [expr $tco_min + $tdata_trace_delay_min + $tclk_trace_delay_min] [get_ports spi_0*io] -clock_fall;

set_multicycle_path 2 -setup -from clk_sck -to [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]] 
set_multicycle_path 1 -hold -end -from clk_sck -to [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]] 

# Data is captured into SPI on the following rising edge of SCK
# Data is driven by the IP on alternate rising_edge of the ext_spi_clk

set_output_delay -clock clk_sck -max [expr $tsu + $tdata_trace_delay_max - $tclk_trace_delay_min] [get_ports spi_0*io];
set_output_delay -clock clk_sck -min [expr $tdata_trace_delay_min -$th - $tclk_trace_delay_max] [get_ports spi_0*io];

set_multicycle_path 2 -setup -start -from [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]] -to clk_sck 
set_multicycle_path 1 -hold -from [get_clocks -of_objects [get_pins -hierarchical */ext_spi_clk]] -to clk_sck

set_property IOB false [get_cells -hierarchical -filter {NAME =~*SCK_O_*_4_FDRE_INST}]
set_property IOB false [get_cells -hierarchical -filter {NAME =~*IO*_I_REG}]

