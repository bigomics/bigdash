import 'jquery';
import 'shiny';
import { refreshHelp } from './sidebar';
import { DEFAULT_ID } from './scope';

// Programmatic counterpart to sidebar.js / settings.js: these drive the same
// DOM those modules wire up, so the server can open, close and hide things.
// They hang off `window` because shinyjs::runjs evaluates in global scope.

const unloadSidebar = () => {
	$('.sidebar-content')
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
        $('#sidebar-help-container').hide();
}

// the label click runs through setSidebarState, which calls refreshHelp; the
// help box is no longer shown or hidden from here, or it would override the
// "sidebar open AND tab has help" rule sidebar.js applies
const sidebarClose = () => {
    if($('#sidebar-container').hasClass('sidebar-expanded')) {
	$('.sidebar-label').trigger('click');
    }
}

const sidebarOpen = () => {
    if($('#sidebar-container').hasClass('sidebar-collapsed')) {
	$('.sidebar-label').trigger('click');
    }
}

// The panel is click-toggled from its label (settings.js), so drive that,
// the same way sidebarOpen/sidebarClose drive '.sidebar-label'. Testing for
// the absence of 'settings-collapsed' rather than the presence of
// 'settings-expanded' matters: a freshly rendered panel is open but carries
// neither class.
const settingsClose = () => {
	if(!$('#settings-container').hasClass('settings-collapsed'))
		$('.settings-label').trigger('click');
}

const settingsOpen = () => {
	if($('#settings-container').hasClass('settings-collapsed'))
		$('.settings-label').trigger('click');
}

export const handleNavigation = () => {
  window.unloadSidebar = unloadSidebar;
  window.sidebarClose = sidebarClose;
  window.sidebarOpen = sidebarOpen;
  window.settingsClose = settingsClose;
  window.settingsOpen = settingsOpen;

  Shiny.addCustomMessageHandler('show-tabs', (msg) => {
	setTimeout(() => {
	$('.sidebar-content')
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

	refreshHelp(DEFAULT_ID);
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
}
