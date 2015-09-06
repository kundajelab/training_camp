rm ${DATA_DIR}/tagAlign/PooledReps*

while read line     
do      
    #skip lines starting with #    
    if [[ $line == [#]* ]];then    
       echo "skipping line $line because it starts with #"     
    else    
    read -a items <<< "$line"
    barcode=${items[0]}
    sample=${items[1]}
    wtORmut=${items[2]}
    zcat -f ${DATA_DIR}/tagAlign/${barcode}-${wtORmut}.final.tagAlign.gz >> ${DATA_DIR}/tagAlign/PooledReps_Sample${sample}_${wtORmut}.tagAlign
    fi
done < ${AK_DATA_DIR}/metadata

for f in $(ls ${DATA_DIR}/tagAlign/PooledReps*);do echo $f;gzip $f;done
