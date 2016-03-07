library("modules")
library("saeRobust")
library("saeSim")
library("dat")
library("ggplot2")
library("gridExtra")

theme <- use("R/graphics/themes.R")
table <- use("R/graphics/tables.R")

# Cache
recompute <- FALSE
recomputeSpatial <- FALSE

# Graphic Params
width <- 7
height <- 3
fontSize <- 14
labelParam <- "Parameter Estimate"
labelScore <- "Estimation Equation"

# Simulation Params
domains <- 40
units <- 1
sige <- seq(5, 15, length.out = domains)^2
sigv <- 100
runs <- 200
maxIter1 <- 100
maxIter2 <- 1000
maxIterParam <- 5
cpus <- parallel::detectCores() - 1

# The Simulation Config
comp_rfh <- function(dat) {
  rfh(y ~ x, dat, "dirVar", maxIter = maxIter1, maxIterParam = maxIter1, maxIterRe = maxIter2)
}

comp_rsfh <- function(dat) {
  rfh(y ~ x, dat, "dirVar", corSAR1(testRook(domains)),
      maxIter = maxIter1, maxIterParam = maxIterParam, maxIterRe = 1)
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
  sim_gen(comp_var(dirVar = sige)) %>%
  sim_resp_eq(y = 100 + 10 * x + v + e)

scenarioBase <-
  baseData %>%
  sim_gen_v(sd = sqrt(sigv)) %>%
  sim_comp_agg(comp_rfh)

scenarioExtreme <-
  scenarioBase %>%
  sim_gen(gen_extreme_cases)

scenarioSpatial <-
  baseData %>%
  sim_gen(gen_v_sar(sd = sqrt(sigv), name = "v")) %>%
  sim_comp_agg(comp_rsfh)

scenarioSpatialExtreme <-
  scenarioSpatial %>%
  sim_gen(gen_extreme_cases)

# Run simulation
if (recompute) {
  set.seed(15)
  resultsBase <-
    scenarioBase %>%
    sim(runs, mode = "multicore", cpus = cpus, mc.preschedule = FALSE)
  save(list = "resultsBase", file = "R/data/stability/resultsBase.RData")

  resultsExtreme <-
    scenarioExtreme %>%
    sim(runs, mode = "multicore", cpus = cpus, mc.preschedule = FALSE)
  save(list = "resultsExtreme", file = "R/data/stability/resultsExtreme.RData")
} else {
  load("R/data/stability/resultsBase.RData")
  load("R/data/stability/resultsExtreme.RData")
}

if (recomputeSpatial) {
  set.seed(15)
  resultsSpatial <-
    scenarioSpatial %>%
    sim(runs, mode = "multicore", cpus = cpus, mc.preschedule = FALSE)
  save(list = "resultsSpatial", file = "R/data/stability/resultsSpatial.RData")

  resultsSpatialExtreme <-
    scenarioSpatialExtreme %>%
    sim(runs, mode = "multicore", cpus = cpus, mc.preschedule = FALSE)
  save(list = "resultsSpatialExtreme", file = "R/data/stability/resultsSpatialExtreme.RData")
} else {
  load("R/data/stability/resultsSpatial.RData")
  load("R/data/stability/resultsSpatialExtreme.RData")
}


# Make Plots
densPlot <- function(dat, intercept, xlab = NULL, var) {
  ggplot(dat, aes_string(x = var)) +
    geom_density() +
    facet_grid(scenario ~.) +
    geom_vline(xintercept = intercept, linetype = 2, colour = "gray") +
    theme$theme_thesis(fontSize) +
    labs(title = NULL, y = NULL, x = xlab) +
    theme(axis.text.y = element_blank())
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

g1 <- densPlot(coefs, 100, labelParam, var = "Intercept") + theme(strip.text = element_blank())
g2 <- densPlot(scores, 0, labelScore, var = "Intercept")

cairo_pdf("figs/stability_intercept_base.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2)
dev.off()

g1 <- densPlot(coefs, 10, labelParam, var = "Slope") + theme(strip.text = element_blank())
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

g1 <- densPlot(dat, 100, "Parameter Estimate", var = "Variance") + theme(strip.text = element_blank())
g2 <- ggplot(data.frame(estimate = dat$Variance, score = scores$Variance, scenario = dat$scenario)) +
  geom_point(aes(x = estimate, y = score)) +
  facet_grid(scenario ~ .) +
  theme$theme_thesis(fontSize) +
  labs(x = labelParam, y = labelScore)

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

# jpeg("figs/stability_random_effect_base.jpg", width = width, height = height,
#      units = "in", quality = 100, res = 150)
cairo_pdf("figs/stability_random_effect_base.pdf", width, height)
ggplot(ggDat, aes(Variance, re)) +
  geom_point() +
  facet_grid(. ~ scenario) +
  theme$theme_thesis(fontSize) +
  labs(y = "Median Random Effect")
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
           maxIter = 100, maxIterParam = 1, maxIterRe = 1)

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
  labs(x = "Iteration", y = labelParam)
dev.off()


# Tables --- FH
extractIterations <- function(resultList, type, identifier) {
  flatmap(resultList, "iterations") %>%
    flatmap(type) %>%
    map(~{rownames(.) <- NULL; .}) %>%
    map(as.data.frame) %>%
    magrittr::set_names(NULL) %>%
    bindRows(id = "R") %>%
    mutar(scenario ~ identifier) %>%
    mutar(iterations ~ n(), by = c("R", "i", "scenario"))
}

iterCoefs <- rbind(
  extractIterations(resultsBase, "coefficients", "Base"),
  extractIterations(resultsExtreme, "coefficients", "Outlier")
)

iterSigma <- rbind(
  extractIterations(resultsBase, "variance", "Base"),
  extractIterations(resultsExtreme, "variance", "Outlier")
)

iterRe <- rbind(
  extractIterations(resultsBase, "re", "Base"),
  extractIterations(resultsExtreme, "re", "Outlier")
)

overall <-
  iterCoefs %>%
  mutar(
    row ~ "Overall",
    first ~ NA_real_,
    second ~ NA_real_,
    remaining ~ median(i),
    max ~ max(i),
    converged ~ (runs - sum(i == maxIter1)) / runs,
    by = "scenario"
  )

beta <- iterCoefs %>%
  mutar(
    row ~ "- Beta",
    first ~ median(iterations[i == 1]),
    second ~ median(iterations[i == 2]),
    remaining ~ median(iterations[i > 2]),
    max ~ max(iterations),
    converged ~ (runs - sum(i == maxIter1)) / runs,
    by = "scenario"
  )

sigma <- iterSigma %>%
  mutar(
    row ~ "- Sigma",
    first ~ median(iterations[i == 1]),
    second ~ median(iterations[i == 2]),
    remaining ~ median(iterations[i > 2]),
    max ~ max(iterations),
    converged ~ (runs - sum(i == maxIter1)) / runs,
    by = "scenario"
  )

re <- iterRe %>%
  mutar(
    row ~ "Random Effect",
    first ~ NA_real_,
    second ~ NA_real_,
    remaining ~ median(i),
    max ~ max(i),
    converged ~ (runs - sum(i == maxIter2)) / runs,
    by = "scenario"
  )

tableDat <- rbind(overall, beta, sigma, re) %>%
  mutar(scenario ~ factor(scenario, c("Base", "Outlier"), ordered = TRUE),
        row ~ factor(row, c("Overall", "- Beta", "- Sigma", "Random Effect"), ordered = TRUE)) %>%
  mutar(~order(row, scenario))
row.names(tableDat) <- NULL
tableDat[c(2, 4, 6, 8), "row"] <- NA
tableDat <- tableDat[c("row", "scenario", "first", "second", "remaining", "max", "converged")]

tab <- table$saveResize(
  tableDat,
  "tabs/stability_fh.tex",
  label = "tab:stability_fh",
  colheads = c("", names(tableDat)[-1]),
  caption = "Number of Iterations in Optimisation. Base vs. Deterministic Outlier Scenario."
)


### Tables - Remaining Models

iterSpatialCorrelation <- rbind(
  extractIterations(resultsSpatial, "correlation", "Base"),
  extractIterations(resultsSpatial, "correlation", "Outlier")
)

overallSpatial <-
  iterSpatialCorrelation %>%
  mutar(
    row ~ "Spatial",
    first ~ NA_real_,
    second ~ NA_real_,
    remaining ~ median(i),
    max ~ max(i),
    converged ~ (runs - sum(i == maxIter1)) / runs,
    by = "scenario"
  )






