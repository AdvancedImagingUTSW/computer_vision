#!/bin/bash -i
if [ -d $@ ]; then
	quickMIPSwap.sh $1/*
else
	quickMIPSwap.sh $@
fi
module --silent load gmic
gmic /tmp/gmic-cache/*.png  -montage X
