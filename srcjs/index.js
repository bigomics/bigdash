import 'shiny';
import { handleSidebar } from './sidebar.js';
import { handleSettings } from './settings.js';
import { handleSwap } from './swap.js';
import { handleActivityTracker } from './user_activity.js';
import { handleNavigation } from './navigation.js';
import { handleModules } from './modules.js';
import { handleModals } from './modal.js';


// Outside the ready handler: these publish globals that inline onclick
// attributes and other scripts' ready handlers call, so they must exist
// before the DOM is ready rather than racing it.
handleNavigation();
handleModules();
// Delegated on document, so it also covers modals inserted later.
handleModals();

$(function(){
  handleSwap();
  handleSettings();
  handleSidebar();
  handleActivityTracker();
});
