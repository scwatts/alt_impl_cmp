#!/usr/bin/env Rscript

### Libraries
require(ggplot2)
require(GGally)

### Command line arguments
args <- commandArgs(trailingOnly=TRUE)
if (length(args) < 1) {
  stop('Must specify at least one correlation filepath')
}


### Data
d <- lapply(args, read.table, row.names=1, comment.char='', header=TRUE, sep='\t', check.names=FALSE)

### Process
# Upper triangle only (no diagonal)
names(d) <- c('FastSpar', 'Mothur SparCC', 'SparCC', 'SpiecEasi SparCC')
d.melt <- lapply(names(d), function(n) { d <- data.frame(correlation=unlist(d[[n]][upper.tri(d[[n]])])); colnames(d) <- n; d })
d.combined <- do.call('cbind', d.melt)

# Reorder data frame
d.combined <- d.combined[ ,c('FastSpar', 'SparCC', 'SpiecEasi SparCC', 'Mothur SparCC')]

### Plots
pair_scatter_fn <- function(data, mapping, ...) {
  ggplot(data=data, mapping=mapping) + geom_point(..., alpha=0.1) + ylim(NA, 0.4) + xlim(NA, 0.4)
}

svg(filename='output/correlation_plot.svg', height=8, width=8)
{
  ggpairs(d.combined, lower=list(continuous=pair_scatter_fn, combo=ggally_dot_no_facet))
}
dev.off()
