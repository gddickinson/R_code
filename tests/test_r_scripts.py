"""Regression tests for the PCR plot scripts, run with R itself (skipped when Rscript is not installed or on CI).

tests/r_plot_harness.R runs a script on a null device and reports what it drew and which warnings R gave.
"""
import json
import os
import shutil
import subprocess
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parent.parent
pytestmark = pytest.mark.skipif(not shutil.which("Rscript") or os.environ.get("CI"), reason="needs R (not on CI)")


def run(script: str) -> dict:
    r = subprocess.run(["Rscript", "tests/r_plot_harness.R", f"PCR/{script}"], cwd=ROOT, capture_output=True, text=True)
    assert r.returncode == 0, r.stderr
    return json.loads(r.stdout.strip().splitlines()[-1])


SEROTYPE_SCRIPTS = ["Plot1a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_OriC.R",
                    "Plot1b_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_gfp.R",
                    "Plot3a_Non-Salmonella_dilutions_series_SmartCycler_vs_ABI7500_OriC.R", "dotPlot_PCR_data.R"]


@pytest.mark.parametrize("script", SEROTYPE_SCRIPTS)
def test_serotype_plots_draw_their_points(script):
    """With R >= 4 read.csv returns serotype names as text; using them as x drew nothing ('NAs introduced by
    coercion') and the misspelt xact= left the numeric axis in place."""
    out = run(script)
    assert not [w for w in out["warnings"] if "coercion" in w or "graphical parameter" in w], out["warnings"]
    drawn = sum(c["n"] for c in out["calls"])
    assert drawn >= 40, drawn


@pytest.mark.parametrize("script", ["Plot2a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_oric.R",
                                    "Plot2b_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_gfp.R"])
def test_dilution_plots_draw_abi_enterica(script):
    """The ABI 7500 series (squares, pch 15) left out S. enterica (red)."""
    out = run(script)
    abi = [c for c in out["calls"] if c["pch"] == 15 and c["kind"] == "points" and isinstance(c["col"], str)]  # not legend keys
    assert len(abi) == 10 and any(c["col"] == "red" for c in abi)


def test_plot2a_legend_symbols_match_points():
    """Plot2a's legend gave SmartCycler the square and ABI 7500 the circle: the opposite of the points."""
    out = run("Plot2a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_oric.R")
    sym = {c["col"] + str(c["pch"]) for c in out["calls"]}
    smart = next(c for c in out["calls"] if c["kind"] == "plot")["pch"]
    leg = out["legends"][-1]
    assert dict(zip(leg["legend"], leg["pch"]))["SmartCycler"] == smart
    assert dict(zip(leg["legend"], leg["pch"]))["ABI 7500"] == 15 and "red15" in sym
