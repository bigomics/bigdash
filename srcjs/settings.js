import 'shiny';
import { isMobile } from './utils';
import { scopedId, rootIdFor, eachRootId } from './scope';

export const handleSettings = () => {
  moveSettings();

  eachRootId((id) => {
    let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);

    if($settingsContainer.length === 0)
      return;

    if(isMobile()){
      // hide settings tab on mobile
      $settingsContainer.find('.tab-settings').removeClass('d-none');
      $settingsContainer.hide();
      return;
    }

    // the settings panel is toggled by hand only, the auto-collapse lives
    // on the sidebar (see sidebar.js)
    $settingsContainer.find('.settings-label').on('click', () => {
      settingsToggle(id);
    });
  });
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

const moveSettings = () => {
  $('.big-tab')
    .each((index, el) => {
      let $tab = $(el);
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
    });
}
