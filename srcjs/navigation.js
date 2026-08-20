import 'jquery';
import 'shiny';
import { refreshHelp, initSidebarRoot } from './sidebar';
import { settingsExpand, settingsCollapse, initSettingsRoot, moveSettingsForRoot } from './settings';
import { DEFAULT_ID, scopedId } from './scope';

// Programmatic counterpart to sidebar.js / settings.js: these drive the same
// DOM those modules wire up, so the server can open, close and hide things.
// They hang off `window` because shinyjs::runjs evaluates in global scope.

// Every sidebarMenu() group should disappear entirely -- header, chevron,
// hr, collapse body -- the moment hiding/showing leaves it with zero visible
// sidebarMenuItem()s; a header that expands to an empty box is never useful,
// so this applies unconditionally, not just to promote_single = TRUE groups.
// A sidebarMenu(promote_single = TRUE) group additionally reads as a flat,
// top-level item -- no header/chevron, no indent -- whenever exactly one
// item is left visible. Both are re-run after every message that can change
// item-level visibility (below), so they stay correct through any number of
// filterTabs()/hideMenuItem() calls across the session, not just at initial
// render.
//
// `.css('display')` (not jQuery's `:visible`) on purpose: `:visible` also
// factors in the `.collapse` ancestor's own open/closed state, which would
// make every item in a currently-collapsed group read as "not visible" even
// though it's just accordion-closed, not filtered out.
const refreshMenuPromotion = () => {
	$('.sidebar-menu').each((i, headerLink) => {
		const $headerLink = $(headerLink);
		const $header = $headerLink.closest('p');
		const $hr = $header.next('hr');
		const $collapse = $(`#${$headerLink.data('target')}`);
		if ($collapse.length === 0) return;

		const visibleCount = $collapse
			.find('.tab-trigger')
			.filter((i, el) => $(el).css('display') !== 'none')
			.length;
		const empty = visibleCount === 0;
		const promote = !empty && visibleCount === 1 && $headerLink.data('promote-single') === true;

		$header.toggleClass('menu-empty', empty);
		$hr.toggleClass('menu-empty', empty);
		$collapse.toggleClass('menu-empty', empty);

		$header.toggleClass('menu-promoted', promote);
		$hr.toggleClass('menu-promoted', promote);
		$collapse.toggleClass('menu-promoted', promote);
	});
};

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
      refreshMenuPromotion();
  });

  Shiny.addCustomMessageHandler('bigdash-show-menuitem', (msg) => {
      $(`.tab-trigger[data-target=${msg.value}]`).show();
	  $(`.tab-trigger-hr[data-target=${msg.value}]`).show();
      refreshMenuPromotion();
  });

  Shiny.addCustomMessageHandler('bigdash-hide-tab', (msg) => {
      $(`.big-tab[data-name=${msg.value}]`).hide();
  });

  Shiny.addCustomMessageHandler('bigdash-show-tab', (msg) => {
      $(`.big-tab[data-name=${msg.value}]`).show();
  });

  // Unlike bigdash-hide-tab/bigdash-show-tab (which only ever touch the one
  // tab named in msg.value), this walks every tab/menu-item currently in the
  // DOM so it can hide whatever is NOT in the kept list, not just show what
  // is -- the R side has no registry of "every tab that exists" to loop
  // hideTab() over, but the DOM does.
  //
  // Scoped to msg.value.id's own #big-tabs/#sidebar-container (scopedId()
  // resolves the default id to the same unscoped #big-tabs/#sidebar-container
  // selector as before, so this is a no-op change for the common
  // single-bigPage() case) -- needed so several bigPage()s rendered in
  // parallel with different ids from the same server don't filter each
  // other's tabs just because they happen to reuse a tab name.
  Shiny.addCustomMessageHandler('bigdash-filter-tabs', (msg) => {
      const id = msg.value.id || DEFAULT_ID;
      // A single-tab vector auto-unboxes to a bare string over the wire, not
      // a 1-element array -- normalise so .includes() below is always an
      // array membership check.
      const keep = [].concat(msg.value.keep || []);
      const select = msg.value.select;

      $(`#${scopedId(id, 'big-tabs')} .big-tab`).each((i, el) => {
          $(el).toggle(keep.includes($(el).data('name')));
      });
      $(`#${scopedId(id, 'sidebar-container')} .tab-trigger[data-target], #${scopedId(id, 'sidebar-container')} .tab-trigger-hr[data-target]`).each((i, el) => {
          $(el).toggle(keep.includes($(el).data('target')));
      });
      refreshMenuPromotion();

      // bigdash.filterTabs() already resolved this to the current tab (if
      // still visible) or tabs[[1]] -- re-clicking an already-active tab is
      // a harmless no-op (Shiny dedupes identical setInputValue calls), so
      // this is always safe to fire.
      if (select) {
          $(`#${scopedId(id, 'sidebar-container')} .tab-trigger[data-target=${select}]`).trigger('click');
      }
  });

  Shiny.addCustomMessageHandler('bigdash-remove-tab', (msg) => {
      $(`.big-tab[data-name=${msg.value}]`).remove();
	  $(`.tab-settings:has(a#${msg.value.slice(0, -4)}-options)`).remove();
      $(`[data-target=${msg.value}]`).hide();
      refreshMenuPromotion();
  });

  // Primarily targets the sidebarMenu() group whose own id is msg.value
  // (its .collapse body's DOM id, and what its header <a data-target=...>
  // points at) -- not just a `span:contains(text)` label match, which was
  // one false positive away from hiding the wrong group (any span
  // containing that substring anywhere on the page) and broke the moment a
  // label was translated or renamed.
  //
  // Falls back to that old label match when no id matches, purely for
  // compatibility with callers written before sidebarMenu() had a settable
  // `id` -- they have no choice but to pass the visible label, same as this
  // always required. New code should give its sidebarMenu() an explicit
  // `id` and target that instead.
  const findMenuHeader = (value) => {
      let $header = $(`.sidebar-menu[data-target="${value}"]`).closest('p');
      if ($header.length === 0) {
          $header = $(`.sidebar-menu span:contains(${value})`).closest('p');
      }
      return $header;
  };

  Shiny.addCustomMessageHandler('bigdash-hide-menu-element', (msg) => {
      const $header = findMenuHeader(msg.value);
      // .nodisp marks the header as deliberately hidden so
      // show-tabs/unloadSidebar's landing-page reveal (navigation.js/
      // sidebar.js) leaves it alone, same contract every other
      // manually-hidden element here already relies on.
      $header.hide().addClass('nodisp');
      $header.next('hr').hide();
      // Close the body too, not just the header -- otherwise a group that
      // was open when hidden leaves its items sitting on screen with no
      // header left to click closed. Resolved from the header's own
      // data-target, not msg.value directly -- those differ when msg.value
      // matched via the legacy label fallback above.
      const collapseId = $header.find('.sidebar-menu').data('target');
      if (collapseId) {
          $(`#${collapseId}`).removeClass('show').hide();
      }
  });

  Shiny.addCustomMessageHandler('bigdash-show-menu-element', (msg) => {
      const $header = findMenuHeader(msg.value);
      $header.show().removeClass('nodisp');
      $header.next('hr').show();
      // Clear the inline display hide-menu-element set above so the
      // .collapse's own bootstrap class (show/not) governs it again --
      // reappears closed, same as a freshly rendered sidebarMenu(), not
      // forced open.
      const collapseId = $header.find('.sidebar-menu').data('target');
      if (collapseId) {
          $(`#${collapseId}`).css('display', '').removeClass('show');
      }
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
