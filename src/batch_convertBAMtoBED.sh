#!/bin/bash
for i in $(find ${DATA_DIR}/bam -name '*.final.bam')
do
    qsub -V -cwd -l h_vmem=2G -N "bam_convert_$(basename $i)" -o "$(basename $i).out" -e "$(basename $i).err" ${SRC_DIR}/convertBAMtoBED.sh ${i}
done
