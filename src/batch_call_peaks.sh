#!/bin/bash
for i in $(find ${DATA_DIR}/tagAlign -name '*.tagAlign.gz')
do
    qsub -V -cwd -q training-camp -A training-camp -l h_vmem=4G -N $(basename $i) -o $i.out -e $i.err ./call_peaks.sh yeast $i
done