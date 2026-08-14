import 'jquery';
import 'shiny';
import { isMobile } from './utils';
import { scopedId, rootIdFor, eachRootId } from './scope';

let sidebarHelpByRoot = {};
// whether the tab currently on screen has any help to show
let hasActiveHelp = {};

export const handleSidebar = () => {
  // Collapse click
  $('.sidebar-label').on('click', (e) => {
    sidebarToggle(rootIdFor($(e.currentTarget)));
  });

  // flip the help chevron with the panel it toggles, delegated because the
  // title is re-rendered on every tab switch
  $(document)
    .on('show.bs.collapse', '.sidebar-help-content', (e) => {
      setHelpIcon(rootIdFor($(e.currentTarget)), true);
    })
    .on('hide.bs.collapse', '.sidebar-help-content', (e) => {
      setHelpIcon(rootIdFor($(e.currentTarget)), false);
    });
}

const setHelpIcon = (id, open) => {
  $(`#${scopedId(id, 'sidebar-help-title')}`)
    .find('.sidebar-help-icon')
    .toggleClass('fa-angle-down', open)
    .toggleClass('fa-angle-up', !open);
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
  hasActiveHelp[id] = false;
  refreshHelp(id);

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
    // the help panel opens upwards: the chevron points up while the panel
    // is collapsed and down once it is open
    let open = $(`#${scopedId(id, 'sidebar-help-content')}`).hasClass('show');
    $(`#${scopedId(id, 'sidebar-help-title')}`)
      .html(
        `${help.title}
        <i class='fas fa-angle-${open ? 'down' : 'up'} float-right sidebar-help-icon'></i>`
      );
    $(`#${scopedId(id, 'sidebar-help-content')}`)
      .html(help.text);
  }
  hasActiveHelp[id] = !!help;
  refreshHelp(id);

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

// Exported so the server-side (R) `bigdash.open/closeSidebar()` can drive a
// specific bigPage() instance instead of the JS-only, unscoped globals in
// navigation.js.
export const setSidebarState = (id, expand) => {
  // nothing to do, the sidebar already is in the requested state
  if(expand === isExpanded(id))
    return;

  $(`#${scopedId(id, 'sidebar-container')}`).toggleClass('sidebar-expanded sidebar-collapsed');
  $(`#${scopedId(id, 'sidebar-wrapper')}`).toggleClass('p-2');
  $(`#${scopedId(id, 'sidebar-top-expanded')}`).toggleClass('d-none');
  $(`#${scopedId(id, 'sidebar-top-collapsed')}`).toggleClass('d-none');
  refreshHelp(id);
  toggleCollapseContent(id);
}

const sidebarToggle = (id) => setSidebarState(id, !isExpanded(id));

// The help box belongs on screen only when the sidebar is open *and* the
// active tab has help. Deciding those separately is what put it in the 3rem
// rail as an unreadable ribbon, and what left an empty box on tabs with no
// sidebarTabHelp(); both callers come through here so they cannot disagree.
export const refreshHelp = (id) => {
  $(`#${scopedId(id, 'sidebar-help-container')}`)
    .toggle(isExpanded(id) && !!hasActiveHelp[id]);
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

export const isExpanded = (id) => {
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
