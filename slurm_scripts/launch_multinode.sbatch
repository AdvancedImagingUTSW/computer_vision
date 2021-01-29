#!/bin/bash
#SBATCH --job-name=parallel
#SBATCH --partition=32GB
#SBATCH --nodes=2
#SBATCH --cpus-per-task=2
#SBATCH --time=2:00:00
#SBATCH -o /home2/kdean/Documents/slurmOutputs/outputs/job_%j.out
#SBATCH -e /home2/kdean/Documents/slurmOutputs/errors/job_%j.err
#SBATCH --mail-type FAIL
#SBATCH --mail-user kevin.dean@UTSouthwestern.edu

## Command(s) to run (example):
module load parallel

#### Define Functions
mycp() {
	hostname
	echo copying ${1} to ${2} on $host
	cp ${1} ${2}
}

### Defines Environment Variables
export -f mycp
export WDIR=/home2/kdean/Documents/slurmOutputs/errors

### CD into the directory
cd $WDIR

# set number of jobs based on number of cores available and number of threads per job
export JOBS_PER_NODE=$(( $SLURM_CPUS_ON_NODE / $SLURM_CPUS_PER_TASK ))

echo Processing $WDIR
echo The number CPUs per node $SLURM_CPUS_ON_NODE
echo The number of CPUs per task $SLURM_CPUS_PER_TASK
echo The number of jobs per node $JOBS_PER_NODE
echo $SLURM_JOB_NODELIST |sed s/\,/\\n/g > hostfile

# Define Commands
INPUT_COMMAND="ls $WDIR"
SAVE_LOG=/home2/kdean/Documents/slurmOutputs/$SLURM_JOB_ID_task.log
PARALLEL="parallel --delay .05 -j $JOBS_PER_NODE --will-cite --joblog $SAVE_LOG --env mycp"

# parallel --jobs $JOBS_PER_NODE --slf hostfile --wd $WDIR --joblog task.log --resume --progress -a task.lst sh myscp.sh {} output/{/.}.blst $SLURM_CPUS_PER_TASK
# parallel -j $JOBS_PER_NODE -a task.lst --env mycp --joblog /home2/kdean/Documents/parallel.log mycp {} {.}.out
eval $INPUT_COMMAND | $PARALLEL mycp {} {.}.output

