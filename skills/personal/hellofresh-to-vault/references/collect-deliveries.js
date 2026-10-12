// Run on https://www.hellofresh.<tld>/my-account/deliveries/past-deliveries
// Clicks "View more" until every past week is loaded, then collects each meal
// from the page's react-query cache plus any past-deliveries responses seen
// while loading. Result is stored in window.__hfMeals as [{week, name, slug}].

window.__hfSeen = window.__hfSeen || [];
if (!window.__hfPatched) {
  const origFetch = window.fetch;
  window.fetch = async function (...args) {
    const res = await origFetch.apply(this, args);
    const url = (args[0] && args[0].url) || String(args[0]);
    if (url.includes("past-deliveries")) res.clone().text().then((t) => window.__hfSeen.push(t));
    return res;
  };
  window.__hfPatched = true;
}

for (let i = 0; i < 60; i++) {
  const more = [...document.querySelectorAll("button")].find((b) => b.innerText.trim() === "View more");
  if (!more) break;
  more.click();
  await new Promise((r) => setTimeout(r, 2500));
}

function findQueryClient() {
  const root = document.getElementById("__next");
  const key = Object.keys(root).find((k) => k.startsWith("__reactContainer") || k.startsWith("__reactFiber"));
  let fiber = root[key];
  if (fiber && fiber.stateNode && fiber.stateNode.current) fiber = fiber.stateNode.current;
  const stack = [fiber];
  while (stack.length) {
    const f = stack.pop();
    if (!f) continue;
    const p = f.memoizedProps;
    if (p && p.client && p.client.getQueryCache) return p.client;
    if (f.child) stack.push(f.child);
    if (f.sibling) stack.push(f.sibling);
  }
  return null;
}

const meals = new Map();
function addWeeks(payload) {
  for (const w of (payload && payload.weeks) || []) {
    for (const m of w.meals || []) {
      if (m.websiteURL && !meals.has(m.id)) {
        meals.set(m.id, { week: w.week, name: m.name, slug: m.websiteURL.split("/recipes/")[1] });
      }
    }
  }
}

const client = findQueryClient();
if (client) {
  for (const q of client.getQueryCache().getAll()) {
    const d = q.state.data;
    if (d) (d.pages || [d]).forEach(addWeeks);
  }
}
window.__hfSeen.forEach((t) => { try { addWeeks(JSON.parse(t)); } catch (e) {} });

window.__hfMeals = [...meals.values()];
JSON.stringify({ count: window.__hfMeals.length, weeks: [...new Set(window.__hfMeals.map((m) => m.week))] });
