# Title: Install R dependencies
# Author: Sebastian Warnholz
#
# Intructions:
# Use these installation instructions to set up the correct environment in R.

.libPaths("~/R/x86_64-redhat-linux-gnu-library/3.2")
installPackages <- function(pkgs) {
  # install packages only if necessary:
  pkgs <- pkgs[sapply(pkgs, Negate(require), character.only = TRUE)]
  if (length(pkgs) > 0) {
    install.packages(
      pkgs,
      dependencies = TRUE,
      Ncpus = 4,
      repos = "http://mirrors.softliste.de/cran/"
    )
  }
}

# Update first:
update.packages(
  lib.loc = .libPaths()[1],
  repos = "http://mirrors.softliste.de/cran/",
  checkBuilt = TRUE, ask = FALSE
)

# Install package dependencies from CRAN
installPackages(c(
  "sae", "saeSim", "aoos", "MASS", "dplyr", "reshape2", "ggplot2", "devtools",
  "modules", "tidyr", "Hmisc", "RcppArmadillo"
))

# To ease the installation you can use the unofficial repositories of these
# packages. Otherwise the source-package should be close by.

devtools::install_github("wahani/dat", force = TRUE)
devtools::install_github("wahani/saeRobust", force = TRUE)
