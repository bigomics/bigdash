# The visibility toolbox: the probe's markup, the tab-name resolution, and the
# redraw tick's "only after a purge, and only on the way back in" rule.

test_that("bd_visibility_probe() emits a namespaced probe and registration", {
  html <- as.character(bd_visibility_probe(shiny::NS("qsee-impute")))

  expect_true(grepl('id="qsee-impute-bd_visible_probe"', html, fixed = TRUE))
  expect_true(grepl('"input":"qsee-impute-is_visible"', html, fixed = TRUE))
  expect_true(grepl('"prefix":"qsee-impute-"', html, fixed = TRUE))
  expect_true(grepl("__bigdashVisibility", html, fixed = TRUE))
  # must stay in layout flow or it can never register as visible
  expect_false(grepl("display:none", html, fixed = TRUE))
})

test_that("bd_visibility_probe(spinner =) is reported to the client", {
  on_html <- as.character(bd_visibility_probe(shiny::NS("b")))
  off_html <- as.character(bd_visibility_probe(shiny::NS("b"), spinner = FALSE))

  expect_true(grepl('"spinner":true', on_html, fixed = TRUE))
  expect_true(grepl('"spinner":false', off_html, fixed = TRUE))
})

test_that("bd_visibility_lookup() picks the innermost enclosing board", {
  session <- list(
    ns = shiny::NS("qsee-impute-pca_plots"),
    userData = list(
      bigdash_visibility = list(
        "qsee-" = list(prefix = "qsee-"),
        "qsee-impute-" = list(prefix = "qsee-impute-"),
        "qsee-outlier-" = list(prefix = "qsee-outlier-")
      )
    )
  )

  expect_identical(bd_visibility_lookup(session)$prefix, "qsee-impute-")
})

test_that("bd_visibility_lookup() returns NULL when no board registered", {
  session <- list(ns = shiny::NS("elsewhere"), userData = list())
  expect_null(bd_visibility_lookup(session))
  expect_null(bd_visibility_lookup(NULL))
})

test_that("bd_is_purgeable() only claims the libraries drawn in the browser", {
  expect_true(bd_is_purgeable("plotly"))
  expect_true(bd_is_purgeable("iheatmapr"))
  expect_false(bd_is_purgeable("base"))
  expect_false(bd_is_purgeable("ggplot"))
  expect_false(bd_is_purgeable("image"))
})

test_that("bd_purge_enabled() resolves a logical, a function or a reactive", {
  expect_true(bd_purge_enabled(TRUE))
  expect_false(bd_purge_enabled(FALSE))
  expect_true(bd_purge_enabled(function() TRUE))
  expect_false(bd_purge_enabled(function() NULL))
})

test_that("bd_with_redraw() takes the dependency before calling the function", {
  calls <- character(0)
  wrapped <- bd_with_redraw(
    function() calls <<- c(calls, "tick"),
    function() {
      calls <<- c(calls, "func")
      "plot"
    }
  )

  expect_identical(wrapped(), "plot")
  expect_identical(calls, c("tick", "func"))
})

## --- the tick ---------------------------------------------------------------

board_server <- function(id, purge = TRUE) {
  shiny::moduleServer(id, function(input, output, session) {
    is_visible <- bd_is_visible(input, purge = purge)
    tick <- bd_redraw_tick()
    NULL
  })
}

test_that("the tick moves when a purged board comes back, not on first sight", {
  shiny::testServer(board_server, {
    session$setInputs(is_visible = TRUE)
    expect_true(is_visible())
    expect_identical(tick(), 0L) # first visit: nothing was ever purged

    session$setInputs(is_visible = FALSE)
    expect_false(is_visible())
    expect_identical(tick(), 0L) # bump on show, never on hide

    session$setInputs(is_visible = TRUE)
    expect_identical(tick(), 1L)

    session$setInputs(is_visible = FALSE)
    session$setInputs(is_visible = TRUE)
    expect_identical(tick(), 2L)
  })
})

test_that("the tick stays put when purging is switched off", {
  shiny::testServer(board_server, args = list(purge = FALSE), {
    session$setInputs(is_visible = TRUE)
    session$setInputs(is_visible = FALSE)
    session$setInputs(is_visible = TRUE)

    expect_identical(tick(), 0L)
  })
})

test_that("a board registers itself for the plot modules inside it", {
  shiny::testServer(board_server, args = list(id = "impute"), {
    session$setInputs(is_visible = TRUE)

    registry <- session$userData$bigdash_visibility
    expect_true(is.list(registry))
    expect_true("impute-" %in% names(registry))
    expect_true(shiny::is.reactive(registry[["impute-"]]$visible))
  })
})

test_that("bd_redraw_tick() is inert without a board above it", {
  orphan <- function(id) {
    shiny::moduleServer(id, function(input, output, session) {
      tick <- bd_redraw_tick()
      NULL
    })
  }

  shiny::testServer(orphan, {
    expect_identical(tick(), 0L)
  })
})

## --- the JavaScript-free alternative ----------------------------------------

test_that("bd_active_tab() reads the nav input from inside the module", {
  board <- function(id) {
    shiny::moduleServer(id, function(input, output, session) {
      active <- bd_active_tab(id = "qsee")
      NULL
    })
  }

  shiny::testServer(board, args = list(id = "qsee"), {
    session$setInputs(nav = "qsee-impute-tab")
    expect_identical(active(), "qsee-impute-tab")
  })
})

test_that("bd_active_tab() reads the scoped nav input from the app server", {
  shiny::testServer(
    function(input, output, session) {
      active <- bd_active_tab(id = "qsee")
    },
    {
      session$setInputs(`qsee-nav` = "qsee-outlier-tab")
      expect_identical(active(), "qsee-outlier-tab")
    }
  )
})
