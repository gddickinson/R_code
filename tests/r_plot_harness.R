# Runs one PCR plot script (without its setwd line) on a null device and prints, as JSON, what it drew:
# every points()/plot() call's colour, symbol and number of drawable (finite) points, the legend, and the warnings.
# Used by tests/test_r_scripts.py.  Usage: Rscript tests/r_plot_harness.R PCR/<script>.R
suppressMessages(library(jsonlite))
script <- commandArgs(trailingOnly = TRUE)[1]
calls <- list(); legends <- list(); warns <- character()
rec <- function(kind, x, y, col, pch) {
  xy <- suppressWarnings(xy.coords(x, y))
  calls[[length(calls) + 1]] <<- list(kind = kind, col = if (is.null(col)) "black" else col, pch = if (is.null(pch)) 1 else pch,
                                      n = sum(is.finite(xy$x) & is.finite(xy$y)))
}
points <- function(x, y = NULL, col = NULL, pch = NULL, ...) { rec("points", x, y, col, pch); graphics::points(x, y, col = col, pch = pch, ...) }
plot <- function(x, y = NULL, col = NULL, pch = NULL, ...) {
  if (!is.null(y)) rec("plot", x, y, col, pch)
  graphics::plot(x, y, col = col, pch = pch, ...)
}
legend <- function(x, ..., legend, pch = NULL) {
  legends[[length(legends) + 1]] <<- list(legend = legend, pch = pch)
  graphics::legend(x, ..., legend = legend, pch = pch)
}
pdf(NULL)
src <- readLines(file.path(dirname(script), basename(script)), warn = FALSE)
src <- src[!grepl("^\\s*setwd\\(", src)]
owd <- setwd(dirname(script))
withCallingHandlers(eval(parse(text = src)), warning = function(w) { warns <<- c(warns, conditionMessage(w)); invokeRestart("muffleWarning") })
setwd(owd)
cat(toJSON(list(calls = calls, legends = legends, warnings = warns), auto_unbox = TRUE))
