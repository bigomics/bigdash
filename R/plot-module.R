##
## Copyright (c) 2018-2026 BigOmics Analytics SA. All rights reserved.
##

#' Plot module
#'
#' A bslib card wrapping a plot, with info/options/download/zoom controls in
#' the header, a fullscreen modal, and a caption footer.  Renders and exports
#' for a range of plotting libraries (see `plotlib`).
#'
#' @param id Module id.
#' @param info.text,info.methods,info.references,info.extra_link Content of the
#'   info popover.
#' @param title,caption,caption2 Card title and captions (card / modal).
#' @param options Extra controls, shown behind the hamburger button.
#' @param plotlib,plotlib2 Plotting library for the card and the modal. One of
#'   `base`, `ggplot`, `grid`, `plotly`, `visnetwork`, `iheatmapr`, `image`,
#'   `pairsD3`, `svgPanZoom`, `ggiraph`, `htmlwidget`, `renderUI`, `generic`.
#' @param outputFunc,outputFunc2 Override the output function inferred from
#'   `plotlib`.
#' @param no.download,download.fmt Download button: disable, or restrict formats.
#' @param editor Show the plot editor button. Requires a `bigdash.editor_content`
#'   hook, see [bd_hook()].
#' @param label Unused, kept for backwards compatibility.
#' @param just.info Hide the options button.
#' @param info.width Width of the info popover.
#' @param show.maximize Show the zoom button.
#' @param height,width Length-2 vectors: card size, then modal size.
#' @param card_footer_height Height of the caption footer.
#' @param pdf.width,pdf.height Default PDF/PNG export size, in inches.
#' @param cards Render several plots as tabs within one card.
#' @param card_names Tab labels, one per card, when `cards = TRUE`.
#' @param header_buttons Extra controls placed in the card header.
#' @param translate,translate_js Passed to the `bigdash.tspan` hook, see [bd_hook()].
#' @param ns_parent Namespace function of the calling module, used by the editor.
#' @param plot_type Which editor panel set to build, e.g. `"volcano"`.
#' @param bar_color_default,palette_default,bars_order_default Editor defaults.
#' @param color_selection,color_selection_default,subplot_order Editor toggles.
#'
#' @export
PlotModuleUI <- function(id,
                         info.text = "Figure",
                         info.methods = NULL,
                         info.references = NULL,
                         info.extra_link = NULL,
                         title = "",
                         options = NULL,
                         label = "",
                         caption = info.text,
                         caption2 = caption,
                         plotlib = "base",
                         plotlib2 = NULL,
                         outputFunc = NULL,
                         outputFunc2 = outputFunc,
                         no.download = FALSE,
                         download.fmt = c("png", "pdf", "svg"),
                         just.info = FALSE,
                         info.width = "300px",
                         show.maximize = TRUE,
                         height = c(400, 800),
                         card_footer_height = "3rem",
                         width = c("auto", "100%"),
                         pdf.width = 8,
                         pdf.height = 8,
                         cards = FALSE,
                         card_names = NULL,
                         header_buttons = NULL,
                         translate = TRUE,
                         translate_js = TRUE,
                         editor = FALSE,
                         ns_parent = function(a) {
                           return(a)
                         },
                         plot_type = "volcano",
                         bar_color_default = "#3181de",
                         palette_default = "muted_light",
                         bars_order_default = "alphabetical",
                         color_selection = FALSE,
                         color_selection_default = FALSE,
                         subplot_order = FALSE) {
  ns <- shiny::NS(id)

  # Svg is only available if watermark is disabled
  if (isTRUE(bd_hook("watermark", FALSE))) {
    download.fmt <- download.fmt[download.fmt != "svg"]
  }

  if (is.null(plotlib2)) plotlib2 <- plotlib
  if (length(height) == 1) height <- c(height, 800)
  if (length(width) == 1) width <- c(width, "100%")

  ifnotchar.int <- function(s) {
    suppressWarnings(
      ifelse(!is.na(as.integer(s)), paste0(as.integer(s), "px"), s)
    )
  }
  width.1 <- ifnotchar.int(width[1])
  width.2 <- "100%"
  height.1 <- ifnotchar.int(height[1])
  height.2 <- ifnotchar.int(height[2])

  if (translate) {
    info.text <- bd_tspan(info.text, js = translate_js)
    info.methods <- bd_tspan(info.methods, js = translate_js)
    title <- bd_tspan(title, js = translate_js)
    caption2 <- bd_tspan(caption2, js = translate_js)
    caption <- bd_tspan(caption, js = translate_js)
  }

  getOutputFunc <- function(plotlib) {
    FUN <- switch(plotlib,
      generic = NULL,
      htmlwidget = NULL,
      plotly = plotly::plotlyOutput,
      pairsD3 = pairsD3::pairsD3Output,
      visnetwork = visNetwork::visNetworkOutput,
      ggplot = shiny::plotOutput,
      grid = shiny::plotOutput,
      iheatmapr = iheatmapr::iheatmaprOutput,
      image = shiny::imageOutput,
      base = shiny::plotOutput,
      svgPanZoom = svgPanZoom::svgPanZoomOutput,
      ggiraph = ggiraph::ggiraphOutput,
      renderUI = shiny::htmlOutput,
      shiny::plotOutput
    )
    FUN
  }

  if (is.null(plotlib2)) plotlib2 <- plotlib
  if (cards) {
    if (length(plotlib) != length(card_names)) {
      plotlib <- rep(plotlib[1], length(card_names))
    }
    if (length(outputFunc) == 1) {
      outputFunc <- rep(list(outputFunc), length(card_names))
    }
    if (length(outputFunc2) == 1) {
      outputFunc2 <- rep(list(outputFunc2), length(card_names))
    }
    if (is.null(outputFunc)) outputFunc <- lapply(plotlib, getOutputFunc)
    if (is.null(outputFunc2)) outputFunc2 <- lapply(plotlib2, getOutputFunc)
  } else {
    if (is.null(outputFunc)) outputFunc <- getOutputFunc(plotlib)
    if (is.null(outputFunc2)) outputFunc2 <- getOutputFunc(plotlib2)
  }

  ## --------------------------------------------------------------------------------
  ## ------------------------ BUTTONS -----------------------------------------------
  ## --------------------------------------------------------------------------------
  options.button <- ""

  if (!just.info && !is.null(options) && length(options) > 0) {
    options.button <- DropdownMenu(
      options,
      size = "xs",
      width = "auto",
      icon = shiny::icon("bars"),
      status = "default"
    )
  }

  if (cards == FALSE) {
    download_buttons <- div(
      shiny::downloadButton(
        outputId = ns("download"),
        label = "Download",
        class = "btn-outline-primary"
      )
    )
  } else {
    button_list <- lapply(seq_along(card_names), function(x) {
      div(
        shiny::downloadButton(
          outputId = ns(paste0(
            "download", x
          )),
          label = card_names[x],
          class = "btn-outline-primary"
        )
      )
    })
    download_buttons <- button_list
  }

  pdf_size_ui <- shiny::tagList(
    shiny::fillRow(
      shiny::numericInput(ns("pdf_width"),
        "Width",
        pdf.width,
        1, 20, 1,
        width = "95%"
      ),
      shiny::numericInput(ns("pdf_height"),
        "Height",
        pdf.height,
        1, 20, 1,
        width = "100%"
      )
    ),
    shiny::br(), shiny::br(), shiny::br()
  )

  if ("csv" %in% download.fmt) download.fmt <- c(download.fmt, "excel")

  dload.button <- DropdownMenu(
    div(
      style = "width: 150px;",
      shiny::selectInput(
        inputId = ns("downloadOption"),
        label = "Format",
        choices = download.fmt
      ),
      div(
        id = ns("pdf_size_panel"),
        shiny::div(
          pdf_size_ui,
          shiny::br()
        )
      ),
      # shiny::conditionalPanel(
      #   condition = "input.downloadOption == 'pdf'",
      #   ns = ns,
      shiny::checkboxInput(
        inputId = ns("get_pdf_settings"),
        label = "Include plot settings (PDF)",
        TRUE
      ),
      # ),
      download_buttons
    ),
    size = "xs",
    icon = shiny::icon("download"),
    status = "default"
  )

  if (no.download || length(download.fmt) == 0) dload.button <- ""

  zoom.button <- NULL
  if (show.maximize) {
    zoom.button <- modalTrigger(
      ns("zoombutton"),
      ns("plotPopup"),
      icon("up-right-and-down-left-from-center"),
      class = "btn-circle-xs"
    )
  }

  # Build cards or single plot
  if (cards) {
    tabs <- lapply(1:length(card_names), function(x) {
      bslib::nav_panel(
        card_names[x],
        outputFunc[[x]](ns(paste0("renderfigure", x))) |>
          bigLoaders::useSpinner()
      )
    })
    tabs <- c(tabs, title = "", id = ns("card_selector"))
    plot_cards <- do.call(
      bslib::navset_card_pill,
      tabs
    )
  } else {
    plot_cards <- outputFunc(ns("renderfigure")) |>
      bigLoaders::useSpinner()
  }

  if (is.null(header_buttons)) {
    header_buttons <- div()
  }

  ## Resolved before the button is built: with no host app to supply the
  ## editor, the button would open an empty modal.
  getEditorContent <- bd_hook("editor_content")
  if (editor && is.null(getEditorContent)) {
    warning("[PlotModuleUI] editor = TRUE but no bigdash.editor_content hook registered")
    editor <- FALSE
  }

  if (editor) {
    editor_button <- shiny::div(
      class = "edit-button",
      title = "edit plot",
      modalTrigger(
        ns("editbutton"),
        ns("plotPopup2"),
        icon("pencil"),
        class = "btn-circle-xs"
      )
    )
  } else {
    editor_button <- NULL
  }

  info_button <- DropdownMenu(
    shiny::div(
      class = "plotmodule-info",
      shiny::HTML("<b>Plot info</b><br>"),
      shiny::HTML(as.character(info.text))
    ),
    if (!is.null(info.methods)) {
      shiny::div(
        class = "plotmodule-info",
        shiny::HTML("<b>Methods</b><br>"),
        shiny::HTML(info.methods)
      )
    } else {
      NULL
    },
    if (!is.null(info.references)) {
      html_code <- ""
      for (i in seq_along(info.references)) {
        ref <- info.references[[i]]
        name <- ref[[1]]
        link <- ref[[2]]

        # Create the formatted HTML string
        formatted_ref <- paste0("[", i, "] ", name, " <a href='", link, "' target='_blank'>", link, "</a><br>")

        # Append the formatted string to the HTML code
        html_code <- paste0(html_code, formatted_ref)
      }
      shiny::div(
        class = "plotmodule-info",
        shiny::HTML("<b>References</b>"),
        shiny::div(
          class = "plotmodule-info plotmodule-references",
          shiny::HTML(html_code)
        )
      )
    } else {
      NULL
    },
    if (!is.null(info.extra_link)) {
      shiny::div(
        class = "plotmodule-info",
        shiny::HTML(
          paste0(
            "<b><a href='",
            info.extra_link,
            "' target='_blank'>Further information...</a></b>"
          )
        )
      )
    } else {
      NULL
    },
    shiny::HTML("<br>"),
    shiny::actionButton(
      ns("copy_info"),
      "Copy text",
      icon = shiny::icon("clipboard"),
      class = "btn-outline-dark btn-sm",
      onclick = "copyPlotModuleInfo();"
    ),
    size = "xs",
    icon = shiny::icon("info"),
    status = "default",
    width = "300px"
  )

  header <- shiny::fillRow(
    flex = c(1, NA, NA, NA, NA, NA, NA, NA),
    class = "plotmodule-header",
    shiny::div(
      class = "plotmodule-title",
      style = "white-space: nowrap; overflow: hidden; text-overflow: clip;",
      title
    ),
    if (cards) {
      nav_bar <- gsub("nav nav-pills shiny-tab-input card-header-pills", "nav navbar-nav shiny-tab-input header-nav", plot_cards$children[[1]])
      nav_bar <- gsub("card-header bslib-navs-card-title", "bslib-navs-card-title", nav_bar) |> shiny::HTML()
      nav_bar
    } else {
      shiny::div()
    },
    header_buttons,
    info_button,
    options.button,
    editor_button,
    shiny::div(class = "download-button", title = "download", dload.button),
    shiny::div(class = "zoom-button", title = "zoom", zoom.button)
  )

  ## ------------------------------------------------------------------------
  ## --------------- modal UI (former output$popupfig) ----------------------
  ## ------------------------------------------------------------------------

  height.2 <- "100%"
  height.2 <- "calc(80vh - 100px)"

  if (cards) {
    tabs_modal <- lapply(1:length(card_names), function(x) {
      bslib::nav_panel(
        card_names[x],
        id = card_names[x],
        bslib::card_body(
          outputFunc2[[x]](ns(paste0("renderpopup", x)),
            width = width.2, height = height.2
          ) |>
            bigLoaders::useSpinner()
        )
      )
    })
    tabs_modal <- c(tabs_modal, id = ns("card_selector_modal"), bg = "transparent", inverse = FALSE)
    plot_cards_modal <- do.call(
      bslib::navset_bar,
      tabs_modal
    )
    plot_cards_modal[[1]] <- gsub("nav navbar-nav nav-underline", "nav navbar-nav", plot_cards_modal[[1]]) |> shiny::HTML()
    plot_cards_modal[[1]] <- gsub("navbar navbar-default navbar-static-top", "navbar navbar-default navbar-static-top navbar-custom", plot_cards_modal[[1]]) |> shiny::HTML()
  } else {
    plot_cards_modal <- outputFunc2(ns("renderpopup"), width = width.2, height = height.2) |>
      bigLoaders::useSpinner()
  }


  popupfigUI <- function() {
    ## render caption2 (for modal)
    if (any(class(caption2) == "reactive")) {
      caption2 <- caption2()
    }
    caption2 <- shiny::div(
      class = "caption2 popup-plot-caption",
      shiny::HTML(paste0(
        "<b>", as.character(title), ".</b>&nbsp;&nbsp;",
        as.character(caption2)
      ))
    )
    shiny::div(
      class = "popup-plot-body",
      shiny::div(
        class = "popup-plot",
        plot_cards_modal
      ),
      caption2
    )
  }

  popupfigUI.BSLIB <- function() {
    if (any(class(caption2) == "reactive")) {
      caption2 <- caption2()
    }
    caption2 <- shiny::div(
      class = "caption2 popup-plot-caption",
      shiny::HTML(paste0(
        "<b>", as.character(title), ".</b>&nbsp;&nbsp;",
        as.character(caption2)
      ))
    )
    bslib::layout_columns(
      class = "popup-plot-body",
      height = "80vh",
      col_widths = 12,
      row_heights = list(1, "auto"),
      shiny::div(class = "popup-plot", plot_cards_modal),
      caption2
    )
  }

  editor_content <- if (!editor) NULL else getEditorContent(
    plot_type = plot_type,
    ns = ns,
    ns_parent = ns_parent,
    title = title,
    cards = cards,
    outputFunc = outputFunc,
    width.2 = width.2,
    height.2 = height.2,
    bar_color_default = bar_color_default,
    palette_default = palette_default,
    bars_order_default = bars_order_default,
    color_selection = color_selection,
    color_selection_default = color_selection_default,
    subplot_order = subplot_order
  )

  ## inline styles (should be in CSS...)
  modaldialog.style <- paste0("#", ns("plotPopup"), " .modal-dialog {width:", width.2, ";}")
  modalbody.style <- paste0("#", ns("plotPopup"), " .modal-body {min-height:", height.2, "; padding:30px 150px;}")
  modalcontent.style <- paste0("#", ns("plotPopup"), " .modal-content {width:100vw;}")
  modalfooter.none <- paste0("#", ns("plotPopup"), " .modal-footer{display:none;}")

  if (any(class(caption) == "reactive")) {
    caption <- caption()
  }

  e <- bslib::card(
    # bslib::card_header(header),
    # class = "plotmodule",
    # full_screen = FALSE,
    # style = paste0("height:", height.1, ";overflow: visible;"),
    bslib::as.card_item(div(header)),
    bslib::card_body(
      gap = "0px",
      if (cards) {
        plot_cards$children[[2]]
      } else {
        plot_cards
      },
      shiny::div(
        class = "popup-modal",
        modalUI(
          id = ns("plotPopup"),
          title = title,
          size = "fullscreen",
          footer = NULL,
          popupfigUI(),
          track_open = TRUE
        )
      ),
      if (editor) {
        editor_content
      },
      shiny::tagList(
        shiny::tags$head(shiny::tags$style(modaldialog.style)),
        shiny::tags$head(shiny::tags$style(modalbody.style)),
        shiny::tags$head(shiny::tags$style(modalcontent.style)),
        shiny::tags$head(shiny::tags$style(modalfooter.none))
      )
    ),
    bslib::card_body(
      class = "card-footer", # center the content horizontally and vertically
      style = paste0("height:", card_footer_height, ";"), # add left and top margin of 2 pixels
      div(
        class = "caption",
        shiny::HTML(paste0(
          "<b>", as.character(title), ".</b>&nbsp;",
          as.character(caption)
        ))
      )
    )
  ) # end of card
  # e <- bslib::card(
  #   outputFunc(ns("renderfigure")) |>
  #     bigLoaders::useSpinner()
  # )
  return(e)
}


