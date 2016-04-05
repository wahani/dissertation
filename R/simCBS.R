# (0) Loading libraries
################################################################################

library(saeSim)
library(dat)
library(ggplot2)

rerun <- TRUE
fontSize <- 14
height <- 3
width <- 7
cpus <- round(parallel::detectCores() / 2)

# (1) Loading data
################################################################################

comp <- modules::use("R/comp")
gg <- modules::use("R/graphics/")

# This file also exists as .csv
load("R/data/CBS/cbsData.RData")

# Weights for aggregating
probSample <- read.table(
  "R/data/CBS/PROBsample.txt",
  header = TRUE, quote = "\"")[[1]]

# Original Ordering -- saeSim will sort for the id variables
dat$idOrd <- 1:nrow(dat)
idOrd <- as.data.frame(base_add_id(dat, domainId = c("group"))) [["idOrd"]]


# (2) Defining simulation
################################################################################

# Defining the simulation set-up
setup <- base_add_id(dat, domainId = c("group")) %>%
  # Calc on pop:
  sim_comp_popMean() %>%
  sim_comp_N() %>%
  sim_comp_pop(comp_var(
    turn_1_var = var(turn_1),
    turn_1 = mean(turn_1)
  ), by = "idD") %>%

  # Fix this computation:
  as.data.frame %>%

  # Sampling:
  sim_sample(comp$design$sample(idOrd, "R/data/CBS/IDsample_rep500.txt")) %>%

  # Calc on Sample:
  sim_comp_n() %>%

  # Aggregate:
  sim_agg(comp$direct$ht(probSample, "y")) %>%
  sim_agg() %>%

  # Calc on aggregates:
  sim_comp_agg(comp$design$fh)

if (rerun) {
  sim(
    setup, R = 500,
    path = "R/data/CBS/simData/", overwrite = FALSE,
    mode = "multicore", cpus = cpus, mc.preschedule = FALSE
    )
}

# sim_clear_data("R/data/CBS/simData/")

simData <- sim_read_data("R/data/CBS/simData/")

# Graphics:
#
# ## Point Predictions
simData$Direct <- simData$y

simData <- as.DataFrame(simData)

ggDat <- reshape2::melt(
  simData,
  id.vars = c("idD", "popMean"),
  measure.vars = c(
    "Direct", "FH", "RFH", "RFH.BC"
  ),
  variable.name = "method",
  value.name = "prediction"
)

ggDat <- ggDat %>%
  mutar(RBIAS ~ mean((prediction - popMean) / popMean) * 100,
        RRMSE ~ sqrt(mean(((prediction - popMean) / popMean)^2)) * 100,
        by = c("idD", "method"))

methodOrder <- c(
  "Direct",
  "FH", "RFH", "RFH.BC"
)

ggDat <- ggDat %>%
  mutar(method ~ factor(method, ordered = TRUE, levels = methodOrder))

ggDat$simName <- ""

g1 <- gg$plots$bias(ggDat, fontsize = fontSize) +
  labs(y = "RBIAS in %")
g2 <- gg$plots$mse(ggDat, fontsize = fontSize) +
  labs(y = "RRMSPE in %") +
  coord_flip(ylim = c(0, 80)) +
  theme(axis.text.y = element_blank())

cairo_pdf("figs/design_rrmspe.pdf", width, height)
gridExtra::grid.arrange(g1, g2, ncol = 2, widths = c(0.6, 0.4) * width)
dev.off()

## MSPE estimation:
plotRMSE <- function(simDat) {
  mseDat <- simDat %>%
    mutar(
      MC ~ sqrt(mean((RFH - popMean)^2)),
      MC.BC ~ sqrt(mean((RFH.BC - popMean)^2)),
      CCT ~ mean(sqrt(RFH.CCT)),
      BOOT ~ mean(sqrt(RFH.BOOT)),
      CCT.BC ~ mean(sqrt(RFH.BC.CCT)),
      BOOT.BC ~ mean(sqrt(RFH.BC.BOOT)),
      by = c("idD", "simName")
    )

  ggDat <- mseDat %>%
    tidyr::gather(estimator, RMSPE, -idD, -simName) %>%
    mutar(~ estimator %in% c(
      "MC", "CCT",  "BOOT"
      # "MC.BC", "CCT.BC", "BOOT.BC"
    ))

  ggplot(ggDat, aes(x = idD, y = RMSPE, colour = estimator)) +
    geom_line() + gg$themes$theme_thesis(fontSize) + labs(x = "Domain", colour = NULL) +
    theme(legend.position = "bottom")

}

