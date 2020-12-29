#!/bin/bash
# java -cp /home2/kdean/Desktop/GitHub/computer_vision/deconvolution/epfl/PSFGenerator.jar PSFGenerator /home2/kdean/Desktop/GitHub/computer_vision/deconvolution/epfl/psf_config.txt

java -jar /home2/kdean/Desktop/GitHub/computer_vision/deconvolution/epfl/DeconvolutionLab_2.jar Run \
-image file ~/Desktop/test-1.tif \
-psf file ~/Desktop/PSF2.tif \
-algorithm RL 20 \
-out stack test_deconvolved.tif \
-path ~/Desktop/
