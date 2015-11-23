module::import("saeSim")
module::use("R/generators/gen_x.R")
module::use("R/comp/direct_estimators.R")
module::use("R/comp/area_level.R")

# Constants:
D <- 100
Ud <- 1
trueVar <- seq(1, 3.2, length.out = D)

setup <- base_id(D, Ud) %>%
  # Area-Level Data
  sim_gen_e(sd = sqrt(trueVar)) %>%
  sim_gen_v(sd = 1) %>%
  sim_gen_generic(gen_x, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 10 * x + v + e) %>%
  sim_comp_agg(comp_var(trueVar = trueVar))

setup %<>%
  sim_comp_agg(comp_fh("y", "trueVar", "FH")) %>%
  sim_comp_agg(comp_rfh("y", "trueVar", "RFH"))

setup <- setup %>%
  sim_agg(function(dat) { dat$idC <- FALSE; dat }) %>%
  sim_simName("(0, 0)")

setupV <- setup %>%
  sim_gen_vc(sd = 20, fixed = TRUE) %>%
  sim_simName("(v, 0)")

simFun <- . %>%
  sim(500, mode = "multicore", cpus = 3, path = "./R/data/areaLevel", overwrite = FALSE) %>%
  do.call(what = rbind)

lapply(list(setup, setupV), simFun)
