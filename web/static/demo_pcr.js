// Demo: the PCR figure scripts redrawn from their committed Ct tables (pcr_engine.js).
import { $, api, esc, list } from './core.js';
import { scatter, symbol } from './chart.js';
import { PLOTS, points } from './pcr_engine.js';

const CSS = { yellow: '#e6d200', grey: '#9aa5c4', black: '#e8f1ff', white: '#e8f1ff', brown: '#c58b4c', purple: '#b28cff', blue: '#5aa9ff', red: '#ff5c7a', green: '#3dff8f', orange: '#ff9f3d', pink: '#ff8fc8' };
const c = name => CSS[name] || name;

export async function render(root, query) {
  const files = [...new Set(PLOTS.flatMap(p => p.files))];
  const texts = Object.fromEntries(await Promise.all(files.map(async f => [f, (await api('/data/pcr-' + f)).text])));
  const id = PLOTS.some(p => p.id === query.p) ? query.p : 'plot2a';
  root.innerHTML = `<p class="kicker">Demo · PCR/Plot*.R</p><h1>qPCR Ct plots: SmartCycler vs ABI 7500</h1>
  <p class="lead">The six figure scripts of the instrument comparison, redrawn from the same CSV tables. A lower Ct means
    the target was detected earlier (more template). The scripts compare raw Ct values; they contain no efficiency or
    delta-delta-Ct calculation, so none is shown here.</p>
  <div class="seg" role="tablist">${list(PLOTS, p => `<button type="button" data-p="${p.id}" class="${p.id === id ? 'on' : ''}">${p.id.replace('plot', 'Plot ')}</button>`)}</div>
  <div id="plot"></div>`;
  const draw = pid => {
    const plot = PLOTS.find(p => p.id === pid), r = points(plot, texts);
    const xs = r.xticks.map(t => t[0]);
    const xlim = r.xlog ? [Math.min(...xs) / 1.6, Math.max(...xs) * 1.6] : [0.5, xs.length + 0.5];
    $('#plot', root).innerHTML = `
      ${scatter(r.pts.map(p => ({ ...p, colour: c(p.colour), title: `${p.series}: ${p.label} Ct ${p.y}` })),
        { title: plot.title, xlog: r.xlog, xlim, ylim: plot.ylim, xlab: r.xlab, ylab: 'Ct', xticks: r.xticks, rotate: !r.xlog })}
      <div class="legend">${list(r.legend, l => `<span><svg width="14" height="14" aria-hidden="true">${symbol(l.symbol, 7, 7, c(l.colour), 5)}</svg>${esc(l.text)}</span>`)}</div>
      <p class="small mute">Script: <a href="#/code/${plot.script.replace(/\//g, '__')}">${esc(plot.script)}</a> · data:
        ${plot.files.map(f => `<a href="#/code/PCR__${f}">${esc(f)}</a>`).join(', ')} · ${r.pts.length} points inside Ct ${plot.ylim.join('-')}
        (a Ct of 0 or a blank cell means no amplification and is not drawn, as in R).</p>`;
  };
  root.querySelectorAll('[data-p]').forEach(b => b.addEventListener('click', () => {
    root.querySelectorAll('[data-p]').forEach(x => x.classList.toggle('on', x === b));
    history.replaceState(null, '', '#/demo/pcr?p=' + b.dataset.p);
    draw(b.dataset.p);
  }));
  draw(id);
}
