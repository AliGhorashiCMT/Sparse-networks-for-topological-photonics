#!/bin/bash
#SBATCH --partition=xeon-g6-volta
##SBATCH --gres=gpu:volta:1
##SBATCH --exclusive
##SBATCH -n 20
#SBATCH -o inverse-design-%a.o ## Make one output file for all members of job array since otherwise file management becomes cumbersome
#SBATCH -a 0-7 ## Run 200 job arrays.
source /etc/profile
module load anaconda/Python-ML-2025a
export PYTHONWARNINGS="ignore"
#python ./Inverse_Design_From_Kan.py  $SLURM_ARRAY_TASK_ID
#python ./Two_Tone_Inverse_Design_From_Kan.py  $SLURM_ARRAY_TASK_ID
#python ./Inverse_Design_From_Symbols.py  $SLURM_ARRAY_TASK_ID
#python ./Two_Tone_Inverse_Design_From_Symbols.py  $SLURM_ARRAY_TASK_ID
#python ./Inverse_Design_From_Symbols_Random.py  $SLURM_ARRAY_TASK_ID
python ./Two_Tone_Inverse_Design_From_Symbols_Random.py  $SLURM_ARRAY_TASK_ID
