#' Page
#' 
#' @import shiny
bigPage <- function(
  ...,
  sidebar = list(),
  title = "BigOmics",
  lang = NULL
) {
  bootstrapPage(
    title = title,
    lang = lang,
    theme = bslib::bs_theme(version = 5L),
    dependencies(),
    div(
      class = "row",
      id = "app",
      div(
        id = "sidebar-container",
        class = "sidebar-expanded d-none d-md-block",
        sidebar
      ),
      div(
        class = "col p-4",
        ...
      )
    )
  )
}
