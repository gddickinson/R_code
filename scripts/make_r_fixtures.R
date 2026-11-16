# Reference values for the JavaScript ports, computed by R itself from the repository's own scripts and data.
# Run from the repository root:  Rscript scripts/make_r_fixtures.R [out.json]
# Writes tests/fixtures/r_reference.json (read by web/static/*.test.mjs and checked by tests/test_web.py).
suppressMessages(library(jsonlite))
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else "tests/fixtures/r_reference.json"
ref <- list(r_version = R.version.string)

# --- SoundScience/clustering.R: term groups, Euclidean distances, Ward ("ward.D") clustering, cutree -------------
src <- readLines("SoundScience/clustering.R", warn = FALSE)
start <- grep("^data = read.csv\\(filepath", src)
stop <- grep("^data_crop <- data_combined\\[!rownames", src)
filepath <- "SoundScience/data_habitat_speciesNames.csv"
eval(parse(text = src[start:stop]))                      # the script's own lines: read, group terms, drop outliers
h <- hclust(dist(data_crop, method = "euclidean"), method = "ward.D")
ref$clustering <- list(
  lines = c(start, stop), columns = names(data), rows = rownames(data_crop), groups = names(data_combined),
  first_row = unname(unlist(data_crop[1, ])), merge = unname(h$merge), height = h$height, order = h$order,
  cutree = lapply(2:15, function(k) unname(cutree(h, k = k))))
# Same clustering without dropping the four outlying projects (the script's commented-out alternative).
h_all <- hclust(dist(data_combined), method = "ward.D")
ref$clustering_all <- list(rows = rownames(data_combined), height = h_all$height, merge = unname(h_all$merge),
                           order = h_all$order, cutree12 = unname(cutree(h_all, k = 12)))

# --- DataCamp/probability_1.R: dbinom / pbinom ----------------------------------------------------------------------
grid <- expand.grid(x = 0:10, size = c(1, 10, 25), prob = c(0.1, 0.5, 0.73))
grid <- grid[grid$x <= grid$size, ]
ref$binom <- list(script = list(dbinom_5_10 = dbinom(5, 10, .5), pbinom_4_10 = pbinom(4, 10, .5)),
                  grid = data.frame(grid, d = dbinom(grid$x, grid$size, grid$prob), p = pbinom(grid$x, grid$size, grid$prob)))

# --- EdX_course/Week1_CentralLimitTheorem*.R: population mean, popsd (rafalib), proportion within k SD -----------
dat <- na.omit(read.csv("EdX_course/mice_pheno.csv"))
popsd <- function(x) sqrt(mean((x - mean(x))^2))       # rafalib::popsd
groups <- list()
for (sex in c("F", "M")) for (diet in c("chow", "hf")) {
  y <- dat$Bodyweight[dat$Sex == sex & dat$Diet == diet]
  prop <- function(q) mean(y <= q)
  groups[[paste(sex, diet)]] <- list(sex = sex, diet = diet, n = length(y), mean = mean(y), popsd = popsd(y),
    within = sapply(1:3, function(k) prop(mean(y) + k * popsd(y)) - prop(mean(y) - k * popsd(y))))
}
ref$mice <- list(rows = nrow(dat), groups = unname(groups))

# --- PCR: every CSV a plot script reads, as R's read.csv sees it --------------------------------------------------
pcr <- list()
used <- unique(unlist(lapply(list.files("PCR", pattern = "\\.R$", full.names = TRUE), function(f)
  regmatches(readLines(f, warn = FALSE), regexpr("(?<=read.csv\\(')[^']+", readLines(f, warn = FALSE), perl = TRUE)))))
for (f in sort(used[file.exists(file.path("PCR", used))])) {   # commented-out reads may name missing files
  d <- read.csv(file.path("PCR", f), header = TRUE)
  pcr[[f]] <- list(names = names(d), columns = lapply(unname(as.list(d)), function(v) if (is.numeric(v)) v else as.character(v)))
}
ref$pcr <- pcr

writeLines(toJSON(ref, digits = NA, auto_unbox = TRUE, na = "null", pretty = FALSE), out)
cat("wrote", out, "\n")
