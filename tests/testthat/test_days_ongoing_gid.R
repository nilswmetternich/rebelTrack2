context("Test rebeltrack_days_ongoing_gid")

test_days_ongoing_gid <- function(side, period) {
  dataset <- .rebeltrack_test_dataset()
  data <- rebeltrack_dataframe_gid(dataset,
                                   side = side,
                                   period = period,
                                   balanced = TRUE)

  data <- data %>%
    rebeltrack_days_ongoing_gid(days_ongoing) %>%
    as.data.frame()

  columns <- c("priogrid_gid", "period_start", "period_end", "active", "days_ongoing")
  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)

  # days_ongoing is clipped to the period, so it can never exceed the
  # period's own length in days, and can never be negative.
  period_length <- as.integer(as.Date(data$period_end) - as.Date(data$period_start)) + 1
  expect_true(all(data$days_ongoing >= 0, na.rm = TRUE))
  expect_true(all(data$days_ongoing[!is.na(data$days_ongoing)] <=
                    period_length[!is.na(data$days_ongoing)]))
}

test_that("Weekly Days Ongoing are correct", {
  test_days_ongoing_gid(SIDE_A, "week")
  test_days_ongoing_gid(SIDE_B, "week")
})

test_that("Monthly Days Ongoing are correct", {
  test_days_ongoing_gid(SIDE_A, "month")
  test_days_ongoing_gid(SIDE_B, "month")
})
