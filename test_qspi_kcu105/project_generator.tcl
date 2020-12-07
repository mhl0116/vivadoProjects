# In the source directory run the below command
# vivado -nojournal -nolog -mode batch -source project_generator.tcl

# Environment variables
#set FPGA_TYPE xcku040-ffva1156-2-e
set FPGA_TYPE xcku035-ffva1156-1-c 


# Generate ip
set argv $FPGA_TYPE
set argc 1
# create ip project when needed
#source ip_generator.tcl

# Create project
create_project test_qspi_kcu105  project -part $FPGA_TYPE -force
set_property target_language Verilog [current_project]
set_property target_simulator XSim [current_project]

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set 'sources_1' fileset object
set obj [get_filesets sources_1]
# Import local files from the original project

# Add files
# for f in source/*; do echo \"$f\"\\; done
# find ip -type f -name "*.xci"
set files [list \
"source/spiflash_programmer_test_top.vhd"\
"source/spiflashprogrammer_test.vhd"\
"source/leds_0to7.vhd"\
"source/oneshot.vhd"\
"ip/xcku035-ffva1156-1-c/clockManager/clockManager.xci"\
"ip/xcku035-ffva1156-1-c/ila_0/ila_0.xci"\
"ip/xcku035-ffva1156-1-c/vio_0/vio_0.xci"\
"ip/xcku035-ffva1156-1-c/readbackfifo/spi_readback_fifo.xci"\
"ip/xcku035-ffva1156-1-c/writefifo/writeFIFO.xci"\
"source/spiflashprogrammer.xdc"\
"source/Firmware_pkg.vhd"
]
#"source/spiflash_programmer_test_top.vhd"\
#"source/spiflashprogrammer_test.vhd"\

add_files -norecurse $files
add_files -fileset constrs_1 -norecurse "source/spiflashprogrammer.xdc"

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "spiflash_programmer_test_top.vhd" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj

# Add tcl for simulation
## not set currently, add when needed
#set_property -name {xsim.simulate.custom_tcl} -value {../../../../source/Firmware_tb.tcl} -objects [get_filesets sim_1]

# Set ip as global
#set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/ibert_ultrascale_gth_0/ibert_ultrascale_gth_0.xci]
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/clockManager/clockManager.xci]
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/ila_0/ila_0.xci]
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/vio_0/vio_0.xci]
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/readbackfifo/spi_readback_fifo.xci ]
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/writefifo/writeFIFO.xci ]

puts "\[Success\] Created project"
close_project
