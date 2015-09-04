#!/bin/bash
# read from command line which files to align
p1=$1

# help
if [ -z "$p1" ]
then
    echo "This will convert to bam, sort, remove mitochondria/duplicates and histogram insert size"
    echo "$(basename $0) <samFile>"
    echo "<samFile>: Required sam input file"
    exit
fi


# convert to bam and sort
echo "Sorting..."
out1prefix=$(echo $p1 | sed 's/\.sam\.gz$//')
out1="${out1prefix}.bam"
echo ${out1}
samtools view -S -u $p1 | samtools sort - ${out1prefix}
#index
samtools index $out1

#samtools rmdup
echo "Removing duplicates..."
out2=$(echo ${out1} | sed 's/\.bam$/.rmdup.bam/')
echo ${out2}
java -Xmx4G -jar $PICARDROOT/MarkDuplicates.jar INPUT=${out1} OUTPUT=${out2} METRICS_FILE="${out2}.dups.log" REMOVE_DUPLICATES=true
# index
samtools index $out2

# Remove multimapping and improper reads
out3=$(echo $out1 | sed 's/\.bam$/.final.bam/')
samtools view -q 20 -F 1804 -b ${out2} > ${out3}
samtools index $out3

# histogram file
for w in 1000 500 200
do
    java -Xmx4G -jar $PICARDROOT/CollectInsertSizeMetrics.jar I=$out3 O="${out3}.window${w}.hist_data" H="${out3}.window${w}.hist_graph.pdf" W=${w}
done
