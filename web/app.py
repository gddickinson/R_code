"""FastAPI web app for R_code: a showcase and code explorer of the repository, plus interactive ports of a few
calculations. Serves static/ and the JSON API under /api.

Run with `python run_web.py` (http://127.0.0.1:8254, local only). `scripts/build_static.py` exports every path in
STATIC_ENDPOINTS to JSON for the GitHub Pages site, so keep that list in step with the GET routes below.
"""
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from web import howto, html_report, r_facts
from web import repo_files as R

STATIC = Path(__file__).resolve().parent / "static"

app = FastAPI(title="R code")
app.mount("/static", StaticFiles(directory=STATIC), name="static")

# Data files the in-browser demos read (unmodified repository files).
DEMO_DATA = {
    "soundscience": "SoundScience/data_habitat_speciesNames.csv",
    "mice": "EdX_course/mice_pheno.csv",
    **{f"pcr-{n}": f"PCR/{n}" for n in (
        "abi7500_detection_limit_oric.csv", "abi7500_dilutions_gfp.csv", "abi7500_dilutions_oric.csv", "abi7500_gfp_2.csv",
        "abi7500_oric_2.csv", "non-salm_smartcycler_gfp.csv", "non-salm_smartcycler_oric.csv",
        "smartcycler_dilutions_gfp.csv", "smartcycler_dilutions_oric.csv", "smartcycler_gfp_2.csv", "smartcycler_oric_2.csv")},
}


@app.get("/", include_in_schema=False)
def index():
    return FileResponse(STATIC / "index.html")


@app.get("/api/info")
def info():
    """Counts and folder summary for the home page."""
    folders = {}
    for f in R.files():
        top = f["path"].split("/")[0] if "/" in f["path"] else "(top level)"
        d = folders.setdefault(top, {"name": top, "files": 0, "r": 0})
        d["files"] += 1
        d["r"] += f["path"].lower().endswith(".r")
    return {"title": "R code", "stats": R.stats(), "folders": list(folders.values())}


@app.get("/api/files")
def files():
    """Every listed file (metadata only)."""
    return {"files": R.files()}


@app.get("/api/file/{fid}")
def file(fid: str):
    """One file: metadata, text (when shown), facts for R scripts, or the sanitised report."""
    f = R.get(fid)
    if not f:
        raise HTTPException(404, f"no file {fid!r}")
    out = dict(f)
    if f["shown"] and f["kind"] in ("code", "doc", "data"):
        out["text"] = R.read_text(f["path"])
        if f["path"].lower().endswith((".r", ".rmd")):
            out["facts"] = r_facts.facts(out["text"])
    elif f["shown"] and f["kind"] == "report":
        out["report"] = html_report.clean(R.read_text(f["path"]))
    return out


@app.get("/api/corpus")
def corpus():
    """Text of every shown R script, R Markdown and Markdown file, for the explorer's text search."""
    return {f["id"]: R.read_text(f["path"]) for f in R.files() if f["shown"] and f["kind"] in ("code", "doc")}


@app.get("/api/how")
def how():
    return {"sections": howto.sections()}


@app.get("/api/data/{name}")
def data(name: str):
    """A data file one of the demos reads, unmodified."""
    if name not in DEMO_DATA:
        raise HTTPException(404, f"no demo data {name!r}")
    return {"path": DEMO_DATA[name], "text": R.raw_text(DEMO_DATA[name])}


@app.get("/repo/{path:path}", include_in_schema=False)
def repo_image(path: str):
    """Images committed in the repository (only listed, shown image files)."""
    if path not in R.image_paths():
        raise HTTPException(404, "not a shown image in this repository")
    return FileResponse(R.ROOT / path)


# GET paths (without the /api prefix) written to the static site as api/<path>.json.
STATIC_ENDPOINTS = (["/info", "/files", "/corpus", "/how"] + [f"/file/{f['id']}" for f in R.files()]
                    + [f"/data/{n}" for n in DEMO_DATA])
