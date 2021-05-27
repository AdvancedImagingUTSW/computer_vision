#!/bin/bash

module load gmic/2.1.1 

# Example Command
# '/home2/kdean/Desktop/GitHub/computer_vision/shell_scripts/gmic_build_mesh.sh' '/home2/kdean/Desktop/input.tif' ~/Desktop/output.off

# gmic $1 -a z -blur 2.5 -laplacian[-1] -*[-1] -1 --gt[-1] 3 --area[-1] 0 -*[-1,-2] -gt[-1] 90% -* isosurface3d 4 -moded3d 2 -o[-1] $2 

# gt is the threshold step
# area is the smallest connected component

gmic $1 -a z  \
--gt[-1] 50% -e \
--area[-1] 0 -*[-1,-2] -gt[-1] 50% -* -e \
-isosurface3d 1 -o ~/Desktop/test.off

