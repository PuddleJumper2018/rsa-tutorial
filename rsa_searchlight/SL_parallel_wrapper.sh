#!/bin/bash

path_to_model_list="/home/mpib/sztuka/projects/RSA/code/py-searchlight/LLF/model_list.txt" # points to text file with list of models
model_list=$(cat ${path_to_model_list} | tr '\n' ' ') # creates variable with model names
path_to_sub_list="/home/mpib/sztuka/projects/RSA/code/py-searchlight/LLF/sub_list.txt" # points to text file with list of subs
sub_list=$(cat ${path_to_sub_list} | tr '\n' ' ') # creates variable with sub names
# for models in the list of models
for model in $model_list ; do
  for sub in $sub_list; do
    echo '#!/bin/bash'                    > job.slurm
    echo "#SBATCH --job-name ARCH-_$model-$sub"  >> job.slurm
    echo "#SBATCH -c 1"              >> job.slurm
    echo "#SBATCH --mem 12GB" 		>> job.slurm
    echo "#SBATCH --output /home/mpib/sztuka/logs/euclid-%j.log" >> job.slurm
    echo "which python" 		>> job.slurm
    echo "source ~/arch/bin/activate" 	>>job.slurm
    echo "which python3" 		>>job.slurm
    echo "python3 SL_LLF_parallel.py $model $sub"           >> job.slurm
    sbatch job.slurm
    rm -f job.slurm
  done
done
