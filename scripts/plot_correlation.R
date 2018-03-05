#!/usr/bin/env Rscript

### Libraries
require(scales)

### Command line arguments
args = commandArgs(trailingOnly=TRUE)
if (length(args) < 1) {
  stop('Must specify at least one input profile')
}

### Data
d <- lapply(args, read.table, row.names=1, comment.char='', header=TRUE, sep='\t', check.names=FALSE)

### Process
names(d) <- sub('^.+/(.+)_cor\\.tsv', '\\1', args)
d.melt <- lapply(names(d), function(n) { d <- data.frame(correlation=unlist(d[[n]])); colnames(d) <- n; d })
d.combined <- do.call('cbind', d.melt)

### Plots
png(filename='output/correlation_plot.png', width=1920, height=1080, res=150)
{
  pairs(d.combined, col=scales::alpha(1, 0.2))
}
dev.off()