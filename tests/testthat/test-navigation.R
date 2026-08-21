# Fake session that records what would be sent to the browser instead of
# actually needing a live Shiny connection, so `bigdash.*` nav helpers can be
# exercised directly with plain testthat.
fake_session <- function(ns_prefix = NULL) {
  env <- new.env()
  # `send_nav()` only requires `inherits(session, c("ShinySession",
  # "MockShinySession", "session_proxy"))`; tagging a plain list as
  # "MockShinySession" (rather than "session_proxy") satisfies that without
  # tripping shiny's real `$.session_proxy`/`$<-.session_proxy` methods,
  # which expect an actual session_proxy environment, not a plain list.
  session <- structure(
    list(
      ns = shiny::NS(ns_prefix),
      sendCustomMessage = function(type, message) {
        env$sent <- list(type = type, message = message)
        env$all <- c(env$all, list(list(type = type, message = message)))
      }
    ),
    class = "MockShinySession"
  )
  list(session = session, env = env)
}

test_that("nav_scope_id resolves the top-level session to NULL (unscoped)", {
  fs <- fake_session()
  expect_null(nav_scope_id(fs$session))
})

test_that("nav_scope_id resolves a module session to its module id", {
  fs <- fake_session("qsee")
  expect_identical(nav_scope_id(fs$session), "qsee")
})

test_that("nav_scope_id returns NULL when there is no session at all", {
  expect_null(nav_scope_id(NULL))
})

test_that("bigdash.openSidebar/closeSidebar scope the message to the module id", {
  fs <- fake_session("qsee")

  bigdash.openSidebar(fs$session)
  expect_identical(fs$env$sent$type, "bigdash-open-sidebar")
  expect_identical(fs$env$sent$message$value, "qsee")

  bigdash.closeSidebar(fs$session)
  expect_identical(fs$env$sent$type, "bigdash-close-sidebar")
  expect_identical(fs$env$sent$message$value, "qsee")
})

test_that("bigdash.openSidebar/closeSidebar send no value for the top-level session", {
  fs <- fake_session()

  bigdash.openSidebar(fs$session)
  expect_identical(fs$env$sent$type, "bigdash-open-sidebar")
  expect_false("value" %in% names(fs$env$sent$message))
})

test_that("bigdash.toggleSidebar dispatches to open/close and keeps scoping", {
  fs <- fake_session("qsee")

  bigdash.toggleSidebar(TRUE, fs$session)
  expect_identical(fs$env$sent$type, "bigdash-open-sidebar")
  expect_identical(fs$env$sent$message$value, "qsee")

  bigdash.toggleSidebar(FALSE, fs$session)
  expect_identical(fs$env$sent$type, "bigdash-close-sidebar")
  expect_identical(fs$env$sent$message$value, "qsee")
})

test_that("bigdash.unloadSidebar scopes the message to the module id", {
  fs <- fake_session("qsee")

  bigdash.unloadSidebar(fs$session)
  expect_identical(fs$env$sent$type, "bigdash-unload-sidebar")
  expect_identical(fs$env$sent$message$value, "qsee")
})

test_that("bigdash.openSettings/closeSettings scope the message to the module id", {
  fs <- fake_session("qsee")

  bigdash.openSettings(session = fs$session)
  expect_identical(fs$env$sent$type, "bigdash-open-settings")
  expect_identical(fs$env$sent$message$value, "qsee")

  bigdash.closeSettings(fs$session)
  expect_identical(fs$env$sent$type, "bigdash-close-settings")
  expect_identical(fs$env$sent$message$value, "qsee")
})

test_that("bigdash.showTabs scopes the show-tabs message to the module id", {
  fs <- fake_session("qsee")

  bigdash.showTabs(fs$session)
  expect_identical(fs$env$sent$type, "show-tabs")
  expect_identical(fs$env$sent$message$value, "qsee")
})

