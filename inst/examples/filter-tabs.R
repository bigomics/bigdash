## Dynamic tab filtering with bigdash.filterTabs()
##
## Demonstrates bigdash::bigdash.filterTabs(session, tabs), a convenience
## function that shows *only* the listed tabs (and their sidebar menu items)
## while hiding all others (both the menu entries and the .big-tab canvases).
##
## Also exercises a multilevel sidebarMenu()/sidebarMenuItem() submenu
## ("Reports" collapses into "Sales Report"/"Usage Report") alongside plain
## sidebarItem()s, to check hiding/filtering behaves the same for both.
##
## Run with:
##   Rscript inst/examples/filter-tabs.R
library(shiny)
library(bigdash)

tab_names <- c("overview", "plots", "tables", "sales-report", "usage-report", "settings-tab")

ui <- bigPage(
  title = "bigdash filterTabs demo",
  navbar = navbar(
    tags$img(src = "assets/img/bigomics.png", height = "30"),
    navbarDropdown(
      "Filter Demo",
      navbarDropdownItem("All tabs", onclick = "Shiny.setInputValue('filter_preset', 'all')"),
      navbarDropdownItem("Core only", onclick = "Shiny.setInputValue('filter_preset', 'core')"),
      navbarDropdownItem("Analysis only", onclick = "Shiny.setInputValue('filter_preset', 'analysis')")
    )
  ),
  sidebar = sidebar(
    "Menu",
    sidebarItem("Overview", "overview"),
    sidebarItem("Plots", "plots"),
    sidebarItem("Tables", "tables"),
    sidebarMenu(
      "Reports",
      sidebarMenuItem("Sales Report", "sales-report"),
      sidebarMenuItem("Usage Report", "usage-report"),
      promote_single = TRUE
    ),
    sidebarItem("Extra Settings", "settings-tab")
  ),
  settings = settings("Global Settings"),
  sidebarHelp(
    sidebarTabHelp("overview", "Overview", "Dashboard landing page."),
    sidebarTabHelp("plots", "Plots", "Interactive visualizations."),
    sidebarTabHelp("tables", "Tables", "Data tables with filtering."),
    sidebarTabHelp("sales-report", "Sales Report", "Generated PDF/Excel sales report."),
    sidebarTabHelp("usage-report", "Usage Report", "Generated PDF/Excel usage report."),
    sidebarTabHelp("settings-tab", "Settings", "App configuration.")
  ),
  bigTabs(
    bigTabItem(
      "overview",
      div(class = "p-4",
        h2("Overview"),
        p("This is the landing page. Use the navbar dropdown or the multi-select below to filter visible tabs."),
        p("The ", code("bigdash.filterTabs()"), " call hides menu items + tab canvases for all non-selected tabs."),
        selectInput("visible_tabs", "Visible tabs (multi-select)", choices = character(0), multiple = TRUE, width = "100%"),
        verbatimTextOutput("active_tab")
      )
    ),
    bigTabItem(
      "plots",
      div(class = "p-4",
        h2("Plots Board"),
        PlotModuleUI("plot1", title = "Sample Plot", plotlib = "plotly"),
        p("Only visible when 'plots' is in the allowed tabs list.")
      )
    ),
    bigTabItem(
      "tables",
      div(class = "p-4",
        h2("Tables Board"),
        TableModuleUI("table1", title = "Sample Table"),
        p("Dynamic data table.")
      )
    ),
    bigTabItem(
      "sales-report",
      div(class = "p-4",
        h2("Sales Report"),
        p("Report generation interface (placeholder)."),
        actionButton("generate_sales_report", "Generate Sales Report")
      )
    ),
    bigTabItem(
      "usage-report",
      div(class = "p-4",
        h2("Usage Report"),
        p("Report generation interface (placeholder)."),
        actionButton("generate_usage_report", "Generate Usage Report")
      )
    ),
    bigTabItem(
      "settings-tab",
      tabSettings(
        selectInput("theme", "Theme", choices = c("light", "dark"), selected = "light"),
        sliderInput("refresh_rate", "Auto-refresh (s)", 5, 60, 30)
      ),
      div(class = "p-4",
        h2("Settings Board"),
        p("Configuration that affects the whole dashboard.")
      )
    )
  )
)

server <- function(input, output, session) {

  # Register plot/table modules (minimal)
  PlotModuleServer("plot1", plotlib = "plotly", func = function() {
    plotly::plot_ly(x = 1:10, y = rnorm(10), type = "scatter", mode = "markers")
  })
  TableModuleServer("table1", func = function() DT::datatable(head(iris)))

  output$active_tab <- renderPrint({
    paste("Currently active tab:", input$nav %||% "(none)")
  })

  # Single tab selector
  observeEvent(input$visible_tabs, {
    req(input$visible_tabs)
    selected <- input$visible_tabs
    message("[filterTabs] Showing only: ", paste(selected, collapse = ", "))
    bigdash.filterTabs(session, selected)
  }, ignoreNULL = TRUE)

  # Preset buttons via navbar dropdown
  observeEvent(input$filter_preset, {
    preset <- input$filter_preset
    tabs <- switch(preset,
      "all"       = tab_names,
      "core"      = c("overview", "plots", "tables"),
      "analysis"  = c("plots", "tables", "sales-report", "usage-report"),
      tab_names
    )
    message("[filterTabs] Preset '", preset, "' → ", paste(tabs, collapse = ", "))
    bigdash.filterTabs(session, tabs)
    # Also update the multi-select to match
    updateSelectInput(session, "visible_tabs", selected = tabs)
  })

  # Initial state: show all
  bigdash.filterTabs(session, tab_names)
  updateSelectInput(session, "visible_tabs",
    choices = tab_names,
    selected = tab_names
  )

  # Demo report buttons
  observeEvent(input$generate_sales_report, {
    showNotification("Sales report would be generated here (demo).", type = "message")
  })
  observeEvent(input$generate_usage_report, {
    showNotification("Usage report would be generated here (demo).", type = "message")
  })
}

shinyApp(ui, server, options = list(port = 8080, launch.browser = TRUE))
