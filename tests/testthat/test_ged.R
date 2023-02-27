context("Test rebeltrack_load_dataset (UCDP GED)")

test_that("GED dimensions are correct", {
  dataset <- rebeltrack_load_dataset()
  events <- dataset@events
  expect_equal(nrow(events), 59017)
  expect_equal(ncol(events), 46)
})
