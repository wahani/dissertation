# Title: Model based simulation: Performance of MSPE estimators
# Author: Sebastian Warnholz
#
# Intructions:
# Run 00Dependencies.R first. Use 'runs' to reduce the number of iterations. Set
# recompute* to TRUE when the results are not cached. Check cpus for parallel
# computing.

.libPaths("~/R/x86_64-redhat-linux-gnu-library/3.2")
library("dat")
library("saeSim")
library("saeRobust")
library("ggplot2")

comp <- modules::use("R/comp/mse.R")
gg <- modules::use("R/graphics/")
gen <- modules::use("R/generators/x.R")
tab <- modules::use("R/graphics/tables.R")

# Constants
LOCAL <- identical(commandArgs(TRUE), character(0))

## Graphic Parameter
width <- 7
height <- 3
fontSize <- 14

## Scenario:
D <- 40
n <- 1
nTime <- 10
nCont <- c(5, 15, 25, 35)
sige <- sqrt(seq(2, 6, length.out = D))
sigre <- 8
sigre2 <- 4

## Simulation
runs <- 100
cpus <- if (LOCAL) parallel::detectCores() - 1 else 1
number <- if (LOCAL) NULL else commandArgs(TRUE)
rerunBase <- TRUE
rerunSpatial <- TRUE
rerunTemporal <- TRUE
rerunSpatioTemporal <- TRUE

# Setup
setup <- base_id(D, 1) %>%
  sim_gen_generic(gen$fixed_sequence, groupVars = "idD", name = "x") %>%
  sim_gen_e(sd = sige) %>%
  sim_comp_pop(function(dat) {dat$trueVar <- sige^2; dat}) %>%
  sim_resp_eq(y = 100 + 5 * x + v + e, trueVal = 100 + 5 * x + v)

## Base
setupBase <- setup %>%
  sim_gen_v(sd = sqrt(sigre))  %>%
  sim_comp_agg(comp$rfh("y", "trueVar")) %>%
  sim_simName("(0)")

