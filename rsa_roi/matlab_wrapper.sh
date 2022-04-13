#!/bin/bash
job_name="ARCH_dCNN" # whatever is the name of your project analysis
path_to_model_list="/home/mpib/user/models.txt" # points to text file with list of models, subjects or whatever you want to loop
model_list=$(cat ${path_to_model_list} | tr '\n' ' ') # creates variable with looped variable (in my case it's a model name)

for model in $model_list; do
      sbatch \
          --job-name ${job_name}_${model} \
          --cpus-per-task 1 \
          --mem 32gb \
          --time 24:00:00 \
          --output /home/mpib/user/logs/rsa-roi-${job_name}-%j.log \
          --workdir . \
          --wrap ". /etc/profile ; module load matlab/R2020a; matlab -nodisplay -r \"your_script('${model}')\""
done
