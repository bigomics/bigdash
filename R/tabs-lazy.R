#' Load a tab's UI and server the first time it is opened
#'
#' A [bigTabItem()] normally carries its whole board: the markup is built and
#' the module server started before the user has been anywhere near that tab.
#' With many tabs that is the dominant cost of opening a dashboard, and most of
#' it is for tabs nobody visits.
#'
#' `bigTabsLazy()` defers both halves. Give it, per tab, a function returning
#' the UI and a function starting the server; on the first activation of that
#' tab it inserts the UI, then calls the server, then never again.
#'
#' Leave the tab's heavy content out of [bigTabItem()] and keep only what must
#' exist up front there -- typically the sidebar inputs and a placeholder.
#'
#' @section Placeholder cleanup:
#' Give the placeholder the class `"bigtabslazy-placeholder"` (e.g. a loading
#' spinner) and it is removed automatically, as a direct child of the tab,
#' once the real UI for that tab is inserted. Without this class the
#' placeholder is left in the DOM forever, stacked underneath the real
#' content.
#'
#' @section Ordering:
#' The UI is inserted before the server function runs. Module servers routinely
#' call `updateSelectInput()` and friends during initialisation, and those
#' messages are dropped if the elements are not in the DOM yet.
#'
#' @section Scoping:
#' Activation is read from the *scoped* nav input (`<id>-nav`, or `nav` for the
#' default instance), so a nested [bigPage()] cannot trigger its parent's tabs
#' through a tab-name clash. The UI is inserted with a selector rooted at this
#' instance's `#<id>-big-tabs` for the same reason.
#'
#' @param tabs Named list, one entry per tab, named by the tab's `name` as
#'   given to [bigTabItem()] -- the fully-namespaced name (e.g.
#'   `session$ns("plots-tab")`), not the bare one, unless `id` is the default
#'   `"app"`. A name that doesn't start with that namespace is rejected up
#'   front, since otherwise nothing loads and nothing errors. Each entry is a
#'   list with `ui` and/or `server`, each a function of no arguments; either
#'   may be omitted. Set `preload = TRUE` on an entry to load it immediately
#'   instead of waiting for its tab to be opened -- for a board whose server
#'   other boards depend on, which therefore cannot wait for a click.
#' @param id Namespace id, matching the enclosing [bigPage()].
#' @param session Shiny session; defaults to the current one.
#'
#' @return Invisibly, a function returning the names of the tabs loaded so far.
#'
#' @examples
#' \dontrun{
#' ## ui
#' bigTabs(
#'   bigTabItem("plots-tab", plotsInputs("plots"))  # inputs only
#' )
#'
#' ## server
#' bigTabsLazy(list(
#'   "plots-tab" = list(
#'     ui     = function() plotsUI("plots"),
#'     server = function() plotsServer("plots", data = data)
#'   )
#' ))
#' }
#'
#' @export
bigTabsLazy <- function(tabs,
                        id = BIGDASH_DEFAULT_ID,
                        session = shiny::getDefaultReactiveDomain()) {
  if (!is.list(tabs) || is.null(names(tabs)) || any(!nzchar(names(tabs)))) {
    stop("`tabs` must be a named list, one entry per tab name")
  }
  if (is.null(session)) {
    stop("bigTabsLazy() must be called from a Shiny server function")
  }

  ## The one failure mode this can't otherwise surface: a `tabs` name that
  ## doesn't match any bigTabItem(), silently. load_tab() below is only ever
  ## invoked with whatever the client reports for the nav input -- the same
  ## fully-namespaced name bigTabItem() was given in the UI (id = "app" is
  ## the one case with no namespace at all) -- so a mismatch here means the
  ## observeEvent() driving it just never fires; nothing loads and nothing
  ## errors. Catch it up front instead.
  id_prefix <- if (is.null(id) || identical(id, BIGDASH_DEFAULT_ID)) "" else paste0(id, "-")
  if (nzchar(id_prefix)) {
    bad <- names(tabs)[!startsWith(names(tabs), id_prefix)]
    if (length(bad)) {
      stop(
        "bigTabsLazy(): every name in `tabs` must be the fully-namespaced tab ",
        "name bigTabItem() was given in the UI -- i.e. start with '", id_prefix,
        "' (id = '", id, "'). Name the entry e.g. session$ns('", bad[1], "') ",
        "rather than '", bad[1], "'. Offending name(s): ",
        paste(sprintf("'%s'", bad), collapse = ", ")
      )
    }
  }

  loaded <- new.env(parent = emptyenv())
  nav_input <- scoped_id(id, "nav")
  tabs_selector <- paste0("#", scoped_id(id, "big-tabs"))

  ## session$input[[...]] auto-prefixes with the *caller's own* module
  ## namespace when bigTabsLazy() is called from inside a moduleServer (the
  ## usual shape for a nested bigTabs(id = id)) -- so a nav_input already
  ## scoped by `id` would be looked up twice-prefixed and never match.
  ## Strip the caller's own prefix first, exactly like bd_active_tab().
  input_prefix <- session$ns("")
  if (nzchar(input_prefix) && startsWith(nav_input, input_prefix)) {
    nav_input <- substring(nav_input, nchar(input_prefix) + 1L)
  }

  load_tab <- function(name) {
    spec <- tabs[[name]]
    if (is.null(spec) || isTRUE(loaded[[name]])) {
      return(invisible(FALSE))
    }
    ## Latch before running: if the UI or server errors we must not retry on
    ## every subsequent click, which would insert the UI twice.
    loaded[[name]] <- TRUE

    if (is.function(spec$ui)) {
      tab_selector <- sprintf("%s > div.big-tab[data-name='%s']", tabs_selector, name)
      shiny::insertUI(
        selector = tab_selector,
        where = "beforeEnd",
        ui = spec$ui(),
        immediate = TRUE
      )
      ## Drop the placeholder now that the real content has replaced it --
      ## otherwise it sits underneath forever, nothing else ever removes it.
      shiny::removeUI(
        selector = paste0(tab_selector, " > .bigtabslazy-placeholder"),
        multiple = TRUE,
        immediate = TRUE
      )
    }
    if (is.function(spec$server)) {
      spec$server()
    }
    invisible(TRUE)
  }

  shiny::observeEvent(session$input[[nav_input]],
    {
      load_tab(session$input[[nav_input]])
    },
    ignoreNULL = TRUE
  )

  ## Boards other boards depend on cannot wait to be clicked. Loaded through
  ## the same path, so they are latched and will not load twice if their tab
  ## is opened later.
  for (name in names(tabs)) {
    if (isTRUE(tabs[[name]]$preload)) {
      load_tab(name)
    }
  }

  invisible(function() ls(loaded))
}
