// How it works: the main analyses explained from their code, each claim linked to the line it describes.
import { api, app, esc, list, route } from './core.js';

// Data flow of SoundScience/clustering.R (inline SVG).
const FLOW = `<svg class="chart" viewBox="0 0 720 120" role="img" aria-label="Clustering pipeline: word counts, topic groups, distances, Ward tree, groups">
  ${[['word frequencies', '99 projects x 334 terms'], ['topic groups', 'rowSums -> 37 columns'], ['drop 4 outliers', '95 projects'],
    ['Euclidean dist', 'dist()'], ['Ward tree', 'hclust ward.D'], ['k groups', 'cutree(k = 12)']].map(([a, b], i) =>
    `<g transform="translate(${8 + i * 119},28)"><rect width="104" height="58" rx="6" fill="none" stroke="${['#c6ff4a', '#5aa9ff', '#ff6fb5'][i % 3]}"/>
     <text x="52" y="25" text-anchor="middle" class="lab">${a}</text><text x="52" y="44" text-anchor="middle">${b}</text></g>
     ${i < 5 ? `<path d="M${114 + i * 119},57h10" stroke="#94a3c6" marker-end="url(#ar)"/>` : ''}`).join('')}
  <defs><marker id="ar" viewBox="0 0 6 6" refX="5" refY="3" markerWidth="6" markerHeight="6" orient="auto"><path d="M0,0L6,3L0,6z" fill="#94a3c6"/></marker></defs>
</svg>`;

route('how', async () => {
  const { sections } = await api('/how');
  app().innerHTML = `<h1>How it works</h1>
  <p class="lead">What the main scripts actually do, read from their code. Each statement links to the line it
    describes in the code explorer.</p>
  ${list(sections, s => `<h2 id="${s.id}">${esc(s.title)}</h2>${s.id === 'soundscience' ? FLOW : ''}
    ${list(s.claims, c => `<div class="claim">${esc(c.text)}<br><a href="#/code/${c.id}?l=${c.line}">${esc(c.file)}:${c.line}</a>
      <code>${esc(c.quote)}</code></div>`)}`)}
  <h2>Elsewhere in the repository</h2>
  <p>The edX bioinformatics scripts (<a href="#/code?folder=EdX-Bioinformatics/R_projects/Intro">EdX-Bioinformatics/R_projects/Intro</a>)
    follow the course week by week with Bioconductor packages; most download data from NCBI or Bioconductor when run.
    The code explorer lists each script's packages, input files, functions and plots.</p>`;
});
