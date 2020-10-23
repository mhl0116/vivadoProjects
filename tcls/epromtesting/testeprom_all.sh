binfilename="/homes/hmei/ODMB/vivadoProjects/test_qspi_kcu105/project/test_qspi_kcu105.runs/impl_1/spiflashprogrammer_top"
tag="20201023_v1"
mkdir -p firmwares
mkdir -p epromcontent 
mkdir -p result 
mkdir -p tmp
rm tmp/*
rm epromcontent/*csv
rm result/*${tag}*
# prepare parameters
savefwname="firmwares/spiflashprogrammer_top_${tag}.bin"
xxd $binfilename".bin" $savefwname 
readEndAddr=`tail -n1 $savefwname | awk -F ":" '{print 0$1}' ` 
nlinesfw=`wc -l $savefwname | awk -F " " '{print $1}'`
eof="02000000"

## read content of programmed eprom
echo "$(date)" "[INFO] Start read EPROM" >> result/result_${tag}.txt
./doeprom.sh "read" $binfilename "fwcontent" $readEndAddr 
echo "$(date)" "[INFO] Read EPROM finished" >> result/result_${tag}.txt

for csvname in epromcontent/*fwcontent*
do 
awk -F "," '{print $10":",$11,$12,$13,$14,$15,$16,$17,$18}' $csvname | sed -n '4,$p' >> tmp/firmware_${tag}.txt
#awk -F "," '{print $10":",$11,$12,$13,$14,$15,$16,$17,$18}' $csvname | awk -v s="4" -v e="$nlinesfw" 'NR>=s&&NR<=e' >> firmware_${tag}.txt
done

# remove useless characters in the last columns
awk -v b=1 -v e=9 'BEGIN{FS=OFS=" "} {for (i=b;i<=e;i++) printf "%s%s",$i, (i<e ? OFS : ORS)}' $savefwname > result/fwcontent_${tag}.txt
awk -v s="0" -v e="$nlinesfw" 'NR>=s&&NR<e' tmp/firmware_${tag}.txt > result/fwcontent_rdback_${tag}.txt

echo "$(date)" "[INFO] Compare content readback from EPROM to content of orignal firmware" >> result/result_${tag}.txt
diff result/fwcontent_${tag}.txt result/fwcontent_rdback_${tag}.txt >> result/result_${tag}.txt

## erase eprom
echo "$(date)" "[INFO] Start erase EPROM" >> result/result_${tag}.txt
./doeprom.sh "erase" $binfilename  
echo "$(date)" "[INFO] Erase EPROM finished" >> result/result_${tag}.txt

echo "$(date)" "[INFO] Start read EPROM" >> result/result_${tag}.txt
./doeprom.sh "read" $binfilename "aftererase" $eof 
echo "$(date)" "[INFO] Read EPROM finished" >> result/result_${tag}.txt

for csvname in epromcontent/*aftererase*
do 
#awk -F "," '{print $10":",$11,$12,$13,$14,$15,$16,$17,$18}' $csvname | sed -n '4,$p' >> result/epromaftererase_${tag}.txt
awk -F "," '{$11,$12,$13,$14,$15,$16,$17,$18}' $csvname | sed -n '4,$p' >> result/epromaftererase_${tag}.txt
done

echo "$(date)" "[INFO] Check if there is only FFFF in EPROM" >> result/result_${tag}.txt
for content in {0..9}
do
	echo "check if there is "${content}" in EPROM" >> result/result_${tag}.txt
	grep $content result/epromaftererase_${tag}.txt >> result/result_${tag}.txt
done

for content in A B C D E  
do
	echo "check if there is "${content}" in EPROM" >> result/result_${tag}.txt
	grep -i $content result/epromaftererase_${tag}.txt >> result/result_${tag}.txt
done

## write eprom
echo "$(date)" "[INFO] Start write EPROM" >> result/result_${tag}.txt
./doeprom.sh "write" $binfilename  
echo "$(date)" "[INFO] Write EPROM finished" >> result/result_${tag}.txt

echo "$(date)" "[INFO] Start read EPROM" >> result/result_${tag}.txt
./doeprom.sh "read" $binfilename "afterwrite" $eof 
echo "$(date)" "[INFO] Read EPROM finished" >> result/result_${tag}.txt

for csvname in epromcontent/*afterwrite*
do 
echo $csvname
awk -F "," '{print $10":",$11,$12,$13,$14,$15,$16,$17,$18}' $csvname | sed -n '4,$p' >> result/epromafterwrite_${tag}.txt
done
