# devtools::install_github("wahani/dat")
library("dat")
library("saeSim")
library("saeRobust")
library("ggplot2")

comp <- modules::use("R/comp")
gg <- modules::use("R/graphics/")

D <- 40
ssd <- sqrt(seq(16, 16, length.out = D))

makeSim <- function(D, ssd, vsd) {
  base_id(D, 1) %>%
    sim_gen_x() %>%
    as.data.frame() %>%
    sim_gen_v(sd = vsd) %>%
    sim_gen_e(sd = ssd) %>%
    sim_comp_pop(function(dat) {dat$samplingVar <- ssd^2; dat}) %>%
    sim_resp_eq(y = 100 + 2 * x + v + e, trueVal = 100 + 2 * x + v) %>%
    sim_comp_agg(comp$area$rfh_mse("y", "samplingVar")) %>%
    sim_simName(paste0(vsd, "-4"))
}

startSim <- function(setup) {
  sim(setup, 30, mode = "multicore", cpus = 3,
      path = "R/data/areaLevelMSE", overwrite = FALSE)
}

map(4, ~ makeSim(D, ssd, .)) %>% map(startSim)

simDat <- sim_read_data("R/data/areaLevelMSE/")

# ggplot(simDat, aes(x = rfh, y = trueVal)) + geom_point()

ggDat <- simDat %>%
  mutar(MCRFH ~ mean((rfh - mean(trueVal))^2),
        PseudoRFH ~ mean(rfhPseudoMse),
        BootRFH ~ mean(rfhBootMse),
        by = c("idD", "simName")) %>%
  tidyr::gather(estimator, mse, -idD, -simName)

areaLevelMse <- ggplot(ggDat, aes(x = idD, y = mse, colour = estimator)) +
  geom_line() + facet_wrap(~simName, ncol = 4) + gg$themes$theme_thesis_nogrid()

gg$save$default(areaLevelMse)

# ggplot(ggDat, aes(x = mse, fill = estimator)) +
#   geom_density(alpha = 0.2) +
#   facet_wrap(~simName, ncol = 4)

ggDat <- simDat %>%
  map(mutar, By(c("idD", "simName")), MCRFH ~ mean((rfh - mean(trueVal))^2)) %>%
  mutar(RBIAS ~ mean((rfhPseudoMse - MCRFH) / MCRFH),
        RRMSE ~ sqrt(mean(((rfhPseudoMse - MCRFH) / MCRFH)^2)),
        RBIASBoot ~ mean((rfhBootMse - MCRFH) / MCRFH),
        RRMSEBoot ~ sqrt(mean(((rfhBootMse - MCRFH) / MCRFH)^2)),
        by = c("idD", "simName")) %>%
  tidyr::gather(estimator, mse, -idD, -simName) %>%
  mutar(m ~ mean(mse), by = c("estimator", "simName"))
