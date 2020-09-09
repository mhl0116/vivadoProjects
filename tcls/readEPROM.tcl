open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210308AB0E6E]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210308AB0E6E]
open_hw_target

set_property PROGRAM.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.bit} [get_hw_devices xcku040_0]
set_property PROBES.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.ltx} [get_hw_devices xcku040_0]
set_property FULL_PROBES.FILE {/net/top/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top.ltx} [get_hw_devices xcku040_0]
current_hw_device [get_hw_devices xcku040_0]
refresh_hw_device [lindex [get_hw_devices xcku040_0] 0]

set cmdIndex  [lindex $argv 0]
set startaddr [lindex $argv 1] 
set wordlimit [lindex $argv 2]
set endaddr   [lindex $argv 3] 

#
#puts "Start"
#set i 0
#while {$i < 10} {
#    puts "I inside third loop: $i"
#    incr i
#    puts "I after incr: $i"
#}
#for {set X 0}  {$X < $line_length }  {set X [expr {$X + 2}]} {
#    set hexbyte [string range $line $X [expr {$X + 1}]]
#    set sum1 [format %x [expr 0x$hexbyte + 0x$sum1]]
#}

puts "start to read eprom"
while { $startaddr < $endaddr } {
	puts "startaddr: ${startaddr}, endaddr: ${endaddr}"

	display_hw_ila_data [ get_hw_ila_data hw_ila_data_1 -of_objects [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]]
	#note the 7th bit is start to read readback fifo in trigger
	set_property TRIGGER_COMPARE_VALUE eq8'bX1XX_XXXX [get_hw_probes ila_trigger1 -of_objects [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]]

	#set trigger position
	set_property CONTROL.TRIGGER_POSITION 0 [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]
	#set vio value
	set_property OUTPUT_VALUE $cmdIndex [get_hw_probes ila_CmdIndex -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	commit_hw_vio [get_hw_probes {ila_CmdIndex} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	set_property OUTPUT_VALUE $startaddr [get_hw_probes in_rdAddr -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	commit_hw_vio [get_hw_probes {in_rdAddr} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	set_property OUTPUT_VALUE $wordlimit [get_hw_probes ila_wdlimit -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	commit_hw_vio [get_hw_probes {ila_wdlimit} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	#reset readback fifo
	startgroup
	set_property OUTPUT_VALUE 1 [get_hw_probes vio_reset -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	commit_hw_vio [get_hw_probes {vio_reset} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	endgroup

	startgroup
	set_property OUTPUT_VALUE 0 [get_hw_probes vio_reset -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	commit_hw_vio [get_hw_probes {vio_reset} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	endgroup
	# run ila 
	run_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]

	# inject read eprom signal
	startgroup
	set_property OUTPUT_VALUE 0 [get_hw_probes startread_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	commit_hw_vio [get_hw_probes {startread_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	endgroup
	startgroup
	set_property OUTPUT_VALUE 1 [get_hw_probes startread_gen -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	commit_hw_vio [get_hw_probes {startread_gen} -of_objects [get_hw_vios -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_vio"}]]
	endgroup

	wait_on_hw_ila [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]
	current_hw_ila_data [upload_hw_ila_data [get_hw_ilas -of_objects [get_hw_devices xcku040_0] -filter {CELL_NAME=~"i_ila"}]]
	display_hw_ila_data [current_hw_ila_data]
	write_hw_ila_data -csv_file promcontent/ila_data_addr_${startaddr}_nwd_${wordlimit} [current_hw_ila_data]

	#increase start address by 2*numberofword
	set startaddr [format %0.8x [expr 0x$startaddr + 0x$wordlimit * 2 ] ]
}