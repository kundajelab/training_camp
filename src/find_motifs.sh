
b=$1 #bed file in which we will search for motifs
genomeFasta=${YEAST_DIR}/WholeGenomeFasta/genome.fa
b=/tc2015/oursu/results/peaks/PooledReps_Sample3_arp-ko.4col.peaks.bed


#get the fasta file corresponding to the bed file
bedtools getfasta -fi ${genomeFasta} -bed ${b} -fo ${DATA_DIR}/results/motifs/$(basename $b | sed 's/.bed//g').fa

#make a soft link to the genome file
genomeLink=${DATA_DIR}/results/motifs/genomeFiles/$(basename ${genomeFasta})
ln -s ${genomeFasta} ${genomeLink}

#scan for the motif collection in homer 
findMotifsGenome.pl ${b} ${genomeLink} ${DATA_DIR}/results/motifs/ -size given -len 8
#### remember to set TMP for homer
