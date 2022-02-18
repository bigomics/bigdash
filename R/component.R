#' Full page
#' 
#' Full page component, takes the entirety of the screen.
#' 
#' @param .class Additional class to pass to parent
#' `<div>`.
#' @param ... Content of the page.
#' 
#' @importFrom htmltools div
#' 
#' @export 
fullPage <- function(
  ...,
  .class = ""
) {
  class <- sprintf(
    "big-full-page w-100 p-4 %s",
    .class
  )

  div(
    class = class,
    ...
  )
}