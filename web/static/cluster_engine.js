// Port of SoundScience/clustering.R (deterministic part): combine search-term columns into topic groups
// (lines 33-80, combined at line 91), Euclidean distances (dist), Ward clustering (hclust method = "ward.D", R's Fortran hclust.f with
// its nearest-neighbour list and hcass2 merge/order), cutree(k), and a dendrogram layout. Checked against R in
// engines.test.mjs (tests/fixtures/r_reference.json from scripts/make_r_fixtures.R). K-means is not ported: it is
// random-start, so its clusters change from run to run even in R.
import { readCsv } from './r_csv.js';

// Topic groups exactly as clustering.R builds data_combined (line 91 order); [script line, terms].
export const GROUPS = {
  birds: [33, ['avian', 'woodpecker', 'bird', 'warbler', 'tanager', 'cuckoo', 'owl', 'flycatcher', 'flicker', 'vireo', 'quail', 'blackbird', 'starling', 'dove', 'migrants', 'waterbirds', 'shorebirds', 'yellow.billed']],
  fish: [34, ['fish', 'pikeminnow', 'razorback', 'rasu', 'flannelmouth', 'humpback', 'chub', 'bonytail', 'rainbow', 'trout', 'catfish', 'bass']],
  plants: [35, ['deciduous', 'weed', 'plant', 'tree', 'shrub', 'willow', 'quailbush', 'cedar', 'mesquite', 'arrowweed', 'cottonwood', 'cottonwood.willow', 'milkvetch', 'buckwheat', 'saltcedar', 'saltgrass', 'tamarisk']],
  insects: [36, ['butterfly', 'insect', 'sootywing']],
  bats: [37, ['bat']],
  amphibians: [38, ['amphibian', 'frog']],
  fishTracking: [59, ['submersible', 'sherman', 'fyke', 'electrofishing', 'sur', 'hydrophone', 'pit', 'trammel', 'implantation', 'boat']],
  birdTracking: [60, ['call.playback', 'banded', 'banding', 'mist.netting', 'vocalization', 'singing', 'band']],
  birdPlumage: [61, ['display', 'plumage', 'colorimeter']],
  trapping: [62, ['hoop', 'trapping', 'trap', 'capture', 'captured', 'release', 'mark', 'recapture', 'mark.recapture', 'netting', 'netted']],
  tracking: [63, ['tag', 'telemetry', 'track', 'tracking', 'passive', 'active', 'transponder', 'transmitters', 'tagging', 'tagged', 'acoustic', 'sonic']],
  physiology: [64, ['physiology', 'physiological', 'growth', 'mass', 'height', 'weight', 'weighed', 'disease', 'aging', 'sexed', 'tissue', 'cell', 'microscope', 'mortality']],
  fishPhysiology: [65, ['pectoral', 'fin', 'swim', 'swimming']],
  waterChemistry: [66, ['depth', 'oxygen', 'nitrogen', 'carbon', 'potassium', 'phosphorous', 'ammonia', 'salinity', 'nitrate', 'nitrite', 'acid', 'alkalinity', 'arsenic', 'selenium', 'conductivity', 'turbidity']],
  soilChemistry: [67, ['pozzolan', 'lassenite', 'humidity', 'limnological', 'hydrology', 'hydrological']],
  gis: [68, ['gis', 'satellite', 'map', 'mapping']],
  hatchery: [69, ['hatchery.reared', 'post.stocking', 'translocation', 'broodstock', 'repatriation', 'stocking', 'spawning']],
  populationStats: [70, ['distribution', 'demography', 'absence', 'presence', 'population', 'diversity', 'anova', 'sampling', 'double.sampling', 'transect', 'survivorship', 'colonization', 'survival', 'recruitment']],
  genetic: [71, ['genetic', 'dna', 'mtdna', 'microsatellites', 'haplotype', 'dimorphism', 'taxonomic']],
  restoration: [72, ['evaluation', 'study', 'conservation', 'development', 'plan', 'outreach', 'restoration', 'planting', 'clearing', 'monitoring']],
  photography: [73, ['video', 'photo', 'photograph', 'photography', 'orthophotography', 'imaging']],
  predation: [74, ['predation', 'predator', 'prey', 'foraging']],
  breeding: [75, ['nest', 'nesting', 'eggs', 'breeding', 'propagation']],
  transport: [76, ['transport', 'handling', 'management']],
  diet: [77, ['diet']],
  biologicalMeasures: [78, ['biomass', 'density', 'moisture', 'temperature', 'toxicity', 'abiotic', 'habitat']],
  survey: [79, ['survey', 'search', 'sampled', 'aerial', 'visual', 'helicopter']],
  fertilizer: [80, ['fertilization', 'fertilizer']],
  river: [44, ['reach', 'river', 'tributary', 'tributaries', 'spring', 'freshwater', 'riparian', 'channel']],
  laboratory: [45, ['impoundment', 'raceway', 'tank', 'laboratory', 'hatchery']],
  reservoir: [47, ['reservoir', 'sediment', 'dam', 'pond']],
  lake: [46, ['shore', 'lake']],
  marsh: [48, ['flood', 'floodplain', 'wetland', 'backwater']],
  woodland: [49, ['herbaceous', 'woody', 'woodlands', 'canopy', 'understory', 'wildfire', 'forest', 'foliage']],
  agricultural: [50, ['agricultural', 'soil', 'crop', 'irrigation', 'ditch', 'reclamation', 'sediment', 'drainage']],
  mines: [51, ['mine']],
  roosts: [52, ['roost', 'roosting']],
};
export const OUTLIERS = ['c39', 'e14', 'e27', 'e18'];   // clustering.R line 98

