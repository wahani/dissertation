modules::import(stats)

fh <- function(dir_name, dir_var_name, pred_name = "fh") {
  force(dir_var_name)
  force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat[[pred_name]] <- saeRobust::rfh(formula, dir_var_name, data = dat, k = 1e6)$reblup
    dat
  }
}

rfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name)
  force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat[[pred_name]] <- saeRobust::rfh(formula, dir_var_name, data = dat)$reblup
    dat
  }
}

rfh_mse <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name)
  force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    modelFit <- saeRobust::rfh(formula, dir_var_name, data = dat)
    prediction <- predict(modelFit, mse = c("pseudo", "boot"), B = 100)
    dat[[pred_name]] <- prediction$REBLUP
    dat[[paste0(pred_name, "PseudoMse")]] <- prediction$pseudo
    dat[[paste0(pred_name, "BootMse")]] <- prediction$boot
    dat
  }
}
