.First <- function() {
  if (grepl("Windows", Sys.getenv("OS"))) {
    .libPaths("../../library")
    # Fix for Git under RStudio to locate SSH-Keys
    Sys.setenv(USERPROFILE=Sys.getenv("HOME"))
  } else {
      .libPaths("~/R/x86_64-pc-linux-gnu-library/3.1/")
    }

}
.First()
