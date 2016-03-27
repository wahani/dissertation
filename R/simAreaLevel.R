# Monte Carlo simulation starting from area level data for the standard fh
.libPaths("~/R/x86_64-redhat-linux-gnu-library/3.2")
library("ggplot2")
library("saeSim")
library("dat")

gen <- modules::use("R/generators")
comp <- modules::use("R/comp")
gg <- modules::use("./R/graphics")

LOCAL <- identical(commandArgs(TRUE), character(0))

# Parameter in Simulation
D <- 40
nCont <- c(5, 15, 25, 35)
n <- 1
nTime <- 10
trueVar <- seq(2, 6, length.out = D)
sigre <- 2

# Settings
runs <- 500
cpus <- parallel::detectCores() - 1
# set.seed(1)
reRun <- TRUE

# Graphic Parameter
width <- 7
height <- 3
fontSize <- 14

simFun <- function(s, path) {
  if (LOCAL) {
    sim(s, runs, mode = "multicore", cpus = cpus, mc.preschedule = FALSE,
        path = path, overwrite = FALSE)
  } else {
    Sys.sleep(runif(1, 10, 30))
    gc()
    sim(s, runs, path = path, overwrite = FALSE)
  }
}

trueVarTemporal <- rep(trueVar, each = nTime)

setupTemporal <- base_id_temporal(D, n, nTime) %>%
  # Area-Level Data
  sim_gen_e(sd = sqrt(trueVarTemporal)) %>%
  sim_gen_generic(gen$x$fixed_sequence, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 5 * x + v + ar + e) %>%
  sim_comp_agg(comp_var(trueVar = trueVarTemporal)) %>%
  # All the models:
  sim_comp_agg(comp$area_temporal$fh("y", "trueVar", "FH")) %>%
  sim_comp_agg(comp$area_temporal$rfh("y", "trueVar", "RFH")) %>%
  sim_comp_agg(comp$area_temporal$sfh("y", "trueVar", "SFH")) %>%
  sim_comp_agg(comp$area_temporal$rsfh("y", "trueVar", "RSFH")) %>%
  sim_comp_agg(comp$area_temporal$tfh("y", "trueVar", "TFH")) %>%
  sim_comp_agg(comp$area_temporal$rtfh("y", "trueVar", "RTFH")) %>%
  sim_comp_agg(comp$area_temporal$stfh("y", "trueVar", "STFH")) %>%
  sim_comp_agg(comp$area_temporal$rstfh("y", "trueVar", "RSTFH"))

setupTemporalBase <- setupTemporal %>%
  sim_gen(gen_v_sar(rho = 0, sd = sqrt(sigre), name = "v")) %>%
  sim_gen(gen_v_ar1(rho = 0, sd = sqrt(sigre), name = "ar")) %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0, 0)")

setupSpatioTemporal <- setupTemporal %>%
  sim_gen(gen_v_sar(rho = 0.5, sd = sqrt(sigre), name = "v")) %>%
  sim_gen(gen_v_ar1(rho = 0.5, sd = sqrt(sigre), name = "ar")) %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0.5, 0)")

setupTemporalBaseOutlier <- setupTemporalBase %>%
  sim_gen_cont(
    gen_norm(9, 5, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(0, u)")

setupSpatioTemporalOutlier <- setupSpatioTemporal %>%
  sim_gen_cont(
    gen_norm(9, 5, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(0.5, u)")

# Trigger Simulation:

if (reRun) {
  lapply(
    list(setupTemporalBase, setupSpatioTemporal, setupTemporalBaseOutlier,
         setupSpatioTemporalOutlier),
    simFun, path = "R/data/areaLevel/"
  )
  simData <- sim_read_data("./R/data/areaLevel")
  save(list = "simData", file = "R/data/areaLevel.RData")
} else {
  load("R/data/areaLevel.RData")
}

sim_clear_data("R/data/areaLevel/")

if (!LOCAL) {
  q("no")
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

cairo_pdf("figs/area_level_temporal_rrmse.pdf", width, 2 * height)
gg$plots$mse(ggDat, fontsize = fontSize)
dev.off()

cairo_pdf("figs/area_level_temporal_rbias.pdf", width, 2 * height)
gg$plots$bias(ggDat, fontsize = fontSize)
dev.off()




