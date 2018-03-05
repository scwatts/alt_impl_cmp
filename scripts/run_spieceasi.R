#!/usr/bin/env Rscript


### Arguments
args = commandArgs(trailingOnly=TRUE)
if(length(args) != 4) {
    stop('Iterations, exclusion iterations, and filepaths required\n./run_spieceasi.R <it> <xit> <infp> <outfp>')
}
iterations <- args[[1]]
xiterations <- args[[2]]
input_fp <- args[[3]]
output_fp <- args[[4]]


### Library
library(SpiecEasi)


### Processing
d <- read.table(input_fp, comment.char='', sep='\t', header=TRUE, check.names=FALSE, row.names=1)
r <- sparcc(t(d), iter=iterations, inner_iter=xiterations)
rownames(r$Cor) <- colnames(r$Cor) <- rownames(d)
write.table(r$Cor, output_fp, quote=FALSE, row.names=TRUE, sep='\t')
