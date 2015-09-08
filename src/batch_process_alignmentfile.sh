#!/bin/bash
for i in $(find ${DATA_DIR}/sam -name '*.sam.gz')
do
    qsub -V -cwd -l h_vmem=8G -N "S$(basename $i)" -o "${DATA_DIR}/sam/$(basename $i).process_alignmentfile.out" -e "${DATA_DIR}/sam/$(basename $i).process_alignmentfile.err" ${SRC_DIR}/process_alignmentfile.sh ${i}
done
