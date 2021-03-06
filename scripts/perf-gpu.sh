#!/bin/bash

#SBATCH --time=0:45:00     # walltime
#SBATCH --nodes=1          # number of nodes
#SBATCH --mem-per-cpu=5G   # memory per CPU core
#SBATCH --gres=gpu:4

set -euo pipefail
set -x #echo on
hostname

cd ${CI_SRCDIR}

export JULIA_DEPOT_PATH="$(pwd)/.slurmdepot_gpu"
export JULIA_CUDA_USE_BINARYBUILDER=false
export OPENBLAS_NUM_THREADS=1
export CLIMATEMACHINE_SETTINGS_FIX_RNG_SEED=true

module load cuda/10.0 openmpi/4.0.3_cuda-10.0 julia/1.4.2 hdf5/1.10.1 netcdf-c/4.6.1

export TEST_NAME="$(basename "$1")"
mpiexec nvprof --profile-child-processes --profile-api-trace none --normalized-time-unit us --csv --log-file %q{CI_OUTDIR}/%q{TEST_NAME}-%p.%q{OMPI_COMM_WORLD_RANK}.summary.nvplog julia --color=no --project "$@"
mpiexec nvprof --profile-child-processes --normalized-time-unit us --metrics local_load_transactions,local_store_transactions --csv --log-file %q{CI_OUTDIR}/%q{TEST_NAME}-%p.%q{OMPI_COMM_WORLD_RANK}.metrics.nvplog julia --color=no --project "$@"
