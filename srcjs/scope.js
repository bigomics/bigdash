import 'jquery';

// Keep this in sync with `scoped_id()` in R/utils.R.
export const DEFAULT_ID = 'app';

export const scopedId = (id, suffix) => (
  (!id || id === DEFAULT_ID) ? suffix : `${id}-${suffix}`
);

// Given any element inside a bigPage(), find the id of the closest
// enclosing bigPage() instance (its `data-bigdash-id`). Navbar lives
// outside `.bigdash-app` (sibling under `.bigdash-page`) so we also
// accept any ancestor that carries the attribute. Falls back to the
// default id if the element isn't inside a marked root.
export const rootIdFor = ($el) => {
  let $root = $el.closest('.bigdash-app, [data-bigdash-id]');
  return $root.length ? ($root.attr('data-bigdash-id') || DEFAULT_ID) : DEFAULT_ID;
};

// Sidebar + navbar belonging to one bigPage(), so tab highlighting and
// similar walks do not leak into a sibling instance.
export const $scopeFor = (id) => {
  const $app = $(`.bigdash-app[data-bigdash-id="${id}"]`);
  const $page = $app.closest('.bigdash-page');
  if ($page.length) return $page;
  return $app.add($(`.navbar[data-bigdash-id="${id}"]`));
};

// The two places a `.tab-trigger` or `.sidebar-menu` can live: this instance's
// navbar and its sidebar. $scopeFor() resolves to `.bigdash-page`, which also
// holds every tab body -- so a `.find()` off it walked all the boards and the
// figures drawn inside them, on every tab click. Reached from the sidebar's own
// id rather than through an attribute selector, which has no index and so walks
// the document to answer.
export const $navScopeFor = (id) => {
  const sidebar = document.getElementById(scopedId(id, 'sidebar-container'));
  if (!sidebar) return $scopeFor(id);
  const page = sidebar.closest('.bigdash-page');
  const $navbar = page ? $(page).children('.navbar') : $();
  return $navbar.add(sidebar);
};

// Call `fn(id, $root)` once for every bigPage() instance on the page.
export const eachRootId = (fn) => {
  $('.bigdash-app').each((index, el) => {
    let $root = $(el);
    fn($root.attr('data-bigdash-id') || DEFAULT_ID, $root);
  });
};
