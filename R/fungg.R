theme_thesis <- function(base_size = 12, base_family = "serif") {
    theme_minimal(base_size, base_family) %+replace%
        theme(panel.grid.minor = element_blank())
}

theme_thesis_nogrid <- function(base_size = 12, base_family = "serif") {
    theme_minimal(base_size, base_family) %+replace%
        theme(panel.grid = element_blank())
}
