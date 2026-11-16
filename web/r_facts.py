"""Facts read from an R script's text (no R needed): header comment, packages, data files read, functions defined,
plotting calls and, for Shiny apps, the inputs and outputs. Only what is literally in the file."""
import re

LIB = re.compile(r"^\s*(?:library|require|requireNamespace)\(\s*['\"]?([\w.]+)", re.M)
READ = re.compile(r"\b(read\.csv|read\.table|read\.delim|read\.fasta|read\.xls|read_excel|read\.alignment|readRDS|"
                  r"st_read|readOGR|fread|read_csv|load|read\.GenBank|readLines)\(\s*(?:file\s*=\s*)?(['\"]([^'\"]+)['\"]|[\w.$]+)")
FUNC = re.compile(r"^\s*([\w.]+)\s*(?:<-|=)\s*function\s*\(", re.M)
PLOT = re.compile(r"\b(plot|hist|barplot|boxplot|ggplot|qqnorm|heatmap|image|clusplot|leaflet|plot_ly|pairs|matplot)\s*\(")
SHINY_IN = re.compile(r"\b(\w+Input|\w+Button|checkboxGroupInput|radioButtons|sliderInput|selectInput|dateRangeInput)\(\s*(?:inputId\s*=\s*)?['\"]([\w.]+)['\"]")
SHINY_OUT = re.compile(r"output\$([\w.]+)\s*<-\s*(render\w+)")


def header(text: str, max_lines: int = 4) -> str:
    """The prose comment at the top of the file (commented-out code such as '#install.packages(...)' skipped)."""
    out = []
    for line in text.splitlines()[:40]:
        s = line.strip()
        if not s:
            if out:
                break
            continue
        if not s.startswith("#"):
            break
        body = s.lstrip("#").strip()
        if not body or re.match(r"^[\w.$:]+\s*(\(|<-|=)|^https?://", body) or set(body) <= set("#-=*_ "):
            continue
        out.append(body)
        if len(out) >= max_lines:
            break
    return " ".join(out)


def facts(text: str) -> dict:
    code = "\n".join(l for l in text.splitlines() if not l.lstrip().startswith("#"))
    reads = []
    for m in READ.finditer(code):
        target = m.group(3) or m.group(2)
        if target not in reads:
            reads.append(target)
    return {
        "summary": header(text),
        "packages": sorted(set(LIB.findall(code))),
        "reads": reads[:20],
        "functions": sorted(set(FUNC.findall(code))),
        "plots": len(PLOT.findall(code)),
        "shiny_inputs": sorted({f"{k}:{v}" for k, v in SHINY_IN.findall(code)}),
        "shiny_outputs": sorted({f"{k}:{v}" for k, v in SHINY_OUT.findall(code)}),
    }
