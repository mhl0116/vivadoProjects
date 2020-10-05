# Template
Only the source folder is requried. Other folders can be generated using the generator tcl files.

## File description 
- source/Firmware.vhd: Module
- source/Firmware_pkg.vhd: Pakage file that holds global variables
- source/Firmware_tb.vhd: Testbench for module
- source/Firmware_tb.xdc: Constraint file for testbench
- source/Firmware_tb.tcl: Simulation file
- source/data: COE data files for LUTs

- ip/xcku040-ffva1156-2-e/clockManager/clockManager.xci: IP for generating clocks
- ip/xcku040-ffva1156-2-e/ila/ila.xci: IP for logic analyzer
- ip/xcku040-ffva1156-2-e/lut_input1/lut_input1.xci: IP for lut input 1
- ip/xcku040-ffva1156-2-e/lut_input2/lut_input2.xci: IP for lut input 2

- project/project.xpr: Vivado project for module. Set for xcku035-ffva1156-1-c
- tb_project/tb_project.xpr: Vivado project for testbench. Set for KCU105 (xcku040-ffva1156-2-e)

## Generator files
- source/ip_generator.tcl: Tcl file that can generate IPs according to the FPGA
- source/project_generator.tcl: Tcl file that can generate Vivado project
- source/tb_project_generator.tcl: Tcl file that can generate testbench Vivado project

## To re-make the project, run the below commands
~~~~bash
cd source; vivado -nojournal -nolog -mode batch -source project_generator.tcl
~~~~

## To re-make the testbench project, run the below commands. The testbench is targeted for the KCU105 board.
~~~~bash
cd source; vivado -nojournal -nolog -mode batch -source tb_project_generator.tcl
~~~~

## To re-make the ip cores, run one of the below command according to the FPGA target
~~~~bash
cd source; vivado -nojournal -nolog -mode batch -source ip_generator.tcl -tclargs xcku040-ffva1156-2-e
cd source; vivado -nojournal -nolog -mode batch -source ip_generator.tcl -tclargs xcku035-ffva1156-1-c
~~~~
