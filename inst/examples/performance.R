##
## Not paying for a board nobody is looking at.
##
## Three groups in the sidebar, three ways a board costs you while it is off
## screen, and the bigdash tool for each:
##
##   Purging       A plot keeps its drawn SVG/WebGL alive in a tab nobody has
##                 open -- and a second copy for every plot ever maximised.
##                 PlotModuleServer(purge=) and bd_redraw_tick() drop it and
##                 put it back. Compare "Purged" with "Kept" while watching the
##                 node count in the navbar.
##
##   Gating        An observer runs whether or not anyone is looking. Shiny
##                 suspends hidden *outputs* by itself; an observe() is exactly
##                 what it does not suspend, so it is the one that needs the
##                 flag. Compare "Gated" with "Ungated" while watching the two
##                 work counters in the navbar, and the R console.
##
##   Lazy loading  A board you never open should not be built at all.
##                 bigTabsLazy() defers both the UI and the server to
##                 the first visit. Watch the R console: "alpha" loads only
##                 when you click it, and only once. "beta" is already
##                 preloaded at startup,
##
## Lazy loading and purging are complementary: the first is about never paying
## for a board, the second about getting the memory back once you have.
##
##   shiny::runApp(system.file("examples/performance.R", package = "bigdash"))
##

library(shiny)
library(bigdash)

if (!requireNamespace("plotly", quietly = TRUE)) {
  stop("this example needs the plotly package")
}

POINTS <- 8000 ## enough SVG nodes per plot to see them come and go

## --- 1. purging -------------------------------------------------------------

plotBoardUI <- function(id, purged) {
  ns <- NS(id)
  div(
    ## Everything the two boards do differently follows from this one line
    ## plus the `purge` argument passed to the server below.
    bd_visibility_probe(ns),
    h3(if (purged) "Purged while hidden" else "Kept while hidden"),
    p(
      "Two plotly scatters of ", POINTS, " points each. ",
      if (purged) {
        "This board's plots are dropped from the DOM when you leave the tab,
         and redrawn when you come back. Maximise one, close it again, and
         watch the count too: a closed modal is hidden as well."
      } else {
        "This board's plots stay drawn for the whole session."
      }
    ),
    PlotModuleUI(
      ns("scatter"),
      title = "In a plot module",
      info.text = "Card and maximised modal, both purged and redrawn for you.",
      plotlib = "plotly",
      height = c(320, 700)
    ),
    br(),
    strong("Rendered without a plot module"),
    plotly::plotlyOutput(ns("hand_rolled"), height = "320px")
  )
}

plotBoardServer <- function(id, purge = TRUE) {
  moduleServer(id, function(input, output, session) {
    bd_is_visible(input, purge = purge, label = id)

    scatter <- reactive({
      set.seed(nchar(id))
      plotly::plot_ly(
        x = rnorm(POINTS), y = rnorm(POINTS),
        type = "scatter", mode = "markers",
        marker = list(size = 4, color = "#3181de")
      )
    })

    ## Card + maximised modal, purged and redrawn without further wiring:
    ## purge = NULL (the default) would turn itself on anyway because this
    ## board has a probe, so it is spelled out here only to be explicit.
    PlotModuleServer(
      "scatter",
      plotlib = "plotly",
      func = function() scatter(),
      purge = purge
    )

    ## Outside a plot module nothing wraps the render function for you: read
    ## the tick in the render expression. Without a purge it never moves, so
    ## the plot is still rendered exactly once per visit.
    redraw <- bd_redraw_tick()
    output$hand_rolled <- plotly::renderPlotly({
      redraw()
      scatter()
    })
  })
}

## --- 2. gating --------------------------------------------------------------

pollBoardUI <- function(id, gated) {
  ns <- NS(id)
  div(
    ## No probe on the ungated board: with nothing reporting its visibility,
    ## there is nothing to gate on.
    if (gated) bd_visibility_probe(ns),
    h3(if (gated) "Gated observer" else "Ungated observer"),
    p(
      "An observer doing expensive work every two seconds. ",
      if (gated) {
        "req(is_visible()) parks it while the tab is closed; it picks up again
         when you come back."
      } else {
        "Nothing stops it: it keeps working for the rest of the session,
         whether or not this tab is open."
      }
    ),
    verbatimTextOutput(ns("runs"))
  )
}

pollBoardServer <- function(id, gated) {
  moduleServer(id, function(input, output, session) {
    ## purge = FALSE: this board has no plots to drop, only an observer to
    ## park, so nothing should be purged on its behalf.
    is_visible <- if (gated) bd_is_visible(input, purge = FALSE) else reactive(TRUE)

    runs <- reactiveVal(0L)
    observe({
      ## req() before invalidateLater(): the timer is then never scheduled
      ## while hidden, and the observer wakes on the visibility change alone.
      req(is_visible())
      invalidateLater(2000)

      n <- isolate(runs()) + 1L
      runs(n)
      message("[", id, "] expensive step #", n, " at ", format(Sys.time(), "%H:%M:%S"))
    })

    output$runs <- renderText(paste("expensive steps run:", runs()))

    runs
  })
}

