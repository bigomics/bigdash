## A complete BigOmics-looking dashboard built from bigdash alone.
##
## Nothing here comes from Omics Playground: no opt, no FILES, no pgx object,
## no sourced components/ tree. Just `library(bigdash)` and base R datasets.
##
##   Rscript inst/examples/standalone.R          # run it
##   SMOKE=TRUE Rscript inst/examples/standalone.R   # render-only self-check
library(shiny)
library(bigdash)

ui <- bigPage(
  title = "bigdash standalone",
  navbar = navbar(
    tags$img(src = "assets/img/bigomics.png", width = "110"),
    center = NULL,
    left = NULL,
    navbarDropdown(
      "Demo",
      navbarDropdownTab("Plots", "plots-tab"),
      navbarDropdownTab("Table", "table-tab")
    )
  ),
  sidebar = sidebar(
    "Menu",
    sidebarItem("Plots", "plots-tab"),
    sidebarItem("Table", "table-tab")
  ),
  settings = settings("Settings"),
  sidebarHelp(
    sidebarTabHelp("plots-tab", "Plots", "Two PlotModules, one plotly and one base R."),
    sidebarTabHelp("table-tab", "Table", "A TableModule over the iris data.")
  ),
  bigTabs(
    bigTabItem(
      "plots-tab",
      ## Per-tab settings: bigdash moves .tab-settings into the drawer on load.
      tabSettings(
        selectInput("species", "Species",
          choices = c("all", levels(iris$Species)), selected = "all"
        ),
        sliderInput("size", "Point size", min = 1, max = 12, value = 6),
        checkboxInput("logscale", "Log x axis", FALSE)
      ),
      bslib::layout_columns(
        col_widths = c(7, 5),
        row_heights = list("420px"),
        PlotModuleUI(
          "scatter",
          title = "Sepal vs petal",
          info.text = "Petal length against sepal length for the iris data.",
          info.methods = "plotly scatter, coloured by species.",
          info.references = list(list(
            "Fisher R.A. (1936) The use of multiple measurements in taxonomic problems.",
            "https://doi.org/10.1111/j.1469-1809.1936.tb02137.x"
          )),
          caption = "Each point is one flower. Use the settings drawer to filter by species.",
          plotlib = "plotly",
          download.fmt = c("png", "pdf", "csv"),
          height = c(380, 800),
          options = tagList(
            checkboxInput("show_fit", "Show linear fit", FALSE)
          )
        ),
        PlotModuleUI(
          "hist",
          title = "Eruption waiting times",
          info.text = "Distribution of waiting times between Old Faithful eruptions.",
          caption = "Base R histogram, to show a non-htmlwidget plotlib.",
          plotlib = "base",
          download.fmt = c("png", "pdf"),
          height = c(380, 800)
        )
      ),
      div(
        class = "p-2",
        ## The server-side navigation API, same calls Omics Playground makes.
        actionButton("goto_table", "bigdash.selectTab -> Table", class = "btn btn-primary btn-sm"),
        actionButton("hide_table", "bigdash.hideTab", class = "btn btn-outline-primary btn-sm"),
        actionButton("show_table", "bigdash.showTab", class = "btn btn-outline-primary btn-sm")
      )
    ),
    bigTabItem(
      "table-tab",
      tabSettings(
        numericInput("nrows", "Rows", value = 150, min = 5, max = 150, step = 5)
      ),
      TableModuleUI(
        "tbl",
        title = "Iris measurements",
        info.text = "The raw iris data behind the scatter plot.",
        caption = "Sortable and searchable; the zoom button opens it fullscreen.",
        height = c(560, 800)
      )
    )
  )
)

server <- function(input, output, session) {
  iris_subset <- reactive({
    d <- iris
    if (!is.null(input$species) && input$species != "all") {
      d <- d[d$Species == input$species, , drop = FALSE]
    }
    d
  })

  PlotModuleServer(
    "scatter",
    plotlib = "plotly",
    csvFunc = iris_subset,
    func = function() {
      d <- iris_subset()
      p <- plotly::plot_ly(
        d,
        x = ~Sepal.Length, y = ~Petal.Length, color = ~Species,
        type = "scatter", mode = "markers",
        marker = list(size = input$size)
      )
      if (isTRUE(input$logscale)) {
        p <- plotly::layout(p, xaxis = list(type = "log"))
      }
      if (isTRUE(input$show_fit)) {
        fit <- lm(Petal.Length ~ Sepal.Length, data = d)
        p <- plotly::add_lines(p,
          x = d$Sepal.Length, y = fitted(fit),
          inherit = FALSE, name = "fit", line = list(color = "black")
        )
      }
      p
    },
    download.fmt = c("png", "pdf", "csv")
  )

  PlotModuleServer(
    "hist",
    plotlib = "base",
    csvFunc = function() faithful,
    func = function() {
      hist(faithful$waiting,
        breaks = 20, col = "#3181de", border = "white",
        main = "", xlab = "waiting time (min)"
      )
    },
    download.fmt = c("png", "pdf")
  )

  TableModuleServer(
    "tbl",
    func = function() {
      n <- if (is.null(input$nrows)) 150 else input$nrows
      DT::datatable(head(iris, n), selection = "single")
    }
  )

  observeEvent(input$goto_table, bigdash.selectTab(session, "table-tab"))
  observeEvent(input$hide_table, bigdash.hideTab(session, "table-tab"))
  observeEvent(input$show_table, bigdash.showTab(session, "table-tab"))
}

if (isTRUE(as.logical(Sys.getenv("SMOKE")))) {
  html <- as.character(htmltools::renderTags(ui)$html)

  ## the page and both modules render
  stopifnot(
    grepl("plotmodule-header", html),
    grepl("tablemodule-header", html),
    grepl("sidebar-container", html),
    grepl("settings-container", html)
  )

  ## editor = TRUE without a host app degrades to no editor, it does not error
  warned <- FALSE
  withCallingHandlers(
    PlotModuleUI("p", editor = TRUE),
    warning = function(w) {
      warned <<- TRUE
      invokeRestart("muffleWarning")
    }
  )
  stopifnot(warned)

  ## ...and the hooks actually get consulted
  options(bigdash.tspan = function(text, js = TRUE) paste0("XX", text))
  on.exit(options(bigdash.tspan = NULL))
  stopifnot(grepl("XXHooked", as.character(TableModuleUI("t", title = "Hooked"))))

  message("smoke: bigdash standalone app renders, no Omics Playground present")
} else {
  shinyApp(ui, server, options = list(port = 8080, launch.browser = FALSE))
}
