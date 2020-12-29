#! /bin/bash
# A program that attempts to compile the Flowscape software.

module purge;
# previously tried cmake/2.8.12.  
module load shared slurm cmake/3.10.2;

# base gcc/4.8.5.  Previously tried 5.4.0
module load gcc/8.3.0;
module list;
rm -R /home2/kdean/Applications/flowscope/flowscope/CSL2/build/*;
cd /home2/kdean/Applications/flowscope/flowscope/CSL2/build;

# compile with cmake
cmake ..;

# compile with make
make

