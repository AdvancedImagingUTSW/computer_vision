#! /bin/bash

module load gmic

gmic /archive/bioinformatics/Danuser_lab/Fiolka/Manuscripts/RemoteFocus/Revision/3PhBrainScile/test1.tif -a z  \
-blur 2.5 -laplacian[-1] -*[-1] -1 \
--gt[-1] 25.0% -e \"thresholding the image at X%\" \
--area[-1] 0 -*[-1,-2] -gt[-1] 1% -* -e \"suppressing the X% smallest connected component\" \
--orthoMIP -o[-1] ~/Desktop/mip.tif -rm[-1] -e \"print a mip for debugging\" \
isosurface3d 4 -moded3d 2 -o[-1] ~/Desktop/surface.off -e \"build surface\"
