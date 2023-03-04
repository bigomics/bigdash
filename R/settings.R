#' Settings
#' 
#' Settings content to pass to [bigPage()].
#' 
#' @inheritParams sidebar
#' @param .posthook JavaScript function as string to run
#' after the settings have been rendered.
#' 
#' @importFrom htmltools div h4 div
#' @importFrom shiny HTML
#' 
#' @export 
settings <- function(
  title = "Settings",
  ...,
  .posthook = NULL
) {
  div(
    id = "settings-container",
    class = "settings-expanded position-relative d-none flex-shrink-1 d-md-block",
    div(
      class = "settings p-2 mt-3",
      div(
        class = "settings-lock settings-unlocked settings-lock-collapsed",
        tags$i(class = "fa-solid fa-lock-open cursor-pointer settings-locked-icon"),
      ),
      h4(
        
        title,
        icon("chevron-right", class = "settings-icon"),
        class = "settings-label mb-3"
      ),
      div(
        ...,
        id = "settings-content"
      )
    ),
    tags$script(
      id = "settings-posthook",
      type = "application/JavaScript",
      HTML(.posthook)
    )
  )
}

#' Tab Settings
#' 
#' Tab settings, to place within [bigTabItem()],
#' every [bigTabItem()] expect max one [tabSettings()].
#' These ultimately appear in the settings sidebar.
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
  div(
    class = "d-none tab-settings",
    ...
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
