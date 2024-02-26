#!/usr/bin/env bash
# Created by Pierre Walker (GitHub: @pw0908) on 2024-02-23

#SBATCH --job-name=NaImpl
#SBATCH --time=7-00:00:00

# Slurm: Node configuration
#SBATCH --partition=PersonalQ
#SBATCH --nodes=1 --ntasks-per-node=1 --mem=4G
#SBATCH --gres=gpu:0 --gpu-bind=closest

# Slurm: Runtime I/O
#SBATCH --output=/home/pjwalker/slurm-reports/slurm-%j.out --error=/home/pjwalker/slurm-reports/slurm_error-%j.out

# built-in shell options
# set -o errexit # exit when a command fails
# set -o nounset # exit when script tries to use undeclared variables

# simulation path variables
proj_base_dir="$(pwd)/.."
scripts_dir="${proj_base_dir}/scripts"
params_dir="${proj_base_dir}/submission/input"

input_globals=(
    implicit_water_sodium.sh
)

# start script
date_time=$(date +"%Y-%m-%d %T")
echo "START: ${date_time}"

parallel --link --keep-order --ungroup --halt-on-error '2' --jobs '1' \
    "${scripts_dir}/run.sh" "${params_dir}/{1}" --all \
    ::: "${input_globals[@]}"

# end script
date_time=$(date +"%Y-%m-%d %T")
echo "END: ${date_time}"
