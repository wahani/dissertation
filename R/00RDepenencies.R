.libPaths("~/R/x86_64-redhat-linux-gnu-library/3.2")
installPackages <- function(pkgs) {
  # install packages if necessary:
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

update.packages(
  lib.loc = .libPaths()[1],
  repos = "http://mirrors.softliste.de/cran/",
  checkBuilt = TRUE, ask = FALSE
)

# overall package dependencies
installPackages(c(
  "sae", "aoos", "MASS", "dplyr", "reshape2", "ggplot2", "devtools", "tidyr", "Hmisc", "RcppArmadillo"
))

devtools::install_github("wahani/modules", force = TRUE)
devtools::install_github("wahani/dat", force = TRUE)
devtools::install_github("wahani/saeSim", force = TRUE)
devtools::install_github("wahani/saeRobustTools", force = TRUE)
