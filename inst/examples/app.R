library(shiny)
library(bigdash)

ui <- bigPage(
  navbar = navbar(
    tags$img(
      src = "assets/img/bigomics.png",
      height = "30",
    ),
    # center/left named explicitly so both dropdowns fall through to `...`,
    # which navbar() renders right-aligned
    center = NULL,
    left = NULL,
    navbarDropdown(
      "Support",
      navbarDropdownItem(
        "Documentation"
      ),
      navbarDropdownItem(
        "Contact"
      )
    ),
    navbarDropdown(
      "Tutorials",
      navbarDropdownItem(
        "Get started"
      ),
      navbarDropdownItem(
        "Advanced"
      )
    ),
    navbarDropdown(
      "John Doe",
      navbarDropdownTab(
        "Profile",
        "tab3"
      ),
      navbarDropdownItem(
        "Upgrade"
      )
    )
  ),
  sidebar = sidebar(
    "Menu",
    sidebarItem(
      "Home",
      "home"
    ),
    sidebarMenu(
      "Upload",
      sidebarMenuItem(
        "Data",
        "tab1"
      ),
      sidebarMenuItem(
        "Document",
        "tab2"
      )
    )
  ),
  settings = settings(
    "Settings"
    ## Settings will appear here
  ),
  sidebarHelp(
    sidebarTabHelp(
      "home",
      "Welcome!",
      "This is the homepage, welcome!"
    ),
    sidebarTabHelp(
      "tab1",
      "Upload",
      "This is the first tab!"
    )
  ),
  bigTabs(
    bigTabItem(
      "home",
      fullPage(
        .class = "bg-secondary text-center",
        tags$img(
          src = "assets/img/mascotte-sc.png",
          class = "img-fluid",
          style = "max-height: 20rem;"
        )
      )
    ),
    bigTabItem(
      "tab1",
      # settings for this tab only, moved into the right-hand
      # settings panel when the tab is activated
      tabSettings(
        selectInput(
          "dataset",
          "Dataset",
          choices = c("Example A", "Example B", "Example C")
        ),
        sliderInput(
          "ngenes",
          "Number of genes",
          min = 10,
          max = 1000,
          value = 100,
          step = 10
        ),
        checkboxInput(
          "normalize",
          "Normalize counts",
          value = TRUE
        )
      ),
      div(
        class = "p-4",
        h2("World"),
        tabsetPanel(
          tabPanel(
            "First tab",
            verbatimTextOutput("settings_values"),
          ),
          tabPanel(
            "Second tab",
            h1("Second tab")
          )
        )
      )
    ),
    bigTabItem(
      "tab2",
      div(
        class = "p-4",
        h2("profile")
      )
    )
  )
)

server <- function(input, output) {
  output$settings_values <- renderPrint({
    list(
      dataset = input$dataset,
      ngenes = input$ngenes,
      normalize = input$normalize
    )
  })
}

shinyApp(ui, server, options = list(port = 8080))

