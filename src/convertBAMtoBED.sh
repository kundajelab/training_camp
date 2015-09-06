#!/bin/bash
p1=$1

if [ -z "$p1" ]
then
    echo "This converts BAM files to BED files"
    echo "$(basename $0) <bamFile>"
    echo "First input is the bamFile"
    exit
fi

o1=$(echo ${p1} | sed -r 's/\.bam$/.tagAlign.gz/g')

bamToBed -i ${p1} | awk 'BEGIN{OFS="\t"} $6=="+" { $2=$2+4; $3=$3 ; $4="N" ; print $0} $6=="-"{ $2=$2; $3=$3-5; $4="N" ; print $0}' | gzip -c > ${o1}
