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
replicateList = list("samp1.arp.ko"=c("samp1.arp.ko.final.count", "samp2.arp.ko.final.count"),
"samp2.arp.ko"=c("samp3.arp.ko.final.count","samp4.arp.ko.final.count"),
"samp3.arp.ko"=c("samp5.arp.ko.final.count","samp6.arp.ko.final.count"),
"samp4.arp.ko"=c("samp7.arp.ko.final.count", "samp8.arp.ko.final.count", "samp13.arp.ko.final.count"),
"samp5.arp.ko"=c("samp9.arp.ko.final.count", "samp10.arp.ko.final.count"),
"samp6.arp.ko"=c("samp11.arp.ko.final.count", "samp12.arp.ko.final.count"),
"samp1.wt"=c("samp1.wt.final.count", "samp2.wt.final.count"),
"samp2.wt"=c("samp3.wt.final.count", "samp4.wt.final.count"),
"samp3.wt"=c("samp5.wt.final.count", "samp6.wt.final.count"),
"samp4.wt"=c("samp7.wt.final.count", "samp8.wt.final.count"),
"samp5.wt"=c("samp9.wt.final.count", "samp10.wt.final.count"),
"samp6.wt"=c("samp11.wt.final.count", "samp12.wt.final.count"))

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
		
