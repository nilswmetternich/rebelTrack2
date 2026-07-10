#' Actors Present per Priogrid_gid
#'
#' Calculate the number of distinct actors present in each \code{priogrid}
#' and \code{period} specified when the \code{RebelTrackDataFrameGid} was
#' created with \link{rebeltrack_dataframe_gid}, counting an actor once
#' regardless of which side of an event it appears on.
#'
#' (rebeltrack_actors_active_gid was an exact duplicate of this function and
#' has been removed - use this one. See docs/STEP2_NOTES.md.)
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply.
#' @examples
#' library(rebeltrack)
#'
#' \dontrun{
#' dataset <- rebeltrack_load_dataset(type = UCDP_STATE_BASED)
#'
#' data <- rebeltrack_dataframe_gid(dataset,
#'                              side = SIDE_B,
#'                              period = "month",
#'                              balanced = TRUE)
#'
#' data <- rebeltrack_gid_actors_present(data, actors_present)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_actors_present_gid <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  # Was n_distinct(side_a) + n_distinct(side_b) - counts distinct side_a
  # actors and distinct side_b actors separately and adds them. That's only
  # correct when the two sides are guaranteed to be disjoint sets of actors
  # (true for UCDP_STATE_BASED, where side_a is always the state and side_b
  # always the rebel group) - for other event types (e.g. UCDP_NON_STATE,
  # where two non-state groups can appear as either side across different
  # events, or interstate conflicts) the same actor could be counted twice.
  # n_distinct(c(side_a, side_b)) counts each actor once regardless of
  # role, giving the same answer as before whenever the sides really are
  # disjoint, and the correct answer when they're not.
  .rebeltrack_measure_impl(
    x, group_col = "priogrid_gid",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag_gid, constructor = .rebeltrack_dataframe_gid,
    summarise = function(group) dplyr::summarize(
      group, .var = dplyr::n_distinct(c(side_a, side_b)))
  )
}
