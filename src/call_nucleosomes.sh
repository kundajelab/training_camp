#!/bin/bash
ref=$1 # first input is the reference 
region=$2 # second input is the region 
bam=$3  # third input is aligned data

export PYTHONPATH=/tc2015/nasa/src/NucleoATAC/build/lib.linux-x86_64-2.7/:$PYTHONPATH

/tc2015/nasa/src/NucleoATAC/bin/nucleoatac run --bed $region --bam $bam --out `basename $bam .final.bam` --fasta $ref --write_all
