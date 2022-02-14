#' Dependencies
#' 
#' @importFrom htmltools htmlDependency
#' 
#' @keywords internal
dependencies <- function() {
  htmlDependency(
    "bigui",
    version = utils::packageVersion("bigui"),
    src = "assets",
    script = c(
      src = "index.js"
    ),
    stylesheet = c(
      src = "style.min.css"
    ),
    package = "bigui"
  )
}