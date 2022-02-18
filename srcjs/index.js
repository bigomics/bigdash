import 'shiny';
import { handleSidebar } from './sidebar.js';
import { handleSettings } from './settings.js';

$(function(){
  handleSidebar();
  handleSettings();
});
