#!/bin/bash


cd ~/Desktop/GitHub/external/ACME/Linux-x86-64/

# Median Filter - Sigma 0.3
./cellPreprocess ~/Desktop/1_CH00_000000.mha ~/Desktop/preprocess.mha 0.3

# Resample Data
./resample ~/Desktop/preprocess.mha ~/Desktop/preprocess.mha 1.0 1.0 0.835

# Planarity Filter - Sigma 0.4
sigma=4
./multiscalePlateMeasureImageFilter ~/Desktop/preprocess.mha ~/Desktop/planarity.mha ~/Desktop/eigen.mha $sigma

# Tensor Voting - Sigma 0.5, rod (a) = 0.4, plate (b) = 0.4, ball (g) = 850
./membraneVotingField3D ~/Desktop/planarity.mha ~/Desktop/eigen.mha ~/Desktop/TV.mha 0.5

# Watershed
./membraneSegmentation ~/Desktop/preprocess.mha ~/Desktop/TV.mha ~/Desktop/segmented.mha 1.0

