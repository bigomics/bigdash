import 'shiny';
import { isMobile } from './utils';

export const handleSettings = () => {
  moveSettings();

  let $container = $('#settings-container')
    .find('.settings-content');

  if(!isMobile()){
    // check if lock is unlocked and run mouse events
    
    // show settings tab on desktop with mouse entering settings
    $('#settings-container').mouseenter(function(){
      settingsExpand($container);
    })
    
    // hide settings tab on desktop with mouse entering settings
    //this code can be wrapped in a function, since its used in many places
    $('#settings-container').mouseleave(function(){
      settingsCollapse();
    })
  }else if(isMobile){
    // hide settings tab on mobile
      $('.tab-settings').removeClass('d-none');
      $('#settings-container').hide();
      $('#tab-settings').hide();
      return;
  };

  // lockstate = false will lock settings upon lock click
  // lockstate = true will unlock settings upon lock click
  var lockState = false;

  $(".settings-lock").click(function(){
    // click listener to change the locked and unlocked settings
      if (lockState === false) {
        $('#settings-container').removeClass("settings-unlocked");
        $('#settings-container').addClass("settings-locked");
        $('.settings-lock').removeClass("fa-lock-open");
        $('.settings-lock').addClass("fa-lock");
        $('#settings-container').off("mouseleave");
        lockState = true;
      } else {
        $('#settings-container').removeClass("settings-locked");
        $('#settings-container').addClass("settings-unlocked");
        $('#settings-container').mouseleave(function(){
          settingsCollapse();
          $('#settings-container').hide();
          $('.tab-settings').hide();
        })
        $('.settings-lock').removeClass("fa-lock");
        $('.settings-lock').addClass("fa-lock-open");
        lockState = false;
     }
  });
}

const settingsExpand = () => {
  //change settings sidebar css upon expanding
  $('.settings-lock').show(); // show lock when settings sidebar is expanded
  $('#settings-container').removeClass('settings-collapsed');
  $('#settings-container').addClass('settings-expanded');
  //change icon css style for expanded position
  $('.settings-lock').removeClass('settings-lock-collapsed');
  $('.settings-lock').addClass('settings-lock-expanded');
  $('.settings').addClass('p-2');
  $('#settings-container').show();
  $('.tab-settings').show();
  toggleCollapseLabel();
}

const settingsCollapse = () => {
  $('#settings-container').removeClass('settings-expanded');
  $('#settings-container').removeClass('settings-collapsed');
  $('#settings-container').addClass('settings-collapsed');
  //change icon css style for expanded position
  $('.settings-lock').removeClass('settings-lock-expanded');
  $('.settings').removeClass('p-2');
  $('.settings-lock').hide(); // lock should be hidden when settings is collapsed
  $('#settings-container').hide();
  $('.tab-settings').hide();
  toggleCollapseLabel();
}

const toggleCollapseLabel = () => {
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

  if(!isExpanded()) {
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

const moveSettings = () => {
  $('.big-tab')
    .each((index, el) => {
      let settings = $(el)
        .find('.tab-settings')
        .first();

      $(settings).data('target', $(el).data('name'));
      $(settings).appendTo('#settings-content');
    });
}
