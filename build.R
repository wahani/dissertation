library(knitr)
args <- commandArgs(TRUE)
input <- args[1]
output <- args[2]
figPath <- paste0("figs/", sub(".Rmd$", "", basename(input)), "/")
opts_chunk$set(fig.path = figPath)
# opts_chunk$set(fig.cap = "center")
opts_chunk$set(tidy = FALSE)
# opts_chunk$set(out.width = "\\textwidth")
opts_chunk$set(fig.width=7)
opts_chunk$set(fig.height=4)
# opts_chunk$set(fig.width = 6)
# opts_chunk$set(fig.height = 3.5)
opts_chunk$set(dpi = 600)

knit(input = args[1], output = args[2])
