import 'jquery';

/*
 * Visibility toolbox (client half). The R side is R/visibility.R.
 *
 * A board registers a probe (bd_visibility_probe()); this watches it and
 *   - reports on/off screen to the server as `input$is_visible`,
 *   - drops the drawn Plotly/iheatmapr trees of that board while it is off
 *     screen, and of a modal while it is closed.
 *
 * Purging is off until the *server* enables it for a board (bd_is_visible()
 * does that when it registers), because a purged plot only comes back if
 * something server-side holds a redraw tick for it. No tick, no purge.
 */

const WIDGETS = '.js-plotly-plot, .plotly.html-widget, .iheatmapr';
const VISIBILITY_ATTRS = ['class', 'style', 'hidden', 'aria-hidden'];
const MAX_PAINT_FRAMES = 600; // ~10s at 60fps

// module namespace prefix (e.g. "qsee-impute-") -> board state
const boards = {};

const board = (prefix) => {
  if (!boards[prefix]) {
    boards[prefix] = { prefix: prefix, enabled: false, spinner: false };
  }
  return boards[prefix];
}

// The board owning an element id: the longest registered prefix matching it.
const boardFor = (id) => {
  let best = null;
  for (const prefix in boards) {
    if (id.indexOf(prefix) !== 0) continue;
    if (!best || prefix.length > best.length) best = prefix;
  }
  return best ? boards[best] : null;
}

const isWidget = (el) =>
  el.classList.contains('plotly') ||
  el.classList.contains('js-plotly-plot') ||
  el.classList.contains('iheatmapr');

const painted = (el) => !!el.querySelector('svg, canvas');

const purgeNode = (node) => {
  // Plotly.purge first: it drops plotly's own state for the node, so the
  // htmlwidget binding does a fresh newPlot() instead of a react() against a
  // graph div whose DOM we are about to delete.
  if (window.Plotly && typeof window.Plotly.purge === 'function') {
    try {
      window.Plotly.purge(node);
    } catch (e) {
      // not a plotly graph div after all
    }
  }
  while (node.firstChild) node.removeChild(node.firstChild);

  // htmlwidgets keeps the widget instance on the element and skips
  // initialize() while "initialized" is set -- and Shiny's resize handler
  // calls straight into that stale instance, which for plotly means
  // Plotly.relayout() against a graph div we just emptied ("Cannot read
  // properties of undefined (reading '_guiEditing')"). Clearing both makes
  // htmlwidgets treat the next render as a first render, which it is.
  delete node.htmlwidget_data_initialized;
  delete node.htmlwidget_data_init_result;
}

// Purge drawn widgets inside `root`; with `prefix`, only those it owns. The
// output element itself stays -- Shiny renders back into it.
const purgeWithin = (root, prefix) => {
  const nodes = root.querySelectorAll(WIDGETS);
  let n = 0;
  for (let i = 0; i < nodes.length; i++) {
    const el = nodes[i];
    if (prefix && el.id && el.id.indexOf(prefix) !== 0) continue;
    if (!painted(el)) continue; // nothing drawn -- nothing to drop
    purgeNode(el);
    n++;
  }
  return n;
}

const purgeBoard = (b) => (b && b.enabled ? purgeWithin(document, b.prefix) : 0);

// --- probes -----------------------------------------------------------------

