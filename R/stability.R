# Title: Stability Tests for saeRobust
# Author: Sebastian Warnholz
#
# Intructions:
# Run 00Dependencies.R first. Use 'runs' to reduce the number of iterations. Set
# recompute* to TRUE when the results are not cached. Check cpus for parallel
# computing.

.libPaths("~/R/x86_64-redhat-linux-gnu-library/3.2")
library("modules")
library("saeRobust")
library("saeSim")
library("dat")
library("ggplot2")
library("gridExtra")

theme <- use("R/graphics/themes.R")
table <- use("R/graphics/tables.R")
LOCAL <- identical(commandArgs(TRUE), character(0))

# Cache
recompute <- FALSE
recomputeSpatial <- FALSE
recomputeTemporal <- FALSE
recomputeSpatioTemporal <- FALSE

# Graphic Params
width <- 7
height <- 3
fontSize <- 14
labelParam <- "Parameter Estimate"
labelScore <- "Estimation Equation"

# Simulation Params
domains <- 40
units <- 1
nTime <- 10
sige <- seq(5, 15, length.out = domains)^2
sigv <- 100
runs <- 500
maxIter1 <- 100
maxIter2 <- 1000
maxIterParam <- 100
cpus <- 1 # round(parallel::detectCores() / 2)

mcSettings <- if (LOCAL) {
  list(mode = "multicore", cpus = cpus, mc.preschedule = FALSE)
} else {
  NULL
}

comp <- module({
  # This module exists to handle the dependencies of the model functions
  import("methods")
  import("saeRobust")

  domains <- .GlobalEnv$domains
  nTime <- .GlobalEnv$nTime
  maxIter1 <- .GlobalEnv$maxIter1
  maxIter2 <- .GlobalEnv$maxIter2
  maxIterParam <- .GlobalEnv$maxIterParam

  rbfh <- function(dat) {
    rfh(
      y ~ x, dat, "dirVar",
      maxIter = maxIter1, maxIterParam = maxIter1, maxIterRe = maxIter2
    )
  }

  rsfh <- function(dat) {
    rfh(
      y ~ x, dat, "dirVar", corSAR1(testRook(domains)),
      maxIter = maxIter1, maxIterParam = maxIterParam, maxIterRe = 1
    )
  }

  rtfh <- function(dat) {
    rfh(
      y ~ x, dat, "dirVar", corAR1(nTime),
      maxIter = maxIter1, maxIterParam = maxIterParam, maxIterRe = 1
    )
  }

  rstfh <- function(dat) {
    out <- try({
      rfh(
        y ~ x, dat, "dirVar", corSAR1AR1(W = testRook(domains), nTime = nTime),
        maxIter = maxIter1, maxIterParam = maxIterParam, maxIterRe = 1
      )
    })
    if (inherits(out, "try-error")) dat else out
  }

})

comp_dirVar <- function(dirVar) {
  force(dirVar)
  function(dat) {
    dat$dirVar <- dirVar
    dat
  }
}

gen_extreme_cases <- function(dat) {
  ind <- sample(1:nrow(dat), size = round(nrow(dat) * 0.1))
  dat[ind, "e"] <- 10000
  dat
}

baseData <-
  base_id(domains, units) %>%
  sim_gen_x() %>%
  sim_gen_e(sd = sqrt(sige)) %>%
  sim_gen(comp_dirVar(sige)) %>%
  sim_resp_eq(y = 100 + 10 * x + v + e)

scenarioBase <-
  baseData %>%
  sim_gen_v(sd = sqrt(sigv)) %>%
  sim_comp_agg(comp$rbfh)

scenarioExtreme <-
  scenarioBase %>%
  sim_gen(gen_extreme_cases)

scenarioSpatial <-
  baseData %>%
  sim_gen(gen_v_sar(sd = sqrt(sigv), name = "v")) %>%
  sim_comp_agg(comp$rsfh)

