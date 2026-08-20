## Two independent bigPage() instances in one Shiny app.
##
## Each page gets its own `id`, and that same `id` is passed to navbar(),
## sidebar(), settings(), sidebarHelp() and bigTabs() so generated element
## ids do not collide. Tab names are unique per page so client-side
## `.tab-trigger[data-target=...]` lookups stay isolated too.
##
## The outer shell is a plain bslib page (not a bigPage). Call
## bigdash::dependencies() on that shell so the CSS/JS bundle loads even
## if a child page is not the first thing in the DOM.
##
## Watch the header: each page writes its own scoped nav input
## (`input[["sales-nav"]]`, `input[["lab-nav"]]`) and filterTabs() with
## `id =` only touches that instance.
##
##   Rscript inst/examples/multiple-pages.R
library(shiny)
library(bigdash)

## One self-contained dashboard. `id` is both the bigPage() namespace and
## the Shiny module id, so input$nav inside the module is the scoped value.
demo_page <- function(id, title, accent) {
  ns <- NS(id)
  tabs <- paste0(id, c("-overview", "-plots", "-tables"))

  bigPage(
    id = id,
    title = title,
    navbar = navbar(
      tagList(
        tags$span(
          class = "badge me-2",
          style = paste0("background:", accent, ";"),
          paste0("id = \"", id, "\"")
        ),
        title
      ),
      id = id
    ),
    sidebar = sidebar(
      "Menu",
      sidebarItem("Overview", tabs[[1]]),
      sidebarItem("Plots", tabs[[2]]),
      sidebarItem("Tables", tabs[[3]]),
      id = id
    ),
    settings = settings("Settings", id = id),
    sidebarHelp(
      sidebarTabHelp(tabs[[1]], "Overview", paste(title, "landing page.")),
      sidebarTabHelp(tabs[[2]], "Plots", paste(title, "plot board.")),
      sidebarTabHelp(tabs[[3]], "Tables", paste(title, "table board.")),
      id = id
    ),
    bigTabs(
      id = id,
      bigTabItem(
        tabs[[1]],
        tabSettings(
          selectInput(ns("dataset"), "Dataset",
            choices = c("iris", "mtcars", "faithful")
          )
        ),
        div(
          class = "p-3",
          h3(paste(title, "Overview")),
          p(
            "This is a full ", code("bigPage()"), " with ",
            code(paste0("id = \"", id, "\"")), "."
          ),
          p("Active tab (scoped):"),
          verbatimTextOutput(ns("nav")),
          p("Per-page settings:"),
          verbatimTextOutput(ns("settings")),
          actionButton(ns("only_core"), "filterTabs: Overview + Plots",
            class = "btn btn-primary btn-sm"
          ),
          actionButton(ns("show_all"), "filterTabs: all tabs",
            class = "btn btn-outline-primary btn-sm"
          )
        )
      ),
      bigTabItem(
        tabs[[2]],
        div(
          class = "p-3",
          h3(paste(title, "Plots")),
          plotOutput(ns("plot"), height = "280px")
        )
      ),
      bigTabItem(
        tabs[[3]],
        div(
          class = "p-3",
          h3(paste(title, "Tables")),
          tableOutput(ns("table"))
        )
      )
    )
  )
}

demo_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    tabs <- paste0(id, c("-overview", "-plots", "-tables"))

    output$nav <- renderPrint({
      ## Inside this module, input$nav is the scoped "<id>-nav" value.
      input$nav
    })

    output$settings <- renderPrint({
      input$dataset
    })

    data <- reactive({
      switch(input$dataset %||% "iris",
        iris = iris,
        mtcars = mtcars,
        faithful = faithful,
        iris
      )
    })

    output$plot <- renderPlot({
      d <- data()
      x <- d[[1]]
      y <- if (ncol(d) >= 2) d[[2]] else d[[1]]
      plot(x, y, pch = 19, col = "#3181de",
        xlab = names(d)[1], ylab = names(d)[min(2, ncol(d))],
        main = paste(id, input$dataset)
      )
    })

    output$table <- renderTable({
      head(data(), 8)
    })

    observeEvent(input$only_core, {
      bigdash.filterTabs(session, tabs[1:2], id = id)
    })
    observeEvent(input$show_all, {
      bigdash.filterTabs(session, tabs, id = id)
    })
  })
}

ui <- bslib::page_fillable(
  theme = big_theme(),
  padding = 0,
  gap = 0,
  ## Host page is not a bigPage(), so attach the bundle here.
  dependencies(),
  ## One slim status row -- a taller debug header plus two height:100%
  ## pages would overflow the window.
  div(
    class = "px-3 py-1 bg-white border-bottom small d-flex flex-wrap align-items-center gap-3",
    tags$strong("sales"),
    span(class = "text-muted", textOutput("sales_nav", inline = TRUE)),
    tags$strong("lab"),
    span(class = "text-muted", textOutput("lab_nav", inline = TRUE))
  ),
  bslib::layout_columns(
    col_widths = bslib::breakpoints(sm = 12, lg = 6),
    class = "p-0",
    fill = TRUE,
    fillable = TRUE,
    div(
      class = "border-end h-100",
      demo_page("sales", "Sales", "#3181de")
    ),
    div(
      class = "h-100",
      demo_page("lab", "Lab", "#2a9d8f")
    )
  )
)

server <- function(input, output, session) {
  demo_server("sales")
  demo_server("lab")

  output$sales_nav <- renderText(input[["sales-nav"]] %||% "(none)")
  output$lab_nav <- renderText(input[["lab-nav"]] %||% "(none)")
}

shinyApp(ui, server, options = list(port = 8080, launch.browser = TRUE))
