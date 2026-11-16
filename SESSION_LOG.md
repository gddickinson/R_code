# SESSION_LOG.md

## 2026-11-13..16: web interface (branch web-interface)
- Showcase + code explorer (FastAPI, port 8254; static Pages export on master): 175 files listed, R scripts with
  header comment, packages, inputs, functions, plots and Shiny I/O; text search; sanitised view of test.html.
- Demos ported to JS and tested against R 4.4.1 (`scripts/make_r_fixtures.R` -> tests/fixtures/r_reference.json):
  SoundScience Ward clustering (merge, heights, order, cutree k=2..15 identical), PCR figures (read.csv parsing of all
  11 CSVs identical), dbinom/pbinom, mouse weights mean/popsd/SD rule. No delta-delta-Ct exists in the PCR code.
- Fixed PCR plot scripts (8ae4df1): empty serotype plots under R >= 4 (text x), xact typo, ABI enterica missing from
  Plot2a/2b, Plot2a legend symbols swapped.
- Not fixed (intent unclear): DataCamp/probability_1.R line 3 `rbinom(n,1,prob)` uses undefined `n`.
- Public-site review: user names in paths and a UCI e-mail in mend-to-bibtex.R are redacted in the site; RStudio
  Shiny tutorial (no licence) listed only. For George: PCR instrument exports/docx (workplace Salmonella validation,
  isolate codes), Puff_Project/puff_data_shadowlessTIRF_11072014.csv (lab data) are in the public repo already.