test_that("session = NULL falls back to the pre-existing, unscoped runjs helpers", {
  calls <- character(0)
  testthat::local_mocked_bindings(
    runjs = function(code) calls <<- c(calls, code),
    .package = "shinyjs"
  )

  bigdash.openSidebar(session = NULL)
  bigdash.closeSidebar(session = NULL)
  bigdash.unloadSidebar(session = NULL)
  bigdash.openSettings(session = NULL)
  bigdash.closeSettings(session = NULL)

  expect_identical(
    calls,
    c("sidebarOpen()", "sidebarClose()", "unloadSidebar()", "settingsOpen()", "settingsClose()")
  )
})

test_that("no-argument calls stay backward compatible inside a moduleServer", {
  # Reproduces the pre-existing call convention (`bigdash.openSidebar()`,
  # `bigdash.openSettings()`, no session passed) and checks it now
  # auto-resolves *and scopes* to the enclosing module via
  # `shiny::getDefaultReactiveDomain()`, instead of erroring or silently
  # targeting the page-wide default.
  env <- new.env()
  parent_session <- shiny::MockShinySession$new()
  parent_session$sendCustomMessage <- function(type, message) {
    env$sent <- list(type = type, message = message)
  }

  server <- function(id) {
    shiny::moduleServer(id, function(input, output, session) {
      bigdash.openSidebar()
      bigdash.openSettings()
    })
  }

  shiny::testServer(server, args = list(id = "qsee"), session = parent_session, {
    expect_identical(env$sent$type, "bigdash-open-settings")
    expect_identical(env$sent$message$value, "qsee")
  })
})

test_that("bigdash.hideMenuElement/showMenuElement target a sidebarMenu() by its id", {
  fs <- fake_session()

  bigdash.hideMenuElement(fs$session, "reports-menu")
  expect_identical(fs$env$sent$type, "bigdash-hide-menu-element")
  expect_identical(fs$env$sent$message$value, "reports-menu")

  bigdash.showMenuElement(fs$session, "reports-menu")
  expect_identical(fs$env$sent$type, "bigdash-show-menu-element")
  expect_identical(fs$env$sent$message$value, "reports-menu")
})

test_that("bigdash.filterTabs sends the kept tabs and selects the first one when nothing was active", {
  fs <- fake_session()

  bigdash.filterTabs(fs$session, c("plots", "tables", "plots"))

  expect_identical(fs$env$sent$type, "bigdash-filter-tabs")
  expect_identical(fs$env$sent$message$value$id, "app")
  expect_identical(fs$env$sent$message$value$keep, c("plots", "tables"))
  expect_identical(fs$env$sent$message$value$select, "plots")
})

test_that("bigdash.filterTabs keeps the current tab selected when it is still in the kept set", {
  fs <- fake_session()
  fs$session$input <- list(nav = "tables")

  bigdash.filterTabs(fs$session, c("plots", "tables"))

  expect_identical(fs$env$sent$message$value$select, "tables")
})

test_that("bigdash.filterTabs falls back to the first tab when the current one was filtered out", {
  fs <- fake_session()
  fs$session$input <- list(nav = "reports")

  bigdash.filterTabs(fs$session, c("plots", "tables"))

  expect_identical(fs$env$sent$message$value$select, "plots")
})

test_that("bigdash.filterTabs scopes to the given bigPage() id", {
  fs <- fake_session()

  bigdash.filterTabs(fs$session, c("plots", "tables"), id = "reportsApp")

  expect_identical(fs$env$sent$message$value$id, "reportsApp")
})

test_that("bigdash.filterTabs coerces non-character input and no-ops on empty input", {
  fs <- fake_session()

  bigdash.filterTabs(fs$session, factor(c("a", "b")))
  expect_identical(fs$env$all[[1]]$message$value$keep, c("a", "b"))

  fs2 <- fake_session()
  bigdash.filterTabs(fs2$session, character(0))
  expect_null(fs2$env$sent)
})