#' Plot module server
#'
#' @param id Module id, matching [PlotModuleUI()].
#' @param func,func2 Functions returning the plot for the card and the modal.
#' @param csvFunc Function returning the underlying data, enabling CSV/Excel
#'   download and click-to-label.
#' @param plotlib,plotlib2 Plotting library, see [PlotModuleUI()].
#' @param renderFunc,renderFunc2 Override the render function inferred from `plotlib`.
#' @param download.fmt Formats offered in the download menu.
#' @param download.pdf,download.png,download.html,download.csv,download.excel,download.obj
#'   Override the generated [shiny::downloadHandler()].
#' @param add.watermark `FALSE`, or a position passed to the `bigdash.watermark_png`
#'   / `bigdash.watermark_pdf` hooks. See [bd_hook()].
#' @param parent_session Session of the calling module, needed by the editor.
#' @param height,width Length-2 vectors: card size, then modal size.
#' @param res Length-2 vector: card resolution, then modal resolution.
#' @param download.contrast.name Reactive appended to the download filename.
#' @param pdf.width,pdf.height,pdf.pointsize PDF export geometry.
#' @param remove_margins Strip plot margins before export.
#' @param vis.delay Seconds to wait before screenshotting a visNetwork.
#' @param card Index of this plot when the UI was built with `cards = TRUE`.
#'
#' @export
PlotModuleServer <- function(id,
                             func,
                             func2 = NULL,
                             plotlib = "base",
                             plotlib2 = plotlib,
                             renderFunc = NULL,
                             renderFunc2 = renderFunc,
                             csvFunc = NULL,
                             download.fmt = c("png", "pdf", "svg"),
                             height = c(640, 800),
                             width = c("auto", 1400),
                             res = c(80, 110),
                             download.pdf = NULL,
                             download.png = NULL,
                             download.html = NULL,
                             download.csv = NULL,
                             download.excel = NULL,
                             download.obj = NULL,
                             download.contrast.name = NULL,
                             pdf.width = 8,
                             pdf.height = 6,
                             pdf.pointsize = 12,
                             add.watermark = FALSE,
                             remove_margins = FALSE,
                             vis.delay = 3,
                             card = NULL,
                             parent_session = NULL) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      filename <- sub("-$", "", ns("")) ## filename root

      observeEvent(input$downloadOption,
        {
          if (!input$downloadOption %in% c("pdf", "png")) {
            shinyjs::hide("pdf_size_panel")
          } else {
            shinyjs::show("pdf_size_panel")
          }
        },
        ignoreInit = TRUE
      )

      ## Reset all editor inputs back to their UI-declared defaults.
      ## The button and wrapper div are created in the *parent* namespace
      ## (see editorModalBody()), because shinyjs::reset only handles a
      ## single ns prefix and the editor inputs themselves use ns_parent.
      ## We run shinyjs::reset inside the parent_session's reactive
      ## domain so it prefixes/strips with the parent ns and dispatches
      ## the resulting update*Input calls to the right session.
      if (!is.null(parent_session)) {
        shiny::observeEvent(parent_session$input$editor_reset,
          {
            shiny::withReactiveDomain(parent_session, {
              shinyjs::reset("editor_inputs")
            })
          },
          ignoreInit = TRUE
        )
      }

      ## --------------------------------------------------------------------------------
      ## ------------------------ Click-to-label handler --------------------------------
      ## --------------------------------------------------------------------------------
      ## Plotly click handler (for plotly editor popups)
      if (requireNamespace("plotly", quietly = TRUE) && any(plotlib %in% "plotly")) {
        observeEvent(plotly::event_data("plotly_click"), {
          shiny::req(parent_session)
          click_data <- plotly::event_data("plotly_click")
          shiny::req(click_data)
          clicked_feature <- click_data$key
          if (is.null(clicked_feature) || is.na(clicked_feature) || clicked_feature == "") {
            return()
          }

          ## Quote names containing spaces so they stay as one token
          display_feature <- if (grepl(" ", clicked_feature)) {
            paste0('"', clicked_feature, '"')
          } else {
            clicked_feature
          }

          current_features <- parent_session$input$label_features
          if (is.null(current_features) || current_features == "") {
            new_features <- display_feature
          } else {
            current_features_vec <- strsplit(current_features, "\n")[[1]]
            current_features_vec <- trimws(current_features_vec)
            current_features_vec <- current_features_vec[current_features_vec != ""]
            ## Match against both quoted and unquoted forms for toggle-off
            is_present <- display_feature %in% current_features_vec ||
              clicked_feature %in% current_features_vec
            if (!is_present) {
              new_features <- paste0(paste(current_features_vec, collapse = "\n"), "\n", display_feature)
            } else {
              current_features_vec <- current_features_vec[
                current_features_vec != display_feature & current_features_vec != clicked_feature
              ]
              new_features <- paste(current_features_vec, collapse = "\n")
            }
          }
          updateTextAreaInput(parent_session, "label_features", value = new_features)
        })
      }

      ## Shiny plot click handler (for ggplot/base editor popups)
      observeEvent(input$plot_click, {
        shiny::req(csvFunc)
        click_x <- input$plot_click$x
        click_y <- input$plot_click$y
        plot_data <- csvFunc()
        if (inherits(plot_data, "list") && !is.data.frame(plot_data)) {
          if (!is.null(plot_data$df)) {
            plot_data <- plot_data$df
          } else {
            ## Find the position matrix: prefer named $pos, else last 2-col matrix
            pos_mat <- plot_data$pos
            if (is.null(pos_mat)) {
              pos_idx <- which(sapply(plot_data, function(x) {
                (is.matrix(x) || is.data.frame(x)) && ncol(x) == 2 && !is.null(rownames(x))
              }))
              if (length(pos_idx) > 0) {
                pos_mat <- plot_data[[tail(pos_idx, 1)]]
              }
            }
            if (!is.null(pos_mat)) {
              plot_data <- data.frame(x = pos_mat[, 1], y = pos_mat[, 2], row.names = rownames(pos_mat))
            } else {
              plot_data <- NULL
            }
          }
        }
        if (is.null(plot_data)) {
          return()
        }
        ## Ensure data.frame for $ access
        if (is.matrix(plot_data)) {
          plot_data <- data.frame(plot_data, row.names = rownames(plot_data), check.names = FALSE)
        }
        ## Use first two columns as x/y if "x"/"y" not present
        if (!all(c("x", "y") %in% colnames(plot_data))) {
          if (ncol(plot_data) >= 2) {
            colnames(plot_data)[1:2] <- c("x", "y")
          } else {
            return()
          }
        }
        distances <- sqrt((plot_data$x - click_x)^2 + (plot_data$y - click_y)^2)
        nearest_idx <- which.min(distances)
        ## Use feature_name column if available (for faceted/multi-panel plots
        ## where the same feature appears multiple times with different coords)
        clicked_feature <- if ("feature_name" %in% colnames(plot_data)) {
          plot_data$feature_name[nearest_idx]
        } else {
          rownames(plot_data)[nearest_idx]
        }

        ## Quote names containing spaces so they stay as one token
        display_feature <- if (grepl(" ", clicked_feature)) {
          paste0('"', clicked_feature, '"')
        } else {
          clicked_feature
        }

        current_features <- parent_session$input$label_features
        if (is.null(current_features) || current_features == "") {
          new_features <- display_feature
        } else {
          current_features_vec <- strsplit(current_features, "\n")[[1]]
          current_features_vec <- trimws(current_features_vec)
          current_features_vec <- current_features_vec[current_features_vec != ""]
          ## Match against both quoted and unquoted forms for toggle-off
          is_present <- display_feature %in% current_features_vec ||
            clicked_feature %in% current_features_vec
          if (!is_present) {
            new_features <- paste(current_features_vec, collapse = "\n")
            new_features <- paste0(new_features, "\n", display_feature)
          } else {
            current_features_vec <- current_features_vec[
              current_features_vec != display_feature & current_features_vec != clicked_feature
            ]
            new_features <- paste(current_features_vec, collapse = "\n")
          }
        }

        # Update label_features input
        updateTextAreaInput(
          parent_session,
          "label_features",
          value = new_features
        )
      })


      ## --------------------------------------------------------------------------------
      ## ------------------------ FIGURE ------------------------------------------------
      ## --------------------------------------------------------------------------------

      ## these engines cannot (yet) provide html
      if (plotlib %in% c("base")) {
        download.fmt <- setdiff(download.fmt, c("html"))
      }

      do.pdf <- "pdf" %in% download.fmt
      do.png <- "png" %in% download.fmt
      do.html <- "html" %in% download.fmt
      do.obj <- "obj" %in% download.fmt
      do.svg <- "svg" %in% download.fmt
      do.csv <- !is.null(csvFunc)
      do.excel <- !is.null(csvFunc)

      PNGFILE <- PDFFILE <- HTMLFILE <- CSVFILE <- EXCELFILE <- SVGFILE <- NULL
      if (do.pdf) PDFFILE <- paste0(gsub("file", "plot", tempfile()), ".pdf")
      if (do.png) PNGFILE <- paste0(gsub("file", "plot", tempfile()), ".png")
      if (do.svg) SVGFILE <- paste0(gsub("file", "plot", tempfile()), ".svg")
      if (do.csv) CSVFILE <- paste0(gsub("file", "data", tempfile()), ".csv")
      if (do.excel) EXCELFILE <- paste0(gsub("file", "data", tempfile()), ".xlsx")
      HTMLFILE <- paste0(tempfile(), ".html") ## tempory for webshot
      HTMLFILE
      unlink(HTMLFILE)

      ## ============================================================
      ## =============== Download Handlers ==========================
      ## ============================================================

      if (do.png && is.null(download.png)) {
        download.png <- shiny::downloadHandler(
          filename = shiny::reactive({
            if (!is.null(download.contrast.name)) {
              paste0(paste0(filename, "-", download.contrast.name()), ".png")
            } else {
              paste0(filename, ".png")
            }
          }),
          content = function(file) {
            png.width <- input$pdf_width * 80
            png.height <- input$pdf_height * 80
            resx <- 4 ## upresolution
            shiny::withProgress(
              {
                if (plotlib == "plotly") {
                  p <- func()
                  p$width <- png.width
                  p$height <- png.height
                  plotlyExport(p, PNGFILE, width = p$width, height = p$height, scale = resx)
                } else if (plotlib == "iheatmapr") {
                  p <- func()
                  iheatmapr::save_iheatmap(p, vwidth = png.width, vheight = png.height, PNGFILE)
                } else if (plotlib == "visnetwork") {
                  p <- func()
                  visPrint(p,
                    file = PNGFILE,
                    width = png.width * resx * 2,
                    height = png.height * resx * 2,
                    delay = vis.delay,
                    zoom = 1
                  )
                } else if (plotlib %in% c("htmlwidget", "pairsD3", "scatterD3")) {
                  p <- func()
                  htmlwidgets::saveWidget(p, HTMLFILE)
                  webshot2::webshot(
                    url = HTMLFILE, file = PNGFILE,
                    vwidth = png.width * resx, vheight = png.height * resx
                  )
                } else if (plotlib %in% c("ggplot", "ggplot2")) {
                  ggplot2::ggsave(PNGFILE, plot = func(), dpi = 72 * resx)
                } else if (plotlib == "grid") {
                  p <- func()
                  png(PNGFILE,
                    width = png.width * resx,
                    height = png.height * resx,
                    pointsize = 1.2 * pdf.pointsize,
                    res = 72 * resx
                  )
                  grid::grid.draw(p)
                  dev.off()
                } else if (plotlib == "image") {
                  p <- func()
                  file.copy(p$src, PNGFILE, overwrite = TRUE)
                } else if (plotlib == "generic") {
                  ## generic function should produce PNG inside plot func()
                } else if (plotlib == "base") {
                  # Save original plot parameters
                  if (remove_margins == TRUE) {
                    par(mar = c(0, 0, 0, 0), oma = c(0, 0, 0, 0))
                  }
                  png(PNGFILE,
                    width = png.width * resx,
                    height = png.height * resx,
                    pointsize = 1.2 * pdf.pointsize,
                    res = 72 * resx
                  )
                  print(func())
                  dev.off() ## important!!
                } else if (plotlib == "svgPanZoom") {
                  p <- func()
                  htmlwidgets::saveWidget(p, HTMLFILE)
                  webshot2::webshot(
                    url = HTMLFILE, file = PNGFILE,
                    vwidth = png.width, vheight = png.height, zoom = 4
                  )
                } else { ## end base

                  png(PNGFILE, pointsize = pdf.pointsize)
                  plot.new()
                  mtext("Error. PNG not available.", line = -8)
                  dev.off()
                }

                ## finally copy to final exported file
                message("[downloadHandler.PNG] copy PNGFILE", PNGFILE, "to download file", file)
                file.copy(PNGFILE, file, overwrite = TRUE)
                ## ImageMagick or pdftk
                watermark_png <- bd_hook("watermark_png")
                if (!is.null(watermark_png) && !add.watermark %in% c("none", FALSE)) {
                  message("[plotModule] adding watermark to PNG...")
                  watermark_png(file, position = add.watermark)
                }
                ## Record downloaded plot
                bd_record_download(ns)
              },
              message = "Exporting to PNG",
              value = 0.8
            )
          } ## content
        ) ## PNG downloadHandler
      } ## end if do.png

      if (do.pdf && is.null(download.pdf)) {
        download.pdf <- shiny::downloadHandler(
          filename = shiny::reactive({
            if (!is.null(download.contrast.name)) {
              paste0(paste0(filename, "-", download.contrast.name()), ".pdf")
            } else {
              paste0(filename, ".pdf")
            }
          }),
          content = function(file) {
            pdf.width <- input$pdf_width
            pdf.height <- input$pdf_height
            shiny::withProgress(
              {
                if (plotlib == "plotly") {
                  p <- func()
                  p$width <- pdf.width * 80
                  p$height <- pdf.height * 80
                  plotlyExport(p, PDFFILE, width = p$width, height = p$height)
                } else if (plotlib == "iheatmapr") {
                  p <- func()
                  iheatmapr::save_iheatmap(p, vwidth = pdf.width * 80, vheight = pdf.height * 80, PDFFILE)
                } else if (plotlib == "visnetwork") {
                  p <- func()
                  visPrint(p, file = PDFFILE, width = pdf.width, height = pdf.height, delay = vis.delay, zoom = 1)
                } else if (plotlib %in% c("htmlwidget", "pairsD3", "scatterD3")) {
                  p <- func()
                  htmlwidgets::saveWidget(p, HTMLFILE)
                  webshot2::webshot(url = HTMLFILE, file = PDFFILE, vwidth = pdf.width * 100, vheight = pdf.height * 100)
                } else if (plotlib %in% c("ggplot", "ggplot2")) {
                  sysfonts::font_add_google("lato")
                  showtext::showtext_auto()
                  p <- func()
                  pdf(PDFFILE, width = pdf.width, height = pdf.height, pointsize = pdf.pointsize)
                  print(p)
                  dev.off()
                } else if (plotlib %in% c("grid")) {
                  p <- func()
                  pdf(PDFFILE, width = pdf.width, height = pdf.height, pointsize = pdf.pointsize)
                  grid::grid.draw(p)
                  dev.off()
                } else if (plotlib == "image") {
                  p <- func()
                } else if (plotlib == "generic") {
                  ## generic function should produce PDF inside plot func()
                } else if (plotlib == "base") {
                  pdf(
                    file = PDFFILE, width = pdf.width, height = pdf.height,
                    pointsize = pdf.pointsize
                  )
                  print(func())
                  dev.off() ## important!!
                } else if (plotlib == "svgPanZoom") {
                  p <- func()
                  htmlwidgets::saveWidget(p, HTMLFILE)
                  webshot2::webshot(
                    url = HTMLFILE, file = PDFFILE,
                    vwidth = pdf.width * 100, vheight = pdf.height * 100
                  )
                } else if (plotlib == "ggiraph") {
                  p <- func()
                  SVGFILE <- tempfile(fileext = ".svg")
                  ggiraph::dsvg(SVGFILE)
                  print(p)
                  dev.off()
                  system(paste("convert ", SVGFILE, " ", PDFFILE))
                  unlink(SVGFILE)
                } else { ## end base
                  pdf(PDFFILE, pointsize = pdf.pointsize)
                  plot.new()
                  mtext("Error. PDF not available.", line = -8)
                  dev.off()
                }

                ## finally copy to final exported file
                message("[downloadHandler.PDF] copy PDFFILE", PDFFILE, "to download file", file)
                file.copy(PDFFILE, file, overwrite = TRUE)

                ## ImageMagick or pdftk
                watermark_pdf <- bd_hook("watermark_pdf")
                if (!is.null(watermark_pdf) && !add.watermark %in% c(FALSE, "none")) {
                  message("[plotModule] adding watermark to PDF...")
                  watermark_pdf(file, w = pdf.width, h = pdf.height)
                }
                # Add settings
                pdf_settings <- bd_hook("pdf_settings")
                if (!is.null(pdf_settings) && isTRUE(input$get_pdf_settings)) {
                  pdf_settings(ns, session, file)
                }
                ## Record downloaded plot
                bd_record_download(ns)
              },
              message = "Exporting to PDF",
              value = 0.8
            )
          } ## content
        ) ## PDF downloadHandler
      } ## end if do.pdf
      # Svg is only available if watermark is disabled
      if (do.svg && add.watermark == FALSE) {
        download.svg <- shiny::downloadHandler(
          filename = paste0(filename, ".svg"),
          content = function(file) {
            shiny::withProgress(
              {
                if (plotlib == "plotly") {
                  p <- func()
                  p$width <- input$pdf_width * 80
                  p$height <- input$pdf_height * 80
                  plotly::save_image(p, file = file, format = "svg", width = p$width, height = p$height)
                } else if (plotlib %in% c("ggplot", "ggplot2")) {
                  p <- func()
                  ggplot2::ggsave(file, plot = p, device = "svg", width = input$pdf_width, height = input$pdf_height)
                } else if (plotlib == "base") {
                  svglite::svglite(file, width = input$pdf_width, height = input$pdf_height)
                  func() # Call the plotting function directly
                  dev.off()
                } else if (plotlib == "grid") {
                  svglite::svglite(file, width = input$pdf_width, height = input$pdf_height)
                  func() # Call the plotting function directly
                  dev.off()
                } else if (plotlib == "svgPanZoom") {
                  p <- func()
                  # Save the SVG content directly to file
                  cat(p$x$svg, file = file)
                } else if (plotlib == "visnetwork") {
                  p <- func()
                  visNetwork::visSvgSave(p, file = file, delay = vis.delay)
                } else {
                  # For unsupported plot types, create a simple SVG with error message
                  svglite::svglite(file)
                  plot.new()
                  mtext("SVG export not supported for this plot type", line = -8)
                  dev.off()
                }
                ## Record downloaded plot
                bd_record_download(ns)
              },
              message = "Exporting to SVG",
              value = 0.8
            )
          }
        )
      }

      saveHTML <- function() {
        if (plotlib %in% c("plotly")) {
          p <- func()
          htmlwidgets::saveWidget(p, HTMLFILE)
        } else if (plotlib %in% c("htmlwidget", "pairsD3", "scatterD3", "ggiraph")) {
          p <- func()
          htmlwidgets::saveWidget(p, HTMLFILE)
        } else if (plotlib == "iheatmapr") {
          p <- func()
          iheatmapr::save_iheatmap(p, HTMLFILE)
        } else if (plotlib == "visnetwork") {
          p <- func()
          visNetwork::visSave(p, HTMLFILE)
        } else if (plotlib %in% c("ggplot", "ggplot2")) {
          p <- func()
          htmlwidgets::saveWidget(plotly::ggplotly(p), file = HTMLFILE)
        } else if (plotlib == "image") {
          write("<body>image cannot export to HTML</body>", HTMLFILE)
        } else if (plotlib == "generic") {
          ## generic function should produce PDF inside plot func()
        } else if (plotlib == "base") {
          write("<body>R base plots cannot export to HTML</body>", HTMLFILE)
        } else if (plotlib == "svgPanZoom") {
          p <- func()
          htmlwidgets::saveWidget(p, HTMLFILE)
        } else { ## end base
          write("<body>HTML export error</body>", file = HTMLFILE)
        }
        return(HTMLFILE)
      }

      if (do.html && is.null(download.html)) {
        download.html <- shiny::downloadHandler(
          filename = paste0(filename, ".html"),
          content = function(file) {
            shiny::withProgress(
              {
                if (plotlib == "plotly") {
                  p <- func()
                  htmlwidgets::saveWidget(p, HTMLFILE)
                } else if (plotlib %in% c("htmlwidget", "pairsD3", "scatterD3", "ggiraph")) {
                  p <- func()
                  htmlwidgets::saveWidget(p, HTMLFILE)
                } else if (plotlib == "iheatmapr") {
                  p <- func()
                  iheatmapr::save_iheatmap(p, HTMLFILE)
                } else if (plotlib == "visnetwork") {
                  p <- func()
                  visNetwork::visSave(p, HTMLFILE)
                } else if (plotlib %in% c("ggplot", "ggplot2")) {
                  p <- func()
                  htmlwidgets::saveWidget(plotly::ggplotly(p), file = HTMLFILE)
                } else if (plotlib == "generic") {
                  ## generic function should produce PDF inside plot func()
                } else if (plotlib == "image") {
                  write("<body>image cannot be exported to HTML</body>", HTMLFILE)
                } else if (plotlib == "base") {
                  write("<body>R base plots cannot be exported to HTML</body>", HTMLFILE)
                } else { ## end base
                  write("<body>HTML export error</body>", file = HTMLFILE)
                }
                ## Record downloaded plot
                bd_record_download(ns)
                ## finally copy to fina lexport file
                file.copy(HTMLFILE, file, overwrite = TRUE)
              },
              message = "Exporting to HTML",
              value = 0.8
            )
          } ## end of content
        ) ## end of HTML downloadHandler
      } ## end of do HTML

      if (do.obj) {
        if (plotlib == "plotly") {
          download.obj <- shiny::downloadHandler(
            filename = paste0(filename, ".rds"),
            content = function(file) {
              shiny::withProgress(
                {
                  p <- func()
                  ## we need to strip away unnecessary environment to prevent save bloat
                  b <- plotly::plotly_build(p)$x[c("data", "layout", "config")]
                  b <- plotly::as_widget(b) ## from JSON back to R object
                  saveRDS(b, file = file)
                  ## Record downloaded plot
                  bd_record_download(ns)
                },
                message = "saving plot object",
                value = 0.2
              )
            } ## end of content
          ) ## end of object downloadHandler
        }
      } ## end of do object

      ## if(do.csv && is.null(download.csv) )  {
      if (do.csv) {
        download.csv <- shiny::downloadHandler(
          filename = shiny::reactive({
            if (!is.null(download.contrast.name)) {
              paste0(paste0(filename, "-", download.contrast.name()), ".csv")
            } else {
              paste0(filename, ".csv")
            }
          }),
          content = function(file) {
            shiny::withProgress(
              {
                data <- csvFunc()
                if (is.list(data) && !is.data.frame(data)) data <- data[[1]]
                write.csv(data, file = file)
                ## Record downloaded plot
                bd_record_download(ns)
              },
              message = "Exporting to CSV",
              value = 0.8
            )
          } ## end of content
        ) ## end of HTML downloadHandler
      } ## end of do HTML

      # Excel download
      if (do.excel) {
        download.excel <- shiny::downloadHandler(
          filename = shiny::reactive({
            if (!is.null(download.contrast.name)) {
              paste0(paste0(filename, "-", download.contrast.name()), ".xlsx")
            } else {
              paste0(filename, ".xlsx")
            }
          }),
          content = function(file) {
            shiny::withProgress({
              data <- csvFunc()
              if (is.list(data) && !is.data.frame(data)) data <- data[[1]]
              openxlsx::write.xlsx(data, file = file, rowNames = TRUE)
            })
          }
        )
      }

      ## --------------------------------------------------------------------------------
      ## ------------------------ OUTPUT ------------------------------------------------
      ## --------------------------------------------------------------------------------
      if (is.null(card)) {
        observeEvent(input$downloadOption, {
          if (input$downloadOption == "png") {
            output$download <- download.png
          }
          if (input$downloadOption == "pdf") {
            output$download <- download.pdf
          }
          if (input$downloadOption == "svg") {
            output$download <- download.svg
          }
          if (input$downloadOption == "csv") {
            output$download <- download.csv
          }
          if (input$downloadOption == "excel") {
            output$download <- download.excel
          }
          if (input$downloadOption == "html") {
            output$download <- download.html
          }
          if (input$downloadOption == "obj") {
            output$download <- download.obj
          }
        })
      } else {
        observeEvent(input$downloadOption, {
          if (input$downloadOption == "png") {
            output[[paste0(
              "download",
              card
            )]] <- download.png
          }
          if (input$downloadOption == "pdf") {
            output[[paste0(
              "download",
              card
            )]] <- download.pdf
          }
          if (input$downloadOption == "svg") {
            output[[paste0(
              "download",
              card
            )]] <- download.svg
          }
          if (input$downloadOption == "csv") {
            output[[paste0(
              "download",
              card
            )]] <- download.csv
          }
          if (input$downloadOption == "excel") {
            output[[paste0(
              "download",
              card
            )]] <- download.excel
          }
          if (input$downloadOption == "html") {
            output[[paste0(
              "download",
              card
            )]] <- download.html
          }
          if (input$downloadOption == "obj") {
            output[[paste0(
              "download",
              card
            )]] <- download.obj
          }
        })
      }

      ## --------------------------------------------------------------------------------
      ## ---------------------------- UI ------------------------------------------------
      ## --------------------------------------------------------------------------------

      if (is.null(func2)) func2 <- func
      if (is.null(plotlib2)) plotlib2 <- plotlib
      if (length(height) == 1) height <- c(height, 700)
      if (length(width) == 1) width <- c(width, 1200)
      if (length(res) == 1) res <- c(res, 1.3 * res)

      res.1 <- res[1]
      res.2 <- res[2]

      ## width and height should actually be speficied in UI, not here.
      ifnotchar.int <- function(s) ifelse(grepl("[%]$|auto|vmin|vh|vw|vmax", s), s, as.integer(s))
      width.1 <- ifnotchar.int(width[1])
      width.2 <- ifnotchar.int(width[2])
      height.1 <- ifnotchar.int(height[1])
      height.2 <- ifnotchar.int(height[2])

      ## This sets the correct render and output functions for different
      ## plotting libraries.

      getRenderFunc <- function(plotlib) {
        switch(plotlib,
          generic = NULL,
          htmlwidget = NULL,
          plotly = plotly::renderPlotly,
          pairsD3 = pairsD3::renderPairsD3,
          visnetwork = visNetwork::renderVisNetwork,
          ggplot = shiny::renderPlot,
          grid = function(x) shiny::renderPlot(grid::grid.draw(x, recording = FALSE)),
          iheatmapr = iheatmapr::renderIheatmap,
          image = shiny::renderImage,
          base = shiny::renderPlot,
          svgPanZoom = svgPanZoom::renderSvgPanZoom,
          ggiraph = ggiraph::renderggiraph,
          renderUI = shiny::renderUI,
          shiny::renderPlot
        )
      }

      if (is.null(renderFunc)) {
        renderFunc <- getRenderFunc(plotlib)
      }

      if (is.null(renderFunc2)) {
        renderFunc2 <- getRenderFunc(plotlib2)
      }

      render <- render2 <- NULL

      if (!is.null(func) && plotlib == "base") {
        render <- shiny::renderPlot(
          {
            func()
          },
          res = res.1
        )
      }
      if (!is.null(func2) && plotlib2 == "base") {
        render2 <- shiny::renderPlot(
          {
            func2()
          },
          res = res.2
        )
      }
      if (!is.null(func) && plotlib == "grid") {
        render <- shiny::renderPlot(
          {
            grid::grid.draw(func(), recording = FALSE)
          },
          res = res.1
        )
      }
      if (!is.null(func2) && plotlib2 == "grid") {
        render2 <- shiny::renderPlot(
          {
            grid::grid.draw(func2(), recording = FALSE)
          },
          res = res.2
        )
      }
      if (plotlib == "image") {
        render <- shiny::renderImage(func(), deleteFile = FALSE)
      }
      if (!is.null(func2) && plotlib2 == "image") {
        render2 <- shiny::renderImage(func2(), deleteFile = FALSE)
      }

      if (grepl("cacheKeyExpr", head(renderFunc, 1))) {
        render <- shiny::renderCachedPlot(
          func(),
          cacheKeyExpr = {
            list(csvFunc())
          },
          res = res.1
        )
      }
      if (grepl("cacheKeyExpr", head(renderFunc2, 1))) {
        render2 <- shiny::renderCachedPlot(
          func2(),
          cacheKeyExpr = {
            list(csvFunc())
          },
          res = res.2
        )
      }

      if (is.null(render)) {
        if (plotlib == "plotly") {
          # If the plotting function is `plotly`, add the edit button
          render <- renderFunc({
            # By default remove plotly logo from all plots
            plot <- func() |>
              plotly::config(
                displaylogo = FALSE,
                scrollZoom = TRUE
              ) |>
              plotly::plotly_build()

            if (remove_margins == TRUE) {
              plot <- plot |> plotly::layout(margin = list(l = 0, r = 0, t = 0, b = 0))
            }

            # Remove toImage button from modebar
            if (inherits(plot$x$config$modeBarButtons, "list")) {
              for (y in seq_along(plot$x$config$modeBarButtons[[1]])) {
                if (plot$x$config$modeBarButtons[[1]][[y]] == "toImage") {
                  plot$x$config$modeBarButtons[[1]][[y]] <- NULL
                  break
                }
              }
            } else {
              plot <- plot |>
                plotly::config(
                  modeBarButtonsToRemove = c("zoomIn2d", "toImage")
                )
            }
            plot
          })
        } else {
          render <- renderFunc(func())
        }
      }

      if (is.null(render2) && !is.null(func2)) {
        if (plotlib2 == "plotly") {
          render2 <- renderFunc2({
            # By default remove plotly logo from all plots
            plot <- func2() |>
              plotly::config(
                displaylogo = FALSE,
                scrollZoom = TRUE
              ) |>
              plotly::plotly_build()
            # Remove toImage button from modebar
            if (inherits(plot$x$config$modeBarButtons, "list")) {
              for (y in seq_along(plot$x$config$modeBarButtons[[1]])) {
                if (plot$x$config$modeBarButtons[[1]][[y]] == "toImage") {
                  plot$x$config$modeBarButtons[[1]][[y]] <- NULL
                  break
                }
              }
            } else {
              plot <- plot |>
                plotly::config(
                  modeBarButtonsToRemove = c("zoomIn2d", "toImage")
                )
            }
            plot
          })
        } else {
          render2 <- renderFunc2(func2())
        }
      }

      if (is.null(card)) {
        output$renderfigure <- render
        output$renderpopup <- render2
        output$renderfigure_2 <- render2
      } else {
        output[[paste0(
          "renderfigure",
          card
        )]] <- render
        output[[paste0(
          "renderpopup",
          card
        )]] <- render2
        output$renderfigure_2 <- render
      }

      shiny::observeEvent(input$copy_info, {
        shinyjs::runjs(
          paste0(
            "addTick('",
            ns("copy_info"),
            "')"
          )
        )
      })


      ## --------------------------------------------------------------------------------
      ## -------------------- THEME COLOR OBSERVERS ------------------------------------
      ## --------------------------------------------------------------------------------

      theme_observer <- bd_hook("editor_theme_observer")
      if (!is.null(parent_session) && !is.null(theme_observer)) {
        theme_observer(parent_session)
      }

      ## --------------------------------------------------------------------------------
      ## ---------------------------- RETURN VALUE --------------------------------------
      ## --------------------------------------------------------------------------------

      list(
        plotfun = func,
        plotfun2 = func2,
        .tmpfiles = c(pdf = PDFFILE, html = HTMLFILE),
        render = render,
        render2 = render2,
        download.pdf = download.pdf,
        download.png = download.png,
        download.html = download.html,
        download.csv = download.csv,
        download.excel = download.excel,
        saveHTML = saveHTML,
        renderFunc = renderFunc
      )
    }
  )
}


