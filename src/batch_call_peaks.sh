#!/bin/bash
for i in $(find ${DATA_DIR}/tagAlign -name '*.tagAlign.gz')
do
    qsub -V -cwd -l h_vmem=4G -N call_peaks_$(basename $i) -o $i.out -e $i.err ${SRC_DIR}/call_peaks.sh yeast $i
done
