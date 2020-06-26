# In the source directory run the below command
# vivado -nojournal -nolog -mode batch -source project_generator.tcl

# Environment variables
set FPGA_TYPE xcku040-ffva1156-2-e

# Generate ip
set argv $FPGA_TYPE
set argc 1
# create ip project when needed
#source ip_generator.tcl

# Create project
create_project example_ibert_ultrascale_gth_0 project -part $FPGA_TYPE -force
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
"source/example_ibert_ultrascale_gth_0.v"\
"source/example_ibert_ultrascale_gth_0.xdc"\
"source/ibert_ultrascale_gth_ip_example.xdc"\
"ip/$FPGA_TYPE/ibert_ultrascale_gth_0/ibert_ultrascale_gth_0.xci"\
]

add_files -norecurse $files
add_files -fileset constrs_1 -norecurse "source/example_ibert_ultrascale_gth_0.xdc"
add_files -fileset constrs_1 -norecurse "source/ibert_ultrascale_gth_ip_example.xdc"

# Set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property -name "top" -value "example_ibert_ultrascale_gth_0.v" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj

# Add tcl for simulation
## not set currently, add when needed
#set_property -name {xsim.simulate.custom_tcl} -value {../../../../source/Firmware_tb.tcl} -objects [get_filesets sim_1]

# Set ip as global
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/ibert_ultrascale_gth_0/ibert_ultrascale_gth_0.xci]

puts "\[Success\] Created project"
close_project
