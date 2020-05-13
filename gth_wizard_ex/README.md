based on vivado gth wizard example design, work with kcu105

# Template
Only the source folder is requried. Other folders can be generated using the generator tcl files.

## File description 
- source/gtwizard_ultrascale_1_example_bit_sync.v
- source/gtwizard_ultrascale_1_example_checking_8b10b.v
- source/gtwizard_ultrascale_1_example_gtwiz_userclk_rx.v
- source/gtwizard_ultrascale_1_example_gtwiz_userclk_tx.v
- source/gtwizard_ultrascale_1_example_init.v
- source/gtwizard_ultrascale_1_example_reset_sync.v
- source/gtwizard_ultrascale_1_example_stimulus_8b10b.v
- source/gtwizard_ultrascale_1_example_top_sim.v
- source/gtwizard_ultrascale_1_example_top.v
- source/gtwizard_ultrascale_1_example_top.xdc
- source/gtwizard_ultrascale_1_example_wrapper_functions.v
- source/gtwizard_ultrascale_1_example_wrapper.v
- source/gtwizard_ultrascale_1_prbs_any.v

- ip/xcku040-ffva1156-2-e/clockManager/clockManager.xci
- ip/xcku040-ffva1156-2-e/ila_0/ila_0.xci
- ip/xcku040-ffva1156-2-e/gtwizard_ultrascale_1/gtwizard_ultrascale_1.xci
- ip/xcku040-ffva1156-2-e/gtwizard_ultrascale_1_vio_0/gtwizard_ultrascale_1_vio_0.xci

- project/tb_project.xpr: Vivado project for testbench. Set for KCU105 (xcku040-ffva1156-2-e)

## Generator files
- ip_generator.tcl
- project_generator.tcl

## To re-make the project, run the below commands
~~~~bash
cd source; vivado -nojournal -nolog -mode batch -source project_generator.tcl
~~~~

## To re-make the ip cores, run one of the below command according to the FPGA target
~~~~bash
cd source; vivado -nojournal -nolog -mode batch -source ip_generator.tcl -tclargs xcku040-ffva1156-2-e
cd source; vivado -nojournal -nolog -mode batch -source ip_generator.tcl -tclargs xcku035-ffva1156-1-c
~~~~
