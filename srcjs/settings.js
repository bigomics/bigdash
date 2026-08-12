import 'shiny';
import { isMobile } from './utils';
import { scopedId, rootIdFor, eachRootId } from './scope';

const lockedByRoot = {};

export const handleSettings = () => {
  moveSettings();

  eachRootId((id) => {
    let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);

    if($settingsContainer.length === 0)
      return;

    lockedByRoot[id] = false;

    if(!isMobile()){
      // check if lock is unlocked and run mouse events

      // show settings tab on desktop with mouse entering settings
      $settingsContainer.on('mouseenter', () => {
        settingsExpand(id);
      });

      // hide settings tab on desktop with mouse leaving settings
      $settingsContainer.on('mouseleave', () => {
        settingsCollapse(id);
      });
    } else {
      // hide settings tab on mobile
      $settingsContainer.find('.tab-settings').removeClass('d-none');
      $settingsContainer.hide();
      return;
    }

    $settingsContainer.find('.settings-lock').on('click', () => {
      // click listener to change the locked and unlocked settings
      if (lockedByRoot[id] === false) {
        $settingsContainer.removeClass('settings-unlocked');
        $settingsContainer.addClass('settings-locked');
        $settingsContainer.find('.settings-lock')
          .removeClass('fa-lock-open')
          .addClass('fa-lock');
        $settingsContainer.off('mouseleave');
        lockedByRoot[id] = true;
      } else {
        $settingsContainer.removeClass('settings-locked');
        $settingsContainer.addClass('settings-unlocked');
        $settingsContainer.on('mouseleave', () => {
          settingsCollapse(id);
          $settingsContainer.hide();
          $settingsContainer.find('.tab-settings').hide();
        });
        $settingsContainer.find('.settings-lock')
          .removeClass('fa-lock')
          .addClass('fa-lock-open');
        lockedByRoot[id] = false;
      }
    });
  });
}

const settingsExpand = (id) => {
  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  //change settings sidebar css upon expanding
  $settingsContainer.find('.settings-lock').show(); // show lock when settings sidebar is expanded
  $settingsContainer.removeClass('settings-collapsed');
  $settingsContainer.addClass('settings-expanded');
  //change icon css style for expanded position
  $settingsContainer.find('.settings-lock').removeClass('settings-lock-collapsed');
  $settingsContainer.find('.settings-lock').addClass('settings-lock-expanded');
  $settingsContainer.find('.settings').addClass('p-2');
  $settingsContainer.show();
  $settingsContainer.find('.tab-settings').show();
  toggleCollapseLabel(id);
}

const settingsCollapse = (id) => {
  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  $settingsContainer.removeClass('settings-expanded');
  $settingsContainer.removeClass('settings-collapsed');
  $settingsContainer.addClass('settings-collapsed');
  //change icon css style for expanded position
  $settingsContainer.find('.settings-lock').removeClass('settings-lock-expanded');
  $settingsContainer.find('.settings').removeClass('p-2');
  $settingsContainer.find('.settings-lock').hide(); // lock should be hidden when settings is collapsed
  $settingsContainer.hide();
  $settingsContainer.find('.tab-settings').hide();
  toggleCollapseLabel(id);
}

const toggleCollapseLabel = (id) => {
  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  let css = {
    'transform': 'none',
    'margin-top': 0,
  };
  let cssIcon = {
    'float': 'right',
    'position': 'relative',
    'top': 'inherit',
    'right': 'inherit',
    'transform': 'rotate(0deg)',
  }

  if(!isExpanded(id)) {
    css = {
      'transform': 'rotate(-90deg)',
      'margin-top': '3rem',
    };
    cssIcon = {
      'position': 'absolute',
      'top': '0.1rem',
      'right': '4.5rem',
      'transform': 'rotate(-90deg)',
    }
  }

  $settingsContainer
    .find('.settings-label')
    .css(css);

  $settingsContainer
    .find('.settings-icon')
    .css(cssIcon);
}

const isExpanded = (id) => {
  return $(`#${scopedId(id, 'settings-container')}`).hasClass('settings-expanded');
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
