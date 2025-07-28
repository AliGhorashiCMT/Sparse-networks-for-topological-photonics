#!/bin/bash
#SBATCH --partition=xeon-g6-volta
#SBATCH -o mpb-calculation-%a.o ## Make one output file for all members of job array since otherwise file management becomes cumbersome
#SBATCH -a 1-200 ## Run 200 job arrays. 
source /etc/profile
export PYTHONPATH="/home/gridsan/aligho/.local/lib/python3.8/site-packages/PyNormaliz-2.15-py3.8-linux-x86_64.egg"
export LD_PRELOAD=/state/partition1/llgrid/pkg/anaconda/anaconda3-2023b/lib/libstdc++.so julia

#julia ./runlattices-array.jl  $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_COUNT
julia ./runlattices-contrasts.jl  $SLURM_ARRAY_TASK_ID $SLURM_ARRAY_TASK_COUNT
