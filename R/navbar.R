#' Navbar
#' 
#' Main navbar to pass to [bigPage()] `navbar` argument.
#' 
#' @param title Brand of the navbar.
#' @param ... Content of the navbar, generally `navbar*`
#' functions.
#' 
#' @importFrom htmltools tags div
#' 
#' @export 
navbar <- function(
  title,
  ...
) {
  if(missing(title))
    stop("Missing `title`")

  tags$nav(
    class = "navbar navbar-light bg-white mb-0 pb-0",
    div(
      class = "container-fluid",
      tags$span(
        class = "navbar-brand mt-0 pt-0",
        title
      ),
      tags$button(
        class = "navbar-toggler",
        type = "button",
        `data-bs-toggle` = "collapse",
        `data-bs-target` = "#navbarContent",
        `aria-controls` = "navbarContent",
        `aria-expanded` = "false",
        `aria-label` = "Toggle navigation",
        span(
          class = "navbar-toggler-icon"
        )
      ),
      div(
        class = "collapse navbar-collapse",
        id = "navbarContent",
        tags$ul(
          class = "navbar-nav ms-auto mb-2 mb-lg-0",
          ...
        )
      )
    )
  )
}

#' Navbar Tab
#' 
#' A navbar item to use in [navbar()] which
#' toggles a [bigTabItem()].
#' 
#' @param target Target [bigTabItem()] this should
#' show.
#' @param ... Content of the navbar button.
#' 
#' @importFrom htmltools tags
#' 
#' @export 
navbarTab <- function(
  target,
  ...
) {
  tags$li(
    class = "nav-item",
    tags$a(
      class = "nav-link cursor-pointer tab-trigger",
      `data-target` = target,
      ...
    )
  )
}

#' Navbar Item
#' 
#' A navbar item to use in [navbar()].
#' 
#' @param .class Additional class to pass to `nav-item`
#' @param ... Content of the navbar button.
#' 
#' @importFrom htmltools tags
#' 
#' @export 
navbarItem <- function(
  ...,
  .class = ""
) {
  class <- sprintf("nav-item %s", .class)
  tags$li(
    class = class,
    tags$a(
      class = "nav-link",
      ...
    )
  )
}

#' Navbar Dropdown
#' 
#' A navbar dropdown menu.
#' 
#' @param title Title of the dropdown, displayed on
#' the navbar.
#' @param ... Content of the dropdown, see 
#' [navbarDropdownTab()] and [navbarDropdownItem()].
#' 
#' @importFrom htmltools tags
#' 
#' @export 
navbarDropdown <- function(
  title,
  ...
) {
  if(missing(title))
    stop("Missing `title`")

  id <- make_id()

  tags$li(
    class = "nav-item dropdown",
    tags$a(
      class = "nav-link dropdown-toggle text-mid-blue",
      id = id, 
      role = "button",
      `data-bs-toggle` = "dropdown",
      `aria-expanded` = "false",
      title
    ),
    tags$ul(
      class = "dropdown-menu",
      `aria-labelledby` = id,
      ...
    )
  )
}

#' Dropdown Item
#' 
#' A dropdown item to use in [navbarDropdown()]:
#' 
#' @param title Title of the button.
#' @param link Link the item opens.
#' @param ... Attributes passed to `<a>` tag.
#' 
#' @importFrom htmltools tags
#' 
#' @export 
navbarDropdownItem <- function(
  title,
  ...,
  link = "#"
) {
  tags$li(
    tags$a(
      class = "dropdown-item",
      href = link,
      title,
      ...
    )
  )
}

#' Navbar Dropdown Tab
#' 
#' A navbar dropdown item that opens a tab,
#' used in [navbarDropdown()].
#' 
#' @param title Title of the button.
#' @param target Target tab this should display.
#' 
#' @importFrom htmltools tags
#' 
#' @export 
navbarDropdownTab <- function(
  title,
  target
) {
  if(missing(title))
    stop("Missing `title`")

  if(missing(target))
    stop("Missing `target`")

  tags$li(
    tags$a(
      class = "dropdown-item cursor-pointer tab-trigger",
      `data-target` = target,
      title
    )
  )
}
