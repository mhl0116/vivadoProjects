based on vivado gth wizard example design, work with kcu105

# Template
Only the source folder is requried. Other folders can be generated using the generator tcl files.

## File description 
- source/example_ibert_ultrascale_gth_0.v
- source/example_ibert_ultrascale_gth_0.xdc
- source/ibert_ultrascale_gth_ip_example.xdc

- ip/xcku040-ffva1156-2-e/ibert_ultrascale_gth_0/ibert_ultrascale_gth_0.xci

- project/example_ibert_ultrascale_gth_0.xpr: Vivado project for testbench. Set for KCU105 (xcku040-ffva1156-2-e)

## Generator files
- project_generator.tcl

## To re-make the project, run the below commands
~~~~bash
cd source; vivado -nojournal -nolog -mode batch -source project_generator.tcl
~~~~

# Note
When opening this project with Vivado, it complains the top file is not correct
after manually setting example_ibert_ultrascale_gth_0.v to be the top module there is no problem
in following firmware making, to be understood
