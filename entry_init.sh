#!/bin/bash
#entrypoint pre-initialization
source /environment
source activate mne

export TMPDIR=/tmp
export JOBLIB_TEMP_FOLDER=$TMPDIR

#cuda
#export PATH=/bind/lib/cuda/bin:"$PATH"
#export LD_LIBRARY_PATH=/bind/lib/cuda/lib64:${LD_LIBRARY_PATH}

#run the user command
exec "$@"
