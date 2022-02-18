#' Default Theme
#' 
#' Default theme, passed to [bigPage()].
#' 
#' @importFrom bslib bs_theme font_google
#' 
#' @export 
big_theme <- function() {
  bs_theme(
    version = 5L,
    primary = "#004CA7",
    secondary = "#F2FAFF",
    success = "#86A563",
    info = "#6ABEEA",
    danger = "#E45C00",
    base_font = font_google(
      "Lato"
    )
  )
}