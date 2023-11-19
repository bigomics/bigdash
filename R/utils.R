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

#' Update tab elements
#'
#' @title Update tab elements
#'
#' @param input_tab Character name of the input tab 
#' @param tab_elements Named list of elements to enable/disable for each tab
#'
#' @return No return value, called for side effects
#' 
#' @details Enables elements for the given input tab and disables all other elements.
#' Checks that input_tab is valid name in tab_elements. Gets enable/disable elements
#' for that tab, calls shinyjs::enable() on those elements. Disables all other elements.
#' \dontrun{
#'     tab_elements <- list(
#'      "Heatmap" = list(enable = NULL,
#'                         disable = c("hm_clustmethod")),
#'      "PCA/tSNE" = list(enable = NULL,
#'                        disable = c("hm_features", "hm_splitby", "hm_level", "hm_filterXY", "hm_filterMitoRibo")),
#'      "Parallel" = list(enable = NULL,
#'                       disable = c("selected_phenotypes", "hm_clustmethod"))
#'    )
#'    shiny::observeEvent(input$tabs1, {
#'      bigdash::update_tab_elements(input$tabs1, tab_elements)
#'    })
#' }
#' @export
update_tab_elements <- function(input_tab, tab_elements) {
  # Safety check
  if (!input_tab %in% names(tab_elements)) {
    stop("Error: input_tab not found in tab_elements")
  }
  # Get the elements to enable or disable for this tab
  elements <- tab_elements[[input_tab]]
  # Enable the elements
  if (!is.null(elements$enable)) {
    for (element in elements$enable) {
      shinyjs::enable(element)
    }
  } else {
    all_elements <- unlist(tab_elements)
    elements_to_enable <- setdiff(all_elements, elements$disable)  
    for (element in elements_to_enable) {
      shinyjs::enable(element)
    }
  }
  # Disable the elements
  if (!is.null(elements$disable)) {
    for (element in elements$disable) {
      shinyjs::disable(element)
    }

  }
}