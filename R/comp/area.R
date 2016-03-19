modules::import(stats)
modules::import(saeRobust)

maxIter <- 200
maxIterParam <- 10
maxIterRe <- 1000

fh <- function(dir_name, dir_var_name, pred_name = "fh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat$dirVar <- dat[[dir_var_name]]
    fit <- try({
      sae::eblupFH(formula, dirVar, data = dat)
    })
    dat[[pred_name]] <- if (inherits(fit, "try-error")) NA else as.numeric(fit$eblup)
    dat
  }
}

sfh <- function(dir_name, dir_var_name, pred_name = "sfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat$dirVar <- dat[[dir_var_name]]
    fit <- try({
      sae::eblupSFH(formula, dirVar, proxmat = testRook(nrow(dat)), data = dat)
    })
    dat[[pred_name]] <- if (inherits(fit, "try-error")) NA else as.numeric(fit$eblup)
    dat
  }
}

rfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    fit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    dat[[pred_name]] <- fit$reblup
    dat[[paste0(pred_name, "-BC")]] <- predict(fit, type = "reblupbc")$reblupbc
    dat
  }
}

rsfh <- function(dir_name, dir_var_name, pred_name = "rsfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    fit <- saeRobust::rfh(
      formula, dir_var_name, data = dat, correlation = corSAR1(testRook(nrow(dat))),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )
    dat[[pred_name]] <- fit$reblup
    dat[[paste0(pred_name, "-BC")]] <- predict(fit, type = "reblupbc")$reblupbc
    dat
  }
}

stfh <- function(dir_name, dir_var_name, pred_name = "sfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {

    T <- length(unique(dat$idT))
    D <- length(unique(dat$idD))

    dat$dirVar <- dat[[dir_var_name]]
    fit <- try({
      sae::eblupSTFH(formula, D, T, dirVar, proxmat = testRook(D), data = dat,
                     MAXITER = maxIter * maxIterParam)
    })
    dat[[pred_name]] <- if (inherits(fit, "try-error")) NA else as.numeric(fit$eblup)
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
      correlation = corAR1(T), k = 1e6,
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
      correlation = corAR1(T),
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
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )

    dat[[pred_name]] <- fit$reblup
    dat[[paste0(pred_name, "-BC")]] <- predict(fit, type = "reblupbc")$reblupbc

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
