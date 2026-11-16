// Home: what the repository is, real counts, folders, and the demos.
import { api, app, esc, list, route } from './core.js';

const FOLDER_NOTES = {
  PCR: 'qPCR comparison of two instruments (ABI 7500 FAST vs Cepheid SmartCycler) for Salmonella detection: Ct data and plot scripts',
  SoundScience: 'Text-mining and cluster analysis of Lower Colorado River ecosystem research reports',
  'EdX-Bioinformatics': 'edX bioinformatics course: FASTA, alignment, comparative genomics, mass spec, GWAS/eQTL, microarray, RNA-seq',
  EdX_course: 'edX data-analysis course, week 1: mouse body weights and the central limit theorem',
  shiny: 'Shiny apps: earthquake and census maps, tweets, webcam; plus the RStudio Shiny tutorial files',
  leaflet: 'leaflet map demos', DataCamp: 'DataCamp probability exercise', dataOne: 'Searching the DataONE / KNB data repository',
  Puff_Project: 'RStudio project with a calcium-puff data table (listed only)',
};

route('home', async () => {
  const info = await api('/info'), s = info.stats;
  app().innerHTML = `
  <section class="hero">
    <p class="kicker">gddickinson / R_code</p>
    <h1 class="glow">R code</h1>
    <p class="lead">Assorted R scripts and notebooks: DataCamp and edX coursework, qPCR analysis, calcium-puff data,
      and Sound Science conservation work. Browse every script with its packages, inputs and plots, read how the main
      analyses work, and run ports of their calculations in the browser, checked against R.</p>
    <a class="btn" href="#/code">Browse the code</a><a class="btn alt" href="#/demo/clustering">Clustering demo</a>
    <a class="btn alt" href="#/how">How it works</a>
  </section>
  <div class="tiles">
    <div class="tile"><b>${s.r_scripts}</b><span>R scripts</span></div>
    <div class="tile"><b>${s.r_lines.toLocaleString()}</b><span>lines of R shown</span></div>
    <div class="tile"><b>${s.data_files}</b><span>data files</span></div>
    <div class="tile"><b>${s.shiny_apps}</b><span>Shiny apps</span></div>
    <div class="tile"><b>${s.files}</b><span>files in ${s.folders} folders</span></div>
  </div>
  <h2>Interactive demos</h2>
  <div class="grid wide">
    <a class="card" href="#/demo/clustering"><b>Clustering research projects</b><small>SoundScience/clustering.R</small>
      <span>Ward hierarchical clustering of 95 projects by 37 topic groups, with a dendrogram you can cut into k groups. Matches R's hclust exactly.</span></a>
    <a class="card" href="#/demo/pcr"><b>qPCR Ct plots</b><small>PCR/Plot*.R</small>
      <span>The six figure scripts redrawn from their committed Ct tables: two instruments, two assays, ten serotypes.</span></a>
    <a class="card" href="#/demo/stats"><b>Binomial and mouse weights</b><small>DataCamp, EdX_course</small>
      <span>dbinom / pbinom, and mouse body-weight means, population SDs and the 1-2-3 SD rule by sex and diet.</span></a>
  </div>
  <h2>Folders</h2>
  <div class="grid">${list(info.folders, f => `<a class="card" href="#/code?folder=${encodeURIComponent(f.name)}"><b>${esc(f.name)}</b>
    <small>${f.files} files · ${f.r} R scripts</small><span>${esc(FOLDER_NOTES[f.name] || '')}</span></a>`)}</div>`;
});
