#' Page
#' 
#' Main application page.
#' 
#' @param ... Content of the application.
#' @param sidebar Sidebar content as returned by `sidebar`.
#' @param navbar Navbar.
#' @param settings Settings drawer.
#' @param title Title of the application.
#' @param lang Language for meta tag.
#' 
#' @import shiny
#' @importFrom bslib bs_theme
#' 
#' @export 
bigPage <- function(
  ...,
  sidebar = htmltools::tagList(),
  settings = htmltools::tagList(),
  title = "BigOmics",
  navbar = htmltools::tagList(),
  lang = NULL
) {
  bootstrapPage(
    title = title,
    lang = lang,
    theme = bs_theme(version = 5L),
    dependencies(),
    navbar,
    div(
      class = "row",
      id = "app",
      div(
        id = "sidebar-container",
        class = "sidebar-expanded d-none d-md-block",
        sidebar
      ),
      div(
        id = "settings-container",
        class = "sidebar-expanded d-none d-md-block",
        settings
      ),
      div(
        class = "col p-4",
        ...
      )
    )
  )
}
