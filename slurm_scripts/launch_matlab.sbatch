#!/bin/bash
#SBATCH --job-name=par_matlab 
#SBATCH --partition=256GB
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --time=2-00:00:00
#SBATCH -o /home2/kdean/Desktop/slurmOutputs/outputs/job_%j.out
#SBATCH -e /home2/kdean/Desktop/slurmOutputs/errors/job_%j.err
#SBATCH --mail-type ALL
#SBATCH --mail-user kevin.dean@UTSouthwestern.edu

#### Import Modules
module add parallel

#### Define Functions
launch_matlab() {
	echo $1
	module add gsl/1.15
	module add matlab/2019b
	matlab -nodisplay -nodesktop -logfile \
	"/home2/kdean/Desktop/slurmOutputs/outputs/$1.txt" \
	-batch "startup(); segment_glomeruli($1); exit"
}
export -f launch_matlab

PARALLEL="parallel --delay .02 -j 4 --will-cite --joblog home2/kdean/Desktop/slurmOutputs/task.log --env launch_matlab"

#### Execute Function
$PARALLEL sh launch_matlab {} ::: {502..527}
