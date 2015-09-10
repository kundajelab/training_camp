#!/bin/bash
#module add python/2.7
#export PYTHONPATH="${AK_DIR}/lib/python2.7/site-packages:${PYTHONPATH}"

o1=$1
t1=$2

if [[ "$#" -lt 2 ]]
then
    echo "Calls peaks on a single sample"
    echo "USAGE: ./call_peaks.sh <organism> <tagAlign_alignment_file>"
    echo "<organism>: yeast"
    echo "<tagAlign_alignment_file>: Full path to tagAlign.gz file containing aligned reads"
    exit
fi

if [[ ! -e $t1 ]]
then
    echo "tagAlign File $t1 does not exist. Please check your path" >&2
    exit
fi

if [[ $o1 == "yeast" ]]
then
    gsize=12157105
    gfile="${AK_TOOL_DIR}/Saccharomyces_cerevisiae/UCSC/sacCer3/yeast_genome.size"
    ssize=50
    ssizetimes2=100
fi

p1=$(echo ${t1} | sed -r 's/\.tagAlign.gz$//g')

#Make temporary directory
TEMP_DIR="${DATA_DIR}/tmp"
[[ ! -d ${TEMP_DIR} ]] && mkdir ${TEMP_DIR}
TEMP_FILE="${TEMP_DIR}/${RANDOM}$(basename ${t1})"

#Adjust read coordinates. Shift + strand reads by -${ssize} and - strand reads by +{ssize}
slopBed -l ${ssize} -r -${ssize} -s -g ${gfile} -i ${t1} | gzip -c > ${TEMP_FILE}

# Call peaks and create signal track
macs2 callpeak -t ${TEMP_FILE} -f BED -n ${p1} -g ${gsize} -p 1e-2 --nomodel --shift=0 --extsize=${ssizetimes2} -B --SPMR
#rm -f ${p1}_peaks.xls ${p1}_peaks.bed ${p1}_summits.bed

# Compute fold-change track
macs2 bdgcmp -t ${p1}_treat_pileup.bdg -c ${p1}_control_lambda.bdg -o ${p1}_FE.bdg -m FE
slopBed -i ${p1}_FE.bdg -g ${gfile} -b 0 | /srv/scratch/trainingCamp/2015/tools/bedClip stdin ${gfile} ${p1}.FE.bedGraph
#rm ${p1}_FE.bdg ${p1}_treat_pileup.bdg ${p1}_control_lambda.bdg

# Create bigwig file
bedGraphToBigWig ${p1}.FE.bedGraph ${gfile} ${p1}.FE.bigWig
gzip ${p1}.FE.bedGraph
sort -k8nr,8nr ${p1}_peaks.narrowPeak | gzip -c > ${p1}.peaks.bed.gz
#rm ${p1}_peaks.encodePeak
zcat ${p1}.peaks.bed.gz | awk 'BEGIN{OFS="\t"}{print $1,$2,$3,$8}' > ${p1}.4col.peaks.bed