const watch = (spec) => {
  const b = board(spec.prefix);
  if (spec.spinner) b.spinner = true;

  const el = document.getElementById(spec.probe);
  if (!el) return;
  // Marked on the element, not on the board: a board whose UI is rebuilt
  // (renderUI, insertUI) gets a fresh probe that must be watched again.
  if (el.dataset.bdWatching) return;
  el.dataset.bdWatching = '1';

  let lastState = null;
  const report = (state) => {
    // Shiny.setInputValue is not attached until shiny.js has initialised,
    // which can be after this runs. Leave lastState alone on failure so the
    // same state is reported again by the next check() -- including the
    // guaranteed one on 'shiny:connected'.
    if (!(window.Shiny && typeof window.Shiny.setInputValue === 'function')) return;
    if (state === lastState) return;
    lastState = state;
    window.Shiny.setInputValue(spec.input, state, { priority: 'event' });
  }

  const check = () => {
    // offsetParent is null while any ancestor is display:none.
    const visible = el.offsetParent !== null && el.getClientRects().length > 0;
    if (!visible) purgeBoard(b);
    report(visible);
  }

  if (window.IntersectionObserver) {
    new IntersectionObserver(() => check()).observe(el);
  }

  // An element inside a tab that is display:none does not reliably get an
  // intersection callback when that tab is activated, so watch the class /
  // style flips too -- on each *ancestor* that can carry them, rather than on
  // documentElement with subtree:true, which would call back on every DOM
  // change anywhere in the app, for every board.
  const mo = new MutationObserver(() => window.requestAnimationFrame(check));
  let node = el.parentElement;
  while (node && node !== document.body) {
    mo.observe(node, { attributes: true, attributeFilter: VISIBILITY_ATTRS });
    node = node.parentElement;
  }

  check();
  document.addEventListener('shiny:connected', check);

  // Chrome only delivers IntersectionObserver entries -- and, in practice,
  // only finishes settling layout -- as part of an actual render/paint
  // pass. A page that goes idle right after load, with nothing else
  // scheduling a frame, can leave that pass (and so the observer callback)
  // pending indefinitely: the probe then never reports `true` until some
  // real user input (e.g. a scroll) forces a new compositor frame and
  // unsticks it. Force a short burst of our own frames instead of waiting
  // on that: requestAnimationFrame always fires on a foreground tab
  // regardless of what else is scheduled, and re-running check() on each
  // one is what actually lets a late `true` through without needing the
  // user to touch anything.
  let settleFrames = 10;
  const settle = () => {
    check();
    if (--settleFrames > 0) window.requestAnimationFrame(settle);
  }
  window.requestAnimationFrame(settle);
}

// --- modals: a closed modal is hidden, whatever the board is doing ----------

const watchModals = () => {
  $(document).on('hidden.bs.modal', (e) => {
    const el = e.target;
    if (!el || !el.id) return;
    const b = boardFor(el.id);
    if (!b || !b.enabled) return;
    purgeWithin(el, null);
  });
}

// --- spinner: bigLoaders hides on shiny:value, i.e. before plotly paints -----

const watchSpinners = () => {
  $(document).on('shiny:value', (e) => {
    if (!e.name) return;
    const b = boardFor(e.name);
    if (!b || !b.spinner) return;
    const el = document.getElementById(e.name);
    if (!el || !isWidget(el) || painted(el)) return;
    const sp = document.getElementById(e.name + '-spinner');
    if (!sp) return;

    // Runs after spinner.js's own handler (a page-level htmlDependency,
    // registered first), so this undoes its early hide.
    $(sp).show();
    // visibility, not display: plotly measures the container to size the
    // figure, so it has to keep its layout box while drawing.
    el.style.visibility = 'hidden';

    let frames = 0;
    (function wait() {
      if (painted(el) || ++frames > MAX_PAINT_FRAMES) {
        $(sp).hide();
        el.style.visibility = 'inherit';
        return;
      }
      window.requestAnimationFrame(wait);
    })();
  });
}

// --- wiring -----------------------------------------------------------------

const whenShiny = (fn) => {
  if (window.Shiny && window.Shiny.addCustomMessageHandler) return fn();
  let waited = 0;
  const timer = setInterval(() => {
    if (window.Shiny && window.Shiny.addCustomMessageHandler) {
      clearInterval(timer);
      fn();
    } else if ((waited += 20) > 10000) {
      clearInterval(timer);
    }
  }, 20);
}

export const handleVisibility = () => {
  if (window.bigdash && window.bigdash.visibility) return;

  whenShiny(() => {
    window.Shiny.addCustomMessageHandler('bigdash-visibility-enable', (msg) => {
      board(msg.prefix).enabled = !!msg.enabled;
    });
    window.Shiny.addCustomMessageHandler('bigdash-visibility-purge', (msg) => {
      purgeBoard(board(msg.prefix));
    });
    watchModals();
    watchSpinners();
  });

  // Probes registered before this ran are queued in an array; drain it, then
  // replace the queue with a push-through so later ones go straight in.
  const queued = window.__bigdashVisibility || [];
  for (let i = 0; i < queued.length; i++) watch(queued[i]);
  window.__bigdashVisibility = { push: watch };

  window.bigdash = window.bigdash || {};
  window.bigdash.visibility = {
    boards: boards,
    purge: (prefix) => purgeBoard(board(prefix)),
    purgeWithin: purgeWithin
  };
}
