modules::import("ggplot2")

save_default <- function(x, path = "./figs/", dev = "pdf", width = 7, height = 4, envir = parent.frame()) {
  p <- get(x, envir = envir)
  filename <- paste0(path, x, ".", dev)
  ggplot2::ggsave(filename, plot = p, width = width, height = height)
  filename
}
