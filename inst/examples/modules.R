## Standalone PlotModuleUI / TableModuleUI, with no Omics Playground in sight.
## Doubles as the smoke test: sourcing this file with SMOKE=TRUE renders both
## modules' UI and exits non-zero if either references something bigdash does
## not ship.
library(shiny)
library(bigdash)

ui <- bigdash::bigPage(
  title = "bigdash modules",
  sidebar = bigdash::sidebar("Menu", bigdash::sidebarItem("Demo", "demo-tab")),
  navbar = bigdash::navbar("bigdash"),
  settings = bigdash::settings(),
  bigdash::bigTabs(
    bigdash::bigTabItem(
      "demo-tab",
      bslib::layout_columns(
        col_widths = c(6, 6),
        bigdash::PlotModuleUI(
          "plot",
          title = "Old Faithful",
          info.text = "Eruption waiting times.",
          caption = "Histogram of waiting times between eruptions.",
          plotlib = "base",
          height = c(400, 800)
        ),
        bigdash::TableModuleUI(
          "table",
          title = "Eruptions",
          info.text = "The raw faithful data.",
          caption = "Waiting time and eruption duration.",
          height = c(400, 800)
        )
      )
    )
  )
)

server <- function(input, output, session) {
  bigdash::PlotModuleServer(
    "plot",
    plotlib = "base",
    func = function() hist(faithful$waiting, main = "", xlab = "waiting"),
    csvFunc = function() faithful,
    download.fmt = c("png", "pdf")
  )
  bigdash::TableModuleServer(
    "table",
    func = function() DT::datatable(faithful)
  )
}

if (isTRUE(as.logical(Sys.getenv("SMOKE")))) {
  stopifnot(inherits(htmltools::renderTags(ui)$html, "html"))

  ## editor = TRUE without a host app degrades to no editor, it does not error
  warned <- FALSE
  withCallingHandlers(
    bigdash::PlotModuleUI("p", editor = TRUE),
    warning = function(w) {
      warned <<- TRUE
      invokeRestart("muffleWarning")
    }
  )
  stopifnot(warned)

  ## ...and the hooks actually get consulted
  options(bigdash.tspan = function(text, js = TRUE) paste0("XX", text))
  on.exit(options(bigdash.tspan = NULL))
  stopifnot(grepl(
    "XXHooked",
    as.character(bigdash::TableModuleUI("t", title = "Hooked"))
  ))

  message("smoke: bigdash modules render standalone")
} else {
  shinyApp(ui, server)
}
