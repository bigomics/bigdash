#' Tabs
#' 
#' Create big tabs.
#' 
#' @param ... Tabs, must be [bigTabItem()].
#' @param id Namespace id, must match the `id` passed to the enclosing
#' [bigPage()]. See [bigPage()] for details on nesting.
#'
#' @export
bigTabs <- function(
  ...,
  id = BIGDASH_DEFAULT_ID
) {
  div(
    id = scoped_id(id, "big-tabs"),
    `data-bigdash-id` = id,
    ...
  )
}

#' Tab
#' 
#' Create a tab.
#' 
#' @param name Name of tab.
#' This is to be reference in the `target` argument
#' of the [sidebarMenuItem()].
#' @param ... Content of the tab.
#' 
#' @export 
bigTabItem <- function(
  name,
  ...
) {
  if(missing(name)) 
    stop("Missing `name`")

  div(
    class = "big-tab d-none",
    `data-name` = name,
    ...
  )
}