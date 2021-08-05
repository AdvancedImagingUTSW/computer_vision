# to run in analysis root folder. Vague feeling of immense power is normal for the first tries.
filePattern=$@;
module --silent load gmic
module --silent load parallel
mkdir /tmp/gmic-cache/
rm -rf /tmp/gmic-cache/*
fileList=`find $filePattern -maxdepth 0 ! -name '*.txt' -type f -print0 | xargs -0r ls -v`
ls -v $fileList
ls -v $fileList | parallel --will-cite  gmic {} -max -adjust_colors 0,20,20 -normalize 0,255 -o '/tmp/gmic-cache/mip-$(printf "%.5d" {#})-print.png'
