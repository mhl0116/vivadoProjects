ops=$1
bitfilename=$2
tagForRead=$3
readEndAddr=$4
#set cmdIndex  [lindex $argv 0]
#set startaddr [lindex $argv 1] 
#set wordlimit [lindex $argv 2]
#set endaddr   [lindex $argv 3] 
#set tag       [lindex $argv 4]
#set bitfilename  [lindex $argv 5]
## 0x3FFF8 words = 262136 words = 8*32767
## depth of readback fifo and ila is currently set to: 32768

if [ $ops = "read" ]; then
echo "start read..."
# last argument dependent on size of firmware, sould make it configurable
#vivado -nojournal -nolog -mode batch -notrace -source readEPROM.tcl -tclargs "4" "00000000" "0003FFF8" "006f4ee0" $tagForRead  
vivado -nojournal -nolog -mode batch -notrace -source readEPROM.tcl -tclargs "4" "00000000" "0003FFF8" $readEndAddr $tagForRead $bitfilename 
echo "read eprom done!"
fi 

#set startaddr [lindex $argv 0] 
#set sectorcount  [lindex $argv 1]
if [ $ops = "erase" ]; then
echo "start erase..."
vivado -nojournal -nolog -mode batch -notrace -source eraseEPROM.tcl -tclargs "00000000" "2000" $bitfilename 
echo "erase eprom done!"
fi

#set startaddr [lindex $argv 0] 
#set datasize   [lindex $argv 1]
#set pagecount  [lindex $argv 2]
if [ $ops = "write" ]; then
echo "start write..."
vivado -nojournal -nolog -mode batch -notrace -source writeEPROM.tcl -tclargs "00000000" "00000400" "20000" $bitfilename 
echo "write eprom done!"
fi
