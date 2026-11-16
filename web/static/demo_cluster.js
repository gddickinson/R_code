// Demo: SoundScience/clustering.R in the browser: topic groups -> Euclidean distances -> Ward (ward.D) -> cutree(k).
import { $, api, esc, list } from './core.js';
import { combine, cutree, dist, GROUPS, hclustWardD, layout, OUTLIERS } from './cluster_engine.js';

const PALETTE = ['#c6ff4a', '#5aa9ff', '#ff6fb5', '#ffd23f', '#3dffd2', '#ff8a3d', '#b28cff', '#ff5c7a', '#7cff6b', '#2ee6ff', '#ff4fd8', '#e8f1ff', '#9aa5c4', '#ffb347', '#64d9a8'];

function dendrogram(tree, rows, groups) {
  const n = rows.length, nodes = layout(tree, n), W = 720, H = 360, L = 40, R = 10, T = 14, B = 64;
  const top = tree.height.at(-1), X = x => L + (x / (n - 1)) * (W - L - R), Y = y => H - B - (y / top) * (H - T - B);
  const colourOf = new Map();
  tree.order.forEach(obs => colourOf.set(obs, PALETTE[(groups[obs - 1] - 1) % PALETTE.length]));
  const seg = (A, node) => `M${X(A.x)},${Y(A.y)}V${Y(node.y)}`;
  const paths = nodes.map(nd => `<path class="branch" d="${seg(nd.a, nd)}${seg(nd.b, nd).replace('M', 'M')}M${X(nd.a.x)},${Y(nd.y)}H${X(nd.b.x)}"/>`).join('');
  const leaves = tree.order.map((obs, i) => `<g><circle cx="${X(i)}" cy="${Y(0)}" r="3" fill="${colourOf.get(obs)}"/>
    <text transform="translate(${X(i) + 3},${H - B + 8}) rotate(-90)" text-anchor="end" style="font-size:8px">${esc(rows[obs - 1])}</text>
    <title>${esc(rows[obs - 1])}: group ${groups[obs - 1]}</title></g>`).join('');
  return `<svg class="chart" viewBox="0 0 ${W} ${H}" role="img" aria-label="Dendrogram of ${n} projects">
    <text x="${L - 6}" y="${Y(top) + 4}" text-anchor="end">${top.toFixed(0)}</text><text x="${L - 6}" y="${Y(0) + 4}" text-anchor="end">0</text>
    <text transform="translate(12,${(H - B) / 2}) rotate(-90)" text-anchor="middle" class="lab">height (ward.D)</text>${paths}${leaves}</svg>`;
}

export async function render(root) {
  const { text } = await api('/data/soundscience');
  root.innerHTML = `<p class="kicker">Demo · SoundScience/clustering.R</p><h1>Clustering research projects by vocabulary</h1>
  <p class="lead">Each research project's word frequencies are summed into ${Object.keys(GROUPS).length} topic groups, then
    the projects are clustered with Ward's method on Euclidean distances, exactly as the script does with
    <code>dist()</code>, <code>hclust(method = "ward.D")</code> and <code>cutree()</code>. The JavaScript port reproduces
    R's merge order, heights and groups to 1e-9 (tested against R 4.4.1).</p>
  <div class="row">
    <div><label for="k">Number of groups (cutree k) <b id="kv">12</b></label><input id="k" type="range" min="2" max="15" value="12"></div>
    <div><label><input type="checkbox" id="drop" checked> Drop the script's four outlying projects (${OUTLIERS.join(', ')})</label></div>
  </div>
  <div id="dendro"></div><div id="groups"></div>
  <p class="small mute">Not ported: the script's k-means runs (random starts, so their groups change between runs even in R)
    and the clusplot / phylogram figures. Data: SoundScience/data_habitat_speciesNames.csv from the repository.</p>`;
  const k = $('#k', root), drop = $('#drop', root);
  let state = null;
  const build = () => {
    const C = combine(text, undefined, drop.checked ? OUTLIERS : []);
    state = { C, tree: hclustWardD(dist(C.X), C.rows.length) };
  };
  const draw = () => {
    const { C, tree } = state, kk = +k.value, g = cutree(tree.merge, C.rows.length, kk);
    $('#kv', root).textContent = kk;
    $('#dendro', root).innerHTML = dendrogram(tree, C.rows, g);
    const members = Array.from({ length: kk }, (_, i) => C.rows.filter((_, j) => g[j] === i + 1));
    // the three topic groups with the largest mean in each cluster, from the clustered table itself
    const tops = members.map((_, i) => {
      const idx = C.rows.map((_, j) => j).filter(j => g[j] === i + 1);
      const means = C.groups.map((name, c) => [name, idx.reduce((a, j) => a + C.X[j][c], 0) / idx.length]);
      return means.sort((a, b) => b[1] - a[1]).slice(0, 3);
    });
    $('#groups', root).innerHTML = `<h2>${kk} groups</h2><div class="scroll"><table><thead><tr><th>Group</th><th>Projects</th><th>Highest topic groups (mean word-frequency score)</th></tr></thead><tbody>
      ${list(members, (m, i) => `<tr><td><span style="color:${PALETTE[i % PALETTE.length]}">●</span> ${i + 1}</td><td class="small mono">${esc(m.join(', '))}</td>
        <td class="small">${tops[i].map(([nm, v]) => `${esc(nm)} ${v.toFixed(4)}`).join(', ')}</td></tr>`)}</tbody></table></div>`;
  };
  build(); draw();
  k.addEventListener('input', draw);
  drop.addEventListener('change', () => { build(); draw(); });
}
