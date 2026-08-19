test_that("as_dt_widget() passes through NULL and existing datatable widgets unchanged", {
  expect_null(as_dt_widget(NULL))

  dt <- DT::datatable(head(iris))
  expect_identical(as_dt_widget(dt), dt)
})

test_that("as_dt_widget() wraps a bare data.frame/matrix in DT::datatable()", {
  wrapped <- as_dt_widget(head(iris))
  expect_true(inherits(wrapped, "datatables"))
  expect_identical(nrow(wrapped$x$data), 6L)

  wrapped_mat <- as_dt_widget(as.matrix(head(iris[1:3])))
  expect_true(inherits(wrapped_mat, "datatables"))
})

test_that("TableModuleServer() renders when func() returns a bare data.frame", {
  # Regression test: func() returning a plain data.frame used to corrupt
  # itself via `dt$x$foo <- ...` on a nonexistent `x` column, surfacing as
  # an opaque "replacement has N rows, data has M" error instead of just
  # working. See as_dt_widget().
  server <- function(id) {
    shiny::moduleServer(id, function(input, output, session) {
      TableModuleServer("t1", func = function() head(iris))
    })
  }

  shiny::testServer(server, args = list(id = "mod"), {
    session$setInputs()
    session$flushReact()
    out <- session$getOutput("mod-t1-datatable")
    expect_true(nchar(as.character(out)) > 0)
  })
})
