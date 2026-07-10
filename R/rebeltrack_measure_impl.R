# Shared engine behind the actor/gid "measure" function pairs (casualty
# count, event count, days affected, distance to border/capital,
# (trans)national count/ratio). Before this file, every one of those had two
# near-identical implementations - one grouped by `actor`, one grouped by
# `priogrid_gid` - differing only in the grouping column, which S4 class
# constructs the result, and which weighted_lag engine applies the lag/
# weight step. This factors that shared skeleton into one place so each
# measure function only needs to say what's actually different about it.
#
# This is a purely internal refactor - every exported function name and
# signature is unchanged (rebeltrack_casualty_count(),
# rebeltrack_casualty_count_gid(), etc. all still exist exactly as before),
# so nothing that calls them needs to change. See dev-notes/STEP2_NOTES.md.
#
# weighted_lag()/weighted_lag_gid() themselves are NOT merged here even
# though they're also very similar, because they differ in a real,
# non-cosmetic way: weight_apply_gid() treats the weight matrix as a slam
# sparse array and converts it accordingly, while weight_apply() expects a
# plain dense array. Forcing those together risked changing behaviour for
# something this refactor couldn't verify by running R - so both are kept
# as two explicit, still-parallel engines, and `lag_engine` below just picks
# which one to call.

#' Shared implementation for actor/gid measure functions
#'
#' @param x A \code{RebelTrackDataFrame} or \code{RebelTrackDataFrameGid} object
#' @param group_col The grouping column for this measure (\code{actor} or \code{priogrid_gid})
#' @param var Name of the variable to create (already resolved to a string,
#'   e.g. via \code{rlang::quo_name(rlang::enquo(var))})
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply.
#' @param lag_engine \code{weighted_lag} or \code{weighted_lag_gid}
#' @param constructor \code{.rebeltrack_dataframe} or \code{.rebeltrack_dataframe_gid}
#' @param make_group A function(events, group_col) that returns a tibble
#'   grouped by \code{group_col} and \code{period_start} (after whatever
#'   intermediate mutate/group_by/summarize steps this particular measure
#'   needs), ready to be summarised. Defaults to \code{.simple_group()},
#'   which covers every measure that just groups by group_col and
#'   period_start with no intermediate stage.
#' @param summarise A function(group) that returns the group summary data
#'   frame via \code{dplyr::summarize(group, .var = value)}, where
#'   \code{value} is this measure's computed column
#' @keywords internal
.rebeltrack_measure_impl <- function(x, group_col, var, fill, lag, weight,
                                     lag_engine, constructor,
                                     summarise, make_group = .simple_group()) {
  group <- make_group(x@dataset@events, group_col)
  group_summary <- summarise(group)

  data <- x %>%
    lag_engine(var, group, group_summary, fill, lag, weight)

  constructor(dataset = x@dataset, data = data)
}

#' Build a \code{make_group} function for the common case: optionally
#' transform the raw events, then group by \code{group_col} and
#' \code{period_start} with no intermediate grouping stage.
#'
#' @param prepare A function(events) applied before grouping (e.g. to add a
#'   derived column). Defaults to the identity function.
#' @keywords internal
.simple_group <- function(prepare = identity) {
  function(events, group_col) {
    events %>%
      prepare() %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(c(group_col, "period_start"))))
  }
}
