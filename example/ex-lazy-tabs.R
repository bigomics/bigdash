##
## bigTabsLazy(): load a tab's UI and server the first time it is opened.
##
## Each of the three tabs below pretends to be an expensive board: building its
## UI sleeps, and starting its server sleeps again. Eagerly, opening the app
## would pay for all three (~4.5s) before showing anything. Lazily you pay only
## for the tab you click, and only once.
##
## Watch the console: "BUILD UI" / "START SERVER" appear on first visit only.
##
##   shiny::runApp("example/ex-lazy-tabs.R")
##

library(shiny)
library(bigdash)

BOARDS <- c(alpha = "Alpha", beta = "Beta", gamma = "Gamma")

## --- a pretend board -------------------------------------------------------

boardInputs <- function(id) {
  ns <- NS(id)
  tabSettings(
    sliderInput(ns("n"), "Points", min = 10, max = 500, value = 100)
  )
}

boardUI <- function(id) {
  ns <- NS(id)
  message("  [BUILD UI]      ", id)
  Sys.sleep(0.8) ## stand-in for a real board's tag building
  div(
    h3(paste("Board", id)),
    p("This UI was built the first time you opened the tab."),
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
      plot(stats::rnorm(input$n), stats::rnorm(input$n),
        pch = 19, col = "#3181de",
        xlab = "", ylab = "", main = paste("board", id)
      )
    })
    output$info <- renderText({
      paste0("board '", id, "' server started at ", format(Sys.time(), "%H:%M:%S"))
    })
  })
}

## --- app -------------------------------------------------------------------

ui <- bigPage(
  navbar = navbar("bigTabsLazy() example"),
  sidebar = sidebar(
    "Boards",
    !!!unname(Map(function(id, label) sidebarItem(label, paste0(id, "-tab")),
      names(BOARDS), BOARDS
    ))
  ),
  settings = settings("Settings"),
  bigTabs(
    ## Only the inputs are here. The board itself is registered below and
    ## inserted on first visit.
    !!!unname(lapply(names(BOARDS), function(id) {
      bigTabItem(paste0(id, "-tab"), boardInputs(id))
    }))
  )
)

server <- function(input, output, session) {
  loaded <- bigTabsLazy(
    stats::setNames(
      lapply(names(BOARDS), function(id) {
        list(
          ui = function() boardUI(id),
          server = function() boardServer(id)
        )
      }),
      paste0(names(BOARDS), "-tab")
    )
  )

  ## Nothing is built until a tab is opened.
  observe({
    message("[loaded so far] ", paste(loaded(), collapse = ", "))
  })
}

shinyApp(ui, server)
