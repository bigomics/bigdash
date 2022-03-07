#' Masonry
#' 
#' Create a masonry grid.
#' 
#' @param inputId Id of input.
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
