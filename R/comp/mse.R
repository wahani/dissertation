modules::import(stats)
modules::import(saeRobust)

maxIter <- 50
maxIterParam <- 10
maxIterRe <- 1000
B <- 100

rfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name)
  force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {

    modelFit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )

    prediction <- mse(modelFit, type = c("pseudo", "boot"), predType = c("reblup", "reblupbc"), B = B)

    dat[[pred_name]] <- prediction$reblup
    dat[[paste0(pred_name, ".BC")]] <- prediction$reblupbc

    dat[[paste0(pred_name, "PseudoMse")]] <- prediction$pseudo
    dat[[paste0(pred_name, "PseudoMse.BC")]] <- prediction$pseudobc

    dat[[paste0(pred_name, "BootMse")]] <- prediction$boot
    dat[[paste0(pred_name, "BootMse.BC")]] <- prediction$bootbc

    dat

  }
}


rsfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {

    modelFit <- saeRobust::rfh(
      formula, dir_var_name, data = dat, correlation = corSAR1(testRook(nrow(dat))),
      x0Var = c(0.5, 4),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )

    prediction <- mse(modelFit, type = c("pseudo", "boot"), predType = c("reblup", "reblupbc"), B = B)

    dat[[pred_name]] <- prediction$reblup
    dat[[paste0(pred_name, ".BC")]] <- prediction$reblupbc

    dat[[paste0(pred_name, "PseudoMse")]] <- prediction$pseudo
    dat[[paste0(pred_name, "PseudoMse.BC")]] <- prediction$pseudobc

    dat[[paste0(pred_name, "BootMse")]] <- prediction$boot
    dat[[paste0(pred_name, "BootMse.BC")]] <- prediction$bootbc

    dat

  }
}

rtfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {

    T <- length(unique(dat$idT))
    modelFit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      correlation = corAR1(T), x0Var = c(0.5, 2, 2),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )

    prediction <- mse(modelFit, type = c("pseudo", "boot"), predType = c("reblup", "reblupbc"), B = B)

    dat[[pred_name]] <- prediction$reblup
    dat[[paste0(pred_name, ".BC")]] <- prediction$reblupbc

    dat[[paste0(pred_name, "PseudoMse")]] <- prediction$pseudo
    dat[[paste0(pred_name, "PseudoMse.BC")]] <- prediction$pseudobc

    dat[[paste0(pred_name, "BootMse")]] <- prediction$boot
    dat[[paste0(pred_name, "BootMse.BC")]] <- prediction$bootbc

    dat

  }
}

rstfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name); force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {

    T <- length(unique(dat$idT))
    D <- length(unique(dat$idD))

    modelFit <- saeRobust::rfh(
      formula, dir_var_name, data = dat,
      correlation = corSAR1AR1(W = testRook(D), nTime = T),
      x0Var = c(0.5, 0.5, 2, 2),
      maxIter = maxIter, maxIterParam = maxIterParam, maxIterRe = maxIterRe
    )

    prediction <- mse(modelFit, type = c("pseudo", "boot"), predType = c("reblup", "reblupbc"), B = B)

    dat[[pred_name]] <- prediction$reblup
    dat[[paste0(pred_name, ".BC")]] <- prediction$reblupbc

    dat[[paste0(pred_name, "PseudoMse")]] <- prediction$pseudo
    dat[[paste0(pred_name, "PseudoMse.BC")]] <- prediction$pseudobc

    dat[[paste0(pred_name, "BootMse")]] <- prediction$boot
    dat[[paste0(pred_name, "BootMse.BC")]] <- prediction$bootbc

    dat

  }
}
