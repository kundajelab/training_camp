#!/bin/bash
for i in $(find ${DATA_DIR}/tagAlign/mergedReplicates -name '*.tagAlign.gz')
do
    qsub -V -cwd -l h_vmem=4G -N "S$(basename $i)" -o "${DATA_DIR}/tagAlign/mergedReplicates/${i}.call_peaks.out" -e "${DATA_DIR}/tagAlign/mergedReplicates/${i}.call_peaks.err" ${SRC_DIR}/call_peaks.sh yeast $i
done
