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
#' @param settings_position Position of the settings bar.
#' 
#' @import shiny
#' 
#' @export 
bigPage <- function(
  ...,
  sidebar = htmltools::tagList(),
  settings = htmltools::tagList(),
  settings_position = c("right", "left"),
  title = "BigOmics",
  navbar = htmltools::tagList(),
  lang = NULL,
  theme = big_theme()
) {
  settings_position <- match.arg(settings_position)

  bootstrapPage(
    title = title,
    lang = lang,
    theme = theme,
    dependencies(),
    navbar,
    div(
      class = "d-flex",
      id = "app",
      sidebar,
      if(settings_position == "left") settings,
      div(
        class = "flex-grow-1 p-0 w-100",
        ...
      ),
      if(settings_position == "right") settings
    )
  )
}
