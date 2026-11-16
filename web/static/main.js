// Entry point: lazy page modules, the mode label, a faint dendrogram-like background, then the router.
import { $, app, isStatic, lazy, route, start } from './core.js';

const PAGES = { 'home.js': ['home'], 'code.js': ['code'], 'how.js': ['how'], 'demos.js': ['demo'], 'about.js': ['about'] };
lazy(Object.fromEntries(Object.entries(PAGES).flatMap(([file, names]) => names.map(n => [n, () => import('./' + file)]))));
route('notfound', () => { app().innerHTML = '<h1>Not found</h1><p><a href="#/">Back to the start</a></p>'; });

$('#mode').textContent = isStatic()
  ? 'static site: files read from the repository at build time; demos run in your browser'
  : 'local app: files read from this checkout; demos run in your browser';

// Background: slowly drifting points that join into small trees. Off under prefers-reduced-motion.
function background(canvas) {
  if (!canvas || matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  const g = canvas.getContext('2d'), cols = ['#c6ff4a', '#5aa9ff', '#ff6fb5'];
  const fit = () => { canvas.width = innerWidth; canvas.height = innerHeight; };
  fit(); addEventListener('resize', fit);
  const pts = Array.from({ length: 36 }, (_, i) => ({ x: Math.random(), y: Math.random(), vx: (Math.random() - 0.5) * 3e-4, vy: (Math.random() - 0.5) * 3e-4, c: cols[i % 3] }));
  let last = 0;
  const tick = t => {
    requestAnimationFrame(tick);
    if (document.hidden || t - last < 60) return;
    last = t;
    const W = canvas.width, H = canvas.height;
    g.clearRect(0, 0, W, H);
    for (const p of pts) { p.x = (p.x + p.vx + 1) % 1; p.y = (p.y + p.vy + 1) % 1; }
    g.lineWidth = 1;
    for (let i = 0; i < pts.length; i++) for (let j = i + 1; j < pts.length; j++) {
      const a = pts[i], b = pts[j], d = Math.hypot((a.x - b.x) * W, (a.y - b.y) * H);
      if (d < 130) { g.strokeStyle = a.c; g.globalAlpha = 0.35 * (1 - d / 130); g.beginPath(); g.moveTo(a.x * W, a.y * H); g.lineTo(a.x * W, b.y * H); g.lineTo(b.x * W, b.y * H); g.stroke(); }
    }
    g.globalAlpha = 0.6;
    for (const p of pts) { g.fillStyle = p.c; g.fillRect(p.x * W - 1.5, p.y * H - 1.5, 3, 3); }
  };
  requestAnimationFrame(tick);
}
background($('#bg'));
start();
