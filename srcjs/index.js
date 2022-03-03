import 'shiny';
import { handleSidebar } from './sidebar.js';
import { handleSettings } from './settings.js';
import { handleDrag } from './drag.js';

$(function(){
  handleDrag();
  handleSidebar();
  handleSettings();
});
