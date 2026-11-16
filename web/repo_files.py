"""The repository's own files for the code explorer: what each file is, whether its text is shown, and its text.

Kinds: code (.R .Rmd), doc (.md), report (.html), data (.csv .txt .fasta ...), image, binary (.xlsx .docx .RData),
generated (R session files: .Rhistory, .RData, .Rproj.user/, .Rproj). Text is shown for code, docs, reports and data
up to MAX_TEXT bytes; third-party material follows privacy.origin(). The web interface's own files are not listed.
"""
import re
from functools import lru_cache
from pathlib import Path

from web import privacy, r_facts

ROOT = Path(__file__).resolve().parent.parent
MAX_TEXT = 200_000
WEB_FILES = {"web", "scripts", "tests", "docs", ".github", "site", ".git", "run_web.py", "requirements-web.txt",
             "INTERFACE.md", "SESSION_LOG.md", "CLAUDE.md", "README.md", ".gitignore", ".pytest_cache"}
KIND = {".r": "code", ".rmd": "code", ".md": "doc", ".html": "report", ".css": "code",
        ".csv": "data", ".txt": "data", ".fasta": "data", ".phylip": "data", ".dat": "data", ".tex": "data",
        ".log": "data", ".png": "image", ".jpg": "image", ".gif": "image",
        ".xlsx": "binary", ".xls": "binary", ".docx": "binary", ".rdata": "generated", ".rhistory": "generated",
        ".rproj": "generated"}
LANG = {".r": "r", ".rmd": "r", ".css": "c"}


def file_id(rel: str) -> str:
    """URL-safe id of a path (also the static file name): 'PCR/Plot1a.R' -> 'PCR__Plot1a.R'."""
    return re.sub(r"[^A-Za-z0-9._-]+", "_", rel.replace("/", "__"))


def kind_of(rel: str) -> str:
    p = Path(rel)
    if ".Rproj.user" in p.parts or p.name in (".DS_Store",):
        return "generated"
    if p.name == "LICENSE":
        return "doc"
    return KIND.get(p.suffix.lower(), "binary" if p.suffix else "data")


def _listed(p: Path) -> bool:
    rel = p.relative_to(ROOT)
    return (p.is_file() and rel.parts[0] not in WEB_FILES and p.name != ".DS_Store"
            and ".Rproj.user" not in rel.parts)  # RStudio session state: not listed


@lru_cache(maxsize=1)
def files() -> list:
    """Every listed file with id, path, folder, kind, size, lines, origin, shown flag and reason when not shown."""
    out = []
    for p in sorted(ROOT.rglob("*"), key=lambda q: str(q.relative_to(ROOT)).lower()):
        if not _listed(p):
            continue
        rel = str(p.relative_to(ROOT))
        kind, size, org = kind_of(rel), p.stat().st_size, privacy.origin(rel)
        why = ""
        if kind in ("binary", "generated"):
            why = {"binary": "binary file (spreadsheet, document or R workspace)", "generated": "R session / project file"}[kind]
        elif kind not in ("image", "report") and size > MAX_TEXT:
            why = f"large file ({size / 1e3:.0f} kB): listed only"
        elif not org["show"]:
            why = org["note"]
        text = read_text(rel) if kind in ("code", "doc", "data") and not why else ""
        out.append({
            "id": file_id(rel), "path": rel, "folder": str(Path(rel).parent) if "/" in rel else "", "name": p.name,
            "kind": kind, "lang": LANG.get(p.suffix.lower(), ""), "size": size,
            "lines": text.count("\n") + (1 if text and not text.endswith("\n") else 0) if text else None,
            "origin": org["kind"], "note": org["note"], "shown": not why, "why": why,
            "summary": r_facts.header(text) if kind == "code" and text else "",
        })
    return out


def get(fid: str) -> dict | None:
    return next((f for f in files() if f["id"] == fid), None)


def read_text(rel: str) -> str:
    """File text with CR / CRLF line ends normalised, decoded as UTF-8 (Latin-1 fallback), personal details redacted."""
    raw = (ROOT / rel).read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        text = raw.decode("latin-1")
    return privacy.redact(text.replace("\r\n", "\n").replace("\r", "\n"))


def raw_text(rel: str) -> str:
    """Unmodified file text (for the demos' data files, which hold no personal details)."""
    return (ROOT / rel).read_text(encoding="utf-8")


def stats() -> dict:
    fs = files()
    code = [f for f in fs if f["kind"] == "code" and f["shown"] and f["path"].lower().endswith((".r", ".rmd"))]
    return {
        "files": len(fs), "r_scripts": sum(f["path"].lower().endswith(".r") for f in fs),
        "r_lines": sum(f["lines"] or 0 for f in code), "data_files": sum(f["kind"] == "data" for f in fs),
        "shown": sum(f["shown"] for f in fs), "folders": len({f["path"].split("/")[0] for f in fs if "/" in f["path"]}),
        "shiny_apps": sum(f["name"] == "app.R" and "tutorial" not in f["path"] for f in fs),
    }


def image_paths() -> list:
    """Shown image files (served at repo/<path> locally and copied there in the static export)."""
    return [f["path"] for f in files() if f["kind"] == "image" and f["shown"]]
