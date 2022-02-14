#' Page
#' 
#' Main application page.
#' 
#' @param ... Content of the application.
#' @param sidebar Sidebar content as returned by `sidebar`.
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
  title = "BigOmics",
  lang = NULL
) {
  sidebar <- tagAppendChild(
    sidebar,
    tags$a(
      `data-toggle` = "sidebar-collapse",
      class = "btn btn-sm btn-default",
      span("Collapse")
    )
  )
  bootstrapPage(
    title = title,
    lang = lang,
    theme = bs_theme(version = 5L),
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

#' Sidebar
#' 
#' Sidebar content to pass to [bigPage()].
#' 
#' @param ... Contnent of the sidebar.
#' 
#' @export 
sidebar <- function(
  ...
) {
  div(
    class = "sidebar m-4",
    ...
  )
}

#' Sidebar Menu
#' 
#' Menu for the side bar to pass to [sidebar()].
#' 
#' @param text Text to display when the sidebar is expanded.
#' @param icon Icon to display when the sidebar is collapsed.
#' @param ... Children, [sidebarMenuElement()].
#' 
#' @export 
sidebarMenu <- function(
  text,
  icon,
  ...
) {
  if(missing(text))
    stop("Missing `text`")

  if(missing(icon))
    stop("Missing `icon`")

  id <- make_id()

  tagList(
    p(
      class = "w-100 mb-2",
      a(
        class = "hide-expanded text-dark d-none",
        `data-bs-toggle` = "collapse",
        href = sprintf("#%s", id),
        icon
      ),
      tags$a(
        class = "show-expanded text-decoration-none text-dark",
        `data-bs-toggle` = "collapse",
        href = sprintf("#%s", id),
        span(
          class = "fw-bold",
          text
        ),
        span(
          icon(
            "chevron-down",
            class = "toggler float-right pt-1"
          )
        )
      )
    ),
    hr_(),
    div(
      class = "collapse",
      id = id,
      ...
    )
  )
}

#' Element for the Sidebar menu
#' 
#' Element in the collapsible [sidebarMenu()].
#' 
#' @inheritParams sidebarMenu
#' 
#' @export 
sidebarMenuElement <- function(
  text,
  icon
) {
  if(missing(text))
    stop("Missing `text`")

  if(missing(icon))
    stop("Missing `icon`")

  tagList(
    p(
      class = "w-100 mb-2",
      a(
        class = "hide-expanded text-dark d-none",
        icon
      ),
      a(
        class = "show-expanded text-decoration-none text-dark",
        text
      ),
    ),
    hr_()
  )
}

#' Horizontal Rule
#' 
#' Horizontal rule with little margin.
#' 
#' @keywords internal
hr_ <- function() {
  htmltools::tags$hr(class = "mt-1 mp-1")
}
