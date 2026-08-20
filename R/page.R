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
#' @param id Namespace id for this page. Leave as the default `"app"`
#' unless you are nesting a [bigPage()] inside another one (e.g. embedding
#' a bigdash dashboard as a tab/module of a larger bigdash app). When
#' nesting, pass a distinct `id` here and the *same* `id` to the
#' [sidebar()], [bigTabs()], [settings()] and [sidebarHelp()] used to
#' build this page, so their generated element ids don't collide with
#' the outer page's.
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
  navbar = NULL,
  lang = NULL,
  theme = big_theme(),
  id = BIGDASH_DEFAULT_ID
) {
  settings_position <- match.arg(settings_position)

  ## One wrapper so a bigPage() fills whatever hosts it (the window, or a
  ## column next to another bigPage()). The sidebar then stretches to that
  ## height and sidebarHelp() can pin to the visible bottom instead of to
  ## `100vh` below a navbar/header.
  bootstrapPage(
    title = title,
    lang = lang,
    theme = theme,
    dependencies(),
    div(
      class = "bigdash-page d-flex flex-column h-100",
      navbar,
      div(
        class = "d-flex bigdash-app flex-grow-1",
        id = id,
        `data-bigdash-id` = id,
        style = "min-width: 0; min-height: 0;",
        sidebar,
        if(settings_position == "left") settings,
        div(
          ## No w-100: on a flex row that means 100% of the *container*, i.e. the
          ## full page width, while the sidebar and settings are siblings taking
          ## their own space -- the row then overflows by their combined width.
          ## flex-grow-1 alone already fills whatever is left over.
          ## min-width:0 because flex items default to min-width:auto, which lets
          ## wide content (tables, plots) push the column past its share instead
          ## of shrinking.
          class = "flex-grow-1 p-0",
          style = "min-width: 0;",
          ...
        ),
        if(settings_position == "right") settings
      )
    )
  )
}
