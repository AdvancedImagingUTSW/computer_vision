#!/bin/bash
#SBATCH --job-name=clean_directory 
#SBATCH --partition=32GB
#SBATCH -N 1
#SBATCH --mem 28672      # Memory Requirement (MB)
#SBATCH --time=2-00:00:00
#SBATCH -o /home2/kdean/Documents/slurmOutputs/job_%j.out
#SBATCH -e /home2/kdean/Documents/slurmOutputs/job_%j.err
#SBATCH --mail-type ALL
#SBATCH --mail-user kevin.dean@UTSouthwestern.edu

/home2/kdean/GIT/computer_vision/shell_scripts/clean_MIL_directory.sh
