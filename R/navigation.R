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

#' Finish wiring a [bigPage()] root inserted into the DOM after page load
#'
#' bigdash's one-time page-ready setup (settings-panel relocation, first-tab
#' selection) only ever sees the roots present in the DOM at that moment.
#' Call this once, right after inserting a new [bigPage()] at runtime (e.g.
#' via `bslib::nav_insert()` or `shiny::insertUI()` to lazily load a
#' module's UI on demand), to run that same per-root setup for it. Click
#' handlers (sidebar collapse, settings drawer, tab switching) do not need
#' this -- they are bound delegated and already cover new roots.
#'
#' Deferred via `session$onFlush()` so it is sent after (not possibly
#' before) the message that actually inserts the new root's markup, as long
#' as this is called after the insertion call in the same reactive tick --
#' `onFlush` callbacks run, and so their messages are sent to the client, in
#' registration order.
#'
#' @param session Shiny session.
#' @param id The `id` passed to the newly-inserted [bigPage()].
#' @export
bigdash.initRoot <- function(session, id) {
  session$onFlush(function() {
    send_nav(session, "bigdash-init-root", id)
  }, once = TRUE)
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

#' Hide a sidebar menu group by its id
#'
#' Hides the group's header/chevron/divider and closes its collapse body.
#' The body reappears closed (not force-expanded) the next time
#' [bigdash.showMenuElement()] reveals the group -- same as a freshly
#' rendered [sidebarMenu()], the user re-expands it by clicking.
#'
#' @param session Shiny session.
#' @param id The target [sidebarMenu()]'s own `id`. [sidebarMenu()]
#'   auto-generates one if you don't pass `id` yourself, so targeting a
#'   specific group from the server requires giving it an explicit,
#'   stable `id` in the UI first: `sidebarMenu(..., id = "reports-menu")`.
#'
#'   If nothing matches `id`, this falls back to matching the group's
#'   visible label instead (the pre-`id` behaviour) -- purely so callers
#'   written before [sidebarMenu()] took an `id` keep working unchanged.
#'   New code should always give its [sidebarMenu()] an explicit `id` and
#'   target that; matching by label breaks the moment two groups share a
#'   label or one gets renamed/translated.
#'
#' @export
bigdash.hideMenuElement <- function(session, id) {
  send_nav(session, "bigdash-hide-menu-element", id)
}

#' Show a sidebar menu group by its id
#' @inheritParams bigdash.hideMenuElement
#' @export
bigdash.showMenuElement <- function(session, id) {
  send_nav(session, "bigdash-show-menu-element", id)
}

#' Filter visible tabs and menu items
#'
#' Shows only the specified tabs (and their corresponding sidebar menu items).
#' Hides all other menu items and their associated tab canvases (`big-tab`
#' elements). Useful for dynamic filtering of available boards/views.
#'
#' The currently active tab stays selected if it is still among `tabs`;
#' otherwise the first tab in `tabs` is selected. This avoids bouncing the
#' user back to `tabs[[1]]` on every call when their current tab was never
#' actually filtered out.
#'
#' @param session Shiny session.
#' @param tabs Character vector of tab names (`data-name` / `target` values
#'   from [bigTabItem()], [sidebarItem()], etc.).
#' @param id Namespace id of the [bigPage()] instance to filter, as given to
#'   [bigPage()]/[bigTabs()]/[sidebar()] in the UI. Only needed when several
#'   `bigPage()`s render in parallel from the same server, each with its own
#'   `id` (not nested) -- omit it for the default, single-`bigPage()` case.
#' @export
bigdash.filterTabs <- function(session, tabs, id = BIGDASH_DEFAULT_ID) {
  if (!length(tabs)) {
    return(invisible(NULL))
  }
  if (!inherits(tabs, "character")) {
    tabs <- as.character(tabs)
  }
  tabs <- unique(tabs)

  ## The nav input is set at the root, under the bigTabs id ("qsee-nav").
  ## Read from inside module "qsee" that is input$nav; read from the app
  ## server it is input[["qsee-nav"]]. Strip the caller's own prefix when
  ## it is there. (Same lookup as bd_active_tab(), kept private here so
  ## this doesn't reach across into an unrelated module.)
  nav <- scoped_id(id, "nav")
  prefix <- session$ns("")
  if (nzchar(prefix) && startsWith(nav, prefix)) {
    nav <- substring(nav, nchar(prefix) + 1L)
  }
  current <- shiny::isolate(session$input[[nav]])
  select <- if (!is.null(current) && current %in% tabs) current else tabs[[1]]

  send_nav(session, "bigdash-filter-tabs", list(id = id, keep = tabs, select = select))
}