// Group sums per project: { rows, groups, X } (X[i][g] = sum of that group's term columns for project i).
export function combine(csvText, groups = Object.keys(GROUPS), drop = OUTLIERS) {
  const d = readCsv(csvText, { rowNames: true });
  const col = Object.fromEntries(d.names.map((n, j) => [n, d.columns[j]]));
  const keep = d.rownames.map((r, i) => i).filter(i => !drop.includes(d.rownames[i]));
  const X = keep.map(i => groups.map(g => GROUPS[g][1].reduce((a, t) => {
    if (!(t in col)) throw new Error(`column ${t} missing`);
    return a + col[t][i];
  }, 0)));
  return { rows: keep.map(i => d.rownames[i]), groups, X };
}

// Lower-triangle Euclidean distances; D(i,j) via idx(i,j) with i < j (0-based), like R's dist object.
export function dist(X) {
  const n = X.length, D = new Float64Array(n * (n - 1) / 2);
  for (let i = 0; i < n; i++) for (let j = i + 1; j < n; j++) {
    let s = 0;
    for (let k = 0; k < X[i].length; k++) { const v = X[i][k] - X[j][k]; s += v * v; }
    D[idx(n, i, j)] = Math.sqrt(s);
  }
  return D;
}
const idx = (n, i, j) => j + i * n - ((i + 1) * (i + 2)) / 2;   // 0-based IOFFST

