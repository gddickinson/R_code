"""Web interface tests: every exported endpoint answers, the static build is complete, and the JS engine tests pass.

Run: python -m pytest -q tests/test_web.py
"""
import shutil
import subprocess
import sys
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

from web.app import STATIC, STATIC_ENDPOINTS, app  # noqa: E402

client = TestClient(app)


def test_index_served():
    r = client.get("/")
    assert r.status_code == 200 and "static/main.js" in r.text


@pytest.mark.parametrize("path", STATIC_ENDPOINTS)
def test_endpoint(path):
    r = client.get("/api" + path)
    assert r.status_code == 200, r.text
    assert r.json() is not None


def test_static_build(tmp_path):
    sys.path.insert(0, str(ROOT / "scripts"))
    import build_static
    build_static.build(tmp_path / "site")
    assert (tmp_path / "site" / "index.html").read_text().count("APP_STATIC") == 1
    for path in STATIC_ENDPOINTS:
        assert (tmp_path / "site" / "api" / (path.strip("/") + ".json")).exists()


def test_static_assets_referenced_exist():
    html = (STATIC / "index.html").read_text()
    for name in ("style.css", "main.js"):
        assert f"static/{name}" in html and (STATIC / name).exists()


@pytest.mark.skipif(not shutil.which("node"), reason="node not installed")
def test_js_engine():
    tests = sorted(STATIC.glob("*.test.mjs"))
    for t in tests:
        r = subprocess.run(["node", str(t)], capture_output=True, text=True)
        assert r.returncode == 0, r.stdout + r.stderr


# --- project-specific -----------------------------------------------------------------------------------------------
import json  # noqa: E402
import os  # noqa: E402

from web import howto, privacy  # noqa: E402
from web import repo_files as R  # noqa: E402

PERSONAL = ("DickinsG", "g_dic", "dickinsg@", "Users\\\\George", "Users\\George", "/home/george")


def test_static_export_has_no_personal_details(tmp_path):
    sys.path.insert(0, str(ROOT / "scripts"))
    import build_static
    build_static.build(tmp_path / "site")
    for p in (tmp_path / "site" / "api").rglob("*.json"):
        if p.name.startswith("data"):
            continue
        text = p.read_text()
        assert not [s for s in PERSONAL if s in text], p


def test_redact():
    assert privacy.redact(r'setwd("C:\\Users\\DickinsG\\Desktop")') == r'setwd("C:\\Users\\<user>\\Desktop")'
    assert privacy.redact("/home/george/x.xls a@b.edu") == "/home/<user>/x.xls <email>"


def test_third_party_tutorial_not_shown():
    for f in R.files():
        if f["path"].startswith("shiny/shiny.rstudio.com-tutorial-master/"):
            assert not f["shown"]
            assert "text" not in client.get(f"/api/file/{f['id']}").json()


def test_report_is_sanitised():
    r = client.get(f"/api/file/{R.file_id('test.html')}").json()["report"]
    assert "<script" not in r["html"] and "<style" not in r["html"] and r["images"] == 1
    assert "summary(cars)" in r["html"]


def test_howto_quotes_exist():
    for s in howto.sections():
        for c in s["claims"]:
            assert c["line"], (c["file"], c["quote"])


@pytest.mark.skipif(not shutil.which("Rscript") or bool(os.environ.get("CI")), reason="needs R (not on CI)")
def test_r_fixture_is_current(tmp_path):
    """tests/fixtures/r_reference.json matches a fresh run of scripts/make_r_fixtures.R (floats to rtol 1e-6)."""
    out = tmp_path / "ref.json"
    subprocess.run(["Rscript", "scripts/make_r_fixtures.R", str(out)], cwd=ROOT, check=True, capture_output=True)
    _close(json.loads(out.read_text()), json.loads((ROOT / "tests/fixtures/r_reference.json").read_text()))


def _close(a, b, path="$"):
    if isinstance(a, float) or isinstance(b, float):
        assert a == pytest.approx(b, rel=1e-6, abs=1e-9), path
    elif isinstance(a, dict):
        assert set(a) == set(b), path
        for k in a:
            _close(a[k], b[k], f"{path}.{k}")
    elif isinstance(a, list):
        assert len(a) == len(b), path
        for i, (x, y) in enumerate(zip(a, b)):
            _close(x, y, f"{path}[{i}]")
    else:
        assert a == b, path


def test_close_helper():
    _close({"a": [1.0, "x"]}, {"a": [1.0 + 1e-12, "x"]})
    with pytest.raises(AssertionError):
        _close([1.0], [1.1])
