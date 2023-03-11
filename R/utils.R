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
  htmltools::tags$hr(class = "mt-0 mb-0", ...)
}

#' @keywords internal
pkg_file <- function(
  path
) {
  system.file(path,  package = "bigdash")
}
