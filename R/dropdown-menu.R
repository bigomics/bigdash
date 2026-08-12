##
## Copyright (c) 2018-2026 BigOmics Analytics SA. All rights reserved.
##

#' Dropdown menu
#'
#' A circular icon button that opens its content in a Bootstrap popover.  Used
#' for the info, options and download buttons of [PlotModuleUI()] and
#' [TableModuleUI()].
#'
#' @param ... Content of the popover.
#' @param size Button size: `default`, or a Bootstrap suffix such as `xs`/`sm`.
#' @param status Bootstrap button variant, without the `btn-` prefix.
#' @param icon Icon shown on the button.
#' @param circle Use the circular button style.
#' @param border Bootstrap border variant, or `default` for none.
#' @param width Width of the popover body.
#'
#' @export
DropdownMenu <- function(..., size = "default", status = "default", icon = NULL, circle = TRUE, border = "default", width = "") {
  id <- make_id()
  bslib::popover(
    shiny::tags$a(
      class = paste0(
        "btn btn-", status, " action-button",
        if (circle) {
          " btn-circle"
        } else {
          ""
        },
        if (size == "default") {
          " "
        } else {
          paste0("-", size, " ")
        },
        if (size != "default") paste0("btn-", size),
        if (border != "default") paste0(" border border-", border)
      ),
      list(icon), `data-bs-toggle` = "popover", id = id
    ),
    ...,
    placement = "bottom",
    options = list(
      animation = FALSE,
      template = paste0('<div class="popover" role="tooltip"><div class="popover-arrow"></div><h3 class="popover-header"></h3><div class="popover-body style=width:,', width, ';"></div></div>')
    ),
    onClick = shiny::HTML(paste0("$(document).ready(function() { makePopoverDismissible('", id, "'); addActionOnPopoverChange('", id, "'); });"))
  )
}
