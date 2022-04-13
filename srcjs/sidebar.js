import 'jquery';

let sidebarHelp = {};

export const handleSidebar = () => {
  // Collapse click
  $('.sidebar-label').on('click', (e) => {
    sidebarCollapse();
  });
}

const toggleFirstTab = () => {
  let target = $('.tab-trigger.tab-sidebar')
    .first()
    .data('target');

  toggleTabs(target);
}

const toggleTabs = (target) => {
  // reset be we set in case some help is missing
  $('#sidebar-help-container').hide();
      
  $('#big-tabs')
    .find('.big-tab')
    .each((index, tab) => {
      toggleTab(tab, target);
    })
}

const toggleTab = (tab, target) => {
  let name = $(tab).data('name');

  // we hide the tab content
  // it's not the one being shown
  if(name != target) {
    $(tab).addClass('d-none');
    $(tab).hide();
    $(tab).trigger('hidden');
    return ;
  }

  // we show the tab content
  $(tab).removeClass('d-none');
  $(tab).show();
  $(tab).trigger('shown');

  // we show the associated help
  // truthy in case it is missing
  if(sidebarHelp[name]) {
    $('#sidebar-help-title')
      .html(sidebarHelp[name].title);
    $('#sidebar-help-content')
      .html(sidebarHelp[name].text);
    $('#sidebar-help-container').show();
  } else {
    $('#sidebar-help-container').hide();
  }

  // we display the settings
  $('#settings-content').html('');
  let settings = $(tab)
    .find('.tab-settings')
    .first()
    .text();

  $('#settings-content').html(settings);
}

const sidebarCollapse = () => {
  $('#sidebar-container').toggleClass('sidebar-expanded sidebar-collapsed');
  $('#sidebar-help-container').toggle();
  collapseHelp();
  toggleCollapseLabel();
  toggleCollapseContent();
}

const collapseHelp = () => {
  let expanded = $('#sidebar-container').hasClass('sidebar-expanded')
  if(expanded){
    $('#sidebar-help-container').show();
    return;
  }
    
  $('#sidebar-help-container').hide();
}

const toggleCollapseContent = () => {
  let $container = $('#sidebar-container')
    .find('.sidebar-content');

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

  if(!isExpanded()) {
    $('#sidebar-wrapper').removeClass('m-4');
    css = {
      'transform': 'rotate(-90deg)',
      'margin-top': '3.5rem',
    };
    cssIcon = {
      'position': 'absolute',
      'top': 0,
      'right': '4rem',
    }
  } else {
    $('#sidebar-wrapper').addClass('m-4');
  }

  $('#sidebar-container')
    .find('.sidebar-label')
    .css(css);

  $('#sidebar-container')
    .find('.sidebar-icon')
    .css(cssIcon);
}

const isExpanded = () => {
  return $('#sidebar-container').hasClass('sidebar-expanded');
}

$(function() {
  // data to render in the sidebar help
  if($("#sidebar-help").length > 0)
    sidebarHelp = JSON.parse($("#sidebar-help").text());

  // on load toggle first tab
  toggleFirstTab();

  $('.tab-trigger').on('click', (e) => {
    let target = $(e.currentTarget).data('target');
    toggleTabs(target)
  });

  $('.sidebar-menu').on('click', (e) => {
    $(e.currentTarget)
      .find('.sidebar-menu-icon')
      .toggleClass('fa-chevron-down fa-chevron-up');
  })
});
