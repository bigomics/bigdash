## Demo for the plotmodule header height fix.
## Left: plain PlotModuleUI. Right: PlotModuleUI(cards = TRUE), whose spliced
## nav bar drags bslib's .card-header min-height: 2.5rem into the header.
library(shiny)
devtools::load_all(quiet = TRUE) ## run from the package root

ui <- bigPage(
  title = "plotmodule header",
  navbar = navbar(tags$b("plotmodule header height"), center = NULL, left = NULL),
  sidebar = sidebar("Menu", sidebarItem("Demo", "demo-tab")),
  settings = settings("Settings"),
  bigTabs(
    bigTabItem(
      "demo-tab",
      bslib::layout_columns(
        col_widths = c(6, 6),
        row_heights = list("400px"),
        class = "p-3",
        PlotModuleUI(
          "plain",
          title = "Plain header (cards = FALSE)",
          info.text = "A normal plot module header.",
          plotlib = "base",
          download.fmt = c("png", "pdf"),
          height = c(360, 800)
        ),
        PlotModuleUI(
          "tabbed",
          title = "Tabbed header (cards = TRUE)",
          info.text = "Header with the spliced navset_card_pill nav bar.",
          plotlib = c("base", "base"),
          cards = TRUE,
          card_names = c("Histogram", "Density"),
          download.fmt = c("png", "pdf"),
          height = c(360, 800)
        )
      )
    )
  )
)

server <- function(input, output, session) {
  PlotModuleServer("plain",
    plotlib = "base",
    func = function() {
      hist(faithful$waiting, breaks = 20, col = "#3181de", border = "white",
           main = "", xlab = "waiting time (min)")
    }
  )
  PlotModuleServer("tabbed",
    plotlib = "base", card = 1,
    func = function() {
      hist(faithful$eruptions, breaks = 20, col = "#86A563", border = "white",
           main = "", xlab = "eruption time (min)")
    }
  )
  PlotModuleServer("tabbed",
    plotlib = "base", card = 2,
    func = function() {
      plot(density(faithful$eruptions), col = "#E45C00", lwd = 2, main = "",
           xlab = "eruption time (min)")
    }
  )
}

shinyApp(ui, server, options = list(port = 8080, launch.browser = FALSE))
