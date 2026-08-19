test_that("sidebarMenu() defaults to promote_single = FALSE", {
  html <- as.character(sidebarMenu("Reports", sidebarMenuItem("Sales", "sales")))
  expect_true(grepl('data-promote-single="false"', html, fixed = TRUE))
})

test_that("sidebarMenu(promote_single = TRUE) marks its header for client-side promotion", {
  # navigation.js's refreshMenuPromotion() looks for this attribute to decide
  # which groups are eligible to collapse down to a flat top-level item when
  # exactly one sidebarMenuItem() is left visible.
  html <- as.character(sidebarMenu("Reports", sidebarMenuItem("Sales", "sales"), promote_single = TRUE))

  expect_true(grepl('class="w-100 mb-0 sidebar-menu-header"', html, fixed = TRUE))
  expect_true(grepl('data-promote-single="true"', html, fixed = TRUE))
})

test_that("sidebarMenu(id = ...) uses the given id instead of an auto-generated one", {
  # bigdash.hideMenuElement()/showMenuElement() target a group by this id, so
  # it must be the one the caller actually passed, on both the header's
  # data-target and the .collapse body's own id.
  html <- as.character(sidebarMenu("Reports", sidebarMenuItem("Sales", "sales"), id = "reports-menu"))

  expect_true(grepl('data-target="reports-menu"', html, fixed = TRUE))
  expect_true(grepl('id="reports-menu"', html, fixed = TRUE))
})

test_that("sidebarMenu() auto-generates an id when none is given", {
  html1 <- as.character(sidebarMenu("Reports", sidebarMenuItem("Sales", "sales")))
  html2 <- as.character(sidebarMenu("Reports", sidebarMenuItem("Sales", "sales")))

  id1 <- regmatches(html1, regexpr('(?<=data-target=")[a-z]+', html1, perl = TRUE))
  id2 <- regmatches(html2, regexpr('(?<=data-target=")[a-z]+', html2, perl = TRUE))

  expect_false(identical(id1, id2))
})
