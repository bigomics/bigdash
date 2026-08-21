##
## Visibility toolbox: know when a board is on screen, and stop paying for it
## when it is not.
##

BD_VISIBLE_INPUT <- "is_visible"

#' Probe reporting whether this board is on screen
#'
#' Prepend to a board's UI. It reports whether the board is actually shown --
#' its tab selected, its accordion open, its parent app tab active -- to the
#' board's server as `input$is_visible`, read with [bd_is_visible()].
#'
#' The check is generic (an `IntersectionObserver` plus an `offsetParent` test
#' on an invisible 1px element) rather than tied to any one tab implementation,
#' so it composes: a board nested in a [bigTabs()] inside another [bigTabs()]
#' is visible only when both are.
#'
#' Enabling the probe also lets bigdash drop the drawn Plotly/iheatmapr trees
#' of a hidden board -- see [bd_redraw_tick()] and the `purge` argument of
#' [PlotModuleServer()]. Nothing is dropped until [bd_is_visible()] switches it
#' on from the server, because a purged plot only comes back if something holds
#' a redraw tick for it.
#'
#' @section Keep it in flow:
#' The probe must stay in normal layout flow -- do not put it inside something
#' `display:none` of your own, or it can never register as visible. It is
#' transparent rather than hidden for that reason.
#'
#' @param ns Module namespace function, `shiny::NS(id)`.
#' @param spinner Keep the [bigLoaders::useSpinner()] spinner up until the
#'   widget has actually painted, instead of hiding it when the data arrives.
#'   Matters most right after a purge, when the whole redraw is client-side.
#'
#' @return A [shiny::tagList()] to prepend to the board UI.
#'
#' @seealso [bd_is_visible()], [bd_redraw_tick()], [bd_active_tab()]
#'
#' @examples
#' boardUI <- function(id) {
#'   ns <- shiny::NS(id)
#'   shiny::div(
#'     bd_visibility_probe(ns),
#'     plotly::plotlyOutput(ns("scatter"))
#'   )
#' }
#'
#' @export
bd_visibility_probe <- function(ns, spinner = TRUE) {
  spec <- list(
    probe = ns("bd_visible_probe"),
    input = ns(BD_VISIBLE_INPUT),
    prefix = ns(""),
    spinner = isTRUE(spinner)
  )
  shiny::tagList(
    dependencies(),
    shiny::tags$div(
      id = spec$probe,
      class = "bd-visibility-probe",
      style = "width:1px; height:1px; opacity:0; pointer-events:none;"
    ),
    shiny::tags$script(shiny::HTML(sprintf(
      "(window.__bigdashVisibility = window.__bigdashVisibility || []).push(%s);",
      jsonlite::toJSON(spec, auto_unbox = TRUE)
    )))
  )
}

#' Is this board on screen?
#'
#' Reads the [bd_visibility_probe()] embedded in the board's UI.
#'
#' @section What this is for:
#' Not for gating plots and tables. Shiny already suspends hidden outputs
#' (`suspendWhenHidden = TRUE`), and a `reactive()` whose only consumers are
#' suspended outputs does not run either -- a hidden board is mostly free
#' without help. Use this flag for the things that escape that:
#'
#' * `observe()` / `observeEvent()`, which run whether or not anyone is looking
#' * outputs set to `suspendWhenHidden = FALSE`
#' * `invalidateLater()` polling
#' * any reactive pulled eagerly by one of the above
#'
#' The usual shape is `shiny::req(is_visible())` at the top of such an observer.
#'
#' @param input Module `input`.
#' @param purge Enable dropping this board's drawn Plotly/iheatmapr trees while
#'   it is hidden: `TRUE`, `FALSE`, or a reactive/function returning a logical
#'   for a runtime switch. Only takes effect for plots that hold a redraw tick
#'   ([PlotModuleServer()] with `purge`, or [bd_redraw_tick()]).
#' @param label Optional label; when given, visibility changes are `message()`d.
#' @param session Module session.
#'
#' @return A `reactive` returning `TRUE` while the board is on screen.
#'
#' @seealso [bd_visibility_probe()], [bd_redraw_tick()]
#'
#' @examples
#' \dontrun{
#' boardServer <- function(id) {
#'   moduleServer(id, function(input, output, session) {
#'     is_visible <- bd_is_visible(input)
#'
#'     ## an observer would otherwise poll all session long
#'     observe({
#'       shiny::req(is_visible())
#'       shiny::invalidateLater(5000)
#'       refresh_status()
#'     })
#'   })
#' }
#' }
#'
#' @export
bd_is_visible <- function(input,
                          purge = TRUE,
                          label = NULL,
                          session = shiny::getDefaultReactiveDomain()) {
  is_visible <- shiny::reactive({
    visible <- isTRUE(input[[BD_VISIBLE_INPUT]])
    if (!is.null(label)) {
      message("[", label, "] visible = ", visible)
    }
    visible
  })

  if (!is.null(session)) {
    bd_visibility_register(is_visible, purge, session)
  }
  is_visible
}

