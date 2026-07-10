context("Test rebeltrack_load_dataset (UCDP GED)")

test_that("GED dimensions are correct", {
  # Updated for UCDP GED v26.1 (was v18.1's 59017 x 46). rebeltrack_load_dataset()
  # defaults to prec = 1 (only precision-level-1/exact-location events), which
  # is why this is far fewer than the raw download's 417968 rows. The column
  # count is GED's own 49 plus the 2 PRIO-GRID covariates (bdist2, capdist)
  # added by the join in rebeltrack_load_dataset(). See docs/DATA_SOURCES.md.
  dataset <- .rebeltrack_test_dataset()
  events <- dataset@events
  expect_equal(nrow(events), 194544)
  expect_equal(ncol(events), 51)
})
