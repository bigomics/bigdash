#' Tabs
#' 
#' Create big tabs.
#' 
#' @param ... Tabs, must be [bigTabItem()].
#' 
#' @export 
bigTabs <- function(
  ...
) {
  div(
    id = "big-tabs",
    ...
  )
}

#' Tab
#' 
#' Create a tab.
#' 
#' @param name Name of tab.
#' This is to be reference in the `target` argument
#' of the [sidebarMenuElement()].
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