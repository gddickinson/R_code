"""'How it works' explanations, each claim tied to the file and the quoted code it describes.

The line number of every claim is found by searching the file for its quote, and tests/test_web.py checks that each
quote is present, so the explanations cannot drift away from the code.
"""
from web.repo_files import ROOT, file_id

SECTIONS = [
    {"id": "pcr", "title": "qPCR platform comparison (PCR/)", "claims": [
        ("Each figure script reads small CSV tables of Ct values exported from the two instruments.",
         "PCR/Plot2a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_oric.R", "smartcycler_oric = read.csv('smartcycler_dilutions_oric.csv'"),
        ("Dilution-series plots put the dilution factor on a log x axis and Ct on y, limited to Ct 20-45, so a Ct of 0 (no amplification) falls outside the plot.",
         "PCR/Plot2a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_oric.R", 'log = "x",'),
        ("ABI 7500 points are drawn 5% to the right of the SmartCycler points so the two instruments do not overlap.",
         "PCR/Plot2a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_oric.R", "x2 <- c(1.05, 10.5, 105, 1050)"),
        ("Serotype plots place each serotype at its position in the file and label it underneath at 60 degrees.",
         "PCR/Plot1a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_OriC.R", "srt = 60"),
        ("The non-Salmonella specificity plot shows both assays on a 0-45 Ct axis (filled symbols OriC, open symbols gfp).",
         "PCR/Plot3a_Non-Salmonella_dilutions_series_SmartCycler_vs_ABI7500_OriC.R", "points(match(gfp$serotype, x), gfp$SmartCycler, col=\"blue\", pch = 1"),
        ("The limit-of-detection plot follows two S. enterica dilution series out to 1:100000 on the ABI 7500.",
         "PCR/Plot4a_enterica_dilution_series_ABI_limitOfDetection_OriC.R", "x2 <- c(1.03, 10.3, 103, 1030, 10300, 103000)"),
        ("No efficiency, standard-curve or delta-delta-Ct calculation exists in these scripts: they compare raw Ct values by eye.",
         "PCR/README.md", "## Key Visualizations"),
    ]},
    {"id": "soundscience", "title": "Clustering research projects by their vocabulary (SoundScience/)", "claims": [
        ("The input is a table of word frequencies: one row per research project code, one column per search term.",
         "SoundScience/clustering.R", 'data = read.csv(filepath, header = TRUE, sep=",", row.names = 1)'),
        ("Related search terms are summed into topic groups, e.g. 18 bird words into 'birds'.",
         "SoundScience/clustering.R", 'birds <- rowSums(data[,c("avian","woodpecker"'),
        ("37 topic groups (species, methods, habitats) form the table that is clustered.",
         "SoundScience/clustering.R", "data_combined <- data.frame(birds, fish, plants, insects, bats, amphibians,fishTracking"),
        ("Four outlying projects (c39, e14, e27, e18) are removed before clustering.",
         "SoundScience/clustering.R", 'data_crop <- data_combined[!rownames(data_combined) %in% c("c39", "e14", "e27", "e18"), ]'),
        ("K-means is run for k = 2..15 to draw an elbow plot of within-group sums of squares, then with k = 12.",
         "SoundScience/clustering.R", "for (i in 2:15) wss[i] <- sum(kmeans(data_crop,"),
        ("Hierarchical clustering uses Euclidean distances between projects...",
         "SoundScience/clustering.R", 'd <- dist(data.stand, method = "euclidean")'),
        ("... and Ward's method as R calls it 'ward.D' (Lance-Williams update on unsquared distances).",
         "SoundScience/clustering.R", 'H.fit <- hclust(d, method="ward.D")'),
        ("The tree is cut into the same number of groups as k-means, to compare the two groupings.",
         "SoundScience/clustering.R", "Euc_groups <- cutree(H.fit, k=kmeansValue)"),
    ]},
    {"id": "coursework", "title": "Statistics coursework (EdX_course/, DataCamp/)", "claims": [
        ("Mouse body weights (mice_pheno.csv) lose rows with missing values first.",
         "EdX_course/Week1_CentralLimitTheorem.R", "dat <- na.omit( dat )"),
        ("Spread is the population SD from rafalib (divides by n, not n - 1).",
         "EdX_course/Week1_CentralLimitTheorem.R", "bodyweight_male_chow_sd <- popsd(x)"),
        ("The share of mice within 1, 2 and 3 SD of the mean uses the empirical CDF, prop(q) = mean(y <= q).",
         "EdX_course/Week1_CentralLimitTheorem_2.R", "prop = function(q) {"),
        ("The sampling distribution of the mean is simulated with 10000 samples of 25 mice.",
         "EdX_course/Week1_CentralLimitTheorem_2.R", "avgs <- replicate(10000, mean( sample(y, 25)))"),
        ("Binomial probabilities: simulated coin flips, then the exact density and cumulative probability.",
         "DataCamp/probability_1.R", "dbinom(number_heads,10,.5)"),
    ]},
    {"id": "shiny", "title": "Shiny and leaflet apps (shiny/, leaflet/)", "claims": [
        ("leafletApp2 maps earthquakes from R's built-in quakes data with a magnitude range slider and colour scheme choice.",
         "shiny/leafletApp2/app.R", 'sliderInput("range", "Magnitudes", min(quakes$mag), max(quakes$mag),'),
        ("twitterApp downloads tweets for a hashtag and date range (rtweet; needs Twitter API access).",
         "shiny/twitterApp/app.R", 'textInput("hashtag_to_search",'),
        ("censusDataApp maps US counties from a census shapefile (ACS table B27001) kept out of the repository; the commented-out preparation computes the share of uninsured adults aged 18-34 in 2012 and 2016.",
         "shiny/censusDataApp/app.R", 'shp <- st_read("C:/Users/<user>/Dropbox/code/R_code/shiny/censusDataApp/acs_2012_2016_county_us_B27001'),
        ("cameraApp takes a webcam snapshot in the browser (shinysense).",
         "shiny/cameraApp/app.R", "library(shinysense)"),
    ]},
]


def _line(rel: str, quote: str) -> int | None:
    from web.repo_files import read_text
    for i, line in enumerate(read_text(rel).split("\n"), 1):
        if quote in line:
            return i
    return None


def sections() -> list:
    out = []
    for s in SECTIONS:
        claims = [{"text": t, "file": f, "id": file_id(f), "quote": q, "line": _line(f, q)} for t, f, q in s["claims"]]
        out.append({"id": s["id"], "title": s["title"], "claims": claims})
    return out


assert ROOT.exists()
