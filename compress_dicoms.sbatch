#!/bin/bash

#SBATCH --job-name=compress-folders
#SBATCH --output=compress-%A_%a.out
#SBATCH --error=compress-%A_%a.err
#SBATCH --array=1-28
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --mem=6G

# Load necessary modules (if required)
# module load tar

DICOMDIR_PROJ='/arc/project/st-hyim1-1/fMRI data_2024/Data'
DICOMDIR_SCRATCH='/scratch/st-hyim1-1/ambly/sourcedata'

# Navigate to the target directory
cd "$DICOMDIR_PROJ"

# Read a list of directories into an array
SUB_ARRAY=($(find . -maxdepth 1 -type d -name "sub*" | sed 's@./@@'))

# Use SLURM_ARRAY_TASK_ID to pick a directory
SUB=${SUB_ARRAY[$SLURM_ARRAY_TASK_ID-1]}
SUBDIR_PROJ="$DICOMDIR_PROJ/$SUB"

SUB="$(echo $SUB | sed 's/subj/sub/')"
SUBDIR_SCRATCH="$DICOMDIR_SCRATCH/$SUB"
if [ ! -d "$SUBDIR_SCRATCH" ]; then
  mkdir -p "$SUBDIR_SCRATCH"
fi

echo "Compressing ${SUBDIR_PROJ} to ${SUBDIR_SCRATCH}/${SUB}.tar.gz"
cd "${SUBDIR_PROJ}"

# Compress the directory
tar -czf "${SUBDIR_SCRATCH}/${SUB}.tar.gz" ./

echo "Done"
