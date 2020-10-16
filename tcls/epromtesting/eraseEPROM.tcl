open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210308AB0E6E]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210308AB0E6E]
open_hw_target

set startaddr [lindex $argv 0] 
set sectorcount  [lindex $argv 1]
set bitfilename  [lindex $argv 2]

set_property PROGRAM.FILE $bitfilename.bit [get_hw_devices xcku040_0]
set_property PROBES.FILE $bitfilename.ltx [get_hw_devices xcku040_0]
set_property FULL_PROBES.FILE $bitfilename.ltx [get_hw_devices xcku040_0]
#set_property PROGRAM.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.bit} [get_hw_devices xcku040_0]
#set_property PROBES.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.ltx} [get_hw_devices xcku040_0]
#set_property FULL_PROBES.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.ltx} [get_hw_devices xcku040_0]
current_hw_device [get_hw_devices xcku040_0]
refresh_hw_device [lindex [get_hw_devices xcku040_0] 0]

# set trigger
set_property TRIGGER_COMPARE_VALUE eq12'bXXXX_XXXX_XX1X [get_hw_probes ila_trigger4 -of_objects [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]]

# set initial address for erase
set_property OUTPUT_VALUE $startaddr [get_hw_probes startaddr -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {startaddr} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]

# set number of sector to be erased
set_property OUTPUT_VALUE $sectorcount [get_hw_probes sectorcount -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {sectorcount} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]

run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]

startgroup
set_property OUTPUT_VALUE 0 [get_hw_probes startinfo_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {startinfo_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
endgroup
startgroup
set_property OUTPUT_VALUE 1 [get_hw_probes startinfo_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {startinfo_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
endgroup

startgroup
set_property OUTPUT_VALUE 0 [get_hw_probes starterase_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {starterase_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
endgroup

startgroup
set_property OUTPUT_VALUE 1 [get_hw_probes starterase_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {starterase_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
endgroup

wait_on_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]
display_hw_ila_data [upload_hw_ila_data [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]]

