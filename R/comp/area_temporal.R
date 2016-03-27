modules::import(stats)
modules::import(saeRobust)

maxIter <- 50
maxIterParam <- 10
maxIterRe <- 1000

fh <- function(dir_name, dir_var_name, pred_name = "fh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    datFit <- dat[dat$idT == 10, ]
    fit <- saeRobust::rfh(
      formula, dir_var_name, data = datFit,
      x0Var = c(4), k = 1e6,
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    dat[dat$idT == 10, pred_name] <- fit$reblup
    dat
  }
}

sfh <- function(dir_name, dir_var_name, pred_name = "sfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    datFit <- dat[dat$idT == 10, ]
    fit <- saeRobust::rfh(
      formula, dir_var_name, data = datFit, correlation = corSAR1(testRook(nrow(datFit))),
      x0Var = c(0.5, 4), k = 1e6,
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    dat[dat$idT == 10, pred_name] <- fit$reblup
    dat
  }
}

rfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    datFit <- dat[dat$idT == 10, ]
    fit <- saeRobust::rfh(
      formula, dir_var_name, data = datFit,
      x0Var = c(4),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    dat[dat$idT == 10, pred_name] <- fit$reblup
    dat[dat$idT == 10, paste0(pred_name, "-BC")] <- predict(fit, type = "reblupbc")$reblupbc
    dat
  }
}

rsfh <- function(dir_name, dir_var_name, pred_name = "rsfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    datFit <- dat[dat$idT == 10, ]
    fit <- saeRobust::rfh(
      formula, dir_var_name, data = datFit, correlation = corSAR1(testRook(nrow(datFit))),
      x0Var = c(0.5, 4),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    dat[dat$idT == 10, pred_name] <- fit$reblup
    dat[dat$idT == 10, paste0(pred_name, "-BC")] <- predict(fit, type = "reblupbc")$reblupbc
    dat
  }
}

stfh <- function(dir_name, dir_var_name, pred_name = "sfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {

    T <- length(unique(dat$idT))
    D <- length(unique(dat$idD))

    fit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      correlation = corSAR1AR1(W = testRook(D), nTime = T),
      k = 1e6, x0Var = c(0.5, 0.5, 2, 2),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )

    dat[[pred_name]] <- fit$reblup
    dat
  }
}

tfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    T <- length(unique(dat$idT))
    fit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      correlation = corAR1(T), k = 1e6, x0Var = c(0.5, 2, 2),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    dat[[pred_name]] <- fit$reblup
    dat
  }
}

rtfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    T <- length(unique(dat$idT))
    fit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      correlation = corAR1(T), x0Var = c(0.5, 2, 2),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    dat[[pred_name]] <- fit$reblup
    dat[[paste0(pred_name, "-BC")]] <- predict(fit, type = "reblupbc")$reblupbc
    dat
  }
}

rstfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {

    T <- length(unique(dat$idT))
    D <- length(unique(dat$idD))

    fit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      correlation = corSAR1AR1(W = testRook(D), nTime = T),
      x0Var = c(0.5, 0.5, 2, 2),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )

    dat[[pred_name]] <- fit$reblup
    dat[[paste0(pred_name, "-BC")]] <- predict(fit, type = "reblupbc")$reblupbc

    dat
  }
}

