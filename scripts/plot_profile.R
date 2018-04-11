#!/usr/bin/env Rscript

### Libraries
require(ggplot2)

### Command line arguments
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop('Must specific extracted profile filepath')
}
d.fp <- args[[1]]

### Data
d <- read.table(d.fp, header=TRUE, sep='\t')

### Process
d$time <- d$time / (60**2)
d$memory <- d$memory / (1024**2)

d$names <- c('FastSpar', 'FastSpar (threaded)', 'Mothur SparCC', 'SparCC', 'SpiecEasi SparCC')

### Plots
svg(filename='output/profile_time.svg', height=4, width=8)
{
  ggplot(d, aes(x=names, y=time)) + geom_bar(stat='identity') + labs(title='run time', x='Software', y='Time (hours)')
}
dev.off()

svg(filename='output/profile_memory.svg', height=4, width=8)
{
  ggplot(d, aes(x=names, y=memory)) + geom_bar(stat='identity') + labs(title='memory comsumption (GB)', x='Software', y='Memory (GB)')
}
dev.off()
