// Demo: binomial probabilities (DataCamp/probability_1.R) and mouse body weights (EdX_course/Week1_CentralLimitTheorem*.R).
import { $, api, esc, list, rng } from './core.js';
import { histogram } from './chart.js';
import { readCsv } from './r_csv.js';
import { dbinom, mean, miceSummary, pbinom, sample } from './stats_engine.js';

export async function render(root) {
  const { text } = await api('/data/mice');
  const d = readCsv(text);
  const rows = d.columns[0].map((_, i) => Object.fromEntries(d.names.map((n, j) => [n, d.columns[j][i]])));
  const S = miceSummary(rows);
  root.innerHTML = `<p class="kicker">Demo · coursework</p><h1>Binomial probabilities and mouse body weights</h1>
  <h2>Binomial (DataCamp/probability_1.R)</h2>
  <p>The script asks for the chance of exactly 5 heads in 10 fair flips, <code>dbinom(5, 10, .5)</code>, and of 4 or fewer,
    <code>pbinom(4, 10, .5)</code>. Change the numbers:</p>
  <div class="row">
    <div><label for="bx">Heads (x)</label><input id="bx" type="number" min="0" value="5"></div>
    <div><label for="bn">Flips (size)</label><input id="bn" type="number" min="1" max="1000" value="10"></div>
    <div><label for="bp">Probability of heads (prob)</label><input id="bp" type="number" min="0" max="1" step="0.01" value="0.5"></div>
  </div>
  <p id="bout" class="eq"></p>
  <h2>Mouse body weights (EdX_course, week 1)</h2>
  <p>mice_pheno.csv after <code>na.omit</code>: ${S.rows} mice. Population mean and SD (rafalib <code>popsd</code>, divides by n),
    and the share of mice within 1, 2 and 3 SD of the mean (<code>prop(q) = mean(y &lt;= q)</code>), as in
    Week1_CentralLimitTheorem_2.R. Values agree with R to 1e-9.</p>
  <div class="scroll"><table><thead><tr><th>Sex</th><th>Diet</th><th>n</th><th>Mean (g)</th><th>popsd (g)</th><th>within 1 SD</th><th>within 2 SD</th><th>within 3 SD</th></tr></thead>
  <tbody>${list(S.groups, g => `<tr><td>${g.sex}</td><td>${g.diet}</td><td>${g.n}</td><td>${g.mean.toFixed(3)}</td><td>${g.popsd.toFixed(3)}</td>
    ${g.within.map(w => `<td>${(100 * w).toFixed(1)}%</td>`).join('')}</tr>`)}</tbody></table></div>
  <h3>Sampling distribution of the mean</h3>
  <p>The script draws 10000 samples of 25 mice from one group and plots the sample means. This runs the same procedure
    with your browser's random numbers (seeded), so the values differ slightly from R's <code>set.seed(1)</code> run.</p>
  <div class="row"><div><label for="grp">Group</label><select id="grp">${list(S.groups, (g, i) => `<option value="${i}" ${g.sex === 'M' && g.diet === 'chow' ? 'selected' : ''}>${g.sex} ${g.diet}</option>`)}</select></div>
    <div><label for="ss">Sample size <b id="ssv">25</b></label><input id="ss" type="range" min="2" max="100" value="25"></div></div>
  <div id="hist"></div>`;
  const binom = () => {
    const x = Math.max(0, Math.floor(+$('#bx', root).value)), n = Math.max(1, Math.floor(+$('#bn', root).value)), p = Math.min(1, Math.max(0, +$('#bp', root).value));
    $('#bout', root).textContent = `dbinom(${x}, ${n}, ${p}) = ${dbinom(x, n, p).toPrecision(6)}    pbinom(${x}, ${n}, ${p}) = ${pbinom(x, n, p).toPrecision(6)}`;
  };
  const hist = () => {
    const g = S.groups[+$('#grp', root).value], size = Math.min(+$('#ss', root).value, g.n), r = rng(1);
    $('#ssv', root).textContent = size;
    const avgs = Array.from({ length: 10000 }, () => mean(sample(g.values, size, r)));
    $('#hist', root).innerHTML = histogram(avgs, { title: `10000 means of ${size} ${esc(g.sex)} ${esc(g.diet)} mice`, xlab: 'sample mean body weight (g)',
      marks: [{ x: g.mean, label: 'population mean', colour: '#ff6fb5' }] }) +
      `<p class="small mute">Mean of the sample means ${mean(avgs).toFixed(3)} g (population ${g.mean.toFixed(3)} g).</p>`;
  };
  ['#bx', '#bn', '#bp'].forEach(s => $(s, root).addEventListener('input', binom));
  $('#grp', root).addEventListener('change', hist); $('#ss', root).addEventListener('input', hist);
  binom(); hist();
}
