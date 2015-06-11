.First <- function() {
  if (grepl("Windows", Sys.getenv("OS"))) {
    .libPaths("../../library")
    # Fix for Git under RStudio to locate SSH-Keys
    Sys.setenv(USERPROFILE = Sys.getenv("HOME"))
  }

  source("R/deps.R")
  source("R/fungg.R")

}
.First()
