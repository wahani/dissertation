library("saeSim")
library("dat")
modules::import(magrittr, "%<>%")

gen <- modules::use("./R/generators/")
comp <- modules::use("./R/comp")
gg <- modules::use("./R/graphics")


# Constants:
D <- 100
Ud <- 1000
S <- round(seq(5, 15, length.out = D))

setup <- base_id(D, Ud) %>%
  # Population
  sim_gen_e(sd = 4) %>%
  sim_gen_v(sd = 1) %>%
  sim_gen_generic(gen$x$fixed_sequence, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 10 * x + v + e) %>%
  sim_comp_N %>%
  sim_comp_popMean %>%
  # Sample
  sim_sample(sample_numbers(S, groupVars = "idD")) %>%
  sim_comp_n

setup %<>%
  comp$direct$sim_comp_sampleMean() %>%
  sim_comp_sample(comp$direct$global_var) %>%
  sim_comp_sample(comp_var(sMGVF = globalVar / n)) %>%
  sim_comp_sample(comp$direct$robust_mean, "idD") %>%
  sim_agg

setup %<>%
  sim_comp_agg(comp$area$fh("sMean", "sMVar", "FH")) %>%
  sim_comp_agg(comp$area$fh("sMean", "sMGVF", "FHGVF")) %>%
  sim_comp_agg(comp$area$fh("rMean", "rMVar", "FHRMean")) %>%
  sim_comp_agg(comp$area$fh("mMean", "rMVar", "FHMMean")) %>%
  sim_comp_agg(comp$area$rfh("sMean", "sMVar", "RFH")) %>%
  sim_comp_agg(comp$area$rfh("sMean", "sMGVF", "RFHGVF")) %>%
  sim_comp_agg(comp$area$rfh("rMean", "rMVar", "RFHRMean")) %>%
  sim_comp_agg(comp$area$rfh("mMean", "rMVar", "RFHMMean"))

setup <- setup %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0, 0)")

setupE <- setup %>%
  sim_gen_ec(sd = 150, areaVar = "idD",
             nCont = c(rep(0, 90), rep(0.5, 5), rep(0, 5))) %>%
  sim_simName("(0, e)")

setupV <- setup %>%
  sim_gen_vc(sd = 20, fixed = TRUE) %>%
  sim_simName("(v, 0)")

simFun <- . %>%
  sim(500, mode = "multicore", cpus = 3, path = "./R/data/fromUnitToAreaLevel", overwrite = FALSE) %>%
  do.call(what = rbind)

lapply(list(setup, setupE, setupV), simFun)

simData <- sim_read_data("./R/data/fromUnitToAreaLevel") %>%
  mutar(c("idD", "popMean", "simName", "sMean", "rMean", "FH", "FHGVF",
          "FHRMean", "RFH", "RFHGVF", "RFHRMean"))

ggDat <- tidyr::gather(
  simData,
  method, prediction,
  -idD, -popMean, -simName
)

ggDat %<>% mutar(RBIAS ~ mean((prediction - popMean) / popMean),
                 RRMSE ~ sqrt(mean(((prediction - popMean) / popMean)^2)),
                 by = c("idD", "method", "simName"))

unit_to_area_level_mc_rrmse_00 <- gg$plots$mse(subset(ggDat, simName == "(0, 0)"))
unit_to_area_level_mc_rrmse_0e <- gg$plots$mse(subset(ggDat, simName == "(0, e)"))
unit_to_area_level_mc_rrmse_v0 <- gg$plots$mse(subset(ggDat, simName == "(v, 0)")) + ggplot2::scale_y_log10()

unit_to_area_level_mc_rbias_00 <- gg$plots$bias(subset(ggDat, simName == "(0, 0)"))
unit_to_area_level_mc_rbias_0e <- gg$plots$bias(subset(ggDat, simName == "(0, e)"))
unit_to_area_level_mc_rbias_v0 <- gg$plots$bias(subset(ggDat, simName == "(v, 0)"))

unit_to_area_level_mc_rrmse_all <- gg$plots$mse(ggDat) + ggplot2::scale_y_log10()
unit_to_area_level_mc_rbias_all <- gg$plots$bias(ggDat)

gg$save$default(unit_to_area_level_mc_rrmse_00)
gg$save$default(unit_to_area_level_mc_rrmse_0e)
gg$save$default(unit_to_area_level_mc_rrmse_v0)

gg$save$default(unit_to_area_level_mc_rbias_00)
gg$save$default(unit_to_area_level_mc_rbias_0e)
gg$save$default(unit_to_area_level_mc_rbias_v0)

gg$save$default(unit_to_area_level_mc_rrmse_all, height = 5)
gg$save$default(unit_to_area_level_mc_rbias_all, height = 5)
