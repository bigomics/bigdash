import 'shiny';

export const handleSettings = () => {
  $('.settings-label').on('click', (e) => {
    settingsCollapse();
  });
}

const settingsCollapse = () => {
  $('#settings-container').toggleClass('settings-expanded settings-collapsed');
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
    'position': 'relative',
    'top': 0,
    'right': 0,
  }

  $('#settings-content').toggle();

  if(!isExpanded()) {
    css = {
      'transform': 'rotate(-90deg)',
      'margin-top': '5rem',
    };
    cssIcon = {
      'position': 'absolute',
      'top': 0,
      'right': '1rem',
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
