#!/usr/bin/env Rscript
# Concatenates the specified column from multiple files into a
# single matrix, and performs arcsinh transforms/quantile normalization
# if requested.
#
# Usage: normalize_data.R <input.dir> <output.file> <column> <normalize?>
#
library(preprocessCore)

args <- commandArgs(trailingOnly = TRUE)
input.dir <- args[1]
output.file <- args[2]
column <- as.integer(args[3])
normalize <- as.logical(args[4])

file.list <- list.files(input.dir, full.names=TRUE)
signal.matrix <- do.call("cbind",
                         lapply(file.list, FUN=function(file) {
                            read.table(file)[, column]
                         }))


if (normalize) {
    output.matrix <- normalize.quantiles(asinh(signal.matrix))
} else {
    output.matrix <- signal.matrix
}

peak.names <- read.table(file.list[1])[, 1]

colnames(output.matrix) <- file.list
rownames(output.matrix) <- peak.names

write.table(output.matrix, output.file)

