##
## bigTabsLazy(): load a tab's UI and server the first time it is opened.
##
## The board below pretends to be expensive: building its UI sleeps, and
## starting its server sleeps again. Eagerly you would pay for all three
## boards before seeing anything. Lazily you pay only for the one you open,
## once.
##
## Watch the console:
##   - "beta" loads at startup    -- marked preload = TRUE, standing in for a
##                                   board that other boards depend on
##   - "alpha" loads at startup   -- it is the auto-selected first tab
##   - "gamma" loads only when you click it, and only the first time
##
##   shiny::runApp("example/ex-lazy-tabs.R")
##

library(shiny)
library(bigdash)

## --- one pretend board, instantiated three times ----------------------------

boardInputs <- function(id) {
  ns <- NS(id)
  tabSettings(
    sliderInput(ns("n"), "Points", min = 10, max = 500, value = 150)
  )
}

boardUI <- function(id) {
  ns <- NS(id)
  message("  [BUILD UI]      ", id)
  Sys.sleep(0.8) ## stand-in for a real board's tag building
  div(
    h3(paste("Board", id)),
    p("This UI was built when the tab was first opened."),
    plotOutput(ns("plot"), height = "320px"),
    verbatimTextOutput(ns("info"))
  )
}

boardServer <- function(id) {
  message("  [START SERVER]  ", id)
  Sys.sleep(0.7) ## stand-in for a real board's server initialisation
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

ui <- bigPage(
  navbar = navbar("bigTabsLazy() example"),
  sidebar = sidebar(
    "Boards",
    sidebarItem("Alpha", "alpha-tab"),
    sidebarItem("Beta", "beta-tab"),
    sidebarItem("Gamma", "gamma-tab")
  ),
  settings = settings("Settings"),
  bigTabs(
    ## Only the sidebar inputs live here. The boards themselves are registered
    ## below and inserted on first visit.
    bigTabItem("alpha-tab", boardInputs("alpha")),
    bigTabItem("beta-tab", boardInputs("beta")),
    bigTabItem("gamma-tab", boardInputs("gamma"))
  )
)

server <- function(input, output, session) {
  loaded <- bigTabsLazy(list(
    "alpha-tab" = list(
      ui     = function() boardUI("alpha"),
      server = function() boardServer("alpha")
    ),
    "beta-tab" = list(
      ui      = function() boardUI("beta"),
      server  = function() boardServer("beta"),
      preload = TRUE ## other boards depend on it; cannot wait for a click
    ),
    "gamma-tab" = list(
      ui     = function() boardUI("gamma"),
      server = function() boardServer("gamma")
    )
  ))

  observeEvent(input$nav, {
    message("[loaded so far] ", paste(loaded(), collapse = ", "))
  })
}

shinyApp(ui, server)
