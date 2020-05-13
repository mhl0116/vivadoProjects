# In the source directory run the below command
# vivado -nojournal -nolog -mode batch -source project_generator.tcl

# Environment variables
set FPGA_TYPE xcku040-ffva1156-2-e

# Generate ip
set argv $FPGA_TYPE
set argc 1
# create ip project when needed
source ip_generator.tcl

# Create project
create_project project_gth_wizard_ex project -part $FPGA_TYPE -force
set_property target_language VHDL [current_project]
set_property target_simulator XSim [current_project]

create_fileset -srcset sources_1
set obj [get_filesets sources_1]

# Add files
# for f in source/*; do echo \"$f\"\\; done
# find ip -type f -name "*.xci"
set files [list \
"source/gtwizard_ultrascale_1_example_bit_sync.v"\
"source/gtwizard_ultrascale_1_example_checking_8b10b.v"\
"source/gtwizard_ultrascale_1_example_gtwiz_userclk_rx.v"\
"source/gtwizard_ultrascale_1_example_gtwiz_userclk_tx.v"\
"source/gtwizard_ultrascale_1_example_init.v"\
"source/gtwizard_ultrascale_1_example_reset_sync.v"\
"source/gtwizard_ultrascale_1_example_stimulus_8b10b.v"\
"source/gtwizard_ultrascale_1_example_top_sim.v"\
"source/gtwizard_ultrascale_1_example_top.v"\
"source/gtwizard_ultrascale_1_example_top.xdc"\
"source/gtwizard_ultrascale_1_example_wrapper_functions.v"\
"source/gtwizard_ultrascale_1_example_wrapper.v"\
"source/gtwizard_ultrascale_1_prbs_any.v"\
"ip/$FPGA_TYPE/clockManager/clockManager.xci"\
"ip/$FPGA_TYPE/ila_0/ila_0.xci"\
"ip/$FPGA_TYPE/gtwizard_ultrascale_1/gtwizard_ultrascale_1.xci"\
"ip/$FPGA_TYPE/gtwizard_ultrascale_1_vio_0/gtwizard_ultrascale_1_vio_0.xci"\
]
add_files -norecurse -fileset $obj $files
add_files -fileset constrs_1 -norecurse "source/gtwizard_ultrascale_1_example_top.xdc"

# Add tcl for simulation
## not set currently, add when needed
#set_property -name {xsim.simulate.custom_tcl} -value {../../../../source/Firmware_tb.tcl} -objects [get_filesets sim_1]

# Set ip as global
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/clockManager/clockManager.xci]
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/ila_0/ila_0.xci]
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/gtwizard_ultrascale_1/gtwizard_ultrascale_1.xci]
set_property generate_synth_checkpoint false [get_files  ip/$FPGA_TYPE/gtwizard_ultrascale_1_vio_0/gtwizard_ultrascale_1_vio_0.xci]

puts "\[Success\] Created project"
close_project
