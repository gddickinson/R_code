// Small SVG chart helpers (no dependencies): scatter plots with linear or log axes, and a histogram.
import { esc } from './core.js';

const nice = (lo, hi, n = 6) => {
  const step0 = (hi - lo) / n, mag = 10 ** Math.floor(Math.log10(step0)), r = step0 / mag;
  const step = (r < 1.5 ? 1 : r < 3 ? 2 : r < 7 ? 5 : 10) * mag, out = [];
  for (let v = Math.ceil(lo / step) * step; v <= hi + 1e-9; v += step) out.push(+v.toFixed(10));
  return out;
};

export function symbol(kind, x, y, colour, r = 5) {
  const fill = kind.endsWith('-open') ? 'none' : colour, stroke = colour, k = kind.replace('-open', '');
  if (k === 'square') return `<rect x="${x - r}" y="${y - r}" width="${2 * r}" height="${2 * r}" fill="${fill}" stroke="${stroke}" stroke-width="1.5"/>`;
  if (k === 'triangle') return `<path d="M${x},${y - r * 1.2}L${x + r * 1.1},${y + r * 0.8}L${x - r * 1.1},${y + r * 0.8}Z" fill="${fill}" stroke="${stroke}" stroke-width="1.5"/>`;
  return `<circle cx="${x}" cy="${y}" r="${r}" fill="${fill}" stroke="${stroke}" stroke-width="1.5"/>`;
}

// pts: [{x, y, colour, symbol, title}]; opt: { xlog, xlim, ylim, xlab, ylab, xticks: [[v, label]], title, rotate }
export function scatter(pts, opt) {
  const W = 720, H = 420, L = 56, R = 16, T = 30, B = opt.rotate ? 110 : 48;
  const fx = opt.xlog ? Math.log10 : v => v;
  const [x0, x1] = opt.xlim.map(fx), [y0, y1] = opt.ylim;
  const X = v => L + ((fx(v) - x0) / (x1 - x0)) * (W - L - R), Y = v => H - B - ((v - y0) / (y1 - y0)) * (H - T - B);
  const yt = nice(y0, y1);
  const xt = opt.xticks || nice(opt.xlim[0], opt.xlim[1]).map(v => [v, String(v)]);
  return `<svg class="chart" viewBox="0 0 ${W} ${H}" role="img" aria-label="${esc(opt.title || 'chart')}">
    <text x="${W / 2}" y="18" class="ct" text-anchor="middle">${esc(opt.title || '')}</text>
    <rect x="${L}" y="${T}" width="${W - L - R}" height="${H - T - B}" class="frame"/>
    ${yt.map(v => `<line x1="${L}" x2="${W - R}" y1="${Y(v)}" y2="${Y(v)}" class="grid"/><text x="${L - 6}" y="${Y(v) + 4}" text-anchor="end">${v}</text>`).join('')}
    ${xt.map(([v, lab]) => `<line x1="${X(v)}" x2="${X(v)}" y1="${H - B}" y2="${H - B + 5}" class="axis"/>${opt.rotate
      ? `<text transform="translate(${X(v) + 4},${H - B + 10}) rotate(-60)" text-anchor="end">${esc(lab)}</text>`
      : `<text x="${X(v)}" y="${H - B + 18}" text-anchor="middle">${esc(lab)}</text>`}`).join('')}
    <text x="${(L + W - R) / 2}" y="${H - 6}" text-anchor="middle" class="lab">${esc(opt.xlab || '')}</text>
    <text transform="translate(14,${(T + H - B) / 2}) rotate(-90)" text-anchor="middle" class="lab">${esc(opt.ylab || '')}</text>
    ${pts.map(p => `<g>${symbol(p.symbol || 'circle', X(p.x), Y(p.y), p.colour)}<title>${esc(p.title || '')}</title></g>`).join('')}
  </svg>`;
}

// Histogram of values with `bins` equal-width bins; marks: [{x, label, colour}] drawn as vertical lines.
export function histogram(values, { bins = 30, title = '', xlab = '', marks = [] } = {}) {
  const lo = Math.min(...values), hi = Math.max(...values), w = (hi - lo) / bins || 1;
  const counts = Array(bins).fill(0);
  values.forEach(v => counts[Math.min(bins - 1, Math.floor((v - lo) / w))]++);
  const W = 720, H = 300, L = 48, R = 16, T = 28, B = 44, top = Math.max(...counts);
  const X = v => L + ((v - lo) / (hi - lo || 1)) * (W - L - R), Y = c => H - B - (c / top) * (H - T - B);
  return `<svg class="chart" viewBox="0 0 ${W} ${H}" role="img" aria-label="${esc(title)}">
    <text x="${W / 2}" y="18" class="ct" text-anchor="middle">${esc(title)}</text>
    ${counts.map((c, i) => `<rect x="${X(lo + i * w) + 0.5}" y="${Y(c)}" width="${Math.max(0, X(lo + (i + 1) * w) - X(lo + i * w) - 1)}" height="${H - B - Y(c)}" class="bar"/>`).join('')}
    ${nice(lo, hi).map(v => `<text x="${X(v)}" y="${H - B + 16}" text-anchor="middle">${v}</text>`).join('')}
    ${marks.map(m => `<line x1="${X(m.x)}" x2="${X(m.x)}" y1="${T}" y2="${H - B}" stroke="${m.colour}" stroke-width="2"/><text x="${X(m.x) + 4}" y="${T + 12}" fill="${m.colour}">${esc(m.label)}</text>`).join('')}
    <text x="${(L + W - R) / 2}" y="${H - 6}" text-anchor="middle" class="lab">${esc(xlab)}</text>
  </svg>`;
}
