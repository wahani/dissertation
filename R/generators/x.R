fixed_sequence <- function(D) {
  b <- function(i) i / D
  x <- function(i) b(i) * 0.5 + 1
  x(1:D)
}
