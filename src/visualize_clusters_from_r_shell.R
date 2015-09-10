### Script to Visualize Clusters, to be called from within the R shell

# Load libraries
library(gplots)

#need to set the variable input_file beforehand
data = read.table(input_file)

# Cluster Rows
d =  dist(data, method='euclidean')
row_hclust = hclust(d, method='ward')
row_sort_ind = row_hclust$order

# Cluster Columns
#d =  dist(t(data), method='euclidean')
#col_hclust = hclust(d, method='average')
#col_sort_ind = col_hclust$order
col_sort_ind = seq(1, ncol(data))

# Plot
row_sort_data = data[row_sort_ind,]
rowcol_sort_data = row_sort_data[,col_sort_ind]

heatmap.2(as.matrix(rowcol_sort_data), rowsep=0, colsep=0, sepwidth=c(0,0), dendrogram='none', trace='none', Rowv=FALSE, Colv=FALSE, xlab='Time Points', ylab='Peaks', margins=c(12,8))
title('Hierarchically Clustered Peaks and Time Points')

# Say finished
print(sprintf('Done'))

