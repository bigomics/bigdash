#' @importFrom shiny addResourcePath
.onLoad <- function(...) {
  addResourcePath(
    "assets",
    pkg_file("assets")
  )
}