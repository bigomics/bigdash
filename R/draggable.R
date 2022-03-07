#' Swappable
#' 
#' Create swappable elements.
#' `swappableItem`s within `swappable` can be swapper.
#' 
#' @param id,inputId Id of input.
#' @param class Any additional class to pass to parent div.
#' @param ... Content, HTML tags.
#' @param order List of `inputId`s of `draggableItem` in desired
#' order.
#' @param session A value reactive domain.
#' 
#' @importFrom jsonlite toJSON
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
