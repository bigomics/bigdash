#' Make ID
#' 
#' Generate a unique id.
#' 
#' @keywords internal
make_id <- function(){
  paste0(sample(letters), collapse = "")
}

#' Horizontal Rule
#' 
#' Horizontal rule with little margin.
#' 
#' @keywords internal
hr_ <- function(...) {
  #  htmltools::tags$hr(class = "mt-1 mp-1", ...)
  htmltools::tags$hr(class = "mt-0 mb-0 tab-trigger-hr", ...)
}

#' @keywords internal
pkg_file <- function(
  path
) {
  system.file(path,  package = "bigdash")
}

#' Boostrap alert
#' @export
bs_alert <- function(..., conditional = TRUE, style = "primary") {
  id <- bigdash:::make_id()
  alert_tag <- shiny::tags$div(
    id = id,
    class = paste0("alert alert-", style, " alert-dismissible fade show"),
    role = "alert",
    ...,
    if (conditional) {
      shiny::tags$button(
        # Use display: none; instead of official boostrap close button.
        # If not, the element interfers with the bslib::layout_column_wrap
        # and we get extra gap on top. The second part of the `onclick` is
        # to also close the box (hide it) when it is not placed inside a
        # bslib::layout_column_wrap
        onclick = paste0('$("#', id, ' button").closest(".bslib-gap-spacing.html-fill-container").css("display", "none");$("#', id, ' button").parent().css("display", "none");'),
        type = "button",
        class = "btn-close btn-close-bs-conditional",
        `aria-label` = "Close",
        shiny::tags$span(
          `aria-hidden` = "true"
        )
      )
    } else {
      shiny::tags$button(
        onclick = paste0('$("#', id, ' button").closest(".bslib-gap-spacing.html-fill-container").css("display", "none");$("#', id, ' button").parent().css("display", "none");'),
        type = "button",
        class = "btn-close",
        `aria-label` = "Close",
        shiny::tags$span(
          `aria-hidden` = "true"
        )
      )
    }
  )
  return(alert_tag)
}