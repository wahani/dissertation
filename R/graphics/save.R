modules::import("ggplot2")

default <- function(x, path = "./figs/", dev = "pdf", width = 7, height = 4) {
  filename <- paste0(path, as.character(substitute(x)), ".", dev)
  ggplot2::ggsave(filename, plot = x, width = width, height = height)
  filename
}
