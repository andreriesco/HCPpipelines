#!/bin/bash

MAX_PARALLEL=4

run_preprocessing() {
    local dir="$1"
    DenoiseAlgo='mppca'
    echo "Processing direction ${dir}"
    StudyFolder="${PWD}/datasets/HCP/HCPDatasetUnprocessedPrepared_shell_1000/denoise_${DenoiseAlgo}/${dir}" #Location of Subject folders (named by subjectID)
    echo "StudyFolder: ${StudyFolder}"
    # Collect numeric subject IDs that do not yet have a T1w/Diffusion output folder.
    Subjlist=$(for subjdir in "${StudyFolder}"/[0-9]*; do
        echo "Checking subject directory: ${subjdir}" >&2
        [ -d "${subjdir}" ] || continue
        if [ ! -f "${subjdir}/T1w/Diffusion/data.nii.gz" ]; then
            subj=$(basename "${subjdir}")
            echo "Processing subject ${subj} in direction ${dir}" >&2
            ./Examples/Scripts/DiffusionPreprocessingBatch.sh --StudyFolder="${StudyFolder}" --Subject="${subj}" >&2
            rm -rf "${subjdir}/Diffusion"
        else
            echo "Subject ${subjdir} already has T1w/Diffusion output folder, skipping." >&2
        fi
    done | sort -d | tr '\n' ' ' | sed 's/[[:space:]]*$//')
}

# (90, 1), (90, 2), (90, 3), (90, 4), (90, 6), (90, 9), (90, 12), (90, 15)]
# (6, 18), (10, 18), (15, 18), (20, 18), (30, 18), (45, 18), (60, 18), (75, 18)]
# (6, 1), (10, 2), (15, 3), (20, 4), (30, 6), (45, 9), (60, 12), (75, 15)]


Directions=(
    '90+18'
    '90+1'
    '90+2'
    '90+3'
    '90+4'
    '90+6'
    '90+9'
    '90+12'
    '90+15'
    '6+1'
    '10+2'
    '15+3'
    '20+4'
    '30+6'
    '45+9'
    '60+12'
    '75+15'
    '6+18'
    '10+18'
    '15+18'
    '20+18'
    '30+18'
    '45+18'
    '60+18'
    '75+18'
)

for dir in "${Directions[@]}"; do
    run_preprocessing "${dir}" &

    while [ "$(jobs -pr | wc -l)" -ge "${MAX_PARALLEL}" ]; do
        wait -n
    done
done

wait


# Send
# rsync -avz --delete /home/andrera/Documents/doutorado/tese/HCPpipelines -e "ssh -p 22000" principal@143.107.235.162:/home/principal/Documents/andre/doutorado/tese

# Receive
# rsync -avz  -e "ssh -p 22000" principal@143.107.235.162:/home/principal/Documents/andre/doutorado/tese/HCPpipelines /home/andrera/Documents/doutorado/tese
