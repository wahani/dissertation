import(Hmisc, latex)

save <- function(x, fileName, ..., caption.loc = "bottom", rowname = NULL) {
  latex(
    x,
    file = fileName,
    ...,
    caption.loc = caption.loc,
    rowname = rowname
  )
}

saveResize <- function(...) {
  tab <- save(...)
  fileContent <- readLines(tab$file)
  fileContent <- gsub("\\\\begin\\{tabular\\}", "\\\\resizebox{\\\\linewidth}{!}{\\\\begin{tabular}", fileContent)
  fileContent <- gsub("\\\\end\\{tabular\\}", "\\\\end{tabular}}", fileContent)
  writeLines(fileContent, tab$file)
  tab
}

