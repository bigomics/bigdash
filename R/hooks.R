#' Application hooks
#'
#' `PlotModule`/`TableModule` were extracted from Omics Playground, which wires
#' in behaviour bigdash has no business knowing about: i18n, watermarking, the
#' plot editor, download telemetry.  Rather than depending on it, bigdash looks
#' those up as options and falls back to a no-op, so a standalone app works out
#' of the box and Omics Playground registers its own on startup:
#'
#' ```r
#' options(
#'   bigdash.tspan                  = tspan,
#'   bigdash.editor_content         = getEditorContent,
#'   bigdash.editor_theme_observer  = plotmodule_theme_observer,
#'   bigdash.record_download        = record_plot_download,
#'   bigdash.watermark              = opt$WATERMARK,
#'   bigdash.watermark_png          = function(file, position) ...,
#'   bigdash.watermark_pdf          = function(file, w, h) ...,
#'   bigdash.pdf_settings           = addSettings
#' )
#' ```
#'
#' @param name Hook name, without the `bigdash.` prefix.
#' @param default Value to use when the hook is not registered.
#'
#' @keywords internal
bd_hook <- function(name, default = NULL) {
  getOption(paste0("bigdash.", name), default)
}

#' Translate a UI string
#'
#' Identity unless the host app registered a `bigdash.tspan` hook.
#'
#' @keywords internal
bd_tspan <- function(text, js = TRUE) {
  fn <- bd_hook("tspan")
  if (is.null(fn)) {
    return(text)
  }
  fn(text, js = js)
}
