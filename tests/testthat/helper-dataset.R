# Shared, session-cached dataset fixture for tests.
#
# rebeltrack_load_dataset() with no filters reads the full GED events,
# actors, and PRIO-GRID covariate RDS files from disk and joins them -
# expensive. Before this fixture, every test file called it independently
# (and several call it multiple times within one file, once per
# side/period combination under test), so a single devtools::test()/
# check() run redid that same full load-and-join 30+ times over. testthat
# sources every helper-*.R file once per session, before any test file
# runs, and keeps it in scope for all of them - so loading the dataset
# once here and having tests call .rebeltrack_test_dataset() instead of
# rebeltrack_load_dataset() directly cuts that down to one load for the
# whole suite.
.rebeltrack_test_dataset <- local({
  cached <- NULL
  function() {
    if (is.null(cached)) {
      cached <<- rebeltrack_load_dataset()
    }
    cached
  }
})
