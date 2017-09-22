echo $GENOME_FILE_DIR
echo $MOTIF_DIR
b=$1 #bed file in which we will search for motifs
genomeFasta=/srv/scratch/training_camp/saccer3/SacCer3_genome.fa
#get the fasta file corresponding to the bed file
bedtools getfasta -fi ${genomeFasta} -bed ${b} -fo ${MOTIF_DIR}/$(basename $b | sed 's/.bed//g').fa
#scan for the motif collection in homer 
findMotifsGenome.pl ${b} $genomeFasta ${MOTIF_DIR}/$(basename $b | sed 's/.bed//g') -size given -len 8 -preparsedDir $MOTIF_DIR

