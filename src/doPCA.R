#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
inpFile <- args[1] #file with cols to run PCA on; cols are the samples
inpData <- read.table(inpFile, header=TRUE, row.names=1)

#transpose so that we do pca for the columns
row_sub = apply(inpData, 1, function(row) any(row != row[1] ))
components <- prcomp(t(inpData[row_sub,]),scale=TRUE)

#visualise the sdevs associated with the PCs
#png("PCA_sdev.png")
barplot(components$sdev,xlab="PCs")
dev.off()

numComponentsToFocusOn = 3
for (i in seq(1,numComponentsToFocusOn)) {
    component_i = components$x[,i]
    write.table(components$rotation[,i],paste("pc",i,"_rotation.txt",sep=""),quote=FALSE,col.names=FALSE,row.names=TRUE)
    for (j in seq(i+1,numComponentsToFocusOn)) {
        component_j = components$x[,j]
#        png(paste(paste("PC",i,"vs",j,sep="_"),".png", sep=""))
        plot(component_i,component_j,xlab=paste("Component",i,sep=""), ylab=paste("Component",j,sep=""),col="blue")
        text(component_i,component_j,names(inpData),cex=1.0)
        dev.off()
    }
}


