context("Test rebeltrack_casualty_count")

test_casualty_counts <- function(side, period) {
  dataset <- .rebeltrack_test_dataset()
  data <- rebeltrack_dataframe(dataset,
                               side = side,
                               period = period,
                               balanced = TRUE)

  data <- data %>%
    rebeltrack_casualty_count(SIDE_A, casualty_count_A) %>%
    rebeltrack_casualty_count(SIDE_B, casualty_count_B) %>%
    as.data.frame()

  columns <- c("actor", "period_start", "period_end", "active",
               "casualty_count_A", "casualty_count_B")

  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)
}

test_that("Weekly Casualty Counts are correct", {
  test_casualty_counts(SIDE_A, "week")
  test_casualty_counts(SIDE_B, "week")
})

test_that("Monthly Casualty Counts are correct", {
  test_casualty_counts(SIDE_A, "month")
  test_casualty_counts(SIDE_B, "month")
})

