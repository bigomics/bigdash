import 'jquery';

// Keep this in sync with `scoped_id()` in R/utils.R.
export const DEFAULT_ID = 'app';

export const scopedId = (id, suffix) => (
  (!id || id === DEFAULT_ID) ? suffix : `${id}-${suffix}`
);

// Given any element inside a bigPage(), find the id of the closest
// enclosing bigPage() instance (its `data-bigdash-id`). Falls back to
// the default id if the element isn't inside a `.bigdash-app` (e.g. in
// older markup, or during tests).
export const rootIdFor = ($el) => {
  let $root = $el.closest('.bigdash-app');
  return $root.length ? ($root.attr('data-bigdash-id') || DEFAULT_ID) : DEFAULT_ID;
};

// Call `fn(id, $root)` once for every bigPage() instance on the page.
export const eachRootId = (fn) => {
  $('.bigdash-app').each((index, el) => {
    let $root = $(el);
    fn($root.attr('data-bigdash-id') || DEFAULT_ID, $root);
  });
};
