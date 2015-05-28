installAndLoad <- function(package) {
  if(!eval(substitute(suppressPackageStartupMessages(require(package))))) {
    install.packages(package, quiet = TRUE)
    eval(substitute(suppressPackageStartupMessages(library(package))))
  }
}

installAndLoad("ggplot2")

