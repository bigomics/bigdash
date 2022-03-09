<!-- badges: start -->
<!-- badges: end -->

# bigdash

Dashboard layout and theme for [shiny](https://shiny.rstudio.com).

## Installation

You can install the development version of bigdash from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("bigomics/bigdash")
```

## Example

```r
library(shiny)
library(bigdash)

ui <- bigPage(
  navbar = navbar(
    tags$img(
      src = "assets/img/bigomics.png",
      width = "110",
    ),
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
    "Settings",
    p(
      "Settings will appear here."
    )
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
      div(
        class = "p-4",
        h1("Hello"),
        actionButton("reorder", "randomise order"),
        swappable(
          inputId = "swap",
          fluidRow(
            swappableItem(
              inputId = "s1",
              class = "col-6",
              div(
                class = "card",
                div(
                  class = "card-body",
                  plotOutput("plot1")
                )
              )
            ),
            swappableItem(
              inputId = "s2",
              class = "col-3",
              div(
                class = "card",
                div(
                  class = "card-body",
                  h3("Something")
                )
              )
            ),
            swappableItem(
              inputId = "s3",
              class = "col-3",
              div(
                class = "card",
                div(
                  class = "card-body",
                  h5("Something else")
                )
              )
            )
          )
        )
      )
    ),
    bigTabItem(
      "tab2",
      div(
        class = "p-4",
        h2("World"),
        tabsetPanel(
          tabPanel(
            "First tab",
            h1("First tab")
          ),
          tabPanel(
            "Second tab",
            h1("Second tab")
          )
        )
      )
    ),
    bigTabItem(
      "tab3",
      div(
        class = "p-4",
        h2("profile")
      )
    )
  )
)

server <- function(input, output) {
  output$plot1 <- renderPlot({
    plot(cars)
  })

  observeEvent(input$swap, {
    print(input$swap)
  })

  observeEvent(input$reorder, {
    order <- sample(
      c(
        "s1",
        "s2",
        "s3"
      )
    )

    update_swappable("swap", order)
  })
}

shinyApp(ui, server, options = list(port = 8080))
```

