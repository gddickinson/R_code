"""Web showcase and code explorer for R_code (FastAPI app + static front end; see INTERFACE.md).

app.py          routes under /api and STATIC_ENDPOINTS for the static export
repo_files.py   lists the repository's files: kind, size, origin, whether the text is shown, redacted text
privacy.py      third-party / course origin of files, redaction of home-folder user names and e-mail addresses
r_facts.py      facts read from an R script: header comment, packages, data read, functions, plots, Shiny I/O
html_report.py  sanitises committed HTML reports (no scripts, styles or external resources)
howto.py        'How it works' claims tied to quoted lines of the scripts
static/         the front end (ES modules, no build step) and the JavaScript ports with their node tests
"""
