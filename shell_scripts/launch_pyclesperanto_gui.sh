#!/bin/bash
image_location='/archive/MIL/marciano/20210302_cropped_volumes/20201211_mutant/1_CH00_000000.tif'

#image_location='/archive/MIL/ramirez/JConnor_Sample520_112019/ch02/JConnor_Sample520_112019_S000104_L01_ch02.tif'

module add cuda101/toolkit/10.1.243
module load python/3.6.4-anaconda
source activate pyclesperanto

cat > /home2/kdean/tmp/temporary_python.py <<_EOF_

# Import Modules
import pyclesperanto_prototype as cle
from skimage.io import imread
import napari
import napari_pyclesperanto_assistant

# Select GPU
cle.select_device()
print(cle.get_device().name)


# load data
image = imread('$image_location')
print(image.shape)

# Specify Voxel Size
# voxel_size = [0.406, 0.406, 1.075] # microns

# Launch Napari
with napari.gui_qt():
    viewer = napari.Viewer()

    # attach the assistant
    napari_pyclesperanto_assistant.napari_plugin(viewer)
    
    # viewer.add_image(image, name='Spheroid', scale=voxel_size)
    viewer.add_image(image)

    gui = workflow.Gui()
    viewer.window.add_dock_widget(gui)
_EOF_

python /home2/kdean/tmp/temporary_python.py
