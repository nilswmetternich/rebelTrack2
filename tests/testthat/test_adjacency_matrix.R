context("Test rebeltrack_adjacency_matrix / rebeltrack_adjacency_matrix_gid")

# Neither adjacency matrix function had any test coverage before this - that's
# exactly how rebeltrack_adjacency_matrix()'s bare n() (missing a dplyr::
# prefix, so it only worked when dplyr was attached via library(), not when
# called as package-internal code) went unnoticed. These are deliberately
# light smoke tests: they just check the functions run and return
# correctly-shaped output, not exact values.

test_that("rebeltrack_adjacency_matrix runs and returns a correctly-shaped array", {
  dataset <- .rebeltrack_test_dataset()
  data <- rebeltrack_dataframe(dataset, side = SIDE_B, period = "month",
                               balanced = TRUE)

  adjacency_matrix <- rebeltrack_adjacency_matrix(data)

  n_actors <- dplyr::n_distinct(as.data.frame(data)$actor)
  n_periods <- dplyr::n_distinct(as.data.frame(data)$period_start)

  expect_equal(dim(adjacency_matrix), c(n_actors, n_actors, n_periods))
})

test_that("rebeltrack_adjacency_matrix_gid runs and returns a sparse array", {
  dataset <- .rebeltrack_test_dataset()
  data <- rebeltrack_dataframe_gid(dataset, side = SIDE_B, period = "month",
                                   balanced = TRUE)

  adjacency_matrix <- rebeltrack_adjacency_matrix_gid(data)

  expect_s3_class(adjacency_matrix, "simple_sparse_array")
  expect_equal(length(dim(adjacency_matrix)), 3)
})
