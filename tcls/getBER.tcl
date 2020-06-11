# Connect to the Digilent Cable on localhost:3121
open_hw_manager
connect_hw_server -url localhost:3121 -allow_non_jtag
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/210308AB0E6E]
set_property PARAM.FREQUENCY 15000000 [get_hw_targets */xilinx_tcf/Digilent/210308AB0E6E]
open_hw_target

current_hw_device [get_hw_devices xcku040_0]
refresh_hw_device [lindex [get_hw_devices xcku040_0] 0]

# set_property PROGRAM.FILE {/net/top/homes/hmei/ODMB/odmbDevelopment/ibert_ultrascale_gth_0_ex/ibert_ultrascale_gth_0_ex.runs/impl_1/example_ibert_ultrascale_gth_0.bit} [get_hw_devices xcku040_0]
# set_property PROBES.FILE {/net/top/homes/hmei/ODMB/odmbDevelopment/ibert_ultrascale_gth_0_ex/ibert_ultrascale_gth_0_ex.runs/impl_1/example_ibert_ultrascale_gth_0.ltx} [get_hw_devices xcku040_0]
# set_property FULL_PROBES.FILE {/net/top/homes/hmei/ODMB/odmbDevelopment/ibert_ultrascale_gth_0_ex/ibert_ultrascale_gth_0_ex.runs/impl_1/example_ibert_ultrascale_gth_0.ltx} [get_hw_devices xcku040_0]
# program_hw_devices [lindex [get_hw_devices] 0]
# refresh_hw_device [lindex [get_hw_devices] 0]

# Set Up Link
set rxs [get_hw_sio_rxs]
#put $rxs
set txs [get_hw_sio_txs]
#put $txs

# the following 7 lines are hardcoded for kcu105 
set tx1 [lindex [get_hw_sio_txs] 1]
set rx1 [lindex [get_hw_sio_rxs] 1]
set tx2 [lindex [get_hw_sio_txs] 2]
set rx2 [lindex [get_hw_sio_rxs] 2]

set link1 [create_hw_sio_link $tx1 $rx2]
set link2 [create_hw_sio_link $tx2 $rx1]
set links [list $link1 $link2]

proc parse_report {objname propertyname index} {

  set fullrep [split [report_property $objname $propertyname -return_string] "\n"]
  # this will return something like, only last number on second line is needed:
  # Property  Type    Read-only  Value
  # RX_BER    string  true       1.2844469155632799e-13
  # RX_RECEIVED_BIT_COUNT                       string  true       113905209031560
  # RX_PATTERN                                  enum    false      PRBS 7-bit
  set secondline [lindex $fullrep 1]
  # https://wiki.tcl-lang.org/page/split
  set result [lindex [regexp -all -inline {\S+} $secondline] $index]

  return $result 

}

# first argument passed to this script is the index of nth link to dump
set linkindex [lindex $argv 0]
puts $linkindex
# record bit error rate, number of bits received, prbs pattern
set BER [parse_report [lindex $links $linkindex] "RX_BER" 3]
set RECEIVEBITCOUNT [parse_report [lindex $links $linkindex] "RX_RECEIVED_BIT_COUNT" 3]
set PRBSPATTERN [parse_report [lindex $links $linkindex] "RX_PATTERN" 4]

close_hw_manager

#get current time with microseconds precision:
set val [clock microseconds]
# extract time with seconds precision:
set seconds_precision [expr { $val / 1000000 }]
set currenttime [format "%s" [clock format $seconds_precision -format "%Y-%m-%d %H:%M:%S"]]

# write to file
set outfile [open [format "report_%s.out" $linkindex] a+]
puts $outfile "$currenttime $PRBSPATTERN $BER $RECEIVEBITCOUNT" 
close $outfile
