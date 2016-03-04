library("modules")
library("saeRobustTools")
library("saeSim")
library("dat")
library("ggplot2")
library("gridExtra")

theme <- use("R/graphics/themes.R")
table <- use("R/graphics/tables.R")
recompute <- FALSE

# Graphic Params
width <- 7
height <- 3
fontSize <- 14
paramLabel <- "Parameter Estimate"
scoreLabel <- "Estimation Equation"

# Simulation Params
domains <- 40
units <- 1
sige <- seq(5, 15, length.out = domains)^2
sigv <- 100
runs <- 200
maxIter1 <- 100
maxIter2 <- 1000
cpus <- 3

# The Simulation Config
comp_rfh <- function(dat) {
  rfh(y ~ x, dat, "dirVar", maxIter = maxIter1, maxIterRe = maxIter2)
}

gen_extreme_cases <- function(dat) {
  ind <- sample(1:nrow(dat), size = round(nrow(dat) * 0.1))
  dat[ind, "e"] <- 10000
  dat
}

baseScenario <-
  base_id(domains, units) %>%
  sim_gen_x() %>%
  sim_gen_v(sd = sqrt(sigv)) %>%
  sim_gen_e(sd = sqrt(sige)) %>%
  sim_gen(comp_var(dirVar = sige)) %>%
  sim_resp_eq(y = 100 + 10 * x + v + e) %>%
  sim_comp_agg(comp_rfh)

extremeScenario <-
  baseScenario %>%
  sim_gen(gen_extreme_cases)

# Run simulation
if (recompute) {
  set.seed(15)
  baseResults <-
    baseScenario %>%
    sim(runs, mode = "multicore", cpus = cpus, mc.preschedule = FALSE)
  save(list = "baseResults", file = "R/data/stability/baseResults.RData")

  extremeResults <-
    extremeScenario %>%
    sim(runs, mode = "multicore", cpus = cpus, mc.preschedule = FALSE)
  save(list = "extremeResults", file = "R/data/stability/extremeResults.RData")
} else {
  load("R/data/stability/baseResults.RData")
  load("R/data/stability/extremeResults.RData")
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
  map(baseResults, "coefficients") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(coefs1)[1:2] <- c("Intercept", "Slope")

coefs2 <-
  map(extremeResults, "coefficients") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(coefs2)[1:2] <- c("Intercept", "Slope")

coefs <- rbind(coefs1, coefs2)

scores1 <-
  flatmap(baseResults, score, "beta") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(scores1)[1:2] <- c("Intercept", "Slope")

scores2 <-
  flatmap(extremeResults, score, "beta") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(scores2)[1:2] <- c("Intercept", "Slope")

scores <- rbind(scores1, scores2)

g1 <- densPlot(coefs, 100, paramLabel, var = "Intercept") + theme(strip.text = element_blank())
g2 <- densPlot(scores, 0, scoreLabel, var = "Intercept")

cairo_pdf("figs/stability_intercept_base.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2)
dev.off()

g1 <- densPlot(coefs, 10, paramLabel, var = "Slope") + theme(strip.text = element_blank())
g2 <- densPlot(scores, 0, scoreLabel, var = "Slope")

cairo_pdf("figs/stability_slope_base.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2)
dev.off()

# Variance Parameters

dat1 <-
  map(baseResults, "variance") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(dat1)[1] <- c("Variance")

dat2 <-
  map(extremeResults, "variance") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Outlier")
names(dat2)[1] <- c("Variance")

dat <- rbind(dat1, dat2)

scores1 <-
  flatmap(baseResults, score, "delta") %>%
  do.call(what = rbind) %>%
  as.data.frame(row.names = FALSE) %>%
  mutar(scenario ~ "Base")
names(scores1)[1] <- c("Variance")

scores2 <-
  flatmap(extremeResults, score, "delta") %>%
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
  labs(x = paramLabel, y = scoreLabel)

cairo_pdf("figs/stability_variance_base.pdf", width, 1.7 * height)
grid.arrange(g1, g2, ncol = 2, widths = c(0.4 * width, 0.6 * width))
dev.off()

# Random Effects
re1 <-
  map(baseResults, "re") %>%
  unlist(recursive = FALSE) %>%
  do.call(what = rbind) %>%
  apply(1, median) %>%
  { data.frame(re = .) } %>%
  mutar(scenario ~ "Base")

re2 <-
  map(extremeResults, "re") %>%
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



# Tables
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
  extractIterations(baseResults, "coefficients", "Base"),
  extractIterations(extremeResults, "coefficients", "Outlier")
)

iterSigma <- rbind(
  extractIterations(baseResults, "variance", "Base"),
  extractIterations(extremeResults, "variance", "Outlier")
)

iterRe <- rbind(
  extractIterations(baseResults, "re", "Base"),
  extractIterations(extremeResults, "re", "Outlier")
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
