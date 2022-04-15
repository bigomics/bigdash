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
    id = "settings-container",
    class = "settings-expanded position-relative d-none flex-shrink-1 d-md-block",
    div(
      class = "settings m-4",
      h4(
        title,
        icon("chevron-down", class = "settings-icon"),
        class = "settings-label cursor-pointer mb-3"
      ),
      div(
        ...,
        id = "settings-content"
      )
    )
  )
}

#' Tab Settings
#' 
#' Tab settings, to place within [bigTabItem()].
#' 
#' @param ... Content.
#' 
#' @importFrom jsonlite toJSON
#' @importFrom htmltools span
#' 
#' @export 
tabSettings <- function(
  ...
) {
  items <- list(...) |> 
    lapply(as.character) |> 
    span(
      class = "tab-settings d-none",
      type = "application/json"
    )
}

#' Tab Settings Item
#' 
#' Tab settings item to pass to [tabSettings()],
#' these are generally inputs that will appear in the 
#' settings siderbar.
#' 
#' @param element Content.
#' 
#' @export 
tabSettingsItem <- function(
  element
) {
  structure(
    element,
    class = c(
      "tagSettingsItem",
      class(element)
    )
  )
}
