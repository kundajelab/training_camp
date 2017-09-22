#!/usr/bin/env Rscript
library('Cairo')
args <- commandArgs(trailingOnly = TRUE)
inpFile <- args[1] #file with cols to run PCA on; cols are the samples
batchesFile <- args[2]
var <-args[3]
data <- read.table(inpFile, header=TRUE, sep='\t')
batches=read.table(batchesFile,header=TRUE,sep='\t')
data.pca=prcomp(t(data),center=FALSE,scale=TRUE)
CairoPNG("PCA_scree_plot.png")
barplot(100*data.pca$sdev^2/sum(data.pca$sdev^2),las=2,xlab="",ylab="% Variance Explained")
dev.off() 

groups=factor(rownames(data.pca$x))

#PC1 vs PC2

numComponentsToFocusOn = 3
for (i in seq(1,numComponentsToFocusOn)) {
    component_i = data.pca$x[,i]
    write.table(data.pca$rotation[,i],paste("pc",i,"_rotation.txt",sep=""),quote=FALSE,col.names=FALSE,row.names=TRUE)
    for (j in seq(i+1,numComponentsToFocusOn)) {
        component_j = data.pca$x[,j]
	CairoPNG(paste(paste("PC",i,"vs",j,sep="_"),".png", sep=""))
        plot(component_i,component_j,xlab=paste("Component",i,sep=""), ylab=paste("Component",j,sep=""),col=batches[,var])
        text(component_i,component_j,names(data),pos=3,cex=0.5)
        dev.off()
    }
}


