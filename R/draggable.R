#' Masonry
#' 
#' Create a masonry grid.
#' 
#' @param width Used to defined column width, e.g.: 6 results in col-6
#' @param class Any additional class to pass to parent div.
#' @param ... Content, HTML tags.
#' 
#' @importFrom jsonlite toJSON
#' 
#' @name masonry
#' 
#' @export 
draggable <- function(
 ...
) {
  div(
    class = "row draggable-container",
    ...
  )
}

#' @rdname masonry
#' @export 
draggableItem <- function(
  ...,
  width = NULL,
  class = ""
) {
  .class <- sprintf("%s draggable-item", class)

  .width <- "col"
  if(!is.null(width))
    .width <- sprintf("%s-%s", .width, width)

  div(
    class = paste(.class, .width),
    ...
  )
}
