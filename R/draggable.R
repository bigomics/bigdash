#' Draggable
#' 
#' Create a draggable grid.
#' 
#' @param id,inputId Id of input.
#' @param width Used to defined column width, e.g.: 6 results in col-6
#' @param class Any additional class to pass to parent div.
#' @param ... Content, HTML tags.
#' @param order List of `inputId`s of `draggableItem` in desired
#' order.
#' @param session A value reactive domain.
#' 
#' @importFrom jsonlite toJSON
#' 
#' @name masonry
#' 
#' @export 
draggable <- function(
  inputId,
 ...
) {
  if(missing(inputId))
    stop("Missing `inputId`")

  div(
    id = inputId,
    class = "row draggable-container",
    ...
  )
}

#' @rdname masonry
#' @export 
draggableItem <- function(
  inputId,
  ...,
  width = NULL,
  class = ""
) {
  if(missing(inputId))
    stop("Missing `inputId`")

  .class <- sprintf("%s draggable-item", class)

  .width <- "col"
  if(!is.null(width))
    .width <- sprintf("%s-%s", .width, width)

  div(
    id = inputId,
    class = paste(.class, .width),
    ...
  )
}

#' @rdname masonry
#' @export 
update_draggable <- function(
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
