#!/bin/bash
#SBATCH --partition=xeon-g6-volta
#SBATCH -o verify_accuracy-%a.o ## Make one output file for all members of job array since otherwise file management becomes cumbersome
#SBATCH -a 0-159 ## Run 160 job arrays.
source /etc/profile
module load anaconda/Python-ML-2025a
export PYTHONWARNINGS="ignore"
python ./symbol_accuracy.py  $SLURM_ARRAY_TASK_ID
