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
#' @param theme Theme, passed to `theme`, defaults to
#' [big_theme()] which returns an object of class
#' `bs_theme`. Can be changed but must be a n object
#' of the same class as returned by [bslib::bs_theme()]
#' for __Bootstrap 5.__
#' 
#' @import shiny
#' 
#' @export 
bigPage <- function(
  ...,
  sidebar = htmltools::tagList(),
  settings = htmltools::tagList(),
  title = "BigOmics",
  navbar = htmltools::tagList(),
  lang = NULL,
  theme = big_theme()
) {
  bootstrapPage(
    title = title,
    lang = lang,
    theme = theme,
    dependencies(),
    navbar,
    div(
      class = "row",
      id = "app",
      div(
        id = "sidebar-container",
        class = "sidebar-expanded d-none d-md-block",
        sidebar,
        div(
          id = "sidebar-help-container",
          class = "p-2",
          h4(
            id = "sidebar-help-title"
          ),
          hr_(),
          div(
            id = "sidebar-help-content"
          )
        )
      ),
      div(
        id = "settings-container",
        class = "settings-expanded d-none d-md-block",
        settings
      ),
      div(
        class = "col p-0",
        ...
      )
    )
  )
}
