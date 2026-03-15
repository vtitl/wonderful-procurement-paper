#!/usr/bin/env bash
#$ -N collusion-detection
#$ -j y
#$ -l m_mem_free=60G
#$ -l h_rt=48:00:00
#$ -pe openmp 4
#$ -cwd

# RUN TIME: ~17h on 14-core M4 MacBook Pro, ~21.5h on 4-core Linux cluster
# MEMORY: peak virtual memory ~163GB (driven by Julia permutation test)


set -o xtrace
set -e
set -o pipefail

rm -rf ../data/processed/
rm -rf ../output/
mkdir -p ../data/processed/
mkdir -p ../output/logs/
touch ../output/scalars.tex


if [ "$(basename "$PWD")" != "code" ]; then
    echo "Error: This script must be run from the 'code' directory."
    exit 1
fi

STATABIN="${STATABIN:-stata-se}"


run_and_log_stata() {
    local do_file_path="$1"
    shift
    local do_file_name
    do_file_name=$(basename "$do_file_path" .do)
    local log_file="${do_file_name}.log"

    $STATABIN -b "$do_file_path" "$@"

    if grep -E --before-context=1 --max-count=1 "^r\([0-9]+\);$" "$log_file"; then
        exit 1
    fi

    if [ -f "../output/logs/$log_file" ]; then
        rm "../output/logs/$log_file"
    fi

    mv "$log_file" "../output/logs/$log_file"
}

#####################################
# TABLES AND FIGURES FROM THE PAPER #
#####################################
(
date #so we have start-time
	run_and_log_stata datasetMerging.do
	run_and_log_stata analysis.do
	

) 2>&1 | tee -a ../output/logs/make.log
