#' Page
#' 
#' @import shiny
bigPage <- function(
  ...,
  menu = list(),
  title = "BigOmics",
  lang = NULL
) {
  bootstrapPage(
    title = title,
    lang = lang,
    theme = bslib::bs_theme(version = 5L),
    div(
      class = "row",
      id = "app",
      div(
        class = "sidebar-expanded d-none d-md-block",
        menu
      ),
      div(
        class = "col p-4",
        ...
      )
    )
  )
}

