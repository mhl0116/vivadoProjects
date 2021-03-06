####################################
# KCU105 RevD XDC
####################################
create_clock -period 3.333 [get_nets SYSCLK_P]
#create_clock -period 31.000 [get_nets Bscan1Drck]

#125MHz clock
set_property IOSTANDARD DIFF_SSTL12 [get_ports SYSCLK_P]
set_property PACKAGE_PIN AK17 [get_ports SYSCLK_P]
set_property ODT         RTT_48 [get_ports SYSCLK_P]

set_property PACKAGE_PIN AK16 [get_ports SYSCLK_N]
set_property IOSTANDARD DIFF_SSTL12 [get_ports SYSCLK_N]
set_property ODT         RTT_48 [get_ports SYSCLK_N]

set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]

#LED 0
set_property PACKAGE_PIN AP8 [get_ports {LEDS[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDS[0]}]
#LED 1
set_property PACKAGE_PIN H23 [get_ports {LEDS[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDS[1]}]
##LED 2
set_property PACKAGE_PIN P20 [get_ports {LEDS[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDS[2]}]
#LED 3
set_property PACKAGE_PIN P21 [get_ports {LEDS[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDS[3]}]
#LED 4
set_property PACKAGE_PIN N22 [get_ports {LEDS[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDS[4]}]
#LED 5
set_property PACKAGE_PIN M22 [get_ports {LEDS[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDS[5]}]
#LED 6
set_property PACKAGE_PIN R23 [get_ports {LEDS[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDS[6]}]
#LED 7
set_property PACKAGE_PIN P23 [get_ports {LEDS[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDS[7]}]

##set_false_path -to [get_cells spiflashprogrammer_inst/synced_fifo_almostfull_reg*]
##set_false_path -to [get_cells spiflashprogrammer_inst/synced_erase_reg*]

# The below paths from DRCK to SPICLK are static after the initial load of the registers.
# There is plenty of time for those propagate to the SPICLK.
##set_false_path -from [get_cells *valid_reg*]
##set_false_path -from [get_cells pagecount_reg*]
##set_false_path -from [get_cells sectorcount_reg*]
##set_false_path -from [get_cells startaddr_reg*]
##set_false_path -from [get_cells starterase_reg*]
#From SPI clk to DRCK. Called out individually.
##set_false_path -from [get_cells spiflashprogrammer_inst/erase_inprogress_reg] -to [get_cells pagecount_reg*]
##set_false_path -from [get_cells spiflashprogrammer_inst/erase_inprogress_reg] -to [get_cells sectorcount_reg*]
##set_false_path -from [get_cells spiflashprogrammer_inst/erase_inprogress_reg] -to [get_cells startaddr_reg*]
##set_false_path -from [get_cells spiflashprogrammer_inst/erase_inprogress_reg] -to [get_cells pagecountvalid_reg*]
##set_false_path -from [get_cells spiflashprogrammer_inst/erase_inprogress_reg] -to [get_cells sectorcountvalid_reg*]
##set_false_path -from [get_cells spiflashprogrammer_inst/erase_inprogress_reg] -to [get_cells startaddrvalid_reg*]
##set_false_path -from [get_cells spiflashprogrammer_inst/erase_inprogress_reg] -to [get_cells starterase_reg*]
##set_false_path -from [get_cells spiflashprogrammer_inst/erase_inprogress_reg] -to [get_cells download_state_reg*]

########################  Min Delays to avoid SPI hold time violations ###############
set_min_delay -to [get_pins -hierarchical STARTUPE3_inst/DO*] 3.000
set_min_delay -to [get_pins -hierarchical STARTUPE3_inst/FCSBO] 3.000
set_min_delay -to [get_pins -hierarchical STARTUPE3_inst/DTS*] 3.000

##############  Some Max delays to be safe
set_max_delay -to [get_pins -hierarchical STARTUPE3_inst/DO*] 14.000
set_max_delay -to [get_pins -hierarchical STARTUPE3_inst/FCSBO] 14.000
set_max_delay -to [get_pins -hierarchical STARTUPE3_inst/DTS*] 14.000
##set_max_delay -to [get_pins -hierarchical {er_rddata_reg[0]/D}] 8.000
set_max_delay -to [get_pins -hierarchical {rd_rddata_reg[0]/D}] 8.000
set_max_delay -to [get_pins -hierarchical {rddata_reg[0]/D}] 8.000

##########################   Bitstream options #####################################
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design] 
set_property CONFIG_VOLTAGE 1.8 [current_design] 
set_property CFGBVS GND [current_design] 


