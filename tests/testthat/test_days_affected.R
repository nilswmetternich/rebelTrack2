context("Test rebeltrack_days_affected")

test_days_affected <- function(side, period) {
  dataset <- .rebeltrack_test_dataset()
  data <- rebeltrack_dataframe(dataset,
                               side = side,
                               period = period,
                               balanced = TRUE)

  data <- data %>%
    rebeltrack_days_affected(days_affected) %>%
    as.data.frame()

  columns <- c("actor", "period_start", "period_end", "active", "days_affected")
  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)
}

test_that("Weekly Days Affected are correct", {
  test_days_affected(SIDE_A, "week")
  test_days_affected(SIDE_B, "week")
})

test_that("Monthly Days Affected are correct", {
  test_days_affected(SIDE_A, "month")
  test_days_affected(SIDE_B, "month")
})
