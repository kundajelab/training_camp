echo $GENOME_FILE_DIR
echo $MOTIF_DIR
b=$1 #bed file in which we will search for motifs
#genomeFasta=${YEAST_DIR}/WholeGenomeFasta/genome.fa
genomeFasta=/srv/scratch/training_camp/saccer3/SacCer3_genome.fa
#b=/tc2015/oursu/results/peaks/PooledReps_Sample3_arp-ko.4col.peaks.bed


#get the fasta file corresponding to the bed file
bedtools getfasta -fi ${genomeFasta} -bed ${b} -fo ${MOTIF_DIR}/$(basename $b | sed 's/.bed//g').fa

#make a soft link to the genome file
#genomeLink=${GENOME_FILE_DIR}/$(basename ${genomeFasta})
#ln -s ${genomeFasta} ${genomeLink}

#scan for the motif collection in homer 
findMotifsGenome.pl ${b} $genomeFasta ${MOTIF_DIR}/$(basename $b | sed 's/.bed//g') -size given -len 8
#### remember to set TMP for homer
