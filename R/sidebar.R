#' Sidebar
#' 
#' Sidebar content to pass to [bigPage()].
#' 
#' @param title Title of the sidebar.
#' @param ... Content of the sidebar.
#' 
#' @export 
sidebar <- function(
  title = "Menu",
  ...
) {
  div(
    class = "sidebar m-4",
    h4(
      title,
      icon("chevron-down", class = "sidebar-icon"),
      class = "sidebar-label cursor-pointer mb-3"
    ),
    div(
      ...,
      class = "sidebar-content"
    )
  )
}

sidebarItem <- function(
  title,
  target
) {

  if(missing(title))
    stop("Missing `title`")

  if(missing(target))
    stop("Missing `target`")

  tagList(
    p(
      title,
      `data-target` = target,
      class = "tab-trigger tab-sidebar cursor-pointer fw-bold w-100 mb-2"
    ),
    hr_()
  )
}

#' Sidebar Menu
#' 
#' Menu for the side bar to pass to [sidebar()].
#' 
#' @param text Text to display when the sidebar is expanded.
#' @param ... Children, [sidebarMenuElement()].
#' 
#' @export 
sidebarMenu <- function(
  text,
  ...
) {
  if(missing(text))
    stop("Missing `text`")
  
  id <- make_id()

  tagList(
    p(
      class = "w-100 mb-2",
      tags$a(
        class = "sidebar-menu text-decoration-none text-dark",
        `data-bs-toggle` = "collapse",
        href = sprintf("#%s", id),
        span(
          class = "fw-bold",
          text
        ),
        icon(
          "chevron-down",
          class = "sidebar-menu-icon float-right mt-1 text-mid-grey"
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
#' @param target `name` of the target [bigTabItem()] that this should
#' make visible.
#' 
#' @export 
sidebarMenuElement <- function(
  text,
  target
) {
  if(missing(text))
    stop("Missing `text`")

  if(missing(target))
    stop("Missing `target`")

  tagList(
    p(
      class = "w-100 mb-2",
      a(
        class = "text-decoration-none text-dark cursor-pointer tab-trigger tab-sidebar",
        `data-target` = target,
        text
      ),
    ),
    hr_()
  )
}