scenarioSpatialExtreme <-
  scenarioSpatial %>%
  sim_gen(gen_extreme_cases)

scenarioTemporal <-
  base_id_temporal(domains, units, nTime) %>%
  sim_gen_x() %>%
  sim_gen_e(sd = sqrt(rep(sige, each = nTime))) %>%
  sim_gen(comp_dirVar(rep(sige, each = nTime))) %>%
  sim_gen(gen_v_ar1(sd = sqrt(sigv), name = "ar")) %>%
  sim_gen_v(sd = sqrt(sigv)) %>%
  sim_resp_eq(y = 100 + 10 * x + v + ar + e) %>%
  sim_comp_agg(comp$rtfh)

scenarioTemporalExtreme <-
  scenarioTemporal %>%
  sim_gen(gen_extreme_cases)

scenarioSpatioTemporal <-
  base_id_temporal(domains, units, nTime) %>%
  sim_gen_x() %>%
  sim_gen_e(sd = sqrt(rep(sige, each = nTime))) %>%
  sim_gen(comp_dirVar(rep(sige, each = nTime))) %>%
  sim_gen(gen_v_ar1(sd = sqrt(sigv), name = "ar")) %>%
  sim_gen(gen_v_sar(sd = sqrt(sigv), name = "v")) %>%
  sim_resp_eq(y = 100 + 10 * x + v + ar + e) %>%
  sim_comp_agg(comp$rstfh)

scenarioSpatioTemporalExtreme <-
  scenarioSpatioTemporal %>%
  sim_gen(gen_extreme_cases)

simFun <- function(scenario, path) {
  path <- paste0("R/data/stability/", path)
  do.call(sim, c(
    list(scenario),
    R = runs,
    path = path,
    overwrite = FALSE, fileExt = ".RData",
    mcSettings)
  )
  sim_read_list(path)
}

# Run simulation
if (recompute) {

  resultsBase <- simFun(scenarioBase, "base")

  save(
    list = "resultsBase",
    file = "R/data/stability/resultsBase.RData",
    compress = TRUE
  )

  resultsExtreme <- simFun(scenarioExtreme, "extreme")

  save(
    list = "resultsExtreme",
    file = "R/data/stability/resultsExtreme.RData",
    compress = TRUE
  )
}

if (recomputeSpatial) {

  resultsSpatial <- simFun(scenarioSpatial, "spatial")

  save(
    list = "resultsSpatial",
    file = "R/data/stability/resultsSpatial.RData",
    compress = TRUE
  )

  resultsSpatialExtreme <- simFun(scenarioSpatialExtreme, "spatialExtreme")

  save(
    list = "resultsSpatialExtreme",
    file = "R/data/stability/resultsSpatialExtreme.RData",
    compress = TRUE
  )
}

if (recomputeTemporal) {

  resultsTemporal <- simFun(scenarioTemporal, "temporal")
  save(
    list = "resultsTemporal",
    file = "R/data/stability/resultsTemporal.RData",
    compress = TRUE
  )

  resultsTemporalExtreme <- simFun(scenarioTemporalExtreme, "temporalExtreme")
  save(
    list = "resultsTemporalExtreme",
    file = "R/data/stability/resultsTemporalExtreme.RData",
    compress = TRUE
  )
}

if (recomputeSpatioTemporal) {

  resultsSpatioTemporal <- simFun(scenarioSpatioTemporal, "spatioTemporal")
  save(
    list = "resultsSpatioTemporal",
    file = "R/data/stability/resultsSpatioTemporal.RData",
    compress = TRUE
  )

  resultsSpatioTemporalExtreme <-
    simFun(scenarioSpatioTemporalExtreme, "spatioTemporalExtreme")
  save(
    list = "resultsSpatioTemporalExtreme",
    file = "R/data/stability/resultsSpatioTemporalExtreme.RData",
    compress = TRUE
  )

}

