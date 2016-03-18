# Monte Carlo simulation starting from area level data for the standard fh

library("ggplot2")
library("saeSim")
library("dat")

gen <- modules::use("R/generators")
comp <- modules::use("R/comp")
gg <- modules::use("./R/graphics")

# Parameter in Simulation
D <- 40
nCont <- round(0.1 * D)
n <- 1
trueVar <- seq(3.2, 1, length.out = D)
sigre <- 2

# Settings
runs <- 200
cpus <- parallel::detectCores() - 1
# set.seed(1)
reRun <- FALSE

# Defining the Setups
setup <- base_id(D, n) %>%
  # Area-Level Data
  sim_gen_e(sd = sqrt(trueVar)) %>%
  sim_gen_v(sd = 1) %>%
  sim_gen_generic(gen$x$fixed_sequence, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 5 * x + v + e) %>%
  sim_comp_agg(comp_var(trueVar = trueVar)) %>%
  sim_comp_agg(comp$area$fh("y", "trueVar", "FH")) %>%
  sim_comp_agg(comp$area$rfh("y", "trueVar", "RFH")) %>%
  sim_comp_agg(comp$area$sfh("y", "trueVar", "SFH")) %>%
  sim_comp_agg(comp$area$rsfh("y", "trueVar", "RSFH"))

setupBase <- setup %>%
  sim_gen(gen_v_norm(sd = sigre)) %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0, 0)")

setupSpatial <- setup %>%
  sim_gen(gen_v_sar(rho = 0.5, sd = sigre, name = "v")) %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0.5, 0)")

setupBaseOutlier <- setupBase %>%
  sim_gen_cont(
    gen_norm(10, 10, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(0, u)")

setupSpatialOutlier <- setupSpatial %>%
  sim_gen_cont(
    gen_norm(10, 10, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(0.5, u)")

# Trigger Simulation:
simFun <- . %>%
  sim(runs,
      mode = "multicore", cpus = cpus, mc.preschedule = FALSE,
      path = "./R/data/areaLevel", overwrite = TRUE) %>%
  do.call(what = rbind)

if (reRun) {
  lapply(
    list(setupBase, setupBaseOutlier, setupSpatial, setupSpatialOutlier),
    simFun
  )
  simData <- sim_read_data("./R/data/areaLevel")
  save(list = "simData", file = "R/data/areaLevel/simData.RData")
} else {
  load("R/data/areaLevel/simData.RData")
}


# Graphics:
simData$popMean <- simData$y - simData$e
simData$Direct <- simData$y

ggDat <- reshape2::melt(
  simData,
  id.vars = c("idD", "popMean", "simName"),
  measure.vars = c("Direct", "FH", "RFH", "SFH", "RSFH"),
  variable.name = "method",
  value.name = "prediction"
)

ggDat %<>%
  dplyr::group_by(idD, method, simName) %>%
  dplyr::summarise(RBIAS = mean((prediction - popMean) / popMean),
                   RRMSE = sqrt(mean(((prediction - popMean) / popMean)^2)))

ggDat %>%
  as.data.frame %>%
  mutar(rbias ~ mean(RBIAS[37:40]), by = c("method", "simName"))

area_level_mc_rrmse_all <- gg$plots$mse(ggDat)
area_level_mc_rbias_all <- gg$plots$bias(ggDat)

