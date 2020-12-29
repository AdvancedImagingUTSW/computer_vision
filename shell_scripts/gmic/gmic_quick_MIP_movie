#!/bin/bash -i
if [ -d $@ ]; then
	quickMIPSwap.sh $1/*
else
	quickMIPSwap.sh $@
fi
mkdir -p ~/gmic-video/test-images/
rm ~/gmic-video/test-images/*
module --silent load gmic
gmic /tmp/gmic-cache/*.png  -a z -d -split z -o ~/gmic-video/test-images/frame.png  -o ~/gmic-video/test.avi 
