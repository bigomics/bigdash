import 'shiny';
import { handleSidebar } from './sidebar.js';
import { handleSettings } from './settings.js';
import { handleSwap } from './swap.js';
import { handleActivityTracker } from './user_activity.js';


$(function(){
  handleSwap();
  handleSettings();
  handleSidebar();
  handleActivityTracker();
});
