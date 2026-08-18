##
## The visibility toolbox: stop paying for a board nobody is looking at.
##
## Four tricks, one app. Open the R console and the navbar counter, then click
## between the tabs:
##
##   bd_visibility_probe()          reports the board's on/off screen state to
##                                  its server as input$is_visible
##
##   bd_is_visible()                gates the polling observer. Shiny already
##                                  suspends hidden *outputs*; an observe() is
##                                  exactly what it does not suspend, so this
##                                  is where the flag earns its keep. The
##                                  console goes quiet when you leave "Purged".
##
##   PlotModuleServer(purge = TRUE) drops the plot's drawn DOM while the board
##                                  is off screen -- and while the maximise
##                                  modal is closed -- and redraws it on the
##                                  way back. Watch "DOM nodes" in the navbar.
##
##   bd_redraw_tick()               the same, for a plot rendered without a
##                                  plot module: take the dependency yourself.
##
##   bd_active_tab()                which tab is open, straight from bigdash's
##                                  own nav input -- no probe, no JavaScript.
##
## The "Kept" tab is the same board with purge = FALSE. Leave each tab in turn
## and compare the node count: only the purged one gives its nodes back.
##
##   shiny::runApp(system.file("examples/visibility.R", package = "bigdash"))
##

library(shiny)
library(bigdash)

if (!requireNamespace("plotly", quietly = TRUE)) {
  stop("this example needs the plotly package")
}

POINTS <- 4000 ## enough SVG nodes per plot to see them come and go

## --- one board, instantiated twice ------------------------------------------

boardUI <- function(id, purged) {
  ns <- NS(id)
  div(
    ## Everything below hangs off this one line.
    bd_visibility_probe(ns),
    h3(if (purged) "Purged while hidden" else "Kept while hidden"),
    p(
      "Two plotly scatters of ", POINTS, " points each. ",
      if (purged) {
        "This board's plots are dropped from the DOM when you leave the tab."
      } else {
        "This board's plots stay drawn for the whole session."
      }
    ),
    PlotModuleUI(
      ns("scatter"),
      title = "In a plot module",
      info.text = "Maximise me, close it again, and watch the node count.",
      plotlib = "plotly",
      height = c(320, 700)
    ),
    br(),
    strong("Rendered without a plot module"),
    plotly::plotlyOutput(ns("hand_rolled"), height = "320px")
  )
}

boardServer <- function(id, purge = TRUE) {
  moduleServer(id, function(input, output, session) {
    ## TRUE while this board is on screen. `purge` is this board's switch for
    ## dropping drawn plots -- pass a reactive here for a runtime toggle.
    is_visible <- bd_is_visible(input, purge = purge, label = id)

    ## An observer runs whether or not anyone is looking at it. This is the
    ## kind of thing the flag is for.
    observe({
      req(is_visible())
      invalidateLater(3000)
      message("[", id, "] polling, ", format(Sys.time(), "%H:%M:%S"))
    })

    scatter <- reactive({
      set.seed(nchar(id))
      plotly::plot_ly(
        x = rnorm(POINTS), y = rnorm(POINTS),
        type = "scatter", mode = "markers",
        marker = list(size = 4, color = "#3181de")
      )
    })

    ## Card + maximised modal, purged and redrawn without further wiring:
    ## purge = NULL (the default) turns itself on because this board has a
    ## probe, so it is spelled out here only to be explicit.
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
    "Visibility toolbox",
    center = div(node_counter, textOutput("nodes", inline = TRUE))
  ),
  sidebar = sidebar(
    "Boards",
    sidebarItem("Purged", "purged-tab"),
    sidebarItem("Kept", "kept-tab"),
    sidebarItem("Active tab", "active-tab")
  ),
  settings = settings("Settings"),
  bigTabs(
    bigTabItem("purged-tab", boardUI("purged", purged = TRUE)),
    bigTabItem("kept-tab", boardUI("kept", purged = FALSE)),
    bigTabItem(
      "active-tab",
      h3("bd_active_tab()"),
      p(
        "The open tab, read from the nav input bigdash already maintains.",
        "No probe and no round trip -- but it only knows about tabs, so it",
        "cannot see an accordion, a nested navset, or an outer tab that is",
        "itself closed. bd_is_visible() is the one that composes."
      ),
      verbatimTextOutput("active")
    )
  )
)

server <- function(input, output, session) {
  boardServer("purged", purge = TRUE)
  boardServer("kept", purge = FALSE)

  active <- bd_active_tab()
  output$active <- renderText(paste("open tab:", active()))

  output$nodes <- renderText({
    n <- if (is.null(input$dom_nodes)) 0 else input$dom_nodes
    paste("DOM nodes in tabs:", format(n, big.mark = ","))
  })
}

shinyApp(ui, server)