#' Export a plotly object to a static file
#'
#' Tries kaleido first, falling back to the deprecated orca-based
#' `plotly::export()`, and finally to a placeholder image.
#'
#' @param p A plotly object.
#' @param file Output path; the format is taken from its extension.
#' @param format Output format, defaults to the extension of `file`.
#' @param width,height,scale Passed through to the exporter.
#' @param server Unused, kept for backwards compatibility.
#'
#' @export
plotlyExport <- function(p, file, format = tools::file_ext(file),
                         width = NULL, height = NULL, scale = 1, server = NULL) {
  is.docker <- file.exists("/.dockerenv")
  is.docker
  export.ok <- FALSE

  if (class(p)[1] != "plotly") {
    message("[plotlyExport] ERROR : not a plotly object")
    return(NULL)
  }
  ## remove old
  unlink(file, force = TRUE)

  ## See if Kaleido is available
  if (1 && !export.ok) {
    ## https://github.com/plotly/plotly.R/issues/2179
    reticulate::py_run_string("import sys")
    err <- try(suppressMessages(plotly::save_image(p, file = file, width = width, height = height, scale = scale)))
    export.ok <- class(err) != "try-error"
    if (export.ok) message("[plotlyExport] --> exported with plotly::save_image() (kaleido)")
    export.ok <- TRUE
  }
  if (1 && !export.ok) {
    ## works only for non-GL plots
    err <- try(plotly::export(p, file, width = width, height = height))
    export.ok <- class(err) != "try-error"
    if (export.ok) message("[plotlyExport] --> exported with plotly::export() (deprecated)")
  }
  if (0 && !export.ok) {
    tmp <- paste0(tempfile(), ".html")
    htmlwidgets::saveWidget(p, tmp)
    err <- try(webshot2::webshot(url = tmp, file = file, vwidth = width * 100, vheight = height * 100))
    export.ok <- class(err) != "try-error"
    if (export.ok) message("[plotlyExport] --> exported with webshot2::webshot()")
  }
  if (!export.ok) {
    message("[plotlyExport] WARNING: export failed!")
    if (format == "png") png(file)
    if (format == "pdf") pdf(file)
    par(mfrow = c(1, 1))
    frame()
    text(0.5, 0.5, "Plotly export error", cex = 2)
    dev.off()
  }

  message("[plotlyExport] file.exists(file)=", file.exists(file))
  export.ok <- export.ok && file.exists(file)
  return(export.ok)
}


