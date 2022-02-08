dependencies <- function() {
  htmltools::htmlDependency(
    "bigui",
    version = utils::packageVersion("bigui"),
    src = "assets",
    script = c(
      src = "index.js"
    ),
    style = c(
      src = "style.min.css"
    ),
    package = "bigui"
  )
}