// read.csv as R does it, for the committed data files the R scripts read (pure; tested in engines.test.mjs).
// Handles quoted fields, CR / LF / CRLF line ends, R's make.names(unique = TRUE) column names, numeric columns
// (all non-empty values numeric -> numbers, empty / "NA" -> null) and row.names = 1.

export function parseCsv(text) {
  const rows = [];
  let row = [], field = '', q = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (q) {
      if (c === '"') { if (text[i + 1] === '"') { field += '"'; i++; } else q = false; } else field += c;
    } else if (c === '"') q = true;
    else if (c === ',') { row.push(field); field = ''; }
    else if (c === '\n' || c === '\r') {
      if (c === '\r' && text[i + 1] === '\n') i++;
      row.push(field); rows.push(row); row = []; field = '';
    } else field += c;
  }
  if (field !== '' || row.length) { row.push(field); rows.push(row); }
  return rows.filter(r => !(r.length === 1 && r[0] === ''));
}

const RESERVED = new Set('if else repeat while function for next break TRUE FALSE NULL Inf NaN NA NA_integer_ NA_real_ NA_character_ in'.split(' '));
// R's make.names(names, unique = TRUE).
export function makeNames(names) {
  const valid = names.map(n => {
    let s = n.replace(/[^A-Za-z0-9._]/g, '.');
    if (!/^([A-Za-z]|\.(?![0-9]))/.test(s)) s = 'X' + s;
    return RESERVED.has(s) ? s + '.' : s;
  });
  const seen = new Set(valid), count = new Map(), out = [], used = new Set();
  for (const s of valid) {
    if (!used.has(s)) { used.add(s); out.push(s); continue; }
    let k = count.get(s) || 0, t;
    do { k++; t = `${s}.${k}`; } while (seen.has(t) || used.has(t));
    count.set(s, k); used.add(t); out.push(t);
  }
  return out;
}

const isNum = s => /^\s*[-+]?(\d+\.?\d*|\.\d+)([eE][-+]?\d+)?\s*$/.test(s);

// { names, columns, rownames } like read.csv(text, header = TRUE[, row.names = 1]).
export function readCsv(text, { rowNames = false } = {}) {
  const rows = parseCsv(text);
  const width = rows[0].length;
  let names = makeNames(rows[0]);
  let cols = names.map((_, j) => rows.slice(1).map(r => r[j] ?? ''));
  cols = cols.map(v => v.every(s => s === '' || s === 'NA' || isNum(s)) && v.some(s => s !== '' && s !== 'NA')
    ? v.map(s => (s === '' || s === 'NA' ? null : Number(s))) : v.map(s => (s === 'NA' ? null : s)));
  let rownames = null;
  if (rowNames) { rownames = cols[0]; cols = cols.slice(1); names = makeNames(rows[0].slice(1)); }
  return { names, columns: cols.slice(0, width), rownames };
}
