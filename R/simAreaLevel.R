# Monte Carlo simulation starting from area level data for the standard fh

module::import("ggplot2")
module::import("saeSim")
module::use("R/generators/gen_x.R")
module::use("R/comp/direct_estimators.R")
module::use("R/comp/area_level.R")
ggPlot <- module::as.module("./R/graphics/mse_bias.R")
gg <- module::as.module("./R/graphics/save.R")

# Constants:
D <- 100
Ud <- 1
trueVar <- seq(1, 3.2, length.out = D)

setup <- base_id(D, Ud) %>%
  # Area-Level Data
  sim_gen_e(sd = sqrt(trueVar)) %>%
  sim_gen_v(sd = 1) %>%
  sim_gen_generic(gen_x, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 10 * x + v + e) %>%
  sim_comp_agg(comp_var(trueVar = trueVar))

setup %<>%
  sim_comp_agg(comp_fh("y", "trueVar", "FH")) %>%
  sim_comp_agg(comp_rfh("y", "trueVar", "RFH"))

setup <- setup %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0, 0)")

setupV <- setup %>%
  sim_gen_vc(sd = 20, fixed = TRUE) %>%
  sim_simName("(v, 0)")

simFun <- . %>%
  sim(500, mode = "multicore", cpus = 3, path = "./R/data/areaLevel", overwrite = FALSE) %>%
  do.call(what = rbind)

lapply(list(setup, setupV), simFun)

# Graphics:

simData <- sim_read_data("./R/data/areaLevel")

simData$popMean <- simData$y - simData$e

ggDat <- reshape2::melt(
  simData,
  id.vars = c("idD", "popMean", "simName"),
  measure.vars = c("y", "FH", "RFH"),
  variable.name = "method",
  value.name = "prediction"
)

ggDat %<>%
  dplyr::group_by(idD, method, simName) %>%
  dplyr::summarise(RBIAS = mean((prediction - popMean) / popMean),
                   RRMSE = sqrt(mean(((prediction - popMean) / popMean)^2)))

"area_level_mc_rrmse_00" <- ggPlot$mse(subset(ggDat, simName == "(0, 0)"))
"area_level_mc_rrmse_v0" <- ggPlot$mse(subset(ggDat, simName == "(v, 0)")) + ggplot2::scale_y_log10()
"area_level_mc_rbias_00" <- ggPlot$bias(subset(ggDat, simName == "(0, 0)"))
"area_level_mc_rbias_v0" <- ggPlot$bias(subset(ggDat, simName == "(v, 0)"))
"area_level_mc_rrmse_all" <- ggPlot$mse(ggDat) + ggplot2::scale_y_log10()
"area_level_mc_rbias_all" <- ggPlot$bias(ggDat)

gg$save_default("area_level_mc_rrmse_00")
gg$save_default("area_level_mc_rrmse_v0")
gg$save_default("area_level_mc_rbias_00")
gg$save_default("area_level_mc_rbias_v0")
gg$save_default("area_level_mc_rrmse_all")
gg$save_default("area_level_mc_rbias_all")
