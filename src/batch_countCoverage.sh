#!/bin/bash
for i in $(find ${DATA_DIR}/tagAlign -name '*.tagAlign.gz')
do
    qsub -V -cwd -l h_vmem=4G -N "job"$(basename $i) -o $i.out -e $i.err $SRC_DIR/create_countCoverageTracks.sh $i
done
