#!/bin/bash
#SBATCH --job-name=parallel_ilastik 
#SBATCH --partition=256GB
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=2-00:00:00
#SBATCH -o /home2/kdean/Desktop/slurmOutputs/outputs/job_%j.out
#SBATCH -e /home2/kdean/Desktop/slurmOutputs/errors/job_%j.err
#SBATCH --mail-type ALL
#SBATCH --mail-user kevin.dean@UTSouthwestern.edu


IMAGEJ="/home2/kdean/Desktop/ImageJ-linux64 --headless --console -macro "

MACRO="/home2/kdean/Desktop/GitHub/data_analysis/marciano_lab/launch_ijm_function.ijm"

FILES="ls /archive/MIL/marciano/20201211_CapillaryLooping/cropped_gamma/wt/1_CH00_*.tif"

module add parallel

PARALLEL="parallel --delay .2 -j 15 --will-cite --joblog task.log"

eval $FILES | $PARALLEL $IMAGEJ $MACRO {}

FILES="ls /archive/MIL/marciano/20201211_CapillaryLooping/cropped_gamma/mutant/1_CH00_*.tif"

eval $FILES | $PARALLEL $IMAGEJ $MACRO {}
