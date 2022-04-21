import 'shiny';
import { handleSidebar } from './sidebar.js';
import { handleSettings } from './settings.js';
import { handleSwap } from './swap.js';

$(function(){
  handleSwap();
  handleSettings();
  handleSidebar();
});
