modules::import(stats)
modules::import(saeRobust)

maxIter <- 200
maxIterParam <- 100
maxIterRe <- 10000

fh <- function(dir_name, dir_var_name, pred_name = "fh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat$dirVar <- dat[[dir_var_name]]
    fit <- sae::eblupFH(formula, dirVar, data = dat)
    dat[[pred_name]] <- as.numeric(fit$eblup)
    dat
  }
}

sfh <- function(dir_name, dir_var_name, pred_name = "sfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat$dirVar <- dat[[dir_var_name]]
    fit <- sae::eblupSFH(formula, dirVar, proxmat = testRook(nrow(dat)), data = dat)
    dat[[pred_name]] <- as.numeric(fit$eblup)
    dat
  }
}

rfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat[[pred_name]] <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )$reblup
    dat
  }
}

rsfh <- function(dir_name, dir_var_name, pred_name = "rsfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat[[pred_name]] <- saeRobust::rfh(
      formula, dir_var_name, data = dat, correlation = corSAR1(testRook(nrow(dat))),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )$reblup
    dat
  }
}

rfh_mse <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name)
  force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    modelFit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    prediction <- predict(modelFit, mse = c("pseudo", "boot"), B = 100)
    dat[[pred_name]] <- prediction$REBLUP
    dat[[paste0(pred_name, "PseudoMse")]] <- prediction$pseudo
    dat[[paste0(pred_name, "BootMse")]] <- prediction$boot
    dat
  }
}
