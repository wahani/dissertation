installPackages <- function(pkgs) {
  # install packages if necessary:
  pkgs <- pkgs[sapply(pkgs, Negate(require), character.only = TRUE)]
  if (length(pkgs) > 0) {
    install.packages(
      pkgs,
      dependencies = TRUE,
      Ncpus = 4,
      repos = "https://cran.rstudio.com/"
    )
  }
}

# overall package dependencies
installPackages(c(
  "saeSim", "sae", "aoos", "MASS", "dplyr", "reshape2", "ggplot2", "devtools", "tidyr", "Hmisc"
))
devtools::install_github("wahani/modules")
devtools::install_github("wahani/dat")
# devtools::install_github("wahani/saeRobust") needed but not public
