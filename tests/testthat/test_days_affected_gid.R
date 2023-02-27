context("Test rebeltrack_days_affected_gid")

test_days_affected_gid <- function(side, period) {
  dataset <- rebeltrack_load_dataset()
  data <- rebeltrack_dataframe_gid(dataset,
                                   side = side,
                                   period = period,
                                   balanced = TRUE)

  data <- data %>%
    rebeltrack_days_affected_gid(days_affected) %>%
    as.data.frame()

  columns <- c("priogrid_gid", "period_start", "period_end", "active", "days_affected")
  expect_equal(ncol(data), length(columns))
  expect_named(data, columns)
}

test_that("Weekly Days Affected are correct", {
  test_days_affected_gid(SIDE_A, "week")
  test_days_affected_gid(SIDE_B, "week")
})

test_that("Monthly Days Affected are correct", {
  test_days_affected_gid(SIDE_A, "month")
  test_days_affected_gid(SIDE_B, "month")
})
