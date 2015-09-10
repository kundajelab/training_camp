#!/usr/bin/env bash
module load ucsc_tools/2.7.2

MERGEDPEAKS="${AK_DATA_DIR}/results/peaks/all_merged.peaks.bed.gz"
COUNTDIR="${AK_DATA_DIR}/countTracks"
FCDIR="${AK_DATA_DIR}/results/foldChangeTracks"

OUTPUTDIR="${WORK_DIR}/results/signal"
COUNTSIGNALDIR="${OUTPUTDIR}/counts"
FCSIGNALDIR="${OUTPUTDIR}/foldChange"

COUNTCOL=4
FCCOL=6

[[ ! -d $OUTPUTDIR ]] && mkdir $OUTPUTDIR
[[ ! -d $COUNTSIGNALDIR ]] && mkdir $COUNTSIGNALDIR
[[ ! -d $FCSIGNALDIR ]] && mkdir $FCSIGNALDIR

# Extract Signal
for countfile in ${COUNTDIR}/*.bigWig
do
    filename=$(basename ${countfile})
    outputfile="${filename%.*}"
    $SRC_DIR/bigWigAverageOverBed ${countfile} ${MERGEDPEAKS} ${COUNTSIGNALDIR}/${outputfile}
done

for fcfile in ${FCDIR}/*.bigWig
do
    filename=$(basename ${fcfile})
    outputfile="${filename%.*}"
    $SRC_DIR/bigWigAverageOverBed ${fcfile} ${MERGEDPEAKS} ${FCSIGNALDIR}/${outputfile}
done


# Combine data and normalize if necessary

# Do not normalize counts; DE-seq will do it
$SRC_DIR/normalize_data.R ${COUNTSIGNALDIR} ${OUTPUTDIR}/counts.tab ${COUNTCOL} FALSE
# Normalize fold changes
$SRC_DIR/normalize_data.R ${FCSIGNALDIR} ${OUTPUTDIR}/foldChange.tab ${FCCOL} TRUE


# Visualize clusters
$SRC_DIR/visualize_clusters.R ${OUTPUTDIR}/counts.tab ${OUTPUTDIR}/counts_cluster.png
$SRC_DIR/visualize_clusters.R ${OUTPUTDIR}/foldChange.tab ${OUTPUTDIR}/foldChange_cluster.png

