modules::import("saeSim")
modules::import(stats, median)
modules::import(MASS, huber)

sim_comp_sampleMean <- . %>%
  # sample mean and standard deviation
  sim_comp_sample(comp_var(
    sMean = mean(y),
    sMVar = var(y) / n
  ), by = "idD")

comp_globalVar <- function(dat) {
  # global variance. i.e. within domain variance
  varDat <- dplyr::group_by(dat, idD, n) %>%
    dplyr::summarise(var = var(y))
  dat$globalVar <- sum(varDat$var * (varDat$n - 1)) / (sum(varDat$n) - NROW(varDat))
  dat
}

comp_robustMean <- function(dat) {
  # robust mean and variance
  dat$mMean <- median(dat$y)
  dat$rMean <- huber(dat$y, k = 1.345)$mu
  dat$rMVar <- huber(dat$y, k = 1.345)$s^2 / dat$n
  dat
}