if (LOCAL) {
  load("R/data/stability/resultsBase.RData")
  load("R/data/stability/resultsExtreme.RData")
  load("R/data/stability/resultsSpatial.RData")
  load("R/data/stability/resultsSpatialExtreme.RData")
  load("R/data/stability/resultsTemporal.RData")
  load("R/data/stability/resultsTemporalExtreme.RData")
  load("R/data/stability/resultsSpatioTemporal.RData")
  load("R/data/stability/resultsSpatioTemporalExtreme.RData")
} else {
  sim_clear_list("R/data/stability/base/")
  sim_clear_list("R/data/stability/extreme/")
  sim_clear_list("R/data/stability/spatial/")
  sim_clear_list("R/data/stability/spatialExtreme/")
  sim_clear_list("R/data/stability/temporal/")
  sim_clear_list("R/data/stability/temporalExtreme/")
  sim_clear_list("R/data/stability/spatioTemporal/")
  sim_clear_list("R/data/stability/spatioTemporalExtreme/")
  q("no")
}

# Make Plots
densPlot <- function(dat, intercept, xlab = NULL, var) {
  ggplot(dat, aes_string(x = var)) +
    geom_density() +
    facet_grid(scenario ~.) +
    geom_vline(xintercept = intercept, linetype = 2, colour = "gray") +
    theme$theme_thesis(fontSize) +
    labs(title = NULL, y = NULL, x = xlab) +
    theme(axis.text.y = element_blank(),
          plot.margin = rep(unit(0,"null"), 4))
}

# Regression Coefficients
coefs1 <-
  map(resultsBase, "coefficients") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(coefs1)[1:2] <- c("Intercept", "Slope")

coefs2 <-
  map(resultsExtreme, "coefficients") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(coefs2)[1:2] <- c("Intercept", "Slope")

coefs <- rbind(coefs1, coefs2)

scores1 <-
  flatmap(resultsBase, score, "beta") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(scores1)[1:2] <- c("Intercept", "Slope")

scores2 <-
  flatmap(resultsExtreme, score, "beta") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(scores2)[1:2] <- c("Intercept", "Slope")

scores <- rbind(scores1, scores2)

g1 <- densPlot(coefs, 100, "Intercept", var = "Intercept") +
  theme(strip.text = element_blank())
g2 <- densPlot(scores, 0, labelScore, var = "Intercept")


