#' Dependencies
#'
#' bigdash's CSS/JS bundle, as an [htmltools::htmlDependency()]. [bigPage()]
#' already includes this; call it directly when building a page that hosts
#' one or more [bigPage()]s as children/tabs without itself being a
#' [bigPage()] (e.g. a plain [bslib::page_fillable()] shell), so bigdash's
#' assets are guaranteed to load regardless of which child happens to be
#' initially visible.
#'
#' @importFrom htmltools htmlDependency
#'
#' @export
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