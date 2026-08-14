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
  ## Same class list shiny:::validate_session_object accepts. Inside
  ## moduleServer the session is a bare `session_proxy`, which does NOT
  ## inherit from ShinySession, so checking for that alone rejects every
  ## call made from within a module.
  if (!inherits(session, c("ShinySession", "MockShinySession", "session_proxy"))) {
    stop("`session` must be a Shiny session object", call. = FALSE)
  }
  session$sendCustomMessage(type, if (is.null(value)) list() else list(value = value))
}

#' Resolve the [bigPage()] id `session` belongs to, for scoping nav messages.
#'
#' `session$ns(NULL)` is `""`/`character(0)` for the top-level session and
#' the module id for a `moduleServer()` session_proxy -- which is exactly the
#' `id` convention [bigPage()]/[sidebar()]/[settings()] already use (see
#' [scoped_id()]). Returning `NULL` for the top-level case (rather than `""`)
#' matters: `send_nav()` treats a `NULL` value as "no value field at all",
#' which the JS side's `scopedId()` then reads as the unscoped default,
#' matching pre-existing, page-wide behaviour exactly.
#'
#' @keywords internal
nav_scope_id <- function(session) {
  if (is.null(session)) {
    return(NULL)
  }
  id <- session$ns(NULL)
  if (length(id) == 0 || !nzchar(id)) {
    return(NULL)
  }
  id
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
  send_nav(session, "show-tabs", nav_scope_id(session))
}

## ------------------- sideBar ---------------------------
#' Open the sidebar
#'
#' @param session Shiny session that identifies which [bigPage()] instance to
#'   target. Defaults to the current reactive domain, so existing no-argument
#'   calls keep working unchanged -- at the top level that resolves to the
#'   default/unscoped `bigPage()`, and inside a `moduleServer()` it resolves
#'   to that module's own scoped `bigPage()`. Pass it explicitly (or leave
#'   the default) from inside a module to target that module's sidebar
#'   rather than the page-wide default. `NULL` (no reactive domain found, or
#'   passed explicitly) falls back to the pre-existing, unscoped behaviour.
#' @export
bigdash.openSidebar <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    shinyjs::runjs("sidebarOpen()")
    return(invisible(NULL))
  }
  send_nav(session, "bigdash-open-sidebar", nav_scope_id(session))
}

#' Close the sidebar
#' @inheritParams bigdash.openSidebar
#' @export
bigdash.closeSidebar <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    shinyjs::runjs("sidebarClose()")
    return(invisible(NULL))
  }
  send_nav(session, "bigdash-close-sidebar", nav_scope_id(session))
}

#' Collapse the sidebar back to its initial state
#' @inheritParams bigdash.openSidebar
#' @export
bigdash.unloadSidebar <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    shinyjs::runjs("unloadSidebar()")
    return(invisible(NULL))
  }
  send_nav(session, "bigdash-unload-sidebar", nav_scope_id(session))
}

#' Open or close the sidebar
#' @param state `TRUE` to open, `FALSE` to close.
#' @inheritParams bigdash.openSidebar
#' @export
bigdash.toggleSidebar <- function(state, session = shiny::getDefaultReactiveDomain()) {
  if (state) bigdash.openSidebar(session)
  if (!state) bigdash.closeSidebar(session)
}

## ------------------- settingsBar ---------------------------
#' Open the settings drawer
#' @param lock Ignored, kept so existing calls keep working. The drawer no
#'   longer closes itself when the pointer leaves, so it is always "locked".
#' @inheritParams bigdash.openSidebar
#' @export
bigdash.openSettings <- function(lock = TRUE, session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    shinyjs::runjs("settingsOpen()")
    return(invisible(NULL))
  }
  send_nav(session, "bigdash-open-settings", nav_scope_id(session))
}

#' Close the settings drawer
#' @inheritParams bigdash.openSidebar
#' @export
bigdash.closeSettings <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    shinyjs::runjs("settingsClose()")
    return(invisible(NULL))
  }
  send_nav(session, "bigdash-close-settings", nav_scope_id(session))
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
