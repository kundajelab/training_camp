#!/bin/bash
t1=$1

if [[ "$#" -lt 1 ]]
then
    echo "Create a genome-wide count coverage track from an alignment file"
    echo "USAGE: ./$(basename $0) <tagAlign_alignment_file>"
    echo "<tagAlign_alignment_file>: Full path to tagAlign.gz file containing aligned reads"
    exit
fi

if [[ ! -e $t1 ]]
then
    echo "tagAlign File $t1 does not exist. Please check your path" >&2
    exit
fi

p1=$(echo ${t1} | sed -r 's/\.tagAlign.gz$//g')

# Call peaks and create signal track
gfile=${SRC_DIR}/yeast_genome.size

zcat ${t1} | sort -k1,1 | genomeCoverageBed -bg -5 -i stdin -g ${gfile} > "${p1}.count.bedgraph"
chmod 755 "${p1}.count.bedgraph"

# Create bigwig file
bedGraphToBigWig "${p1}.count.bedgraph" ${gfile} "${p1}.count.bigWig"
gzip "${p1}.count.bedgraph"
