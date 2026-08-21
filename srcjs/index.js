import 'shiny';
import { handleSidebar } from './sidebar.js';
import { handleSettings } from './settings.js';
import { handleSwap } from './swap.js';
import { handleActivityTracker } from './user_activity.js';
import { handleNavigation } from './navigation.js';
import { handleModules } from './modules.js';
import { handleVisibility } from './visibility.js';


// Outside the ready handler: these publish globals that inline onclick
// attributes and other scripts' ready handlers call, so they must exist
// before the DOM is ready rather than racing it.
handleNavigation();
handleModules();
handleVisibility();

$(function(){
  handleSwap();
  handleSettings();
  handleSidebar();
  handleActivityTracker();
});
