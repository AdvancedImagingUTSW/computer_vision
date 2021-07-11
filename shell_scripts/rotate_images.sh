#!/bin/bash
clear
module load imod/4.9.3
for i in {00..99}
do
	VAR1="/home2/kdean/Desktop/20200217_GEMS/ch1/1_CH00_0000"
	VAR2=$i
	VAR3="_deskewed.tif"
	VAR4="$VAR1$VAR2$VAR3"

	echo "Input: $VAR4"

	# rotatevol -i $VAR4 -ou ~/tmp/temp3.mrc -a -90,0,0 -f 0 -q;
	rotatevol -i $VAR4 -ou ~/tmp/temp3.mrc -a -90,0,0 -f 0 -s 512,337,21; 
	
	VAR5="_rotated.tif"
	VAR6="$VAR1$VAR2$VAR5"
	echo "Output: $VAR6"


	mrc2tif -s ~/tmp/temp3.mrc $VAR6;

done




