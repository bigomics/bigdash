# These check that the bigPage() building blocks generate ids that are
# unique per instance when nested/used in parallel (a distinct `id` is
# passed), while staying byte-identical to the pre-scoping markup when `id`
# is left at the default (BIGDASH_DEFAULT_ID / "app").

find_id <- function(html, tag_pattern) {
  m <- regmatches(html, regexpr(tag_pattern, html))
  if (length(m) == 0) NA_character_ else m
}

test_that("navbar() ids are unscoped at the default id (backward compatible)", {
  html <- as.character(navbar("Title"))

  expect_true(grepl('id="navbarLeftContent"', html, fixed = TRUE))
  expect_true(grepl('id="navbarCenterContent"', html, fixed = TRUE))
  expect_true(grepl('id="navbarContent"', html, fixed = TRUE))
  expect_true(grepl('data-bs-target="#navbarContent"', html, fixed = TRUE))
  expect_true(grepl('aria-controls="navbarContent"', html, fixed = TRUE))
})

test_that("navbar() ids are namespaced when given a non-default id", {
  html <- as.character(navbar("Title", id = "mymod"))

  expect_true(grepl('id="mymod-navbarLeftContent"', html, fixed = TRUE))
  expect_true(grepl('id="mymod-navbarCenterContent"', html, fixed = TRUE))
  expect_true(grepl('id="mymod-navbarContent"', html, fixed = TRUE))
  expect_true(grepl('data-bs-target="#mymod-navbarContent"', html, fixed = TRUE))
  expect_true(grepl('aria-controls="mymod-navbarContent"', html, fixed = TRUE))
  expect_true(grepl('data-bigdash-id="mymod"', html, fixed = TRUE))

  # no leftover unscoped ids
  expect_false(grepl('id="navbarContent"', html, fixed = TRUE))
})

test_that("two navbar() instances with distinct ids don't collide", {
  outer <- as.character(navbar("Outer"))
  inner <- as.character(navbar("Inner", id = "mymod"))

  outer_ids <- regmatches(outer, gregexpr('id="[^"]+"', outer))[[1]]
  inner_ids <- regmatches(inner, gregexpr('id="[^"]+"', inner))[[1]]

  expect_length(intersect(outer_ids, inner_ids), 0)
})

test_that("sidebar()/settings()/bigTabs() stay scoped consistently with navbar()", {
  id <- "mymod"

  sidebar_html <- as.character(sidebar("Menu", id = id, sidebarItem("Tab", "mymod-t1")))
  settings_html <- as.character(settings("Settings", id = id))
  tabs_html <- as.character(bigTabs(id = id, bigTabItem("mymod-t1", "content")))

  expect_true(grepl('id="mymod-sidebar-container"', sidebar_html, fixed = TRUE))
  expect_true(grepl('id="mymod-settings-container"', settings_html, fixed = TRUE))
  expect_true(grepl('id="mymod-big-tabs"', tabs_html, fixed = TRUE))
})

test_that("sidebar help keeps its layout class when the page id is scoped", {
  # Bottom-alignment CSS keys off .sidebar-help-container, not the
  # (now namespaced) id, so both default and scoped pages stay pinned.
  default_html <- as.character(sidebar("Menu", sidebarItem("Tab", "t1")))
  scoped_html <- as.character(sidebar("Menu", id = "mymod", sidebarItem("Tab", "t1")))

  expect_true(grepl('class="p-3 sidebar-help-container"', default_html, fixed = TRUE))
  expect_true(grepl('class="p-3 sidebar-help-container"', scoped_html, fixed = TRUE))
  expect_true(grepl('id="sidebar-help-container"', default_html, fixed = TRUE))
  expect_true(grepl('id="mymod-sidebar-help-container"', scoped_html, fixed = TRUE))
})
