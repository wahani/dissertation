modules::import("utils", "read.table")
modules::import("saeRobust")
modules::import("stats", "as.formula", "lm", "predict", "runif")

sample <- function(idOrd, fileName) {
  # Function to retrieve the next sampling set. The functions remebers how often
  # it has been called.
  force(idOrd)
  force(fileName)
  sampleMatrix <- read.table(fileName, header = TRUE, sep = " ")
  function(dat) {
    # This figures out in which iteration we are. This is important to parallelise
    # the computation. Otherwise it is not possible to handle the state.
    Sys.sleep(runif(1, max = 2))
    currectCount <- list.files("R/data/CBS/", pattern = "^counter_", full.names = TRUE)
    currentI <- as.numeric(sub(".*counter_", "", currectCount))
    if (identical(currentI, numeric())) i <- 1
    else if (currentI == 500) i <- 1
    else i <- currentI + 1
    stopifnot(file.create(paste0("R/data/CBS/counter_", i)))
    file.remove(currectCount)
    dat$sId <- i
    dat[sapply(sampleMatrix[, i], function(pos) which(idOrd == pos)), ]
  }
}

fh <- function(dat) {
  # calc function for area-level models
  # (0) Loading libraries
  # (1) Defining variables
  # (2) Prepare data
  # (3) Linear model
  # (4) FHI - known sd
  # (5) FHII -

  # (1) Defining variables
  auxVars <- c("turn_1")
  auxVarForm <- paste(auxVars, sep = "", collapse = " + ")
  form <- as.formula(paste("y ~ ", auxVarForm, sep = ""))
  dat$samplingVar <- dat$ySe^2

  # (4) FHI
  modelFitFH <- rfh(form, samplingVar = "samplingVar", data = dat, k = 1e6)
  dat["FH"] <- modelFitFH$reblup
  dat[c("FH.CCT", "FH.BOOT")] <- mse(modelFitFH, type = c("pseudo", "boot"), predType = "reblup")[c("pseudo", "boot")]

  # () RFHI
  modelFitFH <- rfh(form, samplingVar = "samplingVar", data = dat)
  dat["RFH"] <- modelFitFH$reblup
  dat["RFH.BC"] <- predict(modelFitFH, type = "reblupbc")["reblupbc"]
  mse(modelFitFH, type = c("pseudo", "boot"), predType = c("reblup", "reblupbc"))
  dat[c("RFH.CCT", "RFH.BC.CCT", "RFH.BOOT", "RFH.BC.BOOT")] <-
    mse(
      modelFitFH,
      type = c("pseudo", "boot"),
      predType = c("reblup", "reblupbc")
    )[c("pseudo", "pseudobc", "boot", "bootbc")]

  dat

}
