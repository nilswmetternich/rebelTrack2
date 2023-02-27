context("Test rebeltrack_load_dataset")

test_that("Class is RebelTrackDataSet", {
  dataset <- rebeltrack_load_dataset()
  expect_s4_class(dataset, "RebelTrackDataSet")
})
