context("Test rebeltrack_event_count_gid")

test_event_counts_gid <- function(side, period) {
  dataset <- rebeltrack_load_dataset()
  data <- rebeltrack_dataframe_gid(dataset,
                               side = side,
                               period = period,
                               balanced = TRUE)

  data <- data %>%
    rebeltrack_event_count_gid(event_count) %>%
    as.data.frame()

  columns <- c("priogrid_gid", "period_start", "period_end", "active", "event_count")
  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)
}

test_that("Weekly Gid Event Counts are correct", {
  test_event_counts_gid(SIDE_A, "week")
  test_event_counts_gid(SIDE_B, "week")
})

test_that("Monthly Gid Event Counts are correct", {
  test_event_counts_gid(SIDE_A, "month")
  test_event_counts_gid(SIDE_B, "month")
})