setupOutlier <- setup %>%
  sim_gen_v(sd = sqrt(sigre))  %>%
  sim_comp_agg(comp$rfh("y", "trueVar")) %>%
  sim_gen_cont(
    gen_norm(9, 5, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(u)")

## Spatial
setupSpatial <- setup %>%
  sim_gen(gen_v_sar(sd = sqrt(sigre), name = "v"))  %>%
  sim_comp_agg(comp$rsfh("y", "trueVar")) %>%
  sim_simName("(0)")

setupOutlierSpatial <- setupSpatial %>%
  sim_gen_cont(
    gen_norm(9, 5, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_simName("(u)")

## Temporal

trueVarTemporal <- rep(sige^2, each = nTime)

setupTemporal <- base_id_temporal(D, n, nTime) %>%
  # Area-Level Data
  sim_gen_e(sd = sqrt(trueVarTemporal)) %>%
  sim_gen_generic(gen$fixed_sequence, groupVars = "idD", name = "x") %>%
  sim_gen(gen_v_ar1(rho = 0.5, sd = sqrt(sigre2), name = "ar")) %>%
  sim_resp_eq(y = 100 + 5 * x + v + ar + e, trueVal = 100 + 5 * x + v + ar) %>%
  sim_comp_agg(comp_var(trueVar = trueVarTemporal))

setupTemporalBase <- setupTemporal %>%
  sim_gen(gen_v_sar(rho = 0, sd = sqrt(sigre2), name = "v")) %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_comp_agg(comp$rtfh("y", "trueVar")) %>%
  sim_simName("(0)")

setupTemporalBaseOutlier <- setupTemporalBase %>%
  sim_gen_cont(
    gen_norm(9, 5, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_gen(function(dat) { dat[dat$idD %in% nCont, "ar"] <- 0 ; dat }) %>%
  sim_comp_agg(comp$rtfh("y", "trueVar")) %>%
  sim_simName("(u)")

## Spatio Temporal
setupSpatioTemporal <- setupTemporal %>%
  sim_gen(gen_v_sar(rho = 0.5, sd = sqrt(sigre2), name = "v")) %>%
  sim_gen(gen_v_ar1(rho = 0.5, sd = sqrt(sigre2), name = "ar")) %>%
  sim_comp_agg(comp$rstfh("y", "trueVar")) %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0)")

setupSpatioTemporalOutlier <- setupSpatioTemporal %>%
  sim_gen_cont(
    gen_norm(9, 5, "v"),
    type = "area", areaVar = "idD", fixed = TRUE,
    nCont = nCont) %>%
  sim_gen(function(dat) { dat[dat$idD %in% nCont, "ar"] <- 0 ; dat }) %>%
  sim_simName("(u)")

# Simulation

fixName <- function(x) {
  # Necessary for old add hoc fix for naming struct
  sub("^.*\\(", "(", x)
}

# mutar(simName ~ fixName(simName))
simFun <- function(s, path = "R/data/areaLevelMSE") {
  if (LOCAL) {
    sim(s, runs, mode = "multicore", cpus = cpus, mc.preschedule = FALSE,
      path = path, overwrite = FALSE)
  } else {
    Sys.sleep(runif(1, 10, 30))
    gc()
    sim(s, runs, path = path, overwrite = FALSE)
  }
}

if (rerunBase) {
  lapply(list(setupBase, setupOutlier), simFun)
}

if (rerunSpatial) {
  lapply(list(setupSpatial, setupOutlierSpatial), simFun,
         path = "R/data/areaLevelMSESpatial/")
}

if (rerunTemporal) {
  lapply(list(setupTemporalBase, setupTemporalBaseOutlier), simFun,
         path = "R/data/areaLevelMSETemporal/")
}

if (rerunSpatioTemporal) {
  lapply(list(setupSpatioTemporal, setupSpatioTemporalOutlier), simFun,
         path = "R/data/areaLevelMSESpatioTemporal/")
}

sim_clear_data("R/data/areaLevelMSE/")
sim_clear_data("R/data/areaLevelMSESpatial//")
sim_clear_data("R/data/areaLevelMSETemporal//")
sim_clear_data("R/data/areaLevelMSESpatioTemporal//")

simDat <- sim_read_data("R/data/areaLevelMSE/")
save(list = "simDat", file = "R/data/areaLevelMse.RData")
simDatSpatial <- sim_read_data("R/data/areaLevelMSESpatial/")
save(list = "simDatSpatial", file = "R/data/areaLevelMseSpatial.RData")
simDatTemporal <- sim_read_data("R/data/areaLevelMSETemporal/")
save(list = "simDatTemporal", file = "R/data/areaLevelMseTemporal.RData")
simDatSpatioTemporal <- sim_read_data("R/data/areaLevelMSESpatioTemporal/")
save(list = "simDatSpatioTemporal", file = "R/data/areaLevelMseSpatioTemporal.RData")

if (!LOCAL) {
  q("no")
}

simDatSpatioTemporal <- simDatSpatioTemporal %>% mutar(~idT == nTime)
simDatTemporal <- simDatTemporal %>% mutar(~idT == nTime)

plotRMSE <- function(simDat) {
  mseDat <- simDat %>%
    mutar(
      MC ~ sqrt(mean((rfh - trueVal)^2)),
      MC.BC ~ sqrt(mean((rfh.BC - trueVal)^2)),
      CCT ~ mean(sqrt(rfhPseudoMse)),
      BOOT ~ mean(sqrt(rfhBootMse)),
      CCT.BC ~ mean(sqrt(rfhPseudoMse.BC)),
      BOOT.BC ~ mean(sqrt(rfhBootMse.BC)),
      by = c("idD", "simName")
    )

  ggDat <- mseDat %>%
    tidyr::gather(estimator, RMSPE, -idD, -simName) %>%
    mutar(~ estimator %in% c("MC.BC", "CCT.BC", "BOOT.BC"))

  ggplot(ggDat, aes(x = idD, y = RMSPE, colour = estimator)) +
    geom_line() + gg$themes$theme_thesis(fontSize) + labs(x = "Domain", colour = NULL) +
    theme(legend.position = "bottom") + facet_wrap(~simName, ncol = 2)

}

cairo_pdf("figs/area_level_mse.pdf", width, 1.2 * height)
plotRMSE(simDat)
dev.off()


# plotRMSE(simDatSpatial)
# plotRMSE(simDatTemporal)
# plotRMSE(simDatSpatioTemporal)


tableMSE <- function(simDat) {
  mseDat <- simDat %>%
    mutar(
      MCRFH ~ sqrt(mean((rfh - trueVal)^2)),
      MCRFH.BC ~ sqrt(mean((rfh.BC - trueVal)^2)),
      by = c("idD", "simName")
    )

  simDat <- dplyr::left_join(
    simDat,
    mseDat[c("idD", "simName", "MCRFH", "MCRFH.BC")],
    by = c("idD", "simName")
  )

  # RBIAS
  bias <- simDat %>%
    mutar(
      PseudoRFH ~ mean((sqrt(rfhPseudoMse) - MCRFH) / MCRFH),
      BootRFH ~ mean((sqrt(rfhBootMse) - MCRFH) / MCRFH),
      PseudoRFH.BC ~ mean((sqrt(rfhPseudoMse.BC) - MCRFH.BC) / MCRFH.BC),
      BootRFH.BC ~ mean((sqrt(rfhBootMse.BC) - MCRFH.BC) / MCRFH.BC),
      by = c("idD", "simName")
    ) %>%
    mutar(ind ~ ifelse(grepl("u\\)$", simName) & (idD %in% nCont), 1, 0)) %>%
    mutar(RFH.PSEUDO ~ median(PseudoRFH),
          RFH.BOOT ~ median(BootRFH),
          RFH.BC.PSEUDO ~ median(PseudoRFH.BC),
          RFH.BC.BOOT ~ median(BootRFH.BC),
          by = c("ind", "simName"))

  colNames <- paste(
    bias$simName,
    ifelse(bias$ind == 0, "Regular", "Outlier"),
    sep = "-"
  )

  biasMat <- t(as.matrix(mutar(bias, "^RFH")))
  colnames(biasMat) <- colNames

  # RRMSE
  mse <- simDat %>%
    mutar(
      PseudoRFH ~ sqrt(mean(((sqrt(rfhPseudoMse) - MCRFH) / MCRFH)^2)),
      BootRFH ~ sqrt(mean(((sqrt(rfhBootMse) - MCRFH) / MCRFH)^2)),
      PseudoRFH.BC ~ sqrt(mean(((sqrt(rfhPseudoMse.BC) - MCRFH.BC) / MCRFH.BC)^2)),
      BootRFH.BC ~ sqrt(mean(((sqrt(rfhBootMse.BC) - MCRFH.BC) / MCRFH.BC)^2)),
      by = c("idD", "simName")
    ) %>%
    mutar(ind ~ ifelse(grepl("u\\)$", simName) & (idD %in% nCont), 1, 0)) %>%
    mutar(RFH.PSEUDO ~ median(PseudoRFH),
          RFH.BOOT ~ median(BootRFH),
          RFH.BC.PSEUDO ~ median(PseudoRFH.BC),
          RFH.BC.BOOT ~ median(BootRFH.BC),
          by = c("ind", "simName"))

  mseMat <- t(as.matrix(mutar(mse, "^RFH")))
  colnames(mseMat) <- colNames

  list(bias = biasMat, mse = mseMat)

}


tabRFH <- tableMSE(simDat)
tabRSFH <- tableMSE(simDatSpatial)
tabRTFH <- tableMSE(simDatTemporal)
tabRSTFH <- tableMSE(simDatSpatioTemporal)

makeTable <- function(tabRFH, tabRSFH, tabRTFH, tabRSTFH, type) {

  datBIAS <- as.data.frame(rbind(
    tabRFH[[type]],
    tabRSFH[[type]],
    tabRTFH[[type]],
    tabRSTFH[[type]]
  ) * 100, row.names = FALSE) %>%
    round(2) %>%
    mutar(
      Predictor ~ c(c("RFH", NA),
                    c("RFH.BC", NA),
                    c("RSFH", NA),
                    c("RSFH.BC", NA),
                    c("RTFH", NA),
                    c("RTFH.BC", NA),
                    c("RSTFH", NA),
                    c("RSTFH.BC", NA)),
      MSPE ~ rep(c("CCT", "BOOT"), 8)
    )
  datBIAS[c(4, 5, 1, 2, 3)]
}

rbias <- makeTable(tabRFH, tabRSFH, tabRTFH, tabRSTFH, "bias")
rbiasRow <- rbias[FALSE, ]
rbiasRow[1, 1] <- "Median RBIAS:"
rbias <- rbind(rbiasRow, rbias)

rrmse <- makeTable(tabRFH, tabRSFH, tabRTFH, tabRSTFH, "mse")
rrmseRow <- rrmse[FALSE, ]
rrmseRow[1, 1] <- "Median RRMSE:"
rrmse <- rbind(rrmseRow, rrmse)

dump <- tab$saveResize(
  rbind(rbias, rrmse),
  fileName = "tabs/mse_template.tex",
  caption = "\\label{tab:mse_performace}Performance of RMSPE Estimators in Model\\hyp{}Based Simulation. Results are in \\%. \\textit{Regular} denotes non\\hyp{}outlier observations. (0) is the model specific scenario without contamination; (u) is with outlier contamination.",
  caption.lot = "Performance of RMSPE Estimators in Model\\hyp{}Based Simulation"
)



