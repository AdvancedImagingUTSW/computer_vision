#!/bin/bash

module add cuda11/toolkit/11.1.0
module load python/3.6.4-anaconda
source activate imageanalysis
# cd /home2/kdean/Desktop/GitHub/computer_vision/jupyter_notebooks/
cd /home2/kdean/Desktop/Git/external/OPM
jupyter-lab
