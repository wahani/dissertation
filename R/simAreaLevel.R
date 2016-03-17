# Monte Carlo simulation starting from area level data for the standard fh

library("ggplot2")
library("saeSim")

gen <- modules::use("R/generators")
comp <- modules::use("R/comp")
gg <- modules::use("./R/graphics")

# Parameter in Simulation
D <- 100
Ud <- 1
trueVar <- seq(1, 3.2, length.out = D)

# Settings
cpus <- parallel::detectCores() - 1

set.seed(1)

# Defining the Setups

setup <- base_id(D, Ud) %>%
  # Area-Level Data
  sim_gen_e(sd = sqrt(trueVar)) %>%
  sim_gen_v(sd = 1) %>%
  sim_gen_generic(gen$x$fixed_sequence, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 10 * x + v + e) %>%
  sim_comp_agg(comp_var(trueVar = trueVar)) %>%
  sim_gen(gen_v_sar(rho = 0, name = "sar"))

setup %<>%
  sim_comp_agg(comp$area$fh("y", "trueVar", "FH")) %>%
  sim_comp_agg(comp$area$rfh("y", "trueVar", "RFH"))

setup <- setup %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0, 0)")

setupV <- setup %>%
  sim_gen_vc(sd = 20, fixed = TRUE) %>%
  sim_simName("(v, 0)")


# Trigger Simulation:
simFun <- . %>%
  sim(100,
      mode = "multicore", cpus = cpus,
      path = "./R/data/areaLevel", overwrite = FALSE) %>%
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

area_level_mc_rrmse_00 <- gg$plots$mse(subset(ggDat, simName == "(0, 0)"))
area_level_mc_rrmse_v0 <- gg$plots$mse(subset(ggDat, simName == "(v, 0)")) + ggplot2::scale_y_log10()
area_level_mc_rbias_00 <- gg$plots$bias(subset(ggDat, simName == "(0, 0)"))
area_level_mc_rbias_v0 <- gg$plots$bias(subset(ggDat, simName == "(v, 0)"))
area_level_mc_rrmse_all <- gg$plots$mse(ggDat) + ggplot2::scale_y_log10()
area_level_mc_rbias_all <- gg$plots$bias(ggDat)

gg$save$default(area_level_mc_rrmse_00)
gg$save$default(area_level_mc_rrmse_v0)
gg$save$default(area_level_mc_rbias_00)
gg$save$default(area_level_mc_rbias_v0)
gg$save$default(area_level_mc_rrmse_all)
gg$save$default(area_level_mc_rbias_all)
