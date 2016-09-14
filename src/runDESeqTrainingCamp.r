# This script takes a table of merged peaks x experiments where each entry i,j is the signal in merged peak i in experiment j.
# It assumes that each experiment has two replicates and that replicates are listed consecutively (repl. 1 odd cols., rep. 2 in even cols.).
# It runs DESeq on all pairs of time-points and records the output of each run of DESeq in a separate file.
# Usage: runDESeqTrainingCamp.r <inputFileName> <outputFileNamePrefix>
# inputFileName and outputFileName should contain the entire paths.

# Load DESeq
#source("http://bioconductor.org/biocLite.R")
#biocLite("locfit")
#biocLite("DESeq")
library("locfit")
library( "DESeq")

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
inputFileName <- args[1]
outputFileNamePrefix <- args[2]

# Put data into table for DESeq
DNaseSignalTable <- read.table(inputFileName,header=TRUE)
experimentNames <- colnames(DNaseSignalTable)


replicateList = list("Ct"=c("sampCt_1_S22","sampCt_2_S23","sampCt_3_S24","sampCt_300_S3","sampCt_800_S9"),
"Cz"=c("sampCz_1_S16","sampCz_2_S17","sampCz_3_S18","sampCz_300_S1","sampCz_800_S7"),
"DMSO"=c("sampDMSO_1_S31","sampDMSO_1_S6","sampDMSO_2_S12","sampDMSO_2_S32"),
"It"=c("sampIt_1_S25","sampIt_2_S26","sampIt_3_S27","sampIt_300_S5","sampIt_800_S11"),
"Kt"=c("sampKt_1_S13","sampKt_2_S14","sampKt_3_S15"),
"Kz"=c("sampKz_300_S4","sampKz_800_S10"),
"Mz"=c("sampMz_1_S19","sampMz_2_S20","sampMz_3_S21","sampMz_300_S2","sampMz_800_S8"),
"U"=c("sampU_1_S28","sampU_2_S29","sampU_3_S30"))

DNaseSignalTableSize <- dim(DNaseSignalTable)
#numTimePoints <- DNaseSignalTableSize[2]/3
#cdsColumnNames <- c("Time Point 1", "Time Point 1", "Time Point 2", "Time Point 2")

for (i in 1:(length(replicateList)-1)) {
	replicateSet1Name = names(replicateList)[i]
    cdsColumnNamesRep1 <- c()
    for (replicateName in replicateList[[replicateSet1Name]]) {
        cdsColumnNamesRep1 <- c(cdsColumnNamesRep1, "Time Point 1")
    }
    # Iterate through the time-points and run DESeq on each with each other time-point
	#firstCol <- (3*i) - 1
	#firstExperimentString <- paste(experimentNames[firstCol], sep="")
    for (j in (i+1):(length(replicateList))) {
        replicateSet2Name = names(replicateList)[j]
        cdsColumnNamesRep2 <- c()
        for (replicateName in replicateList[[replicateSet2Name]]) {
            cdsColumnNamesRep2 <- c(cdsColumnNamesRep2, "Time Point 2")
        }
        cdsColumnNames <- c(cdsColumnNamesRep1, cdsColumnNamesRep2)
		print(cdsColumnNames)
        # Iterate through the second time-points for each time-point pair
		#currentExperimentCols <- c(firstCol, firstCol + 1, secondCol, secondCol + 1)
		currentDNaseSignalTable <- DNaseSignalTable[,c(replicateList[[replicateSet1Name]], replicateList[[replicateSet2Name]])]
	    print(names(currentDNaseSignalTable))
	
		# Run DESeq
		cds = newCountDataSet(currentDNaseSignalTable, cdsColumnNames)
		cds = estimateSizeFactors(cds)
		cds = estimateDispersions(cds)
		res = nbinomTest(cds, "Time Point 1", "Time Point 2")
		resSig = res[res$padj < 0.05, ]
		
		# Output results
		outputFileNameSuffix <- paste(replicateSet1Name, "Vs", replicateSet2Name, sep="_")
		currentOutputFileName <- paste(outputFileNamePrefix, outputFileNameSuffix, sep="_")
		currentOutputFileNameSigPeakNames <- paste(currentOutputFileName, "sigPeakNames", sep="_")
		write.table(res, file=currentOutputFileName)
		write.table(resSig[,1], file=currentOutputFileNameSigPeakNames, row.names=FALSE, col.names=FALSE, quote=FALSE)
	}
}
		
