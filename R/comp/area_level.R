modules::import(stats)

comp_fh <- function(dir_name, dir_var_name, pred_name = "fh") {
  force(dir_var_name)
  force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    modelDat <- as.data.frame(dat) # package:sae needs this!
    modelDat$varDir <- modelDat[[dir_var_name]]
    dat[[pred_name]] <- sae::eblupFH(formula, varDir, data = modelDat)$eblup[, 1]
    dat
  }
}

comp_rfh <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name)
  force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    dat[[pred_name]] <- predict(saeRobustTools::rfh(formula, dir_var_name, data = dat))$REBLUP
    dat
  }
}

comp_rfh_mse <- function(dir_name, dir_var_name, pred_name = "rfh") {
  force(dir_var_name)
  force(pred_name)
  formula <- as.formula(paste(dir_name, "~", "x"))
  function(dat) {
    modelFit <- saeRobustTools::rfh(formula, dir_var_name, data = dat)
    prediction <- predict(modelFit, mse = "pseudo")
    dat[[pred_name]] <- prediction$REBLUP
    dat[[paste0(pred_name, "PseudoMse")]] <- prediction$pseudo
    dat
  }
}
