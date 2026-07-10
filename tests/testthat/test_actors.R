context("Test rebeltrack_local_dataset (UCDP Actors)")

test_that("Actors dimensions are correct", {
  # Updated for UCDP's current actor release (was v18.1's flat 1687 x 3
  # actorlist.csv). The current source is ucdp-actor-261-csv.zip, which
  # ships far more columns (35) per actor; rebeltrack_load_actors() loads it
  # as-is with no column selection. See dev-notes/DATA_SOURCES.md.
  dataset <- .rebeltrack_test_dataset()
  expect_s4_class(dataset, "RebelTrackDataSet")
  actors <- dataset@actors
  expect_equal(nrow(actors), 1987)
  expect_equal(ncol(actors), 35)
})
