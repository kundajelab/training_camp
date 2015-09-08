#!/bin/bash
for i in $(find ${DATA_DIR}/bam -name '*.final.bam')
do
    qsub -V -cwd -l h_vmem=64G -pe shm 1 -N "nucleoatac_`basename $i`" -o `basename $i`.out -e `basename $i`.err call_nucleosomes.sh /mnt/data/annotations/by_organism/sacCer/sacCer3/sacCer3.fa /mnt/data/annotations/by_organism/sacCer/sacCer3/sacCer3.genome.bed $i
done
