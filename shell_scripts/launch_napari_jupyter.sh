#!/bin/bash

module load cuda112/toolkit/11.2.0
module load python/3.8.x-anaconda
source activate napari

cd /home2/kdean/GIT/computer_vision/jupyter_notebooks

jupyter-lab

