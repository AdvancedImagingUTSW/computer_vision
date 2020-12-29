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

#### Load Modules
module add parallel


#### Define Functions
launch_ilastik() {
	echo "Processing file $1"
	/home2/kdean/Desktop/Applications/ilastik-1.3.3post3-Linux/run_ilastik.sh \
	--headless \
	--readonly=1 \
	--output_format='multipage tiff' \
	--export_source="Simple Segmentation" \
	--output_filename_format=/archive/MIL/marciano/20201211_CapillaryLooping/cropped/wt_segmented/{nickname}_results.tiff \
	--project=/archive/MIL/marciano/20201211_CapillaryLooping/cropped/capillary_segmentation.ilp \
	$1
}
export -f launch_ilastik

INPUT_COMMAND="ls /archive/MIL/marciano/20201211_CapillaryLooping/cropped/wt/1_CH00_*.h5"

PARALLEL="parallel --delay .05 -j 12 --will-cite --joblog /home2/kdean/Desktop/slurmOutputs/$SLURM_JOB_ID_task.log --env launch_ilastik"


#### Execute Functions
eval $INPUT_COMMAND | $PARALLEL launch_ilastik {}


