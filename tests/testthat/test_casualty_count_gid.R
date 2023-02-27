context("Test rebeltrack_casualty_count_gid")

test_casualty_counts_gid <- function(period) {
  dataset <- rebeltrack_load_dataset()
  data <- rebeltrack_dataframe_gid(dataset,
                               side = SIDE_B,
                               period = period,
                               balanced = TRUE)

  data <- data %>%
    rebeltrack_casualty_count_gid(casualty_count) %>%
    as.data.frame()

  columns <- c("priogrid_gid", "period_start", "period_end", "active",
               "casualty_count")

  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)
}

test_that("Weekly Casualty Counts are correct", {
  test_casualty_counts_gid("week")
})

test_that("Monthly Casualty Counts are correct", {
  test_casualty_counts_gid("month")
})
