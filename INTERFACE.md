# INTERFACE.md: navigation map for R_code

R scripts live in topic folders (see README.md). The web interface (FastAPI locally, static on GitHub Pages) is
separate from them and never runs the R code.

## Web interface
| File | Contents |
|---|---|
| `run_web.py` | Starts uvicorn on 127.0.0.1:8254 |
| `web/app.py` | Routes `/api/info`, `/files`, `/file/{id}`, `/corpus`, `/how`, `/data/{name}`, `/repo/{image}`; `STATIC_ENDPOINTS`, `DEMO_DATA` |
| `web/repo_files.py` | `files()`, `get(id)`, `read_text(rel)` (redacted), `raw_text`, `file_id`, `kind_of`, `stats()`, `image_paths()` |
| `web/privacy.py` | `redact(text)`, `origin(rel)`; `THIRD_PARTY`, `COURSE` |
| `web/r_facts.py` | `header(text)`, `facts(text)`: packages, reads, functions, plots, Shiny inputs/outputs |
| `web/html_report.py` | `clean(html)`: whitelist sanitiser for committed HTML reports |
| `web/howto.py` | `SECTIONS` claims (text, file, quote) and `sections()` with line numbers |
| `web/static/core.js`, `style.css` | Shared kit (router, `api()`, theme) |
| `web/static/main.js`, `index.html`, `style_app.css`, `static_api.js` | Shell, page registry, styles, static data layer |
| `web/static/home.js`, `code.js`, `how.js`, `demos.js`, `about.js` | Pages `#/`, `#/code[/id]`, `#/how`, `#/demo/<name>`, `#/about` |
| `web/static/demo_cluster.js`, `demo_pcr.js`, `demo_stats.js` | Demo pages |
| `web/static/r_csv.js` | `parseCsv`, `makeNames` (R make.names), `readCsv` (read.csv semantics) |
| `web/static/cluster_engine.js` | `GROUPS`, `OUTLIERS`, `combine`, `dist`, `hclustWardD` (R hclust.f port), `cutree`, `layout` |
| `web/static/pcr_engine.js` | `PLOTS`, `points(plot, texts)`: series of each PCR figure script |
| `web/static/stats_engine.js` | `dbinom`, `pbinom`, `mean`, `popsd`, `within`, `miceSummary`, `sample` |
| `web/static/chart.js`, `highlight.js` | SVG scatter/histogram; syntax highlighter (R, MATLAB, ...) |
| `web/static/engines.test.mjs` | Node tests of the ports against `tests/fixtures/r_reference.json` |
| `scripts/make_r_fixtures.R` | Writes the R reference values (runs the scripts' own lines) |
| `scripts/build_static.py`, `scripts/screenshots.py` | Static export; Playwright smoke test / screenshots |
| `tests/test_web.py` | Endpoints, static build, privacy, report sanitiser, how-it-works quotes, fixture currency |
| `tests/test_r_scripts.py`, `tests/r_plot_harness.R` | Regression tests of the PCR plot scripts, run in R |
| `.github/workflows/pages.yml` | Publishes the static site on push to master |
