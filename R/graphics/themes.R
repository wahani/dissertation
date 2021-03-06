modules::import("ggplot2")

theme_thesis <- function(base_size = 12, base_family = "serif") {
  theme_minimal(base_size, base_family) %+replace% theme(
    panel.margin = unit(1.2, "lines"),
    panel.grid.minor = element_blank(),
    axis.text = element_text(size = base_size),
    legend.position = "bottom",
    axis.text.y = element_text(hjust = 0)
  )
}

theme_thesis_nogrid <- function(base_size = 12, base_family = "serif") {
    theme_minimal(base_size, base_family) %+replace% theme(
      panel.margin = unit(1.2, "lines"),
      panel.grid = element_blank(),
      axis.text = element_text(size = base_size))
}

theme_thesis_boxplot <- function(base_size = 12, base_family = "serif") {
  theme_thesis(base_size, base_family) %+replace% theme(
    axis.title.y = element_blank(),
    legend.position = "bottom",
    axis.text.y = element_text(hjust = 0)
  )
}
