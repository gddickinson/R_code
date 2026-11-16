"""What the site may show of each file, and redaction of personal details.

Everything the web app returns about file contents goes through redact(): user names inside home-folder paths
(C:\\Users\\<name>, /Users/<name>, /home/<name>) and e-mail addresses are replaced, so the static export never
contains them. Third-party material is listed with its source and licence; its text is shown only when the material
states a licence that allows redistribution. No file in the repository forbids redistribution (checked 2026-11-13:
no licence, copyright or honour-code statement besides LICENSE, the Bootswatch theme and the knitted test.html).
"""
import re

# path prefix -> (origin, note, show text?)
THIRD_PARTY = {
    "shiny/shiny.rstudio.com-tutorial-master/part-3-code/bootswatch-cerulean.css":
        ("vendored", "Bootswatch v3.3.4+1 'Cerulean' theme, Copyright 2012-2015 Thomas Park, MIT licence (file header)", False),
    "shiny/shiny.rstudio.com-tutorial-master/":
        ("third-party", "exercise files of the RStudio Shiny video tutorial (shiny.rstudio.com/tutorial, per its README); "
                        "no licence statement in the folder", False),
    "example_distributionPlot.R":
        ("third-party", "examples from R's own help pages (plot.default, points; R is GPL-2 | GPL-3)", True),
}
COURSE = {
    "EdX_course/": "edX course exercises (genomicsclass PH525x data analysis course; data downloaded from genomicsclass/dagdata)",
    "EdX-Bioinformatics/": "edX bioinformatics course exercises (per the folder name), with the course's example data files",
    "DataCamp/": "DataCamp course exercise",
}

_HOME = [
    (re.compile(r"(?i)([A-Z]:(?:\\\\|\\|/)+Users(?:\\\\|\\|/)+)([^\\/'\"\s]+)"), r"\1<user>"),
    (re.compile(r"(?i)((?:\\\\|/)Users(?:\\\\|/)+)([^\\/'\"\s]+)"), r"\1<user>"),
    (re.compile(r"(/home/)([^/'\"\s]+)"), r"\1<user>"),
]
_EMAIL = re.compile(r"(?<![A-Za-z0-9._%+-])[A-Za-z0-9._%+-]++@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}")


def redact(text: str) -> str:
    """Text with home-folder user names and e-mail addresses replaced by <user> / <email>."""
    for rx, rep in _HOME:
        text = rx.sub(rep, text)
    return _EMAIL.sub("<email>", text)


def origin(rel: str) -> dict:
    """{'kind': own | course | third-party | vendored, 'note': str, 'show': bool} for a repository path."""
    for prefix, (kind, note, show) in THIRD_PARTY.items():
        if rel == prefix or (prefix.endswith("/") and rel.startswith(prefix)):
            return {"kind": kind, "note": note, "show": show}
    for prefix, note in COURSE.items():
        if rel.startswith(prefix):
            return {"kind": "course", "note": note, "show": True}
    return {"kind": "own", "note": "", "show": True}
