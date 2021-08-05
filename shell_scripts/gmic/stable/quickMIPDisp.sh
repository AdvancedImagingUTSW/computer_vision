# to run in analysis root folder. Vague feeling of immense power is normal for the first tries.
filePattern=$@;
module --silent load gmic
module --silent load parallel
mkdir /tmp/gmic-cache/
rm -rf /tmp/gmic-cache/*
ls -v $filePattern
ls -v  $@ | parallel --will-cite  gmic {} --max -l[-1] -split z -max -adjust_colors 0,20,20 -normalize 0,255 -endl -a[0--2] z -d
