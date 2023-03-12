#' Sidebar
#'
#' Sidebar content to pass to [bigPage()].
#'
#' @param title Title of the sidebar.
#' @param ... Content of the sidebar.
#' @param top_expanded,top_collapsed Top of page content, above title.
#'
#' @export
sidebar <- function(
  title = "Menu",
  ...,
  top_expanded = NULL,
  top_collapsed = NULL
) {
  if(!is.null(top_expanded))
    top_expanded <- div(id = "sidebar-top-expanded", top_expanded)

  if(!is.null(top_collapsed))
    top_collapsed <- div(id = "sidebar-top-collapsed", top_collapsed, class = "d-none")

  div(
    id = "sidebar-container",
    class = "sidebar-expanded flex-shrink-1 d-md-block",
    div(
      class = "sidebar p-2",
      id = "sidebar-wrapper",
      top_expanded,
      top_collapsed,
      h4(
        title,
        icon("angles-left", class = "sidebar-icon float-right"),
        class = "sidebar-label cursor-pointer mb-3"
      ),
      div(
        class = "sidebar-content",
        ...
      )
    ),
    div(
      id = "sidebar-help-container",
      class = "p-2",
      h4(
        id = "sidebar-help-title",
        `data-bs-toggle` = "collapse",
        href = "#sidebar-help-content"
      ),
      hr_(),
      div(
        id = "sidebar-help-content",
        class = "collapse"
      )
    )
  )
}

#' Sidebar Item
#'
#' A sidebar item to place as child of [sidebar()].
#'
#' @param title Title of the sidebar.
#' @param target Target [bigTabItem()] this should toggle.
#'
#' @export
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
      class = "tab-trigger tab-sidebar cursor-pointer w-100 mb-0 text-muted"
    ),
    hr_()
  )
}

#' Sidebar Menu
#'
#' Menu for the side bar to pass to [sidebar()].
#'
#' @param text Text to display when the sidebar is expanded.
#' @param ... Children, [sidebarMenuItem()].
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
      class = "w-100 mb-0",
      tags$a(
        class = "sidebar-menu text-decoration-none text-muted cursor-pointer",
        `data-target` = id,
        span(
          text
        ),
        icon(
          "angle-right",
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
sidebarMenuItem <- function(
  text,
  target
) {
  if(missing(text))
    stop("Missing `text`")

  if(missing(target))
    stop("Missing `target`")

  tagList(
    p(
      class = "w-100 mb-0 sidebar-menu-item",
      a(
        class = "text-decoration-none text-muted cursor-pointer tab-trigger tab-sidebar",
        `data-target` = target,
        text
      ),
    ),
    hr_()
  )
}
