#!/bin/bash
# read from command line which files to align
ref=$1 # first input is the reference 
p1=$2  # second input is read 1
p2=$3  # third input is read 2

# help
if [ -z "$p1" ]
then
    echo "This script will use Bowtie 2 to align two paired-end fastq files"
    echo "$(basename $0) <bowtie2IndexDir> <readFile1> <readFile2>"
    echo "First input is the location of the Bowtie2 index directory for yeast"
    echo "Second input is location of file containing read 1"
    echo "Third input is location of file containing read 2"
    exit
fi

# if no p2 then make it up
if [ -z "$p2" ]
then
    p2=`echo $p1 | sed 's/R1/R2/g'`
fi

# get file type
echo "aligning" $p1
type=$(echo $p1 | sed -r 's/.*\.//g')

python ${SRC_DIR}/pyadapter_trim.py -a $p1 -b $p2

# check if zipped
if [ $type == 'gz' ];
then
    # process zipped file
    out1=$(echo $p1 | sed 's/\.fastq\.gz/.sam.gz/g' | sed 's/_R1//g')
    bowtie2 -X2000 -p4 $ref -1 <(gunzip -c $p1) -2 <(gunzip -c $p2) | gzip -c > $out1

elif [ $type == 'fastq' ];
then
    # process unzipped file
    out1=$(echo $p1 | sed 's/\.fastq/.sam.gz/g' | sed 's/_R1//g')
    p1trim=$(echo $p1 | sed 's/fastq.gz/trim.fastq/g')
    p2trim=$(echo $p2 |sed 's/fastq.gz/trim.fastq/g')
    bowtie2 -X2000 -p4 $ref -1 $p1trim -2 $p2trim | gzip -c > $out1

elif [ $type == 'fq' ];
1;2cthen
    # process unzipped file
    out1=$(echo $p1 | sed 's/\.fq/.sam.gz/g' | sed 's/_R1//g')
    bowtie2 -X2000 -p4 $ref -1 $p1 -2 $p2 | gzip -c > $out1
else
    echo "Unrecognized file type, accepts .fastq or .fq or .gz"
fi

echo "Done===="
# misc code, trims one side of the read to 39 bps
#awk '{if(NR % 2)print;else print substr($0,0,39)}' $p2 > trimmed.p2.fastq

