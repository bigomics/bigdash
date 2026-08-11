##
## Copyright (c) 2018-2026 BigOmics Analytics SA. All rights reserved.
##

## Server-side navigation. Each of these sends a custom message handled in
## srcjs/navigation.js, or calls one of the globals defined there.
##
## The `bigdash.` prefix predates these living in the package; it is kept so
## that calling code reads the same whether it dot-sources them or imports
## the package.

#' @keywords internal
send_nav <- function(session, type, value = NULL) {
  if (!inherits(session, "ShinySession")) {
    stop("`session` must be a Shiny session object", call. = FALSE)
  }
  session$sendCustomMessage(type, if (is.null(value)) list() else list(value = value))
}

#' Select a tab
#' @param session Shiny session.
#' @param selected `data-target` of the tab to select.
#' @export
bigdash.selectTab <- function(session, selected) {
  send_nav(session, "bigdash-select-tab", selected)
}

#' Reveal the sidebar menu after the landing page
#' @param session Shiny session.
#' @export
bigdash.showTabs <- function(session) {
  send_nav(session, "show-tabs")
}

## ------------------- sideBar ---------------------------
#' Open the sidebar
#' @export
bigdash.openSidebar <- function() {
  shinyjs::runjs("sidebarOpen()")
}

#' Close the sidebar
#' @export
bigdash.closeSidebar <- function() {
  shinyjs::runjs("sidebarClose()")
}

#' Collapse the sidebar back to its initial state
#' @export
bigdash.unloadSidebar <- function() {
  shinyjs::runjs("unloadSidebar()")
}

#' Open or close the sidebar
#' @param state `TRUE` to open, `FALSE` to close.
#' @export
bigdash.toggleSidebar <- function(state) {
  if (state) bigdash.openSidebar()
  if (!state) bigdash.closeSidebar()
}

## ------------------- settingsBar ---------------------------
#' Open the settings drawer
#' @param lock Keep the drawer open when the pointer leaves it.
#' @export
bigdash.openSettings <- function(lock = TRUE) {
  shinyjs::runjs("settingsUnlock()")
  shinyjs::runjs("settingsOpen()")
  if (lock) {
    Sys.sleep(0.1)
    shinyjs::runjs("settingsLock()")
  }
}

#' Close the settings drawer
#' @export
bigdash.closeSettings <- function() {
  shinyjs::runjs("settingsUnlock()")
  shinyjs::runjs("settingsClose()")
}

## --------------------menuItem --------------------------
#' Show a sidebar menu item
#' @param session Shiny session.
#' @param item `data-target` of the menu item.
#' @export
bigdash.showMenuItem <- function(session, item) {
  send_nav(session, "bigdash-show-menuitem", item)
}

#' Hide a sidebar menu item
#' @param session Shiny session.
#' @param item `data-target` of the menu item.
#' @export
bigdash.hideMenuItem <- function(session, item) {
  send_nav(session, "bigdash-hide-menuitem", item)
}

#' Show or hide a sidebar menu item
#' @param session Shiny session.
#' @param item `data-target` of the menu item.
#' @param state `TRUE` to show, `FALSE` to hide.
#' @export
bigdash.toggleMenuItem <- function(session, item, state) {
  if (state) bigdash.showMenuItem(session, item)
  if (!state) bigdash.hideMenuItem(session, item)
}

## --------------------BigTab --------------------------
#' Show a tab and its menu item
#' @param session Shiny session.
#' @param tab `data-name` of the tab.
#' @export
bigdash.showTab <- function(session, tab) {
  send_nav(session, "bigdash-show-tab", tab)
  bigdash.showMenuItem(session, tab)
}

#' Hide a tab and its menu item
#' @param session Shiny session.
#' @param tab `data-name` of the tab.
#' @export
bigdash.hideTab <- function(session, tab) {
  send_nav(session, "bigdash-hide-tab", tab)
  bigdash.hideMenuItem(session, tab)
}

#' Show or hide a tab
#' @param session Shiny session.
#' @param tab `data-name` of the tab.
#' @param state `TRUE` to show, `FALSE` to hide.
#' @export
bigdash.toggleTab <- function(session, tab, state) {
  if (state) bigdash.showTab(session, tab)
  if (!state) bigdash.hideTab(session, tab)
}

#' Remove a tab, its settings pane and its menu item
#' @param session Shiny session.
#' @param tab `data-name` of the tab.
#' @export
bigdash.removeTab <- function(session, tab) {
  send_nav(session, "bigdash-remove-tab", tab)
}

#' Hide a sidebar menu section by its label
#' @param session Shiny session.
#' @param name Visible label of the section.
#' @export
bigdash.hideMenuElement <- function(session, name) {
  send_nav(session, "bigdash-hide-menu-element", name)
}

#' Show a sidebar menu section by its label
#' @param session Shiny session.
#' @param name Visible label of the section.
#' @export
bigdash.showMenuElement <- function(session, name) {
  send_nav(session, "bigdash-show-menu-element", name)
}
