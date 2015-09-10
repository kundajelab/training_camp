#!/usr/bin/env Rscript

#need to set the variable inpFile to the file with cols to run PCA on; cols are the samples
inpData <- read.table(inpFile, header=TRUE, row.names=1)

#transpose so that we do pca for the columns
row_sub = apply(inpData, 1, function(row) any(row != row[1] ))
components <- prcomp(t(inpData[row_sub,]),scale=TRUE)

#visualise the sdevs associated with the PCs
dev.new()
barplot(components$sdev,xlab="PCs")

numComponentsToFocusOn = 3
for (i in seq(1,numComponentsToFocusOn-1)) {
    component_i = components$x[,i]
    for (j in seq(i+1,numComponentsToFocusOn)) {
        component_j = components$x[,j]
        plot(component_i,component_j,xlab=paste("Component",i,sep=""), ylab=paste("Component",j,sep=""),col="blue")
        text(component_i,component_j,names(inpData),cex=1.0)
        dev.new()
    }
}


