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

const settingsExpand = (id) => {
  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  //change settings sidebar css upon expanding
  $settingsContainer.removeClass('settings-collapsed');
  $settingsContainer.addClass('settings-expanded');
  $settingsContainer.find('.settings').addClass('p-2');
  $settingsContainer.show();
  $settingsContainer.find('.tab-settings').show();
}

const settingsCollapse = (id) => {
  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  $settingsContainer.removeClass('settings-expanded');
  $settingsContainer.addClass('settings-collapsed');
  $settingsContainer.find('.settings').removeClass('p-2');
  $settingsContainer.hide();
  $settingsContainer.find('.tab-settings').hide();
}

const settingsToggle = (id) => {
  // the panel renders expanded but carries neither class until it is
  // toggled once, so anything that is not collapsed counts as expanded
  if($(`#${scopedId(id, 'settings-container')}`).hasClass('settings-collapsed'))
    settingsExpand(id);
  else
    settingsCollapse(id);
}

const moveSettings = () => {
  $('.big-tab')
    .each((index, el) => {
      let $tab = $(el);
      let id = rootIdFor($tab);
      let settings = $tab
        .find('.tab-settings')
        .first();

      $(settings).data('target', $tab.data('name'));
      $(settings).appendTo(`#${scopedId(id, 'settings-content')}`);
    });
}
