module::import("ggplot2")
module::use("R/graphics/themes.R")

plotRBIAS <- function(dat) {
  ggplot(dat) +
    geom_boxplot(aes(x = method, y = RBIAS)) +
    coord_flip() + facet_grid(simName ~ .) +
    geom_hline(aes(yintercept = 0), colour = "grey", linetype = 2) +
    theme_thesis() +
    labs(x = NULL)
}

plotRRMSE <- function(dat) {
  ggplot(dat, aes(x = method, y = RRMSE)) +
    geom_boxplot() + coord_flip() + facet_grid(simName ~ .) +
    theme_thesis() +
    labs(x = NULL)
}
