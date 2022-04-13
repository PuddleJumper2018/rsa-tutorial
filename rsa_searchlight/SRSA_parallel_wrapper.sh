#!/bin/bash
# This is job wrapper for low-level visual feature models. Looped over model names list (stored in model_list.txt)
# and subject names (stored in sub_list.txt). If you wish to change the models to other you need to modify the following:
# 1. path_to_model_list 2. model_list 3. path_to_sub_list 3. sub_list.
# in the SL_parallel.py you need to modify: directories. and RDM file.

path_to_model_list="/pathto/.model_list.txt" # points to text file with list of models
model_list=$(cat ${path_to_model_list} | tr '\n' ' ') # creates variable with model names
path_to_sub_list="/pathto/sub_list.txt" # points to text file with list of subs
sub_list=$(cat ${path_to_sub_list} | tr '\n' ' ') # creates variable with sub names
# for models in the list of models
for model in $model_list ; do
  for sub in $sub_list; do
    echo '#!/bin/bash'                    > job.slurm
    echo "#SBATCH --job-name ARCH-_$model-$sub"  >> job.slurm
    echo "#SBATCH -c 1"              >> job.slurm
    echo "#SBATCH --mem 12GB" 		>> job.slurm
    echo "#SBATCH --output /pathto/logs/euclid-%j.log" >> job.slurm
    echo "which python" 		>> job.slurm
    echo "source ~/arch/bin/activate" 	>>job.slurm
    echo "which python3" 		>>job.slurm
    echo "python3 SRSA_parallel.py $model $sub"           >> job.slurm
    sbatch job.slurm
    rm -f job.slurm
  done
done
