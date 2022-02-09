#' Page
#' 
#' @import shiny
bigPage <- function(
  ...,
  sidebar = list(),
  title = "BigOmics",
  lang = NULL
) {
  sidebar <- htmltools::tagAppendChild(
    sidebar,
    tags$a(
      `data-toggle` = "sidebar-colapse",
      "Collapse",
      class = "btn btn-default"
    )
  )
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

sidebar <- function(
  ...
) {
  tags$ul(
    class = "list-group",
    ...
  )
}

sidebarBlock <- function(
  text
) {
  tags$li(
    class = "list-group-item sidebar-separator-title text-muted d-flex align-items-center menu-collapsed",
    tags$small(
      text
    )
  )
}

sidebarSubMenu <- function(
  text,
  ...,
  .icon = "fa fa-gauge fa-fw"
) {
  if(missing(text))
    stop("Missing `text`")

  id <- make_id()

  tagList(
    tags$a(
      href = sprintf("#%s", id),
      `data-toggle` = "collapse",
      `aria-expanded` = "false",
      class = "bg-dark list-group-item list-group-item-action flex-column align-items-start",
      tags$div(
        class = "d-flex w-100 justify-content-start align-items-center",
        span(
          class = sprintf("%s mr-3", .icon)
        ),
        span(
          class = "menu-collapsed",
          text
        ),
        span(
          class = "submenu-icon ml-auto"
        )
      )
    ),
    div(
      id = id,
      class = "collapse sidebar-submenu",
      ...
    )
  )
}

sidebarSubMenuItem <- function(
  text,
  target = text
) {
  tags$a(
    `data-target` = target,
    class = "list-group-item list-group-item-action bg-dark text-white",
    span(
      class = "menu-collapsed",
      text
    )
  )
}
