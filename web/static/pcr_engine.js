// Port of the PCR plot scripts (PCR/Plot*.R): which committed CSV columns each figure draws, at which x, in which
// colour and symbol. The R scripts only plot Ct values; there is no efficiency or delta-delta-Ct calculation in them.
// Series follow the scripts after the fixes in this branch (ABI enterica drawn in Plot2a/2b, Plot2a legend symbols,
// serotype positions in Plot1a/1b/3a). Values come from read.csv-compatible parsing (r_csv.js).
import { readCsv } from './r_csv.js';

export const SEROTYPE_COLS = ['enterica', 'typhimurium', 'irumu', 'newport', 'infantis', 'X4..5...12.i...', 'montevideo', 'cerro', 'hadar', 'muenchen'];
export const SEROTYPE_LABELS = ['enterica', 'typhimurium', 'irumu', 'newport', 'infantis', '4,[5], 12:i:-', 'montevideo', 'cerro', 'hadar', 'muenchen'];
export const COLOURS = ['red', 'blue', 'green', 'purple', 'orange', 'yellow', 'brown', 'pink', 'grey', 'black'];
const DIL_X = [1, 10, 100, 1000], ABI_X = [1.05, 10.5, 105, 1050];   // Plot2a/2b: ABI drawn 5% to the right

// Each plot: { id, script, title, xlab, ylab, xlog, ylim, kind, series: [{ file, column, x, label, colour, symbol }] }
// symbol: 'circle' (pch 16), 'square' (pch 15), 'triangle' (pch 17), open variants (pch 1, 2).
export const PLOTS = [
  { id: 'plot1a', script: 'PCR/Plot1a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_OriC.R', title: 'OriC assay', kind: 'serotype',
    files: ['smartcycler_oric_2.csv', 'abi7500_oric_2.csv'], instruments: [['SmartCycler', 'blue'], ['ABI 7500', 'red']], ylim: [20, 45] },
  { id: 'plot1b', script: 'PCR/Plot1b_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_gfp.R', title: 'gfp assay', kind: 'serotype',
    files: ['smartcycler_gfp_2.csv', 'abi7500_gfp_2.csv'], instruments: [['SmartCycler', 'blue'], ['ABI 7500', 'red']], ylim: [20, 45] },
  { id: 'plot2a', script: 'PCR/Plot2a_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_oric.R', title: 'OriC assay', kind: 'dilution',
    files: ['smartcycler_dilutions_oric.csv', 'abi7500_dilutions_oric.csv'], ylim: [20, 45] },
  { id: 'plot2b', script: 'PCR/Plot2b_Salmonella_dilutions_series_SmartCycler_vs_ABI7500_gfp.R', title: 'gfp assay', kind: 'dilution',
    files: ['smartcycler_dilutions_gfp.csv', 'abi7500_dilutions_gfp.csv'], ylim: [20, 45] },
  { id: 'plot3a', script: 'PCR/Plot3a_Non-Salmonella_dilutions_series_SmartCycler_vs_ABI7500_OriC.R', title: 'OriC & gfp assays', kind: 'nonsalm',
    files: ['non-salm_smartcycler_oric.csv', 'non-salm_smartcycler_gfp.csv'], ylim: [0, 45] },
  { id: 'plot4a', script: 'PCR/Plot4a_enterica_dilution_series_ABI_limitOfDetection_OriC.R', title: 'OriC assay', kind: 'lod',
    files: ['abi7500_detection_limit_oric.csv'], ylim: [20, 45] },
];

const col = (d, name) => d.columns[d.names.indexOf(name)];

// Points of one plot from the CSV texts: [{ x, y, colour, symbol, series, label }], plus axis setup and legend.
export function points(plot, texts) {
  const d = plot.files.map(f => readCsv(texts[f]));
  const pts = [];
  const add = (xs, ys, colour, symbol, series, labels) => ys.forEach((y, i) => {
    if (y != null && y >= plot.ylim[0] && y <= plot.ylim[1]) pts.push({ x: xs[i], y, colour, symbol, series, label: labels ? labels[i] : String(xs[i]) });
  });
  if (plot.kind === 'serotype') {
    // x = position of the serotype in the SmartCycler file; ABI rows are matched by serotype name.
    const names = col(d[0], 'serotype').map(s => s.trim());
    d.forEach((di, k) => {
      const at = col(di, 'serotype').map(s => names.indexOf(s.trim()) + 1);
      for (const c of ['X1', 'X10', 'X100', 'X1000']) add(at, col(di, c), plot.instruments[k][1], 'circle', `${plot.instruments[k][0]} 1:${c.slice(1)}`, col(di, 'serotype'));
    });
    return { pts, xlab: 'serotype', xticks: names.map((n, i) => [i + 1, n]), xlog: false,
      legend: plot.instruments.map(([t, c]) => ({ text: t, colour: c, symbol: 'circle' })) };
  }
  if (plot.kind === 'dilution') {
    SEROTYPE_COLS.forEach((c, i) => {
      add(DIL_X, col(d[0], c), COLOURS[i], 'circle', `SmartCycler ${SEROTYPE_LABELS[i]}`);
      add(ABI_X, col(d[1], c), COLOURS[i], 'square', `ABI 7500 ${SEROTYPE_LABELS[i]}`);
    });
    return { pts, xlab: 'dilution factor', xlog: true, xticks: DIL_X.map(v => [v, String(v)]),
      legend: [{ text: 'SmartCycler', colour: 'white', symbol: 'circle' }, { text: 'ABI 7500', colour: 'white', symbol: 'square' },
        ...SEROTYPE_LABELS.map((t, i) => ({ text: t, colour: COLOURS[i], symbol: 'circle' }))] };
  }
  if (plot.kind === 'nonsalm') {
    const names = col(d[0], 'serotype');
    const at = names.map((_, i) => i + 1);
    add(at, col(d[0], 'SmartCycler'), 'blue', 'circle', 'SmartCycler OriC', names);
    add(at, col(d[0], 'ABI.7500'), 'red', 'triangle', 'ABI 7500 OriC', names);
    add(at, col(d[1], 'SmartCycler'), 'blue', 'circle-open', 'SmartCycler gfp', names);
    add(at, col(d[1], 'ABI.7500'), 'red', 'triangle-open', 'ABI 7500 gfp', names);
    return { pts, xlab: '', xlog: false, xticks: names.map((n, i) => [i + 1, n]),
      legend: [{ text: 'ABI 7500 (OriC filled, gfp open)', colour: 'red', symbol: 'triangle' }, { text: 'SmartCycler (OriC filled, gfp open)', colour: 'blue', symbol: 'circle' }] };
  }
  const x = col(d[0], 'dilution'), x2 = [1.03, 10.3, 103, 1030, 10300, 103000];
  add(x, col(d[0], 'enterica_a'), 'red', 'circle', 'enterica_a');
  add(x2, col(d[0], 'enterica_b'), 'blue', 'circle', 'enterica_b');
  return { pts, xlab: 'dilution factor', xlog: true, xticks: x.map(v => [v, String(v)]),
    legend: [{ text: 'enterica_a', colour: 'red', symbol: 'circle' }, { text: 'enterica_b', colour: 'blue', symbol: 'circle' }] };
}
