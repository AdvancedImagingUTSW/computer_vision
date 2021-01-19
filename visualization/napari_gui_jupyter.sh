#!/bin/bash

module add cuda101/toolkit/10.1.243
module load python/3.6.4-anaconda
source activate napari-env

cd /home2/kdean/Desktop/GitHub/computer_vision/jupyter_notebooks
jupyter-lab
