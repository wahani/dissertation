module::import("saeSim")
module::use("R/generators/gen_x.R")
module::use("R/comp/direct_estimators.R")
module::use("R/comp/area_level.R")

# Constants:
D <- 100
Ud <- 1000
S <- round(seq(5, 15, length.out = D))

setup <- base_id(D, Ud) %>%
  # Population
  sim_gen_e(sd = 4) %>%
  sim_gen_v(sd = 1) %>%
  sim_gen_generic(gen_x, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 10 * x + v + e) %>%
  sim_comp_N %>%
  sim_comp_popMean %>%
  # Sample
  sim_sample(sample_numbers(S, groupVars = "idD")) %>%
  sim_comp_n

setup %<>%
  sim_comp_sampleMean %>%
  sim_comp_sample(comp_globalVar) %>%
  sim_comp_sample(comp_var(sMGVF = globalVar / n)) %>%
  sim_comp_sample(comp_robustMean, "idD") %>%
  sim_agg

setup %<>%
  sim_comp_agg(comp_fh("sMean", "sMVar", "FH")) %>%
  sim_comp_agg(comp_fh("sMean", "sMGVF", "FHGVF")) %>%
  sim_comp_agg(comp_fh("rMean", "rMVar", "FHRMean")) %>%
  sim_comp_agg(comp_fh("mMean", "rMVar", "FHMMean")) %>%
  sim_comp_agg(comp_rfh("sMean", "sMVar", "RFH")) %>%
  sim_comp_agg(comp_rfh("sMean", "sMGVF", "RFHGVF")) %>%
  sim_comp_agg(comp_rfh("rMean", "rMVar", "RFHRMean")) %>%
  sim_comp_agg(comp_rfh("mMean", "rMVar", "RFHMMean"))

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
