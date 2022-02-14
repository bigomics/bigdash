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
});
