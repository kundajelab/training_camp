#!/bin/bash
for i in $(find ${DATA_DIR}/sam -name '*.sam.gz')
do
    qsub -V -cwd -l h_vmem=8G -N "S$(basename $i)" -o "$(basename $i).out" -e "$(basename $i).err" ${SRC_DIR}/process_alignmentfile.sh ${i}
done
