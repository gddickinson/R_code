// Node tests: the JavaScript ports against values R computed from the same scripts and data
// (tests/fixtures/r_reference.json, written by `Rscript scripts/make_r_fixtures.R`). Run: node web/static/engines.test.mjs
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { combine, cutree, dist, GROUPS, hclustWardD, layout } from './cluster_engine.js';
import { makeNames, readCsv } from './r_csv.js';
import { dbinom, miceSummary, pbinom } from './stats_engine.js';
import { PLOTS, points } from './pcr_engine.js';

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..');
const ref = JSON.parse(readFileSync(join(ROOT, 'tests/fixtures/r_reference.json'), 'utf8'));
const read = p => readFileSync(join(ROOT, p), 'utf8');
const close = (a, b, tol = 1e-9) => assert.ok(Math.abs(a - b) <= tol * Math.max(1, Math.abs(b)), `${a} vs ${b}`);
const closeAll = (a, b, tol) => { assert.equal(a.length, b.length); a.forEach((v, i) => close(v, b[i], tol)); };

// make.names / read.csv
assert.deepEqual(makeNames(['a', 'a', '4,[5], 12:i:- ', 'ABI 7500', 'if', 'a.1', 'a']), ['a', 'a.2', 'X4..5...12.i...', 'ABI.7500', 'if.', 'a.1', 'a.3']);
for (const [file, r] of Object.entries(ref.pcr)) {
  const d = readCsv(read('PCR/' + file));
  assert.deepEqual(d.names, r.names, file);
  d.columns.forEach((c, j) => c.forEach((v, i) => {
    const want = r.columns[j][i];
    if (typeof want === 'number') close(v, want); else assert.equal(v, want, `${file} ${r.names[j]}[${i}]`);
  }));
}

// SoundScience clustering: columns, group sums, Ward merge/height/order, cutree k = 2..15
const csv = read('SoundScience/data_habitat_speciesNames.csv');
assert.deepEqual(readCsv(csv, { rowNames: true }).names, ref.clustering.columns);
assert.deepEqual(Object.keys(GROUPS), ref.clustering.groups);
const C = combine(csv);
assert.deepEqual(C.rows, ref.clustering.rows);
closeAll(C.X[0], ref.clustering.first_row);
const n = C.rows.length, tree = hclustWardD(dist(C.X), n);
closeAll(tree.height, ref.clustering.height, 1e-9);
assert.deepEqual(tree.merge, ref.clustering.merge);
assert.deepEqual(tree.order, ref.clustering.order);
ref.clustering.cutree.forEach((g, i) => assert.deepEqual(cutree(tree.merge, n, i + 2), g, `cutree k=${i + 2}`));
const top = layout(tree, n).at(-1);
close(top.y, tree.height.at(-1));
// ... and on all 99 projects (no outliers dropped)
const A = combine(csv, undefined, []), treeA = hclustWardD(dist(A.X), A.rows.length);
assert.deepEqual(A.rows, ref.clustering_all.rows);
closeAll(treeA.height, ref.clustering_all.height);
assert.deepEqual(treeA.merge, ref.clustering_all.merge);
assert.deepEqual(treeA.order, ref.clustering_all.order);
assert.deepEqual(cutree(treeA.merge, A.rows.length, 12), ref.clustering_all.cutree12);

// Binomial (DataCamp/probability_1.R)
close(dbinom(5, 10, 0.5), ref.binom.script.dbinom_5_10, 1e-12);
close(pbinom(4, 10, 0.5), ref.binom.script.pbinom_4_10, 1e-12);
for (const g of ref.binom.grid) { close(dbinom(g.x, g.size, g.prob), g.d, 1e-12); close(pbinom(g.x, g.size, g.prob), g.p, 1e-12); }

// Mice body weights (EdX_course/Week1_CentralLimitTheorem*.R)
const mice = readCsv(read('EdX_course/mice_pheno.csv'));
const rows = mice.columns[0].map((_, i) => Object.fromEntries(mice.names.map((nm, j) => [nm, mice.columns[j][i]])));
const S = miceSummary(rows);
assert.equal(S.rows, ref.mice.rows);
S.groups.forEach((g, i) => {
  const r = ref.mice.groups[i];
  assert.equal(g.sex, r.sex); assert.equal(g.diet, r.diet); assert.equal(g.n, r.n);
  close(g.mean, r.mean); close(g.popsd, r.popsd); closeAll(g.within, r.within);
});

// PCR plots: every series reads real values; hand-traced spot checks from the CSVs.
const texts = Object.fromEntries(Object.keys(ref.pcr).map(f => [f, read('PCR/' + f)]));
const p2a = points(PLOTS.find(p => p.id === 'plot2a'), texts).pts;
assert.ok(p2a.some(p => p.series === 'ABI 7500 enterica' && p.x === 1.05 && p.y === 25.2));      // abi7500_dilutions_oric.csv row 1
assert.ok(!p2a.some(p => p.series === 'ABI 7500 muenchen' && p.x === 1050));                     // Ct 0 = no Ct, outside ylim
const p1a = points(PLOTS.find(p => p.id === 'plot1a'), texts);
assert.equal(p1a.xticks[5][1], '4,[5], 12:i:-');
assert.equal(p1a.pts.filter(p => p.series.startsWith('ABI')).length, 39);                       // muenchen 1:1000 blank
assert.ok(p1a.pts.some(p => p.series === 'SmartCycler 1:1000' && p.x === 10 && p.y === 40.25));
for (const p of PLOTS) assert.ok(points(p, texts).pts.length > 0, p.id);
console.log(`engines tests ok (R ${ref.r_version}; ${n} projects clustered, ${Object.keys(ref.pcr).length} PCR files)`);
