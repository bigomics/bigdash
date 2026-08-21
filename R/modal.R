##
## Copyright (c) 2018-2026 BigOmics Analytics SA. All rights reserved.
##

#' Modal trigger
#'
#' A link that opens the modal with the given id. Pair with [modalUI()].
#'
#' @param id Id of the trigger itself.
#' @param target Id of the modal to open.
#' @param ... Content of the link, typically an icon.
#' @param class Extra classes for the link.
#'
#' @export
modalTrigger <- function(
    id,
    target,
    ...,
    class = "") {
  class <- sprintf(
    "btn %s",
    class
  )

  shiny::tags$a(
    id = id,
    ...,
    `data-bs-toggle` = "modal",
    `data-bs-target` = sprintf("#%s", target),
    class = class
  )
}

#' Modal
#'
#' A Bootstrap 5 modal, declared inline in the UI and opened by a
#' [modalTrigger()] rather than by [shiny::showModal()].
#'
#' @param id Modal id, referenced by the trigger's `target`.
#' @param title Modal title.
#' @param ... Modal body.
#' @param size Modal size.
#' @param track_open Report the open/closed state to the server as the
#'   `<id>_is_open` input.
#' @param footer Modal footer; `NULL` for none.
#'
#' @export
modalUI <- function(
    id,
    title,
    ...,
    size = c("default", "sm", "lg", "xl", "fullscreen"),
    track_open = FALSE,
    footer = shiny::tags$div(
      class = "modal-footer",
      shiny::tags$button(
        type = "button",
        class = "btn btn-secondary",
        `data-bs-dismiss` = "modal",
        "Close"
      )
    )) {
  size <- match.arg(size)

  size_cl <- switch(size,
    "sm" = "modal-sm",
    "lg" = "modal-lg",
    "xl" = "modal-xl",
    "fullscreen" = "modal-fullscreen",
    ""
  )

  modal <- shiny::tags$div(
    class = "modal fade",
    id = id,
    tabindex = "-1",
    `aria-labelledby` = "exampleModalLabel",
    `aria-hidden` = "true",
    shiny::tags$div(
      class = sprintf("modal-dialog %s", size_cl),
      shiny::tags$div(
        class = "modal-content",
        shiny::tags$div(
          class = "modal-header",
          shiny::tags$div(
            class = "modal-title",
            title
          ),
          shiny::tags$button(
            type = "button",
            class = "btn-close",
            `data-bs-dismiss` = "modal",
            `aria-label` = "Close"
          )
        ),
        shiny::tags$div(
          class = "modal-body",
          ...
        ),
        footer
      )
    )
  )

  if (track_open) {
    shiny::tagList(modal, modal_track_script(id))
  } else {
    modal
  }
}

#' Report a modal's open state to the server
#'
#' The script behind `modalUI(track_open = TRUE)`, so it can also be attached to
#' a modal built elsewhere -- the plot editor's, which [PlotModuleUI()] triggers
#' but does not build.
#'
#' @param id DOM id of the modal. Reported as `<id>_is_open`.
#'
#' @keywords internal
modal_track_script <- function(id) {
  shiny::tags$script(shiny::HTML(sprintf(
    "$('#%s').on('shown.bs.modal hidden.bs.modal', function(e) {
      Shiny.setInputValue('%s_is_open', e.type === 'shown');
    });",
    id,
    id
  )))
}
