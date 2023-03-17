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
    primary = "#3181DE",
    secondary = "#81A1C1",
    success = "#009C9F",
    info = "#8FBCBB",
    danger = "#BF616A",
    warning = "#E3A45A",
    dark = "#3B4252",
    light = "#F8FBFF",
    base_font = font_google(
      "Lato"
    )
  )
}
