binfilename="/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top"
tag="20201016_v1"
mkdir -p firmwares
mkdir -p epromcontent 
savefwname="firmwares/spiflashprogrammer_top_${tag}.bin"
xxd $binfilename".bin" $savefwname 
readEndAddr=`tail -n1 $savefwname | awk -F ":" '{print 0$1}' ` 
eof="02000000"
#echo $readEndAddr
#./doeprom.sh "read" $binfilename "fwcontent" $readEndAddr 

#for csvname in epromcontent/*fwcontent*
#do 
#awk -F "," '{print $10":",$11,$12,$13,$14,$15,$16,$17,$18}' $csvname | sed -n '4,$p' >> firmware_${tag}.txt
#done

##some formatting is needed
#diff firmware_${tag}.txt $savefwname

#./doeprom.sh "erase" $binfilename  
#./doeprom.sh "read" $binfilename "aftererase" $eof 
#for csvname in epromcontent/*aftererase*
#do 
#awk -F "," '{print $10":",$11,$12,$13,$14,$15,$16,$17,$18}' $csvname | sed -n '4,$p' >> epromaftererase_${tag}.txt
#done

#./doeprom.sh "write" $binfilename  
./doeprom.sh "read" $binfilename "afterwrite" $eof 
#for csvname in epromcontent/*afterwrite*
#do 
#echo $csvname
#awk -F "," '{print $10":",$11,$12,$13,$14,$15,$16,$17,$18}' $csvname | head #sed -n '4,$p' >> epromafterwrite_${tag}.txt
#done
