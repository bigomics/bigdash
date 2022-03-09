#' Dependencies
#' 
#' @importFrom htmltools htmlDependency
#' 
#' @keywords internal
dependencies <- function() {
  htmlDependency(
    "bigdash",
    version = utils::packageVersion("bigdash"),
    src = "assets",
    script = c(
      src = "index.js"
    ),
    stylesheet = c(
      src = "style.min.css"
    ),
    package = "bigdash"
  )
}