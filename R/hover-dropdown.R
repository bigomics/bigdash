#' Create a Hover Dropdown UI Element
#'
#' This function creates a hover dropdown UI element in a Shiny app. The dropdown appears
#' when the user hovers over the icon.
#'
#' @param icon_class A character string that defines the class of the Font Awesome icon to use.
#' @param ... Arbitrary Shiny UI elements to display in the dropdown.
#'
#' @return A Shiny UI element that can be added to the UI definition of the app.
#' @export
#'
#' @examples
#' hover_dropdown(
#'   icon_class = "fa fa-cog",
#'   div(class = "custom-item", "Item 1"),
#'   div(class = "custom-item", "Item 2")
#' )
hover_dropdown <- function(..., icon_class = "fa fa-cog") {
    dropdown_content <- lapply(list(...), function(x) {
        div(class = "custom-item", x)
    })

    tagList(
        div(class = "hover-dropdown",
            tags$i(class = paste0(icon_class, " hover-dropdown-button")),
            div(
                class = "hover-dropdown-content",
                do.call(tagList, dropdown_content)
            )
        )
    )
}