## --- 3. lazy loading --------------------------------------------------------

lazyBoardInputs <- function(id) {
  ns <- NS(id)
  tabSettings(
    sliderInput(ns("n"), "Points", min = 10, max = 500, value = 150)
  )
}

lazyBoardUI <- function(id, preloaded=FALSE) {
  ns <- NS(id)
  message("  [BUILD UI]      ", id)
  Sys.sleep(0.8) ## stand-in for a real board's tag building
  msg <- "This UI was built and its server called when the tab was first opened."
  if(preloaded) msg <- "This UI and its server was preloaded."
  div(
    h3(paste("Board", id)),
    p(msg),
    plotOutput(ns("plot"), height = "320px"),
    verbatimTextOutput(ns("info"))
  )
}

lazyBoardServer <- function(id) {
  message("  [START SERVER]  ", id)
  Sys.sleep(1.2) ## stand-in for a real board's server initialisation
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      set.seed(nchar(id))
      plot(rnorm(input$n), rnorm(input$n),
        pch = 19, col = "#3181de", xlab = "", ylab = "", main = id
      )
    })
    output$info <- renderText({
      paste0("board '", id, "' server started at ", format(Sys.time(), "%H:%M:%S"))
    })
  })
}

## --- app --------------------------------------------------------------------

## Reports how many nodes the tabs are holding, once a second.
node_counter <- tags$script(HTML(
  "setInterval(function() {
     if (window.Shiny && Shiny.setInputValue) {
       Shiny.setInputValue('dom_nodes', document.querySelectorAll('.big-tab *').length);
     }
   }, 1000);"
))

ui <- bigPage(
  navbar = navbar(
    "Performance toolbox",
    center = div(node_counter, textOutput("readout", inline = TRUE))
  ),
  sidebar = sidebar(
    "Tricks",
    sidebarMenu(
      "Purging",
      sidebarMenuItem("Purged", "purged-tab"),
      sidebarMenuItem("Kept", "kept-tab")
    ),
    sidebarMenu(
      "Gating",
      sidebarMenuItem("Gated", "gated-tab"),
      sidebarMenuItem("Ungated", "ungated-tab")
    ),
    sidebarMenu(
      "Lazy loading",
      sidebarMenuItem("Alpha", "alpha-tab"),
      sidebarMenuItem("Beta", "beta-tab")
    )
  ),
  settings = settings("Settings"),
  bigTabs(
    bigTabItem("purged-tab", plotBoardUI("purged", purged = TRUE)),
    bigTabItem("kept-tab", plotBoardUI("kept", purged = FALSE)),
    bigTabItem("gated-tab", pollBoardUI("gated", gated = TRUE)),
    bigTabItem("ungated-tab", pollBoardUI("ungated", gated = FALSE)),
    ## Only the sidebar inputs live here; the boards themselves are registered
    ## with bigTabsLazy() below and inserted on first visit.
    bigTabItem("alpha-tab", lazyBoardInputs("alpha")),
    bigTabItem("beta-tab", lazyBoardInputs("beta"))
  )
)

server <- function(input, output, session) {
  plotBoardServer("purged", purge = TRUE)
  plotBoardServer("kept", purge = FALSE)

  gated <- pollBoardServer("gated", gated = TRUE)
  ungated <- pollBoardServer("ungated", gated = FALSE)

  loaded <- bigTabsLazy(list(
    "alpha-tab" = list(
      ui     = function() lazyBoardUI("alpha"),
      server = function() lazyBoardServer("alpha")
    ),
    "beta-tab" = list(
      ui      = function() lazyBoardUI("beta", preloaded=TRUE),
      server  = function() lazyBoardServer("beta"),
      preload = TRUE ## other boards depend on it; cannot wait for a click
    )
  ))

  ## bd_active_tab(): which tab is open, read from the nav input bigdash
  ## already maintains -- no probe and no round trip, but it only knows about
  ## tabs. bd_is_visible() is the one that also sees accordions, nested
  ## navsets, and an outer tab that is itself closed.
  active <- bd_active_tab()
  observe({
    message("[open tab] ", active(), "  [loaded so far] ", paste(loaded(), collapse = ", "))
  })

  output$readout <- renderText({
    nodes <- if (is.null(input$dom_nodes)) 0 else input$dom_nodes
    paste0(
      "DOM nodes in tabs: ", format(nodes, big.mark = ","),
      "   |   expensive steps: gated ", gated(), " / ungated ", ungated()
    )
  })
}

shinyApp(ui, server)
