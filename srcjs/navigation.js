import 'jquery';
import 'shiny';
import { refreshHelp, initSidebarRoot } from './sidebar';
import { settingsExpand, settingsCollapse, initSettingsRoot, moveSettingsForRoot } from './settings';
import { DEFAULT_ID, scopedId } from './scope';

// Programmatic counterpart to sidebar.js / settings.js: these drive the same
// DOM those modules wire up, so the server can open, close and hide things.
// They hang off `window` because shinyjs::runjs evaluates in global scope.

// Scoped so a bigPage() nested inside another one (e.g. a module embedded as
// a tab of the main app) can be driven on its own, without also touching
// every other bigPage() instance on the page. `id` defaults to DEFAULT_ID so
// the legacy, page-wide `window.*` helpers below keep their original,
// unscoped behaviour.
const unloadSidebar = (id = DEFAULT_ID) => {
	$(`#${scopedId(id, 'sidebar-container')} .sidebar-content`)
		.children()
		.each((index, el) => {
			if($(el).hasClass('collapse')){
				$(el).removeClass('show');
				$(el).hide();
				return;
			}
			if($(el).hasClass('nodisp')){
				$(el).hide();
				return;
			}
			$(el).show();
		});
        $(`#${scopedId(id, 'sidebar-help-container')}`).hide();
}

// the label click runs through setSidebarState, which calls refreshHelp; the
// help box is no longer shown or hidden from here, or it would override the
// "sidebar open AND tab has help" rule sidebar.js applies
const sidebarClose = (id = DEFAULT_ID) => {
    if($(`#${scopedId(id, 'sidebar-container')}`).hasClass('sidebar-expanded')) {
	$(`#${scopedId(id, 'sidebar-container')} .sidebar-label`).trigger('click');
    }
}

const sidebarOpen = (id = DEFAULT_ID) => {
    if($(`#${scopedId(id, 'sidebar-container')}`).hasClass('sidebar-collapsed')) {
	$(`#${scopedId(id, 'sidebar-container')} .sidebar-label`).trigger('click');
    }
}

// The panel is click-toggled from its label (settings.js), so drive that,
// the same way sidebarOpen/sidebarClose drive '.sidebar-label'. Testing for
// the absence of 'settings-collapsed' rather than the presence of
// 'settings-expanded' matters: a freshly rendered panel is open but carries
// neither class.
const settingsClose = (id = DEFAULT_ID) => {
	if(!$(`#${scopedId(id, 'settings-container')}`).hasClass('settings-collapsed'))
		$(`#${scopedId(id, 'settings-container')} .settings-label`).trigger('click');
}

const settingsOpen = (id = DEFAULT_ID) => {
	if($(`#${scopedId(id, 'settings-container')}`).hasClass('settings-collapsed'))
		$(`#${scopedId(id, 'settings-container')} .settings-label`).trigger('click');
}