// hclust(d, method = "ward.D"): returns { merge: [[a,b]...] (R signs: -obs, +step), height, order (1-based) }.
export function hclustWardD(D, n) {
  D = Float64Array.from(D);
  const flag = Array(n).fill(true), membr = Array(n).fill(1), nn = Array(n).fill(0), disnn = Array(n).fill(Infinity);
  const ia = [], ib = [], crit = [];
  for (let i = 0; i < n - 1; i++) {
    let dmin = Infinity, jm = 0;
    for (let j = i + 1; j < n; j++) if (D[idx(n, i, j)] < dmin) { dmin = D[idx(n, i, j)]; jm = j; }
    nn[i] = jm; disnn[i] = dmin;
  }
  for (let ncl = n; ncl > 1;) {
    let dmin = Infinity, im = 0, jm = 0;
    for (let i = 0; i < n - 1; i++) if (flag[i] && disnn[i] < dmin) { dmin = disnn[i]; im = i; jm = nn[i]; }
    ncl--;
    const i2 = Math.min(im, jm), j2 = Math.max(im, jm);
    ia.push(i2); ib.push(j2); crit.push(dmin);
    flag[j2] = false;
    dmin = Infinity; let jj = 0;
    const xx = D[idx(n, i2, j2)];
    for (let k = 0; k < n; k++) {
      if (!flag[k] || k === i2) continue;
      const i1 = i2 < k ? idx(n, i2, k) : idx(n, k, i2), ind2 = j2 < k ? idx(n, j2, k) : idx(n, k, j2);
      D[i1] = ((membr[i2] + membr[k]) * D[i1] + (membr[j2] + membr[k]) * D[ind2] - membr[k] * xx) / (membr[i2] + membr[j2] + membr[k]);
      if (i2 < k) { if (D[i1] < dmin) { dmin = D[i1]; jj = k; } }
      else if (D[i1] < disnn[k]) { disnn[k] = D[i1]; nn[k] = i2; }
    }
    membr[i2] += membr[j2]; disnn[i2] = dmin; nn[i2] = jj;
    for (let i = 0; i < n - 1; i++) {
      if (flag[i] && (nn[i] === i2 || nn[i] === j2)) {
        let dm = Infinity, j3 = 0;
        for (let j = i + 1; j < n; j++) if (flag[j] && D[idx(n, i, j)] < dm) { dm = D[idx(n, i, j)]; j3 = j; }
        nn[i] = j3; disnn[i] = dm;
      }
    }
  }
  return { ...hcass2(n, ia.map(v => v + 1), ib.map(v => v + 1)), height: crit };
}

// R's hcass2: cluster numbers -> merge matrix in R's convention, and the leaf order for plotting.
function hcass2(n, ia, ib) {
  const iia = ia.slice(), iib = ib.slice();
  for (let i = 0; i < n - 2; i++) {
    const k = Math.min(ia[i], ib[i]);
    for (let j = i + 1; j < n - 1; j++) { if (ia[j] === k) iia[j] = -(i + 1); if (ib[j] === k) iib[j] = -(i + 1); }
  }
  for (let i = 0; i < n - 1; i++) { iia[i] = -iia[i]; iib[i] = -iib[i]; }
  for (let i = 0; i < n - 1; i++) {
    if (iia[i] > 0 && iib[i] < 0) { const k = iia[i]; iia[i] = iib[i]; iib[i] = k; }
    if (iia[i] > 0 && iib[i] > 0) { const k1 = Math.min(iia[i], iib[i]), k2 = Math.max(iia[i], iib[i]); iia[i] = k1; iib[i] = k2; }
  }
  const order = [iia[n - 2], iib[n - 2]];
  for (let i = n - 2; i >= 1; i--) {
    const j = order.indexOf(i);
    if (j >= 0) order.splice(j, 1, iia[i - 1], iib[i - 1]);
  }
  return { merge: iia.map((a, i) => [a, iib[i]]), order: order.map(v => -v) };
}

// cutree(tree, k): group of each observation, groups numbered in order of first appearance (as R does).
export function cutree(merge, n, k) {
  const parent = Array.from({ length: n }, (_, i) => i);
  const find = i => (parent[i] === i ? i : (parent[i] = find(parent[i])));
  const rep = [];
  for (let s = 0; s < n - k; s++) {
    const [a, b] = merge[s].map(v => (v < 0 ? -v - 1 : rep[v - 1]));
    parent[find(b)] = find(a); rep.push(find(a));
  }
  for (let s = n - k; s < n - 1; s++) rep.push(null);
  const label = new Map();
  return Array.from({ length: n }, (_, i) => { const r = find(i); if (!label.has(r)) label.set(r, label.size + 1); return label.get(r); });
}

// Dendrogram coordinates: leaf x = position in order (0..n-1); each merge gets {x, y, a, b} (children's x/y).
export function layout(tree, n) {
  const pos = new Map(tree.order.map((obs, i) => [obs, i]));
  const nodes = [];
  const at = v => (v < 0 ? { x: pos.get(-v), y: 0 } : nodes[v - 1]);
  tree.merge.forEach(([a, b], s) => {
    const A = at(a), B = at(b);
    nodes.push({ x: (A.x + B.x) / 2, y: tree.height[s], a: A, b: B });
  });
  return nodes;
}
