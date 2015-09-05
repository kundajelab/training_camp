#!/bin/bash
for i in $(find ${DATA_DIR}/fastq -name '*.fastq.gz' | sed 's/_R1.fastq.gz//g' | sed 's/_R2.fastq.gz//g' | xargs -I fname basename fname | sort | uniq)
do
    qsub -V -cwd -l h_vmem=2G -pe shm 4 -N "S"$i -o $i.out -e $i.err ${SRC_DIR}/map_reads.sh ${YEAST_INDEX} ${DATA_DIR}/fastq/${i}_R1.fastq.gz ${DATA_DIR}/fastq/${i}_R2.fastq.gz
done
