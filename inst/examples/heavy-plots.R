##
## Heavy rendering test: 10 boards, 4 plotly scatters each, 4000 points a plot.
##
## 40 drawn figures and 160,000 points if you visit every board -- enough that
## the browser's node count is the thing you feel, not the server's work. The
## navbar reports how many DOM nodes the tabs are holding right now and the
## peak since the last toggle.
##
## Flip "purge hidden plots" in the navbar and take the tour again:
##
##   purging off   every board you have ever opened keeps its four drawn
##                 figures for the rest of the session, so the count climbs
##                 board by board and stays there
##
##   purging on    a board gives its nodes back when you leave it and redraws
##                 them when you return, so the count stays at roughly one
##                 board's worth however long you keep clicking
##
## The toggle is a plain reactive passed to bd_is_visible(purge=), which is how
## an app offers this as a runtime setting rather than a build-time decision.
## It reaches every board at once.
##
##   shiny::runApp(system.file("examples/heavy-plots.R", package = "bigdash"))
##

library(shiny)
library(bigdash)

if (!requireNamespace("plotly", quietly = TRUE)) {
  stop("this example needs the plotly package")
}

N_BOARDS <- 10
N_PLOTS <- 4
POINTS <- 20000

PALETTE <- c("#3181de", "#e2726e", "#40b57e", "#f0a202")

## --- one board of four scatters ---------------------------------------------

boardUI <- function(id) {
  ns <- NS(id)
  plots <- lapply(seq_len(N_PLOTS), function(i) {
    PlotModuleUI(
      ns(paste0("plot", i)),
      title = paste("Scatter", i),
      info.text = paste(POINTS, "random points. Maximise it and close it again:
        a closed modal is hidden too, so its copy is purged as well."),
      plotlib = "plotly",
      height = c(300, 700)
    )
  })

  div(
    ## One line per board is the whole opt-in.
    bd_visibility_probe(ns),
    h3(paste("Board", sub("board", "", id))),
    do.call(bslib::layout_column_wrap, c(list(width = 1 / 2), plots))
  )
}

boardServer <- function(id, purge) {
  moduleServer(id, function(input, output, session) {
    ## `purge` is the navbar checkbox, as a reactive: every board reads the
    ## same one, and flipping it takes effect on the next tab switch.
    bd_is_visible(input, purge = purge)

    for (i in seq_len(N_PLOTS)) {
      local({
        plot_id <- paste0("plot", i)
        seed <- nchar(id) * 100 + i
        colour <- PALETTE[(i - 1) %% length(PALETTE) + 1]

        fig <- reactive({
          set.seed(seed)
          plotly::plot_ly(
            x = rnorm(POINTS), y = rnorm(POINTS),
            type = "scatter", mode = "markers",
            marker = list(size = 4, color = colour, opacity = 0.6)
          ) |>
            plotly::layout(
              xaxis = list(title = ""),
              yaxis = list(title = ""),
              margin = list(l = 30, r = 10, t = 10, b = 30)
            )
        })

        ## purge = NULL (the default) picks up this board's probe by itself.
        PlotModuleServer(
          plot_id,
          plotlib = "plotly",
          func = function() fig(),
          add.watermark = FALSE
        )
      })
    }
  })
}

board_ids <- paste0("board", seq_len(N_BOARDS))
tab_name <- function(id) paste0(id, "-tab")

## --- app --------------------------------------------------------------------

## Reports the tabs' node count once a second, and clicks through every board
## on demand so the two settings can be compared the same way twice.
counter_js <- tags$script(HTML(
  "setInterval(function() {
     if (window.Shiny && Shiny.setInputValue) {
       Shiny.setInputValue('dom_nodes', document.querySelectorAll('.big-tab *').length);
     }
   }, 1000);
   window.bigdashTour = function() {
     var triggers = [].slice.call(document.querySelectorAll('.sidebar-menu-item .tab-trigger'));
     var i = 0;
     (function step() {
       if (i >= triggers.length) return;
       triggers[i++].click();
       setTimeout(step, 3000);
     })();
   };"
))

ui <- bigPage(
  navbar = navbar(
    "Heavy rendering",
    center = div(
      class = "d-flex align-items-center gap-3",
      counter_js,
      div(
        class = "mb-0",
        checkboxInput("purge", "purge hidden plots", value = TRUE, width = "200px")
      ),
      tags$button(
        class = "btn btn-sm btn-outline-secondary",
        onclick = "bigdashTour()",
        "tour all boards"
      ),
      textOutput("readout", inline = TRUE)
    )
  ),
  sidebar = do.call(
    sidebar,
    c(
      list("Boards"),
      list(do.call(
        sidebarMenu,
        c(
          list(paste(N_BOARDS, "boards")),
          lapply(seq_len(N_BOARDS), function(i) {
            sidebarMenuItem(paste("Board", i), tab_name(board_ids[i]))
          })
        )
      ))
    )
  ),
  settings = settings("Settings"),
  do.call(
    bigTabs,
    lapply(board_ids, function(id) bigTabItem(tab_name(id), boardUI(id)))
  )
)

server <- function(input, output, session) {
  purge <- reactive(isTRUE(input$purge))

  for (id in board_ids) {
    boardServer(id, purge = purge)
  }

  ## Peak nodes since the last time the setting changed, so the two runs are
  ## comparable.
  peak <- reactiveVal(0)
  observeEvent(input$dom_nodes, peak(max(peak(), input$dom_nodes)))
  observeEvent(input$purge, peak(0), ignoreInit = TRUE)

  output$readout <- renderText({
    nodes <- if (is.null(input$dom_nodes)) 0 else input$dom_nodes
    paste0(
      "nodes now ", format(nodes, big.mark = ","),
      "   |   peak ", format(peak(), big.mark = ","),
      "   |   purging ", if (isTRUE(input$purge)) "ON" else "OFF"
    )
  })
}

shinyApp(ui, server)
