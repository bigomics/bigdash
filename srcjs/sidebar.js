import 'jquery';
import 'shiny';
import { isMobile } from './utils';
import { scopedId, rootIdFor, $scopeFor, eachRootId } from './scope';

let sidebarHelpByRoot = {};
// whether the tab currently on screen has any help to show
let hasActiveHelp = {};

export const handleSidebar = () => {
  // Collapse click -- delegated (rather than bound to whatever matches at
  // this instant) so it also covers sidebars inserted later, e.g. via
  // bslib::nav_insert()/insertUI() for a lazily-loaded module.
  $(document).on('click', '.sidebar-label', (e) => {
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

  // Only this bigPage()'s triggers. A page-wide `$('.tab-trigger')` /
  // `[data-target=...]` walk would clear the orange bar on every other
  // instance the moment one of them changed tab.
  $scopeFor(id)
    .find('.tab-trigger')
    .each((index, el) => {
      const $el = $(el);
      const active = $el.data('target') == target;

      $el.toggleClass('text-muted', !active);
      $el.toggleClass('text-dark fw-bold', active);

      if ($el.is('hr')) return;

      if ($el.is('p')) {
        $el.toggleClass('active-sidebar active-sidebar-space', active);
      } else {
        $el.parent().toggleClass('active-sidebar', active);
      }
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
    // Unscoped, kept for backwards compatibility: existing apps observe
    // input$nav. With more than one bigPage() on the page every instance
    // writes this same input, so it cannot tell you *which* instance moved.
    Shiny.setInputValue('nav', name);
    // Scoped counterpart. Same value, but one input per bigPage() instance,
    // which is what lazy tab loading keys off -- a nested bigPage() must not
    // be able to trigger its parent's tabs (or vice versa) via a name clash.
    Shiny.setInputValue(scopedId(id, 'nav'), name);
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
  // we display the settings. Scoped to this root's own settings-content:
  // `moveSettings()` (settings.js) already relocates every `.tab-settings`
  // block there, and two bigPage() instances (nested or parallel) can
  // legitimately reuse the same tab `name`, so this must not touch another
  // instance's settings panel.
  $(`#${scopedId(id, 'settings-content')} .tab-settings`)
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

// Per-root setup: sidebar help content + auto-selecting the first tab.
// Called for every root at boot (below) and again -- for just the one new
// root -- by bigdash-init-root (navigation.js) when a bigPage() is
// inserted into the DOM after page load (e.g. via
// bslib::nav_insert()/insertUI() for a lazily-loaded module).
export const initSidebarRoot = (id, $root) => {
  // data to render in the sidebar help
  let $help = $root.find(`#${scopedId(id, 'sidebar-help')}`);
  if($help.length > 0)
    sidebarHelpByRoot[id] = JSON.parse($help.text());

  // on load toggle first tab
  toggleFirstTab(id, $root);
}

/* $(function() { */
$(document).on('shiny:connected', function() {
  eachRootId(initSidebarRoot);

  // Delegated so it also matches tab-triggers for roots inserted later.
  $(document).on('click', '.tab-trigger', (e) => {
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

  $(document).on('click', '.sidebar-menu', function(e){
    const $menu = $(this);
    const $menus = $scopeFor(rootIdFor($menu)).find('.sidebar-menu');
    $menus.not(this)
      .find('.sidebar-menu-icon')
      .removeClass('fa-angle-right')
      .removeClass('fa-angle-down')
      .addClass('fa-angle-right');
    $menu
      .find('.sidebar-menu-icon')
      .toggleClass('fa-angle-down fa-angle-right');

    const target = $menu.data('target');
    const ids = new Set($menus.map((_, el) => $(el).data('target')).get());
    collapse.forEach((el) => {
      if (!ids.has(el.id)) return;
      if (el.id == target)
        el.obj.toggle();
      else
        el.obj.hide();
    });
  })
});