#' The tab this board is in, and whether it is the open one
#'
#' `bd_active_tab()` returns the name of the [bigTabItem()] currently open in a
#' [bigTabs()] instance, straight from the nav input bigdash already maintains
#' -- no probe, no JavaScript, no round trip, and never `NULL` after the first
#' navigation.
#'
#' It is the cheap alternative to [bd_is_visible()] and the right one when tab
#' selection is all you need. It does not compose across nesting: a board in a
#' [bigTabs()] nested inside another one is on screen only if the outer tab is
#' open too, which this cannot see. Use [bd_is_visible()] when that matters, or
#' when visibility is decided by an accordion, a `bslib` navset, or scrolling.
#'
#' @param id Namespace id of the [bigTabs()] instance, as given in the UI. If
#'   the calling module's namespace already carries that prefix (the usual shape
#'   for a nested `bigTabs(id = id)`), it is stripped, so the same call works
#'   from the app server and from inside the module.
#' @param session Session to read the nav input from.
#'
#' @return A `reactive` returning the open tab's name.
#'
#' @examples
#' \dontrun{
#' active <- bd_active_tab()
#' is_visible <- shiny::reactive(active() == "alpha-tab")
#' }
#'
#' @export
bd_active_tab <- function(id = BIGDASH_DEFAULT_ID,
                          session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    stop("bd_active_tab() must be called from a Shiny server function")
  }
  nav <- scoped_id(id, "nav")
  ## The nav input is set at the root, under the bigTabs id ("qsee-nav"). Read
  ## from inside module "qsee" that is input$nav; read from the app server it
  ## is input[["qsee-nav"]]. Strip the caller's own prefix when it is there.
  prefix <- session$ns("")
  if (nzchar(prefix) && startsWith(nav, prefix)) {
    nav <- substring(nav, nchar(prefix) + 1L)
  }
  shiny::reactive(session$input[[nav]])
}

#' Redraw tick for plots purged while hidden
#'
#' While a board is off screen its drawn Plotly/iheatmapr trees are dropped (see
#' [bd_visibility_probe()]). The plots are then only blank because we emptied
#' them, and Shiny will not resend a value for an output it has not invalidated
#' -- so anything purged needs a dependency that changes when the board comes
#' back. This is that dependency.
#'
#' [PlotModuleServer()] wires this up itself. Use it directly for plots rendered
#' outside a plot module, by reading `tick()` in the render expression or by
#' wrapping the render function in [bd_with_redraw()].
#'
#' The tick only moves after a purge actually happened, so a first visit -- or a
#' board whose `purge` is switched off -- renders exactly once.
#'
#' @param is_visible Reactive logical, defaulting to the one [bd_is_visible()]
#'   registered for the enclosing board.
#' @param session Module session.
#' @param label Optional label; when given, purge and redraw events are
#'   `message()`d -- handy for confirming purging is actually happening.
#'
#' @return A `reactive` returning an integer.
#'
#' @examples
#' \dontrun{
#' redraw <- bd_redraw_tick()
#' output$scatter <- plotly::renderPlotly({
#'   redraw()
#'   plotly::plot_ly(df, x = ~x, y = ~y)
#' })
#' }
#'
#' @export
bd_redraw_tick <- function(is_visible = NULL,
                           session = shiny::getDefaultReactiveDomain(),
                           label = NULL) {
  purge <- TRUE
  if (is.null(is_visible)) {
    registered <- bd_visibility_lookup(session)
    if (is.null(registered)) {
      ## No probe above us: nothing is ever purged, so nothing has to redraw.
      return(shiny::reactive(0L))
    }
    is_visible <- registered$visible
    purge <- registered$purge
  }

  tick <- shiny::reactiveVal(0L)
  purged <- FALSE

  shiny::observeEvent(is_visible(),
    {
      if (!isTRUE(is_visible())) {
        ## Purging is client-side, on the same visibility change; all we do
        ## here is remember that the plots are now empty.
        if (isTRUE(bd_purge_enabled(purge))) {
          purged <<- TRUE
          if (!is.null(label)) message("[", label, "] purged (off screen)")
        } else if (!is.null(label)) {
          message("[", label, "] off screen, purging OFF -- kept")
        }
      } else if (purged) {
        ## Bump on show, never on hide: the browser reports visibility
        ## asynchronously, so a tick moved at hide-time can land while the
        ## outputs still count as visible and force a pointless re-render.
        purged <<- FALSE
        tick(shiny::isolate(tick()) + 1L)
        if (!is.null(label)) message("[", label, "] redrawn (back on screen)")
      }
    },
    ignoreInit = TRUE
  )

  shiny::reactive(tick())
}

