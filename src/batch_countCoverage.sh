#!/bin/bash
for i in $(find ${TAGALIGN_DIR} -name '*.tagAlign.gz')
do
     $SRC_DIR/create_countCoverageTracks.sh $i
done
