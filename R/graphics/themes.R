module::import("ggplot2")

theme_thesis <- function(base_size = 12, base_family = "serif") {
    theme_minimal(base_size, base_family) %+replace%
        theme(panel.grid.minor = element_blank())
}

theme_thesis_nogrid <- function(base_size = 12, base_family = "serif") {
    theme_minimal(base_size, base_family) %+replace%
        theme(panel.grid = element_blank())
}

theme_thesis_boxplot <- function(base_size = 12, base_family = "serif") {
  theme_thesis(base_size, base_family) %+replace%
    theme(panel.border = element_rect(fill = "transparent"),
          axis.title.y = element_blank())
}
