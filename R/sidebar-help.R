#' Sidebar Help
#' 
#' Setup contextual help to display on each tab.
#' 
#' @param ... Elements defined by [sidebarTabHelp()].
#' @param target Target tab when this should be displayed.
#' @param title,text Title, and text of the help.
#' @param id Namespace id, must match the `id` passed to the enclosing
#' [bigPage()]. See [bigPage()] for details on nesting.
#'
#' @importFrom jsonlite toJSON
#'
#' @name sidebarHelp
#'
#' @export
sidebarHelp <- function(
  ...,
  id = BIGDASH_DEFAULT_ID
) {
  data <- list(...)
  for(i in seq(data)) {
    names(data)[i] <- data[[i]]$target
  }
  json <- toJSON(
    data,
    auto_unbox = TRUE
  )
  tags$script(
    id = scoped_id(id, "sidebar-help"),
    type = "application/json",
    HTML(json)
  )
}

#' @rdname sidebarHelp
#' @export 
sidebarTabHelp <- function(
  target,
  title,
  text
) {
  if(missing(target))
    stop("Missing `target`")

  if(missing(title))
    stop("Missing `title`")

  if(missing(text))
    stop("Missing `text`")

  structure(
    list(
      target = target,
      title = title,
      text = as.character(text)
    ),
    class = c("list", "sidebarHelper")
  )
}