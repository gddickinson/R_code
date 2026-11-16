"""Make a committed HTML report (knitted R Markdown, tutorial pages) safe to show inside the site.

Scripts, styles, event handlers, iframes and forms are dropped; only a whitelist of structural tags is kept; images
are kept only when embedded (data:image/png|jpeg|gif|svg+xml) and links only when they are http(s). The result is
plain HTML that the page inserts into a container, so nothing from the report can run.
"""
from html import escape
from html.parser import HTMLParser

KEEP = {"h1", "h2", "h3", "h4", "h5", "h6", "p", "pre", "code", "em", "strong", "b", "i", "ul", "ol", "li", "table",
        "thead", "tbody", "tr", "th", "td", "blockquote", "br", "hr", "img", "a", "div", "span", "sub", "sup"}
DROP_CONTENT = {"script", "style", "noscript", "iframe", "object", "embed", "template", "head", "title", "svg", "form"}
VOID = {"br", "hr", "img"}
IMG_PREFIX = ("data:image/png;", "data:image/jpeg;", "data:image/gif;", "data:image/svg+xml;")


class _Clean(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.out, self.skip, self.images = [], 0, 0

    def handle_starttag(self, tag, attrs):
        if tag in DROP_CONTENT:
            self.skip += 1
            return
        if self.skip or tag not in KEEP:
            return
        a = dict(attrs)
        if tag == "img":
            src = a.get("src") or ""
            if src.startswith(IMG_PREFIX):
                self.images += 1
                self.out.append(f'<img src="{escape(src)}" alt="{escape(a.get("alt") or "figure from the report")}">')
            return
        if tag == "a":
            href = a.get("href") or ""
            self.out.append(f'<a href="{escape(href)}" target="_blank" rel="noopener">' if href.startswith(("http://", "https://")) else "<a>")
            return
        self.out.append(f"<{tag}>")

    def handle_endtag(self, tag):
        if tag in DROP_CONTENT:
            self.skip = max(0, self.skip - 1)
            return
        if not self.skip and tag in KEEP and tag not in VOID:
            self.out.append(f"</{tag}>")

    def handle_data(self, data):
        if not self.skip:
            self.out.append(escape(data))


def clean(html: str) -> dict:
    """{'html': sanitised body, 'images': number of embedded images kept}."""
    p = _Clean()
    p.feed(html)
    p.close()
    return {"html": "".join(p.out).strip(), "images": p.images}
