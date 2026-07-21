import 'jquery';
import 'shiny';
import { isMobile } from './utils';
import { scopedId, rootIdFor, eachRootId } from './scope';

let sidebarHelpByRoot = {};

export const handleSidebar = () => {
  // Collapse click
  $('.sidebar-label').on('click', (e) => {
    sidebarCollapse(rootIdFor($(e.currentTarget)));
  });
}

const toggleFirstTab = (id, $root) => {
  let $el = $root
    .find('.tab-trigger.tab-sidebar')
    .first();

  let target = $el.data('target');

  if(target)
    toggleTabs(target, id);
}

const toggleTabs = (target, id) => {
  // reset be we set in case some help is missing
  $(`#${scopedId(id, 'sidebar-help-container')}`).hide();

  $(`#${scopedId(id, 'big-tabs')}`)
    .find('.big-tab')
    .each((index, tab) => {
      toggleTab(tab, target, id);
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

const toggleTab = (tab, target, id) => {
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
  let help = (sidebarHelpByRoot[id] || {})[name];
  if(help) {
    $(`#${scopedId(id, 'sidebar-help-title')}`)
      .html(
        `${help.title}
        <i class='fas fa-angle-down float-right'></i>`
      );
    $(`#${scopedId(id, 'sidebar-help-content')}`)
      .html(help.text);
    $(`#${scopedId(id, 'sidebar-help-container')}`).show();
  } else {
    $(`#${scopedId(id, 'sidebar-help-container')}`).hide();
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

  let $settingsContainer = $(`#${scopedId(id, 'settings-container')}`);
  if(!found){
    $settingsContainer.removeClass('d-md-block');
    $settingsContainer.hide();
  } else {
    $settingsContainer.addClass('d-md-block');
    $settingsContainer.show();
  }

  // run hook
  let hook = eval($(`#${scopedId(id, 'settings-posthook')}`).text());
  if(hook)
    eval(hook());
}

const sidebarCollapse = (id) => {
  $(`#${scopedId(id, 'sidebar-container')}`).toggleClass('sidebar-expanded sidebar-collapsed');
  $(`#${scopedId(id, 'sidebar-help-container')}`).toggle();
  $(`#${scopedId(id, 'sidebar-wrapper')}`).toggleClass('p-2');
  $(`#${scopedId(id, 'sidebar-top-expanded')}`).toggleClass('d-none');
  $(`#${scopedId(id, 'sidebar-top-collapsed')}`).toggleClass('d-none');
  collapseHelp(id);
  toggleCollapseLabel(id);
  toggleCollapseContent(id);
}

const collapseHelp = (id) => {
  let expanded = $(`#${scopedId(id, 'sidebar-container')}`).hasClass('sidebar-expanded')
  if(expanded){
    $(`#${scopedId(id, 'sidebar-help-container')}`).show();
    return;
  }

  $(`#${scopedId(id, 'sidebar-help-container')}`).hide();
}

const toggleCollapseContent = (id) => {
  let $container = $(`#${scopedId(id, 'sidebar-container')}`)
    .find('.sidebar-content');

  if(isExpanded(id)) {
    $container.show();
    return
  }

  $container.hide();
}

const toggleCollapseLabel = (id) => {
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

  if(!isExpanded(id)) {
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

  $(`#${scopedId(id, 'sidebar-container')}`)
    .find('.sidebar-label')
    .css(css);

  $(`#${scopedId(id, 'sidebar-container')}`)
    .find('.sidebar-icon')
    .css(cssIcon);
}

const isExpanded = (id) => {
  return $(`#${scopedId(id, 'sidebar-container')}`).hasClass('sidebar-expanded');
}

/* $(function() { */
$(document).on('shiny:connected', function() {
  eachRootId((id, $root) => {
    // data to render in the sidebar help
    let $help = $root.find(`#${scopedId(id, 'sidebar-help')}`);
    if($help.length > 0)
      sidebarHelpByRoot[id] = JSON.parse($help.text());

    // on load toggle first tab
    toggleFirstTab(id, $root);
  });

  $('.tab-trigger').on('click', (e) => {
    let $trigger = $(e.currentTarget);
    let target = $trigger.data('target');
    toggleTabs(target, rootIdFor($trigger));
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