cairo_pdf("figs/stability_intercept_base.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2, padding = 0)
dev.off()

g1 <- densPlot(coefs, 10, "Slope", var = "Slope") +
  theme(strip.text = element_blank())
g2 <- densPlot(scores, 0, labelScore, var = "Slope")

cairo_pdf("figs/stability_slope_base.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2)
dev.off()

# Variance Parameters

dat1 <-
  map(resultsBase, "variance") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(dat1)[1] <- c("Variance")

dat2 <-
  map(resultsExtreme, "variance") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(dat2)[1] <- c("Variance")

dat <- rbind(dat1, dat2)

scores1 <-
  flatmap(resultsBase, score, "delta") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(scores1)[1] <- c("Variance")

scores2 <-
  flatmap(resultsExtreme, score, "delta") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(scores2)[1] <- c("Variance")

scores <- rbind(scores1, scores2)

g1 <- densPlot(dat, 100, "Variance", var = "Variance") +
  theme(strip.text = element_blank())
g2 <- ggplot(data.frame(estimate = dat$Variance, score = scores$Variance, scenario = dat$scenario)) +
  geom_point(aes(x = estimate, y = score)) +
  facet_grid(scenario ~ .) +
  theme$theme_thesis(fontSize) +
  labs(x = "Variance", y = labelScore)

cairo_pdf("figs/stability_variance_base.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2, widths = c(0.4 * width, 0.6 * width))
dev.off()

# Random Effects
re1 <-
  map(resultsBase, "re") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  apply(1, median) %>%
  { data.frame(re = .) } %>%
  mutar(scenario ~ "Base")

re2 <-
  map(resultsExtreme, "re") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  apply(1, median) %>%
  { data.frame(re = .) } %>%
  mutar(scenario ~ "Outlier")

re <- rbind(re1, re2)

ggDat <- cbind(dat, re[-2]) # dat should be the variance

g1 <- densPlot(ggDat, 0, "Median Random Effect", "re") +
  theme(strip.text = element_blank())

g2 <- ggplot(ggDat, aes(Variance, re)) +
  geom_smooth(colour = "black") +
  facet_grid(scenario ~ .) +
  theme$theme_thesis(fontSize) +
  labs(y = "Median Random Effect")

# jpeg("figs/stability_random_effect_base.jpg", width = width, height = height,
#      units = "in", quality = 100, res = 150)
cairo_pdf("figs/stability_random_effect_base.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2, widths = c(0.4 * width, 0.6 * width))
dev.off()

# Graphics -- Spatial

dat1 <-
  flatmap(resultsSpatial, "variance") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(dat1)[1:2] <- c("Correlation", "Variance")

dat2 <-
  map(resultsSpatialExtreme, "variance") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(dat2)[1:2] <- c("Correlation", "Variance")

dat <- rbind(dat1, dat2)
dat <- dat %>% mutar(~Variance < 1000)

g1 <- densPlot(dat, 0.5, "Correlation", var = "Correlation")  +
  theme(strip.text = element_blank())
g2 <- densPlot(dat, 100, "Variance", var = "Variance")

cairo_pdf("figs/stability_variance_spatial.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2, widths = c(0.4 * width, 0.6 * width))
dev.off()

set.seed(19) # some value to have a scenario with a 'high number' of iterations
dat <- baseData %>%
  sim_gen(gen_v_sar(sd = sqrt(sigv), name = "v")) %>%
  as.data.frame

out1 <- rfh(y ~ x, dat, "dirVar", corSAR1(testRook(domains)),
           maxIter = 10000, maxIterParam = 1, maxIterRe = 1)

out2 <- rfh(y ~ x, dat, "dirVar", corSAR1(testRook(domains)),
            maxIter = 100, maxIterParam = 100, maxIterRe = 1)

dat1 <- rbind(
  out1$iterations$correlation %>%
    as.data.frame(row.names = FALSE) %>%
    mutar(parameter ~ "Correlation"),
  out1$iterations$variance %>%
    as.data.frame(row.names = FALSE) %>%
    mutar(parameter ~ "Variance")
) %>% mutar(strategy ~ "1 Iter")

dat2 <- rbind(
  out2$iterations$correlation %>%
    as.data.frame(row.names = FALSE) %>%
    mutar(parameter ~ "Correlation"),
  out2$iterations$variance %>%
    as.data.frame(row.names = FALSE) %>%
    mutar(parameter ~ "Variance")
) %>% mutar(strategy ~ "100 Iter")

iterations1 <- flatmap(dat1, df ~ nrow(df), by = "parameter", combine = unlist)
iterations2 <- flatmap(dat2, df ~ nrow(df), by = "parameter", combine = unlist)

dat2 <- flatmap(dat2, df ~ df[nrow(df), ], by = c("i", "parameter"))

dat <- rbind(dat1, dat2)
dat$parameter <- factor(
  dat$parameter, levels = c("Variance", "Correlation"), ordered = TRUE
)

cairo_pdf("figs/stability_convergence_spatial.pdf", width, 1.7 * height)
ggplot(dat, aes(x = i, y = V1)) +
  geom_line() +
  facet_grid(parameter ~ strategy, scales = "free_y") +
  theme$theme_thesis(14) +
  labs(x = "Iteration", y = labelParam) +
  coord_cartesian(xlim = c(0, 100))
dev.off()


# Graphics Temporal

dat1 <-
  flatmap(resultsTemporal, "variance") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(dat1)[1:3] <- c("Correlation", "Variance1", "Variance2")

dat2 <-
  map(resultsTemporalExtreme, "variance") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(dat2)[1:3] <- c("Correlation", "Variance1", "Variance2")

dat <- rbind(dat1, dat2)
dat <- dat %>% mutar(~ Variance1 < 1000)

g1 <- densPlot(dat, 0.5, "CorrelationAR", var = "Correlation") +
  theme(strip.text = element_blank())
g2 <- densPlot(dat, 100, "VarianceAR", var = "Variance2") +
  theme(strip.text = element_blank())
g3 <- densPlot(dat, 100, "Variance1", var = "Variance1")


cairo_pdf("figs/stability_variance_temporal.pdf", width, 1.7 * height)
grid.arrange(g1, g2, g3, ncol = 3, widths = c(0.3 * width, 0.3 * width, 0.4 * width))
dev.off()

# Graphics Spatio-Temporal

dat1 <-
  flatmap(resultsSpatioTemporal, "variance") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")

dat2 <-
  map(resultsSpatioTemporalExtreme, "variance") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")

dat <- rbind(dat1, dat2)

dat <- dat %>% mutar(~ varianceAR < 1000)

g1 <- densPlot(dat, 0.5, "CorrelationSAR", var = "SAR")  +
  theme(strip.text = element_blank()) + scale_x_continuous(breaks = c(0, 0.5))
g2 <- densPlot(dat, 100, "VarianceSAR", var = "varianceSAR")  +
  theme(strip.text = element_blank()) + scale_x_continuous(breaks = c(100, 200))
g3 <- densPlot(dat, 0.5, "CorrelationAR", var = "AR") +
  theme(strip.text = element_blank()) + scale_x_continuous(breaks = c(0, 0.5))
g4 <- densPlot(dat, 100, "VarianceAR", var = "varianceAR") +
  scale_x_continuous(breaks = c(100, 300))

cairo_pdf("figs/stability_variance_spatio_temporal.pdf", 1.1 * width, 1.7 * height)
grid.arrange(g1, g2, g3, g4, ncol = 4, widths = c(0.25 * width, 0.25 * width, 0.25 * width, 0.35 * width))
dev.off()


# Random Effects Convergence

pos <- which.max(flatmap(resultsExtreme, ~ nrow(.$iterations$re)))
copy <- model <- resultsExtreme[[pos]]
scores <- model$iterations$re

for (i in 1:nrow(model$iterations$re)) {
  copy$re <-  model$iterations$re[i, 1:domains]
  scores[i, 1:domains] <- score(copy, "re")$re
}

colnames(scores)[1:domains] <- 1:domains
ggDat <- tidyr::gather(as.data.frame(scores), domain, score, -i)
g1 <- ggplot(mutar(ggDat, ~ i <= 10) , aes(x = i, y = score, group = domain)) +
  geom_line() + labs(x = "Iteration", y = labelScore) + theme$theme_thesis(14) +
  scale_x_continuous(breaks = c(1, 5, 10)) +
  theme(plot.margin = rep(unit(0,"null"), 4))

ggDat <- tidyr::gather(as.data.frame(model$iterations$re), domain, param, -i)
g2 <- ggplot(mutar(ggDat, ~ i <= 10) , aes(x = i, y = param, group = domain)) +
  geom_line() + labs(x = "Iteration", y = labelParam) + theme$theme_thesis(14) +
  scale_x_continuous(breaks = c(1, 5, 10)) +
  theme(plot.margin = rep(unit(0,"null"), 4))

cairo_pdf("figs/stability_convergence_random_effects.pdf", width, height)
grid.arrange(g1, g2, ncol = 2, widths = c(0.5 * width, 0.5 * width))
dev.off()


# Tables --- FH
tableOrder <- c("row", "Scenario", "First", "Second", "Remaining", "Max", "Converged")

makeTable <- function(result1, result2, name1, name2) {

  iterList <- map(name1, n ~ rbind(
    extractIterations(result1, n, "Base"),
    extractIterations(result2, n, "Outlier")
  ))

  overall <- iterList[[1]] %>%
    mutar(
      row ~ name2[1],
      First ~ NA_real_,
      Second ~ NA_real_,
      Remaining ~ median(i),
      Max ~ max(i),
      Converged ~ (runs - sum(i == maxIter1)) / runs,
      by = "Scenario"
    )

  tabs <- map(ML(iterList, name2[-1]), f(iter, n) ~ {
    iter %>%
      mutar(
        row ~ n,
        First ~ median(iterations[i == 1]),
        Second ~ median(iterations[i == 2]),
        Remaining ~ median(iterations[i > 2]),
        Max ~ max(iterations),
        Converged ~ NA_real_,
        by = "Scenario"
      )
  })

  tab <- do.call(rbind, c(list(overall), tabs))[tableOrder]
  tab[((1:nrow(tab)) %% 2) == 0, "row"] <- NA
  tab
}

extractIterations <- function(resultList, type, identifier) {
  flatmap(resultList, "iterations") %>%
    flatmap(type) %>%
    map(~{rownames(.) <- NULL; .}) %>%
    map(as.data.frame) %>%
    magrittr::set_names(NULL) %>%
    bindRows(id = "R") %>%
    mutar(Scenario ~ identifier) %>%
    mutar(iterations ~ n(), by = c("R", "i", "Scenario"))
}

coefTab <- makeTable(
  resultsBase, resultsExtreme,
  c("coefficients", "variance"),
  c("Overall", "- Coefficients", "- Variance")
)

iterRe <- rbind(
  extractIterations(resultsBase, "re", "Base"),
  extractIterations(resultsExtreme, "re", "Outlier")
)

re <- iterRe %>%
  mutar(
    row ~ "Random Effect",
    First ~ NA_real_,
    Second ~ NA_real_,
    Remaining ~ median(i),
    Max ~ max(i),
    Converged ~ (runs - sum(i == maxIter2)) / runs,
    by = "Scenario"
  )

tableDat <- rbind(coefTab, re)
tableDat[c(8), "row"] <- NA


tab <- table$saveResize(
  tableDat,
  "tabs/stability_fh.tex",
  label = "tab:stability_fh",
  colheads = c("", names(tableDat)[-1]),
  caption = "\\label{tab:stability_fh}Median Number of Iterations in Optimisation until Convergence Was Reached. The columns \\textit{converged} contains the relative frequency of runs in which the stopping rule was reached before the maximum number of iterations.",
  caption.lot = "Median Number of Iterations in Optimisation -- RFH"
)


### Tables - Remaining Models

tabSpatial <- makeTable(
  resultsSpatial, resultsSpatialExtreme,
  c("correlation", "variance"),
  c("SFH - Overall", "- CorSAR", "- VarSAR")
)

# Temporal
tabTemporal <- makeTable(
  resultsTemporal, resultsTemporalExtreme,
  c("correlation", "variance"),
  c("TFH - Overall", " - CorAR", " - Variances")
)

# Spatio - Temporal
tabSpatioTemporal <- makeTable(
  resultsSpatioTemporal, resultsSpatioTemporalExtreme,
  c("SAR", "AR", "variance"),
  c("STFH - Overall", " - CorSAR", " - CorAR", " - Variances")
)

tableDat <- rbind(tabSpatial, tabTemporal, tabSpatioTemporal)

tab <- table$saveResize(
  tableDat,
  "tabs/stability_all_fh.tex",
  where = "t",
  label = "tab:stability_all_fh",
  colheads = c("", names(tableDat)[-1]),
  caption = "\\label{tab:stability_all_fh}Median Number of Iterations in Optimisation until Convergence Was Reached. The columns \\textit{converged} contains the relative frequency of runs in which the stopping rule was reached before the maximum number of iterations.",
  caption.lot = "Median Number of Iterations in Optimisation -- Extensions"
)



