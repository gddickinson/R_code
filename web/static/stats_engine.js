// Ports of two small coursework calculations (pure; tested against R in engines.test.mjs):
//  - DataCamp/probability_1.R: dbinom / pbinom (binomial probability and cumulative probability)
//  - EdX_course/Week1_CentralLimitTheorem*.R: population mean, rafalib::popsd and the proportion of values
//    within 1, 2 and 3 SD of the mean, for each sex x diet group of mice_pheno.csv (after na.omit).

export function choose(n, k) {
  if (k < 0 || k > n) return 0;
  k = Math.min(k, n - k);
  let c = 1;
  for (let i = 1; i <= k; i++) c = (c * (n - k + i)) / i;
  return c;
}
export const dbinom = (x, size, prob) => (x < 0 || x > size || x !== Math.floor(x) ? 0
  : choose(size, x) * prob ** x * (1 - prob) ** (size - x));
export function pbinom(q, size, prob) {
  if (q < 0) return 0;
  let s = 0;
  for (let x = 0; x <= Math.min(Math.floor(q), size); x++) s += dbinom(x, size, prob);
  return Math.min(1, s);
}

export const mean = v => v.reduce((a, b) => a + b, 0) / v.length;
export const popsd = v => { const m = mean(v); return Math.sqrt(mean(v.map(x => (x - m) ** 2))); };

// Week1_CentralLimitTheorem_2.R: prop(q) = mean(y <= q); within k SD = prop(mean + k sd) - prop(mean - k sd).
export function within(v, k) {
  const m = mean(v), s = popsd(v), prop = q => v.filter(x => x <= q).length / v.length;
  return prop(m + k * s) - prop(m - k * s);
}

// rows: [{Sex, Diet, Bodyweight}] -> na.omit -> one summary per sex x diet (F/M x chow/hf), as the scripts compute.
export function miceSummary(rows) {
  const ok = rows.filter(r => r.Sex != null && r.Diet != null && r.Bodyweight != null && r.Sex !== '' && r.Diet !== '');
  const out = [];
  for (const sex of ['F', 'M']) for (const diet of ['chow', 'hf']) {
    const y = ok.filter(r => r.Sex === sex && r.Diet === diet).map(r => r.Bodyweight);
    out.push({ sex, diet, n: y.length, mean: mean(y), popsd: popsd(y), within: [1, 2, 3].map(k => within(y, k)), values: y });
  }
  return { rows: ok.length, groups: out };
}

// Seeded sample of `size` values without replacement (browser RNG, not R's set.seed stream).
export function sample(v, size, rand) {
  const a = v.slice();
  for (let i = 0; i < size; i++) { const j = i + Math.floor(rand() * (a.length - i)); [a[i], a[j]] = [a[j], a[i]]; }
  return a.slice(0, size);
}
