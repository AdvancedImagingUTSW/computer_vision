#!/bin/bash
module load imod/4.9.3

VAR1="/archive/MIL/hanker/20200219/MCF7-1/AktPH-GFP/200218/Cell1/1_CH00_000000"
VAR2=".tif"
VAR4="$VAR1$VAR2"
echo "Input: $VAR4"

# Z, Y, X
# -34.21 results in 11.16 degree slope.
# -24.21 results in a 24.21 degree slopw
rotatevol -i $VAR4 -ou ~/tmp/temp.mrc -a -3.18,0,-36.78 -f 0; 

VAR5="_rotated.tif"
VAR6="$VAR1$VAR5"
echo "Output: $VAR6"

mrc2tif -s ~/tmp/temp.mrc $VAR6;





