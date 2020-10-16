#set cmdIndex  [lindex $argv 0]
#set startaddr [lindex $argv 1] 
#set wordlimit [lindex $argv 2]
#set endaddr   [lindex $argv 3] 
## 0x3FFF8 words = 262136 words = 8*32767
## depth of readback fifo and ila is currently set to: 32768
vivado -nojournal -nolog -mode batch -notrace -source readEPROM.tcl -tclargs "4" "00000000" "0003FFF8" "001C0F68"   

#set startaddr [lindex $argv 0] 
#set sectorcount  [lindex $argv 1]
vivado -nojournal -nolog -mode batch -notrace -source eraseEPROM.tcl -tclargs "00000000" "2000"    

#set startaddr [lindex $argv 0] 
#set datasize   [lindex $argv 1]
#set pagecount  [lindex $argv 2]
vivado -nojournal -nolog -mode batch -notrace -source writeEPROM.tcl -tclargs "00000000" "00000400" "20000"    