plotRMSE(simData)

# cairo_pdf("figs/area_level_mse.pdf", width, 1.2 * height)
#
# dev.off()

tableMSE <- function(simDat) {
  mseDat <- simDat %>%
    mutar(
      MCFH ~ sqrt(mean((FH - popMean)^2)),
      MCRFH ~ sqrt(mean((RFH - popMean)^2)),
      MCRFH.BC ~ sqrt(mean((RFH.BC - popMean)^2)),
      by = c("idD")
    )

  simDat <- dplyr::left_join(
    simDat,
    mseDat[c("idD", "MCFH", "MCRFH", "MCRFH.BC")],
    by = c("idD")
  )

  # RBIAS
  bias <- simDat %>%
    mutar(
      FH.CCT ~ mean((sqrt(FH.CCT) - MCFH) / MCFH),
      FH.BOOT ~ mean((sqrt(FH.BOOT) - MCFH) / MCFH),
      RFH.CCT ~ mean((sqrt(RFH.CCT) - MCRFH) / MCRFH),
      RFH.BOOT ~ mean((sqrt(RFH.BOOT) - MCRFH) / MCRFH),
      RFH.BC.CCT ~ mean((sqrt(RFH.BC.CCT) - MCRFH.BC) / MCRFH.BC),
      RFH.BC.BOOT ~ mean((sqrt(RFH.BC.BOOT) - MCRFH.BC) / MCRFH.BC),
      id ~ 1,
      by = c("idD")
    ) %>%
    mutar(
      FH.CCT ~ median(FH.CCT),
      FH.BOOT ~ median(FH.BOOT),
      RFH.CCT ~ median(RFH.CCT),
      RFH.BOOT ~ median(RFH.BOOT),
      RFH.BC.CCT ~ median(RFH.BC.CCT),
      RFH.BC.BOOT ~ median(RFH.BC.BOOT),
      by = "id"
    )


  biasMat <- t(as.matrix(mutar(bias, "^.*FH")))
  colnames(biasMat) <- "RBIAS"

  # RRMSE
  mse <- simDat %>%
    mutar(
      FH.CCT ~ sqrt(mean(((sqrt(FH.CCT) - MCFH) / MCFH)^2)),
      FH.BOOT ~ sqrt(mean(((sqrt(FH.BOOT) - MCFH) / MCFH)^2)),
      RFH.CCT ~ sqrt(mean(((sqrt(RFH.CCT) - MCRFH) / MCRFH)^2)),
      RFH.BOOT ~ sqrt(mean(((sqrt(RFH.BOOT) - MCRFH) / MCRFH)^2)),
      RFH.BC.CCT ~ sqrt(mean(((sqrt(RFH.BC.CCT) - MCRFH.BC) / MCRFH.BC)^2)),
      RFH.BC.BOOT ~ sqrt(mean(((sqrt(RFH.BC.BOOT) - MCRFH.BC) / MCRFH.BC)^2)),
      id ~ 1,
      by = c("idD")
    ) %>%
    mutar(
      FH.CCT ~ median(FH.CCT),
      FH.BOOT ~ median(FH.BOOT),
      RFH.CCT ~ median(RFH.CCT),
      RFH.BOOT ~ median(RFH.BOOT),
      RFH.BC.CCT ~ median(RFH.BC.CCT),
      RFH.BC.BOOT ~ median(RFH.BC.BOOT),
      by = "id"
    )

  mseMat <- t(as.matrix(mutar(mse, "^.*FH")))
  colnames(mseMat) <- "RRMSE"

  list(bias = biasMat, mse = mseMat)

}

tabRFH <- tableMSE(simData)
tabData <- data.frame(
  Predictor = c("FH", NA, "RFH", NA, "RFH.BC", NA),
  MSPE = c("CCT", "BOOT"),
  RBIAS = tabRFH$bias * 100,
  RRMSE = tabRFH$mse * 100
)
rownames(tabData) <- NULL

dump <- gg$tables$save(
  tabData,
  fileName = "tabs/mse_design.tex",
  caption = "\\label{tab:mse_performace_design}Performance of RMSPE Estimators in Design\\hyp{}Based Simulation. Results are in \\%. \\textit{Regular} denotes non\\hyp{}outlier observations. (0) is the model specific scenario without contamination; (u) is with outlier contamination.",
  caption.lot = "Performance of RMSPE Estimators in Design\\hyp{}Based Simulation"
)






