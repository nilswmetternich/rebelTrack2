context("Test rebeltrack_local_dataset (UCDP Actors)")

test_that("Actors dimensions are correct", {
  dataset <- rebeltrack_load_dataset()
  expect_s4_class(dataset, "RebelTrackDataSet")
  actors <- dataset@actors
  expect_equal(nrow(actors), 1687)
  expect_equal(ncol(actors), 3)
})
