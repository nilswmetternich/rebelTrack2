context("Test rebeltrack_dataframe_gid")

test_RebelTrackDataFrame_gid <- function(side, period, period_min, period_max) {
  dataset <- .rebeltrack_test_dataset()
  data <- rebeltrack_dataframe_gid(dataset,
                               side = side,
                               period = period,
                               balanced = TRUE)

  expect_s4_class(data, "RebelTrackDataFrameGid")
  data <- as.data.frame(data)

  period_length <- data$period_end - data$period_start +1
  expect_equal(min(period_length), as.difftime(period_min, unit="days"))
  expect_equal(max(period_length), as.difftime(period_max, unit="days"))

  columns <- c("priogrid_gid", "period_start", "period_end", "active")
  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)
}

test_that("Weekly RebelTrackDataFrameGid is created correctly", {
  test_RebelTrackDataFrame_gid(SIDE_A, "week", 7, 7)
  test_RebelTrackDataFrame_gid(SIDE_B, "week", 7, 7)
})

test_that("Monthly RebelTrackDataFrameGid is created correctly", {
  test_RebelTrackDataFrame_gid(SIDE_A, "month", 28, 31)
  test_RebelTrackDataFrame_gid(SIDE_B, "month", 28, 31)
})
