#!/usr/bin/env bash
source /etc/profile.d/modules.sh
module load ucsc_tools/2.7.2


MERGEDPEAKS="${PEAKS_DIR}/all_merged.peaks.bed.gz"

OUTPUTDIR=$SIGNAL_DIR
COUNTSIGNALDIR=$COUNTS_DIR
FCSIGNALDIR=$FOLDCHANGE_DIR

COUNTSIGNALDIR_PROCESSED=$COUNTSIGNALDIR/processed 
FCSIGNALDIR_PROCESSED=$FCSIGNALDIR/processed

COUNTCOL=4
FCCOL=6

[[ ! -d $OUTPUTDIR ]] && mkdir $OUTPUTDIR
[[ ! -d $COUNTSIGNALDIR ]] && mkdir $COUNTSIGNALDIR
[[ ! -d $FCSIGNALDIR ]] && mkdir $FCSIGNALDIR
[[ ! -d $COUNTSIGNALDIR_PROCESSED ]] && mkdir $COUNTSIGNALDIR_PROCESSED
[[ ! -d $FCSIGNALDIR_PROCESSED ]] && mkdir $FCSIGNALDIR_PROCESSED

# Extract Signal
for countfile in ${COUNTSIGNALDIR}/*.bigWig
do
    filename=$(basename ${countfile})
    outputfile="${filename%.*}"
    $SRC_DIR/bigWigAverageOverBed ${countfile} ${MERGEDPEAKS} ${COUNTSIGNALDIR_PROCESSED}/${outputfile}
done

for fcfile in ${FCSIGNALDIR}/*.bigWig
do
    filename=$(basename ${fcfile})
    outputfile="${filename%.*}"
    $SRC_DIR/bigWigAverageOverBed ${fcfile} ${MERGEDPEAKS} ${FCSIGNALDIR_PROCESSED}/${outputfile}
done

echo "extracted signal" 
# Combine data and normalize if necessary

# Do not normalize counts; DE-seq will do it
$SRC_DIR/normalize_data.R ${COUNTSIGNALDIR_PROCESSED} ${OUTPUTDIR}/counts.tab ${COUNTCOL} FALSE
# Normalize fold changes
$SRC_DIR/normalize_data.R ${FCSIGNALDIR_PROCESSED} ${OUTPUTDIR}/foldChange.tab ${FCCOL} TRUE

echo "combined the data" 

# Visualize clusters
MASTERDATADIR=/srv/scratch/training_camp/data/tc2017
$SRC_DIR/visualize_clusters.R ${MASTERDATADIR}/counts.small.tab ${OUTPUTDIR}/counts_cluster.png "counts"
$SRC_DIR/visualize_clusters.R ${MASTERDATADIR}/foldChange.small.tab ${OUTPUTDIR}/foldChange_cluster.png "fold change"

