#' Days Affected by Events
#'
#' Calculate the number of distinct calendar days affected by ongoing
#' conflict (the union of every event's \code{date_start}-\code{date_end}
#' span, not double-counting overlapping events), grouped by
#' \code{priogrid_gid} and \code{period} specified when the
#' \code{RebelTrackDataFrameGid} was created with
#' \link{rebeltrack_dataframe_gid}.
#'
#' (Previously this counted only the number of distinct days on which
#' events *started*, ignoring how long each event actually lasted - fixed
#' 2026-07-10, see docs/STEP2_NOTES.md. This does not clip event spans to
#' period boundaries; see \code{rebeltrack_count_days_affected()}.)
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply. Must be a gid weight matrix to maintain dimensionality
#' @examples
#' library(rebeltrack)
#'
#' \dontrun{
#' dataset <- rebeltrack_load_dataset(type = UCDP_STATE_BASED)
#'
#' data <- rebeltrack_dataframe_gid(dataset,
#'                              period = "month",
#'                              balanced = TRUE)
#'
#' data <- rebeltrack_days_affected_gid(data, days_affected)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_days_affected_gid <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "priogrid_gid",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag_gid, constructor = .rebeltrack_dataframe_gid,
    summarise = function(group) dplyr::summarize(
      group, .var = rebeltrack_count_days_affected(date_start, date_end))
  )
}

