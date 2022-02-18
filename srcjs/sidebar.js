import 'jquery';

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
  $('#big-tabs')
    .find('.big-tab')
    .each((index, tab) => {
      toggleTab(tab, target);
    })
}

const toggleTab = (tab, target) => {
  let name = $(tab).data('name');

  if(name == target) {
    $(tab).removeClass('d-none');
    $(tab).show();
    $(tab).trigger('shown');
    return;
  }

  $(tab).addClass('d-none');
  $(tab).hide();
  $(tab).trigger('hidden');
}

const sidebarCollapse = () => {
  $('#sidebar-container').toggleClass('sidebar-expanded sidebar-collapsed');
  toggleCollapseLabel();
  toggleCollapseContent();
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
    css = {
      'transform': 'rotate(-90deg)',
      'margin-top': '3rem',
    };
    cssIcon = {
      'position': 'absolute',
      'top': 0,
      'right': '1rem',
    }
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
  // on load toggle first tab
  toggleFirstTab();

  $('.tab-trigger').on('click', (e) => {
    let target = $(e.currentTarget).data('target');
    toggleTabs(target)
  });

  $('.sidebar-menu').on('click', (e) => {
    console.log(e.currentTarget);
    $(e.currentTarget)
      .find('.sidebar-menu-icon')
      .toggleClass('fa-chevron-down fa-chevron-up');
  })
});
