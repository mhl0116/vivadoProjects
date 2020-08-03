based on vivado gth wizard example design, work with kcu105
this repo is based on this example design:
https://www.xilinx.com/support/answers/62376.html

# Template
Only the source folder is requried. Other folders can be generated using the generator tcl files.

## File description 
- source/test_qspi_kcu105.v
- source/test_qspi_kcu105.xdc

- project/test_qspi_kcu105.xpr: Vivado project for testbench. Set for KCU105 (xcku040-ffva1156-2-e)

## Generator files
- project_generator.tcl

## To re-make the project, run the below commands
~~~~bash
cd source; vivado -nojournal -nolog -mode batch -source project_generator.tcl
~~~~

# Note
When opening this project with Vivado, it complains the top file is not correct
after manually setting test_qspi_kcu105.v to be the top module there is no problem
in following firmware making, to be understood
