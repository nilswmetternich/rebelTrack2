context("Test rebeltrack_dataframe")

test_RebelTrackDataFrame <- function(side, period, period_min, period_max) {
  dataset <- .rebeltrack_test_dataset()
  data <- rebeltrack_dataframe(dataset,
                               side = side,
                               period = period,
                               balanced = TRUE)

  expect_s4_class(data, "RebelTrackDataFrame")
  data <- as.data.frame(data)

  period_length <- data$period_end - data$period_start +1
  expect_equal(min(period_length), as.difftime(period_min, unit="days"))
  expect_equal(max(period_length), as.difftime(period_max, unit="days"))

  columns <- c("actor", "period_start", "period_end", "active")
  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)
}

test_that("Weekly RebelTrackDataFrame is created correctly", {
  test_RebelTrackDataFrame(SIDE_A, "week", 7, 7)
  test_RebelTrackDataFrame(SIDE_B, "week", 7, 7)
})

test_that("Monthly RebelTrackDataFrame is created correctly", {
  test_RebelTrackDataFrame(SIDE_A, "month", 28, 31)
  test_RebelTrackDataFrame(SIDE_B, "month", 28, 31)
})
