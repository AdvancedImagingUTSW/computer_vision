#!/bin/bash
#SBATCH --job-name=par_matlab 
#SBATCH --partition=256GB
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=2-00:00:00
#SBATCH -o /home2/kdean/Documents/slurmOutputs/job_%j.out
#SBATCH -e /home2/kdean/Documents/slurmOutputs/job_%j.err
#SBATCH --mail-type ALL
#SBATCH --mail-user kevin.dean@UTSouthwestern.edu


#### Execute Function
module add gsl/1.15;
module add matlab/2020b;
cell_idx=2
matlab -nodisplay -nodesktop -logfile "startup(); process_tfm_data($cell_idx); exit"

