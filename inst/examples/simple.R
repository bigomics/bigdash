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
      "John Doe",
      navbarDropdownTab(
        "Profile",
        "tab2"
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
        h2("Data Board"),
        tabsetPanel(
          tabPanel(
            "First",
            verbatimTextOutput("settings_values"),
          ),
          tabPanel("Second", div(class="p-3", "Second tab contents")),
          tabPanel("Third", div(class="p-3", "Third tab contents"))         
        )
      )
    ),
    bigTabItem(
      "tab2",
      div(
        class="p-4",
        h2("Document Board"),
        p("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
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

