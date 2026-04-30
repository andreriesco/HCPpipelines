#!/bin/bash

MAX_PARALLEL=2

run_preprocessing() {
    local dir="$1"

    echo "Processing direction ${dir}"
    StudyFolder="${PWD}/datasets/HCP/HCPDatasetSubsetS1200UnprocessedPrepared_shell_1000/${dir}" #Location of Subject folders (named by subjectID)
    echo "StudyFolder: ${StudyFolder}"
    ./Examples/Scripts/DiffusionPreprocessingBatch.sh --StudyFolder="${StudyFolder}"
}

Directions=(
    '90+18'
    '90+2'
    '60+2'
    '45+2'
    '30+2'
    '15+2'
    '10+2'
    '6+2'
)

for dir in "${Directions[@]}"; do
    run_preprocessing "${dir}" &

    while [ "$(jobs -pr | wc -l)" -ge "${MAX_PARALLEL}" ]; do
        wait -n
    done
done

wait


