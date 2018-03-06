#!/usr/bin/env Rscript

### Libraries
require(ggplot2)

### Command line arguments
args = commandArgs(trailingOnly=TRUE)
if (length(args) != 1) {
  stop('Must specific extracted profile filepath')
}
d.fp <- args[[1]]

### Data
d <- read.table(d.fp, header=TRUE, sep='\t')

### Process
d$names <- sub('_500_1000.txt$', '', d$software)
d$time <- d$time / (60**2)
d$memory <- d$memory / (1024**2)

### Plots
png(filename='output/profile_time.png', width=1920, height=1080, res=150)
{
  ggplot(d, aes(x=names, y=time)) + geom_bar(stat='identity') + labs(title='run time', x='software')
}
dev.off()

png(filename='output/profile_memory.png', width=1920, height=1080, res=150)
{
  ggplot(d, aes(x=names, y=memory)) + geom_bar(stat='identity') + labs(title='memory comsumption (GB)', x='software')
}
dev.off()
