#!/bin/bash

# Example use of databott (dcm2bids + fmriprep) pipeline for amblyopia fmri dataset on UBC Sockeye HPC
#
#   - Uses databott_slurm.sh to submit a SLURM job on Sockeye
#
#   - DICOM data should be in "$BIDSDIR/sourcedata/sub-$ID" - can be directory of dicoms or contain compressed (.zip or .tar.gz) archives 
#
#   - Supports using the first command line arg to set subject(s). e.g. run_databott.sh "29 30 31"
#
#   - Requires databott_slurm.sh, databott apptainer image, freesurfer license, prepped templateflow directory (Sockeye only)
#
#   
# info@surveybott.com, 2024

# set environment/databott variables
SLURM_ACCOUNT=st-hyim1-1
SOFTWARE_DIR=/arc/project/st-hyim1-1/software
DATABOTT_REPO=$SOFTWARE_DIR/databott
DATABOTT_IMG=$SOFTWARE_DIR/databott_latest.sif
export TEMPLATEFLOW_HOME=$SOFTWARE_DIR/templateflow
export FS_LICENSE=$SOFTWARE_DIR/fs_license.txt

# study-specific variables
BIDSDIR=/scratch/st-hyim1-1/ambly
DCM2BIDS_CONFIG=$BIDSDIR/code/dcm2bids.json
LOGDIR=$BIDSDIR/derivatives/logs/databott
FMRIPREP_ARGS=" --cifti-output 91k --use-aroma --fd-spike-threshold 0.6"

# set subjects (check if provided as input)
if [ -n "$1" ]; then
    SUB="$1"
    echo $SUB
else
   echo "No SUB provided. Exiting"
   exit 1
   #SUB= # space separated, leave empty to run everyone
fi

# run databott (submit slurm job)
#   use "squeue -u $USER" to monitor job stats
#   see below (or run $DATABOTT_REPO/databott_slurm.sh -h) for more info

OWD=$(pwd)
if [ -n "$LOGDIR" ]; then mkdir -p $LOGDIR; cd $LOGDIR; fi

# "-c $DCM2BIDS_CONFIG \" # add to databott_slurm.sh command to do dcm2bids

$DATABOTT_REPO/databott_slurm.sh -d \
	-S $DATABOTT_IMG \
	-b $BIDSDIR \
	-A $SLURM_ACCOUNT \
	-f "$FMRIPREP_ARGS" \
	-s "$SUB"

cd $OWD


# Usage: ./databott_slurm.sh [options]

# Options:
#  -b <path>     Set BIDS directory path
#  -c [path]     Set dcm2bids configuration. Enables dcm2bids and searches /sourcedir for subjects
#  -s [sub]      Set subjects (space-delimited) to include, default all
#  -f [args]     Set fmriprep parameters (default: )
#  -t            Enable tedana processing (default: false)
#  -o            Overwrite existing (default: false)
#  -w            Working directory
#  -P [name]     Set SLURM partition (default: )
#  -T [time]     Set SLURM time limit [format: days-hours:minutes:seconds] (default: 24:00:00)
#  -M [mem]      Set SLURM memory allocation in MB (default 40000)
#  -C [cpus]     Set SLURM CPUs per task (default: 8)
#  -S [path]     Set path to Singularity image file (default: /home/jeilbott/databott_latest.sif)
#  -A [account]  Set the SLURM account flag (default: )
#  -d            Dev mode. Bind over /app with local repo
#  -h            Show this help message

