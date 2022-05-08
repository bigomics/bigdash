#' Swappable
#' 
#' Create swappable elements.
#' `swappableItem`s within `swappable` can be swapper.
#' 
#' @param el Element to apply type to.
#' @param id,inputId Id of input.
#' @param class Any additional class to pass to parent div.
#' @param ... Content, HTML tags.
#' @param order List of `inputId`s of `draggableItem` in desired
#' order.
#' @param session A value reactive domain.
#' 
#' @examples 
#' library(shiny)
#' 
#' ui <- bigPage(
#'   sidebar = sidebar(
#'     "Menu",
#'     sidebarItem(
#'       "Home",
#'       "home"
#'     )
#'   ),
#'   bigTabs(
#'     bigTabItem(
#'       "home",
#'       div(
#'         class = "p-4",
#'         h1("Hello"),
#'         actionButton("reorder", "randomise order"),
#'         swappable(
#'           inputId = "swap",
#'           fluidRow(
#'             swappableItem(
#'               inputId = "s1",
#'               class = "col-6",
#'               div(
#'                 class = "card",
#'                 div(
#'                   class = "card-body",
#'                   plotOutput("plot1")
#'                 )
#'               )
#'             ),
#'             swappableItem(
#'               inputId = "s2",
#'               class = "col-3",
#'               div(
#'                 class = "card",
#'                 div(
#'                   class = "card-body",
#'                   h3("Something")
#'                 )
#'               )
#'             ),
#'             swappableItem(
#'               inputId = "s3",
#'               class = "col-3",
#'               div(
#'                 class = "card",
#'                 div(
#'                   class = "card-body",
#'                   h5("Something else")
#'                 )
#'               )
#'             )
#'           )
#'         )
#'       )
#'     )
#'   )
#' )
#' 
#' server <- function(input, output) {
#'   output$plot1 <- renderPlot({
#'     plot(cars)
#'   })
#' 
#'   observeEvent(input$swap, {
#'     print(input$swap)
#'   })
#' 
#'   observeEvent(input$reorder, {
#'     order <- sample(
#'       c(
#'         "s1",
#'         "s2",
#'         "s3"
#'       )
#'     )
#' 
#'     update_swappable("swap", order)
#'   })
#' }
#' 
#' if(interactive())
#'  shinyApp(ui, server)
#' 
#' @importFrom jsonlite toJSON
#' @importFrom htmltools tagAppendAttributes
#' 
#' @name swappable
#' 
#' @export 
swappable <- function(
  inputId,
 ...
) {
  if(missing(inputId))
    stop("Missing `inputId`")

  div(
    id = inputId,
    class = "swappable-container",
    ...
  )
}

#' @rdname swappable
#' @export 
asSwappable <- \(el){
  tagAppendAttributes(el, class = "swappable-container")
}

#' @rdname swappable
#' @export 
swappableItem <- function(
  inputId,
  ...,
  class = ""
) {
  if(missing(inputId))
    stop("Missing `inputId`")

  .class <- sprintf("%s swappable-item", class)

  div(
    id = inputId,
    class = .class,
    ...
  )
}

#' @rdname swappable
#' @export 
asSwappableItem <- \(el){
  tagAppendAttributes(el, class = "swappable-item")
}

#' @rdname swappable
#' @export 
update_swappable <- function(
  id,
  order,
  session = shiny::getDefaultReactiveDomain()
) {
  if(missing(id))
    stop("Missing `id`")

  if(missing(order))
    stop("Missing `order`")

  session$sendInputMessage(id, as.list(order))
}
