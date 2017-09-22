#!/usr/bin/env Rscript
### Script to Visualize Clusters
### Peyton Greenside
### 9/11/14

### Usage
# visualize_clusters.R <input.table> <output.png>

# Load libraries
library('Cairo') 
library(gplots)

### Needed arguments: data file, output filename
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file <- args[2]

data = read.table(input_file,header=TRUE,sep='\t')


# Cluster Rows
d =  dist(data, method='euclidean')
row_hclust = hclust(d, method='ward')
row_sort_ind = row_hclust$order

# Cluster Columns
d =  dist(t(data), method='euclidean')
col_hclust = hclust(d, method='average')
col_sort_ind = col_hclust$order


# Plot
plot_name = output_file
row_sort_data = data[row_sort_ind,]
rowcol_sort_data = row_sort_data[,col_sort_ind]


CairoPNG(plot_name,width=8,height=10,units="in",res=300)
heatmap.2(as.matrix(rowcol_sort_data), rowsep=0, colsep=0, sepwidth=c(0,0), dendrogram='none', trace='none', Rowv=TRUE, Colv=TRUE, xlab='Samples', ylab='Peaks', margins=c(12,8),labCol=c(""))
title('Hierarchically Clustered Peaks and Time Points')
dev.off()

# Say finished
print(sprintf('Done. Plot is called %s', plot_name))

