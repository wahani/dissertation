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

update.packages(repos = "http://mirrors.softliste.de/cran/", checkBuilt = TRUE, ask = FALSE)

# overall package dependencies
installPackages(c(
  "saeSim", "sae", "aoos", "MASS", "dplyr", "reshape2", "ggplot2", "devtools", "tidyr", "Hmisc", "RcppArmadillo"
))

devtools::install_github("wahani/dat", force = TRUE)

if (file.exists("saeRobust.tar.gz")) install.packages("saeRobust.tar.gz", repos = NULL, type = "source")

# devtools::install_github("wahani/saeRobust") needed but not public
