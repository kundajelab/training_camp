library(DESeq2)


#thresholds 
padjust_thresh=0.05
lfc_thresh=1 

# Get command line arguments
args <- commandArgs(trailingOnly = TRUE)
inputFileName <- args[1]
batchesFileName <-args[2]
outputFileNamePrefix <- args[3]
#inputFileName="/srv/scratch/training_camp/data/tc2017/counts.filtered.tab"
#batchesFileName="/srv/scratch/training_camp/data/tc2017/batches.deseq2.txt"
#outputFileNamePrefix="."


#full time series data 
data=read.table(inputFileName,header=TRUE,sep='\t')
peaks=data$Chrom_Start_End
data$Chrom_Start_End=NULL
rownames(data)=peaks
data=as.matrix(data)

#get the design matrix 
batches=read.table(batchesFileName,header=TRUE,sep='\t')
batches$Salt=factor(batches$Salt)
mod=model.matrix(~0+Strain+Media+Salt,data=batches)
######################################################################################################################################################
#run DESEQ2 
ddsMat=DESeqDataSetFromMatrix(countData=data,
                              colData=batches,
                              design=~0+Strain+Media+Salt)
dds<-DESeq(ddsMat,parallel=TRUE,betaPrior=FALSE)
deseq_contrasts=list(c("Media","SCD","SCE"),
                     c("Salt","1","0"),
                     c("Strain","WT","cln3"),
                     c("Strain","WT","whi5"),
                     c("Strain","WT","whi5cln3"))
contrast_names=c("Media_SCD_vs_SCE",
	"Salt_1_vs_0",
	"Strain_WT_vs_cln3",
	"Strain_WT_vs_whi5",
	"Strain_WT_vs_whi5cln3")

for(contrast_index in seq(1,5))
{
	comparison_name=unlist(contrast_names[contrast_index])
	ds=results(dds,
	   contrast=unlist(deseq_contrasts[contrast_index]),
           parallel = TRUE)
	write.table(ds,file=paste(outputFileNamePrefix,"/",comparison_name,".txt",sep=""),quote=FALSE,row.names=TRUE,col.names=TRUE,sep='\t') 
	ds=na.omit(ds)
	sig=ds[ds$padj<padjust_thresh,]
	write.table(sig,file=paste(outputFileNamePrefix,"/",comparison_name,".txt.sigPeakNames",sep=""),quote=FALSE,row.names=TRUE,col.names=TRUE,sep='\t')
	   
}

