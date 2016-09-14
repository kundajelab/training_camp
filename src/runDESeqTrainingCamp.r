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


replicateList = list("Ct"=c("Ct_1_S22","Ct_2_S23","Ct_3_S24","Ct_300_S3","Ct_800_S9"),
"Cz"=c("Cz_1_S16","Cz_2_S17","Cz_3_S18","Cz_300_S1","Cz_800_S7"),
"DMSO"=c("DMSO_1_S31","DMSO_1_S6","DMSO_2_S12","DMSO_2_S32"),
"It"=c("It_1_S25","It_2_S26","It_3_S27","It_300_S5","It_800_S11"),
"Kt"=c("Kt_1_S13","Kt_2_S14","Kt_3_S15"),
"Kz"=c("Kz_300_S4","Kz_800_S10"),
"Mz"=c("Mz_1_S19","Mz_2_S20","Mz_3_S21","Mz_300_S2","Mz_800_S8"),
"U"=c("U_1_S28","U_2_S29","U_3_S30"))

DNaseSignalTableSize <- dim(DNaseSignalTable)
#numTimePoints <- DNaseSignalTableSize[2]/3
#cdsColumnNames <- c("Condition1", "Condition1", "Condition2", "Condition2")

for (i in 1:(length(replicateList)-1)) {
	replicateSet1Name = names(replicateList)[i]
    cdsColumnNamesRep1 <- c()
    for (replicateName in replicateList[[replicateSet1Name]]) {
        cdsColumnNamesRep1 <- c(cdsColumnNamesRep1, replicateSet1Name)
    }
    # Iterate through the time-points and run DESeq on each with each other time-point
	#firstCol <- (3*i) - 1
	#firstExperimentString <- paste(experimentNames[firstCol], sep="")
    for (j in (i+1):(length(replicateList))) {
        replicateSet2Name = names(replicateList)[j]
        cdsColumnNamesRep2 <- c()
        for (replicateName in replicateList[[replicateSet2Name]]) {
            cdsColumnNamesRep2 <- c(cdsColumnNamesRep2, replicateSet2Name)
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
		res = nbinomTest(cds, replicateSet1Name, replicateSet2Name)
		resSig = res[res$padj < 0.05, ]
		
		# Output results
		outputFileNameSuffix <- paste(replicateSet1Name, "Vs", replicateSet2Name, sep="_")
		currentOutputFileName <- paste(outputFileNamePrefix, outputFileNameSuffix, sep="_")
		currentOutputFileNameSigPeakNames <- paste(currentOutputFileName, "sigPeakNames", sep="_")
		write.table(res, file=currentOutputFileName)
		write.table(resSig[,1], file=currentOutputFileNameSigPeakNames, row.names=FALSE, col.names=FALSE, quote=FALSE)
	}
}
		
