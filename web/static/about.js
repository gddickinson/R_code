// About: what the repository is, how the site is made, what is not shown, how to run it.
import { api, app, route } from './core.js';

route('about', async () => {
  const s = (await api('/info')).stats;
  app().innerHTML = `<h1>About</h1>
  <p class="lead">R_code is George Dickinson's collection of assorted R scripts and notebooks: DataCamp and edX
    coursework, a qPCR instrument comparison, calcium-puff data and Sound Science conservation work (MIT licence).
    This site shows the repository; it does not change or run the R code.</p>
  <h2>How the site is made</h2>
  <ul>
    <li>The code explorer lists ${s.files} files. For R scripts it shows the header comment, packages, files read,
      functions defined, plotting calls and Shiny inputs and outputs, all read from the script's text.</li>
    <li>The committed R Markdown report (test.html) is shown as text and its embedded figure only: scripts and styles are removed.</li>
    <li>The demos are JavaScript ports of calculations that are in the scripts (Ward clustering, the PCR figures,
      dbinom/pbinom, popsd and the SD rule). Node tests compare them with values R computed from the same scripts and
      data (<code>Rscript scripts/make_r_fixtures.R</code>).</li>
  </ul>
  <h2>What is not shown</h2>
  <ul>
    <li>User names in home-folder paths (<code>C:\\Users\\&lt;user&gt;</code>, <code>/home/&lt;user&gt;</code>) and e-mail
      addresses are replaced in everything shown.</li>
    <li>The RStudio Shiny tutorial files (shiny/shiny.rstudio.com-tutorial-master) are third-party without a licence
      statement: listed only. The Bootswatch theme (MIT) is listed with its licence.</li>
    <li>Spreadsheets, Word documents, R workspaces and histories, RStudio session folders, and files over 200 kB
      (including the calcium-puff table) are listed or omitted, not shown.</li>
    <li>Course material (edX, DataCamp) is George's own exercise code and is shown; no file in the repository restricts
      redistribution.</li>
  </ul>
  <h2>Running the R code</h2>
  <p>Each script is standalone. Most start with <code>setwd()</code> pointing at the author's own folders: change it to
    the folder holding the data. Packages used are listed on each script's page (base R for the PCR plots; ape,
    phytools, cluster, qgraph, mclust for SoundScience; seqinr, Biostrings and other Bioconductor packages for the edX
    bioinformatics course; shiny and leaflet for the apps).</p>
  <h2>Run this site locally</h2>
  <pre>pip install -r requirements-web.txt
python run_web.py            # http://127.0.0.1:8254</pre>
  <p>The static copy for GitHub Pages is built by <code>scripts/build_static.py</code> and published by
    <code>.github/workflows/pages.yml</code> on every push to master.</p>`;
});
