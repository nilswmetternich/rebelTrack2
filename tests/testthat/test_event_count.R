context("Test rebeltrack_event_count")

test_event_counts <- function(side, period) {
  dataset <- .rebeltrack_test_dataset()
  data <- rebeltrack_dataframe(dataset,
                               side = side,
                               period = period,
                               balanced = TRUE)

  data <- data %>%
    rebeltrack_event_count(event_count) %>%
    as.data.frame()

  columns <- c("actor", "period_start", "period_end", "active", "event_count")
  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)
}

test_that("Weekly Event Counts are correct", {
  test_event_counts(SIDE_A, "week")
  test_event_counts(SIDE_B, "week")
})

test_that("Monthly Event Counts are correct", {
  test_event_counts(SIDE_A, "month")
  test_event_counts(SIDE_B, "month")
})
