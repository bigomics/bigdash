import 'shiny';
import { isMobile } from './utils';
import { scopedId, rootIdFor, eachRootId } from './scope';

// Per-root setup: on mobile, tab settings render inline instead of in the
// settings drawer. Called for every root at boot (below) and again -- for
// just the one new root -- by bigdash-init-root (navigation.js) when a
// bigPage() is inserted into the DOM after page load (e.g. via
// bslib::nav_insert()/insertUI() for a lazily-loaded module).
export const initSettingsRoot = (id) => {
  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  if($settingsContainer.length === 0)
    return;

  if(isMobile()){
    // hide settings tab on mobile
    $settingsContainer.find('.tab-settings').removeClass('d-none');
    $settingsContainer.hide();
  }
}

export const handleSettings = () => {
  moveSettings();

  // Delegated (rather than bound per-root to whatever matches at this
  // instant) so it also covers settings drawers inserted later. Harmless
  // on mobile roots too: their settings-container stays hidden, so the
  // label is never actually clickable there.
  $(document).on('click', '.settings-label', (e) => {
    settingsToggle(rootIdFor($(e.currentTarget)));
  });

  eachRootId(initSettingsRoot);
}

// Exported so the server-side (R) `bigdash.open/closeSettings()` can drive a
// specific bigPage() instance instead of the JS-only, unscoped globals in
// navigation.js.
export const settingsExpand = (id) => {
  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  //change settings sidebar css upon expanding
  $settingsContainer.removeClass('settings-collapsed');
  $settingsContainer.addClass('settings-expanded');
  $settingsContainer.find('.settings').addClass('p-2');
  $settingsContainer.show();
  $settingsContainer.find('.tab-settings').show();
}

export const settingsCollapse = (id) => {
  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  $settingsContainer.removeClass('settings-expanded');
  $settingsContainer.addClass('settings-collapsed');
  $settingsContainer.find('.settings').removeClass('p-2');
  $settingsContainer.hide();
  $settingsContainer.find('.tab-settings').hide();
}

// the panel renders expanded but carries neither class until it is toggled
// once, so anything that is not collapsed counts as expanded
export const isSettingsExpanded = (id) => (
  !$(`#${scopedId(id, 'settings-container')}`).hasClass('settings-collapsed')
);

const settingsToggle = (id) => {
  if(isSettingsExpanded(id))
    settingsCollapse(id);
  else
    settingsExpand(id);
}

const moveSettingsForTab = ($tab) => {
  let id = rootIdFor($tab);
  // A bigTabItem() can wrap an entire nested bigPage() (a module
  // embedded as a tab, e.g. Qsee), so `$tab.find('.tab-settings')` can
  // reach straight through into that nested bigPage()'s own
  // tabSettings() -- filtering to descendants that still resolve back
  // to *this* tab's own root keeps a nested instance's settings panel
  // from being stolen into the wrong (outer) settings-content.
  let settings = $tab
    .find('.tab-settings')
    .filter((i, s) => rootIdFor($(s)) === id)
    .first();

  $(settings).data('target', $tab.data('name'));
  $(settings).appendTo(`#${scopedId(id, 'settings-content')}`);
}

const moveSettings = () => {
  $('.big-tab').each((index, el) => moveSettingsForTab($(el)));
}

// Move settings panes for just the tabs under one newly-inserted root.
// Exported for bigdash-init-root (navigation.js) -- the document-ready
// moveSettings() above only ever sees tabs present in the DOM at that
// moment, so a root inserted afterward needs this repeated for it alone.
export const moveSettingsForRoot = (id, $root) => {
  $root.find('.big-tab').each((index, el) => moveSettingsForTab($(el)));
}
