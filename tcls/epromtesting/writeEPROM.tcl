open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210308AB0E6E]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210308AB0E6E]
open_hw_target

set startaddr [lindex $argv 0] 
set datasize   [lindex $argv 1]
set pagecount  [lindex $argv 2]

set_property PROGRAM.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.bit} [get_hw_devices xcku040_0]
set_property PROBES.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.ltx} [get_hw_devices xcku040_0]
set_property FULL_PROBES.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.ltx} [get_hw_devices xcku040_0]
current_hw_device [get_hw_devices xcku040_0]
refresh_hw_device [lindex [get_hw_devices xcku040_0] 0]

# set trigger
set_property TRIGGER_COMPARE_VALUE eq8'bXXX1_XXXX [get_hw_probes ila_trigger5 -of_objects [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]]
set_property OUTPUT_VALUE $startaddr [get_hw_probes startaddr -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {startaddr} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
set_property OUTPUT_VALUE $datasize [get_hw_probes load_data_size -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {load_data_size} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
set_property OUTPUT_VALUE $pagecount [get_hw_probes pagecount -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {pagecount} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]

startgroup
set_property OUTPUT_VALUE 0 [get_hw_probes startinfo_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {startinfo_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
endgroup
startgroup
set_property OUTPUT_VALUE 1 [get_hw_probes startinfo_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {startinfo_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
endgroup

run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]

startgroup
set_property OUTPUT_VALUE 0 [get_hw_probes startdata_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {startdata_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
endgroup
startgroup
set_property OUTPUT_VALUE 1 [get_hw_probes startdata_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
commit_hw_vio [get_hw_probes {startdata_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
endgroup

wait_on_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]
display_hw_ila_data [upload_hw_ila_data [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]]