#' Record a plot download
#'
#' No-op unless the host app registered a `bigdash.record_download` hook.
#'
#' @keywords internal
bd_record_download <- function(ns) {
  fn <- bd_hook("record_download")
  if (is.null(fn)) {
    return(invisible(NULL))
  }
  fn(substr(ns(""), 1, nchar(ns("")) - 1))
}

#' Export a visNetwork object to a static file
#'
#' Renders the widget offscreen with webshot2. PDF output goes via PNG and
#' needs ImageMagick's `convert` on the PATH.
#'
#' @param visnet A visNetwork object.
#' @param file Output path; `.pdf` triggers the ImageMagick step.
#' @param width,height Render size in pixels.
#' @param delay Seconds to wait before the screenshot, for layouts that animate.
#' @param zoom Screenshot zoom factor.
#'
#' @export
visPrint <- function(visnet, file, width = 3000, height = 3000, delay = 0, zoom = 1) {
  is.pdf <- grepl("pdf$", file)
  if (is.pdf) {
    width <- width * 600
    height <- height * 600
  }
  vis2 <- htmlwidgets::createWidget(
    name = "visNetwork",
    x = visnet$x,
    width = width, height = height,
    package = "visNetwork"
  )
  tmp.html <- paste0(tempfile(), "-visnet.html")
  tmp.png <- paste0(tempfile(), "-webshot.png")
  visNetwork::visSave(vis2, file = tmp.html)
  webshot2::webshot(
    url = tmp.html,
    file = tmp.png,
    selector = "#htmlwidget_container",
    delay = delay,
    zoom = zoom,
    cliprect = "viewport",
    vwidth = width,
    vheight = height
  )
  if (is.pdf) {
    cmd <- paste("convert", tmp.png, "-density 600", file)
    system(cmd)
  } else {
    file.copy(tmp.png, file, overwrite = TRUE)
  }
  unlink(tmp.html)
}
