library("modules")
library("saeRobustTools")
library("saeSim")
library("dat")
library("ggplot2")
library("gridExtra")

theme <- use("R/graphics/themes.R")
recompute <- FALSE

# Graphic Params
width <- 7 #
height <- 3 #
fontSize <- 14
paramLabel <- "Parameter Estimate"
scoreLabel <- "Estimation Equation"

# Simulation Params
domains <- 40
units <- 1
sige <- seq(5, 15, length.out = domains)^2

# The Simulation Config
comp_rfh <- function(dat) {
  rfh(y ~ x, dat, "dirVar", maxIterRe = 1000, tol = 1e-07)
}

gen_extreme_cases <- function(dat) {
  ind <- sample(1:nrow(dat), size = round(nrow(dat) * 0.1))
  dat[ind, "e"] <- 10000
  dat
}

baseScenario <-
  base_id(domains, units) %>%
  sim_gen_x() %>%
  sim_gen_v(sd = 10) %>%
  sim_gen_e(sd = sqrt(sige)) %>%
  sim_gen(comp_var(dirVar = sige)) %>%
  sim_resp_eq(y = 100 + 10 * x + v + e) %>%
  sim_comp_agg(comp_rfh)

extremeScenario <-
  baseScenario %>%
  sim_gen(gen_extreme_cases)

# Run simulation
if (recompute) {
  baseResults <-
    baseScenario %>%
    sim(200, mode = "multicore", cpus = 6, mc.preschedule = FALSE)
  save(list = "baseResults", file = "R/data/stability/baseResults.RData")

  extremeResults <-
    extremeScenario %>%
    sim(200, mode = "multicore", cpus = 6, mc.preschedule = FALSE)
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

