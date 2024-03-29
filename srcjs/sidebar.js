import 'jquery';
import 'shiny';
import { isMobile } from './utils';

let sidebarHelp = {};

export const handleSidebar = () => {
  // Collapse click
  $('.sidebar-label').on('click', (e) => {
    sidebarCollapse();
  });
}

const toggleFirstTab = () => {
  let $el = $('.tab-trigger.tab-sidebar')
    .first();

  let target = $el.data('target');

  toggleTabs(target);
}

const toggleTabs = (target) => {
  // reset be we set in case some help is missing
  $('#sidebar-help-container').hide();

  $('#big-tabs')
    .find('.big-tab')
    .each((index, tab) => {
      toggleTab(tab, target);
    });

  $('.tab-trigger')
    .each((index, el) => {
      let name = $(el).data('target');
      if(target == name){
        $(`[data-target='${name}']`).removeClass('text-muted');
        $(`[data-target='${name}']`).addClass('text-dark fw-bold');

        if($(`[data-target='${name}']`).not('hr').is('p'))
          $(`[data-target='${name}']`).not('hr').addClass('active-sidebar active-sidebar-space');

        if(!$(`[data-target='${name}']`).not('hr').is('p'))
          $(`[data-target='${name}']`).not('hr').parent().addClass('active-sidebar');
        return;
      }

      $(`[data-target='${name}']`).removeClass('active-sidebar active-sidebar-space');
      $(`[data-target='${name}']`).parent().removeClass('active-sidebar');

      $(`[data-target='${name}']`).addClass('text-muted');
      $(`[data-target='${name}']`).removeClass('text-dark fw-bold');
    });
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
  try {
    Shiny.setInputValue('nav', name);
  } catch(error) {
    console.error(error);
  }

  // we show the associated help
  // truthy in case it is missing
  if(sidebarHelp[name]) {
    $('#sidebar-help-title')
      .html(
        `${sidebarHelp[name].title}
        <i class='fas fa-angle-down float-right'></i>`
      );
    $('#sidebar-help-content')
      .html(sidebarHelp[name].text);
    $('#sidebar-help-container').show();
  } else {
    $('#sidebar-help-container').hide();
  }

  if(isMobile())
    return;

  let found = false;
  // we display the settings
  $('.tab-settings')
    .each((index, el) => {
      let tg = $(el).data('target');

      if(tg != name) {
        $(el).addClass('d-none');
        $(el).trigger('hidden');
        return;
      }

      found = true;
      $(el).removeClass('d-none');
      $(el).trigger('shown');
    });

  if(!found){
    $('#settings-container').removeClass('d-md-block');
    $('#settings-container').hide();
  } else {
    $('#settings-container').addClass('d-md-block');
    $('#settings-container').show();
  }

  // run hook
  let hook = eval($('#settings-posthook').text());
  if(hook)
    eval(hook());
}

const sidebarCollapse = () => {
  $('#sidebar-container').toggleClass('sidebar-expanded sidebar-collapsed');
  $('#sidebar-help-container').toggle();
  $('#sidebar-wrapper').toggleClass('p-2');
  $('#sidebar-top-expanded').toggleClass('d-none');
  $('#sidebar-top-collapsed').toggleClass('d-none');
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
    'margin-top': '1rem',
  };
  let cssIcon = {
    'position': 'relative',
    'top': 0,
    'right': 0,
    'transform': 'rotate(0deg)',
  }

  if(!isExpanded()) {
    css = {
      'transform': 'rotate(-90deg)',
      'margin-top': '3.5rem',
    };
    cssIcon = {
      'position': 'absolute',
      'top': 0,
      'right': '4rem',
      'transform': 'rotate(-90deg)',
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

/* $(function() { */
$(document).on('shiny:connected', function() {
  // data to render in the sidebar help
  if($("#sidebar-help").length > 0)
    sidebarHelp = JSON.parse($("#sidebar-help").text());

  // on load toggle first tab
  toggleFirstTab();

  $('.tab-trigger').on('click', (e) => {
    let target = $(e.currentTarget).data('target');
    toggleTabs(target);
  });

  let collapse = [];
  $('.sidebar-content')
    .find('.collapse')
    .each((index, el) => {
      collapse.push({
        id: $(el).attr('id'),
        obj: new bootstrap.Collapse(el, {toggle: false}),
      });
    });

  $('.sidebar-menu').click(function(){
    $('.sidebar-menu').not(this)
      .find('.sidebar-menu-icon')
      .removeClass('fa-angle-right')
      .removeClass('fa-angle-down')
      .addClass('fa-angle-right');
    $(this)
      .find('.sidebar-menu-icon')
      .toggleClass('fa-angle-down fa-angle-right');
  })

  $('.sidebar-menu').on('click', (e) => {

    let target = $(e.currentTarget).data('target');

    collapse.map((el) => {
      if(el.id == target)
        el.obj.toggle();
      else
        el.obj.hide();
    });
  })
});
