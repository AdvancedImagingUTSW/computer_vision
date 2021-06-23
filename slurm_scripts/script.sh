#!/bin/bash

let "ID=$SLURM_NODEID*$SLURM_NTASKS/$SLURM_NNODES+$SLURM_LOCALID+1"
echo $ID

matlab \
-nodisplay \
-nodesktop \
-logfile "/home2/kdean/Documents/slurmOutputs/$ID.txt" \
-batch "startup(); process_tfm_data($ID); exit"
