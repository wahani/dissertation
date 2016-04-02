library("saeSim")
library("dat")
modules::import(magrittr, "%<>%")

gen <- modules::use("./R/generators/")
comp <- modules::use("./R/comp")
gg <- modules::use("./R/graphics")

LOCAL <- identical(commandArgs(TRUE), character(0))

# Constants:
D <- 40
Ud <- 1000
S <- round(seq(5, 15, length.out = D))
sige <- 32
sigre <- 4
runs <- 500

simFun <- if (LOCAL) {
  . %>% sim(
    runs, mode = "multicore", cpus = parallel::detectCores() - 2,
    path = "./R/data/fromUnitToAreaLevel", overwrite = FALSE
  )
} else {
  . %>% sim(runs, path = "./R/data/fromUnitToAreaLevel", overwrite = FALSE)
}

setup <- base_id(D, Ud) %>%
  # Population
  sim_gen_e(sd = sqrt(sige)) %>%
  sim_gen_v(sd = sqrt(sigre)) %>%
  sim_gen_generic(gen$x$fixed_sequence, groupVars = "idD", name = "x") %>%
  sim_resp_eq(y = 100 + 5 * x + v + e) %>%
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
  sim_gen_ec(
    mean = 20,
    sd = sqrt(200),
    areaVar = "idD",
    nCont = replace(rep(0, 40), c(4, 14, 24, 34), 0.2)
  ) %>%
  sim_simName("(0, e)")

setupU <- setup %>%
  sim_gen_vc(mean = 9, sd = 5, nCont = c(5, 15, 25, 35), fixed = TRUE) %>%
  sim_simName("(u, 0)")

setupUE <- setup %>%
  sim_gen_ec(
    mean = 20,
    sd = sqrt(200),
    areaVar = "idD",
    nCont = replace(rep(0, 40), c(4, 14, 24, 34), 0.2)
  ) %>%
  sim_gen_vc(mean = 9, sd = 5, nCont = c(5, 15, 25, 35), fixed = TRUE) %>%
  sim_simName("(u, e)")

lapply(list(setup, setupE, setupU, setupUE), simFun)

sim_clear_data("./R/data/fromUnitToAreaLevel")

if (!LOCAL) q("no")

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

gg$plots$mse(ggDat)
gg$plots$bias(ggDat)
