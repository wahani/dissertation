# Monte Carlo simulation starting from area level data for the standard fh

library("ggplot2")
library("saeSim")
library("dat")

gen <- modules::use("R/generators")
comp <- modules::use("R/comp")
gg <- modules::use("./R/graphics")

# Parameter in Simulation
D <- 40
nCont <- c(5, 15, 25, 35)
n <- 1
T <- 10
trueVar <- seq(2, 6, length.out = D)
sigre <- 2

# Settings
runs <- 500
cpus <- parallel::detectCores() - 1
# set.seed(1)
reRun <- FALSE
reRunTemporal <- FALSE

# Graphic Parameter
width <- 7
height <- 3
fontSize <- 14

# Defining the Setups
setup <- base_id(D, n) %>%
  # Area-Level Data
  sim_gen_e(sd = sqrt(trueVar)) %>%
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
    gen_norm(100, 10, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(0, u)")

setupSpatialOutlier <- setupSpatial %>%
  sim_gen_cont(
    gen_norm(100, 10, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(0.5, u)")

# Temporal Scenarios

trueVarTemporal <- rep(trueVar, each = T)

setupTemporal <- base_id_temporal(D, n, T) %>%
  # Area-Level Data
  sim_gen_e(sd = sqrt(trueVarTemporal)) %>%
  sim_gen_generic(gen$x$fixed_sequence, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 5 * x + v + e) %>%
  sim_comp_agg(comp_var(trueVar = trueVarTemporal)) %>%
  sim_comp_agg(comp$area$tfh("y", "trueVar", "TFH")) %>%
  sim_comp_agg(comp$area$rtfh("y", "trueVar", "RTFH")) %>%
  sim_comp_agg(comp$area$stfh("y", "trueVar", "STFH")) %>%
  sim_comp_agg(comp$area$rstfh("y", "trueVar", "RSTFH"))

setupTemporalBase <- setupTemporal %>%
  sim_gen(gen_v_sar(rho = 0, sd = sqrt(sigre), name = "v")) %>%
  sim_gen(gen_v_ar1(rho = 0, sd = sqrt(sigre), name = "ar")) %>%
  sim_resp_eq(y = y + ar) %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0, 0)")

setupSpatioTemporal <- setupTemporal %>%
  sim_gen(gen_v_sar(rho = 0.5, sd = sqrt(sigre), name = "v")) %>%
  sim_gen(gen_v_ar1(rho = 0.5, sd = sqrt(sigre), name = "ar")) %>%
  sim_resp_eq(y = y + ar) %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0.5, 0)")

setupTemporalBaseOutlier <- setupTemporalBase %>%
  sim_gen_cont(
    gen_norm(100, 10, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(0, u)")

setupSpatioTemporalOutlier <- setupSpatioTemporal %>%
  sim_gen_cont(
    gen_norm(100, 10, "v"),
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
  save(list = "simData", file = "R/data/areaLevel.RData")
} else {
  load("R/data/areaLevel.RData")
}

if (reRunTemporal) {

  simFun <- . %>%
    sim(runs,
        mode = "multicore", cpus = cpus, mc.preschedule = FALSE,
        path = "./R/data/areaLevelTemporal", overwrite = TRUE) %>%
    do.call(what = rbind)

  lapply(
    list(setupTemporalBase, setupTemporalBaseOutlier, setupSpatioTemporal,
         setupSpatioTemporalOutlier),
    simFun
  )
  simDataTemporal <- sim_read_data("./R/data/areaLevelTemporal")
  save(list = "simDataTemporal", file = "R/data/areaLevelTemporal.RData")
} else {
  load("R/data/areaLevelTemporal.RData")
}

simData %>% mutar(~is.na(SFH), n ~ length(unique(idR)), by = c("simName"))
simData %>% mutar(function(col) any(is.na(col))) # check for missings
simDataTemporal %>% mutar(function(col) any(is.na(col))) # check for missings
# ar is missing in scenarios with no ar process


# Graphics:
simData$popMean <- simData$y - simData$e
simData$Direct <- simData$y

simData <- as.DataFrame(simData)

ggDat <- reshape2::melt(
  simData,
  id.vars = c("idD", "popMean", "simName"),
  measure.vars = c("Direct", "FH", "RFH", "SFH", "RSFH", "RFH.BC", "RSFH.BC"),
  variable.name = "method",
  value.name = "prediction"
)

ggDat <- ggDat %>%
  mutar(RBIAS ~ mean((prediction - popMean) / popMean),
        RRMSE ~ sqrt(mean(((prediction - popMean) / popMean)^2)),
        by = c("idD", "method", "simName"))

scenarioOrder <- c("(0, 0)", "(0, u)", "(0.5, 0)", "(0.5, u)")
methodOrder <- c("Direct", "FH", "SFH", "RFH", "RSFH", "RFH.BC", "RSFH.BC")

ggDat <- ggDat %>%
  mutar(simName ~ factor(simName, ordered = TRUE, levels = scenarioOrder),
        method ~ factor(method, ordered = TRUE, levels = methodOrder))

cairo_pdf("figs/area_level_rrmse.pdf", width, 2 * height)
gg$plots$mse(ggDat, fontsize = fontSize) +
  scale_y_log10(breaks = c(0.01, 0.02, 0.1))
dev.off()

cairo_pdf("figs/area_level_rbias.pdf", width, 2 * height)
gg$plots$bias(ggDat, fontsize = fontSize)
dev.off()

ggDat %>% as.data.frame %>% mutar(~ RRMSE > 0.03)

## Graphics Temporal

simDataTemporal$popMean <- simDataTemporal$y - simDataTemporal$e
simDataTemporal$Direct <- simDataTemporal$y

simDataTemporal <- as.DataFrame(simDataTemporal)

simDataTemporal[~is.na(STFH), n ~ length(unique(idR)), by = c("simName")]
simDataTemporal[~is.na(TFH), n ~ length(unique(idR)), by = c("simName")]

# We are interested in the current time period:
simDataTemporal <- simDataTemporal[~idT == 10]


ggDat <- reshape2::melt(
  simDataTemporal,
  id.vars = c("idD", "popMean", "simName"),
  measure.vars = c("Direct", "TFH", "RTFH", "STFH", "RSTFH", "RTFH.BC", "RSTFH.BC"),
  variable.name = "method",
  value.name = "prediction"
)

ggDat <- ggDat %>%
  mutar(RBIAS ~ mean((prediction - popMean) / popMean),
        RRMSE ~ sqrt(mean(((prediction - popMean) / popMean)^2)),
        by = c("idD", "method", "simName"))

scenarioOrder <- c("(0, 0)", "(0, u)", "(0.5, 0)", "(0.5, u)")
methodOrder <- c("Direct", "TFH", "STFH", "RTFH", "RSTFH", "RTFH.BC", "RSTFH.BC")

ggDat <- ggDat %>%
  mutar(simName ~ factor(simName, ordered = TRUE, levels = scenarioOrder),
        method ~ factor(method, ordered = TRUE, levels = methodOrder))

cairo_pdf("figs/area_level_rrmse.pdf", width, 2 * height)
gg$plots$mse(ggDat, fontsize = fontSize)
dev.off()

cairo_pdf("figs/area_level_rbias.pdf", width, 2 * height)
gg$plots$bias(ggDat, fontsize = fontSize)
dev.off()