export const handleNavigation = () => {
  // Unscoped globals: `shinyjs::runjs("sidebarOpen()")` etc (no bigPage() id
  // available) evaluate these in global scope, so they keep defaulting to
  // the page's default/top-level bigPage() instance, same as before.
  window.unloadSidebar = () => unloadSidebar();
  window.sidebarClose = () => sidebarClose();
  window.sidebarOpen = () => sidebarOpen();
  window.settingsClose = () => settingsClose();
  window.settingsOpen = () => settingsOpen();

  // Scoped counterparts: driven by `bigdash.open/closeSidebar(session)` and
  // `bigdash.open/closeSettings(session)`, which send the calling module's
  // id (or no value at all for the default/top-level session) as msg.value.
  Shiny.addCustomMessageHandler('bigdash-open-sidebar', (msg) => {
    sidebarOpen(msg.value);
  });

  Shiny.addCustomMessageHandler('bigdash-close-sidebar', (msg) => {
    sidebarClose(msg.value);
  });

  Shiny.addCustomMessageHandler('bigdash-unload-sidebar', (msg) => {
    unloadSidebar(msg.value);
  });

  Shiny.addCustomMessageHandler('bigdash-open-settings', (msg) => {
    settingsExpand(msg.value || DEFAULT_ID);
  });

  Shiny.addCustomMessageHandler('bigdash-close-settings', (msg) => {
    settingsCollapse(msg.value || DEFAULT_ID);
  });

  Shiny.addCustomMessageHandler('show-tabs', (msg) => {
	let id = msg.value || DEFAULT_ID;
	setTimeout(() => {
	$(`#${scopedId(id, 'sidebar-container')} .sidebar-content`)
		.children()
		.each((index, el) => {
      if ($(el).hasClass('collapse')) {
				$(el).removeClass('show');
				$(el).css({'display' : ''});
				return;
			}
			if($(el).hasClass('w-100')) {
				$(el).children().children()[[1]].classList.remove('fa-angle-down');
				$(el).children().children()[[1]].classList.add('fa-angle-right');
			}
      if (!$(el).hasClass('nodisp')) {
        $(el).show();
      }
		});

	refreshHelp(id);
	}, 1000);
  });

  Shiny.addCustomMessageHandler('bigdash-select-tab', (msg) => {
      $(`.tab-trigger[data-target=${msg.value}]`).trigger('click');
  });

  Shiny.addCustomMessageHandler('bigdash-hide-menuitem', (msg) => {
      $(`.tab-trigger[data-target=${msg.value}]`).hide();
      $(`.tab-trigger-hr[data-target=${msg.value}]`).hide();
  });

  Shiny.addCustomMessageHandler('bigdash-show-menuitem', (msg) => {
      $(`.tab-trigger[data-target=${msg.value}]`).show();
	  $(`.tab-trigger-hr[data-target=${msg.value}]`).show();
  });

  Shiny.addCustomMessageHandler('bigdash-hide-tab', (msg) => {
      $(`.big-tab[data-name=${msg.value}]`).hide();
  });

  Shiny.addCustomMessageHandler('bigdash-show-tab', (msg) => {
      $(`.big-tab[data-name=${msg.value}]`).show();
  });

  Shiny.addCustomMessageHandler('bigdash-remove-tab', (msg) => {
      $(`.big-tab[data-name=${msg.value}]`).remove();
	  $(`.tab-settings:has(a#${msg.value.slice(0, -4)}-options)`).remove();
      $(`[data-target=${msg.value}]`).hide();
  });

  Shiny.addCustomMessageHandler('bigdash-hide-menu-element', (msg) => {
      $(`span:contains(${msg.value})`).closest('p').hide();
      $(`span:contains(${msg.value})`).closest('p').addClass("nodisp");
  });

  Shiny.addCustomMessageHandler('bigdash-show-menu-element', (msg) => {
      $(`span:contains(${msg.value})`).closest('p').show();
      $(`span:contains(${msg.value})`).closest('p').removeClass("nodisp");
  });

  // Finish wiring a bigPage() root that was inserted into the DOM after
  // page load (e.g. via bslib::nav_insert()/shiny::insertUI(), to lazily
  // load a module's UI on demand). Click handlers (.sidebar-label,
  // .settings-label, .tab-trigger) don't need this -- they're bound
  // delegated in sidebar.js/settings.js -- but moving each tab's settings
  // pane into place and selecting the first tab are one-off DOM
  // operations the page-ready setup only ever did for roots that existed
  // at that moment, so they need to be repeated explicitly for this one.
  Shiny.addCustomMessageHandler('bigdash-init-root', (msg) => {
      const id = msg.value;
      const $root = $(`.bigdash-app[data-bigdash-id="${id}"]`);
      if ($root.length === 0) return;

      moveSettingsForRoot(id, $root);
      initSettingsRoot(id);
      initSidebarRoot(id, $root);
  });
}
