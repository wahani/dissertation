# Title: Model based simulation. From Unit to Area Level
# Author: Sebastian Warnholz
#
# Intructions:
# Run 00Dependencies.R first. Use 'runs' to reduce the number of iterations. Set
# recompute* to TRUE when the results are not cached. Check cpus for parallel
# computing.

.libPaths("~/R/x86_64-redhat-linux-gnu-library/3.2")
library("saeSim")
library("dat")
library("ggplot2")
modules::import(gridExtra, grid.arrange)
modules::import(magrittr, "%<>%")

gen <- modules::use("./R/generators/")
comp <- modules::use("./R/comp")
gg <- modules::use("./R/graphics")

LOCAL <- identical(commandArgs(TRUE), character(0))

# Cache
rerun <- TRUE

# Graphic Params
width <- 7
height <- 3
fontSize <- 14

# Constants:
D <- 40
Ud <- 1000
S <- round(seq(5, 15, length.out = D))
sige <- 32
sigre <- 2
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
  sim_comp_agg(comp$area$rfh("sMean", "sMVar", "RFH")) %>%
  sim_comp_agg(comp$area$rfh("sMean", "sMGVF", "RFHGVF")) %>%
  sim_comp_agg(comp$area$rfh("rMean", "rMVar", "RFHRMean"))

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

setupES <- setup %>%
  sim_gen_ec(
    mean = 0,
    sd = sqrt(200),
    areaVar = "idD",
    nCont = replace(rep(0, 40), c(4, 14, 24, 34), 0.2)
  ) %>%
  sim_simName("(0, e-sym)")

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

if (rerun) {
  lapply(list(setup, setupE, setupU, setupUE, setupES), simFun)
  sim_clear_data("./R/data/fromUnitToAreaLevel")
}

if (!LOCAL) q("no")

simData <- sim_read_data("./R/data/fromUnitToAreaLevel") %>%
  mutar(c("idD", "popMean", "simName", "sMean", "rMean", "FH", "FHGVF",
          "FHRMean", "RFH", "RFHGVF", "RFHRMean", "RFH.BC"))

ggDat <- tidyr::gather(
  simData,
  method, prediction,
  -idD, -popMean, -simName
)

ggDat %<>%
  mutar(method ~ replace(method, ~ . == "sMean", "SM"),
        method ~ replace(method, ~ . == "rMean", "RM"),
        method ~ replace(method, ~ . == "FHGVF", "FH.SM.GVF"),
        method ~ replace(method, ~ . == "RFHGVF", "RFH.SM.GVF"),
        method ~ replace(method, ~ . == "RFH.BC", "RFH.SM.BC"),
        method ~ replace(method, ~ . == "RFH", "RFH.SM"),
        method ~ replace(method, ~ . == "FH", "FH.SM"),
        method ~ replace(method, ~ . == "RFHRMean", "RFH.RM"),
        method ~ replace(method, ~ . == "FHRMean", "FH.RM"))

methodOrder <- c("SM", "RM", "FH.SM", "FH.SM.GVF", "FH.RM", "RFH.SM", "RFH.SM.GVF", "RFH.RM", "RFH.SM.BC")
ggDat %<>% mutar(
  method ~ factor(method, methodOrder, ordered = TRUE)
)

ggDat %<>% mutar(
  RBIAS ~ mean((prediction - popMean) / popMean) * 100,
  RRMSE ~ sqrt(mean(((prediction - popMean) / popMean)^2)) * 100,
  by = c("idD", "method", "simName")
)

ggDat %<>% mutar(
  idC ~ ifelse(idD %in% c(5, 15, 25, 35) & simName %in% c("(u, 0)", "(u, e)"), 1, NA_integer_),
  idC ~ ifelse(idD %in% c(4, 14, 24, 34) & simName %in% c("(0, e)", "(0, e-sym)", "(u, e)"), 2, idC),
  idC ~ factor(idC, labels = c("Area-outlier", "Unit-outlier"))
)

cairo_pdf("figs/unit_mse.pdf", width, 4 * height)
gg$plots$mse(ggDat, fontsize = fontSize) +
  geom_point(aes(colour = idC), ggDat %>% mutar(~!is.na(idC))) +
  labs(colour = NULL, y = "RRMSPE in %")
dev.off()

cairo_pdf("figs/unit_bias.pdf", width, 4 * height)
gg$plots$bias(ggDat, fontsize = fontSize) +
  geom_point(aes(colour = idC), ggDat %>% mutar(~!is.na(idC))) +
  labs(colour = NULL, y = "RBIAS in %")
dev.off()
