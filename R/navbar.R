navbar <- function(
  title,
  ...
) {
  if(missing(title))
    stop("Missing `title`")

  tags$nav(
    class = "navbar navbar-light bg-light",
    div(
      class = "container-fluid",
      tags$span(
        class = "navbar-brand",
        title
      ),
      tags$button(
        class = "navbar-toggler",
        type = "button",
        `data-bs-toggle` = "collapse",
        `data-bs-target` = "#navbarSupportedContent",
        `aria-controls` = "navbarSupportedContent",
        `aria-expanded` = "false",
        `aria-label` = "Toggle navigation",
        span(
          class = "navbar-toggler-icon"
        )
      ),
      div(
        class = "collapse navbar-collapse",
        id = "navbarSupportedContent",
        tags$ul(
          class = "navbar-nav me-auto mb-2 mb-lg-0",
          ...
        )
      )
    )
  )
}

navbarItem <- function(
  target,
  ...
) {
  tags$li(
    class = "nav-item",
    tags$a(
      class = "nav-link",
      `data-target` = target,
      ...
    )
  )
}
