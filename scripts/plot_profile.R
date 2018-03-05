#!/usr/bin/env Rscript

### Libraries
require(ggplot2)

### Command line arguments
# args = commandArgs(trailingOnly=TRUE)
# if (length(args) != 1) {
#   stop('Must specific extracted profile filepath')
# }
d.fp <- 'output/profiles.tsv'

### Data
d <- read.table(d.fp, header=TRUE, sep='\t')

### Process
d$names <- sub('_200_50.txt$', '', d$software)

### Plots
png(filename='output/profile_time.png', width=1920, height=1080, res=150)
{
  ggplot(d, aes(x=names, y=time)) + geom_bar(stat='identity') + labs(title='run time', x='software')
}
dev.off()

png(filename='output/profile_memory.png', width=1920, height=1080, res=150)
{
  ggplot(d, aes(x=names, y=memory)) + geom_bar(stat='identity') + labs(title='memory comsumption', x='software')
}
dev.off()