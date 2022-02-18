#' Settings
#' 
#' Settings content to pass to [bigPage()].
#' 
#' @inheritParams sidebar
#' 
#' @importFrom htmltools div h4 div
#' 
#' @export 
settings <- function(
  title = "Settings",
  ...
) {
  div(
    class = "settings m-4",
    h4(
      title,
      icon("chevron-down", class = "settings-icon"),
      class = "settings-label"
    ),
    div(
      ...,
      class = "settings-content"
    )
  )
}
