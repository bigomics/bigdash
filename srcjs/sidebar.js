import 'jquery';

export const handleSidebar = () => {
  // Collapse click
  $('[data-toggle=sidebar-collapse]').on('click', (e) => {
    sidebarCollapse(e.currentTarget);
  });
}

const sidebarCollapse = (el) => {
  $('#sidebar-container').toggleClass('sidebar-expanded sidebar-collapsed');
  toggleCollapseButton(el);
  toggleCollapse();
}

const toggleCollapseButton = (el) => {
  if(isExpanded()) {
    $(el).html('<span>Collapse</span>');
    return;
  }

  $(el).html('<i class="fa fa-expand"></i>');
}

const toggleCollapse = () => {
  $('.show-expanded').toggleClass('d-none');
  $('.hide-expanded').toggleClass('d-none');
}

const isExpanded = () => {
  return $('#sidebar-container').hasClass('sidebar-expanded');
}

$(function() {
  $('[data-bs-toggle]').on('click', (e) => {
    $(e.currentTarget)
      .find('.toggler')
      .toggleClass('fa-chevron-down')
      .toggleClass('fa-chevron-up')
  });
  
  // on load toggle first tab
  toggleFirstTab();

  $('.tab-trigger').on('click', (e) => {
    let target = $(e.currentTarget).data('target');
    toggleTabs(target)
  })
});


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
