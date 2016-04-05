modules::import("saeSim")
modules::import("stats", median, mad)
modules::import("MASS", huber)
modules::import("samplingbook")

sim_comp_sampleMean <- . %>%
  # sample mean and standard deviation
  sim_comp_sample(comp_var(
    sMean = mean(y),
    sMVar = var(y) / n
  ), by = "idD")

global_var <- function(dat) {
  # global variance. i.e. within domain variance
  varDat <- dplyr::group_by(dat, idD, n) %>%
    dplyr::summarise(var = var(y))
  dat$globalVar <- sum(varDat$var * (varDat$n - 1)) / (sum(varDat$n) - NROW(varDat))
  dat
}

robust_mean <- function(dat) {
  # robust mean and variance
  dat$rMean <- median(dat$y)
  dat$rMVar <- mad(dat$y)^2 / dat$n
  # dat$rMean <- huber(dat$y, k = 1.345)$mu
  # dat$rMVar <- huber(dat$y, k = 1.345)$s^2 / dat$n
  dat
}

ht <- function(probSample, var) {
  # Function to calculate the direct estimator
  force(probSample)
  force(var)
  function(dat) {
    dat <- dat[order(dat$idOrd), ]
    dat$pk <- probSample
    dat <- split(dat, dat$idD) %>%
      lapply(function(dat) {
        tmp <- htestimate(dat[[var]], N = dat$N[1], pk = dat$pk, method = "hh")
        dat[var] <- tmp$mean
        dat[paste0(var, "Se")] <- tmp$se
        dat
      }) %>%
      do.call(what = rbind)
    dat
  }
}
