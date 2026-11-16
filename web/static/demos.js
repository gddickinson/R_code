// Demo router: #/demo/<name> loads the demo's module.
import { app, route } from './core.js';

const DEMOS = { clustering: './demo_cluster.js', pcr: './demo_pcr.js', stats: './demo_stats.js' };

route('demo', async ([name = 'clustering'], query) => {
  if (!DEMOS[name]) { app().innerHTML = '<h1>Not found</h1><p><a href="#/">Back to the start</a></p>'; return; }
  const mod = await import(DEMOS[name]);
  await mod.render(app(), query);
});
