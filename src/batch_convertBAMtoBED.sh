#!/bin/bash
for i in $(find ${DATA_DIR}/bam -name '*.final.bam')
do
    qsub -V -cwd -l h_vmem=2G -N "S$(basename $i)" -o "${DATA_DIR}/bam/$(basename $i).convertBAMtoBED.out" -e "${DATA_DIR}/bam/$(basename $i).convertBAMtoBED.err" ${SRC_DIR}/convertBAMtoBED.sh ${i}
done
