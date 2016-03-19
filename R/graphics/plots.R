modules::import("ggplot2")
modules::use("R/graphics/themes.R", attach = TRUE)

bias <- function(dat, x = "method", y = "RBIAS", fontsize = 12) {
  ggplot(dat) +
    geom_boxplot(aes_string(x = x, y = y)) +
    coord_flip() +
    facet_grid(simName ~ .) +
    geom_hline(aes(yintercept = 0), colour = "black", linetype = 2) +
    theme_thesis_boxplot(fontsize)
}

mse <- function(dat, x = "method", y = "RRMSE", fontsize = 12) {
  ggplot(dat, aes(x = method, y = RRMSE)) +
    geom_boxplot() + coord_flip() + facet_grid(simName ~ .) +
    theme_thesis_boxplot(fontsize)
}
