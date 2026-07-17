context("Test rebeltrack_load_dataset (exclude_interstate)")

test_that("exclude_interstate = TRUE drops state-based rows with a government side B", {
  with_interstate <- .rebeltrack_test_dataset()  # exclude_interstate = FALSE
  without_interstate <- rebeltrack_load_dataset(exclude_interstate = TRUE)

  # gwnob must actually be present in the real GED data for this filter to
  # do anything - if it isn't, rebeltrack_exclude_interstate() warns and
  # no-ops, and this test would otherwise pass vacuously.
  expect_true("gwnob" %in% names(with_interstate@events))

  state_based_with <- dplyr::filter(with_interstate@events,
                                    type_of_violence == UCDP_STATE_BASED)
  n_interstate <- sum(!is.na(state_based_with$gwnob))

  # There should be at least one interstate row in the real data (e.g.
  # Ethiopia-Eritrea, India-Pakistan) for this to be a meaningful check.
  expect_gt(n_interstate, 0)

  expect_equal(nrow(without_interstate@events),
              nrow(with_interstate@events) - n_interstate)

  # No remaining state-based row should have a government side B.
  state_based_without <- dplyr::filter(without_interstate@events,
                                       type_of_violence == UCDP_STATE_BASED)
  expect_true(all(is.na(state_based_without$gwnob)))
})

test_that("exclude_interstate has no effect on non-state or one-sided events", {
  non_state_with <- rebeltrack_load_dataset(type = UCDP_NON_STATE,
                                            exclude_interstate = FALSE)
  non_state_without <- rebeltrack_load_dataset(type = UCDP_NON_STATE,
                                               exclude_interstate = TRUE)
  expect_equal(nrow(non_state_with@events), nrow(non_state_without@events))

  one_sided_with <- rebeltrack_load_dataset(type = UCDP_ONE_SIDED,
                                            exclude_interstate = FALSE)
  one_sided_without <- rebeltrack_load_dataset(type = UCDP_ONE_SIDED,
                                               exclude_interstate = TRUE)
  expect_equal(nrow(one_sided_with@events), nrow(one_sided_without@events))
})

test_that("rebeltrack_exclude_interstate() degrades gracefully if gwnob is missing", {
  fake_ged <- data.frame(type_of_violence = c(UCDP_STATE_BASED, UCDP_STATE_BASED),
                         side_a_new_id = c(1, 1), side_b_new_id = c(2, 3))
  expect_warning(result <- rebeltrack_exclude_interstate(fake_ged, TRUE),
                 "gwnob")
  expect_equal(nrow(result), 2)  # no-op: nothing dropped
})
