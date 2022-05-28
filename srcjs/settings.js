import 'shiny';
import { isMobile } from './utils';

export const handleSettings = () => {
  moveSettings();
  $('.settings-label').on('click', (e) => {
    settingsCollapse();
  });
}

const settingsCollapse = () => {
  $('#settings-container').toggleClass('settings-expanded settings-collapsed');
  $('.settings').toggleClass('p-2');
  toggleCollapseLabel();
  toggleCollapseContent();
}

const toggleCollapseContent = () => {
  let $container = $('#settings-container')
    .find('.settings-content');

  if(isExpanded()) {
    $container.show();
    return
  }

  $container.hide();
}

const toggleCollapseLabel = () => {
  let css = {
    'transform': 'none',
    'margin-top': 0,
  };
  let cssIcon = {
    'position': 'absolute',
    'top': '1.8rem',
    'right': '2.4rem',
  }

  $('#settings-content').toggle();

  if(!isExpanded()) {
    css = {
      'transform': 'rotate(-90deg)',
      'margin-top': '3rem',
    };
    cssIcon = {
      'position': 'absolute',
      'top': '0.1rem',
      'right': '4.5rem',
    }
  }

  $('#settings-container')
    .find('.settings-label')
    .css(css);

  $('#settings-container')
    .find('.settings-icon')
    .css(cssIcon);
}

const isExpanded = () => {
  return $('#settings-container').hasClass('settings-expanded');
}

$(function(){
  setTimeout(() => {
    $('.settings-label').trigger('click');
  }, 50);
});


const moveSettings = () => {
  if(isMobile()){
    $('.tab-settings').removeClass('d-none');
    $('#settings-container').hide();
    return;
  }

  $('.big-tab')
    .each((index, el) => {
      let settings = $(el)
        .find('.tab-settings')
        .first();

      $(settings).data('target', $(el).data('name'));
      $(settings).appendTo('#settings-content');
    });
}
