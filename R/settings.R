#' Settings
#' 
#' Settings content to pass to [bigPage()].
#' 
#' @param ... Content of the sidebar.
#' 
#' @export 
settings <- function(
  ...
) {
  div(
    class = "settings m-4",
    h4(
      "Settings",
      icon("chevron-down", class = "settings-icon"),
      class = "settings-label"
    ),
    div(
      ...,
      class = "settings-content",
      tags$a(
        `data-toggle` = "settings-collapse",
        class = "btn btn-sm btn-default",
        span("Collapse")
      )
    )
  )
}