#' Make a render function depend on a redraw tick
#'
#' @param tick Reactive from [bd_redraw_tick()].
#' @param func Function returning the plot.
#'
#' @return A function calling `tick()` and then `func()`.
#'
#' @examples
#' \dontrun{
#' PlotModuleServer("scatter", plotlib = "plotly",
#'   func = bd_with_redraw(bd_redraw_tick(), render.scatter)
#' )
#' }
#'
#' @export
bd_with_redraw <- function(tick, func) {
  force(tick)
  force(func)
  function(...) {
    tick()
    func(...)
  }
}

## ---------------------------------------------------------------------------
## internals
## ---------------------------------------------------------------------------

## Plot libraries that draw in the browser, and are therefore what the purge
## selector (.js-plotly-plot, .plotly.html-widget, .iheatmapr) can match. The
## rest render to a server-side image: nothing to drop, and a redraw tick would
## only buy needless replotting. "generic" and "htmlwidget" come with a
## caller-supplied render function that may well be a plotly one, so they are
## treated as purgeable -- a redraw too many beats a plot left blank.
BD_PURGEABLE_PLOTLIB <- c("plotly", "iheatmapr", "generic", "htmlwidget")

#' Can this plot library's output be dropped from the DOM and redrawn?
#' @keywords internal
bd_is_purgeable <- function(plotlib) {
  any(plotlib %in% BD_PURGEABLE_PLOTLIB)
}

#' Resolve a purge switch given as logical, function or reactive
#' @keywords internal
bd_purge_enabled <- function(purge) {
  if (is.function(purge)) {
    return(isTRUE(purge()))
  }
  isTRUE(purge)
}

#' Publish a board's visibility for the plot modules inside it
#'
#' Keyed by the board's namespace prefix in `session$userData`, which is shared
#' with the root session, so a plot module several levels down can find the
#' board it belongs to (see [bd_visibility_lookup()]).
#'
#' @keywords internal
bd_visibility_register <- function(is_visible, purge, session) {
  prefix <- session$ns("")
  if (!is.list(session$userData$bigdash_visibility)) {
    session$userData$bigdash_visibility <- list()
  }
  session$userData$bigdash_visibility[[prefix]] <- list(
    prefix = prefix,
    visible = is_visible,
    purge = purge
  )

  ## Mirror the switch to the browser, which is where purging happens. Off
  ## until told otherwise, so a board that registers no tick keeps its plots.
  shiny::observe({
    session$sendCustomMessage(
      "bigdash-visibility-enable",
      list(prefix = prefix, enabled = bd_purge_enabled(purge))
    )
  })

  invisible(prefix)
}

#' The visibility registration covering this module
#'
#' The longest registered namespace prefix that is a prefix of the caller's --
#' i.e. the innermost enclosing board that has a probe.
#'
#' @keywords internal
bd_visibility_lookup <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) {
    return(NULL)
  }
  registry <- session$userData$bigdash_visibility
  if (!is.list(registry) || !length(registry)) {
    return(NULL)
  }
  me <- session$ns("")
  keys <- names(registry)
  keys <- keys[vapply(keys, function(k) startsWith(me, k), logical(1))]
  if (!length(keys)) {
    return(NULL)
  }
  registry[[keys[which.max(nchar(keys))]]]
}
