#!/bin/bash

module load gmic/1.6.0.0
# other versions include 2.1.1

gmic $1 -a z -blur 2.5 -laplacian[-1] -*[-1] -1 --gt[-1] 3 --area[-1] 0 -*[-1,-2] -gt[-1] 90% -* isosurface3d 4 -moded3d 2 -o[-1] $2 

# old working parameters: 2.15% & 20%

# gt is the threshold step
# area is the smallest connected component

threshold=5%
smallest_component=3%

#gmic $1 -a z  \
#--gt[-1] $threshold -e \
#--area[-1] 0 -*[-1,-2] -gt[-1] $smallest_component -* -e \
#--orthoMIP -o[-1] $2.debug.tif -rm[-1] -e \
#isosurface3d 4 -moded3d 2 -o[-1] $2


