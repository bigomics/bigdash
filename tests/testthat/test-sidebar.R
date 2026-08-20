test_that("sidebarItem()'s divider hr carries the same data-target as its tab-trigger", {
  # bigdash-hide-menuitem/bigdash-show-menuitem key off [data-target=...] to
  # hide both the label and its hr divider together. Without a data-target
  # here, hiding the item leaves its hr behind, doubling up against the next
  # visible item's own hr.
  html <- as.character(sidebarItem("Overview", "overview"))

  expect_true(grepl('class="tab-trigger tab-sidebar cursor-pointer w-100 mb-0 text-muted"', html, fixed = TRUE))
  expect_true(grepl('<hr class="mt-0 mb-0 tab-trigger-hr" data-target="overview"', html, fixed = TRUE))
})
